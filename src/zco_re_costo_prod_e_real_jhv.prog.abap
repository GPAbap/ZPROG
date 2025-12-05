*&---------------------------------------------------------------------*
*& Report zco_re_costo_prod_real_jhv
*&---------------------------------------------------------------------*
*& COSTOS EMPACADORA
*&---------------------------------------------------------------------*
REPORT zco_re_costo_prod_e_real_jhv.

INCLUDE zco_re_costo_prod_real_jhv_top.
INCLUDE zco_re_costo_prod_real_jhv_fun.

INITIALIZATION.
  gv_tipore = 'EMPACADORA'.

*LOOP AT SCREEN.
* if screen-group4 = '003' OR screen-group4 = '004'.
*    screen-active = '0'.
*    MODIFY SCREEN.
* ENDIF.
*ENDLOOP.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group4 = '003' OR screen-group4 = '004' OR screen-group4 = '005'
    OR screen-group4 = '008' OR screen-group4 = '009' OR screen-group4 = '010'
    OR screen-group4 = '013' OR screen-group4 = '014' OR screen-group4 = '011'
    OR screen-group4 = '015' OR screen-group4 = '006' OR screen-group4 = '017'
    OR screen-group4 = '018' OR screen-group4 = '021' OR screen-group4 = '022'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


START-OF-SELECTION.


  PERFORM set_textos.
  PERFORM build_fieldcatalog.
  PERFORM build_dinamic_table.
  PERFORM get_ordenes_emp.
  if it_aufnr_end is not INITIAL.
    perform create_alv_option.
  ENDIF.
  PERFORM get_costosdirectos.
  PERFORM get_costosindirectos.
  PERFORM get_totales.
  "estadisticos
  PERFORM get_kgs_prod.
  perform get_unitarios_emp.
  "-------------------

  PERFORM show_results.
