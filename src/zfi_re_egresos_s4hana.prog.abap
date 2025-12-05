*&---------------------------------------------------------------------
*&
*&---------------------------------------------------------------------*

REPORT  zfi_re_egresos_s4hana.
TABLES: bkpf, acdoca,zfi_xml_complem.


INCLUDE Z_REP_EGRESOS_TOP.
INCLUDE ZFI_RE_EGRESOS_S4HANA_FN.


START-OF-SELECTION.

***
  PERFORM get_texto.
  PERFORM create_fieldcat.
  PERFORM get_Data.
  PERFORM get_inversiones.
  PERFORM show_alv.




END-OF-SELECTION.
