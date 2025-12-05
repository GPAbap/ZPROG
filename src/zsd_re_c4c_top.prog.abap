*&---------------------------------------------------------------------*
*& Include zsd_re_c4c_top
*&---------------------------------------------------------------------*

TABLES: vbrk, vbrp, kna1,zsd_tt_c4c.

TYPE-POOLS: slis.
**WITH NON-UNIQUE SORTED KEY pk COMPONENTS ticket werks posnr,
DATA: it_outtable   TYPE STANDARD TABLE OF zsd_st_c4c WITH NON-UNIQUE SORTED KEY pk COMPONENTS vkorg vtweg spart vkbur vkgrp aubel vbeln posnr fkdat,
      wa_outtable   LIKE LINE OF it_outtable,
      it_zsd_tt_c4c TYPE STANDARD TABLE OF zsd_tt_c4c  WITH NON-UNIQUE SORTED KEY pk COMPONENTS vkorg vtweg spart vkbur vkgrp aubel vbeln posnr fkdat,
      wa_zsd_tt_c4c LIKE LINE OF it_zsd_tt_c4c.


*DATA: gv_cl_wsc4c TYPE REF TO zcpico_y6gowohay_ws_facturas.
DATA: gv_cl_wsc4c TYPE REF TO zcpico_yisaunlgy_ws_facturas.

DATA: vl_input    TYPE  zcpibo_facturas_create_reques4,
      vl_posicion TYPE zcpibo_facturas_create_req_tab,
      wa_posicion LIKE LINE OF vl_posicion,
      vl_output   TYPE zcpibo_facturas_create_confir3.

DATA: rg_kschl   TYPE RANGE OF prcd_elements-kschl,
      wa_rgkschl LIKE LINE OF rg_kschl.
DATA: cl_table TYPE REF TO zcl_tm_c4c.


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


DATA: lt_kna1 TYPE STANDARD TABLE OF kna1.



*
*
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
*
*  Select-OPTIONS:
*
*    s_kunag for  kna1-kunnr,
*    s_vkorg for vbrk-vkorg,
*    s_vtweg for vbrk-vtweg,
*    s_spart for vbrk-spart,
*    s_werks for vbrp-werks,
*    s_matnr for vbrp-matnr,
*    s_FKDAT for vbrk-fkdat,
*    s_prodh for vbrp-prodh,
*    s_vkbur for vbrp-vkbur,
*    s_bzirk for vbrk-bzirk,
*    s_vkgrp for vbrp-vkgrp,
*    s_vbeln for vbrk-vbeln.
*
*
*SELECTION-SCREEN END OF BLOCK b1.
