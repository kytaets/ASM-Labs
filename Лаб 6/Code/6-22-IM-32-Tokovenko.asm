.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\debug.inc

includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\debug.lib

.data?
    outputBuffer        db 1024 dup (?)
    tempDouble         dq ?
    denominatorValid   dd ?    ; Прапорець валідності знаменника
    logValid           dd ?    ; Прапорець валідності логарифма
    
.data
    inputA dq 2.5, 1.5, 0.5, 0.1, 7.5, -1.1
    inputB dq 1.2, 3.5, 2.5, 0.7, 2.2, 2.1
    inputC dq 0.8, 2.6, 0.1, 0.3, 9.6, 0.25
    inputD dq 0.4, 6.3, 0.6, 5.5, 3.3, 3.7
    
    windowTitle db "Lab 5. Floating Point Calculations. Var-22", 0
    messageFormat db "Expression: (ln(a + 4*c) - 1) / (3*b - 2*d)", 10, 10,
                 "Value of a: %s", 10,
                 "Value of b: %s", 10,
                 "Value of c: %s", 10,
                 "Value of d: %s", 10, 10,
                 "Result: %s", 0
    zeroDenominatorMsg db "Error: Division by zero (3*b - 2*d = 0)", 0
    logErrorMsg db "Error: Invalid logarithm argument (a + 4*c <= 0)", 0
    bothErrorsMsg db "Error: Both division by zero and invalid logarithm", 0

    iteration dd 0
    strA db 64 dup(?)
    strB db 64 dup(?)
    strC db 64 dup(?)
    strD db 64 dup(?)
    strResult db 64 dup(?)

    one      real8 1.0
    two      real8 2.0
    three    real8 3.0
    four     real8 4.0
    epsilon  real8 1.0e-10  ; Мале значення для порівняння з нулем

.code
start:
    mov esi, [iteration]
    
calculationLoop:
    finit
    mov [denominatorValid], 1  ; Вважаємо знаменник валідним
    mov [logValid], 1         ; Вважаємо логарифм валідним
    
    ; Обчислення знаменника (3*b - 2*d)
    fld qword ptr [inputB + 8*esi]    ; b
    fmul [three]                      ; 3*b
    fld qword ptr [inputD + 8*esi]    ; d, 3*b
    fmul [two]                        ; 2*d, 3*b
    fsubp st(1), st(0)                ; 3*b - 2*d
    
    ; Перевірка знаменника на 0 (з урахуванням epsilon)
    fabs                              ; Беремо модуль значення
    fcomp [epsilon]                   ; Порівнюємо з epsilon
    fstsw ax
    sahf
    jb denominator_zero               ; Якщо менше epsilon - вважаємо нулем
    
denominator_ok:
    ; Якщо знаменник не нуль, завантажуємо його знову
    fld qword ptr [inputB + 8*esi]    ; b
    fmul [three]                      ; 3*b
    fld qword ptr [inputD + 8*esi]    ; d, 3*b
    fmul [two]                        ; 2*d, 3*b
    fsubp st(1), st(0)                ; 3*b - 2*d
    fstp qword ptr [tempDouble]       ; Зберігаємо знаменник
    jmp check_numerator
    
denominator_zero:
    mov [denominatorValid], 0         ; Позначили невалідним
    fstp st(0)                        ; Очищаємо стек FPU
    
check_numerator:
    ; Обчислення аргументу логарифма (a + 4*c)
    fld qword ptr [inputC + 8*esi]    ; c
    fmul [four]                       ; 4*c
    fadd qword ptr [inputA + 8*esi]   ; a + 4*c
    
    ; Перевірка аргументу логарифма (a + 4*c > 0)
    ftst
    fstsw ax
    sahf
    ja log_ok                         ; Якщо > 0, все добре
    
    mov [logValid], 0                 ; Позначили невалідним
    
log_ok:
    ; Якщо обидві частини валідні, обчислюємо результат
    cmp [denominatorValid], 1
    jne check_errors
    cmp [logValid], 1
    jne check_errors
    
    ; Обчислення натурального логарифма
    fldln2
    fxch
    fyl2x                             ; ln(a + 4*c)
    fsub [one]                        ; ln(a + 4*c) - 1
    
    ; Ділення чисельника на знаменник
    fdiv qword ptr [tempDouble]       ; результат
    
    ; Збереження результату
    fstp qword ptr [tempDouble]
    
    ; Конвертація у рядки
    invoke FloatToStr2, [inputA + 8*esi], addr strA
    invoke FloatToStr2, [inputB + 8*esi], addr strB
    invoke FloatToStr2, [inputC + 8*esi], addr strC
    invoke FloatToStr2, [inputD + 8*esi], addr strD
    invoke FloatToStr2, [tempDouble], addr strResult
    
    ; Форматування виводу
    invoke wsprintf, addr outputBuffer, addr messageFormat,
        addr strA, addr strB, addr strC, addr strD, addr strResult
    
    jmp showResult

check_errors:
    ; Визначення типу помилки
    finit
    invoke FloatToStr2, [inputA + 8*esi], addr strA
    invoke FloatToStr2, [inputB + 8*esi], addr strB
    invoke FloatToStr2, [inputC + 8*esi], addr strC
    invoke FloatToStr2, [inputD + 8*esi], addr strD
    
    cmp [denominatorValid], 1
    je log_error_only
    cmp [logValid], 1
    je denominator_error_only
    
    ; Обидві помилки
    invoke wsprintf, addr outputBuffer, addr messageFormat,
        addr strA, addr strB, addr strC, addr strD, addr bothErrorsMsg
    jmp showResult
    
denominator_error_only:
    invoke wsprintf, addr outputBuffer, addr messageFormat,
        addr strA, addr strB, addr strC, addr strD, addr zeroDenominatorMsg
    jmp showResult
    
log_error_only:
    invoke wsprintf, addr outputBuffer, addr messageFormat,
        addr strA, addr strB, addr strC, addr strD, addr logErrorMsg
    
showResult:
    invoke MessageBox, 0, addr outputBuffer, addr windowTitle, MB_OK
    
    inc esi
    cmp esi, 6
    jne calculationLoop
    
    invoke ExitProcess, 0

end start