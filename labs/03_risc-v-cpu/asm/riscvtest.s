# riscvtest.s
# Sarah.Harris@unlv.edu
# David_Harris@hmc.edu
# 27 Oct 2020
#
# Test the RISC-V processor:
#
add, sub, and, or, slt, addi, lw, sw, beq, jal
# If successful, it should write the value 25 to address 100
#
RISC-V Assembly
Description
Address
addi x2, x0, 5
# x2 = 5
main:
0
addi x3, x0, 12
# x3 = 12
4
addi x7, x3, -9
# x7 = (12 - 9) = 3
8
or
x4, x7, x2
# x4 = (3 OR 5) = 7
C
and x5, x3, x4
# x5 = (12 AND 7) = 4
10
add x5, x5, x4
# x5 = 4 + 7 = 11
14
beq x5, x7, end
# shouldn't be taken
18
slt x4, x3, x4
# x4 = (12 < 7) = 0
1C
beq x4, x0, around
# should be taken
20
addi x5, x0, 0
# shouldn't execute
24
around: slt x4, x7, x2
# x4 = (3 < 5) = 1
28
add x7, x4, x5
# x7 = (1 + 11) = 12
2C
sub x7, x7, x2
# x7 = (12 - 5) = 7
30
sw
x7, 84(x3)
# [96] = 7
34
lw
x2, 96(x0)
# x2 = [96] = 7
38
add x9, x2, x5
# x9 = (7 + 11) = 18
3C
jal x3, end
# jump to end, x3 = 0x44
40
addi x2, x0, 1
# shouldn't execute
44
end:
add x2, x2, x9
# x2 = (7 + 18) = 25
48
sw
x2, 0x20(x3)
# [100] = 25
4C
done:
beq x2, x2, done
# infinite loop
50
Machine Code
00500113
00C00193
FF718393
0023E233
0041F2B3
004282B3
02728863
0041A233
00020463
00000293
0023A233
005203B3
402383B3
0471AA23
06002103
005104B3
008001EF
00100113
00910133
0221A023
00210063