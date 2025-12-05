************************************************************************
* Programa             : SAPMZCOINV                                     *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Picking                                       *
* Fecha Creación       : 04.07.2017                                    *
* Consultor Funcional  :                                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           MZSATRAF01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                    LOG DE MODIFICACIONES                             *
*----------------------------------------------------------------------*
* Descripción          :                                               *
* Funcional            :                                               *
* Desarrollador        :                                               *
* Fecha Modificación   :                                               *
*----------------------------------------------------------------------*


***********************************************************************
* Proyecto...: PPA_EVOLUTION                                          *
* Rutina.....: F_UPDATE                                               *
* Descripción: Inicia proceso                                         *
* Fecha......: 06/01/2017                                             *
* Autor......: Roberto Bautista Dominguez                             *
***********************************************************************
FORM F_UPDATE .

  DATA:
    SL_HUINV_ITEM TYPE HUINV_ITEM.

  DATA:
    TL_COUNTED_ITEMS TYPE HUINV_COUNTING_T,
    TL_MSG           TYPE HUITEM_MESSAGES_T.

  DATA:
    SL_COUNTED_ITEMS TYPE HUINV_COUNTING,
    SL_MSG           TYPE HUITEM_MESSAGES.

  DATA:
    TL_CANASTAS TYPE STANDARD TABLE OF TY_ITEM,
    TL_MATERIAL TYPE STANDARD TABLE OF TY_ITEM,
    TL_LOTES    TYPE STANDARD TABLE OF TY_ITEM,
    TL_CANTIDAD TYPE STANDARD TABLE OF TY_ITEM.

  DATA:
    SL_CANASTAS TYPE TY_ITEM,
    SL_MATERIAL TYPE TY_ITEM,
    SL_LOTES    TYPE TY_ITEM,
    SL_CANTIDAD TYPE TY_ITEM.

  DATA:
    VL_CANT     TYPE HUINV_ITEM-VEMNG,
    VL_LINES    TYPE SY-INDEX,
    VL_TABIX    TYPE SY-INDEX,
    VL_CANTIDAD TYPE C LENGTH 20.

*<-- Begin cbarrera.20220624
  "Se verifica si la HU es de ECC o Hana
  SELECT SINGLE EXIDV
  INTO VG_TOP_EXIDV
  FROM VEKP
  WHERE EXIDV = VG_TOP_EXIDV.

  IF SY-SUBRC NE 0.
    SELECT SINGLE EXIDV
    INTO VG_TOP_EXIDV
    FROM VEKP
    WHERE EXIDV2 = VG_TOP_EXIDV.
  ENDIF.
*<-- End cbarrera.20220624

  " Actualiza
  SELECT * INTO TABLE TG_HUINV_ITEM
    FROM HUINV_ITEM
   WHERE HANDLE EQ SG_HEAD-HANDLE
     AND TOP_EXIDV = VG_TOP_EXIDV.

  SORT TG_HUINV_ITEM.

  LOOP AT TG_HUINV_ITEM INTO SL_HUINV_ITEM
   WHERE TOP_EXIDV = VG_TOP_EXIDV
     AND COUNTED   = SPACE
     AND POSTED    = SPACE.

    SL_COUNTED_ITEMS-HANDLE       = SG_HEAD-HANDLE.
    SL_COUNTED_ITEMS-ITEM_NR      = SL_HUINV_ITEM-ITEM_NR.
    SL_COUNTED_ITEMS-HUEXIST      = ABAP_TRUE.
    SL_COUNTED_ITEMS-HUEXISTNOT   = SL_HUINV_ITEM-HUEXISTNOT.
    SL_COUNTED_ITEMS-QUANTITY     = SL_HUINV_ITEM-VEMNG.
    SL_COUNTED_ITEMS-MEINS        = SL_HUINV_ITEM-MEINS.
    SL_COUNTED_ITEMS-HUINV_NULL   = SL_HUINV_ITEM-HUINV_NULL.
    APPEND SL_COUNTED_ITEMS TO TL_COUNTED_ITEMS.
    CLEAR SL_COUNTED_ITEMS.

*    DELETE tg_huinv_item.

    " Determina el número de canastillas
    IF  SL_HUINV_ITEM-TOP_EXIDV NE SL_HUINV_ITEM-EXIDV
    AND SL_HUINV_ITEM-EXIDV IS NOT INITIAL.
      SL_CANASTAS-TOP_EXIDV  = SL_HUINV_ITEM-TOP_EXIDV.
      SL_CANASTAS-VEMNG      = 1.
      COLLECT SL_CANASTAS INTO TL_CANASTAS.
    ENDIF.
    IF SL_HUINV_ITEM-EXIDV IS INITIAL.

      SL_CANTIDAD-TOP_EXIDV  = SL_LOTES-TOP_EXIDV   = SL_MATERIAL-TOP_EXIDV  = SL_HUINV_ITEM-TOP_EXIDV.
      SL_CANTIDAD-VEMNG      = SL_LOTES-VEMNG       = SL_MATERIAL-VEMNG      = SL_HUINV_ITEM-VEMNG.
      SL_MATERIAL-MATNR      = SL_HUINV_ITEM-MATNR.
      SL_LOTES-CHARG         = SL_HUINV_ITEM-CHARG.
      SL_CANTIDAD-MEINS      = SL_HUINV_ITEM-MEINS.
      COLLECT SL_MATERIAL INTO TL_MATERIAL.
      COLLECT SL_LOTES    INTO TL_LOTES.
      COLLECT SL_CANTIDAD INTO TL_CANTIDAD.
      VL_CANT = VL_CANT + SL_HUINV_ITEM-VEMNG.
    ENDIF.
    AT LAST.

      READ TABLE TG_ITEM INTO SG_ITEM INDEX 1.

      IF SY-SUBRC = 0.
        VL_TABIX = SG_ITEM-ITEM_NR.
        CLEAR SG_ITEM.
      ENDIF.
      VL_TABIX =  VL_TABIX + 1.
      DESCRIBE TABLE TL_MATERIAL LINES VL_LINES.
      IF VL_LINES > 1.
        SG_ITEM-MATNR = 'MIX'.
      ELSE.
        READ TABLE TL_MATERIAL INTO SL_MATERIAL INDEX 1.
        SG_ITEM-MATNR = SL_MATERIAL-MATNR.
      ENDIF.
      DESCRIBE TABLE TL_LOTES    LINES VL_LINES.
      IF VL_LINES > 1.
        SG_ITEM-CHARG = 'MIX'.
      ELSE.
        READ TABLE TL_LOTES INTO SL_LOTES INDEX 1.
        SG_ITEM-CHARG = SL_LOTES-CHARG.
      ENDIF.
      DESCRIBE TABLE TL_CANTIDAD LINES VL_LINES.
      IF VL_LINES > 1.
        SG_ITEM-MEINS = 'MIX'.
      ELSE.
        READ TABLE TL_CANTIDAD INTO SL_CANTIDAD INDEX 1.
        SG_ITEM-MEINS = SL_CANTIDAD-MEINS.
      ENDIF.
      SG_ITEM-VEMNG     = VL_CANT.
      SG_ITEM-TOP_EXIDV = SL_MATERIAL-TOP_EXIDV.
      READ TABLE TL_CANASTAS INTO SL_CANASTAS INDEX 1.
      SG_ITEM-CANAST  = SL_CANASTAS-VEMNG.
      SG_ITEM-ITEM_NR = VL_TABIX.

      CONCATENATE 'Mater:' SG_ITEM-MATNR INTO SG_ITEM-CAMPO1 SEPARATED BY SPACE.

      WRITE: SG_ITEM-CANAST TO VL_CANTIDAD UNIT SG_ITEM-MEINS.
      CONDENSE VL_CANTIDAD NO-GAPS.
      CONCATENATE 'Canas:' VL_CANTIDAD INTO SG_ITEM-CAMPO2 SEPARATED BY SPACE.

      WRITE: SG_ITEM-VEMNG  TO VL_CANTIDAD UNIT SG_ITEM-MEINS.
      CONDENSE VL_CANTIDAD NO-GAPS.
      CONCATENATE 'Cant :' VL_CANTIDAD SG_ITEM-MEINS INTO SG_ITEM-CAMPO3 SEPARATED BY SPACE.

      CONCATENATE 'Lote :' SG_ITEM-CHARG INTO SG_ITEM-CAMPO4 SEPARATED BY SPACE.

      APPEND SG_ITEM TO TG_ITEM.
      CLEAR  SG_ITEM .
    ENDAT.
    CLEAR: SL_MATERIAL,SL_LOTES,SL_CANTIDAD,SL_CANASTAS.
  ENDLOOP.

  SORT TG_ITEM BY ITEM_NR DESCENDING.

  CLEAR VG_ERROR.
  IF TL_COUNTED_ITEMS[] IS NOT INITIAL.
    VG_LOG-EXTNUMBER = 'Proceso Conteo inventario'.         "#EC NOTEXT
    VG_LOG-ALUSER    = SY-UNAME.
    VG_LOG-ALPROG    = SY-REPID.
    VG_LOG-OBJECT    = 'ZHANDHELD'.
    VG_LOG-SUBOBJECT = 'ZCON_INV'.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        I_S_LOG      = VG_LOG
      IMPORTING
        E_LOG_HANDLE = VG_HANDLER
      EXCEPTIONS
        OTHERS       = 1.

    VG_MSG3 = 'Detalles SLG1 en SAP'.
    CONCATENATE 'Objeto' VG_LOG-OBJECT    INTO VG_MSG4 SEPARATED BY SPACE.
    CONCATENATE 'ObjInf' VG_LOG-SUBOBJECT INTO VG_MSG5 SEPARATED BY SPACE.

    CALL FUNCTION 'HUINV_GENERAL_DATA_REFRESH'.
    CALL FUNCTION 'HUINV_DOCUMENT_COUNTING'
      EXPORTING
        IF_HANDLE        = SG_HEAD-HANDLE
        IT_COUNTED_ITEMS = TL_COUNTED_ITEMS
      IMPORTING
        ET_MESSAGES      = TL_MSG
      EXCEPTIONS
        ERROR            = 1
        OTHERS           = 2.

    IF SY-SUBRC = 0.

      COMMIT WORK.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      PERFORM F_ARMA_102 USING '' 'Proceso exitoso' VG_MSG3 VG_MSG4 VG_MSG5
            SPACE SPACE SPACE SPACE SPACE.

    ELSE.
      VG_ERROR = ABAP_TRUE.
      PERFORM F_ARMA_102 USING '' 'Proceso erróneo' VG_MSG3 VG_MSG4 VG_MSG5
            SPACE SPACE SPACE SPACE SPACE.

    ENDIF.

    LOOP AT TL_MSG INTO SL_MSG.

      SG_MSJ-MSGTYP = SL_MSG-MSGTY.
      SG_MSJ-MSGID  = SL_MSG-MSGID.
      SG_MSJ-MSGNR  = SL_MSG-MSGNO.
      SG_MSJ-MSGV1  = SL_MSG-MSGV1.
      SG_MSJ-MSGV2  = SL_MSG-MSGV2.
      SG_MSJ-MSGV3  = SL_MSG-MSGV3.
      SG_MSJ-MSGV4  = SL_MSG-MSGV4.
      PERFORM F_MSG_ADD USING SG_MSJ '3'.

    ENDLOOP.

    APPEND VG_HANDLER TO TG_LOGHANDLE.
    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        I_CLIENT         = SY-MANDT
        I_IN_UPDATE_TASK = ' '
        I_SAVE_ALL       = ' '
        I_T_LOG_HANDLE   = TG_LOGHANDLE
      IMPORTING
        E_NEW_LOGNUMBERS = TG_LOGNUMBERS
      EXCEPTIONS
        LOG_NOT_FOUND    = 1
        SAVE_NOT_ALLOWED = 2
        NUMBERING_ERROR  = 3
        OTHERS           = 4.

    PERFORM F_FREE USING SG_HEAD-HANDLE.

  ELSE.
    " Se verifica si es error, porque ya esta contada o contabilizada
    READ TABLE TG_HUINV_ITEM INTO SL_HUINV_ITEM
      WITH KEY TOP_EXIDV = VG_TOP_EXIDV.

    IF SY-SUBRC = 0.

      IF SL_HUINV_ITEM-COUNTED = ABAP_TRUE
      OR SL_HUINV_ITEM-POSTED  = ABAP_TRUE.

        PERFORM F_ARMA_102 USING 'Esta UMp ya ha sido' 'contada para el' 'inventario'
                                 SG_HEAD-HUINV_NR '-' VG_TOP_EXIDV SPACE SPACE SPACE SPACE.
        CALL SCREEN '0103'.

      ENDIF.

    ELSE.


      " Se verifica si es una unidad de manipulación hijas
      SELECT SINGLE * INTO SL_HUINV_ITEM
        FROM HUINV_ITEM
       WHERE HANDLE EQ SG_HEAD-HANDLE
         AND EXIDV = VG_TOP_EXIDV.



      IF SY-SUBRC = 0.
        PERFORM F_ARMA_102 USING 'Se debe escanear' 'un pallet' SL_HUINV_ITEM-EXIDV
                                  SL_HUINV_ITEM-TOP_EXIDV SPACE  SPACE SPACE SPACE SPACE SPACE.

        CALL SCREEN '0103'.

      ELSE.

        PERFORM F_ZALMACENA.
        IF SY-SUBRC NE 0.
          " No existe
          PERFORM F_ARMA_102 USING 'No se pudo' 'determinar error' VG_TOP_EXIDV
                                    SPACE SPACE  SPACE SPACE SPACE SPACE SPACE.

          CALL SCREEN '0103'.
        ELSE.
          " No existe
          PERFORM F_ARMA_102 USING 'La UM no se' 'encontro' VG_TOP_EXIDV
                                   'Se guardo en tabla' 'Tabla ZHUINV_POST ' SPACE  SPACE SPACE SPACE SPACE.

          CALL SCREEN '0103'.

        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.

  CLEAR TG_HUINV_ITEM[].

ENDFORM.                    "f_update
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_FREE                                                  *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Libera transacciones                                    *
************************************************************************
FORM F_FREE USING X_OBJ.

  DATA:
    TL_SEQG3  TYPE STANDARD TABLE OF SEQG3.

  DATA:
    SL_SEQG3  TYPE SEQG3.

  DATA:
    VL_CONT  TYPE I.

  CLEAR VL_CONT.
  DO.
    CLEAR TL_SEQG3[].
    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        GCLIENT               = SY-MANDT
        GUNAME                = SY-UNAME
      TABLES
        ENQ                   = TL_SEQG3
      EXCEPTIONS
        COMMUNICATION_FAILURE = 1
        SYSTEM_FAILURE        = 2
        OTHERS                = 3.

    VL_CONT = VL_CONT + 1.
    LOOP AT TL_SEQG3 INTO SL_SEQG3
    WHERE GARG+3 = X_OBJ.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      EXIT.
    ELSE.
      IF VL_CONT = 180000.
        EXIT.
      ENDIF.
    ENDIF.
  ENDDO.

ENDFORM.                    " F_FREE
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_FREE                                                  *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Añade mensaje a LOG                                     *
************************************************************************
FORM  F_MSG_ADD USING X_MSJ    TYPE BDCMSGCOLL
      X_PROCLS TYPE BAL_S_MSG-PROBCLASS.
  DATA:
        L_S_MSG TYPE BAL_S_MSG.

  L_S_MSG-MSGTY     = X_MSJ-MSGTYP.
  L_S_MSG-MSGID     = X_MSJ-MSGID.
  L_S_MSG-MSGNO     = X_MSJ-MSGNR.
  L_S_MSG-MSGV1     = X_MSJ-MSGV1.
  L_S_MSG-MSGV2     = X_MSJ-MSGV2.
  L_S_MSG-MSGV3     = X_MSJ-MSGV3.
  L_S_MSG-MSGV4     = X_MSJ-MSGV4.
  L_S_MSG-PROBCLASS = X_PROCLS.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      I_S_MSG       = L_S_MSG
    EXCEPTIONS
      LOG_NOT_FOUND = 0
      OTHERS        = 1.

ENDFORM.                    "f_msg_add
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_GET_INFO                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Extrae información para ser procesada                   *
************************************************************************
FORM F_GET_INFO .
  DATA:
    TL_ITEM_1 TYPE STANDARD TABLE OF HUINV_ITEM,
    TL_ITEM_2 TYPE STANDARD TABLE OF HUINV_ITEM.

  DATA:
    SL_ITEM_1     TYPE HUINV_ITEM,
    SL_HUINV_ITEM TYPE HUINV_ITEM.

  SELECT SINGLE HANDLE HUINV_NR WERKS LGORT COUNTED POSTED
    INTO SG_HEAD
    FROM HUINV_HDR
   WHERE HUINV_NR EQ VG_HUINV_NR.

  IF SY-SUBRC EQ 0.

    IF  SG_HEAD-POSTED  EQ SPACE
    AND SG_HEAD-COUNTED EQ SPACE.

      SELECT * INTO TABLE TG_HUINV_ITEM
        FROM HUINV_ITEM
       WHERE HANDLE EQ SG_HEAD-HANDLE.

      IF SY-SUBRC NE 0.
        PERFORM F_ARMA_102
          USING '' 'DocInv:' VG_HUINV_NR 'sin posiciones' 'relevantes'
                SPACE SPACE SPACE SPACE SPACE.

        PERFORM F_PANT_MSJ.
      ENDIF.

      TL_ITEM_1[] = TG_HUINV_ITEM[].
      DELETE TL_ITEM_1 WHERE MATNR IS INITIAL.
      LOOP AT TL_ITEM_1 INTO SL_ITEM_1.

        READ TABLE TG_HUINV_ITEM INTO SL_HUINV_ITEM
          WITH KEY VENUM = SL_ITEM_1-VENUM
                   MATNR = SPACE.

        IF SY-SUBRC = 0.

          SG_ITEM-TOP_EXIDV = SL_ITEM_1-TOP_EXIDV.
          SG_ITEM-ITEM_NR   = SL_ITEM_1-ITEM_NR.
          SG_ITEM-VENUM     = SL_ITEM_1-VENUM.
          SG_ITEM-MATNR     = SL_ITEM_1-MATNR.
          SG_ITEM-CHARG     = SL_ITEM_1-CHARG.
          SG_ITEM-EXIDV     = SL_HUINV_ITEM-EXIDV.
          SG_ITEM-VEMNG     = SL_ITEM_1-VEMNG.
          SG_ITEM-MEINS     = SL_ITEM_1-MEINS.

          APPEND SG_ITEM TO TG_ITEM.
          CLEAR SG_ITEM.

        ENDIF.

      ENDLOOP.

      SORT TG_ITEM BY ITEM_NR VENUM TOP_EXIDV.

    ELSE.

      IF  SG_HEAD-POSTED  EQ ABAP_TRUE.

        PERFORM F_ARMA_102 USING '' 'DocInv:' VG_HUINV_NR 'Compensado' VG_MSG5
                SPACE SPACE SPACE SPACE SPACE.

        PERFORM F_PANT_MSJ.
      ENDIF.
      IF SG_HEAD-COUNTED EQ ABAP_TRUE.
        PERFORM F_ARMA_102 USING '' 'DocInv:' VG_HUINV_NR 'con conteo previo' VG_MSG5
              SPACE SPACE SPACE SPACE SPACE.

        PERFORM F_PANT_MSJ.
      ENDIF.

    ENDIF.

  ELSE.

    PERFORM F_ARMA_102 USING '' 'DocInv:' VG_HUINV_NR 'no existe' VG_MSG5
            SPACE SPACE SPACE SPACE SPACE.

    PERFORM F_PANT_MSJ.

  ENDIF.

ENDFORM.                    " F_GET_INFO
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_ARMA_102                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Arma mensajes                                           *
************************************************************************
FORM F_ARMA_102 USING X_TXT1 X_TXT2 X_TXT3 X_TXT4 X_TXT5 X_TXT6 X_TXT7
      X_TXT8 X_TXT9 X_TXT10.

  VG_MSG1  = X_TXT1.
  VG_MSG2  = X_TXT2.
  VG_MSG3  = X_TXT3.
  VG_MSG4  = X_TXT4.
  VG_MSG5  = X_TXT5.
  VG_MSG6  = X_TXT6.
  VG_MSG7  = X_TXT7.
  VG_MSG8  = X_TXT8.
  VG_MSG9  = X_TXT9.
  VG_MSG10 = X_TXT10.

ENDFORM.                    " F_ARMA_102
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_PANT_MSJ                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Arma mensajes                                           *
************************************************************************
FORM F_PANT_MSJ .

  CALL SCREEN '0103'.
  CLEAR VG_OK_CODE.

ENDFORM.                    " F_PANT_MSJ
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_VALIDA_UM                                             *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Valida doc de inventario                                *
************************************************************************
FORM F_VALIDA_UM .

  SELECT SINGLE HANDLE HUINV_NR WERKS LGORT COUNTED POSTED
    INTO SG_HEAD
    FROM HUINV_HDR
   WHERE HUINV_NR EQ VG_HUINV_NR.

  IF SY-SUBRC EQ 0.

    IF  SG_HEAD-POSTED  EQ SPACE
    AND SG_HEAD-COUNTED EQ SPACE.

      SELECT * INTO TABLE TG_HUINV_ITEM
        FROM HUINV_ITEM
       WHERE HANDLE EQ SG_HEAD-HANDLE.

      CALL SCREEN '0101'.

    ELSE.

      IF  SG_HEAD-POSTED  EQ ABAP_TRUE.

        PERFORM F_ARMA_102 USING '' 'DocInv:' VG_HUINV_NR 'Compensado' VG_MSG5
              SPACE SPACE SPACE SPACE SPACE.

        PERFORM F_PANT_MSJ.
      ENDIF.
      IF SG_HEAD-COUNTED EQ ABAP_TRUE.
        PERFORM F_ARMA_102 USING '' 'DocInv:' VG_HUINV_NR 'con conteo previo' VG_MSG5
              SPACE SPACE SPACE SPACE SPACE.

        PERFORM F_PANT_MSJ.
      ENDIF.

    ENDIF.

  ELSE.

    PERFORM F_ARMA_102 USING '' 'DocInv:' VG_HUINV_NR 'no existe' VG_MSG5
          SPACE SPACE SPACE SPACE SPACE.

    PERFORM F_PANT_MSJ.

  ENDIF.

*      PERFORM f_get_info.
*      IF tg_item[] IS NOT INITIAL.

*      ENDIF.
ENDFORM.                    " F_VALIDA_UM
*&---------------------------------------------------------------------*
*&      Form  F_ZALMACENA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_ZALMACENA                                             *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Almacena la información en la tabla Z                   *
************************************************************************
FORM F_ZALMACENA.

  TYPES: BEGIN OF TY_VEKP,
           VENUM  TYPE VEKP-VENUM,
           EXIDV  TYPE VEKP-EXIDV,
           STATUS TYPE VEKP-STATUS.
  TYPES:   END OF TY_VEKP.

  TYPES: BEGIN OF TY_Z2,
           VENUM  TYPE VEPO-VENUM,
           VEPOS  TYPE VEPO-VEPOS,
           VEMNG  TYPE VEPO-VEMNG,
           VEMEH  TYPE VEPO-VEMEH,
           MATNR  TYPE VEPO-MATNR,
           CHARG  TYPE VEPO-CHARG,
           WERKS  TYPE VEPO-WERKS,
           LGORT  TYPE VEPO-LGORT,
           EXIDV  TYPE VEKP-EXIDV,
           STATUS TYPE VEKP-STATUS.
  TYPES:   END OF TY_Z2.

  DATA:
    VL_VENUM TYPE VEKP-VENUM,
    VL_VHART TYPE VEKP-VHART.

  DATA:
    TL_VEKP        TYPE STANDARD TABLE OF TY_VEKP,
    TL_TEMP        TYPE STANDARD TABLE OF TY_Z2,
    TL_ZHUINV_POST TYPE STANDARD TABLE OF ZHUINV_POST.

  DATA:
    SL_TEMP        TYPE TY_Z2,
    SL_ZHUINV_POST TYPE ZHUINV_POST.


  SELECT SINGLE VENUM VHART
    INTO (VL_VENUM,VL_VHART)
    FROM VEKP
   WHERE EXIDV = VG_TOP_EXIDV.

  " Es un pallet
  IF VL_VHART = 'Z003'.

    SELECT VENUM EXIDV STATUS
      INTO TABLE TL_VEKP
      FROM VEKP
     WHERE UEVEL = VL_VENUM.

    IF TL_VEKP[] IS NOT INITIAL.
      SELECT VEPO~VENUM VEPO~VEPOS VEPO~VEMNG VEPO~VEMEH VEPO~MATNR VEPO~CHARG
             VEPO~WERKS VEPO~LGORT VEKP~EXIDV VEKP~STATUS
       INTO TABLE TL_TEMP
        FROM ( VEPO
       INNER JOIN VEKP
          ON VEKP~VENUM EQ VEPO~VENUM )
         FOR ALL ENTRIES IN TL_VEKP
       WHERE VEKP~VENUM = TL_VEKP-VENUM
         AND VEPO~VELIN = '1'.
    ENDIF.
  ELSE.
    SELECT VEPO~VENUM VEPO~VEPOS VEPO~VEMNG VEPO~VEMEH VEPO~MATNR VEPO~CHARG
           VEPO~WERKS VEPO~LGORT VEKP~EXIDV VEKP~STATUS
      INTO TABLE TL_TEMP
      FROM ( VEPO
     INNER JOIN VEKP
        ON VEKP~VENUM EQ VEPO~VENUM )
     WHERE VEKP~VENUM = VL_VENUM
       AND VEPO~VELIN = '1'.

  ENDIF.
  IF SY-SUBRC = 0.

    LOOP AT TL_TEMP INTO SL_TEMP.

      SL_ZHUINV_POST-HUINV_NR    = SG_HEAD-HUINV_NR.
      SL_ZHUINV_POST-TOP_EXIDV   = VG_TOP_EXIDV.
      SL_ZHUINV_POST-VENUM       = SL_TEMP-VENUM.
      SL_ZHUINV_POST-VEPOS       = SL_TEMP-VEPOS.
      SL_ZHUINV_POST-INVENTORY   = SG_HEAD-INVENTORY.
      SL_ZHUINV_POST-WERKS_INV   = SG_HEAD-WERKS.
      SL_ZHUINV_POST-LGORT_INV   = SG_HEAD-LGORT.
      SL_ZHUINV_POST-EXIDV       = SL_TEMP-EXIDV.
      SL_ZHUINV_POST-MATNR       = SL_TEMP-MATNR.
      SL_ZHUINV_POST-CHARG       = SL_TEMP-CHARG.
      SL_ZHUINV_POST-VEMNG       = SL_TEMP-VEMNG.
      SL_ZHUINV_POST-MEINS       = SL_TEMP-VEMEH.
      SL_ZHUINV_POST-STATUS      = SL_TEMP-STATUS.
      SL_ZHUINV_POST-WERKS_HU    = SL_TEMP-WERKS.
      SL_ZHUINV_POST-LGORT_HU    = SL_TEMP-LGORT.
      SL_ZHUINV_POST-UEVEL       = VL_VENUM.
      APPEND SL_ZHUINV_POST TO TL_ZHUINV_POST.
      CLEAR SL_ZHUINV_POST.
    ENDLOOP.
    IF TL_ZHUINV_POST[] IS NOT INITIAL.
      MODIFY ZHUINV_POST  FROM TABLE TL_ZHUINV_POST .
    ENDIF.
  ENDIF.

ENDFORM.                    " F_ZALMACENA
