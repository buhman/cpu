        .section .text.vector
        addi x0,x0,0

        .section .text

        addi x1,x0,%lo(_here)
_loop:
        jalr x0,0(x1)
_here:
        addi x1,x0,%lo(_there)
        addi x0,x0,0x123
        jal x0,_loop
_there:
        addi x1,x0,%lo(_here)
        addi x0,x0,0x456
        jal x0,_loop
