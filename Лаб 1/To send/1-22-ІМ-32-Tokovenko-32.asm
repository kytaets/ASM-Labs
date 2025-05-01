.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\gdi32.inc
includelib \masm32\lib\gdi32.lib
include \masm32\include\advapi32.inc
includelib \masm32\lib\advapi32.lib
include \masm32\include\comdlg32.inc
includelib \masm32\lib\comdlg32.lib
include \masm32\include\shell32.inc
includelib \masm32\lib\shell32.lib

.data
    student_header_tok_vvt db "Студент № ІМ3222", 0
    stud_clolr_vvt db "Red", 0
    vvt_19042006_age_date db "19.04.2006", 0
    tok_vvt_stud_FIO_bd_num_msg_box db "ПІБ (Прізвище, ім'я, по батькові) студента: Токовенко Владислав Вікторович", 13, 10
               db "Д.Н. (Дата народження) студента: 19.04.2006", 13, 10
               db "НЗК (Номер залікової книжки) студента: ІМ3222", 13, 10
               db "Спеціальність: 121", 13, 10
               db "Номер групи: ІМ-32", 13, 10
               db "Курс: 2", 13, 10
               db "Форма навчання: Очна", 13, 10
               db "Формат навчання: Онлайн навчання (дистанційне)", 13, 10
               db "Бюджетна/контрактна основа: Бюджетна", 0
    vvt_19042006_tok_message_view_data db "Переглянути дані студента?", 0
    
    kytaec_name_525252_vvt db "Токовенко Владислав Вікторович", 0
    kytaec_age_525252_vvt dd 12345678h
    kytaec_kurs_525252_vvt db "2 курс", 0
    
    kytaec_color_525252_vvt db 0FFh, 0AAh, 055h, 0

.code
start:
    nop
    invoke MessageBox, NULL, addr vvt_19042006_tok_message_view_data, addr student_header_tok_vvt, MB_OK
    invoke MessageBox, NULL, addr tok_vvt_stud_FIO_bd_num_msg_box, addr student_header_tok_vvt, MB_OK
    nop
    mov ebx, offset kytaec_color_525252_vvt
    invoke ExitProcess, 0
end start