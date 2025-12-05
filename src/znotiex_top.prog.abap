*&---------------------------------------------------------------------*
*& Include znotiex_top
*&---------------------------------------------------------------------*
TABLES: afko, afvc, afvv, crhd, afru.

DATA: it_layout TYPE STANDARD TABLE OF zst_layout_notifica_pm.

DATA : lr_excel_structure      TYPE REF TO data,
       lo_source_table_descr   TYPE REF TO cl_abap_tabledescr,
       lo_table_row_descriptor TYPE REF TO cl_abap_structdescr,
       lv_content              TYPE xstring,
       lt_binary_tab           TYPE TABLE OF sdokcntasc,
       lv_length               TYPE i,
       gv_filename             TYPE string.

DATA: it_tabemp   TYPE filetable,
      gd_subrcemp TYPE i.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t-001.
  SELECT-OPTIONS: so_aufnr FOR afko-aufnr OBLIGATORY.
  PARAMETERS p_file TYPE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
