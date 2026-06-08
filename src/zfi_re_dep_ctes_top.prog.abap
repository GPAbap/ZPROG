*&---------------------------------------------------------------------*
*& Include          ZFI_RE_DEP_CTES_TOP
*&---------------------------------------------------------------------*
TABLES: kna1, bsad, bseg.

DATA: go_alv    TYPE REF TO cl_salv_table,
      go_layout TYPE REF TO cl_salv_layout,
      gs_key    TYPE salv_s_layout_key.

DATA: go_columns TYPE REF TO cl_salv_columns_table,
      go_column  TYPE REF TO cl_salv_column.

TYPES: BEGIN OF st_datos,

         kunnr   TYPE kunnr,
         nombre  TYPE char50,
         stcd3   TYPE stcd3,
         stras   TYPE stras_gp,
         pstlz   TYPE pstlz,
         ort01   TYPE ort01_gp,
         regio   TYPE regio,
         budat   TYPE budat,
         bldat   TYPE bldat,
         cpudt   TYPE cpudt,
         wrbtr   TYPE wrbtr,
         blart   TYPE blart,
         zzfpago TYPE zfpago,
         belnr   TYPE belnr_d,
         augbl   TYPE augbl,
         anulado TYPE stblg,
       END OF st_datos.

DATA it_datos TYPE STANDARD TABLE OF st_datos.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS P_BUKrs TYPE bukrs OBLIGATORY.
  SELECT-OPTIONS: so_kunnr FOR kna1-kunnr ,
                  so_cpudt FOR bsad-cpudt,
                  so_budat FOR bsad-budat OBLIGATORY,
                  so_monat  FOR bsad-monat NO INTERVALS.
  PARAMETERS:     p_gjahr TYPE gjahr OBLIGATORY.


SELECTION-SCREEN END OF BLOCK b1.
