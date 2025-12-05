*&---------------------------------------------------------------------*
*& Report zco_re_costo_prod_real_jhv
*&---------------------------------------------------------------------*
*& COSTOS ENGORDA
*&---------------------------------------------------------------------*
REPORT zco_re_costo_prod_real_jhv.

INCLUDE zco_re_costo_prod_real_jhv_top.
INCLUDE zco_re_costo_prod_real_jhv_fun.


INITIALIZATION.
  gv_tipore = 'ENGORDA'.


AT SELECTION-SCREEN.
  IF p_werks IS NOT INITIAL.
    CLEAR p_zona.
  ENDIF.

  IF p_zona IS NOT INITIAL.
    CLEAR p_werks.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group4 = '005' OR screen-group4 = '008' OR screen-group4 = '009' OR screen-group4 = '010'
    OR screen-group4 = '013' OR screen-group4 = '014' OR screen-group4 = '011' OR screen-group4 = '015'
    OR screen-group4 = '006' OR screen-group4 = '017' OR screen-group4 = '018' OR screen-group4 = '021'
    OR screen-group4 = '022'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_zona.
  REFRESH: t_values, t_fields.
  CLEAR : t_values, t_fields.

  t_fields-fieldname = 'NAME2'.
  t_fields-tabname = 'T001W'.
  t_fields-selectflag = 'X'.
  APPEND t_fields. CLEAR t_fields.

  SELECT name2 AS zona
  INTO TABLE t_match
  FROM t001w WHERE werks LIKE 'PE%'.

  SORT t_match BY zona.
  DELETE ADJACENT DUPLICATES FROM t_match.

  LOOP AT t_match.
    t_values-value = t_match-zona.
    APPEND t_values.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
    EXPORTING
*     cucol        = 20
*     curow        = 4
      tabname      = 'T_MATCH'
      fieldname    = 'zona'
    IMPORTING
      select_value = p_zona
    TABLES
      fields       = t_fields
      valuetab     = t_values.



START-OF-SELECTION.

  PERFORM build_fieldcatalog.
  PERFORM build_dinamic_table.
  PERFORM get_ordenes_fin.
  IF it_aufnr_end IS INITIAL.
    MESSAGE 'No hay órdenes con los criterios establecidos' TYPE 'I' DISPLAY LIKE 'S'.
  ELSE.
    PERFORM set_textos.
    PERFORM get_kgs_pzas.
    PERFORM get_costosdirectos.
    PERFORM get_costosindirectos.
    PERFORM get_recuperaciones.
    PERFORM get_totales.
    "estadisticos
    PERFORM get_pollitos.
    PERFORM get_mortandad.
    PERFORM get_kgsAlimento.
    PERFORM set_indicadores.
    "PERFORM get_totalespro.
    PERFORM set_indicadores2.
    PERFORM get_metros2.
    PERFORM get_prom_edad.
    PERFORM set_indicadores3.
    "-------------------
    PERFORM show_results.

  ENDIF.
