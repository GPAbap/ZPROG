*&---------------------------------------------------------------------*
*& Include zsd_re_facfolfis_top
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

TABLES:
  vbrk,          " cabecera de facturas
  vbrp,          " detalle de facturas
  vbpa,          " Interlocutor de documentos comerciales
  kna1,          " maestro de clientes
  t247,
  t171t,
  tvkot,
  makt
  .

* Tablas Internas
* Cabecera y Posición de las facturas
DATA:
  BEGIN OF vbr OCCURS 0,
    vkorg       LIKE vbrk-vkorg,          " Organización de Ventas
    vtext       LIKE tvkot-vtext,         " Desc. Org. Vtas.
    spart       LIKE vbrk-spart,          " Sector
    vtweg       LIKE vbrk-vtweg,          " canal de distribución
    fkdat       LIKE vbrk-fkdat,          " Fecha de Factura
    vbeln       LIKE vbrk-vbeln,          " Factura SAP
    kunag       LIKE vbrk-kunag,          " Solicitante
    name1       LIKE kna1-name1,          " Nombre
    stcd1       LIKE kna1-stcd1,          " rfc
    netwr       LIKE vbrk-netwr,          " Valor Neto
    waerk       LIKE vbrk-waerk,          " Moneda
    knumv       LIKE vbrk-knumv,          " Número de condición
    bzirk       LIKE vbrk-bzirk,          " zona de ventas
    bztxt       LIKE t171t-bztxt,         " Desc. Zona de ventas
    kurrf       LIKE vbrk-kurrf,          " Tipo de cambio
    fktyp       LIKE vbrk-fktyp,          " Tipo de factura
    Vbtyp       LIKE vbrk-vbtyp,          " Tipo de docto comercial
    fksto       LIKE vbrk-fksto,          " ID factura anulada
    fkimg       LIKE vbrp-fkimg,          " cantidad facturada
    vrkme       LIKE vbrp-vrkme,          " Unidad de medida de venta
    matnr       LIKE vbrp-matnr,          " material
    maktx       LIKE makt-maktx,          "Desc. Material
    kzwi1       LIKE vbrp-kzwi1,          " precio Producto
    kzwi6       LIKE vbrp-kzwi6,          " precio de flete
    aubel       LIKE vbrp-aubel,          "Pedido de Venta
    belnr       LIKE vbrk-belnr,          "Factura
    txtinternos TYPE char20,              "Textos Internos
    fklmg       LIKE vbrp-fklmg,          "
    ntgew       LIKE vbrp-ntgew,                "Cantidad Facturada UMB.
    gewei       LIKE vbrp-gewei,                 "unidad de medida
    uuid        type string,

  END OF vbr.
DATA:
  BEGIN OF tab OCCURS 0,
    vkorg       LIKE vbrk-vkorg,          " Organización de Ventas
    vtext       LIKE tvkot-vtext,         " Desc. Org. Vtas.
    spart       LIKE vbrk-spart,          " Sector
    id(2),
    matnr       LIKE vbrp-matnr,          " material
    bzirk       LIKE vbrk-bzirk,          " zona de ventas
    fkdat       LIKE vbrk-fkdat,          " Fecha de Factura
    kunnr       LIKE vbpa-kunnr,          " destinatario de mercancías.
    vbeln       LIKE vbrk-vbeln,          " Factura SAP
    kunag       LIKE vbrk-kunag,          " Solicitante
    netwr       LIKE vbrk-netwr,          " Valor Neto
    waerk       LIKE vbrk-waerk,          " Moneda
    knumv       LIKE vbrk-knumv,          " Número de condición
    bztxt       LIKE t171t-bztxt,         " Desc Zona Ventas
    maktx       LIKE makt-maktx,          " Desc Material
    fkimg       LIKE vbrp-fkimg,          " cantidad facturada
    vrkme       LIKE vbrp-vrkme,          " Unidad de medida de venta
    kzwi1       LIKE vbrp-kzwi1,          " precio Producto
    kzwi6       LIKE vbrp-kzwi6,          " precio de flete
    name1       LIKE kna1-name1,          " Nombre Cliente
    namewe      LIKE kna1-name1,          " Nombre Cliente
    stcd1       LIKE kna1-stcd1,          " RFC
    vtweg       LIKE vbrk-vtweg,          "
    kurrf       LIKE vbrk-kurrf,            " Tipo de cambio
    fktyp       LIKE vbrk-fktyp,            " Tipo de factura
    Vbtyp       LIKE vbrk-vbtyp,            " Tipo de docto comercial
    fksto       LIKE vbrk-fksto,          " ID factura anulada
    folfis(36),                       " MGM 20190319
    aubel       LIKE vbrp-aubel,             "Documento de Ventas
    belnr       LIKE vbrk-belnr,             "factura
    txtinternos TYPE char20,              "Textos Internos
    ntgew       LIKE vbrp-ntgew,                "Cantidad Facturada UMB.
    gewei       LIKE vbrp-gewei,                 "unidad de medida

  END OF tab.
* Tabla interna de textos de cabecera   MGM 20190319
DATA: BEGIN OF t_textos OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA: END OF t_textos.
DATA: BEGIN OF t_textos2 OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA: END OF t_textos2.
DATA:
  tdname    LIKE thead-tdname,
  docto(20),
  gjahr_p   LIKE vbrk-gjahr,
  fecha     LIKE vbrk-fkdat.

*Estructura de parámetros
DATA: lf_layout    TYPE slis_layout_alv,    "Manejar diseño de layout
      it_topheader TYPE slis_t_listheader,  "Manejar cabecera del rep
      wa_top       LIKE LINE OF it_topheader. "Línea para cabecera

*Tablas. Catálogo de campos
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv, "lvc_t_fcat.
      wa_fieldcat TYPE slis_fieldcat_alv.

*****     PARAMETROS DE SELECCIÓN
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
    vkorg_p FOR vbrk-vkorg,      " Organización de ventas
    vtweg   FOR vbrk-vtweg,      "Canal de Distribución
    spart_p FOR vbrk-spart,      " Sector
    fkdat_p FOR vbrk-fkdat.      " Fecha de factura
*PARAMETERS:
*  fkdat_d LIKE vbrk-fkdat.     " Día a relacionar
SELECTION-SCREEN END OF BLOCK block1.
