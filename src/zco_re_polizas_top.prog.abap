*&---------------------------------------------------------------------*
*& Include          ZCO_RE_POLIZAS_TOP
*&---------------------------------------------------------------------*
TABLES: bseg,
        BKPf.

TYPES: slis.

DATA acumulado(007) TYPE p DECIMALS 02.
DATA cargo(007) TYPE p DECIMALS 02.

DATA: it_polizas TYPE STANDARD TABLE OF zco_st_polizas,
      wa_polizas LIKE LINE OF it_polizas.

DATA %runmode TYPE aqlimode.
DATA %seloptions TYPE TABLE OF rsparams WITH HEADER LINE.

FIELD-SYMBOLS <%selopt> TYPE rsparams_tt.

DATA gt_fieldcat TYPE slis_t_fieldcat_alv.

SELECTION-SCREEN BEGIN OF BLOCK qsel
  WITH FRAME TITLE TEXT-s02.
  SELECT-OPTIONS sp$00001 FOR bseg-bukrs MEMORY ID buk.
  SELECT-OPTIONS sp$00002 FOR bseg-belnr MEMORY ID bln.
  SELECT-OPTIONS sp$00003 FOR bseg-gjahr MEMORY ID gjr.
  SELECT-OPTIONS sp$00004 FOR bseg-hkont.
  SELECT-OPTIONS sp$00005 FOR bseg-kunnr MEMORY ID kun.
  SELECT-OPTIONS sp$00006 FOR bseg-lifnr MEMORY ID lif.
  SELECT-OPTIONS sp$00007 FOR bkpf-blart MEMORY ID bar.
  SELECT-OPTIONS sp$00008 FOR bkpf-budat.
SELECTION-SCREEN END OF BLOCK qsel.
SELECTION-SCREEN BEGIN OF BLOCK stdsel WITH FRAME TITLE TEXT-s03.
  PARAMETERS %layout TYPE slis_vari MODIF ID lay.
SELECTION-SCREEN END OF BLOCK stdsel.
