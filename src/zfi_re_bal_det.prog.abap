*&---------------------------------------------------------------------*
*& Report ZFI_RE_BAL_DET
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_re_bal_det.
INCLUDE ZFI_RE_BAL_DET_top.
INCLUDE ZFI_RE_BAL_DET_fun.


START-OF-SELECTION.

PERFORM get_data.
PERFORM set_fieldcat.
PERFORM layout_build.
PERFORM show_alv_hierseq.
