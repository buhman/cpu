        .section .text.vector
        addi x0,x0,0

        .section .text
        addi x10,x0,0x4
        addi x11,x0,0x10
        addi x12,x0,0xee
        sw x10,0(x0)
        sw x11,0(x10)
        sw x12,0(x11)

        lw x2,0(x0)
        lw x2,0(x2)
        lw x2,0(x2)
        addi x4,x2,5
        addi x3,x2,0

        addi x0,x0,1
        addi x0,x0,2
        addi x0,x0,3
        addi x0,x0,4
        addi x0,x0,5
        addi x0,x0,6
        addi x0,x0,7
        addi x0,x0,8
        addi x0,x0,9
        addi x0,x0,10
