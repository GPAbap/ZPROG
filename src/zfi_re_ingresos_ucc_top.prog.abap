*&---------------------------------------------------------------------*
*&  Include           Z_REP_INGRESOS_TOP
*&---------------------------------------------------------------------*


TYPE-POOLS: slis.

TYPES: BEGIN OF tys_bseg_tot,
         bukrs   TYPE bukrs,
         belnr   TYPE belnr_d,
         gjahr   TYPE gjahr,
         koart   TYPE koart,
         total   TYPE p DECIMALS 2,
         iva     TYPE p DECIMALS 2,
         iva_ret TYPE p DECIMALS 2,
         hkont   TYPE hkont,
         band    TYPE c,
         bschl   TYPE bschl,
       END OF tys_bseg_tot.

DATA: gt_bseg_tot TYPE TABLE OF tys_bseg_tot,
      gs_bseg_tot TYPE tys_bseg_tot.

DATA: gt_bkpf TYPE STANDARD TABLE OF bkpf.

DATA: gtext(100)  TYPE c,
      gtext2(100) TYPE c,
      gtext3(100) TYPE c.


*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      lf_layout   TYPE slis_layout_alv,    "Manejar diseño de layout
      t_sort      TYPE slis_t_sortinfo_alv,
      gt_events     type slis_t_event.


DATA it_ingresos_union TYPE STANDARD TABLE OF zfi_st_ingresos.
DATA it_ingresos_rv TYPE STANDARD TABLE OF zfi_st_ingresos.
DATA it_ingresos TYPE STANDARD TABLE OF zfi_st_ingresos.
DATA it_inversiones TYPE STANDARD TABLE OF zfi_st_ingresos.

TYPES: BEGIN OF ty_data_alv,
         check           TYPE check,      " Para seleccionar
         anulada         TYPE iconname,   " Indicador
         bukrs           TYPE t001-bukrs, " Sociedad
         vkbur           TYPE vbrp-vkbur, " Oficina de ventas
         vbeln           TYPE vbeln_vf,   " Factura
         fkdat           TYPE fkdat,       " Fecha
         kunag           TYPE string,     " Cliente
         netwr           TYPE vbrk-netwr, " Monto Factura
         mwsbk           TYPE vbrk-mwsbk, " Impuesto
         uuid            TYPE string,     " uuid
*         FECHA_XML(50)   TYPE C,          " Fecha recuperada del XML
         pdf             TYPE iconname,   " PDF
         xml             TYPE iconname,   " XML
         comentario(600) TYPE c,          " Error
         fksto           TYPE fksto,
         motivo          TYPE char2,
         fec_canc        TYPE budat, "Fecha de Cancelación.
         pdf_canc        TYPE iconname,   " PDF cancelacion
******************CAMPOS ADICINALES 05/12/2023 JHV****************************************************
         tipo_comp(10)   TYPE c, "Tipo de Comprobante
         uso_cfdi        TYPE string, "USO CFDI
         fecha_timbre    TYPE zfechacobro, "FECHA TIMBRADO
         receptor_rfc    TYPE zrfc_gen, "RECEPTOR RFC
         receptor_nombre TYPE name1, "RECEPTOR NOMBRE
         concepto_bien   TYPE string,
         clave_sat       TYPE string,
         cuenta          TYPE saknr, "cuenta contable
         subtotal_xml    TYPE ztotaling, "SUBTOTAL XML
         base16          TYPE ztotaling, "IMPORTE BASE 16
         base8           TYPE ztotaling, "importe base8
         base0           TYPE ztotaling, "IMPORTE BASE 0
         exento          TYPE ztotaling, "exento
         descuento       TYPE ztotaling, "DESCUENTO
         iva_xml         TYPE ziva, "IVA XML
         total_xml       TYPE ztotal, "TOTAL XML
         tipo_cambio     TYPE ztipocambio, "TIPO DE CAMBIO
         moneda_xml      TYPE zmonedacobro, "MONEDA XML
         forma_pago(3)   TYPE c,
         metodo_pago     TYPE zmetcobro,
         doc_prov        TYPE belnr_d, "DOCUMENTO DE PROVISIÓN
         doc_ingreso     TYPE augbl, "DOCUMENTO DE INGRESO
         importe_pend    TYPE dmbtr, "IMPORTE PENDIENTE DE PAGO
         folio_compl(36) TYPE c, "folio de complemento, si Existe
**********************************************************************
*         XML_CANC        TYPE ICONNAME,   " XML cancelacion
*         stat_canc       type c,
*         status(600)     type c,
       END OF  ty_data_alv.

DATA: it_xmlsat TYPE TABLE OF smum_xmltb,
      wa_xmlsat TYPE smum_xmltb,
      xml_file  TYPE zaxnare_el034.





SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-020 .
  PARAMETERS s_bukrs TYPE bukrs OBLIGATORY.
  PARAMETERS  p_gjahr TYPE bkpf-gjahr OBLIGATORY.
  PARAMETERS:  S_monat TYPE monat OBLIGATORY.
*  s_CPUDT FOR bkpf-cpudt ,
  SELECT-OPTIONS: s_budat FOR bkpf-budat.
  SELECT-OPTIONS: s_belnr FOR bkpf-belnr.


  SELECTION-SCREEN SKIP .

  PARAMETERS: p_conta  RADIOBUTTON GROUP g1,
              p_conci  RADIOBUTTON GROUP g1,
              p_cocon  RADIOBUTTON GROUP g1,
              p_rIVA   RADIOBUTTON GROUP g1,
              p_rISR   RADIOBUTTON GROUP g1,
              p_RESING RADIOBUTTON GROUP g1.

SELECTION-SCREEN END OF BLOCK b2.
