*&---------------------------------------------------------------------*
*& Include ztable_load_fun
*&---------------------------------------------------------------------*

FORM load_xls USING p_wa_xls_archivo
 CHANGING p_ok .

  DATA vl_filename TYPE rlgrap-filename.
  DATA: lo_uploader TYPE REF TO zcl_upload_xls.




  REFRESH it_outtable.
  p_ok = abap_false.

  vl_filename = p_wa_xls_archivo .
  CREATE OBJECT lo_uploader.
  lo_uploader->max_rows = 2000.
  lo_uploader->filename = vl_filename.
  lo_uploader->header_rows_count = 1.
  lo_uploader->upload( CHANGING ct_data = it_outtable ).

  IF sy-subrc EQ 0.

    LOOP AT it_outtable ASSIGNING <t>.
      ASSIGN COMPONENT 'VBELN' OF STRUCTURE <t> to <fd>.
      call FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fd>
        IMPORTING
          output = <fd>
        .
    ENDLOOP.

    p_ok = abap_true.
  ENDIF.
ENDFORM.

FORM update_cfdi.

  SELECT mandt,bukrs, vbeln, gjahr, kunag,
  stcd1, rfc_emi, netwr, mwsbk, kurrf,
  waers, forma_pago, metodo_pago, erdat,
  erzet, fkart, status, fksto, archivoxml, archivopdf,
  uuid, fec_sello, xml, pdf, semaforo, uuid_canc,
  stat_canc, archivoxml_canc, archivopdf_canc, xml_canc,
  pdf_canc, mot_canc, comentario, result_pac,
  code, message, archivo, estatus
  FROM zsd_cfdi_timbre
  FOR ALL ENTRIES IN @it_outtable
  WHERE bukrs = @it_outtable-bukrs AND vbeln = @it_outtable-vbeln
  INTO TABLE @it_zcfdi.
  .

  IF it_zcfdi IS NOT INITIAL.
    LOOP AT it_outtable INTO DATA(wa_data).

      READ TABLE it_zcfdi ASSIGNING <t> WITH KEY bukrs = wa_Data-bukrs vbeln = wa_Data-vbeln.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT 'ARCHIVOPDF' OF STRUCTURE <t> TO <fd>.
        <fd> = wa_data-url.

      ENDIF.

    ENDLOOP.


    TRY.
        MODIFY zsd_cfdi_timbre FROM TABLE it_zcfdi.
        IF sy-subrc EQ 0.
          MESSAGE 'Registros Actualizados con Ruta PDF' TYPE 'S'.
        else.
          MESSAGE 'Error al Actualizar con Ruta PDF' TYPE 'E' DISPLAY LIKE 'S'.
        ENDIF.
      CATCH cx_sql_exception INTO DATA(cx).
          MESSAGE 'Error al Actualizar con Ruta PDF' TYPE 'E' DISPLAY LIKE 'S'.
    ENDTRY.

  ENDIF.


ENDFORM.
