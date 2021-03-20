        .section .text.vector
        jal x0,_begin

        .section .text
_begin:
        addi x1,x0,0
        addi x2,x0,1
        addi x31,x0,254
_loop:
        addi x3,x2,0
        add x2,x2,x1
        sw x2,0(x0)
        addi x1,x3,0
        blt x3,x31,_loop
_forever:
        jal x0,_forever
