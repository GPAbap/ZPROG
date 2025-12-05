************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZCONCILIACION_AUTOMATICA                      *
* Titulo              :  Conciliacion automatica                       *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : III.2021                                       *
************************************************************************
*&---------------------------------------------------------------------*
*& Report  ZCONCILIACION_AUTOMATICAV2
*&---------------------------------------------------------------------*
REPORT  zconciliacion_automaticav2.

INCLUDE zconc_aut_topv2.

INCLUDE zfb05_conc_automv2.


AT SELECTION-SCREEN.

START-OF-SELECTION.

  PERFORM fn_recursivo.


FORM fn_recursivo.
*---------------------------------recursividad.
  CLEAR:   i_zclientes_concil.
  REFRESH: i_zclientes_concil.

  IF p_kunnr-low IS NOT INITIAL.
    CLEAR v_kun_sel.
    v_kun_sel = p_kunnr-low.
    SHIFT v_kun_sel LEFT DELETING LEADING '0'.
    CONCATENATE '%' v_kun_sel '%' INTO v_kun_sel.

    PERFORM f_get_docs_pend.

    IF i_febep[] IS INITIAL.
      MESSAGE e001(00) WITH 'No existen datos para procesar.'.
    ELSE.
      PERFORM f_procesa_concil.
    ENDIF.

  ELSE.

    SELECT *
      FROM zclientes_concil
      INTO TABLE i_zclientes_concil.

    LOOP AT i_zclientes_concil.

      CLEAR: v_kunnr, v_kun_sel.
      v_kun_sel = i_zclientes_concil-kunnr.
      v_kunnr   = i_zclientes_concil-kunnr.
      SHIFT v_kun_sel LEFT DELETING LEADING '0'.
      CONCATENATE '%' v_kun_sel '%' INTO v_kun_sel.

      PERFORM f_get_docs_pend.

      IF i_febep[] IS INITIAL.
        CONTINUE.
*        MESSAGE E001(00) WITH 'No existen datos para procesar.'.
      ELSE.
        PERFORM f_procesa_concil.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF i_febep[] IS INITIAL.
    MESSAGE e001(00) WITH 'No existen datos para procesar.'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GENERA_DOC_PAGO
*&---------------------------------------------------------------------*
FORM f_get_docs_pend.

*** Extraer posiciones pendientes de contabilizar **********************************************************************
  CLEAR   i_febep.
  REFRESH i_febep.

  SELECT *
    FROM febep
    INTO TABLE i_febep
    WHERE nbbln = space                 " Documento contable relacionado
    AND   belnr NE space                " Documento contable
    AND   ( info2 LIKE v_kun_sel OR         " Interlocutor BBVA
            chect LIKE v_kun_sel OR
            butxt LIKE v_kun_sel ).         " Interlocutor BANAMEX



  SORT i_febep BY budat ASCENDING.
ENDFORM.




*&---------------------------------------------------------------------*
*&      Form  F_GENERA_DOC_PAGO
*&---------------------------------------------------------------------*
FORM f_genera_doc_pago .

  DATA: v_escenario TYPE string.
  CLEAR v_escenario.

  SORT i_facturas_pagar.
  LOOP AT i_facturas_pagar.
    CONCATENATE v_escenario i_facturas_pagar-tipo
      INTO v_escenario.
  ENDLOOP.

  DO 50 TIMES.
    REPLACE ALL OCCURRENCES OF '11' IN v_escenario WITH '1'.
  ENDDO.

  DO 50 TIMES.
    REPLACE ALL OCCURRENCES OF '22' IN v_escenario WITH '2'.
  ENDDO.

*** Escenarios posibles
*** E0 = REM(1)
*** E1 = REM(1) + TOT(2) + PAR(3)
*** E2 = REM(1) + TOT(2)
*** E3 = REM(1) + PAR(3)
*** E4 = TOT(2) + PAR(3)
*** E5 = TOT(2)
*** E6 = PAR(3)
BREAK jhernandev.

  IF v_escenario = '1'.
    PERFORM f_rem.
  ELSEIF v_escenario = '123'.
    PERFORM f_rem_tot_par.
  ELSEIF v_escenario = '12'.
    PERFORM f_rem_tot.
  ELSEIF v_escenario = '13'.
    PERFORM f_rem_par.
  ELSEIF v_escenario = '23'.
    PERFORM f_tot_par.
  ELSEIF v_escenario = '2'.
    PERFORM f_tot.
  ELSEIF v_escenario = '3'.
    PERFORM f_par.
  ENDIF.


*** Procesa la respuesta para extraer el numero de doc contable
  READ TABLE i_msg INTO wa_msg WITH KEY msgnr = '312'.
  IF sy-subrc EQ 0.
    DATA: v_nbbln LIKE febep-nbbln.
    CLEAR v_nbbln.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_msg-msgv1
      IMPORTING
        output = v_nbbln.

    UPDATE febep SET vb2ok = 'X'
                     nbbln = v_nbbln
                     gjahr = sy-datum+0(4)
                     WHERE kukey = i_febep-kukey
                       AND esnum = i_febep-esnum.
    COMMIT WORK AND WAIT.
  ELSE.
    LOOP AT i_msg INTO wa_msg.
      MESSAGE ID   wa_msg-msgid
              TYPE wa_msg-msgtyp
              NUMBER wa_msg-msgnr
              INTO i_log-msg
              WITH wa_msg-msgv1 wa_msg-msgv2 wa_msg-msgv3 wa_msg-msgv4.
      APPEND i_log.
      CLEAR i_log.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_GENERA_DOC_PAGO

*&---------------------------------------------------------------------*
*&      Form  F_FACTURAS_PENDIENTES_CLIENTE
*&---------------------------------------------------------------------*
FORM f_facturas_pendientes_cliente .

  CLEAR:   i_bsid, i_bsid_doc, i_saldos.
  REFRESH: i_bsid, i_bsid_doc, i_saldos.


*** Selecciona las partidas abiertas de ese cliente
*** aun despues de cada pago
  SELECT *
    FROM bsid
    INTO TABLE i_bsid
    WHERE bukrs = v_bukrs
    AND   kunnr = i_febep-kunnr
    AND   vbeln NE space
    AND   zlspr NE 'F'
    AND   ( blart = 'RV' OR
            blart = 'DZ' ).

  IF i_bsid[] IS INITIAL.
    EXIT.
  ENDIF.

*** Selecciona notas de credito referenciadas a esas facturas
  SELECT *
    FROM bsid
    APPENDING CORRESPONDING FIELDS OF TABLE i_bsid
    FOR ALL ENTRIES IN i_bsid
    WHERE bukrs = v_bukrs
    AND   kunnr = i_bsid-kunnr
    AND   zlspr NE 'F'
    AND   ( blart = 'RP' OR blart = 'RX' ).

  LOOP AT i_bsid.
    IF i_bsid-blart = 'RP'.
      i_bsid-vbeln = i_bsid-zuonr.
      MODIFY i_bsid.
    ENDIF.
  ENDLOOP.


  SORT i_bsid BY budat ASCENDING.
  i_bsid_doc[] = i_bsid[].
  LOOP AT i_bsid.
    MOVE-CORRESPONDING i_bsid TO i_saldos.
    IF i_bsid-blart = 'DZ' OR
       i_bsid-blart = 'RP' OR
       i_bsid-blart = 'RX' .
      i_saldos-saldo = i_bsid-dmbtr * -1.
    ELSE.
      i_saldos-saldo = i_bsid-dmbtr.
    ENDIF.
    CLEAR: i_saldos-budat,
           i_saldos-belnr.
    COLLECT i_saldos.
  ENDLOOP.

*** Asigna la fecha contabilizacion y el saldo original
*** de cada factura
  LOOP AT i_saldos.
    IF i_saldos-saldo <= 0.
      DELETE i_saldos.
      CONTINUE.
    ENDIF.
    READ TABLE i_bsid WITH KEY kunnr = i_saldos-kunnr
                               vbeln = i_saldos-vbeln
                               blart = 'RV'.
    IF sy-subrc EQ 0.
      i_saldos-budat    = i_bsid-budat.
      i_saldos-importe  = i_bsid-dmbtr.
      i_saldos-belnr    = i_bsid-belnr.
      i_saldos-waers    = i_bsid-waers.
      MODIFY i_saldos.
    ENDIF.
  ENDLOOP.
  SORT i_saldos BY budat vbeln ASCENDING.

ENDFORM.                    " F_FACTURAS_PENDIENTES_CLIENTE


*&---------------------------------------------------------------------*
*&      Form  bdc_build_script_record
*&---------------------------------------------------------------------*
FORM bdc_build_script_record USING dynbegin name value.

  IF dynbegin = 'X'.

    MOVE: name      TO bdcdata_wa-program,
          value     TO bdcdata_wa-dynpro,
          'X'       TO bdcdata_wa-dynbegin.
  ELSE.
    MOVE: name      TO bdcdata_wa-fnam,
          value     TO bdcdata_wa-fval,
          ' '       TO bdcdata_wa-dynbegin.
    SHIFT bdcdata_wa-fval LEFT DELETING LEADING space.
  ENDIF.

  APPEND bdcdata_wa TO bdcdata_tab.
  CLEAR bdcdata_wa.


ENDFORM.                    "bdc_build_script_record


*&---------------------------------------------------------------------*
*&      Form  F_FORMATO_CLIENTE
*&---------------------------------------------------------------------*
FORM f_formato_cliente USING p_febep_kunnr TYPE string.
  DATA: v_kunnr_existe TYPE kunnr,
        v_caract       TYPE i,
        v_len          TYPE i.


  SHIFT p_febep_kunnr LEFT DELETING LEADING '0'.
  SHIFT p_febep_kunnr LEFT DELETING LEADING 'C'.
  SHIFT p_febep_kunnr LEFT DELETING LEADING 'E'.
  v_len = strlen( p_febep_kunnr ).
  IF v_len >= 10.
    p_febep_kunnr = p_febep_kunnr+0(10).
  ELSE.
    p_febep_kunnr = p_febep_kunnr+0(v_len).
  ENDIF.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_febep_kunnr
    IMPORTING
      output = i_febep-kunnr.

  IF i_febep-kunnr CO '1234567890'.
  ELSE.
  ENDIF.

  IF i_febep-kunnr = 0.
  ENDIF.

*      V_FEBEP_KUNNR = I_FEBEP-CHECT+0(6).

  v_caract = strlen( p_febep_kunnr ).

*** Valida que el cliente exista, si no, le quita 1 hasta que lo encuentre
  DO.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_febep_kunnr
      IMPORTING
        output = i_febep-kunnr.

    CLEAR v_kunnr_existe.
    SELECT SINGLE kunnr
      FROM kna1
      INTO v_kunnr_existe
      WHERE kunnr = i_febep-kunnr.

    IF sy-subrc EQ 0.
      i_febep-kunnr = v_kunnr_existe.
      EXIT.
    ELSE.
      v_caract = v_caract - 1.

      CLEAR v_len.
      v_len = strlen( p_febep_kunnr ).
      IF v_len = 1.
        EXIT.
      ENDIF.
      p_febep_kunnr = p_febep_kunnr+0(v_caract).
    ENDIF.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROCESA_CONCIL
*&---------------------------------------------------------------------*
FORM f_procesa_concil .

  DATA: v_kunnr_existe TYPE kunnr,
        v_febep_kunnr  TYPE string,
        v_caract       TYPE i,
        v_len          TYPE i.
  DATA vl_recursivo.


*** Le da formato al numero de cliente
  LOOP AT i_febep.

    IF i_febep-info2 IS NOT INITIAL.
      v_febep_kunnr = i_febep-info2.
      PERFORM f_formato_cliente USING v_febep_kunnr.

    ELSEIF i_febep-chect IS NOT INITIAL.
      v_febep_kunnr = i_febep-chect.

      PERFORM f_formato_cliente USING v_febep_kunnr.

    ELSEIF i_febep-butxt IS NOT INITIAL.

      v_febep_kunnr = i_febep-butxt.
      PERFORM f_formato_cliente USING v_febep_kunnr.

    ENDIF.

    MODIFY i_febep.


  ENDLOOP.

  IF p_kunnr IS NOT INITIAL.
    LOOP AT i_febep.
      IF i_febep-kunnr NOT IN p_kunnr.
        DELETE i_febep.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF i_zclientes_concil[] IS NOT INITIAL.
    SORT i_febep BY kunnr.
    DELETE i_febep WHERE kunnr NE v_kunnr.
  ENDIF.

  DELETE i_febep WHERE kunnr IS INITIAL.


*  IF I_FEBEP[] IS INITIAL.
*    EXIT.
*  ELSE.
*
*  ENDIF.

*** Extrae datos adicionales del extracto cargado **********************************************************************
  CLEAR   i_febko.
  REFRESH i_febko.
  SELECT *
    FROM febko
    INTO TABLE i_febko
    FOR ALL ENTRIES IN i_febep
    WHERE kukey = i_febep-kukey.

*** Extrae datos generales del cliente **********************************************************************
  CLEAR   i_kna1.
  REFRESH i_kna1.
  SELECT *
    FROM kna1
    INTO TABLE i_kna1
    FOR ALL ENTRIES IN i_febep
    WHERE kunnr = i_febep-kunnr.

*** Elimina referencias de clientes que no sean reales
  LOOP AT i_febep.
    READ TABLE i_kna1 WITH KEY kunnr = i_febep-kunnr.
    IF sy-subrc NE 0.
      DELETE i_febep.
    ENDIF.
  ENDLOOP.

*** Se extraen las equivalencias de la forma de pago **********************************************************************
  SELECT *
    FROM zconc_forma_pago
    INTO TABLE i_zconc_forma_pago.

  CLEAR: v_importe_factura, v_saldo_factura,
         v_monto_disponible, v_saldo_agotado,
         i_facturas_pagar.

  REFRESH: i_facturas_pagar.

***********************************************
***          Tipos de pago                  ***
*** 1 = Remanente ; 2 = Total ; 3 = Parcial ***
***********************************************
*** Barre la tabla de pagos para buscar facturas de cada cliente
  SORT i_febep BY budat ASCENDING.
  DO.

*** Valida que aun existan registros a procesar
    IF i_febep[] IS INITIAL.
      EXIT.
    ENDIF.

    DATA: v_kunnr_bloq TYPE kunnr.
    CLEAR v_kunnr_bloq.

    CLEAR v_kunnr_bloq.
    SELECT SINGLE kunnr
      FROM zbloqueo_conci
      INTO v_kunnr_bloq
      WHERE kunnr = i_febep-kunnr.

    IF sy-subrc EQ 0.
      MESSAGE i001(00) WITH 'Cliente bloqueado.'.
      CONTINUE.
    ENDIF.

    CLEAR v_flag_fb05.
*** Lee el primer ingreso
    READ TABLE i_febep INDEX 1.

    READ TABLE i_febko WITH KEY kukey = i_febep-kukey.
    IF sy-subrc NE 0.
      DELETE i_febep INDEX 1.
      CLEAR i_facturas_pagar.
      REFRESH i_facturas_pagar.
    ENDIF.
    v_bukrs = i_febko-bukrs.          " Sociedad
    v_cta   = i_febko-hkont + 1.          " Cuenta banco

*** Extrae las facturas con saldo del cliente, lo debe
*** hacer para cada registro, para considerar el pago previo
    PERFORM f_facturas_pendientes_cliente.

*** Si no hay facturas pendientes sigue.
    IF i_saldos[] IS INITIAL.
      DELETE i_febep INDEX 1.
      CONTINUE.
    ENDIF.

*** Procesa la factura pendiente
    CLEAR v_monto_disponible.
    v_monto_disponible = i_febep-kwbtr.
**-------Se busca que el monto del ingreso sea igual a uno de las facturas que estén pendientes.
    READ TABLE i_saldos INTO DATA(wa_saldos) WITH KEY importe = v_monto_disponible saldo = v_monto_disponible .
    IF sy-subrc EQ 0.
      i_facturas_pagar-tipo = '2'.   " Total
      i_facturas_pagar-vbeln      = wa_saldos-vbeln.
      i_facturas_pagar-netwr      = wa_saldos-saldo.
      i_facturas_pagar-budat      = wa_saldos-budat.
      i_facturas_pagar-fecha_doc  = i_febep-budat.
      i_facturas_pagar-kunnr      = wa_saldos-kunnr.
      i_facturas_pagar-waers      = wa_saldos-waers.
      i_facturas_pagar-belnr      = wa_saldos-belnr.
      APPEND i_facturas_pagar.
      v_monto_disponible = v_monto_disponible - wa_saldos-saldo.
      v_flag_fb05 = 'X'.


  ELSE.
**---------------------------------------------------------------------------------------------------

    LOOP AT i_saldos WHERE kunnr = i_febep-kunnr.
*** Asigna montos de factura (importe y saldo)
      CLEAR: v_importe_factura, v_saldo_factura.
      v_importe_factura = i_saldos-importe.
      v_saldo_factura   = i_saldos-saldo.
*** Tiene un saldo pendiente
      IF v_importe_factura > v_saldo_factura.
*** El monto del pago cubre el saldo
        IF v_monto_disponible >= v_saldo_factura.
          i_facturas_pagar-tipo = '1'.  " Remanente
          i_facturas_pagar-vbeln      = i_saldos-vbeln.
          i_facturas_pagar-netwr      = v_saldo_factura.
          i_facturas_pagar-budat      = i_saldos-budat.
          i_facturas_pagar-fecha_doc  = i_febep-budat.
          i_facturas_pagar-kunnr      = i_saldos-kunnr.
          i_facturas_pagar-waers      = i_saldos-waers.
          i_facturas_pagar-belnr      = i_saldos-belnr.
          APPEND i_facturas_pagar.
          v_monto_disponible = v_monto_disponible - v_saldo_factura.
        ELSEIF v_monto_disponible < v_saldo_factura.
          i_facturas_pagar-tipo = '3'.  " Parcial
          i_facturas_pagar-vbeln      = i_saldos-vbeln.
          i_facturas_pagar-netwr      = v_saldo_factura.
          i_facturas_pagar-budat      = i_saldos-budat.
          i_facturas_pagar-fecha_doc  = i_febep-budat.
          i_facturas_pagar-kunnr      = i_saldos-kunnr.
          i_facturas_pagar-waers      = i_saldos-waers.
          i_facturas_pagar-belnr      = i_saldos-belnr.
          APPEND i_facturas_pagar.
          v_saldo_agotado = 'X'.
        ENDIF.
*** La factura no ha tenido pagos
      ELSEIF v_importe_factura = v_saldo_factura.
        IF v_monto_disponible >= v_saldo_factura.
          i_facturas_pagar-tipo = '2'.   " Total
          i_facturas_pagar-vbeln      = i_saldos-vbeln.
          i_facturas_pagar-netwr      = v_saldo_factura.
          i_facturas_pagar-budat      = i_saldos-budat.
          i_facturas_pagar-fecha_doc  = i_febep-budat.
          i_facturas_pagar-kunnr      = i_saldos-kunnr.
          i_facturas_pagar-waers      = i_saldos-waers.
          i_facturas_pagar-belnr      = i_saldos-belnr.
          APPEND i_facturas_pagar.
          v_monto_disponible = v_monto_disponible - v_saldo_factura.
        ELSEIF v_monto_disponible < v_saldo_factura.
          i_facturas_pagar-tipo = '3'.  " Parcial
          i_facturas_pagar-vbeln      = i_saldos-vbeln.
          "I_FACTURAS_PAGAR-NETWR      = V_SALDO_FACTURA.
          i_facturas_pagar-netwr      = v_monto_disponible.
          i_facturas_pagar-budat      = i_saldos-budat.
          i_facturas_pagar-fecha_doc  = i_febep-budat.
          i_facturas_pagar-kunnr      = i_saldos-kunnr.
          i_facturas_pagar-waers      = i_saldos-waers.
          i_facturas_pagar-belnr      = i_saldos-belnr.
          APPEND i_facturas_pagar.
          v_saldo_agotado = 'X'.
        ENDIF.
      ENDIF.
      IF v_saldo_agotado = 'X' OR v_monto_disponible = 0.
        v_flag_fb05 = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDIF.

  IF i_facturas_pagar[] IS NOT INITIAL AND
     v_flag_fb05 = 'X'.
*** Asigna forma de pago
    IF i_febep-vgext NE '079'.
      READ TABLE i_zconc_forma_pago WITH KEY vgext = i_febep-vgext.       " BBVA
    ELSE.
      READ TABLE i_zconc_forma_pago WITH KEY vgext = i_febep-intag.       " BANAMEX
    ENDIF.
    v_forma_pago = i_zconc_forma_pago-zzfpago.
*** Asigna textos de cabecera

    "*** Txt.cab.doc.
    CONCATENATE i_febep-kukey i_febep-esnum
      INTO v_bktxt.
    SHIFT v_bktxt LEFT DELETING LEADING '0'.

    "* Referencia
    CONCATENATE i_febko-hbkid i_febko-hktid
                i_febep-budat+2(2) i_febep-budat+4(2) i_febep-budat+6(2)
      INTO v_xblnr.

*** Ejecuta la transaccion FB05
    PERFORM f_genera_doc_pago.
    vl_recursivo = abap_true.
  ELSE. "Hay factura pendiente, pero ya no alcanza para cubrirla
    vl_recursivo = space.
  ENDIF.
*** Borra el registro de la tabla para no pagar doble
  DELETE i_febep INDEX 1.
  CLEAR i_facturas_pagar.
  REFRESH i_facturas_pagar.
  COMMIT WORK AND WAIT.
  WAIT UP TO 1 SECONDS.
  IF vl_recursivo EQ abap_true.
    PERFORM fn_recursivo.
  ENDIF.

ENDDO.

ENDFORM.                    " F_PROCESA_CONCIL
