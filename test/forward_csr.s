        lui x1,0xfefe0
        addi x1,x1,-773 /* fefdfcfb */
        lui x4,0xaaaab
        addi x4,x4,-1366 /* aaaaaaaa */
        csrrw x2,0x340,x1
        csrrw x3,0x341,x2
        csrrc x0,0x340,x4

_forever:
        jal x0,_forever
