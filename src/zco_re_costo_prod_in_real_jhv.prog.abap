*&---------------------------------------------------------------------*
*& Report zco_re_costo_prod_real_jhv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_re_costo_prod_in_real_jhv.

INCLUDE zco_re_costo_prod_real_jhv_top.
INCLUDE zco_re_costo_prod_real_jhv_fun.


INITIALIZATION.
  gv_tipore = 'INCUBADORA'.
  gv_dauat = 'IN01'.


AT SELECTION-SCREEN.

  CASE sscrfields-ucomm.
    WHEN 'CHK_ACA'.
      IF c_gapesa EQ abap_true.
        c_gapesa = abap_false.

      ENDIF.
      gv_dauat = 'IN01'.
    WHEN 'CHK_GP'.
      IF c_aca EQ abap_true.
        c_aca = abap_false.
      ENDIF.
      gv_dauat = 'IN03'.
  ENDCASE.



AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group4 = '004' OR screen-group4 = '005'  OR screen-group4 = '008' OR screen-group4 = '009' OR screen-group4 = '010'
    OR screen-group4 = '013' OR screen-group4 = '014' OR screen-group4 = '011' OR screen-group4 = '015'
    OR screen-group4 = '017' OR screen-group4 = '018'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.








START-OF-SELECTION.

  PERFORM set_textos.
  PERFORM build_fieldcatalog.
  PERFORM build_dinamic_table.
  PERFORM get_ordenes_incubadora USING gv_dauat.



  IF c_aca EQ abap_true.
    PERFORM get_maquila_aca.
    PERFORM get_costosind_aca.
    PERFORM get_totales.
    PERFORM estadisticos_hue_aca.
    PERFORM get_unitarios_incuba.
    "PERFORM build_rows_aca.
*  ELSEIF c_gapesa EQ abap_true.
*  "GAPESA
*    PERFORM get_maquila_gapesa.
*    PERFORM get_costosind_gapesa.
*    PERFORM get_totales.
*    PERFORM estadisticos_hue_gapesa.
*    PERFORM get_unitarios_incuba.

  ELSE.
    PERFORM get_costosdirectos_incubadora.
    PERFORM get_costosindirectos_crianza.
    PERFORM get_subproductos_inc.
    PERFORM get_totales.
**"estadisticos
    PERFORM estadisticos_hue_inc.
    PERFORM get_unitarios_incuba.
    PERFORM get_unitarios_incuba2.
  ENDIF.
  "-------------------

  PERFORM show_results.
