*&---------------------------------------------------------------------*
*& Include zsd_re_traza_docs_top
*&---------------------------------------------------------------------*

TYPES: slis.
TABLES: vbrk, vbak, vbrp,kna1 .


DATA it_outtable TYPE STANDARD TABLE OF zsd_st_trazafacts.
DATA gv_t_fieldcat TYPE slis_t_fieldcat_alv.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t01.

  SELECT-OPTIONS: s_bukrs FOR vbrk-bukrs NO INTERVALS,
                  s_vkorg FOR vbrk-vkorg OBLIGATORY,
                  s_vtweg     FOR vbak-vtweg,
                  s_spart     FOR vbak-spart,
                  s_fkdat FOR vbrk-fkdat OBLIGATORY,
                  s_kunrg FOR kna1-kunnr NO INTERVALS,
                  s_vbtyp FOR vbrk-vbtyp NO INTERVALS DEFAULT 'M',
                  s_vbeln for vbrk-vbeln.

SELECTION-SCREEN END OF BLOCK b1.
