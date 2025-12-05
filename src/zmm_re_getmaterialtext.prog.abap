*&---------------------------------------------------------------------*
*& Report ZMM_RE_GETMATERIALTEXT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_RE_GETMATERIALTEXT.

INCLUDE ZMM_RE_GETMATERIALTEXT_TOP.
INCLUDE ZMM_RE_GETMATERIALTEXT_FUN.




START-OF-SELECTION.

PERFORM get_data.
PERFORM create_fieldcat.
PERFORM show_alv.
