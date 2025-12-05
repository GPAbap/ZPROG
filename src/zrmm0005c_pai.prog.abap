*----------------------------------------------------------------------*
***INCLUDE ZRMM0005B_PAI .
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

      IF NOT g_custom_container IS INITIAL.
        CALL METHOD g_custom_container->free
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
        ENDIF.
        FREE g_custom_container.
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
