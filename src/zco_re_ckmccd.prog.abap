*&---------------------------------------------------------------------*
*& Report ZCO_RE_CKMCCD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCO_RE_CKMCCD.

INCLUDE ZCO_RE_CKMCCD_TOP.
INCLUDE ZCO_RE_CKMCCD_FUN.


START-OF-SELECTION.

refresh rg_werks.
PERFORM get_werks CHANGING rg_werks.

LOOP AT rg_werks into data(wa_werks).
  PERFORM get_data_ckml USING wa_werks-low.
  PERFORM process_data.

ENDLOOP.

 IF it_ckml[] is not INITIAL.
      PERFORM create_fieldcat.
      PERFORM show_alv.
  ENDIF.
