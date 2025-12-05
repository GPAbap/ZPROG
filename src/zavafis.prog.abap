*&---------------------------------------------------------------------*
*& Report zavafis
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zavafis.

INCLUDE ZAVAFIS_top.
INCLUDE ZAVAFIS_fun.


START-OF-SELECTION.

  PERFORM get_datos.
  IF it_outtable IS NOT INITIAL.
    PERFORM show_form.
  ENDIF.
