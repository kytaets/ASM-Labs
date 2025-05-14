.386
.model flat, stdcall
option casemap:none

include \masm32\include\masm32rt.inc

; ========== Макровизначення ==========
printInfoVVTok MACRO header, text
;; Макрос для виведення інформації у MessageBox
    invoke MessageBox, 0, offset text, offset header, 0
ENDM

encryptStringVVTok MACRO inputStr, outputStr
;; Макрос для шифрування рядка (XOR) з повною логікою

    LOCAL EncryptionLoop, EncryptionDone
    
    push esi
    push edi
    push ebx
    push ecx
    
    mov esi, offset inputStr
    mov edi, offset outputStr
    mov ebx, offset VVTokKytaecKey
    xor ecx, ecx
    
EncryptionLoop:
    mov al, [esi]
    test al, al
    jz EncryptionDone
    
    xor al, [ebx]
    mov [edi], al
    
    inc esi
    inc edi
    inc ebx
    inc ecx
    
    cmp byte ptr [ebx], 0
    jne EncryptionLoop
    mov ebx, offset VVTokKytaecKey
    jmp EncryptionLoop
    
EncryptionDone:
    mov byte ptr [edi], 0
    
    pop ecx
    pop ebx
    pop edi
    pop esi
ENDM

compareHashesVVTok MACRO hash1, hash2, successLabel, failLabel
;; Макрос для порівняння хеш-кодів

    LOCAL local_success, local_fail

    invoke lstrcmp, offset hash1, offset hash2
    .if EAX == 0
        jmp local_success
    .else
        jmp local_fail
    .endif

    local_success:
        jmp successLabel
    local_fail:
        jmp failLabel
ENDM

; ========== Дані ==========
.data
    VVTokKytaecEncryptedPassword db 25h, 33h, 37h, 1Dh, 0Eh, 47h, 79h, 57h, 4Bh, 0
    VVTokKytaecKey      db "secretKey", 0

    VVTokKytaecOkHeader        db "Access Granted!", 0
    VVTokKytaecNoHeader        db "Access Denied", 0

    ; Розділені дані про студента
    VVTokKytaecStudentName     db "Student Full Name: Tokovenko Vladyslav Viktorovych", 0
    VVTokKytaecBirthDate       db "Birth Date: 19.04.2006", 0
    VVTokKytaecStudentID       db "Student Book ID Number: IM3222", 0
    VVTokKytaecSpeciality      db "Speciality: 121", 0

    VVTokKytaecDissmissText    db "Your password is wrong!", 0

.data?
    VVTokKytaecPasswordField   db 32 dup (?)
    VVTokKytaecEncryptedStr    db 32 dup (?)

; ========== Код ==========
.code

Exit proc
    invoke ExitProcess, 0
Exit endp

Handler proc WindowHandle:dword, Unit:dword, WordPar:dword, LonPar:dword
    .if Unit == WM_COMMAND
        .if WordPar == IDOK
            invoke GetDlgItemText, WindowHandle, 999, addr VVTokKytaecPasswordField, 512
            
            ; Шифрування введеного пароля
            encryptStringVVTok VVTokKytaecPasswordField, VVTokKytaecEncryptedStr

            ; Порівняння хешів
            compareHashesVVTok VVTokKytaecEncryptedPassword, VVTokKytaecEncryptedStr, success, fail

            success:
                ; Виведення інформації у чотирьох окремих вікнах
                printInfoVVTok VVTokKytaecOkHeader, VVTokKytaecStudentName
                printInfoVVTok VVTokKytaecOkHeader, VVTokKytaecBirthDate
                printInfoVVTok VVTokKytaecOkHeader, VVTokKytaecStudentID
                printInfoVVTok VVTokKytaecOkHeader, VVTokKytaecSpeciality
                jmp end_handler

            fail:
                printInfoVVTok VVTokKytaecNoHeader, VVTokKytaecDissmissText

            end_handler:
        .endif

        .if WordPar == IDCANCEL
            call Exit
        .endif

    .elseif Unit == WM_CLOSE
        call Exit
    .endif

    return 0
Handler endp

start:
    Dialog "Lab4: Regular Mode", "Arial", 12, \
    WS_SYSMENU or WS_OVERLAPPED or DS_CENTER, 4, 30, 30, 120, 80, 5555

    DlgStatic "Enter Password:", SS_CENTER, 11, 5, 90, 12, 555
    DlgEdit WS_BORDER, 7, 17, 100, 12, 999

    DlgButton "Cancel", WS_TABSTOP, 7, 35, 30, 15, IDCANCEL 
    DlgButton "OK", WS_TABSTOP,     76, 35, 30, 15 , IDOK
    
    CallModalDialog 0, 0, Handler, NULL

end start