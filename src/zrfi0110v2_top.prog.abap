*&---------------------------------------------------------------------*
*& Include          ZRFI0110V2_TOP
*&---------------------------------------------------------------------*
TABLES:
  T001,     " Sociedades
  KNA1,     " Maestro de clientes (parte general)
  LFA1,     " Maestro de proveedores (parte general)
  BSEG,     " Segmento de documento de Contabilidad
  BKPF,     " Maestro de documentos contables
  GLT0,     " Cifras movimientos reg.maestro ctas.mayor
  ZIVA1,    " Maestro de Impuestos Ingenios
  ZIVAI.    " Movimientos de Impuestos

***************************A ALV
* Inicia Declaraciones ALV ******************************************
* ALV
TYPE-pools: slis.
* cabecera.
DATA: wa_fieldcat   TYPE slis_fieldcat_alv,
      wa_format     TYPE slis_layout_alv,
      wa_gs_line    TYPE slis_listheader,
      gt_header     TYPE slis_t_listheader,
      wa_header     TYPE slis_listheader,
      gt_line       LIKE wa_header-info,

* Catalogo.
      gt_fieldcat   TYPE STANDARD TABLE OF slis_fieldcat_alv,
      gv_title      TYPE lvc_title,
      wa_variant    TYPE disvariant,
      gv_program    TYPE sy-repid,

* Color.
      gt_colts      TYPE lvc_s_scol,
      gt_coltc      TYPE lvc_t_scol,
      gv_table      TYPE ddobjname,
      gv_conta      TYPE tabfdpos,
      gv_field      TYPE fieldname,
      gv_col        TYPE C.


* SORT
DATA : it_sort TYPE slis_t_sortinfo_alv, "internal table para ordenar
      wa_sort TYPE slis_sortinfo_alv. "work area para ordenar



FIELD-SYMBOLS:<M>.
DATA:VALOR(10) TYPE C VALUE 'GLT0-HSLXX',
      MES(2) TYPE C.

* TABLA INTERNA
* Para Cargar los registros correspondientes de la tabla BSEG
TYPES:
BEGIN OF st_BSEG,
  BUKRS Type BUKRS,             " SOCIEDAD
  BELNR Type BELNR_D,             " DOCUMENTO
  GJAHR type GJAHR,             " EJERCICIO
  KOART type KOART,             " CLASE DE CUENTA
  KUNNR type KUNNR,             " DEUDOR
  LIFNR type LIFNR,             " PROVEEDOR
  ACRED type LIFNR,             " ACREEDOR
  STCD1 type STCD1,             " RFC
  NAME1 type NAME1,             " NOMBRE
  NAME2 type NAME2,             " NOMBRE
  KTOKK type KTOKK,             " GRUPO DE CUENTAS ACREEDOR
  DMBTR type DMBTR,             " IMPORTE DE IVA EN MONEDA LOCAL
  HWBAS type HWBAS,             " BASE DE IVA EN MONEDA LOCAL
  TOTAL type WRBTR,             " TOTAL DEL DOCUMENTO
  BAND(1),
  MWSKZ type MWSKZ,             " CODIGO DE IMPUESTO
  BUDAT type BUDAT,             " FECHA CONTABILIZACION DOCTO
  FECHA type BUDAT,             " OTRA FECHA
  BLART type BLART,             " CLASE DE DOCTO
  XBLNR type XBLNR,             " NUM DOCTO DE REFERENCIA
  SHKZG type SHKZG,             " INDICADOR DEBE/HABER
  HKONT type HKONT, "cuenta
******************************* PEDIDO ********
  EBELN type EBELN,
END OF st_BSEG.



TYPES:
BEGIN OF ty_final,
  BUKRS LIKE BSEG-BUKRS,             " SOCIEDAD
  BELNR LIKE BSEG-BELNR,             " DOCUMENTO
  GJAHR LIKE BSEG-GJAHR,             " EJERCICIO
  KOART LIKE BSEG-KOART,             " CLASE DE CUENTA
  KUNNR LIKE BSEG-KUNNR,             " DEUDOR
  LIFNR LIKE BSEG-LIFNR,             " PROVEEDOR
  ACRED LIKE BSEG-LIFNR,             " ACREEDOR
  STCD1 LIKE LFA1-STCD1,             " RFC
  NAME1 LIKE LFA1-NAME1,             " NOMBRE
  NAME2 LIKE LFA1-NAME2,             " NOMBRE
  KTOKK LIKE LFA1-KTOKK,             " GRUPO DE CUENTAS ACREEDOR
  DMBTR LIKE BSEG-DMBTR,             " IMPORTE DE IVA EN MONEDA LOCAL
  HWBAS LIKE BSEG-HWBAS,             " BASE DE IVA EN MONEDA LOCAL
  TOTAL LIKE BSEG-WRBTR,             " TOTAL DEL DOCUMENTO
  BAND(1),
  MWSKZ LIKE BSEG-MWSKZ,             " CODIGO DE IMPUESTO
  BUDAT LIKE BKPF-BUDAT,             " FECHA CONTABILIZACION DOCTO
  FECHA LIKE BKPF-BUDAT,             " OTRA FECHA
  BLART LIKE BKPF-BLART,             " CLASE DE DOCTO
  XBLNR LIKE BKPF-XBLNR,             " NUM DOCTO DE REFERENCIA
  SHKZG LIKE BSEG-SHKZG,             " INDICADOR DEBE/HABER
  fec_cor(10) TYPE C,
  IMP_TOT LIKE BSEG-WRBTR,
  NAT_CTA(1)      TYPE C,
  HKONT LIKE BSEG-HKONT,
  txt20 LIKE skat-TXT20,
END OF ty_final.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
  P_BUKRS LIKE BSEG-BUKRS OBLIGATORY,     "SOCIEDAD
  GJAHR LIKE BSEG-GJAHR OBLIGATORY.       "EJERCICIO
  SELECT-OPTIONS:
  P_BUDAT FOR BKPF-BUDAT.                 " FECHA DE CREACION
SELECTION-SCREEN END OF BLOCK BLOCK1.

DATA: it_final TYPE TABLE OF ty_final,
      wa_final LIKE LINE OF it_final,
      tab_bseg type STANDARD TABLE OF st_bseg.

DATA: lv_kokrs TYPE kokrs.

DATA :
      TIP_1(50)       TYPE C
      VALUE 'RG01,RG02,RG03,RG04,RG05,RS01,RS02,RS03,RS04,RS05',
      TIP_2(20)       TYPE C VALUE 'PF02,PM02',
      TIP_3(20)       TYPE C VALUE 'PF01,PM01',
      SUB_TOT_GEN     LIKE BSEG-WRBTR VALUE 0,
      IVA_GEN         LIKE BSEG-WRBTR VALUE 0,
      TOT_GEN         LIKE BSEG-WRBTR VALUE 0,
      SUB_TOT_COR     LIKE BSEG-WRBTR,
      IVA_COR         LIKE BSEG-WRBTR,
      TOT_COR         LIKE BSEG-WRBTR,
      TOT_REG_COR     LIKE SY-TABIX,
      TOT_REG_GEN     LIKE SY-TABIX VALUE 0,
      TOT_IVA_08      LIKE BSEG-WRBTR VALUE 0, " Modificacion nuevo iva 08% MGM 20190319
      TOT_IVA_11      LIKE BSEG-WRBTR VALUE 0, " Modificacion nuevo iva 11% ORG 02.02.2010
      TOT_IVA_16      LIKE BSEG-WRBTR VALUE 0, " Modificacion nuevo iva 16% ORG 02.02.2010
      TOT_IVA_CLI     LIKE BSEG-WRBTR VALUE 0,
      NAT_CTA(1)      TYPE C,
      IVA_PJE(4) TYPE C,
      IMP_TOT LIKE BSEG-WRBTR,
      FECHA   LIKE BKPF-BUDAT.
