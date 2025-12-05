*&---------------------------------------------------------------------*
*& Report  ZAXNAREP003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zaxnarep003_enh.

INCLUDE zaxnarep003_enh_f01.
*INCLUDE zaxnarep003_f01.


START-OF-SELECTION.

  DATA: lt_facturas_n TYPE zaxnare_tb001 OCCURS 0,
    lw_factura_n  TYPE zaxnare_tb001,
    lt_fact_mod_n TYPE zaxnare_tb001 OCCURS 0,
    ls_referencia TYPE zaxnare_tb002,
    lv_old_status TYPE rbstat,
    lv_tbl_lines  TYPE i,
    lv_test       TYPE c,
    lv_ejercicio  TYPE gjahr,
    lv_fact       TYPE re_belnr,
    lv_old_fpago  TYPE zaxnare_el017.

  DATA:lv_begin TYPE sydatum,
       lv_end   TYPE sydatum.

  FIELD-SYMBOLS:
                 <fs_fact_mod> TYPE zaxnare_tb001.

  " Rangos de selección para el estatus de las facturas
  RANGES: r_status FOR zaxnare_tb001-estatus.


  r_status-sign   = 'E'.
  r_status-option = 'EQ'.

*  r_status-low = 'D'.
*  APPEND r_status.

  r_status-low = 'X'.
  APPEND r_status.

  r_status-low = '2'.
  APPEND r_status.

  r_status-low = '3'.
  APPEND r_status.

  lv_begin = ( sy-datum - 90 ).
  lv_end = sy-datum.


*  IF lv_test EQ 'X'.
*
*    " Recorremos la tabla para ciertas facturas identificadas
*    SELECT *
*    FROM zaxnare_tb001
*    INTO TABLE lt_facturas_n
*    WHERE doc_factura EQ  lv_fact
*    AND ejercicio EQ lv_ejercicio
*    AND estatus IN r_status.
*
*  ELSE.
  " Recorremos la tabla de Facturas recibidas
  SELECT mandt, doc_factura, ejercicio, bukrs, rfc_e, tipo_comprobante,
        version, serie, folio, uuid, rfc_r, estatus, no_proveedor, f_factura,
        f_iso8601, sub_total, traslados, retenciones, total, moneda, doc_type,
        doc_ref, f_contable, f_vencimiento, f_pago, doc_contable, doc_comp,
        f_comp, no_cheque, doc_anulacion, ejer_anul, responsable, u_portal,
        f_registro, h_registro, xml_dir, pdf_dir, total_pagado, status_pago,
        esanticipo, metododepago, formadepago, uuid_rel, folio_interno
  FROM zaxnare_tb001
  INTO TABLE @lt_facturas_n
  WHERE doc_factura NE ''
  AND ejercicio NE ''
  AND estatus IN @r_status
  AND f_registro BETWEEN @lv_begin AND @lv_end.

*  ENDIF.

  CLEAR lt_fact_mod_n.

  LOOP AT lt_facturas_n INTO lw_factura_n.

    IF lw_factura_n-doc_contable IS NOT INITIAL.

      " Guardamos el estatus actual.
      CLEAR:
              lv_old_status,
              lv_old_fpago.

      lv_old_status = lw_factura_n-estatus.
      lv_old_fpago  = lw_factura_n-f_pago.

      CALL FUNCTION 'ZAXN_CFDS_ESTATUS'
        EXPORTING
          i_sociedad       = lw_factura_n-bukrs
          i_ejercicio      = lw_factura_n-ejercicio
          i_documento      = lw_factura_n-doc_contable
          i_estatus        = lw_factura_n-estatus
          i_u_portal       = lw_factura_n-u_portal
        IMPORTING
          e_estatus        = lw_factura_n-estatus
          e_fecha_contable = lw_factura_n-f_contable
          e_fecha_vento    = lw_factura_n-f_vencimiento
          e_doc_comp       = lw_factura_n-doc_comp
          e_fecha_comp     = lw_factura_n-f_comp
          e_fecha_pago     = lw_factura_n-f_pago
          e_no_cheque      = lw_factura_n-no_cheque.

      IF lv_old_status NE lw_factura_n-estatus.
        APPEND lw_factura_n TO lt_fact_mod_n.
      ELSEIF lv_old_fpago NE lw_factura_n-f_pago.
        APPEND lw_factura_n TO lt_fact_mod_n.
      ELSEIF lv_old_status EQ 'P'.
        APPEND lw_factura_n TO lt_fact_mod_n.
      ENDIF.

    ENDIF.

  ENDLOOP.

  DESCRIBE TABLE lt_fact_mod_n LINES lv_tbl_lines.

  IF lv_tbl_lines GT 0.

    " Modificamos la informacion de la factura recibida
    MODIFY zaxnare_tb001 FROM TABLE lt_fact_mod_n.

  ENDIF.

  PERFORM f_actualiza_referencia.

  LOOP AT lt_fact_mod_n ASSIGNING <fs_fact_mod>.

    IF <fs_fact_mod>-estatus EQ '2'
      OR <fs_fact_mod>-estatus EQ '3'
      OR <fs_fact_mod>-estatus EQ 'X'.

      SELECT * UP TO 1 ROWS
      INTO ls_referencia
      FROM zaxnare_tb002
      WHERE doc_factura EQ <fs_fact_mod>-doc_factura
      AND ejercicio EQ <fs_fact_mod>-ejercicio
      AND sociedad EQ <fs_fact_mod>-bukrs.
      ENDSELECT.

      IF sy-subrc EQ 0.

        DELETE zaxnare_tb002
        FROM ls_referencia.

      ENDIF.

    ENDIF.

  ENDLOOP.
