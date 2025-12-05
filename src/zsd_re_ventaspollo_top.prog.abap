*&---------------------------------------------------------------------*
*& Include          ZSD_RE_VENTASPOLLO_TOP
*&---------------------------------------------------------------------*
TABLES: VBAK, VBAP, T685.

TYPE-POOLS: slis.

TYPES: BEGIN OF st_ventas,
  ERDAT type ERDAT,
  VBELN type VBELN,
  KUNNR type KUNNR,
  NAME1 TYPE NAME1_GP,
  SORT1 TYPE AD_SORT1,
  SORT2 TYPE AD_SORT2,
  END OF st_ventas.


data: it_ventas type STANDARD TABLE OF st_ventas.


*Estructura de parámetros
DATA: lf_layout    TYPE slis_layout_alv,    "Manejar diseño de layout
      it_topheader TYPE slis_t_listheader,  "Manejar cabecera del rep
      wa_top       LIKE LINE OF it_topheader. "Línea para cabecera

*Tablas. Catálogo de campos
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,"lvc_t_fcat.
      wa_fieldcat type slis_fieldcat_alv.
