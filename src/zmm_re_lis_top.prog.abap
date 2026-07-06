*&---------------------------------------------------------------------*
*& Include          ZMM_RE_LIS_TOP
*&---------------------------------------------------------------------*



TABLES: matdoc, mara, makt, mard, mbew, s032.

TYPES: BEGIN OF ty_out,
         matnr        TYPE matnr,
         maktx        TYPE maktx,
         werks        TYPE werks_d,
         lgort        TYPE lgort_d,
         bklas        TYPE bklas,
         stock_actual TYPE menge_d,
         valor_stock  TYPE dmbtr,
         cant_ent     TYPE menge_d,
         valor_ent    TYPE dmbtr,
         cant_sal     TYPE menge_d,
         valor_sal    TYPE dmbtr,
         ult_ent      TYPE budat,
         ult_sal      TYPE budat,
         num_ent      TYPE i,
         num_sal      TYPE i,
         inv_ini_val  TYPE dmbtr,
         inv_fin_val  TYPE dmbtr,
         inv_prom_val TYPE dmbtr,
         rotacion     TYPE p LENGTH 16 DECIMALS 4,
         dias_inv     TYPE p LENGTH 16 DECIMALS 2,
       END OF ty_out.

DATA: gt_out TYPE STANDARD TABLE OF ty_out,
      gs_out TYPE ty_out.

CONSTANTS: gc_dias_periodo TYPE i VALUE 365.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
    s_werks FOR matdoc-werks OBLIGATORY,
    s_lgort FOR matdoc-lgort,
    s_matnr FOR matdoc-matnr.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS: s_mtart FOR s032-mtart,
                  s_matkl FOR s032-matkl.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
  SELECT-OPTIONS: s_budat FOR matdoc-budat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b3.
