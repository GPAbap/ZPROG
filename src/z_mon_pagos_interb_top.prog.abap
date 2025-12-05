************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZMONITOR_ALTA_PAGOS_BBVA_H2H                  *
* Titulo              :  Inclue de declaraciones                       *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VIII.2020                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZMON_ALTA_PAGOS_TOP
*&---------------------------------------------------------------------*

TABLES: REGUH.

DATA: I_ZH2H_BBVA_ST_PAG LIKE ZH2H_BBVA_ST_PAG   OCCURS 0 WITH HEADER LINE.

DATA: OB_GRID               TYPE REF TO CL_GUI_ALV_GRID,    "#EC NEEDED
      IT_FLDCAT             TYPE LVC_T_FCAT,
      WA_FLDCAT             TYPE LVC_S_FCAT,
      IS_LAYOUT_LVC         TYPE  LVC_S_LAYO OCCURS 0 WITH HEADER LINE,
      LS_SORT               TYPE LVC_S_SORT,
      LT_SORT               TYPE LVC_T_SORT,
      GD_REPID              LIKE SY-REPID,
      REF_GRID              TYPE REF TO CL_GUI_ALV_GRID,
      ZPOS                  TYPE I.

"$. Region Reporte (PDF) -------------------------------------------------------*
  TYPES:
      BEGIN OF TY_PREFINAL,   """ Tipo de Información mostrada por columna en la tabla
          SELECCION         TYPE C,               """ Columna de Selección
          MANDANTE          TYPE MANDT,           """ Mandante
          SOCIEDAD          TYPE BUKRS,           """ Sociedad
          FECHA_EJECUCION   TYPE LAUFD,           """ Fecha en la que debe ejecutarse el programa
          ID_ADICIONAL      TYPE LAUFI,           """ Característica de Identificación adicional
          NUM_PROVEEDOR     TYPE LIFNR,           """ Número de cuenta del proveedor o acreedor
          REFERENCIA_SIT    TYPE ZREF_SIT,        """ Referencia SIT
          REFERENCIA_NUM    TYPE ZREF_NUM,        """ Referencia numérica
          RECEPTOR_PAGO     TYPE DZNME1,          """ Nombre del Receptor del pago
          IMPORTE_ML        TYPE RBETR,           """ Importe en Moneda Local
          CLAVE_MONEDA      TYPE WAERS,           """ Clave de la moneda
          NUM_BANCO         TYPE UBKNT,           """ Nuestro número de cuenta del banco
          NUM_RECEPTOR      TYPE DZBNKN,           """ Número de cuenta bancaria del receptor del pago
          COD_RES_H         TYPE ZSTATUS_BBVA_H,  """ Código de Respuesta [00:Aceptado, 01:Aceptado Parcial, 03:Rechazado]
          COMENTARIO_H      TYPE ZCOMENTARIO,     """ Comentario de Respuesta H
          COD_RES_D         TYPE ZSTATUS_BBVA_D,  """ Código de Respuesta [00:Aceptado, 01:Aceptado Parcial, 03:Rechazado]
          COMENTARIO_D      TYPE ZCOMENTARIO,     """ Comentario de Respuesta H
        END OF TY_PREFINAL,

        BEGIN OF TY_OPERACIONES, """ PDF
           NREG   TYPE I,
           OPA    TYPE I,
           OPR    TYPE I,
           ITOTAL TYPE DMBTR,
           IA     TYPE DMBTR,
           IR     TYPE DMBTR,
        END OF TY_OPERACIONES.

  DATA:
        IT_PREFINAL  TYPE TABLE OF TY_PREFINAL, """ Tabla de Datos
        WA_PREFINAL  LIKE LINE OF IT_PREFINAL,  """ Fila de la Tabla de Datos
        LT_FIELDCAT TYPE  SLIS_T_FIELDCAT_ALV,  """ Tabla (Campos)
        LW_FIELDCAT TYPE SLIS_FIELDCAT_ALV,     """ Columna de la tabla
        LW_LAYOUT   TYPE  SLIS_LAYOUT_ALV.      """ Columna única de la tabla (Columna de selección)

  DATA:  """ PDF
        FM_NAME TYPE RS38L_FNAM,
        L_XSTRING        TYPE XSTRING,
        LS_JOB_INFO      TYPE SSFCRESCL,
        V_BIN_FILESIZE   TYPE I,
        LT_DATA          TYPE STANDARD TABLE OF X255,
        LV_URL           TYPE CHAR255,
        IT_CAB TYPE TABLE OF ZST_PAGOSBBVA,
        WA_CAB LIKE LINE OF IT_CAB,
        IT_DET TYPE TABLE OF ZST_PAGOSBBVAD,
        WA_DET LIKE LINE OF IT_DET,
        IT_OPERACIONES    TYPE TABLE OF TY_OPERACIONES,
        WA_OPERACIONES LIKE LINE OF IT_OPERACIONES,
        V_E_DEVTYPE      TYPE RSPOPTYPE,
        OUTPUT_OPTIONS   TYPE SSFCOMPOP,
        CONTROL          TYPE SSFCTRLOP,
        C_SMART TYPE RS38L_FNAM VALUE 'ZSF_PAGOSFORMATOTEST_2',
        LV_SOCIEDAD TYPE CHAR50,
        G_HTML_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        G_HTML_CONTROL   TYPE REF TO CL_GUI_HTML_VIEWER,
        USER_SETTINGS    TYPE TDBOOL.
"$. Endregion Reporte (PDF) ----------------------------------------------------*
