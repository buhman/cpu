_i_type:
        addi x31,x31,-1
        addi x31,x31,-2048
        addi x31,x31,2047

_s_type:
        sw x31,-2(x31)
        sw x31,-2048(x31)
        sw x31,2047(x31)

_b_type:
        .word 0xffff8fe3
        .word 0x01ff9463
        .word 0x01ff8063
        .word 0x7fff8fe3
        .word 0x81ff8063

_u_type:
        lui x31,0
        lui x31,1048575
        lui x31,524288

        jal x31,_j_type
_j_type:
        jal x31,_j_type
        jal x31,_j_type
