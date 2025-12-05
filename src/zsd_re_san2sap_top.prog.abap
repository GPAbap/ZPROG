*&---------------------------------------------------------------------*
*& Include          ZSD_RE_SAN2SAP_TOP
*&---------------------------------------------------------------------*
TABLES: vbak, vbap,zsd_tt_plantsan, zsd_tt_pedticsan, zsd_tt_pedcreaut,
        zsd_tt_logsanh, zsd_tt_logsanp.

TYPE-POOLS: slis.
TYPES: SLIS.
TYPES: BEGIN OF st_nocreados,
         fecha   TYPE datum,
         werks   TYPE werks_d,
         ticket  TYPE char13,
         pos     TYPE posnr,
         auart   TYPE auart,
         vkorg   TYPE vkorg,
         vtweg   TYPE vtweg,
         spart   TYPE spart,
         route   TYPE route,
         lgort   TYPE lgort_d,
         bstdk   TYPE bstdk,
         sold    TYPE kunnr,
         name1   TYPE name1,
         bmeng   TYPE kwmeng,
         kbetr   TYPE kbetr,
         message TYPE zmensaje,
       END OF st_nocreados.

DATA: it_nocreados TYPE STANDARD TABLE OF st_nocreados,
      wa_nocreados LIKE LINE OF it_nocreados.

DATA: it_creados  TYPE STANDARD TABLE OF zsd_st_creadosan,
      it_creadosh TYPE STANDARD TABLE OF zsd_st_creadosanh.

DATA: lc_archivo TYPE string,
      lv_file    TYPE string.

*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

********para ALV
DATA: ti_header TYPE slis_t_listheader,
      st_header TYPE slis_listheader,
      ti_sort   TYPE slis_t_sortinfo_alv,
      st_sort   TYPE slis_sortinfo_alv.

**********Alv Jerarquico
DATA: st_keyinfo TYPE slis_keyinfo_alv,
      lt_sort    TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      gt_events  TYPE slis_t_event,
      lf_layout  TYPE slis_layout_alv.    "Manejar diseño de layout
