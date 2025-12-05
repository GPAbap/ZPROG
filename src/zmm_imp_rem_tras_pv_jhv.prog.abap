*&---------------------------------------------------------------------*
*& Report ZMM_IMP_REM_TRAS_PV_JHV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_imp_rem_tras_pv_jhv.
INCLUDE ZMM_IMP_REM_TRAS_PV_JHV_top.
INCLUDE ZMM_IMP_REM_TRAS_PV_JHV_fun.

START-OF-SELECTION.

  PERFORM consultar_pedido.
  PERFORM print_smartform TABLES it_remision it_bascula using gv_bascula.
