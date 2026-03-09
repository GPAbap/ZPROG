*&---------------------------------------------------------------------*
*& Include zco_re_costo_prod_rentab_fun
*&---------------------------------------------------------------------*


FORM handle_user_command USING i_ucomm TYPE salv_de_function.
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
  ls_fcat-coltext   = 'CONCEPTO'.
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
    ls_fcat-decimals = '3'.
    ls_fcat-outputlen = '22'.
    ls_fcat-do_sum    = 'X'.
    APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.
  ENDLOOP.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'TOTAL'.
  ls_fcat-coltext   = 'TOTAL'.
  "ls_fcat-datatype  = 'CURR'.
  ls_fcat-ref_table = 'MSEG'.
  ls_fcat-ref_field = 'MENGE'.
  ls_fcat-decimals = '3'.
  ls_fcat-outputlen = '22'.
  ls_fcat-no_out = 'X'.
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

  vl_wfechas-high = so_fecha-low.
  vl_wfechas-loW = so_fecha-low.
  vl_wfechas-option = 'BT'."so_fecha-option.
  vl_wfechas-sign = so_fecha-sign.
  APPEND vl_wfechas TO vl_fechas.



  IF p_tipo EQ 'ENGORDA'.
    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'EN01'.
    APPEND wa_rgdauat TO vl_rgdauat.


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
  ENDIF.

  REFRESH it_aufnr_end.

  obj_engorda->get_aufnr_cte_ren(
EXPORTING
  p_gjahr   =  so_fecha-low+0(4)
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
*    o_alv->set_screen_status(
*        pfstatus      =  'ZSTANDARD'
*        report        =  sy-repid
*        set_functions = o_alv->c_functions_all ).
*
*    lr_events = o_alv->get_event( ).
*
*    CREATE OBJECT gr_events.
*
**... §6.1 register to the event USER_COMMAND
*    SET HANDLER gr_events->on_user_command FOR lr_events.
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
  column->set_short_text('CONCEPTO' ).
  column->set_medium_text('CONCEPTO' ).
  column->set_long_text('CONCEPTO' ).


*
  column = lr_columns->get_column( columnname = 'TOTAL' ).
  column->set_short_text('TOTAL' ).
  column->set_medium_text('TOTAL' ).
  column->set_long_text('TOTAL' ).

  LOOP AT lt_fcat INTO DATA(wa_fcat) WHERE fieldname NE 'WGBEZ60' AND fieldname NE 'TOTAL' AND fieldname NE lv_fname.

    CONCATENATE sy-datum+0(4) wa_fcat-fieldname+1(2) '01' INTO campocu.
    vl_date = campocu.
    CALL FUNCTION '/SAPCE/IURU_GET_MONTH_NAME'
      EXPORTING
        iv_date       = vl_date
      IMPORTING
        ev_month_name = vl_name_month.

    vl_zname_month = vl_name_month.
    TRANSLATE vl_zname_month TO UPPER CASE.
*    CONCATENATE vl_zname_month 'REAL' INTO vl_zname_month SEPARATED BY space.
*    TRANSLATE vl_zname_month TO UPPER CASE.
    vl_scrtext_m = vl_zname_month.
    vl_scrtext_l = vl_zname_month.
*    CONCATENATE vl_zname_month+0(3) 'REAL' INTO vl_zname_month SEPARATED BY space.
    vl_scrtext_s = vl_zname_month.



    column = lr_columns->get_column( columnname = wa_fcat-fieldname ).
    column->set_short_text( vl_scrtext_s ).
    column->set_medium_text( vl_scrtext_m ).
    column->set_long_text( vl_scrtext_l ).
    columnname = wa_fcat-fieldname.
  ENDLOOP.


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
  <fs_field> = TEXT-001.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      READ TABLE it_aux_acum INTO DATA(wa_acum) WITH KEY columna = wa_meses-zmonth.
      IF sy-subrc = 0.
        UNASSIGN <fs_mes>.
        ASSIGN COMPONENT wa_meses-zmonth OF STRUCTURE <fs_st> TO <fs_mes> .
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_acum TO <fs_acum>.

        LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
          ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_piezas>).
          vl_piezas_pv = <fs_piezas>.

          ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_kilos>).
          IF <fs_kilos> GT 0.
            vl_kilos_pv = <fs_kilos>.
          ENDIF.

        ENDLOOP.

        IF vl_piezas_pv GT 0.
          <fs_mes> = vl_kilos_pv / vl_piezas_pv.
          CLEAR wa_backlog.
          wa_backlog-wgbez60 = TEXT-001.
          wa_backlog-valor = <fs_mes>.
          APPEND wa_backlog TO it_backlog.
        ENDIF.
      ENDIF.
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


  DATA: vl_rgbwart TYPE RANGE OF mseg-bwart,
        wa_rgbwart LIKE LINE OF vl_rgbwart,
        vl_rgmatnr TYPE RANGE OF mara-matnr,
        wa_rgmatnr LIKE LINE OF vl_rgmatnr,
        vl_mes(3)  TYPE c,
        vl_string  TYPE string,
        vl_fecha_i TYPE datum, vl_fecha_f TYPE datum,
        vl_find,
        vl_sytabix TYPE sy-tabix.
  DATA num_days    TYPE i.

  DATA: vl_menge  TYPE menge_d, vl_dmbtr TYPE dmbtr_cs,
        vl_concep TYPE maktx.

  DATA: kg_pro           TYPE menge_d, kg_menu TYPE menge_d, kg_merma TYPE menge_d,
        kilos_producidos TYPE menge_d.

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


  IF it_aufnr_end IS NOT INITIAL.

    obj_engorda->get_mb51(
           EXPORTING
             i_aufnr  = it_aufnr_end
             i_rgbwart = vl_rgbwart
           CHANGING
             ch_mb51 = it_mb51 ).



    DELETE it_mb51 WHERE ( matkl NE 'PT0001' AND racct NE '0504025051' AND racct NE'0504025106' ).

    LOOP AT gv_tt_meses INTO DATA(wa_meses).

      DATA(aux_aufnr) = it_aufnr_end[].
      CONCATENATE so_fecha-low+0(4) wa_meses-zmonth+1(2) '01' INTO vl_string.
      vl_fecha_i = vl_string.


      CONCATENATE so_fecha-low+0(4) wa_meses-zmonth+1(2) so_fecha-low+6(2) INTO vl_string.
      vl_fecha_f = vl_string.

      DELETE aux_aufnr WHERE getri NOT BETWEEN vl_fecha_i AND vl_fecha_f.

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

      obj_engorda->get_kgs_cost_trans(
                 EXPORTING
                   i_fecha_i  = vl_fecha_i
                   i_fecha_f  = vl_fecha_f
                   i_ferth   = 'PPRO'
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


      obj_engorda->get_kgs_cost_trans(
              EXPORTING
                i_fecha_i  = vl_fecha_i
                i_fecha_f  = vl_fecha_f
                i_ferth   = 'MEND'
                i_rgbwart = vl_rgbwart
              CHANGING
                ch_kgs_cost_trans = it_kg_menudencia ).

      obj_engorda->get_kgs_cost_trans(
                 EXPORTING
                   i_fecha_i  = vl_fecha_i
                   i_fecha_f  = vl_fecha_f
                   i_ferth   = 'MER1'
                   i_rgbwart = vl_rgbwart
                 CHANGING
                   ch_kgs_cost_trans = it_kg_merma ).

      APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      <fs_field> = TEXT-003.

      ASSIGN COMPONENT wa_meses-zmonth OF STRUCTURE <fs_st> TO <fs_field>.

      READ TABLE it_aux_out INTO DATA(kilos_tras) INDEX 1.

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
      ENDIF.

      READ TABLE it_kg_merma INTO DATA(kilos_merma) INDEX 1.
      IF sy-subrc EQ 0.
        kg_merma = kilos_merma-menge.
      ENDIF.
      kilos_producidos = kilos_pro-menge - kilos_menu-menge - kilos_merma-menge.

      IF kilos_producidos GT 0.
        <fs_field> = kilos_tras-month  / kilos_producidos  .
      ELSE.
        <fs_field> = '0.00'.
      ENDIF.

      wa_backlog-wgbez60 = TEXT-003.
      wa_backlog-valor = <fs_field>.
      APPEND wa_backlog TO it_backlog.

      wa_backlog-wgbez60 = 'KILOS PRODUCIDOS'.
      wa_backlog-valor = kilos_producidos.
      APPEND wa_backlog TO it_backlog.


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

    CONCATENATE so_fecha-low+0(4) wa_meses-zmonth+1(2) '01' INTO vl_string.
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

    obj_engorda->get_kgs_cost_trans(
              EXPORTING
                i_fecha_i  = vl_fecha_i
                i_fecha_f  = vl_fecha_f
                i_ferth   = 'ROSC'
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


    obj_engorda->get_kgs_cost_trans(
              EXPORTING
                i_fecha_i  = vl_fecha_i
                i_fecha_f  = vl_fecha_f
                i_ferth   = 'CADH'
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

    IF vl_tot_kgs_pro_neto GT 0.
      vl_rendimiento = vl_kgs_proceso / vl_tot_kgs_pro_neto.
    ELSE.
      vl_rendimiento = '0.00'.
    ENDIF.

    wa_backlog-wgbez60 = 'MERMA DESTAZADA'.
    wa_backlog-valor = vl_consumo_rosc.
    APPEND wa_backlog TO it_backlog.

    wa_backlog-wgbez60 = 'TOTAL KILOS PROD. NETOS'.
    wa_backlog-valor = vl_tot_kgs_pro_neto.
    APPEND wa_backlog TO it_backlog.

    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = TEXT-004.

    ASSIGN COMPONENT wa_meses-zmonth OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = vl_rendimiento.


    wa_backlog-wgbez60 = TEXT-004.
    wa_backlog-valor = vl_rendimiento.
    APPEND wa_backlog TO it_backlog.





  ENDLOOP.

ENDFORM.

FORM flete_gto_transf.

  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.


  DATA: vl_rg_objnr TYPE RANGE OF cosp-objnr,
        wa_rg_objnr LIKE LINE OF vl_rg_objnr,
        vl_rg_kstar TYPE RANGE OF cosp-kstar,
        wa_rg_kstar LIKE LINE OF vl_rg_kstar.

  wa_rg_kstar-loW = 'S42SG0135'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.

  wa_rg_kstar-loW = 'S42SG0173'.
  wa_rg_kstar-option = 'EQ'.
  wa_rg_kstar-sign = 'I'.
  APPEND wa_rg_kstar TO vl_rg_kstar.



  obj_engorda->get_flete_gto_transf(
        EXPORTING
          i_gjahr  = so_fecha-low+0(4)
          i_month  = so_fecha-low
          i_gpo_kostl = 'PPTARIFAS.23'
          i_gpo_kstar  = vl_rg_kstar
        CHANGING
          ch_flete_transf = it_flete_transf ).

  DATA(vl_sum_ctas) = REDUCE #( INIT s TYPE menge_d
                               FOR wa IN it_flete_transf
                               NEXT s = s + wa-mes ).

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-007.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).
    ASSIGN COMPONENT wa_meses-zmonth OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = vl_sum_ctas.
    wa_backlog-wgbez60 = TEXT-007.
    wa_backlog-valor = vl_sum_ctas.
    APPEND wa_backlog TO it_backlog.
  ENDLOOP.
ENDFORM.

FORM precio_vta_kg_uni.

  FIELD-SYMBOLS: <fs_st>    TYPE any,
                 <fs_field> TYPE any.


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


  obj_engorda->get_ventas_netas(
        EXPORTING
          i_fecha  = so_fecha-low
          i_gpo_kstar  = vl_rg_kstar
        CHANGING
          ch_vtas_netas = it_vtas_netas ).

  DATA(vl_sum_vtas) = REDUCE #( INIT s TYPE menge_d
                               FOR wa IN it_vtas_netas
                               NEXT s = s + wa-mes ).

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

  obj_engorda->get_kgs_vendidos(
          EXPORTING
            i_fecha  = so_fecha-low
            i_gpo_ferth  = vl_rg_ferth
            i_gpo_werks = vl_rg_werks
            i_bukrs = 'SA01'
          CHANGING
            ch_kgs_vendidos = it_kgs_vendidos ).


  DATA(vl_sum_kgs) = REDUCE #( INIT s TYPE menge_d
                                FOR wa1 IN it_kgs_vendidos
                                NEXT s = s + wa1-mes ).

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = TEXT-009.

  LOOP AT gv_tt_meses INTO DATA(wa_meses).
    ASSIGN COMPONENT wa_meses-zmonth OF STRUCTURE <fs_st> TO <fs_field>.
    IF vl_sum_kgs GT 0.
      <fs_field> = vl_sum_vtas / vl_sum_kgs.
    ELSE.
      <fs_field> = 0.
    ENDIF.
    wa_backlog-wgbez60 = TEXT-009.
    wa_backlog-valor = <fs_field>.
    APPEND wa_backlog TO it_backlog.
  ENDLOOP.

ENDFORM.
