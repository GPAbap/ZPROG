*&---------------------------------------------------------------------*
*& Report ZPP_NOTIFICA_ORDENES_PROD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPP_NOTIFICA_ORDENES_PROD.

INCLUDE ZPP_NOTIFICA_TOP.
INCLUDE ZPP_NOTIFICA_FUN.


START-OF-SELECTION.

  PERFORM get_data.
  IF it_ordenes[] is not INITIAL.
    PERFORM create_fieldcat.
    PERFORM show_alv.
  ENDIF.
end-of-SELECTION.
