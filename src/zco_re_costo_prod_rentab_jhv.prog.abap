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
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  perform get_cantidad_procesado. "para operaciones posteriores
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  perform get_cantidad_pv. "para operaciones posteriores
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   PERFORM get_kgs_pzas. "para operaciones posteriores
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM flete_gto_transf.
  """"""""""""""""""""""""""""""""""
  PERFORM set_costo_transf.
  """"""""""""""""""""""""""""""""
  PERFORM get_ordenes_fin USING 'PPA'.
  PERFORM set_rendimientos.
  """""""""""""""""""""""""""""""""""""
  PERFORM set_peso_prom.
  """"""""""""""""""""""""""""
  PERFORM precio_vta_kg_uni.
  """""""""""""""""""""""""""""""""
  PERFORM set_gastos_distrib.
  """""""""""""""""""""""""""""""""""""
  PERFORM set_gastos_venta.
  """"""""""""""""""""""""""""""""""""""
  PERFORM set_gastos_admon.
  """"""""""""""""""""""""""""""""""""""""
  PERFORM show_results.
*  ENDIF.
