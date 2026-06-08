*&---------------------------------------------------------------------*
*& Report ZMM_RE_PROVEEDOR_BLOQUEADO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_re_proveedor_bloqueado.

INCLUDE ZMM_RE_PROVEEDOR_BLOQUEADO_top.
INCLUDE ZMM_RE_PROVEEDOR_BLOQUEADO_fun.

START-OF-SELECTION.
  PERFORM get_blocked_vendors.
  CALL SCREEN 0100.

INCLUDE zmm_re_proveedor_bloqueado_pbo.

INCLUDE zmm_re_proveedor_bloqueado_pai.
