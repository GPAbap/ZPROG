*&---------------------------------------------------------------------*
*&  Include           ZSD_MONITOR_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSD_MONITOR_F01
*&---------------------------------------------------------------------*
FORM f_get_data.
  DATA: i_data TYPE zsd_cfdi_timbre OCCURS 0 WITH HEADER LINE.
  CLEAR gt_data.
  REFRESH gt_data.
* Recupera infTormación basandose en la selección del usuario
  SELECT bukrs, vbeln, gjahr, zsd_cfdi_timbre~status,  zsd_cfdi_timbre~archivoxml, zsd_cfdi_timbre~archivopdf,
  zsd_cfdi_timbre~uuid, zsd_cfdi_timbre~semaforo,  mot_canc
    INTO CORRESPONDING FIELDS OF TABLE @gt_data
   FROM zsd_cfdi_timbre
    WHERE zsd_cfdi_timbre~bukrs IN @s_bukrs
    AND vbeln IN @s_vbeln
    AND erdat IN  @s_fkdat
    AND kunag IN @s_kunnr.


*** Elimina facturas segun los criterios de seleccion
  IF p_rad1 = 'X'.          " Mostrar solo facturas pendientes
    DELETE gt_data WHERE uuid IS NOT INITIAL.
  ELSEIF p_rad2 = 'X'.      " Mostrar solo facturas timbradas.
    DELETE gt_data WHERE uuid IS INITIAL.
  ENDIF.


  IF gt_data[] IS NOT INITIAL.  "SY-SUBRC EQ 0.
    SORT gt_data BY vbeln .
* Recupera información de la factura
    SELECT vbrk~vbeln, vbrk~belnr, bseg~augbl,  vbrk~fkdat, vkorg, vbrk~bukrs, kunag, bseg~dmbtr AS netwr, mwsbk ,vbrk~zterm, vbrk~zlsch, fksto,
           vbrp~matnr, vbrp~posnr, zalv_comp_pago~uuid AS uuid_compl, zalv_comp_pago~impsaldoinsoluto AS importe_pend,bschl

      FROM vbrk
      INNER JOIN vbrp ON vbrp~vbeln = vbrk~vbeln
      LEFT JOIN bseg ON bseg~belnr = vbrk~belnr AND bseg~bschl IN ( '01', '40' )  AND bseg~bukrs EQ vbrk~bukrs
      LEFT JOIN zalv_comp_pago ON zalv_comp_pago~factura = vbrk~vbeln AND zalv_comp_pago~doc_comp = vbrk~belnr
      FOR ALL ENTRIES IN @gt_data
      WHERE  vbrk~vbeln EQ @gt_data-vbeln
      AND vbrk~bukrs    EQ @gt_data-bukrs
      AND bseg~gjahr EQ @gt_data-gjahr
      INTO CORRESPONDING FIELDS OF TABLE @gt_vbrk.


* Recupera Información de posición
    SELECT vbeln vkbur
      FROM vbrp
      INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
      FOR ALL ENTRIES IN gt_vbrk
      WHERE  vbeln EQ gt_vbrk-vbeln
         AND vkbur IN s_vkbur.
  ENDIF.

  LOOP AT gt_vbrk INTO ls_vbrk.
    READ TABLE gt_vbrp INTO ls_vbrp WITH KEY vbeln = ls_vbrk-vbeln.
    IF sy-subrc NE 0.
      DELETE gt_vbrk.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " F_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .

  SELECT belnr, budat
  INTO TABLE @DATA(it_bkpf)
   FROM bkpf
  FOR ALL ENTRIES IN @gt_vbrk
  WHERE belnr = @gt_vbrk-belnr
  AND xreversal = '1'.


  SELECT belnr, awitem, racct,bschl
  INTO TABLE @DATA(it_cuentas)
  FROM acdoca
  FOR ALL ENTRIES IN @gt_vbrk
  WHERE belnr = @gt_vbrk-belnr
  AND awitem = @gt_vbrk-posnr.


  CLEAR gt_data_alv.
  REFRESH gt_data_alv.
* Se arma tabla de salida.
  LOOP AT gt_data ASSIGNING <ls_data>.
    CLEAR: ls_vbrk, ls_vbrp, ls_bseg.
    APPEND INITIAL LINE TO gt_data_alv ASSIGNING <ls_data_alv>.
    READ TABLE gt_vbrk  INTO ls_vbrk WITH KEY vbeln = <ls_data>-vbeln.
    READ TABLE gt_vbrp  INTO ls_vbrp WITH KEY vbeln = <ls_data>-vbeln.
    READ TABLE gt_bseg  INTO ls_bseg WITH KEY belnr = <ls_data>-vbeln.
* Asignación de semaforo dependiendo el tipo de status
    CASE <ls_data>-semaforo.
      WHEN 'E'.
        <ls_data_alv>-anulada = icon_led_red.
*        <ls_data_alv>-txt = icon_display_text.
      WHEN 'S'.
        <ls_data_alv>-anulada = icon_led_green.
      WHEN 'W'.
        <ls_data_alv>-anulada = icon_led_yellow.
      WHEN OTHERS.
        <ls_data_alv>-anulada = icon_led_yellow.
    ENDCASE.


    <ls_data_alv>-bukrs = ls_vbrk-bukrs.
    <ls_data_alv>-kunag = ls_vbrk-kunag.
*   <ls_data_alv>-zterm = ls_vbrk-zterm.
*   <ls_data_alv>-zlsch = ls_vbrk-zlsch.
    <ls_data_alv>-vbeln = <ls_data>-vbeln.
    <ls_data_alv>-fkdat = ls_vbrk-fkdat.
    <ls_data_alv>-vkbur = ls_vbrp-vkbur.
    <ls_data_alv>-netwr = ls_vbrk-netwr. " valor total factura
    <ls_data_alv>-mwsbk = ls_vbrk-mwsbk. " Impuesto
    <ls_data_alv>-uuid  = <ls_data>-uuid.
    <ls_data_alv>-fksto = ls_vbrk-fksto.
    IF ls_vbrk-fksto EQ 'X'.
      READ TABLE it_bkpf INTO DATA(wa_bkpf) WITH KEY belnr = ls_vbrk-belnr.
      IF sy-subrc EQ 0.
        <ls_data_alv>-fec_canc = wa_bkpf-budat.
      ENDIF.
    ENDIF.

    READ TABLE it_cuentas INTO DATA(wa_cuentas) WITH KEY belnr = ls_vbrk-belnr awitem = ls_vbrk-posnr.
    IF sy-subrc = 0.
      <ls_data_alv>-cuenta = wa_cuentas-racct.
    ENDIF.
    <ls_data_alv>-motivo = <ls_data>-mot_canc.
    <ls_data_alv>-doc_prov = ls_vbrk-belnr.
    <ls_data_alv>-doc_ingreso = ls_vbrk-augbl.
    IF ls_vbrk-augbl IS INITIAL.
      SELECT SINGLE augbl INTO <ls_data_alv>-doc_ingreso FROM bseg
      WHERE belnr = ls_vbrk-belnr AND vbeln = <ls_data>-vbeln AND bschl = '11'.
      IF sy-subrc NE 0.
        READ TABLE gt_vbrk  INTO DATA(aux_vbrk) WITH KEY vbeln = <ls_data>-vbeln bschl = '01'.
        IF sy-subrc EQ 0.
          <ls_data_alv>-doc_ingreso = aux_vbrk-augbl.
        ENDIF.
      ENDIF.
    ENDIF.
    <ls_data_alv>-folio_compl = ls_vbrk-uuid_compl.
*    <ls_data_alv>-kunag = <ls_data>-kunag.
*    <LS_DATA_ALV>-FECHA_XML = <LS_DATA>-FEC_SELLO.
* PDF
    IF <ls_data>-archivopdf IS NOT INITIAL.
      <ls_data_alv>-pdf   = icon_pdf.    " PDF
    ENDIF.
* Archivo XML
    IF <ls_data>-archivoxml IS NOT INITIAL.
      <ls_data_alv>-xml   = icon_xml_doc. " XML
    ENDIF.
*** PDF de cancelacion
    IF <ls_data>-archivoxml_canc IS NOT INITIAL.
      <ls_data_alv>-pdf_canc   = icon_pdf. " XML
    ENDIF.
* Comentario
    <ls_data_alv>-comentario = <ls_data>-status.
*** Nuevo semaforo
    IF <ls_data_alv>-uuid IS NOT INITIAL.
      <ls_data_alv>-anulada = icon_led_green.
    ELSEIF <ls_data_alv>-uuid IS INITIAL AND <ls_data_alv>-comentario IS NOT INITIAL.
      <ls_data_alv>-anulada = icon_led_yellow.
    ELSEIF <ls_data_alv>-uuid IS INITIAL AND <ls_data_alv>-comentario IS INITIAL.
      <ls_data_alv>-anulada = icon_led_red.
    ENDIF.
    """"""""""""""""""""Datos obtenidos del XML 05/12/2023 JHV""""""""""""""""""""""""""""""""""""""""""""""""""
    xml_file = <ls_data>-archivoxml.
    REFRESH it_xmlsat.
    IF xml_file IS NOT INITIAL. "AND vl_status_http NE '1'.
      REPLACE 'https://' IN xml_file WITH 'http://'.
      PERFORM transformar_xml TABLES it_xmlsat[] USING xml_file.
    ENDIF.

    IF it_xmlsat[] IS NOT INITIAL.

      PERFORM distribuir_xml TABLES it_xmlsat
                             USING <ls_data>-vbeln
                             '01'
                             CHANGING <ls_data_alv>.
       ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
***************************
    "si hay movimiento 40 del mismo documento.
    READ TABLE gt_vbrk  INTO ls_vbrk WITH KEY vbeln = <ls_data>-vbeln bschl = '40'.
    IF sy-subrc EQ 0.

      APPEND INITIAL LINE TO gt_data_alv ASSIGNING <ls_data_alv2>.
      CASE <ls_data>-semaforo.
        WHEN 'E'.
          <ls_data_alv2>-anulada = icon_led_red.
*        <ls_data_alv>-txt = icon_display_text.
        WHEN 'S'.
          <ls_data_alv2>-anulada = icon_led_green.
        WHEN 'W'.
          <ls_data_alv2>-anulada = icon_led_yellow.
        WHEN OTHERS.
          <ls_data_alv2>-anulada = icon_led_yellow.
      ENDCASE.


      <ls_data_alv2>-bukrs = ls_vbrk-bukrs.
      <ls_data_alv2>-kunag = ls_vbrk-kunag.
*   <ls_data_alv>-zterm = ls_vbrk-zterm.
*   <ls_data_alv>-zlsch = ls_vbrk-zlsch.
      <ls_data_alv2>-vbeln = <ls_data>-vbeln.
      <ls_data_alv2>-fkdat = ls_vbrk-fkdat.
      <ls_data_alv2>-vkbur = ls_vbrp-vkbur.
      <ls_data_alv2>-netwr = ls_vbrk-netwr. " valor total factura
      <ls_data_alv2>-descuento = ls_vbrk-netwr.

      <ls_data_alv2>-mwsbk = ls_vbrk-mwsbk. " Impuesto
      <ls_data_alv2>-uuid  = <ls_data>-uuid.
      <ls_data_alv2>-fksto = ls_vbrk-fksto.
      IF ls_vbrk-fksto EQ 'X'.
        READ TABLE it_bkpf INTO DATA(wa_bkpf2) WITH KEY belnr = ls_vbrk-belnr.
        IF sy-subrc EQ 0.
          <ls_data_alv2>-fec_canc = wa_bkpf2-budat.
        ENDIF.
      ENDIF.

      READ TABLE it_cuentas INTO DATA(wa_cuentas2) WITH KEY belnr = ls_vbrk-belnr awitem = ls_vbrk-posnr bschl = '40'.
      IF sy-subrc = 0.
        <ls_data_alv2>-cuenta = wa_cuentas2-racct.
      ENDIF.

      <ls_data_alv2>-motivo = <ls_data>-mot_canc.
      <ls_data_alv2>-doc_prov = ls_vbrk-belnr.
      <ls_data_alv2>-doc_ingreso = ls_vbrk-augbl.
      IF ls_vbrk-augbl IS INITIAL.
        SELECT SINGLE augbl INTO <ls_data_alv2>-doc_ingreso FROM bseg
        WHERE belnr = ls_vbrk-belnr AND vbeln = <ls_data>-vbeln AND bschl = '11'.
        IF sy-subrc NE 0.
          READ TABLE gt_vbrk  INTO DATA(aux_vbrk2) WITH KEY vbeln = <ls_data>-vbeln bschl = '01'.
          IF sy-subrc EQ 0.
            <ls_data_alv2>-doc_ingreso = aux_vbrk2-augbl.
          ENDIF.
        ENDIF.
      ENDIF.
      <ls_data_alv2>-folio_compl = ls_vbrk-uuid_compl.
*    <ls_data_alv>-kunag = <ls_data>-kunag.
*    <LS_DATA_ALV>-FECHA_XML = <LS_DATA>-FEC_SELLO.
* PDF
      IF <ls_data>-archivopdf IS NOT INITIAL.
        <ls_data_alv2>-pdf   = icon_pdf.    " PDF
      ENDIF.
* Archivo XML
      IF <ls_data>-archivoxml IS NOT INITIAL.
        <ls_data_alv2>-xml   = icon_xml_doc. " XML
      ENDIF.
*** PDF de cancelacion
      IF <ls_data>-archivoxml_canc IS NOT INITIAL.
        <ls_data_alv2>-pdf_canc   = icon_pdf. " XML
      ENDIF.
* Comentario
      <ls_data_alv2>-comentario = <ls_data>-status.
*** Nuevo semaforo
      IF <ls_data_alv2>-uuid IS NOT INITIAL.
        <ls_data_alv2>-anulada = icon_led_green.
      ELSEIF <ls_data_alv2>-uuid IS INITIAL AND <ls_data_alv>-comentario IS NOT INITIAL.
        <ls_data_alv2>-anulada = icon_led_yellow.
      ELSEIF <ls_data_alv2>-uuid IS INITIAL AND <ls_data_alv>-comentario IS INITIAL.
        <ls_data_alv2>-anulada = icon_led_red.
      ENDIF.

      IF it_xmlsat[] IS NOT INITIAL.

        PERFORM distribuir_xml TABLES it_xmlsat
                               USING <ls_data>-vbeln
                                     '40'
                               CHANGING <ls_data_alv2>
                               .

      ENDIF.

    ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    UNASSIGN <ls_data_alv>.
    UNASSIGN <ls_data_alv2>.
  ENDLOOP.

ENDFORM.                    " F_PROCESS_DATA

FORM transformar_xml  TABLES   gt_xml_data STRUCTURE smum_xmltb
                      USING    ruta_xml TYPE zaxnare_el034
                    .

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
      " p_status_http = '1'.
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
                           p_bschl TYPE bschl
                     CHANGING wa_data_alv TYPE ty_data_alv.

  DATA wa_xmlsat TYPE smum_xmltb.

  CLEAR wa_xmlsat.
  DATA: indice_base TYPE i, indice_inc TYPE i.
  DATA: vl_valor TYPE p DECIMALS 6,  vl_tasa TYPE p DECIMALS 6.
  DATA vl_vbeln TYPE vbeln.




*  READ TABLE p_it_xmlsat INTO wa_xmlsat WITH KEY  hier = '5' type = 'A' cname = 'Folio' cvalue = vl_vbeln.
*  IF sy-tabix EQ 0 OR vl_vbeln CP '180*'.
*    EXIT.
*  ENDIF.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'MetodoPago'.
  wa_data_alv-metodo_pago = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'Moneda'.
  wa_data_alv-moneda_xml = wa_xmlsat-cvalue.

  IF wa_data_alv-forma_pago IS INITIAL.
    CLEAR wa_xmlsat.
    READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'FormaPago'.
    wa_data_alv-forma_pago = wa_xmlsat-cvalue.
  ENDIF.

  CLEAR wa_xmlsat.
  IF p_bschl NE '40'.
    READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'Descuento'.
    IF sy-subrc EQ 0.
      wa_data_alv-descuento = wa_xmlsat-cvalue.
    ELSE.
      wa_data_alv-descuento = 0.
    ENDIF.
  ENDIF.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'Total'.
  IF sy-subrc EQ 0.
    wa_data_alv-total_xml = wa_xmlsat-cvalue.
  ELSE.
    wa_data_alv-total_xml = 0.
  ENDIF.


  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '2' type = 'A' cname = 'UsoCFDI'.
  wa_data_alv-uso_cfdi = wa_xmlsat-cvalue.


  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '3' type = 'A' cname = 'Descripcion'.
  wa_data_alv-concepto_bien = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '1' type = 'A' cname = 'Fecha'.
  CONCATENATE wa_xmlsat-cvalue+8(2) wa_xmlsat-cvalue+5(2) wa_xmlsat-cvalue+0(4)   INTO DATA(tmp_fecha) .

  CALL FUNCTION 'CONVERSION_EXIT_PDATE_INPUT'
    EXPORTING
      input        = tmp_fecha
    IMPORTING
      output       = wa_data_alv-fecha_timbre
    EXCEPTIONS
      invalid_date = 1
      OTHERS       = 2.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '1' type = 'A' cname = 'TipoCambio'.
  wa_data_alv-tipo_cambio = wa_xmlsat-cvalue.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  hier = '1' type = 'A' cname = 'TipoDeComprobante'.
  IF wa_xmlsat-cvalue EQ 'I'.
    wa_data_alv-tipo_comp = 'Ingreso'.
  ELSE.
    wa_data_alv-tipo_comp = 'Otro'.
  ENDIF.

  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  cname = 'Receptor'.
  indice_base = sy-tabix.
  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_base + 1.
  wa_data_alv-receptor_rfc = wa_xmlsat-cvalue.
  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_base + 2.
  wa_data_alv-receptor_nombre = wa_xmlsat-cvalue.

  """""""""""""""""""""impuestos y bases"""""""""""""""""""""""""""""""""""""""""""""""""
  CLEAR wa_xmlsat.
  READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY hier = '4' type = 'A' cname = 'Base'.

  IF sy-subrc EQ 0.
    DATA(vl_base) = wa_xmlsat-cvalue.
    indice_base = sy-tabix.
    indice_inc = indice_base + 3.
    CLEAR wa_xmlsat.
    READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_inc.
    IF sy-subrc EQ 0.
      IF wa_xmlsat-cvalue EQ '0.000000'.
        wa_data_alv-base0 = vl_base.
        wa_data_alv-iva_xml = 0.
      ELSE.
        wa_data_alv-base16 = vl_base.
        CLEAR wa_xmlsat.
        READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_inc + 1.
        wa_data_alv-iva_xml = wa_xmlsat-cvalue.
      ENDIF.
    ENDIF.


    CLEAR wa_xmlsat.
    READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_base + 6.
    IF wa_xmlsat-cname EQ 'Base'.
      indice_base = indice_base + 6.
      vl_base = wa_xmlsat-cvalue.
      indice_inc = indice_base + 3.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_inc.
      IF sy-subrc EQ 0.
        IF wa_xmlsat-cvalue EQ '0.000000'.
          wa_data_alv-base0 = vl_base.
          wa_data_alv-iva_xml = 0.
        ELSE.
          wa_data_alv-base16 = vl_base.
          CLEAR wa_xmlsat.
          READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_inc + 1.
          wa_data_alv-iva_xml = wa_xmlsat-cvalue.
        ENDIF.
      ENDIF.


    ENDIF.

  ENDIF.

  """""""""""""""""se obtienen los materiales y se concantenan"""""""""""""""""""""""""""""""""""""""""""""""""""""

  LOOP AT gt_vbrk INTO DATA(wa_vbrk) WHERE vbeln = wa_data_alv-vbeln.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = wa_vbrk-matnr
      IMPORTING
        output = wa_vbrk-matnr.

    CLEAR wa_xmlsat.
    READ TABLE it_xmlsat INTO wa_xmlsat WITH KEY  cname = 'NoIdentificacion' cvalue = wa_vbrk-matnr.
    IF sy-subrc EQ 0.
      indice_base = sy-tabix - 1 .
      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_base.
      CONCATENATE wa_data_alv-clave_sat wa_xmlsat-cvalue '|' INTO wa_data_alv-clave_sat.

      CLEAR wa_xmlsat.
      READ TABLE it_xmlsat INTO wa_xmlsat INDEX indice_base + 5.
      CONCATENATE wa_data_alv-concepto_bien wa_xmlsat-cvalue '|' INTO wa_data_alv-concepto_bien.
    ENDIF.

  ENDLOOP.



  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SHOW_ALV
*&---------------------------------------------------------------------*
FORM f_show_alv .

************* DESBORRAR   *****************************
*  DELETE  GT_DATA_ALV WHERE ANULADA IS INITIAL.
  DELETE gt_data_alv WHERE vbeln IS INITIAL.

  DATA: lx_msg     TYPE REF TO cx_salv_msg,
        lr_funct   TYPE REF TO cl_salv_functions,
        lr_columns TYPE REF TO cl_salv_columns_table,
        lr_column  TYPE REF TO cl_salv_column_table,
        lr_events  TYPE REF TO cl_salv_events_table,
        l_text     TYPE string,
        l_icon     TYPE string.

  TRY.
      cl_salv_table=>factory(
*      EXPORTING
*        LIST_DISPLAY = ABAP_TRUE
        IMPORTING
          r_salv_table = o_alv
        CHANGING
          t_table      = gt_data_alv ).

    CATCH cx_salv_msg INTO lx_msg.

  ENDTRY.

  o_alv->set_screen_status(
      pfstatus      =  'SALV_STANDARD'
      report        =  sy-repid
      set_functions = o_alv->c_functions_all ).


  lr_funct = o_alv->get_functions( ).
  lr_funct->set_all( abap_true ).

  lr_columns = o_alv->get_columns( ).
  lr_columns->set_optimize( abap_true ).
  lr_columns->set_optimize( 'X' ).


  TRY.
*** Checkbox
      lr_column ?= lr_columns->get_column( 'CHECK' ).
      lr_column->set_long_text( 'Marcar' ).
      lr_columns->set_optimize( 'X' ).
      lr_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).

*** Anulada
      lr_column ?= lr_columns->get_column( 'ANULADA' ).
*      LR_COLUMN->SET_LONG_TEXT( 'Status' ).
      lr_column->set_short_text( 'Status' ).
      lr_columns->set_optimize( 'X' ).
      lr_column->set_icon( if_salv_c_bool_sap=>true ).

** Factura
      lr_column ?= lr_columns->get_column( 'VBELN' ).
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

*** UUID
      lr_column ?= lr_columns->get_column( 'UUID' ).
      lr_column->set_long_text( 'UUID' ).

**Fecha de Canecelacion
      lr_column ?= lr_columns->get_column( 'FEC_CANC' ).
      lr_column->set_short_text('Fec. Canc.').
      lr_column->set_long_text( 'Fecha de Cancelación' ).
      lr_columns->set_optimize( 'X' ).

**Cuenta contable
      lr_column ?= lr_columns->get_column( 'CUENTA' ).
      lr_column->set_short_text( 'Cuenta' ).
      lr_column->set_long_text( 'Cuenta' ).
      lr_columns->set_optimize( 'X' ).

**Base 8%
      lr_column ?= lr_columns->get_column( 'BASE8' ).
      lr_column->set_short_text( 'Base IVA 8' ).
      lr_column->set_long_text( 'Base IVA 8' ).
      lr_columns->set_optimize( 'X' ).

**Exento
      lr_column ?= lr_columns->get_column( 'EXENTO' ).
      lr_column->set_short_text( 'Exento' ).
      lr_column->set_long_text( 'Exento' ).
      lr_columns->set_optimize( 'X' ).
* VALOR NETO
      lr_column ?= lr_columns->get_column( 'NETWR' ).
*      LR_COLUMN->SET_LONG_TEXT( 'Fecha XML' ).
      lr_column->set_visible( ' ' ).

* IMPUESTO
      lr_column ?= lr_columns->get_column( 'MWSBK' ).
*      LR_COLUMN->SET_LONG_TEXT( 'Fecha XML' ).
      lr_column->set_visible( ' ' ).


*** Cliente
      lr_column ?= lr_columns->get_column( 'KUNAG' ).
      lr_column->set_long_text( 'Cliente' ).

***PDF
      lr_column ?= lr_columns->get_column( 'PDF' ).
      lr_column->set_icon( if_salv_c_bool_sap=>true ).
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      lr_column->set_long_text( 'PDF (CFDI)' ).
      lr_column->set_short_text( 'PDF (CFDI)' ).

***XML
      lr_column ?= lr_columns->get_column( 'XML' ).
      lr_column->set_icon( if_salv_c_bool_sap=>true ).
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      lr_column->set_short_text( 'XML (CFDI)' ).
      lr_column->set_long_text( 'XML (CFDI)' ).

*** Error
      lr_column ?= lr_columns->get_column( 'COMENTARIO' ).
      lr_column->set_long_text( 'Status PAC' ).

*** Motivo de cancelacion
      lr_column ?= lr_columns->get_column( 'MOTIVO' ).
      lr_column->set_long_text( 'Mot.Canc.' ).


***PDF
      lr_column ?= lr_columns->get_column( 'PDF_CANC' ).
      lr_column->set_icon( if_salv_c_bool_sap=>true ).
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      lr_column->set_long_text( 'Acuse Canc.' ).
      lr_column->set_short_text( 'AcuseCanc.' ).
**********************************************************************
      lr_column ?= lr_columns->get_column( 'TIPO_COMP' ).
      lr_column->set_long_text( 'Tipo Comprobante' ).
**********************************************************************
      lr_column ?= lr_columns->get_column( 'USO_CFDI' ).
      lr_column->set_long_text( 'Uso CFDI' ).
**********************************************************************
      lr_column ?= lr_columns->get_column( 'FECHA_TIMBRE' ).
      lr_column->set_long_text( 'Fecha Timbrado' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'RECEPTOR_RFC' ).
      lr_column->set_long_text( 'Receptor RFC' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'RECEPTOR_NOMBRE' ).
      lr_column->set_long_text( 'Receptor Nombre' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'CONCEPTO_BIEN' ).
      lr_column->set_long_text( 'Concepto SAT' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'CLAVE_SAT' ).
      lr_column->set_long_text( 'Clave SAT' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'SUBTOTAL_XML' ).
      lr_column->set_long_text( 'Subtotal Xml' ).
      lr_column->set_visible( ' ' ).


**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'BASE16' ).
      lr_column->set_long_text( 'Base IVA 16' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'BASE0' ).
      lr_column->set_long_text( 'Base IVA 0' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'DESCUENTO' ).
      lr_column->set_long_text( 'Descuento' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'IVA_XML' ).
      lr_column->set_long_text( 'IVA' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'TOTAL_XML' ).
      lr_column->set_long_text( 'Total' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'TIPO_CAMBIO' ).
      lr_column->set_long_text( 'Tipo de Cambio' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'MONEDA_XML' ).
      lr_column->set_long_text( 'Moneda' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'FORMA_PAGO' ).
      lr_column->set_long_text( 'Forma Pago' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'METODO_PAGO' ).
      lr_column->set_long_text( 'Metodo Pago' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'DOC_PROV' ).
      lr_column->set_long_text( 'Doc. Provision' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'DOC_INGRESO' ).
      lr_column->set_long_text( 'Doc. Ingreso' ).
**********************************************************************
**********************************************************************
      lr_column ?= lr_columns->get_column( 'IMPORTE_PEND' ).
      lr_column->set_long_text( 'Importe Pend.' ).
**********************************************************************

**********************************************************************
      lr_column ?= lr_columns->get_column( 'FOLIO_COMPL' ).
      lr_column->set_long_text( 'Folio Complemento' ).
**********************************************************************







    CATCH  cx_salv_not_found.

*** Status de cancelacion
*      LR_COLUMN ?= LR_COLUMNS->GET_COLUMN( 'M' ).
*      LR_COLUMN->SET_LONG_TEXT( 'Mot.Canc.' ).
*
*         STAT_CANC       TYPE C,
*         STATUS(600)     TYPE C,

  ENDTRY.

*Eventos
  lr_events = o_alv->get_event( ).

  SET HANDLER cl_event_handler=>on_link_click       FOR lr_events.
  SET HANDLER cl_event_handler=>on_added_function   FOR lr_events.

*Muestra ALV
  o_alv->display( ).



ENDFORM.                    " F_SHOW_ALV
*&---------------------------------------------------------------------*
*&      Form  SHOW_DOCUMENT
*&---------------------------------------------------------------------*
FORM show_document  USING p_row TYPE salv_de_row
                          p_column TYPE salv_de_column .

  DATA: lv_url          TYPE          c LENGTH 255,
        lv_type         TYPE          c LENGTH 20,
        lv_subtype      TYPE          c LENGTH 20,
        lcl_html_viewer TYPE REF TO   cl_gui_html_viewer,
        lt_binary_tab   TYPE TABLE OF sdokcntbin,
        lv_length       TYPE          i,
        lv_xstring      TYPE          xstring,
        lv_error        TYPE          boolean,
        lv_file         TYPE string.

  TYPES: lty_x_line(256) TYPE                   x,
         lty_x_tab       TYPE STANDARD TABLE OF lty_x_line.

  DATA: lt_xtab TYPE        lty_x_tab,
        o_cfdi  TYPE REF TO zcl_cfdi.


  FIELD-SYMBOLS: <ls_data>     LIKE LINE OF gt_data,
                 <ls_data_alv> LIKE LINE OF gt_data_alv,
                 <ls_envio>    LIKE LINE OF gt_envio.

  READ TABLE gt_data_alv ASSIGNING <ls_data_alv> INDEX  p_row.

  IF sy-subrc EQ 0.

    READ TABLE   gt_data ASSIGNING <ls_data>  WITH KEY vbeln = <ls_data_alv>-vbeln.

    IF sy-subrc EQ 0.

      CALL METHOD cl_gui_cfw=>flush.

      CREATE OBJECT lcl_html_viewer
        EXPORTING
          parent   = cl_gui_container=>screen2
          lifetime = 0.

      CASE p_column.

        WHEN 'VBELN'.
* Abrir transacción para visualizar Factura
          SET PARAMETER ID 'VF' FIELD <ls_data_alv>-vbeln.
          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
          RETURN.

        WHEN 'PDF'.

          lv_url = <ls_data>-archivopdf.
          IF lv_url IS NOT INITIAL.

            CALL FUNCTION 'CALL_BROWSER'
              EXPORTING
                url                    = lv_url
              EXCEPTIONS
                frontend_not_supported = 1
                frontend_error         = 2
                prog_not_found         = 3
                no_batch               = 4
                unspecified_error      = 5
                OTHERS                 = 6.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

          ENDIF.

        WHEN 'XML' .

          lv_url = <ls_data>-archivoxml.
          IF lv_url IS NOT INITIAL.

            CALL FUNCTION 'CALL_BROWSER'
              EXPORTING
                url                    = lv_url
              EXCEPTIONS
                frontend_not_supported = 1
                frontend_error         = 2
                prog_not_found         = 3
                no_batch               = 4
                unspecified_error      = 5
                OTHERS                 = 6.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

          ENDIF.

        WHEN 'PDF_CANC'.

          lv_url = <ls_data>-archivopdf_canc.
          IF lv_url IS NOT INITIAL.

            CALL FUNCTION 'CALL_BROWSER'
              EXPORTING
                url                    = lv_url
              EXCEPTIONS
                frontend_not_supported = 1
                frontend_error         = 2
                prog_not_found         = 3
                no_batch               = 4
                unspecified_error      = 5
                OTHERS                 = 6.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

          ENDIF.

      ENDCASE.

      IF lv_error IS INITIAL.
      ELSE.
        MESSAGE 'Selection not valid'(002) TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " SHOW_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_DESCARGA_XML_CANC_CONS
*&---------------------------------------------------------------------*
FORM f_descarga_xml_canc_cons USING tipo .


  LOOP AT gt_data_alv ASSIGNING <ls_data_alv>." INDEX ROW.
    IF <ls_data_alv>-check = 'X'.
      READ TABLE gt_data ASSIGNING <ls_data_desc>
        WITH KEY bukrs = <ls_data_alv>-bukrs
                 vbeln = <ls_data_alv>-vbeln.
      IF tipo = 0.
        IF <ls_data_desc>-stat_canc = 'V' OR
          <ls_data_desc>-stat_canc = 'A' OR
          <ls_data_desc>-stat_canc = 'S' OR
          <ls_data_desc>-stat_canc = 'O'.
          CALL FUNCTION 'POPUP_TO_INFORM'
            EXPORTING
              titel = 'Factura cancelada'
              txt1  = 'Factura previamente cancelada o solicitada'
              txt2  = 'No se procesa'.
        ELSE.
*** Envia solicitud de cancelacoin
          PERFORM f_solicitud_canc_cons USING '0'.
        ENDIF.
      ELSE.
        PERFORM f_solicitud_canc_cons USING '1'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  WAIT UP TO 1 SECONDS.
  PERFORM f_get_data.
  PERFORM f_process_data.

  o_alv->refresh( refresh_mode = if_salv_c_refresh=>full ).

ENDFORM.                    " F_DESCARGA_XML_CANC

*&---------------------------------------------------------------------*
*&      FORM F_DESCARGA_XML_STAT
*&---------------------------------------------------------------------*
FORM f_descarga_xml_stat .
*
*  DATA: IT_XML             TYPE STRING OCCURS 0 WITH HEADER LINE,
*        I_ZPAC_DATOS_LOGON TYPE ZPAC_DATOS_LOGON OCCURS 0 WITH HEADER LINE,
*        I_ZSD_CFDI_TIMBRE  TYPE ZSD_CFDI_TIMBRE  OCCURS 0 WITH HEADER LINE,
*        LR_SELECTIONS      TYPE REF TO CL_SALV_SELECTIONS,
*        LT_ROWS            TYPE SALV_T_ROW,
*        L_ROW              TYPE I,
*        V_ROW              TYPE CHAR128,
*        V_RFC              TYPE STRING,
*        V_UUID             TYPE STRING,
*        V_TOTAL            TYPE STRING.
*
*  CLEAR:   IT_XML, I_ZPAC_DATOS_LOGON, I_ZSD_CFDI_TIMBRE,
*           V_RFC, V_UUID, V_TOTAL.
*  REFRESH: IT_XML, I_ZPAC_DATOS_LOGON, I_ZSD_CFDI_TIMBRE.
*
*  FIELD-SYMBOLS: <LS_DATA>     LIKE LINE OF GT_DATA,
*                 <LS_DATA_ALV> LIKE LINE OF GT_DATA_ALV,
*                 <LS_ENVIO>    LIKE LINE OF GT_ENVIO.
*
*
*
*
*  LR_SELECTIONS = O_ALV->GET_SELECTIONS( ).
*  LT_ROWS = LR_SELECTIONS->GET_SELECTED_ROWS( ).
*  LOOP AT LT_ROWS INTO L_ROW.
*    WRITE L_ROW TO V_ROW LEFT-JUSTIFIED.
*  ENDLOOP.
*  READ TABLE GT_DATA_ALV ASSIGNING <LS_DATA_ALV> INDEX V_ROW.
*
*  IF SY-SUBRC EQ 0.
*    SELECT *
*      FROM ZPAC_DATOS_LOGON
*      INTO TABLE I_ZPAC_DATOS_LOGON.
*
*    SELECT *
*      FROM ZSD_CFDI_TIMBRE
*      INTO TABLE I_ZSD_CFDI_TIMBRE
*      WHERE VBELN = <LS_DATA_ALV>-VBELN.
*
*    READ TABLE I_ZPAC_DATOS_LOGON INDEX 1.
*    READ TABLE I_ZSD_CFDI_TIMBRE INDEX 1.
*    V_RFC = I_ZSD_CFDI_TIMBRE-STCD1.
*    V_UUID = I_ZSD_CFDI_TIMBRE-UUID.
*    V_TOTAL = I_ZSD_CFDI_TIMBRE-NETWR.
*    CONDENSE: V_RFC, V_UUID, V_TOTAL.
*
**** Valida si ya esta cancelada para no enviar de nuevo
*    IF I_ZSD_CFDI_TIMBRE-STAT_CANC = 'V' OR
*       I_ZSD_CFDI_TIMBRE-STAT_CANC = 'A' OR
*       I_ZSD_CFDI_TIMBRE-STAT_CANC = 'S'.
*
*      CONCATENATE 'Invoice:' <LS_DATA_ALV>-VBELN INTO V_TXT1 SEPARATED BY SPACE.
*      V_TXT2 = 'Already Cancelled.  Request will not be sent.'.
*      CALL FUNCTION 'POPUP_TO_INFORM'
*        EXPORTING
*          TITEL = 'Invoice cancellation'
*          TXT1  = V_TXT1
*          TXT2  = V_TXT2.
*      EXIT.
*    ENDIF.
*
*    IT_XML = '<root>'. APPEND IT_XML. CLEAR IT_XML.
*
*    CONCATENATE '<usuario>'     I_ZPAC_DATOS_LOGON-USER_PAC       '</usuario>' INTO IT_XML. APPEND IT_XML. CLEAR IT_XML.
*    CONCATENATE '<contrasena>'  I_ZPAC_DATOS_LOGON-PASSWORD_PAC   '</contrasena>' INTO IT_XML. APPEND IT_XML. CLEAR IT_XML.
*
*    CONCATENATE '<rfcReceptor>' V_RFC   '</rfcReceptor>' INTO IT_XML. APPEND IT_XML. CLEAR IT_XML.
*    CONCATENATE '<uuid>'        V_UUID  '</uuid>' INTO IT_XML. APPEND IT_XML. CLEAR IT_XML.
*    CONCATENATE '<Total>'       V_TOTAL '</Total>' INTO IT_XML. APPEND IT_XML. CLEAR IT_XML.
*
*    IT_XML = '</root>'. APPEND IT_XML. CLEAR IT_XML.
*
*
*  ENDIF.
*
**** Se descarga el archivo al servidor
*  DATA: C_FILENAME(128)       TYPE C.
*  CLEAR C_FILENAME.
*
**  SELECT SINGLE PATHS
**    FROM ZTSERVER_PATHS
**    INTO C_FILENAME
**    WHERE PROCESS = 'CANC'.
*
*  CONCATENATE C_FILENAME
*              'outbound/'
*                I_ZSD_CFDI_TIMBRE-BUKRS
*                '_'
*                I_ZSD_CFDI_TIMBRE-VBELN
*                '_'
*                I_ZSD_CFDI_TIMBRE-GJAHR
*                '_status'
*                '.xml'
*      INTO C_FILENAME.
*
*  OPEN DATASET C_FILENAME FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
*
*  IF SY-SUBRC EQ 0.
*    LOOP AT IT_XML.
*      TRANSFER IT_XML  TO C_FILENAME.
*    ENDLOOP.
*    CLOSE DATASET C_FILENAME.
*  ENDIF.
*
**** Actualiza la tabla del monitor
*  I_ZSD_CFDI_TIMBRE-SEMAFORO = 'C'.
*  I_ZSD_CFDI_TIMBRE-COMENTARIO = 'Cancellation status requested.'.
*
*  CONCATENATE 'Invoice:' <LS_DATA_ALV>-VBELN INTO V_TXT1 SEPARATED BY SPACE.
*  V_TXT2 = 'Cancellation status request sent to PAC.'.
*  CALL FUNCTION 'POPUP_TO_INFORM'
*    EXPORTING
*      TITEL = 'Invoice cancellation'
*      TXT1  = V_TXT1
*      TXT2  = V_TXT2.
*
*  MODIFY ZSD_CFDI_TIMBRE FROM I_ZSD_CFDI_TIMBRE.
*  COMMIT WORK AND WAIT.
*  WAIT UP TO 1 SECONDS.
*  PERFORM F_GET_DATA.
*  PERFORM F_PROCESS_DATA.
*
*  O_ALV->REFRESH( REFRESH_MODE = IF_SALV_C_REFRESH=>FULL ).
*
*  DATA: P_RUTA_FAC TYPE STRING.


ENDFORM.                    "

*&---------------------------------------------------------------------*
*&      FORM F_REENVIAR_XML
*&---------------------------------------------------------------------*
FORM f_reenviar_xml.

  DATA: v_uuid_timbre TYPE zsd_cfdi_timbre-uuid.
  FIELD-SYMBOLS: <ls_data_alv> LIKE LINE OF gt_data_alv.

  CLEAR: i_log_desc.
  REFRESH: i_log_desc.

  LOOP AT gt_data_alv ASSIGNING <ls_data_alv>." INDEX ROW.
*** Si esta seleccoinado el renglon
    IF <ls_data_alv>-check = 'X'.

      CLEAR v_uuid_timbre.

      SELECT SINGLE uuid
        FROM zsd_cfdi_timbre
        INTO v_uuid_timbre
        WHERE vbeln = <ls_data_alv>-vbeln.

*** Valida si ya esta timbrada
      IF v_uuid_timbre IS INITIAL OR
         v_uuid_timbre EQ '00000000-0000-0000-0000-000000000000'.

        DATA: i_vbeln   TYPE  vbeln,
              c_message TYPE  bapiret2_t.

        CLEAR: i_vbeln, c_message, v_txt1, v_txt2.

        i_vbeln =  <ls_data_alv>-vbeln.

*** Si no esta timbrada se reenvia
        CALL FUNCTION 'ZTIMBRADO_CFDI_MM_SD_FI'
          EXPORTING
            i_tipo    = 'FA'
            i_vbeln   = i_vbeln
          CHANGING
            c_message = c_message.

        CONCATENATE 'Factura: ' <ls_data_alv>-vbeln ' reenviada al pac'
          INTO i_log_desc-msg1 RESPECTING BLANKS. "SEPARATED BY SPACE.
        APPEND i_log_desc.

      ELSE.

        CONCATENATE 'Factura: ' <ls_data_alv>-vbeln ' ya timbrada.  No se procesa.'
          INTO i_log_desc-msg1 RESPECTING BLANKS.
        APPEND i_log_desc.

      ENDIF.
    ENDIF.

  ENDLOOP.

  IF i_log_desc[] IS NOT INITIAL.
    PERFORM f_ventana_log.
  ENDIF.

  WAIT UP TO 2 SECONDS.
  PERFORM f_get_data.
  PERFORM f_process_data.
  o_alv->refresh( ).

ENDFORM.                    " f_reenviar_xml

*&---------------------------------------------------------------------*
*&      Form  F_REFRESCAR
*&---------------------------------------------------------------------*
FORM f_refrescar .

  PERFORM f_get_data.
  PERFORM f_process_data.
  o_alv->refresh( ).

ENDFORM.                    " F_REFRESCAR

*&---------------------------------------------------------------------*
*& Form F_MARCAR_TODO
*&---------------------------------------------------------------------*
FORM f_marcar_todo .

  FIELD-SYMBOLS: <lfa_data> LIKE LINE OF gt_data_alv.
  LOOP AT gt_data_alv ASSIGNING <lfa_data>." INDEX ROW.
    <lfa_data>-check = 'X'.
  ENDLOOP.
  o_alv->refresh( ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DESMARCAR_TODO
*&---------------------------------------------------------------------*
FORM f_desmarcar_todo .

  FIELD-SYMBOLS: <lfa_data> LIKE LINE OF gt_data_alv.
  LOOP AT gt_data_alv ASSIGNING <lfa_data>." INDEX ROW.
    CLEAR <lfa_data>-check.
  ENDLOOP.
  o_alv->refresh( ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DESCARGAR
*&---------------------------------------------------------------------*
FORM f_descargar .

  LOOP AT gt_data_alv ASSIGNING <ls_data_alv>." INDEX ROW.
    IF <ls_data_alv>-check = 'X'.
      READ TABLE gt_data ASSIGNING <ls_data_desc>
        WITH KEY bukrs = <ls_data_alv>-bukrs
                 vbeln = <ls_data_alv>-vbeln.
*** Descarga pdf
      CLEAR v_url.
      v_url = <ls_data_desc>-archivopdf.
      PERFORM f_getcdata USING v_url 'pdf'.
*** Descarga xml
      CLEAR v_url.
      v_url = <ls_data_desc>-archivoxml.
      PERFORM f_getcdata USING v_url 'xml'.
    ENDIF.
  ENDLOOP.

  PERFORM f_ventana_log .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_getcdata
*&---------------------------------------------------------------------*
FORM f_getcdata  USING v_url
                       v_tipo.
*
*  TYPES: BEGIN OF TY_STRING,
*           DATA TYPE STRING,
*         END OF TY_STRING.
*
*
*  DATA: TAB_DETAIL   TYPE STANDARD TABLE OF TY_STRING,
*        I_TAB_DETAIL LIKE LINE OF  TAB_DETAIL OCCURS 0 WITH HEADER LINE,
*        FILENAME     TYPE STRING,
*        WA_STRING    TYPE TY_STRING,
*        HTTP_CLIENT  TYPE REF TO IF_HTTP_CLIENT,
*        PATH         TYPE STRING,
*        L_XSTRING    TYPE XSTRING,
*        W_RESULT     TYPE STRING.
*
*** Reemplaza por el sitio sin SSL
  REPLACE ALL OCCURRENCES OF 'https' IN v_url WITH 'http'.

**** Ruta de salida
  DATA: v_dp           TYPE c LENGTH 255,
        v_absolute_uri TYPE c LENGTH 255,
        v_ext          TYPE string.

  CLEAR: v_dp, v_absolute_uri, v_ext.

  v_absolute_uri = v_url.

  CONCATENATE p_path <ls_data_alv>-bukrs      '_'
                     <ls_data_alv>-vbeln      '_'
                     <ls_data_alv>-fkdat+0(4) '-('
                     <ls_data_alv>-uuid      ').'
                     v_tipo
    INTO v_dp.

  CALL FUNCTION 'HTTP_GET_FILE'
    EXPORTING
      absolute_uri          = v_absolute_uri
      document_path         = v_dp
    EXCEPTIONS
      connect_failed        = 1
      timeout               = 2
      internal_error        = 3
      document_error        = 4
      tcpip_error           = 5
      system_failure        = 6
      communication_failure = 7
      OTHERS                = 8.

  v_ext = v_tipo.
  TRANSLATE v_ext TO UPPER CASE.

  CONCATENATE v_ext 'de la factura' <ls_data_alv>-vbeln 'descargado.'
  INTO i_log_desc-msg1 SEPARATED BY space.
  APPEND i_log_desc.

*  CLEAR: HTTP_CLIENT, PATH.
*  PATH = V_URL.
*
**** Abre la conexion
*  CALL METHOD CL_HTTP_CLIENT=>CREATE_BY_URL
*    EXPORTING
*      URL                = PATH
*    IMPORTING
*      CLIENT             = HTTP_CLIENT
*    EXCEPTIONS
*      ARGUMENT_NOT_FOUND = 1
*      PLUGIN_NOT_ACTIVE  = 2
*      INTERNAL_ERROR     = 3
*      OTHERS             = 4.
*
*  CHECK HTTP_CLIENT IS NOT INITIAL.
*
**** Envia el request
*  CALL METHOD HTTP_CLIENT->SEND
*    EXCEPTIONS
*      HTTP_COMMUNICATION_FAILURE = 1
*      HTTP_INVALID_STATE         = 2.
*  IF SY-SUBRC NE 0.
*    MESSAGE E000(ZBH) WITH 'Error sending message'
*    RAISING COMMUNICATION_ERROR.
*  ENDIF.
*
**** Recibe respuesta
*  CALL METHOD HTTP_CLIENT->RECEIVE
*    EXCEPTIONS
*      HTTP_COMMUNICATION_FAILURE = 1
*      HTTP_INVALID_STATE         = 2
*      HTTP_PROCESSING_FAILED     = 3.
*
*  IF SY-SUBRC NE 0.
*  ENDIF.
*
**** Descarga la respuesta a un archivo
*  W_RESULT = HTTP_CLIENT->RESPONSE->GET_CDATA( ).
*  WA_STRING-DATA = W_RESULT.
*  APPEND WA_STRING TO TAB_DETAIL.
*

*** Descarga xml
*    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
*      EXPORTING
*        FILENAME = FILENAME
*        FILETYPE = 'ASC'
*      CHANGING
*        DATA_TAB = TAB_DETAIL.
*  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_VENTANA_LOG
*&---------------------------------------------------------------------*
FORM f_ventana_log .

  DATA: i_tsmesg TYPE tsmesg OCCURS 0,
        i_xx     TYPE LINE OF tsmesg,
        gt_mesg  TYPE  tsmesg,
        ls_mesg  TYPE  smesg.

  CLEAR:    i_tsmesg.
  REFRESH:  i_tsmesg.



  LOOP AT i_log_desc.
    ls_mesg-arbgb = '00'.
    ls_mesg-txtnr = '001'.
    ls_mesg-zeile = sy-tabix.
    IF i_log_desc-msg1+0(1) = 'D'.
      ls_mesg-msgty = 'W'.
    ELSE.
      ls_mesg-msgty = 'I'.
    ENDIF.
    ls_mesg-msgv1 = i_log_desc-msg1.
    ls_mesg-msgv2 = i_log_desc-msg2.
    APPEND ls_mesg TO gt_mesg.
  ENDLOOP.


  CALL FUNCTION 'FB_MESSAGES_DISPLAY_POPUP'
    EXPORTING
      it_smesg        = gt_mesg
      id_send_if_one  = abap_true
    EXCEPTIONS
      no_messages     = 1
      popup_cancelled = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM f_desmarcar_todo.

ENDFORM.                    " F_VENTANA_LOG

*&---------------------------------------------------------------------*
*& Form f_solicitud_canc_cons
*&---------------------------------------------------------------------*
FORM f_solicitud_canc_cons USING v_tipo.


  IF v_tipo = '0'.

    CALL FUNCTION 'ZCANCELACION_CFDI'
      EXPORTING
        titulo = 'Motivo de cancelación CFDI'
      IMPORTING
        motivo = v_motivo
        uuid   = v_uuid_sust.

  ENDIF.

  IF v_tipo = '0' AND v_motivo IS INITIAL.
    MESSAGE e001(00) WITH 'Es necesario indicar el motivo'.
    EXIT.
  ENDIF.

*** Valores de usuario y contraseña
  CLEAR:   i_output_cons_canc, i_zpac_datos_logon.
  REFRESH: i_output_cons_canc, i_zpac_datos_logon.

  SELECT *
    FROM zpac_datos_logon
    INTO TABLE i_zpac_datos_logon
    WHERE bukrs = <ls_data_alv>-bukrs.

  READ TABLE i_zpac_datos_logon INDEX 1.
  MOVE i_zpac_datos_logon-user_pac        TO i_output_cons_canc-usuario.
  MOVE i_zpac_datos_logon-password_pac    TO i_output_cons_canc-contrasena.
  DATA: v_uuid_upper TYPE char36.
  CLEAR v_uuid_upper.
  v_uuid_upper = <ls_data_desc>-uuid.
  TRANSLATE v_uuid_upper TO UPPER CASE.
  i_output_cons_canc-uuid                 = v_uuid_upper.

  DATA: v_rfc_receptor TYPE stcd1.
  CLEAR v_rfc_receptor.

  v_rfc_receptor = <ls_data_desc>-stcd1.
  IF v_rfc_receptor IS INITIAL.
    SELECT SINGLE stcd1
      FROM kna1
      INTO v_rfc_receptor
      WHERE kunnr = <ls_data_alv>-kunag.
    IF v_rfc_receptor IS INITIAL.
      SELECT SINGLE stcd3
        FROM kna1
        INTO v_rfc_receptor
        WHERE kunnr = <ls_data_alv>-kunag.
    ENDIF.
  ENDIF.

  i_output_cons_canc-rfc_receptor         = v_rfc_receptor.
  i_output_cons_canc-motivo               = v_motivo.
  IF v_uuid_sust = '00000000000000000000000000000000'.
    i_output_cons_canc-uuid_sustitucion     = ''.
  ELSE.
    i_output_cons_canc-uuid_sustitucion     = v_uuid_sust.
  ENDIF.
  i_output_cons_canc-uuid_sustitucion     = v_uuid_sust.
  i_output_cons_canc-total                = <ls_data_desc>-netwr.


*** Este campo va vacio por ser solicitud de cancleacion
  IF v_tipo = '0'.
    MOVE space TO i_output_cons_canc-consulta_ocancelacion.
  ELSE.
    MOVE '1' TO i_output_cons_canc-consulta_ocancelacion.
  ENDIF.


*******************************************************************************************
***                               Nodo para envio correo                                ***
*******************************************************************************************
  CLEAR: v_respondera, v_asunto, v_mensaje, v_para, v_cc, v_bcc, v_archadj.


*** Definir a quien se enviara el correo informando que hubo una
*** solicitude de cancelacion

*** Asunto


*** Mensaje en formato HTML
  IF v_tipo = '0'.
    v_asunto = 'Solicitud de cancelación'.
    CONCATENATE v_mensaje '<body aria-readonly="false">Se solicitó al SAT la cancelacion de la factura:<br />' INTO v_mensaje.
  ELSEIF  v_tipo = '1'.
    v_asunto = 'Consulta de status'.
    CONCATENATE v_mensaje '<body aria-readonly="false">Se consultó el status de la factura:<br />' INTO v_mensaje.
  ENDIF.

  CONCATENATE v_mensaje '<br />' INTO v_mensaje.
  CONCATENATE v_mensaje <ls_data_desc>-vbeln INTO v_mensaje.

  CONCATENATE v_mensaje '</body>' INTO v_mensaje.

*** Opcionales

  IF v_para IS NOT INITIAL.
  ENDIF.

  DATA: zcorreo TYPE zdt_s4_consultay_cancelacion_2 OCCURS 0 WITH HEADER LINE.
*
  MOVE v_respondera TO zcorreo-responder_a.
  MOVE v_asunto     TO zcorreo-asunto.
  MOVE v_mensaje    TO zcorreo-mensaje.
  MOVE v_para       TO zcorreo-para.
  MOVE v_cc         TO zcorreo-cc.
  MOVE v_bcc        TO zcorreo-bcc.
  MOVE '0'          TO zcorreo-archivoadjunto.

  MOVE zcorreo TO i_output_cons_canc-correo.

  CLEAR i_out_cons_canc.

  i_out_cons_canc-mt_s4_consultay_cancelacion_re = i_output_cons_canc.

  PERFORM f_timbrado_canc_cons.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_timbrado_canc_cons
*&---------------------------------------------------------------------*
FORM f_timbrado_canc_cons .


*** Crea el objeto del proxy de la factura
  TRY.
      CREATE OBJECT l_proxy_serv_canc_cons.

    CATCH cx_ai_system_fault INTO lr_ai_system_fault.
      l_errortext = lr_ai_system_fault->errortext.
      l_errorcode = lr_ai_system_fault->code.
  ENDTRY.

*** Con este codigo se habilita la recuperacion del ACK
  IF NOT c_ack_enabled IS INITIAL.
    TRY.
        lr_async_messaging ?= l_proxy_serv_canc_cons->get_protocol( if_wsprotocol=>async_messaging ).
      CATCH cx_ai_system_fault INTO  lr_ai_system_fault.
        lr_async_messaging->set_acknowledgment_requested(
        if_wsprotocol_async_messaging=>co_complete_acknowledgment ).
    ENDTRY.
  ENDIF.

  TRY.
      lr_message_id_protocol ?= l_proxy_serv_canc_cons->get_protocol( if_wsprotocol=>message_id ).
    CATCH cx_ai_system_fault INTO  lr_ai_system_fault.
  ENDTRY.

*** Manda llamar el proxy
  TRY.
      TRY.
          CALL METHOD l_proxy_serv_canc_cons->si_os_s4_consultay_cancelacion
            EXPORTING
              output = i_out_cons_canc
            IMPORTING
              input  = zmt_s4_cfditimbrado_resp.

        CATCH cx_ai_system_fault INTO lr_ai_system_fault.
          l_errortext = lr_ai_system_fault->errortext.
          l_errorcode = lr_ai_system_fault->code.
      ENDTRY.
    CATCH cx_ai_system_fault INTO lr_ai_system_fault.
      l_errortext = lr_ai_system_fault->errortext.
      l_errorcode = lr_ai_system_fault->code.

  ENDTRY.

  COMMIT WORK.

  IF l_errortext IS NOT INITIAL.

    DATA: p_ruta_fac TYPE string.

    CONCATENATE 'C:\temp\error_llamada_proxy'
                    '.html'
                    INTO p_ruta_fac.

    CLEAR: it_xml_err.
    REFRESH: it_xml_err.

    it_xml_err = l_errortext.
    APPEND it_xml_err.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = p_ruta_fac
        filetype                = 'ASC'
        codepage                = '4110'
      TABLES
        data_tab                = it_xml_err
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
    IF sy-subrc <> 0.

    ENDIF.

  ENDIF.


*** Leemos el ID del mensaje

  l_message_id = lr_message_id_protocol->get_message_id( ).

*** Comprobacion del estado acknowledgement

  IF NOT c_ack_enabled IS INITIAL.

* El do sirve para esperar en lo que devuelve el ACK
    DO 20 TIMES.
      l_cnt = l_cnt + 1.
      TRY.
*** Recuperamos el código de ACK

          lr_ack = cl_proxy_access=>get_acknowledgment( l_message_id ).
          ls_status = lr_ack->get_status( ).

        CATCH cx_ai_system_fault INTO lr_ai_system_fault .
*** En caso de que aun no llegue el mensaje de ACK
          IF lr_ai_system_fault->code = cx_xms_syserr_proxy=>co_id_no_ack_arrived_yet.
            sy-subrc = 1.
          ELSE.
            l_errortext = lr_ai_system_fault->errortext.
            l_errorcode = lr_ai_system_fault->code.
          ENDIF.
      ENDTRY .

      IF ls_status IS INITIAL.
        EXIT.
      ENDIF.

*** Esperamos un Segundo para obtener la respuesta del ACK en caso de aun no llegue
      WAIT UP TO 1 SECONDS.
    ENDDO.
  ENDIF.


  IF zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-message IS NOT INITIAL.
    PERFORM f_procesa_cons_canc.
  ENDIF.
*
*PERFORM F_VENTANA_LOG .
*
**** Actualiza la tabla del monitor
*  I_ZSD_CFDI_TIMBRE-SEMAFORO = 'C'.
*  I_ZSD_CFDI_TIMBRE-COMENTARIO = 'Cancellation requested.'.
*
*  MODIFY ZSD_CFDI_TIMBRE FROM I_ZSD_CFDI_TIMBRE.
*  COMMIT WORK AND WAIT.
*  WAIT UP TO 1 SECONDS.
*  PERFORM F_GET_DATA.
*  PERFORM F_PROCESS_DATA.
*
*  O_ALV->REFRESH( REFRESH_MODE = IF_SALV_C_REFRESH=>FULL ).
*
*
*
*
*
*
*
*
**    PERFORM F_PROCESA_RESPUESTA_TIMBRADO.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_procesa_cons_canc
*&---------------------------------------------------------------------*
FORM f_procesa_cons_canc .

  CLEAR: v_result, v_code, v_message, v_uuid, v_urlxml, v_urlqr,
           v_urlpdf, v_archivo, v_estatus.

  v_result    = zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-result.
  v_code      = zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-code.
  v_message   = zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-message.
  v_uuid      = zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-uuid.
  v_urlxml    = zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-url_xml.
  v_urlpdf    = zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-url_pdf.
  v_urlqr     = zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-url_qr.
  v_archivo   = zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-archivo.
  v_estatus   = zmt_s4_cfditimbrado_resp-mt_s4_consultay_cancelacion_re-estatus.


  CLEAR:   i_zsd_cfdi_timbre.
  REFRESH: i_zsd_cfdi_timbre.

  SELECT * FROM zsd_cfdi_timbre
    INTO TABLE i_zsd_cfdi_timbre
    WHERE bukrs = <ls_data_desc>-bukrs
    AND   vbeln = <ls_data_desc>-vbeln.

  READ TABLE i_zsd_cfdi_timbre INDEX 1.
  i_zsd_cfdi_timbre-result_pac       = v_result.
  i_zsd_cfdi_timbre-code             = v_code.
  i_zsd_cfdi_timbre-message          = v_message.
  i_zsd_cfdi_timbre-status           = v_message.
  i_zsd_cfdi_timbre-comentario       = v_message.
  i_zsd_cfdi_timbre-uuid_canc        = v_uuid.
  i_zsd_cfdi_timbre-archivoxml_canc  = v_urlxml.
  i_zsd_cfdi_timbre-archivopdf_canc  = v_urlpdf.
  i_zsd_cfdi_timbre-stat_canc        = v_estatus.
  IF v_motivo IS NOT INITIAL.
    i_zsd_cfdi_timbre-mot_canc         = v_motivo.
  ENDIF.
  i_zsd_cfdi_timbre-semaforo        = 'S'.
  MODIFY i_zsd_cfdi_timbre INDEX 1.
  MODIFY zsd_cfdi_timbre FROM i_zsd_cfdi_timbre.
  COMMIT WORK AND WAIT.

  DATA: v_motivo_vf11 LIKE v_motivo.
  CLEAR v_motivo_vf11.
  v_motivo_vf11 = v_motivo.
  IF v_motivo_vf11 IS INITIAL.
    v_motivo_vf11 = i_zsd_cfdi_timbre-mot_canc.
  ENDIF.

  IF v_estatus = 'V' OR
     v_estatus = 'A' OR
     v_estatus = 'S'.
    IF v_motivo_vf11 = '02' OR
       v_motivo_vf11 = '03'.
      DATA: i_return_canc  TYPE bapireturn1 OCCURS 0 WITH HEADER LINE,
            i_success_canc TYPE bapivbrksuccess OCCURS 0 WITH HEADER LINE.

      CLEAR: i_return_canc, i_success_canc.
      REFRESH: i_return_canc, i_success_canc.

      CALL FUNCTION 'BAPI_BILLINGDOC_CANCEL1'
        EXPORTING
          billingdocument = <ls_data_desc>-vbeln
          billingdate     = sy-datum
        TABLES
          return          = i_return_canc
          success         = i_success_canc.

    ENDIF.          .
  ENDIF.

ENDFORM.
