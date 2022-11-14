# Write an interesting pattern into LED MMR. 
# Set a variable as the MMR Address, then set the bit fields one by one (shifting in between)
addi s0, x0, 1
slli s0, s0, 16 # s0 = 32'h0001_0000, the MMR Address
# MMR is {led0[3:0], led1[3:0], red[7:0], green[7:0], blue[7:0]
# LED peripheral knows that the RGB led is active low.
# Can set low bits with immediate instructions, then shift left!
# Common technique (bit masking)
addi t0, x0, 8 # led0
slli t0, t0, 4 
addi t0, t0, 4 # led1
slli t0, t0, 4
addi t0, t0, 127 # half red
slli t0, t0, 8
addi t0, t0, 0 # no green
slli t0, t0, 8
addi t0, t0, 255 # full blue
sw t0, 0(s0)

# Write an interesting pattern into VRAM (DMA example)
# Set a variable as the start of VRAM
# Set loop from 0 to 320*240 of VRAM addresses
# t1 = 320*240. Too big for an immediate! Use a shift to get the right value
# for (t0 = 0; t0 < t1; t0 = t0 + 1)
#   t2 = s0 + t0
#   vram[t2] = t2
addi s0, x0, 2
slli s0, s0, 16 # s0 = x8 = 32'h0002_0000
addi t1, x0, 75 # t1 = x6 = 75
slli t1, t1, 10 # t1 = x6 = 76800 (320*240)
addi t0, x0, 0  # t0 = x5 = 0
LOOP_START: add t2, s0, t0 # t2 = x7 = x8 + x5
            sw t0, 0(t2)
            addi t0, t0, 1
            blt t0, t1, LOOP_START
DONE: beq x0, x0, DONE # infinite loop at end
