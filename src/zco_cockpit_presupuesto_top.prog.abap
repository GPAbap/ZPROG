*&---------------------------------------------------------------------*
*&  Include           ZCO_COCKPIT_PRESUPUESTO_TOP
*& 07032023
*&---------------------------------------------------------------------*
TABLES: zco_tt_planpres,zco_tt_planpresh, mara, makt,csks,t001,t001w,t023,t023t,
        zco_tt_datomatnr.

TYPE-POOLS: slis.
TYPE-POOLS: vrm.
TYPES: type_excel_tab TYPE STANDARD TABLE OF alsmex_tabline. "Tabla para el excel

*Objetos de Clase
DATA: grid_handlerdyn102 TYPE REF TO lcl_grid_event_receiverdyn102.
DATA: event_handlerdyn103 TYPE REF TO lcl_grid_event_receiverdyn103.
DATA: event_handlerdyn104 TYPE REF TO lcl_grid_event_receiverdyn104.
DATA: event_handlerdynecc TYPE REF TO lcl_grid_event_receiverdynecc.

DATA gv_selectall.
DATA gv_p_bukrs1 TYPE bukrs.
DATA: event_handler TYPE REF TO lcl_event_receiver.
DATA: event_handlerdyn102 TYPE REF TO lcl_event_receiverdyn102.

DATA: it_zco_tt_planpres     TYPE STANDARD TABLE OF zco_tt_planpres,
      it_zco_reservassolpeds TYPE STANDARD TABLE OF zco_tt_datomatnr,
      wa_zco_reservassolpeds like LINE OF it_zco_reservassolpeds,
      "wa_zco_tt_planpres LIKE LINE OF it_zco_tt_planpres,

      it_zco_tt_planpresh    TYPE STANDARD TABLE OF zco_tt_planpresh,
      wa_zco_tt_planpresh    LIKE LINE OF it_zco_tt_planpresh.

DATA: it_zco_tt_matcuenta TYPE STANDARD TABLE OF zco_tt_matcuenta,
      wa_zco_tt_matcuenta LIKE LINE OF it_zco_tt_matcuenta.

DATA: gv_init.

TYPES: BEGIN OF st_kostl,
         idpres      TYPE char10,
         kostl       TYPE kostl,
         ktext       TYPE ktext,
         objnr       TYPE objnr,
         kstar       TYPE kstar,
         status(4)   TYPE c,
         descripcion TYPE string,
       END OF st_kostl.

DATA: it_kostl      TYPE STANDARD TABLE OF st_kostl,
      wa_kostl      LIKE LINE OF it_kostl,
      it_only_kostl TYPE STANDARD TABLE OF st_kostl,
      wa_only_kostl LIKE LINE OF it_only_kostl.


TYPES: BEGIN OF st_auth,
         kostl     TYPE kostl,
         bname     TYPE xubname,
         name_text TYPE ad_namtext,
       END OF st_auth.

TYPES: BEGIN OF st_matnrpres,
         kokrs TYPE kokrs,
         gjahr TYPE gjahr,
         matnr TYPE matnr,
         netpr TYPE netpr,
         dmbtr TYPE zinlfacion,
       END OF st_matnrpres.


DATA: it_auth TYPE STANDARD TABLE OF st_auth,
      wa_auth LIKE LINE OF it_auth.

DATA: it_matnrpres TYPE STANDARD TABLE OF st_matnrpres,
      wa_matnrpres LIKE LINE OF it_matnrpres.


TYPES: BEGIN OF st_xls,
         archivo         TYPE string,
         anio(4)         TYPE c,
         status(4)       TYPE c,
         comentario(200) TYPE c,
       END OF st_xls.

TYPES: BEGIN OF st_autorizar,
         bukrs TYPE bukrs,
         butxt TYPE butxt,
       END OF st_autorizar.

TYPES: BEGIN OF st_usuario,
         bname     TYPE xubname,
         name_text TYPE name_text,
         smtp_addr TYPE ad_smtpadr,
       END OF st_usuario.

DATA: it_usuario TYPE STANDARD TABLE OF st_usuario,
      wa_usuario LIKE LINE OF it_usuario.

DATA: it_autorizar TYPE STANDARD TABLE OF st_autorizar,
      wa_autorizar LIKE LINE OF it_autorizar.

TYPES: BEGIN OF st_lgort,
         matnr TYPE matnr,
         werks TYPE werks_d,
         lgort TYPE lgort_d,
       END OF st_lgort.

DATA it_lgort TYPE STANDARD TABLE OF st_lgort.

TYPES: BEGIN OF st_temporal,
         idpres      TYPE char10,
         usuario     TYPE uname,
         fecha       TYPE datum,
         autorizador TYPE uname,
         fechaaut    TYPE datum,
       END OF st_temporal.

TYPES: BEGIN OF st_matpres,
         name1 TYPE name1,
         wgbez TYPE wgbez.
         INCLUDE STRUCTURE zco_tt_planpres.
TYPES:  END OF st_matpres.

TYPES: BEGIN OF st_listamateriales,
         kokrs TYPE kokrs,
         matnr TYPE matnr,
         netpr TYPE bprei,
         gjahr TYPE gjahr,
         row   TYPE c,
       END OF st_listamateriales.


TYPES: BEGIN OF st_ajustepres,
         color   TYPE char4,
         celltab TYPE lvc_t_styl,
         check   TYPE c,
         name1   TYPE name1,
         wgbez   TYPE wgbez,
         ktext   TYPE ktext,
         txt20   TYPE txt20_skat.
         INCLUDE STRUCTURE zco_tt_planpres.
TYPES:  END OF st_ajustepres.

TYPES: BEGIN OF st_cosp,
         objnr   TYPE j_objnr,
         kstar   TYPE kstar,
         vrgng   TYPE co_vorgang,
         wtg001  TYPE wtgxxx,
         wtg002  TYPE wtgxxx,
         wtg003  TYPE wtgxxx,
         wtg004  TYPE wtgxxx,
         wtg005  TYPE wtgxxx,
         wtg006  TYPE wtgxxx,
         wtg007  TYPE wtgxxx,
         wtg008  TYPE wtgxxx,
         wtg009  TYPE wtgxxx,
         wtg010  TYPE wtgxxx,
         wtg011  TYPE wtgxxx,
         wtg012  TYPE wtgxxx,
         wtgtot  TYPE wtgxxx,
         wtggral TYPE wtgxxx,
       END OF st_cosp.

DATA: it_cosp     TYPE STANDARD TABLE OF st_cosp,
      wa_cosp     LIKE LINE OF it_cosp,
      wa_cospreal LIKE LINE OF it_cosp.

DATA: it_temporal TYPE STANDARD TABLE OF st_temporal,
      wa_temporal LIKE LINE OF it_temporal.

DATA: it_matpres    TYPE STANDARD TABLE OF st_matpres,

      it_matpresd   TYPE STANDARD TABLE OF st_matpres,
      it_ajustepres TYPE STANDARD TABLE OF st_ajustepres,
      wa_ajustepres LIKE LINE OF it_ajustepres,
      wa_matpres    LIKE LINE OF it_matpres,
      wa_matpresd   LIKE LINE OF it_matpresd.

*Variable manejo de Dynpros
DATA: dyn1000, dyn1001.

*Tabla Interna
DATA: it_outtable TYPE STANDARD TABLE OF zco_st_laycargapresupuesto,
      wa_outtable LIKE LINE OF it_outtable.

*Tabla interna lista de materiales
DATA: it_listamateriales TYPE STANDARD TABLE OF st_listamateriales,
      wa_listamateriales LIKE LINE OF it_listamateriales.

*Tabla de CeCos
DATA: it_csks TYPE STANDARD TABLE OF csks,
      wa_csks LIKE LINE OF it_csks.

*Posiciones
DATA: it_planpres TYPE STANDARD TABLE OF zco_tt_planpres,
      wa_planpres LIKE LINE OF it_planpres.

*DATA:
*      it_zco_tt_planpresi TYPE STANDARD TABLE OF zco_tt_planpresi,
*      wa_zco_tt_planpresi LIKE LINE OF it_zco_tt_planpresi,
*      it_zco_tt_planpreso TYPE STANDARD TABLE OF zco_tt_planpreso,
*      wa_zco_tt_planpreso LIKE LINE OF it_zco_tt_planpreso.
*Encabezado
DATA: it_planpresh TYPE STANDARD TABLE OF zco_tt_planpresh,
      wa_planpresh LIKE LINE OF it_planpresh.


*Variables
DATA: file TYPE rlgrap-filename.

*Guarda la ruta y el contenido de ese directorio
DATA: file_table    TYPE TABLE OF sdokpath,
      wa_file_table LIKE LINE OF file_table,

      dir_table     TYPE TABLE OF sdokpath,
      wa_dir_table  LIKE LINE OF dir_table.

* Filtrado de archivos xls o xlsx
DATA:
  it_xls TYPE TABLE OF st_xls,
  wa_xls LIKE LINE OF it_xls.



* Guarda la información de Excel
DATA it_excel TYPE  type_excel_tab.
*&---------------------------------------------------------------------*
*& Variables de Refencia para tabla dinámica
*&---------------------------------------------------------------------*
DATA: t_dyn_tab TYPE REF TO data,
      x_dyn_wa  TYPE REF TO data.

*&---------------------------------------------------------------------*
*& Variables para ALV
*&---------------------------------------------------------------------*
* Data
DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
      lt_sort     TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      gs_key      TYPE slis_keyinfo_alv,
      gt_events   TYPE slis_t_event,
      wa_fieldcat TYPE slis_fieldcat_alv,
      wa_format   TYPE slis_layout_alv,
      wa_gs_line  TYPE slis_listheader,

* Header
      gt_header   TYPE slis_t_listheader,
      wa_header   TYPE slis_listheader,
      gt_line     LIKE wa_header-info.

*Variables ALV OO
DATA: po_fieldcat TYPE lvc_t_fcat,
      de_fieldcat TYPE lvc_t_fcat,
      hi_fieldcat TYPE lvc_t_fcat,
      fieldcat102 TYPE lvc_t_fcat.
*---------------------------
* Obtener paramentros dynpro
TYPES: BEGIN OF values,
         p_route TYPE filename,
       END OF values.

DATA: dynpro_values TYPE TABLE OF dynpread,
      field_value   LIKE LINE OF dynpro_values,
      values_tab    TYPE TABLE OF values,
      wa_values_tab LIKE LINE OF values_tab.

*&---------------------------------------------------------------------*
*& Field Symbols
*&---------------------------------------------------------------------*
FIELD-SYMBOLS : <fs_table> TYPE STANDARD TABLE,
                <fs_wa>    TYPE any,
                <linea>    TYPE any.

* ALV Grid
DATA gref_alvgrid    TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgridd    TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgrid101    TYPE REF TO cl_gui_alv_grid.
DATA gref_alvgrid101d    TYPE REF TO cl_gui_alv_grid.
* Contenedor ALV
DATA gref_ccontainer TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainerd TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainer101 TYPE REF TO cl_gui_custom_container.
DATA gref_ccontainer101d TYPE REF TO cl_gui_custom_container.


*Parametro de entrada para Dynpro 1001

SELECTION-SCREEN BEGIN OF SCREEN 101 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002. "Input
    "PARAMETERS p_frgco TYPE t16fc-frgco DEFAULT '01'.
    PARAMETERS: p_bukrs1 TYPE bukrs OBLIGATORY DEFAULT 'SA01',
                p_auth   TYPE ad_namtext.

  SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN END OF SCREEN 101.


SELECTION-SCREEN BEGIN OF SCREEN 103 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-009. "Input
    PARAMETERS: p__gjahr TYPE gjahr DEFAULT sy-datum+0(4) OBLIGATORY,
                p__versn type versn DEFAULT '000' OBLIGATORY,
                p__kokrs TYPE kokrs DEFAULT 'SA00' OBLIGATORY.

    SELECT-OPTIONS: s_bukrs FOR t001-bukrs,
    s__kostl FOR csks-kostl,
    s__werks FOR t001w-werks,
    s__matkl FOR t023-matkl,
    s__matnr FOR mara-matnr.
  SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN END OF SCREEN 103.

SELECTION-SCREEN BEGIN OF SCREEN 105 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE TEXT-009. "Input
    PARAMETERS: p5_gjahr TYPE gjahr DEFAULT sy-datum+0(4) OBLIGATORY,
                p5_versn type versn DEFAULT '000' OBLIGATORY,
                p5_kokrs TYPE kokrs DEFAULT 'SA00' OBLIGATORY,
                p5_tipo  TYPE char20 DEFAULT 'CUENTA'.

    SELECT-OPTIONS: s5_bukrs FOR t001-bukrs,
    s5_kostl FOR csks-kostl,
    s5_werks FOR t001w-werks,
    s5_matkl FOR t023-matkl,
    s5_matnr FOR mara-matnr,
    s5_kstar FOR zco_tt_planpres-kstar.
  SELECTION-SCREEN END OF BLOCK b5.
SELECTION-SCREEN END OF SCREEN 105.


SELECTION-SCREEN BEGIN OF SCREEN 102 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-009. "Input
    PARAMETERS: p_gjahr TYPE gjahr DEFAULT sy-datum+0(4) OBLIGATORY,
                p_versn type versn DEFAULT '000' OBLIGATORY,
                p_kokrs TYPE kokrs DEFAULT 'SA00' OBLIGATORY.
    SELECT-OPTIONS: skostl FOR csks-kostl,
    smatnr FOR mara-matnr.
    PARAMETERS: p_monat TYPE monat DEFAULT '1' OBLIGATORY.

  SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF SCREEN 102.


SELECTION-SCREEN BEGIN OF SCREEN 104 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-009. "Input
    PARAMETERS: pgjahr TYPE gjahr DEFAULT sy-datum+0(4) OBLIGATORY,
                pversn type versn DEFAULT '000' OBLIGATORY,
                pkokrs TYPE kokrs DEFAULT 'SA00' OBLIGATORY,
                ptipo  TYPE char20 DEFAULT 'CUENTA'.

    SELECT-OPTIONS: skstar FOR zco_tt_planpres-kstar.
  SELECTION-SCREEN END OF BLOCK b4.
SELECTION-SCREEN END OF SCREEN 104.

SELECTION-SCREEN BEGIN OF SCREEN 106 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK b6 WITH FRAME TITLE TEXT-009. "Input
    PARAMETERS: p6_gjahr TYPE gjahr DEFAULT sy-datum+0(4) OBLIGATORY,
                p6_versn type versn DEFAULT '000' OBLIGATORY,
                p6_kokrs TYPE kokrs DEFAULT 'SA00' OBLIGATORY.

    SELECT-OPTIONS: s6_kostl FOR csks-kostl DEFAULT '1' OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK b6.
SELECTION-SCREEN END OF SCREEN 106.

SELECTION-SCREEN BEGIN OF SCREEN 107 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK b7 WITH FRAME TITLE TEXT-009. "Input
    PARAMETERS: p7_gjahr TYPE gjahr DEFAULT sy-datum+0(4) OBLIGATORY,
                p7_versn type versn DEFAULT '000' OBLIGATORY,
                p7_kokrs TYPE kokrs DEFAULT 'GA00' OBLIGATORY.

    SELECT-OPTIONS: s7_kostl FOR csks-kostl DEFAULT '1' OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK b7.
SELECTION-SCREEN END OF SCREEN 107.



INITIALIZATION.

  LOOP AT SCREEN.

    IF screen-group1 = 'B1'.

      screen-input = 0.

      MODIFY SCREEN. " Disable for input.</b>

    ENDIF.

  ENDLOOP.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_bukrs1.
