; public.asm
.386
.model flat, stdcall
option casemap:none

public CalcDenominator
extern inputB:qword
extern inputD:qword
extern three:real8
extern two:real8
extern tempDenominator:tbyte

.code

CalcDenominator proc
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]     ; індекс у масивах (esi)

    fld qword ptr [inputB + eax*8]
    fmul [three]
    fld qword ptr [inputD + eax*8]
    fmul [two]
    fsubp st(1), st(0)
    fstp tbyte ptr [tempDenominator]

    pop ebp
    ret 4
CalcDenominator endp

end
