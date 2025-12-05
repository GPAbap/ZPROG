*&---------------------------------------------------------------------*
*& Report ZMM_BAPI_DELSOLPED_TRAS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_BAPI_DELSOLPED_TRAS.

INCLUDE ZMM_BAPI_DELSOLPED_TRAS_TOP.
INCLUDE ZMM_BAPI_DELSOLPED_TRAS_FUN.

START-OF-SELECTION.

PERFORM get_data.
PERFORM create_fieldcat.
PERFORM show_alv.
