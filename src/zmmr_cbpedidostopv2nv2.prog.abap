*&---------------------------------------------------------------------*
*&  Include           ZMMR_CBPEDIDOSTOPV2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include ZMMR_CBPEDIDOSTOP                                 Report ZMMR_CBPEDIDOS
*&
*&---------------------------------------------------------------------*


TABLES: ztm_tt_lounits,
        ekko,
        ekpo.
TYPE-POOLS: vrm, slis.

TYPES: BEGIN OF tt_alv,
         sel       TYPE c,
         ebeln     TYPE ebeln,
         bukrs     TYPE bukrs,
         bstyp     TYPE ebstyp,
         bsart     TYPE esart,
         statu     TYPE estak,
         aedat     TYPE erdat,
         ernam     TYPE ernam,
         lifnr     TYPE elifn,
         adrnr     TYPE adrnr,
         name1     TYPE name1_gp, " descripción proveedor tabla LFA1
         smtp_addr TYPE ad_smtpadr, " dirección de correo electrónico
         smtp_add1 TYPE ad_smtpadr,
         smtp_add2 TYPE ad_smtpadr,
         smtp_add3 TYPE ad_smtpadr,
         smtp_add4 TYPE ad_smtpadr,
         zterm     TYPE dzterm,
         ekorg     TYPE ekorg,
         ekgrp     TYPE bkgrp,
         waers     TYPE waers,
         bedat     TYPE ebdat,
         kdatb     TYPE kdatb,
         kdate     TYPE kdate,
         kunnr     TYPE kunnr,
         frgke     TYPE frgke,
         frgzu     TYPE frgzu,
         frgrl     TYPE frgrl,
         memory    TYPE memer,
         procstat  TYPE meprocstate,
       END OF tt_alv.


DATA: gt_fieldcat        TYPE slis_t_fieldcat_alv,
      gt_layout          TYPE slis_layout_alv,
      gt_alv             TYPE STANDARD TABLE OF tt_alv,
      gt_seleccion       TYPE STANDARD TABLE OF tt_alv,
      gs_alv             TYPE tt_alv,
      gcl_ref_grid       TYPE REF TO cl_gui_alv_grid,
      fcode              TYPE sy-ucomm,
      gv_noprint         TYPE c,
      lv_scontrol_param  TYPE ssfctrlop,
      lv_scomposer_param TYPE ssfcompop.

**********************CARTA PORTE*************
TYPES: BEGIN OF ty_cp,
         unidad     TYPE znounidad,
         stras      TYPE stras,
         pstlz      TYPE pstlz,
         regio      TYPE regio,
         ort01      TYPE ort01,
         werks      TYPE werks_d,

         strasd     TYPE stras,
         pstlzd     TYPE   pstlz,
         regiod     TYPE   regio,
         ort01d     TYPE   ort01,
         werksd     TYPE   werks_d,

         nounidad   TYPE  znounidad,
         marca      TYPE zmarca,
         tipounidad TYPE  ztipou,
         modelo     TYPE zmodelo,
         noplacas   TYPE  zplacas,
         nooperador TYPE  znooperador,
         pernr      TYPE persno,
         rfc        TYPE psg_idnum,
         lic        TYPE psg_idnum,
         asegura    TYPE char40,
         poliza     TYPE char12,
         permiso    TYPE char12,
       END OF ty_cp.

DATA: it_cp TYPE TABLE OF ty_cp,
      wa_cp LIKE LINE OF it_cp.

DATA: gr_bsart  TYPE RANGE OF esart,
      gr_bsartn TYPE RANGE OF esart,
      gr_frgke  TYPE RANGE OF frgke,
      gr_frgken TYPE RANGE OF frgke,
      gr_bukrs  TYPE RANGE OF bukrs.

CONSTANTS: gc_zmm_cb020   TYPE string VALUE 'ZMM_CB020',
           gc_zmm_cb020n  TYPE string VALUE 'ZMM_NO_LIB_CB',
           gc_cb020_bukrs TYPE string VALUE 'ZMM_CB020_BUKRS'.

FIELD-SYMBOLS : <fs_alv> TYPE tt_alv.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_ebeln  FOR ekko-ebeln,
                  s_ekorg  FOR ekko-ekorg OBLIGATORY,
                  s_bstyp  FOR ekko-bstyp NO-EXTENSION NO INTERVALS,
                  s_matnr  FOR ekpo-matnr NO-DISPLAY,
                  s_matkl  FOR ekpo-matkl NO-EXTENSION NO INTERVALS,
                  "s_bsart  FOR ekko-bsart,
                  s_ekgrp  FOR ekko-ekgrp,
                  s_lifnr  FOR ekko-lifnr,
                  s_reswk  FOR ekko-reswk,
                  s_bedat  FOR ekko-bedat.
  parameters:     p_show as checkbox.
SELECTION-SCREEN END OF BLOCK a1.
