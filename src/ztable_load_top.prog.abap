" LOAD_TABLES*&---------------------------------------------------------------------*
*& Include ztable_load_top
*&---------------------------------------------------------------------*

FIELD-SYMBOLS: <t> ,  "Points to Table work area
               <fd>.     "Points to Table Field


TYPES:BEGIN OF st_outtable,
        bukrs TYPE bukrs,
        ofvta TYPE vkbur,
        vbeln TYPE vbeln,
        url   TYPE char300,
      END OF st_outtable.

DATA it_outtable TYPE STANDARD TABLE OF st_outtable.
data it_zcfdi type STANDARD TABLE OF ZSD_CFDI_TIMBRE.

data p_ok type c.

"Especificar Tabla "Z"
*SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
*  PARAMETER : p_table LIKE dd03l-tabname OBLIGATORY DEFAULT 'ZSD_CFDI_TIMBRE' . "tabla
*  "PARAMETER: p_delete AS CHECKBOX.  "borrar tabla
*SELECTION-SCREEN END OF BLOCK b01.
"Especificar Archivo de Carga
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETER : p_file TYPE rlgrap-filename OBLIGATORY.    "archivo
SELECTION-SCREEN END OF BLOCK b02.
