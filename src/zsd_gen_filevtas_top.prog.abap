*&---------------------------------------------------------------------*
*&  Include           ZREP_BVTAS_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZREP_BASCULA_TOP
*&---------------------------------------------------------------------*

REPORT  zrep_bascula.
TYPE-POOLS : rsanm, abap.


DATA : lt_file_table       TYPE rsanm_file_table,
       ls_file_table       TYPE rsanm_file_line,
       lv_applserv         TYPE char01,
       lv_title            TYPE string,
       lv_gui_extension    TYPE string,
       lv_gui_ext_filter   TYPE string,
       lv_canceled         TYPE as4flag,
       lv_applserv_logical TYPE as4flag,
       lv_applserv_al11    TYPE as4flag,
       lv_file_name        TYPE string,
       lv_lines_written    TYPE i.


DATA: go_container TYPE REF TO cl_gui_custom_container,
      r_layout     TYPE slis_layout_alv,
      go_alv_grid  TYPE REF TO cl_gui_alv_grid.

DATA: zbasculavtas_0  TYPE zbasculavtas_0.
DATA: zbasculavtas_1  TYPE zbasculavtas_1.
DATA: zbascula00      TYPE zbascula00.

DATA: sb0   TYPE zbasculavtas_0.
DATA: tb1   TYPE STANDARD TABLE OF zbasculavtas_1.
DATA: sb1   TYPE zbasculavtas_1.
DATA: sb2   TYPE zbasculavtas_2.
DATA: tb3   TYPE STANDARD TABLE OF zbasculavtas_3.
DATA: sb3   TYPE zbasculavtas_3.
DATA: sb4   TYPE zbasculavtas_4.
*DATA: sb00  TYPE zbascula00.
*DATA: tb00  TYPE STANDARD TABLE OF zbascula00.

DATA: tflow TYPE tdt_docflow.
DATA: sflow LIKE LINE OF tflow.
DATA: gd_vbeln_vl TYPE vbeln_vl.

TYPES: BEGIN OF ty_rep.
*   ebeln   TYPE ekko-ebeln,
*   matnr   TYPE ekpo-matnr,
         INCLUDE STRUCTURE zrep_bascula_vtas.
TYPES: END OF ty_rep.

TYPES: BEGIN OF ty_cvs.
*   ebeln   TYPE ekko-ebeln,
*   matnr   TYPE ekpo-matnr,
         INCLUDE STRUCTURE zrep_bascula_vtas_cvs.
TYPES: END OF ty_cvs.




**DATA: BEGIN OF tt_rep.
**DATA: include TYPE zrep_bascula,
**END OF tt_rep.

DATA: trep  TYPE STANDARD TABLE OF ty_rep.
DATA: srep  LIKE LINE OF trep.

data it_csv type STANDARD TABLE OF ty_cvs.

DATA: tfieldcat    TYPE slis_t_fieldcat_alv,
      sfieldcat    LIKE LINE OF tfieldcat,

      gt_events    TYPE slis_t_event WITH HEADER LINE,        "ALV table

      gt_sort      TYPE slis_t_sortinfo_alv  WITH HEADER LINE, "ALV table
      it_eventexit TYPE slis_t_event_exit,
      wa_eventexit TYPE slis_event_exit.

DATA  svbap TYPE vbap.
DATA  svbak TYPE vbak.

DATA: BEGIN OF tab_kna1 OCCURS 0.
        INCLUDE STRUCTURE kna1.
DATA: END OF tab_kna1.


SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME TITLE TEXT-001.

  PARAMETERS:     p_werks  TYPE t001w-werks.

  SELECT-OPTIONS:
                  so_erdat   FOR zbasculavtas_0-fechape, " DEFAULT sy-datum,
                  so_basnr   FOR zbascula00-basnr,
                  so_vbeln   FOR  zbasculavtas_1-vbeln.

  SELECTION-SCREEN: BEGIN OF BLOCK block01 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN: END OF BLOCK block01.
SELECTION-SCREEN: END OF BLOCK main.
