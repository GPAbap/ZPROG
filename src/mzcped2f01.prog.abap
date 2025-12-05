************************************************************************
* Programa             : SAPMZCPED                                     *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Pedido automático                             *
* Fecha Creación       : 04.11.2017                                    *
* Consultor Funcional  :                                               *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                    LOG DE MODIFICACIONES                             *
*----------------------------------------------------------------------*
* Descripción          :                                               *
* Funcional            :                                               *
* Desarrollador        :                                               *
* Fecha Modificación   :                                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           MZSATRAF01
*&---------------------------------------------------------------------*
***********************************************************************
* Proyecto...: PPA Evolution                                          *
* Rutina.....: F_PROCESO                                              *
* Descripción: Inicia proceso                                         *
* Fecha......: 06/01/2017                                             *
* Autor......: Roberto Bautista Dominguez                             *
***********************************************************************
FORM f_update.

  IF tg_p101[] IS NOT INITIAL.

*    IF vg_nocarga IS INITIAL.
*
*      CALL FUNCTION 'NUMBER_GET_NEXT'
*        EXPORTING
*          nr_range_nr             = '01'
*          object                  = 'ZNCPA'
**         quantity                = 1
*        IMPORTING
*          number                  = sg_p101-nocarga
*        EXCEPTIONS
*          interval_not_found      = 1
*          number_range_not_intern = 2
*          object_not_found        = 3
*          quantity_is_0           = 4
*          quantity_is_not_1       = 5
*          interval_overflow       = 6
*          buffer_overflow         = 7
*          OTHERS                  = 8.
*
*      IF sy-subrc NE 0.
*        PERFORM f_arma_102 USING 'No se pudo' 'determiar' 'no de carga' vg_msg4 vg_msg5
*              space space space space space.
*        CALL SCREEN '0103'.
*      ENDIF.
*
*    ENDIF.
*
*    MODIFY tg_p101 FROM sg_p101 TRANSPORTING nocarga
*     WHERE nocarga IS INITIAL.

    IF vg_oferta = abap_false.
      vg_final = abap_true.
      MODIFY zsdtt_002 FROM TABLE tg_p102.
      PERFORM f_arma_102 USING 'Se guardo' 'la información' 'temporalmente' 'No de carga'  sg_p101-nocarga
                                space space space space space.
      CALL SCREEN '0103'.
    ELSE.
*      IF vg_nocarga IS INITIAL.
*        vg_nocarga = sg_p101-nocarga.
*      ENDIF.
      PERFORM f_crear_ped.
    ENDIF.

  ENDIF.

ENDFORM.                                                    "f_vl01n
***********************************************************************
* Proyecto...: PPA Evolution                                          *
* Subrutina..: F_CALL                                                  *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 09/01/2017                                              *
* Función....: Llama trsacción                                         *
************************************************************************
FORM f_call USING x_tcode.

  CALL TRANSACTION x_tcode
  USING tg_bdc
        MODE vg_modo
        UPDATE 'S'
        MESSAGES INTO tg_msj.

ENDFORM.                    " F_CALL
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_FILL-BDC                                              *
* Función....: Fill the table BDC                                      *
* Fecha......: 06/01/2017                                              *
* Autor......: Roberto Bautista Dominguez                              *
************************************************************************
FORM f_fill_bdc USING x_begin x_name x_valor.

  DATA:
        sl_bdc TYPE bdcdata.

  IF x_begin = abap_true.
    sl_bdc-dynbegin = x_begin.
    sl_bdc-program  = x_name.
    sl_bdc-dynpro   = x_valor.
  ELSE.
    sl_bdc-fnam     = x_name.
    sl_bdc-fval     = x_valor.
  ENDIF.
  APPEND sl_bdc TO tg_bdc.

ENDFORM.                    "f_fill_bdc
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_MSJ                                                   *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 09/01/2017                                              *
* Función....: Procesa mensajes                                        *
************************************************************************
FORM f_msj USING x_tipo.

  LOOP AT tg_msj INTO sg_msj.

    CASE sg_msj-msgtyp.
      WHEN 'S'.
        PERFORM f_msg_add USING sg_msj '3'.
      WHEN 'E'.
        vg_error     = abap_true.
        PERFORM f_msg_add USING sg_msj '1'.
      WHEN OTHERS.
        PERFORM f_msg_add USING sg_msj '2'.
    ENDCASE.
    IF ( sg_msj-msgid = 'VL'
    OR   sg_msj-msgid = 'V1' )
    AND  sg_msj-msgnr = '311'.
      vg_final = abap_true.
      CLEAR vg_error.
    ELSE.
      vg_error     = abap_true.
    ENDIF.
  ENDLOOP.
  CLEAR: tg_msj[],tg_bdc.

ENDFORM.                    " F_MSJ
************************************************************************
* Proyecto...: PPA Evolution                                           *
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
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_FREE                                                  *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Añade mensaje a LOG                                     *
************************************************************************
FORM  f_msg_add USING x_msj TYPE bdcmsgcoll
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
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_CANTIDAD                                          *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene la información                                  *
************************************************************************
FORM f_get_cantidad .

  DATA:
    tl_vepo       TYPE STANDARD TABLE OF ty_vepo,
    tl_vepo_unvel TYPE STANDARD TABLE OF ty_vepo_pallet,
    tl_vepo_cant  TYPE STANDARD TABLE OF ty_vepo_pallet.

  DATA:
    sl_vepo       TYPE ty_vepo,
    sl_vepo_unvel TYPE ty_vepo_pallet,
    sl_vepo_cant  TYPE ty_vepo_pallet.

  CLEAR:tl_vepo_cant[],tl_vepo_unvel[].
  SELECT SINGLE venum exidv vhilm vhart ntgew status uevel
    INTO (sl_vepo-venum,sl_vepo-exidv,sl_vepo-vhilm,sl_vepo-vhart,sl_vepo-ntgew,
          sl_vepo-status,sl_vepo-uevel)
    FROM vekp
   WHERE exidv EQ vg_scaner.

  IF  sy-subrc EQ 0.

    IF sl_vepo-status EQ '0050'
    OR sl_vepo-status EQ '0060'.

      PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'Status' sl_vepo-status 'no permitido'
                               space space space space.
      CLEAR vg_scaner.
      SET SCREEN '0103'.
      RETURN.

    ENDIF.
    IF sl_vepo-uevel NE space.

      PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'Esta contenida' 'en UMP superior'
            space space space space space.
      CLEAR vg_scaner.
      CALL SCREEN '0103'.
      RETURN.

    ENDIF.

    CLEAR: tl_vepo_unvel[],tl_vepo_cant.
    SELECT venum unvel vemng matnr charg werks lgort
      INTO TABLE tl_vepo_unvel
      FROM vepo
     WHERE venum EQ sl_vepo-venum.

    IF tl_vepo_unvel[] IS NOT INITIAL.
      CLEAR: sg_p101,sg_p102.
      IF sl_vepo-vhart EQ 'Z003'.
        " Para los pallets se verifica a nivel vepo con unvel
        SELECT venum unvel vemng matnr charg werks lgort
          INTO TABLE tl_vepo_cant
          FROM vepo
           FOR ALL ENTRIES IN tl_vepo_unvel
         WHERE venum EQ tl_vepo_unvel-unvel.

        LOOP AT tl_vepo_unvel INTO sl_vepo_unvel.

          LOOP AT tl_vepo_cant INTO sl_vepo_cant
            WHERE venum EQ sl_vepo_unvel-unvel
              AND vemng NE 0.

            IF NOT sl_vepo_cant-lgort IN ra_lgort.
              PERFORM f_arma_102 USING 'Unidad de Manipu' vg_scaner 'con almacen' sl_vepo_cant-lgort
                                       'Debe primero' 'realizar traslado' 'a EMBA' space space space.
              CLEAR vg_scaner.
              CALL SCREEN '0103'.
              RETURN.
            ELSE.

              PERFORM f_arma_visual USING sl_vepo_cant-matnr sl_vepo_cant-vemng 0.
**              sg_p101-mandt     = sy-mandt.
*              sg_p101-nocarga   = vg_nocarga.
**              sg_p101-exidv     = sl_vepo-exidv.
*              sg_p101-matnr     = sl_vepo_cant-matnr.
*              sg_p101-lfimg     = sl_vepo_cant-vemng.
*              sg_p101-pza       = sl_vepo_cant-vemng / 100.
**              sg_p101-vrkme     = 'Kg'.
**              sg_p101-werks     = sl_vepo_cant-werks.
**              sg_p101-lgort     = sl_vepo_cant-lgort.
**              sg_p101-charg     = sl_vepo_cant-charg.
*
*              COLLECT sg_p101 INTO tg_p101.
*              CLEAR sg_p101.
              PERFORM f_arma_updt USING sl_vepo-exidv      sl_vepo_cant-matnr sl_vepo_cant-vemng
                                        sl_vepo_cant-werks sl_vepo_cant-lgort sl_vepo_cant-charg.
*              sg_p102-mandt     = sy-mandt.
*              sg_p102-nocarga   = vg_nocarga.
*              sg_p102-exidv     = sl_vepo-exidv.
*              sg_p102-matnr     = sl_vepo_cant-matnr.
*              sg_p102-lfimg     = sl_vepo_cant-vemng.
*              sg_p102-vrkme     = 'Kg'.
*              sg_p102-werks     = sl_vepo_cant-werks.
*              sg_p102-lgort     = sl_vepo_cant-lgort.
*              sg_p102-charg     = sl_vepo_cant-charg.
*
*              COLLECT sg_p102 INTO tg_p102.
*              CLEAR sg_p102.

            ENDIF.
          ENDLOOP.
        ENDLOOP.
        " Añade el el número de escaneados
        PERFORM f_add_scan.
      ELSE.

        LOOP AT tl_vepo_unvel INTO sl_vepo_unvel
            WHERE vemng NE 0.

          IF NOT sl_vepo_unvel-lgort IN ra_lgort.
            PERFORM f_arma_102 USING 'Unidad de Manipu' vg_scaner 'con almacen' sl_vepo_cant-lgort
                                     'Debe primero' 'realizar traslado' 'a EMBA' space space space.
            CLEAR vg_scaner.
            CALL SCREEN '0103'.
            RETURN.
          ELSE.

            PERFORM f_arma_visual USING sl_vepo_unvel-matnr sl_vepo_unvel-vemng 1.
**            sg_p101-mandt     = sy-mandt.
*            sg_p101-nocarga   = vg_nocarga.
**            sg_p101-exidv     = sl_vepo-exidv.
*            sg_p101-matnr     = sl_vepo_unvel-matnr.
*            sg_p101-lfimg     = sl_vepo_unvel-vemng.
*            sg_p101-pza       = sl_vepo_unvel-vemng / 100.
*            sg_p101-scaneo    = 1.
**            sg_p101-vrkme     = 'Kg'.
**            sg_p101-werks     = sl_vepo_unvel-werks.
**            sg_p101-lgort     = sl_vepo_unvel-lgort.
**            sg_p101-charg     = sl_vepo_unvel-charg.
*
*            COLLECT sg_p101 INTO tg_p101.
*            CLEAR sg_p101.
            PERFORM f_arma_updt USING sl_vepo-exidv       sl_vepo_unvel-matnr sl_vepo_unvel-vemng
                                      sl_vepo_unvel-werks sl_vepo_unvel-lgort sl_vepo_unvel-charg.

*            sg_p102-mandt     = sy-mandt.
*            sg_p102-nocarga   = vg_nocarga.
*            sg_p102-exidv     = sl_vepo-exidv.
*            sg_p102-matnr     = sl_vepo_unvel-matnr.
*            sg_p102-lfimg     = sl_vepo_unvel-vemng.
*            sg_p102-vrkme     = 'Kg'.
*            sg_p102-werks     = sl_vepo_unvel-werks.
*            sg_p102-lgort     = sl_vepo_unvel-lgort.
*            sg_p102-charg     = sl_vepo_unvel-charg.
*
*            COLLECT sg_p102 INTO tg_p102.
*            CLEAR sg_p102.

          ENDIF.

        ENDLOOP.
*        IF sy-subrc EQ 0.
*          PERFORM f_add_scan.
*        ENDIF.

      ENDIF.

    ENDIF.

*    LOOP AT tl_vepo_unvel INTO sl_vepo_unvel.
*
*      LOOP AT tl_vepo_cant INTO sl_vepo_cant
*        WHERE venum EQ sl_vepo_unvel-unvel
*          AND vemng NE 0.
*
*        sg_p101-mandt     = sy-mandt.
*        sg_p101-nocarga   = vg_nocarga.
*        sg_p101-exidv     = sl_vepo-exidv.
*        sg_p101-matnr     = sl_vepo_cant-matnr.
*        sg_p101-lfimg     = sl_vepo_cant-vemng.
*        sg_p101-vrkme     = 'Kg'.
*        sg_p101-werks     = sl_vepo_cant-werks.
*        sg_p101-lgort     = sl_vepo_cant-lgort.
*        sg_p101-charg     = sl_vepo_cant-charg.
*
*        COLLECT sg_p101 INTO tg_p101.
*        CLEAR sg_p101.
*
*      ENDLOOP.
*      IF sy-subrc NE 0.
*
*        IF sl_vepo_unvel-vemng NE 0.
*
*          sg_p101-exidv     = sl_vepo-exidv.
*          sg_p101-matnr     = sl_vepo_unvel-matnr.
*          sg_p101-lfimg     = sl_vepo_unvel-vemng.
*          sg_p101-vrkme     = 'Kg'.
*          sg_p101-werks     = sl_vepo_unvel-werks.
*          sg_p101-lgort     = sl_vepo_unvel-lgort.
*          sg_p101-charg     = sl_vepo_unvel-charg.
*
*          COLLECT sg_p101 INTO tg_p101.
*          CLEAR sg_p101.
*
*        ENDIF.
*
*      ENDIF.
*
*    ENDLOOP.

*    IF sy-subrc NE 0.
*
*      PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'No existe' vg_msg5
*            space space space space space.
*      CLEAR vg_scaner.
*      CALL SCREEN '0103'.
*      RETURN.
*
*    ENDIF.

  ELSE.

    PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'No existe' vg_msg5
          space space space space space.
    CLEAR vg_scaner.
    CALL SCREEN '0103'.

  ENDIF.

  CLEAR vg_scaner.

ENDFORM.                    " F_GET_CANTIDAD
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_ARMA_102                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Arma mensaje                                            *
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
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_SCANER_REPETIDO                                       *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Verifica si hay repetidas                               *
************************************************************************
FORM f_scaner_repetido.

  SELECT SINGLE exidv INTO vg_scaner
    FROM zsdtt_002
   WHERE exidv   EQ vg_scaner.

*   WHERE nocarga EQ vg_nocarga
*     AND fecha   EQ vg_fecha
*     AND exidv   EQ vg_scaner
*     AND vbeln   EQ space.

  IF sy-subrc NE 0.
    READ TABLE tg_p102 INTO sg_p102
      WITH KEY exidv = vg_scaner.
  ENDIF.

ENDFORM.                    " F_SCANER_REPETIDO
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_SCANER_REPETIDO                                       *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Verifica si hay repetidas                               *
************************************************************************
FORM f_scaner_repetido2.

  SELECT SINGLE exidv INTO vg_scaner
    FROM zsdtt_002
   WHERE nocarga EQ vg_nocarga
     AND fecha   EQ vg_fecha
     AND exidv   EQ vg_scaner.
*     AND vbeln   EQ space.

  IF sy-subrc NE 0.
    READ TABLE tg_p102 INTO sg_p102
      WITH KEY exidv = vg_scaner.
  ENDIF.

ENDFORM.                    " F_SCANER_REPETIDO
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_CREAR_PED                                             *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Crea el pedido                                          *
************************************************************************
FORM f_crear_ped.
  DATA:
    vl_test  TYPE bapiflag-bapiflag VALUE ' ',
    vl_item  TYPE posnr_va,
    vl_indx  TYPE sy-index.

  DATA:
    sl_head  TYPE bapisdhd1,
    sl_headx TYPE bapisdhd1x,
    sl_part  TYPE bapiparnr,
    sl_ret   TYPE bapiret2,
    sl_item  TYPE bapisditm,
    sl_itemx TYPE bapisditmx,
    sl_sche  TYPE bapischdl,
    sl_schex TYPE bapischdlx.

  DATA:
    tl_ret   TYPE STANDARD TABLE OF bapiret2,
    tl_item  TYPE STANDARD TABLE OF bapisditm,
    tl_sche  TYPE STANDARD TABLE OF bapischdl,
    tl_schex TYPE STANDARD TABLE OF bapischdlx,
    tl_itemx TYPE STANDARD TABLE OF bapisditmx,
    tl_part  TYPE STANDARD TABLE OF bapiparnr.

  vg_log-extnumber = 'Proceso Ped Auto'.                    "#EC NOTEXT
  vg_log-aluser    = sy-uname.
  vg_log-alprog    = sy-repid.
  vg_log-object    = 'ZHANDHELD'.
  vg_log-subobject = 'ZPED_AUTO'.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log      = vg_log
    IMPORTING
      e_log_handle = vg_handler
    EXCEPTIONS
      OTHERS       = 1.

  sg_msj-msgtyp = 'S'.
  sg_msj-msgid  = '00'.
  sg_msj-msgnr  = '368'.
  sg_msj-msgv1  = 'Inicio de proceso carga' .
  sg_msj-msgv2  = vg_nocarga.
  PERFORM f_msg_add USING sg_msj '3'.

*  " Movimiento de mercancías
*  PERFORM f_goods_mov.

*  IF vg_error = abap_false.

  sl_head-doc_type   = 'ZAUT'.
  sl_head-sales_org  = '0013'.
  sl_head-distr_chan = '01'.

  CONCATENATE 'PedAuto' vg_nocarga INTO sl_head-purch_no_c SEPARATED BY space.

  sl_headx-doc_type  = sl_headx-sales_org  = sl_headx-distr_chan = sl_headx-division = sl_headx-purch_no_c = abap_true.

  sl_part-partn_role = 'TR'.
  sl_part-partn_numb = 'CATM'.
  APPEND sl_part TO tl_part.

  sl_part-partn_role = 'RE'.
  sl_part-partn_numb = 'CATM'.
  APPEND sl_part TO tl_part.

  sl_part-partn_role = 'WE'.
  sl_part-partn_numb = 'CATM'.
  APPEND sl_part TO tl_part.

  LOOP AT tg_p102 INTO sg_p102.

    IF sl_head-division IS INITIAL.
      SELECT SINGLE spart INTO sl_head-division
        FROM mara
       WHERE matnr = sg_p102-matnr.
    ENDIF.

    sl_item-material   = sg_p102-matnr.
    sl_item-plant      = sg_p102-werks.
    sl_item-store_loc  = sg_p102-lgort.
    sl_item-target_qty = sg_p102-lfimg.

    COLLECT sl_item INTO tl_item.
    CLEAR sl_item.

  ENDLOOP.

*   Asinga el número de posición
  CLEAR vl_item.
  LOOP AT tl_item INTO sl_item.
    vl_item = vl_item + 10.
    sl_item-itm_number = sl_itemx-itm_number = sl_sche-itm_number  = sl_schex-itm_number = vl_item.
    MODIFY tl_item FROM sl_item.

    sl_itemx-material = sl_itemx-plant = sl_itemx-plant = sl_itemx-store_loc = sl_itemx-target_qty = abap_true.
    COLLECT sl_itemx INTO tl_itemx.

    sl_sche-req_qty     = sl_item-target_qty.
    COLLECT sl_sche INTO tl_sche.
    sl_schex-req_qty    = abap_true.
    COLLECT sl_schex INTO tl_schex.

    CLEAR: sl_itemx,sl_item,sl_sche,sl_schex.

  ENDLOOP.

  CALL FUNCTION 'BAPI_QUOTATION_CREATEFROMDATA2'
    EXPORTING
      quotation_header_in     = sl_head
      quotation_header_inx    = sl_headx
      testrun                 = vl_test
    IMPORTING
      salesdocument           = vg_vbeln
    TABLES
      return                  = tl_ret
      quotation_items_in      = tl_item
      quotation_items_inx     = tl_itemx
      quotation_partners      = tl_part
      quotation_schedules_in  = tl_sche
      quotation_schedules_inx = tl_schex.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

  IF vg_vbeln IS NOT INITIAL.

    sg_p102-vbeln = vg_vbeln.
    MODIFY tg_p102 FROM sg_p102 TRANSPORTING vbeln
     WHERE vbeln IS INITIAL.

*    MODIFY ZSDTT_002 FROM TABLE tg_p101.

  ENDIF.

  LOOP AT tl_ret INTO sl_ret.

    sg_msj-msgtyp = sl_ret-type.
    sg_msj-msgid  = sl_ret-id.
    sg_msj-msgnr  = sl_ret-number.
    sg_msj-msgv1  = sl_ret-message_v1.
    sg_msj-msgv2  = sl_ret-message_v2.
    sg_msj-msgv3  = sl_ret-message_v3.
    sg_msj-msgv4  = sl_ret-message_v3.

    CASE sl_ret-type.
      WHEN 'S'.
        PERFORM f_msg_add USING sg_msj '3'.
      WHEN 'E'.
        vg_error     = abap_true.
        PERFORM f_msg_add USING sg_msj '1'.
      WHEN OTHERS.
        PERFORM f_msg_add USING sg_msj '2'.
    ENDCASE.

  ENDLOOP.

  IF  vg_error = space
  AND vg_vbeln NE space.

    PERFORM f_free USING vg_vbeln.
    " Movimiento de mercancías
*    PERFORM f_goods_mov.

  ENDIF.

*  ENDIF.
  MODIFY zsdtt_002 FROM TABLE tg_p102.
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

  IF vg_error IS INITIAL.

    PERFORM f_arma_102 USING 'Pedido:' vg_vbeln 'generado correctamente' space space
                              space space space space space.

*    MODIFY zsdtt_002 FROM TABLE tg_p102.
    vg_final = abap_true.

  ELSE.

    vg_msg3 = 'Detalles SLG1 en SAP'.
    CONCATENATE 'Objeto' vg_log-object    INTO vg_msg4 SEPARATED BY space.
    CONCATENATE 'ObjInf' vg_log-subobject INTO vg_msg5 SEPARATED BY space.

    PERFORM f_arma_102 USING '' 'Proceso erróneo' vg_msg3 vg_msg4 vg_msg5
          space space space space space.

    vg_final = abap_false.

  ENDIF.

  CALL SCREEN '0103'.

ENDFORM.                    "f_crear_ped
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GOODS_MOV                                             *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Llama a la BAPI para bloquear los datos                 *
************************************************************************
FORM f_goods_mov.
  DATA:
    tl_data_move_to TYPE hum_data_move_to_t,
    tl_external     TYPE hum_exidv_t,
    tl_msg          TYPE huitem_messages_t.

  DATA:
    sl_data_move_to TYPE hum_data_move_to,
    sl_external     TYPE hum_exidv,
    sl_msg          TYPE huitem_messages.

  DATA:
    vl_mblnr TYPE rm07m-mblnr.

  sg_msj-msgtyp = 'S'.
  sg_msj-msgid  = '00'.
  sg_msj-msgnr  = '368'.
  sg_msj-msgv1  = 'Inicio proceso'.
  sg_msj-msgv2  = 'HU_CREATE_GOODS_MOVEMENT'.
  PERFORM f_msg_add USING sg_msj '3'.

  LOOP AT tg_p101 INTO sg_p101.

    sl_data_move_to-werks = sg_p101-werks.
    sl_data_move_to-lgort = sg_p101-lgort.

    APPEND sl_data_move_to TO tl_data_move_to.
    CLEAR sl_data_move_to.

    sl_external-exidv = sg_p101-exidv.
    APPEND sl_external TO tl_external.
    CLEAR sl_external.

  ENDLOOP.

  SORT:
    tl_data_move_to BY werks lgort,
    tl_external     BY exidv.

  DELETE ADJACENT DUPLICATES FROM tl_data_move_to COMPARING werks lgort.
  DELETE ADJACENT DUPLICATES FROM tl_external     COMPARING exidv.

  CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
    EXPORTING
      if_event       = '0005'
      if_commit      = 'X'
      if_tcode       = 'VLMOVE'
      it_move_to     = tl_data_move_to
      it_external_id = tl_external
    IMPORTING
      es_message     = sl_msg
      et_messages    = tl_msg.

  LOOP AT tl_msg INTO sl_msg.

    sg_msj-msgtyp = sl_msg-msgty.
    sg_msj-msgid  = sl_msg-msgid.
    sg_msj-msgnr  = sl_msg-msgno.
    sg_msj-msgv1  = sl_msg-msgv1.
    sg_msj-msgv2  = sl_msg-msgv2.
    sg_msj-msgv3  = sl_msg-msgv3.
    sg_msj-msgv4  = sl_msg-msgv4.

    CASE sl_msg-msgty.
      WHEN 'S'.
        PERFORM f_msg_add USING sg_msj '3'.
        IF  sl_msg-msgno = '309'
        AND sl_msg-msgid = 'HUGENERAL'.
          vl_mblnr = sg_msj-msgv1.
        ENDIF.
      WHEN 'E'.
        vg_error     = abap_true.
        PERFORM f_msg_add USING sg_msj '1'.
      WHEN OTHERS.
        PERFORM f_msg_add USING sg_msj '2'.
    ENDCASE.

  ENDLOOP.

  IF sy-subrc NE 0.
    vg_error     = abap_true.
    sg_msj-msgtyp = 'E'.
    sg_msj-msgid  = '00'.
    sg_msj-msgnr  = '368'.
    sg_msj-msgv1  = 'No se pudo determinar'.
    sg_msj-msgv2  = 'error'.
    PERFORM f_msg_add USING sg_msj '3'.
    RETURN.
  ENDIF.

  IF vl_mblnr IS NOT INITIAL.
    sg_p101-mblnr = vl_mblnr.
    MODIFY tg_p101 FROM sg_p101 TRANSPORTING mblnr
     WHERE mblnr IS INITIAL.
  ENDIF.

ENDFORM.                    " F_GOODS_MOV
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_ALMACEN                                               *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 04/12/2017                                              *
* Función....: Llena la tabla de los almancenes permitidos             *
************************************************************************
FORM f_almacen.

  DATA:
    tl_tvarvc TYPE STANDARD TABLE OF tvarvc,
    sl_tvarvc TYPE tvarvc,
    sl_lgort  LIKE LINE OF ra_lgort.

  IF ra_lgort[] IS INITIAL.

    SELECT * INTO TABLE tl_tvarvc
      FROM tvarvc
     WHERE name EQ 'HH_LGORT'.

    LOOP AT tl_tvarvc INTO sl_tvarvc.

      sl_lgort-sign   = sl_tvarvc-sign.
      sl_lgort-option = sl_tvarvc-opti.
      sl_lgort-low    = sl_tvarvc-low.
      APPEND sl_lgort TO ra_lgort.
      CLEAR sl_lgort.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_ALMACEN
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_LEE_DATOS                                             *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 04/12/2017                                              *
* Función....: Lee los datos de la tabla Z                             *
************************************************************************
FORM f_lee_datos USING x_fecha.

  SELECT * INTO TABLE tg_p101
    FROM zsdtt_002
   WHERE nocarga EQ vg_nocarga
     AND fecha   EQ x_fecha
     AND vbeln   EQ space.

ENDFORM.                    " F_LEE_DATOS
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_ADD_SCAN                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 04/12/2017                                              *
* Función....: Anade el número de escaneadas                           *
************************************************************************
FORM f_add_scan .

  READ TABLE tg_p102 INTO sg_p102 WITH KEY exidv = vg_scaner.
  IF sy-subrc EQ 0.
    LOOP AT tg_p101 INTO sg_p101
      WHERE matnr EQ sg_p102-matnr.

      CLEAR: sg_p101-lfimg,sg_p101-pza.
      sg_p101-scaneo = 1.
      COLLECT sg_p101 INTO tg_p101.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_ADD_SCAN
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_ARMA_VISUAL                                           *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 04/12/2017                                              *
* Función....: Anade resgitros para visualizar                         *
************************************************************************
FORM f_arma_visual USING x_matnr x_lfimg x_scaneos.

  sg_p101-nocarga   = vg_nocarga.
  sg_p101-matnr     = x_matnr.
  sg_p101-lfimg     = x_lfimg.
  sg_p101-pza       = x_lfimg / 100.
  sg_p101-scaneo    = x_scaneos.

  COLLECT sg_p101 INTO tg_p101.
  CLEAR sg_p101.

ENDFORM.                    " F_ARMA_VISUAL
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_ARMA_UPDT                                             *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 04/12/2017                                              *
* Función....: Anade resgitros para actualizar la tabla Z              *
************************************************************************
FORM f_arma_updt USING x_exidv x_matnr x_vemng x_werks x_lgort x_charg.

  sg_p102-mandt     = sy-mandt.
  sg_p102-nocarga   = vg_nocarga.
  sg_p102-fecha     = vg_fecha.
  sg_p102-exidv     = x_exidv.
  sg_p102-matnr     = x_matnr.
  sg_p102-lfimg     = x_vemng.
  sg_p102-vrkme     = 'Kg'.
  sg_p102-werks     = x_werks.
  sg_p102-lgort     = x_lgort.
  sg_p102-charg     = x_charg.

  COLLECT sg_p102 INTO tg_p102.
  CLEAR sg_p102.

ENDFORM.                    " F_ARMA_UPDT
