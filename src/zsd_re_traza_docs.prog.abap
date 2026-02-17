*&---------------------------------------------------------------------*
*& Report zsd_re_traza_docs
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsd_re_traza_docs.

INCLUDE zsd_re_traza_docs_top.
INCLUDE zsd_re_traza_docs_fun.

at SELECTION-SCREEN OUTPUT.
LOOP AT SCREEN.
  IF sy-uname NE 'JHERNANDEV' AND sy-uname NE 'AHERNANDEZPA'.
      IF screen-group4 = '008'.
        screen-active = 0. " 0 = no visible
        MODIFY SCREEN.
      ENDIF.
  ENDIF.
ENDLOOP.


START-OF-SELECTION.

  PERFORM get_data.
  perform show_data.
