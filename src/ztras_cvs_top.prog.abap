*&---------------------------------------------------------------------*
*&  Include           ZREP_BVTAS_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZREP_BASCULA_TOP
*&---------------------------------------------------------------------*

REPORT  zrep_bascula.
TYPE-POOLS : rsanm, abap.

DATA: go_container TYPE REF TO cl_gui_custom_container,
      r_layout     TYPE slis_layout_alv,
      go_alv_grid  TYPE REF TO cl_gui_alv_grid.

DATA: zbasculatrasla_0  TYPE zbasculatrasla_0.
DATA: zbasculatrasla_1  TYPE zbasculatrasla_1.
DATA: zbascula00      TYPE zbascula00.




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


DATA: sb0   TYPE zbasculatrasla_0.
DATA: tb1   TYPE STANDARD TABLE OF zbasculatrasla_1.
DATA: sb1   TYPE zbasculatrasla_1.
DATA: sb2   TYPE zbasculatrasla_2.
DATA: tb3   TYPE STANDARD TABLE OF zbasculatrasla_3.
DATA: sb3   TYPE zbasculatrasla_3.
DATA: sb4   TYPE zbasculatrasla_4.
DATA: tb4   TYPE STANDARD TABLE OF zbasculatrasla_4.

*DATA: sb00  TYPE zbascula00.
*DATA: tb00  TYPE STANDARD TABLE OF zbascula00.

DATA: ld_filename TYPE string,
      ld_path     TYPE string,
      ld_fullpath TYPE string,
      ld_result   TYPE i,
      file        TYPE string.




TYPES: BEGIN OF ty_rep.
         INCLUDE STRUCTURE zrep_bascula_tras.
TYPES: END OF ty_rep.

TYPES: BEGIN OF st_csv.
*         bukrs       TYPE bukrs,
*         reswk       TYPE reswk,
*         werks       TYPE werks_d,
*         ebeln       TYPE ebeln,
*         tticket     TYPE ztick_tra,
*         ticketf     TYPE ze_ticketf,
*         matnr       TYPE matnr,
*         maktx       TYPE maktx,
*         peso_basdif TYPE string,"zbstmg1,
         include STRUCTURE zrep_bascula_tras_cvs.
types: END OF st_csv.


**DATA: BEGIN OF tt_rep.
**DATA: include TYPE zrep_bascula,
**END OF tt_rep.

DATA: trep  TYPE STANDARD TABLE OF ty_rep.
DATA: srep  LIKE LINE OF trep.

DATA: it_csv      TYPE STANDARD TABLE OF st_csv,
      it_csv_file TYPE truxs_t_text_data.


DATA: tfieldcat    TYPE slis_t_fieldcat_alv,
      sfieldcat    LIKE LINE OF tfieldcat,

      gt_events    TYPE slis_t_event WITH HEADER LINE,        "ALV table

      gt_sort      TYPE slis_t_sortinfo_alv  WITH HEADER LINE, "ALV table
      it_eventexit TYPE slis_t_event_exit,
      wa_eventexit TYPE slis_event_exit.


SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: so_werks  FOR zbasculatrasla_1-reswk.

  SELECT-OPTIONS:
                  so_erdat     FOR zbasculatrasla_1-f_proc_ent, " DEFAULT sy-datum,
                  so_ttick     FOR zbasculatrasla_1-tticket,
                  so_ebeln     FOR  zbasculatrasla_1-ebeln.

  SELECTION-SCREEN: BEGIN OF BLOCK block01 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN: END OF BLOCK block01.
SELECTION-SCREEN: END OF BLOCK main.
