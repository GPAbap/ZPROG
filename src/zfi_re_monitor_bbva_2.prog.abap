************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZMONITOR_ALTA_NOM_BBVA_H2H                    *
* Titulo              :  Monitor status nomina enviada a BBVA          *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VIII.2020                                      *
************************************************************************
*&---------------------------------------------------------------------*
*& Report  ZMONITOR_ALTA_NOM_BBVA_H2H
*&---------------------------------------------------------------------*
REPORT  ZMONITOR_ALTA_NOM_BBVA_H2H.

*** Include de selecciones
INCLUDE ZMON_ALTA_NOMINA_TOP.

*** Include de selecciones
INCLUDE ZMON_ALTA_NOMINA_SEL.

*** Include de procesamiento
INCLUDE ZMON_ALTA_NOMINA_F01.


"$. Region DATA
DATA: IT_CAB TYPE TABLE OF ZST_PAGOSBBVA,
      WA_CAB LIKE LINE OF IT_CAB,
      IT_DET TYPE TABLE OF ZST_PAGOSBBVAD,
      WA_DET LIKE LINE OF IT_DET.

DATA: FM_NAME TYPE RS38L_FNAM,
      C_SMART TYPE RS38L_FNAM VALUE 'ZSF_PAGOSFORMATOTEST'.

********************** SMARTFORMS ********************************
DATA: LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      GS_KEY      TYPE SLIS_KEYINFO_ALV,
      GT_EVENTS   TYPE SLIS_T_EVENT,
      LW_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      LW_LAYOUT   TYPE  SLIS_LAYOUT_ALV,
      LT_EVENTS   TYPE SLIS_T_EVENT,
      I_EVENT     TYPE SLIS_T_EVENT.


DATA : IT_SORT1 TYPE SLIS_SORTINFO_ALV OCCURS 1,
       WA_SORT1 LIKE LINE OF IT_SORT1.


DATA: LV_CUENTA  TYPE UBKNT,
      LV_IMPORTE TYPE STRING.

*********************************** COLLECT OPERACIONES
TYPES: BEGIN OF TY_OPERACIONES,
         NREG   TYPE I,
         OPA    TYPE I,
         OPR    TYPE I,
         ITOTAL TYPE DMBTR,
         IA     TYPE DMBTR,
         IR     TYPE DMBTR,
       END OF TY_OPERACIONES,

      BEGIN OF TY_PREFINAL,
          SEL         TYPE C,
          MANDANTE    TYPE MANDT,
          SOCIEDAD    TYPE BUKRS,
          REGISTRO    TYPE ZREGISTRO,
          REGISTRO_OK TYPE ZREGOK,
          IMPORTE_OK  TYPE ZIMPOK,
          REGISTRO_ER TYPE ZREGERR,
          IMPORTE_ER  TYPE ZIMPERR,
          FECHA_OPER  TYPE ZFECHOPER,
          FECHA_PAGO  TYPE ZFECHAPAGO,
          REFERENCIA  TYPE ZREFERENCIA,
          RFC_CURP    TYPE ZRFCCURP,
          TIPO_CUENTA TYPE ZTIPOCTA,
          BANCO_DEST  TYPE ZBCODEST,
          CUENTA_ABON TYPE ZCTABONO,
          IMPORTE_LOC TYPE RBETR,
          RECEP_PAGO  TYPE DZNME1,
          STATUS_PAGO TYPE ZSTATUS_BBVA_D,
          COMENTARIO  TYPE ZCOMENTARIO,
        END OF TY_PREFINAL,

        BEGIN OF TY_PREFINALC,
          SOCIEDAD   TYPE BUKRS,
          REGISTRO    TYPE ZREGISTRO,
          RFC_CURP    TYPE ZRFCCURP,
          TIPOSERV   TYPE CHAR20,
          TIPOPAGO   TYPE CHAR20,
          FECHAOP    TYPE DATUM,
          IMPORTE    TYPE DMBTR,
          IMPORTEA   TYPE DMBTR,
          IMPORTEC   TYPE DMBTR,
        END OF TY_PREFINALC.

DATA: IT_PREFINAL  TYPE TABLE OF TY_PREFINAL,
      WA_PREFINAL  LIKE LINE OF IT_PREFINAL,

      IT_PREFINALC TYPE TABLE OF TY_PREFINALC,
      WA_PREFINALC LIKE LINE OF IT_PREFINALC.

DATA: IT_OPERACIONES    TYPE TABLE OF TY_OPERACIONES,
      CONTROL          TYPE SSFCTRLOP,
      OUTPUT_OPTIONS   TYPE SSFCOMPOP,
      USER_SETTINGS    TYPE TDBOOL,
      V_E_DEVTYPE      TYPE RSPOPTYPE,
      LS_JOB_INFO      TYPE SSFCRESCL,
      V_BIN_FILESIZE   TYPE I,
      L_XSTRING        TYPE XSTRING,
      LT_DATA          TYPE STANDARD TABLE OF X255,
      WA_DATA          TYPE X255,
      LV_URL           TYPE CHAR255,
      G_HTML_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      G_HTML_CONTROL   TYPE REF TO CL_GUI_HTML_VIEWER.

DATA: LV_ADR      TYPE ADRNR,
      LV_NAME1    TYPE CHAR40,
      LV_NAME2    TYPE CHAR40,
      LV_SOCIEDAD TYPE CHAR50.

DATA : P_FILE_N TYPE LOCALFILE,
       P_FILE_E TYPE LOCALFILE.

DATA: BEGIN OF IT_TAB OCCURS 0,
        REC(1000) TYPE C,
      END OF IT_TAB.
DATA: WA_TAB(1000) TYPE C.

""" Contador para pruebas controladas
DATA: C TYPE I.

DATA: BEGIN OF IT_FILEDIR OCCURS 10.
        INCLUDE STRUCTURE SALFLDIR.
DATA: END OF IT_FILEDIR.

DATA: P_FDIR TYPE PFEFLNAMEL.
DATA: LV_DAT TYPE DATUM.
DATA: LV_FECHA TYPE CHAR6.

DATA : LV_DIR   TYPE EPS2FILNAM,
       LV_DIR_E TYPE EPS2FILNAM.

DATA: IT_FILES TYPE TABLE OF EPS2FILI,
      WA_FILES LIKE LINE OF IT_FILES.

TYPES: BEGIN OF TY_ARCHIVOS,
         NAME TYPE EPS2FILNAM,
       END OF TY_ARCHIVOS.

DATA: IT_ARCHIVOS TYPE TABLE OF TY_ARCHIVOS,
      WA_ARCHIVOS LIKE LINE OF IT_ARCHIVOS.

DATA: WA_OPERACIONES LIKE LINE OF IT_OPERACIONES.
"$. Endregion DATA

""" Inicio del procesamiento
START-OF-SELECTION.

""" Extrae datos para el ALV
PERFORM F_EXTRAE_DATOS.

""" Si se obtuvieron datos...
IF NOT I_ZH2H_BBVA_ST_nom[] IS INITIAL.
  """ Guardar datos para tabla y PDF
  LOOP AT I_ZH2H_BBVA_ST_NOM.
    CLEAR WA_PREFINAL.

    WA_PREFINAL-SOCIEDAD = I_ZH2H_BBVA_ST_NOM-BUKRS.
    WA_PREFINAL-IMPORTE_OK = I_ZH2H_BBVA_ST_NOM-ZIMPOK.
    WA_PREFINAL-REGISTRO = I_ZH2H_BBVA_ST_NOM-LLAVE.
    WA_PREFINAL-REGISTRO_OK = I_ZH2H_BBVA_ST_NOM-ZREGOK.
    WA_PREFINAL-IMPORTE_OK = I_ZH2H_BBVA_ST_NOM-ZIMPOK.
    WA_PREFINAL-REGISTRO_ER = I_ZH2H_BBVA_ST_NOM-ZREGERR.
    WA_PREFINAL-IMPORTE_ER = I_ZH2H_BBVA_ST_NOM-ZIMPERR.
    WA_PREFINAL-FECHA_OPER = I_ZH2H_BBVA_ST_NOM-ZFECHOPER.
    WA_PREFINAL-FECHA_PAGO = I_ZH2H_BBVA_ST_NOM-ZFECHAPAGO.
    WA_PREFINAL-FECHA_PAGO = I_ZH2H_BBVA_ST_NOM-ZFECHAPAGO.
    WA_PREFINAL-REFERENCIA = I_ZH2H_BBVA_ST_NOM-ZREFERENCIA.
    WA_PREFINAL-RFC_CURP = I_ZH2H_BBVA_ST_NOM-ZRFCCURP.
    WA_PREFINAL-TIPO_CUENTA = I_ZH2H_BBVA_ST_NOM-ZTIPOCTA.
    WA_PREFINAL-BANCO_DEST = I_ZH2H_BBVA_ST_NOM-ZBCODEST.
    WA_PREFINAL-CUENTA_ABON = I_ZH2H_BBVA_ST_NOM-ZCTABONO.
    WA_PREFINAL-IMPORTE_LOC = I_ZH2H_BBVA_ST_NOM-RBETR.
    WA_PREFINAL-RECEP_PAGO = I_ZH2H_BBVA_ST_NOM-ZNME1.
    WA_PREFINAL-STATUS_PAGO = I_ZH2H_BBVA_ST_NOM-STATUS_D.
    WA_PREFINAL-COMENTARIO = I_ZH2H_BBVA_ST_NOM-COMENTARIO_D.

    APPEND WA_PREFINAL TO IT_PREFINAL.
    ENDLOOP.

  """ Generar tabla
  PERFORM F_ARMA_CATALOGO_2.

""" Si no hay datos, mostrar mensaje de error
ELSE.
  MESSAGE E001(00) WITH 'No existen datos para los' 'criterios de selección'.
ENDIF.

END-OF-SELECTION.

""" -----------------------------------------------------------------------------------------------
"$. Region FORM: Armar Catalogo de datos
FORM F_ARMA_CATALOGO_2 .
  DATA:
        LT_FIELDCAT TYPE  SLIS_T_FIELDCAT_ALV, """ Columna de la tabla
        LW_LAYOUT   TYPE  SLIS_LAYOUT_ALV.     """ Configuración de columna única de la tabla

  CLEAR:   WA_FLDCAT, IT_FLDCAT.
  REFRESH: IT_FLDCAT.

  """ Columnas de la tabla de resultados
  """ Campo: Sociedad (BUKRS)
  LW_FIELDCAT-FIELDNAME = 'SOCIEDAD'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Sociedad'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Registro (ZREGISTRO)
  LW_FIELDCAT-FIELDNAME = 'REGISTRO_OK'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Registro OK'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Error de Registro (ZREGERR)
  LW_FIELDCAT-FIELDNAME = 'REGISTRO_ER'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Registro Error'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Error de Importe (ZIMPERR)
  LW_FIELDCAT-FIELDNAME = 'IMPORTE_ER'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Importe Error'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Fecha de Operación (ZFECHOPER)
  LW_FIELDCAT-FIELDNAME = 'FECHA_OPER'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Fecha de Operación'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Fecha de Pago (ZFECHAPAGO)
  LW_FIELDCAT-FIELDNAME = 'FECHA_PAGO'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Fecha de Pago'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Referencia (ZREFERENCIA)
  LW_FIELDCAT-FIELDNAME = 'REFERENCIA'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Referencia'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: RFC o CURP (ZRFCCURP)
  LW_FIELDCAT-FIELDNAME = 'RFC_CURP'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'RFC/CURP'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Tipo de Cuenta (ZTIPOCTA)
  LW_FIELDCAT-FIELDNAME = 'TIPO_CUENTA'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Tipo de Cuenta'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.

  """ Campo: Banco Destino (ZBCODEST)
  LW_FIELDCAT-FIELDNAME = 'BANCO_DEST'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Banco Destino'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.

  """ Campo: Cuenta de Abono (ZCTABONO)
  LW_FIELDCAT-FIELDNAME = 'CUENTA_ABON'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Cuenta de Abono'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.

  """ Campo: Importe pagado en Moneda Local (RBETR)
  LW_FIELDCAT-FIELDNAME = 'IMPORTE_LOC'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Importe pagado en Moneda Local'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.

  """ Campo: Receptor del Pago (DZNME1)
  LW_FIELDCAT-FIELDNAME = 'RECEP_PAGO'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Nombre del Receptor del pago'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.

  """ Campo: Status del pago (ZSTATUS_BBVA_D)
  LW_FIELDCAT-FIELDNAME = 'STATUS_PAGO'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Código de Respuesta (D)'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.

  """ Campo: Comentario (ZCOMENTARIO)
  LW_FIELDCAT-FIELDNAME = 'COMENTARIO'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Comentario'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.

  """ Columna para seleccionar una fila (Seleccionar todo)
  LW_LAYOUT-ZEBRA = 'X'.
  LW_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  LW_LAYOUT-BOX_FIELDNAME     = 'SEL'. "" Establecer variable 'SEL' en esta columna para seleccionar fila y usar esos datos

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    I_CALLBACK_PROGRAM       = SY-REPID
    I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
    I_CALLBACK_PF_STATUS_SET = 'PF'           " PF-STATUS (botones)
    IS_LAYOUT                = LW_LAYOUT
    IT_FIELDCAT              = LT_FIELDCAT
  TABLES
    T_OUTTAB                 = IT_PREFINAL
  EXCEPTIONS
    PROGRAM_ERROR            = 1
    OTHERS                   = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " F_ARMA_CATALOGO
"$. Endregion FORM: Armar Catalogo de datos
""" -----------------------------------------------------------------------------------------------
"$. Region FORM: Status GUI
FORM PF USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTATUS'.
ENDFORM.
"$. Endregion FORM: Status GUI
""" -----------------------------------------------------------------------------------------------
"$. Region Comandos de Usuario en GUI
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.

  CASE R_UCOMM.
    WHEN '&IC1'.

      DATA: LV_NUMREG TYPE I.

      CLEAR: FM_NAME, L_XSTRING, LS_JOB_INFO, V_BIN_FILESIZE,
      LT_DATA, LV_URL, IT_DET, WA_CAB, WA_DET.
      REFRESH: IT_CAB, IT_DET, IT_OPERACIONES.

      LOOP AT IT_PREFINAL INTO WA_PREFINAL WHERE SEL = 'X'.

        WA_OPERACIONES-NREG =  1.
        WA_OPERACIONES-ITOTAL = WA_PREFINAL-IMPORTE_LOC.

        IF WA_PREFINAL-IMPORTE_LOC > 0.
          WA_OPERACIONES-IA = WA_PREFINAL-IMPORTE_LOC.
          WA_OPERACIONES-OPA = 1.
        ELSE.
          WA_OPERACIONES-IR = WA_PREFINAL-IMPORTE_ER.
          WA_OPERACIONES-OPR = 1.
        ENDIF.

        COLLECT WA_OPERACIONES INTO IT_OPERACIONES.
        CLEAR: WA_OPERACIONES.
      ENDLOOP.
*********************************** COLLECT OPERACIONES
      CLEAR: FM_NAME, L_XSTRING, LS_JOB_INFO, V_BIN_FILESIZE,
         LT_DATA, LV_URL, IT_DET, WA_CAB, WA_DET, WA_PREFINAL, WA_OPERACIONES.
      REFRESH: IT_CAB, IT_DET.

      LOOP AT IT_PREFINAL INTO WA_PREFINAL WHERE SEL = 'X'.

        IF IT_CAB IS INITIAL.
          "WA_CAB-NOCONTRATO = WA_PREFINAL-NOCONTRATO. """ Checar No. de Contrato
          WA_CAB-CUENTA  = WA_PREFINAL-MANDANTE.
          "WA_CAB-TIPOSERVICIO = WA_PREFINAL-TIPOSERV.
          WA_CAB-FECHAOP = WA_PREFINAL-FECHA_OPER.
          "WA_CAB-FOLIOLOTE = WA_PREFINAL-FOLIO.

          READ TABLE IT_OPERACIONES INTO WA_OPERACIONES INDEX 1.

          IF SY-SUBRC = 0.

            WA_CAB-IMPORTETOTAL = WA_OPERACIONES-ITOTAL.
            WA_CAB-NUMREG = WA_OPERACIONES-NREG.
            WA_CAB-OPACEPTADAS = WA_OPERACIONES-OPA.
            WA_CAB-OPRECHADAZADAS = WA_OPERACIONES-OPR.
            WA_CAB-IMPORTEACEPTADO = WA_OPERACIONES-IA.
            WA_CAB-IMPORTERECHAZADO = WA_OPERACIONES-IR.


          ENDIF.

          APPEND WA_CAB TO IT_CAB.
        ENDIF.



        "WA_DET-NOCONTRATO = WA_PREFINAL-NOCONTRATO.
        "WA_DET-CUENTA = WA_PREFINAL-CUENTA.
        "WA_DET-TCUENTA = WA_PREFINAL-TCUENTA.WA_DET-BANCO = WA_PREFINAL-BANCO.
        "WA_DET-IMPORTE = WA_PREFINAL-IMPORTE."""""""
        "WA_DET-NOMBRE = WA_PREFINAL-NOMBRE.
*         WA_DET-IMPORTE = '123.12'.
        "WA_DET-ABONO = WA_PREFINAL-ABONO.
        "WA_DET-CODIGO = WA_PREFINAL-CODIGO.
        "WA_DET-DESCCOD = WA_PREFINAL-DESCCOD.
        WA_DET-ABONO = WA_PREFINAL-CUENTA_ABON.
        WA_DET-TCUENTA = WA_PREFINAL-TIPO_CUENTA.
        WA_DET-BANCO = WA_PREFINAL-BANCO_DEST.
        WA_DET-IMPORTE = WA_PREFINAL-IMPORTE_LOC.
        WA_DET-NOMBRE = WA_PREFINAL-RECEP_PAGO.
        WA_DET-CODIGO = WA_PREFINAL-STATUS_PAGO.
        WA_DET-DESCRIPCION = WA_PREFINAL-COMENTARIO.
        WA_DET-DESCCOD = WA_PREFINAL-COMENTARIO.
        APPEND WA_DET TO IT_DET.
      ENDLOOP.

      CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
        EXPORTING
          I_LANGUAGE    = SY-LANGU
          I_APPLICATION = 'SAPDEFAULT'
        IMPORTING
          E_DEVTYPE     = V_E_DEVTYPE.

      OUTPUT_OPTIONS-TDPRINTER = V_E_DEVTYPE.
      OUTPUT_OPTIONS-TDCOPIES  = 1.
      OUTPUT_OPTIONS-TDARMOD   = 1.
      CONTROL-NO_DIALOG        = 'X'.
      CONTROL-GETOTF           = 'X'.


      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME           = C_SMART
        IMPORTING
          FM_NAME            = FM_NAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.

      IF SY-SUBRC <> 0.
        CLEAR: L_XSTRING.
      ELSE.



        CALL FUNCTION FM_NAME
          EXPORTING
            CONTROL_PARAMETERS = CONTROL
            OUTPUT_OPTIONS     = OUTPUT_OPTIONS
            USER_SETTINGS      = USER_SETTINGS
            GV_SOCIEDAD        = LV_SOCIEDAD
          IMPORTING
            JOB_OUTPUT_INFO    = LS_JOB_INFO
*           GV_SOCIEDAD        = LV_SOCIEDAD
          TABLES
            IT_CABECERA        = IT_CAB
            IT_DETALLE         = IT_DET
          EXCEPTIONS
            FORMATTING_ERROR   = 1
            INTERNAL_ERROR     = 2
            SEND_ERROR         = 3
            USER_CANCELED      = 4
            OTHERS             = 5.

        CLEAR: IT_CAB, IT_DET, LV_SOCIEDAD.

        IF SY-SUBRC <> 0.
          CLEAR: L_XSTRING.
        ELSE.
* convert to otf to PDF in xstring file
          DATA LT_LINES TYPE TABLE OF TLINE.

          CLEAR: LT_LINES[].

          CALL FUNCTION 'CONVERT_OTF'
            EXPORTING
              FORMAT                = 'PDF'
            IMPORTING
              BIN_FILESIZE          = V_BIN_FILESIZE
              BIN_FILE              = L_XSTRING
            TABLES
              OTF                   = LS_JOB_INFO-OTFDATA
              LINES                 = LT_LINES
            EXCEPTIONS
              ERR_MAX_LINEWIDTH     = 1
              ERR_FORMAT            = 2
              ERR_CONV_NOT_POSSIBLE = 3
              ERR_BAD_OTF           = 4
              OTHERS                = 5.

*      l_byte_out = l_xstring.

          IF SY-SUBRC <> 0.
            CLEAR: L_XSTRING.
          ENDIF.
        ENDIF.
      ENDIF.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          BUFFER     = L_XSTRING "xpdf
        TABLES
          BINARY_TAB = LT_DATA.

      FREE: G_HTML_CONTAINER, G_HTML_CONTROL.

      CREATE OBJECT G_HTML_CONTAINER
        EXPORTING
          CONTAINER_NAME = 'PDF'.

      CREATE OBJECT G_HTML_CONTROL
        EXPORTING
          PARENT = G_HTML_CONTAINER.

* Load the HTML
      CALL METHOD G_HTML_CONTROL->LOAD_DATA(
        EXPORTING
          TYPE                 = 'application'
          SUBTYPE              = 'pdf'
        IMPORTING
          ASSIGNED_URL         = LV_URL
        CHANGING
          DATA_TABLE           = LT_DATA
        EXCEPTIONS
          DP_INVALID_PARAMETER = 1
          DP_ERROR_GENERAL     = 2
          CNTL_ERROR           = 3
          OTHERS               = 4 ).

* Show it
      CALL METHOD G_HTML_CONTROL->SHOW_URL_IN_BROWSER( URL = LV_URL ).

  ENDCASE.
  RS_SELFIELD-REFRESH = 'X'.
ENDFORM.                    "USER_COMMAND
"$. Endregion Comandos de Usuario en GUI
