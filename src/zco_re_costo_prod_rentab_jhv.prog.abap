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
  PERFORM get_cantidad_procesado. "para operaciones posteriores
  PERFORM get_cantidad_procesado_mes. "para operaciones posteriores
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM get_cantidad_pv_mes. "para operaciones posteriores (dato mensual)
  PERFORM get_cantidad_pv. "para operaciones posteriores (dato diario)

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM get_kgs_pzas. "para operaciones posteriores
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*  PERFORM flete_gto_transf_2.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  """"""""""""""""""""""""""""""""""

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """"""""""""""""""""""""""""""""
  PERFORM get_ordenes_fin USING 'PPA'.
  PERFORM set_costo_transf.
  PERFORM flete_gto_transf.
  PERFORM flete_gto_transf_2.
  PERFORM set_rendimientos.
  PERFORM set_recuperaciones.
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
  PERFORM cu_mat_prima.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM Costo_total_kg.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM Utilidad_bruta.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM total_gastos_venta.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM Utilidad_operacion.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  PerfORM utilidad_pkg.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM show_results.
*  ENDIF.
