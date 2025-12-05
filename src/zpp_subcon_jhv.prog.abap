*&---------------------------------------------------------------------*
*& Report zpp_subcon_jhv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpp_subcon_jhv.

INCLUDE zpp_subcon_jhv_top.
INCLUDE zpp_subcon_jhv_fn.


START-OF-SELECTION.

PERFORM get_data.
PERFORM set_fieldcat.
PERFORM show_data.
