*&---------------------------------------------------------------------
*&
*&---------------------------------------------------------------------*

REPORT  zfi_re_ingresos_satep.


INCLUDE zfi_re_ingresos_satep_top.
INCLUDE zfi_re_ingresos_satep_fn.

START-OF-SELECTION.

***

  PERFORM create_fieldcat.
  "PERFORM get_Data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM show_alv.


END-OF-SELECTION.
