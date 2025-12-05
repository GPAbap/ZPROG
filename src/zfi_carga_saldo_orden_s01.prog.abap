*----------------------------------------------------------------------*
* Include ZFI_CARGA_SALDOS_S01                                         *
*----------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: P_RUTA  TYPE STRING     OBLIGATORY. " Ruta del archivo
SELECTION-SCREEN END OF BLOCK A1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_RUTA.
  PERFORM SEL_FILE CHANGING P_RUTA. " Selección del archivo origen
