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

       BEGIN OF st_kgs_cost_trans,
         "matnr TYPE matnr,
         menge TYPE menge_d,
         meins TYPE meins,
       END OF st_KGS_COST_TRANS,

       BEGIN OF st_flete_transf,
         kstar TYPE kstar,
         mes   TYPE wtgxxx,
       END OF st_FLETE_TRANSF,

       BEGIN OF st_kgs_vendidos,
         artnr TYPE matnr,
         mes   TYPE rke2_vvpnt,
       END OF st_kgs_vendidos.

DATA: it_aux_out       TYPE STANDARD TABLE OF st_aux_out,
      wa_aux_out       LIKE LINE OF it_aux_out,
      it_mb51          TYPE STANDARD TABLE OF st_mb51,
      it_kg_cost_trans TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_menudencia TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_merma      TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_rns        TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_pro_merma  TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_kg_cad_h      TYPE STANDARD TABLE OF st_kgs_cost_trans,
      it_flete_transf  TYPE STANDARD TABLE OF st_flete_transf,
      it_vtas_netas    TYPE STANDARD TABLE OF st_flete_transf,
      it_kgs_vendidos  type stANDARD TABLE OF st_kgs_vendidos,
      it_backlog       TYPE STANDARD TABLE OF st_backlog,
      wa_backlog       LIKE LINE OF it_backlog.

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


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  PARAMETERS: p_gjahr TYPE gjahr NO-DISPLAY.
  SELECT-OPTIONS so_fecha FOR afko-gltri OBLIGATORY NO INTERVALS.
  SELECT-OPTIONS: p_werks FOR afpo-dwerk NO-DISPLAY.

  " SELECT-OPTIONS: p_aufnr FOR afko-aufnr NO-DISPLAY.


SELECTION-SCREEN END OF BLOCK b1.
