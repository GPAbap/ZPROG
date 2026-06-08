*----------------------------------------------------------------------*
***INCLUDE ZMM_RE_PROVEEDOR_BLOQUEADO_PBO.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
 SET PF-STATUS 'MAIN'.
  SET TITLEBAR 'T01'.

  IF go_cont IS INITIAL.

    CREATE OBJECT go_cont
      EXPORTING
        container_name = 'CC_ALV'.

    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_cont.

    CREATE OBJECT go_handler.
    SET HANDLER go_handler->on_toolbar      FOR go_grid.
    SET HANDLER go_handler->on_user_command FOR go_grid.
    SET HANDLER go_handler->on_double_click FOR go_grid.

    PERFORM display_grid.

  ENDIF.
ENDMODULE.
