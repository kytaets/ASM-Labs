; ========== Макровизначення ==========

;; Макрос для виведення інформації у MessageBox
printInfoVVTok MACRO header, text
    invoke MessageBox, 0, offset text, offset header, 0
ENDM

;; Макрос для шифрування рядка (XOR) з повною логікою
encryptStringVVTok MACRO inputStr, outputStr
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

;; Макрос для порівняння хеш-кодів
compareHashesVVTok MACRO hash1, hash2, successLabel, failLabel
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