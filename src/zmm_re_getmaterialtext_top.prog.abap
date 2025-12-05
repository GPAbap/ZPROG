*&---------------------------------------------------------------------*
*& Include          ZMM_RE_GETMATERIALTEXT_TOP
*&---------------------------------------------------------------------*
TABLES: MARA, makt.
TYPE-POOLS: SLIS.

types: BEGIN OF st_materiales,
      matnr type matnr,
      maktx type maktx,
      texto type string,
  END OF st_materiales.

  data: it_materiales type STANDARD TABLE OF st_materiales.

*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

********para ALV
DATA: ti_header TYPE slis_t_listheader,
      st_header TYPE slis_listheader,
      lf_layout  TYPE slis_layout_alv.    "Manejar diseño de layout


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: so_matnr FOR mara-matnr.


SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN SKIP 1.
