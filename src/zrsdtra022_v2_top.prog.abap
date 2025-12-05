*&---------------------------------------------------------------------*
*& Include          ZRSDTRA022_V2_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: SLIS.

*-----     Especificaciones de Entrada
TABLES:
  t001w_biw,
  tvstt,
  vbfa,          " Flujo de Documentos comerciales
  likp,          " Entregas Cabecera
  lips,          " Entregas Posición
  kna1,          " Maestro de Clientes
  lfa1.          " Proveedores Transportistas

*Estructura de parámetros
DATA: lf_layout    TYPE slis_layout_alv,    "Manejar diseño de layout
      it_topheader TYPE slis_t_listheader,  "Manejar cabecera del rep
      wa_top       LIKE LINE OF it_topheader. "Línea para cabecera

*Tablas. Catálogo de campos
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,"lvc_t_fcat.
      wa_fieldcat type slis_fieldcat_alv.

DATA usuarios(90) TYPE c VALUE
'MARY, AMENDOZA, AUDITORIA, AZUCARERAHX, AZUCARERAMC, SAMEZCUA, AMONTIEL, SPVENTAS'.
types: BEGIN OF st_rec,
        vkorg  LIKE likp-vkorg,      " Organización de Ventas
        vstel  LIKE likp-vstel,      " Puesto de Expedición
        vtext  LIKE tvstt-vtext,      " Descripción pto exp
        vbeln  LIKE likp-vbeln,      " Entrega
        kunag  LIKE likp-kunag,      " Solicitante
        kunnr  LIKE likp-kunnr,      " destinatario de mercancías
        name1  LIKE kna1-name1,      "nombre del destinatario
        erdat  LIKE likp-erdat,      " Fecha de creación de Entrega
        posnr  LIKE lips-posnr,      " Posición
        ntgew  LIKE lips-ntgew,      " Cantidad entregada
        werks  LIKE lips-werks,      " Centro
        txtmd  LIKE t001w_biw-txtmd, " nombre centro
        matnr  LIKE lips-matnr,      " Material
        ciudad LIKE kna1-ort02,      " Ciudad de entrega
        estado LIKE kna1-regio,      " Estado
        rfmng  LIKE vbfa-rfmng,      " Cantidad
        meins  LIKE vbfa-meins,      " Unidad de Medida Base
        rfwrt  LIKE vbfa-rfwrt,      " Valor referenciado
        entrega LIKE kna1-ort02,
        carta(10) TYPE c,
      END OF st_rec.
* Variables
data rec type STANDARD TABLE OF st_rec.

DATA:
  vkorg(4),
  soc(40),
  cont(2)      VALUE 0,
  precio       LIKE vbfa-rfwrt,
  operador(60),
  entrega(30).

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
*PARAMETERS:

  SELECT-OPTIONS:
    vkorg_p FOR likp-vkorg OBLIGATORY,       " Organización de ventas
    erdat_p FOR likp-erdat OBLIGATORY,       " Fecha de entrega
    kunag_p FOR likp-kunag,                  " Cliente (solicitante)
    werks_p FOR lips-werks,                  " Centro
    matnr_p FOR lips-matnr.                  " Material
*    LIFNR_P FOR ZENT-LIFNR.                  " Proveedor transportista
SELECTION-SCREEN END OF BLOCK block1.
