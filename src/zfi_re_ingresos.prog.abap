*&---------------------------------------------------------------------
*&
*&---------------------------------------------------------------------*

REPORT  zfi_re_ingresos.
TABLES: bkpf, acdoca, bseg.

INCLUDE ZFI_RE_INGRESOS_TOP.
INCLUDE ZFI_RE_INGRESOS_FN.


START-OF-SELECTION.

***


  PERFORM get_Data.
  PERFORM create_fieldcat.
  PERFORM get_inversiones.
  PERFORM show_alv.

END-OF-SELECTION.
