*&---------------------------------------------------------------------*
*& Report zco_re_costo_prod_real_jhv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_re_costo_prod_c_real_jhv.

INCLUDE zco_re_costo_prod_real_jhv_top.
INCLUDE zco_re_costo_prod_real_jhv_fun.


INITIALIZATION.
  gv_tipore = 'POSTURA'.


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group4 = '004' OR screen-group4 = '005' OR screen-group4 = '008' OR screen-group4 = '009' OR screen-group4 = '010'
    OR screen-group4 = '013' OR screen-group4 = '014' OR screen-group4 = '011' OR screen-group4 = '015' OR screen-group4 = '006'
    OR screen-group4 = '017' OR screen-group4 = '018' OR screen-group4 = '021' OR screen-group4 = '022'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.



START-OF-SELECTION.

  PERFORM set_textos.
  PERFORM build_fieldcatalog.
  PERFORM build_dinamic_table.
  PERFORM get_ordenes_huevo.

  "PERFORM get_kgs_pzas.
  PERFORM get_costosdirectos_postura.
  PERFORM get_costosindirectos_postura.
  PERFORM get_recuperaciones_post.
  PERFORM get_costowip.
  PERFORM get_totales.
*"estadisticos
PERFORM estadisticos_postura.


PERFORM set_indicadores_post.
PERFORM get_unitarios_post.

  "-------------------

  PERFORM show_results.
