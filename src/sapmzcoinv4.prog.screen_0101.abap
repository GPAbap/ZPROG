
PROCESS BEFORE OUTPUT.
  MODULE status_screen_101.
  LOOP.
    MODULE show_data.
  ENDLOOP.


PROCESS AFTER INPUT.
  MODULE exit_commands_0101 AT EXIT-COMMAND.
  LOOP.
    MODULE contador_101.

    CHAIN.
      FIELD sg_item-vemng.
      FIELD sg_item-huexistnot.
      FIELD sg_item-mark
      MODULE get_entrega ON CHAIN-REQUEST.
    ENDCHAIN.

  ENDLOOP.
  MODULE user_commands_0101.
