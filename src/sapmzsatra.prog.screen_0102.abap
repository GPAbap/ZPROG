
PROCESS BEFORE OUTPUT.
  MODULE status_screen_102.
  LOOP.
    MODULE show_data_102.
  ENDLOOP.


PROCESS AFTER INPUT.
  MODULE exit_commands_0102 AT EXIT-COMMAND.
  LOOP.
    MODULE contador_102.
  ENDLOOP.
  MODULE user_commands_0102.
