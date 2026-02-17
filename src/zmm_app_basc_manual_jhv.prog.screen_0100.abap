PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE INIT.

*
PROCESS AFTER INPUT.
MODULE cancel AT EXIT-COMMAND.
  MODULE user_command_0100.

  CHAIN.
    FIELD zmm_tt_bascm_ent-pedido_sap MODULE pedido_sap .
  ENDCHAIN.
