************************************************************************
* Programa             : SAPMZCPED                                     *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Pedido automático                             *
* Fecha Creación       : 04.11.2017                                    *
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
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0102 INPUT.

  vg_dynnr = '0102'.
  CASE vg_ok_code.
    WHEN 'SAVE'.
      PERFORM f_update.
    WHEN 'NEXT'.
      IF vg_scaner IS NOT INITIAL.
        PERFORM f_scaner_repetido.
        IF sy-subrc NE 0.
          PERFORM f_get_cantidad.
        ELSE.
          PERFORM f_arma_102 USING 'UnManipu' vg_scaner 'Ya fue escaneado' space space space
                                   space space space space.
          CLEAR vg_scaner.
          CALL SCREEN '0103'.
        ENDIF.
      ENDIF.
    WHEN 'PGDN'. "Avance de página
      DESCRIBE TABLE tg_p101 LINES vg_lines2.
      vg_line2 = vg_line2 + 3.
      IF vg_index2 >= vg_lines2.
        vg_line2 = vg_line2 - 3.
      ENDIF.
    WHEN 'PGUP'. " Regresar página
      vg_line2 = vg_line2 - 3.
      IF vg_line2 < 0.
        vg_line2 = 0.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0104 INPUT.

  vg_dynnr = '0104'.
  CASE vg_ok_code.
    WHEN 'SAVE'.
      IF tg_dele[] IS NOT INITIAL.
        DELETE zsdtt_001 FROM TABLE tg_dele.
        CLEAR tg_dele[].
        IF vg_oferta = abap_false
        OR tg_p101[] IS INITIAL.
          PERFORM f_arma_102 USING 'Se eliminaron' 'UMan' space space space
                                    space space space space space.
          CLEAR vg_scaner.
          CALL SCREEN '0103'.
        ELSE.
          IF tg_p101[] IS NOT INITIAL.
            PERFORM f_crear_ped.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR vg_scaner.
    WHEN 'NEXT'.
      IF vg_scaner IS NOT INITIAL.
        PERFORM f_scaner_repetido.
        IF sy-subrc EQ 0.
          READ TABLE tg_p101 INTO sg_p101 WITH KEY exidv = vg_scaner.
          IF sy-subrc = 0.
            APPEND sg_p101 TO tg_dele.
            DELETE tg_p101 WHERE exidv = vg_scaner.
          ENDIF.
        ELSE.
          PERFORM f_arma_102 USING 'UnManipu' vg_scaner 'no existe' space space space
                space space space space.
          CLEAR vg_scaner.
          CALL SCREEN '0103'.
        ENDIF.
        CLEAR vg_scaner.
      ENDIF.
    WHEN 'PGDN'. "Avance de página
      DESCRIBE TABLE tg_p101 LINES vg_lines2.
      vg_line2 = vg_line2 + 3.
      IF vg_index2 >= vg_lines2.
        vg_line2 = vg_line2 - 3.
      ENDIF.
    WHEN 'PGUP'. " Regresar página
      vg_line2 = vg_line2 - 3.
      IF vg_line2 < 0.
        vg_line2 = 0.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMANDS  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0103 INPUT.

  CASE vg_dynnr.
    WHEN '0101'.
      CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2.
      CLEAR tg_p101[].
      SET SCREEN 0.
    WHEN OTHERS.
      IF vg_final EQ space.
        LEAVE TO SCREEN vg_dynnr.
      ELSE.
        vg_final = space.
        CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2.
        LEAVE PROGRAM.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " EXIT_COMMANDS_0102  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0102 INPUT.

  CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2.
  CLEAR tg_p101[].
  CLEAR: vg_final,vg_error,vg_vbeln,vg_oferta.
  IF sy-tcode = 'ZSDTR_0008'.
    LEAVE PROGRAM.
  ELSE.
    LEAVE TO SCREEN '0101'.
  ENDIF.
ENDMODULE.                 " EXIT_COMMANDS_0102  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0104 INPUT.

  CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2.
  CLEAR tg_p101[].
  CLEAR: vg_final,vg_error,vg_vbeln,vg_oferta.

  LEAVE TO SCREEN '0101'.
ENDMODULE.                 " EXIT_COMMANDS_0104  INPUT
*&---------------------------------------------------------------------*
*&      Module  CONTADOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE contador_102 INPUT.

  vg_index2 = sy-stepl + vg_line2.

ENDMODULE.                 " CONTADOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0101 INPUT.

  LEAVE PROGRAM.

ENDMODULE.                 " EXIT_COMMANDS_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0101 INPUT.

  IF vg_nocarga IS NOT  INITIAL.

    vg_dynnr = '0101'.
    SELECT * INTO TABLE tg_p101
      FROM zsdtt_001
     WHERE nocarga = vg_nocarga
       AND vbeln   = space.

    IF sy-subrc NE 0.
*      vg_dynnr = '0101'.
      PERFORM f_arma_102 USING 'No de carga' vg_nocarga 'no existe' 'o ya fue' 'Procesada' space
            space space space space.
      CALL SCREEN '0103'.

    ELSE.

      IF vg_agrega = abap_true.
        CALL SCREEN '0102'.
      ENDIF.
      IF vg_quitar = abap_true.
        CALL SCREEN '0104'.
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " USER_COMMANDS_0101  INPUT
