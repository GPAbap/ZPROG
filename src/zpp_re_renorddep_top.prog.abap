*&---------------------------------------------------------------------*
*& Include zpp_re_renorddep_top
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

TABLES: resb, afko,afpo.

TYPES:BEGIN OF st_outtable,
        pwerks      TYPE pwerks,
        ltrmi       TYPE co_ltrmi,
        aufnr       TYPE aufnr,
        consumido   TYPE menge_d,
        pt          TYPE menge_d,
        rendimiento TYPE menge_d,
        Decomiso    TYPE menge_d,
        porc_decom  TYPE menge_d,
        diferencia  TYPE menge_d,
        Porcentaje  TYPE menge_d,
      END OF st_outtable.


DATA it_outtable TYPE STANDARD TABLE OF st_outtable.

*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

********para ALV
DATA: ti_header TYPE slis_t_listheader,
      st_header TYPE slis_listheader,
      ti_sort   TYPE slis_t_sortinfo_alv,
      st_sort   TYPE slis_sortinfo_alv,
      ti_event  TYPE slis_t_event,
      lf_layout TYPE slis_layout_alv.    "Manejar diseño de layout




SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: s_aufnr FOR afko-aufnr,
  s_ltrmi FOR afpo-ltrmi,
  s_pwerk FOR afpo-pwerk.

SELECTION-SCREEN END OF BLOCK b1.
