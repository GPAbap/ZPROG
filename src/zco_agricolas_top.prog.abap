*&---------------------------------------------------------------------*
*& Include zco_agricolas_top
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.
"top
TABLES: Afko, afpo, mseg, bseg, mara, makt, mbewh, t009b,t001w, t001 .
TABLES: sscrfields.
INCLUDE <cl_alv_control>.
INCLUDE <icon>.

DATA obj_agricolas TYPE REF TO zcl_costos_agricolas_jhv.
DATA parent TYPE REF TO cl_gui_custom_container.
DATA style  TYPE lvc_style.
DATA variant TYPE disvariant. "for parameter IS_VARIANT
DATA layout TYPE lvc_s_layo.   " Layout

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

FIELD-SYMBOLS: <fs_outtable> TYPE STANDARD TABLE, "tabla dinamica de salida
               <fs_struct>   TYPE any,
               <linea>       TYPE any.

DATA: lo_tabla   TYPE REF TO data.


DATA: campocu        TYPE string,
      vl_date        TYPE dats,
      vl_name_month  TYPE fcltx,
      vl_zname_month TYPE zfcltx.


DATA: lt_fcat  TYPE lvc_t_fcat, "FieldCat
      ls_fcat  TYPE lvc_s_fcat, "wa Fieldcat
      lv_fname TYPE lvc_fname.

DATA: o_alv           TYPE REF TO  zgui_alv_grid_merge, " cl_salv_table,
      lr_columns      TYPE REF TO cl_salv_columns,
      lo_layout       TYPE REF TO cl_salv_layout,
      gs_layout       TYPE lvc_s_layo,
      lf_variant      TYPE slis_vari,
      lo_aggregations TYPE REF TO cl_salv_aggregations,
      lo_function     TYPE REF TO cl_salv_functions_list,
      ls_key          TYPE salv_s_layout_key.


DATA: lr_events TYPE REF TO cl_salv_events_table.
DATA: gr_events TYPE REF TO lcl_handle_events.
CONSTANTS gv_subcampo TYPE char12 VALUE 'SUBCAMPO'.

TYPES: BEGIN OF st_header,
         titulo1 TYPE string,
         titulo2 TYPE string,
         titulo3 TYPE string,
         titulo4 TYPE string,
       END OF st_header,

       BEGIN OF st_bukrs,
         bukrs TYPE bukrs,
       END OF st_bukrs.

TYPES: BEGIN OF st_vtas_netas,
         racct    TYPE racct,
         matnr    TYPE matnr,
         concepto TYPE char50,
         msl      TYPE quan1_12,
         runit    TYPE meins,
         hsl      TYPE fins_vhcur12,
         rhcur    TYPE fins_currh,
         poper    TYPE poper,
       END OF st_vtas_netas,

       BEGIN OF st_inv_inicial,
         matnr      TYPE matnr,
         concepto   TYPE char50,
         lbkum      TYPE lbkum,
         salk3      TYPE salk3,
         budat_mkpf TYPE budat,
         lfmon      TYPE lfmon,
       END OF st_inv_inicial,

       BEGIN OF st_v_ctos_vta,
         concepto TYPE char50,
         poper    TYPE poper,
         msl      TYPE quan1_12,
         hsl      TYPE fins_vhcur12,
       END OF st_v_ctos_vta,

       BEGIN OF st_costos_pro,
         racct    TYPE racct,
         concepto TYPE char50,
         aufnr    TYPE aufnr,
         matnr    TYPE matnr,
         werks    TYPE werks_d,
         msl      TYPE quan1_12,
         runit    TYPE meins,
         hsl      TYPE fins_vhcur12,
         rwcur    TYPE fins_currw,
         budat    TYPE budat,
         poper    TYPE poper,
         ryear    TYPE gjahr_pos,
       END OF st_costos_pro,

       BEGIN OF st_grupo_act,
         subsetname TYPE subsetname,
         concepto   TYPE char50,
         poper      TYPE poper,
         msl        TYPE quan1_12,
         hsl        TYPE fins_vhcur12,
         activities TYPE ztt_activities,
       END OF st_grupo_act,

       BEGIN OF st_ndis,
         concepto TYPE char50,
         poper    TYPE poper,
         hsl      TYPE menge_d,
       END OF st_ndis,

       BEGIN OF st_semilla,
         racct    TYPE racct,
         concepto TYPE char50,
         aufnr    TYPE aufnr,
         matnr    TYPE matnr,
         werks    TYPE werks_d,
         msl      TYPE quan1_12,
         runit    TYPE meins,
         hsl      TYPE fins_vhcur12,
         rwcur    TYPE fins_currw,
         budat    TYPE budat,
         poper    TYPE poper,
         ryear    TYPE gjahr_pos,
       END OF st_semilla.


TYPES: BEGIN OF st_aux_out,
         concepto TYPE char50,
         menge    TYPE menge_d,
         month    TYPE fins_vhcur12,
       END OF st_aux_out,

       BEGIN OF st_aux_out_act,
         subsetname TYPE subsetname,
         concepto   TYPE char50,
         menge      TYPE menge_d,
         month      TYPE fins_vhcur12,
       END OF st_aux_out_act.

TYPES: BEGIN OF st_gastos_cosech,
         perio  TYPE co_perio,
         kostl  TYPE kostl,
         kstar  TYPE kstar,
         wtgbtr TYPE wtgxxx,
       END OF st_gastos_cosech.

DATA:  it_aufnr  TYPE STANDARD TABLE OF zco_tt_aufnr_fin.
DATA it_costos_pro TYPE STANDARD TABLE OF st_costos_pro.
DATA it_grupos_act TYPE STANDARD TABLE OF st_grupo_act.
DATA it_ndis TYPE STANDARD TABLE OF st_ndis.
DATA it_semilla TYPE STANDARD TABLE OF st_semilla.
DATA it_v_ctos_vta TYPE STANDARD TABLE OF st_v_ctos_vta.
DATA it_gastos_cosech TYPE STANDARD TABLE OF st_gastos_cosech.
DATA it_gastos_opera TYPE STANDARD TABLE OF st_gastos_cosech.
DATA it_otros_gastos TYPE STANDARD TABLE OF st_gastos_cosech.
DATA it_impuestos TYPE STANDARD TABLE OF st_gastos_cosech.

DATA it_inv_ini TYPE STANDARD TABLE OF st_inv_inicial.
DATA it_inv_final TYPE STANDARD TABLE OF st_inv_inicial.


DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
      wa_aux_out LIKE LINE OF it_aux_out.

DATA: it_aux_out_act TYPE STANDARD TABLE OF st_aux_out_act,
      wa_aux_out_act LIKE LINE OF it_aux_out_act.

DATA: it_header TYPE STANDARD TABLE OF st_header,
      wa_header LIKE LINE OF it_header.

DATA it_bukrs TYPE STANDARD TABLE OF st_bukrs.

DATA: rg_bukrs   TYPE RANGE OF t001-bukrs,
      wa_rgbukrs LIKE LINE OF rg_bukrs.

DATA: it_vtas_netas TYPE STANDARD TABLE OF st_vtas_netas.

DATA gv_flag.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_gjahr TYPE gjahr OBLIGATORY.
  SELECT-OPTIONS so_poper FOR t009b-poper OBLIGATORY.
  SELECT-OPTIONS: p_werks FOR afpo-dwerk NO-DISPLAY.
  SELECT-OPTIONS: p_bukrs FOR t001-bukrs OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
