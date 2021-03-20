        .section .text.vector
        addi x0,x0,0
        addi x0,x0,0
        addi x0,x0,0
        mret

        .section .text
        addi x1,x0,0
        sw x1,1(x0)
        ecall
_forever:
        addi x1,x1,1

        jal x0,_forever
