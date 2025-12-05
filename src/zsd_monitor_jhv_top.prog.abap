*&---------------------------------------------------------------------*
*&  Include           ZSD_MONITOR_TOP
*&---------------------------------------------------------------------*
TABLES: vbrk, vbrp, icon.
TYPE-POOLS: icon.
* Parametros de Selección
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_bukrs FOR vbrk-bukrs OBLIGATORY NO-EXTENSION NO INTERVALS,  " Sociedad
                  s_vkbur FOR vbrp-vkbur NO INTERVALS NO-EXTENSION NO-DISPLAY,  " Oficina de Venta
                  s_kunnr FOR vbrk-kunag,                                       " Cliente
                  s_vbeln FOR vbrk-vbeln,                                       " Factura
                  s_fkdat FOR vbrk-fkdat.                                       " Fecha

  SELECTION-SCREEN SKIP.

  PARAMETERS: p_path LIKE rlgrap-filename DEFAULT 'C:\temp\'.

SELECTION-SCREEN END OF BLOCK b1.




SELECTION-SCREEN BEGIN OF BLOCK b2.
  PARAMETERS : p_rad1 RADIOBUTTON GROUP rb1,
               p_rad2 RADIOBUTTON GROUP rb1,
               p_rad3 RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK b2.

* Estructura para cliente
TYPES: BEGIN OF ty_kna1,
         kunnr TYPE kunnr,
         name1 TYPE name1_gp,
         name2 TYPE name2_gp,
       END OF ty_kna1.
* Estructura de información de Factura
TYPES: BEGIN OF ty_vbrk,
         vbeln          TYPE vbeln_vf,
         belnr          TYPE belnr_d,
         augbl          TYPE augbl,
         fkdat          TYPE fkdat,
         vkorg          TYPE vkorg,
         bukrs          TYPE t001-bukrs,
         kunag          TYPE vbrk-kunag,
         netwr          TYPE vbrk-netwr,
         mwsbk          TYPE vbrk-mwsbk,
         zterm          TYPE vbrk-zterm,
         zlsch          TYPE vbrk-zlsch,
         fksto          TYPE vbrk-fksto,
         matnr          TYPE vbrp-matnr,
         posnr          TYPE vbrp-posnr,
         uuid_compl(36) TYPE c,
         bschl          TYPE bschl,
       END OF ty_vbrk.

TYPES: BEGIN OF ty_vbrp,
         vbeln TYPE vbeln_vf,
         vkbur TYPE vbrp-vkbur,
       END OF ty_vbrp.

TYPES: BEGIN OF ty_bseg,
         belnr TYPE bseg-belnr,
         dmbtr TYPE bseg-dmbtr,
       END OF ty_bseg.
* Estructura para envio por correo
TYPES: BEGIN OF ty_envio,
         vbeln     TYPE vbeln_vf,
         kunag     TYPE kunag,
         status_e  TYPE boolean,
         status_f  TYPE boolean,
         log_email TYPE c LENGTH 200,
         log_ftp   TYPE c LENGTH 200,
       END OF ty_envio.
* Estructura basica de salida.
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

* Declaración de Tablas
DATA: gt_data     TYPE STANDARD TABLE OF zsd_cfdi_timbre,
      gt_data_alv TYPE STANDARD TABLE OF ty_data_alv,
      gt_kna1     TYPE STANDARD TABLE OF ty_kna1,
      gt_vbrk     TYPE STANDARD TABLE OF ty_vbrk,
      gt_vbrp     TYPE STANDARD TABLE OF ty_vbrp,
      gt_bseg     TYPE STANDARD TABLE OF ty_bseg,
      gt_envio    TYPE STANDARD TABLE OF ty_envio,
      o_alv       TYPE REF TO            cl_salv_table.

DATA: BEGIN OF i_log_desc OCCURS 0,
        msg1 TYPE string,
        msg2 TYPE string.
DATA: END OF i_log_desc.


DATA: i_response         TYPE TABLE OF text WITH HEADER LINE,
      i_response_headers TYPE TABLE OF text WITH HEADER LINE,
      v_url              TYPE string.

DATA: i_output_cons_canc TYPE zmt_s4_consultay_cancelacion_1-mt_s4_consultay_cancelacion_re OCCURS 0 WITH HEADER LINE,
      i_out_cons_canc    TYPE zmt_s4_consultay_cancelacion_1,
      i_zpac_datos_logon TYPE zpac_datos_logon OCCURS 0 WITH HEADER LINE.

DATA: gt_outtab_canc   TYPE zmot_canc OCCURS 0,
      gs_private_canc  TYPE slis_data_caller_exit,
      gs_selfield_canc TYPE slis_selfield,
      gt_fieldcat_canc TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      g_exit_canc(1)   TYPE c.

DATA: v_motivo    TYPE  char2,
      v_uuid_sust TYPE char36.
DATA: lo_msg_id_protocol       TYPE REF TO if_wsprotocol_message_id,
      l_msg_id                 TYPE sxmsguid,
*Estructuras de proxy...
*        L_PROXY_SERV       TYPE REF TO ZCO_SI_OA_DATOS_OUT,
      l_proxy_serv_canc_cons   TYPE REF TO zco_si_os_s4_consultay_cancela,
*** Datos para timbrar
      zmt_s4_cfditimbrado_req  TYPE zmt_s4_consultay_cancelacion_1,
      zmt_s4_cfditimbrado_resp TYPE zmt_s4_consultay_cancelacion_r. "ZMT_S4_CFDITIMBRADO_RESP.

DATA:
  lr_ai_system_fault     TYPE REF TO cx_ai_system_fault,
  l_errortext            TYPE string,
  l_errorcode            TYPE string,
* Definiciones para acknowlegment
  ls_status              TYPE prx_ack_status,
  lr_ack                 TYPE REF TO if_ws_acknowledgment,
  ls_req_detail          TYPE prx_ack_request_details,
  lr_async_messaging     TYPE REF TO if_wsprotocol_async_messaging,
  l_cnt                  TYPE i,
* Definiciones para la determinacion del ID
  lr_message_id_protocol TYPE REF TO if_wsprotocol_message_id,
  l_message_id           TYPE sxmsmguid.

DATA: v_result           TYPE string,
      v_code             TYPE string,
      v_message          TYPE string,
      v_uuid             TYPE string,
      v_fechatimbrado    TYPE string,
      v_nocertificadosat TYPE string,
      v_rfcprovcertif    TYPE string,
      v_sellocfd         TYPE string,
      v_sellosat         TYPE string,
      v_urlxml           TYPE string,
      v_urlpdf           TYPE string,
      v_urlqr            TYPE string,
      v_archivo          TYPE string,
      v_estatus          TYPE string.

DATA: i_zsd_cfdi_timbre       TYPE zsd_cfdi_timbre OCCURS 0 WITH HEADER LINE.

DATA: it_xml_err        TYPE string OCCURS 0 WITH HEADER LINE.
CONSTANTS: c_ack_enabled TYPE c VALUE 'X'.

DATA: v_respondera TYPE string,
      v_asunto     TYPE string,
      v_mensaje    TYPE string,
      v_para       TYPE string,
      v_cc         TYPE string,
      v_bcc        TYPE string,
      v_archadj    TYPE string.

DATA: ls_vbrk LIKE LINE OF gt_vbrk,
      ls_vbrp LIKE LINE OF gt_vbrp,
      ls_bseg LIKE LINE OF gt_bseg.

DATA: v_txt1 TYPE string,
      v_txt2 TYPE string.
DATA: gd_path TYPE string.

*DATA: V_URL TYPE C LENGTH 300.
FIELD-SYMBOLS: <ls_data>      LIKE LINE OF gt_data,
               <ls_data_desc> LIKE LINE OF gt_data,
               <ls_data_alv>  LIKE LINE OF gt_data_alv,
               <ls_data_alv2>  LIKE LINE OF gt_data_alv,
               <ls_kna1>      LIKE LINE OF gt_kna1,
               <ls_envio>     LIKE LINE OF gt_envio.
