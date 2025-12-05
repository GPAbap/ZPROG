*&---------------------------------------------------------------------*
*&  Include           ZAXNAREP003_F01
*&---------------------------------------------------------------------*

FORM f_actualiza_referencia.

  DATA:
    lt_facturas_n TYPE STANDARD TABLE OF zaxnare_tb001,
    lt_fact_mod_n TYPE STANDARD TABLE OF zaxnare_tb001,
    lv_begin      TYPE sydatum,
    lv_end        TYPE sydatum,
    lv_belnr      TYPE belnr_d,
    lt_bkpf       TYPE STANDARD TABLE OF bkpf.

  FIELD-SYMBOLS:
    <fs_factura> TYPE zaxnare_tb001,
    <fs_bkpf>    TYPE bkpf.

  lv_begin = ( sy-datum - 90 ).
  lv_end = sy-datum.

  FREE:
        lt_facturas_n,
        lt_fact_mod_n.

  SELECT mandt, doc_factura, ejercicio, bukrs, rfc_e, tipo_comprobante,
        version, serie, folio, uuid, rfc_r, estatus, no_proveedor, f_factura,
        f_iso8601, sub_total, traslados, retenciones, total, moneda, doc_type,
        doc_ref, f_contable, f_vencimiento, f_pago, doc_contable, doc_comp,
        f_comp, no_cheque, doc_anulacion, ejer_anul, responsable, u_portal,
        f_registro, h_registro, xml_dir, pdf_dir, total_pagado, status_pago,
        esanticipo, metododepago, formadepago, uuid_rel, folio_interno
  FROM zaxnare_tb001
  INTO TABLE @lt_facturas_n
  WHERE estatus EQ 'D'
  AND f_registro BETWEEN @lv_begin AND @lv_end.

  IF sy-subrc EQ 0.

    SORT lt_facturas_n BY no_cheque.

    LOOP AT lt_facturas_n ASSIGNING <fs_factura>.

      IF <fs_factura>-doc_comp IS NOT INITIAL.

        IF <fs_factura>-no_cheque IS INITIAL.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <fs_factura>-doc_comp
            IMPORTING
              output = lv_belnr.

          FREE lt_bkpf.

          SELECT *
          INTO TABLE lt_bkpf
          FROM bkpf
          WHERE bukrs EQ <fs_factura>-bukrs
          AND belnr EQ lv_belnr
          AND gjahr EQ <fs_factura>-ejercicio.

          IF sy-subrc EQ 0.

            LOOP AT lt_bkpf ASSIGNING <fs_bkpf>.

              IF <fs_bkpf>-xblnr IS NOT INITIAL.

                <fs_factura>-no_cheque = <fs_bkpf>-xblnr.

                APPEND <fs_factura> TO lt_fact_mod_n.

                EXIT.

              ENDIF.

            ENDLOOP.

          ENDIF.

        ELSE.

          EXIT.

        ENDIF.

      ENDIF.

    ENDLOOP.

    IF lt_fact_mod_n[] IS NOT INITIAL.

      " Modificamos la informacion de la factura recibida
      MODIFY zaxnare_tb001
      FROM TABLE lt_fact_mod_n.

    ENDIF.

  ENDIF.

ENDFORM.                    "f_actualiza_referencia
