        .section .text.vector
        addi x0,x0,0

        .section .text
        addi x0,x0,1
        jal x0,_here
        addi x0,x0,2
        addi x0,x0,3
        addi x0,x0,4
_here:
        addi x0,x0,5
        addi x0,x0,6
        addi x0,x0,7
        addi x0,x0,8
