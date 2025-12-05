*&---------------------------------------------------------------------*
*& Report ZRFI0110V2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrfi0110v2.

INCLUDE zrfi0110v2_top.
INCLUDE zrfi0110v2_fun.

START-OF-SELECTION.

  PERFORM proceso.
  PERFORM totalcuenta.
  "PERFORM maestro_iva.
  PERFORM fill_fieldcat.
  PERFORM display_alv.

  END-OF-SELECTION.
