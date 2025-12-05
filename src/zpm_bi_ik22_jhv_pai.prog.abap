*----------------------------------------------------------------------*
***INCLUDE ZBIPM0005B_PAI .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
DATA: lv_ucomm TYPE syucomm.
  lv_ucomm = sy-ucomm.

  CASE lv_ucomm.
    WHEN 'BACK'
      OR 'EXIT'
      OR 'CANC'.

      IF NOT cc_grid IS INITIAL.
        CALL METHOD cc_grid->free
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
        ENDIF.
        FREE cc_grid.
      ENDIF.

      CALL METHOD cl_gui_cfw=>flush
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc NE 0.
      ENDIF.

*      SET SCREEN 0.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN 'OKAY'.
    WHEN OTHERS.
  ENDCASE..

ENDMODULE.                 " USER_COMMAND_0100  INPUT
