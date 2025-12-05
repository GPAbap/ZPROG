*----------------------------------------------------------------------*
* Include ZFI_CARGA_SALDOS_S01                                         *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*&      Form  SEL_FILE
*&---------------------------------------------------------------------*
* Esta subrutina ejecuta el metodo: cl_gui_frontend_services=>file_open_dialog
* Para darle al usuario la opcion de seleccionar el archivo de entrada
* Dejando en la variable p_ruta, ruta y nombre de archivo
*----------------------------------------------------------------------*
*      <--P_RUTA  text
*----------------------------------------------------------------------*
FORM SEL_FILE CHANGING P_RUTA.                              "#EC *
  DATA: TI_RUTA TYPE FILETABLE,
        SL_RUTA LIKE LINE OF TI_RUTA,
        VL_RC   TYPE I.

  VG_TITTLE  = TEXT-001.                                    "#EC *
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = VG_TITTLE
      DEFAULT_EXTENSION = '*.*'
      INITIAL_DIRECTORY = 'C:\'
    CHANGING
      FILE_TABLE        = TI_RUTA
      RC                = VL_RC.
  IF SY-SUBRC EQ 0.
    READ TABLE TI_RUTA INTO SL_RUTA INDEX 1.
    IF SY-SUBRC EQ 0.
      MOVE SL_RUTA-FILENAME TO P_RUTA.
    ENDIF.

  ENDIF.
ENDFORM. "sel_file

*&---------------------------------------------------------------------*
*&      Form  importa_archivo
*&---------------------------------------------------------------------*
*  Carga el archivo de Entrada cuya ruta esta en la variable p_ruta
*  en la tabla interna tg_file
*----------------------------------------------------------------------*
FORM IMPORTA_ARCHIVO .

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME                = P_RUTA
      FILETYPE                = C_ASC
      HAS_FIELD_SEPARATOR     = C_X
    CHANGING
      DATA_TAB                = TG_FILE
    EXCEPTIONS
      FILE_OPEN_ERROR         = 1
      FILE_READ_ERROR         = 2
      NO_BATCH                = 3
      GUI_REFUSE_FILETRANSFER = 4
      INVALID_TYPE            = 5
      NO_AUTHORITY            = 6
      UNKNOWN_ERROR           = 7
      BAD_DATA_FORMAT         = 8
      HEADER_NOT_ALLOWED      = 9
      SEPARATOR_NOT_ALLOWED   = 10
      HEADER_TOO_LONG         = 11
      UNKNOWN_DP_ERROR        = 12
      ACCESS_DENIED           = 13
      DP_OUT_OF_MEMORY        = 14
      DISK_FULL               = 15
      DP_TIMEOUT              = 16
      NOT_SUPPORTED_BY_GUI    = 17
      ERROR_NO_GUI            = 18
      OTHERS                  = 19.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM. "importa_archivo
*&---------------------------------------------------------------------*
*&      Form  PROCESA_ARCHIVO
*&---------------------------------------------------------------------*
*  Procesa la tabla interna tg_file la cual contiene el archivo de entrada
*  Por cada linea de la tabla crea una posición en el asiento contable
*----------------------------------------------------------------------*
FORM CREA_ASIENTO_CONTABLE .
  DATA: VL_POS(10)  TYPE N,
        VL_OBJ_TYPE TYPE BAPIACHE09-OBJ_TYPE,               "#EC NEEDED
        VL_OBJ_KEY  TYPE BAPIACHE09-OBJ_KEY,                "#EC NEEDED
        VL_OBJ_SYS  TYPE BAPIACHE09-OBJ_SYS,                "#EC NEEDED
        VL_ZFBDT    TYPE CHAR10,
        VL_BUDAT    TYPE CHAR10,
        VL_BLDAT    TYPE CHAR10,
        VL_VALUT    TYPE CHAR10,
        VL_XMWST    TYPE XMWST,
        VL_IVA      TYPE WRBTR,
        AMT_WRBTR2  TYPE BAPIWRBTR,
        VL_NEWBS(2) TYPE N.

  PERFORM LEE_CVES_CONTABILIZACION.
  PERFORM LEE_TIPOS_DE_RETENCION.

*  READ TABLE tg_file INTO sg_file INDEX 1.
*  clear vl_budat.
*  IF sg_file-budat IS NOT INITIAL.
*    CONCATENATE sg_file-budat+6(4) sg_file-budat+3(2) sg_file-budat(2) INTO vl_budat.
*  ENDIF.
*  CLEAR vl_bldat.
*  IF sg_file-bldat IS NOT INITIAL.
*    CONCATENATE sg_file-bldat+6(4) sg_file-bldat+3(2) sg_file-bldat(2) INTO vl_bldat.
*  ENDIF.
**  CONCATENATE sg_file-zfbdt+4(4) sg_file-zfbdt+2(2) sg_file-zfbdt(2) INTO vl_zfbdt.
*  CLEAR sg_header.
** Datos de cabecera del asiento contable
*  sg_header-bus_act    = c_bus_act.
*  sg_header-username   = sy-uname.
*  sg_header-comp_code  = sg_file-bukrs.
*  sg_header-fisc_year  = vl_budat(4).
*  sg_header-doc_date   = vl_bldat.
*  sg_header-pstng_date = vl_budat.
*  sg_header-fis_period = sg_file-monat.
*  sg_header-doc_type   = sg_file-blart.
*  sg_header-header_txt = sg_file-bktxt.
*  sg_header-compo_acc  = space.


  VL_POS = 0.
  LOOP AT TG_FILE INTO SG_FILE.

    CLEAR: VL_BUDAT,
           VL_BLDAT,
           VL_ZFBDT,
           VL_VALUT.

    IF SG_FILE-BUDAT IS NOT INITIAL.
      CONCATENATE SG_FILE-BUDAT+6(4) SG_FILE-BUDAT+3(2) SG_FILE-BUDAT(2) INTO VL_BUDAT.
    ENDIF.


    IF SG_FILE-BLDAT IS NOT INITIAL.
      CONCATENATE SG_FILE-BLDAT+6(4) SG_FILE-BLDAT+3(2) SG_FILE-BLDAT(2) INTO VL_BLDAT.
    ENDIF.


    IF SG_FILE-ZFBDT IS NOT INITIAL.
      CONCATENATE SG_FILE-ZFBDT+6(4) SG_FILE-ZFBDT+3(2) SG_FILE-ZFBDT(2) INTO VL_ZFBDT.
    ENDIF.


    IF SG_FILE-VALUT IS NOT INITIAL.
      CONCATENATE SG_FILE-VALUT+6(4) SG_FILE-VALUT+3(2) SG_FILE-VALUT(2) INTO VL_VALUT.
    ENDIF.

    CLEAR SG_HEADER.

    SG_HEADER-BUS_ACT    = C_BUS_ACT.
    SG_HEADER-USERNAME   = SY-UNAME.
    SG_HEADER-COMP_CODE  = SG_FILE-BUKRS.
    SG_HEADER-FISC_YEAR  = VL_BUDAT(4).
    SG_HEADER-DOC_DATE   = VL_BLDAT.
    SG_HEADER-PSTNG_DATE = VL_BUDAT.
    SG_HEADER-FIS_PERIOD = SG_FILE-MONAT.
    SG_HEADER-DOC_TYPE   = SG_FILE-BLART.
    SG_HEADER-HEADER_TXT = SG_FILE-BKTXT.
    SG_HEADER-COMPO_ACC  = SPACE.

    IF SG_FILE-MWSKZ = '**'.
      CLEAR SG_FILE-MWSKZ.
    ENDIF.
    CLEAR: SG_ACCOUNT, SG_ACCPAY, SG_ACCREC.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = SG_FILE-NEWKO
      IMPORTING
        OUTPUT = SG_FILE-NEWKO.
    VL_POS = VL_POS + 1.

    CASE SG_FILE-KOART."   p_koart.
      WHEN C_CLIENTES.
*         Datos de partida abierta de Deudores
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = SG_FILE-NEWKO
          IMPORTING
            OUTPUT = SG_ACCREC-CUSTOMER.

        SG_ACCREC-ITEMNO_ACC  = VL_POS.
*        sg_accrec-customer   = sg_file-newko.
        SG_ACCREC-TAX_CODE    = SG_FILE-MWSKZ.
        SG_ACCREC-PMNTTRMS    = SG_FILE-ZTERM.  "ins lcruz 210516
        SG_ACCREC-BLINE_DATE  = VL_ZFBDT. " mod lcruz 240516
*        sg_accrec-bline_date = vl_zfbdt. mod lcruz 240516
        SG_ACCREC-PMNT_BLOCK = SG_FILE-ZLSPR.
        SG_ACCREC-PYMT_METH  = SG_FILE-ZLSCH.

        SG_ACCREC-ALLOC_NMBR = SG_FILE-XBLNR. "sg_file-zuonr.
        SG_ACCREC-ITEM_TEXT  = SG_FILE-SGTXT.  "KTXT. "sg_file-sgtxt.
        SG_ACCREC-SP_GL_IND = SG_FILE-NEWUM.
*        SG_ACCREC-BUS_AREA   = SG_FILE-GSBER. "add soporte05 030417
        SG_ACCREC-PROFIT_CTR = SG_FILE-PRCTR.
        SG_ACCREC-REF_KEY_1 = SG_FILE-XREF1.
        SG_ACCREC-REF_KEY_2 = SG_FILE-XREF2.
        SG_ACCREC-REF_KEY_3 = SG_FILE-XREF3.
        APPEND SG_ACCREC TO TG_ACCREC.
      WHEN C_PROVEEDORES.
*         Datos de partida abierta de Acreedores
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = SG_FILE-NEWKO
          IMPORTING
            OUTPUT = SG_ACCPAY-VENDOR_NO.

        SG_ACCPAY-ITEMNO_ACC = VL_POS.
*        sg_accpay-vendor_no  = sg_file-newko.
        SG_ACCPAY-COMP_CODE  = SG_FILE-BUKRS.
        SG_ACCPAY-PMNTTRMS   = SG_FILE-ZTERM. "mod lcruz 210516
        SG_ACCPAY-TAX_CODE   = SG_FILE-MWSKZ.
        SG_ACCPAY-BLINE_DATE = VL_ZFBDT. "mod lcruz 240516
*        sg_accpay-bline_date = vl_zfbdt. mod lcruz 240516
        SG_ACCPAY-SP_GL_IND  = SG_FILE-NEWUM.

        SG_ACCPAY-PMNT_BLOCK = SG_FILE-ZLSPR.
        SG_ACCPAY-PYMT_METH  = SG_FILE-ZLSCH.
        SG_ACCPAY-ALLOC_NMBR = SG_FILE-XBLNR. "sg_file-zuonr.
        SG_ACCPAY-ITEM_TEXT  = SG_FILE-SGTXT."BKTXT. "sg_file-sgtxt.
        SG_ACCPAY-PROFIT_CTR = SG_FILE-PRCTR.
        SG_ACCPAY-REF_KEY_1 = SG_FILE-XREF1.
        SG_ACCPAY-REF_KEY_2 = SG_FILE-XREF2.
        SG_ACCPAY-REF_KEY_3 = SG_FILE-XREF3.
        APPEND SG_ACCPAY TO TG_ACCPAY.

***--- Buscar logica para determinar si el vendor es sujeto a retenciones
***---- With Holding Tax----------------*
        CLEAR: TG_WTAX,
               SG_WTAX.

        REFRESH: TG_WTAX.

        LOOP AT TG_LFBW INTO SG_LFBW WHERE LIFNR = SG_ACCPAY-VENDOR_NO.

          SG_WTAX-ITEMNO_ACC = VL_POS.
          SG_WTAX-WT_TYPE    =  SG_LFBW-WITHT.
          SG_WTAX-WT_CODE    =  SG_LFBW-WT_WITHCD.
          APPEND SG_WTAX TO TG_WTAX.
        ENDLOOP.

***---- With Holding Tax----------------*

      WHEN OTHERS.
*         Datos de partida abierta de Bancos y Otras cuentas
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = SG_FILE-NEWKO
          IMPORTING
            OUTPUT = SG_ACCOUNT-GL_ACCOUNT.
        SG_ACCOUNT-ITEMNO_ACC = VL_POS.
*       sg_account-gl_account = sg_file-newko.
        SG_ACCOUNT-DOC_TYPE   = SG_FILE-BLART.
        SG_ACCOUNT-COMP_CODE  = SG_FILE-BUKRS.
        SG_ACCOUNT-FIS_PERIOD = SG_FILE-MONAT.
        SG_ACCOUNT-FISC_YEAR  = VL_BUDAT(4).
        SG_ACCOUNT-PSTNG_DATE = VL_BUDAT.
*        SG_ACCOUNT-BUS_AREA   = SG_FILE-GSBER.    " Division
        "SG_ACCOUNT-COSTCENTER = SG_FILE-KOSTL.
        SG_ACCOUNT-ORDERID = SG_FILE-ORDERID. "Orden 20.03.2024 Jaime Hernandez Velásquez
        SG_ACCOUNT-PROFIT_CTR = SG_FILE-PRCTR.
        SG_ACCOUNT-VALUE_DATE = VL_VALUT.
*ins lcruz 10042018
        SG_ACCOUNT-ALLOC_NMBR =  SG_FILE-XBLNR.
*        SG_ACCOUNT-ITEM_TEXT  =  SG_FILE-BKTXT.
*fin mod lcruz.

        SG_ACCOUNT-ITEM_TEXT  = SG_FILE-SGTXT.
        SG_ACCOUNT-TAX_CODE   = SG_FILE-MWSKZ.
*          sg_account-ALLOC_NMBR = sg_file-zuonr.
        SG_ACCOUNT-REF_KEY_1 = SG_FILE-XREF1.
        SG_ACCOUNT-REF_KEY_2 = SG_FILE-XREF2.
        SG_ACCOUNT-REF_KEY_3 = SG_FILE-XREF3.
        SG_ACCOUNT-ITEM_TEXT = SG_FILE-SGTXT.
        APPEND SG_ACCOUNT TO TG_ACCOUNT.
    ENDCASE.

* Asigna Valor a Clave de Contabilizacion en estructura de EXTENSION
* debido a que la BAPI no maneja este valor en las estructuras estandar
* en una funcion posterior (ZGL_ACC_DOCUMENT_POST) este valor se asignara
* al campo correspondiente.

    IF SG_FILE-NEWUM IS NOT INITIAL.
      SG_EXTENS1-FIELD1 = VL_POS.
      SG_EXTENS1-FIELD2 = C_BSCHL.
      SG_EXTENS1-FIELD3 = SG_FILE-NEWBS.
      APPEND SG_EXTENS1 TO TG_EXTENS1.
    ENDIF.

* Asigna Valor a Monto de Movimiento
* Para Cada Registro de tg_accrec, tg_accpay, tg_account se crea un registro
* en la tabla tg_camount con el importe correspondiente.

    CLEAR SG_CAMOUNT.
    SG_CAMOUNT-ITEMNO_ACC   = VL_POS.
    SG_CAMOUNT-CURRENCY     = SG_FILE-WAERS.
    SG_CAMOUNT-EXCH_RATE    = SG_FILE-KURSF.
    VL_NEWBS = SG_FILE-NEWBS.
    READ TABLE TG_TBSL INTO SG_TBSL WITH KEY BSCHL = VL_NEWBS
                      BINARY SEARCH.
    IF SG_TBSL-SHKZG = C_HABER.         " Naturaleza del Registro (Debe/Haber)
      SG_CAMOUNT-AMT_DOCCUR = - SG_FILE-WRBTR.
    ELSE.
      SG_CAMOUNT-AMT_DOCCUR = SG_FILE-WRBTR.
    ENDIF.

*     Calculo Automatico de IVA
    IF SG_FILE-XMWST = C_X.
      VL_XMWST = SG_FILE-XMWST.
    ENDIF.
    IF VL_XMWST = C_X AND ( NOT SG_FILE-MWSKZ IS INITIAL ).
*         Esta rutina calcula el iva de acuerdo a la naturaleza de la cuenta
*         Generando n registros en la tabla tg_mwdat con el detalle del calculo
      PERFORM CALC_IVA.
      VL_IVA = 0.
      LOOP AT TG_MWDAT INTO SG_MWDAT.
        VL_IVA = VL_IVA + SG_MWDAT-WMWST.
      ENDLOOP.
*         Se resta el IVA calculado del monto del registro ya que se
*         Agregaran registros al asiento con el valor del IVA y al final
*         La suma de valores debera dar "Cero" (Asiento Cuadrado).
      SG_CAMOUNT-AMT_DOCCUR = SG_CAMOUNT-AMT_DOCCUR - VL_IVA.
*      SG_CAMOUNT-EXCH_RATE    = SG_FILE-KURSF.       " Tipo de cambio
      APPEND SG_CAMOUNT TO TG_CAMOUNT.
*         Adicion de registros con los valores de IVA Calculado en el asiento contable
      LOOP AT TG_MWDAT INTO SG_MWDAT.
        VL_POS = VL_POS + 1.
        SG_ACCTAX-ITEMNO_ACC = VL_POS.
        SG_ACCTAX-GL_ACCOUNT = SG_MWDAT-HKONT.         " Cuenta de IVA
        SG_ACCTAX-TAX_CODE   = SG_FILE-MWSKZ.          " Clave de Impuestos
        SG_ACCTAX-ACCT_KEY   = SG_MWDAT-KTOSL.         " Clave de Operacion
        SG_ACCTAX-COND_KEY   = SG_MWDAT-KSCHL.         " Clave de Condicion
        APPEND SG_ACCTAX TO TG_ACCTAX.
        SG_CAMOUNT-ITEMNO_ACC   = VL_POS.
        SG_CAMOUNT-CURRENCY     = SG_FILE-WAERS.
        SG_CAMOUNT-AMT_DOCCUR   = SG_MWDAT-WMWST.      " Importe de Impuesto
        SG_CAMOUNT-AMT_BASE     = SG_MWDAT-KAWRT.      " Base p/Calc. de Impuesto
        SG_CAMOUNT-EXCH_RATE    = SG_FILE-KURSF.       " Tipo de cambio
        APPEND SG_CAMOUNT TO TG_CAMOUNT.
      ENDLOOP.
*          vl_xmwst = sg_file-xmwst.
    ELSE.
      APPEND SG_CAMOUNT TO TG_CAMOUNT.
    ENDIF.

* Genera 2da linea movto
    IF SG_FILE-WRBTR2 IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = SG_FILE-NEWKO2
        IMPORTING
          OUTPUT = SG_FILE-NEWKO2.
      VL_POS = VL_POS + 1.

      CASE SG_FILE-KOART.
        WHEN C_CLIENTES.
*           Datos de partida abierta de Deudores
          SG_ACCREC-ITEMNO_ACC = VL_POS.
          SG_ACCREC-CUSTOMER   = SG_FILE-NEWKO2.
          SG_ACCREC-PMNTTRMS   = SG_FILE-ZTERM. " ins lcruz 210516
          SG_ACCREC-BLINE_DATE = VL_ZFBDT.  " ins lcruz 240516
          APPEND SG_ACCREC TO TG_ACCREC.
        WHEN C_PROVEEDORES.
*           Datos de partida abierta de Acreedores
          SG_ACCPAY-ITEMNO_ACC = VL_POS.
          SG_ACCPAY-VENDOR_NO  = SG_FILE-NEWKO2.
          APPEND SG_ACCPAY TO TG_ACCPAY.
        WHEN OTHERS.
*           Datos de partida abierta de Bancos y Otras cuentas
          SG_ACCOUNT-ITEMNO_ACC = VL_POS.
          SG_ACCOUNT-GL_ACCOUNT = SG_FILE-NEWKO2.
          APPEND SG_ACCOUNT TO TG_ACCOUNT.
      ENDCASE.

      SG_EXTENS1-FIELD1 = C_BSCHL.
      SG_EXTENS1-FIELD2 = SG_FILE-NEWBS2.
      SG_EXTENS1-FIELD3 = SG_FILE-NEWUM.
      APPEND SG_EXTENS1 TO TG_EXTENS1.

      CLEAR SG_CAMOUNT.

      SG_CAMOUNT-ITEMNO_ACC   = VL_POS.
      SG_CAMOUNT-CURRENCY     = SG_FILE-WAERS.
*      SG_CAMOUNT-EXCH_RATE    = SG_FILE-KURSF.
      VL_NEWBS = SG_FILE-NEWBS.
      READ TABLE TG_TBSL INTO SG_TBSL WITH KEY BSCHL = VL_NEWBS
                          BINARY SEARCH.
      IF SG_TBSL-SHKZG = C_HABER.         " Naturaleza del Registro (Debe/Haber)
        SG_CAMOUNT-AMT_DOCCUR = - SG_FILE-WRBTR2.
      ELSE.
        SG_CAMOUNT-AMT_DOCCUR = SG_FILE-WRBTR2.
      ENDIF.
      APPEND SG_CAMOUNT TO TG_CAMOUNT.
    ENDIF.

*     En cada Cambio de Valor de Referencia
*     Se Graba un Nuevo Asiento Contable
    AT END OF XBLNR.
      SG_HEADER-REF_DOC_NO = SG_FILE-XBLNR.
      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          DOCUMENTHEADER    = SG_HEADER
        IMPORTING
          OBJ_TYPE          = VL_OBJ_TYPE
          OBJ_KEY           = VL_OBJ_KEY
          OBJ_SYS           = VL_OBJ_SYS
        TABLES
          ACCOUNTTAX        = TG_ACCTAX
          ACCOUNTRECEIVABLE = TG_ACCREC
          ACCOUNTPAYABLE    = TG_ACCPAY
          ACCOUNTGL         = TG_ACCOUNT
          CURRENCYAMOUNT    = TG_CAMOUNT
          RETURN            = TG_RETURN
          EXTENSION1        = TG_EXTENS1
          ACCOUNTWT         = TG_WTAX.
      READ TABLE TG_RETURN INTO SG_RETURN INDEX 1.
      IF SG_RETURN-TYPE = C_SUCCESS.                      " Creacion exitosa
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.
      ENDIF.
      SORT TG_RETURN BY NUMBER MESSAGE_V1.
*       Se suprimen los mensajes iguales para reportar solo una linea de mensaje por linea de asiento
      DELETE ADJACENT DUPLICATES FROM TG_RETURN COMPARING NUMBER MESSAGE_V1.
      LOOP AT TG_RETURN INTO SG_RETURN.
        SG_LOG-MSGID = SG_RETURN-ID.
        SG_LOG-MSGTY = SG_RETURN-TYPE.
        SG_LOG-MSGNO = SG_RETURN-NUMBER.
        SG_LOG-MSGV1 = SG_RETURN-MESSAGE_V1.
        SG_LOG-MSGV2 = SG_RETURN-MESSAGE_V2.
        SG_LOG-MSGV3 = SG_RETURN-MESSAGE_V3.
        SG_LOG-MSGV4 = SG_RETURN-MESSAGE_V4.
        SG_LOG-LINENO = SG_RETURN-ROW.
*         Adiciona mensaje a log de errores que al finalizar el programa sera
*         Desplegado en forma total
        APPEND SG_LOG TO   TG_LOG.
      ENDLOOP.
      REFRESH: TG_ACCREC, TG_ACCPAY, TG_ACCOUNT, TG_CAMOUNT, TG_EXTENS1,
               TG_ACCTAX, TG_MWDAT.
      CLEAR: VL_POS, VL_XMWST.
    ENDAT.
  ENDLOOP.

ENDFORM. " PROCESA_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  LEE_CVES_CONTABILIZACION
*&---------------------------------------------------------------------*
* Lee claves de contabilización las cuales serán utilizadas para determinar
* la naturaleza de cada posición del asiento contable
*----------------------------------------------------------------------*
FORM LEE_CVES_CONTABILIZACION .
  SELECT BSCHL SHKZG
    FROM TBSL INTO TABLE TG_TBSL.
ENDFORM. " LEE_CVES_CONTABILIZACION

*&---------------------------------------------------------------------*
*&      Form  CALC_IVA
*&---------------------------------------------------------------------*
* Calcula iva de asiento
* dejando detalle de contabilización en tabla : tg_mwdat
*----------------------------------------------------------------------*

FORM CALC_IVA.
  DATA: VL_DFIVA TYPE WRBTR,                                "#EC NEEDED
        VL_WRBTR TYPE BSEG-WRBTR.
  VL_WRBTR = SG_CAMOUNT-AMT_DOCCUR.
  CALL FUNCTION 'CALCULATE_TAX_FROM_GROSSAMOUNT'
    EXPORTING
      I_BUKRS                 = SG_FILE-BUKRS
      I_MWSKZ                 = SG_FILE-MWSKZ
      I_WAERS                 = SG_FILE-WAERS
      I_WRBTR                 = VL_WRBTR
    IMPORTING
      E_FWAST                 = VL_DFIVA
    TABLES
      T_MWDAT                 = TG_MWDAT
    EXCEPTIONS
      BUKRS_NOT_FOUND         = 1
      COUNTRY_NOT_FOUND       = 2
      MWSKZ_NOT_DEFINED       = 3
      MWSKZ_NOT_VALID         = 4
      ACCOUNT_NOT_FOUND       = 5
      DIFFERENT_DISCOUNT_BASE = 6
      DIFFERENT_TAX_BASE      = 7
      TXJCD_NOT_VALID         = 8
      NOT_FOUND               = 9
      KTOSL_NOT_FOUND         = 10
      KALSM_NOT_FOUND         = 11
      PARAMETER_ERROR         = 12
      KNUMH_NOT_FOUND         = 13
      KSCHL_NOT_FOUND         = 14
      UNKNOWN_ERROR           = 15
      OTHERS                  = 16.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "CALC_IVA
*&---------------------------------------------------------------------*
*& Form LEE_TIPOS_DE_RETENCION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM LEE_TIPOS_DE_RETENCION .

  LOOP AT TG_FILE INTO SG_FILE.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = SG_FILE-NEWKO
      IMPORTING
        OUTPUT = SG_LIFNR-LIFNR.
    IF SY-SUBRC EQ 0.

      APPEND SG_LIFNR TO TG_LIFNR.

    ENDIF.

  ENDLOOP.


  SELECT LIFNR WITHT WT_WITHCD
   FROM LFBW INTO TABLE TG_LFBW
    FOR ALL ENTRIES IN TG_LIFNR
  WHERE   WT_SUBJCT = 'X'
    AND LIFNR = TG_LIFNR-LIFNR.
ENDFORM.
