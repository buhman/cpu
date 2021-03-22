        .section .text.vector
        addi x0,x0,0

        .section .text
_loop:
        lw x1,0(x0)
        addi x1,x0,1
        beq x1,x0,_loop

        addi x0,x0,123
_forever:
        jal x0,_forever
