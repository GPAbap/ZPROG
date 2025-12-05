*&---------------------------------------------------------------------*
*& Include          ZRFI0030_JHV_TOP
*&---------------------------------------------------------------------*
TABLES:
  lfa1,           " Maestro de Proveedores
  bsak,           " Docuementos de Provisión
  reguh,          " Documentos de contabilidad
  regup,
  bkpf.           " Cabecera de documentos

TYPE-POOLS: slis.
TYPES: SLIS.

*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

********para ALV
DATA: ti_header TYPE slis_t_listheader,
      st_header TYPE slis_listheader,
      lf_layout  TYPE slis_layout_alv.    "Manejar diseño de layout


* Parámetros de Selección
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
*PARAMETERS:
*  bukrs_p LIKE bkpf-bukrs DEFAULT 'SA01',  " Sociedad Pagadora
*  gjahr_p LIKE bkpf-gjahr DEFAULT sy-datum+0(4).  " Ejercicio
  SELECT-OPTIONS:
  bukrs_p FOR bkpf-bukrs,
  cpudt_p FOR bkpf-cpudt.      " fecha de registro
SELECTION-SCREEN END OF BLOCK block1.
* Tablas Internas
* Tabla para la selección de encabezados de documentos de pago
DATA: BEGIN OF cab OCCURS 0,
  bukrs  LIKE bkpf-bukrs,            " Sociedad
  gjahr  LIKE bkpf-gjahr,            " Ejercicio
  belnr  LIKE bkpf-belnr,            " Documento de Pago
  blart  LIKE bkpf-blart,            " clase de docto. (temporal)
  cpudt  LIKE bkpf-cpudt,
  budat  LIKE bkpf-budat,            " Fecha Contab pago
  xblnr  LIKE bkpf-xblnr,            " Cheque
  tcode LIKE bkpf-tcode,            " Cód Trx
END OF cab.
* Tabla para la selección del detalle de pagos
DATA: BEGIN OF tab_pago OCCURS 0,
* bkpf
  bukrs  LIKE bkpf-bukrs,            " Sociedad
  gjahr  LIKE bkpf-gjahr,            " Ejercicio
  belnr  LIKE bkpf-belnr,            " Documento de Pago
*  buzei  LIKE bseg-buzei,            " Posición
  blart  LIKE bkpf-blart,            " clase de docto. (temporal)
  budat  LIKE bkpf-budat,            " Fecha Contab pago
  xblnr  LIKE bkpf-xblnr,            " Cheque
  tcode  LIKE bkpf-tcode,            " Cod Trx
* reguh
  laufd  LIKE reguh-laufd,
  laufi  LIKE reguh-laufi,
  vblnr  LIKE reguh-vblnr,
  lifnr  LIKE reguh-lifnr,           " Proveedor o acreedor
  name1  LIKE reguh-name1,
  name2  LIKE reguh-name2,
  stcd1  LIKE reguh-stcd1,           " RFC
  waers  LIKE reguh-waers,           " Moneda
  zbnkn  LIKE reguh-zbnkn,
  rwbtr  LIKE reguh-rwbtr,
  rbetr  LIKE reguh-rbetr,
* regup
  belnr_d LIKE regup-belnr,
  xblnr_d LIKE regup-xblnr,
  dmbtr_d LIKE regup-dmbtr,
  wrbtr_d LIKE regup-wrbtr,
END OF tab_pago.
