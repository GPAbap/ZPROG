*&---------------------------------------------------------------------*
*& Include          ZMM_RE_OC_DETALLE_TOP
*&---------------------------------------------------------------------*
TABLES: zmmt001, zmmt003, lfa1, mara.
TYPES: slis.

TYPES: BEGIN OF st_outtable.
         INCLUDE  STRUCTURE zmmt001.
TYPES:   ebelp    TYPE zmmt003-ebelp,
         matnr    TYPE zmmt003-matnr,
         csur     TYPE zmmt003-csur,
         nom_prov TYPE lfa1-name1,
         nom_mat  TYPE makt-maktx,
       END OF st_outtable.

DATA it_outtable TYPE STANDARD TABLE OF st_outtable.
DATA: go_alv    TYPE REF TO cl_salv_table,
      go_layout TYPE REF TO cl_salv_layout,
      gs_key    TYPE salv_s_layout_key,
      lo_columns TYPE REF TO cl_salv_columns_table,
      lo_column  TYPE REF TO cl_salv_column.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS p_mjahr TYPE mjahr OBLIGATORY.

  SELECT-OPTIONS: s_lifnr FOR zmmt001-lifnr,
                  s_consec FOR zmmt001-conse,
                  s_ebeln FOR zmmt001-ebeln,
                  s_erdat FOR zmmt001-erdat.
SELECTION-SCREEN END OF BLOCK b1.
