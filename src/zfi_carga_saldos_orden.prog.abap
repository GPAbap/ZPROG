*----------------------------------------------------------------------*
* Report  ZFI_CARGA_SALDOS                                             *
*----------------------------------------------------------------------*

REPORT  ZFI_CARGA_SALDO.

INCLUDE ZFI_CARGA_SALDO_ORDEN_TOP.
*INCLUDE ZFI_CARGA_SALDO_TOP.
INCLUDE ZFI_CARGA_SALDO_ORDEN_S01.
*INCLUDE ZFI_CARGA_SALDO_S01.
INCLUDE ZFI_CARGA_SALDO_ORDEN_F01.
*INCLUDE ZFI_CARGA_SALDO_F01.

START-OF-SELECTION.

  PERFORM IMPORTA_ARCHIVO .

  IF TG_FILE[] IS NOT INITIAL.
    PERFORM CREA_ASIENTO_CONTABLE.
  ENDIF.

*** Despliega Log de Errores
  IF TG_LOG[] IS NOT INITIAL.
    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        I_MESSAGE_TAB = TG_LOG.
  ENDIF.
