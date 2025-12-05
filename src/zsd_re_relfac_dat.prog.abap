*&---------------------------------------------------------------------*
*& Include          ZSD_RE_RELFAC_DAT
*&---------------------------------------------------------------------*

TABLES:
  vbak,     " Documento de ventas: Datos de cabecera
  vbuk,     " Documento comercial: Status cabecera y datos gestión
  vbrk,          " cabecera de facturas
  vbrp,          " detalle de facturas
  vbkd,          " Documento de ventas: Datos comerciales
  vbap,          " Documento de ventas: Datos de posición
  vbpa,          " Interlocutor de documentos comerciales
  kna1,          " maestro de clientes
  t247,
  t171t,
  tvkot,
  tvfkt,
  t001w,
  konv,
*PROCETI2 8/JULIO/2016
  mara,
  t179t,
*PROCETI2 8/JULIO/2016
  vbfa,
  makt.
TYPE-POOLS: slis.

* INI PROCETI CJTC-DESK929404
TYPES: BEGIN OF ty_tvstt,
  spras TYPE tvstt-spras,
  vstel TYPE tvstt-vstel,
  vtext TYPE tvstt-vtext,
*  txnam_adr TYPE tvst-txnam_adr,
*  txnam_kop TYPE tvst-txnam_kop,
*  txnam_fus TYPE tvst-txnam_fus,
*  txnam_gru TYPE tvst-txnam_gru,
END OF ty_tvstt.
DATA: w_tvstt TYPE ty_tvstt.
DATA: t_tvstt TYPE TABLE OF ty_tvstt.
* FIN PROCETI CJTC-DESK929404

*CONSTANTS:
DATA: fieldtab TYPE slis_t_fieldcat_alv,
      heading  TYPE slis_t_listheader,
      layout   TYPE slis_layout_alv,
      EVENTS   TYPE slis_t_event,
      repname  LIKE sy-repid,
      f2code   LIKE sy-ucomm VALUE  '&ETA',
      g_save(1) TYPE C VALUE 'A',
      g_exit(1) TYPE C,
      t_sort     TYPE  slis_t_sortinfo_alv,
      e_sort     TYPE  slis_sortinfo_alv,

      g_variant LIKE disvariant,
      gx_variant LIKE disvariant,
      v_repid TYPE sy-repid,
      p_events TYPE slis_t_event,
      wa_fieldcat TYPE slis_fieldcat_alv.

* Tablas Internas
* Cabecera y Posición de las facturas
DATA:
BEGIN OF vbr OCCURS 0,
  vkbur LIKE vbrp-vkbur,          " 3 Oficina de ventas
  vkorg LIKE vbrk-vkorg,          " Organización de Ventas
  spart LIKE vbrk-spart,          " Sector
  vtweg LIKE vbrk-vtweg,          " canal de distribución
  vkgrp type vbak-vkgrp,          " Grupo de Vendedores --- Añadido el 16-03-2023 by Jaime Hernandez.
  bezei type TVGRT-bezei,         " Texto Grupo de vendedores
  fkdat LIKE vbrk-fkdat,          " Fecha de Factura
  vbeln LIKE vbrk-vbeln,          " Factura SAP
  fkart LIKE vbrk-fkart,          " Clase de Factura
  kunag LIKE vbrk-kunag,          " Solicitante
*    netwr LIKE vbrk-netwr,          " Valor Neto
  knumv LIKE vbrk-knumv,          " Número de condición
  bzirk LIKE vbrk-bzirk,          " zona de ventas
  kurrf LIKE vbrk-kurrf,          " Tipo de cambio
  fktyp LIKE vbrk-fktyp,          " Tipo de factura
  vbtyp LIKE vbrk-vbtyp,          " Tipo de docto comercial
  fksto LIKE vbrk-fksto,          " anulada
*    knumv like vbrk-knumv,          " Condición de precio
  werks LIKE vbrp-werks,                                  " 1 Centro
  posnr LIKE vbrp-posnr,          " 2 Posición
*    vkbur like vbrp-vkbur,          " 3 Oficina de ventas
  fkimg LIKE vbrp-fkimg,          " 4 cantidad facturada
  vrkme LIKE vbrp-vrkme,          " 5 Unidad de medida de venta
  matnr LIKE vbrp-matnr,          " 6 material
  kzwi1 LIKE vbrp-kzwi1,          " 7 precio Producto
  kzwi5 LIKE vbrp-kzwi5,          " 8 precio de Descuento
  netwr LIKE vbrp-netwr,          " Valor Neto
  ntgew LIKE vbrp-ntgew,          " 9 Peso Neto
  gewei LIKE vbrp-gewei,          " 10 Unidad de medida peso
  aubel LIKE vbrp-aubel,          " 11 Número de pedido
  aupos LIKE vbrp-aupos,          " 12 Posición del pedido
* INI PROCETI CJTC-DESK929556
*    KZWI2    TYPE KZWI2,
  kzwib1  TYPE kzwi1,
  kzwib2  TYPE kzwi2,
  kzwib5  TYPE kzwi5,
  kostl   TYPE kostl,
* FIN PROCETI CJTC-DESK929556

END OF vbr.
DATA:
BEGIN OF tab OCCURS 0,
  vkbur   LIKE vbrp-vkbur,          " Oficina de Ventas
  vkorg   LIKE vbrk-vkorg,          " Organización de Ventas
  spart   LIKE vbrk-spart,          " Sector
  vkgrp type vbak-vkgrp,
  bezei type TVGRT-bezei,         " Texto Grupo de vendedores
*    vkbur   like vbrp-vkbur,          " Oficina de Ventas
  vbtyp   LIKE vbrk-vbtyp,           " Tipo de docto comercial
  fkdat   LIKE vbrk-fkdat,          " Fecha de Factura
  matnr   LIKE vbrp-matnr,          " material
  bzirk   LIKE vbrk-bzirk,          " zona de ventas
  kunnr   LIKE vbpa-kunnr,          " destinatario de mercancías.
  vbeln   LIKE vbrk-vbeln,          " Factura SAP
  fkart   LIKE vbrk-fkart,          " Clase de Factura
  werks   LIKE vbrp-werks,                                " 1 Centro
  posnr   LIKE vbrp-posnr,          " Posición de la factura
  kunag   LIKE vbrk-kunag,          " Solicitante
  netwr   LIKE vbrp-netwr,          " Valor Neto
*    netwr   LIKE vbrk-netwr,          " Valor Neto
  knumv   LIKE vbrk-knumv,          " Número de condición
  bztxt   LIKE t171t-bztxt,         " Desc Zona Ventas
  maktx   LIKE makt-maktx,          " Desc Material
*PROCETI2 8/JULIO/2016
  prdha   LIKE mara-prdha,          "Jerarquía de productos
  vtext1  LIKE t179t-vtext,         "Denominación
*PROCETI2 8/JULIO/2016
  fkimg   LIKE vbrp-fkimg,          " cantidad facturada
  vrkme   LIKE vbrp-vrkme,          " Unidad de medida de venta
  kzwi1   LIKE vbrp-kzwi1,          " precio Producto
  kzwi5   LIKE vbrp-kzwi5,          " precio de flete
  name1   LIKE kna1-name1,          " Nombre Cliente
  namewe  LIKE kna1-name1,          " Nombre Cliente
  ort01   LIKE kna1-ort01,          " Destino
  vtweg   LIKE vbrk-vtweg,          "
  kurrf   LIKE vbrk-kurrf,            " Tipo de cambio
  fktyp   LIKE vbrk-fktyp,            " Tipo de factura
  aubel   LIKE vbrp-aubel,          " Número de pedido
  aupos   LIKE vbrp-aupos,          " Posición del pedido
  ntgew   LIKE vbrp-ntgew,          " Peso Neto
  gewei   LIKE vbrp-gewei,          " Unidad de medida peso
  ihrez   LIKE vbkd-ihrez,          " Remisión
  bstkd   like vbkd-bstkd,          "Referencia Cliente
  posex   LIKE vbap-posex,          " Caseta
  vstel   LIKE vbap-vstel,  " Pto.exped."PROCETI CJTC-DESK929404
  vtext   LIKE tvfkt-vtext,
  name1c  LIKE t001w-name1,
*    knumv   like vbrk-knumv,          " Cindición de precio
  precio  LIKE konv-kbetr,
  fksto LIKE vbrk-fksto,             " anulada
* bonificación
  bonif   LIKE konv-kbetr,
  bocan   LIKE vbrp-fkimg,          " cantidad facturada
  bounv   LIKE vbrp-vrkme,          " Unidad de medida de venta
  bokgs   LIKE vbrp-ntgew,          " Peso Neto
  boump   LIKE vbrp-gewei,          " Unidad de medida peso
  bovbe   LIKE vbrk-vbeln,          " Documento de bonificación
* INI PROCETI CJTC-DESK929556
  kzwi2	  TYPE kzwi2,
  kzwib1  TYPE kzwi1,
  kzwib2  TYPE kzwi2,
  kzwib5  TYPE kzwi5,
  kostl   TYPE kostl,
* FIN PROCETI CJTC-DESK929556
END OF tab.
DATA:
BEGIN OF tab_p OCCURS 0,
  vkorg      LIKE vbak-vkorg,        " Organización de Ventas
  vtweg      LIKE vbak-vtweg,        " Canal de distribución
  spart      LIKE vbak-spart,        " SECTOR
  vkbur      LIKE vbak-vkbur,        " OFICINA DE VENTAS
  vbeln      LIKE vbak-vbeln,        " FACTURA SAP
  audat      LIKE vbak-audat,        " FECHA DEL PEDIDO
  vbtyp      LIKE vbak-vbtyp,       " CLASE DE FACTURA
  ernam      LIKE vbak-ernam,        " creado por
  bstnk      LIKE vbak-bstnk,        " Número de pedido
  zuonr      LIKE vbak-zuonr,        " Asignación
END OF tab_p.
DATA:
BEGIN OF it_salida OCCURS 0,
  fkdat   LIKE vbrk-fkdat,          " Fecha de Factura
  vbeln   LIKE vbrk-vbeln,          " Factura SAP
  aubel   LIKE vbrp-aubel,          " Número de pedido
  ihrez   LIKE vbkd-ihrez,          " Remisión
  bstkd   like vbkd-bstkd,          "Referencia del cliente
  vtext   LIKE tvfkt-vtext,
  kunag   LIKE vbrk-kunag,          " Solicitante
  name1   LIKE kna1-name1,          " Nombre Cliente
  ort01   LIKE kna1-ort01,          " Destino
  name1c  LIKE t001w-name1,
  posex   LIKE vbap-posex,          " Caseta
  matnr   LIKE vbrp-matnr,          " material
  maktx   LIKE makt-maktx,          " Desc Material
*PROCETI2 8/JULIO/2016
  prdha   LIKE mara-prdha,          "Jerarquía de productos
  vtext1  LIKE t179t-vtext,         "Denominación
*PROCETI2 8/JULIO/2016
  fkimg   LIKE vbrp-fkimg,          " cantidad facturada
  vrkme   LIKE vbrp-vrkme,          " Unidad de medida de venta
  ntgew   LIKE vbrp-ntgew,          " Peso Neto
  gewei   LIKE vbrp-gewei,          " Unidad de medida peso
  promedio LIKE vbrp-ntgew,
*    GEWEI   like vbrp-GEWEI,          " Unidad de medida peso
  bztxt   LIKE t171t-bztxt,         " Desc Zona Ventas
  precio  LIKE konv-kbetr,
  netwr   LIKE vbrp-netwr,          " Valor Neto
  bocan   LIKE vbrp-fkimg,          " cantidad facturada
  bounv   LIKE vbrp-vrkme,          " Unidad de medida de venta
  bokgs   LIKE vbrp-ntgew,          " Peso Neto
  boump   LIKE vbrp-gewei,          " Unidad de medida peso
  bonif   LIKE konv-kbetr,
  bovbe   LIKE vbrk-vbeln,          " Documento de bonificación
  vkbur   LIKE vbrp-vkbur,          " Oficina de Ventas
  vkorg   LIKE vbrk-vkorg,          " Organización de Ventas
  spart   LIKE vbrk-spart,
  vkgrp type vbak-vkgrp,
  bezei type TVGRT-bezei,         " Texto Grupo de vendedores
  vtweg   LIKE vbrk-vtweg,
* INI PROCETI CJTC-DESK929404
  vstel   TYPE vbap-vstel,    " Pto.exped/ent.mcía.
  vtex2   LIKE tvfkt-vtext,
* FIN PROCETI CJTC-DESK929404
* INI PROCETI CJTC-DESK929556
  kzwi1	  LIKE vbrp-kzwi1,
  kzwi2	  LIKE vbrp-kzwi2,
  kzwi5	  LIKE vbrp-kzwi5,
  kzwib1  LIKE vbap-kzwi1,
  kzwib2  LIKE vbap-kzwi2,
  kzwib5  LIKE vbap-kzwi5,
  kostl   LIKE vbak-kostl,
* FIN PROCETI CJTC-DESK929556
END OF it_salida.

DATA:
      promedio LIKE vbrp-ntgew,
      gjahr_p LIKE vbrk-gjahr,
      fecha LIKE vbrk-fkdat.

DATA: it_fieldcat TYPE slis_t_fieldcat_alv.
DATA: w_fieldcat LIKE LINE OF it_fieldcat. " PROCETI CJTC-DESK929404
*---------------------------------------------------------------------*
*--------              Pantalla de Selección                 ---------*
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
  vkorg_p FOR vbrk-vkorg,      " Organización de ventas
  spart_p FOR vbrk-spart,      " Sector
  vkbur_p FOR vbrp-vkbur, " Oficina de Ventas
  so_VKGRP for vbak-vkgrp,
  fkdat_p FOR vbrk-fkdat,      " Fecha de factura
  o_kunag FOR vbrk-kunag,      " Solicitante. PROCETI CJTC-DESK929556
  o_kostl FOR vbak-kostl
  . " PROCETI CJTC-DESK929658
*NO-DISPLAY
*PARAMETERS:
*  fkdat_d LIKE vbrk-fkdat.     " Día a relacionar
SELECTION-SCREEN END OF BLOCK block1.
