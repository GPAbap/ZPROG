*&---------------------------------------------------------------------
*&
*&---------------------------------------------------------------------*

REPORT  zfi_re_ingresos_s4hana.
TABLES: bkpf, acdoca, bseg.

INCLUDE z_rep_ingresos_top.
INCLUDE zfi_re_ingresos_s4hana_fn.

START-OF-SELECTION.

***
  PERFORM get_texto.
  PERFORM create_fieldcat.
  PERFORM get_Data.
  PERFORM get_inversiones.
  PERFORM show_alv.

  IF p_conta IS NOT INITIAL.
    "GTEXT2 = 'REPORTE DE INGRESOS -Contable-'.
  ENDIF.
*    If p_cocon is NOT INITIAL.
*        gtext2 = 'REPORTE DE INGRESOS -Contable Conciliado Concentrado-'.
*    EndIf.
*    IF p_conci is NOT INITIAL.
*        gtext2 = 'REPORTE DE INGRESOS -Contable Conciliado-'.
**        GTEXT2 = 'REPORTE CONCILIADO DE INGRESOS'.
*    ENDIF.
*    IF p_RIVA is NOT INITIAL.
*        GTEXT2 = 'RESUMEN DE INGRESOS I.V.A.'.
*    ENDIF.
*    IF p_RISR is NOT INITIAL.
*        GTEXT2 = 'RESUMEN DE INGRESOS I.S.R.'.
*    ENDIF.
*
*    IF p_RESING is NOT INITIAL.
*        GTEXT2 = 'CONCENTRADO DE INGRESOS ISR '.
*    ENDIF.


END-OF-SELECTION.


  "PERFORM main.
