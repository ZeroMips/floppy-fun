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

The verilog code can decode the MFM stream, parse sector headers, read data,
verify CRC for sector and data. Read data gets pushed to a FIFO.

There is also a VGA out implementation with a test pattern generator.

To play with the bad apple demo, get the original images and transform them
to monochrome 640x40.

```
ffmpeg -i data/bad_apple_original.mp4 -an  -vf fps=10,scale=640:480 /tmp/bad_apple_orig%05d.png
mogrify -monitor -black-threshold 90% -type bilevel /tmp/bad_apple_orig*.png
```

Then it can be RLE encoded with minirle.py.

The testbench can be built with
```
verilator -Gclkspd=62500000 -Wall --trace --cc top.v floppy.v mfm_quantize.v mfm_sync.v mfm_bit_fifo.v sector_header.v sector_data.v vga_timing.v vga_patterngen.v --exe --build sim_main.cpp
```
