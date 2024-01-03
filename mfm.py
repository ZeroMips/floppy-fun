from enum import Enum
from construct import *

class MFMSym(Enum):
	S = 0
	M = 1
	L = 2
	ERROR = 3

class SyncState(Enum):
	WAIT_L0 = 0
	WAIT_M0 = 1
	WAIT_L1 = 2
	WAIT_M1 = 3
	DONE = 4

class ClockState(Enum):
	NO_SYNC = 0
	DATA_0 = 1
	DATA_1 = 2
	CLOCK_0 = 3
	CLOCK_1 = 4

class HeaderState(Enum):
	WAIT_A1 = 0
	WAIT_FX = 1
	WAIT_DATA = 2
	WAIT_CRC = 3

def classify(dt):
	if dt < 1.5:
		return MFMSym.ERROR
	elif dt < 2.5:
		return MFMSym.S
	elif dt < 3.5:
		return MFMSym.M
	elif dt < 4.5:
		return MFMSym.L
	else:
		return MFMSym.ERROR

# This is a state machine waiting for the symbol sequence 'LMLM' which is
# the MFM sync sequence. It is special because it contains an invalid clock bit.
# So it cannot be part of a regular symbol sequence.
def SyncMachine(sync_state, sym):
	if sync_state == SyncState.WAIT_L0:
		if sym == MFMSym.L:
			sync_state = SyncState.WAIT_M0
	elif sync_state == SyncState.WAIT_M0:
		if sym == MFMSym.M:
			sync_state = SyncState.WAIT_L1
		else:
			sync_state = SyncState.WAIT_L0
	elif sync_state == SyncState.WAIT_L1:
		if sym == MFMSym.L:
			sync_state = SyncState.WAIT_M1
		else:
			sync_state = SyncState.WAIT_L0
	elif sync_state == SyncState.WAIT_M1:
		if sym == MFMSym.M:
			sync_state = SyncState.DONE
		else:
			sync_state = SyncState.WAIT_L0
	else:
		sync_state = SyncState.WAIT_L0

	return sync_state

def Stream(stream, sym, clock_state):
	# these clock states can never be correct, because all symbols start with 1
	if clock_state == ClockState.DATA_1:
		clock_state = ClockState.NO_SYNC
	elif clock_state == ClockState.CLOCK_1:
		clock_state = ClockState.NO_SYNC

	if sym == MFMSym.S:
		stream.extend([1, 0])
		# clock state does not get modified
	elif sym == MFMSym.M:
		stream.extend([1, 0, 0])
		if clock_state == ClockState.DATA_0:
			clock_state = ClockState.CLOCK_0
		elif clock_state == ClockState.CLOCK_0:
			clock_state = ClockState.DATA_0
	elif sym == MFMSym.L:
		stream.extend([1, 0, 0, 0])
		# clock state does not get modified

	return clock_state

def Assemble(stream, read_idx, out):
	char = 0
	if len(stream) - read_idx >= 16:
		for k in range(0, 8):
			char = char | (stream[read_idx + 2 * k ] << 7 - k)
		out.append(char)
		read_idx = read_idx + 16
	return read_idx

with open("WFM01.BIN", "rb") as f:
	ctr = 0
	last_data = 0
	sync_state = SyncState.WAIT_L0
	stream = []
	symbols = []
	out = []
	blocks = []
	sectors = []
	read_idx = 0
	sync_done = 0
	clock_state = ClockState.NO_SYNC

	while (byte := f.read(1)):
		# read data falling edge
		if (last_data and not(byte[0] & 0x02)):
			last_stream = len(stream)
			last_out = len(out)
			dt = ctr / 62.5
			sym = classify(dt)
			symbols.append(sym)
			sync_state = SyncMachine(last_sync_state, sym)
			clock_state = Stream(stream, sym, clock_state)
			if (last_sync_state != sync_state) and (sync_state == SyncState.DONE):
				print('Sync done')
				read_idx = len(stream) - 14
				sync_done = 1
				clock_state = ClockState.CLOCK_0
				if len(out) > 3:
					blocks.append(out)
					out = []
			if sync_done:
				last_read_idx = read_idx
				read_idx = Assemble(stream, read_idx, out)
			ctr = 0
			print(dt, byte, sym, clock_state, stream[last_stream:len(stream)], [(hex(no),ascii(chr(no))) for no in out[last_out:len(out)]])
		else:
			ctr = ctr + 1
		last_data = byte[0] & 0x02
		last_sync_state = sync_state

	if len(out) > 3:
		blocks.append(out)
		out = []

	for block in blocks:
		try:
			d = Select(
				Struct(
					"Signature" / Const(b'\xa1\xa1\xa1'),
					"Type" / Const(b'\xfe'),
					"TrackNumber" / Byte,
					"Head" / Byte,
					"SectorNumber" / Byte,
					"SectorSize" / Byte,
					"CRC" / Int16ub
				),
				Struct(
					"Signature" / Const(b'\xa1\xa1\xa1'),
					"Type" / Select(Const(b'\xfa'), Const(b'\xfb')),
					"Data" / Array(512,Byte),
					"CRC" / Int16ub
				)
			)
			sectors.append(d.parse(bytes(block)))
		except (ConstError, SelectError):
			print("Could not parse")

#	print(symbols)
#	print(stream)
	print(sectors)
#	print([(hex(no),ascii(chr(no))) for no in out])

	with open('out.bin', 'wb') as wf:
		wf.write(bytes(out))
