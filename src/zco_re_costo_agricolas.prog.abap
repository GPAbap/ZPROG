*&---------------------------------------------------------------------*
*& Report zco_re_costo_agricolas
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_re_costo_agricolas.

INCLUDE zco_agricolas_top.
INCLUDE zco_agricolas_fun.
INCLUDE zco_re_costo_agricolas_stato01.
INCLUDE zco_re_costo_agricolas_useri01.

INITIALIZATION.
  CREATE OBJECT obj_agricolas.

AT SELECTION-SCREEN.
  PERFORM valida_soc.
  IF it_bukrs IS INITIAL.
    MESSAGE 'Las sociedades ingresadas no son válidas' TYPE 'I'.
    gv_flag = abap_true.
  ELSE.
    gv_flag = abap_false.
  ENDIF.

START-OF-SELECTION.

  IF gv_flag EQ abap_false.
    PERFORM build_fieldcatalog.
    PERFORM build_dinamic_table.
    PERFORM get_vtas_netas.
    PERFORM get_invinicial.
    PERFORM costos_produccion.
    PERFORM get_invfinal.
    PERFORM get_ndi.
    PERFORM get_semilla. "13/06/2025
    PERFORM set_costo_vtas.
    PERFORM valida_ctos_vta.


    "Agricolas
    PERFORM informe_agricolas.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    PERFORM fill_empty.
    PERFORM show_results.



  ENDIF.
