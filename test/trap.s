        .section .text.vector
        jal x0,_ins_misaligned
        ebreak /* instruction access fault */
        jal x0,_ins_illegal
        jal x0,_breakpoint
        jal x0,_load_misaligned
        ebreak /* load access fault */
        jal x0,_store_misaligned
        ebreak /* store access fault */
        ebreak /* ecall u-mode */
        ebreak /* ecall s-mode */
        ebreak /* reserved */
        jal x0,_m_ecall

        .section .text
        addi x0,x0,0
        jal x0,0x2

_ins_misaligned:
        lui x0,0xdead
        jal x0,_forever
_ins_illegal:
        lui x0,0xdead
        jal x0,_forever
_breakpoint:
        lui x0,0xdead
        jal x0,_forever
_load_misaligned:
        lui x0,0xdead
        jal x0,_forever
_store_misaligned:
        lui x0,0xdead
        jal x0,_forever
_m_ecall:
        lui x0,0xdead
        jal x0,_forever
_forever:
        jal x0,_forever
