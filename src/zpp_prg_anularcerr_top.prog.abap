*&---------------------------------------------------------------------*
*& Include          ZPP_PRG_ANULARCERR_TOP
*&---------------------------------------------------------------------*
tables: aufk, afpo.
TYPE-POOLS: SLIS.
INCLUDE <icon>.

types: BEGIN OF st_ordenes,
  aufnr type aufnr,
  werks type werks_d,
  auart type AUFART,
  erdat type AUFERFDAT,
  status(4) type c,
END OF st_ordenes.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      lf_layout   TYPE slis_layout_alv,    "Manejar diseño de layout
      t_sort      TYPE slis_t_sortinfo_alv,
      wa_sort     TYPE slis_sortinfo_alv.


data it_ordenes type STANDARD TABLE OF st_ordenes.

"batch input controller
DATA bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE.
DATA messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: l_mstring(480).
DATA: l_subrc LIKE sy-subrc.



  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
    SELECT-OPTIONS so_aufk FOR aufk-aufnr OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK b1.
