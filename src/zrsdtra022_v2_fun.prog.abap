*&---------------------------------------------------------------------*
*& Include          ZRSDTRA022_V2_FUN
*&---------------------------------------------------------------------*

**-----     Especificaciones de Cálculo
*TOP-OF-PAGE.
*  vkorg = vkorg_p+3(4).
*  CASE vkorg.
*    WHEN 'AZ01'.
*      soc = 'INGENIO DE HUIXTLA S.A. DE C.V.'.
*    WHEN 'AZ02'.
*      soc = 'INGENIO SANTA CLARA S.A. DE C.V.'.
*  ENDCASE.
*
*  ULINE.
*  WRITE:/05 'Fecha:', sy-datum, sy-uname,
*         50 soc,
*         130 'Pagina:', sy-pagno,
*         147 'ZRSDTRA019'.
*  WRITE:/50 'DECLARACIÓN DE EMBARQUES'.
*  ULINE.
*
*  WRITE:/ syst-vline,
*          'Num',
*          6 syst-vline,
*          'Fecha Entr',
*          19 syst-vline,
*          'Ctro',
*          26 syst-vline,
*          'Nombre del Centro',
*          59 syst-vline,
*          'P.E.',
*          66 syst-vline,
*          'Nombre Puesto Expedición',
*          99 sy-vline,
*          'Cte.',
*          106 syst-vline,
*          'Nombre',
*          144 syst-vline,
*          'Destino',
*          167 syst-vline,
*          'Entrega',
*          180 syst-vline,
*          'Cantidad',
*          202 syst-vline,
*          'Valoración',
*          226 syst-vline.

FORM get_data.
  DATA: vl_name  LIKE thead-tdname,
        vl_lines TYPE STANDARD TABLE OF tline.

* Busca las entregas que cumplan con los parámetros dados de
* Organización de Ventas (obligatoria)
* Fecha de entrega (Obligatori)
* Cliente/solicitante, centro y/o material
  SELECT DISTINCT likp~vkorg, likp~vstel, likp~vbeln, likp~kunag,
                  likp~kunnr, likp~erdat, likp~bolnr,
                  lips~posnr, lips~ntgew, lips~werks, lips~matnr,
                  concat_with_space( k~ort02 , k~regio, 1 ) AS entrega,
                  k~ort02 AS ciudad,  k~regio AS estado,k~name1,
                  t~txtmd, tt~vtext
  FROM  likp INNER JOIN lips
  ON likp~vbeln = lips~vbeln
  INNER JOIN kna1 AS k
  ON k~kunnr = likp~kunnr
  INNER JOIN t001w_biw AS t
  ON t~werks = lips~werks AND t~spras = 'S'
  INNER JOIN tvstt AS tt
  ON tt~vstel = likp~vstel
  WHERE  likp~vkorg IN @vkorg_p     " Organización de Ventas
  AND    likp~kunag IN @kunag_p     " Solicitante
  AND    likp~erdat IN @erdat_p     " Fecha de entrega
  AND    lips~werks IN @werks_p     " Centro
  AND    lips~matnr IN @matnr_p    " material
  AND    likp~lfart NE 'NL'        "Entr.reaprovisionam. excluidos.
  INTO CORRESPONDING FIELDS OF TABLE @rec.

  SORT rec BY vbeln.

  DELETE ADJACENT DUPLICATES FROM rec COMPARING vbeln.
  SORT rec BY erdat.

  SELECT vbelv,vbeln, vbtyp_n, vbtyp_v, rfmng, rfwrt
    INTO TABLE @DATA(it_vbfa)
  FROM vbfa
  FOR ALL ENTRIES IN @rec
  WHERE vbelv = @rec-vbeln
        AND   vbtyp_n IN ('M', 'R').

  SELECT vbelv,vbeln, posnn, vbtyp_n, vbtyp_v, rfmng, rfwrt
   INTO TABLE @DATA(it_vbfac)
  FROM vbfa
  FOR ALL ENTRIES IN @rec
  WHERE vbeln = @rec-vbeln
        AND   vbtyp_v = 'C'.

  SELECT vbelv,vbeln,  vbtyp_n, vbtyp_v, rfmng, rfwrt
   INTO TABLE @DATA(it_vbfav)
  FROM vbfa
  FOR ALL ENTRIES IN @it_vbfac
  WHERE vbelv = @it_vbfac-vbelv
        AND   vbtyp_n IN ('M', 'R').




  LOOP AT rec INTO DATA(wa_rec).

    READ TABLE it_vbfa INTO DATA(wa_vbfa) WITH KEY vbelv = wa_rec-vbeln vbtyp_n = 'M'.
    IF sy-subrc EQ 0.
      wa_rec-rfmng = wa_vbfa-rfmng.
      wa_rec-rfwrt = wa_vbfa-rfwrt.
    ELSE.
      "Hacemos la misma consulta pero con estatus 'R'.
      READ TABLE it_vbfa INTO DATA(wa_vbfa1) WITH KEY vbelv = wa_rec-vbeln vbtyp_n = 'R'.

      READ TABLE it_vbfac INTO DATA(wa_vbfac) WITH KEY vbeln = wa_rec-vbeln vbtyp_v = 'C'.
      "si la posición es 10 pero cantidad es 0, es una entrega particionada.
      IF sy-subrc EQ 0.
        IF wa_vbfac-posnn = '000010' AND wa_vbfac-rfmng EQ 0.
          READ TABLE it_vbfav INTO DATA(wa_vbfav) WITH KEY vbelv = wa_vbfac-vbelv vbtyp_n = 'M'.
          IF sy-subrc EQ 0.
            wa_rec-rfmng = wa_vbfav-rfmng.
            precio = wa_vbfav-rfwrt / wa_vbfav-rfmng.
            wa_rec-rfwrt = precio * wa_vbfav-rfmng.
          ENDIF.
        ELSE. "sino, se busca la entrega con el tipo de pedido y entrega en conjunto
          READ TABLE it_vbfav INTO DATA(wa_vbfav1) WITH KEY vbelv = wa_vbfac-vbelv vbeln = wa_vbfa1-vbeln.
          IF sy-subrc EQ 0.
            wa_rec-rfmng = wa_vbfav1-rfmng.
            precio = wa_vbfav1-rfwrt / wa_vbfav1-rfmng.
            wa_rec-rfwrt = precio * wa_vbfav1-rfmng.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    "Lectura de Carta Porte en la Entrega.
    vl_name = wa_rec-vbeln.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client                  = sy-mandt
        id                      = 'ZS13'
        language                = sy-langu
        name                    = vl_name
        object                  = 'VBBK'
      TABLES
        lines                   = vl_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc EQ 0.
      READ TABLE vl_lines INTO DATA(wa_carta) INDEX 1.
      IF sy-subrc EQ 0.
        wa_rec-carta = wa_carta-tdline.
      ENDIF.
    ENDIF.



    MODIFY rec FROM wa_rec TRANSPORTING rfmng rfwrt carta WHERE vbeln = wa_rec-vbeln.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fieldcat .
  CLEAR wa_fieldcat.
  REFRESH gt_fieldcat.

  wa_fieldcat-fieldname = 'ERDAT'.
  wa_fieldcat-seltext_m = 'Fecha Entrega'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-seltext_m = 'Centro'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'TXTMD'.
  wa_fieldcat-seltext_m = 'Descripció'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VSTEL'.
  wa_fieldcat-seltext_m = 'Puesto Expedición'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VTEXT'.
  wa_fieldcat-seltext_m = 'Descripción'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'KUNNR'.
  wa_fieldcat-seltext_m = 'Cliente/Solicitante'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-seltext_m = 'Nombre Cliente'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ENTREGA'.
  wa_fieldcat-seltext_m = 'Destino'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'CARTA'.
  wa_fieldcat-seltext_m = 'Carta Porte'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VBELN'.
  wa_fieldcat-seltext_m = 'Entrega'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'RFMNG'.
  wa_fieldcat-seltext_m = 'Cantidad'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'RFWRT'.
  wa_fieldcat-seltext_m = 'Valor Referenciado'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .
  SORT rec BY erdat.

  lf_layout-zebra = 'X'.
  lf_layout-colwidth_optimize = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK           = ' '
*     I_BYPASSING_BUFFER          = ' '
*     I_BUFFER_ACTIVE             = ' '
      i_callback_program          = sy-repid
      i_callback_pf_status_set    = 'ZPFSTATUS'
      i_callback_user_command     = 'ZCOMMAND'
*     I_CALLBACK_TOP_OF_PAGE      = 'HTML_TOP_OF_PAGE'
      i_callback_html_top_of_page = 'HTML_TOP_OF_PAGE'
*     I_CALLBACK_HTML_END_OF_LIST = ' '
*     I_STRUCTURE_NAME            =
*     I_BACKGROUND_ID             = ' '
*     I_GRID_TITLE                =
*     I_GRID_SETTINGS             =
      is_layout                   = lf_layout
      it_fieldcat                 = gt_fieldcat
    TABLES
      t_outtab                    = rec
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.


ENDFORM.

FORM zpfstatus USING p_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTANDARD_FULLSCREEN'.
ENDFORM.

FORM zcommand  USING p_ucomm LIKE sy-ucomm
              p_selfield TYPE slis_selfield.

  CASE p_ucomm.
    WHEN '&ZEXCEL'.
      PERFORM download_excel.
  ENDCASE.
ENDFORM.

FORM download_excel.
  DATA: lt_bintab   TYPE STANDARD TABLE OF solix,
        lv_size     TYPE i,
        lv_filename TYPE string,
        v_path      TYPE string,   " directorio del archivo
        v_fullpath  TYPE string.   " ruta del arhivo completa



  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
       window_title              = 'Guardar Documento...'
       file_filter               = '*.XLS'
       default_extension         = 'xls'
       default_file_name         = 'ZDATOS_EXCEL'
       prompt_on_overwrite       = 'X'
    CHANGING
      filename                  = lv_filename
      path                      = v_path
      fullpath                  = v_fullpath
*      user_action               =
*      file_encoding             =
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5
  ).
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


* Get New Instance for ALV Table Object
  cl_salv_table=>factory(
    IMPORTING
      r_salv_table   = DATA(lo_alv)
    CHANGING
      t_table        = rec ).

* Convert ALV Table Object to XML
  DATA(lv_xml) = lo_alv->to_xml( xml_type = '02' ).

* Convert XTRING to Binary
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = lv_xml
    IMPORTING
      output_length = lv_size
    TABLES
      binary_tab    = lt_bintab.

  "lv_filename = p_fname.

* Download File
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize            = lv_size
      filename                = lv_filename
      filetype                = 'BIN'
    TABLES
      data_tab                = lt_bintab
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
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

FORM html_top_of_page USING document TYPE REF TO cl_dd_document.
  DATA: text TYPE sdydo_text_element.
  CALL METHOD document->add_gap
    EXPORTING
      width = 100.
  text =  'Reporte de Entregas realizadas para pagos de Seguros'.

  CALL METHOD document->add_text
    EXPORTING
      text      = text
      sap_style = 'HEADING'.
  CALL METHOD document->new_line.
  CALL METHOD document->new_line.
  CALL METHOD document->new_line.
  text = 'Usuario Genero : '.
  CALL METHOD document->add_text
    EXPORTING
      text         = text
      sap_emphasis = 'Strong'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 6.
  text = sy-uname.
  CALL METHOD document->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 50.
  text = 'Fecha : '.
  CALL METHOD document->add_text
    EXPORTING
      text         = text
      sap_emphasis = 'Strong'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 6.
  text = sy-datum.
  CALL METHOD document->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 50.
  text = 'Hora : '.
  CALL METHOD document->add_text
    EXPORTING
      text         = text
      sap_emphasis = 'Strong'.

  CALL METHOD document->add_gap
    EXPORTING
      width = 6.
  text = sy-uzeit.
  CALL METHOD document->add_text
    EXPORTING
      text      = text
      sap_style = 'Key'.
  CALL METHOD document->new_line.
  CALL METHOD document->new_line.
ENDFORM.                    "HTML_TOP_OF_PAGE
