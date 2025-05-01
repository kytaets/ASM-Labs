.386
option casemap:none

include \masm32\include\masm32rt.inc

.data?
	VVTWindowBuffer	                  db 256	dup (?)
	VVTkytaecpositiveDStringBuffer	db 32 	dup (?)
	VVTkytaecnegativeDStringBuffer	db 32 	dup (?)
	VVTkytaecpositiveEStringBuffer	db 32 	dup (?)
	VVTkytaecnegativeEStringBuffer	db 128	dup (?)
	VVTkytaecpositiveFStringBuffer	db 128	dup (?)
	VVTkytaecnegativeFStringBuffer	db 128	dup (?)

.data
	VVTkytaecTitle 		db 	"Студент № 3222 Токовенко Владислав ІМ-32", 0
	
	VVTkytaecMsgBox		db 	"ДН (дата народження) : 19.04.2006", 10, 10,
							"N (№ зал. книжки) = 3222", 10,
							"A = %d, -A = %d", 10,
							"B = %d, -B = %d", 10,
							"C = %d, -C = %d", 10,
							"D = %s, -D = %s", 10,
							"E = %s, -E = %s", 10,
							"F = %s, -F = %s", 0

      VVTkytaecBD             db    "19042006", 0														
	VVTkytaecposAByte		db 	19
	VVTkytaecnegAByte		db 	-19
	VVTkytaecposAWord		dw 	19
	VVTkytaecposBWord		dw 	1904
	VVTkytaecnegAWord		dw 	-19
	VVTkytaecnegBWord		dw 	-1904
	VVTkytaecposAShortInt	dd 	19
	VVTkytaecposBShortInt	dd 	1904
	VVTkytaecposCShortInt	dd 	19042006
	VVTkytaecnegAShortInt	dd 	-19
	VVTkytaecnegBShortInt	dd 	-1904
	VVTkytaecnegCShortInt	dd 	-19042006
	VVTkytaecposDSingle	dd 	0.006
	VVTkytaecnegDSingle	dd 	-0.006
	VVTkytaecposALongInt	dq 	19
	VVTkytaecposBLongInt	dq 	1904
	VVTkytaecposCLongInt	dq 	19042006
	VVTkytaecnegALongInt	dq 	-19
	VVTkytaecnegBLongInt	dq 	-1904
	VVTkytaecnegCLongInt	dq 	-19042006
	VVTkytaecposDDouble	dq 	0.006
	VVTkytaecposEDouble	dq 	0.591
	VVTkytaecposFDouble	dq 	5909.996
	VVTkytaecnegDDouble	dq 	-0.006
	VVTkytaecnegEDouble	dq 	-0.591
      VVTkytaecnegFDouble     dq     -5909.996
	positiveFExt	      dt 	5909.996
	negativeFExt	      dt 	-5909.996

	
.code
start:
	invoke FloatToStr2, VVTkytaecposDDouble, addr VVTkytaecpositiveDStringBuffer
	invoke FloatToStr2, VVTkytaecposEDouble, addr VVTkytaecpositiveEStringBuffer
	invoke FloatToStr2, VVTkytaecposFDouble, addr VVTkytaecpositiveFStringBuffer
	invoke FloatToStr2, VVTkytaecnegDDouble, addr VVTkytaecnegativeDStringBuffer
	invoke FloatToStr2, VVTkytaecnegEDouble, addr VVTkytaecnegativeEStringBuffer
	invoke FloatToStr2, VVTkytaecnegFDouble, addr VVTkytaecnegativeFStringBuffer
	
	invoke wsprintf,
		addr VVTWindowBuffer,
		addr VVTkytaecMsgBox,
		VVTkytaecposAShortInt,
		VVTkytaecnegAShortInt,
		VVTkytaecposBShortInt,
		VVTkytaecnegBShortInt,
		VVTkytaecposCShortInt,
		VVTkytaecnegCShortInt,
		addr VVTkytaecpositiveDStringBuffer,
		addr VVTkytaecnegativeDStringBuffer,
		addr VVTkytaecpositiveEStringBuffer,
		addr VVTkytaecnegativeEStringBuffer,
		addr VVTkytaecpositiveFStringBuffer,
		addr VVTkytaecnegativeFStringBuffer
	
	invoke MessageBox, NULL, addr VVTWindowBuffer, addr VVTkytaecTitle, MB_OK
	
	invoke ExitProcess, 0
end start