*&---------------------------------------------------------------------*
*& Report ZMM_RE_OC_DETALLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_re_oc_detalle.

INCLUDE zmm_re_oc_detalle_top.
INCLUDE zmm_re_oc_detalle_fun.

START-OF-SELECTION.

  PERFORM get_Data.
  PERFORM show_alv.
