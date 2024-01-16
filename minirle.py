# RLE pixel data in simple RLE
# Bit 15-1: count, Bit 0: color

from pathlib import Path
from PIL import Image

pathlist = sorted(Path('/tmp').glob('bad_apple_orig00084.png'))

max_len = 0
total = 0

disk_image = open("floppy.img", "wb")

for filename in pathlist:
	img = Image.open(str(filename))

	pix = img.convert('L').tobytes()

	img.close()

	ctr = 0
	last_pixel = 0
	rle = bytearray()

	for p in pix:
		if (ctr):
			if (last_pixel == p):
				ctr = ctr + 1
			else:
				rle += ((ctr << 1) | (1 if p else 0)).to_bytes(2,  byteorder='big')
				ctr = 0
			if (ctr == 32767):
				rle += ((ctr << 1) | (1 if p else 0)).to_bytes(2,  byteorder='big')
				ctr = 0
		else:
			ctr = ctr +1
		last_pixel = p

	if (ctr):
		rle += ((ctr << 1) | (1 if last_pixel else 0)).to_bytes(2,  byteorder='little')

	total = total + len(rle)
	if (len(rle) > max_len):
		max_len = len(rle)

	print(str(filename), len(rle), max_len, total)

	disk_image.write(rle)

disk_image.close()
