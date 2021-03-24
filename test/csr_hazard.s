        .section .text.vector
        addi x0,x0,0

        .section .text
        csrrwi x0,mtval,4
        csrrc x1,mtval,x0
_forever:
        jal x0,_forever
