*&---------------------------------------------------------------------*
*& Include          ZSDFICO_RE_FACTS_JOB_JHV_TOP
*&---------------------------------------------------------------------*

TABLES: vbrk.

START-OF-SELECTION.

  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
    SELECT-OPTIONS: p_vkorg FOR vbrk-vkorg,
                    p_vtweg FOR vbrk-vtweg,
                    p_fkdat FOR vbrk-fkdat,
                    p_fconta FOR vbrk-fkdat.

  SELECTION-SCREEN END OF BLOCK b1.
