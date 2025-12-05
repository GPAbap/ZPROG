*&---------------------------------------------------------------------*
*&  Include           ZREP_B_COMP_TOP_V2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZREP_BASCULA_TOP
*&---------------------------------------------------------------------*

REPORT  zrep_bascula_v3.
TYPE-POOLS slis.

DATA: go_container TYPE REF TO cl_gui_custom_container,
      r_layout     TYPE slis_layout_alv,
      go_alv_grid  TYPE REF TO cl_gui_alv_grid.

DATA: zbascula_0  TYPE zbascula_0.
DATA: zbascula_1  TYPE zbascula_1.

DATA: sb0   TYPE zbascula_0.
DATA: tb1   TYPE STANDARD TABLE OF zbascula_1.
DATA: sb1   TYPE zbascula_1.
DATA: sb2   TYPE zbascula_2.
DATA: tb3   TYPE STANDARD TABLE OF zbascula_3.
DATA: sb3   TYPE zbascula_3.

TYPES: BEGIN OF ty_rep.
*   ebeln   TYPE ekko-ebeln,
*   matnr   TYPE ekpo-matnr,
        INCLUDE STRUCTURE zrep_basculav3.
TYPES: END OF ty_rep.

DATA: BEGIN OF tt_rep.
DATA: include TYPE zrep_basculav2,
END OF tt_rep.

DATA: trep  TYPE STANDARD TABLE OF ty_rep.
DATA: srep  LIKE LINE OF trep.

DATA: tfieldcat    TYPE slis_t_fieldcat_alv,
      sfieldcat    LIKE LINE OF tfieldcat,

      gt_events    TYPE slis_t_event WITH HEADER LINE,        "ALV table

      gt_sort      TYPE slis_t_sortinfo_alv  WITH HEADER LINE, "ALV table
      it_eventexit TYPE slis_t_event_exit,
      wa_eventexit TYPE slis_event_exit.

DATA  smseg  type mseg.

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME TITLE text-001.

PARAMETERS:     p_werks  TYPE t001w-werks.

SELECT-OPTIONS:
                so_erdat FOR zbascula_0-fechape, " DEFAULT sy-datum,
                so_nnea  FOR zbascula_0-nnea,
                so_ebeln FOR zbascula_0-ebeln.

SELECTION-SCREEN: BEGIN OF BLOCK block01 WITH FRAME TITLE text-002.
*PARAMETERS: chscompl RADIOBUTTON GROUP gr01,
*            chsincom RADIOBUTTON GROUP gr01,
*            chsboth  RADIOBUTTON GROUP gr01.
SELECTION-SCREEN: END OF BLOCK block01.
SELECTION-SCREEN: END OF BLOCK main.
