*&---------------------------------------------------------------------*
*& Report zbipm002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbipm002.
Include zbipm002_top.
include zbipm002_fun.

START-OF-SELECTION.

perform get_data_zccomb.
if it_consumos is not INITIAL.
  "PERFORM aplicar_autoconsumos.
  PERFORM show_alv using it_consumos.

*
ENDIF.

MESSAGE 'Proceso Terminado' type 'S'.
