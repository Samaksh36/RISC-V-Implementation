addi x1, x0, 4
addi x4,x0,16
addi x6,x0,35
addi x9,x0,51
sw x1,4(x0)
addi x10,x4,15
sub x10,x6,x4
sll x9,x4,x1
sub x20, x6, x4
and x7,x6,x4
or x8,x6,x11
lw x3, 0(x1)
beq x20, x10, 12
add x9,x9,x10
sra x5, x4,x1
sub x4,x1,x0
sub x6,x3,x0
and x28,x8,x3
sub x9,x0,x5
sw x1,4(x0)
addi x10,x4,15
sub x10,x6,x4
sll x9,x4,x1
beq x20, x0, 4
sub x20, x6, x4
and x7,x6,x4