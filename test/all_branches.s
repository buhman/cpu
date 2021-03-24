        .section .text.vector
        addi x0,x0,0

        .section .text
        addi x1,x0,1
        addi x2,x0,-1
        beq x0,x0,_eq
_eq:
        bne x0,x1,_neq
_neq:
        blt x0,x1,_lt
_lt:
        blt x2,x0,_lt_neg
_lt_neg:
        bltu x0,x1,_ltu
_ltu:
        bltu x0,x2,_ltu_neg
_ltu_neg:
        jal x0,_ltu_neg
