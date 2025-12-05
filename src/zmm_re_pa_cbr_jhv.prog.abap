*&---------------------------------------------------------------------*
*& Report zmm_re_pa_cbr_jhv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_re_pa_cbr_jhv.

INCLUDE zmm_re_pa_cbr_jhv_top.
INCLUDE zmm_re_pa_cbr_jhv_fun.

AT SELECTION-SCREEN.
  IF p_dias LE 0.
    MESSAGE 'Días debe ser mayor que 0 y menor de 100' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

START-OF-SELECTION.

  PERFORM get_data.
  PERFORM init_calculations.
  PERFORM init_fieldcat.

  PERFORM show_alv.
