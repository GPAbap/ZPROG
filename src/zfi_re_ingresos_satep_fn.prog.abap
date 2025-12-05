*&---------------------------------------------------------------------*
*& Include zfi_re_ingresos_satep_fn
*&---------------------------------------------------------------------*
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
  DATA vl_status_http.
  DATA vl_registro.

  FIELD-SYMBOLS: <fs_initial>      TYPE zfi_st_ingresos_satep,
                 <fs_head>         TYPE zfi_st_ingresos_satep,
                 <fs_body>         TYPE zfi_st_ingresos_satep,
                 <fs_bodyextra>    TYPE zfi_st_ingresos_satep,
                 <fs_devoluciones> TYPE zfi_st_ingresos_satep.


  CLEAR:   i_lineitems, i_fechas, i_customer.
  REFRESH: i_lineitems, i_fechas, i_customer.

*** Llena el parametro de fecha para la bapi
  LOOP AT s_budat.
    MOVE-CORRESPONDING s_budat TO i_fechas.
    APPEND i_fechas.
  ENDLOOP.

*** Llena el parametro de cliente para la bapi
  LOOP AT s_kunnr.
    MOVE-CORRESPONDING s_kunnr TO i_customer.
    APPEND i_customer.
  ENDLOOP.


*  CALL FUNCTION 'ZBAPI_AR_ACC_GETOPENITEMS'
*    EXPORTING
*      companycode = s_bukrs
*      customer    = '*'
*    IMPORTING
*      return      = i_return
*    TABLES
*      lineitems   = i_lineitems
*      fechas      = i_fechas
*      customer2   = i_customer.
*
*  SORT i_lineitems BY doc_no.
*
*
**** Borra los documentos no solicitados
*  DELETE i_lineitems WHERE doc_no NOT IN s_belnr.
*
**** Borra los documentos de compensacion
*  DELETE i_lineitems WHERE doc_no+0(4) = '0100'.
*
**** Borra los docuemtnos anulados
*  DELETE i_lineitems WHERE reversal_doc IS NOT INITIAL.
*
*  DELETE i_lineitems WHERE doc_type NE 'DZ'.
*  DELETE ADJACENT DUPLICATES FROM  i_lineitems COMPARING doc_no.


  SELECT b1~bukrs, b1~gjahr, b1~belnr, b1~augbl, b1~rebzg,  b1~blart, b1~budat,b1~augdt, b1~monat, b1~xblnr, b1~cpudt, b1~waers,
        b1~vbeln,b1~dmbtr AS pago, b2~dmbtr,b4~dmbtr AS iva,b4~hwbas, b4~mwskz,k2~kbetr,
        k~kunnr,k~name1, k~stcd1,k~stcd3,
        b1~hkont, s~txt50, z~archivoxml
    FROM bsad_view AS b1
    INNER JOIN kna1 AS k ON k~kunnr EQ b1~kunnr
    "INNER JOIN bkpf AS b3 ON b3~belnr EQ b1~augbl AND b3~bukrs EQ b1~bukrs
    LEFT JOIN bseg AS b2 ON b2~bukrs EQ b1~bukrs AND  b2~belnr EQ b1~augbl AND b2~fdlev EQ 'F1'
    LEFT JOIN bseg AS b4 ON b4~bukrs EQ b1~bukrs AND b4~belnr EQ b1~belnr AND b4~buzid EQ 'T'
    "LEFT JOIN bseg AS b3 ON b3~bukrs EQ b1~bukrs AND b3~augbl EQ b1~augbl and b3~bschl = '01'
    LEFT JOIN a003 AS a ON a~mwskz EQ b4~mwskz AND kappl = 'TX' AND kschl = 'MWAS' AND aland = 'MX'
    LEFT JOIN konp AS k2 ON k2~knumh EQ a~knumh
    LEFT JOIN skat AS s ON s~spras EQ 'S' AND s~saknr EQ b2~hkont
    LEFT JOIN zalv_comp_pago AS z ON z~doc_comp = b1~augbl AND z~factura = b1~vbeln
    "FOR ALL ENTRIES IN @i_lineitems
    WHERE b1~bukrs = @s_bukrs
    AND   b1~kunnr IN @s_kunnr " @i_lineitems-customer
    AND   b1~augbl IN @s_belnr" @i_lineitems-doc_no
    "AND   b1~monat  in @s_monat
    AND   b1~budat IN @s_budat  "@i_lineitems-pstng_date
    "AND   b1~bschl ne '01'
    AND b1~blart = 'DZ'
UNION ALL
    SELECT b1~bukrs, b1~gjahr, b1~belnr, b1~augbl, b1~rebzg,  b1~blart, b1~budat,b1~augdt, b1~monat, b1~xblnr, b1~cpudt, b1~waers,
        b1~vbeln,b1~dmbtr AS pago, b2~dmbtr,b4~dmbtr AS iva,b4~hwbas, b4~mwskz,k2~kbetr,
        k~kunnr,k~name1, k~stcd1,k~stcd3,
        b1~hkont, s~txt50, z~archivoxml
    FROM bsid_view AS b1
    INNER JOIN kna1 AS k ON k~kunnr EQ b1~kunnr
    "INNER JOIN bkpf AS b3 ON b3~belnr EQ b1~augbl AND b3~bukrs EQ b1~bukrs
    LEFT JOIN bseg AS b2 ON b2~bukrs EQ b1~bukrs AND  b2~belnr EQ b1~augbl AND b2~fdlev EQ 'F1'
    LEFT JOIN bseg AS b4 ON b4~bukrs EQ b1~bukrs AND b4~belnr EQ b1~belnr AND b4~buzid EQ 'T'
    "LEFT JOIN bseg AS b3 ON b3~bukrs EQ b1~bukrs AND b3~augbl EQ b1~augbl and b3~bschl = '01'
    LEFT JOIN a003 AS a ON a~mwskz EQ b4~mwskz AND kappl = 'TX' AND kschl = 'MWAS' AND aland = 'MX'
    LEFT JOIN konp AS k2 ON k2~knumh EQ a~knumh
    LEFT JOIN skat AS s ON s~spras EQ 'S' AND s~saknr EQ b2~hkont
    LEFT JOIN zalv_comp_pago AS z ON z~doc_comp = b1~augbl AND z~factura = b1~vbeln
    "FOR ALL ENTRIES IN @i_lineitems
    WHERE b1~bukrs = @s_bukrs
    AND   b1~kunnr IN @s_kunnr " @i_lineitems-customer
    AND   b1~augbl IN @s_belnr" @i_lineitems-doc_no
    "AND   b1~monat  in @s_monat
    AND   b1~budat IN @s_budat  "@i_lineitems-pstng_date
    "AND   b1~bschl ne '01'
    AND b1~blart = 'DZ'

    INTO TABLE @DATA(it_bkpf).


  IF it_bkpf IS INITIAL.
    MESSAGE 'No hay Información que mostrar' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.

  ELSE.

    SORT it_bkpf BY augbl.

    SELECT b1~kunnr, b1~augbl, b1~belnr, b1~vbeln, b1~dmbtr
       FROM bsad_view AS b1
    INTO TABLE @DATA(bsad_rv)
    FOR ALL ENTRIES IN @it_bkpf
    WHERE augbl = @it_bkpf-augbl
    AND rebzg = @it_bkpf-rebzg
    AND blart = 'RV'.



    SELECT bukrs,gjahr, vbeln, archivoxml
      FROM zsd_cfdi_timbre
        FOR ALL ENTRIES IN @it_bkpf
      WHERE vbeln = @it_bkpf-vbeln
    INTO TABLE @DATA(it_timbrerv).

    SELECT bukrs,gjahr, vbeln, archivoxml
    APPENDING TABLE @it_timbrerv
      FROM zsd_cfdi_timbre
        FOR ALL ENTRIES IN @bsad_rv
      WHERE vbeln = @bsad_rv-vbeln
    .





    SELECT bukrs,gjahr, doc_pago, factura, doc_comp ,uuid_dr, archivoxml
      FROM zalv_comp_pago
        FOR ALL ENTRIES IN @it_bkpf
      WHERE bukrs = @it_bkpf-bukrs AND doc_pago = @it_bkpf-augbl AND factura = @it_bkpf-vbeln
    INTO TABLE @DATA(it_compensa).



  ENDIF.


*  LOOP AT it_bsad INTO DATA(wa_bsad).

  CLEAR: vl_sumaDz, vl_sumaRv, vl_diferencia, vl_devoluciones, vl_nc.
*
  LOOP AT it_bkpf INTO DATA(wa_bkpf).



    APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_head>.
*
    <fs_head>-fecha_cobro = wa_bkpf-budat.
    <fs_head>-concepto_bien = space.
    IF wa_bkpf-stcd1 IS INITIAL.
      <fs_head>-rfc = wa_bkpf-stcd3.
    ELSE.
      <fs_head>-rfc = wa_bkpf-stcd1.
    ENDIF.

    <fs_head>-name1         = wa_bkpf-name1.
    <fs_head>-moneda_cobro  = wa_bkpf-waers.
    <fs_head>-monto         = wa_bkpf-pago.
    <fs_head>-total         = wa_bkpf-pago.
    <fs_head>-fecha_cobro   = wa_bkpf-budat.

    <fs_head>-ref_bancaria  = wa_bkpf-xblnr.
    <fs_head>-num_cta_ban   = wa_bkpf-hkont.
    <fs_head>-inst_financ   = wa_bkpf-txt50.
    <fs_head>-belnr         = wa_bkpf-rebzg.
    <fs_head>-doc_cobro     = wa_bkpf-augbl.
    <fs_head>-kunnr         = wa_bkpf-kunnr.
    <fs_head>-hkont         = wa_bkpf-hkont.
    <fs_head>-vbeln        = wa_bkpf-vbeln.

** Validación de Documento Logistico venga vacio ********************
    IF <fs_head>-vbeln IS INITIAL.
      DATA vl_suma TYPE dmbtr.

      LOOP AT it_bkpf INTO DATA(wa_vbeln_v) WHERE augbl = wa_bkpf-augbl AND kunnr = wa_bkpf-kunnr.
        vl_suma = vl_suma + wa_vbeln_v-pago.
      ENDLOOP.

      LOOP AT bsad_rv INTO DATA(wa_rv) WHERE augbl = wa_bkpf-augbl AND kunnr = wa_bkpf-kunnr.
        READ TABLE it_bkpf INTO DATA(exists) WITH KEY rebzg = wa_rv-belnr.
        IF sy-subrc EQ 0.
          vl_suma = vl_suma - wa_rv-dmbtr.

        ELSE.
          <fs_head>-vbeln =  wa_rv-vbeln.
          <fs_head>-belnr =  wa_rv-belnr.
*       <fs_head>-monto =  wa_rv-dmbtr.
*       <fs_head>-total =  wa_rv-dmbtr.

        ENDIF.
      ENDLOOP.


    ENDIF.
**********************************************************************

    READ TABLE it_compensa INTO DATA(wa_compensa) WITH KEY bukrs = wa_bkpf-bukrs
                                                          doc_pago = wa_bkpf-augbl
                                                          factura = <fs_head>-vbeln.
    IF sy-subrc NE 0.
      CLEAR wa_compensa.
    ELSE.
      <fs_head>-folfis        = wa_compensa-uuid_dr.
    ENDIF.

*
    xml_file = wa_compensa-archivoxml.
*
    REFRESH it_xmlsat. "datos del complemento de Pago
    IF xml_file IS NOT INITIAL. "AND vl_status_http NE '1'.
      PERFORM transformar_xml TABLES it_xmlsat[] USING xml_file CHANGING vl_status_http.
    ENDIF.

    IF it_xmlsat[] IS NOT INITIAL.

      PERFORM distribuir_xml TABLES it_xmlsat
                             USING <fs_head>-vbeln
                             CHANGING <fs_head>.
    ENDIF.


*      "datos de la factura Fiscal.
    REFRESH it_xmlsat.
    CLEAR xml_file.
    READ TABLE it_timbrerv INTO DATA(wa_timbre) WITH KEY vbeln = <fs_head>-vbeln.
    IF sy-subrc NE 0.
      CLEAR wa_timbre.
    ENDIF.
    xml_file = wa_timbre-archivoxml.

    IF xml_file IS NOT INITIAL. "AND vl_status_http NE '1'.
      PERFORM transformar_xml TABLES it_xmlsat[] USING xml_file CHANGING vl_status_http.
    ENDIF.

    IF it_xmlsat[] IS NOT INITIAL.

      PERFORM distribuir_xmlrv TABLES it_xmlsat
                             USING <fs_head>-vbeln
                             CHANGING <fs_head>.
    ENDIF.


    IF wa_bkpf-mwskz IS NOT INITIAL.
      <fs_head>-monto = wa_bkpf-hwbas.
      <fs_head>-iva = wa_bkpf-iva.
      <fs_head>-tasa = ( wa_bkpf-kbetr / 10 ).
      <fs_head>-total = <fs_head>-monto + <fs_head>-iva.
    ENDIF.

    IF <fs_head>-totales EQ 0.
      <fs_head>-totales = wa_bkpf-dmbtr.
    ENDIF.
*


  ENDLOOP.





ENDFORM.

FORM transformar_xml  TABLES   gt_xml_data STRUCTURE smum_xmltb
                      USING    ruta_xml TYPE zaxnare_el034
                      CHANGING p_status_http.

  DATA: gcl_xml       TYPE REF TO cl_xml_document.
  DATA: gv_subrc      TYPE sy-subrc.
  DATA: gv_xml_string TYPE xstring.
  DATA: gv_size       TYPE sytabix.
  DATA: gwa_xml_data  TYPE smum_xmltb.
  DATA: gt_return     TYPE TABLE OF bapiret2.
  DATA: gv_tabix      TYPE sytabix.

  DATA: http_client TYPE REF TO if_http_client .
  DATA: xml_out TYPE string  .


  DATA lv_filename TYPE string.
  REFRESH gt_xml_data.
  CREATE OBJECT gcl_xml.
  lv_filename = ruta_xml.

  "se consulta por URL
  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url    = lv_filename
    IMPORTING
      client = http_client.

  http_client->send(
   EXCEPTIONS
    http_communication_failure = 1
    http_invalid_state         = 2 ).


  http_client->receive(
  EXCEPTIONS
  http_communication_failure = 1
  http_invalid_state         = 2
  http_processing_failed     = 3
  OTHERS                     = 4 ).

  CASE  sy-subrc.
    WHEN 1.
      MESSAGE 'Error de comunicación a Servidor AWS para XML' TYPE 'S' DISPLAY LIKE 'E'.
      p_status_http = '1'.
    WHEN 2.
      MESSAGE 'Estado Inválido para  XML' TYPE 'S' DISPLAY LIKE 'E'.
    WHEN 3.
      MESSAGE 'Error al procesar XML' TYPE 'S' DISPLAY LIKE 'E'.
  ENDCASE.

  CLEAR xml_out .
  xml_out = http_client->response->get_cdata( ).
  http_client->close( ).


  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text   = xml_out
    IMPORTING
      buffer = gv_xml_string
    EXCEPTIONS
      failed = 1
      OTHERS = 2.
* Convert XML to internal table
  CALL FUNCTION 'SMUM_XML_PARSE'
    EXPORTING
      xml_input = gv_xml_string
    TABLES
      xml_table = gt_xml_data
      return    = gt_return.


ENDFORM.

FORM distribuir_xml  TABLES p_it_xmlsat STRUCTURE  smum_xmltb
                     USING p_vbeln TYPE vbeln
                     CHANGING wa_data_alv TYPE zfi_st_ingresos_satep.

  DATA wa_xmlsat TYPE smum_xmltb.

  CLEAR wa_xmlsat.
  DATA: indice_base TYPE i, indice_inc TYPE i.
  DATA: vl_valor TYPE p DECIMALS 6,  vl_tasa TYPE p DECIMALS 6.
  DATA vl_vbeln TYPE vbeln.

*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      input  = p_vbeln
*    IMPORTING
*      output = vl_vbeln.



  READ TABLE p_it_xmlsat INTO wa_xmlsat WITH KEY  cname = 'Folio' cvalue = p_vbeln.
  IF sy-tabix EQ 0 OR vl_vbeln CP '180*'.
    EXIT.
  ENDIF.

  CLEAR wa_xmlsat.
  indice_base = sy-tabix - 1.
  indice_inc = indice_base + 16. " Importe DR
READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
wa_data_alv-iva = wa_xmlsat-cvalue.

"nueva validación de Tasa
indice_inc = indice_inc - 1. "TasaOCuotaDR
READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
wa_data_alv-tasa = wa_xmlsat-cvalue * 100.

indice_inc = indice_inc - 3. " Base DR
READ TABLE it_xmlsat INTO wa_xmlsat index indice_inc.
IF wa_data_alv-tasa > 0. "es .16
  "wa_data_alv-monto = '0.00'.
  wa_data_alv-monto = wa_xmlsat-cvalue.
 else.
     wa_data_alv-monto = wa_xmlsat-cvalue.

ENDIF.

  READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_inc.
  wa_data_alv-monto = wa_xmlsat-cvalue.
  wa_data_alv-total = wa_xmlsat-cvalue.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*  CLEAR wa_xmlsat.
*  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'MetodoPago'.
*  wa_data_alv-metodcobro = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '4' type = 'A' cname = 'MonedaP'.
  wa_data_alv-moneda_cobro = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '4' type = 'A' cname = 'TipoCambioP'.
  wa_data_alv-tipo_cambio = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'Fecha'.
  CONCATENATE wa_xmlsat-cvalue+8(2) wa_xmlsat-cvalue+5(2) wa_xmlsat-cvalue+0(4)   INTO DATA(tmp_fecha) .

  CALL FUNCTION 'CONVERSION_EXIT_PDATE_INPUT'
    EXPORTING
      input        = tmp_fecha
    IMPORTING
      output       = wa_data_alv-fechaemision
    EXCEPTIONS
      invalid_date = 1
      OTHERS       = 2.


  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY cname = 'Monto'.
  wa_data_alv-totales = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '4' type = 'A' cname = 'FormaDePagoP'.
  wa_data_alv-forma_cobro = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '2' type = 'A' cname = 'UsoCFDI'.
  wa_data_alv-uso_cfdi = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '3' type = 'A' cname = 'ClaveProdServ'.
  wa_data_alv-codprod = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '3' type = 'A' cname = 'Descripcion'.
  wa_data_alv-concepto_bien = wa_xmlsat-cvalue.



ENDFORM.

FORM distribuir_xmlrv  TABLES p_it_xmlsat STRUCTURE  smum_xmltb
                     USING p_vbeln TYPE vbeln
                     CHANGING wa_data_alv TYPE zfi_st_ingresos_satep.

  DATA wa_xmlsat TYPE smum_xmltb.

  CLEAR wa_xmlsat.
  DATA: indice_base TYPE i, indice_inc TYPE i.
  DATA: vl_valor TYPE p DECIMALS 6,  vl_tasa TYPE p DECIMALS 6.
  DATA vl_vbeln TYPE vbeln.

*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      input  = p_vbeln
*    IMPORTING
*      output = vl_vbeln.



*  READ TABLE p_it_xmlsat INTO wa_xmlsat WITH KEY  hier = '5' type = 'A' cname = 'Folio' cvalue = vl_vbeln.
*  IF sy-tabix EQ 0 OR vl_vbeln CP '180*'.
*    EXIT.
*  ENDIF.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'MetodoPago'.
  wa_data_alv-metodcobro = wa_xmlsat-cvalue.

  IF wa_data_alv-forma_cobro IS INITIAL.
    CLEAR wa_xmlsat.
    READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'FormaPago'.
    wa_data_alv-forma_cobro = wa_xmlsat-cvalue.
  ENDIF.


  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '2' type = 'A' cname = 'UsoCFDI'.
  wa_data_alv-uso_cfdi = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '3' type = 'A' cname = 'ClaveProdServ'.
  wa_data_alv-codprod = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '3' type = 'A' cname = 'Descripcion'.
  wa_data_alv-concepto_bien = wa_xmlsat-cvalue.

  IF wa_data_alv-folfis IS INITIAL.
    CLEAR wa_xmlsat.
    READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '3' type = 'A' cname = 'UUID'.
    wa_data_alv-folfis = wa_xmlsat-cvalue.
ENDIF.

    CLEAR wa_xmlsat.
    READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'Fecha'.
    CONCATENATE wa_xmlsat-cvalue+8(2) wa_xmlsat-cvalue+5(2) wa_xmlsat-cvalue+0(4)   INTO DATA(tmp_fecha) .

    CALL FUNCTION 'CONVERSION_EXIT_PDATE_INPUT'
      EXPORTING
        input        = tmp_fecha
      IMPORTING
        output       = wa_data_alv-fechaemision
      EXCEPTIONS
        invalid_date = 1
        OTHERS       = 2.

 CLEAR wa_xmlsat.
    READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '1' type = 'A' cname = 'TipoCambio'.
    wa_data_alv-tipo_cambio = wa_xmlsat-cvalue.

  IF wa_data_alv-totales EQ 0.
    CLEAR wa_xmlsat.
    READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '1' type = 'A' cname = 'Total'.
    wa_data_alv-totales = wa_xmlsat-cvalue.



  ENDIF.


ENDFORM.


FORM create_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
*     I_INTERNAL_TABNAME     =
      i_structure_name       = 'ZFI_ST_INGRESOS_SATEP'
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
*
      WHEN 'MONTO'.
        wa_fieldcat-do_sum = 'X'.
      WHEN 'TOTAL'.
        wa_fieldcat-do_sum = 'X'.
      WHEN 'TOTALES'.
        wa_fieldcat-do_sum = 'X'.
      WHEN 'KUNNR'.
        wa_fieldcat-seltext_l = 'CLIENTE'.
        wa_fieldcat-seltext_m = 'CLIENTE'.
        wa_fieldcat-seltext_s = 'CLIENTE'.
      WHEN 'BELNR'.
        wa_fieldcat-seltext_l = 'No. Doc.'.
        wa_fieldcat-seltext_m = 'No. Doc.'.
        wa_fieldcat-seltext_s = 'No. Doc.'.
      WHEN 'VBELN'.
        wa_fieldcat-seltext_l = 'Ref. Fact.'.
        wa_fieldcat-seltext_m = 'Ref. Fact.'.
        wa_fieldcat-seltext_s = 'Ref. Fact.'.
      WHEN 'VBELN'.
        wa_fieldcat-seltext_l = 'Ref. Fact.'.
        wa_fieldcat-seltext_m = 'Ref. Fact.'.
        wa_fieldcat-seltext_s = 'Ref. Fact.'.
      WHEN 'HKONT'.
        wa_fieldcat-seltext_l = 'Cuenta'.
        wa_fieldcat-seltext_m = 'Cuenta'.
        wa_fieldcat-seltext_s = 'Cuenta'.
        "wa_fieldcat-no_out = 'X'.
      WHEN 'FORMA_COBRO'.
        wa_fieldcat-seltext_l = 'Forma Cobro'.
        wa_fieldcat-seltext_m = 'Forma Cobro'.
        wa_fieldcat-seltext_s = 'Forma Cobro'.
      WHEN 'FORMA_COBRO'.
        wa_fieldcat-seltext_l = 'Doc. Cobro'.
        wa_fieldcat-seltext_m = 'Doc. Cobro'.
        wa_fieldcat-seltext_s = 'Doc. Cobro'.


    ENDCASE.
    MODIFY gt_fieldcat FROM wa_fieldcat.
  ENDLOOP.


ENDFORM.

FORM show_alv.

  lf_layout-zebra = 'X'.
  lf_layout-colwidth_optimize = 'X'.

  DATA w_sort TYPE slis_sortinfo_alv.
  w_sort-spos = 1.
  w_sort-fieldname = 'NAME1'.
  w_sort-subtot = 'X'.
  APPEND w_sort TO t_sort.

  w_sort-spos = 1.
  w_sort-fieldname = 'RFC'.
  w_sort-subtot = 'X'.
  APPEND w_sort TO t_sort.

  w_sort-spos = 1.
  w_sort-fieldname = 'KUNNR'.
  w_sort-subtot = 'X'.
  APPEND w_sort TO t_sort.

  w_sort-spos = 1.
  w_sort-fieldname = 'DOC_COBRO'.
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
      it_sort            = t_sort
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

FORM f_get_data.
    DATA: i_vbrp_pue TYPE vbrp OCCURS 0 WITH HEADER LINE,
          i_vbak_pue TYPE vbak OCCURS 0 WITH HEADER LINE.

*** Limpia todas las tablas del proxy

  v_ejercicio = s_budat-low+0(4).
  v_ejerciciom1 = v_ejercicio - 1.
  v_ejerciciop1 = v_ejercicio + 1.

  CLEAR:   i_lineitems, i_fechas, i_customer.
  REFRESH: i_lineitems, i_fechas, i_customer.

  COMMIT WORK.

*** Llena el parametro de fecha para la bapi
  LOOP AT s_budat.
    MOVE-CORRESPONDING s_budat TO i_fechas.
    APPEND i_fechas.
  ENDLOOP.

*** Llena el parametro de cliente para la bapi
  LOOP AT s_kunnr.
    MOVE-CORRESPONDING s_kunnr TO i_customer.
    APPEND i_customer.
  ENDLOOP.

  CLEAR: i_lineitems.
  REFRESH: i_lineitems.

  CALL FUNCTION 'ZBAPI_AR_ACC_GETOPENITEMS'
    EXPORTING
      companycode = s_bukrs
      customer    = '*'
    IMPORTING
      return      = i_return
    TABLES
      lineitems   = i_lineitems
      fechas      = i_fechas
      customer2   = i_customer.

  SORT i_lineitems BY doc_no.

*** Borra los documentos no solicitados
  DELETE i_lineitems WHERE doc_no NOT IN s_belnr.

*** Borra los documentos de compensacion
  DELETE i_lineitems WHERE doc_no+0(4) = '0100'.
  DELETE i_lineitems WHERE doc_no+0(4) = '100'.

*** Borra los docuemtnos anulados
  DELETE i_lineitems WHERE reversal_doc IS NOT INITIAL.

  DATA: BEGIN OF i_line_dup OCCURS 0,
          cant   TYPE i,
          doc_no LIKE i_lineitems-doc_no.
  DATA: END OF i_line_dup.

  LOOP AT i_lineitems.
    MOVE-CORRESPONDING i_lineitems TO i_line_dup.
    i_line_dup-cant = 1.
    COLLECT i_line_dup.
  ENDLOOP.

  DELETE i_line_dup WHERE cant = 1.

  LOOP AT i_line_dup.
    DELETE i_lineitems WHERE
      customer+0(2) = 'IS'       AND
      doc_no = i_line_dup-doc_no AND
      clear_date IS INITIAL  AND
      clr_doc_no IS INITIAL.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM i_lineitems.

  IF i_lineitems[] IS INITIAL.
    IF sy-langu = 'S'.
      MESSAGE e001(00) WITH 'No existe informacion para los' ' criterios de selección'.
      EXIT.
    ELSE.
      MESSAGE e001(00) WITH 'No information found for' ' selection criteria'.
      EXIT.
    ENDIF.
    EXIT.
  ENDIF.

*** Si encontro documentos de pago a procesar
  IF i_lineitems[] IS NOT INITIAL.

*** Copia la tabla de documentos para conservar los 11 y 01
    CLEAR: i_lineitems_comp.
    i_lineitems_comp[] = i_lineitems[].

*** Para los pagos totales debe ir a buscar los documentos relacionados
    CLEAR:   i_bsad.
    REFRESH: i_bsad[].

    SELECT *
      FROM bsad_view
      INTO TABLE @i_bsad
      FOR ALL ENTRIES IN @i_lineitems
      WHERE bukrs = @s_bukrs
      AND   kunnr = @i_lineitems-customer
      AND   augbl = @i_lineitems-doc_no
      AND   augdt = @i_lineitems-pstng_date
      AND   bschl = '01'.

*** Este cambio es por las que tienen pagos antes de la fecha de la factura
*** y no salen cuando se corre en conjunto...
    SELECT *
    FROM bsad_view
    APPENDING CORRESPONDING FIELDS OF TABLE @i_bsad
    FOR ALL ENTRIES IN @i_lineitems
    WHERE bukrs = @s_bukrs
    AND   kunnr = @i_lineitems-customer
    AND   augbl = @i_lineitems-doc_no
*      AND   AUGDT = I_LINEITEMS-PSTNG_DATE
    AND   gjahr = @i_lineitems-pstng_date+0(4)
    AND   bschl = '01'.

    DELETE ADJACENT DUPLICATES FROM i_bsad.

*** Barre cada documento de pago **********************************************************************
    CLEAR:   i_documentos.
    REFRESH: i_documentos.

    DATA: v_tabix_items TYPE sy-tabix.
    SORT i_lineitems BY doc_no.
    LOOP AT i_lineitems  WHERE post_key = '15'
                            OR post_key = '16'
                            OR post_key = '17'. " Complementos de compensación de Chedraui
      CLEAR v_tabix_items.
      v_tabix_items = sy-tabix.
**** Cuando es un documento de pago final no tiene las referencias
      IF i_lineitems-bill_doc IS INITIAL AND                   " PAGO TOTAL FACTURA LOGISTICA
         i_lineitems-inv_ref    IS INITIAL.

        LOOP AT i_bsad WHERE bukrs = s_bukrs
                         AND kunnr = i_lineitems-customer
                         AND augbl = i_lineitems-doc_no
                         AND bschl = '01'.

          IF i_bsad-vbeln IS NOT INITIAL.
            i_documentos-tipo   = 'SDT'.                           " Factura de ventas pago total
            i_documentos-factura        = i_bsad-vbeln.
            i_documentos-doc_comp       = i_bsad-belnr.
            i_documentos-doc_pago       = i_lineitems-doc_no.
            i_documentos-doc_clr        = i_lineitems-clr_doc_no.
            i_documentos-kunnr          = i_lineitems-customer.
          ELSE.
            i_documentos-tipo   = 'FIT'.                           " Factura de ventas pago total
            i_documentos-factura        = i_bsad-belnr.
            i_documentos-doc_comp       = i_bsad-belnr.
            i_documentos-doc_pago       = i_lineitems-doc_no.
            i_documentos-doc_clr        = i_lineitems-clr_doc_no.
            i_documentos-kunnr          = i_lineitems-customer.
          ENDIF.
          APPEND i_documentos.
        ENDLOOP.

      ELSEIF i_lineitems-bill_doc IS NOT INITIAL AND            " PAGO PARCIAL FACTURA LOGISTICA
             i_lineitems-inv_ref    IS NOT INITIAL.
        i_documentos-tipo   = 'SDP'.            " Factura de ventas pago parcial
        i_documentos-factura  = i_lineitems-bill_doc.   "ALLOC_NMBR.
        i_documentos-doc_pago = i_lineitems-doc_no.
        i_documentos-doc_comp = i_lineitems-inv_ref.
        i_documentos-doc_clr        = i_lineitems-clr_doc_no.
        i_documentos-kunnr          = i_lineitems-customer.
        APPEND i_documentos.

*** Cuando es una factura financiera se debe de ir a sacar el resto de la info
      ELSEIF i_lineitems-bill_doc IS INITIAL AND                " PAGO PARCIAL FACTURA FINANCIERA
             i_lineitems-inv_ref    IS NOT INITIAL.
        i_documentos-tipo   = 'FIP'.                               " Factura financiera
        i_documentos-factura  = i_lineitems-inv_ref."I_LINEITEMS-ALLOC_NMBR.
        i_documentos-doc_pago = i_lineitems-doc_no.
        i_documentos-doc_comp = i_lineitems-inv_ref.
        i_documentos-doc_clr  = i_lineitems-clr_doc_no.
        i_documentos-kunnr    = i_lineitems-customer.
        APPEND i_documentos.
      ELSE.
        i_documentos-tipo   = 'FIT'.            " Factura de ventas pago parcial
        i_documentos-factura  = i_lineitems-inv_ref.
        i_documentos-doc_pago = i_lineitems-doc_no.
        i_documentos-doc_comp = i_lineitems-inv_ref.
        i_documentos-doc_clr  = i_lineitems-clr_doc_no.
        i_documentos-kunnr    = i_lineitems-customer.
        APPEND i_documentos.

      ENDIF.

    ENDLOOP.

    IF i_documentos[] IS INITIAL.
      IF sy-langu = 'S'.
        MESSAGE e001(00) WITH 'No existen pagos a procesar'.
        EXIT.
      ELSE.
        MESSAGE e001(00) WITH 'No payments to process'.
        EXIT.
      ENDIF.
      EXIT.
    ENDIF.
    SORT i_documentos.
    DELETE ADJACENT DUPLICATES FROM i_documentos.

*** Elimina documentos que tengan metodo de pago PUE

*** Valida el metodo de pagod e la factura
    DATA: i_zsd_cfdi_timbre_pue TYPE zsd_cfdi_timbre OCCURS 0 WITH HEADER LINE.
    CLEAR: i_zsd_cfdi_timbre_pue.
    REFRESH: i_zsd_cfdi_timbre_pue.

    SELECT *
      FROM zsd_cfdi_timbre
      INTO TABLE i_zsd_cfdi_timbre_pue
      FOR ALL ENTRIES IN i_documentos
      WHERE vbeln = i_documentos-factura
      AND metodo_pago = 'PUE'.

*    LOOP AT i_documentos.
*
*      READ TABLE i_zsd_cfdi_timbre_pue WITH KEY
*          vbeln = i_documentos-factura.
*      IF sy-subrc EQ 0.
*        DELETE i_documentos.
*      ENDIF.
*    ENDLOOP.

*** Valida el metodo de pago directo del campo del pedido de la factura


    CLEAR:   i_vbrp_pue, i_vbak_pue.
    REFRESH: i_vbrp_pue, i_vbak_pue.

    SELECT *
      FROM vbrp
      INTO TABLE i_vbrp_pue
      FOR ALL ENTRIES IN i_documentos
      WHERE vbeln = i_documentos-factura.

    SELECT *
      FROM vbak
      INTO TABLE i_vbak_pue
      FOR ALL ENTRIES IN i_vbrp_pue
      WHERE vbeln = i_vbrp_pue-aubel.

*    LOOP AT i_documentos.
**** Extrae el pedido
*      CLEAR: i_vbrp_pue, i_vbak_pue.
*      READ TABLE i_vbrp_pue WITH KEY vbeln = i_documentos-factura.
*      IF sy-subrc EQ 0.
*        READ TABLE i_vbak_pue WITH KEY vbeln = i_vbrp_pue-aubel.
*        IF sy-subrc EQ 0.
*          IF i_vbak_pue-kvgr2 = 'PUE'.
*            DELETE i_documentos.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*    ENDLOOP.

*** Saca los campos de la factura que se envian al ALV y al SAT
    DATA: i_zsd_cfdi_timbre TYPE zsd_cfdi_timbre OCCURS 0 WITH HEADER LINE.
    CLEAR: i_zsd_cfdi_timbre.

    SELECT *                                                       " D001
      FROM zsd_cfdi_timbre
      INTO TABLE i_zsd_cfdi_timbre
      FOR ALL ENTRIES IN i_documentos
      WHERE vbeln = i_documentos-factura.
*** Agregar logica para extraer el UUID de las facturas logisticas
*** Fin de modificar M001
  ENDIF.
  .
*** Extrae todos los registros ya con status para los documentos de pago
  CLEAR i_zalv_comp_pago.
  REFRESH i_zalv_comp_pago.

  SELECT *
    FROM zalv_comp_pago
    INTO TABLE i_zalv_comp_pago
    FOR ALL ENTRIES IN i_documentos
    WHERE bukrs    = s_bukrs
    AND   doc_pago = i_documentos-doc_pago
    AND   factura  = i_documentos-factura.

  CLEAR:  gt_data.
  REFRESH gt_data.

  SORT i_documentos BY doc_pago ASCENDING.
  LOOP AT i_documentos.
    MOVE-CORRESPONDING i_documentos TO gt_data.
*** Asigna el UUID DEL PAGO **********************************************************************
    READ TABLE i_zalv_comp_pago WITH KEY doc_pago = i_documentos-doc_pago
                                         factura  = i_documentos-factura.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING i_zalv_comp_pago TO gt_data.

    ENDIF.
*** Asigna el UUID de la factura de ventas **********************************************************************
    READ TABLE i_zsd_cfdi_timbre WITH KEY vbeln = i_documentos-factura.
    IF sy-subrc EQ 0.
      gt_data-uuid_dr = i_zsd_cfdi_timbre-uuid.
      gt_data-bukrs = i_zsd_cfdi_timbre-bukrs.
      gt_data-gjahr = i_zsd_cfdi_timbre-gjahr.
    ELSE.
      gt_data-kunnr = i_documentos-kunnr.
      v_flag_ci = 'X'.

      SELECT SINGLE sgtxt, zuonr
        FROM bsad_view
        INTO (@gt_data-uuid_dr, @v_zuonr_ci)
        WHERE bukrs = @s_bukrs
        AND   augbl = @i_documentos-doc_pago
        AND   belnr = @i_documentos-doc_comp
        AND   blart = 'DR'
        AND   bschl = '01'.

      IF sy-subrc NE 0.
        SELECT SINGLE sgtxt
          FROM bsid_view
          INTO @gt_data-uuid_dr
          WHERE bukrs = @s_bukrs
          AND   belnr = @i_documentos-doc_comp
          AND   blart = 'DR'
          AND   bschl = '01'.
        IF sy-subrc NE 0.
          SELECT SINGLE sgtxt, zuonr
            FROM bsad_view
            INTO (@gt_data-uuid_dr, @v_zuonr_ci)
            WHERE bukrs = @s_bukrs
            AND   belnr = @i_documentos-doc_comp
            AND   blart = 'DR'
            AND   bschl = '01'.
        ENDIF.

      ENDIF.
    ENDIF.
    APPEND gt_data.

    CLEAR: i_documentos, gt_data, i_zalv_comp_pago.

  ENDLOOP.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .

  CLEAR: i_vbrk, i_bkpf.
  REFRESH: i_vbrk[], i_bkpf[].
  DATA vl_status_http.
  FIELD-SYMBOLS <fs_head>         TYPE zfi_st_ingresos_satep.

*** Extrae los datos adicoinales de cada factura
  SELECT *
    FROM vbrk
    INTO TABLE i_vbrk
    FOR ALL ENTRIES IN gt_data
    WHERE vbeln = gt_data-factura.

  IF gt_data[] IS INITIAL.
    IF sy-langu = 'S'.
      MESSAGE e001(00) WITH 'No existen pagos a procesar'.
      EXIT.
    ELSE.
      MESSAGE e001(00) WITH 'No payments to process'.
      EXIT.
    ENDIF.
    EXIT.
  ENDIF.
*** Extrae los datos adicionales de cada documento de pago
  SELECT *
    FROM bkpf
    INTO TABLE i_bkpf
    FOR ALL ENTRIES IN gt_data
    WHERE bukrs = s_bukrs
    AND   belnr = gt_data-doc_pago
    AND   ( gjahr = v_ejercicio OR gjahr = v_ejerciciop1 ).


*** Para cada documento encontrado
  LOOP AT gt_data.
    APPEND INITIAL LINE TO it_ingresos ASSIGNING <fs_head>.
*** Valida si es un pago unico o es un pago multiple
    DATA: v_lines TYPE i.
    CLEAR v_lines.

    LOOP AT i_documentos WHERE doc_pago = gt_data-doc_pago.
      ADD 1 TO v_lines.
    ENDLOOP.
    CLEAR: i_vbrk, i_documentos, i_lineitems, i_zalv_comp_pago.

*** Se lee la tabla del detalle de pago
    READ TABLE i_vbrk WITH KEY vbeln = gt_data-factura.
    READ TABLE i_documentos WITH KEY factura  = gt_data-factura
                                     doc_pago = gt_data-doc_pago
                                     doc_comp = gt_data-doc_comp.
    READ TABLE i_bkpf WITH KEY belnr = gt_data-doc_pago.

*** Se lee la tabla con toda la info de la bapi
    IF v_lines = 1.
      READ TABLE i_lineitems WITH KEY doc_no      = gt_data-doc_pago.
    ELSE.
      IF i_documentos-tipo = 'SDP'.
        READ TABLE i_lineitems WITH KEY doc_no      = gt_data-doc_pago
                                        bill_doc    = gt_data-factura
                                        inv_ref     = gt_data-doc_comp.
      ELSEIF i_documentos-tipo = 'FIP'.
        READ TABLE i_lineitems WITH KEY doc_no      = gt_data-doc_pago
                                        inv_ref     = gt_data-doc_comp.
      ENDIF.
    ENDIF.

*** Se asigna el UUID correspondiente
    <fs_head>-folfis =  gt_data-uuid_dr.
    "wa_data_alv-comentario = gt_data-comentario.
    "wa_data_alv-parcialidad = gt_data-numparcialidad.
    " wa_data_alv-stat_canc = gt_data-stat_canc.
    " wa_data_alv-status = gt_data-status.
    "    wa_data_alv-bukrs           = s_bukrs-low.                          " Sociedad

*** De la tabla GT_DATA
    <fs_head>-vbeln     = gt_data-factura.                     " Documento de pago
    <fs_head>-belnr     = gt_data-doc_comp.                      " Factura
    <fs_head>-doc_cobro = gt_data-doc_pago.                     " Documento de compensacion

*** De la tabla de la BAPI
    READ TABLE i_documentos WITH KEY factura = gt_data-factura
    doc_pago = gt_data-doc_pago
    doc_comp = gt_data-doc_comp.
*    IF i_documentos-tipo = 'SDT'     OR i_documentos-tipo = 'FIT'.
*      wa_data_alv-ind_pc = 'X'.
*    ELSEIF i_documentos-tipo = 'SDP' OR i_documentos-tipo = 'FIP'.
*      wa_data_alv-ind_pp = 'X'.
*    ENDIF.

    IF i_lineitems-customer IS INITIAL.
*** Va y busca la info en la tabla BSAD porque es un pago total
      CLEAR: v_monto_pago_doc, v_monto_fact_doc,
             v_monto_pago_local, v_monto_fact_local.

      IF i_documentos-tipo = 'SDT'.
*** Extrae el monto del pago
        READ TABLE i_bsad WITH KEY vbeln = gt_data-factura
                                   belnr = gt_data-doc_comp
                                   augbl = gt_data-doc_pago.
        v_monto_pago_doc   = i_bsad-wrbtr.
        v_monto_pago_local = i_bsad-dmbtr.

        DATA: i_bsad_nc TYPE bsad_view OCCURS 0 WITH HEADER LINE.
        CLEAR i_bsad_nc.
        REFRESH i_bsad_nc.

        SELECT *
          FROM bsad_view
          INTO TABLE @i_bsad_nc
          WHERE kunnr = @gt_data-kunnr
          AND   augbl = @gt_data-doc_pago
          AND   zuonr = @gt_data-factura
          AND   bschl = '11'.

        IF NOT i_bsad_nc[] IS INITIAL.
          LOOP AT i_bsad_nc.
            v_monto_pago_doc   = v_monto_pago_doc   - i_bsad_nc-wrbtr.
            v_monto_pago_local = v_monto_pago_local - i_bsad_nc-dmbtr.
          ENDLOOP.
        ENDIF.

      ELSEIF i_documentos-tipo = 'FIT'.
*** Extrae el monto del pago
        READ TABLE i_bsad WITH KEY vbeln = space
                                   belnr = gt_data-doc_comp
                                   augbl = gt_data-doc_pago.


        v_monto_pago_doc   = i_bsad-wrbtr.
        v_monto_pago_local = i_bsad-dmbtr.

        CLEAR i_bsad_nc.
        REFRESH i_bsad_nc.

        DATA: v_zuonr_nc TYPE bsad-zuonr.
        CLEAR v_zuonr_nc.

        SELECT SINGLE zuonr
          FROM bsad_view
          INTO @v_zuonr_nc
          WHERE bukrs = @s_bukrs
          AND   kunnr = @gt_data-kunnr
          AND   augbl = @gt_data-doc_pago
          AND   belnr = @gt_data-factura
          AND   zuonr NE @space.

        SELECT *
          FROM bsad_view
          INTO TABLE @i_bsad_nc
          WHERE bukrs = @s_bukrs
          AND   kunnr = @gt_data-kunnr
          AND   augbl = @gt_data-doc_pago
          AND   zuonr = @v_zuonr_nc
          AND   bschl = '11'.

        IF NOT i_bsad_nc[] IS INITIAL.
          LOOP AT i_bsad_nc.
            v_monto_pago_doc   = v_monto_pago_doc   - i_bsad_nc-wrbtr.
            v_monto_pago_local = v_monto_pago_local - i_bsad_nc-dmbtr.
          ENDLOOP.
        ENDIF.



*** Valida si tiene pagos previos (para ver si es liquidacion)
      ENDIF.

      CLEAR:   i_bsid_bsad_pagos.
      REFRESH: i_bsid_bsad_pagos.

      SELECT augbl, rebzg, wrbtr, dmbtr
        FROM bsid_view
      INTO CORRESPONDING FIELDS OF TABLE @i_bsid_bsad_pagos
        WHERE bukrs = @s_bukrs
        AND   rebzg = @gt_data-doc_comp
        AND   gjahr = @v_ejercicio
        AND   kunnr = @gt_data-kunnr                   " REVISAR
        AND   xstov NE 'X'.
      SELECT augbl, rebzg, wrbtr, dmbtr
        FROM bsad_view
      APPENDING CORRESPONDING FIELDS OF TABLE @i_bsid_bsad_pagos
        WHERE bukrs = @s_bukrs
        AND   rebzg = @gt_data-doc_comp
        AND   augbl = @gt_data-doc_pago
        AND   gjahr = @v_ejercicio
        AND   kunnr = @gt_data-kunnr                   " REVISAR
        AND   xstov NE'X'.

      IF i_bsid_bsad_pagos[] IS NOT INITIAL.
        LOOP AT i_bsid_bsad_pagos.
          v_monto_pago_doc = v_monto_pago_doc - i_bsid_bsad_pagos-wrbtr.
          v_monto_pago_local = v_monto_pago_local - i_bsid_bsad_pagos-dmbtr.
        ENDLOOP.
      ENDIF.

      IF i_bsad-qsskz = 'XX'.

        CLEAR v_wt_qbshb.

        SELECT SINGLE wt_qbshb
          FROM with_item
          INTO v_wt_qbshb
          WHERE belnr = i_bsad-belnr.
        v_monto_pago_doc = v_monto_pago_doc - v_wt_qbshb.
        v_monto_pago_local = v_monto_pago_local - v_wt_qbshb.
      ENDIF.

      <fs_head>-kunnr           = i_bsad-kunnr.                     " Cliente
      SELECT  name1, stcd1, stcd3
        INTO TABLE @DATA(it_kunnr)
        FROM kna1
        WHERE kunnr = @i_bsad-kunnr
        .
      READ TABLE it_kunnr INTO DATA(wa_kunnr) INDEX 1.
      IF sy-subrc EQ 0.
        IF wa_kunnr-stcd1 IS INITIAL.
          <fs_head>-rfc = wa_kunnr-stcd3.
        ELSE.
          <fs_head>-rfc = wa_kunnr-stcd1.
        ENDIF.
        <fs_head>-name1 = wa_kunnr-name1.
      ENDIF.


      <fs_head>-monto        = v_monto_pago_doc.                 " Importe de pago en moneda del documento
      "wa_data_alv-pago_local      = v_monto_pago_local.               " Importe de pago en moneda local
      <fs_head>-moneda_cobro       = i_bsad-waers.                     " Moneda de pago
      "WRITE  TO .                        " Fecha de pago
      <fs_head>-fecha_cobro = i_bsad-augdt.
      v_fecha_pago = i_bsad-augdt.


    ELSE.
      CLEAR:   v_monto_pago_local, v_monto_pago_doc,
       v_monto_pago_local2, v_monto_pago_doc2.
** Valida si existe un documento 08 con el importe correcto
      SELECT SINGLE wrbtr, dmbtr
        INTO (@v_monto_pago_doc2, @v_monto_pago_local2)
        FROM bsad_view
        WHERE bukrs = @s_bukrs
        AND   kunnr = @i_lineitems-customer
      AND   augbl = @<fs_head>-doc_cobro
      AND   gjahr = @v_ejercicio
      AND   bschl = '08'.


      v_monto_pago_doc   = i_lineitems-amt_doccur - v_monto_pago_doc2.
      v_monto_pago_local = i_lineitems-lc_amount - v_monto_pago_local2.

*** Valida si tiene retencion
      DATA: v_qsskz TYPE bsid-qsskz.
      CLEAR: v_qsskz.

      READ TABLE i_bsad WITH KEY vbeln = gt_data-factura
                                 belnr = gt_data-doc_comp
                                 augbl = gt_data-doc_pago.

      IF sy-subrc NE 0.
*** Es un pago parcial
        SELECT SINGLE qsskz
          FROM bsid_view
          INTO @v_qsskz
          WHERE ( kunnr = @gt_data-kunnr OR kunnr = @i_lineitems-customer )
          AND   belnr = @gt_data-doc_comp
          AND   gjahr = @v_ejercicio.
      ENDIF.

      IF i_bsad-qsskz = 'XX' OR v_qsskz = 'XX'.
        CLEAR v_wt_qbshb.

        IF v_qsskz = 'XX'.
          SELECT SINGLE wt_qbshb
            FROM with_item
            INTO v_wt_qbshb
            WHERE belnr = gt_data-doc_pago
            AND   gjahr = v_ejercicio.
          v_wt_qbshb = abs( v_wt_qbshb ).
        ELSE.

          SELECT SINGLE wt_qbshb
            FROM with_item
            INTO v_wt_qbshb
            WHERE belnr = gt_data-doc_comp
            AND   gjahr = v_ejercicio.
        ENDIF.

        v_monto_pago_doc = v_monto_pago_doc - v_wt_qbshb.
        v_monto_pago_local = v_monto_pago_local - v_wt_qbshb.
      ENDIF.

      v_monto_pago_doc            = v_monto_pago_doc.                 " Pago en la moneda del documento
      v_monto_pago_local          = v_monto_pago_local.               " Pago en la moneda local
      <fs_head>-kunnr           = i_lineitems-customer.             " Cliente

      SELECT  name1, stcd1, stcd3
        INTO TABLE @DATA(it_kunnr2)
        FROM kna1
        WHERE kunnr = @i_lineitems-customer.
      .
      READ TABLE it_kunnr2 INTO DATA(wa_kunnr2) INDEX 1.
      IF sy-subrc EQ 0.
        IF wa_kunnr2-stcd1 IS INITIAL.
          <fs_head>-rfc = wa_kunnr2-stcd3.
        ELSE.
          <fs_head>-rfc = wa_kunnr2-stcd1.
        ENDIF.
        <fs_head>-name1 = wa_kunnr2-name1.
      ENDIF.


      <fs_head>-monto        = v_monto_pago_doc.                 " Importe de pago en moneda documento
      "wa_data_alv-pago_local      = v_monto_pago_local.               " Importe de pago en moneda local
      <fs_head>-moneda_cobro        = i_lineitems-currency.             " Moneda de pago
      "WRITE i_lineitems-pstng_date TO wa_data_alv-budat.              " Fecha de pago

      <fs_head>-fecha_cobro = i_lineitems-pstng_date.
      v_fecha_pago = i_lineitems-pstng_date.

    ENDIF.

*** De la tabla de facturas
    IF i_documentos-tipo = 'SDT' OR i_documentos-tipo = 'SDP'.

      CLEAR: v_monto_fact_doc, v_monto_fact_local.

      DATA: i_bsad_nc_parc        LIKE bsad OCCURS 0 WITH HEADER LINE,
            v_monto_doc_nc_parc   TYPE p DECIMALS 2,
            v_monto_local_nc_parc TYPE p DECIMALS 2.

      CLEAR: i_bsad_nc_parc, v_monto_doc_nc_parc,
             v_monto_local_nc_parc.
      REFRESH i_bsad_nc_parc.

      SELECT *
        FROM bsad
        INTO TABLE i_bsad_nc_parc
        WHERE kunnr = gt_data-kunnr
        AND   augbl = gt_data-doc_pago
        AND   zuonr = gt_data-factura
        AND   bschl = '11'.

      IF i_bsad_nc_parc[] IS NOT INITIAL.
        LOOP AT i_bsad_nc_parc.
          ADD i_bsad_nc_parc-wrbtr TO v_monto_doc_nc_parc.
          ADD i_bsad_nc_parc-dmbtr TO v_monto_local_nc_parc.
        ENDLOOP.
      ENDIF.

      IF v_qsskz = 'XX'.
        v_monto_fact_doc = i_vbrk-netwr - v_monto_doc_nc_parc.
      ELSE.
        v_monto_fact_doc = i_vbrk-netwr + i_vbrk-mwsbk -
                           v_monto_doc_nc_parc.        " Importe de la factura en moneda local
      ENDIF.
      <fs_head>-totales = v_monto_fact_doc.
      "CONDENSE <fs_head>-totales.

      IF i_vbrk-waerk NE 'MXN' AND i_vbrk-waerk NE 'MXP'.
        IF v_qsskz = 'XX'.
          v_monto_fact_local = ( i_vbrk-netwr - v_monto_local_nc_parc ) *
                                 i_vbrk-kurrf.        " Importe de la factura en moneda local
        ELSE.
          v_monto_fact_local = ( i_vbrk-netwr +
                                 i_vbrk-mwsbk -
                                 v_monto_local_nc_parc ) *
                                 i_vbrk-kurrf.        " Importe de la factura en moneda local
        ENDIF.
        <fs_head>-totales = v_monto_fact_local.
        "CONDENSE wa_data_alv-imp_fact_local.
      ELSE.
        <fs_head>-totales = v_monto_fact_doc.
        "CONDENSE wa_data_alv-imp_fact_local.
      ENDIF.

*      WRITE i_vbrk-fkdat TO wa_data_alv-fkdat.         " Fecha de la factura
*      <
*      v_fecha_fact = i_vbrk-fkdat.
*      wa_data_alv-curren_dr = i_vbrk-waerk.

      IF i_vbrk-kurrf > 0.
        "        wa_data_alv-tc_dr     = i_vbrk-kurrf.
      ENDIF.

    ELSEIF i_documentos-tipo = 'FIP' OR i_documentos-tipo = 'FIT'.

      DATA: v_wrbtr_fi   LIKE bsid-wrbtr,
            v_dmbtr_fi   LIKE bsid-dmbtr,
            v_bldat_fi   LIKE bsid-bldat,
            v_waers_fi   LIKE bsid-waers,
            v_kunnr_pago TYPE kunnr,
            v_gjahr_pago TYPE gjahr.

      CLEAR: v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_monto_fact_doc, v_monto_fact_local, v_waers_fi,
             v_kunnr_pago, v_gjahr_pago.

      v_kunnr_pago = i_lineitems-customer.

      SELECT  name1, stcd1, stcd3
        INTO TABLE @DATA(it_kunnr1)
        FROM kna1
        WHERE kunnr = @i_lineitems-customer.

      READ TABLE it_kunnr1 INTO DATA(wa_kunnr1) INDEX 1.
      IF sy-subrc EQ 0.
        IF wa_kunnr1-stcd1 IS INITIAL.
          <fs_head>-rfc = wa_kunnr1-stcd3.
        ELSE.
          <fs_head>-rfc = wa_kunnr1-stcd1.
        ENDIF.
        <fs_head>-name1 = wa_kunnr1-name1.
      ENDIF.

      v_gjahr_pago = i_lineitems-fisc_year.

      IF v_kunnr_pago IS INITIAL.
        v_kunnr_pago = i_bsad-kunnr.
      ENDIF.

      IF v_gjahr_pago IS INITIAL.
        v_gjahr_pago = i_bsad-gjahr.
      ENDIF.

      SELECT SINGLE wrbtr dmbtr bldat waers
        FROM bsid
        INTO (v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_waers_fi)
        WHERE bukrs = s_bukrs
        AND   kunnr = v_kunnr_pago
        AND   belnr = gt_data-doc_comp
        AND   gjahr = v_gjahr_pago.
      IF v_wrbtr_fi IS INITIAL.
        SELECT SINGLE wrbtr dmbtr bldat waers
        FROM bsad
        INTO (v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_waers_fi)
        WHERE bukrs = s_bukrs
        AND   kunnr = v_kunnr_pago
        AND   belnr = gt_data-doc_comp
        AND   gjahr = v_gjahr_pago.
        IF sy-subrc NE 0 AND ( gt_data-doc_comp = gt_data-factura ).
          DATA: v_gjahr_pago_temp LIKE v_gjahr_pago.
          CLEAR v_gjahr_pago_temp.
          v_gjahr_pago_temp = v_gjahr_pago - 1.
          SELECT SINGLE wrbtr dmbtr bldat waers
            FROM bsid
            INTO (v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_waers_fi)
            WHERE bukrs = s_bukrs
            AND   kunnr = v_kunnr_pago
            AND   belnr = gt_data-doc_comp
            AND   gjahr = v_gjahr_pago_temp.
          IF v_wrbtr_fi IS INITIAL.
            SELECT SINGLE wrbtr dmbtr bldat waers
              FROM bsad
              INTO (v_wrbtr_fi, v_dmbtr_fi, v_bldat_fi, v_waers_fi)
              WHERE bukrs = s_bukrs
              AND   kunnr = v_kunnr_pago
              AND   belnr = gt_data-doc_comp
             AND   gjahr = v_gjahr_pago_temp.
          ENDIF.
        ENDIF.
      ENDIF.

      v_monto_fact_doc = v_wrbtr_fi.
      v_monto_fact_local = v_dmbtr_fi.
      <fs_head>-totales = v_monto_fact_local.
      <fs_head>-totales   = v_monto_fact_doc.
      "CONDENSE wa_data_alv-imp_fact_local.
      "CONDENSE wa_data_alv-imp_fact_doc.
      "WRITE v_bldat_fi TO wa_data_alv-fkdat.
      "v_fecha_fact = v_bldat_fi.
      "wa_data_alv-curren_dr = v_waers_fi.

    ENDIF.
*    IF i_bkpf-kursf NE 0.
*      IF i_bkpf-kursf > 0.
*        wa_data_alv-tc_pago          = i_bkpf-kursf.
*      ELSEIF i_bkpf-kursf < 0.
*        wa_data_alv-tc_pago        = 1 / abs( i_bkpf-kursf ).
*      ENDIF.
*      CONDENSE wa_data_alv-tc_pago.
*    ELSE.
*    ENDIF.

*    IF wa_data_alv-tc_pago = 0.
*      wa_data_alv-tc_pago = 1.
*    ENDIF.

*** Le da formato a los importes
*    DATA: v_importe TYPE wrbtr.
*    CLEAR v_importe.
*    v_importe = wa_data_alv-imp_fact_doc.
*    WRITE v_importe CURRENCY 'MXN' TO wa_data_alv-imp_fact_doc.
*    CONDENSE wa_data_alv-imp_fact_doc.
*
*    CLEAR v_importe.
*    v_importe = wa_data_alv-pago_doc.
*    WRITE v_importe CURRENCY 'MXN' TO wa_data_alv-pago_doc.
*    CONDENSE wa_data_alv-pago_doc.
*
*
*    IF p_rad1 IS INITIAL AND wa_data_alv-uuid IS NOT INITIAL.
*      CLEAR: wa_data_alv, i_vbrk, i_lineitems, i_lineitems_comp, i_zalv_comp_pago, i_bsad.
*      CONTINUE.
*    ELSE.
*      APPEND wa_data_alv.
*    ENDIF.

    CLEAR: i_vbrk, i_lineitems, i_lineitems_comp, i_zalv_comp_pago, i_bsad.
    "---------------------
    READ TABLE i_bkpf WITH KEY   belnr = gt_data-doc_comp.
    <fs_head>-ref_bancaria  = i_bkpf-xblnr.

    SELECT bukrs, gjahr, belnr, hkont,txt50
    INTO TABLE @DATA(it_docsban)
    FROM bseg
    INNER JOIN skat ON skat~saknr = bseg~hkont
    WHERE belnr = @gt_data-doc_pago AND bukrs = @gt_data-bukrs
    AND gjahr = @gt_data-gjahr and fdlev = 'F1'.

    READ TABLE it_docsban INTO DATA(wa_ban) WITH KEY belnr = gt_data-doc_pago
                                                     bukrs = gt_data-bukrs
                                                     gjahr = gt_data-gjahr.

    IF  sy-subrc EQ 0.
      <fs_head>-inst_financ = wa_ban-txt50.
      <fs_head>-num_cta_ban   = wa_ban-hkont.
      <fs_head>-hkont   = wa_ban-hkont.


    ENDIF.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Metodo de pago
select single vbrp~kvgr2
into <fs_head>-metodcobro
from vbrk
inner join vbrp on vbrp~vbeln = vbrk~vbeln
where vbrk~vbeln = gt_data-factura
    and  vbrk~gjahr = gt_data-gjahr.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "Aqui, se busca el xml y se asigna.
    xml_file = gt_data-archivoxml.
*
    REFRESH it_xmlsat. "datos del complemento de Pago
    IF xml_file IS NOT INITIAL. "AND vl_status_http NE '1'.
      PERFORM transformar_xml TABLES it_xmlsat[] USING xml_file CHANGING vl_status_http.
    ENDIF.

    IF it_xmlsat[] IS NOT INITIAL.

      PERFORM distribuir_xml TABLES it_xmlsat
                             USING <fs_head>-vbeln
                             CHANGING <fs_head>.
    ENDIF.

    "datos de la factura Fiscal.
    REFRESH it_xmlsat.
    CLEAR xml_file.

    select single archivoxml
    into xml_file
    from zsd_cfdi_timbre
    where vbeln = gt_data-factura.
     " = gt_data-archivoxml..


      IF xml_file IS NOT INITIAL. "AND vl_status_http NE '1'.
        PERFORM transformar_xml TABLES it_xmlsat[] USING xml_file CHANGING vl_status_http.
      ENDIF.

      IF it_xmlsat[] IS NOT INITIAL.

        PERFORM distribuir_xmlrv TABLES it_xmlsat
                               USING <fs_head>-vbeln
                               CHANGING <fs_head>.
      ENDIF.

      <fs_head>-total = <fs_head>-monto + <fs_head>-iva.




  ENDLOOP.

  "SORT wa_data_alv.
  DELETE ADJACENT DUPLICATES FROM it_ingresos.

ENDFORM.                    " F_PROCESS_DATA
