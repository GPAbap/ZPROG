*&---------------------------------------------------------------------*
*& Include znotiex_fun
*&---------------------------------------------------------------------*

FORM get_ordenes.

  SELECT afko~aufnr, afvc~vornr,
          afvv~arbeh, CAST( afvv~fsedd AS CHAR( 10 ) ) AS fsedd,'NOTIFICACION POR FIORI' AS txt_notif,
          CAST( afvv~fsavd AS CHAR( 10 ) ) AS fsavd, CAST( afvv~fsavz AS CHAR( 10 ) ) AS fsavz, afvv~arbeh AS umtr,afvc~ltxa1,
          equi~equnr, eqkt~eqktx
   INTO TABLE @DATA(it_ordenes)
  FROM afko
  INNER JOIN afvc ON afvc~aufpl = afko~aufpl
  INNER JOIN afvv ON afvv~aufpl = afko~aufpl AND afvv~aplzl = afvc~aplzl
  inner join afih on afih~aufnr = afko~aufnr
  inner join equi on equi~equnr = afih~equnr
  inner join eqkt on eqkt~equnr = equi~equnr
  WHERE afko~aufnr IN @so_aufnr
  AND steus EQ 'PM01'.

  SORT it_ordenes BY aufnr vornr.

  LOOP AT it_ordenes ASSIGNING FIELD-SYMBOL(<wa>).
    CONCATENATE <wa>-fsedd+4(2) '/' <wa>-fsedd+6(2) '/' <wa>-fsedd+0(4) INTO <wa>-fsedd.
    CONCATENATE <wa>-fsavd+4(2) '/' <wa>-fsavd+6(2) '/' <wa>-fsavd+0(4) INTO <wa>-fsavd.

    CONCATENATE <wa>-fsavz+0(2) ':' <wa>-fsavz+2(2) ':' <wa>-fsavz+4(2) INTO <wa>-fsavz.

    IF <wa>-arbeh EQ 'STD'.
      <wa>-arbeh = 'HRA'.
    ENDIF.

  ENDLOOP.


  it_layout = VALUE #( FOR ls_ordenes IN it_ordenes INDEX INTO vl_index
                        (
                          aufnr = ls_ordenes-aufnr
                          posnr = ls_ordenes-vornr
                          arbeh = ls_ordenes-arbeh
                          conf_final = 'X'
                          fsedd = ls_ordenes-fsedd
                          txt_notif = ls_ordenes-txt_notif
                          fsavd = ls_ordenes-fsavd
                          fsavz = ls_ordenes-fsavz
                          no_esp_tra_res = 'X'
                          trab_rest = 0
                          arbeh_rest = ls_ordenes-arbeh
                          del_reser_open = 'Cero'
                          ltxa1 = ls_ordenes-ltxa1
                          equnr = ls_ordenes-equnr
                          eqktx = ls_ordenes-eqktx
                        ) ).

ENDFORM.

FORM download_layout.

  PERFORM excel_instantiate.
  gv_filename = p_file.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize         = lv_length
      filename             = gv_filename
      filetype             = 'BIN'
      show_transfer_status = 'X'
    TABLES
      data_tab             = lt_binary_tab.

ENDFORM.

FORM excel_instantiate.

  "create data reference
  GET REFERENCE OF it_layout INTO lr_excel_structure.
  DATA(lo_itab_services) = cl_salv_itab_services=>create_for_table_ref( lr_excel_structure ).
  lo_source_table_descr ?= cl_abap_tabledescr=>describe_by_data_ref( lr_excel_structure  ).

  lo_table_row_descriptor ?= lo_source_table_descr->get_table_line_type( ).

  "excel instantiate
  DATA(lo_tool_xls) = cl_salv_export_tool_ats_xls=>create_for_excel(
                            EXPORTING r_data =  lr_excel_structure  ) .

  "Add columns to sheet
  DATA(lo_config) = lo_tool_xls->configuration( ).

  lo_config->add_column(
      EXPORTING
        header_text          =  |{ TEXT-t01 }|
        field_name           =  'AUFNR'
        display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
      EXPORTING
        header_text          =  |{ TEXT-t02 }|
        field_name           =  'POSNR'
        display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
       EXPORTING
         header_text          =  |{ TEXT-t03 }|
         field_name           =  'POSNR_PARC'
         display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
        EXPORTING
          header_text          =  |{ TEXT-t04 }|
          field_name           =  'EMPLEADO'
          display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
        EXPORTING
          header_text          =  |{ TEXT-t05 }|
          field_name           =  'CLASE_ACTIV'
          display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
        EXPORTING
          header_text          =  |{ TEXT-t06 }|
          field_name           =  'TRAB_REAL'
          display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
       EXPORTING
         header_text          =  |{ TEXT-t07 }|
         field_name           =  'ARBEH'
         display_type         =   if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t08 }|
field_name           =  'CONF_FINAL'
display_type         =   if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t09 }|
field_name           =  'FSEDD'
display_type         =   if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t10 }|
field_name           =  'TXT_NOTIF'
display_type         =   if_salv_bs_model_column=>uie_text_view ).


  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t11 }|
field_name           =  'FSAVD'
display_type         =   if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t12 }|
field_name           =  'FSAVZ'
display_type         =   if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t13 }|
field_name           =  'FECHA_DEFIN'
display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
      EXPORTING
        header_text          =  |{ TEXT-t14 }|
        field_name           =  'HORA_DEFIN'
        display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
    EXPORTING
      header_text          =  |{ TEXT-t15 }|
      field_name           =  'FECHA_DEFINPRE'
      display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t16 }|
field_name           =  'HORA_DEFINPRE'
display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t17 }|
field_name           =  'NO_ESP_TRA_RES'
display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t18 }|
field_name           =  'TRAB_REST'
display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t19 }|
field_name           =  'ARBEH_REST'
display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t20 }|
field_name           =  'DEL_RESER_OPEN'
display_type         =   if_salv_bs_model_column=>uie_text_view ).
  lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t21 }|
field_name           =  'MOTV_DESV'
display_type         =   if_salv_bs_model_column=>uie_text_view ).

lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t22 }|
field_name           =  'LTXA1'
display_type         =   if_salv_bs_model_column=>uie_text_view ).

lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t23 }|
field_name           =  'EQUNR'
display_type         =   if_salv_bs_model_column=>uie_text_view ).


lo_config->add_column(
EXPORTING
header_text          =  |{ TEXT-t24 }|
field_name           =  'EQKTX'
display_type         =   if_salv_bs_model_column=>uie_text_view ).


  "get excel in xstring
  TRY.
      lo_tool_xls->read_result(  IMPORTING content  = lv_content  ).
    CATCH cx_root.
  ENDTRY.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING "
      buffer        = lv_content
    IMPORTING
      output_length = lv_length
    TABLES
      binary_tab    = lt_binary_tab.



ENDFORM.
