.386
.model flat, stdcall
option casemap:none

include \masm32\include\masm32rt.inc

.data
	VVTokKytaecPassword          db "VVTok3222", 0
	VVTokKytaecOkHeader         db "Access Granted!", 0
	VVTokKytaecNoHeader         db "Access Denied", 0

	VVTokKytaecStudentInfo      db "Student Full Name: Tokovenko Vladyslav Viktorovych", 13, 10,
	                             "B.D. (Birth Date): 19.04.2006", 13, 10,
	                             "ID (Student Book ID Number) : IM3222", 13, 10,
                                 "Speciality: 121", 0

	VVTokKytaecDissmissText     db "Your password is wrong!", 0

.data?
	VVTokKytaecPasswordField    db 32 dup (?)

.code

Exit proc
	invoke ExitProcess, 0
Exit endp

StrCompare proc uses esi edi, str1:DWORD, str2:DWORD
	mov esi, str1
	mov edi, str2

compareLoop:
	mov al, [esi]
	mov bl, [edi]
	cmp al, bl
	jne notEqual
	test al, al
	jz equal
	inc esi
	inc edi
	jmp compareLoop

equal:
	xor eax, eax
	ret

notEqual:
	mov eax, 1
	ret
StrCompare endp

CheckPassword proc uses ebx hwnd:dword
	invoke GetDlgItemText, hwnd, 999, addr VVTokKytaecPasswordField, 32
	invoke StrCompare, addr VVTokKytaecPassword, addr VVTokKytaecPasswordField
	test eax, eax
	jnz wrongPassword

	invoke MessageBox, hwnd, addr VVTokKytaecStudentInfo, addr VVTokKytaecOkHeader, MB_OK
	ret

wrongPassword:
	invoke MessageBox, hwnd, addr VVTokKytaecDissmissText, addr VVTokKytaecNoHeader, MB_ICONERROR
	ret
CheckPassword endp

Handler proc WindowHandle:dword, Unit:dword, WordPar:dword, LonPar:dword
	.if Unit == WM_COMMAND
		.if WordPar == IDOK
			call CheckPassword
		.elseif WordPar == IDCANCEL
			call Exit
		.endif
	.elseif Unit == WM_CLOSE
		call Exit
	.endif
	return 0
Handler endp

start:
	Dialog "Lab3: Secure Mode", "Arial", 12, \
	WS_SYSMENU or WS_OVERLAPPED or DS_CENTER, 4, 30, 30, 130, 85, 5555

	DlgStatic "Enter Password:", SS_CENTER, 10, 8, 100, 12, 555
	DlgEdit WS_BORDER, 9, 22, 110, 14, 999

	DlgButton "Cancel", WS_TABSTOP, 10, 45, 40, 18, IDCANCEL 
	DlgButton "OK", WS_TABSTOP,     80, 45, 40, 18, IDOK
	
	CallModalDialog 0, 0, Handler, NULL

end start
