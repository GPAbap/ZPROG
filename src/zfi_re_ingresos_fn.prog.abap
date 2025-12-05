*----------------------------------------------------------------------*
***INCLUDE ZFI_RE_INGRESOS_S4HANA_FN.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_Data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        textit_
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_Data .
  DATA: vl_sumaDz       TYPE dmbtr, vl_sumaRv TYPE dmbtr,
        vl_diferencia   TYPE dmbtr, vl_devoluciones TYPE dmbtr,
        vl_nc           TYPE dmbtr.

  DATA: rg_fechas  TYPE RANGE OF bsid_view-budat,
        wrg_fechas LIKE LINE OF rg_fechas.

  DATA vl_lineitems TYPE STANDARD TABLE OF bapi3007_2.

  DATA: vl_rebgz   TYPE rebzg, vl_zuonr TYPE dzuonr,
        vl_flag_rv.


  FIELD-SYMBOLS: <fs_initial>      TYPE zfi_st_ingresos,
                 <fs_head>         TYPE zfi_st_ingresos,
                 <fs_body>         TYPE zfi_st_ingresos,
                 <fs_bodyextra>    TYPE zfi_st_ingresos,
                 <fs_devoluciones> TYPE zfi_st_ingresos.


  SELECT kunnr, belnr
     FROM bsid_view
    WHERE bukrs = @s_bukrs AND
            gjahr =  @p_gjahr AND
            belnr IN @s_belnr AND
            monat IN @s_monat AND
            budat IN @s_budat AND
*            cpudt IN @s_CPUDT
            blart IN ( 'DZ','DK' )
UNION ALL
  SELECT kunnr, belnr
     FROM bsad_view
    WHERE bukrs = @s_bukrs AND
            gjahr =  @p_gjahr AND
            belnr IN @s_belnr AND
            monat IN @s_monat AND
            budat IN @s_budat AND
*            cpudt IN @s_CPUDT
            blart IN ( 'DZ','DK' )
INTO TABLE @DATA(it_customers)
"            AND xreversed NE 'X'. "si es X son documentos de Anulación
.

  SORT  it_customers BY kunnr.

  DELETE ADJACENT DUPLICATES FROM it_customers COMPARING kunnr.
  "Datos del cliente "
  SELECT kunnr, stcd1 , name1
    INTO TABLE @DATA(it_kna1)
    FROM kna1
    FOR ALL ENTRIES IN @it_customers
    WHERE kunnr = @it_customers-kunnr AND spras = 'S'.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
****"Indicadores de IVA
  SELECT mwskz, knumh
  INTO TABLE @DATA(it_a003)
  FROM a003
  WHERE
  kappl = 'TX' AND kschl = 'MWAS' AND aland = 'MX'.

  SELECT knumh, kbetr
    INTO TABLE @DATA(it_indiva)
   FROM konp
    FOR ALL ENTRIES IN @it_a003
          WHERE knumh = @it_a003-knumh.
  "---------------------------


  PERFORM create_dates CHANGING rg_fechas.
  SORT rg_fechas BY low high ASCENDING.
  READ TABLE rg_fechas INTO wrg_fechas INDEX 1.



  LOOP AT it_customers INTO DATA(wa_customers).
    REFRESH vl_lineitems.

    CALL FUNCTION 'BAPI_AR_ACC_GETSTATEMENT'
      EXPORTING
        companycode = s_bukrs
        customer    = wa_customers-kunnr
        date_from   = wrg_fechas-low
        date_to     = wrg_fechas-high
*       NOTEDITEMS  = ' '
*   IMPORTING
*       RETURN      =
      TABLES
        lineitems   = vl_lineitems.

    SORT vl_lineitems BY clr_doc_no.


    DATA(aux_items) = vl_lineitems[].
    "DELETE ADJACENT DUPLICATES FROM aux_items COMPARING clr_doc_no.
    DELETE aux_items WHERE doc_type = 'SU'.
    SELECT bukrs, belnr, gjahr, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev,h_bldat
               INTO TABLE @DATA(it_docBancotmp)
               FROM bseg
               FOR ALL ENTRIES IN @vl_lineitems
               WHERE belnr = @vl_lineitems-doc_no
               AND bukrs = @vl_lineitems-comp_code
               AND gjahr = @vl_lineitems-fisc_year
               AND bschl = '40'
               AND augbl NE ''
               .
    IF it_docBancotmp IS NOT INITIAL.
      SELECT bukrs, belnr, gjahr, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev, h_bldat
        INTO TABLE @DATA(it_docBanco)
    FROM bseg
    FOR ALL ENTRIES IN @it_docBancotmp
    WHERE augbl = @it_docBancotmp-augbl
    AND bukrs = @it_docBancotmp-bukrs
    AND gjahr = @it_docBancotmp-gjahr
    AND belnr NE @it_docBancotmp-belnr
    AND bschl = '50'
    AND fdlev = 'F1'
    and h_monat in @s_monat.
      .
    ENDIF.


    LOOP AT aux_items INTO DATA(wa_aux) WHERE doc_type = 'DZ' OR doc_type = 'DK'.
      READ TABLE vl_lineitems INTO DATA(wa_items) WITH KEY clr_doc_no = wa_aux-clr_doc_no.
      IF sy-subrc EQ 0.

        LOOP AT vl_lineitems INTO DATA(wa_ingresos) WHERE clr_doc_no = wa_aux-clr_doc_no AND doc_type = 'DZ' OR doc_type = 'DK'.


          APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_head>.
          <fs_head>-rbukrs = wa_ingresos-comp_code.
          <fs_head>-gjahr = wa_ingresos-fisc_year.
          <fs_head>-poper = wa_ingresos-fis_period.
          <fs_head>-budat = wa_ingresos-pstng_date.
          <fs_head>-cpudt = wa_ingresos-doc_date.
          <fs_head>-blart = wa_ingresos-doc_type.
          <fs_head>-belnr = wa_ingresos-doc_no.
          <fs_head>-valut = wa_ingresos-entry_date.
          <fs_head>-kunnr = wa_ingresos-customer.
*esta condición se realiza porque hay documentos DZ que se compensan
          IF wa_ingresos-db_cr_ind = 'H'.
            <fs_head>-tot_ingreso = wa_ingresos-net_amount.
          ELSE.
            <fs_head>-total = wa_ingresos-net_amount * -1.
          ENDIF.
**********************************************************************
          <fs_head>-moneda = wa_ingresos-t_currency.
          <fs_head>-xblnr = wa_ingresos-ref_doc_no.
          <fs_head>-augbl = wa_ingresos-clr_doc_no.
          READ TABLE it_kna1 INTO DATA(wa_kna1) WITH KEY kunnr = wa_ingresos-customer.
          IF sy-subrc EQ 0.
            <fs_head>-name1 = wa_kna1-name1.
            <fs_head>-stcd1 = wa_kna1-stcd1.
          ENDIF.

          READ TABLE it_docBancotmp INTO DATA(wa_banco) WITH KEY belnr = wa_ingresos-doc_no.
          IF sy-subrc EQ 0.
            READ TABLE it_docBanco INTO DATA(wa_doc) WITH KEY augbl = wa_banco-augbl.
            IF sy-subrc EQ 0.
              <fs_head>-DOC_banco = wa_doc-belnr.
              <fs_head>-valut = wa_doc-h_bldat.
            ENDIF.
          ENDIF.


          SELECT z~doc_pago, z~uuid, z~uuid_dr
            INTO TABLE @DATA(it_xmldz)
           FROM zalv_comp_pago AS z
          WHERE doc_pago = @wa_ingresos-doc_no
           AND bukrs = @wa_ingresos-comp_code
           AND gjahr = @wa_ingresos-fisc_year.

          IF sy-subrc EQ 0.
            READ TABLE it_xmldz INTO DATA(wa_xmldz) INDEX 1.
            IF sy-subrc EQ 0.
              <fs_head>-uuid_pago = wa_xmldz-uuid.
            ENDIF.
          ENDIF.


          SELECT belnr, rbukrs, gjahr, racct, valut, usnam
            INTO TABLE @DATA(it_acdoca)
          FROM acdoca
          WHERE belnr = @wa_ingresos-doc_no
          AND rbukrs = @wa_ingresos-comp_code
          AND gjahr = @wa_ingresos-fisc_year
          AND bschl = '40'
          AND vrgng EQ ''.

          IF sy-subrc EQ 0.
            READ TABLE it_acdoca INTO DATA(wa_acdoca) INDEX 1.
            "      IF sy-subrc EQ 0.
            <fs_head>-saknr = wa_acdoca-racct.
            <fs_head>-usnam = wa_acdoca-usnam.

            "      ENDIF.

            SELECT txt50
              INTO TABLE @DATA(it_skat)
              FROM skat
            WHERE saknr = @wa_acdoca-racct
              AND spras = 'S'.

            IF sy-subrc = 0.
              READ TABLE it_skat INTO DATA(wa_skat) INDEX 1.
              <fs_head>-banco = wa_skat-txt50.

            ENDIF.

          ENDIF.

          SELECT belnr, bukrs, gjahr, augdt, augbl, bschl, shkzg, mwskz, dmbtr,
            zuonr, sgtxt, hkont, kunnr, rebzg, h_waers, h_blart, h_budat,
            zzfpago, saknr, fdlev
            INTO TABLE @DATA(it_gkont)
            FROM bseg
               WHERE augbl = @wa_ingresos-doc_no
               AND bukrs = @wa_ingresos-comp_code.

          IF sy-subrc EQ 0.
            READ TABLE it_gkont INTO DATA(wa_gkont) INDEX 1.
            <fs_head>-gkont = wa_gkont-hkont.
          ENDIF.


          SELECT kurs3,waers
        INTO TABLE @DATA(it_bkpf)
        FROM bkpf
            WHERE bukrs = @wa_ingresos-comp_code AND
            gjahr =  @wa_ingresos-fisc_year AND
            belnr = @wa_ingresos-doc_no
            .
          IF sy-subrc = 0.
            READ TABLE it_bkpf INTO DATA(wa_bkpf) INDEX 1.

            IF wa_bkpf-waers EQ 'USD'.
              <fs_head>-tipocambio = wa_bkpf-kurs3.
            ELSE.
              <fs_head>-tipocambio = 0.
            ENDIF.

          ENDIF.
        ENDLOOP.


        vl_flag_rv = abap_false.

        LOOP AT vl_lineitems INTO DATA(wa_body) WHERE clr_doc_no = wa_aux-clr_doc_no AND doc_type = 'RV'.

          vl_flag_rv = abap_true.

          SELECT belnr, bukrs, gjahr, augdt, augbl, bschl, mwskz, dmbtr,
                zuonr, sgtxt, hkont, kunnr, rebzg, h_waers, h_blart, h_budat,h_bldat,
                valut, mwart, saknr, awkey, vbeln, fdlev,belnr AS belnr_bkpf, buzid, h_monat
            INTO TABLE @DATA(it_rv)
            FROM bseg
            WHERE belnr = @wa_body-doc_no
            AND bukrs = @wa_body-comp_code
            AND gjahr = @wa_body-fisc_year
            AND h_blart IN ('RV', 'DR','KD')
            AND bschl NE '01'
            .

**************se realizo este loop a la bseg porque en la Bapi trae la factura totalizada real y quieren ver la factura en detalle
************* por si tiene devoluciones.*********************

          LOOP AT it_rv INTO DATA(wa_rv) WHERE buzid IS INITIAL.
            APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_body>.
            MOVE-CORRESPONDING <fs_head> TO <fs_body>.
            CLEAR: <fs_body>-blart,<fs_body>-tot_ingreso, <fs_body>-augbl, <fs_body>-gkont.
            <fs_body>-rbukrs = <fs_head>-rbukrs.
            <fs_body>-gjahr = wa_rv-gjahr.
            <fs_body>-poper = wa_rv-h_monat.
            <fs_body>-belnr = <fs_head>-belnr.
            <fs_body>-valut = wa_rv-valut.
            <fs_body>-budat = wa_rv-h_budat.
            <fs_body>-cpudt = wa_rv-h_bldat.
            <fs_body>-kunnr = <fs_head>-kunnr.

            <fs_body>-blart_rv = wa_body-doc_type.
            <fs_body>-rebzg = wa_body-doc_no.
            <fs_body>-augbl = wa_body-clr_doc_no.
            <fs_body>-zuonr = wa_body-alloc_nmbr.

            IF wa_rv-mwart NE 'A'.
              <fs_body>-gkont = wa_rv-hkont.
            ENDIF.

            IF wa_rv-bschl = '40'.
              <fs_body>-base = wa_rv-dmbtr * -1.
              <fs_body>-total = wa_rv-dmbtr * -1.
              <fs_body>-tot_ingreso = 0.
              <fs_body>-blart = space.
              <fs_body>-gkont = wa_rv-hkont.
              <fs_body>-forpago = space.
              <fs_body>-rebzg = wa_rv-belnr.
              <fs_body>-moneda = wa_rv-h_waers.
              <fs_body>-blart_rv = wa_rv-h_blart.
              <fs_body>-zuonr = wa_rv-awkey.
              <fs_body>-arktx = <fs_head>-arktx.
            ELSE. "es 50
              "IF wa_rv-zuonr IS INITIAL.

              "ELSE. "iva
              <fs_body>-base = <fs_body>-base + wa_rv-dmbtr.
              <fs_body>-total = <fs_body>-base + <fs_body>-iva.
              READ TABLE it_rv INTO DATA(wa_iva) WITH KEY buzid = 'T' belnr = <fs_body>-rebzg. "impuesto
              IF sy-subrc EQ 0.
                IF wa_rv-h_blart EQ 'DR' AND wa_rv-mwart EQ 'A'.
                  <fs_body>-iva = wa_rv-dmbtr.
                ELSEIF wa_rv-h_blart EQ 'DR' AND wa_rv-mwart IS INITIAL.
                  <fs_body>-base =  wa_rv-dmbtr.
                ELSE.
                  <fs_body>-zuonr = wa_iva-zuonr.
                  IF wa_rv-h_blart NE 'KD'.
                    <fs_body>-iva = wa_iva-dmbtr.
                  ELSE.
                    <fs_body>-iva = 0.
                  ENDIF.
                ENDIF.
              ENDIF.
              <fs_body>-total = <fs_body>-base + <fs_body>-iva.

              "ENDIF.
            ENDIF.
**********************************************************************
            "------SE IDENTIFICA LA TASA
            READ TABLE it_a003 INTO DATA(wa_a003) WITH KEY mwskz = wa_body-tax_code.
            IF sy-subrc EQ 0.
              READ TABLE it_indiva INTO DATA(wa_tasa) WITH KEY knumh = wa_a003-knumh.
              IF sy-subrc EQ 0.
                <fs_body>-tasa = wa_tasa-kbetr / 10.
*                <fs_body>-base = <fs_body>-total / (  1 + ( <fs_body>-tasa / 100 ) ).
*                <fs_body>-iva  = <fs_body>-base *  ( <fs_body>-tasa / 100 ).
              ENDIF.
            ENDIF.
            "----------------------------------------
            <fs_body>-moneda = wa_body-currency.
            <fs_body>-xblnr = <fs_head>-xblnr.

            "Datos de venta
            SELECT  vbeln, kvgr1, kvgr2, arktx, ernam "documento de venta, tipo de pago, metodo de pago
              INTO TABLE @DATA(it_vbrp)
            FROM vbrp AS b
            WHERE vbeln = @wa_body-alloc_nmbr.
            IF sy-subrc EQ 0.
              READ TABLE it_vbrp INTO DATA(wa_vbrp) INDEX 1.
              <fs_body>-arktx = wa_vbrp-arktx.
              <fs_body>-usnam = wa_vbrp-ernam.
              <fs_head>-arktx = wa_vbrp-arktx.
            ENDIF.
            "Fin datos de venta**********************************

            """"""Datos de timbrado
            SELECT z2~vbeln, z2~uuid, z2~metodo_pago, z2~forma_pago
            FROM zsd_cfdi_timbre AS z2
            WHERE vbeln = @wa_body-alloc_nmbr
            AND bukrs = @wa_body-comp_code
            AND gjahr = @wa_body-fisc_year
            INTO TABLE @DATA(it_uuidf).

            IF sy-subrc EQ 0.
              READ TABLE it_uuidf INTO DATA(wa_uuidf) WITH KEY vbeln = wa_body-alloc_nmbr.
              IF sy-subrc EQ 0.
                <fs_body>-uuid_dr = wa_uuidf-uuid.
                <fs_body>-metpago = wa_uuidf-metodo_pago.
                <fs_body>-forpago = wa_uuidf-forma_pago.
              ENDIF.
              <fs_body>-uuid_pago = <fs_head>-uuid_pago.
            ENDIF.

*******fin datos de timbrado
          ENDLOOP.
        ENDLOOP.
**********************************************************************
*****SE VALIDA SI ENCONTRO RV EN EL DOCUMENTO DE COMPENSACIÓN. SINO, SIGNIFICA QUE SE ABONO A UN RV DEL AÑO ANTERIOR
        IF vl_flag_rv EQ abap_false.

          SELECT belnr, bukrs, gjahr, augdt, augbl, bschl, mwskz, dmbtr,
            zuonr, sgtxt, hkont, kunnr, rebzg, h_waers, h_blart, h_budat,h_bldat,
            valut, mwart, saknr, awkey, vbeln, fdlev,belnr AS belnr_bkpf, buzid, h_monat
        INTO TABLE @DATA(it_rvant) "rv de año anterior
        FROM bseg
        WHERE belnr = @wa_ingresos-inv_ref
        AND bukrs = @wa_ingresos-comp_code
        AND gjahr = @wa_ingresos-inv_year
        AND h_blart IN ('RV', 'DR','KD')
        AND bschl NE '01'.

          IF sy-subrc NE 0.
            SELECT belnr, bukrs, gjahr
              INTO TABLE @DATA(it_rvaux)
            FROM bsad
            WHERE augbl = @wa_ingresos-clr_doc_no AND
            bukrs = @wa_ingresos-comp_code AND
            kunnr = @wa_ingresos-customer
            AND blart IN ('RV', 'DR','KD').

            IF sy-subrc EQ 0.

              READ TABLE it_rvaux INTO DATA(wa_rvaux) INDEX 1.

              SELECT belnr, bukrs, gjahr, augdt, augbl, bschl, mwskz, dmbtr,
              zuonr, sgtxt, hkont, kunnr, rebzg, h_waers, h_blart, h_budat,h_bldat,
              valut, mwart, saknr, awkey, vbeln, fdlev,belnr AS belnr_bkpf, buzid, h_monat
              APPENDING TABLE @it_rvant "rv de año anterior
                  FROM bseg
                  WHERE belnr = @wa_rvaux-belnr
                  AND bukrs = @wa_rvaux-bukrs
                  AND gjahr = @wa_rvaux-gjahr
                  AND h_blart IN ('RV', 'DR','KD')
                  AND bschl NE '01'.

            ENDIF.
          ENDIF.

          IF it_rvant[] IS NOT INITIAL.
            LOOP AT it_rvant INTO DATA(wa_rvant) WHERE buzid IS INITIAL.
              APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_body>.
              MOVE-CORRESPONDING <fs_head> TO <fs_body>.
              CLEAR: <fs_body>-blart,<fs_body>-tot_ingreso, <fs_body>-augbl.
              <fs_body>-rbukrs = <fs_head>-rbukrs.
              <fs_body>-gjahr = wa_rvant-gjahr.
              <fs_body>-poper = wa_rvant-h_monat.
              <fs_body>-belnr = <fs_head>-belnr.
              <fs_body>-valut = wa_rvant-valut.
              <fs_body>-budat = wa_rvant-h_budat.
              <fs_body>-cpudt = wa_rvant-h_bldat.
              <fs_body>-kunnr = <fs_head>-kunnr.

              <fs_body>-blart_rv = wa_rvant-h_blart.
              <fs_body>-rebzg = wa_rvant-belnr.
              "<fs_body>-augbl = <-.
              <fs_body>-zuonr = wa_rvant-awkey.
              IF wa_rvant-bschl = '40'.
                <fs_body>-base = wa_rvant-dmbtr * -1.
                <fs_body>-total = wa_rvant-dmbtr * -1.
                <fs_body>-tot_ingreso = 0.
                <fs_body>-blart = space.
                <fs_body>-gkont = wa_rvant-hkont.
                <fs_body>-forpago = space.
                <fs_body>-rebzg = wa_rvant-belnr.
                <fs_body>-moneda = wa_rvant-h_waers.
                <fs_body>-blart_rv = wa_rvant-h_blart.
                <fs_body>-zuonr = wa_rvant-awkey.
                <fs_body>-arktx = <fs_head>-arktx.
              ELSE. "es 50
                "IF wa_rv-zuonr IS INITIAL.

                "ELSE. "iva
                <fs_body>-base = <fs_body>-base + wa_rvant-dmbtr.
                <fs_body>-total = <fs_body>-base + <fs_body>-iva.
                READ TABLE it_rv INTO DATA(wa_iva2) WITH KEY buzid = 'T' belnr = <fs_body>-rebzg. "impuesto
                IF sy-subrc EQ 0.
                  IF wa_rvant-h_blart EQ 'DR' AND wa_rvant-mwart EQ 'A'.
                    <fs_body>-iva = wa_rvant-dmbtr.
                  ELSEIF wa_rvant-h_blart EQ 'DR' AND wa_rvant-mwart IS INITIAL.
                    <fs_body>-base =  wa_rvant-dmbtr.
                  ELSE.
                    <fs_body>-zuonr = wa_iva2-zuonr.
                    IF wa_rvant-h_blart NE 'KD'.
                      <fs_body>-iva = wa_iva2-dmbtr.
                    ELSE.
                      <fs_body>-iva = 0.
                    ENDIF.
                  ENDIF.
                ENDIF.
                <fs_body>-total = <fs_body>-base + <fs_body>-iva.

                "ENDIF.
              ENDIF.
**********************************************************************
              "------SE IDENTIFICA LA TASA
              READ TABLE it_a003 INTO DATA(wa_a0032) WITH KEY mwskz = wa_body-tax_code.
              IF sy-subrc EQ 0.
                READ TABLE it_indiva INTO DATA(wa_tasa2) WITH KEY knumh = wa_a003-knumh.
                IF sy-subrc EQ 0.
                  <fs_body>-tasa = wa_tasa2-kbetr / 10.
                ENDIF.
              ENDIF.
              "----------------------------------------
              <fs_body>-moneda = wa_rvant-h_waers.
              <fs_body>-xblnr = <fs_head>-xblnr.

              IF wa_rvant-h_blart EQ 'RV'.
                "Datos de venta
                SELECT  vbeln, kvgr1, kvgr2, arktx, ernam "documento de venta, tipo de pago, metodo de pago
                  INTO TABLE @DATA(it_vbrp2)
                FROM vbrp AS b
                WHERE vbeln = @wa_rvant-awkey.

                IF sy-subrc EQ 0.
                  READ TABLE it_vbrp2 INTO DATA(wa_vbrp2) INDEX 1.
                  <fs_body>-arktx = wa_vbrp2-arktx.
                  <fs_body>-usnam = wa_vbrp2-ernam.
                  <fs_head>-arktx = wa_vbrp2-arktx.
                ENDIF.
              ENDIF.
              "Fin datos de venta**********************************

              """"""Datos de timbrado
              SELECT z3~vbeln, z3~uuid, z3~metodo_pago, z3~forma_pago
              FROM zsd_cfdi_timbre AS z3
              WHERE vbeln = @wa_rvant-belnr
              AND bukrs = @wa_rvant-bukrs
              AND gjahr = @wa_rvant-gjahr
              INTO TABLE @DATA(it_uuidf2).

              IF sy-subrc EQ 0.
                READ TABLE it_uuidf2 INTO DATA(wa_uuidf2) WITH KEY vbeln = wa_rvant-zuonr.
                IF sy-subrc EQ 0.
                  <fs_body>-uuid_dr = wa_uuidf2-uuid.
                  <fs_body>-metpago = wa_uuidf2-metodo_pago.
                  <fs_body>-forpago = wa_uuidf2-forma_pago.
                ENDIF.
                <fs_body>-uuid_pago = <fs_head>-uuid_pago.
              ENDIF.

            ENDLOOP.

          ENDIF.



        ENDIF.
*****************notas de credito
*    "notas de crédito-----------------------------------------------------------------
        IF <fs_body> IS ASSIGNED.
          SELECT rbukrs, gjahr, blart, belnr, hsl, zuonr, gkont, awref,
            rhcur, usnam
            INTO TABLE @DATA(it_nc)
          FROM acdoca
            WHERE
                zuonr = @<fs_body>-zuonr AND
                rbukrs = @<fs_body>-rbukrs AND
                gjahr = @<fs_body>-gjahr
                AND blart IN ('RP', 'RX')
                AND bschl = '11'.
          "----------------------------------------------------------------------------------
          IF sy-subrc EQ 0.
            "se busca el UUid de la nota de credito.
            SELECT bukrs, vbeln, forma_pago, metodo_pago, waers, uuid
              FROM zsd_cfdi_timbre
              FOR ALL ENTRIES IN @it_nc
                    WHERE vbeln = @it_nc-awref
                    AND bukrs = @it_nc-rbukrs
                    AND gjahr = @it_nc-gjahr
              INTO TABLE @DATA(it_xmlnc)
              .

            READ TABLE it_nc INTO DATA(wa_nc) INDEX 1.

            APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_body>.

            "se ajustan a datos correspondientes a NC.
            <fs_body>-metpago = space.
            <fs_body>-forpago = space.
            <fs_body>-blart_rv = wa_nc-blart.
            <fs_body>-rebzg = wa_nc-belnr.
            <fs_body>-zuonr = wa_nc-zuonr.
            <fs_body>-uuid_pago = space.
            <fs_body>-sgtxt = space.
            <fs_body>-gkont = wa_nc-gkont.
            <fs_body>-base = wa_nc-hsl.
            <fs_body>-total = wa_nc-hsl.
            <fs_body>-moneda = wa_nc-rhcur.
            <fs_body>-saknr = space.
            <fs_body>-usnam = wa_nc-usnam.
            <fs_body>-banco = space.
            <fs_body>-augbl = space.
            <fs_body>-DOC_banco = space.
            vl_nc = wa_nc-hsl.

            READ TABLE it_xmlnc INTO DATA(wa_xmlnc) WITH KEY vbeln = wa_nc-awref.
            IF sy-subrc EQ 0.
              <fs_body>-uuid_dr = wa_xmlnc-uuid.
              <fs_body>-moneda = wa_xmlnc-waers.
              <fs_body>-forpago = wa_xmlnc-forma_pago.
              <fs_body>-metpago = wa_xmlnc-metodo_pago.
            ENDIF.

          ENDIF.
        ENDIF.

        IF <fs_body> IS ASSIGNED.
          vl_sumarv = vl_sumarv + ( <fs_body>-base + <fs_body>-iva )  - vl_devoluciones + vl_nc.
        ENDIF.
**********************************************************************

      ENDIF.
      APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_body>.
    ENDLOOP.

  ENDLOOP.



  "nombre de la cuenta de mayor
**    SELECT saknr, txt50
**      INTO TABLE @DATA(it_skat)
**      FROM skat
**      FOR ALL ENTRIES IN @it_acdoca
**          WHERE saknr = @it_acdoca-racct
**      AND spras = 'S'.
*


*    "dz no compensados en su totalidad.
*    SELECT bukrs, gjahr,belnr, vbeln, rebzg, zuonr,
*          augdt, augbl, bschl, mwskz, dmbtr,
*          sgtxt, hkont, kunnr, h_waers, h_blart, h_budat,
*          zzfpago, saknr,fdlev
*      INTO TABLE @DATA(it_nocomp)
*      FROM bseg
*    FOR ALL ENTRIES IN @it_bkpf
*            WHERE belnr = @it_bkpf-belnr
*      AND bukrs = @it_bkpf-bukrs
*        AND gjahr = @it_bkpf-gjahr.
*    "AND fdlev = 'ZD'.
*
*    "nombre de la cuenta de mayor de CI
*    SELECT saknr, txt50
*    INTO TABLE @DATA(it_skatnocomp)
*          FROM skat
*          FOR ALL ENTRIES IN @it_nocomp
*          WHERE saknr = @it_nocomp-hkont
*          AND spras = 'S'.
*
*
*



ENDFORM.


FORM create_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
*     I_INTERNAL_TABNAME     =
      i_structure_name       = 'ZFI_ST_INGRESOS'
      i_client_never_display = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.


  LOOP AT gt_fieldcat INTO wa_fieldcat.
    CASE wa_fieldcat-fieldname.
      WHEN 'CPUDT'.
        wa_fieldcat-seltext_s = 'Fec. Contab.'.
        wa_fieldcat-seltext_m = 'Fec. Contab.'.
        wa_fieldcat-seltext_l = 'Fec. Contab.'.
      WHEN 'BUDAT'.
        wa_fieldcat-seltext_s = 'Fec. Registro'.
        wa_fieldcat-seltext_m = 'Fec. Registro'.
        wa_fieldcat-seltext_l = 'Fec. Registro'.
      WHEN 'AWREF'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'TOTAL'.
        wa_fieldcat-decimals_out = 2.
      WHEN 'TOT_INGRESO'.
        wa_fieldcat-decimals_out = 2.
      WHEN 'TASA'.
        wa_fieldcat-decimals_out = 2.
      WHEN 'ZUONR'.
        wa_fieldcat-seltext_l = 'Fact. Venta'.
      WHEN 'BANCO'.
        wa_fieldcat-seltext_s = 'Banco'.
        wa_fieldcat-seltext_m = 'Banco'.
        wa_fieldcat-seltext_l = 'Banco'.
      WHEN 'GKONT'.
        wa_fieldcat-seltext_s = 'Cuenta'.
        wa_fieldcat-seltext_m = 'Cuenta'.
        wa_fieldcat-seltext_l = 'Cuenta'.
      WHEN 'ARKTX'.
        wa_fieldcat-seltext_s = 'Concepto'.
        wa_fieldcat-seltext_m = 'Concepto Bien'.
        wa_fieldcat-seltext_l = 'Concepto Bien o Serv.'.

      WHEN 'SGTXT'.
        wa_fieldcat-seltext_s = 'Referencia'.
        wa_fieldcat-seltext_m = 'Refereccia'.
        wa_fieldcat-seltext_l = 'Referecia'.
      WHEN 'XBLNR'.
        wa_fieldcat-seltext_s = 'Forma Pago'.
        wa_fieldcat-seltext_m = 'Forma Pago'.
        wa_fieldcat-seltext_l = 'Forma de Pago'.
      WHEN 'BUZEI'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'TIPOCAMBIO'.
        wa_fieldcat-seltext_s = 'Tipo Cambio'.
        wa_fieldcat-seltext_m = 'Tipo Cambio'.
        wa_fieldcat-seltext_l = 'Tipo de Cambio'.
      WHEN 'FECHACONV'.
        wa_fieldcat-seltext_s = 'Fec. Conv.'.
        wa_fieldcat-seltext_m = 'Fec. Conv.'.
        wa_fieldcat-seltext_l = 'Fecha Conversión'.
      WHEN 'BSCHL'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'FDLEV'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'WSL'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'NOM_RET'.
        wa_fieldcat-no_out = 'X'.
      WHEN OTHERS.
    ENDCASE.
    MODIFY gt_fieldcat FROM wa_fieldcat.
  ENDLOOP.


ENDFORM.

FORM show_alv.

  lf_layout-zebra = 'X'.
  lf_layout-colwidth_optimize = 'X'.

  DATA w_sort TYPE slis_sortinfo_alv.
  w_sort-spos = 1.
  w_sort-fieldname = 'REBZG'.
  w_sort-subtot = 'X'.
  APPEND w_sort TO t_sort.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER = ' '
*     I_BUFFER_ACTIVE    = ' '
      i_callback_program = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME   =
*     I_BACKGROUND_ID    = ' '
*     I_GRID_TITLE       =
*     I_GRID_SETTINGS    =
      is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
*     it_sort            = t_sort
    TABLES
      t_outtab           = it_ingresos
* EXCEPTIONS
*     PROGRAM_ERROR      = 1
*     OTHERS             = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_inversiones
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_inversiones .

  FIELD-SYMBOLS <fs_inversiones> TYPE zfi_st_ingresos.
  DATA: hkont_ingreso TYPE hkont,
        hkont_egreso  TYPE hkont.


  SELECT bk~bukrs AS rbukrs, bk~gjahr, bk~monat AS poper, bk~cpudt, bk~budat,
    bk~belnr, b~hkont AS saknr, b~dmbtr AS base, b~pswsl AS moneda,
    b~sgtxt, bk~usnam,b~fdtag AS augdt, b~kstar AS gkont,s~txt50 AS banco,
    b~buzei, b~bschl,b~fdlev, b~xauto
    FROM bkpf AS bk
    INNER JOIN bseg AS b
  ON b~bukrs = bk~bukrs AND b~gjahr = bk~gjahr AND  b~belnr = bk~belnr "OR b~augbl = bk~belnr )
  LEFT JOIN skat AS s ON s~saknr = b~hkont AND s~spras = 'S'
  WHERE  bk~bukrs = @s_bukrs AND
  bk~gjahr =  @p_gjahr AND
  bk~belnr IN @s_belnr AND"=  p_belnr and
  bk~monat IN @s_monat AND
  bk~budat IN @s_budat AND
*  bk~cpudt IN @s_CPUDT AND
  bk~blart EQ 'SA' AND
  b~sgtxt IS NOT INITIAL
  AND bk~xreversed NE 'X' "si es X son documentos de Anulación
  AND b~fdlev = 'F1' "solo Ingresos
    INTO CORRESPONDING FIELDS OF TABLE @it_inversiones.

  SELECT bk~bukrs AS rbukrs, bk~gjahr, bk~monat AS poper, bk~cpudt, bk~budat,
  bk~belnr, b~hkont AS saknr, b~dmbtr AS base, b~h_hwaer AS moneda,
  b~sgtxt, bk~usnam,b~fdtag AS augdt, b~kstar AS gkont,s~txt50 AS banco,
  b~buzei, b~bschl,b~fdlev, b~xauto

  FROM bkpf AS bk
  INNER JOIN bseg AS b
  ON b~bukrs = bk~bukrs AND b~gjahr = bk~gjahr AND  b~belnr = bk~belnr "OR b~augbl = bk~belnr )
  LEFT JOIN skat AS s ON s~saknr = b~hkont AND s~spras = 'S'
  WHERE  bk~bukrs = @s_bukrs AND
  bk~gjahr =  @p_gjahr AND
  bk~belnr IN @s_belnr AND"=  p_belnr and
  bk~monat IN @s_monat AND
  bk~budat IN @s_budat AND
*  bk~cpudt IN @s_CPUDT AND
  bk~blart EQ 'KL' AND
  b~sgtxt IS NOT INITIAL
  AND bk~xreversed NE 'X' "si es X son documentos de Anulación
  AND b~fdlev = 'F1' "solo Ingresos
  APPENDING CORRESPONDING FIELDS OF TABLE  @it_inversiones
  .


  "AND b~hkont NOT IN ('0504025014', '0504025192', '0601001020', '0601001073'). "Inversiones


  DELETE it_inversiones WHERE saknr CP '06*'.
  DELETE it_inversiones WHERE saknr CP '0115*'.
  DELETE it_inversiones WHERE saknr CP '0109*'.
  DELETE it_inversiones WHERE saknr CP '05*'.
  DELETE it_inversiones WHERE saknr CP '01190*'.
  DELETE it_inversiones WHERE saknr CP '01180*'.
  DELETE it_inversiones WHERE fdlev EQ 'ZK'.
  DELETE it_inversiones WHERE fdlev EQ 'ZD' AND bschl NE '11'.
  DELETE it_inversiones WHERE usnam EQ 'JOBSAP'.
  DELETE it_inversiones WHERE usnam EQ 'TR01'.

  IF it_inversiones[] IS NOT INITIAL.


    SELECT bukrs, belnr, gjahr, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev
    INTO TABLE @DATA(it_docBancotmp)
          FROM bseg
          FOR ALL ENTRIES IN @it_inversiones
          WHERE belnr = @it_inversiones-belnr
          AND bukrs = @it_inversiones-rbukrs
          AND gjahr = @it_inversiones-gjahr
          AND bschl = '40'
          AND augbl NE ''.


    SELECT bukrs, belnr, gjahr, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev, h_bldat
    INTO TABLE @DATA(it_docBanco)
          FROM bseg
          FOR ALL ENTRIES IN @it_docBancotmp
          WHERE augbl = @it_docBancotmp-augbl
          AND bukrs = @it_docBancotmp-bukrs
          AND gjahr = @it_docBancotmp-gjahr
          AND belnr NE @it_docBancotmp-belnr
          AND bschl = '50'
          AND h_blart EQ 'ZA'.


  ENDIF.

  SORT it_inversiones BY cpudt belnr blart.


  LOOP AT it_inversiones ASSIGNING <fs_inversiones>.

    CASE <fs_inversiones>-bschl.
      WHEN '40'.
        IF <fs_inversiones>-fdlev = 'F1'. "bandera ingreso transpaso
          <fs_inversiones>-tot_ingreso = <fs_inversiones>-base.
          <fs_inversiones>-base = <fs_inversiones>-base.
          <fs_inversiones>-total = <fs_inversiones>-base.
          READ TABLE it_inversiones INTO DATA(wa_F) WITH KEY belnr = <fs_inversiones>-belnr fdlev = 'F2' bschl = '50'.
          IF sy-subrc EQ 0.
            <fs_inversiones>-gkont = wa_F-saknr.
            DELETE it_inversiones WHERE ( fdlev EQ 'F2' OR fdlev EQ '' )  AND belnr = <fs_inversiones>-belnr AND bschl = '50'. "se elimina la bandera de Egresos.
          ELSE. "Por bug de cuando crean inversiones manuales, simula ser un traspaso.
            READ TABLE it_inversiones INTO DATA(wa_Fx) WITH KEY belnr = <fs_inversiones>-belnr fdlev = '' bschl = '50'.
            IF sy-subrc = 0.
              <fs_inversiones>-gkont = wa_Fx-saknr.
              DELETE it_inversiones WHERE ( fdlev EQ 'F2' OR fdlev EQ '' )  AND belnr = <fs_inversiones>-belnr AND bschl = '50'. "se elimina la bandera de Egresos.
            ELSE. "SPEI DEVOLUCION
              READ TABLE it_inversiones INTO DATA(wa_Fd) WITH KEY belnr = <fs_inversiones>-belnr fdlev = 'ZD' bschl = '11'.
              IF sy-subrc EQ 0.
                <fs_inversiones>-gkont = wa_Fd-saknr.
                DELETE it_inversiones WHERE ( fdlev EQ 'ZD' OR fdlev EQ '' )  AND belnr = <fs_inversiones>-belnr AND bschl = '11'. "se elimina la bandera de Egresos.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE. "inversion ingreso
          <fs_inversiones>-base = <fs_inversiones>-base.
          <fs_inversiones>-total = <fs_inversiones>-base.
          <fs_inversiones>-tot_ingreso = <fs_inversiones>-base.

          READ TABLE it_inversiones INTO DATA(wa_I) WITH KEY belnr = <fs_inversiones>-belnr xauto = 'X' bschl =  '50'. "indicador creado automatico inv. egresos.

          IF sy-subrc EQ 0.
            <fs_inversiones>-gkont = wa_I-saknr.
            DELETE it_inversiones WHERE ( xauto EQ 'X' OR xauto EQ '' )  AND belnr = <fs_inversiones>-belnr AND bschl = '50'. "se elimina la bandera de Egresos.
          ENDIF.
        ENDIF.
      WHEN '50'.
        "linea borrada en tiempo de ejecución
      WHEN OTHERS.
    ENDCASE.

    READ TABLE it_docBancotmp INTO DATA(wa_za) WITH KEY belnr = <fs_inversiones>-belnr.
    IF sy-subrc EQ 0.
      READ TABLE it_docbanco INTO DATA(wa_za2) WITH KEY augbl = wa_za-augbl.
      IF sy-subrc EQ 0.
        <fs_inversiones>-doc_banco = wa_za2-belnr.
        <fs_inversiones>-valut = wa_za2-h_bldat.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DELETE it_inversiones WHERE fdlev EQ 'F2'.

  APPEND LINES OF  it_inversiones TO it_ingresos.





ENDFORM.

FORM create_dates CHANGING p_rg_fechas.

  DATA: rg_fechas   TYPE RANGE OF bsid-budat,
        wa_rgfechas LIKE LINE OF rg_fechas.


  DATA: cadena      TYPE string,
        vl_fechaI   TYPE d,
        vl_fechaF   TYPE d,
        num_days    TYPE i,
        vl_poper(2) TYPE c,
        vl_gjahr    TYPE gjahr.

  SELECT poper FROM t009b
    INTO TABLE @DATA(it_009b)
    WHERE
    poper IN @s_monat
    GROUP BY poper  ORDER BY poper ASCENDING.

  REFRESH rg_fechas.
  LOOP AT it_009b INTO DATA(wa_poper).
    CLEAR wa_rgfechas.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_poper-poper
      IMPORTING
        output = vl_poper.

    CONCATENATE p_gjahr vl_poper '01' INTO cadena.
    vl_fechaI = cadena.
    PERFORM get_daysMonth USING vl_fechaI
                         CHANGING num_days.

    CONCATENATE p_gjahr vl_poper '01' INTO cadena.
    vl_fechaF = cadena.
    vl_fechaF+6(2) = num_days.
    wa_rgfechas-low = vl_fechaI.
    wa_rgfechas-high = vl_fechaF.
    wa_rgfechas-option = 'BT'.
    wa_rgfechas-sign = 'I'.
    APPEND wa_rgfechas TO rg_fechas.
  ENDLOOP.

  p_rg_fechas = rg_fechas.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_daysMonth
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- NUM_DATES
*&---------------------------------------------------------------------*
FORM get_daysMonth USING p_date TYPE d
                  CHANGING p_num_dates.

  DATA: xdatum TYPE d.

  xdatum = p_date.
  xdatum+6(2) = '01'.
  xdatum = xdatum + 35.          "para llegar seguro al proximo mes
  xdatum+6(2) = '01'. xdatum = xdatum - 1.
  p_num_dates = xdatum+6(2).


ENDFORM.
