*&---------------------------------------------------------------------*
*& Report ztm_re_fletes
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztm_re_fletes.
INCLUDE ztm_re_fletes_top.
INCLUDE ztm_re_fletes_fun.

START-OF-SELECTION.

  PERFORM create_fieldcat.
  PERFORM build_event.
  PERFORM get_data_tm.
  IF it_fletes IS INITIAL.
    MESSAGE 'No hay Datos para mostrar' TYPE 'S'.
  ELSE.
    PERFORM show_alv.
  ENDIF.
