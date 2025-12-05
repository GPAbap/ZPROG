*&---------------------------------------------------------------------*
*& Report ZSD_RE_PROMVSREAL_POLLOVIVO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSD_RE_PROMVSREAL_POLLOVIVO.

INCLUDE ZSD_RE_PROMVSREAL_TOP.
INCLUDE ZSD_RE_PROMVSREAL_FN.
INCLUDE ZSD_RE_PROMVSREAL_ALV.


START-OF-SELECTION.

PERFORM get_data.
PERFORM create_fieldcat.
PERFORM show_alv.
