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
*&  Include           ZCOMP_PAGOS_CFDI_33_BOTONES
*&---------------------------------------------------------------------*
DATA: G_HANDLER TYPE REF TO LCL_EVENT_HANDLER.



*&---------------------------------------------------------------------*
*& Form f_refresh
*&---------------------------------------------------------------------*
FORM F_REFRESH .

  LEAVE TO LIST-PROCESSING.

*  WAIT UP TO 3 SECONDS.
*  CLEAR: GRID_CONTAINER1.", GRID1.
  CLEAR: WA_DATA_ALV, ZOGT, IT_FLDCAT.
  REFRESH: WA_DATA_ALV, ZOGT, IT_FLDCAT..

*** Arma la estructura del ALV
  PERFORM F_CREATE_ALV_STRUCT.

  IF NOT WA_DATA_ALV[] IS INITIAL.

*    DATA : REF_GRID TYPE REF TO CL_GUI_ALV_GRID. "new

    CALL METHOD GRID1->CHECK_CHANGED_DATA.

    CALL METHOD GRID1->REFRESH_TABLE_DISPLAY.

    CALL METHOD GRID1->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IT_TOOLBAR_EXCLUDING = T_FUN
        IS_LAYOUT            = STRUCT_GRID_LSET
      CHANGING
        IT_OUTTAB            = <DYN_TABLE>
        IT_FIELDCATALOG      = IT_FLDCAT
        IT_SORT              = IT_SORT.

  ELSE.
    CLEAR: <DYN_TABLE>.
    REFRESH <DYN_TABLE>.
    CALL METHOD GRID1->CHECK_CHANGED_DATA.

    CALL METHOD GRID1->REFRESH_TABLE_DISPLAY.

    CALL METHOD GRID1->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IT_TOOLBAR_EXCLUDING = T_FUN
        IS_LAYOUT            = STRUCT_GRID_LSET
      CHANGING
        IT_OUTTAB            = <DYN_TABLE>
        IT_FIELDCATALOG      = IT_FLDCAT
        IT_SORT              = IT_SORT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_descarga
*&---------------------------------------------------------------------*
*FORM F_DESCARGA .
*
*  DESCRIBE TABLE <DYN_TABLE> LINES T_SIZE.
*  T_INDEX = 1.
*  WHILE T_INDEX LE T_SIZE.
*    CLEAR WA_DATA_ALV.
*    READ TABLE <DYN_TABLE> INDEX T_INDEX INTO WA_DATA_ALV.
*    IF WA_DATA_ALV-CHECK = 'X'.
*      READ TABLE GT_DATA WITH KEY DOC_PAGO = WA_DATA_ALV-DOC_PAGO
*                                  FACTURA  = WA_DATA_ALV-FACTURA
*                                  DOC_COMP = WA_DATA_ALV-DOC_COMP.
**** Descarga pdf
*      CLEAR V_URL.
*      V_URL = GT_DATA-ARCHIVOPDF.
*      PERFORM F_GETCDATA USING V_URL 'pdf'.
**** Descarga xml
*      CLEAR V_URL.
*      V_URL = GT_DATA-ARCHIVOXML.
*      PERFORM F_GETCDATA USING V_URL 'xml'.
*
*    ENDIF.
**    CLEAR WA_DATA_ALV-CHECK.
**    MODIFY <DYN_TABLE> FROM WA_DATA_ALV INDEX T_INDEX.
*    T_INDEX = T_INDEX + 1.
*  ENDWHILE.
*
*  PERFORM F_VENTANA_LOG_DESC.
**
**  CALL METHOD GRID1->REFRESH_TABLE_DISPLAY.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  instantiate_grid
*&---------------------------------------------------------------------*
FORM INSTANTIATE_GRID
   USING  GRID_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER
          CLASS_OBJECT  TYPE REF TO CL_GUI_ALV_GRID
          CONTAINER_NAME TYPE SCRFNAME.

  CREATE OBJECT GRID_CONTAINER
    EXPORTING
      CONTAINER_NAME = CONTAINER_NAME.

  CREATE OBJECT CLASS_OBJECT
    EXPORTING
      I_PARENT = GRID_CONTAINER.

  STRUCT_GRID_LSET-SEL_MODE = 'D'.
  CREATE OBJECT G_HANDLER.
  SET HANDLER G_HANDLER->HANDLE_TOOLBAR       FOR CLASS_OBJECT.
  SET HANDLER G_HANDLER->HANDLE_USER_COMMAND  FOR CLASS_OBJECT.
  SET HANDLER G_HANDLER->HANDLE_HOTSPOT_CLICK FOR CLASS_OBJECT.

  CALL METHOD CLASS_OBJECT->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  FS_SORT-SPOS = '1'.
  FS_SORT-FIELDNAME = 'DOC_PAGO'.
  FS_SORT-UP = 'X'.
  FS_SORT-GROUP = 'X'.
  APPEND FS_SORT TO IT_SORT.
  CLEAR FS_SORT.

  STRUCT_GRID_LSET-CWIDTH_OPT = 'X'.

  CALL METHOD CLASS_OBJECT->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IT_TOOLBAR_EXCLUDING = T_FUN
      IS_LAYOUT            = STRUCT_GRID_LSET
    CHANGING
      IT_OUTTAB            = <DYN_TABLE>
      IT_FIELDCATALOG      = IT_FLDCAT
      IT_SORT              = IT_SORT.


ENDFORM.                    "INSTANTIATE_GRID

*&---------------------------------------------------------------------*
*&      MODULE STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR GRID_CONTAINER1.

  IF GRID_CONTAINER1 IS INITIAL.
    PERFORM F_HIDE_TOOLBAR.

    PERFORM INSTANTIATE_GRID
       USING GRID_CONTAINER1
             GRID1
             'CCONTAINER1'.
  ENDIF.

 " SET PF-STATUS '001'.
  SET TITLEBAR  '000'.

ENDMODULE.                    "STATUS_0100 OUTPUT

*&---------------------------------------------------------------------*
*&      MODULE USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'RETURN'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                    "USER_COMMAND_0100 INPUT






*&---------------------------------------------------------------------*
*& Form f_solicitud_canc_cons
*&---------------------------------------------------------------------*
FORM F_SOLICITUD_CANC_CONS USING V_TIPO.
  V_FLAG_CANC = 'X'.

  CLEAR:   I_OUTPUT, I_OUTPUT_CONS_CANC.
  REFRESH: I_OUTPUT_CONS_CANC.

  IF V_TIPO = '0'.

    CALL FUNCTION 'ZCANCELACION_CFDI'
      EXPORTING
        TITULO = 'Motivo de cancelación CFDI'
      IMPORTING
        MOTIVO = V_MOTIVO
        UUID   = V_UUID_SUST.

  ENDIF.

  IF V_TIPO = '0' AND V_MOTIVO IS INITIAL.
    MESSAGE E001(00) WITH 'Es necesario indicar el motivo'.
    EXIT.
  ENDIF.

*** Valores de usuario y contraseña
  CLEAR:   I_OUTPUT_CONS_CANC, I_ZPAC_DATOS_LOGON.
  REFRESH: I_OUTPUT_CONS_CANC, I_ZPAC_DATOS_LOGON.

  SELECT *
    FROM ZPAC_DATOS_LOGON
    INTO TABLE I_ZPAC_DATOS_LOGON
    WHERE BUKRS = WA_DATA_ALV-BUKRS.

  READ TABLE I_ZPAC_DATOS_LOGON INDEX 1.
  MOVE I_ZPAC_DATOS_LOGON-USER_PAC        TO I_OUTPUT_CONS_CANC-USUARIO.
  MOVE I_ZPAC_DATOS_LOGON-PASSWORD_PAC    TO I_OUTPUT_CONS_CANC-CONTRASENA.

  DATA: V_UUID_UPPER TYPE CHAR36.
  CLEAR V_UUID_UPPER.
  V_UUID_UPPER = WA_DATA_ALV-UUID.
  TRANSLATE V_UUID_UPPER TO UPPER CASE.
  I_OUTPUT_CONS_CANC-UUID                 = V_UUID_UPPER.

  DATA: V_RFC_RECEPTOR TYPE STCD1.
  CLEAR V_RFC_RECEPTOR.

*  V_RFC_RECEPTOR = <LS_DATA_DESC>-STCD1.
  IF V_RFC_RECEPTOR IS INITIAL.
    SELECT SINGLE STCD1
      FROM KNA1
      INTO V_RFC_RECEPTOR
      WHERE KUNNR = WA_DATA_ALV-KUNNR.
    IF V_RFC_RECEPTOR IS INITIAL.
      SELECT SINGLE STCD3
        FROM KNA1
        INTO V_RFC_RECEPTOR
        WHERE KUNNR = WA_DATA_ALV-KUNNR.
    ENDIF.
  ENDIF.

  I_OUTPUT_CONS_CANC-RFC_RECEPTOR         = V_RFC_RECEPTOR.
  I_OUTPUT_CONS_CANC-MOTIVO               = V_MOTIVO.
  IF V_UUID_SUST = '00000000000000000000000000000000'.
    I_OUTPUT_CONS_CANC-UUID_SUSTITUCION     = ''.
  ELSE.
    I_OUTPUT_CONS_CANC-UUID_SUSTITUCION     = V_UUID_SUST.
  ENDIF.
  I_OUTPUT_CONS_CANC-UUID_SUSTITUCION     = V_UUID_SUST.
  "I_OUTPUT_CONS_CANC-TOTAL                = WA_DATA_ALV-PAGO_LOCAL.

*** Este campo va vacio por ser solicitud de cancleacion
  IF V_TIPO = '0'.
    MOVE SPACE TO I_OUTPUT_CONS_CANC-CONSULTA_OCANCELACION.
  ELSE.
    MOVE '1' TO I_OUTPUT_CONS_CANC-CONSULTA_OCANCELACION.
  ENDIF.


*******************************************************************************************
***                               Nodo para envio correo                                ***
*******************************************************************************************
  CLEAR: V_RESPONDERA, V_ASUNTO, V_MENSAJE, V_PARA, V_CC, V_BCC, V_ARCHADJ.


*** Definir a quien se enviara el correo informando que hubo una
*** solicitude de cancelacion
  IF SY-SYSID = 'SPD'.
    V_PARA = 'ddelvalle@scanda.com.mx'.
  ENDIF.

*** Asunto


*** Mensaje en formato HTML
  IF V_TIPO = '0'.
    V_ASUNTO = 'Solicitud de cancelación'.
    CONCATENATE V_MENSAJE '<body aria-readonly="false">Se solicitó al SAT la cancelacion de la factura:<br />' INTO V_MENSAJE.
  ELSEIF  V_TIPO = '1'.
    V_ASUNTO = 'Consulta de status'.
    CONCATENATE V_MENSAJE '<body aria-readonly="false">Se consultó el status de la factura:<br />' INTO V_MENSAJE.
  ENDIF.

  CONCATENATE V_MENSAJE '<br />' INTO V_MENSAJE.
*  CONCATENATE V_MENSAJE WA_DATA_ALV-BELNR INTO V_MENSAJE.

  CONCATENATE V_MENSAJE '</body>' INTO V_MENSAJE.

*** Opcionales

  IF V_PARA IS NOT INITIAL.
  ENDIF.

  DATA: ZCORREO TYPE ZDT_S4_CONSULTAY_CANCELACION_2 OCCURS 0 WITH HEADER LINE.
*
  MOVE V_RESPONDERA TO ZCORREO-RESPONDER_A.
  MOVE V_ASUNTO     TO ZCORREO-ASUNTO.
  MOVE V_MENSAJE    TO ZCORREO-MENSAJE.
  MOVE V_PARA       TO ZCORREO-PARA.
  MOVE V_CC         TO ZCORREO-CC.
  MOVE V_BCC        TO ZCORREO-BCC.
  MOVE '0'          TO ZCORREO-ARCHIVOADJUNTO.

  MOVE ZCORREO TO I_OUTPUT_CONS_CANC-CORREO.

  CLEAR I_OUT_CONS_CANC.

  I_OUT_CONS_CANC-MT_S4_CONSULTAY_CANCELACION_RE = I_OUTPUT_CONS_CANC.

  PERFORM F_TIMBRADO_CANC_CONS.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_timbrado_canc_cons
*&---------------------------------------------------------------------*
FORM F_TIMBRADO_CANC_CONS .


*** Crea el objeto del proxy de la factura
  TRY.
      CREATE OBJECT L_PROXY_SERV_CANC_CONS.

    CATCH CX_AI_SYSTEM_FAULT INTO LR_AI_SYSTEM_FAULT.
      L_ERRORTEXT = LR_AI_SYSTEM_FAULT->ERRORTEXT.
      L_ERRORCODE = LR_AI_SYSTEM_FAULT->CODE.
  ENDTRY.

*** Con este codigo se habilita la recuperacion del ACK
  IF NOT C_ACK_ENABLED IS INITIAL.
    TRY.
        LR_ASYNC_MESSAGING ?= L_PROXY_SERV_CANC_CONS->GET_PROTOCOL( IF_WSPROTOCOL=>ASYNC_MESSAGING ).
      CATCH CX_AI_SYSTEM_FAULT INTO  LR_AI_SYSTEM_FAULT.
        LR_ASYNC_MESSAGING->SET_ACKNOWLEDGMENT_REQUESTED(
        IF_WSPROTOCOL_ASYNC_MESSAGING=>CO_COMPLETE_ACKNOWLEDGMENT ).
    ENDTRY.
  ENDIF.

  TRY.
      LR_MESSAGE_ID_PROTOCOL ?= L_PROXY_SERV_CANC_CONS->GET_PROTOCOL( IF_WSPROTOCOL=>MESSAGE_ID ).
    CATCH CX_AI_SYSTEM_FAULT INTO  LR_AI_SYSTEM_FAULT.
  ENDTRY.

*** Manda llamar el proxy
  TRY.
      TRY.
          CALL METHOD L_PROXY_SERV_CANC_CONS->SI_OS_S4_CONSULTAY_CANCELACION
            EXPORTING
              OUTPUT = I_OUT_CONS_CANC
            IMPORTING
              INPUT  = ZMT_S4_CFDITIMBRADO_RESP_C.

        CATCH CX_AI_SYSTEM_FAULT INTO LR_AI_SYSTEM_FAULT.
          L_ERRORTEXT = LR_AI_SYSTEM_FAULT->ERRORTEXT.
          L_ERRORCODE = LR_AI_SYSTEM_FAULT->CODE.
      ENDTRY.
    CATCH CX_AI_SYSTEM_FAULT INTO LR_AI_SYSTEM_FAULT.
      L_ERRORTEXT = LR_AI_SYSTEM_FAULT->ERRORTEXT.
      L_ERRORCODE = LR_AI_SYSTEM_FAULT->CODE.

  ENDTRY.

  COMMIT WORK.

  IF L_ERRORTEXT IS NOT INITIAL.

    DATA: P_RUTA_FAC TYPE STRING.

    CONCATENATE 'C:\temp\error_llamada_proxy'
                    '.html'
                    INTO P_RUTA_FAC.

    CLEAR: IT_XML_ERR.
    REFRESH: IT_XML_ERR.

    IT_XML_ERR = L_ERRORTEXT.
    APPEND IT_XML_ERR.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                = P_RUTA_FAC
        FILETYPE                = 'ASC'
        CODEPAGE                = '4110'
      TABLES
        DATA_TAB                = IT_XML_ERR
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6
        HEADER_NOT_ALLOWED      = 7
        SEPARATOR_NOT_ALLOWED   = 8
        FILESIZE_NOT_ALLOWED    = 9
        HEADER_TOO_LONG         = 10
        DP_ERROR_CREATE         = 11
        DP_ERROR_SEND           = 12
        DP_ERROR_WRITE          = 13
        UNKNOWN_DP_ERROR        = 14
        ACCESS_DENIED           = 15
        DP_OUT_OF_MEMORY        = 16
        DISK_FULL               = 17
        DP_TIMEOUT              = 18
        FILE_NOT_FOUND          = 19
        DATAPROVIDER_EXCEPTION  = 20
        CONTROL_FLUSH_ERROR     = 21
        OTHERS                  = 22.
    IF SY-SUBRC <> 0.

    ENDIF.

  ENDIF.


*** Leemos el ID del mensaje

  L_MESSAGE_ID = LR_MESSAGE_ID_PROTOCOL->GET_MESSAGE_ID( ).

*** Comprobacion del estado acknowledgement

  IF NOT C_ACK_ENABLED IS INITIAL.

* El do sirve para esperar en lo que devuelve el ACK
    DO 20 TIMES.
      L_CNT = L_CNT + 1.
      TRY.
*** Recuperamos el código de ACK

          LR_ACK = CL_PROXY_ACCESS=>GET_ACKNOWLEDGMENT( L_MESSAGE_ID ).
          LS_STATUS = LR_ACK->GET_STATUS( ).

        CATCH CX_AI_SYSTEM_FAULT INTO LR_AI_SYSTEM_FAULT .
*** En caso de que aun no llegue el mensaje de ACK
          IF LR_AI_SYSTEM_FAULT->CODE = CX_XMS_SYSERR_PROXY=>CO_ID_NO_ACK_ARRIVED_YET.
            SY-SUBRC = 1.
          ELSE.
            L_ERRORTEXT = LR_AI_SYSTEM_FAULT->ERRORTEXT.
            L_ERRORCODE = LR_AI_SYSTEM_FAULT->CODE.
          ENDIF.
      ENDTRY .

      IF LS_STATUS IS INITIAL.
        EXIT.
      ENDIF.

*** Esperamos un Segundo para obtener la respuesta del ACK en caso de aun no llegue
      WAIT UP TO 1 SECONDS.
    ENDDO.
  ENDIF.


  IF ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-MESSAGE IS NOT INITIAL.
    PERFORM F_PROCESA_CONS_CANC.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_procesa_cons_canc
*&---------------------------------------------------------------------*
FORM F_PROCESA_CONS_CANC .

  CLEAR: V_RESULT, V_CODE, V_MESSAGE, V_UUID, V_URLXML, V_URLQR,
           V_URLPDF, V_ARCHIVO, V_ESTATUS.

  V_RESULT    = ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-RESULT.
  V_CODE      = ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-CODE.
  V_MESSAGE   = ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-MESSAGE.
  V_UUID      = ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-UUID.
  V_URLXML    = ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-URL_XML.
  V_URLPDF    = ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-URL_PDF.
  V_URLQR     = ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-URL_QR.
  V_ARCHIVO   = ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-ARCHIVO.
  V_ESTATUS   = ZMT_S4_CFDITIMBRADO_RESP_C-MT_S4_CONSULTAY_CANCELACION_RE-ESTATUS.


  DATA: I_ZALV_CP_CANC TYPE ZALV_COMP_PAGO OCCURS 0 WITH HEADER LINE.
  CLEAR:   I_ZALV_CP_CANC.
  REFRESH: I_ZALV_CP_CANC.

  SELECT *
    FROM ZALV_COMP_PAGO
    INTO TABLE I_ZALV_CP_CANC
    WHERE BUKRS = WA_DATA_ALV-BUKRS
    AND   KUNNR = WA_DATA_ALV-KUNNR
    AND   GJAHR = WA_DATA_ALV-BUDAT+6(4)
    AND   DOC_PAGO = WA_DATA_ALV-DOC_PAGO.

  LOOP AT I_ZALV_CP_CANC.
    I_ZALV_CP_CANC-RESULT_PAC       = V_RESULT.
    I_ZALV_CP_CANC-CODE             = V_CODE.
    I_ZALV_CP_CANC-STATUS           = V_MESSAGE.
    I_ZALV_CP_CANC-UUID_CANC        = V_UUID.
    I_ZALV_CP_CANC-PDF_CANC  = V_URLPDF.
    I_ZALV_CP_CANC-STAT_CANC        = V_ESTATUS.
*    I_ZALV_CP_CANC-SEMAFORO        = 'E'.
    MODIFY I_ZALV_CP_CANC INDEX 1.
    MODIFY ZALV_COMP_PAGO FROM I_ZALV_CP_CANC.
    COMMIT WORK AND WAIT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_getcdata
*&---------------------------------------------------------------------*
FORM F_GETCDATA  USING V_URL
                       V_TIPO.

*** Reemplaza por el sitio sin SSL
  REPLACE ALL OCCURRENCES OF 'https' IN V_URL WITH 'http'.

**** Ruta de salida
  DATA: V_DP           TYPE C LENGTH 255,
        V_ABSOLUTE_URI TYPE C LENGTH 255,
        V_EXT          TYPE STRING.

  CLEAR: V_DP, V_ABSOLUTE_URI, V_EXT.

  V_ABSOLUTE_URI = V_URL.

  CONCATENATE P_PATH GT_DATA-BUKRS      '_'
                     GT_DATA-DOC_PAGO   '_'
                     GT_DATA-GJAHR      '('
                     GT_DATA-UUID      ').'
                     V_TIPO
    INTO V_DP.

  CALL FUNCTION 'HTTP_GET_FILE'
    EXPORTING
      ABSOLUTE_URI          = V_ABSOLUTE_URI
      DOCUMENT_PATH         = V_DP
    EXCEPTIONS
      CONNECT_FAILED        = 1
      TIMEOUT               = 2
      INTERNAL_ERROR        = 3
      DOCUMENT_ERROR        = 4
      TCPIP_ERROR           = 5
      SYSTEM_FAILURE        = 6
      COMMUNICATION_FAILURE = 7
      OTHERS                = 8.

  V_EXT = V_TIPO.
  TRANSLATE V_EXT TO UPPER CASE.

  CONCATENATE V_EXT 'del documento' GT_DATA-DOC_PAGO 'descargado.'
  INTO I_LOG_DESC-MSG1 SEPARATED BY SPACE.
  APPEND I_LOG_DESC.


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_VENTANA_LOG_DESC
*&---------------------------------------------------------------------*
FORM F_VENTANA_LOG_DESC .

  DATA: I_TSMESG TYPE TSMESG OCCURS 0,
        I_XX     TYPE LINE OF TSMESG,
        GT_MESG  TYPE  TSMESG,
        LS_MESG  TYPE  SMESG.

  CLEAR:    I_TSMESG.
  REFRESH:  I_TSMESG.



  LOOP AT I_LOG_DESC.
    LS_MESG-ARBGB = '00'.
    LS_MESG-TXTNR = '001'.
    LS_MESG-ZEILE = SY-TABIX.
    IF I_LOG_DESC-MSG1+0(1) = 'D'.
      LS_MESG-MSGTY = 'W'.
    ELSE.
      LS_MESG-MSGTY = 'I'.
    ENDIF.
    LS_MESG-MSGV1 = I_LOG_DESC-MSG1.
    LS_MESG-MSGV2 = I_LOG_DESC-MSG2.
    APPEND LS_MESG TO GT_MESG.
  ENDLOOP.


  CALL FUNCTION 'FB_MESSAGES_DISPLAY_POPUP'
    EXPORTING
      IT_SMESG        = GT_MESG
      ID_SEND_IF_ONE  = ABAP_TRUE
    EXCEPTIONS
      NO_MESSAGES     = 1
      POPUP_CANCELLED = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

 " PERFORM DESELECT_ALL_ROWS.

ENDFORM.                    " F_VENTANA_LOG_DESC
