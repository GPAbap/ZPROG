*&---------------------------------------------------------------------*
*& Include zco_re_costo_prod_real_jhv_top General
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.
"top
TABLES: Afko, afpo, mseg, bseg, mara, makt, mbewh, t009b,t001w .
TABLES: sscrfields.
INCLUDE <cl_alv_control>.
DATA obj_engorda TYPE REF TO zcl_cost_engorda_jhv.
DATA: it_aufnr_end     TYPE STANDARD TABLE OF zco_tt_aufnr_fin,
      it_aufnr_IN02    TYPE STANDARD TABLE OF zco_tt_aufnr_fin,
      it_aufnr_ppa_det TYPE STANDARD TABLE OF zco_tt_aufnr_fin.

TYPES: BEGIN OF st_aufnr_0100,
         aufnr TYPE aufnr,
       END OF st_aufnr_0100.

DATA: it_aufnr_0100    TYPE STANDARD TABLE OF st_aufnr_0100.


DATA: gv_txtunit(40)             TYPE c,
      gv_txtcostodir(40)         TYPE c,
      gv_txtcostoindir(40)       TYPE c,
      gv_txtcostorecup(40)       TYPE c,
      gv_txttotalcostprod(40)    TYPE c,
      gv_txttotalpollosp(40)     TYPE c,
      gv_txttotalkilosp(40)      TYPE c,
      gv_txttotalcostomermas(20) TYPE c.

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

DATA: vl_global, vl_solo_granel, vl_solo_maquila, vl_solo_ensacado.
DATA: vl_globald, vl_solo_vivo, vl_solo_caliente.

INCLUDE <icon>.

DATA gv_tipoRE(40) TYPE c.
TYPES:

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

  BEGIN OF st_mb51_dep,
    aufnr      TYPE aufnr,
    matnr      TYPE matnr,
    matkl      TYPE matkl,
    bwart      TYPE bwart,
    wgbez60    TYPE wgbez60,
    werks      TYPE werks_d,
    menge      TYPE menge_d,
    meins      TYPE meins,
    budat_mkpf TYPE budat,
    dmbtr      TYPE dmbtr_cs,
    dmbtr_st   TYPE dmbtr_cs,
  END OF st_mb51_dep,

  BEGIN OF st_alpesur,
    aufnr      TYPE aufnr,
    matnr      TYPE matnr,
    wgbez60    TYPE maktx,
    werks      TYPE werks_d,
    lgort      TYPE lgort_d,
    menge      TYPE menge_d,
    meins      TYPE meins,
    budat_mkpf TYPE budat,
    dmbtr      TYPE dmbtr_cs,
    dmbtr_st   TYPE dmbtr_cs,
  END OF st_alpesur,

  BEGIN OF st_maquila,
    aufnr      TYPE aufnr,
    matnr      TYPE matnr,
    menge      TYPE menge_d,
    bwart      TYPE bwart,
    wgbez60    TYPE maktx,
    werks      TYPE werks_d,
    budat_mkpf TYPE budat,
    dmbtr      TYPE dmbtr_cs,
    dmbtr_st   TYPE dmbtr_cs,
  END OF st_maquila,

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

  BEGIN OF st_acdoca_ppa_det,
    matnr   TYPE matnr,
    racct   TYPE racct,
    maktx   TYPE maktx,
    aufnr   TYPE aufnr,
    msl     TYPE quan1_12,
    runit   TYPE runit,
    hsl     TYPE fins_vhcur12,
    rwcur   TYPE rwcur,
    budat   TYPE budat,
    r_hsl   TYPE fins_vhcur12,
    wgbez60 TYPE txt50_skat,
  END OF st_acdoca_ppa_det,

  BEGIN OF st_mermas,
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
  END OF st_mermas,

  BEGIN OF st_mermas_maq,
    aufnr      TYPE aufnr,
    matnr      TYPE matnr,
    matkl      TYPE matkl,
    wgbez60    TYPE maktx,
    werks      TYPE werks_d,
    menge      TYPE menge_d,
    meins      TYPE meins,
    budat_mkpf TYPE budat,
    dmbtr      TYPE dmbtr_cs,
    dmbtr_st   TYPE dmbtr_cs,

  END OF st_mermas_maq,

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

  END OF st_recupera,

  BEGIN OF st_estad_huevo, "
    matnr      TYPE matnr,
    wgbez60    TYPE maktx,
    menge      TYPE menge_d,
    budat_mkpf TYPE budat,
    dmbtr      TYPE dmbtr_cs,
    dmbtr_st   TYPE dmbtr_cs,
  END OF st_estad_huevo,


  BEGIN OF st_recupera_alim,
    aufnr    TYPE aufnr,
    matnr    TYPE matnr,
    matkl    TYPE matkl,
    wgbez60  TYPE maktx,
    werks    TYPE werks_d,
    "menge    TYPE menge_d,
    meins    TYPE meins,
    budat    TYPE budat,
    dmbtr    TYPE fins_vhcur12, "dmbtr_cs,
    dmbtr_st TYPE fins_vhcur12, "dmbtr_cs,
    awref    TYPE awref,
    awitem   TYPE awitem_rev,

  END OF st_recupera_alim,

  BEGIN OF st_mortandad,
    aufnr TYPE aufnr,
    matnr TYPE char40,
    menge TYPE p LENGTH 13 DECIMALS 3,
    "budat TYPE budat,
  END OF st_mortandad,

  BEGIN OF st_mortal_dep,
    aufnr      TYPE aufnr,
    wgbez60    TYPE char40,
    budat_mkpf TYPE budat,
    /cwm/menge TYPE p LENGTH 13 DECIMALS 3,
  END OF st_mortal_dep,

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
  END OF st_kgs_pzas,

  BEGIN OF st_header,
    titulo1 TYPE string,
    titulo2 TYPE string,
    titulo3 TYPE string,
    titulo4 TYPE string,
  END OF st_header,

  BEGIN OF st_materiales,
    aufnr TYPE aufnr,
    matnr TYPE matnr,
  END OF st_materiales.

TYPES: BEGIN OF st_acumulado,
         columna   TYPE wgbez60,
         acumulado TYPE zco_st_acum,
       END OF st_acumulado,

       BEGIN OF st_mts2,
         columna TYPE wgbez60,
         aufnr   TYPE aufnr,
         metros  TYPE menge_d,
       END OF st_mts2.


TYPES: BEGIN OF st_matnrdetails,
         objnr       TYPE j_objnr,
         accas       TYPE accas,
         kstar       TYPE kstar,
         matnr       TYPE matnr,
         wtgbtr      TYPE wtgxxx,
         werks       TYPE werks_d,
         mbgbtr      TYPE  mbgxxx,
         aufnr       TYPE aufnr,
         matnr_cobrb TYPE matnr,
         konty       TYPE konty,
       END OF st_matnrdetails.

DATA: vl_acum_prod   TYPE menge_d,vl_acum_prod_r TYPE menge_d.

TYPES: BEGIN OF st_acdoca_aux,
         aufnr   TYPE aufnr,
         getri   TYPE co_getri,
         racct   TYPE racct,
         matnr   TYPE matnr,
         msl     TYPE quan1_12,
         hsl     TYPE fins_vhcur12,
         r_hsl   TYPE fins_vhcur12,
         o_hsl   TYPE fins_vhcur12,
         wgbez60 TYPE txt50_skat,
       END OF st_acdoca_aux,

       BEGIN OF st_acdoca_matnr,
         aufnr    TYPE aufnr,
         matnr    TYPE matnr,
         hsl      TYPE fins_vhcur12,
         equivale TYPE p DECIMALS 7,
       END OF st_acdoca_matnr,

       BEGIN OF st_equivalencias,
         aufnr    TYPE aufnr,
         equivale TYPE p DECIMALS 7,
       END OF st_equivalencias.

DATA: rg_aufnr_det TYPE RANGE OF afko-aufnr,
      wrg_aufnr    LIKE LINE OF rg_aufnr_det.

DATA: rg_matnr_det TYPE RANGE OF afpo-matnr,
      wrg_matnr    LIKE LINE OF rg_matnr_det.

DATA: rg_racct_det TYPE RANGE OF acdoca-racct,
      wrg_racct    LIKE LINE OF rg_racct_det.


DATA: it_sum_racct TYPE STANDARD TABLE OF st_acdoca_aux,
      wa_sum_racct LIKE LINE OF it_sum_racct.

DATA: it_sum_matnr     TYPE STANDARD TABLE OF st_acdoca_matnr,
      wa_sum_matnr     LIKE LINE OF it_sum_matnr,

      it_equivalencias TYPE STANDARD TABLE OF st_equivalencias,
      wa_equivalencias LIKE LINE OF it_equivalencias.

DATA: it_matnrdetails TYPE STANDARD TABLE OF st_matnrdetails,
      wa_matnrdetails LIKE LINE OF it_matnrdetails.

DATA gv_dauat TYPE aufart.

DATA it_aux_acum TYPE STANDARD TABLE OF st_acumulado.
DATA: it_mts2 TYPE STANDARD TABLE OF st_mts2,
      wa_mts2 LIKE LINE OF it_mts2.

DATA: it_header TYPE STANDARD TABLE OF st_header,
      wa_header LIKE LINE OF it_header.


FIELD-SYMBOLS: <fs_outtable>   TYPE STANDARD TABLE, "tabla dinamica de salida
               <fs_outtable_o> TYPE STANDARD TABLE, "tabla dinamica de salida
               <linea>         TYPE any,                  "wa tabla dinamica
               <linea2>        TYPE any,
               <f_field>       TYPE any.

DATA: lo_tabla   TYPE REF TO data,lo_tabla_o TYPE REF TO data.

DATA: lt_fcat  TYPE lvc_t_fcat, "FieldCat
      ls_fcat  TYPE lvc_s_fcat, "wa Fieldcat
      lv_fname TYPE lvc_fname.

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
*... §5 object for handling the events of cl_salv_table
DATA: gr_events TYPE REF TO lcl_handle_events.


DATA: it_mb51            TYPE STANDARD TABLE OF st_mb51,
      it_mb51_dep        TYPE STANDARD TABLE OF st_mb51_dep,
      it_acdoca          TYPE STANDARD TABLE OF st_acdoca,
      it_recupera        TYPE STANDARD TABLE OF st_recupera,
      it_mermas          TYPE STANDARD TABLE OF st_mermas,
      it_mermas_maq      TYPE STANDARD TABLE OF st_mermas_maq,
      it_recupera_alim   TYPE STANDARD TABLE OF st_recupera_alim,
      it_kgs_pzas        TYPE STANDARD TABLE OF st_kgs_pzas,
      it_mortandad       TYPE STANDARD TABLE OF st_mortandad,
      it_mortal_dep      TYPE STANDARD TABLE OF st_mortal_dep,
      it_alpesur         TYPE STANDARD TABLE OF st_alpesur,
      it_maquila         TYPE STANDARD TABLE OF st_maquila,
      it_estad_huevo_inc TYPE STANDARD TABLE OF st_estad_huevo,
      it_materiales      TYPE STANDARD TABLE OF st_materiales,
      it_ppa_det         TYPE STANDARD TABLE OF st_acdoca_ppa_det.


"para ayudar en zona
DATA: BEGIN OF t_values OCCURS 0,
        value(60) TYPE c.
DATA: END OF t_values.

DATA: BEGIN OF t_fields OCCURS 0.
        INCLUDE STRUCTURE help_value.
DATA END OF t_fields.

DATA: valor(20) TYPE c.

DATA: BEGIN OF t_match OCCURS 0,
        zona LIKE t001w-name2,
      END OF t_match.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  PARAMETERS: p_gjahr TYPE gjahr OBLIGATORY.
  SELECT-OPTIONS so_poper FOR t009b-poper OBLIGATORY.
  SELECT-OPTIONS: p_werks FOR afpo-dwerk.

  " SELECT-OPTIONS: p_aufnr FOR afko-aufnr NO-DISPLAY.

  PARAMETERS: p_zona  TYPE name2,
              p_clord TYPE aufart.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

  PARAMETERS: r_granel AS CHECKBOX DEFAULT abap_true,
              r_ensaca AS CHECKBOX DEFAULT abap_true,
              r_maquil AS CHECKBOX DEFAULT abap_true.

SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-002.

  PARAMETERS: c_vivo AS CHECKBOX DEFAULT abap_true,
              c_hot  AS CHECKBOX DEFAULT abap_true.


SELECTION-SCREEN END OF BLOCK b3.


SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-003.
  PARAMETERS: c_cria   AS CHECKBOX DEFAULT abap_true,
              c_recria AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE TEXT-003.
  PARAMETERS: c_aca   AS CHECKBOX USER-COMMAND chk_aca. "DEFAULT abap_false.
  PARAMETERS: c_gapesa   AS CHECKBOX USER-COMMAND chk_gp. "DEFAULT abap_false.
SELECTION-SCREEN END OF BLOCK b5.
