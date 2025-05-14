.386
.model flat, stdcall
option casemap:none

include \masm32\include\masm32rt.inc

.data
	VVTokKytaecEncryptedPassword db 25h, 33h, 37h, 1Dh, 0Eh, 47h, 79h, 57h, 4Bh, 0
	VVTokKytaecKey      db "secretKey", 0

	VVTokKytaecOkHeader        db "Access Granted!", 0
	VVTokKytaecNoHeader        db "Access Denied", 0

	VVTokKytaecStudentInfo       	db  "Student Full Name: Tokovenko Vladyslav Viktorovych", 13, 10,
								    								"B.D. (Birth Date): 19.04.2006", 13, 10,
								    								"ID (Student Book ID Number) : IM3222", 13, 10,
                                           "Speciality: 121", 0

	VVTokKytaecDissmissText		    db "Your password is wrong!", 0

.data?
	VVTokKytaecPasswordField    db 32 dup (?)
	VVTokKytaecEncryptedStr   db 32 dup (?)

.code

Exit proc
	invoke ExitProcess, 0
Exit endp

EncryptXOR proc uses esi edi ebx, inputString:DWORD, outputString:DWORD
	MOV ESI, inputString
	MOV EDI, outputString
	MOV EBX, offset VVTokKytaecKey
	MOV ECX, 0 

EncryptionLoopSequence:
	MOV AL, [ESI]       
	CMP AL, 0           
	JE EncryptionDoneSequence    
	XOR AL, [EBX]       
	MOV [EDI], AL       
	
	INC ESI             
	INC EDI            
	INC EBX             
	INC ECX             
	
	CMP BYTE PTR [EBX], 0 
	JNE EncryptionLoopSequence    
	MOV EBX, offset VVTokKytaecKey 
	JMP EncryptionLoopSequence

EncryptionDoneSequence:
	MOV BYTE PTR [EDI], 0 
	RET
EncryptXOR endp

Handler proc WindowHandle:dword, Unit:dword, WordPar:dword, LonPar:dword
	.if Unit == WM_COMMAND
		.if WordPar == IDOK
			invoke GetDlgItemText, WindowHandle, 999, addr VVTokKytaecPasswordField, 512
			invoke EncryptXOR, offset VVTokKytaecPasswordField, offset VVTokKytaecEncryptedStr
			invoke lstrcmp, offset VVTokKytaecEncryptedPassword, offset VVTokKytaecEncryptedStr
			
                  .if EAX == 0
                    invoke MessageBox, 0, offset VVTokKytaecStudentInfo, offset VVTokKytaecOkHeader, 0
			.else
				invoke MessageBox, 0, offset VVTokKytaecDissmissText, offset VVTokKytaecNoHeader, 0
			.endif

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
	Dialog "Lab3: Unencrypted Mode", "Arial", 12, \
	WS_SYSMENU or WS_OVERLAPPED or DS_CENTER, 4, 30, 30, 120, 80, 5555

	DlgStatic "Enter Password:", SS_CENTER, 11, 5, 90, 12, 555
	DlgEdit WS_BORDER, 7, 17, 100, 12, 999

	DlgButton "Cancel", WS_TABSTOP, 7, 35, 30, 15, IDCANCEL 
	DlgButton "OK", WS_TABSTOP,     76, 35, 30, 15 , IDOK
	
	CallModalDialog 0, 0, Handler, NULL

end start