*&---------------------------------------------------------------------*
*& Report ZMM_RE_LIS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_re_lis.
INCLUDE zmm_re_lis_top.
INCLUDE ZMM_RE_LIS_fun.


START-OF-SELECTION.

  PERFORM get_data.
  PERFORM show_alv.
