PROJ = mfm

PIN_DEF = nandland-go.pcf
DEVICE = hx1k
PACKAGE = vq100

all: $(PROJ).bin

SRC :=  floppy.v mfm_quantize.v mfm_sync.v mfm_bit_fifo.v sector_header.v sector_data.v \
Binary_To_7Segment.v vga_timing.v vga_rle.v FIFO.v RAM_2Port.v top.v

%.json: $(SRC)
	verilator --lint-only --top-module top $(SRC)
	yosys -p 'synth_ice40 -top top -json $@' $(SRC)

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --asc $@ --pcf $< --json $*.json

%.bin: %.asc
	icepack $< $@
