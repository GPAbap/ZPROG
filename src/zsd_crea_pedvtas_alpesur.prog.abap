*&---------------------------------------------------------------------*
*& Report zsd_crea_pedvtas_alpesur
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
    REPORT zsd_crea_pedvtas_alpesur.

Include zsd_crea_pedvtas_alpesur_top.
Include zsd_crea_pedvtas_alpesur_fun.

INITIALIZATION.
CREATE OBJECT obj_pedidos.
PERFORM get_parametros.

PERFORM recorre_centros.
