*&---------------------------------------------------------------------*
*& Include ztm_re_fletes_top
*&---------------------------------------------------------------------*

TABLES: "c_frtordgendatabasicfacts,"BY ctorfogen,
        "ctorfogen,
        /scmtms/d_torrot,
        likp,/scmtms/d_sf_rot,
        /scmtms/d_tchrgr, ekko,
        /sapapo/loc, adrc,dd07t.
        "c_transpchargeitemelement. "by ctchrgitemelem.
        "ctchrgitemelem.

TYPE-POOLS slis.

DATA: cl_table TYPE REF TO zcl_tm_fletes.

DATA: it_fletes TYPE STANDARD TABLE OF ztm_st_fletes.

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

  SELECT-OPTIONS: so_vbeln FOR likp-vbeln,
                  so_fecha FOR /scmtms/d_torrot-created_on OBLIGATORY,
                  so_bukrs FOR likp-kkber,
                  so_werks FOR likp-werks.
SELECTION-SCREEN END OF BLOCK b1.
