*&---------------------------------------------------------------------*
*& Report zco_re_costo_prod_real_jhv
*&---------------------------------------------------------------------*
*& COSTOS ALIMENTO
*&---------------------------------------------------------------------*
REPORT zco_re_costo_prod_a_real_jhv.

INCLUDE zco_re_costo_prod_real_jhv_top.
INCLUDE zco_re_costo_prod_real_jhv_fun.

INITIALIZATION.
  gv_tipore = 'ALIMENTO'.
*LOOP AT SCREEN.
* if screen-group4 = '003' OR screen-group4 = '004'.
*    screen-active = '0'.
*    MODIFY SCREEN.
* ENDIF.
*ENDLOOP.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group4 = '004' OR screen-group4 = '005' or screen-group4 = '013' or screen-group4 = '014' OR screen-group4 = '006'
        OR screen-group4 = '015' OR screen-group4 = '017'  OR screen-group4 = '018' OR screen-group4 = '021' OR screen-group4 = '022'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


START-OF-SELECTION.
  CLEAR: vl_global, vl_solo_maquila, vl_solo_granel, vl_solo_ensacado.
  IF r_granel EQ abap_true AND r_maquil EQ abap_true AND r_ensaca EQ abap_true.
    vl_global = abap_true.
  ELSEIF r_granel EQ abap_true AND r_maquil EQ abap_false AND r_ensaca EQ abap_false.
    vl_solo_granel = abap_true.
  ELSEIF r_maquil EQ abap_true AND r_granel EQ abap_false AND r_ensaca EQ abap_false.
    vl_solo_maquila = abap_true.
  ELSEIF r_maquil EQ abap_false AND r_granel EQ abap_false AND r_ensaca EQ abap_true.
    vl_solo_ensacado = abap_true.
  ELSEIF r_maquil EQ abap_false AND r_granel EQ abap_false AND r_ensaca EQ abap_false.
    vl_global = abap_true.
  ENDIF.



  PERFORM set_textos.
  PERFORM build_fieldcatalog.
  PERFORM build_dinamic_table.
  IF vl_solo_ensacado EQ abap_false.
    PERFORM get_ordenes_alim.
    PERFORM get_kgs_pzas.
    PERFORM get_costosdirectos.
    PERFORM get_costosindirectos.
    PERFORM get_recupera_alim.
    "estadisticos
    PERFORM get_totales.
    PERFORM set_indica_alim.
    PERFORM calc_column_total_al.
  else.
  perform create_screen_ensaca.
  ENDIF.

  "-------------------

  PERFORM show_results.
