************************************************************************
* Programa             : SAPMZCOINV                                     *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Picking                                       *
* Fecha Creación       : 04.07.2017                                    *
* Consultor Funcional  :                                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           MZSATRAI01
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
*&      Module  EXIT_COMMANDS_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0100 INPUT.

  IF sy-dynnr = '0100'.
    LEAVE PROGRAM.
  ELSE.
    SET SCREEN 0.
  ENDIF.
  CLEAR: vg_index,vg_line,vg_lines.
ENDMODULE.                 " EXIT_COMMANDS_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0100 INPUT.

  CASE vg_ok_code.
    WHEN 'NEXT'.
      PERFORM f_get_info.
      IF tg_item[] IS NOT INITIAL.
        CALL SCREEN '0101'.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0101 INPUT.

  CASE vg_ok_code.
    WHEN 'SAVE'.
      PERFORM f_update.
    WHEN 'NEXT'.
      IF vg_top_exidv IS NOT INITIAL.
        LOOP AT tg_item INTO sg_item WHERE top_exidv = vg_top_exidv.
          sg_item-mark    = abap_true.
          sg_item-huexist = abap_true.
          MODIFY tg_item FROM sg_item.
        ENDLOOP.
        IF sy-subrc NE 0.
          PERFORM f_arma_102 USING '' 'No Manipulación' vg_top_exidv 'No existe' vg_msg5
                  space space space space space.
          CALL SCREEN '0103'.
        ENDIF.
        SORT tg_item BY item_nr venum top_exidv.
        CLEAR vg_top_exidv.
      ENDIF.
    WHEN 'PGDN'. "Avance de página
      DESCRIBE TABLE tg_item LINES vg_lines.
      vg_line = vg_line + 2.
      IF vg_index >= vg_lines.
        vg_line = vg_line - 2.
      ENDIF.
    WHEN 'PGUP'. " Regresar página
      vg_line = vg_line - 2.
      IF vg_line < 0.
        vg_line = 0.
      ENDIF.
    WHEN OTHERS.
      IF vg_top_exidv IS NOT INITIAL.
        LOOP AT tg_item INTO sg_item WHERE top_exidv = vg_top_exidv.
          sg_item-mark    = abap_true.
          sg_item-huexist = abap_true.
          MODIFY tg_item FROM sg_item.
        ENDLOOP.
        IF sy-subrc NE 0.
          PERFORM f_arma_102 USING '' 'No Manipulación' vg_top_exidv 'No existe' vg_msg5
                space space space space space.
          CALL SCREEN '0103'.
        ENDIF.
        SORT tg_item BY item_nr venum top_exidv.
        CLEAR vg_top_exidv.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0103 INPUT.

  IF vg_error = abap_true
  OR vg_ok_code NE 'SAVE'.
    SET SCREEN vg_dynnr.
  ELSE.
    CLEAR: tg_item[].
    LEAVE TO TRANSACTION 'ZSDTR_0002'.
  ENDIF.
ENDMODULE.                 " EXIT_COMMANDS_0103  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0101 INPUT.

  CLEAR: tg_item[].
  CLEAR: vg_index,vg_line,vg_lines,vg_top_exidv.
  LEAVE TO SCREEN '0100'.

ENDMODULE.                 " EXIT_COMMANDS_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  CONTADOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE contador_101 INPUT.

  vg_index = sy-stepl + vg_line.

ENDMODULE.                 " CONTADOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_ENTREGA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_entrega INPUT.

  IF sg_item-huexistnot = abap_true.
    sg_item-huexist = abap_false.
    sg_item-mark    = abap_true.
  ENDIF.
  MODIFY tg_item FROM sg_item INDEX vg_index.

ENDMODULE.                 " GET_ENTREGA  INPUT
