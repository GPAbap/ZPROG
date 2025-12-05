************************************************************************
* Programa             : SAPMZSATRA                                     *
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
* Proyecto...: PPA Evolution                                          *
* Rutina.....: F_PROCESO                                              *
* Descripción: Inicia proceso                                         *
* Fecha......: 06/01/2017                                             *
* Autor......: Roberto Bautista Dominguez                             *
***********************************************************************
FORM f_update.

  vg_log-extnumber = 'Proceso picking'.                     "#EC NOTEXT
  vg_log-aluser    = sy-uname.
  vg_log-alprog    = sy-repid.
  vg_log-object    = 'ZHANDHELD'.
  vg_log-subobject = 'ZPICKING'.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log      = vg_log
    IMPORTING
      e_log_handle = vg_handler
    EXCEPTIONS
      OTHERS       = 1.

  DATA:
    sl_likp TYPE ty_likp.

*  MODIFY zhuinv_item FROM TABLE tg_item.

  CLEAR: tg_msj[],vg_lfart.
  READ TABLE tg_likp INTO sl_likp
   WITH KEY vbeln = sg_p101-vbeln.

  IF sl_likp-lfart = 'ZNL' OR sl_likp-lfart = 'NL'.
*    vg_lfart = abap_true.
*    PERFORM f_mod_po.
  ELSE.
    PERFORM f_modifica_ped.
  ENDIF.

  IF vg_error IS INITIAL.
    IF sy-tcode = 'ZSDTR_0003'.
      PERFORM f_entrega_dev.
    ELSE.
      PERFORM f_entrega.
    ENDIF.
  ENDIF.

  IF sl_likp-lfart = 'ZNL' OR sl_likp-lfart = 'NL'.
    vg_lfart = abap_true.
    PERFORM f_mod_po.
  ENDIF.

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

  vg_msg3 = 'Detalles SLG1 en SAP'.
  CONCATENATE 'Objeto' vg_log-object    INTO vg_msg4 SEPARATED BY space.
  CONCATENATE 'ObjInf' vg_log-subobject INTO vg_msg5 SEPARATED BY space.

  IF vg_error IS INITIAL.
    PERFORM f_arma_102 USING '' 'Proceso exitoso' vg_msg3 vg_msg4 vg_msg5
          space space space space space.
    vg_final = abap_true.
    DELETE tg_vbs WHERE vbeln = vg_vbln_ok.
*   DELETE zhuinv_item FROM TABLE tg_item.
    CLEAR: tg_item[],tg_p101[].
    CLEAR: vg_vbln_ok, vg_vbeln.

  ELSE.

    PERFORM f_arma_102 USING '' 'Proceso erróneo' vg_msg3 vg_msg4 vg_msg5
          space space space space space.

    vg_final = abap_false.
  ENDIF.

  CLEAR vg_scaner.
  CALL SCREEN '0103'.

ENDFORM.                                                    "f_vl01n
***********************************************************************
* Proyecto...: PPA Evolution                                          *
* Subrutina..: F_CALL                                                  *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 09/01/2017                                              *
* Función....: Llama trsacción                                         *
************************************************************************
FORM f_call USING x_tcode.
  DATA:
        sl_tvarvc TYPE tvarvc.

  SELECT SINGLE * INTO sl_tvarvc
  FROM tvarvc
  WHERE name EQ sy-uname
  AND low  EQ x_tcode.

  IF sy-subrc EQ 0.
    vg_modo = 'A'.
  ENDIF.
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
        vg_final = abap_true.
        CLEAR vg_error.
      WHEN 'E'.
        vg_error     = abap_true.
        PERFORM f_msg_add USING sg_msj '1'.
        vg_error     = abap_true.
      WHEN OTHERS.
        PERFORM f_msg_add USING sg_msj '2'.
    ENDCASE.
*    IF ( sg_msj-msgid = 'VL'
*    OR   sg_msj-msgid = 'V1' )
*    AND  sg_msj-msgnr = '311'.
*      vg_final = abap_true.
*      CLEAR vg_error.
*    ELSE.
*      vg_error     = abap_true.
*    ENDIF.
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
* Subrutina..: F_GET_INFO                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Añade mensaje a LOG                                     *
************************************************************************
FORM f_get_mayor.

  DATA:
    sl_likp TYPE ty_likp.

  PERFORM f_get_vbuk USING space.

  IF tg_vbuk[] IS NOT INITIAL.

    CLEAR vg_contab.
    PERFORM f_fill_vstel.
    PERFORM f_get_likp USING space.

    IF tg_likp IS NOT INITIAL.

      PERFORM f_get_lips.

      IF tg_lips[] IS NOT INITIAL.
        PERFORM f_get_vbak USING 'EQ'.
      ENDIF.

    ENDIF.

    LOOP AT tg_likp INTO sl_likp.

      READ TABLE tg_lips INTO sg_lips
        WITH KEY vbeln = sl_likp-vbeln.

      IF sy-subrc = 0.

        READ TABLE tg_vbak WITH KEY vbeln = sg_lips-vgbel
                       TRANSPORTING NO FIELDS.

        IF sy-subrc = 0.
          MOVE:
            sl_likp-vbeln TO sg_vbs-vbeln,
            sl_likp-name1 TO sg_vbs-name1.
          APPEND sg_vbs TO tg_vbs.
        ELSE.
          DELETE tg_likp.
        ENDIF.
      ELSE.
        DELETE tg_likp.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_GET_MAYOR
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_INFO                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Añade mensaje a LOG                                     *
************************************************************************
FORM f_get_info.

  DATA:
    sl_likp TYPE ty_likp.

  CLEAR vg_contab.
  PERFORM f_fill_vstel.
  PERFORM f_get_likp USING abap_true.

  IF tg_likp IS NOT INITIAL.

    PERFORM f_get_vbuk USING 'O'.

    IF tg_vbuk[] IS NOT INITIAL.

      PERFORM f_get_lips.

      IF tg_lips[] IS NOT INITIAL.
        PERFORM f_get_vbak USING 'NE'.
      ENDIF.

    ENDIF.

*   Busca las entregas a partir de un grupo
    SELECT vbeln INTO CORRESPONDING FIELDS OF TABLE tg_vbss
      FROM vbss
       FOR ALL ENTRIES IN tg_likp
     WHERE vbeln EQ tg_likp-vbeln.

  ENDIF.

  LOOP AT tg_likp INTO sl_likp.

    READ TABLE tg_vbuk WITH KEY vbeln = sl_likp-vbeln
                   TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

      READ TABLE tg_vbss WITH KEY vbeln = sl_likp-vbeln
                     TRANSPORTING NO FIELDS.

      IF sy-subrc NE 0.

        READ TABLE tg_lips INTO sg_lips
          WITH KEY vbeln = sl_likp-vbeln.

        IF sy-subrc = 0.

          IF sl_likp-lfart NE 'NL'.
            READ TABLE tg_vbak WITH KEY vbeln = sg_lips-vgbel
                           TRANSPORTING NO FIELDS.

            IF sy-subrc EQ 0.
              MOVE: sl_likp-vbeln TO sg_vbs-vbeln,
                    sl_likp-name1 TO sg_vbs-name1.
              APPEND sg_vbs TO tg_vbs.
            ELSE.
              DELETE tg_likp.  " Si es canal 01 se borra
            ENDIF.
          ELSE.
            MOVE: sl_likp-vbeln TO sg_vbs-vbeln,
            sl_likp-name1 TO sg_vbs-name1.
            APPEND sg_vbs TO tg_vbs.

          ENDIF.
        ELSE.
          DELETE tg_likp.  " Si es canal 01 se borra
        ENDIF.
      ELSE.
        DELETE tg_likp.      " Si esta en un grupo se borrar
      ENDIF.
    ELSE.
      DELETE tg_likp.        " Si no tiene estatus A o B se borra
    ENDIF.

  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM tg_vbs COMPARING ALL FIELDS.

ENDFORM.                    " F_GET_INFO
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_INFO                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Añade mensaje a LOG                                     *
************************************************************************
FORM f_get_dev.

  DATA:
    sl_likp TYPE ty_likp.

  CLEAR vg_contab.
  PERFORM f_fill_vstel.

  " Seleccionamos las entregas por su fecha y pto de exp
  PERFORM f_get_likp USING vg_datum.
  DELETE tg_likp WHERE lfart  NE 'LR'.

  IF tg_likp IS NOT INITIAL.

    PERFORM f_get_vbuk USING 'D'.
    IF tg_vbuk[] IS NOT INITIAL.
      PERFORM f_get_lips.
    ENDIF.

  ENDIF.

  LOOP AT tg_likp INTO sl_likp.

    READ TABLE tg_lips INTO sg_lips
      WITH KEY vbeln = sl_likp-vbeln.

    IF sy-subrc = 0.

      READ TABLE tg_vbuk WITH KEY vbeln = sl_likp-vbeln
                     TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        MOVE:
          sl_likp-vbeln TO sg_vbs-vbeln,
          sl_likp-name1 TO sg_vbs-name1.
        APPEND sg_vbs TO tg_vbs.
      ELSE.
        DELETE tg_likp.
      ENDIF.
    ELSE.
      DELETE tg_likp.
    ENDIF.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM tg_vbs COMPARING ALL FIELDS.
  IF tg_vbs[] IS NOT INITIAL.
    " Seleeciona las entregas RELACIONADAS  al devolución
    SELECT vbelv posnv vbeln posnn
    FROM vbfa
    INTO TABLE tg_vbfa
    FOR ALL ENTRIES IN tg_vbs
    WHERE vbeln   = tg_vbs-vbeln
    AND vbtyp_n = 'T'
    AND vbtyp_v = 'J'.

  ENDIF.

ENDFORM.                    " F_GET_DEV
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_CANTIDAD                                          *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene la información                                  *
************************************************************************
FORM f_get_cantidad .
  DATA:
    vl_palet TYPE c LENGTH 7,
    vl_lote  TYPE c LENGTH 10,
    vl_matnr TYPE c LENGTH 18,
    vl_lfimg TYPE c LENGTH 6,
    vl_pikmg TYPE lipsd-pikmg,
    vl_pikm2 TYPE lipsd-pikmg,
    vl_longi TYPE i.

  DATA:
    tl_vepo       TYPE STANDARD TABLE OF ty_vepo,
    tl_vepo_unvel TYPE STANDARD TABLE OF ty_vepo_pallet,
    tl_vepo_cant  TYPE STANDARD TABLE OF ty_vepo_pallet,
    tl_vepo_tapa  TYPE STANDARD TABLE OF ty_vepo_pallet.

  DATA:
    sl_vepo       TYPE ty_vepo,
    sl_vepo_unvel TYPE ty_vepo_pallet,
    sl_vepo_cant  TYPE ty_vepo_pallet,
    sl_vepo_tapa  TYPE ty_vepo_pallet.

  DATA:
    vl_scaner TYPE c LENGTH 20.

  CLEAR:tl_vepo_tapa[],tl_vepo_cant[],tl_vepo_unvel[].
  SELECT SINGLE venum exidv vhilm vhart ntgew status uevel
    INTO (sl_vepo-venum,sl_vepo-exidv,sl_vepo-vhilm,sl_vepo-vhart,sl_vepo-ntgew,
          sl_vepo-status,sl_vepo-uevel)
    FROM vekp
   WHERE exidv EQ vg_scaner.
  DATA: vl_lgort TYPE vepo-lgort.

  SELECT SINGLE lgort
    INTO vl_lgort
    FROM vepo
    WHERE venum EQ sl_vepo-venum AND
          lgort NE ''.


  IF ( ( sl_vepo-status  EQ '0050'
  OR     sl_vepo-status  EQ '0060' )
  AND    sy-tcode        EQ 'ZSDTR_0001' )
  OR   ( sl_vepo-status  EQ '0060'
  AND    sy-tcode        EQ 'ZSDTR_0003' )
  OR vl_lgort NE 'EMBA'.

    IF NOT vl_lgort IS INITIAL .

      PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'Status' sl_vepo-status 'no permitido'
                               space space space space.
      CLEAR vg_scaner.
      CALL SCREEN '0103'.
      RETURN.
    ENDIF.
  ENDIF.

  IF sl_vepo-uevel NE space.

    PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'Esta contenida' 'en UMP superior'
          space space space space space.
    CLEAR vg_scaner.
    CALL SCREEN '0103'.
    RETURN.

  ENDIF.

  " Se busca la entrega para la devolución
  IF sy-tcode = 'ZSDTR_0003'.

    IF sl_vepo-vhart = 'Z001'     " Canastilla
    OR sl_vepo-vhart EQ 'Z004'.    " Caja de carton
      SELECT SINGLE vbeln
      INTO sl_vepo-vbeln
      FROM vepo
      WHERE venum EQ sl_vepo-venum
      AND vbeln NE space.

    ELSE.

      SELECT SINGLE unvel matnr vemng charg
      INTO (sl_vepo-unvel,sl_vepo-matnr,sl_vepo-vemng,sl_vepo-charg)
      FROM vepo
      WHERE venum = sl_vepo-venum.

      SELECT SINGLE vbeln
      INTO sl_vepo-vbeln
      FROM vepo
      WHERE venum EQ sl_vepo-unvel
      AND vbeln NE space.


    ENDIF.

    READ TABLE tg_vbfa TRANSPORTING NO FIELDS
    WITH KEY vbelv = sl_vepo-vbeln
    vbeln = sg_p101-vbeln.

    IF sy-subrc NE 0.
      PERFORM f_arma_102 USING 'UnManipu' vg_scaner 'No tiene relación' 'con devolución'
            space space space space space space.
      CLEAR vg_scaner.
      CALL SCREEN '0103'.
      RETURN.

      RETURN.
    ENDIF.
  ENDIF.

  SELECT SINGLE matnr
    INTO sl_vepo-matnr1
    FROM vepo
   WHERE venum EQ sl_vepo-venum
     AND vbeln = space.

  SELECT SINGLE unvel matnr vemng charg
    INTO (sl_vepo-unvel,sl_vepo-matnr,sl_vepo-vemng,sl_vepo-charg)
    FROM vepo
   WHERE venum = sl_vepo-venum.

  " No es el último nivel
  IF  sy-subrc = 0
  AND sl_vepo-unvel NE space.

    SELECT SINGLE venum exidv vhilm
      INTO (sl_vepo-venum2,sl_vepo-exidv2,sl_vepo-vhilm2)
      FROM vekp
     WHERE venum = sl_vepo-unvel.

    IF sy-subrc = 0.

      SELECT SINGLE unvel matnr vemng
        INTO (sl_vepo-unvel,sl_vepo-matnr,sl_vepo-vemng)
        FROM vepo
        WHERE venum = sl_vepo-venum2.

      IF sy-subrc NE 0.

        PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'No existe' vg_msg5
              space space space space space.
        CLEAR vg_scaner.
        CALL SCREEN '0103'.
        RETURN.

      ENDIF.

    ENDIF.

  ELSEIF  sy-subrc NE 0.

    PERFORM f_arma_102 USING '' 'Unidad de Manipu' vg_scaner 'No existe' vg_msg5
          space space space space space.
    CLEAR vg_scaner.
    CALL SCREEN '0103'.
    RETURN.

  ENDIF.

  CLEAR vl_pikmg.
  CLEAR: tl_vepo_unvel[],tl_vepo_cant.
  SELECT venum unvel vemng matnr charg werks lgort
    INTO TABLE tl_vepo_unvel
    FROM vepo
   WHERE venum = sl_vepo-venum.

  IF tl_vepo_unvel[] IS NOT INITIAL.

    SELECT venum unvel vemng matnr charg werks lgort
      INTO TABLE tl_vepo_cant
      FROM vepo
       FOR ALL ENTRIES IN tl_vepo_unvel
     WHERE venum = tl_vepo_unvel-unvel.

    IF sy-subrc = 0.
      tl_vepo_tapa[] =  tl_vepo_cant[].
    ELSEIF sl_vepo-vhart EQ 'Z001'     " Canastilla
        OR sl_vepo-vhart EQ 'Z005'.    " Caja de carton
      tl_vepo_tapa[] =  tl_vepo_cant[] = tl_vepo_unvel[].
      CLEAR tl_vepo_unvel[].
      sl_vepo_unvel-venum = sl_vepo-venum.
      sl_vepo_unvel-unvel = sl_vepo-venum.
      sl_vepo_unvel-vemng = 1.
      sl_vepo_unvel-matnr = sl_vepo-vhilm.
      APPEND sl_vepo_unvel TO tl_vepo_unvel.
      CLEAR sl_vepo_unvel .
    ELSEIF sl_vepo-vhart EQ 'Z002'.     " Carro transportador
      PERFORM f_arma_102 USING 'Unidad de Manipu' vg_scaner 'carro transportador' 'No permitido'
            space space space space space space.
      CLEAR vg_scaner.
      CALL SCREEN '0103'.
      RETURN.
    ENDIF.
    DELETE tl_vepo_cant WHERE charg IS INITIAL.
    DELETE tl_vepo_tapa WHERE charg IS NOT INITIAL.

    LOOP AT tl_vepo_cant INTO sl_vepo_cant
    WHERE NOT lgort IN ra_lgort.

      PERFORM f_arma_102 USING 'Unidad de Manipu' vg_scaner 'con almacen' sl_vepo_cant-lgort
            'Debe primero' 'realizar traslado' 'a EMBA' space space space.
      CLEAR vg_scaner.
      CALL SCREEN '0103'.
      RETURN.

    ENDLOOP.
  ENDIF.

  LOOP AT tl_vepo_unvel INTO sl_vepo_unvel.

    LOOP AT tl_vepo_cant INTO sl_vepo_cant
      WHERE venum EQ sl_vepo_unvel-unvel.

      vl_pikmg = sl_vepo_cant-vemng.
      LOOP AT tg_p101 INTO sg_p101
      WHERE matnr EQ sl_vepo_cant-matnr.

        vl_pikm2          = vl_pikmg.
        vl_pikmg          = vl_pikmg + sg_p101-pikmg.
        sg_p101-pikmg     = vl_pikmg.
        sg_p101-csurt     = sg_p101-csurt + 1.
        MODIFY tg_p101 FROM sg_p101.

        READ TABLE tl_vepo_tapa INTO sl_vepo_tapa
          WITH KEY venum = sl_vepo_unvel-unvel.

*        IF sy-subrc = 0.
        CLEAR sg_item.
        sg_item-mandt     = sy-mandt.
        sg_item-vbeln     = sg_p101-vbeln.
        sg_item-posnr     = sg_p101-posnr.
        sg_item-exidv     = sl_vepo-exidv.
        sg_item-matnr01   = sl_vepo_cant-matnr.  " Material de la entrega
        sg_item-matnr02   = sl_vepo_unvel-matnr. " Canastilla
        sg_item-matnr03   = sl_vepo_tapa-matnr.  " Tapa de canastilla
        sg_item-lfimg01   = sl_vepo_cant-vemng.
        sg_item-charg     = sl_vepo_cant-charg.
        sg_item-lfimg02   = 1.

        COLLECT sg_item INTO tg_item.
        CLEAR sg_item.
*        ENDIF.

      ENDLOOP.
      IF sy-subrc NE 0.
        PERFORM f_arma_102 USING 'Unidad de Manipu' vg_scaner 'no contiene' 'el material'
              sl_vepo_cant-matnr 'para esta entrega' space space space space.
        CLEAR vg_scaner.
        CALL SCREEN '0103'.
        RETURN.

      ENDIF.

    ENDLOOP.

  ENDLOOP.

  IF sy-subrc NE 0.

    PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'No existe' vg_msg5
          space space space space space.
    CLEAR vg_scaner.
    CALL SCREEN '0103'.
    RETURN.

  ENDIF.

  CLEAR vg_scaner.

ENDFORM.                    " F_GET_CANTIDAD
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_ANULA_CANTIDAD                                        *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene la información para anular cantidad             *
************************************************************************
FORM f_anula_cantidad.
  DATA:
    vl_palet TYPE c LENGTH 7,
    vl_lote  TYPE c LENGTH 10,
    vl_matnr TYPE c LENGTH 18,
    vl_lfimg TYPE c LENGTH 6,
    vl_pikmg TYPE lipsd-pikmg,
    vl_pikm2 TYPE lipsd-pikmg,
    vl_longi TYPE i.

  DATA:
    tl_vepo TYPE STANDARD TABLE OF ty_vepo.

  DATA:
    sl_vepo TYPE ty_vepo.

  DATA:
     vl_scaner TYPE c LENGTH 20.

  SELECT SINGLE venum exidv vhilm vhart ntgew status uevel
    INTO (sl_vepo-venum,sl_vepo-exidv,sl_vepo-vhilm,sl_vepo-vhart,sl_vepo-ntgew,
          sl_vepo-status,sl_vepo-uevel)
    FROM vekp
   WHERE exidv = vg_scaner.

  IF sl_vepo-uevel NE space.

    PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'Esta contenida' 'en UMP superior'
          space space space space space.
    CLEAR vg_scaner.
    CALL SCREEN '0103'.
    RETURN.

  ENDIF.

  SELECT SINGLE unvel matnr vemng charg
    INTO (sl_vepo-unvel,sl_vepo-matnr,sl_vepo-vemng,sl_vepo-charg)
    FROM vepo
   WHERE venum = sl_vepo-venum.

*  SELECT SINGLE unvel matnr vemng
*    INTO (sl_vepo-unvel,sl_vepo-matnr,sl_vepo-vemng)
*    FROM vepo
*   WHERE venum = sl_vepo-venum.

  " No es el último nivel
  IF  sy-subrc = 0
  AND sl_vepo-unvel NE space.

    SELECT SINGLE venum exidv vhilm
      INTO (sl_vepo-venum2,sl_vepo-exidv2,sl_vepo-vhilm2)
      FROM vekp
      WHERE venum = sl_vepo-unvel.

    IF sy-subrc = 0.

      SELECT SINGLE unvel matnr vemng
        INTO (sl_vepo-unvel,sl_vepo-matnr,sl_vepo-vemng)
       FROM vepo
       WHERE venum = sl_vepo-venum2.

      IF sy-subrc NE 0.

        PERFORM f_arma_102 USING '' 'UnManipu' vg_scaner 'No existe' vg_msg5
              space space space space space.
        CLEAR vg_scaner.
        CALL SCREEN '0103'.
        RETURN.

      ENDIF.

    ENDIF.

  ELSEIF  sy-subrc NE 0.

    PERFORM f_arma_102 USING '' 'Unidad de Manipu' vg_scaner 'No existe' vg_msg5
          space space space space space.
    CLEAR vg_scaner.
    CALL SCREEN '0103'.
    RETURN.

  ENDIF.

  DATA:
    tl_vepo_unvel TYPE STANDARD TABLE OF ty_vepo_pallet,
    tl_vepo_cant  TYPE STANDARD TABLE OF ty_vepo_pallet,
    tl_vepo_tapa  TYPE STANDARD TABLE OF ty_vepo_pallet.

  DATA:
    sl_vepo_unvel TYPE ty_vepo_pallet,
    sl_vepo_cant  TYPE ty_vepo_pallet,
    sl_vepo_tapa  TYPE ty_vepo_pallet.

  CLEAR: tl_vepo_unvel[],tl_vepo_cant.
  SELECT venum unvel vemng matnr charg
    INTO TABLE tl_vepo_unvel
    FROM vepo
   WHERE venum = sl_vepo-venum.

  IF tl_vepo_unvel[] IS NOT INITIAL.

    SELECT venum unvel vemng matnr charg
      INTO TABLE tl_vepo_cant
      FROM vepo
       FOR ALL ENTRIES IN tl_vepo_unvel
      WHERE venum = tl_vepo_unvel-unvel.

    IF sy-subrc = 0.
      tl_vepo_tapa[] =  tl_vepo_cant[].
    ELSEIF sl_vepo-vhart = 'Z001'
        OR sl_vepo-vhart = 'Z004'.
      tl_vepo_tapa[] =  tl_vepo_cant[] = tl_vepo_unvel[].
      CLEAR tl_vepo_unvel[].
      sl_vepo_unvel-venum = sl_vepo-venum.
      sl_vepo_unvel-unvel = sl_vepo-venum.
      sl_vepo_unvel-vemng = 1.
      sl_vepo_unvel-matnr = sl_vepo-vhilm.
      APPEND sl_vepo_unvel TO tl_vepo_unvel.
      CLEAR sl_vepo_unvel .
    ENDIF.
    DELETE tl_vepo_cant WHERE charg IS INITIAL.
    DELETE tl_vepo_tapa WHERE charg IS NOT INITIAL.

  ENDIF.

  LOOP AT tl_vepo_unvel INTO sl_vepo_unvel.

    LOOP AT tl_vepo_cant INTO sl_vepo_cant
    WHERE venum = sl_vepo_unvel-unvel.

      vl_pikmg = sl_vepo_cant-vemng.
      LOOP AT tg_p101 INTO sg_p101
      WHERE matnr = sl_vepo_cant-matnr.

        vl_pikm2          = vl_pikmg.
        sg_p101-pikmg     = sg_p101-pikmg - vl_pikmg.
        sg_p101-csurt     = sg_p101-csurt - 1.
        MODIFY tg_p101 FROM sg_p101.

        READ TABLE tl_vepo_tapa INTO sl_vepo_tapa
        WITH KEY venum = sl_vepo_unvel-unvel.

*        IF sy-subrc = 0.
        sg_item-mandt     = sy-mandt.
        sg_item-vbeln     = sg_p101-vbeln.
        sg_item-posnr     = sg_p101-posnr.
        sg_item-exidv     = sl_vepo-exidv.
        sg_item-matnr01   = sl_vepo_cant-matnr.  " Material de la entrega
        sg_item-matnr02   = sl_vepo_unvel-matnr. " Canastilla
        sg_item-matnr03   = sl_vepo_tapa-matnr.  " Tapa de canastilla
        sg_item-lfimg01   = sl_vepo_cant-vemng * -1.
        sg_item-charg     = sl_vepo_cant-charg.
        sg_item-lfimg02   = 1.

        COLLECT sg_item INTO tg_item.
        COLLECT sg_item INTO tg_dele.
*        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDLOOP.

*  vl_matnr = sl_vepo-matnr. "vg_scaner(5).
*  vl_lfimg = sl_vepo-vemng.
*
*  LOOP AT tg_p101 INTO sg_p101
*  WHERE matnr = vl_matnr.
*
*    sg_p101-pikmg = sg_p101-pikmg - vl_lfimg.
*    sg_p101-csurt = sg_p101-csurt - 1.
*    MODIFY tg_p101 FROM sg_p101.
*
*    sg_item-vbeln  = sg_p101-vbeln.
*    sg_item-posnr  = sg_p101-posnr.
*    IF sl_vepo-exidv2 IS INITIAL.
*      sg_item-exidv  = sl_vepo-exidv.
*      sg_item-matnr02 = sl_vepo-vhilm.
*    ELSE.
*      sg_item-exidv  = sl_vepo-exidv2.
*      sg_item-matnr02 = sl_vepo-vhilm2.
*    ENDIF.
**    sg_item-matnr01 = sl_vepo-matnr.
**    sg_item-lfimg01 = sl_vepo-vemng * -1.
**    sg_item-lfimg02 = -1.
*
**    COLLECT sg_item INTO tg_item.
*    APPEND sg_item TO tg_dele.
*  ENDLOOP.

  CLEAR vg_scaner.

ENDFORM.                    " F_GET_CANTIDAD
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_ENTREGA                                               *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Modifica la entrega                                     *
************************************************************************
FORM f_entrega .

  DATA: BEGIN OF it_vekp OCCURS 0.
          INCLUDE STRUCTURE vekp.
  DATA: END OF it_vekp.

  DATA: BEGIN OF it_vepo OCCURS 0.
          INCLUDE STRUCTURE vepo.
  DATA: END OF it_vepo.

  DATA: BEGIN OF it_vepo2 OCCURS 0.
          INCLUDE STRUCTURE vepo.
  DATA: END OF it_vepo2.

  DATA: ls_vekp LIKE vekp,
        ls_vepo LIKE vepo.

  DATA:
    tl_part  TYPE STANDARD TABLE OF ty_lotes,
    tl_uman  TYPE STANDARD TABLE OF ty_lotes,
    ls_vepo2 LIKE vepo.

  DATA:
    vl_clabs TYPE mchb-clabs.

  DATA:
    vl_lines TYPE sy-index.

  DATA:
    vl_fecha      TYPE c LENGTH 10,
    vl_cont       TYPE i,
    vl_lot        TYPE n LENGTH 2,
    vl_pick       TYPE n LENGTH 2,
    vl_lips_charg TYPE c LENGTH 20,
    vl_lips_lfimg TYPE c LENGTH 20,
    vl_cant       TYPE c LENGTH 16.

  DATA:
    sl_aux TYPE ty_lotes.

  DATA: BEGIN OF line,
          matnr TYPE lips-matnr,
          charg TYPE lips-charg,
          lfimg TYPE lips-lfimg,
        END OF line.

  DATA itab LIKE SORTED TABLE OF line
  WITH NON-UNIQUE KEY matnr charg WITH HEADER LINE.

  CLEAR tg_lotes[].
  IF NOT tg_item[] IS INITIAL.
    SELECT * INTO TABLE it_vekp
              FROM vekp
               FOR ALL ENTRIES IN tg_item
             WHERE exidv EQ tg_item-exidv.

    IF it_vekp[] IS NOT INITIAL.
      SELECT * INTO TABLE it_vepo
        FROM vepo
         FOR ALL ENTRIES IN it_vekp
       WHERE venum EQ it_vekp-venum.

      IF it_vepo[] IS NOT INITIAL.
        SELECT * INTO TABLE it_vepo2
          FROM vepo
           FOR ALL ENTRIES IN it_vepo
         WHERE venum EQ it_vepo-unvel.

        DELETE it_vepo2 WHERE lgort = ' '.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT tg_item INTO sg_item.

    IF NOT sg_item-charg2 IS INITIAL OR
       NOT sg_item-charg3 IS INITIAL OR
       NOT sg_item-charg4 IS INITIAL OR
       NOT sg_item-charg5 IS INITIAL.

      READ TABLE it_vekp INTO ls_vekp WITH KEY exidv = sg_item-exidv.
      IF sy-subrc = 0.
        LOOP AT it_vepo INTO ls_vepo WHERE venum = ls_vekp-venum.
          READ TABLE it_vepo2 INTO ls_vepo2 WITH KEY venum = ls_vepo-unvel.
          IF sy-subrc = 0.

            line-matnr = ls_vepo2-matnr.
            line-lfimg = ls_vepo2-vemng.
            line-charg = ls_vepo2-charg.

            COLLECT line INTO itab.
          ENDIF.
        ENDLOOP.
      ENDIF.

      LOOP AT itab.
        MOVE: itab-matnr TO sg_lotes-matnr,
              itab-charg TO sg_lotes-charg,
              itab-lfimg TO sg_lotes-lfimg.
        COLLECT sg_lotes  INTO tg_lotes.
      ENDLOOP.
      CLEAR: itab, line.
      REFRESH: itab.
    ELSE.
      IF sg_item-exidv+8(1) = '3'.
        READ TABLE it_vekp INTO ls_vekp WITH KEY exidv = sg_item-exidv.
        IF sy-subrc = 0.
          LOOP AT it_vepo INTO ls_vepo WHERE venum = ls_vekp-venum.
            READ TABLE it_vepo2 INTO ls_vepo2 WITH KEY venum = ls_vepo-unvel.
            IF sy-subrc = 0.
              line-matnr = ls_vepo2-matnr.
              line-lfimg = ls_vepo2-vemng.
              line-charg = ls_vepo2-charg.

              COLLECT line INTO itab.
            ENDIF.
          ENDLOOP.
        ENDIF.

        LOOP AT itab.
          MOVE: itab-matnr TO sg_lotes-matnr,
                itab-charg TO sg_lotes-charg,
                itab-lfimg TO sg_lotes-lfimg.
          COLLECT sg_lotes  INTO tg_lotes.
        ENDLOOP.
        CLEAR: itab, line.
        REFRESH: itab.
      ELSE.

        sg_lotes-matnr = sg_item-matnr01.
        sg_lotes-lfimg = sg_item-lfimg01.
        sg_lotes-charg = sg_item-charg.
        IF sg_lotes-charg IS INITIAL.
          READ TABLE tg_lotes INTO sl_aux
            WITH KEY matnr = sg_item-matnr01.
          IF sy-subrc = 0.
            sg_lotes-charg = sl_aux-charg.
          ENDIF.
        ENDIF.

        COLLECT sg_lotes INTO tg_lotes.
      ENDIF.
    ENDIF.

  ENDLOOP.

  LOOP AT tg_p101 INTO sg_p101.
    vl_cont = vl_cont + 1.

    IF vl_cont = 1.
      PERFORM f_fill_bdc USING:
            'X'  'SAPMV50A'              '4004',
            ' '  'LIKP-VBELN'            sg_p101-vbeln,  " Entrega
            ' '  'BDC_OKCODE'            '/00'.

      PERFORM f_fill_bdc USING:
            'X'  'SAPMV50A'              '1000',
            ' '  'BDC_OKCODE'            'T\02'.

    ENDIF.

    PERFORM f_fill_bdc USING:
          'X'  'SAPMV50A'              '1000',
          ' '  'BDC_OKCODE'            '=POPO_T'.

    PERFORM f_fill_bdc USING:
    'X'  'SAPMV50A'              '0111',
    ' '  'RV50A-POSNR'           sg_p101-posnr,
    ' '  'BDC_OKCODE'            '=WEIT'.

    tl_part[] = tg_lotes[].
    DELETE tl_part WHERE matnr NE sg_p101-matnr.
    DESCRIBE TABLE tl_part LINES vl_lines.

    CLEAR: vl_lot.
    LOOP AT tl_part INTO sg_lotes
      WHERE matnr = sg_p101-matnr.

      IF vl_lines >= 2.
        vl_lot = vl_lot + 1.
        IF vl_lot = 1.
          " Partición de lotes.
          WRITE sg_p101-pikmg TO vl_cant.
          PERFORM f_fill_bdc USING:
                'X'  'SAPMV50A'              '1000',
                ' '  'RV50A-LIPS_SELKZ(01)'  abap_true,
                ' '  'LIPSD-G_LFIMG(01)'     vl_cant,
                ' '  'BDC_OKCODE'            '=CHSP_T'.
        ENDIF.
        CLEAR vl_cant.
        CONCATENATE 'LIPS-CHARG(' vl_lot ')' INTO vl_lips_charg.
        CONCATENATE 'LIPS-LFIMG(' vl_lot ')' INTO vl_lips_lfimg.
        WRITE sg_lotes-lfimg TO vl_cant.
        PERFORM f_fill_bdc USING:
        'X'  'SAPMV50A'                '3000',
        ' '  vl_lips_charg              sg_lotes-charg,
        ' '  vl_lips_lfimg              vl_cant,
        ' '  'BDC_OKCODE'              '/00'.
      ELSE.
        WRITE sg_lotes-lfimg TO vl_cant.
        PERFORM f_fill_bdc USING:
        'X'  'SAPMV50A'                '1000',
        ' ' 'LIPSD-G_LFIMG(01)'        vl_cant,
        ' '  'LIPS-CHARG(01)'          sg_lotes-charg,
        ' '  'LIPS-LGORT(01)'          'EMBA',
        ' '  'LIPSD-PIKMG(01)'         vl_cant,
        ' '  'BDC_OKCODE'              '/00'.

      ENDIF.
    ENDLOOP.

    IF  sy-subrc = 0
    AND vl_lines >= 2.
      PERFORM f_fill_bdc USING:
      'X'  'SAPMV50A'                '3000',
      ' '  'BDC_OKCODE'              '/3'.

      CLEAR: vl_lot,vl_pick.
      LOOP AT tl_part INTO sg_lotes
      WHERE matnr = sg_p101-matnr.

        IF vl_lines >= 2.
          vl_lot = vl_lot + 1.
          IF vl_lot = 1.
            " Partición de lotes.
            PERFORM f_fill_bdc USING:
                  'X'  'SAPMV50A'              '1000',
                  ' '  'BDC_OKCODE'            'CHPL_T01'.
          ENDIF.
          CLEAR vl_cant.
          vl_pick = vl_lot + 1.
          CONCATENATE 'LIPSD-PIKMG(' vl_pick ')' INTO vl_lips_lfimg.
          WRITE sg_lotes-lfimg TO vl_cant.
          PERFORM f_fill_bdc USING:
                'X'  'SAPMV50A'                '1000',
                ' '  vl_lips_lfimg              vl_cant,
                ' '  'BDC_OKCODE'              '/00'.
        ENDIF.
      ENDLOOP.
      IF sy-subrc = 0.
        PERFORM f_fill_bdc USING:
              'X'  'SAPMV50A'              '1000',
              ' '  'BDC_OKCODE'            'CHPL_T01'.

      ENDIF.

    ENDIF.

  ENDLOOP.
  IF sy-subrc = 0.
    IF tg_item[] IS NOT INITIAL.
      PERFORM f_fill_bdc USING:
            'X'  'SAPMV50A'                '1000',
            ' '  'BDC_OKCODE'              '=VERP_T'.

      PERFORM f_fill_bdc USING:
            'X'  'SAPLV51G'                '6000',
            ' '  'BDC_OKCODE'              '=UE6VDIR'.
    ENDIF.

    DATA:
      tl_vekp  TYPE STANDARD TABLE OF vekp,
      tl_vepo  TYPE STANDARD TABLE OF vepo,
      tl_vekp2 TYPE STANDARD TABLE OF vekp,
      sl_vekp  TYPE vekp,
      sl_vepo  TYPE vepo,
      sl_vekp2 TYPE vekp.

    IF tg_item[] IS NOT INITIAL.

      SELECT * INTO TABLE tl_vekp
        FROM vekp
         FOR ALL ENTRIES IN tg_item
       WHERE exidv EQ tg_item-exidv.

      IF tl_vekp[] IS NOT INITIAL.
        SELECT * INTO TABLE tl_vepo
          FROM vepo
           FOR ALL ENTRIES IN tl_vekp
         WHERE venum EQ tl_vekp-venum.

        IF tl_vepo[] IS NOT INITIAL.
          SELECT * INTO TABLE tl_vekp2
            FROM vekp
             FOR ALL ENTRIES IN tl_vepo
           WHERE venum EQ tl_vepo-unvel.
        ENDIF.
      ENDIF.
    ENDIF.
    LOOP AT tg_item INTO sg_item.

      PERFORM f_fill_bdc USING:
      'X'  'SAPLV51G'                '6000',
      ' '  'VEKP-EXIDV'              sg_item-exidv,
      ' '  'BDC_OKCODE'              '/00'.

      AT LAST.
        PERFORM f_fill_bdc USING:
        'X'  'SAPLV51G'                '6000',
        ' '  'BDC_OKCODE'              '/3'.
      ENDAT.

      " Solo para la cantidad del picking de las canastillas o pallets
      IF sg_item-matnr03 IS NOT INITIAL.
        CLEAR sg_lotes.
        sg_lotes-matnr = sg_item-matnr02.
        sg_lotes-lfimg = sg_item-lfimg02.
        COLLECT sg_lotes INTO tl_uman.
        sg_lotes-matnr = sg_item-matnr03.
        COLLECT sg_lotes INTO tl_uman.
      ENDIF.
*      ENDIF.
    ENDLOOP.

    IF tl_uman[] IS NOT INITIAL.
      LOOP AT tl_uman INTO sg_lotes.

        PERFORM f_fill_bdc USING:
        'X'  'SAPMV50A'              '1000',
        ' '  'BDC_OKCODE'            '=POPO_T'.

        PERFORM f_fill_bdc USING:
        'X'  'SAPMV50A'              '0111',
        ' '  'RV50A-POSNR'           space,
        ' '  'RV50A-PO_MATNR'        sg_lotes-matnr,
        ' '  'BDC_OKCODE'            '=WEIT'.
        CLEAR vl_cant.
        WRITE sg_lotes-lfimg TO vl_cant.
        PERFORM f_fill_bdc USING:
        'X'  'SAPMV50A'                '1000',
        ' '  'LIPSD-G_LFIMG(01)'       vl_cant,
        ' '  'LIPSD-PIKMG(01)'         vl_cant,
        ' '  'BDC_OKCODE'              '/00'.

      ENDLOOP.
    ENDIF.

    PERFORM f_fill_bdc USING:
    'X'  'SAPMV50A'                '1000',
    ' '  'BDC_OKCODE'              'WABU_T'.
  ENDIF.

  PERFORM f_call USING c_vl02n.
  PERFORM f_msj  USING c_vl02n.
  PERFORM f_free USING sg_p101-vbeln.

ENDFORM.                    " F_CREAR_ENTREGA
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_ENTREGA                                               *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Modifica la entrega                                     *
************************************************************************
FORM f_entrega_dev.

  DATA:
    tl_part TYPE STANDARD TABLE OF ty_lotes,
    tl_uman TYPE STANDARD TABLE OF ty_lotes.

  DATA:
    vl_clabs      TYPE mchb-clabs,
    vl_lines      TYPE sy-index,
    vl_vbeln      TYPE lips-vbeln,
    vl_fecha      TYPE c LENGTH 10,
    vl_cont       TYPE i,
    vl_lot        TYPE n LENGTH 2,
    vl_lips_charg TYPE c LENGTH 20,
    vl_lips_lfimg TYPE c LENGTH 20,
    vl_cant       TYPE c LENGTH 16.

  DATA:
    sl_aux TYPE ty_lotes.

  CLEAR tg_lotes[].
  LOOP AT tg_item INTO sg_item.
    sg_lotes-matnr = sg_item-matnr01.
    sg_lotes-lfimg = sg_item-lfimg01.
    sg_lotes-charg = sg_item-charg.
    IF sg_lotes-charg IS INITIAL.
      READ TABLE tg_lotes INTO sl_aux
      WITH KEY matnr = sg_item-matnr01.
      IF sy-subrc = 0.
        sg_lotes-charg = sl_aux-charg.
      ENDIF.
    ENDIF.
    COLLECT sg_lotes INTO tg_lotes.
  ENDLOOP.

  LOOP AT tg_p101 INTO sg_p101.
    vl_cont = vl_cont + 1.

    IF vl_cont = 1.
      vl_vbeln = sg_p101-vbeln.
      PERFORM f_fill_bdc USING:
      'X'  'SAPMV50A'              '4004',
      ' '  'LIKP-VBELN'            sg_p101-vbeln,  " Entrega
      ' '  'BDC_OKCODE'            '/00'.

    ENDIF.

    " RBD
    PERFORM f_fill_bdc USING:
    'X'  'SAPMV50A'              '1000',
    ' '  'BDC_OKCODE'            '=POPO_T'.

    PERFORM f_fill_bdc USING:
    'X'  'SAPMV50A'              '0111',
    ' '  'RV50A-POSNR'           sg_p101-posnr,
    ' '  'BDC_OKCODE'            '=WEIT'.

    tl_part[] = tg_lotes[].
    DELETE tl_part WHERE matnr NE sg_p101-matnr.
    DESCRIBE TABLE tl_part LINES vl_lines.

    CLEAR: vl_lot.
    LOOP AT tl_part INTO sg_lotes
    WHERE matnr = sg_p101-matnr.

      IF vl_lines >= 2.
        vl_lot = vl_lot + 1.
        IF vl_lot = 1.
          " Partición de lotes.
          WRITE sg_p101-pikmg TO vl_cant.
          PERFORM f_fill_bdc USING:
          'X'  'SAPMV50A'              '1000',
          ' '  'RV50A-LIPS_SELKZ(01)'  abap_true,
                ' '  'LIPSD-G_LFIMG(01)'     vl_cant,
                ' '  'LIPS-CHARG(01)'        space,
          ' '  'BDC_OKCODE'            '=CHSP_T'.
        ENDIF.
        CLEAR vl_cant.
        CONCATENATE 'LIPS-CHARG(' vl_lot ')' INTO vl_lips_charg.
        CONCATENATE 'LIPS-LFIMG(' vl_lot ')' INTO vl_lips_lfimg.
        WRITE sg_lotes-lfimg TO vl_cant.
        PERFORM f_fill_bdc USING:
        'X'  'SAPMV50A'                '3000',
        ' '  vl_lips_charg              sg_lotes-charg,
        ' '  vl_lips_lfimg              vl_cant,
        ' '  'BDC_OKCODE'              '/00'.
      ELSE.
        WRITE sg_lotes-lfimg TO vl_cant.
        PERFORM f_fill_bdc USING:
        'X'  'SAPMV50A'                '1000',
        ' ' 'LIPSD-G_LFIMG(01)'        vl_cant,
        ' '  'LIPS-CHARG(01)'          sg_lotes-charg,
*             ' '  'LIPSD-PIKMG(01)'         vl_cant,
        ' '  'BDC_OKCODE'              '/00'.

      ENDIF.
    ENDLOOP.
    IF  sy-subrc = 0
    AND vl_lines >= 2.
      PERFORM f_fill_bdc USING:
      'X'  'SAPMV50A'                '3000',
      ' '  'BDC_OKCODE'              '/3'.
    ENDIF.
    " RBD
  ENDLOOP.
  IF sy-subrc = 0.
    IF tg_item[] IS NOT INITIAL.
      PERFORM f_fill_bdc USING:
      'X'  'SAPMV50A'                '1000',
      ' '  'BDC_OKCODE'              '=VERP_T'.

      PERFORM f_fill_bdc USING:
      'X'  'SAPLV51G'                '6000',
      ' '  'BDC_OKCODE'              '=UE6VDIR'.
    ENDIF.
    LOOP AT tg_item INTO sg_item.

      PERFORM f_fill_bdc USING:
      'X'  'SAPLV51G'                '6000',
      ' '  'VEKP-EXIDV'              sg_item-exidv,
      ' '  'BDC_OKCODE'              '/00'.

      AT LAST.
        PERFORM f_fill_bdc USING:
        'X'  'SAPLV51G'                '6000',
        ' '  'BDC_OKCODE'              '/3'.
      ENDAT.

    ENDLOOP.

    PERFORM f_fill_bdc USING:
    'X'  'SAPMV50A'                '1000',
    ' '  'BDC_OKCODE'              'WABU_T'.
  ENDIF.
  PERFORM f_call USING c_vl02n.
  PERFORM f_msj  USING c_vl02n.
  PERFORM f_free USING sg_p101-vbeln.
  IF  vg_final = abap_true
  AND vg_error = abap_false.
    LOOP AT tg_item INTO sg_item.
      DELETE FROM zhuinv_item WHERE exidv = sg_item-exidv.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_CREAR_ENTREGA
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
* Subrutina..: F_MODIFICA_PED                                          *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Modifica pedido                                         *
************************************************************************
FORM f_modifica_ped .

  DATA:
    vl_loop TYPE index,
    vl_cant TYPE c LENGTH 18,
    ls_vbep TYPE vbep.

*  LOOP AT tg_p101 INTO sg_p101.

**    IF sg_p101-pikmg > sg_p101-lfimg.
**      vl_loop =  vl_loop + 1.
**    ELSE.
**      CONTINUE.
**    ENDIF.
*    vl_loop =  vl_loop + 1.
*    IF vl_loop = 1.
*      PERFORM f_fill_bdc USING:
*      'X'  'SAPMV45A'              '0102',
*      ' '  'VBAK-VBELN'            sg_p101-vgbel,
*      ' '  'BDC_OKCODE'            '/00'.
*
*    ENDIF.
*    PERFORM f_fill_bdc USING:
*    'X'  'SAPMV45A'              '4001',
*    ' '  'BDC_OKCODE'            '=POPO'.
*
*    PERFORM f_fill_bdc USING:
*    'X'  'SAPMV45A'              '0251',
*    ' '  'RV45A-POSNR'           sg_p101-vgpos,
*    ' '  'BDC_OKCODE'            '=POSI'.
*
*    WRITE: sg_p101-pikmg TO vl_cant.
*    PERFORM f_fill_bdc USING:
*    'X'  'SAPMV45A'              '4001',
*    ' '  'RV45A-KWMENG(01)'      vl_cant,
*    ' '  'BDC_OKCODE'            '/00'.
*  ENDLOOP.

*  IF vl_loop NE 0.
*    PERFORM f_fill_bdc USING:
*    'X'  'SAPMV45A'              '4001',
*    ' '  'BDC_OKCODE'            '=SICH'.
*
*    PERFORM f_call USING c_va02.
*    PERFORM f_msj USING c_va02.
*    PERFORM f_free USING sg_p101-vgbel.
*  ENDIF.
  DATA: lv_salesdoc  TYPE bapivbeln-vbeln,
        hdr_inx      TYPE bapisdh1x,
        item_in      TYPE STANDARD TABLE OF bapisditm,
        item_inx     TYPE STANDARD TABLE OF bapisditmx,
        item_sch     TYPE STANDARD TABLE OF bapischdl,
        item_schx    TYPE STANDARD TABLE OF bapischdlx,
        return       TYPE STANDARD TABLE OF bapiret2,
        ls_item_in   TYPE bapisditm,
        ls_item_inx  TYPE bapisditmx,
        ls_item_sch  TYPE bapischdl,
        ls_item_schx TYPE bapischdlx.

  LOOP AT tg_p101 INTO sg_p101.
    CLEAR: lv_salesdoc, hdr_inx, ls_item_in, ls_item_inx,item_in,item_inx, item_sch, item_schx, ls_item_sch, ls_item_schx.
    "Llenamos doc. y indicador de Actualización
    lv_salesdoc = sg_p101-vgbel.
    hdr_inx-updateflag = 'U'.

    ls_item_in-itm_number = sg_p101-vgpos.
    ls_item_in-target_qty = sg_p101-pikmg.
    APPEND ls_item_in TO item_in.

    ls_item_inx-itm_number = sg_p101-vgpos.
    ls_item_inx-updateflag = 'U'.
    ls_item_inx-target_qty = abap_true.
    APPEND ls_item_inx TO item_inx.

* Busca linea de reparto para modificar en pedido de venta

    SELECT SINGLE *  INTO  ls_vbep
             FROM vbep
             WHERE vbeln = sg_p101-vgbel
             AND   posnr = sg_p101-vgpos.

    ls_item_sch-itm_number = sg_p101-vgpos.
    ls_item_sch-sched_line = ls_vbep-etenr.
    ls_item_sch-req_date   = ls_vbep-edatu.
    ls_item_sch-req_qty    = sg_p101-pikmg.
    APPEND ls_item_sch TO item_sch.

    ls_item_schx-itm_number = sg_p101-vgpos.
    ls_item_schx-sched_line = ls_vbep-etenr.
    ls_item_schx-req_date   = abap_true.
    ls_item_schx-updateflag = 'U'.
    ls_item_schx-req_qty    = abap_true.
    APPEND ls_item_schx TO item_schx.

    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = lv_salesdoc
        order_header_inx = hdr_inx
      TABLES
        return           = return
        order_item_in    = item_in
        order_item_inx   = item_inx
        schedule_lines   = item_sch
        schedule_linesx  = item_schx.


    READ TABLE return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    IF sy-subrc NE 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.
    MOVE-CORRESPONDING return[] TO tg_msj[].
    PERFORM f_msj USING c_va02.
    PERFORM f_free USING sg_p101-vgbel.

  ENDLOOP.

ENDFORM.                    " F_MODIFICA_PED
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_FIIL_TEMP                                             *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Llena la tabla temporal Z                               *
************************************************************************
FORM f_fill_temp_anula.

  vg_final = abap_true.
*  MODIFY zhuinv_item FROM TABLE tg_item.
  IF tg_dele[] IS NOT INITIAL.
    LOOP AT tg_dele INTO sg_item.
      DELETE FROM zhuinv_item WHERE vbeln = sg_item-vbeln
                                AND exidv = sg_item-exidv.
    ENDLOOP.

  ENDIF.
  CLEAR: tg_item[],tg_dele[].
  PERFORM f_arma_102 USING '' 'Se guardaron los ' 'datos temporalmente' vg_msg4 vg_msg5
        space space space space space.
  CALL SCREEN '0103'.
ENDFORM.                    " F_FIIL_TEMP

************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_FIIL_TEMP                                             *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Llena la tabla temporal Z                               *
************************************************************************
FORM f_fill_temp .
  DATA: ls_item_aux TYPE zhuinv_item,
        lv_charg    TYPE charg_d,
        tg_item_aux TYPE STANDARD TABLE OF zhuinv_item,
        ls_aux      TYPE zhuinv_item.

  LOOP AT tg_item INTO DATA(ls_item).
    CLEAR ls_item_aux.
    ls_item_aux-vbeln = ls_item-vbeln.
    ls_item_aux-posnr = ls_item-posnr.
    ls_item_aux-exidv = ls_item-exidv.
    ls_item_aux-venum = ls_item-venum.
    ls_item_aux-matnr01 = ls_item-matnr01.
    ls_item_aux-matnr02 = ls_item-matnr02.
    ls_item_aux-matnr03 = ls_item-matnr03.
    ls_item_aux-vrkme = ls_item-vrkme.

    READ TABLE tg_item_aux
           INTO ls_aux
           WITH KEY  vbeln = ls_item-vbeln
                     posnr = ls_item-posnr
                     exidv = ls_item-exidv
                     matnr01 = ls_item-matnr01.

    IF sy-subrc NE 0.
      ls_item_aux-lfimg01 = ls_item-lfimg01.
      ls_item_aux-lfimg02 = ls_item-lfimg02.
      ls_item_aux-charg  =  ls_item-charg .

      COLLECT ls_item_aux INTO tg_item_aux.
    ELSE.
      ls_item_aux-lfimg01 = ls_item-lfimg01 + ls_aux-lfimg01.
      ls_item_aux-lfimg02 = ls_item-lfimg02 + ls_aux-lfimg02.
      ls_item_aux-charg  =  ls_aux-charg.
      ls_item_aux-charg2 = COND #( WHEN ls_item_aux-charg  NE ls_item-charg AND
                                    ls_item_aux-charg2 IS INITIAL
                               THEN ls_item-charg ).
      ls_item_aux-charg3 = COND #( WHEN ls_item_aux-charg2 NE ls_item-charg AND
                                        ls_item_aux-charg3 IS INITIAL
                                   THEN ls_item-charg ).
      IF ls_item_aux-charg2 IS INITIAL.
        CLEAR ls_item_aux-charg3.
      ENDIF.
      ls_item_aux-charg4 = COND #( WHEN ls_item_aux-charg3 NE ls_item-charg AND
                                        ls_item_aux-charg4 IS INITIAL
                                   THEN ls_item-charg ).
      IF ls_item_aux-charg3 IS INITIAL.
        CLEAR ls_item_aux-charg4.
      ENDIF.

      ls_item_aux-charg5 = COND #( WHEN ls_item_aux-charg4 NE ls_item-charg AND
                                        ls_item_aux-charg5 IS INITIAL
                                 THEN ls_item-charg ).
      IF ls_item_aux-charg4 IS INITIAL.
        CLEAR ls_item_aux-charg5.
      ENDIF.

      MODIFY tg_item_aux FROM ls_item_aux INDEX sy-tabix
                         TRANSPORTING lfimg01 lfimg02 charg charg2 charg3 charg4 charg5.
    ENDIF.
  ENDLOOP.
*  vg_final = abap_true.

  MODIFY zhuinv_item FROM TABLE tg_item_Aux.
  COMMIT WORK AND WAIT.
*  MODIFY zhuinv_item FROM TABLE tg_item.
*  CLEAR: tg_item[].
  PERFORM f_arma_102 USING '' 'Se guardaron los ' 'datos temporalmente' vg_msg4 vg_msg5
          space space space space space.
  CALL SCREEN '0103'.

ENDFORM.                    " F_FIIL_TEMP
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_ACTUAL_SCANER                                          *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Actualiza las cantidades scaneada anteriormente         *
************************************************************************
FORM f_actual_scaner .
  DATA:
    vl_cant    TYPE zhuinv_item-lfimg01,
    vl_lfimg02 TYPE zhuinv_item-lfimg02.

  " Extraemos las cantidades que fueron previamente cargadas
  SELECT * INTO TABLE tg_anterior
    FROM zhuinv_item
     FOR ALL ENTRIES IN tg_p101
   WHERE vbeln = tg_p101-vbeln.

  LOOP AT tg_p101 INTO sg_p101.

    CLEAR: vl_cant,vl_lfimg02.
    LOOP AT tg_anterior INTO sg_item
      WHERE vbeln EQ sg_p101-vbeln
        AND posnr EQ sg_p101-posnr.

      vl_cant    = vl_cant + sg_item-lfimg01.
      vl_lfimg02 = vl_lfimg02 + sg_item-lfimg02.
      APPEND sg_item TO tg_item.
    ENDLOOP.

    IF sg_p101-lfimg > 0.
      PERFORM f_get_cant_aprox
        USING sg_p101-matnr sg_p101-lfimg sg_p101-capro.
    ELSE.
      PERFORM f_get_cant_aprox
        USING sg_p101-matnr vl_cant  vl_lfimg02.
    ENDIF.
    sg_p101-pikmg = vl_cant.
    sg_p101-csurt = vl_lfimg02.
    MODIFY tg_p101 FROM sg_p101.

  ENDLOOP.

  DATA:
    tl_tvarvc TYPE STANDARD TABLE OF tvarvc,
    sl_tvarvc TYPE tvarvc,
    sl_lgort  LIKE LINE OF ra_lgort.

  IF tl_tvarvc[] IS INITIAL.

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

ENDFORM.                    " F_ACTUAL_SCANER
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_GRUPO                                             *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene entregas en un grupo                            *
************************************************************************
FORM f_get_grupo.

  DATA:
    sl_likp TYPE ty_likp.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = vg_sammg
    IMPORTING
      output = vg_sammg.

* Busca las entregas a partir de un grupo
  SELECT vbeln INTO CORRESPONDING FIELDS OF TABLE tg_vbss
    FROM ( vbss
   INNER JOIN vbsk
      ON vbss~sammg EQ vbsk~sammg )
   WHERE vbsk~smart EQ 'K'
     AND vbss~sammg EQ vg_sammg.

  IF tg_vbss[] IS NOT INITIAL.

    PERFORM f_get_vbuk USING abap_true.

    IF tg_vbuk[] IS NOT INITIAL.

      CLEAR vg_contab.
      PERFORM f_fill_vstel.
      PERFORM f_get_likp USING space.

      IF tg_likp IS NOT INITIAL.

        PERFORM f_get_lips.

      ENDIF.

      LOOP AT tg_likp INTO sl_likp.

        READ TABLE tg_vbss WITH KEY vbeln = sl_likp-vbeln
                           TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          READ TABLE tg_vbuk WITH KEY vbeln = sl_likp-vbeln
                             TRANSPORTING NO FIELDS.

          IF sy-subrc = 0.
            READ TABLE tg_lips INTO sg_lips
              WITH KEY vbeln = sl_likp-vbeln.
            IF sy-subrc = 0.

              MOVE:
                sl_likp-vbeln TO sg_vbs-vbeln,
                sl_likp-name1 TO sg_vbs-name1.
              APPEND sg_vbs TO tg_vbs.
            ELSE.
              DELETE tg_likp.
            ENDIF.
          ELSE.
            DELETE tg_likp.
          ENDIF.
        ELSE.
          DELETE tg_likp.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ELSE.
    PERFORM f_arma_102 USING '' 'Gpo entregas' vg_sammg 'no existe' vg_msg5
          space space space space space.
  ENDIF.

ENDFORM.                    " F_GET_GRUPO
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_FILL_VSTEL                                            *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Llena la tabla de VSTEL                                 *
************************************************************************
FORM f_fill_vstel.

  CLEAR tg_tvar[].
  SELECT * INTO TABLE tg_tvar
   FROM tvarvc
   WHERE name = 'VSTEL'.

  CLEAR ra_vstel[].
  LOOP AT tg_tvar INTO sg_tvar.

    sg_vstel-sign   = sg_tvar-sign.
    sg_vstel-option = sg_tvar-opti.
    sg_vstel-low    = sg_tvar-low.

    APPEND sg_vstel TO ra_vstel.
    CLEAR sg_vstel.

  ENDLOOP.

  SORT ra_vstel.

ENDFORM.                    " F_FILL_VSTEL
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_VBUK                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene el estatus de las entregas                      *
************************************************************************
FORM f_get_vbuk USING x_bool.

  CASE x_bool.
    WHEN 'O' OR 'D'.
      " Estatus para otros o devoluciones
      SELECT a~vbeln a~vtwiv
        INTO CORRESPONDING FIELDS OF TABLE tg_vbuk
        FROM likp AS a
        INNER JOIN lips AS b ON ( b~vbeln = a~vbeln )
         FOR ALL ENTRIES IN tg_likp
       WHERE   a~vbeln  EQ tg_likp-vbeln
*         AND ( kostk  EQ space
         AND ( a~wbstk  EQ 'A'
          OR   a~wbstk  EQ 'B' )
         AND   b~vtweg  IN ( '01', '02' , '05', '15' ).
*         AND vtwiv    IN ( '01', '02' ).

    WHEN abap_true.

      " Estatus para grupo de entregas
      SELECT vbeln INTO CORRESPONDING FIELDS OF TABLE tg_vbuk
        FROM likp
         FOR ALL ENTRIES IN tg_vbss
       WHERE vbeln  EQ tg_vbss-vbeln
*         AND ( kostk  EQ space
         AND ( kostk  EQ 'A'
          OR   kostk  EQ 'B' ).

    WHEN OTHERS.

      SELECT a~vbeln
        FROM likp AS a
        INNER JOIN vbfa AS b ON ( b~vbeln = a~vbeln )
        INNER JOIN vbak AS c ON ( c~vbeln = b~vbelv )
        INTO CORRESPONDING FIELDS OF TABLE tg_vbuk
        WHERE ( a~wbstk EQ 'A'              " No tratado
           OR   a~wbstk EQ 'B' )            " Parcialmente tratado
          AND b~vbtyp_v EQ 'C'              " Pedido
          AND c~vkorg   EQ 'AV03'
          AND c~vtweg   IN ( '01', '02', '05', '15' ).  " Mayoreo y Medio Mayoreo


  ENDCASE.
ENDFORM.                    " F_GET_VBUK.
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_LIKP                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene entregas cabecera                               *
************************************************************************
FORM f_get_likp USING x_fecha.

  IF x_fecha = abap_false.
    " Seleccionamos las entregas para mayoreo y grupo entregas
    SELECT likp~vbeln likp~kunnr kna1~name1 likp~lfart
      INTO TABLE tg_likp
      FROM ( likp
     INNER JOIN kna1
        ON kna1~kunnr  EQ likp~kunnr )
       FOR ALL ENTRIES IN tg_vbuk
     WHERE likp~vbeln  EQ tg_vbuk-vbeln
       AND likp~vstel  IN ra_vstel.

  ELSE.

    " Seleccionamos las entregas devolución y otros
    SELECT likp~vbeln likp~kunnr kna1~name1 likp~lfart
      INTO TABLE tg_likp
      FROM ( likp
     INNER JOIN kna1
        ON kna1~kunnr  EQ likp~kunnr )
     WHERE likp~erdat  GE vg_datum
       AND likp~vstel  IN ra_vstel.

  ENDIF.
ENDFORM.                    " F_GET_LIKP
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_LIPS                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene entregas pos LIPS                               *
************************************************************************
FORM f_get_lips .

  " Seleccionamos las posiciones
  SELECT lips~vbeln lips~posnr lips~matnr lips~charg lips~lfimg lips~vgbel lips~vgpos
         lips~werks lips~lgort lips~meins
*         marc~strgr
    INTO TABLE tg_lips
    FROM lips
*    FROM ( lips
*   INNER JOIN marc
*      ON lips~matnr  EQ marc~matnr
*     AND lips~werks  EQ marc~werks )
     FOR ALL ENTRIES IN tg_likp
   WHERE lips~vbeln  EQ tg_likp-vbeln
     AND ( lips~matnr LIKE 'PT%'
      OR   lips~matnr LIKE 'ST%').

ENDFORM.                    " F_GET_LIPS
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_VBAK                                              *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene cabecera VBAK                                   *
************************************************************************
FORM f_get_vbak USING x_opc.

  IF x_opc = 'EQ'.
    SELECT vbeln vtweg INTO TABLE tg_vbak
      FROM vbak
       FOR ALL ENTRIES IN tg_lips
     WHERE vbeln EQ tg_lips-vgbel
       AND vtweg IN ( '01', '05' ).
  ELSE.
    SELECT vbeln vtweg INTO TABLE tg_vbak
      FROM vbak
       FOR ALL ENTRIES IN tg_lips
     WHERE vbeln EQ tg_lips-vgbel
       AND vtweg NE '01'.
  ENDIF.

ENDFORM.                    " F_GET_VBAK
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_CANT_APROX                                        *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene cantidad aproximada                             *
************************************************************************
FORM f_get_cant_aprox USING x_objek x_cant x_aprox.
  DATA:
*    vl_atinn TYPE ausp-atinn,
    vl_atflv TYPE ausp-atflv VALUE '25'.

*  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*    EXPORTING
*      input  = 'Z_PIEZAS_UMP'
*    IMPORTING
*      output = vl_atinn.
*
*  SELECT SINGLE atflv INTO vl_atflv
*    FROM ausp
*   WHERE objek = x_objek
*     AND  atinn = vl_atinn.

  IF  x_cant NE 0.
*    vl_atflv NE 0
*  AND x_cant   NE 0.

    x_aprox = x_cant / vl_atflv.

  ENDIF.

ENDFORM.                    " F_GET_CANT_APROX
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_GET_ANULAR                                            *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Obtiene datos para eliminar cantidades                  *
************************************************************************
FORM f_get_anular.
  DATA:
    sl_likp TYPE ty_likp.

  CLEAR: tg_likp[],tg_lips[],tg_anterior[].
  APPEND vg_vbeln TO tg_likp.
  PERFORM f_fill_vstel.
  PERFORM f_get_vbuk USING 'O'.
  PERFORM f_get_lips.

  tg_p101[] = tg_lips[].

  DELETE tg_p101 WHERE posnr > '900000'.

  LOOP AT tg_p101 INTO sg_p101.

    READ TABLE tg_vbuk WITH KEY vbeln = sg_p101-vbeln
         TRANSPORTING NO FIELDS.

    IF sy-subrc NE 0.
      DELETE tg_p101.
    ENDIF.

  ENDLOOP.

  IF tg_p101[] IS NOT INITIAL.
    " Extraemos las cantidades que fueron previamente cargadas
    SELECT * INTO TABLE tg_anterior
      FROM zhuinv_item
       FOR ALL ENTRIES IN tg_p101
     WHERE vbeln = tg_p101-vbeln.

    IF sy-subrc = 0.
      CLEAR: tg_likp[],tg_lips[],tg_anterior[].
      PERFORM f_actual_scaner.
      CALL SCREEN '0104'.
    ELSE.
*      PERFORM f_arma_102 USING '' 'La entrega' vg_vbeln 'no se puede' 'anular'
*            space space space space space.
      CLEAR vg_scaner.
*      vg_err_msg = abap_true.
*      CALL SCREEN '0103'.
      RETURN.
    ENDIF.
  ELSE.
*    PERFORM f_arma_102 USING '' 'La entrega' vg_vbeln 'no se puede' 'anular'
*    space space space space space.
    CLEAR vg_scaner.
*    vg_err_msg = abap_true.
*    CALL SCREEN '0103'.
    RETURN.
  ENDIF.
ENDFORM.                    " F_GET_ANULAR
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_SCANER_REPETIDO                                       *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Verifica si hay repetidas                               *
************************************************************************
FORM f_scaner_repetido .
  CLEAR sg_zitem.

*<-- Begin cbarrera.20220624
  "Se verifica si la HU es de ECC o Hana
  DATA: lv_exidv TYPE vekp-exidv.

  lv_exidv = vg_scaner.
  SELECT SINGLE exidv
  INTO vg_scaner
  FROM vekp
  WHERE exidv = lv_exidv.

  IF sy-subrc NE 0.
    SELECT SINGLE exidv
    INTO vg_scaner
    FROM vekp
    WHERE exidv2 = lv_exidv.
  ENDIF.
*<-- End cbarrera.20220624

  IF sy-tcode NE 'ZSDTR_0003'.
    SELECT SINGLE * INTO sg_zitem
      FROM zhuinv_item
     WHERE exidv = vg_scaner.
  ELSE.
    " Se coloca 4 para que haga la verificación en la tabla interna
    sy-subrc = 4.
  ENDIF.

  IF sy-subrc NE 0.
    READ TABLE tg_item INTO sg_zitem
    WITH KEY exidv = vg_scaner.
  ENDIF.

ENDFORM.                    " F_SCANER_REPETIDO
************************************************************************
* Proyecto...: PPA Evolution                                           *
* Subrutina..: F_MOD_PO                                                *
* Autor......: ROBERTO BAUTISTA DOMINGUEZ                              *
* Fecha......: 19/04/2016                                              *
* Función....: Modifica las cantidades del pedido de compras           *
************************************************************************
FORM f_mod_po .

  DATA:
    tl_return  TYPE STANDARD TABLE OF bapiret2,
    tl_poitem  TYPE STANDARD TABLE OF bapimepoitem,
    tl_poitemx TYPE STANDARD TABLE OF bapimepoitemx.

  DATA:
    sl_return  TYPE bapiret2,
    sl_poitem  TYPE bapimepoitem,
    sl_poitemx TYPE bapimepoitemx.

  DATA:
    vl_po LIKE  bapimepoheader-po_number.

  CLEAR: tl_return,tl_poitem,tl_poitemx.

  LOOP AT tg_p101 INTO sg_p101.

*    IF sg_p101-pikmg > sg_p101-lfimg. "Mod 20221115

    vl_po              = sg_p101-vgbel.
    sl_poitem-po_item  = sg_p101-vgpos.
    sl_poitem-quantity = sg_p101-pikmg.
    sl_poitem-po_unit  = sg_p101-meins.

    sl_poitemx-po_item  = sg_p101-vgpos.
    sl_poitemx-quantity = 'X'.

    APPEND sl_poitem  TO tl_poitem.
    APPEND sl_poitemx TO tl_poitemx.
    CLEAR: sl_poitem,sl_poitemx.

*    ENDIF.

  ENDLOOP.

  IF tl_poitem[] IS NOT INITIAL.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = vl_po
      TABLES
        return        = tl_return
        poitem        = tl_poitem
        poitemx       = tl_poitemx.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    LOOP AT tl_return INTO sl_return.

      sg_msj-msgtyp = sl_return-type.
      sg_msj-msgid  = sl_return-id.
      sg_msj-msgnr  = sl_return-number.
      sg_msj-msgv1  = sl_return-message_v1.
      sg_msj-msgv2  = sl_return-message_v2.
      sg_msj-msgv3  = sl_return-message_v3.
      sg_msj-msgv4  = sl_return-message_v3.

      CASE sl_return-type.
        WHEN 'S'.
          PERFORM f_msg_add USING sg_msj '3'.
        WHEN 'E'.
          vg_error     = abap_true.
          PERFORM f_msg_add USING sg_msj '1'.
        WHEN OTHERS.
          PERFORM f_msg_add USING sg_msj '2'.
      ENDCASE.

    ENDLOOP.
  ENDIF.

  PERFORM f_free USING vl_po.

ENDFORM.                    " F_MOD_PO
