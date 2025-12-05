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

  DATA: vl_rebgz TYPE rebzg, vl_zuonr TYPE dzuonr.

  FIELD-SYMBOLS: <fs_initial>      TYPE zfi_st_ingresos,
                 <fs_head>         TYPE zfi_st_ingresos,
                 <fs_body>         TYPE zfi_st_ingresos,
                 <fs_bodyextra>    TYPE zfi_st_ingresos,
                 <fs_devoluciones> TYPE zfi_st_ingresos.


  SELECT bukrs, gjahr, belnr, blart, budat, usnam, bktxt, kurs3, monat, xblnr, cpudt, waers
      INTO TABLE @DATA(it_bkpf)
      FROM bkpf
          WHERE bukrs = @s_bukrs AND
          gjahr =  @p_gjahr AND
          belnr IN @s_belnr AND"=  p_belnr and
          monat IN @s_monat AND
          "a~xreversed NE 'X' AND "que no tome en cuenta posiciones Anuladas
          budat IN @s_budat AND
          cpudt IN @s_CPUDT
          AND blart IN ( 'DZ','DK' )
          AND xreversed NE 'X'. "si es X son documentos de Anulación

  "SORT it_bkpf BY budat.

  "obtenidos los DZ, obtenemos los documentos relacionados
  IF it_bkpf IS INITIAL.
    MESSAGE 'No hay Información que mostrar' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  SELECT belnr, bukrs, gjahr, augdt, augbl, bschl, shkzg, mwskz, dmbtr,
      zuonr, sgtxt, hkont, kunnr, rebzg, h_waers, h_blart, h_budat,
      zzfpago, saknr, fdlev
      INTO TABLE @DATA(it_bseg)
      FROM bseg
      FOR ALL ENTRIES IN @it_bkpf
          WHERE augbl = @it_bkpf-belnr
         AND bukrs = @it_bkpf-bukrs
         "AND gjahr = @it_bkpf-gjahr
        .

  SORT it_bseg BY augbl DESCENDING.


  SELECT belnr, rbukrs, gjahr, racct, valut, usnam
  INTO TABLE @DATA(it_acdoca)
        FROM acdoca
        FOR ALL ENTRIES IN @it_bkpf
        WHERE belnr = @it_bkpf-belnr
        AND rbukrs = @it_bkpf-bukrs
        AND gjahr = @it_bkpf-gjahr
        AND bschl = '40'
        AND vrgng EQ ''.

  SORT it_bseg BY augbl DESCENDING.



  IF it_bseg[] IS NOT INITIAL.


    SELECT z~doc_pago, z~uuid, z~uuid_dr
    INTO TABLE @DATA(it_xmldz)
          FROM zalv_comp_pago AS z
          FOR ALL ENTRIES IN @it_bseg
          WHERE doc_pago = @it_bseg-belnr
          AND bukrs = @it_bseg-bukrs
          AND gjahr = @it_bseg-gjahr.



    SELECT belnr, bukrs, gjahr, augdt, augbl, bschl, mwskz, dmbtr,
          zuonr, sgtxt, hkont, kunnr, rebzg, h_waers, h_blart, h_budat,h_bldat,
          valut, mwart, saknr, awkey, vbeln, fdlev,belnr AS belnr_bkpf
    INTO TABLE @DATA(it_rv)
          FROM bseg
          FOR ALL ENTRIES IN @it_bseg
          WHERE augbl = @it_bseg-belnr
          AND bukrs = @it_bseg-bukrs
          "AND gjahr = @it_bseg-gjahr
          AND h_blart IN ('RV', 'DR','KD').

  ENDIF.


  IF it_bkpf[] IS NOT INITIAL.
    SELECT rebzg AS belnr, bukrs, gjahr, augdt, augbl, bschl, mwskz, dmbtr,
          zuonr, sgtxt, hkont, kunnr, rebzg, h_waers, h_blart, h_budat,h_bldat,
          valut, mwart, saknr, awkey, vbeln, fdlev,belnr AS belnr_bkpf
    APPENDING TABLE @it_rv
          FROM bseg
          FOR ALL ENTRIES IN @it_bkpf
          WHERE belnr = @it_bkpf-belnr
          AND bukrs = @it_bkpf-bukrs
          AND gjahr = @it_bkpf-gjahr
          AND rebzg NE @space.

    SORT it_rv BY belnr.

  ENDIF.

  IF it_rv[] IS NOT INITIAL.
    "obtención de los UUID de las facturas de Venta
    SELECT z2~vbeln, z2~uuid, z2~metodo_pago, z2~forma_pago
    FROM zsd_cfdi_timbre AS z2
    FOR ALL ENTRIES IN @it_rv
    WHERE vbeln = @it_rv-vbeln
    AND bukrs = @it_rv-bukrs
    AND gjahr = @it_rv-gjahr
    INTO TABLE @DATA(it_uuidf).

    SELECT  belnr, bukrs, gjahr, augdt, augbl, bschl, mwskz, dmbtr,
    zuonr, sgtxt, hkont, kunnr, rebzg, h_waers, h_blart, h_budat,h_bldat,
    valut, mwart, saknr, awkey, vbeln, fdlev
      INTO TABLE @DATA(it_detalleRv)
      FROM bseg
    FOR ALL ENTRIES IN @it_rv
  WHERE belnr = @it_rv-belnr
          AND bukrs = @it_rv-bukrs
          AND gjahr = @it_rv-gjahr.
    SORT it_detalleRv BY belnr.

    "adecuación por si solo es parcialidad y para que la tabla Bseg no este vacia, cuando consultamos
    " por documento.
    IF it_bseg[] IS INITIAL.
      SELECT belnr, bukrs, gjahr, augdt, augbl, bschl, shkzg, mwskz, dmbtr,
              zuonr, sgtxt, hkont, kunnr, rebzg, h_waers, h_blart, h_budat,
              zzfpago, saknr, fdlev
    APPENDING TABLE @it_bseg
    FROM bseg
    FOR ALL ENTRIES IN @it_rv
        WHERE augbl = @it_rv-augbl
       AND bukrs = @it_rv-bukrs.

        SELECT z~doc_pago, z~uuid, z~uuid_dr
    APPENDING TABLE @it_xmldz
          FROM zalv_comp_pago AS z
          FOR ALL ENTRIES IN @it_bseg
          WHERE doc_pago = @it_bseg-belnr
          AND bukrs = @it_bseg-bukrs
          AND gjahr = @it_bseg-gjahr.
ENDIF.
    ENDIF.
    "nombre de la cuenta de mayor
    SELECT saknr, txt50
      INTO TABLE @DATA(it_skat)
      FROM skat
      FOR ALL ENTRIES IN @it_acdoca
          WHERE saknr = @it_acdoca-racct
      AND spras = 'S'.


    SELECT mwskz, knumh
      INTO TABLE @DATA(it_a003)
      FROM a003
      FOR ALL ENTRIES IN @it_rv
      WHERE mwskz = @it_rv-mwskz
      AND kappl = 'TX' AND kschl = 'MWAS' AND aland = 'MX'.

    SELECT knumh, kbetr
      INTO TABLE @DATA(it_indiva)
     FROM konp
      FOR ALL ENTRIES IN @it_a003
            WHERE knumh = @it_a003-knumh.


    SELECT kunnr, stcd1 , name1
      INTO TABLE @DATA(it_kna1)
      FROM kna1
      FOR ALL ENTRIES IN @it_bseg
      WHERE kunnr = @it_bseg-kunnr AND spras = 'S'.

    SELECT  vbeln, kvgr1, kvgr2, arktx, ernam "documento de venta, tipo de pago, metodo de pago
    INTO TABLE @DATA(it_vbrp)
          FROM vbrp AS b
          FOR ALL ENTRIES IN @it_rv
          WHERE vbeln = @it_rv-vbeln.
    "AND posnr = '000010'.

    "datos bancarios "cuenta de banco
    SELECT bukrs, belnr, gjahr, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev
      INTO TABLE @DATA(it_docBancotmp)
    FROM bseg
      FOR ALL ENTRIES IN @it_bkpf
      WHERE belnr = @it_bkpf-belnr
      AND bukrs = @it_bkpf-bukrs
      AND gjahr = @it_bkpf-gjahr
      AND bschl = '40'
      AND augbl NE ''
      .

    SELECT bukrs, belnr, gjahr, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev, h_bldat
    INTO TABLE @DATA(it_docBanco)
          FROM bseg
          FOR ALL ENTRIES IN @it_docBancotmp
          WHERE augbl = @it_docBancotmp-augbl
          AND bukrs = @it_docBancotmp-bukrs
          AND gjahr = @it_docBancotmp-gjahr
          AND belnr NE @it_docBancotmp-belnr
          AND bschl = '50'
          AND fdlev = 'F1'.
    .

    "notas de crédito-----------------------------------------------------------------
    SELECT rbukrs, gjahr, blart, belnr, hsl, zuonr, gkont, awref,
      rhcur, usnam
      INTO TABLE @DATA(it_nc)
    FROM acdoca
      WHERE rbukrs = @s_bukrs
          AND gjahr = @p_gjahr
          AND blart IN ('RP', 'RX')
          AND bschl = '11'.
    "----------------------------------------------------------------------------------
    "se busca el UUid de la nota de credito.
    SELECT bukrs, vbeln, forma_pago, metodo_pago, waers, uuid
      FROM zsd_cfdi_timbre
      FOR ALL ENTRIES IN @it_nc
            WHERE vbeln = @it_nc-awref
            AND bukrs = @it_nc-rbukrs
            AND gjahr = @it_nc-gjahr
      INTO TABLE @DATA(it_xmlnc)
      .



    "dz no compensados en su totalidad.
    SELECT bukrs, gjahr,belnr, vbeln, rebzg, zuonr,
          augdt, augbl, bschl, mwskz, dmbtr,
          sgtxt, hkont, kunnr, h_waers, h_blart, h_budat,
          zzfpago, saknr,fdlev
      INTO TABLE @DATA(it_nocomp)
      FROM bseg
    FOR ALL ENTRIES IN @it_bkpf
            WHERE belnr = @it_bkpf-belnr
      AND bukrs = @it_bkpf-bukrs
        AND gjahr = @it_bkpf-gjahr.
    "AND fdlev = 'ZD'.

    "nombre de la cuenta de mayor de CI
    SELECT saknr, txt50
    INTO TABLE @DATA(it_skatnocomp)
          FROM skat
          FOR ALL ENTRIES IN @it_nocomp
          WHERE saknr = @it_nocomp-hkont
          AND spras = 'S'.


    LOOP AT it_bkpf INTO DATA(wa_bkpf).  "Documento DZ

      CLEAR: vl_sumaDz, vl_sumaRv, vl_diferencia, vl_devoluciones, vl_nc.
      APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_head>.

      <fs_head>-rbukrs = wa_bkpf-bukrs.
      <fs_head>-gjahr = wa_bkpf-gjahr.
      <fs_head>-poper = wa_bkpf-monat.
      <fs_head>-blart = wa_bkpf-blart.
      <fs_head>-cpudt = wa_bkpf-cpudt.
      <fs_head>-belnr = wa_bkpf-belnr.
      <fs_head>-budat = wa_bkpf-budat.
      <fs_head>-usnam = wa_bkpf-usnam.


      "documento Banco ZA
      READ TABLE it_docBancotmp INTO DATA(wa_tmp) WITH KEY belnr = wa_bkpf-belnr.
      IF sy-subrc EQ 0.

        READ TABLE it_docBanco INTO DATA(wa_doc) WITH KEY augbl = wa_tmp-augbl.
        IF sy-subrc EQ 0.
          <fs_head>-DOC_banco = wa_doc-belnr.
          <fs_head>-valut = wa_doc-h_bldat.
        ENDIF.
      ENDIF.



      READ TABLE it_bseg INTO DATA(wa_bseg) WITH KEY belnr = wa_bkpf-belnr. "se obtiene primero el docto dZ para opbtener el doc. de compensanción
      IF sy-subrc EQ 0.
        "se buscan los datos del cliente
        READ TABLE it_kna1 INTO DATA(wa_kna1) WITH KEY kunnr = wa_bseg-kunnr.
        <fs_head>-kunnr = wa_kna1-kunnr.
        <fs_head>-stcd1 = wa_kna1-stcd1.
        <fs_head>-name1 = wa_kna1-name1.

        READ TABLE it_docBancotmp INTO DATA(wa_ingreso) WITH KEY belnr = wa_bkpf-belnr fdlev = 'F1'.
        IF sy-subrc = 0.
          <fs_head>-tot_ingreso = wa_ingreso-dmbtr.
        ELSE.
          <fs_head>-tot_ingreso = wa_bseg-dmbtr.
        ENDIF.

        vl_sumaDz = <fs_head>-tot_ingreso.

        <fs_head>-moneda = wa_bkpf-waers.

        <fs_head>-xblnr = wa_bkpf-xblnr.
        <fs_head>-metpago = wa_bseg-zzfpago.

        READ TABLE it_xmldz INTO DATA(wa_xmldz) WITH KEY doc_pago = wa_bseg-belnr.
        IF sy-subrc EQ 0.
          <fs_head>-uuid_pago = wa_xmldz-uuid.

        ENDIF.

        "-------por si no entra a los ciclos de factura relacionada
        <fs_head>-gkont = wa_bseg-hkont.


        READ TABLE it_skat INTO DATA(wa_skat0) WITH KEY saknr = wa_bseg-hkont.
        IF sy-subrc = 0.
          <fs_head>-banco = wa_skat0-txt50.
        ENDIF.
        "---------------------------------------------------------------------



      ELSE.
        CLEAR wa_bseg.

      ENDIF.
      "se busca el documento RV en base al documento de compensación

      "READ TABLE it_bseg INTO DATA(wa_rv) WITH KEY augbl = wa_bseg-augbl bschl = '01'.
      IF <fs_body> IS ASSIGNED.
        UNASSIGN <fs_body>.
      ENDIF.


      LOOP AT it_bseg INTO DATA(wa_rv) WHERE augbl = wa_bseg-augbl." and bschl = '01'.


        "IF sy-subrc EQ 0. "si hay factura se inserta la linea de body o factura.
        IF wa_rv-belnr NE wa_bseg-belnr.


          APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_body>. "suponiendo que solo es la factura sin movimientos extras

          CLEAR vl_zuonr.
          LOOP AT it_detalleRv INTO DATA(wa_detalleRv) WHERE belnr = wa_rv-belnr. "detalle factura RV

            IF wa_detalleRv-bschl NE '01'.
              IF wa_detalleRv-bschl EQ '40'.
                "0402001001 cuenta de devolciones
                IF wa_detalleRv-hkont EQ '0402001001' OR wa_detalleRv-hkont EQ '0402002001'.
                  vl_devoluciones = wa_detalleRv-dmbtr.
                  APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_devoluciones>.

                ENDIF.
              ELSE. " ES 50

                IF wa_detalleRv-zuonr IS INITIAL.
*              IF vl_restorv > 0 .
*                <fs_body>-base = 0.
*              ELSE.
                  <fs_body>-base = <fs_body>-base + wa_detalleRv-dmbtr.

                  <fs_body>-total = <fs_body>-base + <fs_body>-iva.
*              ENDIF.

                ELSE. "iva
                  IF wa_detalleRv-h_blart EQ 'DR' AND wa_detalleRv-mwart EQ 'A'.
                    <fs_body>-iva = wa_detalleRv-dmbtr.
                  ELSEIF wa_detalleRv-h_blart EQ 'DR' AND wa_detalleRv-mwart IS INITIAL.
                    <fs_body>-base =  wa_detalleRv-dmbtr.
                  ELSE.
                    <fs_body>-zuonr = wa_detalleRv-zuonr.
                    IF wa_detalleRv-h_blart NE 'KD'.
                      <fs_body>-iva = wa_detalleRv-dmbtr.
                    ELSE.
                      <fs_body>-iva = 0.
                    ENDIF.
                  ENDIF.

                  <fs_body>-total = <fs_body>-base + <fs_body>-iva.

                ENDIF.

                <fs_body>-rbukrs = wa_bkpf-bukrs.
                <fs_body>-gjahr = wa_bkpf-gjahr.
                <fs_body>-poper = wa_bkpf-monat.
                <fs_body>-blart_rv = wa_rv-h_blart.
                <fs_body>-rebzg = wa_rv-belnr.
                <fs_body>-budat = wa_bkpf-budat.
                <fs_body>-cpudt = wa_bkpf-cpudt.
                <fs_body>-belnr = wa_bkpf-belnr.
                <fs_body>-valut = <fs_head>-valut.
                <fs_head>-kunnr = wa_kna1-kunnr.
                <fs_head>-stcd1 = wa_kna1-stcd1.
                <fs_head>-name1 = wa_kna1-name1.
                <fs_head>-augbl = wa_bseg-augbl.
                <fs_body>-augbl = wa_bseg-augbl.
                <fs_body>-zuonr = wa_bseg-zuonr.
                <fs_head>-zuonr = wa_bseg-zuonr.

                IF wa_bkpf-waers EQ 'USD'.
                  <fs_head>-tipocambio = wa_bkpf-kurs3.
                ELSE.
                  <fs_head>-tipocambio = 0.
                ENDIF.

                <fs_body>-doc_banco = <fs_head>-doc_banco.

                IF wa_detalleRv-mwart NE 'A'.
                  <fs_body>-gkont = wa_detalleRv-hkont.
                ENDIF.


                <fs_body>-kunnr = wa_kna1-kunnr.
                <fs_body>-stcd1 = wa_kna1-stcd1.
                <fs_body>-name1 = wa_kna1-name1.

                READ TABLE it_rv INTO DATA(wa_rv2) WITH KEY belnr = wa_rv-belnr.
                IF sy-subrc EQ 0.
                  READ TABLE it_vbrp INTO DATA(wa_vbrp) WITH KEY vbeln = wa_rv2-vbeln.
                  IF sy-subrc EQ 0.
                    <fs_body>-arktx = wa_vbrp-arktx.
                    <fs_body>-usnam = wa_vbrp-ernam.
                    <fs_head>-arktx = wa_vbrp-arktx.
                  ENDIF.
                ENDIF.

                READ TABLE it_acdoca INTO DATA(wa_acdoca) WITH KEY belnr = wa_bkpf-belnr.
                IF sy-subrc EQ 0.
                  <fs_head>-saknr = wa_acdoca-racct.
                  <fs_body>-saknr = wa_acdoca-racct.
                ENDIF.

                READ TABLE it_skat INTO DATA(wa_skat) WITH KEY saknr = wa_acdoca-racct.
                IF sy-subrc = 0.
                  <fs_head>-banco = wa_skat-txt50.
                  <fs_body>-banco = wa_skat-txt50.
                ENDIF.

                READ TABLE it_uuidf INTO DATA(wa_uuidf) WITH KEY vbeln = wa_rv2-vbeln.
                IF sy-subrc EQ 0.
                  <fs_body>-uuid_dr = wa_uuidf-uuid.
                  <fs_body>-metpago = wa_uuidf-metodo_pago.
                  <fs_body>-forpago = wa_uuidf-forma_pago.
                ENDIF.
                <fs_body>-uuid_pago = <fs_head>-uuid_pago.

                "tasa
                READ TABLE it_a003 INTO DATA(wa_a003) WITH KEY mwskz = wa_rv-mwskz.
                IF sy-subrc EQ 0.
                  READ TABLE it_indiva INTO DATA(wa_tasa) WITH KEY knumh = wa_a003-knumh.
                  IF sy-subrc EQ 0.
                    <fs_body>-tasa = wa_tasa-kbetr / 10.

                  ENDIF.
                ENDIF.
              ENDIF.

            ELSE. "total de la factura. 01

              vl_zuonr = wa_detalleRv-zuonr.
*          IF vl_restorv > 0.
*            <fs_body>-total = vl_restorv.
*          ELSE.
              "<fs_body>-total = wa_detalleRv-dmbtr.
*          ENDIF.
            ENDIF. "if bschl
            IF <fs_devoluciones> IS ASSIGNED.
              <fs_devoluciones> = <fs_head>.
              <fs_devoluciones>-base = vl_devoluciones * -1.
              <fs_devoluciones>-total = vl_devoluciones * -1.
              <fs_devoluciones>-tot_ingreso = 0.
              <fs_devoluciones>-blart = space.
              <fs_devoluciones>-gkont = wa_detalleRv-hkont.
              <fs_devoluciones>-forpago = space.
              <fs_devoluciones>-zuonr = vl_zuonr.
              <fs_devoluciones>-rebzg = wa_detalleRv-belnr.
              <fs_devoluciones>-moneda = wa_detalleRv-h_waers.
              <fs_devoluciones>-blart_rv = wa_detalleRv-h_blart.
              <fs_devoluciones>-zuonr = wa_detalleRv-awkey.
              <fs_devoluciones>-arktx = <fs_head>-arktx.
              UNASSIGN <fs_devoluciones>.
            ENDIF.
            <fs_body>-zuonr = vl_zuonr.
          ENDLOOP. "loop detalle factura rv

          IF wa_rv-shkzg EQ 'H'. "Es un abono a factura que esta dentro del mismo doc. de compensación
            <fs_body> = <fs_head>.
            "<fs_body>-base = wa_rv-dmbtr.
            <fs_body>-tot_ingreso = wa_rv-dmbtr.
            vl_sumaDz = vl_sumaDz + <fs_body>-tot_ingreso.
            <fs_body>-rbukrs = wa_bkpf-bukrs.
            <fs_body>-gjahr = wa_bkpf-gjahr.
            <fs_body>-poper = wa_bkpf-monat.
            <fs_body>-blart_rv = wa_rv-h_blart.
            <fs_body>-rebzg = wa_rv-belnr.
            <fs_body>-budat = wa_bkpf-budat.
            <fs_body>-cpudt = wa_bkpf-cpudt.
            <fs_body>-belnr = wa_bkpf-belnr.
            <fs_body>-valut = <fs_head>-valut.
            <fs_head>-kunnr = wa_kna1-kunnr.
            <fs_head>-stcd1 = wa_kna1-stcd1.
            <fs_head>-name1 = wa_kna1-name1.
            <fs_head>-augbl = wa_bseg-augbl.
            <fs_body>-augbl = wa_bseg-augbl.
            <fs_body>-zuonr = wa_bseg-zuonr.
            "<fs_head>-zuonr = wa_bseg-zuonr.

*          IF wa_bkpf-waers EQ 'USD'.
*            <fs_head>-tipocambio = wa_bkpf-kurs3.
*          ELSE.
*            <fs_head>-tipocambio = 0.
*          ENDIF.

            <fs_body>-doc_banco = <fs_head>-doc_banco.

*          IF wa_detalleRv-mwart NE 'A'.
*            <fs_body>-gkont = wa_detalleRv-hkont.
*          ENDIF.


            <fs_body>-kunnr = wa_kna1-kunnr.
            <fs_body>-stcd1 = wa_kna1-stcd1.
            <fs_body>-name1 = wa_kna1-name1.

            READ TABLE it_acdoca INTO DATA(wa_acdocax) WITH KEY belnr = wa_bkpf-belnr.
            IF sy-subrc EQ 0.
              "<fs_head>-saknr = wa_acdoca-racct.
              <fs_body>-saknr = wa_acdoca-racct.
            ENDIF.

            READ TABLE it_skat INTO DATA(wa_skatx) WITH KEY saknr = wa_acdoca-racct.
            IF sy-subrc = 0.
              "<fs_head>-banco = wa_skat-txt50.
              <fs_body>-banco = wa_skat-txt50.
            ENDIF.

          ENDIF.

          "SE BUSCA NC si es que la hay, para el documento de Venta.
          READ TABLE it_nc INTO DATA(wa_nc) WITH KEY zuonr = <fs_body>-zuonr.
          IF sy-subrc EQ 0.
            "si encontro relación con la factura de venta, se agrega linea adicional.
            APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_bodyExtra>.
            <fs_bodyextra> = <fs_body>.
            "se ajustan a datos correspondientes a NC.
            <fs_bodyextra>-metpago = space.
            <fs_bodyExtra>-forpago = space.
            <fs_bodyExtra>-blart_rv = wa_nc-blart.
            <fs_bodyExtra>-rebzg = wa_nc-belnr.
            <fs_bodyExtra>-zuonr = wa_nc-zuonr.
            <fs_bodyExtra>-uuid_pago = space.
            <fs_bodyExtra>-sgtxt = space.
            <fs_bodyExtra>-gkont = wa_nc-gkont.
            <fs_bodyExtra>-base = wa_nc-hsl.
            <fs_bodyExtra>-total = wa_nc-hsl.
            <fs_bodyExtra>-moneda = wa_nc-rhcur.
            <fs_bodyExtra>-saknr = space.
            <fs_bodyExtra>-usnam = wa_nc-usnam.
            <fs_bodyExtra>-banco = space.
            <fs_bodyExtra>-augbl = space.
            <fs_bodyExtra>-DOC_banco = space.
            vl_nc = wa_nc-hsl.
            "se busca el UUID de la nota de crédito
            READ TABLE it_xmlnc INTO DATA(wa_xmlnc) WITH KEY vbeln = wa_nc-awref.
            IF sy-subrc EQ 0.
              <fs_bodyExtra>-uuid_dr = wa_xmlnc-uuid.
              <fs_bodyExtra>-moneda = wa_xmlnc-waers.
              <fs_bodyExtra>-forpago = wa_xmlnc-forma_pago.
              <fs_bodyExtra>-metpago = wa_xmlnc-metodo_pago.
            ENDIF.
          ENDIF.
          "----------------------------------------------------------------------------------
          vl_sumarv = vl_sumarv + ( <fs_body>-base + <fs_body>-iva )  - vl_devoluciones + vl_nc.
        ENDIF. "IF de igualdad documento compensación
      ENDLOOP.




      vl_diferencia = vl_sumaDz - vl_sumaRv.
      IF vl_sumaRv GT 0.
        IF vl_diferencia NE 0.
          APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_initial>.
          <fs_initial>-rebzg = '999999'. "wa_rv-belnr.
          <fs_initial>-belnr = wa_bkpf-belnr.
          <fs_initial>-arktx = 'DIFERENCIA PAGO VS FACTURAS'.
          <fs_initial>-base = vl_diferencia.
          <fs_initial>-total = vl_diferencia.
          UNASSIGN <fs_initial>.
        ENDIF.
      ENDIF.

      "-------------
      IF <fs_head>-saknr IS INITIAL.
        SELECT SINGLE hkont
      INTO <fs_head>-saknr
          FROM bseg
        WHERE belnr = wa_bkpf-belnr
          AND bukrs = wa_bkpf-bukrs
        AND gjahr = wa_bkpf-gjahr
          AND fdlev = 'F1'.

        SELECT SINGLE txt50
         INTO <fs_head>-banco
        FROM skat
         WHERE saknr = <fs_head>-saknr
          AND spras = 'S'.
      ENDIF.
      "----------------

    ENDLOOP. "bkpf





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

FORM get_texto.
  CLEAR gtext.
  CLEAR gtext2.
  CLEAR gtext3.

  IF s_bukrs IS NOT INITIAL.
    SELECT SINGLE butxt
    INTO gtext
    FROM t001
    WHERE bukrs = s_bukrs.
    ENDIF.


    IF S_monat-low IS NOT INITIAL.
      CASE s_monat-low.
        WHEN '01'.
          gtext3 = 'ENERO '.
        WHEN '02'.
          gtext3 = 'FEBRERO '.
        WHEN '03'.
          gtext3 = 'MARZO '.
        WHEN '04'.
          gtext3 = 'ABRIL '.
        WHEN '05'.
          gtext3 = 'MAYO '.
        WHEN '06'.
          gtext3 = 'JUNIO '.
        WHEN '07'.
          gtext3 = 'JULIO '.
        WHEN '08'.
          gtext3 = 'AGOSTO '.
        WHEN '09'.
          gtext3 = 'SEPTIEMBRE '.
        WHEN '10'.
          gtext3 = 'OCTUBRE '.
        WHEN '11'.
          gtext3 = 'NOVIEMBRE '.
        WHEN '12'.
          gtext3 = 'DICIEMBRE '.
        WHEN OTHERS.
      ENDCASE.
      CONCATENATE gtext3 p_gjahr INTO gtext3 SEPARATED BY space      .
*         GTEXT3 = 'JULIO 2017'.
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
  bk~cpudt IN @s_CPUDT AND
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
    bk~cpudt IN @s_CPUDT AND
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
