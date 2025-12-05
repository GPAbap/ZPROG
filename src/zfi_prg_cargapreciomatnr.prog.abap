*&---------------------------------------------------------------------*
*& Report ZFI_PRG_CARGAPRECIOMATNR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_PRG_CARGAPRECIOMATNR.

INCLUDE ZFI_CARGAPRECIOMATNR_CLS.
INCLUDE ZFI_CARGAPRECIOMATNR_TOP.
INCLUDE ZFI_CARGAPRECIOMATNR_FN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM sub_file_f4.

START-OF-SELECTION.

PERFORM upload_matnrlist CHANGING lv_estado.

MESSAGE 'Proceso Terminado' Type 'S'.
