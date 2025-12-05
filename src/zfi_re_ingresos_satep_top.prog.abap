*&---------------------------------------------------------------------*
*& Include zfi_re_ingresos_satep_top
*&---------------------------------------------------------------------*

*DATA: lo_screen TYPE REF TO lcl_screen.
*DATA: lo_appl TYPE REF TO lcl_appl.
*DATA: lt_data        TYPE  zingresos_output_t2,
*      lt_data_riva   TYPE zing_reps_output_t,
*      lt_data_rISR   TYPE zing_reps_output_t,
*      lt_data_RESING TYPE zing_reps_output_t.

TYPE-POOLS: slis.
TABLES: bkpf, acdoca, bseg, kna1.



DATA: gt_bkpf TYPE STANDARD TABLE OF bkpf.

DATA: gtext(100)  TYPE c,
      gtext2(100) TYPE c,
      gtext3(100) TYPE c.

*** Para el complemento de pagos
DATA: i_lineitems      TYPE bapi3007_2 OCCURS 0 WITH HEADER LINE,
      i_lineitems_comp TYPE bapi3007_2 OCCURS 0 WITH HEADER LINE,
      i_return         TYPE bapireturn OCCURS 0 WITH HEADER LINE,
      i_fechas         TYPE rsdsselopt OCCURS 0 WITH HEADER LINE,
      i_customer       TYPE rsdsselopt OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF i_documentos OCCURS 0,
        tipo     TYPE c LENGTH 5,
        factura  TYPE vbeln,
        doc_pago TYPE belnr_d,
        doc_comp TYPE belnr_d,
        doc_clr  TYPE belnr_d,
        kunnr    TYPE kunnr.
DATA: END OF i_documentos.

DATA: i_zalv_comp_pago     TYPE zalv_comp_pago OCCURS 0 WITH HEADER LINE,
      i_zalv_comp_pago_ref TYPE zalv_comp_pago OCCURS 0 WITH HEADER LINE.
*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      lf_layout   TYPE slis_layout_alv,    "Manejar diseño de layout
      t_sort      TYPE slis_t_sortinfo_alv.


DATA it_ingresos_union TYPE STANDARD TABLE OF zfi_st_ingresos_satep.
DATA it_ingresos_rv TYPE STANDARD TABLE OF zfi_st_ingresos_satep.
DATA it_ingresos TYPE STANDARD TABLE OF zfi_st_ingresos_satep.
DATA i_bsad     TYPE bsad_view OCCURS 0 WITH HEADER LINE.
DATA: gt_data           TYPE zalv_comp_pago OCCURS 0 WITH HEADER LINE.
DATA: v_flag_ci TYPE c.
DATA: v_zuonr_ci TYPE BSAD_view-zuonr.
DATA: v_ejercicio   TYPE gjahr, v_ejerciciom1,v_ejerciciop1.
DATA: i_vbrk TYPE vbrk OCCURS 0 WITH HEADER LINE,
      i_bkpf TYPE bkpf OCCURS 0 WITH HEADER LINE.

data: V_MONTO_PAGO_DOC    TYPE P DECIMALS 2,
      V_MONTO_FACT_DOC    TYPE P DECIMALS 2,
      V_MONTO_PAGO_LOCAL  TYPE P DECIMALS 2,
      V_MONTO_FACT_LOCAL  TYPE P DECIMALS 2,
      V_WT_QBSHB          LIKE WITH_ITEM-WT_QBSHB,
      V_FECHA_PAGO        TYPE DATUM,
      V_MONTO_PAGO_LOCAL2 TYPE P DECIMALS 2,
      V_MONTO_PAGO_DOC2   TYPE P DECIMALS 2.

DATA: BEGIN OF I_BSID_BSAD_PAGOS OCCURS 0,
        AUGBL TYPE AUGBL,
        REBZG TYPE REBZG,
        WRBTR TYPE WRBTR,
        DMBTR TYPE DMBTR.
DATA: END OF I_BSID_BSAD_PAGOS.

DATA: it_xmlsat TYPE TABLE OF smum_xmltb,
      wa_xmlsat TYPE smum_xmltb,
      xml_file  TYPE zaxnare_el034.


SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-020 .
  PARAMETERS s_bukrs TYPE bukrs OBLIGATORY.
  PARAMETERS  p_gjahr TYPE bkpf-gjahr OBLIGATORY.

  SELECT-OPTIONS:
  " S_monat FOR bkpf-monat OBLIGATORY,
  "s_CPUDT FOR bkpf-cpudt ,
  s_kunnr FOR kna1-kunnr,
  s_budat FOR bkpf-budat.
  SELECT-OPTIONS: s_belnr FOR bkpf-belnr.


  SELECTION-SCREEN SKIP .

*  PARAMETERS: p_conta  RADIOBUTTON GROUP g1,
*              p_conci  RADIOBUTTON GROUP g1,
*              p_cocon  RADIOBUTTON GROUP g1,
*              p_rIVA   RADIOBUTTON GROUP g1,
*              p_rISR   RADIOBUTTON GROUP g1,
*              p_RESING RADIOBUTTON GROUP g1.

SELECTION-SCREEN END OF BLOCK b2.
