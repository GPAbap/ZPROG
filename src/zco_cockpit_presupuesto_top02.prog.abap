*&---------------------------------------------------------------------*
*&  Include           ZCO_COCKPIT_PRESUPUESTO_TOP02
*& 07032023
*&---------------------------------------------------------------------*

CLASS lcl_application DEFINITION DEFERRED.
CLASS cl_gui_cfw DEFINITION LOAD.

TYPES: node_table_type LIKE STANDARD TABLE OF mtreesnode
WITH DEFAULT KEY.
* CAUTION: MTREESNODE is the name of the node structure which must
* be defined by the programmer. DO NOT USE MTREESNODE!

"data: go_abapblog type ref to zcl_abapblog_com. "our class with chart methods
DATA: go_chart TYPE REF TO cl_gui_chart_engine.
DATA: go_container TYPE REF TO cl_gui_custom_container.
DATA: graph_type(5) TYPE c. "para ir pasando de gráfico en gráfico.

DATA: g_application      TYPE REF TO lcl_application,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      g_tree             TYPE REF TO cl_gui_simple_tree,
      g_ok_code          TYPE sy-ucomm.
*Layout Alv
DATA  it_layout TYPE lvc_s_layo.
* Fields on Dynpro 100
DATA: g_event(30),
      g_node_key TYPE tv_nodekey.

DATA: stable TYPE lvc_s_stbl."*Global variable declaration

DATA: et_index_rows TYPE lvc_t_row,
      et_row_no     TYPE lvc_t_roid,
      wa            LIKE LINE OF et_row_no.


TYPES: lv_mp_rows TYPE STANDARD TABLE OF zco_tt_planpresm."REF TO DATA.

DATA: gv_numsubscr(4) TYPE c,
      id_exec(20)     TYPE c.
gv_numsubscr = '0'.
CONSTANTS:
  BEGIN OF c_nodekey,
    root   TYPE tv_nodekey VALUE 'Reportes Presupuestos',   "#EC NOTEXT
    child1 TYPE tv_nodekey VALUE 'Seleccionar',             "#EC NOTEXT
*    child2 type tv_nodekey value 'Child2',                  "#EC NOTEXT
    new1   TYPE tv_nodekey VALUE 'MatCantidades',           "#EC NOTEXT
    new2   TYPE tv_nodekey VALUE 'MatMontos',               "#EC NOTEXT
    new3   TYPE tv_nodekey VALUE 'ValidarMat',              "#EC NOTEXT
    new4   TYPE tv_nodekey VALUE 'ElabSolpeds',             "#EC NOTEXT
    new5   TYPE tv_nodekey VALUE 'AjustePres',              "#EC NOTEXT
  END OF c_nodekey.
*-------objetos de ALV Poo

DATA gref_alvgrid102       TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgrid103       TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgrid104       TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgrid102_n2    TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgrid102_n3    TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgrid102_n4    TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgrid102_n5    TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgridecc       TYPE REF TO cl_gui_alv_grid.
* Contenedor ALV

DATA gref_ccontainer102     TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainer103     TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainer104     TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainer102_n2  TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainer102_n3  TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainer102_n4  TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainer102_n5  TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainerecc     TYPE REF TO cl_gui_custom_container.


*-----------BAPI SOLPEDS
DATA:
  prheader  LIKE  bapimereqheader,
  prheaderx LIKE  bapimereqheaderx,
  testrun   LIKE  bapiflag-bapiflag,
  solped    LIKE  bapimereqheader-preq_no.

DATA:
  retorno     TYPE TABLE OF  bapiret2,
  wa_retorno  LIKE LINE OF retorno,
  t_pr_item   TYPE TABLE OF  bapimereqitemimp,
  t_praccount TYPE TABLE OF bapimereqaccount,
  praccount   LIKE LINE OF t_praccount,
  t_praccountx TYPE TABLE OF bapimereqaccountx,
  praccountx LIKE LINE OF t_praccountx,
  pr_item     LIKE LINE OF t_pr_item,
  t_pr_itemx  TYPE TABLE OF bapimereqitemx,
  pr_itemx    LIKE LINE OF t_pr_itemx.
*---tablas------------------------------------
TYPES: BEGIN OF ty_registros,
         idpres  TYPE  char10,
         prespos TYPE num5,
         bukrs   TYPE bukrs,
         werks   TYPE werks,
         matnr   TYPE matnr,
         pos     TYPE bnfpo,
         menge   TYPE menge_d,
       END OF ty_registros.

DATA: it_registros TYPE TABLE OF ty_registros,
      wa_registros LIKE LINE OF it_registros.

TYPES:
  BEGIN OF ty_indice,
    mandt  TYPE mandt,
    kostl  TYPE kostl,
    idpres TYPE char10,
  END OF ty_indice.

*TYPES: BEGIN OF st_zco_tt_planpresm,
*        STYLE TYPE lvc_t_styl.
*        INCLUDE STRUCTURE zco_tt_planpresm.
*
*TYPES:  END OF st_zco_tt_planpresm.





DATA: it_cecos           TYPE TABLE OF zco_tt_cecoaut,
      wa_cecos           LIKE LINE OF it_cecos,
      it_cecos_indice    TYPE TABLE OF ty_indice,
      wa_cecos_indice    LIKE LINE OF it_cecos_indice,
      gt_zco_tt_reservas TYPE TABLE OF zco_tt_reservas,
      wa_zco_tt_reservas LIKE LINE OF gt_zco_tt_reservas.


TYPES: BEGIN OF st_zco_tt_planpresm,  "with header line
         celltab TYPE lvc_t_styl.
         INCLUDE STRUCTURE zco_tt_planpresm.
TYPES:  END OF st_zco_tt_planpresm.

DATA: gt_zco_tt_planpresm TYPE STANDARD TABLE OF st_zco_tt_planpresm,
      wa_zco_tt_planpresm LIKE LINE OF gt_zco_tt_planpresm.

DATA: it_aux TYPE STANDARD TABLE OF st_zco_tt_planpresm,
      wa_aux LIKE LINE OF it_aux.

*----------Subscreens dependiendo de la selección se irán invocando
*subscreen dummy
SELECTION-SCREEN BEGIN OF SCREEN 0 AS SUBSCREEN.
SELECTION-SCREEN END OF SCREEN 0.
*----------------------------------------------

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'P_AUTH'.

      screen-input = 0.

      MODIFY SCREEN.

    ENDIF.

  ENDLOOP.
