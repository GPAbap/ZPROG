*----------------------------------------------------------------------*
***INCLUDE ZFI_RE_INGRESOS_S4HANA_FN.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_Data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_Data .
  DATA: vl_sumaDz     TYPE dmbtr, vl_sumaRv TYPE dmbtr, vl_diferencia TYPE dmbtr.
  DATA vl_fconcil.
  DATA ruta_xml TYPE zaxnare_el034.
  DATA ruta_xml1  TYPE zaxnare_el034.
  DATA sruta_xml TYPE string.
  DATA: it_xmlsat TYPE TABLE OF smum_xmltb,
        wa_xmlsat TYPE smum_xmltb.

  DATA vl_banFF.
  DATA vl_ban19.

  DATA aux_au TYPE augbl.
  DATA aux_bl TYPE belnr_d.



  DATA: vl_isr_ret  TYPE dmbtr, vl_iva_ret TYPE dmbtr, vl_suma_ret TYPE dmbtr,vl_acumret TYPE dmbtr.
  DATA: vl_perdida  TYPE zutilperd,
        vl_utilidad TYPE zutilperd.

  DATA: vl_indretiva TYPE qsskz,
        vl_indretisr TYPE qsskz.

  DATA: lv_exist_prov.

  FIELD-SYMBOLS: <fs_head>      TYPE zfi_st_egresos, <fs_body> TYPE zfi_st_egresos,
                 <fs_headGV>    TYPE zfi_st_egresos,
                 <fs_headGVadd> TYPE zfi_st_egresos,
                 <fs_kr>        TYPE zfi_st_egresos,
                 <bseg2>        TYPE any,
                 <line>         TYPE any,
                 <line2>        TYPE any.

  CREATE OBJECT gcl_xml.

  "obtenemos los documentos de pago
  SELECT  b~bukrs, b~monat, b~gjahr, b~monat AS poper, b~bldat, b~cpudt, b~budat, b~blart, b~belnr, b~bktxt,
         b~hwaer, b~kursf, b~tcode,b~xblnr
         INTO TABLE @DATA(it_bkpf)
   " UP TO 100 ROWS
      FROM bkpf AS b
         WHERE b~bukrs = @s_bukrs AND
        b~gjahr =  @p_gjahr AND
        b~belnr IN @s_belnr AND"=  p_belnr and
        b~monat IN @s_monat AND
        b~budat IN @s_budat AND
        b~cpudt IN @s_CPUDT
        AND ( b~blart = 'KZ' OR b~blart = 'GV' OR b~blart = 'SB' OR b~blart = 'KD')
        AND xreversed NE 'X'. "No tomar en cuenta Documentos de Anulación
  SORT  it_bkpf BY belnr.

  "DELETE it_bkpf WHERE belnr CP '0400*'. "Patron de contenido. //04072023 Se vuelven
  "a dejar los documentos GV 04000, por petición del Usuario (Rene Arceo)

  IF it_bkpf IS INITIAL.

    EXIT.
  ENDIF.


  "buscamos en la ACDOCA esos documentos
  SELECT a~rbukrs, a~belnr, a~gjahr, a~budat, a~blart, a~valut,a~lifnr,
      a~rebzg, a~zuonr, a~gkont, a~augbl, a~hsl AS base, a~hsl AS total,
      a~hsl AS tot_egreso, a~rtcur AS moneda,a~sgtxt, a~augdt, a~usnam,a~racct, a~awref,
      a~bldat
    INTO TABLE @DATA(it_acdoca)
    FROM acdoca AS a
    FOR ALL ENTRIES IN @it_bkpf
  WHERE augbl = @it_bkpf-belnr
          AND rbukrs = @it_bkpf-bukrs AND auggj = @it_bkpf-gjahr.

  SORT it_acdoca BY belnr.

  DELETE ADJACENT DUPLICATES FROM it_acdoca COMPARING belnr.
  SORT it_acdoca BY augbl.

  IF it_acdoca[] IS NOT INITIAL.


    SELECT b~bukRs, b~blart, b~belnr, b~waers, b~kursf
      INTO TABLE @DATA(it_tipocambio)
      FROM bkpf AS b
    FOR ALL ENTRIES IN @it_acdoca
            WHERE bukrs = @it_acdoca-rbukrs
            AND belnr = @it_acdoca-belnr
            AND blart = @it_acdoca-blart
            AND waers = 'USD'.




    "datos del proveedor
    SELECT l~lifnr, l~stcd1, l~name1
      INTO TABLE @DATA(it_lfna1)
      FROM lfa1 AS l
      FOR ALL ENTRIES IN @it_acdoca
      WHERE lifnr EQ @it_acdoca-lifnr.

  ENDIF.
  "----------Datos de Pago y datos de perdida/utilidad cambiaria
  SELECT b~belnr,b~bukrs, b~gjahr,b~mwskz,b~qsskz, b~dmbtr, b~augbl,b~bschl, b~fdlev, b~hkont,
         b~gvtyp, b~shkzg, b~koart, b~xzahl, b~kunnr
    INTO TABLE @DATA(it_bseg)
    FROM bseg AS b
   FOR ALL ENTRIES IN @it_bkpf
          WHERE belnr = @it_bkpf-belnr AND gjahr = @it_bkpf-gjahr AND bukrs = @it_bkpf-bukrs.



  "datos del deudor/nomina
  SELECT k~kunnr, k~stcd1, k~name1
    INTO TABLE @DATA(it_kna1)
    FROM kna1 AS k
    FOR ALL ENTRIES IN @it_bseg
    WHERE kunnr EQ @it_bseg-kunnr.


  DELETE it_bseg WHERE hkont = '0601001058'.
  "---------------------------------------------
  "----------desglose de base IVA IVA RETENIDO EN LA FACTURA
*  IF it_acdoca[] IS NOT INITIAL.
  SELECT b~bukrs, b~belnr, b~buzei, b~augbl, b~buzid, b~shkzg, b~mwskz, b~dmbtr,b~hwbas, b~qbshb, b~bschl, b~hkont, b~mwart,
         b~sgtxt, b~ebeln, b~aufnr, h_budat, h_bldat, h_blart, b~pswsl AS moneda,b~lifnr, b~gjahr, b~koart, b~hwbas AS perutil,
         b~hkont AS ctaperutil, b~mwsk1, b~mwsk2, b~dmbt2,b~qsskz, h_monat, anln1
        INTO TABLE @DATA(it_bseg2)
        FROM bseg AS b
        FOR ALL ENTRIES IN @it_bkpf
        WHERE augbl = @it_bkpf-belnr  AND bukrs = @it_bkpf-bukrs
        AND auggj = @it_bkpf-gjahr. "auggj es el ejercicio de compensación

  IF it_bseg2[] IS NOT INITIAL.


    SELECT b~bukrs, b~belnr, b~buzei, b~augbl, b~buzid, b~shkzg, b~mwskz, b~dmbtr,b~hwbas, b~qbshb, b~bschl, b~hkont, b~mwart,
           b~sgtxt, b~ebeln, b~aufnr, h_budat, h_bldat, h_blart, b~pswsl AS moneda,b~lifnr, b~koart,b~gvtyp,
           b~hwbas AS perutil, b~hkont AS ctaperutil
          INTO TABLE @DATA(it_bseg3)
          FROM bseg AS b

          FOR ALL ENTRIES IN @it_bseg2
          WHERE b~belnr = @it_bseg2-belnr  AND bukrs = @it_bseg2-bukrs
          AND b~gjahr = @it_bseg2-gjahr
         .
    SORT it_bseg3 BY belnr.
    DELETE it_bseg3 WHERE gvtyp = 'X' AND dmbtr = '0.00' AND bschl = '50'.
    DELETE it_bseg3 WHERE gvtyp = 'X' AND dmbtr = '0.00' AND bschl = '40'.
  ENDIF.


  DATA(aux_bseg3) = it_bseg3[].
  DATA(aux_bseg2) = it_bseg2[].

  REFRESH aux_bseg2.

  SORT aux_bseg3 BY augbl.


  DELETE ADJACENT DUPLICATES FROM aux_bseg3 COMPARING augbl.
  DATA(aux_bseg3_2) = aux_bseg3[].
  DELETE aux_bseg3 WHERE augbl  NP '150*'.
  DELETE aux_bseg3_2 WHERE augbl  NP '190*'.

  LOOP AT aux_bseg3 INTO DATA(wa_aux).
    READ TABLE it_bseg2 INTO DATA(wa_aux2) WITH KEY belnr = wa_aux-augbl.
    IF sy-subrc NE 0.
      CLEAR wa_aux2.
      MOVE-CORRESPONDING wa_aux TO wa_aux2.
*      wa_aux2-belnr = wa_aux-augbl.
*      wa_aux2-augbl = wa_aux-belnr.
      APPEND wa_aux2 TO aux_bseg2.
    ENDIF.
  ENDLOOP.

  LOOP AT aux_bseg3_2 INTO wa_aux.
    READ TABLE it_bseg2 INTO wa_aux2 WITH KEY belnr = wa_aux-augbl.
    IF sy-subrc NE 0.
      CLEAR wa_aux2.
      MOVE-CORRESPONDING wa_aux TO wa_aux2.
*      wa_aux2-belnr = wa_aux-augbl.
*      wa_aux2-augbl = wa_aux-belnr.
      APPEND wa_aux2 TO aux_bseg2.
    ENDIF.
  ENDLOOP.


  IF aux_bseg2 IS NOT INITIAL.
    APPEND LINES OF aux_bseg2 TO it_bseg2.
  ENDIF.

  DATA xxx TYPE augbl.

  LOOP AT it_bseg2 ASSIGNING <bseg2>.
    IF <line> IS ASSIGNED.
      UNASSIGN <line>.
    ENDIF.

    ASSIGN COMPONENT 'AUGBL' OF STRUCTURE <bseg2> TO <line>.
    xxx = <line>.


    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
    READ TABLE it_bseg3 INTO DATA(wa_gkont1) WITH KEY belnr = <line> buzid = 'W'.
    UNASSIGN <line>.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'HKONT' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_gkont1-hkont.
      UNASSIGN <line>.
    ELSE.
      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
      READ TABLE it_bseg3 INTO DATA(wa_gkont0) WITH KEY belnr = <line> gvtyp = 'X'.
      UNASSIGN <line>.
      IF sy-subrc EQ 0.
        IF wa_gkont0-hkont EQ '0701001001' OR wa_gkont0-hkont EQ '0702001001'.

        ELSE.
          ASSIGN COMPONENT 'HKONT' OF STRUCTURE <bseg2> TO <line>.
          <line> = wa_gkont0-hkont.
          UNASSIGN <line>.
          CLEAR wa_gkont0.
        ENDIF.
      ENDIF.

      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
      READ TABLE it_bseg3 INTO DATA(wa_gkont2) WITH KEY belnr = <line> gvtyp = 'X' mwskz = 'X5'.

      IF sy-subrc EQ 0.
        ""
        DATA tmp_data TYPE dmbtr.
        DATA tmp_belnr TYPE belnr_d.
        tmp_belnr = <line>.
        UNASSIGN <line>.

        LOOP AT it_bseg3 INTO DATA(wa_x5) WHERE belnr = tmp_belnr AND gvtyp = 'X' AND mwskz = 'X5'.

          tmp_data = tmp_data + wa_x5-dmbtr.
        ENDLOOP.
        ""


*        IF wa_gkont2-bschl EQ '50'.
        ASSIGN COMPONENT 'HKONT' OF STRUCTURE <bseg2> TO <line>.
        <line> = wa_gkont2-hkont.
        UNASSIGN <line>.
*
*        ENDIF.

*        IF wa_gkont2-bschl NE '50'.
        ASSIGN COMPONENT 'MWSK2' OF STRUCTURE <bseg2> TO <line>.
        <line> = wa_gkont2-mwskz.
        UNASSIGN <line>.


        ASSIGN COMPONENT 'DMBT2' OF STRUCTURE <bseg2> TO <line>.
        "<line> = wa_gkont2-dmbtr.
        <line> = tmp_data.
        UNASSIGN <line>.

        CLEAR: wa_gkont2,tmp_data.
*        ENDIF.
        """""
      ENDIF.

    ENDIF.

    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
    READ TABLE it_bseg3 INTO DATA(wa_ebeln) WITH KEY belnr = <line> buzid = 'W'.
    UNASSIGN <line>.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'EBELN' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_ebeln-ebeln. "base 16/8
      UNASSIGN <line>.

      ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_ebeln-aufnr. "base 16/8
      UNASSIGN <line>.

      ASSIGN COMPONENT 'KOART' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_ebeln-koart. "base 16/8
      UNASSIGN <line>.

    ENDIF.


    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
    READ TABLE it_bseg3 INTO DATA(wa_ebeln0) WITH KEY belnr = <line> buzid = 'S'.
    UNASSIGN <line>.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'EBELN' OF STRUCTURE <bseg2> TO <line>.
      IF <line> IS INITIAL.
        <line> = wa_ebeln0-ebeln.
      ENDIF.
      UNASSIGN <line>.

      ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <bseg2> TO <line>.
      IF <line> IS INITIAL.
        <line> = wa_ebeln0-aufnr.
      ENDIF.
      UNASSIGN <line>.

      ASSIGN COMPONENT 'KOART' OF STRUCTURE <bseg2> TO <line>.
      IF <line> IS INITIAL.
        <line> = wa_ebeln0-koart.
      ENDIF.
      UNASSIGN <line>.

    ENDIF.




    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
    READ TABLE it_bseg3 INTO DATA(wa_ebeln1) WITH KEY belnr = <line> buzid = 'F'.
    UNASSIGN <line>.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'EBELN' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_ebeln1-ebeln. "base 16/8
      UNASSIGN <line>.

      ASSIGN COMPONENT 'KOART' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_ebeln1-koart. "base 16/8
      UNASSIGN <line>.

      ASSIGN COMPONENT 'HKONT' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_ebeln1-hkont.
      UNASSIGN <line>.

    ENDIF.




    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
    READ TABLE it_bseg3 INTO DATA(bseg3) WITH KEY belnr = <line> buzid = 'T'.
    UNASSIGN <line>.

    IF sy-subrc EQ 0.

      ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <bseg2> TO <line>.
      <line> = bseg3-hwbas. "base 16/8
      UNASSIGN <line>.

      ASSIGN COMPONENT 'HWBAS' OF STRUCTURE <bseg2> TO <line>.
      <line> = bseg3-dmbtr. " iva
      UNASSIGN <line>.


      ASSIGN COMPONENT 'MWSKZ' OF STRUCTURE <bseg2> TO <line>.
      IF <line> EQ '**'.
        ASSIGN COMPONENT 'MWSK1' OF STRUCTURE <bseg2> TO <line2>.
        "<line> =  <line2>.
        IF bseg3-dmbtr GT 0.
          <line> = 'X7'.
        ELSE.
          <line> =  <line2>.
        ENDIF.
        UNASSIGN <line>.
        UNASSIGN <line2>.
      ELSE.
        <line> = bseg3-mwskz.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
    READ TABLE it_bseg3 INTO DATA(bseg4) WITH KEY belnr = <line> buzid = 'P'.

    IF sy-subrc EQ 0 AND bseg4-hkont EQ '0701001001' OR bseg4-hkont EQ '0702001001'.
      ASSIGN COMPONENT 'PERUTIL' OF STRUCTURE <bseg2> TO <line>.
      <line> = bseg4-dmbtr.
      UNASSIGN <line>.
      ASSIGN COMPONENT 'CTAPERUTIL' OF STRUCTURE <bseg2> TO <line>.
      <line> = bseg4-hkont.

    ELSE.

      ASSIGN COMPONENT 'PERUTIL' OF STRUCTURE <bseg2> TO <line>.
      <line> = 0.
      UNASSIGN <line>.
      ASSIGN COMPONENT 'CTAPERUTIL' OF STRUCTURE <bseg2> TO <line>.
      <line> = space.

    ENDIF.
    ASSIGN COMPONENT 'H_BLART' OF STRUCTURE <bseg2> TO <line>.
    IF <line> EQ 'GV' AND s_belnr IS INITIAL.

      ASSIGN COMPONENT 'AUGBL' OF STRUCTURE <bseg2> TO <line>.
      aux_au =  <line>.

      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
      aux_bl = <line>.

      ASSIGN COMPONENT 'AUGBL' OF STRUCTURE <bseg2> TO <line>.
      <line> = aux_bl.

      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
      <line> = aux_au.


      CLEAR: aux_au,aux_bl.



    ENDIF.
  ENDLOOP.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  IF it_bseg2 IS NOT INITIAL.
    SELECT l~lifnr, l~stcd1, l~name1
    APPENDING TABLE @it_lfna1
    FROM lfa1 AS l
    FOR ALL ENTRIES IN @it_bseg2
    WHERE lifnr EQ @it_bseg2-lifnr.
  ENDIF.

*  ENDIF.
  "----------------------------------------------------------------------
  " Cuentas del SAT en tabla Z
  SELECT cvesat, descsat
      INTO TABLE @DATA(it_cuentassat)
  FROM zfi_tt_clavessat.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "Información de los XML
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  IF it_bseg2 IS NOT INITIAL.
    SELECT z~doc_comp, z~doc_contable,z~bukrs, z~ejercicio AS gjahr,  z~uuid, z~metododepago, z~formadepago, z~total, z~moneda,
         z~folio, z~rfc_e, z~xml_dir, tipo_comprobante
    INTO TABLE @it_xml
    FROM zaxnare_tb001 AS z
    FOR ALL ENTRIES IN @it_bseg2
        WHERE doc_comp = @it_bseg2-augbl AND bukrs = @it_bseg2-bukrs AND no_proveedor = @it_bseg2-lifnr
        AND estatus NOT IN ( 'X', '2', '3' ).

  ENDIF.
  DELETE it_xml WHERE xml_dir NP '*.xml'.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  SELECT   doc_comp ,  doc_contable, bukrs, gjahr,monat, tipo_comprobante, formadepago,
    metododepago, usocfdi, claveprodserv,  moneda,  folio, emisor, descripcion,  fecha,
    fechatimbrado,uuid_pago  FROM zfi_xml_complem
    INTO TABLE @DATA(it_valida)
    WHERE bukrs = @s_bukrs
    AND monat IN @s_monat.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  it_xml = FILTER #( it_xml USING KEY pk EXCEPT IN it_valida WHERE doc_comp = doc_comp AND doc_contable = doc_contable ).
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  LOOP AT it_xml INTO wa_xml.
    ruta_xml1 = wa_xml-xml_dir.
    REFRESH it_xmlsaT.
    PERFORM transformar_xml TABLES it_xmlsat[] USING ruta_xml1.
    IF it_xmlsat[] IS NOT INITIAL.

      CLEAR wa_zfi_xml_complem.
      wa_zfi_xml_complem-doc_comp = wa_xml-doc_comp.
      wa_zfi_xml_complem-doc_contable = wa_xml-doc_contable.
      wa_zfi_xml_complem-gjahr = wa_xml-gjahr.
      wa_zfi_xml_complem-monat = s_monat-low.
      wa_zfi_xml_complem-bukrs = s_bukrs.

      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'UsoCFDI'.
      wa_zfi_xml_complem-usocfdi = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'ClaveProdServ'.
      wa_zfi_xml_complem-claveprodserv = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'FormaPago'.
      wa_zfi_xml_complem-formadepago = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'TipoDeComprobante'.
      wa_zfi_xml_complem-tipo_comprobante = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'MetodoPago'.
      wa_zfi_xml_complem-metododepago = wa_xmlsat-cvalue.




      READ TABLE it_cuentassat INTO DATA(wa_ctasat) WITH KEY cvesat = wa_xmlsat-cvalue.
      IF sy-subrc EQ 0.
        wa_zfi_xml_complem-descripcion = wa_ctasat-descsat.
      ENDIF.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Moneda'.
      wa_zfi_xml_complem-moneda = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Folio'.
      wa_zfi_xml_complem-folio = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Emisor'.
      wa_zfi_xml_complem-emisor = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Descripcion'.
      wa_zfi_xml_complem-descripcion = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Fecha'.
      wa_zfi_xml_complem-fecha = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'FechaTimbrado'.
      wa_zfi_xml_complem-fechatimbrado = wa_xmlsat-cvalue.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'UUID'.
      wa_zfi_xml_complem-uuid_pago = wa_xmlsat-cvalue.

    ENDIF.
    APPEND wa_zfi_xml_complem TO it_zfi_xml_complem.
  ENDLOOP.

  IF it_zfi_xml_complem IS NOT INITIAL.
    TRY.
        INSERT zfi_xml_complem FROM TABLE it_zfi_xml_complem.
      CATCH cx_sy_open_sql_db INTO DATA(lx_sql_error).
        DATA(lv_error_message) = lx_sql_error->get_text( ).
        WRITE: / 'Database error occurred:', lv_error_message.
    ENDTRY.

  ENDIF.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  REFRESH it_valida.

  SELECT   doc_comp ,  doc_contable, bukrs, gjahr,monat, tipo_comprobante, formadepago,
    metododepago, usocfdi, claveprodserv,  moneda,  folio, emisor, descripcion,  fecha,
    fechatimbrado,uuid_pago  FROM zfi_xml_complem
    INTO TABLE @it_valida
    WHERE bukrs = @s_bukrs
    AND monat IN @s_monat..

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""TABLA DE RETENCIONES"""""""""""""""""""""""""""""""""""""""""""""""""""""""
  IF it_bseg2 IS NOT INITIAL.
    SELECT belnr, augbl,gjahr, witht, wt_withcd, wt_qbshh
     INTO TABLE @DATA(it_retenciones)
     FROM with_item
     FOR ALL ENTRIES IN @it_bseg2
     WHERE belnr = @it_bseg2-belnr
     AND augbl = @it_bseg2-augbl
     AND gjahr = @it_bseg2-gjahr
     AND bukrs = @it_bseg2-bukrs.
  ENDIF.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  "-------------------------------------------------------------------


  "--------------nombre de la cuenta de mayor

  SELECT saknr, txt50
  INTO TABLE @DATA(it_skat)
        FROM skat
        FOR ALL ENTRIES IN @it_acdoca
        WHERE saknr = @it_acdoca-racct
        AND spras = 'S'.

  SELECT saknr, txt50
  APPENDING TABLE @it_skat
        FROM skat
        FOR ALL ENTRIES IN @it_bseg
        WHERE saknr = @it_bseg-hkont
        AND spras = 'S'.

  SELECT saknr, txt50
  APPENDING TABLE @it_skat
  FROM skat
  FOR ALL ENTRIES IN @it_bseg2
  WHERE saknr = @it_bseg2-hkont
  AND spras = 'S'.


  "--------obtención del tipo de IVA aplicado.
  SELECT mwskz, knumh
  INTO TABLE @DATA(it_a003)
        FROM a003
        FOR ALL ENTRIES IN @it_bseg2
        WHERE mwskz = @it_bseg2-mwskz
        AND kappl = 'TX' AND kschl = 'MWVS' AND aland = 'MX'.

  SELECT knumh, kbetr
  INTO TABLE @DATA(it_indiva)
        FROM konp
        FOR ALL ENTRIES IN @it_a003
        WHERE knumh = @it_a003-knumh.
  "---------------------------------------------------
  "datos bancarios "cuenta de banco
  SELECT bukrs, belnr, gjahr, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev
  INTO TABLE @DATA(it_docBancotmp)
        FROM bseg
        FOR ALL ENTRIES IN @it_bkpf
        WHERE belnr = @it_bkpf-belnr
        AND bukrs = @it_bkpf-bukrs
        AND gjahr = @it_bkpf-gjahr
        AND bschl = '50'
        AND augbl NE ''
        .

  IF it_docBancotmp IS NOT INITIAL.
    SELECT bukrs, belnr, gjahr,augdt, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev,h_bldat
    INTO TABLE @DATA(it_docBanco)
          FROM bseg
          FOR ALL ENTRIES IN @it_docBancotmp
          WHERE augbl = @it_docBancotmp-augbl
          AND bukrs = @it_docBancotmp-bukrs
          AND gjahr = @it_docBancotmp-gjahr
          AND belnr NE @it_docBancotmp-belnr
          AND bschl = '40'
          AND h_blart EQ 'ZA'.
    "AND fdlev = ''.
  ENDIF.


  "indicadores de retención
  SELECT witht, wt_withcd, qproz, qsatz
    INTO TABLE @DATA(it_T059Z)
  FROM t059z
    WHERE land1 = 'MX'.
  "----------------------------


  REFRESH it_ingresos.

  "se van asignando a la tabla de salida del alv
  LOOP AT it_bkpf INTO DATA(wa_bkpf).
    CLEAR: vl_banFF, vl_ban19.
    CLEAR: vl_iva_ret, vl_isr_ret.

    APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_head>.
    <fs_head>-rbukrs = wa_bkpf-bukrs.
    <fs_head>-gjahr = wa_bkpf-gjahr.
    <fs_head>-cpudt = wa_bkpf-cpudt.
    <fs_head>-poper = wa_bkpf-monat.
    <fs_head>-belnr = wa_bkpf-belnr.
    <fs_head>-budat = wa_bkpf-budat.
    <fs_head>-bldat = wa_bkpf-bldat.
    <fs_head>-cheque = wa_bkpf-bktxt.
    <fs_head>-blart = wa_bkpf-blart.
    <fs_head>-moneda = wa_bkpf-hwaer.
    IF <fs_head>-moneda EQ 'USD'.
      <fs_head>-tipocambio = wa_bkpf-kursf.
    ENDIF.

    READ TABLE it_acdoca INTO DATA(wa_usnam) WITH KEY  belnr = wa_bkpf-belnr.
    IF sy-subrc EQ 0.
      <fs_head>-usnam = wa_usnam-usnam.
    ENDIF.

    "documento Banco ZA
    READ TABLE it_docBancotmp INTO DATA(wa_tmp) WITH KEY belnr = wa_bkpf-belnr.
    IF sy-subrc EQ 0.

      READ TABLE it_docBanco INTO DATA(wa_doc) WITH KEY augbl = wa_tmp-augbl.
      IF sy-subrc EQ 0.
        <fs_head>-DOC_banco = wa_doc-belnr.
        <fs_head>-fecdocbanco = wa_doc-h_bldat.
      ENDIF.
    ENDIF.


    "datos de Xml de documento de pago

    "datos del pago
    CLEAR: vl_iva_ret, vl_isr_ret.

    LOOP AT it_bseg INTO DATA(wa_bseg) WHERE belnr = wa_bkpf-belnr AND bukrs = wa_bkpf-bukrs AND gjahr = wa_bkpf-gjahr.
      IF wa_bseg-augbl EQ wa_bkpf-belnr. "pago proveedores Grupo Porres.
        IF wa_bkpf-blart = 'KD'.
          <fs_head>-tot_egreso = wa_bseg-dmbtr.
        ENDIF.
      ELSEIF wa_bseg-bschl EQ '50' AND ( wa_bseg-qsskz EQ 'IA' OR
                                         wa_bseg-qsskz EQ 'IH' OR
                                         wa_bseg-qsskz EQ 'IS' OR
                                         wa_bseg-qsskz EQ 'IT' ).     "wa_bseg-hkont EQ '0216010002'. "Iva retenido

        <fs_head>-iva_ret = 0. "wa_bseg-dmbtr * -1. "negativo, así fue solicitado.
        vl_iva_ret = wa_bseg-dmbtr.
        vl_indretiva = wa_bseg-qsskz.
      ELSEIF wa_bseg-bschl EQ '50' AND ( wa_bseg-qsskz EQ 'RA' OR
                                         wa_bseg-qsskz EQ 'RH' OR
                                         wa_bseg-qsskz EQ 'F7' OR
                                         wa_bseg-qsskz EQ 'F1' OR
                                         wa_bseg-qsskz EQ 'F5' OR
                                         wa_bseg-qsskz EQ 'IE' OR
                                         wa_bseg-qsskz EQ 'RC' OR
                                         wa_bseg-qsskz EQ 'RN' OR
                                         wa_bseg-qsskz EQ 'RZ'  ). "ISR Retenido

        <fs_head>-isr_ret = 0. "wa_bseg-dmbtr * -1.
        vl_isr_ret = wa_bseg-dmbtr.
        vl_indretisr = wa_bseg-qsskz.
      ELSEIF wa_bseg-bschl EQ '50' AND wa_bseg-qsskz EQ 'RN'. "ISR Retenido
        <fs_head>-nom_ret = 0. "wa_bseg-dmbtr.
      ELSEIF wa_bseg-fdlev EQ 'F2'. "egreso real.
        <fs_head>-tot_egreso = wa_bseg-dmbtr.
        <fs_head>-base0 = 0. "wa_bseg-dmbtr.
        <fs_head>-gkont = wa_bseg-hkont.
        <fs_head>-saknr = wa_bseg-hkont.

        READ TABLE it_skat INTO DATA(wa_skatkz) WITH KEY saknr = wa_bseg-hkont.
        IF sy-subrc EQ 0.
          <fs_head>-banco = wa_skatkz-txt50.
          <fs_head>-banco2 = <fs_head>-banco.
        ENDIF.
      ELSEIF wa_bseg-fdlev EQ 'FF' AND vl_banFF EQ ''. "anticipos que no aparecen en acdoca
        "excepción de SQL
        SELECT bukrs AS rbukrs,
            a~belnr, a~gjahr, a~h_budat AS budat, a~h_blart AS blart,
            a~valut, a~lifnr, a~rebzg, a~zuonr, a~hkont AS gkont, a~augbl,
            a~dmbtr AS base, a~dmbtr AS total, a~dmbtr AS tot_egreso,
            a~h_waers AS moneda, a~sgtxt, a~augdt, a~augbl AS usnam,
            a~hkont AS racct, a~augbl AS awref, a~h_bldat AS bldat
        APPENDING TABLE @it_acdoca
           FROM bseg AS a
           WHERE a~augbl = @wa_bkpf-belnr
          AND bukrs = @wa_bkpf-bukrs AND a~gjahr = @wa_bkpf-gjahr.
        IF sy-subrc EQ 0.
          vl_banFF = 'X'.
        ENDIF.
        "------------------------------------------
      ELSEIF wa_bseg-gvtyp EQ 'X'.
        "El tipo de cuenta de resultados determina para las cuentas de pérdidas y ganancias
        APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_headgv>.
        <fs_headgv> = <fs_head>.

        IF wa_bseg-hkont EQ '0701001001' OR wa_bseg-hkont = '0702001001' .
          <fs_headgv>-del_alv = 'X'.
        ELSE.
          <fs_headgv>-del_alv = space.
        ENDIF.


        IF wa_bseg-shkzg EQ 'S'.
          <fs_headgv>-base0 = wa_bseg-dmbtr.
        ELSE.
          IF wa_bkpf-blart = 'KD'.
            <fs_headgv>-base0 = wa_bseg-dmbtr.
          ELSE.
            <fs_headgv>-base0 = wa_bseg-dmbtr * -1.
          ENDIF.
        ENDIF.

        <fs_headgv>-total = <fs_headgv>-base0.
        <fs_headgv>-tot_egreso = 0.
        <fs_headgv>-gkont = wa_bseg-hkont.
        READ TABLE it_skat INTO DATA(wa_uti) WITH KEY saknr = wa_bseg-hkont.
        IF sy-subrc EQ 0.
          <fs_headgv>-banco = wa_uti-txt50.
          <fs_headgv>-saknr = <fs_head>-saknr.
          <fs_headgv>-banco2 = <fs_head>-banco.
        ENDIF.

        READ TABLE it_acdoca INTO DATA(wa_usnamgv) WITH KEY  belnr = wa_bkpf-belnr.
        IF sy-subrc EQ 0.
          <fs_headgv>-usnam = wa_usnamgv-usnam.
        ENDIF.

        UNASSIGN <fs_headgv>.
      ENDIF.

      READ TABLE it_acdoca INTO DATA(wa_krfalta) WITH KEY augbl = wa_bkpf-belnr.
      IF sy-subrc NE 0 AND vl_ban19 = ''.

        SELECT a~bukrs AS rbukrs,
        a~belnr, a~gjahr, a~h_budat AS budat, a~h_blart AS blart,
        a~valut, a~lifnr, a~rebzg, a~zuonr, a~hkont AS gkont, a~augbl,
        a~dmbtr AS base, a~dmbtr AS total, a~dmbtr AS tot_egreso,
        a~h_waers AS moneda, a~sgtxt, a~augdt, a~aufnr AS usnam,
        a~hkont AS racct, a~augbl AS awref, a~h_bldat AS bldat
        INTO TABLE @DATA(it_acdocakr)
        FROM bseg AS a
        WHERE a~belnr = @wa_bkpf-belnr
        AND a~bukrs = @wa_bkpf-bukrs AND a~gjahr = @wa_bkpf-gjahr
        AND a~koart EQ 'K'
        AND a~augbl NE ''.

        IF it_acdocakr[] IS NOT INITIAL.


          SELECT a~bukrs AS rbukrs,
          a~belnr, a~gjahr, a~h_budat AS budat, a~h_blart AS blart,
          a~valut, a~lifnr, a~rebzg, a~zuonr, a~hkont AS gkont, a~augbl,
          a~dmbtr AS base, a~dmbtr AS total, a~dmbtr AS tot_egreso,
          a~h_waers AS moneda, a~sgtxt, a~augdt, a~aufnr AS usnam,
          a~hkont AS racct, a~augbl AS awref, a~h_bldat AS bldat
          INTO TABLE @DATA(it_acdocazk)
                FROM bseg AS a
                FOR ALL ENTRIES IN @it_acdocakr
                WHERE a~augbl = @it_acdocakr-augbl AND a~belnr NE @wa_bkpf-belnr
                AND a~bukrs = @wa_bkpf-bukrs "AND a~gjahr = @wa_bkpf-gjahr
                AND a~fdlev EQ 'ZK' AND h_blart IN ('KR','NM','KZ', 'CI' ).

          LOOP AT it_acdocazk INTO DATA(wa_kr).
            wa_kr-augbl = wa_bkpf-belnr.
            MODIFY it_acdocazk FROM wa_kr INDEX sy-tabix TRANSPORTING augbl.
          ENDLOOP.

          vl_ban19 = 'X'.

          "MOVE-CORRESPONDING it_acdocakr to it_acdoca.
          APPEND LINES OF it_acdocazk TO it_acdoca.
        ENDIF.
      ENDIF.

    ENDLOOP.

    vl_suma_ret = vl_iva_ret + vl_isr_ret.

    IF <fs_head>-iva > 0.
      <fs_head>-base16 = 0. "<fs_head>-base0.
      <fs_head>-base0 = 0.
    ENDIF.

*    IF <fs_head>-iva_ret ne 0 OR <fs_head>-isr_ret ne 0 OR <fs_head>-nom_ret ne 0.
*      <fs_head>-tot_egreso = <fs_head>-tot_egreso + <fs_head>-iva_ret + <fs_head>-isr_ret + <fs_head>-nom_ret.
*    ENDIF.

    "-------------------------------------------------
    IF <fs_head>-usnam IS INITIAL.
      SELECT SINGLE usnam FROM acdoca
      INTO <fs_head>-usnam
      WHERE belnr = wa_bkpf-belnr AND
      rbukrs = wa_bkpf-bukrs AND
      gjahr = wa_bkpf-gjahr.
    ENDIF.


*        "Datos de la factura (Documento Provision)
    CLEAR lv_exist_prov.

    LOOP AT it_bseg2 INTO DATA(wa_bseg2) WHERE augbl = wa_bkpf-belnr.

      IF wa_bseg2-h_blart EQ 'NM'.
        lv_exist_prov = abap_false.
        EXIT.
      ENDIF.


      IF wa_bseg2-augbl EQ wa_bseg2-belnr.
        IF wa_bseg2-bschl EQ '25'.
          "continua para agregar la fila del movimento no permitido por pago de anticipo.
        ELSE.
          CONTINUE.
        ENDIF.

      ENDIF.

      IF wa_bseg2-gjahr IS INITIAL AND wa_bseg2-h_blart = 'KA'.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_body>.
      lv_exist_prov = abap_true.

      <fs_body>-rbukrs = wa_bkpf-bukrs.
      <fs_body>-cheque = wa_bkpf-bktxt.
      <fs_body>-gjahr = wa_bkpf-gjahr.
      <fs_body>-poper = wa_bkpf-monat.
      <fs_body>-belnr = wa_bkpf-belnr.
      "<fs_body>-usnam = wa_acdoca-usnam. pendiente
      <fs_body>-budat = wa_bseg2-h_budat.
      <fs_body>-rebzg  = wa_bseg2-belnr.
      "<fs_body>-valut = wa_acdoca-valut. -pendiente
      <fs_body>-moneda = wa_bseg2-moneda.




      IF <fs_body>-moneda EQ 'USD'.
        READ TABLE it_tipocambio INTO DATA(wa_tipocambio) WITH KEY belnr = wa_bseg2-belnr bukrs = wa_bseg2-bukrs blart = wa_bseg2-h_blart.
        IF sy-subrc EQ 0.
          <fs_body>-tipocambio = wa_tipocambio-kursf.
        ENDIF.
      ENDIF.
      <fs_body>-saknr = <fs_head>-saknr.
      <fs_body>-banco2 = <fs_head>-banco2.
*
*
      "datos del proveedor
      READ TABLE it_lfna1 INTO DATA(wa_lfa1) WITH KEY lifnr = wa_bseg2-lifnr.
      IF sy-subrc EQ 0.

        <fs_body>-lifnr = wa_lfa1-lifnr.
        <fs_body>-stcd1 = wa_lfa1-stcd1. "detalle
        <fs_body>-name1 = wa_lfa1-name1.

        <fs_head>-lifnr = wa_lfa1-lifnr.
        <fs_head>-stcd1 = wa_lfa1-stcd1. "encabezado
        <fs_head>-name1 = wa_lfa1-name1.

      ENDIF.

      READ TABLE it_acdoca INTO DATA(wa_acdoca) WITH KEY belnr =  wa_bseg2-belnr rbukrs = wa_bseg2-bukrs blart = wa_bseg2-h_blart.
      IF sy-subrc EQ 0.
        <fs_body>-usnam = wa_acdoca-usnam.
      ENDIF.



********************"SOLO ENTRA SI SE ENCONTRARON ANTICIPOS EN EL DOCUMENTO
      IF vl_banFF EQ 'X'.
        <fs_body>-total = wa_bseg2-dmbtr.
        "<fs_body>-base0 = wa_bseg2-dmbtr.
        <fs_body>-cpudt = wa_bseg2-h_bldat.
        <fs_body>-budat = wa_bseg2-h_budat.
        <fs_body>-blart = wa_bseg2-h_blart.
        <fs_body>-gkont = wa_bseg2-hkont.

        IF <fs_body>-usnam IS INITIAL.


          SELECT SINGLE usnam FROM acdoca
          INTO <fs_body>-usnam
          WHERE belnr =  wa_bseg2-belnr AND
                rbukrs = wa_bseg2-bukrs
                 .
        ENDIF.

        READ TABLE it_skat INTO DATA(wa_skatant) WITH KEY saknr = wa_bseg2-hkont.
        IF sy-subrc EQ 0.
          <fs_body>-banco = wa_skatant-txt50.
          <fs_body>-banco2 = <fs_head>-banco2.
        ENDIF.
      ELSEIF vl_ban19 EQ 'X'.

        <fs_body>-total = wa_bseg2-dmbtr.
        <fs_body>-base0 = wa_bseg2-dmbtr."wa_bseg2-base.
        <fs_body>-cpudt = wa_bseg2-h_bldat.
        <fs_body>-budat = wa_bseg2-h_budat.
        <fs_body>-blart = wa_bseg2-h_blart.
        <fs_body>-gkont = wa_bseg2-hkont.
        <fs_body>-sgtxt = wa_bseg2-sgtxt.

        SELECT SINGLE usnam FROM acdoca
        INTO <fs_body>-usnam
        WHERE belnr =  wa_bseg2-belnr AND
        rbukrs = wa_bseg2-bukrs AND blart EQ wa_bseg2-h_blart.

        READ TABLE it_skat INTO DATA(wa_skatkr) WITH KEY saknr = wa_bseg-hkont.
        IF sy-subrc EQ 0.
          <fs_body>-banco = wa_skatkr-txt50.
          <fs_body>-banco2 = <fs_head>-banco2.
        ENDIF.

      ENDIF.
      "------------------------------------------------------------------


      IF wa_bseg2-belnr NE wa_bkpf-belnr.
        IF wa_bseg2-bschl EQ '21' OR wa_bseg2-bschl EQ '27' OR wa_bseg2-bschl EQ '96'. "nota de credito o Ajuste


          IF wa_bseg2-mwskz EQ 'X3' OR wa_bseg2-mwskz EQ 'X7'. "base 16
            <fs_body>-iva = wa_bseg2-hwbas * -1.
            <fs_body>-base16 = wa_bseg2-dmbtr * -1.

            READ TABLE it_a003 INTO DATA(wa_nc16) WITH KEY mwskz = wa_bseg2-mwskz.
            IF sy-subrc EQ 0.
              READ TABLE it_indiva INTO DATA(wa_tasanc16) WITH KEY knumh = wa_nc16-knumh.
              IF sy-subrc EQ 0.
                <fs_body>-tasa = wa_tasanc16-kbetr / 10.
              ENDIF.
            ENDIF.

          ENDIF.

          IF wa_bseg2-mwskz EQ 'X0' OR wa_bseg2-mwskz EQ 'X5' OR wa_bseg2-mwsk2 EQ 'X0' OR wa_bseg2-mwsk2 EQ 'X5'. "base 0
            <fs_body>-base0 = wa_bseg2-dmbt2 * -1.

          ENDIF.

          IF wa_bseg2-mwskz EQ 'X2' OR wa_bseg2-mwskz EQ 'X6' OR wa_bseg2-mwsk2 EQ 'X2' OR wa_bseg2-mwsk2 EQ 'X6'. "base 8
            <fs_body>-iva = wa_bseg2-hwbas * -1.
            <fs_body>-base8 = wa_bseg2-dmbtr * -1.

            READ TABLE it_a003 INTO DATA(wa_nc08) WITH KEY mwskz = wa_bseg2-mwskz.
            IF sy-subrc EQ 0.
              READ TABLE it_indiva INTO DATA(wa_tasanc8) WITH KEY knumh = wa_nc08-knumh.
              IF sy-subrc EQ 0.
                <fs_body>-tasa = wa_tasanc8-kbetr / 10.
              ENDIF.
            ENDIF.
          ENDIF.


          <fs_body>-total =  ( wa_bseg2-dmbtr + wa_bseg2-hwbas ) * -1.

        ELSE.
          IF wa_bseg2-h_blart = 'KZ'.
            <fs_body>-tot_egreso = wa_bseg2-dmbtr.
          ELSEIF wa_bseg2-bschl = '36'.
            <fs_body>-tot_egreso = wa_bseg2-dmbtr.
          ELSE.
            <fs_body>-total = wa_bseg2-dmbtr.
          ENDIF.


        ENDIF.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        SELECT SINGLE uuid_pago
        INTO @DATA(uuid_pago)
        FROM zaxnare_tb001 AS z1
        INNER JOIN zaxnare_tb016 AS z2 ON z2~uuid_padre = z1~uuid
        WHERE z1~doc_contable = @<fs_body>-rebzg AND z1~ejercicio = @<fs_body>-gjahr
        AND z1~bukrs = @<fs_body>-rbukrs.

        <fs_body>-uuid_concep = wa_bseg2-sgtxt.
        IF uuid_pago IS NOT INITIAL.
          <fs_body>-uuid_pago = uuid_pago.
        ENDIF.

        CLEAR uuid_pago.


        <fs_body>-cpudt = wa_bseg2-h_bldat.
        <fs_body>-budat = wa_bseg2-h_budat.
        <fs_body>-blart = wa_bseg2-h_blart.

        "Seleccion de bases 8% y 16%.
        IF wa_bseg2-shkzg  EQ 'H' AND ( wa_bseg2-mwskz EQ 'X0' OR wa_bseg2-mwskz EQ 'X5' OR wa_bseg2-mwsk2 EQ 'X0' OR wa_bseg2-mwsk2 EQ 'X5' ). "BASE 0
          IF wa_bseg2-dmbt2 EQ 0.
            <fs_body>-base0 = ( <fs_body>-base0 + wa_bseg2-dmbtr ) - wa_bseg2-perutil.
          ELSE.
            <fs_body>-base0 = ( <fs_body>-base0 + wa_bseg2-dmbt2 ) - wa_bseg2-perutil.
          ENDIF.

          IF wa_bseg2-ctaperutil EQ '0701001001'. "perdida
            <fs_body>-perdida = wa_bseg2-perutil.
          ELSEIF wa_bseg2-ctaperutil EQ '0702001001'. "utilidad
            <fs_body>-utilidad = wa_bseg2-perutil.
          ENDIF.
        ENDIF.

        IF wa_bseg2-shkzg  EQ 'H' AND ( wa_bseg2-mwskz EQ 'X2' OR wa_bseg2-mwskz EQ 'X6' OR wa_bseg2-mwsk2 EQ 'X2' OR wa_bseg2-mwsk2 EQ 'X6' ) AND wa_bseg2-buzid NE 'T'. "BASE 8

*                                            IF wa_bseg2-dmbt2 EQ 0 .
          <fs_body>-base8 = ( <fs_body>-base8 + wa_bseg2-dmbtr ) - wa_bseg2-perutil.
*                                            ELSE.
*                                              <fs_body>-base8 = ( <fs_body>-base8 + wa_bseg2-dmbt2 ) - wa_bseg2-perutil.
*                                            ENDIF.

          <fs_body>-iva = <fs_body>-iva + wa_bseg2-hwbas.

          IF wa_bseg2-ctaperutil EQ '0701001001'. "perdida
            <fs_body>-perdida = wa_bseg2-perutil.
          ELSEIF wa_bseg2-ctaperutil EQ '0702001001'. "utilidad
            <fs_body>-utilidad = wa_bseg2-perutil.
          ENDIF.

          READ TABLE it_a003 INTO DATA(wa_a003) WITH KEY mwskz = wa_bseg2-mwskz.
          IF sy-subrc EQ 0.
            READ TABLE it_indiva INTO DATA(wa_tasa) WITH KEY knumh = wa_a003-knumh.
            IF sy-subrc EQ 0.
              <fs_body>-tasa = wa_tasa-kbetr / 10.
            ENDIF.
          ENDIF.
        ENDIF.

        IF wa_bseg2-shkzg  EQ 'H' AND ( wa_bseg2-mwskz EQ 'X3' OR wa_bseg2-mwskz EQ 'X7' )   AND wa_bseg2-buzid NE 'T'. "BASE 16
          <fs_body>-base16 = ( <fs_body>-base16 + wa_bseg2-dmbtr ) - wa_bseg2-perutil.
          <fs_body>-iva = <fs_body>-iva + wa_bseg2-hwbas.

          IF wa_bseg2-ctaperutil EQ '0701001001'. "perdida
            <fs_body>-perdida = wa_bseg2-perutil.
          ELSEIF wa_bseg2-ctaperutil EQ '0702001001'. "utilidad
            <fs_body>-utilidad = wa_bseg2-perutil.
          ENDIF.

          READ TABLE it_a003 INTO DATA(wa_a0031) WITH KEY mwskz = wa_bseg2-mwskz.
          IF sy-subrc EQ 0.
            READ TABLE it_indiva INTO DATA(wa_tasa1) WITH KEY knumh = wa_a0031-knumh.
            IF sy-subrc EQ 0.
              <fs_body>-tasa = wa_tasa1-kbetr / 10.
            ENDIF.
          ENDIF.

          """"""""""""""""""""""""""""""
          IF <fs_body>-iva EQ 0.
            <fs_body>-base16 = '0.00'.
          ENDIF. "17/12/2025 1900001273

          <fs_body>-tasa = '0.00'.
          """"""""""""""""""""""""""""""""""
        ENDIF.

        IF wa_bseg2-mwskz IS INITIAL.
          <fs_body>-wsl = wa_bseg2-dmbtr. "No tienen base, por lo regular SA
          IF wa_bseg2-h_blart EQ 'KZ' OR wa_bseg2-h_blart EQ 'GV'.
            IF wa_bseg2-bschl EQ '25'. "GV que son Anticipos
              <fs_body>-no_considerado = wa_bseg2-dmbtr. "No considerado.
              <fs_body>-wsl = '0.00'.
            ELSE.
              <fs_body>-no_considerado = '0.00'. "wa_bseg2-dmbtr. "No considerado.
            ENDIF.

          ELSE.
            <fs_body>-no_considerado = wa_bseg2-dmbtr. "No considerado.
          ENDIF.
        ENDIF.

        IF wa_bseg2-mwskz EQ 'Z0'.
          <fs_body>-wsl = wa_bseg2-dmbtr. "No tienen base, por lo regular SA
          <fs_body>-exento = wa_bseg2-dmbtr. "Exento.
        ENDIF.


        IF wa_bseg2-buzid NE 'P'.
          <fs_body>-gkont = wa_bseg2-hkont.
          IF <fs_body>-gkont = '0201001001'.
            SELECT s~saknr s~txt50
            APPENDING TABLE it_skat
            FROM bseg AS b INNER JOIN skat AS s
            ON s~saknr = b~hkont WHERE b~belnr = wa_bseg2-belnr  AND b~zterm = 'Z000' AND b~bukrs = wa_bseg2-bukrs
            AND b~gjahr = wa_bseg2-gjahr.

            SELECT SINGLE hkont
            INTO @wa_bseg2-hkont
            FROM bseg AS b INNER JOIN skat AS s
            ON s~saknr = b~hkont
            WHERE b~belnr = @wa_bseg2-belnr  AND b~zterm = 'Z000' AND b~bukrs = @wa_bseg2-bukrs
            AND b~gjahr = @wa_bseg2-gjahr
            .
            <fs_body>-gkont = wa_bseg2-hkont.
          ENDIF.

          READ TABLE it_skat INTO DATA(wa_skatx) WITH KEY saknr = wa_bseg2-hkont.
          IF sy-subrc EQ 0.
            <fs_body>-banco = wa_skatx-txt50.
            <fs_body>-banco2 = <fs_head>-banco2.
          ENDIF.
        ENDIF.
      ELSE.
       <fs_body>-del_alv = 'X'.
      ENDIF.

      IF wa_bseg2-bschl NE '50' AND  wa_bseg2-buzid NE 'T' AND wa_bseg2-augbl IS INITIAL .
        <fs_body>-gkont = wa_bseg2-hkont.
        READ TABLE it_skat INTO DATA(wa_skat) WITH KEY saknr = wa_bseg2-hkont.
        IF sy-subrc EQ 0.
          <fs_body>-banco = wa_skat-txt50.
          <fs_body>-banco2 = <fs_head>-banco2.
        ENDIF.
      ENDIF.



      IF wa_bseg2-ebeln IS NOT INITIAL.
        <fs_body>-ebeln = wa_bseg2-ebeln.
*        CASE wa_bseg2-koart.
*          WHEN 'A' OR 'K'.
*            <fs_body>-zkoart = 'A'.
*          WHEN 'M'.
*
*          WHEN 'S'.
*           <fs_body>-zkoart = 'S'.
*          WHEN OTHERS.
*        ENDCASE.
        IF wa_bseg2-anln1 IS NOT INITIAL.
          <fs_body>-zkoart = wa_bseg2-anln1.
        ELSE.

          SELECT SINGLE anln1 INTO <fs_body>-zkoart
            FROM bseg
          WHERE belnr = <fs_body>-rebzg AND gjahr = <fs_body>-gjahr
            AND koart IN ('A','M').

        ENDIF.
      ENDIF.

      IF wa_bseg2-aufnr IS NOT INITIAL.
        <fs_body>-aufnr = wa_bseg2-aufnr.
      ENDIF.

      <fs_body>-DOC_banco = <fs_head>-DOC_banco.
      <fs_body>-fecdocbanco = <fs_head>-fecdocbanco.

      DATA es_iva.

*      READ TABLE it_retenciones INTO DATA(wa_reteniva) WITH KEY belnr = wa_bseg2-belnr gjahr = wa_bseg2-gjahr.
*      IF sy-subrc EQ 0.
      LOOP AT it_retenciones INTO DATA(wa_reteniva) WHERE  belnr = wa_bseg2-belnr AND gjahr = wa_bseg2-gjahr.

        CASE wa_reteniva-witht.
          WHEN 'RA' OR
               'RC' OR
               'RH' OR
               'RN' OR
               'RZ' OR
               'F7' OR
               'F5'.
            IF <fs_body>-iva_ret EQ 0.
              <fs_body>-iva_ret = 0.
            ENDIF.
          WHEN OTHERS.
            IF  <fs_body>-iva_ret EQ 0.
              <fs_body>-iva_ret = wa_reteniva-wt_qbshh.
            ENDIF.

        ENDCASE.
*        ENDIF.


      ENDLOOP.

*      IF vl_iva_ret > 0.
*        <fs_body>-iva_ret = vl_iva_ret * -1.
*      ENDIF.


      IF vl_isr_ret > 0.
*        READ TABLE it_retenciones INTO DATA(wa_retenisr) WITH KEY belnr = wa_bseg2-belnr gjahr = wa_bseg2-gjahr.
*        IF sy-subrc EQ 0 AND ( wa_retenisr-witht EQ 'RA' OR wa_retenisr-witht EQ 'RC' OR wa_retenisr-witht EQ 'RH'
*                              OR wa_retenisr-witht EQ 'RN' OR wa_retenisr-witht EQ 'RZ' OR wa_retenisr-witht EQ 'F7'
*                              OR wa_retenisr-witht EQ 'F5').
*
*          <fs_body>-isr_ret = wa_retenisr-wt_qbshh. "vl_isr_ret * -1.
*        ENDIF.

        LOOP AT it_retenciones INTO DATA(wa_retenisr) WHERE  belnr = wa_bseg2-belnr AND gjahr = wa_bseg2-gjahr.

          CASE wa_retenisr-witht.
            WHEN 'RA' OR
                 'RC' OR
                 'RH' OR
                 'RN' OR
                 'RZ' OR
                 'F7' OR
                 'F5'.
              IF <fs_body>-isr_ret EQ 0.
                <fs_body>-isr_ret = wa_retenisr-wt_qbshh.
              ENDIF.
            WHEN OTHERS.
              IF <fs_body>-isr_ret EQ 0.
                <fs_body>-isr_ret = 0.
              ENDIF.
          ENDCASE.
*        ENDIF.


        ENDLOOP.

      ENDIF.

*    ENDIF.
*

*
      IF <fs_body>-base8 NE 0.
        <fs_body>-base8  = <fs_body>-base8." - <fs_body>-base0.
        <fs_body>-total = <fs_body>-base8 + <fs_body>-base0 + <fs_body>-iva +
                          <fs_body>-utilidad + <fs_body>-perdida.
      ENDIF.

      IF <fs_body>-base16 NE 0.
        <fs_body>-base16  = <fs_body>-base16." - <fs_body>-base0.
        <fs_body>-total = <fs_body>-base16 +  <fs_body>-base0 + <fs_body>-base8 +
                          <fs_body>-iva + <fs_body>-utilidad + <fs_body>-perdida.
      ENDIF.

      IF <fs_body>-base0 NE 0.
        "<fs_body>-base16  = <fs_body>-base16." - <fs_body>-base0.
        <fs_body>-total = <fs_body>-base16 +  <fs_body>-base0 + <fs_body>-base8 +
                          <fs_body>-iva + <fs_body>-utilidad + <fs_body>-perdida.
      ENDIF.

      IF <fs_body>-no_considerado NE 0.
        "<fs_body>-base16  = <fs_body>-base16." - <fs_body>-base0.
        IF wa_bseg2-h_blart NE 'KZ'.
          IF wa_bseg2-bschl = '36'.
            <fs_body>-total = <fs_body>-base16 + <fs_body>-base8 +
                            <fs_body>-iva + <fs_body>-utilidad + <fs_body>-perdida.
          ELSE.
            <fs_body>-total = <fs_body>-base16 +  <fs_body>-no_considerado + <fs_body>-base8 +
                           <fs_body>-iva + <fs_body>-utilidad + <fs_body>-perdida.
          ENDIF.
        ENDIF.
      ENDIF.


      CLEAR wa_ZFI_XML_COMPLEM.
      READ TABLE it_valida INTO DATA(wa_valida) WITH KEY doc_comp = wa_bkpf-belnr doc_contable = wa_bseg2-belnr bukrs = wa_bkpf-bukrs gjahr = wa_bseg2-gjahr.
      IF sy-subrc EQ 0.
        <fs_body>-tipo_comprobante = wa_valida-tipo_comprobante.
        <fs_body>-f_pago_xml = wa_valida-formadepago.
        <fs_body>-metpago_xml = wa_valida-metododepago.
        <fs_body>-usocfdi = wa_valida-usocfdi.
        <fs_body>-codigo_sat = wa_valida-claveprodserv.
        "<fs_body>-uuid_pago = WA_valida-uuid_pago.


        READ TABLE it_cuentassat INTO wa_ctasat WITH KEY cvesat = wa_valida-claveprodserv.
        IF sy-subrc EQ 0.
          <fs_body>-concep_sat = wa_ctasat-descsat.
        ENDIF.
        <fs_body>-moneda_xml = wa_valida-moneda.
        <fs_body>-folio_xml = wa_valida-folio.
        <fs_body>-emisor = wa_valida-emisor.
        <fs_body>-descripprod = wa_valida-descripcion.
        <fs_body>-fecpago_xml = wa_valida-fecha.
        <fs_body>-fectimbxml = wa_valida-fechatimbrado.
      ENDIF.

*      "acceso al XML de doc. proveedor
*      CLEAR wa_xml.
*      READ TABLE it_xml INTO wa_xml WITH KEY doc_comp = wa_bkpf-belnr doc_contable = wa_bseg2-belnr .
*      IF sy-subrc EQ 0.
*        <fs_body>-tipo_comprobante = WA_xml-tipo_comprobante.
*        <fs_body>-f_pago_xml = wa_xml-formadepago.
*        <fs_body>-metpago_xml = wa_xml-metododepago.
*
*        "se lee el complemento de datos del xml
*        " sruta_xml = wa_xml-xml_dir.
*        "ruta_xml = sruta_xml.
*
*        ruta_xml1 = wa_xml-xml_dir.
*        REFRESH it_xmlsaT.
*        PERFORM transformar_xml TABLES it_xmlsat[] USING ruta_xml1.
*        IF it_xmlsat[] IS NOT INITIAL.
*          CLEAR wa_xmlsat.
*          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'UsoCFDI'.
*          <fs_body>-usocfdi = wa_xmlsat-cvalue.
*
*          CLEAR wa_xmlsat.
*          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'ClaveProdServ'.
*          <fs_body>-codigo_sat = wa_xmlsat-cvalue.
*
*          READ TABLE it_cuentassat INTO wa_ctasat WITH KEY cvesat = wa_xmlsat-cvalue.
*          IF sy-subrc EQ 0.
*            <fs_body>-concep_sat = wa_ctasat-descsat.
*          ENDIF.
*
*          CLEAR wa_xmlsat.
*          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Moneda'.
*          <fs_body>-moneda_xml = wa_xmlsat-cvalue.
*
*          CLEAR wa_xmlsat.
*          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'MetodoPago'.
*          <fs_body>-metpago_xml = wa_xmlsat-cvalue.
*
*          CLEAR wa_xmlsat.
*          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Folio'.
*          <fs_body>-folio_xml = wa_xmlsat-cvalue.
*
*          CLEAR wa_xmlsat.
*          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Emisor'.
*          <fs_body>-emisor = wa_xmlsat-cvalue.
*
*          CLEAR wa_xmlsat.
*          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Descripcion'.
*          <fs_body>-descripprod = wa_xmlsat-cvalue.
*
*          CLEAR wa_xmlsat.
*          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Fecha'.
*          <fs_body>-fecpago_xml = wa_xmlsat-cvalue.
*
*          CLEAR wa_xmlsat.
*          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'FechaTimbrado'.
*          <fs_body>-fectimbxml = wa_xmlsat-cvalue.
*
*        ENDIF.
*
*      ENDIF.
*
      IF <fs_body>-iva_ret NE 0 OR <fs_body>-isr_ret NE 0 OR <fs_body>-nom_ret NE 0.
        <fs_body>-total = <fs_body>-total + <fs_body>-iva_ret + <fs_body>-isr_ret + <fs_body>-nom_ret + <fs_body>-utilidad + <fs_body>-perdida.
      ENDIF.

*
    ENDLOOP.
*
    """""""""""""""kz sobre los kz"""""""""""""""jhv
    DATA add_line.
    IF lv_exist_prov EQ abap_false. "si no hubo provisiones
      LOOP AT it_bseg INTO DATA(wa_bsegkz) WHERE belnr = wa_bkpf-belnr
                                           AND bukrs = wa_bkpf-bukrs
                                           AND gjahr = wa_bkpf-gjahr.
        IF wa_bsegkz-xzahl EQ 'X'.
          APPEND INITIAL LINE TO it_ingresos ASSIGNING FIELD-SYMBOL(<fs_bodykz>).
          add_line = 'X'.
          MOVE-CORRESPONDING <fs_head> TO <fs_bodykz>.
          IF wa_bsegkz-mwskz = 'Z0'.
            <fs_bodykz>-exento = wa_bsegkz-dmbtr.
          ELSE.
            <fs_bodykz>-no_considerado = wa_bsegkz-dmbtr.
          ENDIF.

          IF wa_bseg2-h_blart = 'NM'.
            <fs_bodykz>-total = wa_bsegkz-dmbtr.
            <fs_bodykz>-tot_egreso = 0.
            <fs_bodykz>-blart = 'NM'.
          ELSE.
            <fs_bodykz>-tot_egreso = wa_bsegkz-dmbtr.
          ENDIF.

          <fs_bodykz>-gkont = wa_bsegkz-hkont.
          READ TABLE it_skat INTO DATA(wa_hkont) WITH KEY saknr = wa_bsegkz-hkont.
          IF sy-subrc EQ 0.
            <fs_bodykz>-sgtxt = wa_hkont-txt50.
            <fs_bodykz>-banco = wa_hkont-txt50.
          ENDIF.
        ENDIF.
        "ZD
        "UNASSIGN <fs_bodykz>.
        IF add_line IS INITIAL.


          IF wa_bsegkz-fdlev EQ 'ZD' OR wa_bsegkz-fdlev EQ 'ZK' .
            APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_bodykz>.
            MOVE-CORRESPONDING <fs_head> TO <fs_bodykz>.
            IF wa_bsegkz-mwskz = 'Z0'.
              <fs_bodykz>-exento = wa_bsegkz-dmbtr.
            ELSE.
              <fs_bodykz>-no_considerado = wa_bsegkz-dmbtr.
            ENDIF.
            <fs_bodykz>-total = wa_bsegkz-dmbtr.
            <fs_bodykz>-tot_egreso = 0.
            CLEAR wa_hkont.
            READ TABLE it_skat INTO wa_hkont WITH KEY saknr = wa_bsegkz-hkont.
            IF sy-subrc EQ 0.
              <fs_bodykz>-sgtxt = wa_hkont-txt50.
            ENDIF.


          ENDIF.
        ENDIF.

        READ TABLE it_kna1 INTO DATA(wa_kna1) WITH KEY kunnr = wa_bsegkz-kunnr.
        IF sy-subrc EQ 0.
          <fs_bodykz>-lifnr = wa_kna1-kunnr.
          <fs_bodykz>-stcd1 = wa_kna1-stcd1.
          <fs_bodykz>-name1 = wa_kna1-name1.
          <fs_head>-lifnr = wa_kna1-kunnr.
          <fs_head>-stcd1 = wa_kna1-stcd1.
          <fs_head>-name1 = wa_kna1-name1.
        ELSE.
          SELECT kunnr, lifnr INTO TABLE @DATA(it_prov)
            FROM bseg
          WHERE belnr = @wa_bsegkz-belnr AND bukrs = @wa_bsegkz-bukrs
            AND gjahr = @wa_bsegkz-gjahr
            AND fdlev = 'ZK' AND fdgrp = 'Z2'.

          IF it_prov[] IS NOT INITIAL.
            READ TABLE it_prov INTO DATA(wa_prov) INDEX 1.
            IF wa_prov-kunnr IS NOT INITIAL.
              SELECT stcd1, name1
                FROM kna1
                INTO (@<fs_bodykz>-stcd1, @<fs_bodykz>-name1)
               WHERE kunnr = @wa_prov-kunnr.
              ENDSELECT.
              <fs_bodykz>-lifnr = wa_prov-kunnr.

              <fs_head>-lifnr = <fs_bodykz>-lifnr.
              <fs_head>-stcd1 = <fs_bodykz>-stcd1.
              <fs_head>-name1 = <fs_bodykz>-name1.


            ELSE.
              IF <fs_bodykz> IS ASSIGNED.


                SELECT stcd1, name1
                  FROM lfa1
                  INTO (@<fs_bodykz>-stcd1, @<fs_bodykz>-name1)
                 WHERE lifnr = @wa_prov-lifnr.
                ENDSELECT.
                <fs_bodykz>-lifnr = wa_prov-lifnr.

                <fs_head>-lifnr = <fs_bodykz>-lifnr.
                <fs_head>-stcd1 = <fs_bodykz>-stcd1.
                <fs_head>-name1 = <fs_bodykz>-name1.
              ENDIF.
            ENDIF.

          ENDIF.

        ENDIF.


        "ZK
        CLEAR wa_ZFI_XML_COMPLEM.
        "READ TABLE it_zfi_xml_complem INTO wa_ZFI_XML_COMPLEM WITH KEY doc_comp = wa_bkpf-belnr doc_contable = wa_bseg2-belnr .
        READ TABLE it_valida INTO wa_valida WITH KEY doc_comp = wa_bkpf-belnr doc_contable = wa_bseg2-belnr bukrs = wa_bkpf-bukrs gjahr = wa_bseg2-gjahr.
        IF sy-subrc EQ 0.
          <fs_body>-tipo_comprobante = wa_valida-tipo_comprobante.
          <fs_body>-f_pago_xml = wa_valida-formadepago.
          <fs_body>-metpago_xml = wa_valida-metododepago.
          <fs_body>-usocfdi = wa_valida-usocfdi.
          <fs_body>-codigo_sat = wa_valida-claveprodserv.
          READ TABLE it_cuentassat INTO wa_ctasat WITH KEY cvesat = wa_valida-claveprodserv.
          IF sy-subrc EQ 0.
            <fs_body>-concep_sat = wa_ctasat-descsat.
          ENDIF.
          <fs_body>-moneda_xml = wa_valida-moneda.
          <fs_body>-folio_xml = wa_valida-folio.
          <fs_body>-emisor = wa_valida-emisor.
          <fs_body>-descripprod = wa_valida-descripcion.
          <fs_body>-fecpago_xml = wa_valida-fecha.
          <fs_body>-fectimbxml = wa_valida-fechatimbrado.
        ENDIF.
        clear add_line.
      ENDLOOP.
    ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""
    UNASSIGN <fs_bodykz>.
    LOOP AT it_ingresos ASSIGNING <fs_headgv> WHERE belnr = wa_bkpf-belnr AND gkont = '0701001001' . "PERDIDA CAMBIARIA REALIZADA
      vl_perdida = vl_perdida + <fs_headgv>-base0.
    ENDLOOP.

    READ TABLE it_ingresos ASSIGNING <fs_headgv> WITH KEY belnr = wa_bkpf-belnr  gkont = '0701001001'.
    IF sy-subrc EQ 0.
      <fs_headgv>-perdida = vl_perdida.
      <fs_headgv>-total = vl_perdida.
    ENDIF.

    IF <fs_headgv> IS ASSIGNED.
      IF <fs_headgv>-perdida NE 0 .
        APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_headgvadd>.
        MOVE-CORRESPONDING <fs_headgv> TO <fs_headgvadd>.

        <fs_headgvadd>-lifnr = <fs_head>-lifnr.
        <fs_headgvadd>-stcd1 = <fs_head>-stcd1.
        <fs_headgvadd>-name1 = <fs_head>-name1.
        <fs_headgvadd>-base0 = 0.
        <fs_headgvadd>-del_alv = space.
      ENDIF.
    ENDIF.

    LOOP AT it_ingresos ASSIGNING <fs_headgv> WHERE belnr = wa_bkpf-belnr AND gkont = '0702001001'. "UTILIDAD CAMBIARIA REALIZADA
      vl_utilidad = vl_utilidad + <fs_headgv>-base0.
    ENDLOOP.

    READ TABLE it_ingresos ASSIGNING <fs_headgv> WITH KEY belnr = wa_bkpf-belnr  gkont = '0702001001'.
    IF sy-subrc EQ 0.
      <fs_headgv>-utilidad = vl_utilidad.
      <fs_headgv>-total = vl_utilidad.
    ENDIF.

    IF <fs_headgv> IS ASSIGNED.
      IF <fs_headgv>-utilidad NE 0.


        APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_headgvadd>.
        MOVE-CORRESPONDING <fs_headgv> TO <fs_headgvadd>.
        <fs_headgvadd>-lifnr = <fs_head>-lifnr.
        <fs_headgvadd>-stcd1 = <fs_head>-stcd1.
        <fs_headgvadd>-name1 = <fs_head>-name1.
        <fs_headgvadd>-base0 = 0.
        <fs_headgvadd>-del_alv = space.
      ENDIF.
    ENDIF.

    DELETE it_ingresos WHERE del_alv = 'X'.
    CLEAR: vl_perdida, vl_utilidad.

    "linea para obtener la siguiente linea de los cheques de nomina
    IF wa_bkpf-tcode EQ 'FBZ2' AND wa_bkpf-xblnr CP 'CH*'.
      READ TABLE it_bseg INTO DATA(w_nomina) WITH KEY belnr = wa_bkpf-belnr bschl = '25' fdlev = 'ZK'.
      IF sy-subrc EQ 0.
        "--------inicio
        IF <fs_head>-tot_egreso NE w_nomina-dmbtr.
          APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_body>.
          <fs_body> = <fs_head>.
          <fs_body>-total = w_nomina-dmbtr.
          <fs_body>-base0 = w_nomina-dmbtr.
          <fs_body>-tot_egreso = 0.
        ENDIF.
        "---------fin

      ENDIF.
    ENDIF.
    "------------------------------------------------------------------
    APPEND INITIAL LINE TO it_ingresos.
    UNASSIGN <fs_head>.
    UNASSIGN <fs_body>.
    UNASSIGN <fs_headgv>.


  ENDLOOP.


  "se eliminan todos los deudores diversion
  DELETE it_ingresos WHERE gkont = '0107005001'.
  "DELETE it_ingresos WHERE rbukrs IS INITIAL.


ENDFORM.

FORM create_fieldcat.
  REFRESH gt_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
*     I_INTERNAL_TABNAME     =
      i_structure_name       = 'ZFI_ST_EGRESOS'
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

      WHEN 'AWREF'.
        wa_fieldcat-no_out = 'X'.
*      WHEN 'ZUONR'.
*        wa_fieldcat-no_out = 'X'.
      WHEN 'UTILIDAD'.
        wa_fieldcat-seltext_s = 'Util. Prov'.
        wa_fieldcat-seltext_m = 'Utilidad Prov.'.
        wa_fieldcat-seltext_l = 'Utilidad Prov.'.
      WHEN 'PERDIDA'.
        wa_fieldcat-seltext_s = 'Pérd. Prov'.
        wa_fieldcat-seltext_m = 'Pérdida Prov.'.
        wa_fieldcat-seltext_l = 'Pérdida Prov.'.
      WHEN 'BLART_RV'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZKOART'.
        wa_fieldcat-seltext_s = 'Activo'.
        wa_fieldcat-seltext_m = 'Activo Fijo'.
        wa_fieldcat-seltext_l = 'Activo Fijo'.
*      WHEN 'TOTAL'.
*        wa_fieldcat-seltext_s = 'Total'.
*        wa_fieldcat-seltext_m = 'Total'.
*        wa_fieldcat-seltext_l = 'Total'.
*      WHEN 'BANCO'.
*        wa_fieldcat-seltext_s = 'Nombre Cuenta'.
*        wa_fieldcat-seltext_m = 'Nombre Cuenta'.
*        wa_fieldcat-seltext_l = 'Nombre Cuenta'.
*      WHEN 'BANCO2'.
*        wa_fieldcat-seltext_s = 'Descripcion'.
*        wa_fieldcat-seltext_m = 'Descripcion'.
*        wa_fieldcat-seltext_l = 'Descripcion'.
*      WHEN 'GKONT'.
*      wa_fieldcat-seltext_s = 'Cuenta'.
*      wa_fieldcat-seltext_m = 'Cuenta'.
*      wa_fieldcat-seltext_l = 'Cuenta'.
*      WHEN 'CODIGO_SAT'.
*        wa_fieldcat-seltext_s = 'Código SAT'.
*        wa_fieldcat-seltext_m = 'Código SAT'.
*        wa_fieldcat-seltext_l = 'Código SAT'.
*      WHEN 'CODIGO_SAT'.
*        wa_fieldcat-seltext_s = 'Concepto SAT'.
*        wa_fieldcat-seltext_m = 'Concepto SAT'.
*        wa_fieldcat-seltext_l = 'Concepto SAT'.

*      WHEN 'BASE16'.
*        wa_fieldcat-seltext_s = 'Base 16%'.
*        wa_fieldcat-seltext_m = 'Base 16%'.
*        wa_fieldcat-seltext_l = 'Base 16%'.
*    WHEN 'BASE8'.
*      wa_fieldcat-seltext_s = 'Base 8%'.
*      wa_fieldcat-seltext_m = 'Base 8%'.
*      wa_fieldcat-seltext_l = 'Base 8%'.
*      WHEN 'BASE0'.
*        wa_fieldcat-seltext_s = 'Base 0%'.
*        wa_fieldcat-seltext_m = 'Base 0%'.
*        wa_fieldcat-seltext_l = 'Base 0%'.
      WHEN 'ISR_RET'.
        wa_fieldcat-seltext_s = 'ISR Ret'.
        wa_fieldcat-seltext_m = 'ISR Rete'.
        wa_fieldcat-seltext_l = 'ISR Retenido'.
      WHEN 'NOM_RET'.
        wa_fieldcat-seltext_s = 'NOM. Ret'.
        wa_fieldcat-seltext_m = 'NOM. Rete'.
        wa_fieldcat-seltext_l = 'NOM. Retenido'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'TIPOCAMBIO'.
        wa_fieldcat-seltext_s = 'Tip. Camb.'.
        wa_fieldcat-seltext_m = 'Tip. Camb.'.
        wa_fieldcat-seltext_l = 'Tipo Cambio'.
      WHEN 'CHEQUE'.
        wa_fieldcat-seltext_s = 'Ch./Trans.'.
        wa_fieldcat-seltext_m = 'Cheq./Trans.'.
        wa_fieldcat-seltext_l = 'Cheque/Trans.'.
      WHEN 'BUZEI'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'BSCHL'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'MONTO_XML'.
        wa_fieldcat-seltext_s = 'Monto XML'.
        wa_fieldcat-seltext_m = 'Monto XML'.
        wa_fieldcat-seltext_l = 'Monto de XML'.
      WHEN 'MONEDA_XML'.
        wa_fieldcat-seltext_s = 'Moneda XML'.
        wa_fieldcat-seltext_m = 'Moneda XML'.
        wa_fieldcat-seltext_l = 'Moneda XML'.
      WHEN 'METPAGO_XML'.
        wa_fieldcat-seltext_s = 'M.P. XML'.
        wa_fieldcat-seltext_m = 'M.P. XML'.
        wa_fieldcat-seltext_l = 'Met. Pag. XML'.
      WHEN 'FOLIO_XML'.
        wa_fieldcat-seltext_s = 'Folio XML'.
        wa_fieldcat-seltext_m = 'Folio XML'.
        wa_fieldcat-seltext_l = 'Folio XML'.
      WHEN 'EMISOR'.
        wa_fieldcat-seltext_s = 'Emisor'.
        wa_fieldcat-seltext_m = 'Emisor'.
        wa_fieldcat-seltext_l = 'Emisor'.
*      WHEN 'USOCFDI'.
*        wa_fieldcat-seltext_s = 'Uso CFDI'.
*        wa_fieldcat-seltext_m = 'Uso CFDI'.
*        wa_fieldcat-seltext_l = 'Uso CFDI'.
*      WHEN 'DESCRIPPROD'.
*        wa_fieldcat-seltext_s = 'Descripción'.
*        wa_fieldcat-seltext_m = 'Descripción'.
*        wa_fieldcat-seltext_l = 'Descripción'.
      WHEN 'FECPAGO_XML'.
        wa_fieldcat-seltext_s = 'F.Pa. XML'.
        wa_fieldcat-seltext_m = 'Fe.Pa. XML'.
        wa_fieldcat-seltext_l = 'Fecha Pago XML'.
      WHEN 'FECTIMBXML'.
        wa_fieldcat-seltext_s = 'F.Ti. XML'.
        wa_fieldcat-seltext_m = 'Fe.Ti. XML'.
        wa_fieldcat-seltext_l = 'Fecha Timbre XML'.
      WHEN 'VALUT'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'BLART'.
        " wa_fieldcat-no_out = 'X'.
      WHEN 'UTILCAMB'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'XAUTO'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'FDLEV'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'AUGBL'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'AUGDT'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'BLART'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'SERIE_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'CANTIDAD_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'UNIDAD_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'CL_UNI_SAT_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'C_VALOR_UNI_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'C_IMPORTE_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'T_MON_EXT_XML'.
        wa_fieldcat-no_out = 'X'.
*      WHEN 'F_PAGO_XML'.
*        wa_fieldcat-no_out = 'X'.
      WHEN 'F_P_DESC_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'I_MON_EXTR_xml'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'IVA_MON_EXT_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'TOT_MON_EXT_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'TIPO_CAM_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'DEL_ALV'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'I_MON_EXTR_XML'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'BELNR'.
        wa_fieldcat-seltext_s = 'Doc. Pago'.
        wa_fieldcat-seltext_m = 'Doc. Pago'.
        wa_fieldcat-seltext_l = 'Doc. de Pago'.
*      WHEN 'REBZG'.
*        wa_fieldcat-seltext_s = 'Doc. Provisión'.
*        wa_fieldcat-seltext_m = 'Doc. Provisión'.
*        wa_fieldcat-seltext_l = 'Doc. Provisión'.
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
      i_callback_program = sy-repid
      is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat
      i_save             = 'A'
    TABLES
      t_outtab           = it_ingresos
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

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

  FIELD-SYMBOLS <fs_inversiones> TYPE zfi_st_egresos.
  FIELD-SYMBOLS <fs_inversionesadd> TYPE zfi_st_egresos.

  SELECT bk~bukrs AS rbukrs, bk~gjahr, bk~monat AS poper, bk~cpudt, bk~budat,
  bk~belnr, b~hkont AS saknr, b~dmbtr AS base0, b~pswsl AS moneda,
  b~sgtxt, bk~usnam,b~fdtag AS augdt, b~kstar AS gkont,s~txt50 AS banco2,
  b~buzei, b~bschl,b~fdlev, b~xauto
  FROM bkpf AS bk
  INNER JOIN bseg AS b
  ON b~bukrs = bk~bukrs AND b~gjahr = bk~gjahr AND b~belnr = bk~belnr
  LEFT JOIN skat AS s ON s~saknr = b~hkont AND s~spras = 'S'
  WHERE  bk~bukrs EQ @s_bukrs AND
  bk~gjahr =  @p_gjahr AND
  bk~belnr IN @s_belnr AND"=  p_belnr and
  bk~monat IN @s_monat AND
  bk~budat IN @s_budat AND
  bk~cpudt IN @s_CPUDT AND
  bk~blart EQ 'SA' AND
  b~sgtxt IS NOT INITIAL
  AND bk~xreversed NE 'X' "si es X son documentos de Anulación
  "AND b~fdlev = 'F2' "solo egresos
  AND bk~tcode NOT IN ( 'KO88', 'KO8G','FB41' )
  INTO CORRESPONDING FIELDS OF TABLE @it_inversiones.
  "AND b~hkont NOT IN ('0504025014', '0504025192', '0601001020', '0601001073'). "Inversiones

  DELETE it_inversiones WHERE saknr CP '06*'. " gastos
  DELETE it_inversiones WHERE saknr CP '0109*'. " Rentas seguros y fianzas
  DELETE it_inversiones WHERE saknr CP '05*'. " Liquidaciones
  DELETE it_inversiones WHERE saknr CP '01190*'. "IVA
  DELETE it_inversiones WHERE saknr CP '01180*'. "IVA
  DELETE it_inversiones WHERE saknr CP '02090*'. "IVA
  DELETE it_inversiones WHERE saknr CP '02080*'. "IVA
  DELETE it_inversiones WHERE saknr CP '01150*'. "Liquidaciones
  DELETE it_inversiones WHERE saknr CP '0704023003'.
  DELETE it_inversiones WHERE fdlev EQ 'ZK'.
  DELETE it_inversiones WHERE fdlev EQ 'ZD' AND bschl NE '11'.
*    delete it_inversiones where usnam eq 'JOBSAP'.
*  delete it_inversiones where usnam eq 'TR01'.



  IF it_inversiones[] IS NOT INITIAL.


    SELECT bukrs, belnr, gjahr, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev
    INTO TABLE @DATA(it_docBancotmp)
          FROM bseg
          FOR ALL ENTRIES IN @it_inversiones
          WHERE belnr = @it_inversiones-belnr
          AND bukrs = @it_inversiones-rbukrs
          AND gjahr = @it_inversiones-gjahr
          AND bschl IN ( '50' )
          AND augbl NE ''.


    IF it_docBancotmp[] IS NOT INITIAL.
      SELECT bukrs, belnr, gjahr, augbl,dmbtr, zuonr, sgtxt, hkont, fdlev, h_bldat
      INTO TABLE @DATA(it_docBanco)
            FROM bseg
            FOR ALL ENTRIES IN @it_docBancotmp
            WHERE augbl = @it_docBancotmp-augbl
            AND bukrs = @it_docBancotmp-bukrs
            AND gjahr = @it_docBancotmp-gjahr
            AND belnr NE @it_docBancotmp-belnr
            AND bschl = '40'
            AND h_blart EQ 'ZA'.

    ENDIF.
  ENDIF.


  SORT it_inversiones BY cpudt belnr blart.

  DATA: hkont_ingreso TYPE hkont,
        hkont_egreso  TYPE hkont.

  LOOP AT it_inversiones ASSIGNING <fs_inversiones>.

    <fs_inversiones>-gkont = <fs_inversiones>-saknr.
    <fs_inversiones>-banco = <fs_inversiones>-banco2.

    READ TABLE it_docBancotmp INTO DATA(wa_za) WITH KEY belnr = <fs_inversiones>-belnr.
    IF sy-subrc EQ 0.
      READ TABLE it_docbanco INTO DATA(wa_za2) WITH KEY augbl = wa_za-augbl.
      IF sy-subrc EQ 0.
        <fs_inversiones>-doc_banco = wa_za2-belnr.
        <fs_inversiones>-valut = wa_za2-h_bldat.
        IF <fs_inversiones>-sgtxt CP '*DOLAR*'.
          APPEND INITIAL LINE TO it_inversionesadd ASSIGNING <fs_inversionesadd>.
          MOVE-CORRESPONDING <fs_inversiones> TO <fs_inversionesadd>.
          <fs_inversionesadd>-doc_banco = wa_za2-belnr.
          <fs_inversionesadd>-valut = wa_za2-h_bldat.
          <fs_inversionesadd>-total = wa_za2-dmbtr.
          <fs_inversionesadd>-base0 = wa_za2-dmbtr.
        ENDIF.
      ENDIF.
    ENDIF.

    CASE <fs_inversiones>-bschl.
      WHEN '50'.
        IF <fs_inversiones>-fdlev = 'F2'. "bandera egreso transpaso

          IF <fs_inversiones>-sgtxt CP '*DOLAR*'.
            <fs_inversiones>-tot_egreso = <fs_inversiones>-base0.
            "<fs_inversiones>-base0 = <fs_inversiones>-base0.
            "<fs_inversiones>-total = <fs_inversiones>-base0.
          ELSE.
            <fs_inversiones>-tot_egreso = <fs_inversiones>-base0.
            <fs_inversiones>-base0 = <fs_inversiones>-base0.
            <fs_inversiones>-total = <fs_inversiones>-base0.
          ENDIF.
          READ TABLE it_inversiones INTO DATA(wa_F) WITH KEY belnr = <fs_inversiones>-belnr fdlev = 'F1' bschl = '40'.
          IF sy-subrc EQ 0.
            <fs_inversiones>-gkont = wa_F-saknr.
            <fs_inversiones>-banco = wa_F-banco2.
            DELETE it_inversiones WHERE ( fdlev EQ 'F1' OR fdlev EQ '' )  AND belnr = <fs_inversiones>-belnr AND bschl = '40'. "se elimina la bandera de Ingresos
          ELSE. "Por bug de cuando crean inversiones manuales, simula ser un traspaso.
            READ TABLE it_inversiones INTO DATA(wa_Fx) WITH KEY belnr = <fs_inversiones>-belnr fdlev = '' bschl = '40'.
            IF sy-subrc = 0.
              <fs_inversiones>-gkont = wa_Fx-saknr.
              <fs_inversiones>-banco = wa_Fx-banco2.
              DELETE it_inversiones WHERE ( fdlev EQ 'F1' OR fdlev EQ '' )  AND belnr = <fs_inversiones>-belnr AND bschl = '40'. "se elimina la bandera de Egresos.
            ELSE. "SPEI DEVOLUCION
              READ TABLE it_inversiones INTO DATA(wa_Fd) WITH KEY belnr = <fs_inversiones>-belnr fdlev = 'ZD' bschl = '11'.
              IF sy-subrc EQ 0.
                <fs_inversiones>-gkont = wa_Fd-saknr.
                <fs_inversiones>-banco = wa_Fd-banco2.
                DELETE it_inversiones WHERE ( fdlev EQ 'ZD' OR fdlev EQ '' )  AND belnr = <fs_inversiones>-belnr AND bschl = '11'. "se elimina la bandera de Egresos.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE. "inversion ingreso
          <fs_inversiones>-base0 = <fs_inversiones>-base0.
          <fs_inversiones>-total = <fs_inversiones>-base0.
          <fs_inversiones>-tot_egreso = <fs_inversiones>-base0.

          READ TABLE it_inversiones INTO DATA(wa_I) WITH KEY belnr = <fs_inversiones>-belnr xauto = 'X' bschl =  '50'. "indicador creado automatico inv. egresos.

          IF sy-subrc EQ 0.
            <fs_inversiones>-gkont = wa_I-saknr.
            <fs_inversiones>-banco = wa_I-banco2.
            "DELETE it_inversiones WHERE ( xauto EQ 'X' OR xauto EQ '' )  AND belnr = <fs_inversiones>-belnr AND bschl = '50'. "se elimina la bandera de Egresos.
          ENDIF.
        ENDIF.
      WHEN '40'.
        <fs_inversiones>-no_considerado =  <fs_inversiones>-base0.
        <fs_inversiones>-total = <fs_inversiones>-base0.
        "linea borrada en tiempo de ejecución
      WHEN OTHERS.
    ENDCASE.




  ENDLOOP.


  DELETE it_inversiones WHERE fdlev EQ 'F1'.
  APPEND LINES OF it_inversiones    TO it_ordenainvers.
  APPEND LINES OF it_inversionesadd TO it_ordenainvers.
  SORT it_ordenainvers BY budat belnr.

  APPEND LINES OF it_ordenainvers TO it_ingresos.


  IF it_ingresos[] IS INITIAL.
    MESSAGE 'No hay Información que mostrar' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.





ENDFORM.


*&---------------------------------------------------------------------*
FORM leer_xml USING ruta_xml TYPE zaxnare_el034
              CHANGING xml_sat TYPE string.
*&---------------------------------------------------------------------*
  DATA: tabla_xml TYPE TABLE OF string,
        linea_xml TYPE string,
        sruta_xml TYPE string.

  sruta_xml = ruta_xml.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      Filename                = sruta_xml
    CHANGING
      data_tab                = tabla_xml
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc EQ 0.


    LOOP AT tabla_xml INTO linea_xml.
      CONCATENATE xml_sat linea_xml INTO xml_sat.
    ENDLOOP.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
FORM transformar_xml  TABLES gt_xml_data STRUCTURE  smum_xmltb
                      USING   ruta_xml  TYPE zaxnare_el034.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Data Declaration
*&---------------------------------------------------------------------*

  DATA: gv_subrc      TYPE sy-subrc.
  DATA: gv_xml_string TYPE xstring.
  DATA: gv_size       TYPE sytabix.
  " DATA: gt_xml_data   TYPE TABLE OF smum_xmltb.
  DATA: gwa_xml_data  TYPE smum_xmltb.
  DATA: gt_return     TYPE TABLE OF bapiret2.
  DATA: gv_tabix      TYPE sytabix.


  DATA lv_filename TYPE localfile.
  REFRESH gt_xml_data.

  lv_filename = ruta_xml.

  CALL METHOD gcl_xml->import_from_file
    EXPORTING
      filename = lv_filename
    RECEIVING
      retcode  = gv_subrc.

  IF gv_subrc = 0.
    CALL METHOD gcl_xml->render_2_xstring
      IMPORTING
        retcode = gv_subrc
        stream  = gv_xml_string
        size    = gv_size.
    IF gv_subrc = 0.




* Convert XML to internal table
      CALL FUNCTION 'SMUM_XML_PARSE'
        EXPORTING
          xml_input = gv_xml_string
        TABLES
          xml_table = gt_xml_data
          return    = gt_return.
    ENDIF.
  ENDIF.

*  CALL TRANSFORMATION ('Comprobante') "zxml_sat_ts
*  SOURCE XML xml_sat
*  RESULT tab = it_xmlsat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_KA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_ACDOCA[]
*&      --> WA_BKPF_BELNR
*&---------------------------------------------------------------------*
