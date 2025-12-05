*&---------------------------------------------------------------------*
*& Include zco_agricolas_fun
*&---------------------------------------------------------------------*

FORM build_fieldcatalog.
  DATA: campocu        TYPE string,
        ncolumnas      TYPE i,
        nmeses         TYPE i,
        nveces         TYPE i,
        vl_date        TYPE dats,
        vl_name_month  TYPE fcltx,
        vl_poper       TYPE poper,
        vl_firstcolumn.

  ncolumnas = 0.
  nmeses = 0.
  vl_firstcolumn = abap_false.
  SORT so_poper BY low.

  IF so_poper-high IS INITIAL.
    LOOP AT so_poper.
      ncolumnas = ncolumnas + 1.
      nmeses = nmeses + 1.

      CONCATENATE 'CAMPO' so_poper-low '   ' INTO ls_fcat-fieldname. "campo NOMBRE DEL MES
      ls_fcat-col_pos   = ncolumnas.
      ls_fcat-outputlen = 40.
      APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

      CLEAR campocu.
      campocu = 0.
      IF vl_firstcolumn EQ  abap_false.
        nveces = 3.
        vl_firstcolumn = abap_true.
      ELSE.
        nveces = 2.
      ENDIF.
      DO nveces TIMES.
        campocu = campocu + 1.
        CONCATENATE gv_subcampo so_poper-low campocu '   ' INTO ls_fcat-fieldname.
        ls_fcat-col_pos   = ncolumnas.
        ls_fcat-outputlen = 15.
        "ls_fcat-datatype = 'CURR'.
        APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.
      ENDDO.

    ENDLOOP.
  ELSE.
    nmeses = so_poper-high - so_poper-low + 1.
    vl_poper = so_poper-low.



    DO nmeses TIMES.

      IF vl_firstcolumn EQ  abap_false.
        nveces = 3.
        vl_firstcolumn = abap_true.
      ELSE.
        nveces = 2.
      ENDIF.

      ncolumnas = ncolumnas + 1.
      CLEAR campocu.
      campocu = 0.
      CONCATENATE 'CAMPO' vl_poper '   ' INTO ls_fcat-fieldname.
      ls_fcat-col_pos   = ncolumnas.
      ls_fcat-outputlen = 40.
      "ls_fcat-datatype = 'CURR'.
      APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

      DO nveces TIMES.
        campocu = campocu + 1.
        CONCATENATE gv_subcampo vl_poper campocu '   ' INTO ls_fcat-fieldname.
        ls_fcat-col_pos   = ncolumnas.
        ls_fcat-outputlen = 15.
        " ls_fcat-datatype = 'CURR'.
        APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.
      ENDDO.


      vl_poper = vl_poper + 1.

    ENDDO.

  ENDIF.

  ls_fcat-fieldname = 'TOTALES'.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-outputlen = 15.
  "ls_fcat-datatype = 'CURR'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

  ls_fcat-fieldname = 'TOTAL_PT'.
  ls_fcat-col_pos   = ncolumnas + 1.
  ls_fcat-outputlen = 15.
  "ls_fcat-datatype = 'CURR'.
  APPEND ls_fcat TO lt_fcat. CLEAR

  ls_fcat.  ls_fcat-fieldname = 'TOTAL_PRE'.
  ls_fcat-col_pos   = ncolumnas + 1.
  ls_fcat-outputlen = 15.
  "ls_fcat-datatype = 'CURR'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.
ENDFORM.

FORM show_results.

  DATA: lv_text    TYPE string.
  DATA: nmeses    TYPE i, row TYPE i, col TYPE i, outputlen TYPE i.
  DATA vl_firstcolumn.

  CREATE OBJECT parent
    EXPORTING
      container_name              = 'CCONTAINER'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.



  o_alv = NEW #( i_parent = parent ).



  layout-stylefname = 'CELL'.
  layout-no_headers = 'X'.
  layout-cwidth_opt = 'X'.
  layout-no_toolbar = 'X'.
*


  o_alv->set_table_for_first_display(
   EXPORTING
     is_variant      = variant
     is_layout       = layout
   CHANGING
     it_fieldcatalog = lt_fcat
     it_outtab       = <fs_outtable> ).

  nmeses = 0.
  IF so_poper-high IS INITIAL.
    LOOP AT so_poper.
      nmeses = nmeses + 1.
    ENDLOOP.
  ELSE.
    nmeses = so_poper-high - so_poper-low + 1.
  ENDIF.
*
  col = 2.
  outputlen = 4.
  DO nmeses TIMES.
    row = 1.
    IF vl_firstcolumn EQ abap_false.
      PERFORM merge_cells USING row col outputlen .
      vl_firstcolumn = abap_true.
    ELSE.
      col = col + 3.
      outputlen = outputlen + 3.
      PERFORM merge_cells USING row col outputlen .
    ENDIF.

  ENDDO.
  col = col + 3.
  outputlen = outputlen + 3.
  PERFORM merge_cells USING row col outputlen.



  o_alv->z_set_fixed_col_row(
  col = 1
  row = 1 ).

  PERFORM set_colors.

 o_alv->z_display( ).

  CALL SCREEN 1001.

ENDFORM.

FORM set_colors.

  DATA vl_columconcep TYPE char10.


  LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
    CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
    ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
    IF <linea> EQ 'VENTAS' OR
       <linea> EQ 'COSTOS DE PRODUCCIÓN' OR
        <linea> EQ 'TOTAL COSTOS DE PRODUCCIÓN' OR
       <linea> EQ 'NO REPARTIDOS' OR
       <linea> EQ 'CONSUMO SEMILLA' OR
       <linea> EQ 'INVENTARIOS INICIALES' OR
       <linea> EQ 'INVENTARIOS FINALES' OR
       <linea> EQ 'COSTOS DE VENTAS' OR
       <linea> EQ 'UTILIDAD BRUTA' OR
       <linea> EQ 'TOTAL VENTAS' OR
       <linea> EQ 'VALIDACIÓN COSTO DE VENTA'.
      PERFORM paint_cells USING sy-tabix 1 'FIRST'.
    ELSEIF <linea> EQ 'GASTOS COSECHA CAÑA' OR
           <linea> EQ 'TOTAL GASTOS DE COSECHA' OR
           <linea> EQ 'GASTOS DE OPERACIÓN' OR
           <linea> EQ 'TOTAL GASTOS DE OPERACIÓN' OR
           <linea> EQ 'OTROS GASTOS' OR
           <linea> EQ 'TOTAL OTROS GASTOS' OR
           <linea> EQ 'IMPUESTOS' OR
           <linea> EQ 'TOTAL IMPUESTOS' OR
           <linea> EQ 'UTILIDAD DE OPERACIÓN' OR
            <linea> EQ 'UTILIDAD ANTES DE IMPUESTOS' OR
            <linea> EQ 'UTILIDAD NETA'.

      PERFORM paint_cells USING sy-tabix 1 'SECOND'.
    ENDIF.

  ENDLOOP.



ENDFORM.

FORM build_dinamic_table.

  DATA vl_firstcolumn.
  DATA vl_campo(12).

  DATA:
    nmeses   TYPE i,
    nveces   TYPE c,
    vl_poper TYPE poper.

  nmeses = 0.
  nveces = 0.
*  "se construyen las columnas de acuerdo a los lotes
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      " i_style_table   = 'X'
      it_fieldcatalog = lt_fcat
    IMPORTING
      ep_table        = lo_tabla
      "e_style_fname   = lv_fname.
    .
*
  ASSIGN lo_tabla->* TO <fs_outtable>.


  lv_fname = 'TABCOLOR'.

  SORT so_poper BY low.
  vl_firstcolumn = abap_false.
  ""se agregan los meses consultados dinamicos.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  IF so_poper-high IS INITIAL.
    LOOP AT so_poper.

      IF vl_firstcolumn EQ abap_false.
        CONCATENATE gv_subcampo so_poper-low '1' INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.

        vl_firstcolumn = abap_true.

      ELSE.

        CONCATENATE 'CAMPO' so_poper-low  INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.

      ENDIF.

      CONCATENATE p_gjahr so_poper-low+1(2) '01' INTO campocu.
      vl_date = campocu.
      CALL FUNCTION '/SAPCE/IURU_GET_MONTH_NAME'
        EXPORTING
          iv_date       = vl_date
        IMPORTING
          ev_month_name = vl_name_month.
      <linea> = vl_name_month.

    ENDLOOP.

  ELSE.

    nmeses = so_poper-high - so_poper-low + 1.
    vl_poper = so_poper-low.

    DO nmeses TIMES.

      IF vl_firstcolumn EQ abap_false.
        CONCATENATE gv_subcampo vl_poper '1' INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.

        vl_firstcolumn = abap_true.

      ELSE.

        CONCATENATE 'CAMPO' vl_poper  INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.

      ENDIF.

      CONCATENATE p_gjahr vl_poper+1(2) '01' INTO campocu.
      vl_date = campocu.
      CALL FUNCTION '/SAPCE/IURU_GET_MONTH_NAME'
        EXPORTING
          iv_date       = vl_date
        IMPORTING
          ev_month_name = vl_name_month.
      <linea> = vl_name_month.

      vl_poper = vl_poper + 1.

    ENDDO.

  ENDIF.
  ASSIGN COMPONENT 'TOTALES' OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'TOTALES'.

  vl_firstcolumn = abap_false.
  "aqui terminan de generarse los nombres de los meses.
  "y se generan las celdas divididas para cada MES.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  nveces = nveces + 1.
  IF so_poper-high IS INITIAL.
    LOOP AT so_poper.
      nveces = 1.
      IF vl_firstcolumn EQ abap_false.
        CONCATENATE 'CAMPO' so_poper-low  INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.

        vl_firstcolumn = abap_true.
        <linea> = 'CONCEPTO'.

        CONCATENATE gv_subcampo so_poper-low nveces INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = 'TONELADAS'.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo so_poper-low nveces INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = '$/TON.'.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo so_poper-low nveces INTO vl_campo.
        ASSIGN COMPONENT vl_campo  OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = 'COSTO REAL'.

      ELSE.

        CONCATENATE 'CAMPO' so_poper-low INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = 'TONELADAS'.
        CONCATENATE gv_subcampo so_poper-low nveces INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = '$/TON.'.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo so_poper-low nveces INTO vl_campo.
        ASSIGN COMPONENT vl_campo  OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = 'COSTO REAL'.



      ENDIF.




    ENDLOOP.

  ELSE.

    nmeses = so_poper-high - so_poper-low + 1.
    vl_poper = so_poper-low.

    DO nmeses TIMES.
      nveces = 1.
      IF vl_firstcolumn EQ abap_false.
        CONCATENATE 'CAMPO' vl_poper  INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.

        vl_firstcolumn = abap_true.
        <linea> = 'CONCEPTO'.

        CONCATENATE gv_subcampo vl_poper nveces INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = 'TONELADAS'.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo vl_poper nveces INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = '$/TON.'.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo vl_poper nveces INTO vl_campo.
        ASSIGN COMPONENT vl_campo  OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = 'COSTO REAL'.

      ELSE.

        CONCATENATE 'CAMPO' vl_poper INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = 'TONELADAS'.

        CONCATENATE gv_subcampo vl_poper nveces INTO vl_campo.
        ASSIGN COMPONENT vl_campo OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = '$/TON.'.

        nveces = nveces + 1.
        CONCATENATE gv_subcampo vl_poper nveces  INTO vl_campo.
        ASSIGN COMPONENT vl_campo  OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = 'COSTO REAL'.



      ENDIF.

      vl_poper = vl_poper + 1.

    ENDDO.
  ENDIF.

  ASSIGN COMPONENT 'TOTALES' OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'TONELADAS'.

  ASSIGN COMPONENT 'TOTAL_PT' OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = '$/TON'.

  ASSIGN COMPONENT 'TOTAL_PRE' OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'COSTO REAL'.

  nmeses = 0.



ENDFORM.

FORM set_functions_alv.

*   set Layout save restriction
*   1. Set Layout Key .. Unique key identifies the Differenet ALVs
  ls_key-report = sy-repid.
  lo_layout->set_key( ls_key ).

ENDFORM.


FORM set_title_header.
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



  wa_header-titulo1 = 'Resultados Costos Producción/Venta Agrícolas'.
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

FORM handle_user_command USING i_ucomm TYPE salv_de_function.

  CASE i_ucomm.
    WHEN '&MATNR'.

  ENDCASE.
*  PERFORM set_colors.
ENDFORM.                    " handle_user_command

FORM valida_soc.
  REFRESH: rg_bukrs, it_bukrs.

  SELECT bukrs INTO TABLE @it_bukrs
  FROM zco_agric_soc
  WHERE bukrs IN @p_bukrs.

  SORT it_bukrs BY bukrs.
  IF it_bukrs IS NOT INITIAL.
    LOOP AT it_bukrs INTO DATA(wa_bukrs).
      wa_rgbukrs-option = 'EQ'.
      wa_rgbukrs-sign = 'I'.
      wa_rgbukrs-low = wa_bukrs-bukrs.
      APPEND wa_rgbukrs TO rg_bukrs.
    ENDLOOP.
  ENDIF.


ENDFORM.

FORM paint_cells USING p_row TYPE i
                       p_col TYPE i
                       p_reporte TYPE string.

  IF p_reporte EQ 'FIRST'.
    o_alv->z_set_cell_style(
    row   = p_row
    col   = p_col
    style = CONV #( alv_style_font_bold
            + alv_style_align_left_bottom
            + alv_style_color_int_total ) ) .
  ELSE.
    o_alv->z_set_cell_style(
  row   = p_row
  col   = p_col
  style = CONV #( alv_style_font_bold
          + alv_style_align_left_bottom
          + alv_style_color_int_positive ) ) .
  ENDIF.
ENDFORM.

FORM merge_cells USING p_row TYPE i
                       p_col TYPE i
                       p_outputlen TYPE i.

*  o_alv->z_set_merge_vert(
*         row           = 1
*         tab_col_merge =  VALUE #(
**            ( col_id    = 1 outputlen = 1 ) ) ).

  o_alv->z_set_cell_style(
      row   = p_row
      col   = p_col
      style = CONV #( alv_style_font_bold
              + alv_style_align_center_center
              + alv_style_color_key ) ) .

  " Horizontal verbinden
  o_alv->z_set_merge_horiz(
      row           = p_row
      tab_col_merge = VALUE #(
        ( col_id    = p_col  outputlen = p_outputlen  ) ) ).
**
*
*  o_alv->z_set_cell_style(
*      row   = 1
*      col   = 5
*      style = CONV #( alv_style_font_bold
*              + alv_style_align_center_center
*              + alv_style_color_key ) ) .
*
*  o_alv->z_set_merge_horiz(
*      row           = 1
*      tab_col_merge = VALUE #(
*        ( col_id    = 5  outputlen = 7  ) ) ).
*
*  o_alv->z_set_cell_style(
*      row   = 1
*      col   = 8
*      style = CONV #( alv_style_font_bold
*              + alv_style_align_center_center
*              + alv_style_color_key ) ) .
*
*  o_alv->z_set_merge_horiz(
*      row           = 1
*      tab_col_merge = VALUE #(
*        ( col_id    = 8  outputlen = 10  ) ) ).

*
*  o_alv->z_set_merge_horiz(
*      row           = 2
*      tab_col_merge = VALUE #(
*        ( col_id    = 1  outputlen = 1 )
*        ( col_id    = 1 outputlen = 12 ) ) ).
*
*  o_alv->z_set_cell_style(
*      row   = 1
*      col   = 3
*      style = alv_style_font_bold ).
*
*  o_alv->z_set_cell_style(
*      row   = 1
*      col   = 4
*      style = alv_style_font_bold ).
*
*  alv_grid->z_set_cell_style(
*      row   = 1
*      col   = 9
*      style = alv_style_font_bold ).
*
*  alv_grid->z_set_cell_style(
*      row   = 1
*      col   = 10
*      style = alv_style_font_bold ).
*
*
*  alv_grid->z_set_merge_horiz(
*      row           = 2
*      tab_col_merge = VALUE #(
*        ( col_id    = 4  outputlen = 7 )
*        ( col_id    = 10 outputlen = 2 ) ) ).
*
*
*  alv_grid->z_set_cell_style(
*      col   = 3
*      style = CONV #( alv_style_color_group
*                    + alv_style_align_center_center ) ).
*
*  style    = alv_style_color_heading
*           + alv_style_align_center_center.
*
*  alv_grid->z_set_cell_style(
*      col   = 4
*      style = style ).
*
*  alv_grid->z_set_cell_style(
*      col   = 5
*      style = style ).
*
*  alv_grid->z_set_cell_style(
*      col   = 6
*      style = style ).
*
*  alv_grid->z_set_cell_style(
*      col   = 7
*      style = style ).
*
*  alv_grid->z_set_cell_style(
*      col   = 8
*      style = style ).
*
*  style     = alv_style_color_total
*            + alv_style_align_center_center.
*
*  alv_grid->z_set_cell_style(
*      col   = 9
*      style = style ).
*
*  style     = alv_style_color_negative
*            + alv_style_align_center_center.
*
*  alv_grid->z_set_cell_style(
*      col   = 10
*      style = style ).
*
*  alv_grid->z_set_cell_style(
*      col   = 11
*      style = style ).
*
*  alv_grid->z_set_cell_style(
*      col   = 12
*      style = style ).
*
*  alv_grid->z_set_cell_style(
*      col   = 13
*      style = style ).
*
*  style    = alv_style_color_positive
*           + alv_style_align_center_center.
*
*  alv_grid->z_set_cell_style(
*      col   = 14
*      style = style ).
*
*  alv_grid->z_set_cell_style(
*      col   = 15
*      style = style ).
*
*  style     = alv_style_color_int_background
*            + alv_style_align_center_center.
*
*  alv_grid->z_set_cell_style(
*      col   = 16
*      style = style ).
*
*  style    = alv_style_color_positive
*           + alv_style_align_center_center
*           + alv_style_font_italic.
*
*
*  alv_grid->z_set_cell_style(
*      row   = 4
*      col   = 2
*      style = style ).




ENDFORM.

FORM get_vtas_netas.


  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_poperi  TYPE poper,
        vl_poperf  TYPE poper,
        nveces.

  DATA vl_campo TYPE char10.
  DATA vl_columconcep TYPE char10.

  DATA: vl_prexton TYPE menge_d,
        vl_msl     TYPE menge_d,
        vl_hsl     TYPE menge_d,
        vl_acumhsl TYPE menge_d,
        vl_acummsl TYPE menge_d.

  DATA: vl_firstcolumn, vl_found.




  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  obj_agricolas->get_ventas_netas(
    EXPORTING
      p_bukrs  = rg_bukrs
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
    CHANGING
      i_tabla  = it_vtas_netas
  ).

  REFRESH vl_rgpoper.
  CLEAR wa_rgpoper.

  PERFORM get_meses CHANGING vl_rgpoper.

  UNASSIGN <fs_struct>.
  UNASSIGN <linea>.

  LOOP AT vl_rgpoper INTO wa_rgpoper.
    REFRESH it_aux_out.
    CLEAR wa_aux_out.

    IF vl_firstcolumn = abap_false.
      CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.
      APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
      ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
      <linea> = 'VENTAS'.

    ENDIF.

    LOOP AT it_vtas_netas INTO DATA(workarea) WHERE poper = wa_rgpoper-low.
      wa_aux_out-concepto = workarea-concepto.
      wa_aux_out-menge = workarea-msl.
      wa_aux_out-month = workarea-hsl.
      COLLECT wa_aux_out INTO it_aux_out.
    ENDLOOP.

    LOOP AT it_aux_out ASSIGNING <fs_struct>.
      ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_struct> TO <linea>.
*      IF <linea> LT 0.
      <linea> = <linea> * -1.

*      ENDIF.

      ASSIGN COMPONENT 'MONTH' OF STRUCTURE <fs_struct> TO <linea>.
*      IF <linea> LT 0.
      <linea> = <linea> * -1.
*      ENDIF.


    ENDLOOP.

    IF it_aux_out IS NOT INITIAL.

      LOOP AT it_aux_out INTO wa_aux_out.
        nveces ='0'.
        vl_found = abap_false.

        LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          IF <linea> = wa_aux_out-concepto.
            vl_found = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF vl_found EQ abap_false.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          <linea> = wa_aux_out-concepto.
          nveces = nveces + 1.
        ENDIF.

        CLEAR campocu.




        IF vl_firstcolumn EQ abap_true.
          CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.


        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_msl = wa_aux_out-menge. "toneladas
        <linea> = vl_msl.

        vl_acummsl = vl_acummsl + vl_msl.
        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        IF wa_aux_out-menge GT 0.
          vl_prexton = floor( wa_aux_out-month / wa_aux_out-menge ) .
        ELSE.
          vl_prexton = '0.000'.
        ENDIF.
        <linea> = vl_prexton . " 0. "% / toneladas

        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          nveces = nveces + 1.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_hsl = wa_aux_out-month.
        <linea> = vl_hsl.

        vl_acumhsl = vl_acumhsl + vl_hsl.
      ENDLOOP.

    ENDIF.

    IF vl_firstcolumn = abap_false.
      APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
      ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
      <linea> = 'TOTAL VENTAS'.
      nveces = '1'.

      IF vl_firstcolumn EQ abap_true.
        CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
      ELSE.
        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ENDIF.

      ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
      <linea> = vl_acummsl.

      IF vl_firstcolumn EQ abap_true.

        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ELSE.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ENDIF.

      ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
      IF vl_acummsl GT 0.
        vl_acummsl = vl_acumhsl / vl_acummsl.
      ENDIF.
      <linea> = vl_acummsl.

      IF vl_firstcolumn EQ abap_true.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ELSE.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ENDIF.

      ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
      <linea> = vl_acumhsl.

    ELSE.
      LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        IF <linea> = 'TOTAL VENTAS'.
          EXIT.
        ENDIF.
      ENDLOOP.

      nveces = '1'.

      IF vl_firstcolumn EQ abap_true.
        CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
      ELSE.
        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ENDIF.

      ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
      <linea> = vl_acummsl.

      IF vl_firstcolumn EQ abap_true.
        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ELSE.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ENDIF.

      ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
      IF vl_acummsl GT 0.
        vl_acummsl = vl_acumhsl / vl_acummsl.
      ENDIF.
      <linea> =  vl_acummsl.


      IF vl_firstcolumn EQ abap_true.
        nveces = nveces + 1.
        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ELSE.
        nveces = nveces + 2.
        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
      ENDIF.


      ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
      <linea> = vl_acumhsl.



    ENDIF.

    UNASSIGN <fs_struct>.
    UNASSIGN <linea>.
    vl_firstcolumn = abap_true.
    CLEAR: vl_acummsl, vl_acumhsl.
  ENDLOOP.



ENDFORM.

FORM get_meses CHANGING p_rgpoper.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_poperi  TYPE poper,
        vl_poperf  TYPE poper,
        nveces     TYPE i.



  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    vl_poperi = so_poper-low.
    vl_poperf = so_poper-high.
    nveces = vl_poperf - vl_poperi + 1.
    DO nveces TIMES.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = vl_poperi.
      APPEND wa_rgpoper TO vl_rgpoper.
      vl_poperi = vl_poperi + 1.
    ENDDO.
  ENDIF.

  p_rgpoper = vl_rgpoper.

ENDFORM.

FORM get_invinicial.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs.

  DATA:
    vl_poperi TYPE poper,
    vl_poperf TYPE poper,
    nveces.

  DATA vl_campo TYPE char10.
  DATA vl_columconcep TYPE char10.

  DATA vl_prexton TYPE menge_d.

  DATA: vl_firstcolumn, vl_found.

  PERFORM get_meses
    CHANGING  vl_rgpoper.


  IF p_bukrs-high IS INITIAL.
    LOOP AT p_bukrs.
      CLEAR wa_rgbukrs.
      wa_rgbukrs-sign = 'I'.
      wa_rgbukrs-option = 'EQ'.
      wa_rgbukrs-low = p_bukrs-low.
      APPEND wa_rgbukrs TO vl_rgbukrs.
    ENDLOOP.
  ELSE.
    wa_rgbukrs-sign = 'I'.
    wa_rgbukrs-option = 'BT'.
    wa_rgbukrs-low = p_bukrs-low.
    wa_rgbukrs-high = p_bukrs-high.
    APPEND wa_rgbukrs TO vl_rgbukrs.
  ENDIF.


  obj_agricolas->get_inv_inicial(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_bukrs  = vl_rgbukrs
    CHANGING
      i_tabla  = it_inv_ini
  ).

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  LOOP AT vl_rgpoper INTO wa_rgpoper.
    REFRESH it_aux_out.
    CLEAR wa_aux_out.
    vl_prexton = '0.000'.
    IF vl_firstcolumn = abap_false.
      CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.

    ENDIF.

    LOOP AT it_inv_ini INTO DATA(workarea) WHERE lfmon = wa_rgpoper-low+1(2).
      wa_aux_out-concepto = workarea-concepto.
      wa_aux_out-menge = workarea-lbkum.
      wa_aux_out-month = workarea-salk3.
      COLLECT wa_aux_out INTO it_aux_out.
    ENDLOOP.

    IF it_aux_out IS NOT INITIAL.

      LOOP AT it_aux_out INTO wa_aux_out.
        nveces ='0'.
        vl_found = abap_false.

        LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          IF <linea> = wa_aux_out-concepto.
            vl_found = abap_true.
          ENDIF.
        ENDLOOP.

        IF vl_found EQ abap_false.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          <linea> = wa_aux_out-concepto.
          nveces = nveces + 1.
        ENDIF.

        CLEAR campocu.




        IF vl_firstcolumn EQ abap_true.
          CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.


        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = wa_aux_out-menge. "toneladas
        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_prexton = floor( wa_aux_out-month / wa_aux_out-menge )   .
        <linea> = vl_prexton . " 0. "% / toneladas
        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          nveces = nveces + 1.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = wa_aux_out-month.

      ENDLOOP.
    ENDIF.
    vl_firstcolumn = abap_true.
  ENDLOOP.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

ENDFORM.

FORM costos_produccion.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs,
        vl_rgaufnr TYPE RANGE OF afko-aufnr,
        wa_rgaufnr LIKE LINE OF vl_rgaufnr.

  FIELD-SYMBOLS: <fs_struct>    TYPE any,
                 <fs_substruct> TYPE any,
                 <fs_auxstruct> TYPE any,
                 <fs_auxlinea>  TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_sublinea>  TYPE any,
                 <fs_tt>        TYPE table.

  DATA: vl_acum_act_msl TYPE menge_d,
        vl_acum_act_hsl TYPE menge_d.

  DATA:
    vl_poperi TYPE poper,
    vl_poperf TYPE poper,
    nveces, vl_index TYPE i.

  DATA vl_campo TYPE char10.
  DATA vl_columconcep TYPE char10.

  DATA: vl_prexton TYPE menge_d.


  DATA: vl_firstmonth, vl_found.

  PERFORM get_meses CHANGING vl_rgpoper.

  IF p_bukrs-high IS INITIAL.
    LOOP AT p_bukrs.
      CLEAR wa_rgbukrs.
      wa_rgbukrs-sign = 'I'.
      wa_rgbukrs-option = 'EQ'.
      wa_rgbukrs-low = p_bukrs-low.
      APPEND wa_rgbukrs TO vl_rgbukrs.
    ENDLOOP.
  ELSE.
    wa_rgbukrs-sign = 'I'.
    wa_rgbukrs-option = 'BT'.
    wa_rgbukrs-low = p_bukrs-low.
    wa_rgbukrs-high = p_bukrs-high.
    APPEND wa_rgbukrs TO vl_rgbukrs.
  ENDIF.


  obj_agricolas->get_aufnr_cte(
    EXPORTING
      p_gjahr   = p_gjahr
      p_popers  = vl_rgpoper
      p_bukrs   = vl_rgbukrs
*      p_clorder =
*      p_tipo    =
*      p_werks   =
    CHANGING
      i_tabla   = it_aufnr
  ).

  IF it_aufnr IS NOT INITIAL.
    LOOP AT it_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO vl_rgaufnr.
    ENDLOOP.

    obj_agricolas->get_costos_pro(
      EXPORTING
        i_aufnr =  vl_rgaufnr
      CHANGING
        i_tabla = it_costos_pro
    ).

  ENDIF.

  SORT it_costos_pro BY poper racct.

  IF it_costos_pro IS NOT INITIAL.

    SORT it_costos_pro BY racct.

    SELECT subsetname, descript
    INTO TABLE @DATA(head_activities)
    FROM setnode
    INNER JOIN setheadert AS h ON h~setclass = setnode~setclass
    AND h~subclass = setnode~subclass AND h~setname = setnode~subsetname
    WHERE setnode~setname = 'REPCTOAGRI'
    AND setnode~setclass = '0102' AND setnode~subclass = 'GP00'.

    SELECT setname, valfrom
    INTO TABLE @DATA(it_leaf)
    FROM setleaf
    FOR ALL ENTRIES IN @head_activities
    WHERE setname = @head_activities-subsetname

    .



    LOOP AT head_activities INTO DATA(wa_head).
      APPEND INITIAL LINE TO it_grupos_act ASSIGNING <fs_struct>.
      ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.
      <linea> = wa_head-subsetname.

      ASSIGN COMPONENT 'CONCEPTO' OF STRUCTURE <fs_struct> TO <linea>.
      <linea> = wa_head-descript.

    ENDLOOP.

    LOOP AT vl_rgpoper INTO wa_rgpoper.
      REFRESH it_aux_out_act.
      CLEAR wa_aux_out_act.
      LOOP AT it_costos_pro INTO DATA(wa_costos_pro) WHERE poper = wa_rgpoper-low.
        READ TABLE it_leaf INTO DATA(wa_leaf) WITH KEY valfrom = wa_costos_pro-racct.
        IF sy-subrc EQ 0.

          UNASSIGN <fs_struct>.
          READ TABLE it_grupos_act ASSIGNING <fs_struct> WITH KEY subsetname = wa_leaf-setname.
          IF sy-subrc EQ 0.
            wa_aux_out_act-subsetname = wa_leaf-setname.
            wa_aux_out_act-concepto = wa_costos_pro-concepto.
            wa_aux_out_act-menge = wa_costos_pro-msl.
            wa_aux_out_act-month = wa_costos_pro-hsl.
            COLLECT wa_aux_out_act INTO it_aux_out_act.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF it_aux_out_act IS NOT INITIAL.

        LOOP AT it_grupos_act ASSIGNING <fs_struct>.
          CLEAR vl_acum_act_msl.
          CLEAR vl_acum_act_hsl.
          ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE <fs_struct> TO <fs_tt>.
          ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.

          LOOP AT it_aux_out_act INTO wa_aux_out_act WHERE subsetname = <linea>.
            APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_substruct>.
            ASSIGN COMPONENT 'VALFROM' OF STRUCTURE <fs_substruct> TO <linea>.
            <linea> = wa_aux_out_act-concepto.
            ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
            <linea> = wa_aux_out_act-menge.
            vl_acum_act_msl = vl_acum_act_msl + wa_aux_out_act-menge.
            ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <linea>.
            <linea> = wa_aux_out_act-month.
            vl_acum_act_hsl = vl_acum_act_hsl + wa_aux_out_act-month.
            ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <linea>.
            <linea> = wa_rgpoper-low.
          ENDLOOP.

          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_struct> TO <linea>.
          <linea> = vl_acum_act_msl.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_struct> TO <linea>.
          <linea> = vl_acum_act_hsl.
        ENDLOOP.

      ENDIF.
    ENDLOOP.
  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""se acomodan en el ALV
  UNASSIGN <fs_struct>.
  UNASSIGN <fs_substruct>.
  UNASSIGN <linea>.
  UNASSIGN <fs_tt>.



  CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'COSTOS DE PRODUCCIÓN'.

  LOOP AT it_grupos_act INTO DATA(wa_grupos_act).

    CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
    ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_grupos_act-concepto.
    vl_index = sy-tabix.
  ENDLOOP.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'TOTAL COSTOS DE PRODUCCIÓN'.
  vl_index = vl_index + 1.

  vl_firstmonth = abap_false.
  LOOP AT vl_rgpoper INTO wa_rgpoper.

    LOOP AT it_grupos_act INTO  wa_grupos_act.
      nveces ='1'.

      LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        IF <linea> = wa_grupos_act-concepto.

          EXIT.
        ENDIF.
      ENDLOOP.

      CLEAR campocu.

      ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE wa_grupos_act TO <fs_tt> .
      "se eliminan los ceros""""""""""""""""""""""""""""""""""""""""""
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.
        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_linea>.

        IF <linea> EQ 0 AND <fs_linea> EQ 0.
          DELETE <fs_tt> INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_substruct>.
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.

        ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
        IF <fs_sublinea> EQ wa_rgpoper-low.

          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> GT 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.

            vl_acum_act_msl = <linea> + <fs_sublinea>. "toneladas
            <linea> = vl_acum_act_msl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.

          IF vl_firstmonth EQ abap_true.
            nveces = nveces + 1.
          ELSE.
            nveces = nveces + 2.
          ENDIF.


          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> GT 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            vl_acum_act_hsl = <linea> + <fs_sublinea>.
            <linea> = vl_acum_act_hsl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.


          nveces = nveces - 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          vl_prexton =  floor( vl_acum_act_hsl /  vl_acum_act_msl ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
          IF  sy-subrc EQ 0.
            <linea> =  vl_prexton . " 0. "% / toneladas
          ENDIF.

          "acumulado
          nveces = nveces + 1.
          READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          nveces = nveces - 2.
          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          "CONCATENATE campocu wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.

          nveces = nveces + 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          vl_prexton = floor( <linea> /  <fs_auxlinea> ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          <linea> =  vl_prexton .
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


        ENDIF.
        nveces = '1'.

      ENDLOOP.

    ENDLOOP.
    CLEAR: vl_acum_act_hsl, vl_acum_act_msl.
    vl_firstmonth = abap_true.
  ENDLOOP.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

ENDFORM.

FORM get_invfinal.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs.

  DATA:
    vl_poperi TYPE poper,
    vl_poperf TYPE poper,
    nveces.

  DATA vl_campo TYPE char10.
  DATA vl_columconcep TYPE char10.

  DATA: vl_prexton TYPE menge_D,
        vl_msl     TYPE menge_d,
        vl_hsl     TYPE menge_d.

  DATA: vl_firstcolumn, vl_found.

  PERFORM get_meses
    CHANGING  vl_rgpoper.


  IF p_bukrs-high IS INITIAL.
    LOOP AT p_bukrs.
      CLEAR wa_rgbukrs.
      wa_rgbukrs-sign = 'I'.
      wa_rgbukrs-option = 'EQ'.
      wa_rgbukrs-low = p_bukrs-low.
      APPEND wa_rgbukrs TO vl_rgbukrs.
    ENDLOOP.
  ELSE.
    wa_rgbukrs-sign = 'I'.
    wa_rgbukrs-option = 'BT'.
    wa_rgbukrs-low = p_bukrs-low.
    wa_rgbukrs-high = p_bukrs-high.
    APPEND wa_rgbukrs TO vl_rgbukrs.
  ENDIF.


  obj_agricolas->get_inv_final(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_bukrs  = vl_rgbukrs
    CHANGING
      i_tabla  = it_inv_final
  ).

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  LOOP AT vl_rgpoper INTO wa_rgpoper.
    REFRESH it_aux_out.
    CLEAR wa_aux_out.

    IF vl_firstcolumn = abap_false.
      CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.

    ENDIF.

    LOOP AT it_inv_final INTO DATA(workarea) WHERE lfmon = wa_rgpoper-low+1(2).
      wa_aux_out-concepto = workarea-concepto.
      wa_aux_out-menge = workarea-lbkum.
      wa_aux_out-month = workarea-salk3.
      COLLECT wa_aux_out INTO it_aux_out.
    ENDLOOP.

    IF it_aux_out IS NOT INITIAL.

      LOOP AT it_aux_out INTO wa_aux_out.
        nveces ='0'.
        vl_found = abap_false.

        LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          IF <linea> = wa_aux_out-concepto.
            vl_found = abap_true.
          ENDIF.
        ENDLOOP.

        IF vl_found EQ abap_false.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
          nveces = nveces + 1.
        ENDIF.

        CLEAR campocu.

        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = wa_aux_out-concepto.


        IF vl_firstcolumn EQ abap_true.
          CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.


        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_msl = wa_aux_out-menge. "toneladas
        <linea> = vl_msl.
        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_prexton = floor( wa_aux_out-month / wa_aux_out-menge ) .
        <linea> = vl_prexton . " 0. "% / toneladas
        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          nveces = nveces + 1.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_hsl = wa_aux_out-month.
        <linea> = vl_hsl.
      ENDLOOP.
    ENDIF.
    vl_firstcolumn = abap_true.
  ENDLOOP.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


ENDFORM.


FORM get_ndi.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs.

  DATA vl_campo TYPE char10.
  DATA: vl_columconcep TYPE char10, nveces.

  DATA: vl_prexton TYPE menge_D,
        vl_msl     TYPE menge_d,
        vl_hsl     TYPE menge_d.

  DATA: vl_firstcolumn, vl_found.

  PERFORM get_meses
    CHANGING vl_rgpoper .

  IF p_bukrs-high IS INITIAL.
    LOOP AT p_bukrs.
      CLEAR wa_rgbukrs.
      wa_rgbukrs-sign = 'I'.
      wa_rgbukrs-option = 'EQ'.
      wa_rgbukrs-low = p_bukrs-low.
      APPEND wa_rgbukrs TO vl_rgbukrs.
    ENDLOOP.
  ELSE.
    wa_rgbukrs-sign = 'I'.
    wa_rgbukrs-option = 'BT'.
    wa_rgbukrs-low = p_bukrs-low.
    wa_rgbukrs-high = p_bukrs-high.
    APPEND wa_rgbukrs TO vl_rgbukrs.
  ENDIF.


  obj_agricolas->get_ndi(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_bukrs  = vl_rgbukrs
    CHANGING
      i_tabla  = it_ndis
  ).

  IF it_ndis IS NOT INITIAL.

    LOOP AT vl_rgpoper INTO wa_rgpoper.

      IF vl_firstcolumn = abap_false.
        CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.

      ENDIF.

      LOOP AT it_ndis INTO DATA(wa_ndis)  WHERE poper = wa_rgpoper-low .
        nveces ='0'.
        vl_found = abap_false.

        LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          IF <linea> = wa_ndis-concepto.
            vl_found = abap_true.
          ENDIF.
        ENDLOOP.

        IF vl_found EQ abap_false.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          <linea> = wa_ndis-concepto.

        ENDIF.

        CLEAR campocu.

        IF vl_firstcolumn EQ abap_true.
          nveces = '2'.
          " CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
        ELSE.
          nveces = '3'.
        ENDIF.

        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_hsl = wa_ndis-hsl.
        <linea> = vl_hsl.

      ENDLOOP.
      vl_firstcolumn = abap_true.

    ENDLOOP.
  ELSE.

    READ TABLE vl_rgpoper INTO wa_rgpoper INDEX 1.
    CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
    ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = 'NO REPARTIDOS'.
    vl_firstcolumn = abap_false.

    LOOP AT vl_rgpoper INTO wa_rgpoper.

      nveces = '1'.
      vl_hsl = '0.000'.

      IF vl_firstcolumn = abap_false.

        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_hsl.
        nveces = nveces + 1.

        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_hsl.
        nveces = nveces + 1.

        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_hsl.
        nveces = nveces + 1.

      ELSE.

        CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.
        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_hsl.

        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_hsl.
        nveces = nveces + 1.

        CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_hsl.
        nveces = nveces + 1.

      ENDIF.

      vl_firstcolumn = abap_true.
    ENDLOOP.

  ENDIF.
ENDFORM.



FORM get_semilla.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs.

  DATA vl_campo TYPE char10.
  DATA: vl_columconcep TYPE char10, nveces.

  DATA: vl_prexton TYPE menge_D,
        vl_msl     TYPE menge_d,
        vl_hsl     TYPE menge_d.

  DATA: vl_firstcolumn, vl_found.

  PERFORM get_meses
    CHANGING vl_rgpoper .

  IF p_bukrs-high IS INITIAL.
    LOOP AT p_bukrs.
      CLEAR wa_rgbukrs.
      wa_rgbukrs-sign = 'I'.
      wa_rgbukrs-option = 'EQ'.
      wa_rgbukrs-low = p_bukrs-low.
      APPEND wa_rgbukrs TO vl_rgbukrs.
    ENDLOOP.
  ELSE.
    wa_rgbukrs-sign = 'I'.
    wa_rgbukrs-option = 'BT'.
    wa_rgbukrs-low = p_bukrs-low.
    wa_rgbukrs-high = p_bukrs-high.
    APPEND wa_rgbukrs TO vl_rgbukrs.
  ENDIF.


  obj_agricolas->get_semilla(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_bukrs  = vl_rgbukrs
    CHANGING
      i_tabla  = it_semilla
  ).

  REFRESH it_aux_out.
  CLEAR wa_aux_out.




  LOOP AT vl_rgpoper INTO wa_rgpoper.
    REFRESH it_aux_out.
    CLEAR wa_aux_out.
    vl_prexton = '0.000'.

    "IF vl_firstcolumn = abap_false.
    READ TABLE vl_rgpoper INTO DATA(wa_rgpoper0) INDEX 1.
    CONCATENATE 'CAMPO' wa_rgpoper0-low INTO vl_columconcep.

    "ENDIF.

    LOOP AT it_semilla INTO DATA(workarea) WHERE poper = wa_rgpoper-low+1(2).
      wa_aux_out-concepto = workarea-concepto.
      wa_aux_out-menge = workarea-msl.
      wa_aux_out-month = workarea-hsl.
      COLLECT wa_aux_out INTO it_aux_out.
    ENDLOOP.

    IF it_aux_out IS NOT INITIAL.

      LOOP AT it_aux_out INTO wa_aux_out.
        nveces ='0'.


        LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          IF <linea> = wa_aux_out-concepto.
            vl_found = abap_true.
          ENDIF.
        ENDLOOP.

        IF vl_found EQ abap_false.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          <linea> = wa_aux_out-concepto.
          nveces = nveces + 1.
        ENDIF.

        CLEAR campocu.

        IF vl_firstcolumn EQ abap_true.
          CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.


        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = wa_aux_out-menge. "toneladas
        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_prexton =  wa_aux_out-month / wa_aux_out-menge .
        <linea> = vl_prexton . " 0. "% / toneladas
        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          nveces = nveces + 1.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = wa_aux_out-month.

      ENDLOOP.
    ELSE.

      READ TABLE vl_rgpoper INTO wa_rgpoper INDEX 1.
      CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.
      vl_found = abap_false.
      LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        IF <linea> = 'CONSUMO SEMILLA'.
          vl_found = abap_true.
        ENDIF.
      ENDLOOP.

      IF vl_found EQ abap_false.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = 'CONSUMO SEMILLA'.
        vl_firstcolumn = abap_false.

        LOOP AT vl_rgpoper INTO wa_rgpoper.""

          nveces = '1'.
          vl_hsl = '0.000'.

          IF vl_firstcolumn = abap_false.

            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            <linea> = vl_hsl.
            nveces = nveces + 1.

            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            <linea> = vl_hsl.
            nveces = nveces + 1.

            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            <linea> = vl_hsl.
            nveces = nveces + 1.

          ELSE.

            CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.
            ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
            <linea> = vl_hsl.

            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            <linea> = vl_hsl.
            nveces = nveces + 1.

            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            <linea> = vl_hsl.
            nveces = nveces + 1.

          ENDIF.

          vl_firstcolumn = abap_true.
        ENDLOOP.

      ENDIF.

    ENDIF.
    "vl_firstcolumn = abap_true.
  ENDLOOP.

ENDFORM.


FORM set_costo_vtas.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  DATA vl_campo TYPE char10.
  DATA: vl_columconcep TYPE char10, nvecest, nvecesc.

  DATA: vl_prexton   TYPE menge_D,
        vl_msl       TYPE menge_d,
        vl_hsl       TYPE menge_d,
        vl_ubhsl     TYPE menge_d,
        vl_ubmsl     TYPE menge_d,
        vl_tot_cvmsl TYPE menge_d,
        vl_tot_cvhsl TYPE menge_d.

  DATA: vl_firstcolumn, vl_found, vl_index TYPE i.
  FIELD-SYMBOLS: <fs_substruct> TYPE any,
                 <fs_sublinea>  TYPE any.

  PERFORM get_meses
    CHANGING vl_rgpoper .


  READ TABLE vl_rgpoper INTO wa_rgpoper INDEX 1.
  CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'COSTOS DE VENTAS'.

  UNASSIGN <fs_struct>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'UTILIDAD BRUTA'.


  UNASSIGN <fs_struct>.
  LOOP AT vl_rgpoper INTO wa_rgpoper.

    LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
      ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
      IF vl_firstcolumn EQ abap_true.
        nvecest = '0'.
        nvecesc = '2'.
      ELSE.
        nvecest = '1'.
        nvecesc = '3'.
      ENDIF.

      CASE <linea>.
        WHEN 'VENTAS'.

          vl_index = sy-tabix + 1.

          CONCATENATE gv_subcampo wa_rgpoper-low nvecesc INTO campocu.
          READ TABLE <fs_outtable> ASSIGNING <fs_substruct> INDEX vl_index.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_ubhsl = vl_ubhsl + <fs_sublinea>.

          IF nvecest EQ '0'.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nvecest INTO campocu.
          ENDIF.

          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_ubmsl = vl_ubmsl + <fs_sublinea>.


          UNASSIGN <fs_sublinea>.
          UNASSIGN <fs_substruct>.

        WHEN 'INVENTARIOS INICIALES'.

          vl_index = sy-tabix.

          CONCATENATE gv_subcampo wa_rgpoper-low nvecesc INTO campocu.
          READ TABLE <fs_outtable> ASSIGNING <fs_substruct> INDEX vl_index.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_hsl = vl_hsl + <fs_sublinea>.

          IF nvecest EQ '0'.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nvecest INTO campocu.
          ENDIF.

          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_msl = vl_msl + <fs_sublinea>.
          UNASSIGN <fs_sublinea>.
          UNASSIGN <fs_substruct>.


        WHEN 'INVENTARIOS FINALES'.

          vl_index = sy-tabix.

          CONCATENATE gv_subcampo wa_rgpoper-low nvecesc INTO campocu.
          READ TABLE <fs_outtable> ASSIGNING <fs_substruct> INDEX vl_index.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_hsl = vl_hsl - <fs_sublinea>.

          IF nvecest EQ '0'.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nvecest INTO campocu.
          ENDIF.


          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_msl = vl_msl - <fs_sublinea>.
          UNASSIGN <fs_sublinea>.
          UNASSIGN <fs_substruct>.

        WHEN 'TOTAL COSTOS DE PRODUCCIÓN'.

          vl_index = sy-tabix.

          CONCATENATE gv_subcampo wa_rgpoper-low nvecesc INTO campocu.
          READ TABLE <fs_outtable> ASSIGNING <fs_substruct> INDEX vl_index.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_hsl = vl_hsl + <fs_sublinea>.

          IF nvecest EQ '0'.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nvecest INTO campocu.
          ENDIF.


          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_msl = vl_msl + <fs_sublinea>.

          UNASSIGN <fs_sublinea>.
          UNASSIGN <fs_substruct>.

        WHEN 'NO REPARTIDOS'.

          vl_index = sy-tabix.

          CONCATENATE gv_subcampo wa_rgpoper-low nvecesc INTO campocu.
          READ TABLE <fs_outtable> ASSIGNING <fs_substruct> INDEX vl_index.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_hsl = vl_hsl - <fs_sublinea>.

          IF nvecest EQ '0'.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nvecest INTO campocu.
          ENDIF.


          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_msl = vl_msl - <fs_sublinea>.

          UNASSIGN <fs_sublinea>.
          UNASSIGN <fs_substruct>.

        WHEN 'CONSUMO SEMILLA'.

          vl_index = sy-tabix.

          CONCATENATE gv_subcampo wa_rgpoper-low nvecesc INTO campocu.
          READ TABLE <fs_outtable> ASSIGNING <fs_substruct> INDEX vl_index.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_hsl = vl_hsl - <fs_sublinea>.

          IF nvecest EQ '0'.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nvecest INTO campocu.
          ENDIF.


          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          vl_msl = vl_msl - <fs_sublinea>.

          UNASSIGN <fs_sublinea>.
          UNASSIGN <fs_substruct>.

        WHEN 'COSTOS DE VENTAS'.
          vl_index = sy-tabix.

          CONCATENATE gv_subcampo wa_rgpoper-low nvecesc INTO campocu.
          READ TABLE <fs_outtable> ASSIGNING <fs_substruct> INDEX vl_index.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          <fs_sublinea> = vl_hsl.
          vl_tot_cvhsl = vl_hsl.
          IF nvecest EQ '0'.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nvecest INTO campocu.
          ENDIF.


          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          <fs_sublinea> = vl_msl.
          vl_tot_cvmsl = vl_msl.

          IF nvecest EQ '0'.
            CONCATENATE gv_subcampo wa_rgpoper-low '1' INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low '2' INTO campocu.
          ENDIF.


          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF vl_msl GT 0.
            vl_msl = vl_hsl / vl_msl.

            <fs_sublinea> =  vl_msl.

          ENDIF.



          UNASSIGN <fs_sublinea>.
          UNASSIGN <fs_substruct>.

        WHEN 'UTILIDAD BRUTA'.

          vl_index = sy-tabix.

          CONCATENATE gv_subcampo wa_rgpoper-low nvecesc INTO campocu.
          READ TABLE <fs_outtable> ASSIGNING <fs_substruct> INDEX vl_index.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          <fs_sublinea> = vl_ubhsl - vl_tot_cvhsl.


          IF nvecest EQ '0'.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nvecest INTO campocu.
          ENDIF.

          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          <fs_sublinea> = vl_ubmsl - vl_tot_cvmsl.


          IF nvecest EQ '0'.
            CONCATENATE gv_subcampo wa_rgpoper-low '1' INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low '2' INTO campocu.
          ENDIF.

          vl_msl = vl_ubmsl - vl_tot_cvmsl.
          vl_hsl = vl_ubhsl - vl_tot_cvhsl.
          IF vl_msl GT 0.
            vl_msl = vl_hsl / vl_msl.
          ELSE.
            vl_msl = '0.000'.
          ENDIF.

          ASSIGN COMPONENT campocu OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          <fs_sublinea> = vl_msl.



          UNASSIGN <fs_sublinea>.
          UNASSIGN <fs_substruct>.

      ENDCASE.

    ENDLOOP.
    vl_firstcolumn = abap_true.
    CLEAR: vl_index, vl_hsl,vl_msl.




  ENDLOOP.



ENDFORM.

FORM fill_empty.
  DATA: vl_acum_msl    TYPE menge_d,
        vl_acum_hsl    TYPE menge_d,
        vl_acum_preton TYPE menge_d.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  DATA vl_campo TYPE char10.
  DATA: vl_columconcep TYPE char10, nveces.

  DATA: vl_firstcolumn, vl_found, vl_index TYPE i,vl_len TYPE i.

  DATA vl_datatype LIKE dd01v-datatype.

  FIELD-SYMBOLS: <fs_substruct> TYPE any,
                 <fs_sublinea>  TYPE any.

  PERFORM get_meses
    CHANGING vl_rgpoper .

  vl_index = 4.


  READ TABLE vl_rgpoper INTO wa_rgpoper INDEX 1.
  CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep. "linea de concepto.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  nveces = '0'.
  LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
    LOOP AT lt_fcat INTO ls_fcat.
      READ TABLE <fs_outtable> ASSIGNING <fs_substruct> INDEX vl_index.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_substruct> TO <linea>.

        IF ls_fcat-fieldname NE vl_columconcep.
          CONDENSE <linea> NO-GAPS.
        ENDIF.



        IF <linea> NE 'COSTOS DE PRODUCCIÓN'.

          CALL FUNCTION 'NUMERIC_CHECK'
            EXPORTING
              string_in = <linea>
            IMPORTING
*             string_out =
              htype     = vl_datatype.

          CHECK vl_datatype NE 'CHAR' OR ( vl_datatype EQ 'CHAR' AND <linea> CO ' ,.0123456789' ).


          vl_len =  strlen( ls_fcat-fieldname ).
          IF vl_len = 12.
            vl_len = vl_len - 1.
            nveces = ls_fcat-fieldname+vl_len(1).
          ELSE.
            IF ls_fcat-fieldname+0(3) EQ 'CAM'.
              nveces = 0.
            ELSE.
              nveces = 2.
            ENDIF.
          ENDIF.

          CASE nveces.
            WHEN '0' .
              IF <linea> IS INITIAL AND <linea> NE vl_columconcep.
                <linea> = '0.000'.
              ELSEIF <linea> EQ vl_columconcep.
              ELSE.
                vl_acum_msl = vl_acum_msl + <linea>.
                PERFORM set_string_curr CHANGING <linea>.
              ENDIF.


            WHEN '1'. "ton
              IF vl_firstcolumn EQ abap_false AND ls_fcat-fieldname+0(3) EQ 'SUB'.

                IF <linea> IS INITIAL.
                  <linea> = '0.000'.
                ELSE.
                  vl_acum_msl = vl_acum_msl + <linea>.
                  PERFORM set_string_curr CHANGING <linea>.
                ENDIF.

              ENDIF.

              IF <linea> IS INITIAL.
                <linea> = '0.000'.
              ENDIF.

            WHEN '2'.
              IF vl_firstcolumn EQ abap_true AND ls_fcat-fieldname+0(3) EQ 'SUB'.
                IF <linea> IS INITIAL.
                  <linea> = '0.000'.

                  " PERFORM set_string_curr CHANGING <linea>.

                ELSE.


                  """"""""""""""""""""""""""""""""""""""""""""""""""
                  vl_acum_hsl = vl_acum_hsl + <linea>.
                  " PERFORM set_string_curr CHANGING <linea>.
                ENDIF.
                nveces = '0'.
              ENDIF.
              IF <linea> IS INITIAL.
                <linea> = '0.000'.
              ENDIF.
              PERFORM set_string_curr CHANGING <linea>.
            WHEN '3'.
              IF <linea> IS INITIAL.
                <linea> = '0.000'.

              ELSE.

                vl_acum_hsl = vl_acum_hsl + <linea>.
                PERFORM set_string_curr CHANGING <linea>.
              ENDIF.
              nveces = '0'.
              vl_firstcolumn = abap_true.
          ENDCASE.

          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          IF ls_fcat-fieldname EQ 'TOTALES'.
            <linea> = vl_acum_msl.
            PERFORM set_string_curr CHANGING <linea>.
          ELSEIF ls_fcat-fieldname EQ 'TOTAL_PT'.
            IF vl_acum_msl GT 0.
              vl_acum_msl = vl_acum_hsl / vl_acum_msl.
              <linea> = vl_acum_msl.
              PERFORM set_string_curr CHANGING <linea>.
            ENDIF.
          ELSEIF ls_fcat-fieldname EQ 'TOTAL_PRE'.
            <linea> = vl_acum_hsl.
            PERFORM set_string_curr CHANGING <linea>.
          ENDIF.
          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        ENDIF.
      ENDIF.
    ENDLOOP.
    vl_index = vl_index + 1.
    CLEAR: vl_acum_hsl, vl_acum_msl, vl_acum_preton.
*        vl_utilidad_bruta, vl_gastos_cosecha,
*        vl_gastos_operacion, vl_otros_gastos, vl_total_impuestos, vl_utilidad_operacion,
*        vl_utilidad_neta.
    vl_firstcolumn = abap_false.
  ENDLOOP.

*  ENDLOOP.
ENDFORM.


FORM set_string_curr CHANGING p_valor TYPE any.

  DATA: num TYPE fins_vhcur12.
  DATA vl_str TYPE c LENGTH 35.
  CONDENSE p_valor NO-GAPS.
  num = p_valor.

  CALL FUNCTION 'HRCM_AMOUNT_TO_STRING_CONVERT'
    EXPORTING
      betrg  = num
*     waers  = space
*     new_decimal_separator   =
*     new_thousands_separator =
    IMPORTING
      string = vl_str.
*
*    EXPORTING
*      string              = vl_str
*      decimal_separator   = '.'
*      thousands_separator = ','
*    IMPORTING
*      betrg               = num.

  WRITE num CURRENCY 'MXN' TO vl_str.
  CONDENSE vl_str NO-GAPS.
  p_valor = vl_str.


ENDFORM.

FORM valida_ctos_vta.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs.

  DATA:
    vl_poperi TYPE poper,
    vl_poperf TYPE poper,
    nveces.

  DATA vl_campo TYPE char10.
  DATA vl_columconcep TYPE char10.

  DATA: vl_prexton TYPE menge_D,
        vl_msl     TYPE menge_d,
        vl_hsl     TYPE menge_d.

  DATA: vl_firstcolumn, vl_found.

  PERFORM get_meses
    CHANGING  vl_rgpoper.


  IF p_bukrs-high IS INITIAL.
    LOOP AT p_bukrs.
      CLEAR wa_rgbukrs.
      wa_rgbukrs-sign = 'I'.
      wa_rgbukrs-option = 'EQ'.
      wa_rgbukrs-low = p_bukrs-low.
      APPEND wa_rgbukrs TO vl_rgbukrs.
    ENDLOOP.
  ELSE.
    wa_rgbukrs-sign = 'I'.
    wa_rgbukrs-option = 'BT'.
    wa_rgbukrs-low = p_bukrs-low.
    wa_rgbukrs-high = p_bukrs-high.
    APPEND wa_rgbukrs TO vl_rgbukrs.
  ENDIF.


  obj_agricolas->valida_ctos_vta(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_bukrs  = vl_rgbukrs
    CHANGING
      i_tabla  = it_v_ctos_vta
  ).

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  LOOP AT vl_rgpoper INTO wa_rgpoper.
    REFRESH it_aux_out.
    CLEAR wa_aux_out.

    IF vl_firstcolumn = abap_false.
      CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep.

    ENDIF.

    LOOP AT it_v_ctos_vta INTO DATA(workarea) WHERE poper = wa_rgpoper-low+1(2).
      wa_aux_out-concepto = workarea-concepto.
      wa_aux_out-menge = workarea-msl.
      wa_aux_out-month = workarea-hsl.
      COLLECT wa_aux_out INTO it_aux_out.
    ENDLOOP.

    IF it_aux_out IS NOT INITIAL.

      LOOP AT it_aux_out INTO wa_aux_out.
        nveces ='0'.
        vl_found = abap_false.

        LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          IF <linea> = wa_aux_out-concepto.
            vl_found = abap_true.
          ENDIF.
        ENDLOOP.

        IF vl_found EQ abap_false.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
          nveces = nveces + 1.
        ENDIF.

        CLEAR campocu.

        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = wa_aux_out-concepto.


        IF vl_firstcolumn EQ abap_true.
          CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.


        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_msl = wa_aux_out-menge. "toneladas
        <linea> = vl_msl.
        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_prexton = floor( wa_aux_out-month / wa_aux_out-menge ) .
        <linea> = vl_prexton . " 0. "% / toneladas
        nveces = nveces + 1.

        IF vl_firstcolumn EQ abap_true.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
        ELSE.

          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          nveces = nveces + 1.
        ENDIF.

        ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
        vl_hsl = wa_aux_out-month.
        <linea> = vl_hsl.
      ENDLOOP.
    ENDIF.
    vl_firstcolumn = abap_true.
  ENDLOOP.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


ENDFORM.

"""""""""""""inicia el reporte para Caña
FORM informe_agricolas.
  APPEND INITIAL LINE TO <fs_outtable>.
  PERFORM gtos_cos_cana.
  PERFORM gtos_operacion.
  PERFORM add_row_oper_arit USING 'UTILIDAD DE OPERACIÓN'.
  PERFORM otros_gtos.
  PERFORM add_row_oper_arit USING 'UTILIDAD ANTES DE IMPUESTOS'.
  PERFORM impuestos.
  PERFORM add_row_oper_arit USING 'UTILIDAD NETA'.
  PERFORM calculos_utilidad.


ENDFORM.

FORM gtos_cos_cana.

  """""""""""""""""""Inicia Gastos de Costos de Caña
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs,
        vl_rgaufnr TYPE RANGE OF afko-aufnr,
        wa_rgaufnr LIKE LINE OF vl_rgaufnr,
        vl_rgceco  TYPE RANGE OF csks-kostl,
        wa_rgceco  LIKE LINE OF vl_rgceco,
        vl_rgkstar TYPE RANGE OF cosp-kstar,
        wa_rgkstar LIKE LINE OF vl_rgkstar.

  FIELD-SYMBOLS: <fs_struct>    TYPE any,
                 <fs_substruct> TYPE any,
                 <fs_auxstruct> TYPE any,
                 <fs_auxlinea>  TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_sublinea>  TYPE any,
                 <fs_tt>        TYPE table.

  DATA: vl_acum_act_msl TYPE menge_d,
        vl_acum_act_hsl TYPE menge_d.

  DATA:
    vl_poperi TYPE poper,
    vl_poperf TYPE poper,
    nveces, vl_index TYPE i.

  DATA vl_campo TYPE char10.
  DATA vl_columconcep TYPE char10.

  DATA: vl_prexton TYPE menge_d.


  DATA: vl_firstmonth, vl_found.

  PERFORM get_meses CHANGING vl_rgpoper.


  "se obtienen los centros de costo a consultar
*  IF p_bukrs-high IS INITIAL.
*    LOOP AT p_bukrs.
*      CONCATENATE p_bukrs-low '07' INTO wa_rgceco-low .
*      wa_rgceco-sign = 'I'.
*      wa_rgceco-option = 'EQ'.
*      APPEND wa_Rgceco TO vl_rgceco.
*    ENDLOOP.
*  ELSE.
*    CONCATENATE p_bukrs-low '07' INTO wa_rgceco-low.
*    CONCATENATE p_bukrs-high '07' INTO wa_rgceco-high.
*    wa_rgceco-sign = 'I'.
*    wa_rgceco-option = 'BT'.
*    APPEND wa_Rgceco TO vl_rgceco.
*  ENDIF.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  SELECT gpo_kostl, gpo_saknr
  INTO TABLE @DATA(it_jerarquias)
  FROM zco_tt_j_agri
  WHERE bukrs IN @p_bukrs AND descripcion EQ 'COSECHA'.


  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  SELECT setname,setclass,subclass
  INTO TABLE @DATA(head_cecos)
  FROM setheader
  FOR ALL ENTRIES IN @it_jerarquias
  WHERE setname = @it_jerarquias-gpo_kostl
  AND setheader~setclass = '0101' AND setheader~subclass = 'GA00'.

  SELECT setleaf~setname, valfrom
  INTO TABLE @DATA(it_cecos)
  FROM setleaf
 FOR ALL ENTRIES IN @head_cecos
 WHERE setclass = @head_cecos-setclass
 AND subclass = @head_cecos-subclass
 AND setname = @head_cecos-setname.
  .
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  SELECT setnode~setclass,setnode~subclass,subsetname,descript
  INTO TABLE @DATA(head_clcosto)
  FROM setnode
  INNER JOIN setheadert AS h ON h~setclass = setnode~setclass
  AND h~subclass = setnode~subclass
  AND h~setname = setnode~subsetname
  FOR ALL ENTRIES IN @it_jerarquias
  WHERE setnode~setname = @it_jerarquias-gpo_saknr
  AND setnode~setclass = '0102' AND setnode~subclass = 'GP00'.

  SELECT setleaf~setname, valfrom
  INTO TABLE @DATA(it_clcosto)
  FROM setleaf
 FOR ALL ENTRIES IN @head_clcosto
 WHERE setclass = @head_clcosto-setclass
 AND subclass = @head_clcosto-subclass
 AND setname = @head_clcosto-subsetname.

  REFRESH: vl_rgceco, vl_rgkstar.

  LOOP AT it_cecos INTO DATA(wa_cecos).
    wa_rgceco-option = 'EQ'.
    wa_rgceco-sign = 'I'.
    wa_rgceco-low = wa_cecos-valfrom.
    APPEND wa_rgceco TO vl_rgceco.
  ENDLOOP.

  LOOP AT it_clcosto INTO DATA(wa_kstar).
    wa_rgkstar-option = 'EQ'.
    wa_rgkstar-sign = 'I'.
    wa_rgkstar-low = wa_kstar-valfrom.
    APPEND wa_rgkstar TO vl_rgkstar.
  ENDLOOP.

  obj_agricolas->get_gastos_cosech(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_kostl  = vl_rgceco
      i_kstar  = vl_rgkstar
    CHANGING
      i_tabla  = it_gastos_cosech
  ).

  SORT it_gastos_cosech BY kostl kstar.

  REFRESH it_grupos_act.

  LOOP AT head_clcosto INTO DATA(wa_head).
    APPEND INITIAL LINE TO it_grupos_act ASSIGNING <fs_struct>.
    ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_head-subsetname.

    ASSIGN COMPONENT 'CONCEPTO' OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_head-descript.

  ENDLOOP.

  LOOP AT vl_rgpoper INTO wa_rgpoper.
    REFRESH it_aux_out_act.
    CLEAR wa_aux_out_act.

    LOOP AT it_gastos_cosech INTO DATA(wa_gastos_cosech) WHERE perio = wa_rgpoper-low.
      READ TABLE it_clcosto INTO DATA(wa_clcosto) WITH KEY valfrom = wa_gastos_cosech-kstar.
      IF sy-subrc EQ 0.

        UNASSIGN <fs_struct>.
        READ TABLE it_grupos_act ASSIGNING <fs_struct> WITH KEY subsetname = wa_clcosto-setname.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <fs_linea>.
          wa_aux_out_act-subsetname = <fs_linea>.
          UNASSIGN <fs_linea>.
          ASSIGN COMPONENT 'CONCEPTO' OF STRUCTURE <fs_struct> TO <fs_linea>.
          wa_aux_out_act-concepto = <fs_linea>.
          wa_aux_out_act-menge = 0.
          wa_aux_out_act-month = wa_gastos_cosech-wtgbtr.
          COLLECT wa_aux_out_act INTO it_aux_out_act.
        ENDIF.

      ENDIF.
    ENDLOOP.



    IF it_aux_out_act IS NOT INITIAL.

      LOOP AT it_grupos_act ASSIGNING <fs_struct>.
        CLEAR vl_acum_act_msl.
        CLEAR vl_acum_act_hsl.
        ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE <fs_struct> TO <fs_tt>.
        ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.

        LOOP AT it_aux_out_act INTO wa_aux_out_act WHERE subsetname = <linea>.
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_substruct>.
          ASSIGN COMPONENT 'VALFROM' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-concepto.
          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-menge.
          vl_acum_act_msl = vl_acum_act_msl + wa_aux_out_act-menge.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-month.
          vl_acum_act_hsl = vl_acum_act_hsl + wa_aux_out_act-month.
          ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_rgpoper-low.
        ENDLOOP.

        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_acum_act_msl.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_acum_act_hsl.
      ENDLOOP.

    ENDIF.
  ENDLOOP.
*  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""se acomodan en el ALV
  UNASSIGN <fs_struct>.
  UNASSIGN <fs_substruct>.
  UNASSIGN <linea>.
  UNASSIGN <fs_tt>.



  CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'GASTOS COSECHA CAÑA'.

  LOOP AT it_grupos_act INTO DATA(wa_grupos_act).

    CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
    ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_grupos_act-concepto.
    vl_index = sy-tabix.
  ENDLOOP.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'TOTAL GASTOS DE COSECHA'.
  vl_index = vl_index + 1.

  vl_firstmonth = abap_false.
  LOOP AT vl_rgpoper INTO wa_rgpoper.

    LOOP AT it_grupos_act INTO  wa_grupos_act.
      nveces ='1'.

      LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        IF <linea> = wa_grupos_act-concepto.

          EXIT.
        ENDIF.
      ENDLOOP.

      CLEAR campocu.

      ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE wa_grupos_act TO <fs_tt> .
      "se eliminan los ceros""""""""""""""""""""""""""""""""""""""""""
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.
        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_linea>.

        IF <linea> EQ 0 AND <fs_linea> EQ 0.
          DELETE <fs_tt> INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_substruct>.
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.

        ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
        IF <fs_sublinea> EQ wa_rgpoper-low.

          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> GT 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.

            vl_acum_act_msl = <linea> + <fs_sublinea>. "toneladas
            <linea> = vl_acum_act_msl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.

          IF vl_firstmonth EQ abap_true.
            nveces = nveces + 1.
          ELSE.
            nveces = nveces + 2.
          ENDIF.


          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> GT 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            vl_acum_act_hsl = <linea> + <fs_sublinea>.
            <linea> = vl_acum_act_hsl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.


          nveces = nveces - 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          "vl_prexton =  floor( vl_acum_act_hsl /  vl_acum_act_msl ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
          IF  sy-subrc EQ 0.
            <linea> =  vl_prexton . " 0. "% / toneladas
          ENDIF.

          "acumulado
          nveces = nveces + 1.
          READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          nveces = nveces - 2.
          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          "CONCATENATE campocu wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.

          nveces = nveces + 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          "vl_prexton = floor( <linea> /  <fs_auxlinea> ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          <linea> =  vl_prexton .
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


        ENDIF.
        nveces = '1'.

      ENDLOOP.

    ENDLOOP.
    CLEAR: vl_acum_act_hsl, vl_acum_act_msl.
    vl_firstmonth = abap_true.
  ENDLOOP.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""""""Termina Gastos de costos de Caña
ENDFORM.
"""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""Inicia Gastos Operacion
FORM gtos_operacion.

  """""""""""""""""""Inicia Gastos de Costos de Caña
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs,
        vl_rgaufnr TYPE RANGE OF afko-aufnr,
        wa_rgaufnr LIKE LINE OF vl_rgaufnr,
        vl_rgceco  TYPE RANGE OF csks-kostl,
        wa_rgceco  LIKE LINE OF vl_rgceco,
        vl_rgkstar TYPE RANGE OF cosp-kstar,
        wa_rgkstar LIKE LINE OF vl_rgkstar.

  FIELD-SYMBOLS: <fs_struct>    TYPE any,
                 <fs_substruct> TYPE any,
                 <fs_auxstruct> TYPE any,
                 <fs_auxlinea>  TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_sublinea>  TYPE any,
                 <fs_tt>        TYPE table.

  DATA: vl_acum_act_msl TYPE menge_d,
        vl_acum_act_hsl TYPE menge_d.

  DATA:
    vl_poperi TYPE poper,
    vl_poperf TYPE poper,
    nveces, vl_index TYPE i.

  DATA vl_campo TYPE char10.
  DATA vl_columconcep TYPE char10.

  DATA: vl_prexton TYPE menge_d.


  DATA: vl_firstmonth, vl_found.

  PERFORM get_meses CHANGING vl_rgpoper.


  SELECT gpo_kostl, gpo_saknr
  INTO TABLE @DATA(it_jerarquias)
  FROM zco_tt_j_agri
  WHERE bukrs IN @p_bukrs AND descripcion EQ 'OPERACION'.

  IF it_jerarquias IS INITIAL.
    MESSAGE 'No hay jerarquías para Gtos de Operación' TYPE 'S'.
    EXIT.
  ENDIF.

  SELECT setnode~setclass, setnode~subclass, setnode~setname, subsetname
  INTO TABLE @DATA(head_cecos)
  FROM setnode
  INNER JOIN setheader ON setheader~setclass = setnode~setclass
  AND setheader~subclass = setnode~subclass
  AND setheader~setname = setnode~setname
  FOR ALL ENTRIES IN @it_jerarquias
  WHERE setnode~setname = @it_jerarquias-gpo_kostl
  AND setnode~setclass = '0101' AND setnode~subclass = 'GA00'.

  SELECT setleaf~setname, valfrom
  INTO TABLE @DATA(it_cecos)
  FROM setleaf
 FOR ALL ENTRIES IN @head_cecos
 WHERE setclass = @head_cecos-setclass
 AND subclass = @head_cecos-subclass
 AND setname = @head_cecos-subsetname.
  .

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  SELECT setnode~setclass,setnode~subclass,subsetname,descript
  INTO TABLE @DATA(head_clcosto)
  FROM setnode
  INNER JOIN setheadert AS h ON h~setclass = setnode~setclass
  AND h~subclass = setnode~subclass
  AND h~setname = setnode~subsetname
  FOR ALL ENTRIES IN @it_jerarquias
  WHERE setnode~setname EQ @it_jerarquias-gpo_saknr "'GTOSCOSECH'
  AND setnode~setclass = '0102' AND setnode~subclass = 'GP00'.

  SELECT setleaf~setname, valfrom
  INTO TABLE @DATA(it_clcosto)
  FROM setleaf
 FOR ALL ENTRIES IN @head_clcosto
 WHERE setclass = @head_clcosto-setclass
 AND subclass = @head_clcosto-subclass
 AND setname = @head_clcosto-subsetname.

  REFRESH: vl_rgceco, vl_rgkstar.


  LOOP AT it_cecos INTO DATA(wa_cecos).
    wa_rgceco-option = 'EQ'.
    wa_rgceco-sign = 'I'.
    wa_rgceco-low = wa_cecos-valfrom.
    APPEND wa_rgceco TO vl_rgceco.
  ENDLOOP.

  LOOP AT it_clcosto INTO DATA(wa_kstar).
    wa_rgkstar-option = 'EQ'.
    wa_rgkstar-sign = 'I'.
    wa_rgkstar-low = wa_kstar-valfrom.
    APPEND wa_rgkstar TO vl_rgkstar.
  ENDLOOP.

  obj_agricolas->get_gastos_opera(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_kostl  = vl_rgceco
      i_kstar  = vl_rgkstar
    CHANGING
      i_tabla  = it_gastos_opera
  ).

  SORT it_gastos_cosech BY kostl kstar.

  REFRESH it_grupos_act.

  LOOP AT head_clcosto INTO DATA(wa_head).
    APPEND INITIAL LINE TO it_grupos_act ASSIGNING <fs_struct>.
    ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_head-subsetname.

    ASSIGN COMPONENT 'CONCEPTO' OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_head-descript.

  ENDLOOP.

  LOOP AT vl_rgpoper INTO wa_rgpoper.
    REFRESH it_aux_out_act.
    CLEAR wa_aux_out_act.

    LOOP AT it_gastos_cosech INTO DATA(wa_gastos_cosech) WHERE perio = wa_rgpoper-low.
      READ TABLE it_clcosto INTO DATA(wa_clcosto) WITH KEY valfrom = wa_gastos_cosech-kstar.
      IF sy-subrc EQ 0.

        UNASSIGN <fs_struct>.
        READ TABLE it_grupos_act ASSIGNING <fs_struct> WITH KEY subsetname = wa_clcosto-setname.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <fs_linea>.
          wa_aux_out_act-subsetname = <fs_linea>.
          UNASSIGN <fs_linea>.
          ASSIGN COMPONENT 'CONCEPTO' OF STRUCTURE <fs_struct> TO <fs_linea>.
          wa_aux_out_act-concepto = <fs_linea>.
          wa_aux_out_act-menge = 0.
          wa_aux_out_act-month = wa_gastos_cosech-wtgbtr.
          COLLECT wa_aux_out_act INTO it_aux_out_act.
        ENDIF.

      ENDIF.
    ENDLOOP.



    IF it_aux_out_act IS NOT INITIAL.

      LOOP AT it_grupos_act ASSIGNING <fs_struct>.
        CLEAR vl_acum_act_msl.
        CLEAR vl_acum_act_hsl.
        ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE <fs_struct> TO <fs_tt>.
        ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.

        LOOP AT it_aux_out_act INTO wa_aux_out_act WHERE subsetname = <linea>.
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_substruct>.
          ASSIGN COMPONENT 'VALFROM' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-concepto.
          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-menge.
          vl_acum_act_msl = vl_acum_act_msl + wa_aux_out_act-menge.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-month.
          vl_acum_act_hsl = vl_acum_act_hsl + wa_aux_out_act-month.
          ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_rgpoper-low.
        ENDLOOP.

        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_acum_act_msl.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_acum_act_hsl.
      ENDLOOP.

    ENDIF.
  ENDLOOP.
*  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""se acomodan en el ALV
  UNASSIGN <fs_struct>.
  UNASSIGN <fs_substruct>.
  UNASSIGN <linea>.
  UNASSIGN <fs_tt>.



  CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'GASTOS DE OPERACIÓN'.

  LOOP AT it_grupos_act INTO DATA(wa_grupos_act).

    CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
    ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_grupos_act-concepto.
    vl_index = sy-tabix.
  ENDLOOP.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'TOTAL GASTOS DE OPERACIÓN'.
  vl_index = vl_index + 1.

  vl_firstmonth = abap_false.
  LOOP AT vl_rgpoper INTO wa_rgpoper.

    LOOP AT it_grupos_act INTO  wa_grupos_act.
      nveces ='1'.

      LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        IF <linea> = wa_grupos_act-concepto.

          EXIT.
        ENDIF.
      ENDLOOP.

      CLEAR campocu.

      ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE wa_grupos_act TO <fs_tt> .
      "se eliminan los ceros""""""""""""""""""""""""""""""""""""""""""
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.
        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_linea>.

        IF <linea> EQ 0 AND <fs_linea> EQ 0.
          DELETE <fs_tt> INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_substruct>.
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.

        ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
        IF <fs_sublinea> EQ wa_rgpoper-low.

          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> GT 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.

            vl_acum_act_msl = <linea> + <fs_sublinea>. "toneladas
            <linea> = vl_acum_act_msl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.

          IF vl_firstmonth EQ abap_true.
            nveces = nveces + 1.
          ELSE.
            nveces = nveces + 2.
          ENDIF.


          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> GT 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            vl_acum_act_hsl = <linea> + <fs_sublinea>.
            <linea> = vl_acum_act_hsl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.


          nveces = nveces - 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          "vl_prexton =  floor( vl_acum_act_hsl /  vl_acum_act_msl ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
          IF  sy-subrc EQ 0.
            <linea> =  vl_prexton . " 0. "% / toneladas
          ENDIF.

          "acumulado
          nveces = nveces + 1.
          READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          nveces = nveces - 2.
          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          "CONCATENATE campocu wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.

          nveces = nveces + 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          "vl_prexton = floor( <linea> /  <fs_auxlinea> ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          <linea> =  vl_prexton .
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


        ENDIF.
        nveces = '1'.

      ENDLOOP.

    ENDLOOP.
    CLEAR: vl_acum_act_hsl, vl_acum_act_msl.
    vl_firstmonth = abap_true.
  ENDLOOP.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""""""Termina Gastos de operación
ENDFORM.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""otros gastos de operacion***********
FORM otros_gtos.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs,
        vl_rgaufnr TYPE RANGE OF afko-aufnr,
        wa_rgaufnr LIKE LINE OF vl_rgaufnr,
        vl_rgceco  TYPE RANGE OF csks-kostl,
        wa_rgceco  LIKE LINE OF vl_rgceco,
        vl_rgkstar TYPE RANGE OF cosp-kstar,
        wa_rgkstar LIKE LINE OF vl_rgkstar.

  FIELD-SYMBOLS: <fs_struct>    TYPE any,
                 <fs_substruct> TYPE any,
                 <fs_auxstruct> TYPE any,
                 <fs_auxlinea>  TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_sublinea>  TYPE any,
                 <fs_tt>        TYPE table.

  DATA: vl_acum_act_msl TYPE menge_d,
        vl_acum_act_hsl TYPE menge_d.

  DATA:
    vl_poperi TYPE poper,
    vl_poperf TYPE poper,
    nveces, vl_index TYPE i.

  DATA vl_campo TYPE char10.
  DATA vl_columconcep TYPE char10.

  DATA: vl_prexton TYPE menge_d.


  DATA: vl_firstmonth, vl_found.

  PERFORM get_meses CHANGING vl_rgpoper.


  SELECT gpo_kostl, gpo_saknr
  INTO TABLE @DATA(it_jerarquias)
  FROM zco_tt_j_agri
  WHERE bukrs IN @p_bukrs AND descripcion EQ 'OTROS'.

  IF it_jerarquias IS INITIAL.
    MESSAGE 'No hay jerarquías para Otros Gtos' TYPE 'S'.
    EXIT.
  ENDIF.

  .

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  SELECT setnode~setclass,setnode~subclass,subsetname,descript
  INTO TABLE @DATA(head_clcosto)
  FROM setnode
  INNER JOIN setheadert AS h ON h~setclass = setnode~setclass
  AND h~subclass = setnode~subclass
  AND h~setname = setnode~subsetname
  FOR ALL ENTRIES IN @it_jerarquias
  WHERE setnode~setname EQ @it_jerarquias-gpo_saknr
  AND setnode~setclass = '0102' AND setnode~subclass = 'GP00'.

  SELECT setleaf~setname, valfrom
  INTO TABLE @DATA(it_clcosto)
  FROM setleaf
 FOR ALL ENTRIES IN @head_clcosto
 WHERE setclass = @head_clcosto-setclass
 AND subclass = @head_clcosto-subclass
 AND setname = @head_clcosto-subsetname.

  REFRESH: vl_rgkstar.

  SELECT bukrs
  INTO TABLE @DATA(it_bukrs)
  FROM t001
  WHERE bukrs IN @p_bukrs.


  LOOP AT it_bukrs INTO DATA(wa_bukrs).
    CLEAR wa_rgbukrs.
    wa_rgbukrs-sign = 'I'.
    wa_rgbukrs-option = 'EQ'.
    wa_rgbukrs-low = wa_bukrs-bukrs.
    APPEND wa_rgbukrs TO vl_rgbukrs.
  ENDLOOP.


  LOOP AT it_clcosto INTO DATA(wa_kstar).
    wa_rgkstar-option = 'EQ'.
    wa_rgkstar-sign = 'I'.
    wa_rgkstar-low = wa_kstar-valfrom.
    APPEND wa_rgkstar TO vl_rgkstar.
  ENDLOOP.

  obj_agricolas->get_otros_gastos(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_bukrs  = vl_rgbukrs
      i_kstar  = vl_rgkstar
    CHANGING
      i_tabla  = it_otros_gastos
  ).

  SORT it_gastos_cosech BY kostl kstar.

  REFRESH it_grupos_act.

  LOOP AT head_clcosto INTO DATA(wa_head).
    APPEND INITIAL LINE TO it_grupos_act ASSIGNING <fs_struct>.
    ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_head-subsetname.

    ASSIGN COMPONENT 'CONCEPTO' OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_head-descript.

  ENDLOOP.

  LOOP AT vl_rgpoper INTO wa_rgpoper.
    REFRESH it_aux_out_act.
    CLEAR wa_aux_out_act.

    LOOP AT it_otros_gastos INTO DATA(wa_gastos_cosech) WHERE perio = wa_rgpoper-low.
      READ TABLE it_clcosto INTO DATA(wa_clcosto) WITH KEY valfrom = wa_gastos_cosech-kstar.
      IF sy-subrc EQ 0.

        UNASSIGN <fs_struct>.
        READ TABLE it_grupos_act ASSIGNING <fs_struct> WITH KEY subsetname = wa_clcosto-setname.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <fs_linea>.
          wa_aux_out_act-subsetname = <fs_linea>.
          UNASSIGN <fs_linea>.
          ASSIGN COMPONENT 'CONCEPTO' OF STRUCTURE <fs_struct> TO <fs_linea>.
          wa_aux_out_act-concepto = <fs_linea>.
          wa_aux_out_act-menge = 0.
          wa_aux_out_act-month = wa_gastos_cosech-wtgbtr.
          COLLECT wa_aux_out_act INTO it_aux_out_act.
        ENDIF.

      ENDIF.
    ENDLOOP.



    IF it_aux_out_act IS NOT INITIAL.

      LOOP AT it_grupos_act ASSIGNING <fs_struct>.
        CLEAR vl_acum_act_msl.
        CLEAR vl_acum_act_hsl.
        ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE <fs_struct> TO <fs_tt>.
        ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.

        LOOP AT it_aux_out_act INTO wa_aux_out_act WHERE subsetname = <linea>.
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_substruct>.
          ASSIGN COMPONENT 'VALFROM' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-concepto.
          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-menge.
          vl_acum_act_msl = vl_acum_act_msl + wa_aux_out_act-menge.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-month.
          vl_acum_act_hsl = vl_acum_act_hsl + wa_aux_out_act-month.
          ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_rgpoper-low.
        ENDLOOP.

        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_acum_act_msl.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_acum_act_hsl.
      ENDLOOP.

    ENDIF.
  ENDLOOP.
*  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""se acomodan en el ALV
  UNASSIGN <fs_struct>.
  UNASSIGN <fs_substruct>.
  UNASSIGN <linea>.
  UNASSIGN <fs_tt>.



  CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'OTROS GASTOS'.

  LOOP AT it_grupos_act INTO DATA(wa_grupos_act).

    CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
    ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_grupos_act-concepto.
    vl_index = sy-tabix.
  ENDLOOP.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'TOTAL OTROS GASTOS'.
  vl_index = vl_index + 1.

  vl_firstmonth = abap_false.
  LOOP AT vl_rgpoper INTO wa_rgpoper.

    LOOP AT it_grupos_act INTO  wa_grupos_act.
      nveces ='1'.

      LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        IF <linea> = wa_grupos_act-concepto.

          EXIT.
        ENDIF.
      ENDLOOP.

      CLEAR campocu.

      ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE wa_grupos_act TO <fs_tt> .
      "se eliminan los ceros""""""""""""""""""""""""""""""""""""""""""
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.
        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_linea>.

        IF <linea> EQ 0 AND <fs_linea> EQ 0.
          DELETE <fs_tt> INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_substruct>.
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.

        ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
        IF <fs_sublinea> EQ wa_rgpoper-low.

          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> GT 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.

            vl_acum_act_msl = <linea> + <fs_sublinea>. "toneladas
            <linea> = vl_acum_act_msl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.

          IF vl_firstmonth EQ abap_true.
            nveces = nveces + 1.
          ELSE.
            nveces = nveces + 2.
          ENDIF.


          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> NE 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            vl_acum_act_hsl = <linea> + <fs_sublinea>.
            <linea> = vl_acum_act_hsl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.


          nveces = nveces - 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          "vl_prexton =  floor( vl_acum_act_hsl /  vl_acum_act_msl ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
          IF  sy-subrc EQ 0.
            <linea> =  vl_prexton . " 0. "% / toneladas
          ENDIF.

          "acumulado
          nveces = nveces + 1.
          READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          nveces = nveces - 2.
          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          "CONCATENATE campocu wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.

          nveces = nveces + 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          "vl_prexton = floor( <linea> /  <fs_auxlinea> ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          <linea> =  vl_prexton .
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


        ENDIF.
        nveces = '1'.

      ENDLOOP.

    ENDLOOP.
    CLEAR: vl_acum_act_hsl, vl_acum_act_msl.
    vl_firstmonth = abap_true.
  ENDLOOP.

ENDFORM.

"""""""""""otros gastos de operacion***********
FORM impuestos.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgbukrs TYPE RANGE OF t001-bukrs,
        wa_rgbukrs LIKE LINE OF vl_rgbukrs,
        vl_rgaufnr TYPE RANGE OF afko-aufnr,
        wa_rgaufnr LIKE LINE OF vl_rgaufnr,
        vl_rgceco  TYPE RANGE OF csks-kostl,
        wa_rgceco  LIKE LINE OF vl_rgceco,
        vl_rgkstar TYPE RANGE OF cosp-kstar,
        wa_rgkstar LIKE LINE OF vl_rgkstar.

  FIELD-SYMBOLS: <fs_struct>    TYPE any,
                 <fs_substruct> TYPE any,
                 <fs_auxstruct> TYPE any,
                 <fs_auxlinea>  TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_sublinea>  TYPE any,
                 <fs_tt>        TYPE table.

  DATA: vl_acum_act_msl TYPE menge_d,
        vl_acum_act_hsl TYPE menge_d.

  DATA:
    vl_poperi TYPE poper,
    vl_poperf TYPE poper,
    nveces, vl_index TYPE i.

  DATA vl_campo TYPE char10.
  DATA vl_columconcep TYPE char10.

  DATA: vl_prexton TYPE menge_d.


  DATA: vl_firstmonth, vl_found.

  PERFORM get_meses CHANGING vl_rgpoper.

  SELECT bukrs
  INTO TABLE @DATA(it_bukrs)
  FROM t001
  WHERE bukrs IN @p_bukrs.


  LOOP AT it_bukrs INTO DATA(wa_bukrs).
    CLEAR wa_rgbukrs.
    wa_rgbukrs-sign = 'I'.
    wa_rgbukrs-option = 'EQ'.
    wa_rgbukrs-low = wa_bukrs-bukrs.
    APPEND wa_rgbukrs TO vl_rgbukrs.
  ENDLOOP.



  SELECT gpo_kostl, gpo_saknr
  INTO TABLE @DATA(it_jerarquias)
  FROM zco_tt_j_agri
  WHERE bukrs IN @p_bukrs AND descripcion EQ 'IMPUESTOS'.

  IF it_jerarquias IS INITIAL.
    MESSAGE 'No hay jerarquías para Impuestos' TYPE 'S'.
    EXIT.
  ENDIF.

  SELECT setnode~setclass, setnode~subclass, setnode~setname, subsetname
  INTO TABLE @DATA(head_cecos)
  FROM setnode
  INNER JOIN setheader ON setheader~setclass = setnode~setclass
  AND setheader~subclass = setnode~subclass
  AND setheader~setname = setnode~setname
  FOR ALL ENTRIES IN @it_jerarquias
  WHERE setnode~setname = @it_jerarquias-gpo_kostl
  AND setnode~setclass = '0101' AND setnode~subclass = 'GA00'.

  SELECT setleaf~setname, valfrom
  INTO TABLE @DATA(it_cecos)
  FROM setleaf
 FOR ALL ENTRIES IN @head_cecos
 WHERE setclass = @head_cecos-setclass
 AND subclass = @head_cecos-subclass
 AND setname = @head_cecos-subsetname.
  .

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  SELECT setnode~setclass,setnode~subclass,subsetname,descript
  INTO TABLE @DATA(head_clcosto)
  FROM setnode
  INNER JOIN setheadert AS h ON h~setclass = setnode~setclass
  AND h~subclass = setnode~subclass
  AND h~setname = setnode~subsetname
  FOR ALL ENTRIES IN @it_jerarquias
  WHERE setnode~setname EQ @it_jerarquias-gpo_saknr "'GTOSCOSECH'
  AND setnode~setclass = '0102' AND setnode~subclass = 'GP00'.

  SELECT setleaf~setname, valfrom
  INTO TABLE @DATA(it_clcosto)
  FROM setleaf
 FOR ALL ENTRIES IN @head_clcosto
 WHERE setclass = @head_clcosto-setclass
 AND subclass = @head_clcosto-subclass
 AND setname = @head_clcosto-subsetname.

  REFRESH:  vl_rgkstar.


  LOOP AT it_clcosto INTO DATA(wa_kstar).
    wa_rgkstar-option = 'EQ'.
    wa_rgkstar-sign = 'I'.
    wa_rgkstar-low = wa_kstar-valfrom.
    APPEND wa_rgkstar TO vl_rgkstar.
  ENDLOOP.

  obj_agricolas->get_impuestos(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_bukrs  = vl_rgbukrs
      i_kstar  = vl_rgkstar
    CHANGING
      i_tabla  = it_impuestos
  ).

  SORT it_impuestos BY kostl kstar.

  REFRESH it_grupos_act.

  LOOP AT head_clcosto INTO DATA(wa_head).
    APPEND INITIAL LINE TO it_grupos_act ASSIGNING <fs_struct>.
    ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_head-subsetname.

    ASSIGN COMPONENT 'CONCEPTO' OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_head-descript.

  ENDLOOP.

  LOOP AT vl_rgpoper INTO wa_rgpoper.
    REFRESH it_aux_out_act.
    CLEAR wa_aux_out_act.

    LOOP AT it_impuestos INTO DATA(wa_gastos_cosech) WHERE perio = wa_rgpoper-low.
      READ TABLE it_clcosto INTO DATA(wa_clcosto) WITH KEY valfrom = wa_gastos_cosech-kstar.
      IF sy-subrc EQ 0.

        UNASSIGN <fs_struct>.
        READ TABLE it_grupos_act ASSIGNING <fs_struct> WITH KEY subsetname = wa_clcosto-setname.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <fs_linea>.
          wa_aux_out_act-subsetname = <fs_linea>.
          UNASSIGN <fs_linea>.
          ASSIGN COMPONENT 'CONCEPTO' OF STRUCTURE <fs_struct> TO <fs_linea>.
          wa_aux_out_act-concepto = <fs_linea>.
          wa_aux_out_act-menge = 0.
          wa_aux_out_act-month = wa_gastos_cosech-wtgbtr.
          COLLECT wa_aux_out_act INTO it_aux_out_act.
        ENDIF.

      ENDIF.
    ENDLOOP.



    IF it_aux_out_act IS NOT INITIAL.

      LOOP AT it_grupos_act ASSIGNING <fs_struct>.
        CLEAR vl_acum_act_msl.
        CLEAR vl_acum_act_hsl.
        ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE <fs_struct> TO <fs_tt>.
        ASSIGN COMPONENT 'SUBSETNAME' OF STRUCTURE <fs_struct> TO <linea>.

        LOOP AT it_aux_out_act INTO wa_aux_out_act WHERE subsetname = <linea>.
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_substruct>.
          ASSIGN COMPONENT 'VALFROM' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-concepto.
          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-menge.
          vl_acum_act_msl = vl_acum_act_msl + wa_aux_out_act-menge.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_aux_out_act-month.
          vl_acum_act_hsl = vl_acum_act_hsl + wa_aux_out_act-month.
          ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <linea>.
          <linea> = wa_rgpoper-low.
        ENDLOOP.

        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_acum_act_msl.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_struct> TO <linea>.
        <linea> = vl_acum_act_hsl.
      ENDLOOP.

    ENDIF.
  ENDLOOP.
*  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""se acomodan en el ALV
  UNASSIGN <fs_struct>.
  UNASSIGN <fs_substruct>.
  UNASSIGN <linea>.
  UNASSIGN <fs_tt>.



  CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'IMPUESTOS'.

  LOOP AT it_grupos_act INTO DATA(wa_grupos_act).

    CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
    ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
    <linea> = wa_grupos_act-concepto.
    vl_index = sy-tabix.
  ENDLOOP.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = 'TOTAL IMPUESTOS'.
  vl_index = vl_index + 1.

  vl_firstmonth = abap_false.
  LOOP AT vl_rgpoper INTO wa_rgpoper.

    LOOP AT it_grupos_act INTO  wa_grupos_act.
      nveces ='1'.

      LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
        ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
        IF <linea> = wa_grupos_act-concepto.

          EXIT.
        ENDIF.
      ENDLOOP.

      CLEAR campocu.

      ASSIGN COMPONENT 'ACTIVITIES' OF STRUCTURE wa_grupos_act TO <fs_tt> .
      "se eliminan los ceros""""""""""""""""""""""""""""""""""""""""""
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.
        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <linea>.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_linea>.

        IF <linea> EQ 0 AND <fs_linea> EQ 0.
          DELETE <fs_tt> INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_substruct>.
      LOOP AT <fs_tt> ASSIGNING <fs_substruct>.

        ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
        IF <fs_sublinea> EQ wa_rgpoper-low.

          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> GT 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.

            vl_acum_act_msl = <linea> + <fs_sublinea>. "toneladas
            <linea> = vl_acum_act_msl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.

          IF vl_firstmonth EQ abap_true.
            nveces = nveces + 1.
          ELSE.
            nveces = nveces + 2.
          ENDIF.


          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_substruct> TO <fs_sublinea>.
          IF <fs_sublinea> GT 0.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
            vl_acum_act_hsl = <linea> + <fs_sublinea>.
            <linea> = vl_acum_act_hsl.

            READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
            ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.
            <fs_auxlinea> = <fs_auxlinea> + <fs_sublinea>.


          ENDIF.


          nveces = nveces - 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          "vl_prexton =  floor( vl_acum_act_hsl /  vl_acum_act_msl ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_struct> TO <linea>.
          IF  sy-subrc EQ 0.
            <linea> =  vl_prexton . " 0. "% / toneladas
          ENDIF.

          "acumulado
          nveces = nveces + 1.
          READ TABLE <fs_outtable> ASSIGNING <fs_auxstruct> INDEX vl_index.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          nveces = nveces - 2.
          IF vl_firstmonth EQ abap_true.
            CONCATENATE 'CAMPO' wa_rgpoper-low INTO campocu.
          ELSE.
            CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          ENDIF.

          "CONCATENATE campocu wa_rgpoper-low nveces INTO campocu.
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <fs_auxlinea>.

          nveces = nveces + 1.
          CONCATENATE gv_subcampo wa_rgpoper-low nveces INTO campocu.
          "vl_prexton = floor( <linea> /  <fs_auxlinea> ).
          ASSIGN COMPONENT campocu OF STRUCTURE <fs_auxstruct> TO <linea>.
          <linea> =  vl_prexton .
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


        ENDIF.
        nveces = '1'.

      ENDLOOP.

    ENDLOOP.
    CLEAR: vl_acum_act_hsl, vl_acum_act_msl.
    vl_firstmonth = abap_true.
  ENDLOOP.

ENDFORM.

FORM add_row_oper_arit USING p_concept TYPE string.

  DATA vl_columconcep TYPE char10.

  CONCATENATE 'CAMPO' so_poper-low INTO vl_columconcep.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_struct>.
  ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
  <linea> = p_concept.

ENDFORM.


FORM calculos_utilidad.

  DATA: vl_UTILIDAD_BRUTA     TYPE menge_d,
        vl_GASTOS_COSECHA     TYPE menge_d,
        vl_gastos_operacion   TYPE menge_d,
        vl_utilidad_operacion TYPE menge_d.

  DATA: vl_otros_gastos       TYPE menge_d,
        vl_utilidad_antes_imp TYPE menge_d.

  DATA: vl_total_impuestos TYPE menge_d,
        vl_utilidad_neta   TYPE menge_d.

  FIELD-SYMBOLS: <fs_substruct> TYPE any,
                 <linea>        TYPE any,
                 <sublinea>     TYPE any.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  DATA vl_campo TYPE char10.
  DATA: vl_columconcep TYPE char10, nveces.

  DATA: vl_firstcolumn, vl_found, vl_index TYPE i,vl_len TYPE i.

  DATA vl_datatype LIKE dd01v-datatype.


  PERFORM get_meses
    CHANGING vl_rgpoper .

  vl_index = 4.


  READ TABLE vl_rgpoper INTO wa_rgpoper INDEX 1.
  CONCATENATE 'CAMPO' wa_rgpoper-low INTO vl_columconcep. "linea de concepto.

  LOOP AT lt_fcat INTO ls_fcat.
    IF ls_fcat-fieldname+0(3) EQ 'SUB'.
      vl_len =  strlen( ls_fcat-fieldname ).
      IF vl_len = 12.
        vl_len = vl_len - 1.
        nveces = ls_fcat-fieldname+vl_len(1).
      ENDIF.

      IF nveces EQ '3' AND vl_firstcolumn EQ abap_false.
        LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_struct> TO <sublinea>.
          CASE <linea>.
            WHEN 'UTILIDAD BRUTA'.
              vl_utilidad_bruta = <sublinea>.
            WHEN 'TOTAL GASTOS DE COSECHA'.
              vl_gastos_cosecha = <sublinea>.
            WHEN 'TOTAL GASTOS DE OPERACIÓN'.
              vl_gastos_operacion = <sublinea>.
            WHEN 'TOTAL OTROS GASTOS'.
              vl_otros_gastos = <sublinea>.
            WHEN 'TOTAL IMPUESTOS'.
              vl_total_impuestos = <sublinea>.
            WHEN 'UTILIDAD DE OPERACIÓN'.
              vl_utilidad_operacion = vl_utilidad_bruta - vl_gastos_cosecha - vl_gastos_operacion.
              <sublinea> = vl_utilidad_operacion.
            WHEN 'UTILIDAD ANTES DE IMPUESTOS'.
              vl_utilidad_antes_imp = vl_utilidad_operacion - vl_otros_gastos.
              <sublinea> = vl_utilidad_antes_imp.
            WHEN 'UTILIDAD NETA'.
              vl_utilidad_neta = vl_utilidad_antes_imp - vl_total_impuestos.
              <sublinea> = vl_utilidad_neta.

          ENDCASE.
        ENDLOOP.
        vl_firstcolumn = abap_true.
      ELSEIF nveces EQ '2' AND vl_firstcolumn EQ abap_true.
        LOOP AT <fs_outtable> ASSIGNING <fs_struct>.
          ASSIGN COMPONENT vl_columconcep OF STRUCTURE <fs_struct> TO <linea>.
          ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_struct> TO <sublinea>.
          CASE <linea>.
            WHEN 'UTILIDAD BRUTA'.
              vl_utilidad_bruta = <sublinea>.
            WHEN 'TOTAL GASTOS DE COSECHA'.
              vl_gastos_cosecha = <sublinea>.
            WHEN 'TOTAL GASTOS DE OPERACIÓN'.
              vl_gastos_operacion = <sublinea>.
            WHEN 'TOTAL OTROS GASTOS'.
              vl_otros_gastos = <sublinea>.
            WHEN 'TOTAL IMPUESTOS'.
              vl_total_impuestos = <sublinea>.
            WHEN 'UTILIDAD DE OPERACIÓN'.
              vl_utilidad_operacion = vl_utilidad_bruta - vl_gastos_cosecha - vl_gastos_operacion.
              <sublinea> = vl_utilidad_operacion.
            WHEN 'UTILIDAD ANTES DE IMPUESTOS'.
              vl_utilidad_antes_imp = vl_utilidad_operacion - vl_otros_gastos.
              <sublinea> = vl_utilidad_antes_imp.
            WHEN 'UTILIDAD NETA'.
              vl_utilidad_neta = vl_utilidad_antes_imp - vl_total_impuestos.
              <sublinea> = vl_utilidad_neta.

          ENDCASE.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
