*&---------------------------------------------------------------------*
*& Include          ZCO_KKAO_MASS_TOP
*&---------------------------------------------------------------------*
TABLES: t001w.
DATA: bcdata_wa  TYPE bdcdata,
      bcdata_tab TYPE TABLE OF bdcdata.
DATA messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: l_mstring(480).
DATA: l_subrc LIKE sy-subrc.

TYPES: BEGIN OF st_log,
         msg TYPE char255,
       END OF st_log.

DATA: it_log TYPE STANDARD TABLE OF st_log.
FIELD-SYMBOLS <fs_log> TYPE st_log.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS so_werks FOR t001w-werks OBLIGATORY.
  PARAMETERS: p_wip  TYPE bis_abgr_m OBLIGATORY,
              p_ejer TYPE bis_abgr_j OBLIGATORY,
              p_vers TYPE versn OBLIGATORY ,
              p_test TYPE testl.
              "p_sal  TYPE testl.


  PARAMETERS: ck_mode1 RADIOBUTTON GROUP r1,
              ck_mode2 RADIOBUTTON GROUP r1.

SELECTION-SCREEN END OF BLOCK b1.
