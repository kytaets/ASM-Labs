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
    Student_header_tok_vvt db "������� � ��3222", 0
    Stud_clolr_vvt db "Red", 0
    Vvt_19042006_age_date db "19.04.2006", 0

    Tok_vvt_stud_FIO_bd_num_msg_box db "ϲ� (�������, ��'�, �� �������) ��������: ��������� ��������� ³��������", 13, 10
               db "�.�. (���� ����������) ��������: 19.04.2006", 13, 10
               db "��� (����� ������� ������) ��������: ��3222", 13, 10
               db "������������: 121", 13, 10
               db "����� �����: ��-32", 13, 10
               db "����: 2", 13, 10
               db "����� ��������: ����", 13, 10
               db "������ ��������: ������ �������� (�����������)", 13, 10
               db "��������/���������� ������: ��������", 0

    Vvt_19042006_tok_message_view_data db "����������� ��� ��������?", 0
    Kytaec_name_525252_vvt db "��������� ��������� ³��������", 0
    Kytaec_age_525252_vvt dd 12345678h
    Kytaec_kurs_525252_vvt db "2 ����", 0
    Kytaec_color_525252_vvt db 0FFh, 0AAh, 055h, 0

.code
WinMain proc
      enter 0, 0
      invoke MessageBox, NULL, addr Vvt_19042006_tok_message_view_data, addr Student_header_tok_vvt, MB_OK
      invoke MessageBox, NULL, &Tok_vvt_stud_FIO_bd_num_msg_box, &Student_header_tok_vvt, MB_OK
      invoke ExitProcess, NULL
WinMain endp
end