*&---------------------------------------------------------------------*
*& Report ZCO_RE_POLIZAS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_re_polizas.

INCLUDE zco_re_polizas_top.
INCLUDE zco_re_polizas_FUN.


AT SELECTION-SCREEN.
  TABLES sscrfields.
  CALL FUNCTION 'RSAQRT_LAYOUT_CHECK'
    EXPORTING
      variant = %layout
    CHANGING
      rtmode  = %runmode.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR %layout.
  CALL FUNCTION 'RSAQRT_LAYOUT_VALUE_REQUEST'
    CHANGING
      rtmode  = %runmode
      variant = %layout.

AT SELECTION-SCREEN OUTPUT.
  CALL FUNCTION 'RSAQRT_SSCR_OUTPUT'
    CHANGING
      rtmode = %runmode.

START-OF-SELECTION.

  PERFORM get_data.
  PERFORM create_fieldcat.
  PERFORM show_alv.
