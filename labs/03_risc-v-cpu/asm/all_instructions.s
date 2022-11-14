lb x1, 0(x0)
lh x2, 14(x1)
lw x3, 8(x1)
lbu x4, 16(x1)
lhu x5, -32(x1)
addi x1, x0, 17
slli x2, x1, 4
slti x3, x2, 1000
sltiu x4, x2, 1000
xori x5, x2, 479
srli x6, x2, 3
srai x7, x2, 10
ori x8, x2, 2044 # comment check
andi x9, x8, 100
label_a: auipc x31, 0
# full line comment check
sb x1, 0(x9)
sh x2, 2(x9)
sw x3, 4(x9)
add a5, a6, a7
sub s2, s3, s4
sll s5, s6, s9
slt x1, x1, x1
sltu x1, x2, x3
xor t0, t1, t2
srl ra, sp, gp
sra tp, s0, fp
or s1, a0, a1
and a2, a3, a4
lui x1, 383
label_b: 
beq x0, x0, label_a 
label_c:
bne x0, x0, label_b
label_d:
blt x0, x0, label_c
bge x0, x0, label_d
bltu x0, x0, label_a
bgeu x0, x0, label_b
jalr sp, ra, 16
jal ra, label_a

