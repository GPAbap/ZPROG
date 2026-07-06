*&---------------------------------------------------------------------*
*& Include          ZMM_RE_LIS_FUN
*&---------------------------------------------------------------------*

FORM get_data.

  DATA: lt_mov TYPE STANDARD TABLE OF matdoc,
        ls_mov TYPE matdoc.

  SELECT m~*
    INTO TABLE @lt_mov
    FROM matdoc AS m
    INNER JOIN s032 AS s ON s~matnr EQ m~matnr and s~werks eq m~werks and s~lgort eq m~lgort
    WHERE budat IN @s_budat
      AND m~matnr IN @s_matnr
      AND m~werks IN @s_werks
      AND m~lgort IN @s_lgort
      AND s~matkl IN @s_matkl
    AND s~mtart IN @s_mtart
      AND m~bwart IN (
        '101', '202', '262', '602', '302', '312',
        '102', '201', '261', '601', '301', '311', '551'
      ).

  IF lt_mov IS INITIAL.
    MESSAGE 'No existen movimientos para los criterios seleccionados' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  SORT lt_mov BY matnr werks lgort.

  LOOP AT lt_mov INTO ls_mov.

    READ TABLE gt_out ASSIGNING FIELD-SYMBOL(<fs_out>)
      WITH KEY matnr = ls_mov-matnr
               werks = ls_mov-werks
               lgort = ls_mov-lgort.

    IF sy-subrc <> 0.
      CLEAR gs_out.
      gs_out-matnr = ls_mov-matnr.
      gs_out-werks = ls_mov-werks.
      gs_out-lgort = ls_mov-lgort.

      PERFORM fill_master_data CHANGING gs_out.

      APPEND gs_out TO gt_out ASSIGNING <fs_out>.
    ENDIF.

    CASE ls_mov-bwart.

      WHEN '101' OR '202' OR '262' OR '602' OR '302' OR '312'.

        <fs_out>-cant_ent  = <fs_out>-cant_ent  + abs( ls_mov-menge ).
        <fs_out>-valor_ent = <fs_out>-valor_ent + abs( ls_mov-dmbtr ).
        <fs_out>-num_ent   = <fs_out>-num_ent + 1.

        IF <fs_out>-ult_ent IS INITIAL OR ls_mov-budat > <fs_out>-ult_ent.
          <fs_out>-ult_ent = ls_mov-budat.
        ENDIF.

      WHEN '102' OR '201' OR '261' OR '601' OR '301' OR '311' OR '551'.

        <fs_out>-cant_sal  = <fs_out>-cant_sal  + abs( ls_mov-menge ).
        <fs_out>-valor_sal = <fs_out>-valor_sal + abs( ls_mov-dmbtr ).
        <fs_out>-num_sal   = <fs_out>-num_sal + 1.

        IF <fs_out>-ult_sal IS INITIAL OR ls_mov-budat > <fs_out>-ult_sal.
          <fs_out>-ult_sal = ls_mov-budat.
        ENDIF.

    ENDCASE.

  ENDLOOP.

  LOOP AT gt_out ASSIGNING <fs_out>.

    "Inventario final valorizado = valor actual del stock.
    <fs_out>-inv_fin_val = <fs_out>-valor_stock.

    "Inventario inicial estimado:
    "Inventario inicial = inventario final - entradas + salidas
    <fs_out>-inv_ini_val = <fs_out>-inv_fin_val
                         - <fs_out>-valor_ent
                         + <fs_out>-valor_sal.

    <fs_out>-inv_prom_val = ( <fs_out>-inv_ini_val + <fs_out>-inv_fin_val ) / 2.

    IF <fs_out>-inv_prom_val <> 0.
      <fs_out>-rotacion = <fs_out>-valor_sal / <fs_out>-inv_prom_val.
    ENDIF.

    IF <fs_out>-rotacion <> 0.
      <fs_out>-dias_inv = gc_dias_periodo / <fs_out>-rotacion.
    ENDIF.

  ENDLOOP.

ENDFORM.

FORM fill_master_data CHANGING cs_out TYPE ty_out.

  DATA: lv_labst TYPE mard-labst,
        lv_insme TYPE mard-insme,
        lv_speme TYPE mard-speme,
        lv_salk3 TYPE mbew-salk3,
        lv_bklas TYPE mbew-bklas.

  SELECT SINGLE maktx
    FROM makt
    INTO @cs_out-maktx
    WHERE matnr = @cs_out-matnr
      AND spras = 'S'.

  SELECT SINGLE labst, insme, speme
    FROM mard
    INTO (@lv_labst, @lv_insme, @lv_speme)
    WHERE matnr = @cs_out-matnr
      AND werks = @cs_out-werks
      AND lgort = @cs_out-lgort.

  cs_out-stock_actual = lv_labst + lv_insme + lv_speme.

  SELECT SINGLE salk3, bklas
    FROM mbew
    INTO (@lv_salk3, @lv_bklas)
    WHERE matnr = @cs_out-matnr
      AND bwkey = @cs_out-werks.

  cs_out-valor_stock = lv_salk3.
  cs_out-bklas       = lv_bklas.

ENDFORM.

FORM show_alv.

  DATA: lo_alv TYPE REF TO cl_salv_table.
  DATA: lo_columns TYPE REF TO cl_salv_columns_table,
        lo_column  TYPE REF TO cl_salv_column_table.

  DATA:
    lo_layout TYPE REF TO cl_salv_layout,
    ls_key    TYPE salv_s_layout_key.

  IF gt_out IS INITIAL.
    MESSAGE 'No hay información para mostrar' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = gt_out ).

      lo_columns = lo_alv->get_columns( ).
      TRY.

* Material
          lo_column ?= lo_columns->get_column( 'MATNR' ).
          lo_column->set_short_text( 'Material' ).
          lo_column->set_medium_text( 'Material' ).
          lo_column->set_long_text( 'Código de Material' ).
          lo_column->set_output_length( 15 ).
* Descripción
          lo_column ?= lo_columns->get_column( 'MAKTX' ).
          lo_column->set_short_text( 'Descrip.' ).
          lo_column->set_medium_text( 'Descripcion Material' ).
          lo_column->set_long_text( 'Denominacion del Material' ).
          lo_column->set_output_length( 40 ).
* Centro
          lo_column ?= lo_columns->get_column( 'WERKS' ).
          lo_column->set_long_text( 'Centro' ).
          lo_column->set_output_length( 10 ).
* Almacén
          lo_column ?= lo_columns->get_column( 'LGORT' ).
          lo_column->set_long_text( 'Almacén' ).
          lo_column->set_output_length( 10 ).
* Stock
          lo_column ?= lo_columns->get_column( 'STOCK_ACTUAL' ).
          lo_column->set_short_text( 'Stock Act.' ).
          lo_column->set_long_text( 'Stock Actual' ).
          lo_column->set_output_length( 10 ).

* Valor Stock
          lo_column ?= lo_columns->get_column( 'VALOR_STOCK' ).
          lo_column->set_short_text( 'Val. Stock' ).
          lo_column->set_long_text( 'Valor del Stock' ).
          lo_column->set_output_length( 15 ).
* Entradas
          lo_column ?= lo_columns->get_column( 'CANT_ENT' ).
          lo_column->set_short_text( 'Cant. Ent.' ).
          lo_column->set_long_text( 'Cantidad de Entradas' ).
          lo_column->set_output_length( 15 ).

          lo_column ?= lo_columns->get_column( 'VALOR_ENT' ).
          lo_column->set_short_text( 'Valor Ent.' ).
          lo_column->set_long_text( 'Valor de Entradas' ).
          lo_column->set_output_length( 15 ).
* Salidas
          lo_column ?= lo_columns->get_column( 'CANT_SAL' ).
          lo_column->set_short_text( 'Cant. Sal.' ).
          lo_column->set_long_text( 'Cantidad de Salidas' ).
          lo_column->set_output_length( 15 ).
          lo_column ?= lo_columns->get_column( 'VALOR_SAL' ).
          lo_column->set_short_text( 'Valor Sal.' ).
          lo_column->set_long_text( 'Valor de Salidas' ).
          lo_column->set_output_length( 15 ).
* Categoría valoración
          lo_column ?= lo_columns->get_column( 'BKLAS' ).
          lo_column->set_short_text( 'Cat. Val.' ).
          lo_column->set_long_text( 'Categoría de Valoración' ).
          lo_column->set_output_length( 15 ).
* Fechas
          lo_column ?= lo_columns->get_column( 'ULT_ENT' ).
          lo_column->set_short_text( 'Fec. U.E.' ).
          lo_column->set_long_text( 'Fecha Última Entrada' ).
          lo_column->set_output_length( 15 ).

          lo_column ?= lo_columns->get_column( 'ULT_SAL' ).
          lo_column->set_short_text( 'Fec. U.S.' ).
          lo_column->set_long_text( 'Fecha Última Salida' ).
          lo_column->set_output_length( 15 ).

* Contadores
          lo_column ?= lo_columns->get_column( 'NUM_ENT' ).
          lo_column->set_short_text( 'Num. Ent.' ).
          lo_column->set_long_text( 'Número de Entradas' ).
          lo_column->set_output_length( 15 ).

          lo_column ?= lo_columns->get_column( 'NUM_SAL' ).
          lo_column->set_short_text( 'Num. Sal.' ).
          lo_column->set_long_text( 'Número de Salidas' ).
          lo_column->set_output_length( 15 ).

* Inventario
          lo_column ?= lo_columns->get_column( 'INV_INI_VAL' ).
          lo_column->set_short_text( 'Inv. In. V' ).
          lo_column->set_long_text( 'Inventario Inicial ($)' ).
          lo_column->set_output_length( 15 ).

          lo_column ?= lo_columns->get_column( 'INV_FIN_VAL' ).
          lo_column->set_short_text( 'Inv. Fn. V' ).
          lo_column->set_long_text( 'Inventario Final ($)' ).
          lo_column->set_output_length( 15 ).

          lo_column ?= lo_columns->get_column( 'INV_PROM_VAL' ).
          lo_column->set_short_text( 'Inv. Pr. V' ).
          lo_column->set_long_text( 'Inventario Promedio ($)' ).
          lo_column->set_output_length( 15 ).

* Indicadores
          lo_column ?= lo_columns->get_column( 'ROTACION' ).
          lo_column->set_short_text( 'Rotación' ).
          lo_column->set_long_text( 'Rotación de Inventario' ).
          lo_column->set_output_length( 15 ).

          lo_column ?= lo_columns->get_column( 'DIAS_INV' ).
          lo_column->set_short_text( 'Días Inv.' ).
          lo_column->set_long_text( 'Días de Inventario' ).
          lo_column->set_output_length( 15 ).
        CATCH cx_salv_not_found.
      ENDTRY.

      lo_alv->get_functions( )->set_all( abap_true ).
      lo_alv->get_columns( )->set_optimize( abap_false ).

      "Permitir layouts / variantes
      lo_layout = lo_alv->get_layout( ).

      ls_key-report = sy-repid.
      lo_layout->set_key( ls_key ).


      "Permitir guardar layout específico de usuario o global
      lo_layout->set_save_restriction(
        if_salv_c_layout=>restrict_none ).

      "Layout inicial opcional
      lo_layout->set_default( abap_true ).


      lo_alv->display( ).

    CATCH cx_salv_msg INTO DATA(lx_msg).
      MESSAGE lx_msg->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.
