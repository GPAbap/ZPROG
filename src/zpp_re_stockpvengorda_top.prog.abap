*&---------------------------------------------------------------------*
*& Include          ZPP_RE_STOCKPVENGORDA_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS slis.

TABLES: caufv, resbd, mseg, ztpp_mov_engorda.

TYPES: BEGIN OF st_outtable,
         aufnr       TYPE aufnr,
         werks       TYPE werks_d,
         cant_al     TYPE menge_d,
         decomiso    TYPE menge_d,
         natural     TYPE menge_d,
         desembarque TYPE menge_d,
         descartes   TYPE menge_d,
         salidas     TYPE menge_d,
         stock       TYPE menge_d,
         kg_pre      type menge_d,
         kg_inicia   type menge_d,
         kg_crec     type menge_d,
         kg_final    type menge_d,
         kg_final2   type menge_d,
         porc_mort   type menge_d,
         pesoprom    type menge_d,
         conversion  type menge_d,
         pollinaza   type menge_d,
         gstrp       TYPE pm_ordgstrp,
         name1       TYPE name1,
         kilos       TYPE menge_d,
         densidad    type menge_d,
         kgmts2      type menge_d,
         istat       TYPE j_txt30,
       END OF st_outtable.

DATA it_outtable TYPE STANDARD TABLE OF st_outtable.

FIELD-SYMBOLS <fs_table> TYPE st_outtable.
DATA: gt_fieldcat TYPE STANDARD TABLE OF  slis_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      gl_layout   TYPE slis_layout_alv.

DATA:
  gt_header     TYPE slis_t_listheader,
  wa_header     TYPE slis_listheader,
  t_line        LIKE wa_header-info,
  ld_lines      TYPE i,
  ld_linesc(10) TYPE c.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: so_orden FOR caufv-aufnr OBLIGATORY,
                  so_wers FOR caufv-werks.
SELECTION-SCREEN END OF BLOCK b1.
