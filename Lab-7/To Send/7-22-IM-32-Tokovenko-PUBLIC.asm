.386
.model flat, stdcall
option casemap:none

public kytaecVVTok32CalcDenominator
extern kytaecVVTok32inputB:qword
extern kytaecVVTok32inputD:qword
extern kytaecVVTok32three:real8
extern kytaecVVTok32two:real8
extern kytaecVVTok32tempDenominator:tbyte

.code

; === Обчислення знаменника: 3*b - 2*d
kytaecVVTok32CalcDenominator proc
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]     ; отримуємо індекс з main.asm

    fld qword ptr [kytaecVVTok32inputB + eax*8] ; b
    fmul [kytaecVVTok32three]                  ; 3*b
    fld qword ptr [kytaecVVTok32inputD + eax*8] ; d
    fmul [kytaecVVTok32two]                    ; 2*d
    fsubp st(1), st(0)                         ; 3*b - 2*d
    fstp tbyte ptr [kytaecVVTok32tempDenominator]

    pop ebp
    ret 
kytaecVVTok32CalcDenominator endp

end
