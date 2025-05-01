OPTION DOTNAME
option casemap:none

include \masm64\include\temphls.inc
include \masm64\include\win64.inc
include \masm64\include\kernel32.inc
includelib \masm64\lib\kernel32.lib
include \masm64\include\user32.inc
includelib \masm64\lib\user32.lib
includelib \masm64\include\fpu.inc
includelib \masm64\include\shell32.inc
includelib \masm64\lib\Shell32.Lib


.data
    Student_header_tok_vvt db "Студент № ІМ3222", 0
    Stud_clolr_vvt db "Red", 0
    Vvt_19042006_age_date db "19.04.2006", 0

    Tok_vvt_stud_FIO_bd_num_msg_box db "ПІБ (Прізвище, ім'я, по батькові) студента: Токовенко Владислав Вікторович", 13, 10
               db "Д.Н. (Дата народження) студента: 19.04.2006", 13, 10
               db "НЗК (Номер залікової книжки) студента: ІМ3222", 13, 10
               db "Спеціальність: 121", 13, 10
               db "Номер групи: ІМ-32", 13, 10
               db "Курс: 2", 13, 10
               db "Форма навчання: Очна", 13, 10
               db "Формат навчання: Онлайн навчання (дистанційне)", 13, 10
               db "Бюджетна/контрактна основа: Бюджетна", 0

    Vvt_19042006_tok_message_view_data db "Переглянути дані студента?", 0
    Kytaec_name_525252_vvt db "Токовенко Владислав Вікторович", 0
    Kytaec_age_525252_vvt dd 12345678h
    Kytaec_kurs_525252_vvt db "2 курс", 0
    Kytaec_color_525252_vvt db 0FFh, 0AAh, 055h, 0

.code
WinMain proc
      enter 0, 0
      invoke MessageBox, NULL, addr Vvt_19042006_tok_message_view_data, addr Student_header_tok_vvt, MB_OK
      invoke MessageBox, NULL, &Tok_vvt_stud_FIO_bd_num_msg_box, &Student_header_tok_vvt, MB_OK
      invoke ExitProcess, NULL
WinMain endp
end