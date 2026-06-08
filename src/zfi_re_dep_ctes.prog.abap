*&---------------------------------------------------------------------*
*& Report ZFI_RE_DEP_CTES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFI_RE_DEP_CTES.

include ZFI_RE_DEP_CTES_TOP.
INCLUDE ZFI_RE_DEP_CTES_FUN.

START-OF-SELECTION.
PERFORM get_data.

PERFORM show_alv.
