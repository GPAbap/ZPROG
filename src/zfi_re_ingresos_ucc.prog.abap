*&---------------------------------------------------------------------
*&
*&---------------------------------------------------------------------*

REPORT  zfi_re_ingresos_ucc.
TABLES: bkpf, acdoca, bseg.

INCLUDE ZFI_RE_INGRESOS_UCC_TOP.
*INCLUDE ZFI_RE_INGRESOS_TOP.
INCLUDE ZFI_RE_INGRESOS_UCC_FN.
*INCLUDE ZFI_RE_INGRESOS_FN.


START-OF-SELECTION.

***


  PERFORM get_Data.
  PERFORM create_fieldcat.
  PERFORM build_events.
  "PERFORM get_inversiones.
  PERFORM show_alv.

END-OF-SELECTION.
