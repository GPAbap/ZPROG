*&---------------------------------------------------------------------*
*& Report zpp_app_notifica_co11n
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpp_app_notifica_co11n.

INCLUDE zpp_app_notifica_TOP.
INCLUDE zpp_app_notifica_FUN.


START-OF-SELECTION.

PERFORM get_data.
PERFORM create_fieldcat.
PERFORM show_alv.
