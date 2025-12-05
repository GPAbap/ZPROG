
PROCESS BEFORE OUTPUT.
  MODULE status_screen_101.
  LOOP.
    MODULE show_data.
  ENDLOOP.


PROCESS AFTER INPUT.
  MODULE exit_commands_0101 AT EXIT-COMMAND.
  FIELD vg_entre MODULE valida_entrega ON REQUEST.
  LOOP.
    MODULE contador_101.
    FIELD sg_vbs-pick MODULE get_entrega ON REQUEST.
  ENDLOOP.
  MODULE user_commands_0101.
