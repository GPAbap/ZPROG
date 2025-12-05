*&---------------------------------------------------------------------*
*& Report zco_re_costo_prod_real_jhv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_re_costo_prod_cr_real_jhv.

INCLUDE zco_re_costo_prod_real_jhv_top.
INCLUDE zco_re_costo_prod_real_jhv_fun.


INITIALIZATION.
  gv_tipore = 'CRIANZA'.


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group4 = '004' OR screen-group4 = '005'  OR screen-group4 = '008' OR screen-group4 = '009' OR screen-group4 = '010'
    OR screen-group4 = '013' OR screen-group4 = '014' OR screen-group4 = '011' OR screen-group4 = '015' OR screen-group4 = '021'  OR screen-group4 = '022'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.



START-OF-SELECTION.

  PERFORM set_textos.
  PERFORM build_fieldcatalog.
  PERFORM build_dinamic_table.
  PERFORM get_ordenes_crianza.

  PERFORM get_costosdirectos_crianza.
  PERFORM get_costosindirectos_crianza.
  PERFORM get_recuperaciones_crianza.
  PERFORM get_totales.
*"estadisticos
PERFORM estadisticos_crianza.
PERFORM set_indicadores_crianza.
PERFORM get_unitarios_crianza.
 PERFORM calc_column_total_cr.

  "-------------------

  PERFORM show_results.
