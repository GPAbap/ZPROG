*&---------------------------------------------------------------------*
*& Report  ZFI_PROG_ELIMINACOMPLEMENTOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFI_PROG_ELIMINACOMPLEMENTOS.

*********************** PARAMETRO
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS P_UUID TYPE ZAXNARE_EL032 OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
*********************** PARAMETRO

*&---------------------------------------------------------------------*
*& Start-of-Selection
*&---------------------------------------------------------------------*
START-OF-SELECTION.

IF P_UUID NE SPACE.

  CALL FUNCTION 'ZAXN_ELIMINA_PAGO'
  EXPORTING
    UUID_PAGO       = P_UUID.
*   IMPORTING
*     EX_RESULT       =
  .
  IF SY-SUBRC = 0.
    MESSAGE 'Complemento eliminado' TYPE 'S'.
  ELSE.
    MESSAGE 'Error inesperado' TYPE 'E'.
  ENDIF.

ENDIF.


END-OF-SELECTION.
