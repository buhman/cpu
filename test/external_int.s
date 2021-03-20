        .section .text.vector
        addi x0,x0,0
        addi x0,x0,0
        addi x0,x0,0
        mret
        addi x0,x0,0
        addi x0,x0,0
        addi x0,x0,0
        addi x0,x0,0
        addi x0,x0,0
        addi x0,x0,0
        addi x0,x0,0
        mret

        .section .text
_forever:
        lw x29,1(x0)
        addi x1,x0,1
        addi x2,x0,2
        addi x3,x0,3
        jal x0,_forever
