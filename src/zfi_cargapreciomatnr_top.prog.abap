*&---------------------------------------------------------------------*
*& Include          ZFI_CARGAPRECIOMATNR_TOP
*&---------------------------------------------------------------------*

  DATA: lt_file TYPE filetable,
        ls_file TYPE file_table,
        lv_rc   TYPE i,
        lv_ruta TYPE string,
        lv_estado type sy-subrc.

  DATA vl_filename TYPE rlgrap-filename.
  DATA: lo_uploader TYPE REF TO lcl_excel_uploader.
  DATA: it_zco_tt_matnrpres TYPE STANDARD TABLE OF zco_tt_matnrpres,
        wa_zco_tt_matnrpres LIKE LINE OF it_zco_tt_matnrpres.

TYPES: BEGIN OF st_listamateriales,
         kokrs TYPE kokrs,
         matnr TYPE matnr,
         netpr TYPE bprei,
         gjahr TYPE gjahr,
         row   TYPE c,
       END OF st_listamateriales.

*Tabla interna lista de materiales
DATA: it_listamateriales TYPE STANDARD TABLE OF st_listamateriales,
      wa_listamateriales LIKE LINE OF it_listamateriales.


*Parametros para pantalla principal.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  PARAMETERS:
    p_file      TYPE localfile OBLIGATORY.
  "  p_sheet     type i obligatory default 1.
SELECTION-SCREEN END OF BLOCK b1.
