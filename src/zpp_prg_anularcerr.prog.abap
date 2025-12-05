*&---------------------------------------------------------------------*
*& Report ZPP_PRG_ANULARCERR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpp_prg_anularcerr.

INCLUDE zpp_prg_anularcerr_top.
INCLUDE zpp_prg_anularcerr_fun.
INCLUDE zpp_prg_anularcerr_bin.

START-OF-SELECTION.

  PERFORM get_orders.

  IF it_ordenes[] IS INITIAL.
    MESSAGE 'órdenes no encontradas' TYPE 'S' DISPLAY LIKE 'E'.
  else.
    PERFORM exec_bi.
    PERFORM create_fieldcat.
    PERFORM show_alv.
  ENDIF.
