************************************************************************
* Programa             : SAPMZCPED                                     *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Pedido automático                             *
* Fecha Creación       : 04.11.2017                                    *
* Consultor Funcional  :                                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           MZCPEDI01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                    LOG DE MODIFICACIONES                             *
*----------------------------------------------------------------------*
* Descripción          :                                               *
* Funcional            :                                               *
* Desarrollador        :                                               *
* Fecha Modificación   :                                               *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_100 OUTPUT.

  SET PF-STATUS 'STA_0100'.
  SET TITLEBAR '100'.

  PERFORM f_almacen.

ENDMODULE.                 " STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_102 OUTPUT.

  SET PF-STATUS 'STA_0100'.
  IF sy-dynnr EQ '0102'.
    SET TITLEBAR '102'.
  ELSE.
    SET TITLEBAR '101'.
  ENDIF.

  PERFORM f_almacen.

ENDMODULE.                 " STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_104 OUTPUT.

  SET PF-STATUS 'STA_0100'.
  SET TITLEBAR '104'.

ENDMODULE.                 " STATUS_SCREEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_101 OUTPUT.

  SET PF-STATUS 'STA_0102'.
  SET TITLEBAR '101'.

ENDMODULE.                 " STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_data_102 OUTPUT.

  vg_index2 = sy-stepl + vg_line2.
  READ TABLE tg_p101 INTO sg_p101 INDEX vg_index2.

  IF  sy-subrc NE 0.
    EXIT FROM STEP-LOOP.
  ENDIF.
ENDMODULE.                 " SHOW_DATA  OUTPUT
