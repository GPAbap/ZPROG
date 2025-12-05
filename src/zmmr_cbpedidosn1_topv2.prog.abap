*&---------------------------------------------------------------------*
*& Include ZMMR_CBPEDIDOSTOP                                 Report ZMMR_CBPEDIDOS
*&
*&---------------------------------------------------------------------*

REPORT   zmmr_cbpedidos.
TABLES: ekko,
        ekpo.
TABLES: zpedcom_env.
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
         datum     TYPE c LENGTH 10,
         uzeit     TYPE c LENGTH 8,
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
         wkurs     TYPE wkurs,
       END OF tt_alv.

*vmr
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
DATA   wa_cp TYPE ty_cp.
*vmr

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

DATA: vg_datum TYPE sy-datum,
      vg_uzeit TYPE sy-uzeit.

FIELD-SYMBOLS : <fs_alv> TYPE tt_alv.

************************************************************************
** Areas para manejo de txtos al final de venta principal  A. Huesca
************************************************************************


*CONSTANTS: c_long TYPE c LENGTH 3 VALUE 100.
****************
*
**TYPES: BEGIN OF ty_str,
**         linea TYPE c LENGTH 50,
**       END OF ty_str.
**DATA: it_str TYPE STANDARD TABLE OF ty_str.
**DATA: wa_str TYPE ty_str.
*
****************
*TYPES: BEGIN OF ty_textos,
*         LINE TYPE C LENGTH 100,
*       END OF ty_textos.
*DATA: ps_textos TYPE STANDARD TABLE OF ty_textos.
*DATA: wa_textos TYPE ty_textos.
*
****************
*DATA: wa_line TYPE tline.
*DATA: string  TYPE string.
*DATA: xstring TYPE xstring.
*DATA: t_line  TYPE tline OCCURS 0.
*DATA: VG_head TYPE thead.
*
****************
*DATA vg_str     TYPE ZMMR_STRING.
*DATA vg_pos     TYPE c LENGTH 6.
*DATA vg_size    TYPE c LENGTH 6.
*DATA vg_total   TYPE c LENGTH 6.
*DATA vg_totlin  TYPE c LENGTH 6.
*DATA result_tab TYPE match_result_tab.
*DATA wa_tab     TYPE match_result.
*
****************
*FIELD-SYMBOLS <scr> TYPE ty_textos.

DATA: gr_bsart  TYPE RANGE OF esart,
      gr_bsartn TYPE RANGE OF esart,
      gr_frgke  TYPE RANGE OF frgke,
      gr_frgken TYPE RANGE OF frgke,
      gr_bukrs  TYPE RANGE OF bukrs.

CONSTANTS: gc_zmm_cb020    TYPE string VALUE 'ZMM_CB020N',
           gc_zmm_cb020n   TYPE string VALUE 'ZMM_NO_LIB_CB',
           gc_cb020n_bukrs TYPE string VALUE 'ZMM_CB020N_BUKRS'.

************************************************************************
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
  parameters:     p_show   as checkbox.
SELECTION-SCREEN END OF BLOCK a1.
