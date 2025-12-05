*&---------------------------------------------------------------------*
*&  Include           ZRSD0026_DA_CONADESUCAV2_T01
*&---------------------------------------------------------------------*
TABLES:
  t001z,
  mara,
  vbrk,          " cabecera de facturas
  vbrp,          " detalle de facturas
  vbpa,          " Interlocutor de documentos comerciales
  kna1,          " maestro de clientes
  t247,
  t171t,
  tvkot,
  makt.
* Inicio ** 01/01/2020 *** Michael Chávez OT DESK940326
* ESTRUCTURAS TYPES*
TYPES:
  BEGIN OF ty_layout,
    vtext         TYPE vtext, "nombre ingenio
    rfc1          TYPE paval, "rfc sociedad marca ingenio
    rfc2          TYPE paval, "rfc sociedad del emisor
    stcd1         TYPE stcd1, "RFC receptor
    "fkdat TYPE fkdat, "Fecha factura
    fkdat         TYPE string, "lo cambie a string para que la fecha salga con /
    fectim    TYPE dats, "Fecha de timbrado,
    folfis(36)    TYPE c, "folio fiscal
    bismt         TYPE bismt, "id material SAT "tab-BISMT+0(8)
    maktx         TYPE maktx, "descripición material
    kzwi1         TYPE kzwi1, "precio producto
    vrkme         TYPE vrkme, "Unidad de medida de venta
    kzwi6         TYPE kzwi6, "Importe de flete
    vbeln         TYPE vbeln, "Factura SAP
    fkimg         TYPE fkimg, "cantidad facturada
    netwr         TYPE netwr, "Valor neto
    imsf          TYPE kzwi1, " importe total sin flete
    flete         TYPE kzwi6, " impoorte de fleteflete
    ver(2)        TYPE c, "Venta empresa relacionada ****** 24 enero 2020
    lab(2)        TYPE c, "Precio lab ingenio
    puli          TYPE kzwi1, "Precio unitario lab ingenio ****** 24 enero 2020
    ivli          TYPE kzwi1, "Importe venta lab ingenio ***** 24 enero 2020
    obser(20)     TYPE c, "observaciones
    line_color(4) TYPE c, "color renglon
  END OF ty_layout,
  BEGIN OF ty_socs,
    bukrs TYPE bukrs,
    party TYPE party,
    paval TYPE paval,
  END OF ty_socs.
* FIN ** 01/01/2020 ***CONSULTORGPMCZ*** Michael Chávez ** DESK940326

*************************** base codigo Mary **************************
* Tablas Internas
* Cabecera y Posición de las facturas
DATA:
  BEGIN OF vbr OCCURS 0,
    bukrs like vbrk-bukrs,
    vkorg LIKE vbrk-vkorg,          " Organización de Ventas
    spart LIKE vbrk-spart,          " Sector
    vtweg LIKE vbrk-vtweg,          " canal de distribución
    fkdat LIKE vbrk-fkdat,          " Fecha de Factura
    vbeln LIKE vbrk-vbeln,          " Factura SAP
    kunag LIKE vbrk-kunag,          " Solicitante
    netwr LIKE vbrk-netwr,          " Valor Neto
    waerk LIKE vbrk-waerk,          " Moneda
    knumv LIKE vbrk-knumv,          " Número de condición
    bzirk LIKE vbrk-bzirk,          " zona de ventas
    kurrf LIKE vbrk-kurrf,          " Tipo de cambio
    fktyp LIKE vbrk-fktyp,          " Tipo de factura
    vbtyp LIKE vbrk-vbtyp,          " Tipo de docto comercial
    fksto LIKE vbrk-fksto,          " ID factura anulada
    fkimg LIKE vbrp-fkimg,          " cantidad facturada
    vrkme LIKE vbrp-vrkme,          " Unidad de medida de venta
    matnr LIKE vbrp-matnr,          " material
    kzwi1 LIKE vbrp-kzwi1,          " precio Producto s/flete 24.01.20
    kzwi2 LIKE vbrp-kzwi2,          " precio producto total 24.01.20
    kzwi6 LIKE vbrp-kzwi6,          " precio de flete
  END OF vbr,

  BEGIN OF tab OCCURS 0,
    vkorg       LIKE vbrk-vkorg,          " Organización de Ventas
    rfc_emi(12),
    spart       LIKE vbrk-spart,          " Sector
    id(2),
    matnr       LIKE vbrp-matnr,          " material
    bismt       LIKE mara-bismt,          " id material sat
    fkdat       LIKE vbrk-fkdat,          " Fecha de Factura
*    kunnr   LIKE vbpa-kunnr,             " destinatario de mercancías.
    vbeln       LIKE vbrk-vbeln,          " Factura SAP
*    kunag   LIKE vbrk-kunag,             " Solicitante
    netwr       LIKE vbrk-netwr,          " Valor Neto
    waerk       LIKE vbrk-waerk,          " Moneda
    knumv       LIKE vbrk-knumv,          " Número de condición
*    bztxt   LIKE t171t-bztxt,            " Desc Zona Ventas
    maktx       LIKE makt-maktx,          " Desc Material
    fkimg       LIKE vbrp-fkimg,          " cantidad facturada
    vrkme       LIKE vbrp-vrkme,          " Unidad de medida de venta
    kzwi1       LIKE vbrp-kzwi1,          " precio Producto sflete 24.01.20
    kzwi2       LIKE vbrp-kzwi2,          " precio total 24.01.20
    kzwi6       LIKE vbrp-kzwi6,          " precio de flete
*    name1   LIKE kna1-name1,             " Nombre Cliente
*    namewe  LIKE kna1-name1,             " Nombre Cliente
    stcd1       LIKE kna1-stcd1,          " RFC
    vtweg       LIKE vbrk-vtweg,          "
    kurrf       LIKE vbrk-kurrf,          " Tipo de cambio
    fktyp       LIKE vbrk-fktyp,          " Tipo de factura
    vbtyp       LIKE vbrk-vbtyp,          " Tipo de docto comercial
    fksto       LIKE vbrk-fksto,          " ID factura anulada
    folfis(36),                           " MGM 20190319
    fectim(10),
    obser(20),
    lab(2),
  END OF tab.

"almacenaje de Xml
DATA: it_xmlsat TYPE TABLE OF smum_xmltb,
        wa_xmlsat TYPE smum_xmltb,
        xml_file type ZAXNARE_EL034.

* Tabla interna de textos de cabecera   MGM 20190319
DATA: BEGIN OF t_textos OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA: END OF t_textos.
DATA: BEGIN OF t_textos2 OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA: END OF t_textos2.
DATA:
  bukrs_p(4),
  tdname     LIKE thead-tdname,
  docto(20),
  gjahr_p    LIKE vbrk-gjahr,
  fecha      LIKE vbrk-fkdat.
*************************** base codigo Mary **************************


* Inicio ** 01/01/2020 ***CONSULTORGPMCZ*** Michael Chávez ** DESK940326
*TABLAS INTERNAS
DATA:

  gt_socs   TYPE TABLE OF ty_socs,
  wa_socs   LIKE LINE OF gt_socs,

  gt_layout TYPE TABLE OF ty_layout,
  wa_layout LIKE LINE OF gt_layout.
* FIN ** 01/01/2020 ***CONSULTORGPMCZ*** Michael Chávez ** DESK940326

* Inicia Declaraciones ALV
* ALV
TYPE-POOLS: slis.

* cabecera.
DATA: wa_fieldcat TYPE slis_fieldcat_alv,
      wa_format   TYPE slis_layout_alv,
      wa_gs_line  TYPE slis_listheader,
      gt_header   TYPE slis_t_listheader,
      wa_header   TYPE slis_listheader,
      gt_line     LIKE wa_header-info,

* Catalogo.
      gt_fieldcat TYPE STANDARD TABLE OF slis_fieldcat_alv,
      gv_title    TYPE lvc_title,
      wa_variant  TYPE disvariant,
      gv_program  TYPE sy-repid,

* Color.
      gt_colts    TYPE lvc_s_scol,
      gt_coltc    TYPE lvc_t_scol,
      gv_table    TYPE ddobjname,
      gv_conta    TYPE tabfdpos,
      gv_field    TYPE fieldname,
      gv_col      TYPE c.
*ALV
*******ALV
* Termina Declaraciones ALV


*****     PARAMETROS DE SELECCIÓN
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
    vkorg_p FOR vbrk-vkorg,      " Organización de ventas
    spart_p FOR vbrk-spart,      " Sector
    fkdat_p FOR vbrk-fkdat.      " Fecha de factura
*PARAMETERS:
*  fkdat_d LIKE vbrk-fkdat.     " Día a relacionar
SELECTION-SCREEN END OF BLOCK block1.
