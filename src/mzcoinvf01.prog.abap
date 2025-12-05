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
FORM f_update .

  DATA:
    sl_huinv_item TYPE huinv_item.

  vg_log-extnumber = 'Proceso Conteo inventario'.           "#EC NOTEXT
  vg_log-aluser    = sy-uname.
  vg_log-alprog    = sy-repid.
  vg_log-object    = 'ZHANDHELD'.
  vg_log-subobject = 'ZCON_INV'.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log      = vg_log
    IMPORTING
      e_log_handle = vg_handler
    EXCEPTIONS
      OTHERS       = 1.

  vg_msg3 = 'Detalles SLG1 en SAP'.
  CONCATENATE 'Objeto' vg_log-object    INTO vg_msg4 SEPARATED BY space.
  CONCATENATE 'ObjInf' vg_log-subobject INTO vg_msg5 SEPARATED BY space.

  DATA:
    tl_counted_items TYPE huinv_counting_t,
    tl_msg           TYPE huitem_messages_t.

  DATA:
    sl_counted_items TYPE huinv_counting,
    sl_msg           TYPE huitem_messages.

  break bayco7.
  LOOP AT tg_item INTO sg_item
    WHERE mark = abap_true.

    LOOP AT tg_huinv_item INTO sl_huinv_item
      WHERE exidv = sg_item-top_exidv
         OR venum =  sg_item-venum.

      sl_counted_items-handle       = sg_head-handle.
      sl_counted_items-item_nr      = sl_huinv_item-item_nr.
      sl_counted_items-huexist      = sg_item-huexist.
      sl_counted_items-huexistnot   = sg_item-huexistnot.
      sl_counted_items-quantity     = sg_item-vemng.
      sl_counted_items-meins        = sg_item-meins.
      IF sg_item-huexistnot         = abap_true.
        sl_counted_items-huinv_null = abap_true.
        CLEAR sl_counted_items-quantity.
      ENDIF.
      APPEND sl_counted_items TO tl_counted_items.
      CLEAR sl_counted_items.
      DELETE tg_huinv_item.
    ENDLOOP.

  ENDLOOP.

  CLEAR vg_error.
  CALL FUNCTION 'HUINV_DOCUMENT_COUNTING'
    EXPORTING
      if_handle        = sg_head-handle
      it_counted_items = tl_counted_items
    IMPORTING
      et_messages      = tl_msg
    EXCEPTIONS
      error            = 1
      OTHERS           = 2.

  IF sy-subrc = 0.
    COMMIT WORK.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    PERFORM f_arma_102 USING '' 'Proceso exitoso' vg_msg3 vg_msg4 vg_msg5
          space space space space space.

  ELSE.
    vg_error = abap_true.
    PERFORM f_arma_102 USING '' 'Proceso erróneo' vg_msg3 vg_msg4 vg_msg5
          space space space space space.

  ENDIF.

  LOOP AT tl_msg INTO sl_msg.

    sg_msj-msgtyp = sl_msg-msgty.
    sg_msj-msgid  = sl_msg-msgid.
    sg_msj-msgnr  = sl_msg-msgno.
    sg_msj-msgv1  = sl_msg-msgv1.
    sg_msj-msgv2  = sl_msg-msgv2.
    sg_msj-msgv3  = sl_msg-msgv3.
    sg_msj-msgv4  = sl_msg-msgv4.
    PERFORM f_msg_add USING sg_msj '3'.

  ENDLOOP.

  APPEND vg_handler TO tg_loghandle.
  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_client         = sy-mandt
      i_in_update_task = ' '
      i_save_all       = ' '
      i_t_log_handle   = tg_loghandle
    IMPORTING
      e_new_lognumbers = tg_lognumbers
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.

  CALL SCREEN '0103'.

ENDFORM.                                                    "f_vl01n
************************************************************************
* Proyecto...: PROAN                                                   *
* Proyecto...: PPA_EVOLUTION                                           *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 09/01/2017                                              *
* Función....: Llama trsacción                                         *
************************************************************************
FORM f_call USING x_tcode.

*  CALL TRANSACTION x_tcode
*  USING tg_bdc
*        MODE vg_modo
*        UPDATE 'S'
*        MESSAGES INTO tg_msj.

ENDFORM.                    " F_CALL
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_MSJ                                                   *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 09/01/2017                                              *
* Función....: Procesa mensajes                                        *
************************************************************************
FORM f_msj USING x_tipo.

*  LOOP AT tg_msj INTO sg_msj.
*
*    CASE sg_msj-msgtyp.
*      WHEN 'S'.
*        PERFORM f_msg_add USING sg_msj '3'.
*      WHEN 'E'.
*        vg_error     = abap_true.
*        PERFORM f_msg_add USING sg_msj '1'.
*      WHEN OTHERS.
*        PERFORM f_msg_add USING sg_msj '2'.
*    ENDCASE.
*
*    " Entrega
*    IF  sg_msj-msgid = 'VL'
*    AND sg_msj-msgnr = '311'.
*      IF vg_vbeln2 IS INITIAL.
*        vg_vbeln2  = sg_msj-msgv2.
*      ENDIF.
*      PERFORM f_free USING vg_vbeln2.
*      COMMIT WORK.
*    ENDIF.
*
*    " Transporte
*    IF  sg_msj-msgid = 'VW'
*    AND sg_msj-msgnr = '006'.
*      COMMIT WORK.
*      vg_tknum2  = sg_msj-msgv1.
*      PERFORM f_free USING vg_tknum2.
*      COMMIT WORK.
*    ENDIF.
*
*    " Gasto de transporte
*    IF  sg_msj-msgid = 'VY'
*    AND sg_msj-msgnr = '007'.
*      COMMIT WORK.
*      vg_fknum2 = sg_msj-msgv1.
*      PERFORM f_free USING vg_fknum2.
*      COMMIT WORK.
*    ENDIF.
*
*  ENDLOOP.
*  CLEAR: tg_msj[],tg_bdc.

ENDFORM.                    " F_MSJ
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_FREE                                                  *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Libera transacciones                                    *
************************************************************************
FORM f_free USING x_obj.

  DATA:
        tl_seqg3  TYPE STANDARD TABLE OF seqg3.

  DATA:
        sl_seqg3  TYPE seqg3.

  DATA:
        vl_cont  TYPE i.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = x_obj
    IMPORTING
      output = x_obj.

  CLEAR vl_cont.
  DO.
    CLEAR tl_seqg3[].
    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gclient               = sy-mandt
        guname                = sy-uname
      TABLES
        enq                   = tl_seqg3
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        OTHERS                = 3.

    vl_cont = vl_cont + 1.
    LOOP AT tl_seqg3 INTO sl_seqg3
    WHERE garg+3 = x_obj.
    ENDLOOP.
    IF sy-subrc NE 0.
      EXIT.
    ELSE.
      IF vl_cont = 180000.
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
FORM  f_msg_add USING x_msj    TYPE bdcmsgcoll
      x_procls TYPE bal_s_msg-probclass.
  DATA:
        l_s_msg TYPE bal_s_msg.

  l_s_msg-msgty     = x_msj-msgtyp.
  l_s_msg-msgid     = x_msj-msgid.
  l_s_msg-msgno     = x_msj-msgnr.
  l_s_msg-msgv1     = x_msj-msgv1.
  l_s_msg-msgv2     = x_msj-msgv2.
  l_s_msg-msgv3     = x_msj-msgv3.
  l_s_msg-msgv4     = x_msj-msgv4.
  l_s_msg-probclass = x_procls.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_s_msg       = l_s_msg
    EXCEPTIONS
      log_not_found = 0
      OTHERS        = 1.

ENDFORM.                    "f_msg_add
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_GET_INFO                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Extrae información para ser procesada                   *
************************************************************************
FORM f_get_info .
  DATA:
    tl_item_1     TYPE STANDARD TABLE OF huinv_item,
    tl_item_2     TYPE STANDARD TABLE OF huinv_item.

  DATA:
    sl_item_1     TYPE huinv_item,
    sl_huinv_item TYPE huinv_item.

  SELECT SINGLE handle huinv_nr werks lgort counted posted
    INTO sg_head
    FROM huinv_hdr
   WHERE huinv_nr EQ vg_huinv_nr.

  IF sy-subrc EQ 0.

    IF  sg_head-posted  EQ space
    AND sg_head-counted EQ space.

      SELECT * INTO TABLE tg_huinv_item
        FROM huinv_item
       WHERE handle EQ sg_head-handle.

      IF sy-subrc NE 0.
        PERFORM f_arma_102
          USING '' 'DocInv:' vg_huinv_nr 'sin posiciones' 'relevantes'
                space space space space space.

        PERFORM f_pant_msj.
      ENDIF.

      tl_item_1[] = tg_huinv_item[].
      DELETE tl_item_1 WHERE matnr IS INITIAL.
      LOOP AT tl_item_1 INTO sl_item_1.

        READ TABLE tg_huinv_item INTO sl_huinv_item
          WITH KEY venum = sl_item_1-venum
                   matnr = space.

        IF sy-subrc = 0.

          sg_item-top_exidv = sl_item_1-top_exidv.
          sg_item-item_nr   = sl_item_1-item_nr.
          sg_item-venum     = sl_item_1-venum.
          sg_item-matnr     = sl_item_1-matnr.
          sg_item-charg     = sl_item_1-charg.
          sg_item-exidv     = sl_huinv_item-exidv.
          sg_item-vemng     = sl_item_1-vemng.
          sg_item-meins     = sl_item_1-meins.

          APPEND sg_item TO tg_item.
          CLEAR sg_item.

        ENDIF.

      ENDLOOP.

      SORT tg_item BY item_nr venum top_exidv.

    ELSE.

      IF  sg_head-posted  EQ abap_true.

        PERFORM f_arma_102 USING '' 'DocInv:' vg_huinv_nr 'Compensado' vg_msg5
                space space space space space.

        PERFORM f_pant_msj.
      ENDIF.
      IF sg_head-counted EQ abap_true.
        PERFORM f_arma_102 USING '' 'DocInv:' vg_huinv_nr 'con conteo previo' vg_msg5
              space space space space space.

        PERFORM f_pant_msj.
      ENDIF.

    ENDIF.

  ELSE.

    PERFORM f_arma_102 USING '' 'DocInv:' vg_huinv_nr 'no existe' vg_msg5
            space space space space space.

    PERFORM f_pant_msj.

  ENDIF.

ENDFORM.                    " F_GET_INFO
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_ARMA_102                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Arma mensajes                                           *
************************************************************************
FORM f_arma_102 USING x_txt1 x_txt2 x_txt3 x_txt4 x_txt5 x_txt6 x_txt7
      x_txt8 x_txt9 x_txt10.

  vg_msg1  = x_txt1.
  vg_msg2  = x_txt2.
  vg_msg3  = x_txt3.
  vg_msg4  = x_txt4.
  vg_msg5  = x_txt5.
  vg_msg6  = x_txt6.
  vg_msg7  = x_txt7.
  vg_msg8  = x_txt8.
  vg_msg9  = x_txt9.
  vg_msg10 = x_txt10.

ENDFORM.                    " F_ARMA_102
************************************************************************
* Proyecto...: PPA_EVOLUTION                                           *
* Subrutina..: F_PANT_MSJ                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Arma mensajes                                           *
************************************************************************
FORM f_pant_msj .

  CALL SCREEN '0103'.
  CLEAR vg_ok_code.

ENDFORM.                    " F_PANT_MSJ
