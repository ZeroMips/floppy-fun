# floppy-fun

This project is for learning about the ancient art of floppy disks and drives.

This is a nice resource for a deep dive into floppy data encoding: https://floppy.cafe/index.html

I have read a track from a disk using my trusty R&S scopes logic probe. It is sampled with 62.5 Megasamples, meaning there are 62.5 sample per microsecond.
The encoding is one byte per sample, with bit 0 being the Index pulse and bit 1 the actual read data.

## Python implementation

I have hacked together a little python script that decodes the MFM symbols S, M and L from the sample. It also looks for the first synchronization barrier.

### Python TODO

- read sector and verify crc
- see if there is any interesting data inside (I have no idea what is on the disk and which track I read)

## Verilog implementation

There is some verilog code for decoding the MFM stream.
The testbench can be built with
```
verilator -Wall --trace --cc mfm.v mfm_quantize.v mfm_sync.v mfm_bit_fifo.v --exe --build sim_main.cpp
```
