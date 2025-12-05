*&---------------------------------------------------------------------*
*& Report zco_app_cobrb
*&---------------------------------------------------------------------*
*& Descripción: Programa Z que ajusta los productos que tuvieron
*& Producción y los que no, con la norma de liquidación
*&---------------------------------------------------------------------*
REPORT zco_app_cobrb.

INCLUDE zco_app_cobrb_cls.
INCLUDE zco_app_cobrb_top.
INCLUDE zco_app_cobrb_fun.

START-OF-SELECTION.

PERFORM set_fieldcat.
PERFORM get_aufnr.
PERFORM show_alv.
