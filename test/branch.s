        .section .text.vector
        addi x0,x0,0

        .section .text
        beq x0,x0,_jump
        addi x0,x0,1
        addi x0,x0,2
        addi x0,x0,3
        addi x0,x0,4
        addi x0,x0,5
        addi x0,x0,6
_jump:
        addi x0,x0,7
        addi x0,x0,8
        beq x1,x0,_jump
        addi x0,x0,9
        addi x0,x0,10
        beq x0,x0,_jump
