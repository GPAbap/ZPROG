*&---------------------------------------------------------------------*
*& Report zco_re_costo_prod_real_jhv
*&---------------------------------------------------------------------*
*& COSTOS PPA PPA
*&---------------------------------------------------------------------*
REPORT zco_re_costo_prod_ppa_real_jhv.

include zco_re_costo_prod_real_jhv_top.
INCLUDE zco_re_costo_prod_real_jhv_fun.

INITIALIZATION.
gv_tipore = 'PPA'.
LOOP AT SCREEN.
 if screen-group4 = '003' OR screen-group4 = '004'.
    screen-active = '0'.
    MODIFY SCREEN.
 ENDIF.
ENDLOOP.

at SELECTION-SCREEN OUTPUT.
LOOP AT SCREEN.
 if screen-group4 = '003' OR screen-group4 = '004'
 or screen-group4 = '008' or screen-group4 = '009' or screen-group4 = '010'
 or screen-group4 = '013' or screen-group4 = '014'  OR screen-group4 = '011'
 OR screen-group4 = '015' OR screen-group4 = '006' OR screen-group4 = '017'
 OR screen-group4 = '018' OR screen-group4 = '021' OR screen-group4 = '022'.
     screen-active = '0'.
    MODIFY SCREEN.
 ENDIF.

ENDLOOP.

AT SELECTION-SCREEN On VALUE-REQUEST FOR p_clord.
PERFORM filter_ppa.


START-OF-SELECTION.


PERFORM set_textos.
PERFORM build_fieldcatalog.
PERFORM build_dinamic_table.
PERFORM get_ordenes_ppa.
PERFORM get_kgs_pzasppa.
PERFORM get_costosdirectos.
PERFORM get_costosindirectos_flete.
PERFORM get_costosindirectos.
PERFORM get_totales.
PERFORM get_totalespro.
PERFORM set_unitario_ppa_det.
"-------------------

PERFORM show_results.
