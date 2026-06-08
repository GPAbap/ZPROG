*&---------------------------------------------------------------------*
*& Include zco_re_costo_prod_rentab_fun
*&---------------------------------------------------------------------*


FORM handle_user_command USING i_ucomm TYPE salv_de_function.
  PERFORM export_csv.

ENDFORM.

FORM export_csv.

  DATA: gv_line     TYPE string,
        gv_sep      TYPE c LENGTH 1 VALUE ',',
        vl_sap_file TYPE string.

  DATA: dato       TYPE string,
        wgbez60    TYPE string,
        h          TYPE string,
        m          TYPE string,
        chiapas    TYPE string,
        rns_entero TYPE string,
        rns_cortes TYPE string,
        rtc        TYPE string,
        pintado_p  TYPE string,
        hidratado  TYPE string,
        rhp_cortes TYPE string,
        limpiezas  TYPE string.

  FIELD-SYMBOLS: <fs_st>   TYPE any,
                 <fs_line> TYPE any.

  CASE sy-sysid.
    WHEN 'SPD'.
      vl_sap_file = sap_file_dev.
    WHEN 'SPQ'.
      vl_sap_file = sap_file_qas.
    WHEN 'SPP'.
      vl_sap_file = sap_file_pro.
  ENDCASE.

  CONCATENATE vl_sap_file 'export_' so_fecha-low '.csv' INTO vl_sap_file.
  OPEN DATASET vl_sap_file
  FOR OUTPUT IN TEXT MODE ENCODING UTF-8.

  IF sy-subrc <> 0.
    WRITE: / 'No se pudo abrir el archivo:', vl_sap_file.
    MESSAGE 'No se pudo generar el archivo. Revise permisos de R/W' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  "------------------------------------------------------------
  " 3. Escribir encabezado CSV
  "------------------------------------------------------------
  CLEAR gv_line.
  LOOP AT lt_fcat INTO ls_fcat WHERE fieldname NE 'TABCOLOR' .
    dato = ls_fcat-coltext.
    CONCATENATE gv_line dato INTO gv_line SEPARATED BY gv_sep.
  ENDLOOP.

  gv_line = gv_line+1.

  TRANSFER gv_line TO vl_sap_file.

  "------------------------------------------------------------
  " 4. Escribir datos
  "------------------------------------------------------------
  LOOP AT <fs_outtable> ASSIGNING <fs_st>.
    CLEAR gv_line.

    LOOP AT lt_fcat INTO ls_fcat WHERE fieldname NE 'TABCOLOR' .

      ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_st> TO <fs_line>.
      dato = <fs_line>.
      CONCATENATE gv_line dato  INTO gv_line SEPARATED BY gv_sep.

    ENDLOOP.
    gv_line = gv_line+1.

    TRANSFER gv_line TO vl_sap_file.


  ENDLOOP.
  CLOSE DATASET vl_sap_file.
ENDFORM.
FORM build_fieldcatalog.

  DATA: campocu       TYPE string,
        ncolumnas     TYPE i,
        nmeses        TYPE i,
        vl_date       TYPE dats,
        vl_name_month TYPE zfcltx,
        vl_poper      TYPE poper.

  ncolumnas = 0.
  nmeses = 0.

  "Columna de Conceptos
  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'WGBEZ60'.
  ls_fcat-outputlen = '40'.
  ls_fcat-coltext   = 'description'.
  ls_fcat-fix_column = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  CALL FUNCTION 'ZCO_GET_MONTHS_BY_DATE'
    EXPORTING
      p_fecha = so_fecha
    TABLES
      nmeses  = gv_tt_meses.


  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    ncolumnas = ncolumnas + 1.
    ls_fcat-fieldname = wa_meses-zmonth.
    ls_fcat-col_pos   = ncolumnas.
    ls_fcat-ref_table = 'MSEG'.
    ls_fcat-ref_field = 'MENGE'.
    ls_fcat-coltext   = 'H/xalapa'.
    ls_fcat-decimals = '3'.
    ls_fcat-outputlen = '22'.
    ls_fcat-do_sum    = 'X'.
    APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.
  ENDLOOP.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'H'.
  ls_fcat-coltext   = 'H'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '10'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'M'.
  ls_fcat-coltext   = 'M'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '10'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'CHIAPAS'.
  ls_fcat-coltext   = 'CHIAPAS'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '11'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'RNS_ENTERO'.
  ls_fcat-coltext   = 'RNS ENTERO'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '11'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'RNS_CORTES'.
  ls_fcat-coltext   = 'RNS CORTES'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '11'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'RTC'.
  ls_fcat-coltext   = 'RTC'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '10'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'PINTADO_P'.
  ls_fcat-coltext   = 'PINTADO PESADO'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '10'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'HIDRATADO'.
  ls_fcat-coltext   = 'HIDRATADO'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '10'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'RHP_CORTES'.
  ls_fcat-coltext   = 'RHP CORTES'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '10'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'LIMPIEZAS'.
  ls_fcat-coltext   = 'LIMPIEZAS'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '10'.
*  ls_fcat-no_out = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'TABCOLOR'.
  ls_fcat-ref_field = 'COLTAB'.
  ls_fcat-ref_table = 'CALENDAR_TYPE'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.


ENDFORM.

FORM build_dinamic_table.

*  "se construyen las columnas de acuerdo a los lotes
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = lt_fcat
    IMPORTING
      ep_table        = lo_tabla.
*
  ASSIGN lo_tabla->* TO <fs_outtable>.

  lv_fname = 'TABCOLOR'.



ENDFORM.

FORM get_ordenes_fin USING p_tipo TYPE string.

  CREATE OBJECT obj_engorda.


  DATA: vl_fechas  TYPE RANGE OF afko-gltri, vl_wfechas LIKE LINE OF vl_fechas,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat
        .
  DATA: vl_rgwerks  TYPE RANGE OF t001w-werks,
        vl_wrgwerks LIKE LINE OF vl_rgwerks.

  DATA lv_fecha_inicial TYPE dats.
  DATA cadena TYPE string.
  DATA lv_fecha TYPE dats.
  DATA vl_gjahr TYPE gjahr.
  DATA vl_periodo TYPE co_perio.


  lv_fecha = so_fecha-low.

  vl_gjahr = lv_fecha+0(4).

  vl_periodo =  |{ lv_fecha+4(2) ALPHA = IN }|.


  IF vl_periodo = '001'.
    vl_gjahr = vl_gjahr - 1.
  ENDIF.

  IF vl_periodo = '001'.
    vl_periodo = '012'.
  ELSE.
    vl_periodo = vl_periodo - 1.
  ENDIF.


  CONCATENATE vl_gjahr vl_periodo+1(2) '01' INTO cadena.
  lv_fecha_inicial = cadena.

  DATA(lv_fecha_mes) =
    cl_reca_date=>set_to_end_of_month( lv_fecha_inicial ).



  IF p_tipo EQ 'ENGORDA'.
    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'EN01'.
    APPEND wa_rgdauat TO vl_rgdauat.

    vl_wfechas-high = so_fecha-low.
    vl_wfechas-loW = so_fecha-low.
    vl_wfechas-option = 'BT'."so_fecha-option.
    vl_wfechas-sign = so_fecha-sign.
    APPEND vl_wfechas TO vl_fechas.

    vl_gjahr = so_fecha-low+0(4).
  ELSE.
    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA00'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA01'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA02'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA03'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA04'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PP01'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PP02'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PP04'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PPC1'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PPK1'.
    APPEND wa_rgdauat TO vl_rgdauat.

    vl_wfechas-high = lv_fecha_mes.
    vl_wfechas-loW = lv_fecha_inicial .
    vl_wfechas-option = 'BT'."so_fecha-option.
    vl_wfechas-sign = so_fecha-sign.
    APPEND vl_wfechas TO vl_fechas.

  ENDIF.

  REFRESH it_aufnr_end.

  obj_engorda->get_aufnr_cte_ren(
EXPORTING
  p_gjahr   =  vl_gjahr
  p_fecha  = vl_fechas
  p_clorder = vl_rgdauat
  p_tipo    = p_tipo
CHANGING
  i_tabla   = it_aufnr_end
).

  SORT it_aufnr_end BY aufnr getri.


ENDFORM.


FORM set_functions_alv.
  lo_layout = o_alv->get_layout( ).
  gs_layout-ctab_fname = lv_fname.

  o_alv->get_columns( )->set_color_column( lv_fname ).
  o_alv->get_functions( )->set_export_spreadsheet( value = if_salv_c_bool_sap=>true
  ).." set_all( abap_false ). "Set all standard functions of ALV
  o_alv->get_columns( )->set_optimize( abap_true ). "Optimize column length
  o_alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ). "Line and Column Selection
  o_alv->get_display_settings( )->set_striped_pattern( cl_salv_display_settings=>true ). "zebra stripes

* Set up saving of layouts for this report
  o_alv->get_layout( )->set_key( VALUE salv_s_layout_key( report = sy-repid ) ).
  o_alv->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
  o_alv->get_layout( )->set_default( if_salv_c_bool_sap=>true ). "Allow layout preset


*   set Layout save restriction
*   1. Set Layout Key .. Unique key identifies the Differenet ALVs
  ls_key-report = sy-repid.
  lo_layout->set_key( ls_key ).

*   2. Remove Save layout the restriction.
*  lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
*
*   set initial Layout
*  lf_variant = 'DEFAULT'.
*  lo_layout->set_initial_layout( lf_variant ).
**
*
*lo_function = o_alv->get_functions( ).
*lo_function->set_all('X').
*
*
*try.
*  lo_function->add_function(
*    name     = 'MATNR'
*    icon     = CONV string( icon_complete )
*    text     = 'Mat. Producidos'
*    tooltip  = 'Materiales Producidos'
*    position = if_salv_c_function_position=>right_of_salv_functions ).
*  catch cx_salv_existing cx_salv_wrong_call.
*endtry.

*  IF gv_tipore = 'PPA'.
  o_alv->set_screen_status(
      pfstatus      =  'ZSTANDARD'
      report        =  sy-repid
      set_functions = o_alv->c_functions_all ).

  lr_events = o_alv->get_event( ).

  CREATE OBJECT gr_events.

*... §6.1 register to the event USER_COMMAND
  SET HANDLER gr_events->on_user_command FOR lr_events.
*  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form show_results
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_results .

  DATA: lv_text    TYPE string.

  "<fs_outtable_o> = <fs_outtable>.

  cl_salv_table=>factory( IMPORTING r_salv_table = o_alv
         CHANGING t_Table = <fs_outtable>
                  ).

  PERFORM set_functions_alv.
  PERFORM calculate_columns.
*  "PERFORM set_aggregations.
*  PERFORM set_colors.
  PERFORM set_title_header.
  PERFORM report_header
                    CHANGING o_alv.

  o_alv->display( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form calculate_columns
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM calculate_columns .

  DATA: campocu        TYPE string,
        vl_date        TYPE dats,
        vl_name_month  TYPE fcltx,
        vl_zname_month TYPE zfcltx.

  DATA: vl_scrtext_s TYPE SCRTEXT_s,
        vl_scrtext_m TYPE SCRTEXT_m,
        vl_scrtext_l TYPE scrtext_l,
        columnname   TYPE lvc_fname.

  lr_columns = o_alv->get_columns( ).
  lr_columns->set_optimize( abap_true ).

  DATA column TYPE REF TO cl_salv_column.

  column = lr_columns->get_column( columnname = 'WGBEZ60' ).
  column->set_short_text('descript.' ).
  column->set_medium_text('description' ).
  column->set_long_text('description' ).


*
  column = lr_columns->get_column( columnname = 'H' ).
  column->set_short_text('H' ).
  column->set_medium_text('H' ).
  column->set_long_text('H' ).

  LOOP AT lt_fcat INTO DATA(wa_fcat) WHERE fieldname CP 'M0*'.

    vl_scrtext_m = 'H/xalapa'.
    vl_scrtext_l = 'H/xalapa'.
    vl_scrtext_s = 'H/xalapa'."vl_zname_month.


    column = lr_columns->get_column( columnname = wa_fcat-fieldname ).
    column->set_short_text( vl_scrtext_s ).
    column->set_medium_text( vl_scrtext_m ).
    column->set_long_text( vl_scrtext_l ).
    columnname = wa_fcat-fieldname.
  ENDLOOP.

  column = lr_columns->get_column( columnname = 'M' ).
  column->set_short_text('M' ).
  column->set_medium_text('M' ).
  column->set_long_text('M' ).

  column = lr_columns->get_column( columnname = 'CHIAPAS' ).
  column->set_short_text('Chiapas' ).
  column->set_medium_text('Chiapas' ).
  column->set_long_text('Chiapas' ).

  column = lr_columns->get_column( columnname = 'RNS_ENTERO' ).
  column->set_short_text('RNS Entero' ).
  column->set_medium_text('RNS Entero' ).
  column->set_long_text('RNS Entero' ).

  column = lr_columns->get_column( columnname = 'RNS_CORTES' ).
  column->set_short_text('RNS Cortes' ).
  column->set_medium_text('RNS Cortes' ).
  column->set_long_text('RNS Cortes' ).

  column = lr_columns->get_column( columnname = 'RTC' ).
  column->set_short_text('RTC' ).
  column->set_medium_text('RTC' ).
  column->set_long_text('RTC' ).

  column = lr_columns->get_column( columnname = 'PINTADO_P' ).
  column->set_short_text('Pintado p' ).
  column->set_medium_text('Pintado Pesado' ).
  column->set_long_text('Pintado Pesado' ).

  column = lr_columns->get_column( columnname = 'HIDRATADO' ).
  column->set_short_text('Hidratado' ).
  column->set_medium_text('Hidratado' ).
  column->set_long_text('Hidratado' ).

  column = lr_columns->get_column( columnname = 'RHP_CORTES' ).
  column->set_short_text('RHP Cortes' ).
  column->set_medium_text('RHP Cortes' ).
  column->set_long_text('RHP Cortes' ).

  column = lr_columns->get_column( columnname = 'LIMPIEZAS' ).
  column->set_short_text('Limpiezas' ).
  column->set_medium_text('Limpiezas' ).
  column->set_long_text('Limpiezas' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_title_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_title_header .
  CLEAR wa_header.
  REFRESH it_header.

  DATA date_ext(10).

  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = sy-datum
    IMPORTING
      date_external            = date_ext
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.

  wa_header-titulo1 = 'Resultados Matriz Rentabilidad'.
  CONCATENATE 'Fecha Elaboración:' date_ext INTO wa_header-titulo2 SEPARATED BY space.
  IF p_werks IS INITIAL.
    wa_header-titulo3 = 'Reporte Global'.
  ELSEIF p_werks IS NOT INITIAL.
    wa_header-titulo3 = 'Reporte por Centro'.
    SELECT SINGLE concat_with_space( 'Nombre del Centro: ', name1,1 )
     FROM t001w WHERE werks IN @p_werks
      INTO @wa_header-titulo4.
  ENDIF.


  APPEND wa_header TO it_header.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form report_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- O_ALV
*&---------------------------------------------------------------------*
FORM report_header  CHANGING p_o_alv TYPE REF TO cl_salv_table.
*-- ALV Header declarations

  DATA: lv_lines        TYPE i,
        lv_linesc(10)   TYPE c,
        lv_row          TYPE i,
        lv_column       TYPE i,
        lv_date_from    TYPE char10,
        lv_date_to      TYPE char10,
        lv_text         TYPE char255,
        lo_header       TYPE REF TO  cl_salv_form_element,
        lo_layout_grid  TYPE REF TO cl_salv_form_layout_grid,
        lo_layout_mgrid TYPE REF TO cl_salv_form_layout_grid,
        lo_value        TYPE REF TO cl_salv_form_header_info,
        lv_title        TYPE string.

*-- Creating the layout object

  CREATE OBJECT lo_layout_mgrid.

*-- Setting the Header Text

  lo_layout_mgrid->create_grid( EXPORTING row    = 1
                                column = 1
                                RECEIVING r_value = lo_layout_grid ).

  lv_row = 1.

  READ TABLE it_header INTO wa_header INDEX 1.

  lo_layout_grid->create_label( row     = lv_row
                             column  = 1
                             text    = wa_header-titulo1 ).

  lo_layout_mgrid->create_grid( EXPORTING row     = 2
                                column  = 1
                                RECEIVING r_value = lo_layout_grid ).


  lv_row = lv_row + 1.
  lo_layout_grid->create_label( row     = lv_row
                                column  = 1
                                text    = wa_header-titulo2 ).

  lv_row = lv_row + 1.
  lo_layout_grid->create_label( row     = lv_row
                                column  = 1
                                text    = wa_header-titulo3 ).

  IF wa_header-titulo4 IS NOT INITIAL.
    lv_row = lv_row + 1.
    lo_layout_grid->create_label( row     = lv_row
                                  column  = 1
                                  text    = wa_header-titulo4 ).

  ENDIF.

*  lo_layout_grid->create_text( row      = lv_row
*                               column   = 2
*                               text     = sy-datum ).



*
*
*
*  lv_row = lv_row + 1.
*
*
*  lo_layout_grid->create_label( row     = lv_row
*                                column  = 1
*                                text    = 'Run by' ).
*
*  lo_layout_grid->create_text( row      = lv_row
*
*                              column   = 2
*
*                              text     = sy-uname ).

  lo_header = lo_layout_mgrid.

  p_o_alv->set_top_of_list( lo_header ).
ENDFORM.

FORM get_cantidad_pv.
  DATA  vl_valor_base TYPE menge_d.

  DATA: rg_werks TYPE RANGE OF ce1gp00-werks,
        wa_werks LIKE LINE OF rg_werks.

  FIELD-SYMBOLS: <fs_st> TYPE any,
                 <fs_ln> TYPE any.

  obj_engorda->get_pzas_pv(
EXPORTING
 i_fecha  = so_fecha-low
CHANGING
 ch_pzas_pv = it_pzas_pv


).

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE20'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE21'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE22'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE23'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE24'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE25'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE26'.
  APPEND wa_werks TO rg_werks.


  CLEAR: gv_cant_pv,
        gv_cantH ,
        gv_cantM ,
        gv_chiapas,

        gv_cant_pv_kg,
        gv_cantH_kg ,
        gv_cantM_kg ,
        gv_chiapas_kg,

      gv_cant_pv_mn ,
      gv_cantH_mn,
      gv_cantM_mn,
      gv_chiapas_mn,

      gv_dev_pv,
      gv_dev_h,
      gv_dev_m,
      gv_dev_chiapas,
      gv_fletes_pv,
      gv_fletes_h,
      gv_fletes_m,
      gv_fletes_chiapas.


  DATA(it_chiapas) = it_pzas_pv[].

  DELETE it_pzas_pv WHERE werks IN rg_werks.

  gv_cant_pv = REDUCE #( INIT x TYPE rke2_absmg
                                FOR wa1 IN it_pzas_pv WHERE ( spart = '94' )
                                NEXT x = x + wa1-absmg ).

  gv_cant_pv_kg = REDUCE #( INIT x1 TYPE rke2_vvpnt
                                 FOR wa1 IN it_pzas_pv WHERE ( spart = '94' )
                                 NEXT x1 = x1 + wa1-vvpnt ).

  gv_cant_pv_mn = REDUCE #( INIT x2 TYPE rke2_erlos
                                 FOR wa1 IN it_pzas_pv WHERE ( spart = '94' )
                                 NEXT x2 = x2 + wa1-erlos ).

  gv_dev_pv = REDUCE #( INIT x2 TYPE rke2_vvdrv
                                 FOR wa1 IN it_pzas_pv WHERE ( spart = '94' )
                                 NEXT x2 = x2 + wa1-vvdrv ).

  gv_fletes_pv = REDUCE #( INIT x2 TYPE rke2_vvgdi
                                 FOR wa1 IN it_pzas_pv WHERE ( spart = '94' )
                                 NEXT x2 = x2 + wa1-vvgdi ).


  gv_cant_pv_mn = gv_cant_pv_mn -  gv_dev_pv -   gv_fletes_pv.


  IF gv_cant_pv LT 0.
    gv_cant_pv = gv_cant_pv * -1.
  ENDIF.

  gv_cantH = REDUCE #( INIT x TYPE rke2_absmg
                               FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                               NEXT x = x + wa1-absmg ).

  gv_canth_kg = REDUCE #( INIT x1 TYPE rke2_vvpnt
                                FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                                NEXT x1 = x1 + wa1-vvpnt ).

  gv_canth_mn = REDUCE #( INIT x2 TYPE rke2_erlos
                                 FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                                 NEXT x2 = x2 + wa1-erlos ).

  gv_dev_h = REDUCE #( INIT x2 TYPE rke2_vvdrv
                                 FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                                 NEXT x2 = x2 + wa1-vvdrv ).

  gv_fletes_h = REDUCE #( INIT x2 TYPE rke2_vvgdi
                                 FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                                 NEXT x2 = x2 + wa1-vvgdi ).


  gv_canth_mn = gv_canth_mn -   gv_dev_h -   gv_fletes_h.

  IF gv_cantH LT 0.
    gv_cantH = gv_cantH * -1.
  ENDIF.

  gv_cantM = REDUCE #( INIT x TYPE rke2_absmg
                               FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                               NEXT x = x + wa1-absmg ).

  gv_cantm_kg = REDUCE #( INIT x1 TYPE rke2_vvpnt
                               FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                               NEXT x1 = x1 + wa1-vvpnt ).

  gv_cantm_mn = REDUCE #( INIT x2 TYPE rke2_erlos
                                FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                                NEXT x2 = x2 + wa1-erlos ).

  gv_dev_m = REDUCE #( INIT x2 TYPE rke2_vvdrv
                                 FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                                 NEXT x2 = x2 + wa1-vvdrv ).

  gv_fletes_m = REDUCE #( INIT x2 TYPE rke2_vvgdi
                                 FOR wa1 IN it_pzas_pv WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                                 NEXT x2 = x2 + wa1-vvgdi ).


  gv_cantm_mn = gv_cantm_mn - gv_dev_m - gv_fletes_m.


  IF gv_cantm LT 0.
    gv_cantm = gv_cantm * -1.
  ENDIF.

  gv_chiapas = REDUCE #( INIT x TYPE rke2_absmg
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x = x + wa1-absmg ).

  gv_chiapas_kg = REDUCE #( INIT x1 TYPE rke2_vvpnt
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x1 = x1 + wa1-vvpnt ).

  gv_chiapas_mn = REDUCE #( INIT x2 TYPE rke2_erlos
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x2 = x2 + wa1-erlos ).

  gv_dev_chiapas = REDUCE #( INIT x2 TYPE rke2_vvdrv
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x2 = x2 + wa1-vvdrv ).

  gv_fletes_chiapas = REDUCE #( INIT x2 TYPE rke2_vvgdi
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x2 = x2 + wa1-vvgdi ).


  gv_chiapas_mn = gv_chiapas_mn - gv_dev_chiapas -   gv_fletes_chiapas.

  IF gv_chiapas LT 0.
    gv_chiapas = gv_chiapas * -1.
  ENDIF.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_ln>.
  <fs_ln> = TEXT-017.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ).

      CASE ls_fcat-fieldname.
        WHEN 'H'.
          vl_valor_base = gv_canth_kg.

        WHEN 'M'.
          vl_valor_base = gv_cantm_kg.
        WHEN 'CHIAPAS'.
          vl_valor_base = gv_chiapas_kg.
        WHEN 'RNS_ENTERO'.
          vl_valor_base = gv_rnsentero.
        WHEN 'RNS_CORTES'.
          vl_valor_base = gv_rnscortes.

        WHEN 'RTC'.
          vl_valor_base = gv_rtc.

        WHEN 'PINTADO_P'.
          vl_valor_base = gv_pintadopesado.
        WHEN 'HIDRATADO'.

          vl_valor_base = gv_hidratado.
        WHEN 'RHP_CORTES'.
          vl_valor_base = gv_rhpcortes.
        WHEN 'LIMPIEZAS'.
          vl_valor_base = gv_limpiezas.

        WHEN OTHERS.
          IF ls_fcat-fieldname CP 'M0*'.
            vl_valor_base = gv_cant_pv_kg.
          ENDIF.
      ENDCASE.

      PERFORM calcula_columnas
         USING
           vl_valor_base
           0
           ls_fcat-fieldname
           <fs_st>
          TEXT-017
        .


    ENDLOOP.
  ENDLOOP.
ENDFORM.


FORM get_cantidad_pv_mes.
  DATA  vl_valor_base TYPE menge_d.

  DATA: rg_werks TYPE RANGE OF ce1gp00-werks,
        wa_werks LIKE LINE OF rg_werks.

  FIELD-SYMBOLS: <fs_st> TYPE any,
                 <fs_ln> TYPE any.

  obj_engorda->get_pzas_pv_mensual(
EXPORTING
 i_fecha  = so_fecha-low
CHANGING
 ch_pzas_pv = it_pzas_pv_mes


).

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE20'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE21'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE22'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE23'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE24'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE25'.
  APPEND wa_werks TO rg_werks.

  wa_werks-option = 'EQ'.
  wa_werks-sign = 'I'.
  wa_werks-low = 'PE26'.
  APPEND wa_werks TO rg_werks.


  CLEAR: gv_cant_pv_m,
        gv_cantH_m ,
        gv_cantM_m ,
        gv_chiapas_m,

        gv_cant_pv_kg_m,
        gv_cantH_kg_m ,
        gv_cantM_kg_m ,
        gv_chiapas_kg_m,

      gv_cant_pv_mn_m ,
      gv_cantH_mn_m,
      gv_cantM_mn_m,
      gv_chiapas_mn_m,

      gv_dev_pv_m,
      gv_dev_h_m,
      gv_dev_m_m,
      gv_dev_chiapas_m,
      gv_fletes_pv_m,
      gv_fletes_h_m,
      gv_fletes_m_m,
      gv_fletes_chiapas_m.


  DATA(it_chiapas) = it_pzas_pv_mes[].

  DELETE it_pzas_pv_mes WHERE werks IN rg_werks.

  gv_cant_pv_mn_m = REDUCE #( INIT x TYPE rke2_absmg
                                FOR wa1 IN it_pzas_pv_mes WHERE ( spart = '94' )
                                NEXT x = x + wa1-absmg ).

  gv_cant_pv_kg_m = REDUCE #( INIT x1 TYPE rke2_vvpnt
                                 FOR wa1 IN it_pzas_pv_mes WHERE ( spart = '94' )
                                 NEXT x1 = x1 + wa1-vvpnt ).

  gv_cant_pv_mn_m = REDUCE #( INIT x2 TYPE rke2_erlos
                                 FOR wa1 IN it_pzas_pv_mes WHERE ( spart = '94' )
                                 NEXT x2 = x2 + wa1-erlos ).

  gv_dev_pv_m = REDUCE #( INIT x2 TYPE rke2_vvdrv
                                 FOR wa1 IN it_pzas_pv_mes WHERE ( spart = '94' )
                                 NEXT x2 = x2 + wa1-vvdrv ).

  gv_fletes_pv_m = REDUCE #( INIT x2 TYPE rke2_vvgdi
                                 FOR wa1 IN it_pzas_pv_mes WHERE ( spart = '94' )
                                 NEXT x2 = x2 + wa1-vvgdi ).


  gv_cant_pv_mn_m = gv_cant_pv_mn_m -  gv_dev_pv_m -   gv_fletes_pv_m.


  IF gv_cant_pv_m LT 0.
    gv_cant_pv_m = gv_cant_pv_m * -1.
  ENDIF.

  gv_cantH_m = REDUCE #( INIT x TYPE rke2_absmg
                               FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                               NEXT x = x + wa1-absmg ).

  gv_canth_kg_m = REDUCE #( INIT x1 TYPE rke2_vvpnt
                                FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                                NEXT x1 = x1 + wa1-vvpnt ).

  gv_canth_mn_m = REDUCE #( INIT x2 TYPE rke2_erlos
                                 FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                                 NEXT x2 = x2 + wa1-erlos ).

  gv_dev_h_m = REDUCE #( INIT x2 TYPE rke2_vvdrv
                                 FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                                 NEXT x2 = x2 + wa1-vvdrv ).

  gv_fletes_h_m = REDUCE #( INIT x2 TYPE rke2_vvgdi
                                 FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500022' )
                                 NEXT x2 = x2 + wa1-vvgdi ).


  gv_canth_mn_m = gv_canth_mn_m -   gv_dev_h_m -   gv_fletes_h_m.

  IF gv_cantH_m LT 0.
    gv_cantH_m = gv_cantH_m * -1.
  ENDIF.

  gv_cantM_m = REDUCE #( INIT x TYPE rke2_absmg
                               FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                               NEXT x = x + wa1-absmg ).

  gv_cantm_kg_m = REDUCE #( INIT x1 TYPE rke2_vvpnt
                               FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                               NEXT x1 = x1 + wa1-vvpnt ).

  gv_cantm_mn_m = REDUCE #( INIT x2 TYPE rke2_erlos
                                FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                                NEXT x2 = x2 + wa1-erlos ).

  gv_dev_m_m = REDUCE #( INIT x2 TYPE rke2_vvdrv
                                 FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                                 NEXT x2 = x2 + wa1-vvdrv ).

  gv_fletes_m_m = REDUCE #( INIT x2 TYPE rke2_vvgdi
                                 FOR wa1 IN it_pzas_pv_mes WHERE ( spart NE '94' AND matnr EQ '000000000000500021' )
                                 NEXT x2 = x2 + wa1-vvgdi ).


  gv_cantm_mn_m = gv_cantm_mn_m - gv_dev_m_m - gv_fletes_m_m.


  IF gv_cantm_m LT 0.
    gv_cantm_m = gv_cantm_m * -1.
  ENDIF.

  gv_chiapas_m = REDUCE #( INIT x TYPE rke2_absmg
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x = x + wa1-absmg ).

  gv_chiapas_kg_m = REDUCE #( INIT x1 TYPE rke2_vvpnt
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x1 = x1 + wa1-vvpnt ).

  gv_chiapas_mn_m = REDUCE #( INIT x2 TYPE rke2_erlos
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x2 = x2 + wa1-erlos ).

  gv_dev_chiapas_m = REDUCE #( INIT x2 TYPE rke2_vvdrv
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x2 = x2 + wa1-vvdrv ).

  gv_fletes_chiapas_m = REDUCE #( INIT x2 TYPE rke2_vvgdi
                                 FOR wa1 IN it_chiapas WHERE ( werks IN rg_werks )
                                 NEXT x2 = x2 + wa1-vvgdi ).


  gv_chiapas_mn_m = gv_chiapas_mn_m - gv_dev_chiapas_m -   gv_fletes_chiapas_m.

  IF gv_chiapas_m LT 0.
    gv_chiapas_m = gv_chiapas_m * -1.
  ENDIF.


ENDFORM.

FORM get_cantidad_procesado.

  FIELD-SYMBOLS: <fs_st> TYPE any,
                 <fs_ln> TYPE any.

  obj_engorda->get_pzas_pro(
EXPORTING
 i_fecha  = so_fecha-low
CHANGING
 ch_pzas_pro = it_pzas_pro

).

  CLEAR: gv_rnsentero,
         gv_rnscortes,
         gv_rtc,
         gv_pintadopesado,
         gv_hidratado,
         gv_rhpcortes,
         gv_limpiezas,

         gv_rnsentero_mn,
         gv_rnscortes_mn,
         gv_rtc_mn,
         gv_pintadopesado_mn,
         gv_hidratado_mn,
         gv_rhpcortes_mn,
         gv_limpiezas_mn.



  gv_rnsentero = REDUCE #( INIT x TYPE menge_d
                                FOR wa1 IN it_pzas_pro WHERE ( ferth = 'RNSENTERO' )
                                NEXT x = x + wa1-msl ).

  gv_rnsentero_mn = REDUCE #( INIT x1 TYPE fins_vhcur12
                                FOR wa1 IN it_pzas_pro WHERE ( ferth = 'RNSENTERO' )
                                NEXT x1 = x1 + wa1-hsl ).

  IF gv_rnsentero LT 0.
    gv_rnsentero = gv_rnsentero * -1.
    gv_rnsentero_mn = gv_rnsentero_mn * -1.
  ENDIF.

  gv_rnscortes = REDUCE #( INIT x TYPE menge_d
                               FOR wa IN it_pzas_pro WHERE ( ferth = 'RNSCORTES' )
                               NEXT x = x + wa-msl ).

  gv_rnscortes_mn = REDUCE #( INIT x1 TYPE fins_vhcur12
                                 FOR wa IN it_pzas_pro WHERE ( ferth = 'RNSCORTES' )
                                 NEXT x1 = x1 + wa-hsl ).

  IF gv_rnscortes LT 0.
    gv_rnscortes = gv_rnscortes * -1.
    gv_rnscortes_mn = gv_rnscortes_mn * -1.
  ENDIF.

  gv_rtc = REDUCE #( INIT x TYPE menge_d
                               FOR wa1 IN it_pzas_pro WHERE ( ferth = 'RTC' )
                               NEXT x = x + wa1-msl ).

  gv_rtc_mn = REDUCE #( INIT x1 TYPE fins_vhcur12
                              FOR wa1 IN it_pzas_pro WHERE ( ferth = 'RTC' )
                              NEXT x1 = x1 + wa1-hsl ).

  IF gv_rtc_mn LT 0.
    gv_rtc = gv_rtc * -1.
    gv_rtc_mn = gv_rtc_mn * -1.
  ENDIF.

  gv_pintadopesado = REDUCE #( INIT x TYPE menge_d
                                 FOR wa1 IN it_pzas_pro WHERE ( ferth = 'PINTADOPESADO'  )
                                 NEXT x = x + wa1-msl ).

  gv_pintadopesado_mn = REDUCE #( INIT x1 TYPE fins_vhcur12
                                 FOR wa1 IN it_pzas_pro WHERE ( ferth = 'PINTADOPESADO'  )
                                 NEXT x1 = x1 + wa1-hsl ).

  IF gv_pintadopesado LT 0.
    gv_pintadopesado = gv_pintadopesado * -1.
    gv_pintadopesado_mn = gv_pintadopesado_mn * -1.
  ENDIF.


  gv_hidratado = REDUCE #( INIT x TYPE menge_d
                                 FOR wa1 IN it_pzas_pro WHERE ( ferth = 'HIDRATADO'  )
                                 NEXT x = x + wa1-msl ).

  gv_hidratado_mn = REDUCE #( INIT x1 TYPE fins_vhcur12
                                FOR wa1 IN it_pzas_pro WHERE ( ferth = 'HIDRATADO'  )
                                NEXT x1 = x1 + wa1-hsl ).

  IF gv_hidratado LT 0.
    gv_hidratado = gv_hidratado * -1.
    gv_hidratado_mn = gv_hidratado_mn * -1.
  ENDIF.


  gv_rhpcortes = REDUCE #( INIT x TYPE menge_d
                               FOR wa1 IN it_pzas_pro WHERE ( ferth = 'RHPCORTES'  )
                               NEXT x = x + wa1-msl ).

  gv_rhpcortes_mn = REDUCE #( INIT x1 TYPE fins_vhcur12
                               FOR wa1 IN it_pzas_pro WHERE ( ferth = 'RHPCORTES'  )
                               NEXT x1 = x1 + wa1-hsl ).
  IF gv_rhpcortes LT 0.
    gv_rhpcortes = gv_rhpcortes * -1.
    gv_rhpcortes_mn = gv_rhpcortes_mn * -1.
  ENDIF.

  gv_limpiezas = REDUCE #( INIT x TYPE menge_d
                             FOR wa1 IN it_pzas_pro WHERE ( ferth = 'LIMPIEZAS'  )
                             NEXT x = x + wa1-msl ).

  gv_limpiezas_mn = REDUCE #( INIT x1 TYPE fins_vhcur12
                             FOR wa1 IN it_pzas_pro WHERE ( ferth = 'LIMPIEZAS'  )
                             NEXT x1 = x1 + wa1-hsl ).
  IF gv_limpiezas LT 0.
    gv_limpiezas = gv_limpiezas * -1.
    gv_limpiezas_mn = gv_limpiezas_mn * -1.
  ENDIF.


  gv_rnsentero = gv_rnsentero." / c_rnsentero.
  gv_rnscortes = gv_rnscortes." / c_rnscortes.
  gv_rtc = gv_rtc." / c_rtc.
  gv_pintadopesado = gv_pintadopesado." / c_pintado.
  gv_hidratado = gv_hidratado." / c_hidratado.
  gv_rhpcortes = gv_rhpcortes." / c_rhpcortes.
  gv_limpiezas = gv_limpiezas." / c_limpiezas.

ENDFORM.

FORM get_cantidad_procesado_mes.

  FIELD-SYMBOLS: <fs_st> TYPE any,
                 <fs_ln> TYPE any.

  obj_engorda->get_pzas_pro_mes(
EXPORTING
 i_fecha  = so_fecha-low
CHANGING
 ch_pzas_pro = it_pzas_pro_m

).

  CLEAR: gv_rnsentero_m,
         gv_rnscortes_m,
         gv_rtc_m,
         gv_pintadopesado_m,
         gv_hidratado_m,
         gv_rhpcortes_m,
         gv_limpiezas_m,

         gv_rnsentero_mn_m,
         gv_rnscortes_mn_m,
         gv_rtc_mn_m,
         gv_pintadopesado_mn_m,
         gv_hidratado_mn_m,
         gv_rhpcortes_mn_m,
         gv_limpiezas_mn_m.



  gv_rnsentero_m = REDUCE #( INIT x TYPE menge_d
                                FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'RNSENTERO' )
                                NEXT x = x + wa1-msl ).

  gv_rnsentero_mn_m = REDUCE #( INIT x1 TYPE fins_vhcur12
                                FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'RNSENTERO' )
                                NEXT x1 = x1 + wa1-hsl ).

  IF gv_rnsentero_m LT 0.
    gv_rnsentero_m = gv_rnsentero_m * -1.
    gv_rnsentero_mn_m = gv_rnsentero_mn_m * -1.
  ENDIF.

  gv_rnscortes_m = REDUCE #( INIT x TYPE menge_d
                               FOR wa IN it_pzas_pro_m WHERE ( ferth = 'RNSCORTES' )
                               NEXT x = x + wa-msl ).

  gv_rnscortes_mn_m = REDUCE #( INIT x1 TYPE fins_vhcur12
                                 FOR wa IN it_pzas_pro_m WHERE ( ferth = 'RNSCORTES' )
                                 NEXT x1 = x1 + wa-hsl ).

  IF gv_rnscortes_m LT 0.
    gv_rnscortes_m = gv_rnscortes_m * -1.
    gv_rnscortes_mn_m = gv_rnscortes_mn_m * -1.
  ENDIF.

  gv_rtc_m = REDUCE #( INIT x TYPE menge_d
                               FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'RTC' )
                               NEXT x = x + wa1-msl ).

  gv_rtc_mn_m = REDUCE #( INIT x1 TYPE fins_vhcur12
                              FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'RTC' )
                              NEXT x1 = x1 + wa1-hsl ).

  IF gv_rtc_mn_m LT 0.
    gv_rtc_m = gv_rtc_m * -1.
    gv_rtc_mn_m = gv_rtc_mn_m * -1.
  ENDIF.

  gv_pintadopesado_m = REDUCE #( INIT x TYPE menge_d
                                 FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'PINTADOPESADO'  )
                                 NEXT x = x + wa1-msl ).

  gv_pintadopesado_mn_m = REDUCE #( INIT x1 TYPE fins_vhcur12
                                 FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'PINTADOPESADO'  )
                                 NEXT x1 = x1 + wa1-hsl ).

  IF gv_pintadopesado_m LT 0.
    gv_pintadopesado_m = gv_pintadopesado_m * -1.
    gv_pintadopesado_mn_m = gv_pintadopesado_mn_m * -1.
  ENDIF.


  gv_hidratado_m = REDUCE #( INIT x TYPE menge_d
                                 FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'HIDRATADO'  )
                                 NEXT x = x + wa1-msl ).

  gv_hidratado_mn_m = REDUCE #( INIT x1 TYPE fins_vhcur12
                                FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'HIDRATADO'  )
                                NEXT x1 = x1 + wa1-hsl ).

  IF gv_hidratado_m LT 0.
    gv_hidratado_m = gv_hidratado_m * -1.
    gv_hidratado_mn_m = gv_hidratado_mn_m * -1.
  ENDIF.


  gv_rhpcortes_m = REDUCE #( INIT x TYPE menge_d
                               FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'RHPCORTES'  )
                               NEXT x = x + wa1-msl ).

  gv_rhpcortes_mn_m = REDUCE #( INIT x1 TYPE fins_vhcur12
                               FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'RHPCORTES'  )
                               NEXT x1 = x1 + wa1-hsl ).
  IF gv_rhpcortes_m LT 0.
    gv_rhpcortes_m = gv_rhpcortes_m * -1.
    gv_rhpcortes_mn_m = gv_rhpcortes_mn_m * -1.
  ENDIF.

  gv_limpiezas_m = REDUCE #( INIT x TYPE menge_d
                             FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'LIMPIEZAS'  )
                             NEXT x = x + wa1-msl ).

  gv_limpiezas_mn_m = REDUCE #( INIT x1 TYPE fins_vhcur12
                             FOR wa1 IN it_pzas_pro_m WHERE ( ferth = 'LIMPIEZAS'  )
                             NEXT x1 = x1 + wa1-hsl ).
  IF gv_limpiezas_m LT 0.
    gv_limpiezas_m = gv_limpiezas_m * -1.
    gv_limpiezas_mn_m = gv_limpiezas_mn_m * -1.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_textos
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form get_kgs_pzas
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_kgs_pzas .

  DATA: rg_fechas  TYPE RANGE OF mseg-budat_mkpf,
        vl_find,
        vl_sytabix TYPE sy-tabix,
        vl_mes(3)  TYPE c,
        vl_string  TYPE string,
        vl_fecha_i TYPE datum, vl_fecha_f TYPE datum.
  DATA num_days    TYPE i.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any.



  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.




  REFRESH it_aux_acum.


  IF it_aufnr_end IS NOT INITIAL.

    obj_engorda->get_kgs_pzas(
  EXPORTING
    i_aufnr  = it_aufnr_end
  CHANGING
    ch_kgs_pzas = it_kgs_pzas
  ).

  ENDIF.


  SORT it_kgs_pzas BY aufnr budat_mkpf.

  DELETE it_kgs_pzas WHERE racct NE '0504025192'.


*  obj_engorda->calculate_dates(
*    CHANGING
*      p_rgfechas = rg_fechas
*  ).

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    DATA(aux_aufnr) = it_aufnr_end[].
    CONCATENATE so_fecha-low+0(4) wa_meses-zmonth+1(2) '01' INTO vl_string.
    vl_fecha_i = vl_string.

    PERFORM get_num_days USING vl_fecha_i
                        CHANGING  num_days.
    vl_mes = num_days.

    CONCATENATE so_fecha-low+0(4) wa_meses-zmonth+1(2) so_fecha-low+6(2)  INTO vl_string.
    vl_fecha_f = vl_string.

    DELETE aux_aufnr WHERE getri NOT BETWEEN vl_fecha_i AND vl_fecha_f.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_kgs_pzas INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
        vl_mes = wa_meses-zmonth.
        PERFORM calc_acum USING ''
                                wa_recupera-/cwm/menge
                                wa_recupera-menge
                                wa_recupera-dmbtr.
      ENDLOOP.
    ENDLOOP.

    """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
    IF it_aux_out IS NOT INITIAL.
      APPEND INITIAL LINE TO it_aux_acum ASSIGNING <linea>.
      ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
      <fs_field> = vl_mes.
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

      LOOP AT it_aux_out INTO DATA(wa).
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-/cwm/menge.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-piezas.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-month.
        UNASSIGN <fs_field>.

      ENDLOOP.
    ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    REFRESH it_aux_out.
  ENDLOOP.

ENDFORM.

FORM calc_acum USING p_wgbez60 TYPE maktx
                    p_wm_menge TYPE /cwm/menge
                    p_menge TYPE menge_d
                    p_dmbtr TYPE dmbtr_cs.

  CLEAR wa_aux_out.
  wa_aux_out-concepto = p_wgbez60.
  wa_aux_out-/cwm/menge = p_wm_menge.
  wa_aux_out-piezas = p_menge.
  wa_aux_out-month = p_dmbtr.
  COLLECT wa_aux_out INTO it_aux_out.

ENDFORM.

FORM get_num_days USING p_date TYPE d
                  CHANGING p_numDays TYPE i.

  DATA: xdatum TYPE d.

  xdatum = p_date.
  xdatum+6(2) = '01'.
  xdatum = xdatum + 35.          "para llegar seguro al proximo mes
  xdatum+6(2) = '01'. xdatum = xdatum - 1.
  p_numDays = xdatum+6(2).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_peso_prom
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_peso_prom .
  FIELD-SYMBOLS: <fs_tt>    TYPE table,
                 <fs_st>    TYPE any,
                 <fs_mes>   TYPE any,
                 <fs_field> TYPE any,
                 <fs_acum>  TYPE table.

  DATA: vl_piezas_pv TYPE menge_d, vl_kilos_pv TYPE menge_d,
        vl_peso_prom TYPE menge_d.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-004.


  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    ASSIGN COMPONENT wa_meses-zmonth OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_cant_pv_kg / gv_cant_pv  .

    ASSIGN COMPONENT 'H' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_canth_kg / gv_cantH .

    ASSIGN COMPONENT 'M' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_cantm_kg / gv_cantM .

    ASSIGN COMPONENT 'CHIAPAS' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_chiapas_kg / gv_chiapas .

    ASSIGN COMPONENT 'RNS_ENTERO' OF STRUCTURE <fs_st> TO <fs_field>.
    IF gv_rnsentero GT 0.
      <fs_field> = c_rnsentero.
    ENDIF.

    ASSIGN COMPONENT 'RNS_CORTES' OF STRUCTURE <fs_st> TO <fs_field>.
    IF gv_rnscortes GT 0.
      <fs_field> = c_rnscortes.
    ENDIF.

    ASSIGN COMPONENT 'RTC' OF STRUCTURE <fs_st> TO <fs_field>.
    IF gv_rtc GT 0.
      <fs_field> = c_rtc.
    ENDIF.

    ASSIGN COMPONENT 'PINTADO_P' OF STRUCTURE <fs_st> TO <fs_field>.
    IF gv_pintadopesado GT 0.
      <fs_field> = c_pintado.
    ENDIF.

    ASSIGN COMPONENT 'HIDRATADO' OF STRUCTURE <fs_st> TO <fs_field>.
    IF gv_hidratado GT 0.
      <fs_field> = c_hidratado.
    ENDIF.

    ASSIGN COMPONENT 'RHP_CORTES' OF STRUCTURE <fs_st> TO <fs_field>.
    IF gv_rhpcortes GT 0.
      <fs_field> = c_rhpcortes.
    ENDIF.

    ASSIGN COMPONENT 'LIMPIEZAS' OF STRUCTURE <fs_st> TO <fs_field>.
    IF gv_limpiezas GT 0.
      <fs_field> = c_limpiezas.
    ENDIF.
  ENDLOOP.

*  ENDLOOP.

  "ENDLOOP.
ENDFORM.

FORM set_recuperaciones.
  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.

  DATA: vl_recuperaciones TYPE menge_d,
        vl_texto          TYPE string.

  DATA: vl_base TYPE menge_d, vl_div TYPE menge_d.
*  obj_engorda->get_recuperaciones(
*    EXPORTING
*      i_aufnr  = it_aufnr_end
*    CHANGING
*      ch_recupera = it_recupera
*  ).
*
*  SORT it_recupera BY aufnr budat.
*
*  DATA(vl_sum_dp) = REDUCE #( INIT s TYPE menge_d
*                               FOR wa IN it_recupera WHERE ( wgbez60 = 'RECUPERACIÓN DECOMISOS POLLO' )
*                               NEXT s = s + wa-dmbtr ).
*
*  IF vl_sum_dp LT 0.
*    vl_sum_dp  = vl_sum_dp * -1.
*  ENDIF.
*
*  CLEAR wa_backlog.
*  wa_backlog-wgbez60 = 'RECUPERACIÓN DECOMISOS POLLO'.
*  wa_backlog-valor = vl_sum_dp.
*  APPEND wa_backlog TO it_backlog.
*
*  DATA(vl_sum_poll) = REDUCE #( INIT s TYPE menge_d
*                               FOR wa IN it_recupera WHERE ( wgbez60 = 'POLLINAZA' )
*                               NEXT s = s + wa-dmbtr ).
*
*  IF vl_sum_poll LT 0.
*    vl_sum_poll  = vl_sum_poll * -1.
*  ENDIF.
*
*  CLEAR wa_backlog.
*  wa_backlog-wgbez60 = 'POLLINAZA'.
*  wa_backlog-valor = vl_sum_poll.
*  APPEND wa_backlog TO it_backlog.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_st> TO <fs_field> .
  <fs_field> = TEXT-006.


*  vl_recuperaciones = vl_sum_dp + vl_sum_poll. "se suma recupeación Pollo + Pollinaza
*  vl_texto = TEXT-006.
  READ TABLE it_backlog INTO DATA(wa_log) WITH KEY wgbez60 = 'HARINA MXN'.
  IF sy-subrc EQ 0.
    DATA(vl_harina_mxn) = wa_log-valor.
  ENDIF.

  READ TABLE it_backlog INTO wa_log WITH KEY wgbez60 = 'MENUDENCIA MXN'.
  IF sy-subrc EQ 0.
    DATA(vl_menu_mxn) = wa_log-valor.
  ENDIF.

  READ TABLE it_backlog INTO wa_log WITH KEY wgbez60 = 'KILOS PRODUCIDOS'.
  IF sy-subrc EQ 0.
    DATA(vl_kgs_prod) = wa_log-valor.
  ENDIF.


  DATA(vl_recupera_mx) = vl_harina_mxn + vl_menu_mxn.



  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      IF ls_fcat-fieldname EQ wa_meses-zmonth OR
         ls_fcat-fieldname EQ 'H' OR ls_fcat-fieldname EQ 'M' OR
         ls_fcat-fieldname EQ 'CHIAPAS'.

        vl_base = 0.
        vl_div = 0.
        vl_texto = TEXT-006.
      ELSE.
        vl_base = vl_recupera_mx.
        vl_div = vl_kgs_prod.
        vl_texto = 'PPA'.
      ENDIF.

      PERFORM calcula_columnas
        USING
          vl_base
          vl_div
          ls_fcat-fieldname
          <fs_st>
          vl_texto
        .
    ENDLOOP.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_costo_transf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_costo_transf .

  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_mes>   TYPE any,
                 <fs_field> TYPE any,
                 <fs_acum>  TYPE table.

  DATA: lr_ferth TYPE RANGE OF mara-ferth,
        lv_base  TYPE string.


  DATA: vl_rgbwart     TYPE RANGE OF mseg-bwart,
        wa_rgbwart     LIKE LINE OF vl_rgbwart,
        vl_rgmatnr     TYPE RANGE OF mara-matnr,
        wa_rgmatnr     LIKE LINE OF vl_rgmatnr,
        vl_rgacct      TYPE RANGE OF skat-saknr,
        wa_acct        LIKE LINE OF vl_rgacct,
        vl_mes(3)      TYPE c,
        vl_text        TYPE string,
        vl_mes_ant(2)  TYPE c,
        vl_string      TYPE string,
        vl_fecha_i     TYPE datum, vl_fecha_f TYPE datum,
        vl_find,
        vl_sytabix     TYPE sy-tabix,
        vl_per_sales   TYPE menge_d,
        vl_acum_kgs_pv TYPE menge_d,
        vl_valor_base  TYPE menge_d,
        vl_valor_div   TYPE menge_d.

  DATA num_days    TYPE i.

  DATA: vl_menge  TYPE menge_d, vl_dmbtr TYPE dmbtr_cs,
        vl_concep TYPE maktx.

  DATA: kg_pro           TYPE menge_d, kg_menu TYPE menge_d, kg_merma TYPE menge_d,
        kilos_producidos TYPE menge_d, kg_harina TYPE menge_d.

  DATA it_acct_balances TYPE STANDARD TABLE OF bapi3006_4.

  DATA lv_fecha_inicial TYPE dats.
  DATA cadena TYPE string.
  DATA lv_fecha TYPE dats.
  DATA vl_gjahr TYPE gjahr.
  DATA vl_periodo TYPE co_perio.

  kg_pro = 0.
  kg_menu = 0.
  kg_merma = 0.

  """""""""""""""""""""""""""""""""""""""
  DATA: vl_traspaso_vivos TYPE dmbtr_cs.
  """""""""""""""""""""""""""""""""""""""
  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '261'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '262'.
  APPEND wa_rgbwart TO vl_rgbwart.


  lv_fecha = so_fecha-low.

  vl_gjahr = lv_fecha+0(4).

  vl_periodo =  |{ lv_fecha+4(2) ALPHA = IN }|.


  IF vl_periodo = '001'.
    vl_gjahr = vl_gjahr - 1.
  ENDIF.

  IF vl_periodo = '001'.
    vl_periodo = '012'.
  ELSE.
    vl_periodo = vl_periodo - 1.
  ENDIF.


  CONCATENATE vl_gjahr vl_periodo+1(2) '01' INTO cadena.
  lv_fecha_inicial = cadena.

  DATA(lv_fecha_mes) =
    cl_reca_date=>set_to_end_of_month( lv_fecha_inicial ).




  obj_engorda->get_ch_cost_trsf(
            EXPORTING
              i_fecha  = so_fecha-low
              CHANGING
              ch_ch_cost_trsf = it_ch_cost_trsf ).

  DATA(vl_sum_chiapas) = REDUCE #( INIT s TYPE fins_vhcur12
                              FOR wa IN it_ch_cost_trsf
                              NEXT s = s + wa-mes ).


  obj_engorda->get_pv_cost_trsf(
             EXPORTING
               i_fecha  = so_fecha-low
               CHANGING
               ch_pv_cost_trsf = it_pv_cost_trsf ).

  DATA(vl_sum_pv) = REDUCE #( INIT s TYPE fins_vhcur12
                              FOR wa IN it_pv_cost_trsf
                              NEXT s = s + wa-mes ).



  IF it_aufnr_end IS NOT INITIAL.

    obj_engorda->get_mb51(
           EXPORTING
             i_aufnr  = it_aufnr_end
             i_rgbwart = vl_rgbwart
           CHANGING
             ch_mb51 = it_mb51 ).






    DELETE it_mb51 WHERE ( matkl NE 'PT0001' AND racct NE '0504025051' AND racct NE'0504025106' ).

    "CALCULO PARA POLLO VIVO"""""""""""""""""""""""""""""""""""""""""""""""""
    vl_per_sales = 0.
    wa_acct-sign = 'I'.
    wa_acct-option = 'EQ'.
    wa_acct-low = '0501001004'.
    APPEND wa_acct TO vl_rgacct.

    wa_acct-sign = 'I'.
    wa_acct-option = 'EQ'.
    wa_acct-low = '0501001005'.
    APPEND wa_acct TO vl_rgacct.

    wa_acct-sign = 'I'.
    wa_acct-option = 'EQ'.
    wa_acct-low = '0501001007'.
    APPEND wa_acct TO vl_rgacct.

    wa_acct-sign = 'I'.
    wa_acct-option = 'EQ'.
    wa_acct-low = '0501001020'.
    APPEND wa_acct TO vl_rgacct.

    wa_acct-sign = 'I'.
    wa_acct-option = 'EQ'.
    wa_acct-low = '0501001021'.
    APPEND wa_acct TO vl_rgacct.

    wa_acct-sign = 'I'.
    wa_acct-option = 'EQ'.
    wa_acct-low = '0501001022'.
    APPEND wa_acct TO vl_rgacct.

    wa_acct-sign = 'I'.
    wa_acct-option = 'EQ'.
    wa_acct-low = '0501001023'.
    APPEND wa_acct TO vl_rgacct.

    wa_acct-sign = 'I'.
    wa_acct-option = 'EQ'.
    wa_acct-low = '0501001024'.
    APPEND wa_acct TO vl_rgacct.

    wa_acct-sign = 'I'.
    wa_acct-option = 'EQ'.
    wa_acct-low = '0504001004'.
    APPEND wa_acct TO vl_rgacct.


    vl_mes_ant = so_fecha-low+4(2).
    IF vl_mes_ant EQ '01'.
      vl_mes_ant = '012'.
    ELSE.
      vl_mes_ant = vl_mes_ant - 1.
      vl_mes_ant = |{ vl_mes_ant ALPHA = IN }|.
    ENDIF.

    LOOP AT vl_rgacct INTO wa_acct.


      CALL FUNCTION 'BAPI_GL_ACC_GETPERIODBALANCES'
        EXPORTING
          companycode      = 'SA01'
          glacct           = wa_acct-low
          fiscalyear       = so_fecha-low+0(4)
          currencytype     = '10'
        TABLES
          account_balances = it_acct_balances.

      IF it_acct_balances IS NOT INITIAL.
        DATA(wa_sales) = it_acct_balances[ fis_period = vl_mes_ant ].
        IF sy-subrc EQ 0.
          vl_per_sales = vl_per_sales + wa_sales-per_sales.
        ENDIF.

      ENDIF.
    ENDLOOP.

    "IF vl_per_sales GT 0.
    IF vl_sum_pv GT 0.
      "vl_per_sales = vl_per_sales / 30.
      "vl_acum_kgs_pv = gv_cant_pv_kg + gv_canth_kg + gv_cantm_kg + gv_chiapas_kg.
      vl_acum_kgs_pv = gv_cant_pv_kg_m + gv_canth_kg_m + gv_cantm_kg_m.
    ELSE.
      vl_per_sales = 0.
      vl_acum_kgs_pv = 0.
    ENDIF.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    LOOP AT gv_tt_meses INTO DATA(wa_meses).

      DATA(aux_aufnr) = it_aufnr_end[].
*      CONCATENATE so_fecha-low+0(4) wa_meses-zmonth+1(2) so_fecha-low+6(2) INTO vl_string.
*      vl_fecha_i = vl_string.
*
*
*      CONCATENATE so_fecha-low+0(4) wa_meses-zmonth+1(2) so_fecha-low+6(2) INTO vl_string.
*      vl_fecha_f = vl_string.

      DELETE aux_aufnr WHERE getri NOT BETWEEN lv_fecha_inicial AND lv_fecha_mes.

      REFRESH it_aux_out.

      LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
        CLEAR wa_aux_out.

        LOOP AT it_mb51 INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr.
          vl_mes = wa_meses-zmonth.
          vl_menge = wa_mb51-menge.
          vl_dmbtr = wa_mb51-dmbtr.
          vl_concep = wa_mb51-wgbez60.
          IF vl_concep EQ 'TRASP. DIARIO POLLO VIVO'.
            PERFORM calc_acum USING vl_concep
                                    '0.00'
                                    vl_menge
                                    vl_dmbtr.
          ENDIF.
        ENDLOOP. "acumulado transferencia PV


      ENDLOOP. "órdenes

      "calcular Kilos a proceso
      lv_base = 'PPRO'.
      lr_ferth = VALUE #(
  ( sign = 'I' option = 'CP' low = lv_base && '*' )  " patrón dinámico
).

      obj_engorda->get_kgs_cost_trans(
                 EXPORTING
                   i_fecha_i  = lv_fecha_inicial
                   i_fecha_f  = lv_fecha_mes
                   i_ferth   = lr_ferth
                   i_rgbwart = vl_rgbwart
                 CHANGING
                   ch_kgs_cost_trans = it_kg_cost_trans ).

      REFRESH vl_rgbwart.

      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '101'.
      APPEND wa_rgbwart TO vl_rgbwart.

      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '102'.
      APPEND wa_rgbwart TO vl_rgbwart.

      lv_base = 'MEND'.
      REFRESH lr_ferth.
      lr_ferth = VALUE #(
  ( sign = 'I' option = 'CP' low = lv_base && '*' )  " patrón dinámico
).

      obj_engorda->get_kgs_cost_trans(
              EXPORTING
                i_fecha_i  = lv_fecha_inicial
                i_fecha_f  = lv_fecha_mes
                i_ferth   = lr_ferth
                i_rgbwart = vl_rgbwart
              CHANGING
                ch_kgs_cost_trans = it_kg_menudencia ).

      lv_base = 'MER1'.
      REFRESH lr_ferth.
      lr_ferth = VALUE #(
  ( sign = 'I' option = 'CP' low = lv_base && '*' )  " patrón dinámico
).

      obj_engorda->get_kgs_cost_trans(
                 EXPORTING
                   i_fecha_i  = lv_fecha_inicial
                   i_fecha_f  = lv_fecha_mes
                   i_ferth   = lr_ferth
                   i_rgbwart = vl_rgbwart
                 CHANGING
                   ch_kgs_cost_trans = it_kg_merma ).

      lv_base = 'RECP'.
      REFRESH lr_ferth.
      lr_ferth = VALUE #(
  ( sign = 'I' option = 'CP' low = lv_base && '*' )  " patrón dinámico
).

      obj_engorda->get_kgs_cost_trans(
           EXPORTING
             i_fecha_i  = lv_fecha_inicial
             i_fecha_f  = lv_fecha_mes
             i_ferth   = lr_ferth
             i_rgbwart = vl_rgbwart
           CHANGING
             ch_kgs_cost_trans = it_kg_harina ).

      APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      <fs_field> = TEXT-002.

      ASSIGN COMPONENT wa_meses-zmonth OF STRUCTURE <fs_st> TO <fs_field>.

      READ TABLE it_aux_out INTO DATA(kilos_tras) INDEX 1.
      IF sy-subrc EQ 0.
        gv_trasd_vivo = kilos_tras-month.
        wa_backlog-wgbez60 = 'KILOS TRASP. VIVO'.
        wa_backlog-valor = kg_pro.
        APPEND wa_backlog TO it_backlog.
      ENDIF.


      READ TABLE it_kg_cost_trans INTO DATA(kilos_pro) INDEX 1.
      IF sy-subrc EQ 0.
        kg_pro = kilos_pro-menge.
        wa_backlog-wgbez60 = 'KILOS A PROCESO'.
        wa_backlog-valor = kg_pro.
        APPEND wa_backlog TO it_backlog.

      ENDIF.

      READ TABLE it_kg_menudencia INTO DATA(kilos_menu) INDEX 1.
      IF sy-subrc EQ 0.
        kg_menu = kilos_menu-menge.
        wa_backlog-wgbez60 = 'MENUDENCIA KGS'.
        wa_backlog-valor = kg_menu.
        APPEND wa_backlog TO it_backlog.

        wa_backlog-wgbez60 = 'MENUDENCIA MXN'.
        wa_backlog-valor = kilos_menu-dmbtr.
        APPEND wa_backlog TO it_backlog.

      ENDIF.

      READ TABLE it_kg_harina INTO DATA(kilos_harina) INDEX 1.
      IF sy-subrc EQ 0.
        kg_harina = kilos_menu-menge.
        wa_backlog-wgbez60 = 'HARINA KGS'.
        wa_backlog-valor = kg_harina.
        APPEND wa_backlog TO it_backlog.

        wa_backlog-wgbez60 = 'HARINA MXN'.
        wa_backlog-valor = kilos_harina-dmbtr.
        APPEND wa_backlog TO it_backlog.
      ENDIF.


      READ TABLE it_kg_merma INTO DATA(kilos_merma) INDEX 1.
      IF sy-subrc EQ 0.
        kg_merma = kilos_merma-menge.
        wa_backlog-wgbez60 = 'MERMA KGS'.
        wa_backlog-valor = kg_merma.
        APPEND wa_backlog TO it_backlog.

        wa_backlog-wgbez60 = 'MERMA MXN'.
        wa_backlog-valor = kilos_merma-dmbtr.
        APPEND wa_backlog TO it_backlog.
      ENDIF.
      kilos_producidos = kilos_pro-menge - kilos_menu-menge - kilos_merma-menge.

      wa_backlog-wgbez60 = 'KILOS PRODUCIDOS'.
      wa_backlog-valor = kilos_producidos.
      APPEND wa_backlog TO it_backlog.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "<fs_field> = kilos_tras-month  / kilos_producidos  .

      LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ).
        IF ls_fcat-fieldname EQ wa_meses-zmonth OR
           ls_fcat-fieldname EQ 'H' OR ls_fcat-fieldname EQ 'M'
           .

          vl_valor_base = vl_sum_pv. "vl_per_sales.
          vl_valor_div = vl_acum_kgs_pv.
          vl_text = TEXT-002.
        ELSEIF ls_fcat-fieldname EQ 'CHIAPAS'.
          vl_valor_base = vl_sum_chiapas.
          vl_valor_div = gv_chiapas_kg_m.
          vl_text = TEXT-002.
        ELSE.
*          vl_valor_base = gv_trasd_vivo.
*          vl_valor_div = kilos_producidos.
          vl_valor_base = vl_sum_pv. "vl_per_sales.
          vl_valor_div = vl_acum_kgs_pv.
          vl_text = TEXT-002.
          "vl_text = 'PPA'.
        ENDIF.

        PERFORM calcula_columnas
         USING
           vl_valor_base
           vl_valor_div
           ls_fcat-fieldname
           <fs_st>
           vl_text
           .

      ENDLOOP.

    ENDLOOP. "meses

  ENDIF."ultimo if
ENDFORM.

FORM set_rendimientos.

  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_mes>   TYPE any,
                 <fs_field> TYPE any,
                 <fs_acum>  TYPE table.

  DATA: vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgdauat  TYPE RANGE OF afpo-dauat,
        wa_rgdauat  LIKE LINE OF vl_rgdauat,
        vl_fechas   TYPE RANGE OF afko-gltri,
        vl_wfechas  LIKE LINE OF vl_fechas,
        vl_rgaufnr  TYPE RANGE OF afko-aufnr,
        vl_wrgaufnr LIKE LINE OF vl_rgaufnr,
        vl_string   TYPE string,
        vl_fecha_i  TYPE datum, vl_fecha_f TYPE datum.
  DATA: vl_base  TYPE menge_d, vl_div TYPE menge_d,vl_texto TYPE string.

  DATA: lv_base  TYPE string,
        lr_ferth TYPE RANGE OF mara-ferth.


  DATA: vl_menge  TYPE menge_d, vl_dmbtr TYPE dmbtr_cs,
        vl_concep TYPE maktx.

  DATA: kilos_producidos       TYPE menge_d,
        vl_rosticeros          TYPE menge_d, vl_produccion_pa02 TYPE menge_d,
        vl_cadera_h            TYPE menge_d, total_kilos_producidos TYPE menge_d,
        vl_tot_kgs_pro_netos   TYPE menge_d.

  DATA: vl_Consumo_Rosc TYPE menge_d,vl_pro_rosc TYPE menge_d,
        vl_merma_Dest   TYPE menge_d.

  DATA: vl_tot_kgs_pro      TYPE menge_d, vl_kgs_proceso TYPE menge_d,
        vl_tot_kgs_pro_neto TYPE menge_d, vl_rendimiento TYPE menge_d.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    CONCATENATE so_fecha-low+0(4) wa_meses-zmonth+1(2) so_fecha-low+6(2) INTO vl_string.
    vl_fecha_i = vl_string.


    CONCATENATE so_fecha-low+0(4) wa_meses-zmonth+1(2) so_fecha-low+6(2) INTO vl_string.
    vl_fecha_f = vl_string.

    wa_rgbwart-sign = 'I'.
    wa_rgbwart-option = 'EQ'.
    wa_rgbwart-low = '261'.
    APPEND wa_rgbwart TO vl_rgbwart.

    wa_rgbwart-sign = 'I'.
    wa_rgbwart-option = 'EQ'.
    wa_rgbwart-low = '262'.
    APPEND wa_rgbwart TO vl_rgbwart.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA02'.
    APPEND wa_rgdauat TO vl_rgdauat.

    lv_base = 'ROSC'.
    REFRESH lr_ferth.
    lr_ferth = VALUE #(
( sign = 'I' option = 'CP' low = lv_base && '*' )  " patrón dinámico
).

    obj_engorda->get_kgs_cost_trans(
              EXPORTING
                i_fecha_i  = vl_fecha_i
                i_fecha_f  = vl_fecha_f
                i_ferth   = lr_ferth
                i_rgbwart = vl_rgbwart
              CHANGING
                ch_kgs_cost_trans = it_kg_rns ).

    REFRESH vl_rgbwart.

    wa_rgbwart-sign = 'I'.
    wa_rgbwart-option = 'EQ'.
    wa_rgbwart-low = '101'.
    APPEND wa_rgbwart TO vl_rgbwart.

    wa_rgbwart-sign = 'I'.
    wa_rgbwart-option = 'EQ'.
    wa_rgbwart-low = '102'.
    APPEND wa_rgbwart TO vl_rgbwart.

    vl_wfechas-high = so_fecha-low.
    vl_wfechas-loW = so_fecha-low.
    vl_wfechas-option = 'BT'."so_fecha-option.
    vl_wfechas-sign = so_fecha-sign.
    APPEND vl_wfechas TO vl_fechas.

    REFRESH it_aufnr_end.
    obj_engorda->get_aufnr_cte_ren(
     EXPORTING
       p_gjahr   =  so_fecha-low+0(4)
       p_fecha  = vl_fechas
       p_clorder = vl_rgdauat
       p_tipo    = 'PPA'
     CHANGING
       i_tabla   = it_aufnr_end
     ).

    SORT it_aufnr_end BY aufnr getri.

    LOOP AT it_aufnr_end INTO DATA(wa_aufnr).
      vl_wrgaufnr-sign = 'I'.
      vl_wrgaufnr-option = 'EQ'.
      vl_wrgaufnr-low = wa_aufnr-aufnr.
      APPEND vl_wrgaufnr TO vl_rgaufnr.

    ENDLOOP.

    obj_engorda->get_kgs_pro_merma(
              EXPORTING
                i_fecha_i  = vl_fecha_i
                i_fecha_f  = vl_fecha_f
                i_rgaufnr  = vl_rgaufnr
                i_rgbwart = vl_rgbwart
              CHANGING
                ch_kgs_cost_trans = it_kg_pro_merma ).

    lv_base = 'CADH'.
    REFRESH lr_ferth.
    lr_ferth = VALUE #(
( sign = 'I' option = 'CP' low = lv_base && '*' )  " patrón dinámico
).

    obj_engorda->get_kgs_cost_trans(
              EXPORTING
                i_fecha_i  = vl_fecha_i
                i_fecha_f  = vl_fecha_f
                i_ferth   = lr_ferth
                i_rgaufnr = vl_rgaufnr
                i_rgbwart = vl_rgbwart
              CHANGING
                ch_kgs_cost_trans = it_kg_cad_h ).

    "reads a las tablas
    TRY.
        DATA(wa_rosticero) = it_kg_rns[ 1 ].
        vl_consumo_rosc = wa_rosticero-menge.
      CATCH cx_sy_itab_line_not_found .
        vl_consumo_rosc = 0.
        MESSAGE 'kgs_rosc not found' TYPE 'S'.

    ENDTRY.

    TRY.
        DATA(wa_pro_merma) = it_kg_pro_merma[ 1 ].
        vl_pro_rosc = wa_pro_merma-menge.
      CATCH cx_sy_itab_line_not_found .
        vl_pro_rosc = 0.
        MESSAGE 'pro_merma not found' TYPE 'S'.
    ENDTRY.

    TRY.
        DATA(wa_cad_h) = it_kg_cad_h[ 1 ].
        vl_cadera_h = wa_cad_h-menge.
      CATCH cx_sy_itab_line_not_found .
        vl_cadera_h = 0.
        MESSAGE 'cad_h not found' TYPE 'S'.
    ENDTRY.

    TRY.
        DATA(wa_kgs_proc) = it_backlog[ wgbez60 = 'KILOS A PROCESO' ].
        vl_kgs_proceso = wa_kgs_proc-valor.
      CATCH cx_sy_itab_line_not_found .
        vl_kgs_proceso = 0.
        MESSAGE 'kgs_proc not found' TYPE 'S'.
    ENDTRY.

    TRY.
        DATA(wa_kgs_prod) = it_backlog[ wgbez60 = 'KILOS PRODUCIDOS' ].
        vl_tot_kgs_pro = wa_kgs_prod-valor.
      CATCH cx_sy_itab_line_not_found .
        vl_tot_kgs_pro = 0.
        MESSAGE 'kgs_prod not found' TYPE 'S'.
    ENDTRY.

    vl_consumo_rosc = vl_consumo_rosc - vl_pro_rosc.

    vl_tot_kgs_pro_neto = vl_tot_kgs_pro - vl_consumo_rosc - vl_cadera_h.

    IF vl_kgs_proceso GT 0.
      vl_rendimiento = ( vl_tot_kgs_pro_neto / vl_kgs_proceso ) * 100.

    ELSE.
      vl_rendimiento = '0.00'.
    ENDIF.

    wa_backlog-wgbez60 = 'MERMA DESTAZADA'.
    wa_backlog-valor = vl_consumo_rosc.
    APPEND wa_backlog TO it_backlog.

    wa_backlog-wgbez60 = 'TOTAL KILOS PROD. NETOS'.
    wa_backlog-valor = vl_tot_kgs_pro_neto.
    APPEND wa_backlog TO it_backlog.

    wa_backlog-wgbez60 = TEXT-003.
    wa_backlog-valor = vl_rendimiento.
    APPEND wa_backlog TO it_backlog.

    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = TEXT-003.

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname  ).

      IF ls_fcat-fieldname EQ wa_meses-zmonth OR
       ls_fcat-fieldname EQ 'H' OR ls_fcat-fieldname EQ 'M' OR
       ls_fcat-fieldname EQ 'CHIAPAS'.

        vl_base = 0.
        vl_div = 0.
        vl_texto = TEXT-006.
      ELSE.
        vl_base = vl_rendimiento.
        vl_div = 1.
        vl_texto = 'PPA'.
      ENDIF.
      PERFORM calcula_columnas
        USING
          vl_base
          vl_div
          ls_fcat-fieldname
         <fs_st>
         vl_texto
        .
    ENDLOOP.
  ENDLOOP.

ENDFORM.

FORM flete_gto_transf. "1

  FIELD-SYMBOLS: <fs_tt>    TYPE table,
                 <fs_st>    TYPE any,
                 <fs_mes>   TYPE any,
                 <fs_field> TYPE any,
                 <fs_acum>  TYPE table.

  DATA: vl_piezas_pv TYPE p DECIMALS 2, vl_kilos_pv TYPE p DECIMALS 2,
        vl_peso_prom TYPE menge_d.

  DATA: rg_plnbez TYPE RANGE OF afko-plnbez,
        wa_plnbez LIKE LINE OF rg_plnbez.

  DATA: rg_aufnr TYPE RANGE OF afko-aufnr,
        wa_aufnr LIKE LINE OF rg_aufnr.


  DATA: vl_st14pp TYPE menge_d,
        vl_st15pp TYPE menge_d,
        vl_st16pp TYPE menge_d,
        vl_st17pp TYPE menge_d.

  TYPES: BEGIN OF st_ordenes_pp,
           aufnr    TYPE aufnr,
           matnr    TYPE matnr,
           kilos    TYPE menge_d,
           piezas   TYPE menge_d,
           pp       TYPE menge_d,
           contador TYPE p DECIMALS 2,
         END OF st_ordenes_pp.

  DATA: vl_valor_base TYPE menge_d, vl_valor_div TYPE menge_d.
  DATA: it_ordenes_pp TYPE STANDARD TABLE OF st_ordenes_pp,
        wa_ordenes_pp LIKE LINE OF it_ordenes_pp.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-001.

  wa_plnbez-sign = 'I'.
  wa_plnbez-option = 'EQ'.
  wa_plnbez-low = 'ST-100014'.
  APPEND wa_plnbez TO rg_plnbez.

  wa_plnbez-sign = 'I'.
  wa_plnbez-option = 'EQ'.
  wa_plnbez-low = 'ST-100015'.
  APPEND wa_plnbez TO rg_plnbez.

  wa_plnbez-sign = 'I'.
  wa_plnbez-option = 'EQ'.
  wa_plnbez-low = 'ST-100016'.
  APPEND wa_plnbez TO rg_plnbez.

  wa_plnbez-sign = 'I'.
  wa_plnbez-option = 'EQ'.
  wa_plnbez-low = 'ST-100017'.
  APPEND wa_plnbez TO rg_plnbez.



  DATA(it_ppa) = it_aufnr_end[].

  SORT it_ppa BY plnbez.

  DELETE it_ppa WHERE plnbez NOT IN rg_plnbez.

  DATA(it_single_aufnr) = it_ppa[].

  SORT it_single_aufnr BY aufnr.
  DELETE ADJACENT DUPLICATES FROM it_single_aufnr COMPARING aufnr.

  LOOP AT it_single_aufnr INTO DATA(wa_it_aufnr).
    wa_aufnr-sign = 'I'.
    wa_aufnr-option = 'EQ'.
    wa_aufnr-low = wa_it_aufnr-aufnr.
    APPEND wa_aufnr TO rg_aufnr.
  ENDLOOP.

  SELECT aufnr,matnr,
    CASE WHEN matnr EQ '000000000000500021' OR matnr EQ '000000000000500022' THEN
    SUM( /cwm/menge ) END  AS kilos,
    CASE WHEN matnr EQ '000000000000500021' OR matnr EQ '000000000000500022' THEN
    SUM( menge ) END AS piezas,
    '0.00' AS pp

    FROM mseg
  WHERE aufnr IN @rg_aufnr
*  AND matnr IN ('000000000000500021','000000000000500022' )
    GROUP BY aufnr,matnr
    INTO TABLE @DATA(it_mseg_ppa).

  LOOP AT it_mseg_ppa ASSIGNING FIELD-SYMBOL(<fsst>).
    vl_kilos_pv = <fsst>-kilos.
    vl_piezas_pv = <fsst>-piezas.
    <fsst>-pp = vl_kilos_pv / vl_piezas_pv.
  ENDLOOP.

  SORT it_mseg_ppa BY aufnr matnr DESCENDING.

  LOOP AT it_single_aufnr INTO wa_it_aufnr.

*    READ TABLE it_mseg_ppa INTO DATA(wa_mseg) WITH KEY aufnr = wa_it_aufnr-aufnr.
    LOOP AT it_mseg_ppa INTO DATA(wa_mseg) WHERE aufnr = wa_it_aufnr-aufnr.
      IF wa_mseg-matnr CP 'ST*' .
        wa_ordenes_pp-matnr = wa_mseg-matnr.
        CONTINUE.
      ENDIF.
      wa_ordenes_pp-aufnr = wa_mseg-aufnr.
      wa_ordenes_pp-kilos = wa_mseg-kilos.
      wa_ordenes_pp-piezas = wa_mseg-piezas.
      wa_ordenes_pp-pp = wa_mseg-pp.
      wa_ordenes_pp-contador = '1.00'.
      COLLECT wa_ordenes_pp INTO it_ordenes_pp.
    ENDLOOP.
  ENDLOOP.

  DATA(aux_ordenes) = it_ordenes_pp[].
  SORT aux_ordenes BY matnr DESCENDING.
  CLEAR it_ordenes_pp[].

  LOOP AT aux_ordenes INTO DATA(aux).
    CLEAR wa_ordenes_pp.

    wa_ordenes_pp-aufnr = space.
    wa_ordenes_pp-matnr = aux-matnr.
    wa_ordenes_pp-kilos = aux-kilos.
    wa_ordenes_pp-piezas = aux-piezas.
    wa_ordenes_pp-pp = aux-pp.
    wa_ordenes_pp-contador = '1.00'.
    COLLECT wa_ordenes_pp INTO it_ordenes_pp.
  ENDLOOP.


  LOOP AT it_ordenes_pp ASSIGNING FIELD-SYMBOL(<fs_order>).
    <fs_order>-pp = <fs_order>-pp / <fs_order>-contador.
  ENDLOOP.


  LOOP AT gv_tt_meses INTO DATA(wa_meses).


    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      CASE ls_fcat-fieldname.
        WHEN 'H'.
          vl_valor_base = 0."gv_canth_kg.
          vl_valor_div = 0."gv_canth.
        WHEN 'M'.
          vl_valor_base = 0."gv_cantm_kg.
          vl_valor_div = 0."gv_cantm.
        WHEN 'CHIAPAS'.
          vl_valor_base = 0."gv_chiapas_kg.
          vl_valor_div = 0."gv_chiapas.
        WHEN 'RNS_ENTERO'.
                                                            "st-100014
          READ TABLE it_ordenes_pp INTO DATA(wapp) WITH KEY matnr = 'ST-100014'.
          vl_valor_base = wapp-pp.
          vl_valor_div = 0.
        WHEN 'RNS_CORTES'.
                                                            "st-100014
          CLEAR wapp.
          READ TABLE it_ordenes_pp INTO wapp WITH KEY matnr = 'ST-100014'.
          vl_valor_base = wapp-pp.
          vl_valor_div = 0.
        WHEN 'RTC'.
                                                            "st-100017
          CLEAR wapp.
          READ TABLE it_ordenes_pp INTO wapp WITH KEY matnr = 'ST-100017'.
          vl_valor_base = wapp-pp.
          vl_valor_div = 0.
        WHEN 'PINTADO_P'.
                                                            "st-100016
          CLEAR wapp.
          READ TABLE it_ordenes_pp INTO wapp WITH KEY matnr = 'ST-100016'.
          vl_valor_base = wapp-pp.
          vl_valor_div = 0.
        WHEN 'HIDRATADO'.
                                                            "st-100016
          CLEAR wapp.
          READ TABLE it_ordenes_pp INTO wapp WITH KEY matnr = 'ST-100016'.
          vl_valor_base = wapp-pp.
          vl_valor_div = 0.
        WHEN 'RHP_CORTES'.
                                                            "st-100016
          CLEAR wapp.
          READ TABLE it_ordenes_pp INTO wapp WITH KEY matnr = 'ST-100016'.
          vl_valor_base = wapp-pp.
          vl_valor_div = 0.
        WHEN 'LIMPIEZAS'.
                                                            "st-100015
          CLEAR wapp.
          READ TABLE it_ordenes_pp INTO wapp WITH KEY matnr = 'ST-100015'.
          vl_valor_base = wapp-pp.
          vl_valor_div = 0.
        WHEN OTHERS.
          IF ls_fcat-fieldname CP 'M0*'.
            vl_valor_base = 0."gv_cant_pv_kg.
            vl_valor_div = 0."gv_cant_pv.
          ENDIF.
      ENDCASE.

      PERFORM calcula_columnas
         USING
           vl_valor_base
           vl_valor_div
           ls_fcat-fieldname
           <fs_st>
          TEXT-001
        .

    ENDLOOP.
  ENDLOOP.

ENDFORM.

FORM flete_gto_transf_2.

  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.

  DATA: vl_base TYPE menge_d, vl_div TYPE menge_d.


  DATA: vl_rg_objnr   TYPE RANGE OF cosp-objnr,
        wa_rg_objnr   LIKE LINE OF vl_rg_objnr,
        vl_rg_kstar   TYPE RANGE OF cosp-kstar,
        wa_rg_kstar   LIKE LINE OF vl_rg_kstar,
        rg_plnbez     TYPE RANGE OF afko-plnbez,
        wa_plnbez     LIKE LINE OF rg_plnbez,
        vl_cant_div   TYPE menge_d,
        vl_str_backl  TYPE string,
        vl_valor_base TYPE menge_d.


  DATA: vl_gjahr   TYPE gjahr,vl_periodo TYPE co_perio.



  wa_rg_kstar-loW = 'S42SG0135'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.

  wa_rg_kstar-loW = 'S42SG0173'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.



  vl_gjahr = so_fecha-low+0(4).

  vl_periodo =  |{ so_fecha-low+4(2) ALPHA = IN }|.


  IF vl_periodo = '001'.
    vl_gjahr = vl_gjahr - 1.
  ENDIF.

  IF vl_periodo = '001'.
    vl_periodo = '012'.
  ELSE.
    vl_periodo = vl_periodo - 1.
  ENDIF.




  obj_engorda->get_flete_gto_transf(
        EXPORTING
          i_gjahr  = vl_gjahr
          i_month  = vl_periodo
          i_gpo_kostl = 'PPTARIFAS.23'
          i_gpo_kstar  = vl_rg_kstar
        CHANGING
          ch_flete_transf = it_flete_transf ).

  DATA(vl_sum_ctas) = REDUCE #( INIT s TYPE menge_d
                               FOR wa IN it_flete_transf
                               NEXT s = s + wa-mes ).
  vl_base = vl_sum_ctas .

  "ppa""""
  obj_engorda->get_acdoca(
       EXPORTING
         i_aufnr  = it_aufnr_end
       CHANGING
         ch_acdoca = it_acdoca
     ).

  SORT it_acdoca BY txt50.

  DATA(vl_carga_fabril) = REDUCE #( INIT x TYPE fins_vhcur12
                                FOR wa1 IN it_acdoca WHERE ( txt50 = 'CARGA FABRIL' )
                                NEXT x = x + wa1-hsl ).

  DATA(vl_mano_obra) = REDUCE #( INIT x TYPE fins_vhcur12
                                FOR wa1 IN it_acdoca WHERE ( txt50 = 'MANO DE OBRA' )
                                NEXT x = x + wa1-hsl ).

  DATA(vl_tiempo_maquina) = REDUCE #( INIT x TYPE fins_vhcur12
                                FOR wa1 IN it_acdoca WHERE ( txt50 = 'TIEMPO MÁQUINA' )
                                NEXT x = x + wa1-hsl ).

  """"""""
  DATA(vl_suma_indirectos) = vl_carga_fabril + vl_mano_obra + vl_tiempo_maquina.

  vl_sum_ctas = vl_sum_ctas + vl_suma_indirectos.

  """"""""""""""""""""""""kilos producidos"""""""""""""""""
  DATA(wa_kgs_producidos) = it_backlog[ wgbez60 = 'KILOS PRODUCIDOS' ].

  DATA(vl_kgs_prods) = wa_kgs_producidos-valor.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-005.

  "se calcula la división para PPA
  """"""""""""""""""""""""""""""""""""
  wa_plnbez-sign = 'I'.
  wa_plnbez-option = 'EQ'.
  wa_plnbez-low = 'ST-100014'.
  APPEND wa_plnbez TO rg_plnbez.

  wa_plnbez-sign = 'I'.
  wa_plnbez-option = 'EQ'.
  wa_plnbez-low = 'ST-100015'.
  APPEND wa_plnbez TO rg_plnbez.

  wa_plnbez-sign = 'I'.
  wa_plnbez-option = 'EQ'.
  wa_plnbez-low = 'ST-100016'.
  APPEND wa_plnbez TO rg_plnbez.

  wa_plnbez-sign = 'I'.
  wa_plnbez-option = 'EQ'.
  wa_plnbez-low = 'ST-100017'.
  APPEND wa_plnbez TO rg_plnbez.

  SELECT matnr,
     SUM( CASE WHEN bwart = '102' THEN menge * -1 ELSE menge END ) AS kilos
      FROM mseg
    WHERE matnr IN @rg_plnbez
     AND budat_mkpf EQ @so_fecha-low
     AND bwart IN ('101','102')
      GROUP BY matnr
      INTO TABLE @DATA(it_kgs_ppa).

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .
      IF ls_fcat-fieldname EQ wa_meses-zmonth OR
         ls_fcat-fieldname EQ 'H' OR ls_fcat-fieldname EQ 'M' OR
         ls_fcat-fieldname EQ 'CHIAPAS'.

        vl_base = 0.
        vl_div = 0.
      ELSE.
        vl_base = vl_sum_ctas.

        CASE ls_fcat-fieldname.

          WHEN 'RNS_ENTERO'.
                                                            "st-100014
*            READ TABLE it_kgs_ppa INTO DATA(wapp) WITH KEY matnr = 'ST-100014'.
            vl_div = vl_kgs_prods. "gv_rnsentero_m. "wapp-kilos.

          WHEN 'RNS_CORTES'.
                                                            "st-100014
*            CLEAR wapp.
*            READ TABLE it_kgs_ppa  INTO wapp WITH KEY matnr = 'ST-100014'.
            vl_div = vl_kgs_prods." gv_rnscortes_m. " wapp-kilos.

          WHEN 'RTC'.
                                                            "st-100017
*            CLEAR wapp.
*            READ TABLE it_kgs_ppa  INTO wapp WITH KEY matnr = 'ST-100017'.
            vl_div = vl_kgs_prods."gv_rtc_m. "wapp-kilos.

          WHEN 'PINTADO_P'.
                                                            "st-100016
*            CLEAR wapp.
*            READ TABLE it_kgs_ppa  INTO wapp WITH KEY matnr = 'ST-100016'.
            vl_div = vl_kgs_prods."gv_pintadopesado_m. "wapp-kilos.

          WHEN 'HIDRATADO'.
                                                            "st-100016
*            CLEAR wapp.
*            READ TABLE it_kgs_ppa  INTO wapp WITH KEY matnr = 'ST-100016'.
            vl_div = vl_kgs_prods."gv_hidratado_m."wapp-kilos.

          WHEN 'RHP_CORTES'.
                                                            "st-100016
*            CLEAR wapp.
*            READ TABLE it_kgs_ppa  INTO wapp WITH KEY matnr = 'ST-100016'.
            vl_div = vl_kgs_prods."gv_rhpcortes_m."wapp-kilos.

          WHEN 'LIMPIEZAS'.
                                                            "st-100015
*            CLEAR wapp.
*            READ TABLE it_kgs_ppa  INTO wapp WITH KEY matnr = 'ST-100015'.
            vl_div = vl_kgs_prods."gv_limpiezas_m."wapp-kilos.

        ENDCASE.

      ENDIF.

      IF vl_div EQ 0.
        vl_base = 0.
      ENDIF.


      PERFORM calcula_columnas
       USING
         vl_base
         vl_div
         ls_fcat-fieldname
         <fs_st>
        TEXT-005
      .
    ENDLOOP.
  ENDLOOP.
ENDFORM.

FORM precio_vta_kg_uni.

  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.


  DATA: vl_base TYPE menge_d, vl_div TYPE menge_d.


  DATA: vl_rg_ferth TYPE RANGE OF mara-ferth,
        wa_rg_ferth LIKE LINE OF vl_rg_ferth,
        vl_rg_kstar TYPE RANGE OF cosp-kstar,
        wa_rg_kstar LIKE LINE OF vl_rg_kstar,
        vl_rg_werks TYPE RANGE OF t001w-werks,
        wa_rg_werks LIKE LINE OF vl_rg_werks.

  wa_rg_kstar-loW = '0401004001'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.

  wa_rg_kstar-loW = '0401004002'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.

  wa_rg_kstar-loW = '0401004003'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.

  wa_rg_kstar-loW = '0401005002'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.

  wa_rg_kstar-loW = '0401010001'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.

  wa_rg_kstar-loW = '0401012001'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.

  wa_rg_kstar-loW = '0401023001'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.

  wa_rg_kstar-loW = '0402002001'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.


*  obj_engorda->get_ventas_netas(
*        EXPORTING
*          i_fecha  = so_fecha-low
*          i_gpo_kstar  = vl_rg_kstar
*        CHANGING
*          ch_vtas_netas = it_vtas_netas ).
*
*  DATA(vl_sum_vtas) = REDUCE #( INIT s TYPE menge_d
*                               FOR wa IN it_vtas_netas
*                               NEXT s = s + wa-mes ).

  wa_rg_ferth-loW = 'PVIV'.
  wa_rg_ferth-option = 'EQ'.
  wa_rg_ferth-sign = 'I'.
  APPEND wa_rg_ferth TO vl_rg_ferth.

  wa_rg_ferth-loW = 'PVEN'.
  wa_rg_ferth-option = 'EQ'.
  wa_rg_ferth-sign = 'I'.
  APPEND wa_rg_ferth TO vl_rg_ferth.

  wa_rg_ferth-loW = 'CADH'.
  wa_rg_ferth-option = 'EQ'.
  wa_rg_ferth-sign = 'I'.
  APPEND wa_rg_ferth TO vl_rg_ferth.

  wa_rg_ferth-loW = 'MEND'.
  wa_rg_ferth-option = 'EQ'.
  wa_rg_ferth-sign = 'I'.
  APPEND wa_rg_ferth TO vl_rg_ferth.

  wa_rg_ferth-loW = 'KVEN'.
  wa_rg_ferth-option = 'EQ'.
  wa_rg_ferth-sign = 'I'.
  APPEND wa_rg_ferth TO vl_rg_ferth.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  wa_rg_werks-loW = 'PE01'.
  wa_rg_werks-high = 'PE75'.
  wa_rg_werks-option = 'BT'.
  wa_rg_werks-sign = 'I'.
  APPEND wa_rg_werks TO vl_rg_werks.

  wa_rg_werks-loW = 'PP04'.
  wa_rg_werks-high = 'PP06'.
  wa_rg_werks-option = 'BT'.
  wa_rg_werks-sign = 'I'.
  APPEND wa_rg_werks TO vl_rg_werks.

  wa_rg_werks-loW = 'PP08'.
  wa_rg_werks-high = 'PP08'.
  wa_rg_werks-option = 'BT'.
  wa_rg_werks-sign = 'I'.
  APPEND wa_rg_werks TO vl_rg_werks.

  wa_rg_werks-loW = 'PP12'.
  wa_rg_werks-high = 'PP14'.
  wa_rg_werks-option = 'BT'.
  wa_rg_werks-sign = 'I'.
  APPEND wa_rg_werks TO vl_rg_werks.

  wa_rg_werks-loW = 'PP25'.
  wa_rg_werks-high = 'PP25'.
  wa_rg_werks-option = 'BT'.
  wa_rg_werks-sign = 'I'.
  APPEND wa_rg_werks TO vl_rg_werks.

  wa_rg_werks-loW = 'PP27'.
  wa_rg_werks-high = 'PP30'.
  wa_rg_werks-option = 'BT'.
  wa_rg_werks-sign = 'I'.
  APPEND wa_rg_werks TO vl_rg_werks.

  wa_rg_werks-loW = 'PE62'.
  wa_rg_werks-high = 'PE62'.
  wa_rg_werks-option = 'BT'.
  wa_rg_werks-sign = 'E'.
  APPEND wa_rg_werks TO vl_rg_werks.

  wa_rg_werks-loW = 'PE20'.
  wa_rg_werks-high = 'PE26'.
  wa_rg_werks-option = 'BT'.
  wa_rg_werks-sign = 'E'.
  APPEND wa_rg_werks TO vl_rg_werks.

*  obj_engorda->get_kgs_vendidos(
*          EXPORTING
*            i_fecha  = so_fecha-low
*            i_gpo_ferth  = vl_rg_ferth
*            i_gpo_werks = vl_rg_werks
*            i_bukrs = 'SA01'
*          CHANGING
*            ch_kgs_vendidos = it_kgs_vendidos ).

*
*  DATA(vl_sum_kgs) = REDUCE #( INIT s TYPE menge_d
*                                FOR wa1 IN it_kgs_vendidos
*                                NEXT s = s + wa1-mes ).


*  wa_backlog-wgbez60 = 'TOTAL KILOS VENDIDOS'.
*  wa_backlog-valor = vl_sum_kgs.
*  APPEND wa_backlog TO it_backlog.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-007.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ).


      CASE ls_fcat-fieldname.

        WHEN 'H'.
          vl_div = gv_cantH_kg.
          vl_base = gv_canth_mn.
        WHEN 'M'.
          vl_div = gv_cantm_kg.
          vl_base = gv_cantm_mn.
        WHEN 'CHIAPAS'.
          vl_div = gv_chiapas_kg.
          vl_base = gv_chiapas_mn.
        WHEN 'RNS_ENTERO'.
          vl_div = gv_rnsentero.
          vl_base = gv_chiapas_mn.
        WHEN 'RNS_CORTES'.
          vl_div = gv_rnscortes.
          vl_base = gv_rnscortes_mn.

        WHEN 'RTC'.
          vl_div = gv_rtc.
          vl_base = gv_rtc_mn.

        WHEN 'PINTADO_P'.
          vl_div = gv_pintadopesado.
          vl_base = gv_pintadopesado_mn.

        WHEN 'HIDRATADO'.
          vl_div = gv_hidratado.
          vl_base = gv_hidratado_mn.


        WHEN 'RHP_CORTES'.
          vl_div = gv_rhpcortes.
          vl_base = gv_rhpcortes_mn.

        WHEN 'LIMPIEZAS'.
          vl_div = gv_limpiezas.
          vl_base = gv_limpiezas_mn.
        WHEN OTHERS.
          IF ls_fcat-fieldname CP 'M0*'.
            vl_div = gv_cant_pv_kg.
            vl_base = gv_cant_pv_mn.
          ENDIF.
      ENDCASE.


      PERFORM calcula_columnas
        USING
          vl_base
          vl_div
          ls_fcat-fieldname
          <fs_st>
          TEXT-007.
    ENDLOOP.

  ENDLOOP.

ENDFORM.

FORM set_gastos_distrib.
  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.
  DATA vl_acum_kgs_pv TYPE menge_d.
  DATA: vl_texto      TYPE string,
        vl_text       TYPE string,
        vl_valor_base TYPE menge_d,
        vl_valor_div  TYPE menge_d.

  obj_engorda->get_gtos(
            EXPORTING
              i_fecha  = so_fecha-low
              CHANGING
              ch_gtos_dist = it_gtos_dist ).

  DATA(vl_sum_gtos_ch) = REDUCE #( INIT s TYPE menge_d
                              FOR wa IN it_gtos_dist
                              NEXT s = s + wa-mes ).


  obj_engorda->get_gtos_pv(
           EXPORTING
             i_fecha  = so_fecha-low
             CHANGING
             ch_gtos_dist = it_gtos_dist_pv ).

  DATA(vl_sum_gtos_pv) = REDUCE #( INIT s TYPE menge_d
                              FOR wa IN it_gtos_dist_pv
                              NEXT s = s + wa-mes ).

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-008.

  vl_acum_kgs_pv = gv_cant_pv_kg_m + gv_canth_kg_m + gv_cantm_kg_m.
  DATA(vl_kilos_ppa) = gv_rnsentero_m + gv_rnscortes_m + gv_hidratado_m + gv_rtc_m + gv_rhpcortes_m + gv_limpiezas_m.

  """"""""""""""""valor base PPA suma ctas
  obj_engorda->get_gtos_ppa(
    EXPORTING
      i_fecha          = so_fecha-low
    CHANGING
      ch_gtos_dist_ppa = it_gtos_dist_ppa   ).


  DATA(vl_sum_ppa) = REDUCE #( INIT s TYPE menge_d
                             FOR wa IN it_gtos_dist_ppa
                             NEXT s = s + wa-mes ).

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      IF ls_fcat-fieldname EQ wa_meses-zmonth OR
         ls_fcat-fieldname EQ 'H' OR ls_fcat-fieldname EQ 'M'
         .

        vl_valor_base = vl_sum_gtos_pv. "vl_per_sales.
        vl_valor_div = vl_acum_kgs_pv.
        vl_text = TEXT-008.
      ELSEIF ls_fcat-fieldname EQ 'CHIAPAS'.
        vl_valor_base = vl_sum_gtos_ch.
        vl_valor_div = gv_chiapas_kg_m.
        vl_text = TEXT-008.
      ELSE.
        "CONCATENATE TEXT-017 ls_fcat-fieldname INTO vl_texto.
        "DATA(vl_kilos) = it_backlog[ wgbez60 = vl_texto ].


        vl_valor_base = vl_sum_ppa.
        vl_valor_div = vl_kilos_ppa.
        vl_text = 'PPA'.
      ENDIF.

      PERFORM calcula_columnas
       USING
         vl_valor_base
         vl_valor_div
         ls_fcat-fieldname
         <fs_st>
         vl_text
         .


*      CONCATENATE TEXT-017 ls_fcat-fieldname INTO vl_texto.
*      DATA(vl_kilos) = it_backlog[ wgbez60 = vl_texto ].
*
*      vl_rest = ( vl_sum_gtos / '30.0' )." / vl_tot_kgs_vend-valor.
*
*      IF vl_rest LT 0.
*        vl_rest = vl_rest * -1.
*      ENDIF.
*
*      IF vl_kilos-valor LE 0.
*        vl_rest = 0.
*      ELSE.
*        vl_rest = vl_rest / vl_kilos-valor.
*      ENDIF.
*
*      PERFORM calcula_columnas
*        USING
*         vl_rest
*          0
*          ls_fcat-fieldname
*          <fs_st>
*         TEXT-008
*        .


    ENDLOOP.
  ENDLOOP.
ENDFORM.
""""""""""""""""""""""""""""""""""""""""""
FORM set_gastos_venta.
  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.
  DATA vl_gastos_venta TYPE menge_d.
  DATA vl_rest TYPE menge_d.
  DATA: vl_texto       TYPE string,
        vl_text        TYPE string,
        vl_valor_base  TYPE menge_d,
        vl_valor_div   TYPE menge_d,
        vl_acum_kgs_pv TYPE menge_d.

  obj_engorda->get_ventas(
            EXPORTING
              i_fecha  = so_fecha-low
              CHANGING
              ch_gtos_ventas = it_gtos_ventas ).

  DATA(vl_sum_ventas_ch) = REDUCE #( INIT s TYPE menge_d
                              FOR wa IN it_gtos_ventas
                              NEXT s = s + wa-mes ).


  obj_engorda->get_ventas_pv(
          EXPORTING
            i_fecha  = so_fecha-low
            CHANGING
            ch_gtos_ventas = it_gtos_ventas_pv ).

  DATA(vl_sum_ventas_pv) = REDUCE #( INIT s TYPE menge_d
                              FOR wa IN it_gtos_ventas_pv
                              NEXT s = s + wa-mes ).


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-009.

  vl_acum_kgs_pv = gv_cant_pv_kg_m + gv_canth_kg_m + gv_cantm_kg_m.

  DATA(vl_kilos_ppa) = gv_rnsentero_m + gv_rnscortes_m + gv_hidratado_m + gv_rtc_m + gv_rhpcortes_m + gv_limpiezas_m.

  """"""""""""""""valor base PPA suma ctas
  obj_engorda->get_ventas_ppa(
    EXPORTING
      i_fecha          = so_fecha-low
    CHANGING
      ch_gtos_ventas_ppa = it_gtos_ventas_ppa  ).


  DATA(vl_sum_ppa) = REDUCE #( INIT s TYPE menge_d
                        FOR wa IN it_gtos_ventas_ppa
                        NEXT s = s + wa-mes ).

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


  LOOP AT gv_tt_meses INTO DATA(wa_meses).

*    ASSIGN COMPONENT wa_meses-zmonth OF STRUCTURE <fs_st> TO <fs_field>.
    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      IF ls_fcat-fieldname EQ wa_meses-zmonth OR
          ls_fcat-fieldname EQ 'H' OR ls_fcat-fieldname EQ 'M'
          .

        vl_valor_base = vl_sum_ventas_pv. "vl_per_sales.
        vl_valor_div = vl_acum_kgs_pv.
        vl_text = TEXT-009.
      ELSEIF ls_fcat-fieldname EQ 'CHIAPAS'.
        vl_valor_base = vl_sum_ventas_ch.
        vl_valor_div = gv_chiapas_kg_m.
        vl_text = TEXT-009.
      ELSE.
*        CONCATENATE TEXT-008 ls_fcat-fieldname INTO vl_texto.
*        DATA(vl_kilos) = it_backlog[ wgbez60 = vl_texto ].
*
*        vl_valor_base = vl_sum_ventas_pv.
*        vl_valor_div = vl_kilos-valor.
        vl_valor_base = vl_sum_ppa.
        vl_valor_div = vl_kilos_ppa.
        vl_text = 'PPA'.
      ENDIF.

      PERFORM calcula_columnas
       USING
         vl_valor_base
         vl_valor_div
         ls_fcat-fieldname
         <fs_st>
         vl_text
         .



*      CONCATENATE TEXT-008 ls_fcat-fieldname INTO vl_texto.
*      DATA(vl_gtos_dist) = it_backlog[ wgbez60 = vl_texto ] .
*      vl_gastos_venta = vl_gtos_dist-valor + vl_sum_ventas.
*
*      CONCATENATE TEXT-017 ls_fcat-fieldname INTO vl_texto.
*      DATA(vl_kilos) = it_backlog[ wgbez60 = vl_texto ] .
*
*
*      vl_rest = ( vl_gastos_venta / '30.0' ). "/ vl_tot_kgs_vend-valor.
*
*      IF vl_rest LT 0.
*        vl_rest = vl_rest * -1.
*      ENDIF.
*
*      IF vl_kilos-valor LE 0.
*        vl_rest = 0.
*      ELSE.
*        vl_rest = vl_rest / vl_kilos-valor.
*      ENDIF.
*
*      PERFORM calcula_columnas
*       USING
*        vl_rest
*         0
*         ls_fcat-fieldname
*         <fs_st>
*        TEXT-009
*       .


    ENDLOOP.

  ENDLOOP.

ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM set_gastos_admon.
  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.
  DATA vl_rest TYPE menge_d.
  DATA: vl_texto       TYPE string,
        vl_text        TYPE string,
        vl_valor_base  TYPE menge_d,
        vl_valor_div   TYPE menge_d,
        vl_acum_kgs_pv TYPE menge_d.

  obj_engorda->get_admon(
            EXPORTING
              i_fecha  = so_fecha-low
              CHANGING
              ch_gtos_admon = it_gtos_admon ).

  DATA(vl_sum_admon_ch) = REDUCE #( INIT s TYPE menge_d
                              FOR wa IN it_gtos_admon
                              NEXT s = s + wa-mes ).


  obj_engorda->get_admon_pv(
            EXPORTING
              i_fecha  = so_fecha-low
              CHANGING
              ch_gtos_admon = it_gtos_admon_pv ).

  DATA(vl_sum_admon_pv) = REDUCE #( INIT s TYPE menge_d
                              FOR wa IN it_gtos_admon
                              NEXT s = s + wa-mes ).




  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-010.

  vl_acum_kgs_pv = gv_cant_pv_kg_m + gv_canth_kg_m + gv_cantm_kg_m.

  DATA(vl_kilos_ppa) = gv_rnsentero_m + gv_rnscortes_m + gv_hidratado_m + gv_rtc_m + gv_rhpcortes_m + gv_limpiezas_m.

  """"""""""""""""valor base PPA suma ctas
  obj_engorda->get_admon_ppa(
    EXPORTING
      i_fecha          = so_fecha-low
    CHANGING
      ch_gtos_admon_ppa = it_gtos_admon_ppa   ).


  DATA(vl_sum_ppa) = REDUCE #( INIT s TYPE menge_d
                           FOR wa IN it_gtos_admon_ppa
                           NEXT s = s + wa-mes ).

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      IF ls_fcat-fieldname EQ wa_meses-zmonth OR
           ls_fcat-fieldname EQ 'H' OR ls_fcat-fieldname EQ 'M'
           .

        vl_valor_base = vl_sum_admon_pv. "vl_per_sales.
        vl_valor_div = vl_acum_kgs_pv.
        vl_text = TEXT-009.
      ELSEIF ls_fcat-fieldname EQ 'CHIAPAS'.
        vl_valor_base = vl_sum_admon_ch.
        vl_valor_div = gv_chiapas_kg_m.
        vl_text = TEXT-009.
      ELSE.
*        CONCATENATE TEXT-017 ls_fcat-fieldname INTO vl_texto.
*        DATA(vl_kilos) = it_backlog[ wgbez60 = vl_texto ].
*
*        vl_valor_base = vl_sum_admon_pv.
*        vl_valor_div = vl_kilos-valor.
        vl_valor_base = vl_sum_ppa.
        vl_valor_div = vl_kilos_ppa.
        vl_text = 'PPA'.
      ENDIF.

      PERFORM calcula_columnas
       USING
         vl_valor_base
         vl_valor_div
         ls_fcat-fieldname
         <fs_st>
         vl_text
         .

*
*      CONCATENATE TEXT-017 ls_fcat-fieldname INTO vl_texto.
*      DATA(vl_kilos) = it_backlog[ wgbez60 = vl_texto ].
*
*      vl_rest = ( vl_sum_admon / '30.0' )." / vl_tot_kgs_vend-valor.
*
*      IF vl_rest LT 0.
*        vl_rest = vl_rest * -1.
*      ENDIF.
*
*      IF vl_kilos-valor LE 0.
*        vl_rest = 0.
*      ELSE.
*        vl_rest = vl_rest / vl_kilos-valor.
*      ENDIF.
*
*      PERFORM calcula_columnas
*       USING
*         vl_rest
*         0
*         ls_fcat-fieldname
*         <fs_st>
*        TEXT-010
*       .


    ENDLOOP.
  ENDLOOP.

ENDFORM.

FORM get_valor_columnas USING p_valor_base TYPE menge_d
                            p_cant_pv TYPE menge_d
*                            p_text type string
                       CHANGING
                            p_fieldcolumn TYPE any.

  DATA vl_valor TYPE menge_d.

  IF p_cant_pv GT 0.

    vl_valor = p_valor_base / p_cant_pv.
  ELSE.

    vl_valor = 0.
  ENDIF.

  p_fieldcolumn = vl_valor.


ENDFORM.

FORM calcula_columnas USING p_valor_base TYPE menge_d
                            p_valor_div TYPE menge_d
                            p_fieldname TYPE lvc_rfname
                            p_struct TYPE any
                            p_text TYPE string.

  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any,
                 <fs_text>  TYPE any.

  DATA: vl_cant_div   TYPE menge_d,
        vl_str_backl  TYPE string,
        vl_valor_base TYPE menge_d.


  "LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

  "ASSIGN COMPONENT wa_meses-zmonth OF STRUCTURE <fs_st> TO <fs_field>.
  ASSIGN COMPONENT p_fieldname OF STRUCTURE p_struct TO <fs_field>.

  CASE p_fieldname.
    WHEN 'H'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_canth_mn.
      ELSE.
        IF p_text NE 'PPA'.
          vl_valor_base = p_valor_base.
        ELSE.
          vl_valor_base = 0.
        ENDIF.
      ENDIF.


    WHEN 'M'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_cantm_mn.
      ELSE.
        IF p_text NE 'PPA'.
          vl_valor_base = p_valor_base.
        ELSE.
          vl_valor_base = 0.
        ENDIF.
      ENDIF.

    WHEN 'CHIAPAS'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_chiapas_mn.
      ELSE.
        IF p_text NE 'PPA'.
          vl_valor_base = p_valor_base.
        ELSE.
          vl_valor_base = 0.
        ENDIF.
      ENDIF.


    WHEN 'RNS_ENTERO'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_rnsentero_mn.
      ELSE.
        vl_valor_base = p_valor_base.
      ENDIF.


    WHEN 'RNS_CORTES'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_rnscortes_mn.
      ELSE.
        vl_valor_base = p_valor_base.
      ENDIF.


    WHEN 'RTC'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_rtc_mn.
      ELSE.
        vl_valor_base = p_valor_base.
      ENDIF.


    WHEN 'PINTADO_P'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_pintadopesado_mn.
      ELSE.
        vl_valor_base = p_valor_base.
      ENDIF.

    WHEN 'HIDRATADO'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_hidratado_mn.
      ELSE.
        vl_valor_base = p_valor_base.
      ENDIF.


    WHEN 'RHP_CORTES'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_rhpcortes_mn.
      ELSE.
        vl_valor_base = p_valor_base.
      ENDIF.

    WHEN 'LIMPIEZAS'.
      IF p_valor_div EQ 0.
        vl_cant_div = 1.
      ELSE.
        vl_cant_div = p_valor_div.
      ENDIF.

      IF p_text EQ TEXT-007.
        vl_valor_base = gv_limpiezas_mn.
      ELSE.
        vl_valor_base = p_valor_base.
      ENDIF.


    WHEN OTHERS.
      IF ls_fcat-fieldname CP 'M0*'.
        IF p_valor_div EQ 0.
          vl_cant_div = 1.
        ELSE.
          vl_cant_div = p_valor_div.
        ENDIF.

        IF p_text EQ TEXT-007.
          vl_valor_base = gv_cant_pv_mn.
        ELSE.
          IF p_text NE 'PPA'.
            vl_valor_base = p_valor_base.
          ELSE.
            vl_valor_base = 0.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.




  PERFORM get_valor_columnas
    USING
      vl_valor_base
      vl_cant_div
    CHANGING
     <fs_field>
    .


  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE p_struct TO <fs_text>.
  CONCATENATE <fs_text> ls_fcat-fieldname INTO vl_str_backl.

  IF <fs_text> EQ TEXT-011 OR
    <fs_text> EQ TEXT-012 OR
    <fs_text> EQ TEXT-013 OR
    <fs_text> EQ TEXT-014 OR
    <fs_text> EQ TEXT-015 OR
    <fs_text> EQ TEXT-016 .
    "nothing
else.

    IF <fs_field> LT 0.
      <fs_field> = <fs_field> * -1.
    ENDIF.

  ENDIF.


  wa_backlog-wgbez60 = vl_str_backl.
  wa_backlog-valor = <fs_field>.
  APPEND wa_backlog TO it_backlog.
  " EXIT.
  "ENDLOOP.
ENDFORM.

FORM cu_mat_prima.
  DATA: vl_valor_base TYPE menge_d,
        vl_valor_rend TYPE menge_d,
        vl_texto      TYPE string.


  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-011.

  UNASSIGN <fs_field>.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .


      CONCATENATE TEXT-002 ls_fcat-fieldname INTO vl_texto.
      DATA(wa_002) = it_backlog[ wgbez60 = vl_texto ].
      vl_valor_base = wa_002-valor. "costo transferencia

      CONCATENATE TEXT-001 ls_fcat-fieldname INTO vl_texto.
      DATA(wa_ppa) = it_backlog[ wgbez60 = vl_texto ].
      vl_valor_base = vl_valor_base + wa_ppa-valor. "transferencia ppa

      CONCATENATE TEXT-005 ls_fcat-fieldname INTO vl_texto.
      DATA(wa_ppa2) = it_backlog[ wgbez60 = vl_texto ].
      vl_valor_base = vl_valor_base + wa_ppa2-valor. ""transferencia ppa 2

      CONCATENATE TEXT-006 ls_fcat-fieldname INTO vl_texto.
      DATA(wa_rend) = it_backlog[ wgbez60 = vl_texto ].
      vl_valor_base = vl_valor_base + wa_rend-valor. "recuperaciones



*      IF ls_fcat-fieldname = 'RNS_ENTERO' OR ls_fcat-fieldname = 'RNS_CORTES' OR
*         ls_fcat-fieldname = 'RTC' OR ls_fcat-fieldname = 'PINTADO_P' OR
*         ls_fcat-fieldname = 'HIDRATADO' OR ls_fcat-fieldname = 'RHP_CORTES' OR
*         ls_fcat-fieldname = 'LIMPIEZAS'.
*
**        CONCATENATE TEXT-003 ls_fcat-fieldname INTO vl_texto.
**        DATA(valor_rend) = it_backlog[ wgbez60 = vl_texto ].
**        CLEAR vl_valor_rend.
**        vl_valor_rend = ( valor_rend-valor / 100 ).
*        vl_valor_rend = 0.
*      ELSE.
*        vl_valor_rend = 1.
*      ENDIF.

      vl_valor_rend = 1.
      PERFORM calcula_columnas
       USING
         vl_valor_base
         vl_valor_rend
         ls_fcat-fieldname
         <fs_st>
        TEXT-011
      .

    ENDLOOP.

  ENDLOOP.



ENDFORM.

FORM Costo_total_kg.

  DATA: vl_valor_base  TYPE menge_d,
        vl_valor_flete TYPE menge_d,
        vl_valor_recup TYPE menge_d,
        vl_texto       TYPE string.


  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-012.

  UNASSIGN <fs_field>.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      CONCATENATE TEXT-011 ls_fcat-fieldname INTO vl_texto.
      DATA(wa_011) = it_backlog[ wgbez60 = vl_texto ].
      vl_valor_base = wa_011-valor.

      IF ls_fcat-fieldname = 'RNS_ENTERO' OR ls_fcat-fieldname = 'RNS_CORTES' OR
         ls_fcat-fieldname = 'RTC' OR ls_fcat-fieldname = 'PINTADO_P' OR
         ls_fcat-fieldname = 'HIDRATADO' OR ls_fcat-fieldname = 'RHP_CORTES' OR
         ls_fcat-fieldname = 'LIMPIEZAS'.

        CONCATENATE TEXT-001 ls_fcat-fieldname INTO vl_texto.
        DATA(valor_flete) = it_backlog[ wgbez60 = vl_texto ].
        CLEAR vl_valor_flete.
        vl_valor_flete = valor_flete-valor.

        CONCATENATE TEXT-006 ls_fcat-fieldname INTO vl_texto.
        DATA(valor_recu) = it_backlog[ wgbez60 = vl_texto ].
        CLEAR vl_valor_recup.
        vl_valor_recup = valor_recu-valor.

        vl_valor_flete = vl_valor_base + vl_valor_flete + vl_valor_recup.

      ELSE.
        vl_valor_flete = 0.
      ENDIF.


      PERFORM calcula_columnas
       USING
         vl_valor_base
         vl_valor_flete
         ls_fcat-fieldname
         <fs_st>
        TEXT-012
      .

    ENDLOOP.

  ENDLOOP.


ENDFORM.

FORM Utilidad_bruta.

  DATA: vl_valor_base    TYPE menge_d,
        vl_valor_precvta TYPE menge_d,

        vl_texto         TYPE string.


  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-013.

  UNASSIGN <fs_field>.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      "CONCATENATE TEXT-012 ls_fcat-fieldname INTO vl_texto. "costo total kg
      CONCATENATE TEXT-011 ls_fcat-fieldname INTO vl_texto. "cu_materia_prima
      DATA(wa_012) = it_backlog[ wgbez60 = vl_texto ].
      vl_valor_base = wa_012-valor.



      CONCATENATE TEXT-007 ls_fcat-fieldname INTO vl_texto. "precio de venta
      DATA(valor_precvta) = it_backlog[ wgbez60 = vl_texto ].
      CLEAR vl_valor_precvta.
      vl_valor_precvta = valor_precvta-valor.



      "vl_valor_base = vl_valor_base - vl_valor_precvta.
      vl_valor_base = vl_valor_precvta -  vl_valor_base.  "Precio Venta - cu_materia_prima


      PERFORM calcula_columnas
       USING
         vl_valor_base
         0
         ls_fcat-fieldname
         <fs_st>
        TEXT-013
      .

    ENDLOOP.

  ENDLOOP.


ENDFORM.

FORM total_gastos_venta.

  DATA: vl_valor_base    TYPE menge_d,
        vl_valor_gtosvta TYPE menge_d,

        vl_texto         TYPE string.


  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-014.

  UNASSIGN <fs_field>.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      CONCATENATE TEXT-008 ls_fcat-fieldname INTO vl_texto. "gasto distribución
      DATA(wa_008) = it_backlog[ wgbez60 = vl_texto ].
      vl_valor_base = wa_008-valor.



      CONCATENATE TEXT-009 ls_fcat-fieldname INTO vl_texto. "gastos venta
      DATA(valor_gtosvta) = it_backlog[ wgbez60 = vl_texto ].
      CLEAR vl_valor_gtosvta.
      vl_valor_gtosvta = valor_gtosvta-valor.



      vl_valor_base = vl_valor_base + vl_valor_gtosvta.



      PERFORM calcula_columnas
       USING
         vl_valor_base
         0
         ls_fcat-fieldname
         <fs_st>
        TEXT-014
      .

    ENDLOOP.

  ENDLOOP.


ENDFORM.

FORM Utilidad_operacion.

  DATA: vl_valor_base      TYPE menge_d,
        vl_valor_gtosadmin TYPE menge_d,
        vl_valor_gtosvta   TYPE menge_d,
        vl_texto           TYPE string.


  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-015.

  UNASSIGN <fs_field>.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      CONCATENATE TEXT-013 ls_fcat-fieldname INTO vl_texto. "utilidad bruta
      DATA(wa_013) = it_backlog[ wgbez60 = vl_texto ].
      vl_valor_base = wa_013-valor.


      CONCATENATE TEXT-014 ls_fcat-fieldname INTO vl_texto. "total gastos venta
      DATA(valor_gtosvta) = it_backlog[ wgbez60 = vl_texto ].
      CLEAR vl_valor_gtosvta.
      vl_valor_gtosvta = valor_gtosvta-valor.


      CONCATENATE TEXT-010 ls_fcat-fieldname INTO vl_texto. "gastos administración
      DATA(valor_gtosadmin) = it_backlog[ wgbez60 = vl_texto ].
      CLEAR vl_valor_gtosadmin.
      vl_valor_gtosadmin = valor_gtosadmin-valor.



      vl_valor_base = vl_valor_base - vl_valor_gtosvta - vl_valor_gtosadmin.



      PERFORM calcula_columnas
       USING
         vl_valor_base
         0
         ls_fcat-fieldname
         <fs_st>
        TEXT-015
      .

    ENDLOOP.

  ENDLOOP.


ENDFORM.

FORM Utilidad_pkg.

  DATA: vl_valor_base      TYPE menge_d, vl_div TYPE menge_d,
        vl_valor_gtosadmin TYPE menge_d,
        vl_valor_gtosvta   TYPE menge_d,
        vl_texto           TYPE string.


  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-016.

  UNASSIGN <fs_field>.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT lt_fcat INTO ls_fcat WHERE ( fieldname NE 'WGBEZ60' AND fieldname NE lv_fname ) .

      CONCATENATE TEXT-015 ls_fcat-fieldname INTO vl_texto. "utilidad operacion
      DATA(wa_015) = it_backlog[ wgbez60 = vl_texto ].
      vl_valor_base = wa_015-valor.

      CONCATENATE TEXT-003 ls_fcat-fieldname INTO vl_texto. "rendimiento
      DATA(wa_003) = it_backlog[ wgbez60 = vl_texto ].
      vl_div = wa_003-valor.



      PERFORM calcula_columnas
       USING
         vl_valor_base
         vl_div
         ls_fcat-fieldname
         <fs_st>
        TEXT-016
      .

    ENDLOOP.

  ENDLOOP.


ENDFORM.
