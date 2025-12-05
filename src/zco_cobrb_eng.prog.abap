*&---------------------------------------------------------------------*
*& Report zco_cobrb_eng
*&---------------------------------------------------------------------*
*& Ajuste de Normas de Liquidación historicos de Engorda
*&---------------------------------------------------------------------*
REPORT zco_cobrb_eng.

INCLUDE zco_cobrb_eng_top.
INCLUDE zco_cobrb_eng_fun.


START-OF-SELECTION.
PERFORM set_fieldcat.
PERFORM get_data.
PERFORM show_alv.
