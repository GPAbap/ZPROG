*&---------------------------------------------------------------------*
*& Report zco_re_costo_prod_rentab_jhv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_re_costo_prod_rentab_jhv.

INCLUDE zco_re_costo_prod_rentab_top.
INCLUDE zco_re_costo_prod_rentab_fun.

START-OF-SELECTION.

  PERFORM build_fieldcatalog.
  PERFORM build_dinamic_table.
  PERFORM get_ordenes_fin USING 'ENGORDA'.
*  IF it_aufnr_end IS INITIAL.
*    MESSAGE 'No hay órdenes con los criterios establecidos' TYPE 'I' DISPLAY LIKE 'S'.
*  ELSE.
  PERFORM get_kgs_pzas.
  PERFORM set_peso_prom.
  """"""""""""""""""""""""""""
  PERFORM get_ordenes_fin USING 'PPA'.
  PERFORM set_costo_transf.
  """"""""""""""""""""""""""""""""
  PERFORM set_rendimientos.
  """""""""""""""""""""""""""
  PERFORM flete_gto_transf.
  """""""""""""""""""""""""""""""""
  PERFORM precio_vta_kg_uni.
  """""""""""""""""""""""""""""""""
  PERFORM show_results.
*  ENDIF.
