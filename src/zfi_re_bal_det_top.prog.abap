*&---------------------------------------------------------------------*
*& Include          ZFI_RE_BAL_DET_TOP
*&---------------------------------------------------------------------*


TABLES: acdoca.

TYPES: BEGIN OF ty_cuenta_det,
         bukrs TYPE bukrs,
         racct TYPE acdoca-racct,
         koart TYPE koart,
       END OF ty_cuenta_det.

TYPES: BEGIN OF ty_saldo,
         bukrs TYPE bukrs,
         racct TYPE acdoca-racct,
         saldo TYPE acdoca-hsl,
       END OF ty_saldo.

TYPES: BEGIN OF ty_detalle,
         bukrs  TYPE bukrs,
         racct  TYPE acdoca-racct,
*         subracct TYPE acdoca-racct,
         koart  TYPE koart,
         bp     TYPE char10,
         nombre TYPE char80,
         saldo  TYPE acdoca-hsl,
       END OF ty_detalle.

DATA: gt_cfg     TYPE STANDARD TABLE OF ty_cuenta_det,
      gt_saldos  TYPE STANDARD TABLE OF ty_saldo,
      gt_detalle TYPE STANDARD TABLE OF ty_detalle.

TYPES ty_amount TYPE p LENGTH 16 DECIMALS 2.

TYPES: BEGIN OF ty_out,
         ind        TYPE char1,
         cuentas    TYPE acdoca-racct,
         subcuentas TYPE char20,
         txt50      TYPE txt50,
         texto      TYPE char80,
         soc        TYPE bukrs,
         mon        TYPE waers,
         arrastre   TYPE ty_amount,
         saldo_ant  TYPE ty_amount,
         debe       TYPE ty_amount,
         haber      TYPE ty_amount,
         saldo_mes  TYPE ty_amount,
         total      TYPE ty_amount,
       END OF ty_out.

DATA: gt_out TYPE STANDARD TABLE OF ty_out.

DATA: it_balanzah TYPE STANDARD TABLE OF ty_out,
      it_balanzad TYPE STANDARD TABLE OF ty_out.
*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

**********Alv Jerarquico
DATA: st_keyinfo TYPE slis_keyinfo_alv,
      lt_sort    TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      gt_events  TYPE slis_t_event,
      lf_layout  TYPE slis_layout_alv.    "Manejar diseño de layout




SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY,
              p_versn TYPE versn_011 OBLIGATORY,
              p_rldnr TYPE acdoca-rldnr DEFAULT '0L' OBLIGATORY,
              p_gjahr TYPE gjahr OBLIGATORY,
              p_poper TYPE poper OBLIGATORY.

  SELECT-OPTIONS: s_racct FOR acdoca-racct.
SELECTION-SCREEN END OF BLOCK b1.
