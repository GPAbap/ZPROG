*&---------------------------------------------------------------------*
*& Include zco_re_costo_prod_rentab_top
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.
"top
TABLES: Afko, afpo, mseg, bseg, mara, makt, mbewh, t009b,t001w .
TABLES: sscrfields.
INCLUDE <cl_alv_control>.
DATA obj_engorda TYPE REF TO zcl_cost_engorda_jhv.
DATA: it_aufnr_end     TYPE STANDARD TABLE OF zco_tt_aufnr_fin.
INCLUDE <icon>.

FIELD-SYMBOLS: <fs_outtable>   TYPE STANDARD TABLE, "tabla dinamica de salida
               <fs_outtable_o> TYPE STANDARD TABLE, "tabla dinamica de salida
               <linea>         TYPE any,                  "wa tabla dinamica
               <linea2>        TYPE any,
               <f_field>       TYPE any.
TYPES: BEGIN OF st_header,
         titulo1 TYPE string,
         titulo2 TYPE string,
         titulo3 TYPE string,
         titulo4 TYPE string,
       END OF st_header.

CONSTANTS sap_file_dev TYPE string VALUE '/sapmnt/datadev/'. "alv_export.csv'.
CONSTANTS sap_file_qas TYPE string VALUE '/sapmnt/dataqas/'. "alv_export.csv'.
CONSTANTS sap_file_pro TYPE string VALUE '/sapmnt/datapro/'. "alv_export.csv'.
CONSTANTS: c_rnsentero TYPE p DECIMALS 2 VALUE '2.30',
           c_rnscortes TYPE p DECIMALS 2 VALUE '2.30',
           c_rtc       TYPE p DECIMALS 2 VALUE '1.75',
           c_pintado   TYPE p DECIMALS 2 VALUE '2.35',
           c_hidratado TYPE p DECIMALS 2 VALUE '2.35',
           c_rhpcortes TYPE p DECIMALS 2 VALUE '2.35',
           c_limpiezas TYPE p DECIMALS 2 VALUE '2.10'.


TYPES: BEGIN OF st_aux_out,
         concepto   TYPE wgbez60,
         /cwm/menge TYPE /cwm/menge,
         piezas     TYPE menge_d,
         month      TYPE dmbtr_cs,
         monthst    TYPE dmbtr,
       END OF st_aux_out,

       BEGIN OF st_backlog,
         wgbez60 TYPE wgbez60,
         valor   TYPE menge_d,
       END OF st_BACKLOG,

       BEGIN OF st_mb51,
         aufnr    TYPE aufnr,
         matnr    TYPE matnr,
         matkl    TYPE matkl,
         wgbez60  TYPE wgbez60,
         werks    TYPE werks_d,
         menge    TYPE quan1_12, "menge_d,
         meins    TYPE meins,
         budat    TYPE budat,
         dmbtr    TYPE fins_vhcur12, "dmbtr_cs,
         dmbtr_st TYPE fins_vhcur12, "dmbtr_cs,
         awref    TYPE awref,
         awitem   TYPE awitem_rev,
         racct    TYPE racct,
       END OF st_mb51,

       BEGIN OF st_acdoca,
         aufnr  TYPE aufnr,
         racct  TYPE racct,
         txt50  TYPE txt50,
         hsl    TYPE fins_vhcur12,
         poper  TYPE poper,
         budat  TYPE budat,
         ryear  TYPE gjahr_pos,
         awref  TYPE awref,
         awitem TYPE awitem_rev,
         belnr  TYPE belnr_d,
         docln  TYPE docln6,
         werks  TYPE werks_d,
         rcntr  TYPE kostl,
       END OF st_acdoca,

       BEGIN OF st_kgs_cost_trans,
         "matnr TYPE matnr,
         menge TYPE menge_d,
         meins TYPE meins,
         dmbtr TYPE dmbtr_cs,
       END OF st_KGS_COST_TRANS,

       BEGIN OF st_flete_transf,
         kstar TYPE kstar,
         mes   TYPE wtgxxx,
       END OF st_FLETE_TRANSF,

       BEGIN OF st_ch_cost_trnsf,
         racct TYPE saknr,
         mes   TYPE fins_vhcur12,
       END OF st_ch_cost_trnsf,

       BEGIN OF st_kgs_vendidos,
         artnr TYPE matnr,
         mes   TYPE rke2_vvpnt,
       END OF st_kgs_vendidos,

       BEGIN OF st_pzas_pv,
         matnr TYPE matnr,
         spart TYPE spart,
         werks TYPE werks_d,
         absmg TYPE rke2_absmg, "piezas
         vvpnt TYPE rke2_vvpnt, "Kilos
         erlos TYPE rke2_erlos, "importe
         vvdrv TYPE rke2_vvdrv, "dev
         vvgdi TYPE rke2_vvgdi, "flete
       END OF st_pzas_pv ,

       BEGIN OF st_pzas_pro,
         matnr TYPE matnr,
         ferth TYPE ferth,
         msl   TYPE quan1_12,
         hsl   TYPE fins_vhcur12,
       END OF st_pzas_pro,

       BEGIN OF st_recupera, "
         aufnr    TYPE aufnr,
         matnr    TYPE matnr,
         matkl    TYPE matkl,
         wgbez60  TYPE maktx,
         werks    TYPE werks_d,
         menge    TYPE menge_d,
         meins    TYPE meins,
         budat    TYPE budat,
         dmbtr    TYPE fins_vhcur12, "dmbtr_cs,
         dmbtr_st TYPE fins_vhcur12, "dmbtr_cs,
         awref    TYPE awref,
         awitem   TYPE awitem_rev,

       END OF st_recupera.


DATA: it_aux_out         TYPE STANDARD TABLE OF st_aux_out,
      wa_aux_out         LIKE LINE OF it_aux_out,
      it_mb51            TYPE STANDARD TABLE OF st_mb51,
      it_kg_cost_trans   TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_menudencia   TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_merma        TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_harina       TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_rns          TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_pro_merma    TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_cad_h        TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_flete_transf    TYPE STANDARD TABLE OF st_flete_transf,
      it_vtas_netas      TYPE STANDARD TABLE OF st_flete_transf,
      it_kgs_vendidos    TYPE STANDARD TABLE OF st_kgs_vendidos,
      it_gtos_dist       TYPE STANDARD TABLE OF st_flete_transf,
      it_gtos_dist_ppa   TYPE STANDARD TABLE OF st_flete_transf,
      it_gtos_dist_pv    TYPE STANDARD TABLE OF st_flete_transf,
      it_gtos_ventas     TYPE STANDARD TABLE OF st_flete_transf,
      it_gtos_ventas_ppa TYPE STANDARD TABLE OF st_flete_transf,
      it_gtos_ventas_pv  TYPE STANDARD TABLE OF st_flete_transf,
      it_gtos_admon      TYPE STANDARD TABLE OF st_flete_transf,
      it_gtos_admon_ppa  TYPE STANDARD TABLE OF st_flete_transf,
      it_gtos_admon_pv   TYPE STANDARD TABLE OF st_flete_transf,
      it_ch_cost_trsf    TYPE STANDARD TABLE OF st_ch_cost_trnsf,
      it_pv_cost_trsf    TYPE STANDARD TABLE OF st_ch_cost_trnsf,
      it_backlog         TYPE STANDARD TABLE OF st_backlog,
      it_pzas_pv         TYPE STANDARD TABLE OF st_pzas_pv,
      it_pzas_pv_mes     TYPE STANDARD TABLE OF st_pzas_pv,
      it_pzas_pro        TYPE STANDARD TABLE OF st_pzas_pro,
      it_pzas_pro_m      TYPE STANDARD TABLE OF st_pzas_pro,
      it_recupera        TYPE STANDARD TABLE OF st_recupera,
      wa_backlog         LIKE LINE OF it_backlog,
      it_acdoca          TYPE STANDARD TABLE OF st_acdoca.

TYPES: BEGIN OF st_acumulado,
         columna   TYPE wgbez60,
         acumulado TYPE zco_st_acum,
       END OF st_acumulado,

       BEGIN OF st_kgs_pzas,
         aufnr      TYPE aufnr,
         bwart      TYPE bwart,
         matnr      TYPE matnr,
         werks      TYPE werks_d,
         lgort      TYPE lgort_d,
         erfme      TYPE erfme,
         budat_mkpf TYPE budat,
         dmbtr      TYPE dmbtr_cs,
         dmbtr_st   TYPE dmbtr_cs,
         /cwm/menge TYPE /cwm/menge,
         /cwm/meins TYPE /cwm/meins,
         menge      TYPE menge_d,
         meins      TYPE meins,
         mblnr      TYPE mblnr,
         zeile      TYPE mblpo,
         racct      TYPE racct,
       END OF st_kgs_pzas.


DATA: it_aux_acum TYPE STANDARD TABLE OF st_acumulado,
      it_kgs_pzas TYPE STANDARD TABLE OF st_kgs_pzas.


DATA: it_header TYPE STANDARD TABLE OF st_header,
      wa_header LIKE LINE OF it_header.

DATA: lo_tabla   TYPE REF TO data,lo_tabla_o TYPE REF TO data.
DATA gv_tt_meses TYPE zco_tt_meses.

DATA: lt_fcat  TYPE lvc_t_fcat, "FieldCat
      ls_fcat  TYPE lvc_s_fcat, "wa Fieldcat
      lv_fname TYPE lvc_fname.

DATA: gv_cant_pv        TYPE menge_d,
      gv_cantH          TYPE menge_d,
      gv_cantM          TYPE menge_d,
      gv_chiapas        TYPE menge_d,
      gv_trasd_vivo     TYPE menge_d,

      gv_cant_pv_kg     TYPE menge_d,
      gv_cantH_kg       TYPE menge_d,
      gv_cantM_kg       TYPE menge_d,
      gv_chiapas_kg     TYPE menge_d,

      gv_cant_pv_mn     TYPE menge_d,
      gv_cantH_mn       TYPE menge_d,
      gv_cantM_mn       TYPE menge_d,
      gv_chiapas_mn     TYPE menge_d,

      gv_dev_pv         TYPE menge_d,
      gv_dev_h          TYPE menge_d,
      gv_dev_m          TYPE menge_d,
      gv_dev_chiapas    TYPE menge_d,
      gv_fletes_pv      TYPE menge_d,
      gv_fletes_h       TYPE menge_d,
      gv_fletes_m       TYPE menge_d,
      gv_fletes_chiapas TYPE menge_d.

"datos mensuales""""""""""""""""""""""
DATA: gv_cant_pv_m        TYPE menge_d,
      gv_cantH_m          TYPE menge_d,
      gv_cantM_m          TYPE menge_d,
      gv_chiapas_m        TYPE menge_d,
      gv_trasd_vivo_m     TYPE menge_d,

      gv_cant_pv_kg_m     TYPE menge_d,
      gv_cantH_kg_m       TYPE menge_d,
      gv_cantM_kg_m       TYPE menge_d,
      gv_chiapas_kg_m     TYPE menge_d,

      gv_cant_pv_mn_m     TYPE menge_d,
      gv_cantH_mn_m       TYPE menge_d,
      gv_cantM_mn_m       TYPE menge_d,
      gv_chiapas_mn_m     TYPE menge_d,

      gv_dev_pv_m         TYPE menge_d,
      gv_dev_h_m          TYPE menge_d,
      gv_dev_m_m          TYPE menge_d,
      gv_dev_chiapas_m    TYPE menge_d,
      gv_fletes_pv_m      TYPE menge_d,
      gv_fletes_h_m       TYPE menge_d,
      gv_fletes_m_m       TYPE menge_d,
      gv_fletes_chiapas_m TYPE menge_d.
"""""""""""""""""""""""""""""""""""""2




DATA: gv_rnsentero     TYPE menge_d,
      gv_rnscortes     TYPE menge_d,
      gv_rtc           TYPE menge_d,
      gv_pintadopesado TYPE menge_d,
      gv_hidratado     TYPE menge_d,
      gv_rhpcortes     TYPE menge_d,
      gv_limpiezas     TYPE menge_d.

DATA: gv_rnsentero_mn     TYPE menge_d,
      gv_rnscortes_mn     TYPE menge_d,
      gv_rtc_mn           TYPE menge_d,
      gv_pintadopesado_mn TYPE menge_d,
      gv_hidratado_mn     TYPE menge_d,
      gv_rhpcortes_mn     TYPE menge_d,
      gv_limpiezas_mn     TYPE menge_d.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
DATA: gv_rnsentero_m     TYPE menge_d,
      gv_rnscortes_m     TYPE menge_d,
      gv_rtc_m           TYPE menge_d,
      gv_pintadopesado_m TYPE menge_d,
      gv_hidratado_m     TYPE menge_d,
      gv_rhpcortes_m     TYPE menge_d,
      gv_limpiezas_m     TYPE menge_d.

DATA: gv_rnsentero_mn_m     TYPE menge_d,
      gv_rnscortes_mn_m     TYPE menge_d,
      gv_rtc_mn_m           TYPE menge_d,
      gv_pintadopesado_mn_m TYPE menge_d,
      gv_hidratado_mn_m     TYPE menge_d,
      gv_rhpcortes_mn_m     TYPE menge_d,
      gv_limpiezas_mn_m     TYPE menge_d.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


DATA: o_alv           TYPE REF TO cl_salv_table,
      lr_columns      TYPE REF TO cl_salv_columns,
      lo_layout       TYPE REF TO cl_salv_layout,
      gs_layout       TYPE lvc_s_layo,
      lf_variant      TYPE slis_vari,
      lo_aggregations TYPE REF TO cl_salv_aggregations,
      lo_function     TYPE REF TO cl_salv_functions_list,
      ls_key          TYPE salv_s_layout_key.


*... §6 register to the events of cl_salv_table
DATA: lr_events TYPE REF TO cl_salv_events_table.


CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.                    "lcl_handle_events DEFINITION

CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
    PERFORM handle_user_command USING e_salv_function.
  ENDMETHOD.                    "on_user_command
ENDCLASS.

*... §5 object for handling the events of cl_salv_table
DATA: gr_events TYPE REF TO lcl_handle_events.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-018.

  PARAMETERS: p_gjahr TYPE gjahr NO-DISPLAY.
  SELECT-OPTIONS so_fecha FOR afko-gltri OBLIGATORY NO INTERVALS.
  SELECT-OPTIONS: p_werks FOR afpo-dwerk NO-DISPLAY.

  " SELECT-OPTIONS: p_aufnr FOR afko-aufnr NO-DISPLAY.


SELECTION-SCREEN END OF BLOCK b1.
