        .section .text.vector
        addi x0,x0,0
        addi x0,x0,0
        addi x0,x0,0
        mret

        .section .text
        csrrwi x0,mtvec,31
        ebreak
_forever:
        jal x0,_forever
