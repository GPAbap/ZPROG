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
  DATA sruta_xml TYPE string.
  DATA: it_xmlsat TYPE TABLE OF smum_xmltb,
        wa_xmlsat TYPE smum_xmltb.

  DATA vl_banFF.
  DATA vl_ban19.

  DATA: vl_isr_ret  TYPE dmbtr, vl_iva_ret TYPE dmbtr, vl_suma_ret TYPE dmbtr,vl_acumret TYPE dmbtr.
  DATA: vl_perdida  TYPE zutilperd,
        vl_utilidad TYPE zutilperd.

  DATA: vl_indretiva TYPE qsskz,
        vl_indretisr TYPE qsskz,
        vl_menge_str TYPE char30,
        vl_meins_str TYPE char30,
        vl_netpr_str TYPE char30,
        vl_netwr_str TYPE char30.

  FIELD-SYMBOLS: <fs_head>      TYPE zfi_st_egresos, <fs_body> TYPE zfi_st_egresos,
                 <fs_headGV>    TYPE zfi_st_egresos,
                 <fs_headGVadd> TYPE zfi_st_egresos,
                 <fs_kr>        TYPE zfi_st_egresos,
                 <bseg2>        TYPE any,
                 <line>         TYPE any,
                 <line2>        TYPE any.



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
        AND xreversed NE 'X'.
  "and waers in @s_waers. "No tomar en cuenta Documentos de Anulación
  SORT  it_bkpf BY belnr.

  "DELETE it_bkpf WHERE belnr CP '0400*'. "Patron de contenido. //04072023 Se vuelven
  "a dejar los documentos GV 04000, por petición del Usuario (Rene Arceo)

  IF it_bkpf IS INITIAL.
    MESSAGE 'No hay Información que mostrar' TYPE 'S' DISPLAY LIKE 'E'.
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
         b~gvtyp, b~shkzg, b~koart
    INTO TABLE @DATA(it_bseg)
    FROM bseg AS b
   FOR ALL ENTRIES IN @it_bkpf
          WHERE belnr = @it_bkpf-belnr AND gjahr = @it_bkpf-gjahr AND bukrs = @it_bkpf-bukrs.


  DELETE it_bseg WHERE hkont = '0601001058'.
  "---------------------------------------------
  "----------desglose de base IVA IVA RETENIDO EN LA FACTURA
*  IF it_acdoca[] IS NOT INITIAL.
  SELECT b~bukrs, b~belnr, b~buzei, b~augbl, b~buzid, b~shkzg, b~mwskz, b~dmbtr,b~hwbas, b~qbshb, b~bschl, b~hkont, b~mwart,
         b~sgtxt, b~ebeln, b~aufnr, h_budat, h_bldat, h_blart, b~pswsl AS moneda,b~lifnr, b~gjahr, b~koart, b~hwbas AS perutil,
         b~hkont AS ctaperutil, b~mwsk1, b~mwsk2, b~dmbt2,b~wrbtr
        INTO TABLE @DATA(it_bseg2)
        FROM bseg AS b
        FOR ALL ENTRIES IN @it_bkpf
        WHERE augbl = @it_bkpf-belnr  AND bukrs = @it_bkpf-bukrs
        AND gjahr = @it_bkpf-gjahr
        AND auggj = @it_bkpf-gjahr
        AND h_waers IN @s_waers.

  IF it_bseg2[] IS NOT INITIAL.


    SELECT b~bukrs, b~belnr, b~buzei, b~augbl, b~buzid, b~shkzg, b~mwskz, b~dmbtr,b~hwbas, b~qbshb, b~bschl, b~hkont, b~mwart,
           b~sgtxt, b~ebeln, b~aufnr, h_budat, h_bldat, h_blart, b~pswsl AS moneda,b~lifnr, b~koart,b~gvtyp,
           b~hwbas AS perutil, b~hkont AS ctaperutil
          INTO TABLE @DATA(it_bseg3)
          FROM bseg AS b

          FOR ALL ENTRIES IN @it_bseg2
          WHERE b~belnr = @it_bseg2-belnr  AND bukrs = @it_bseg2-bukrs
          AND b~gjahr = @it_bseg2-gjahr
          AND b~h_monat IN @s_monat.




  ENDIF.

  LOOP AT it_bseg2 ASSIGNING <bseg2>.
    IF <line> IS ASSIGNED.
      UNASSIGN <line>.
    ENDIF.

    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
    READ TABLE it_bseg3 INTO DATA(wa_gkont1) WITH KEY belnr = <line> buzid = 'W'.
    UNASSIGN <line>.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'HKONT' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_gkont1-hkont.
      UNASSIGN <line>.
    ELSE.
      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
      READ TABLE it_bseg3 INTO DATA(wa_gkont2) WITH KEY belnr = <line> gvtyp = 'X'.
      UNASSIGN <line>.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT 'HKONT' OF STRUCTURE <bseg2> TO <line>.
        <line> = wa_gkont2-hkont.
        UNASSIGN <line>.
      ENDIF.

    ENDIF.

    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <bseg2> TO <line>.
    READ TABLE it_bseg3 INTO DATA(wa_ebeln) WITH KEY belnr = <line> buzid = 'W'.
    UNASSIGN <line>.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'EBELN' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_ebeln-ebeln. "base 16/8
      UNASSIGN <line>.

      ASSIGN COMPONENT 'KOART' OF STRUCTURE <bseg2> TO <line>.
      <line> = wa_ebeln-koart. "base 16/8
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
        <line> =  <line2>.
        UNASSIGN <line>.
        UNASSIGN <line2>.
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

  ENDLOOP.
*  ENDIF.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  SELECT bseg~belnr, ekpo~ebeln, ekpo~menge, ekpo~meins, ekpo~netpr, ekpo~netwr
   INTO TABLE @DATA(it_ekpo)
     FROM ekpo
  INNER JOIN bseg ON bseg~ebeln = ekpo~ebeln AND bseg~bukrs = ekpo~bukrs AND bseg~h_blart = 'RE'
  FOR ALL ENTRIES IN @it_bseg2
  WHERE ekpo~ebeln = @it_bseg2-ebeln  AND ekpo~bukrs = @it_bseg2-bukrs.

  IF it_bseg3 IS NOT INITIAL.
    SELECT bseg~belnr, ekpo~ebeln, ekpo~menge, ekpo~meins, ekpo~netpr, ekpo~netwr
      FROM ekpo
      INNER JOIN bseg ON bseg~ebeln = ekpo~ebeln AND bseg~bukrs = ekpo~bukrs AND bseg~h_blart = 'RE'
      FOR ALL ENTRIES IN @it_bseg3
   WHERE ekpo~ebeln = @it_bseg3-ebeln  AND ekpo~bukrs = @it_bseg3-bukrs
   AND ekpo~ebeln IS NOT INITIAL
   APPENDING TABLE @it_ekpo.
  ENDIF.
  """"


  "----------------------------------------------------------------------
  "Información de los XML
  SELECT z~doc_comp, z~doc_contable, z~uuid, z~metododepago, z~formadepago, z~total, z~moneda,
         z~folio, z~rfc_e, z~xml_dir
    INTO TABLE @DATA(it_xml)
    FROM zaxnare_tb001 AS z
    FOR ALL ENTRIES IN @it_bkpf
        WHERE doc_comp = @it_bkpf-belnr AND bukrs = @it_bkpf-bukrs." AND ejercicio = @it_bkpf-gjahr.


  " Cuentas del SAT en tabla Z
  SELECT cvesat, descsat
      INTO TABLE @DATA(it_cuentassat)
  FROM zfi_tt_clavessat.
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
 "   IF <fs_head>-moneda EQ 'USD'.
      <fs_head>-tipocambio = wa_bkpf-kursf.
      <fs_head>-tipo_cam_xml = wa_bkpf-kursf.
  "  ELSE.
   "   <fs_head>-tipocambio = '1.00'.
    "  <fs_head>-tipo_cam_xml = '1.00'.
    "ENDIF.

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

    "proveedor

    SELECT  l~lifnr,l~stcd1,l~name1 INTO TABLE @DATA(it_lifnr)
        FROM bseg AS b
        INNER JOIN lfa1 AS l ON l~lifnr = b~lifnr
        WHERE b~bukrs = @s_bukrs AND
        b~gjahr = @p_gjahr AND b~belnr = @wa_bkpf-belnr.
        IF sy-subrc = 0.
          read TABLE it_lifnr into data(wa_lfa11) index 1.
          <fs_head>-lifnr = wa_lfa11-lifnr.
          <fs_head>-stcd1 = wa_lfa11-stcd1. "encabezado
          <fs_head>-name1 = wa_lfa11-name1.
        ENDIF.

    "datos de Xml de documento de pago

    "datos del pago
    CLEAR: vl_iva_ret, vl_isr_ret.

    LOOP AT it_bseg INTO DATA(wa_bseg) WHERE belnr = wa_bkpf-belnr AND bukrs = wa_bkpf-bukrs AND gjahr = wa_bkpf-gjahr.
      IF wa_bseg-augbl EQ wa_bkpf-belnr. "pago proveedores Grupo Porres.
        " <fs_head>-tot_egreso = wa_bseg-dmbtr.
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
                                         wa_bseg-qsskz EQ 'IE'   ). "ISR Retenido
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
        <fs_headgv>-del_alv = 'X'.

        IF wa_bseg-shkzg EQ 'S'.
          <fs_headgv>-base0 = wa_bseg-dmbtr.
        ELSE.
          <fs_headgv>-base0 = wa_bseg-dmbtr * -1.
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

    "-------------------------------------------------
    IF <fs_head>-usnam IS INITIAL.
      SELECT SINGLE usnam FROM acdoca
      INTO <fs_head>-usnam
      WHERE belnr = wa_bkpf-belnr AND
      rbukrs = wa_bkpf-bukrs AND
      gjahr = wa_bkpf-gjahr.
    ENDIF.


*        "Datos de la factura (Documento Provision)
    LOOP AT it_bseg2 INTO DATA(wa_bseg2) WHERE augbl = wa_bkpf-belnr.
      IF wa_bseg2-augbl EQ wa_bseg2-belnr.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_body>.
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
          <fs_body>-tipo_cam_xml = wa_tipocambio-kursf.
        ENDIF.
      ELSE.
        <fs_body>-tipocambio = '1.00'.
        <fs_body>-tipo_cam_xml = '1.00'.
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
        <fs_body>-base0 = wa_bseg2-dmbtr.
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
            <fs_body>-base16 = wa_bseg2-hwbas * -1.
            <fs_body>-iva = wa_bseg2-dmbtr * -1.

            READ TABLE it_a003 INTO DATA(wa_nc16) WITH KEY mwskz = wa_bseg2-mwskz.
            IF sy-subrc EQ 0.
              READ TABLE it_indiva INTO DATA(wa_tasanc16) WITH KEY knumh = wa_nc16-knumh.
              IF sy-subrc EQ 0.
                <fs_body>-tasa = wa_tasanc16-kbetr / 10.
              ENDIF.
            ENDIF.

          ENDIF.

          IF wa_bseg2-mwskz EQ 'X0' OR wa_bseg2-mwskz EQ 'X5' OR wa_bseg2-mwsk2 EQ 'X0' OR wa_bseg2-mwsk2 EQ 'X5'. "base 0
            <fs_body>-base0 = wa_bseg2-hwbas * -1.

          ENDIF.

          IF wa_bseg2-mwskz EQ 'X2' OR wa_bseg2-mwskz EQ 'X6' OR wa_bseg2-mwsk2 EQ 'X2' OR wa_bseg2-mwsk2 EQ 'X6'. "base 8
            <fs_body>-base8 = wa_bseg2-hwbas * -1.
            <fs_body>-iva = wa_bseg2-dmbtr * -1.

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
          <fs_body>-total = wa_bseg2-dmbtr.
        ENDIF.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        <fs_body>-uuid_concep = wa_bseg2-sgtxt.
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

          IF wa_bseg2-dmbt2 EQ 0.
            <fs_body>-base8 = ( <fs_body>-base8 + wa_bseg2-dmbtr ) - wa_bseg2-perutil.
          ELSE.
            <fs_body>-base8 = ( <fs_body>-base8 + wa_bseg2-dmbt2 ) - wa_bseg2-perutil.
          ENDIF.

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

        IF wa_bseg2-shkzg  EQ 'H' AND ( wa_bseg2-mwskz EQ 'X3' OR wa_bseg2-mwskz EQ 'X7' ) AND wa_bseg2-buzid NE 'T'. "BASE 16
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
        ENDIF.

        IF wa_bseg2-mwskz IS INITIAL.
          <fs_body>-wsl = wa_bseg2-dmbtr. "No tienen base, por lo regular SA
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
      ELSE.
        READ TABLE it_ekpo INTO DATA(wa_ekpo1) WITH KEY belnr = wa_bseg2-belnr.
        IF sy-subrc EQ 0.
          <fs_body>-ebeln = wa_ekpo1-ebeln.
        ENDIF.
      ENDIF.

      CASE wa_bseg2-koart.
        WHEN 'A'.
          <fs_body>-zkoart = 'A-Activo Fijo'.
        WHEN 'M'.
        WHEN OTHERS.
      ENDCASE.

      IF wa_bseg2-aufnr IS NOT INITIAL.
        <fs_body>-aufnr = wa_bseg2-aufnr.
      ENDIF.

      <fs_body>-DOC_banco = <fs_head>-DOC_banco.
      <fs_body>-fecdocbanco = <fs_head>-fecdocbanco.

      IF wa_bseg2-qbshb > 0. "EQ vl_suma_ret. "si los valores de la suma de las retenciones son iguales a este campo de retenciónes, se colocan
        IF vl_iva_ret > 0.
          "<fs_body>-iva_ret = wa_bseg2-qbshb * -1.
          READ TABLE it_t059z INTO DATA(wt029z) WITH KEY witht = vl_indretiva wt_withcd = vl_indretiva.
          IF sy-subrc EQ 0.
            <fs_body>-iva_ret = <fs_body>-base16 * ( wt029z-qsatz / wt029z-qproz  ) * -1.
          ELSE.
            <fs_body>-iva_ret = wa_bseg2-qbshb * -1.
          ENDIF.

        ENDIF.

        IF vl_isr_ret > 0.
          "  <fs_body>-isr_ret = vl_isr_ret * -1.
          READ TABLE it_t059z INTO DATA(wt029z1) WITH KEY witht = vl_indretisr wt_withcd = vl_indretisr.
          IF sy-subrc EQ 0.
            <fs_body>-isr_ret = <fs_body>-base16 * ( wt029z1-qsatz / wt029z1-qproz  ) * -1.
          ELSE.
            <fs_body>-isr_ret = vl_isr_ret * -1.
          ENDIF.
        ENDIF.

      ENDIF.
*

*
      IF <fs_body>-base8 NE 0.
        <fs_body>-base8  = <fs_body>-base8." - <fs_body>-base0.
        <fs_body>-total = <fs_body>-base8 + <fs_body>-base0 + <fs_body>-iva +
                          <fs_body>-utilidad + <fs_body>-perdida.
      ENDIF.

      IF <fs_body>-base16 NE 0.
        <fs_body>-base16  = <fs_body>-base16." - <fs_body>-base0.
        <fs_body>-total = <fs_body>-base16 + + <fs_body>-base0 + <fs_body>-base8 +
                          <fs_body>-iva + <fs_body>-utilidad + <fs_body>-perdida.
      ENDIF.
*
*
*
      "acceso al XML de doc. proveedor
      READ TABLE it_xml INTO DATA(wa_xml) WITH KEY doc_comp = wa_bkpf-belnr doc_contable = wa_bseg2-belnr .
      IF sy-subrc EQ 0.
        "se lee el complemento de datos del xml
        " sruta_xml = wa_xml-xml_dir.
        "ruta_xml = sruta_xml.
        REFRESH it_xmlsaT.
        PERFORM transformar_xml TABLES it_xmlsat[] USING wa_xml-xml_dir.
        IF it_xmlsat[] IS NOT INITIAL.
          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'UsoCFDI'.
          <fs_body>-usocfdi = wa_xmlsat-cvalue.

          SELECT SINGLE bezei INTO <fs_body>-descripprod
            FROM TVV3t WHERE spras = 'S' AND kvgr3 = <fs_body>-usocfdi.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'ClaveProdServ'.
          <fs_body>-codigo_sat = wa_xmlsat-cvalue.

          READ TABLE it_cuentassat INTO DATA(wa_ctasat) WITH KEY cvesat = wa_xmlsat-cvalue.
          IF sy-subrc EQ 0.
            <fs_body>-concep_sat = wa_ctasat-descsat.
          ENDIF.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Moneda'.
          <fs_body>-moneda_xml = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'MetodoPago'.
          <fs_body>-metpago_xml = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'UUID'.
          <fs_body>-uuid_pago = wa_xmlsat-cvalue.



          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Folio'.
          <fs_body>-folio_xml = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Emisor'.
          <fs_body>-emisor = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Descripcion'.
          <fs_body>-descripprod = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Fecha'.
          <fs_body>-fecpago_xml = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'FechaTimbrado'.
          <fs_body>-fectimbxml = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Serie'.
          <fs_body>-serie_xml = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' cname = 'Moneda'.
          <fs_body>-t_mon_ext_xml = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' cname = 'FormaPago'.
          <fs_body>-f_pago_xml = wa_xmlsat-cvalue.


          SELECT SINGLE bezei INTO <fs_body>-f_p_desc_xml
          FROM TVV1t WHERE spras = 'S' AND kvgr1 = <fs_body>-f_pago_xml.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' cname = 'MetodoPago'.
          <fs_body>-metpago_xml = wa_xmlsat-cvalue.

          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '3' cname = 'ClaveUnidad'.
          <fs_body>-cl_uni_sat_xml = wa_xmlsat-cvalue.


          """"""""""""SU ES USD"
          IF <fs_body>-t_mon_ext_xml EQ 'USD'.
            CLEAR wa_xmlsat.
            READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' cname = 'SubTotal'.
            <fs_body>-i_mon_extr_xml = wa_xmlsat-cvalue.

            CLEAR wa_xmlsat.
            READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' cname = 'Total'.
            <fs_body>-tot_mon_ext_xml = wa_xmlsat-cvalue.

            CLEAR wa_xmlsat.
            READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '2' cname = 'TotalImpuestosTrasladados'.
            <fs_body>-iva_mon_ext_xml = wa_xmlsat-cvalue.
            """"""""""""""""""""""""""""""""""""""""""""""""
          ENDIF.

*            SELECT SINGLE bezei INTO <fs_body>-d_
*            FROM TVV2t WHERE spras = 'S' AND kvgr2 = <fs_body>-metpago_xml.

          "se cargan en string las cantidad y unidades del xml
          CLEAR wa_xmlsat.
          LOOP AT it_ekpo INTO DATA(wa_ekpo) WHERE ebeln = <fs_body>-ebeln.
            CLEAR: vl_menge_str, vl_meins_str,vl_netpr_str,vl_netwr_str.
            vl_menge_str = wa_ekpo-menge.
            CONDENSE vl_menge_str NO-GAPS.
            vl_meins_str = wa_ekpo-meins.
            CONDENSE vl_meins_str NO-GAPS.
            vl_netpr_str = wa_ekpo-netpr.
            CONDENSE vl_netpr_str NO-GAPS.
            vl_netwr_str = wa_ekpo-netwr.
            CONDENSE vl_netwr_str NO-GAPS.


            CONCATENATE <fs_body>-cantidad_xml vl_menge_str INTO <fs_body>-cantidad_xml SEPARATED BY '|'.
            CONCATENATE <fs_body>-unidad_xml vl_meins_str INTO <fs_body>-unidad_xml SEPARATED BY '|'.
            CONCATENATE <fs_body>-c_valor_uni_xml vl_netpr_str INTO <fs_body>-c_valor_uni_xml SEPARATED BY '|'.
            CONCATENATE <fs_body>-c_importe_xml vl_netwr_str INTO <fs_body>-c_importe_xml SEPARATED BY '|'.
          ENDLOOP.
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        ENDIF.

      ENDIF.
*


      IF <fs_body>-iva_ret NE 0 OR <fs_body>-isr_ret NE 0 OR <fs_body>-nom_ret NE 0.
        <fs_body>-total = <fs_body>-total + <fs_body>-iva_ret + <fs_body>-isr_ret + <fs_body>-nom_ret + <fs_body>-utilidad + <fs_body>-perdida.
      ENDIF.

*
    ENDLOOP.
*

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
      WHEN 'DEL_ALV'.
        wa_fieldcat-no_out = 'X'.
*      WHEN 'ZUONR'.
*        wa_fieldcat-no_out = 'X'.
      WHEN 'UTILIDAD'.
        wa_fieldcat-seltext_s = 'Utilidad Camb.'.
        wa_fieldcat-seltext_m = 'Utilidad Camb.'.
        wa_fieldcat-seltext_l = 'Utilidad Camb.'.
      WHEN 'PERDIDA'.
        wa_fieldcat-seltext_s = 'Pérdida Camb.'.
        wa_fieldcat-seltext_m = 'Pérdida Camb.'.
        wa_fieldcat-seltext_l = 'Pérdida Camb.'.
      WHEN 'BLART_RV'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZKOART'.
        wa_fieldcat-seltext_s = 'Tipo Imp.'.
        wa_fieldcat-seltext_m = 'Tipo Imp.'.
        wa_fieldcat-seltext_l = 'Tipo Imp.'.
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
      WHEN 'CODIGO_SAT'.
        wa_fieldcat-seltext_s = 'Código SAT'.
        wa_fieldcat-seltext_m = 'Código SAT'.
        wa_fieldcat-seltext_l = 'Código SAT'.
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
      WHEN 'USOCFDI'.
        wa_fieldcat-seltext_s = 'Uso CFDI'.
        wa_fieldcat-seltext_m = 'Uso CFDI'.
        wa_fieldcat-seltext_l = 'Uso CFDI'.
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
      WHEN 'BELNR'.
        wa_fieldcat-seltext_s = 'Doc. Pago'.
        wa_fieldcat-seltext_m = 'Doc. Pago'.
        wa_fieldcat-seltext_l = 'Doc. de Pago'.
*      WHEN 'REBZG'.
*        wa_fieldcat-seltext_s = 'Doc. Provisión'.
*        wa_fieldcat-seltext_m = 'Doc. Provisión'.
*        wa_fieldcat-seltext_l = 'Doc. Provisión'.

      WHEN 'SERIE_XML'.
        wa_fieldcat-seltext_s = 'SERIE'.
        wa_fieldcat-seltext_m = 'SERIE'.
        wa_fieldcat-seltext_l = 'SERIE'.
      WHEN 'CANTIDAD_XML'.
        wa_fieldcat-seltext_s = 'CANTIDAD'.
        wa_fieldcat-seltext_m = 'CANTIDAD'.
        wa_fieldcat-seltext_l = 'CANTIDAD'.
      WHEN 'UNIDAD_XML'.
        wa_fieldcat-seltext_s = 'UNIDAD'.
        wa_fieldcat-seltext_m = 'UNIDAD'.
        wa_fieldcat-seltext_l = 'UNIDAD'.
      WHEN 'CL_UNI_SAT_XML'.
        wa_fieldcat-seltext_s = 'UNIDAD SAT'.
        wa_fieldcat-seltext_m = 'UNIDAD SAT'.
        wa_fieldcat-seltext_l = 'UNIDAD SAT'.
      WHEN 'C_VALOR_UNI_XML'.
        wa_fieldcat-seltext_s = 'VALOR UNI.'.
        wa_fieldcat-seltext_m = 'VALOR UNI.'.
        wa_fieldcat-seltext_l = 'VALOR UNI.'.
      WHEN 'C_IMPORTE_XML'.
        wa_fieldcat-seltext_s = 'IMPORTE'.
        wa_fieldcat-seltext_m = 'IMPORTE'.
        wa_fieldcat-seltext_l = 'IMPORTE'.
      WHEN 'T_MON_EXT_XML'.
        wa_fieldcat-seltext_s = 'TIP M. EX.'.
        wa_fieldcat-seltext_m = 'TIPO MXN EXTR.'.
        wa_fieldcat-seltext_l = 'TOTAL MXN ENXTR.'.
      WHEN 'F_PAGO_XML'.
        wa_fieldcat-seltext_s = 'FORMA PAGO'.
        wa_fieldcat-seltext_m = 'FORMA PAGO'.
        wa_fieldcat-seltext_l = 'FORMA PAGO'.
      WHEN 'F_P_DESC_XML'.
        wa_fieldcat-seltext_s = 'DESCRIPCION'.
        wa_fieldcat-seltext_m = 'DESCRIPCION'.
        wa_fieldcat-seltext_l = 'DESCRIPCION'.
      WHEN 'I_MON_EXTR_XML'.
        wa_fieldcat-seltext_s = 'IMP. MXN EXTR.'.
        wa_fieldcat-seltext_m = 'IMP. MXN EXTR.'.
        wa_fieldcat-seltext_l = 'IMP. MXN EXTR.'.
      WHEN 'IVA_MON_EXT_XML'.
        wa_fieldcat-seltext_s = 'IVA MXN EXTR.'.
        wa_fieldcat-seltext_m = 'IVA MXN EXTR.'.
        wa_fieldcat-seltext_l = 'IVA MXN EXTR.'.
      WHEN 'TOT_MON_EXT_XML'.
        wa_fieldcat-seltext_s = 'T. MXN EXTR.'.
        wa_fieldcat-seltext_m = 'TOTAL MXN. EXTR.'.
        wa_fieldcat-seltext_l = 'TOTAL MXN EXTR.'.
      WHEN 'TIPO_CAM_XML'.
        wa_fieldcat-seltext_s = 'TIPO CAMBIO'.
        wa_fieldcat-seltext_m = 'TIPO CAMBIO'.
        wa_fieldcat-seltext_l = 'TIPO CAMBIO'.

      WHEN 'T_MON_EXT_XML'.
        wa_fieldcat-seltext_s = 'T. MON SAT'.
        wa_fieldcat-seltext_m = 'TIPO MONEDA SAT'.
        wa_fieldcat-seltext_l = 'TIPO MONEDA SAT'.
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
            DELETE it_inversiones WHERE ( xauto EQ 'X' OR xauto EQ '' )  AND belnr = <fs_inversiones>-belnr AND bschl = '50'. "se elimina la bandera de Egresos.
          ENDIF.
        ENDIF.
      WHEN '50'.
        "linea borrada en tiempo de ejecución
      WHEN OTHERS.
    ENDCASE.




  ENDLOOP.


  DELETE it_inversiones WHERE fdlev EQ 'F1'.
  APPEND LINES OF it_inversiones    TO it_ordenainvers.
  APPEND LINES OF it_inversionesadd TO it_ordenainvers.
  SORT it_ordenainvers BY budat belnr.

  APPEND LINES OF it_ordenainvers TO it_ingresos.








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
  DATA: gcl_xml       TYPE REF TO cl_xml_document.
  DATA: gv_subrc      TYPE sy-subrc.
  DATA: gv_xml_string TYPE xstring.
  DATA: gv_size       TYPE sytabix.
  " DATA: gt_xml_data   TYPE TABLE OF smum_xmltb.
  DATA: gwa_xml_data  TYPE smum_xmltb.
  DATA: gt_return     TYPE TABLE OF bapiret2.
  DATA: gv_tabix      TYPE sytabix.


  DATA lv_filename TYPE localfile.
  REFRESH gt_xml_data.
  CREATE OBJECT gcl_xml.
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
