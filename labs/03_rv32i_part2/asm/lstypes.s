# Load a bunch of values into memory locations 120 to 132. 
addi x1, x0, 17
sw x1, 120(x0)
addi x1, x1, 17
sw x1, 124(x0)
addi x1, x1, 17
sw x1, 128(x0)
addi x1, x1, 17
sw x1, 132(x0)
# Read them back out into registers to test lw.
lw x2, 120(x0)
lw x3, 124(x0)
lw x4, 128(x0)