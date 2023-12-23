ctr = 0
last_data = 0
mfm = ''

def classify(dt):
	if dt < 1.5:
		return 'ERROR'
	elif dt < 2.5:
		return 'S'
	elif dt < 3.5:
		return 'M'
	elif dt < 4.5:
		return 'L'
	else:
		return 'ERROR'

with open("WFM01.BIN", "rb") as f:
	while (byte := f.read(1)):
		if (last_data and not(byte[0] & 0x02)):
			dt = ctr / 62.5
			cl = classify(dt)
			mfm = mfm + cl 
			print(dt, 'us', classify(dt))
			ctr = 0
		else:
			ctr = ctr + 1
		last_data = byte[0] & 0x02

x = mfm.find('MLMLMSLMLMSLMLM')
print(x)
print(mfm)
