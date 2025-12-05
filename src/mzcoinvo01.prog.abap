************************************************************************
* Programa             : SAPMZCOINV                                    *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Picking                                       *
* Fecha Creación       : 04.07.2017                                    *
* Consultor Funcional  :                                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           MZSATRAO01
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
MODULE status_screen OUTPUT.

*  SET PF-STATUS 'STA_0100'.
*  SET TITLEBAR '100'.
  vg_dynnr = sy-dynnr.
ENDMODULE.                 " STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_101 OUTPUT.

*  SET PF-STATUS 'STA_0100'.
*  SET TITLEBAR '100'.
  vg_dynnr = sy-dynnr.
ENDMODULE.                 " STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_data OUTPUT.

  vg_index = sy-stepl + vg_line.
  READ TABLE tg_item INTO sg_item INDEX vg_index.

  IF  sy-subrc NE 0.
    EXIT FROM STEP-LOOP.
  ENDIF.
ENDMODULE.                 " SHOW_DATA  OUTPUT
