*&---------------------------------------------------------------------*
*& Include ZMON_ALTA_PAGOS_COM_2
*&
*& Generador de reporte (PDF) para pagos BBVA.
*&
*&---------------------------------------------------------------------*


"$. Region FORM Configuración de la tabla
FORM F_GENERAR_TABLA_DE_PAGOS .

  CLEAR:   WA_FLDCAT, IT_FLDCAT.
  REFRESH: IT_FLDCAT.

  """ Columnas de la tabla de resultados
  """ Campo: Sociedad (BUKRS)
  LW_FIELDCAT-FIELDNAME = 'SOCIEDAD'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Sociedad'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Dia de Ejecución (LAUFD)
  LW_FIELDCAT-FIELDNAME = 'FECHA_EJECUCION'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Dia de Ejecución'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Identificador (LAUFI)
  LW_FIELDCAT-FIELDNAME = 'ID_ADICIONAL'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Identificador'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Proveedor (LIFNR)
  LW_FIELDCAT-FIELDNAME = 'NUM_PROVEEDOR'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Proveedor'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Referencia SIT (ZREF_SIT)
  LW_FIELDCAT-FIELDNAME = 'REFERENCIA_SIT'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Ref. SIT'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Referencia Numérica (ZREF_NUM)
  LW_FIELDCAT-FIELDNAME = 'REFERENCIA_NUM'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Ref. Núm.'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Nombre del Receptor del Pago (DZNME1)
  LW_FIELDCAT-FIELDNAME = 'RECEPTOR_PAGO'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Receptor del Pago'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Numero del Receptor del Pago (ZBNKN)
  LW_FIELDCAT-FIELDNAME = 'NUM_RECEPTOR'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Número de Receptor del Pago'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.

  """ Campo: Importe pagado en Moneda Local (RBETR)
  LW_FIELDCAT-FIELDNAME = 'IMPORTE_ML'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Importe pagado en M.L.'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ FALTA CLAVE_MONEDA

  """ Campo: Nuestro número de cuenta (UBKNT)
  LW_FIELDCAT-FIELDNAME = 'NUM_BANCO'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Nuestro núm. de cta.'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Código de Respuesta H (ZSTATUS_BBVA_H)
  LW_FIELDCAT-FIELDNAME = 'COD_RES_H'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Cód. Res. (H)'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Comentario H (ZCOMENTARIO)
  LW_FIELDCAT-FIELDNAME = 'COMENTARIO_H'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Comentario (H)'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Código de Respuesta D (ZSTATUS_BBVA_D)
  LW_FIELDCAT-FIELDNAME = 'COD_RES_D'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Cód. Res. (D)'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Campo: Comentario D (ZCOMENTARIO)
  LW_FIELDCAT-FIELDNAME = 'COMENTARIO_D'. "" Nombre del campo (Debe ser el mismo al nombre de la columna de la tabla)
  LW_FIELDCAT-OUTPUTLEN = 10.
  LW_FIELDCAT-SELTEXT_L = 'Comentario D'. "" Titulo de la nueva columna del campo
  APPEND LW_FIELDCAT TO LT_FIELDCAT.  "" Añadir a las columnas a desplegar
  CLEAR LW_FIELDCAT.                  "" Reiniciar la variable para reutilizar en otro campo

  """ Columna para seleccionar una fila (Seleccionar todo)
  LW_LAYOUT-ZEBRA = 'X'.
  LW_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  LW_LAYOUT-BOX_FIELDNAME     = 'SELECCION'. "" Establecer variable 'SELECCION' en esta columna para seleccionar fila y usar esos datos

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

ENDFORM.
"$. Endregion FORM Configuración de la tabla

"$. Region FORM: Status GUI
FORM PF USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTATUS'.
ENDFORM.
"$. Endregion FORM: Status GUI

"$. Region Comandos de Usuario en GUI
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.

  CASE R_UCOMM.
    WHEN '&IC1'.

      DATA: LV_NUMREG TYPE I.

      CLEAR: FM_NAME, L_XSTRING, LS_JOB_INFO, V_BIN_FILESIZE,
      LT_DATA, LV_URL, IT_DET, WA_CAB, WA_DET.
      REFRESH: IT_CAB, IT_DET, IT_OPERACIONES.

      LOOP AT IT_PREFINAL INTO WA_PREFINAL WHERE SELECCION = 'X'.

        WA_OPERACIONES-NREG =  1.
        WA_OPERACIONES-ITOTAL = WA_PREFINAL-IMPORTE_ML.

        WA_OPERACIONES-IA = WA_PREFINAL-IMPORTE_ML.
        WA_OPERACIONES-OPA = 1.

        COLLECT WA_OPERACIONES INTO IT_OPERACIONES.
        CLEAR: WA_OPERACIONES.
      ENDLOOP.

      CLEAR: FM_NAME, L_XSTRING, LS_JOB_INFO, V_BIN_FILESIZE,
         LT_DATA, LV_URL, IT_DET, WA_CAB, WA_DET, WA_PREFINAL, WA_OPERACIONES.
      REFRESH: IT_CAB, IT_DET.

      LOOP AT IT_PREFINAL INTO WA_PREFINAL WHERE SELECCION = 'X'.
        IF IT_CAB IS INITIAL.

          READ TABLE IT_OPERACIONES INTO WA_OPERACIONES INDEX 1.

          """ Datos de ENCABEZADO
          IF SY-SUBRC = 0.
            WA_CAB-CUENTA  = WA_PREFINAL-NUM_BANCO.
            WA_CAB-FECHAOP = WA_PREFINAL-FECHA_EJECUCION.
            """ STATUS está fijado a "Operado"
            """ Falta incluir folio lote en los datos recibidos
            WA_CAB-IMPORTETOTAL = WA_OPERACIONES-ITOTAL.
            WA_CAB-NUMREG = WA_OPERACIONES-NREG.
            WA_CAB-OPACEPTADAS = WA_OPERACIONES-OPA.
            WA_CAB-OPRECHADAZADAS = WA_OPERACIONES-OPR.
            WA_CAB-IMPORTEACEPTADO = WA_OPERACIONES-IA.
            WA_CAB-IMPORTERECHAZADO = WA_OPERACIONES-IR.


          ENDIF.

          APPEND WA_CAB TO IT_CAB.
        ENDIF.

        """ Tabla de datos
        SHIFT WA_PREFINAL-NUM_RECEPTOR LEFT DELETING LEADING '0'.
        WA_DET-ABONO = WA_PREFINAL-NUM_RECEPTOR.
        WA_DET-TCUENTA = WA_PREFINAL-ID_ADICIONAL.
*        WA_DET-BANCO = ''.
        WA_DET-IMPORTE = WA_PREFINAL-IMPORTE_ML.
        WA_DET-NOMBRE = WA_PREFINAL-RECEPTOR_PAGO.
        WA_DET-CODIGO = WA_PREFINAL-COD_RES_H.
        WA_DET-DESCCOD = WA_PREFINAL-COMENTARIO_D.
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
