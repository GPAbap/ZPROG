************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZCOMPLEMENTO_PAGOS_CFDI_33                    *
* Titulo              :  Generación de XML con complemento de pagos    *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VII.2017                                       *
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZCOMP_PAGOS_CFDI_33_TOP
*&---------------------------------------------------------------------*
TABLES: BKPF, BSEG, BSID, BSAD, VBRK, ICON.
TYPE-POOLS: ICON.

*** Parametros de Selección
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: S_BUKRS FOR VBRK-BUKRS NO-EXTENSION NO INTERVALS OBLIGATORY,        " Sociedad
                  S_BUDAT FOR BSID-BUDAT NO-EXTENSION OBLIGATORY,                     " Fecha del documento
                  S_KUNNR FOR BSID-KUNNR,                                             " Cliente
                  S_BELNR FOR BKPF-BELNR.                                             " Documento

  SELECTION-SCREEN SKIP 1.

  PARAMETERS : P_RAD1 RADIOBUTTON GROUP RB1,
               P_RAD2 RADIOBUTTON GROUP RB1 DEFAULT 'X'.

  SELECTION-SCREEN SKIP.

 PARAMETERS: P_PATH LIKE RLGRAP-FILENAME DEFAULT 'C:\temp\' NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK B1.



DATA: V_OK                TYPE OK_CODE,
      V_UCOMM             TYPE SY-UCOMM,
      LS_COL              TYPE I,
      LS_COL_ID           TYPE  LVC_S_COL,
      LS_ROW_ID           TYPE LVC_S_ROW,
      LS_VALUE            TYPE C,
      LS_ROW              TYPE I,
      T_FUN               TYPE UI_FUNCTIONS,
      FS_FUN              TYPE UI_FUNC,
      T_INDEX             TYPE INT4,
      T_SIZE              TYPE INT4,
      STRUCT_GRID_LSET    TYPE LVC_S_LAYO,
      V_REGIMEN           TYPE STRING,
      LR_RTTI_STRUC       TYPE REF TO CL_ABAP_STRUCTDESCR,
      ZOG                 LIKE LINE OF LR_RTTI_STRUC->COMPONENTS,
      ZOGT                LIKE TABLE OF ZOG,
      WA_IT_FLDCAT        TYPE LVC_S_FCAT,
      IT_FLDCAT           TYPE LVC_T_FCAT,
      IT_SORT             TYPE LVC_T_SORT,
      FS_SORT             TYPE LVC_S_SORT,
      FS_LAYOUT           TYPE LVC_S_LAYO,
      DY_LINE             TYPE REF TO DATA,
      DY_TABLE            TYPE REF TO DATA,
      DREF                TYPE REF TO DATA,
      V_EXIT              TYPE C,
      V_NUM_PARCIALIDAD   TYPE I,
      V_NUM_PARCIALIDAD_S TYPE STRING,
      V_IMP_SALD_ANT      TYPE P DECIMALS 2,
      V_IMP_PAGADO_LOCAL  TYPE P DECIMALS 2,
      V_IMP_PAGADO_DOC    TYPE P DECIMALS 2,
      V_IMP_SALD_INS      TYPE P DECIMALS 2,
      V_EJERCICIO         TYPE C LENGTH 4,
      V_EJERCICIOM1       TYPE C LENGTH 4,
      V_EJERCICIOP1       TYPE C LENGTH 4,
      V_FECHA_PAGO        TYPE DATUM,
      V_FECHA_FACT        TYPE DATUM,
      V_RFC_SOC           TYPE STRING,
      V_NOMBRE_SOC        TYPE STRING,
      V_NAME1SOC          TYPE AD_NAME1,
      V_NAME2SOC          TYPE AD_NAME1,
      V_ADRNR_SOC         TYPE STRING,
      V_LUGAR_EXP         TYPE STRING,
      V_MONTO_PAGO_DOC    TYPE P DECIMALS 2,
      V_MONTO_PAGO_LOCAL  TYPE P DECIMALS 2,
      V_MONTO_PAGO_DOC2   TYPE P DECIMALS 2,
      V_MONTO_PAGO_LOCAL2 TYPE P DECIMALS 2,
      V_MONTO_FACT_DOC    TYPE P DECIMALS 2,
      V_MONTO_FACT_LOCAL  TYPE P DECIMALS 2,
      V_FECHA_PAGO_12     TYPE STRING,
      V_FECHA_CREACION    TYPE STRING,
      V_WT_QBSHB          LIKE WITH_ITEM-WT_QBSHB,
      V_PAGO_SUST         TYPE BELNR_D,
      V_PARC_SUST         TYPE STRING,
      V_NULL              TYPE STRING,
      V_ID                LIKE  THEAD-TDID,
      V_NAME              LIKE  THEAD-TDNAME,
      V_OBJECT            LIKE  THEAD-TDOBJECT,
      V_SPRAS             LIKE SY-LANGU,
      V_TIPOCAMBIO        TYPE P DECIMALS 6, "xamai 29 08 2020 tipo de cambio
      V_TIPOCAMBIOS(9),
      STR1(2)             VALUE '0',
      V_FACTURA_PREV      TYPE VBELN,
      V_TIPODECAMBIO      TYPE P DECIMALS 10,
      V_TIPODECAMBIO_S    TYPE STRING.


DATA: V_JS_AD_PAC TYPE STRING.


FIELD-SYMBOLS: <FS>        TYPE ANY,
               <DYN_TABLE> TYPE  STANDARD TABLE,
               <DYN_WA>.
DATA GRID1 TYPE REF TO CL_GUI_ALV_GRID.
DATA GRID_CONTAINER1 TYPE REF TO CL_GUI_CUSTOM_CONTAINER .

DATA : gr_table TYPE REF TO cl_salv_table.
DATA : gr_functions TYPE REF TO cl_salv_functions_list.
DATA : gr_columns TYPE REF TO cl_salv_columns_table,

gr_column TYPE REF TO cl_salv_column_table,

lt_column_ref TYPE salv_t_column_ref,

ls_column_ref TYPE salv_s_column_ref.


*** Declaracion de variables adicionales


*** Para el complemento de pagos
DATA: I_LINEITEMS          TYPE BAPI3007_2 OCCURS 0 WITH HEADER LINE,
      I_LINEITEMS_COMP     TYPE BAPI3007_2 OCCURS 0 WITH HEADER LINE,
      I_RETURN             TYPE BAPIRETURN OCCURS 0 WITH HEADER LINE,
      I_FECHAS             TYPE RSDSSELOPT OCCURS 0 WITH HEADER LINE,
      I_CUSTOMER           TYPE RSDSSELOPT OCCURS 0 WITH HEADER LINE,
      I_ZALV_COMP_PAGO     TYPE ZALV_COMP_PAGO OCCURS 0 WITH HEADER LINE,
      I_ZALV_COMP_PAGO_REF TYPE ZALV_COMP_PAGO OCCURS 0 WITH HEADER LINE,
      I_BSAD               TYPE BSAD OCCURS 0 WITH HEADER LINE,
      I_BKPF               TYPE BKPF OCCURS 0 WITH HEADER LINE,
      I_BKPF_FI            TYPE BKPF OCCURS 0 WITH HEADER LINE,
      I_KNA1               TYPE KNA1 OCCURS 0 WITH HEADER LINE,
      I_ADR6               TYPE ADR6 OCCURS 0 WITH HEADER LINE,
      I_ADRC_MAIL          TYPE ADRC OCCURS 0 WITH HEADER LINE,
      I_BSEG               TYPE BSEG OCCURS 0 WITH HEADER LINE,
      I_VBRK               TYPE VBRK OCCURS 0 WITH HEADER LINE,
      I_T_MWDAT            TYPE RTAX1U15 OCCURS 0 WITH HEADER LINE,
      I_ZSDT_FAEHE_RELAC   TYPE ZSD_CFDI_TIMBRE OCCURS 0 WITH HEADER LINE,
      I_BSAD_EXTRA         TYPE BSAD OCCURS 0 WITH HEADER LINE,
      I_BSID_BSAD_PARC     TYPE BSID OCCURS 0 WITH HEADER LINE,
      I_BKPF_ANULADAS      TYPE BKPF OCCURS 0 WITH HEADER LINE,
      I_LINES              TYPE TLINE   OCCURS 0 WITH HEADER LINE,
      V_PARC_CI            TYPE I.

DATA: I_BUKRS LIKE  BKPF-BUKRS,
      I_MWSKZ LIKE  BSEG-MWSKZ,
      I_WRBTR LIKE  BSEG-WRBTR.

DATA: BEGIN OF I_DOCUMENTOS OCCURS 0,
        TIPO     TYPE C LENGTH 5,
        FACTURA  TYPE VBELN,
        DOC_PAGO TYPE BELNR_D,
        DOC_COMP TYPE BELNR_D,
        DOC_CLR  TYPE BELNR_D,
        KUNNR    TYPE KUNNR.
DATA: END OF I_DOCUMENTOS.

DATA: V_FLAG_CI TYPE C.

DATA: BEGIN OF I_BSAD_INDIC OCCURS 0,
        MWSKZ LIKE BSAD-MWSKZ,
        SGTXT LIKE BSAD-SGTXT.
DATA: END OF I_BSAD_INDIC.

TYPES: BEGIN OF S_DATA_ALV,
         LLAVE          TYPE BELNR_D,             " Llave
         CHECK          TYPE C LENGTH 1,          " Checkbox
         ANULADA        TYPE ICONNAME,            " Indicador
         BUKRS          TYPE T001-BUKRS,          " Sociedad
         KUNNR          TYPE KUNNR,               " Cliente
         NAME1          TYPE NAME1,               " Nombre del cliente
         DOC_PAGO       TYPE BELNR_D,             " Documento de pago
         XML            TYPE ICONNAME,            " XML
         PDF            TYPE ICONNAME,            " PDF
         IND_PP         TYPE C,                   " Indicador de pago parcial
         IND_PC         TYPE C,                   " Indicador de pago completo
         FACTURA        TYPE VBELN,               " Factura
*         PAGO_LOCAL     TYPE C LENGTH 16,         " Importe de pago en moneda local
         PAGO_DOC       TYPE C LENGTH 16,         " Importe de pago en moneda del documento
         CURRENCY       TYPE C LENGTH 3,          " Moneda de pago
         PARCIALIDAD    TYPE C LENGTH 5,          " Parcialidad
          TC_PAGO        TYPE C LENGTH 16,         " Tipo de cambio del pago
         BUDAT          TYPE C LENGTH 10,         " Fecha de pago
*         IMP_FACT_LOCAL TYPE C LENGTH 16,         " Importe de la factura en moneda local
         IMP_FACT_DOC   TYPE C LENGTH 16,         " Importe de la factura en moneda del documento
         CURREN_DR      TYPE C LENGTH 3,          " Moneda de la factura
         TC_DR          TYPE C LENGTH 16,         " Tipo de cambio de la factura
         FKDAT          TYPE C LENGTH 10,         " Fecha de la factura
         DOC_COMP       TYPE BELNR_D,             " Documento de compensacion
         COMENTARIO     TYPE C LENGTH 50,         " Comentario
         UUID           TYPE C LENGTH 36,         " UUID del pago
         STAT_CANC      TYPE C,
*         UUID_DR        TYPE C LENGTH 36,         " UUID de la factura
*         STATUS         TYPE C LENGTH 50,
*         PDF_CANC       TYPE ICONNAME,
         BASEIVA16      TYPE C LENGTH 16,         " BASE IVA 16%
         IVATRAS16      TYPE C LENGTH 16,         "IVA TRASLADO 16%
         BASEIVA0       TYPE C LENGTH 16,         " BASE DE IVA 0%
         SALDOPAGAR     TYPE C LENGTH 16,         " SALDO POR PAGAR
         SALDOANT       TYPE C LENGTH 16,         " SALDO ANTERIOR
         FOLFIS         TYPE C LENGTH 36,         " FOLIO FISCAL
         FORMPAGO       TYPE C LENGTH 40,         " FORMA DE PAGO
         MONTOTOTPAGO   TYPE C LENGTH 16.         " MONTO TOTAL DEL PAGO

TYPES: END OF  S_DATA_ALV.

* Declaración de Tablas
DATA: GT_DATA           TYPE ZALV_COMP_PAGO OCCURS 0 WITH HEADER LINE,
      GT_DATA_SHOW      TYPE ZALV_COMP_PAGO OCCURS 0 WITH HEADER LINE,
      GT_DATA_ALV       TYPE STANDARD TABLE OF S_DATA_ALV,
      WA_DATA_ALV       TYPE S_DATA_ALV     OCCURS 0 WITH HEADER LINE,
      I_DATA_ALV        TYPE S_DATA_ALV     OCCURS 0 WITH HEADER LINE,
      DATA_ALV          TYPE STANDARD TABLE OF S_DATA_ALV,
      I_DATA_ALV_GLOBAL TYPE S_DATA_ALV OCCURS 0 WITH HEADER LINE.

DATA: I_BSAD_NC LIKE BSAD OCCURS 0 WITH HEADER LINE.

DATA:
*      I_ZALV_COMP_PAGO   TYPE ZALV_COMP_PAGO OCCURS 0 WITH HEADER LINE,
      V_IMPORTES_FORMATO TYPE STRING.

DATA: I_EXCH_RATE   TYPE BAPI1093_0,
      I_RETURN_EXCH TYPE BAPIRET1.

DATA: V_TC   LIKE TCURR-UKURS,
      V_TC_S TYPE STRING.

DATA: V_URL TYPE C LENGTH 300.

DATA: V_ZUONR_CI TYPE BSAD-ZUONR.

DATA: BEGIN OF I_BSID_BSAD_PAGOS OCCURS 0,
        AUGBL TYPE AUGBL,
        REBZG TYPE REBZG,
        WRBTR TYPE WRBTR,
        DMBTR TYPE DMBTR.
DATA: END OF I_BSID_BSAD_PAGOS.

*** Tablas para almacenar la informacion de pagos
DATA: BEGIN OF I_PAGO10_PAGO OCCURS 0,
        DOC_PAGO        TYPE STRING,
        FECHAPAGO       TYPE STRING,
        FORMADEPAGOP    TYPE STRING,
        MONEDAP         TYPE STRING,
        TIPOCAMBIOP     TYPE STRING,
        MONTO           TYPE STRING,
        NUMOPERACION    TYPE STRING,
        RFCEMISORCTAORD TYPE STRING,
        NOMBANCOORDEXT  TYPE STRING,
        CTAORDENANTE    TYPE STRING,
        RFCEMISORCTABEN TYPE STRING,
        CTABENEFICIARIO TYPE STRING,
        TIPOCADPAGO     TYPE STRING,
        CERTPAGO        TYPE STRING,
        CADPAGO         TYPE STRING,
        SELLOPAGO       TYPE STRING.
DATA: END OF I_PAGO10_PAGO.

DATA: BEGIN OF I_PAGO10_DOCTORELACIONADO OCCURS 0,
        DOC_PAGO         TYPE STRING,
        FACTURA          TYPE STRING,
        IDDOCUMENTO      TYPE STRING,
        SERIE            TYPE STRING,
        FOLIO            TYPE STRING,
        MONEDADR         TYPE STRING,
        TIPOCAMBIODR     TYPE STRING,
        METODODEPAGODR   TYPE STRING,
        NUMPARCIALIDAD   TYPE STRING,
        IMPSALDOANT      TYPE STRING,
        IMPPAGADO        TYPE STRING,
        IMPSALDOINSOLUTO TYPE STRING,
        PARC_O_TOTAL     TYPE STRING.
DATA: END OF I_PAGO10_DOCTORELACIONADO.

DATA: BEGIN OF I_PAGO10_IMPUESTOS OCCURS 0,
        DOC_PAGO                  TYPE STRING,
        TOTALIMPUESTOSRETENIDOS   TYPE STRING,
        TOTALIMPUESTOSTRASLADADOS TYPE STRING.
DATA: END OF I_PAGO10_IMPUESTOS.

DATA: BEGIN OF I_PAGO10_RETENCION OCCURS 0,
        DOC_PAGO TYPE STRING,
        IMPUESTO TYPE STRING,
        IMPORTE  TYPE STRING.
DATA: END OF I_PAGO10_RETENCION.

DATA: BEGIN OF I_PAGO10_TRASLADO OCCURS 0,
        DOC_PAGO   TYPE STRING,
        IMPUESTO   TYPE STRING,
        TIPOFACTOR TYPE STRING,
        TASAOCUOTA TYPE STRING,
        IMPORTE    TYPE STRING.
DATA: END OF I_PAGO10_TRASLADO.


*** Nodo de cabecera

DATA: BEGIN OF I_COMPROBANTE OCCURS 0,
        DOC_PAGO                  TYPE STRING,
        VERSION                   TYPE STRING VALUE '3.3',
        SERIE                     TYPE STRING,
        FOLIO                     TYPE STRING,
        FECHA                     TYPE STRING,
        SELLO                     TYPE STRING,
        NOCERTIFICADO             TYPE STRING,
        CERTIFICADO               TYPE STRING,
        SUBTOTAL                  TYPE STRING VALUE '0',
        MONEDA                    TYPE STRING,
        TOTAL                     TYPE STRING VALUE '0',
        TIPODECOMPROBANTE         TYPE STRING VALUE 'P',
        LUGAREXPEDICION           TYPE STRING,
        CONFIRMACION 	            TYPE STRING,
        RFC_EMISOR                TYPE STRING,
        NOMBRE_EMISOR             TYPE STRING,
        REGIMENFISCAL_EMISOR      TYPE STRING,
        RFC_RECEPTOR              TYPE STRING,
        KUNNR                     TYPE STRING,
        NOMBRE_RECEPTOR           TYPE STRING,
        RESIDENCIAFISCAL_RECEPTOR TYPE STRING,
        NUMREGIDTRIB_RECEPTOR     TYPE STRING,
        USOCFDI                   TYPE STRING,
        CLAVEPRODSERV             TYPE STRING,
        CANTIDAD                  TYPE STRING VALUE '1',
        CLAVEUNIDAD               TYPE STRING VALUE 'ACT',
        DESCRIPCION               TYPE STRING VALUE 'Pago',
        VALORUNITARIO             TYPE STRING VALUE '0',
        IMPORTE                   TYPE STRING VALUE '0'.
DATA: END OF I_COMPROBANTE.

DATA: BEGIN OF I_CFDIRELACIONADOS OCCURS 0,
        TIPORELACION TYPE STRING VALUE '04'.
DATA: END OF I_CFDIRELACIONADOS.

DATA: BEGIN OF I_CFDIRELACIONADO OCCURS 0,
        UUID TYPE STRING.
DATA: END OF I_CFDIRELACIONADO.

DATA: V_NAME2                   TYPE RLGRAP-FILENAME,
      C_CADENA(200)             TYPE C,
      C_CADENA_SELLO(500)       TYPE C,
      C_CADENA2(100)            TYPE C,
      C_FILENAME(128)           TYPE C,
      C_CAOR2                   TYPE STRING,
      C_STR(300)                TYPE C,
      C_CAOR                    TYPE STRING,
      R_SSF_PARAMETERS_ID       TYPE IDMX_DI_PROFILE,
      R_RELEASE                 LIKE CVERS-RELEASE,
      R_PRN_SIGN                TYPE STRING,
      LV_CHECKED_SERIAL_NR(255) TYPE C,
      LS_CERTIFICADO            TYPE IDMX_DI_PROFDET,
      V_CONT_CERT               TYPE STRING,
      SERVER_PATH               TYPE SAPB-SAPPFAD,
      TARGET_PATH               TYPE SAPB-SAPPFAD.


*&---------------------------------------------------------------------*
*&  Definición de tablas internas
*&---------------------------------------------------------------------*
DATA: IT_XML      TYPE STRING         OCCURS 0 WITH HEADER LINE,
      IT_XML_ERR  TYPE STRING OCCURS 0 WITH HEADER LINE,
      IT_XML_COMP TYPE STRING         OCCURS 0 WITH HEADER LINE,
      IT_XML_PS   TYPE STRING OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF I_LOG OCCURS 0,
        MSG1 TYPE STRING,
        MSG2 TYPE STRING.
DATA: END OF I_LOG.


DATA: V_FLAG_CANC TYPE C.

DATA: V_NODO             TYPE STRING,
      I_ZPAC_DATOS_LOGON TYPE ZPAC_DATOS_LOGON OCCURS 0 WITH HEADER LINE,
      I_OUTPUT           TYPE ZMT_S4_CFDITIMBRADO_REQ-MT_S4_CFDITIMBRADO_REQ,
      I_OUTPUT_BIS       TYPE ZMT_S4_CFDITIMBRADO_REQ OCCURS 0 WITH HEADER LINE,
      I_OUT              TYPE ZMT_S4_CFDITIMBRADO_REQ.
CONSTANTS: C_VERSION TYPE STRING VALUE '4.0'.
DATA: V_SERIE_CFDI TYPE STRING,
      V_STR_TMP    TYPE STRING.
DATA: Z_CONCEPTOS TYPE ZDT_S4_CFDITIMBRADO_REQ_CONCEP OCCURS 0 WITH HEADER LINE,
      ZREQ_CONCEP TYPE ZDT_S4_CFDITIMBRADO_REQ_CONCE1 OCCURS 0 WITH HEADER LINE.

FIELD-SYMBOLS: <TABLA> TYPE ANY.
FIELD-SYMBOLS: <TABLA2> TYPE ANY.



DATA: LO_MSG_ID_PROTOCOL         TYPE REF TO IF_WSPROTOCOL_MESSAGE_ID,
      L_MSG_ID                   TYPE SXMSGUID,
*Estructuras de proxy...
*        L_PROXY_SERV       TYPE REF TO ZCO_SI_OA_DATOS_OUT,
      L_PROXY_SERV_FACT          TYPE REF TO ZCO_SI_OS_S4_CFDITIMBRADO,
      L_PROXY_SERV_CANC_CONS     TYPE REF TO ZCO_SI_OS_S4_CONSULTAY_CANCELA,
*** Datos para timbrar
      ZMT_S4_CFDITIMBRADO_REQ    TYPE ZMT_S4_CFDITIMBRADO_REQ,
      ZMT_S4_CFDITIMBRADO_RESP   TYPE ZMT_S4_CFDITIMBRADO_RESP,
      ZMT_S4_CFDITIMBRADO_REQ_C  TYPE ZMT_S4_CONSULTAY_CANCELACION_1,
      ZMT_S4_CFDITIMBRADO_RESP_C TYPE ZMT_S4_CONSULTAY_CANCELACION_R.

DATA:
  LR_AI_SYSTEM_FAULT     TYPE REF TO CX_AI_SYSTEM_FAULT,
  L_ERRORTEXT            TYPE STRING,
  L_ERRORCODE            TYPE STRING,
* Definiciones para acknowlegment
  LS_STATUS              TYPE PRX_ACK_STATUS,
  LR_ACK                 TYPE REF TO IF_WS_ACKNOWLEDGMENT,
  LS_REQ_DETAIL          TYPE PRX_ACK_REQUEST_DETAILS,
  LR_ASYNC_MESSAGING     TYPE REF TO IF_WSPROTOCOL_ASYNC_MESSAGING,
  L_CNT                  TYPE I,
* Definiciones para la determinacion del ID
  LR_MESSAGE_ID_PROTOCOL TYPE REF TO IF_WSPROTOCOL_MESSAGE_ID,
  L_MESSAGE_ID           TYPE SXMSMGUID.

CONSTANTS:
C_ACK_ENABLED TYPE C VALUE 'X'.

DATA: V_MOTIVO    TYPE  CHAR2,
      V_UUID_SUST TYPE CHAR36.

DATA: I_OUTPUT_CONS_CANC TYPE ZMT_S4_CONSULTAY_CANCELACION_1-MT_S4_CONSULTAY_CANCELACION_RE OCCURS 0 WITH HEADER LINE,
      I_OUT_CONS_CANC    TYPE ZMT_S4_CONSULTAY_CANCELACION_1.

DATA: V_RESPONDERA TYPE STRING,
      V_ASUNTO     TYPE STRING,
      V_MENSAJE    TYPE STRING,
      V_PARA       TYPE STRING,
      V_CC         TYPE STRING,
      V_BCC        TYPE STRING,
      V_ARCHADJ    TYPE STRING.

DATA: V_RESULT           TYPE STRING,
      V_CODE             TYPE STRING,
      V_MESSAGE          TYPE STRING,
      V_UUID             TYPE STRING,
      V_FECHATIMBRADO    TYPE STRING,
      V_NOCERTIFICADOSAT TYPE STRING,
      V_RFCPROVCERTIF    TYPE STRING,
      V_SELLOCFD         TYPE STRING,
      V_SELLOSAT         TYPE STRING,
      V_URLXML           TYPE STRING,
      V_URLPDF           TYPE STRING,
      V_URLQR            TYPE STRING,
      V_ARCHIVO          TYPE STRING,
      V_ESTATUS          TYPE STRING.

DATA: BEGIN OF I_LOG_DESC OCCURS 0,
        MSG1 TYPE STRING,
        MSG2 TYPE STRING.
DATA: END OF I_LOG_DESC.




*** Variables para Version 2.0
DATA:V_TOTRETIVA             TYPE NETWR,
     V_TOTRETIVA_TOT         TYPE NETWR,
     V_TOTRETISR             TYPE NETWR,
     V_TOTRETIEPS            TYPE NETWR,
     V_TRASLBASE16           TYPE NETWR,
     V_TRASLIMP16            TYPE NETWR,
     V_TRASLBASE16_TOT       TYPE NETWR,
     V_TRASLIMP16_TOT        TYPE NETWR,
     V_TRASLBASE8            TYPE NETWR,
     V_TRASLIVA8             TYPE NETWR,
     V_TRASLBASE0            TYPE NETWR,
     V_TRASLIVA0             TYPE NETWR,
     V_TRASLBASE0_TOT        TYPE NETWR,
     V_TRASLIVA0_TOT         TYPE NETWR,
     V_TRASLEX               TYPE NETWR,
     V_MONTOTOTPAG           TYPE NETWR,
     V_RFCEMISORCTAORD       TYPE STRING,
     V_NOMBANCOORDEXT        TYPE STRING,
     V_CTAORDENANTE          TYPE STRING,
     V_RFCEMISORCTABEN       TYPE STRING,
     V_CTABENEFICIARIO       TYPE STRING,
     V_TIPOCADPAGO           TYPE STRING,
     V_CERTPAGO              TYPE STRING,
     V_CADPAGO               TYPE STRING,
     V_SELLOPAGO             TYPE STRING,
     V_TAG_TC_EQUIV          TYPE STRING,
     V_OBJETOIMPDR           TYPE STRING,
     V_KNUMV_IMP             TYPE KNUMV,
     I_PRCD_ELEMENTS_IMP     TYPE PRCD_ELEMENTS OCCURS 0 WITH HEADER LINE,
     I_PRCD_ELEMENTS_IMP_BIS TYPE PRCD_ELEMENTS OCCURS 0 WITH HEADER LINE,
     I_Z33_IMPUESTOS         TYPE Z33_IMPUESTOS OCCURS 0 WITH HEADER LINE,
     V_TRASLBASE16_CI        TYPE NETWR,
     V_TRASLIMP16_CI         TYPE NETWR.


DATA: V_MWSK1         LIKE PRCD_ELEMENTS-MWSK1,
      V_MWSK1_POS     LIKE PRCD_ELEMENTS-MWSK1,
      V_RETEN_DOC     TYPE NETWR,
      I_PRCD_ELEMENTS LIKE PRCD_ELEMENTS OCCURS 0 WITH HEADER LINE.

DATA: V_TASAOCUOTADR   TYPE P DECIMALS 6,
      V_TASAOCUOTADR_S TYPE STRING,
      V_BASEDR         TYPE P DECIMALS 2,
      V_BASEDR_S       TYPE STRING,
      V_IMPUESTODR     TYPE P DECIMALS 2,
      V_IMPUESTODR_S   TYPE STRING,
      V_IMPORTEDR      TYPE P DECIMALS 2,
      V_IMPORTEDR_S    TYPE STRING,
      V_RET_POS        TYPE P DECIMALS 2.

DATA: BEGIN OF I_IMPUESTOS_DR OCCURS 0,
        V_TIPO         TYPE STRING,
        V_BASEDR       TYPE STRING,
        V_IMPUESTODR   TYPE STRING,
        V_TIPOFACTORDR TYPE STRING,
        V_TASAOCUOTADR TYPE STRING,
        V_IMPORTEDR    TYPE STRING.
DATA: END OF I_IMPUESTOS_DR.


DATA: BEGIN OF I_IMPUESTOS_DR_COL OCCURS 0,
        V_TIPO         TYPE STRING,
        V_BASEDR       TYPE NETWR,
        V_IMPUESTODR   TYPE NETWR,
        V_TIPOFACTORDR TYPE STRING,
        V_TASAOCUOTADR TYPE STRING,
        V_IMPORTEDR    TYPE NETWR.
DATA: END OF I_IMPUESTOS_DR_COL.

*&---------------------------------------------------------------------*
*& Variables Globales
*&---------------------------------------------------------------------*
DATA: obj_gos        TYPE REF TO cl_gos_document_service.
DATA: wa_borident TYPE                borident.
DATA: wa_objkey   TYPE                borident-objkey.

DATA: it_xmlsat TYPE TABLE OF smum_xmltb,
      wa_xmlsat TYPE smum_xmltb,
      xml_file type ZAXNARE_EL034.
