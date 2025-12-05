*&---------------------------------------------------------------------*
*& Report ZCO_KKAO_MASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_kkao_mass.
INCLUDE zco_kkao_mass_top.
INCLUDE zco_kkao_mass_fun.

START-OF-SELECTION.
PERFORM exec_bi.
