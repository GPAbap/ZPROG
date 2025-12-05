*&---------------------------------------------------------------------*
*& Report ZPP_RE_STOCKPVENGORDA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpp_re_stockpvengorda.

INCLUDE zpp_re_stockpvengorda_top.
INCLUDE zpp_re_stockpvengorda_fun.


START-OF-SELECTION.

PERFORM get_data.
IF it_outtable[] is not INITIAL.
  PERFORM create_fieldcat.
  PERFORM show_alv.
else.
  MESSAGE 'No hay datos de acuerdo a su Criterio' TYPE 'S' DISPLAY LIKE 'W'.
ENDIF.
