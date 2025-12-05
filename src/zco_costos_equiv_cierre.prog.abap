*&---------------------------------------------------------------------*
*& Report ZCO_COSTOS_EQUIV_CIERRE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_costos_equiv_cierre.
INCLUDE zco_costos_equiv_cierre_top.
INCLUDE zco_costos_equiv_cierre_fun.

START-OF-SELECTION.

*AT SELECTION-SCREEN.
*if p_poper ne sy-datum+4(2) and p_gjahr ne sy-datum+0(4).
*   MESSAGE 'Año y Periodo diferente al actual ' type 'S' DISPLAY LIKE 'E'.
*  " exit.
*  ENDIF.


  PERFORM valida_makz CHANGING vg_seguir.

  IF vg_seguir NE 0. "si es 0 no encontro registros.

    PERFORM copy_makg.
    if vg_seguir eq 0.
    PERFORM copy_makz.
    PERFORM get_ordenes.
    PERFORM get_mseg.
    PERFORM get_matnr_precio.
    PERFORM set_zmakz.
    PERFORM calc_dif.
    PERFORM armado_makz_final.
    MESSAGE 'Proceso Terminado. Corra ML' Type 'S'.

    endif.
  ENDIF.
