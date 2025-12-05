*&---------------------------------------------------------------------*
*& Report zco_re_costo_prod_real_jhv
*&---------------------------------------------------------------------*
*& COSTOS DEPOSITO
*&---------------------------------------------------------------------*
REPORT zco_re_costo_prod_d_real_jhv.

include zco_re_costo_prod_real_jhv_top.
INCLUDE zco_re_costo_prod_real_jhv_fun.

INITIALIZATION.
gv_tipore = 'DEPOSITOS'.


at SELECTION-SCREEN OUTPUT.
LOOP AT SCREEN.
 if screen-group4 = '004' or screen-group4 = '005' or screen-group4 = '008' or screen-group4 = '009' or screen-group4 = '010'
    OR screen-group4 = '006' OR screen-group4 = '011' OR screen-group4 = '017' OR screen-group4 = '018' OR screen-group4 = '021' OR screen-group4 = '022'.
     screen-active = '0'.
    MODIFY SCREEN.
 ENDIF.
ENDLOOP.


START-OF-SELECTION.

  CLEAR: vl_globald, vl_solo_vivo, vl_solo_caliente.
  IF c_vivo EQ abap_true AND c_hot EQ abap_true.
    vl_globald = abap_true.
  ELSEIF c_vivo EQ abap_true AND c_hot EQ abap_false.
    vl_solo_vivo = abap_true.
  ELSEIF c_hot EQ abap_true AND c_vivo EQ abap_false.
    vl_solo_caliente = abap_true.
  ELSEIF c_vivo EQ abap_false AND c_hot EQ abap_false.
    vl_globald = abap_true.
  ENDIF.

PERFORM set_textos.
PERFORM build_fieldcatalog.
PERFORM build_dinamic_table.
PERFORM get_ordenes_dep.
PERFORM get_kgs_pzasppa.
PERFORM get_costosdirectos_dep_v.
PERFORM get_costosindirectos_flete.
PERFORM get_costosindirectos.
PERFORM get_totales.
PERFORM get_totalespro.
"estadisticos
"-------------------

PERFORM show_results.
