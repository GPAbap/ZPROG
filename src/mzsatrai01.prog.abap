************************************************************************
* Programa             : SAPMZSATRA                                     *
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
MODULE exit_commands_0010 INPUT.

  LEAVE PROGRAM.

ENDMODULE.                 " EXIT_COMMANDS_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0011  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0011 INPUT.

  CLEAR: vg_sammg, vg_error.
  "sale sin procesar los siguientes metodos, Set screen proceso los mod
  SET SCREEN 0.
ENDMODULE.                 " EXIT_COMMANDS_0011  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0012 INPUT.

  CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2,vg_vbeln, vg_error.
*  LEAVE TO SCREEN '0010'.
  SET SCREEN 0.
ENDMODULE.                 " EXIT_COMMANDS_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0051 INPUT.

  CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2, vg_error.
*  IF sy-dynnr = '0050'.
*    SET SCREEN 0.
*  ELSE.
  LEAVE PROGRAM.
*  ENDIF.

ENDMODULE.                 " EXIT_COMMANDS_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0100 INPUT.

  IF sy-dynnr = '0100'
  OR sy-dynnr = '0050'.
    LEAVE PROGRAM.
  ELSE.
    SET SCREEN 0.
  ENDIF.
  CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2,vg_error.
ENDMODULE.                 " EXIT_COMMANDS_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0010 INPUT.
  CLEAR vg_error.
  IF sy-dynnr = '0010'.
    IF vg_mayor = abap_true.
      PERFORM f_get_mayor.
      IF tg_vbs[] IS INITIAL.
        RETURN.
*        PERFORM f_arma_102 USING '' 'Entregas mayoreo' 'sin entregas' 'relevantes' space
*              space space space space space.
*        CALL SCREEN '0103'.
      ELSE.
        CALL SCREEN '0101'.
        CLEAR vg_mayor.
      ENDIF.
    ENDIF.

    IF vg_grupo = abap_true.
      CALL SCREEN '0011'.
      CLEAR vg_grupo.
    ENDIF.

    IF vg_otras = abap_true.
      CALL SCREEN '0012'.
      CLEAR vg_otras.
    ENDIF.

    IF vg_anula = abap_true.
      " BAPI_HU_DELETE_FROM_DEL
      CALL SCREEN '0013'.
      CLEAR vg_anula.
    ENDIF.

  ELSE.

    IF vg_sammg IS NOT INITIAL.
      PERFORM f_get_grupo.
      IF tg_vbs[] IS INITIAL.
        RETURN.
*        PERFORM f_arma_102 USING '' 'Gpo entregas' vg_sammg 'sin entregas' 'relevantes'
*              space space space space space.
*        CALL SCREEN '0103'.
      ELSE.
        CALL SCREEN '0101'.
      ENDIF.
      CLEAR vg_sammg.
    ENDIF.

  ENDIF.
ENDMODULE.                 " USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0013 INPUT.
  CLEAR vg_error.
  IF vg_vbeln IS NOT INITIAL.
    CASE vg_ok_code.
      WHEN 'NEXT'.
        PERFORM f_get_anular.
    ENDCASE.
  ENDIF.
ENDMODULE.                 " USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0051 INPUT.
  CLEAR vg_error.
  CASE vg_ok_code.
    WHEN 'NEXT'.
      PERFORM f_get_dev.
      IF tg_vbs[] IS NOT INITIAL.
        CALL SCREEN '0101'.
*     ELSE.
*        PERFORM f_arma_102 USING '' 'No se encontraron' 'registros' space
*                space space space space space space.
*
*        CALL SCREEN '0103'.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0012 INPUT.
  CLEAR vg_error.
  CASE vg_ok_code.
    WHEN 'NEXT'.
      PERFORM f_get_info.
      IF tg_vbs[] IS NOT INITIAL.
        CALL SCREEN '0101'.
*      ELSE.
*        PERFORM f_arma_102 USING '' 'No se encontraron' 'registros' space
*              space space space space space space.
*
*        CALL SCREEN '0103'.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands INPUT.
  CLEAR vg_error.
  CASE vg_ok_code.
    WHEN 'NEXT'.
*      PERFORM f_get_info.
      IF tg_vbs[] IS NOT INITIAL.
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
  CLEAR vg_error.
  CASE vg_ok_code.
    WHEN 'NEXT'.
      LOOP AT tg_vbs INTO sg_vbs
        WHERE pick = abap_true.
        tg_p101[] = tg_lips[].
        vg_vbln_ok = sg_vbs-vbeln.
        DELETE tg_p101 WHERE vbeln NE sg_vbs-vbeln.
        CLEAR sg_vbs-pick.
        MODIFY tg_vbs FROM sg_vbs.
      ENDLOOP.
      IF sy-subrc = 0.
        PERFORM f_actual_scaner.
        CALL SCREEN '0102'.
      ENDIF.

    WHEN 'PGDN'. "Avance de página
      DESCRIBE TABLE tg_vbs LINES vg_lines.
      vg_line = vg_line + 6.
      IF vg_index >= vg_lines.
        vg_line = vg_line - 6.
      ENDIF.
    WHEN 'PGUP'. " Regresar página
      vg_line = vg_line - 6.
      IF vg_line < 0.
        vg_line = 0.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0102 INPUT.

  CLEAR vg_error.
  CASE vg_ok_code.
    WHEN 'SAVE'.
      IF vg_contab = abap_true.
        CLEAR: vg_contab.
        PERFORM f_update.
      ELSE.
        PERFORM f_fill_temp.
      ENDIF.
    WHEN 'NEXT'.
      IF vg_scaner IS NOT INITIAL.
        PERFORM f_scaner_repetido.
        IF sy-subrc NE 0.
          PERFORM f_get_cantidad.
        ELSE.
          PERFORM f_arma_102 USING '' 'Unidad manipulación' 'ha sido asignada' 'a entrega'
                  sg_zitem-vbeln space space space space space.
          CLEAR: vg_contab,vg_scaner.
          CALL SCREEN '0103'.
        ENDIF.
      ELSE.
        READ TABLE tg_p101 TRANSPORTING NO FIELDS
          WITH KEY pikmg = 0.
        IF sy-subrc EQ 0
        AND vg_contab = abap_true.
          PERFORM f_arma_102 USING '' 'Aún hay pos' 'sin procesar' 'verifique' vg_msg5
                space space space space space.
          CLEAR vg_contab.
          CALL SCREEN '0103'.
        ENDIF.
      ENDIF.
    WHEN 'PGDN'. "Avance de página
      DESCRIBE TABLE tg_p101 LINES vg_lines2.
      vg_line2 = vg_line2 + 2.
      IF vg_index2 >= vg_lines2.
        vg_line2 = vg_line2 - 2.
      ENDIF.
    WHEN 'PGUP'. " Regresar página
      vg_line2 = vg_line2 - 2.
      IF vg_line2 < 0.
        vg_line2 = 0.
      ENDIF.
  ENDCASE.
  CLEAR vg_ok_code.

ENDMODULE.                 " USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMANDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_commands_0104 INPUT.

  CASE vg_ok_code.
    WHEN 'SAVE'.
      PERFORM f_fill_temp_anula.
    WHEN 'NEXT'.
      IF vg_scaner IS NOT INITIAL.
        READ TABLE tg_dele INTO sg_item WITH KEY vbeln = vg_vbeln
                                                 exidv = vg_scaner.
        IF sy-subrc NE 0.
          SELECT SINGLE * INTO sg_zitem
            FROM zhuinv_item
           WHERE vbeln EQ vg_vbeln
             AND exidv EQ vg_scaner.
          IF sy-subrc = 0.
            PERFORM f_anula_cantidad.
          ELSE.
            CLEAR vg_scaner.
            PERFORM f_arma_102 USING '' 'Unidad manipulación' 'No registrada:' vg_vbeln
                                     space space space space space space.
            CLEAR vg_contab.
            CALL SCREEN '0103'.

          ENDIF.
        ELSE.
          CLEAR vg_scaner.
          PERFORM f_arma_102 USING '' 'Unidad manipulación' 'marcada para' 'borrado'
                sg_zitem-vbeln space space space space space.
          CLEAR vg_contab.
          CALL SCREEN '0103'.
        ENDIF.
      ENDIF.
    WHEN 'PGDN'. "Avance de página
      DESCRIBE TABLE tg_p101 LINES vg_lines2.
      vg_line2 = vg_line2 + 2.
      IF vg_index2 >= vg_lines2.
        vg_line2 = vg_line2 - 2.
      ENDIF.
    WHEN 'PGUP'. " Regresar página
      vg_line2 = vg_line2 - 2.
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

  CLEAR:vg_msg1,vg_msg2,vg_msg3,vg_msg4,vg_msg5,vg_msg6,vg_msg7,vg_msg8,
  vg_msg9,vg_msg10.

  IF vg_final = space.
    IF vg_dynnr EQ '0102'.
      IF tg_vbs[] IS INITIAL.
        LEAVE TO TRANSACTION 'ZSDTR_0001'.
      ELSE.
        LEAVE TO SCREEN '0102'.
*        SET SCREEN 0.
      ENDIF.
    ELSE.
      SET SCREEN 0.
    ENDIF.
*    IF vg_dynnr EQ '0011'.
*      LEAVE TO SCREEN '0011'.
*    ENDIF.
*    IF vg_dynnr EQ '0012'.
*      LEAVE TO SCREEN '0012'.
*    ENDIF.
*    IF vg_anula EQ abap_true.
*      IF vg_err_msg = abap_true.
*        CLEAR vg_err_msg.
*        SET SCREEN 0.
*      ELSE.
*        LEAVE TO SCREEN '0104'.
*      ENDIF.
*    ENDIF.
*    IF vg_dynnr EQ '0051'.
*      LEAVE TO SCREEN '0051'.
*    ENDIF.

  ELSE.
    vg_final = space.
    IF vg_dynnr = '0104'.
      LEAVE TO TRANSACTION 'ZSDTR_0001'.
    ENDIF.
    IF tg_vbs[] IS NOT INITIAL.
      IF  vg_dynnr = '0102'.
        "Se regresa a la pantalla de captura 220931 a petición de usuario
        SET SCREEN '0102'. "SET SCREEN '0101'.
      ENDIF.
    ELSE.
      IF sy-tcode = 'ZSDTR_0001'.
        LEAVE TO TRANSACTION 'ZSDTR_0001'.
      ELSE.
        LEAVE TO TRANSACTION 'ZSDTR_0003'.
      ENDIF.
    ENDIF.
*    SET SCREEN 0.
    CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2.
    CLEAR: tg_vbap,tg_lotes[].
  ENDIF.

* Versión original

*  CLEAR:vg_msg1,vg_msg2,vg_msg3,vg_msg4,vg_msg5,vg_msg6,vg_msg7,vg_msg8,
*        vg_msg9,vg_msg10.
*
*  IF vg_final = space.
*    IF vg_dynnr EQ '0102'.
*      IF tg_vbs[] IS INITIAL.
*        LEAVE PROGRAM.
*      ELSE.
*        LEAVE TO SCREEN '0102'.
*      ENDIF.
**    ELSE.
**      SET SCREEN 0.
*    ENDIF.
*    IF vg_dynnr EQ '0011'.
*      LEAVE TO SCREEN '0011'.
*    ENDIF.
*    IF vg_dynnr EQ '0012'.
*      LEAVE TO SCREEN '0012'.
*    ENDIF.
*    IF vg_anula EQ abap_true.
*      IF vg_err_msg = abap_true.
*        CLEAR vg_err_msg.
*        SET SCREEN 0.
*      ELSE.
*        LEAVE TO SCREEN '0104'.
*      ENDIF.
*    ENDIF.
*    IF vg_dynnr EQ '0051'.
*      LEAVE TO SCREEN '0051'.
*    ENDIF.
*
*  ELSE.
*    vg_final = space.
*    IF tg_vbs[] IS NOT INITIAL.
*      IF  vg_dynnr = '0102'.
*        SET SCREEN '0101'.
*      ENDIF.
*    ELSE.
*      LEAVE TO SCREEN '0010'.
*    ENDIF.
*
*    CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2.
*    CLEAR: tg_vbap,tg_lotes[].
*  ENDIF.
ENDMODULE.                 " EXIT_COMMANDS_0102  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0101 INPUT.

  CLEAR: tg_lips[],tg_vbs[],ra_vstel[],tg_tvar[].
  CLEAR: tg_vbap,tg_lotes[],tg_likp[],tg_vbuk[],tg_vbss[].
  CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2.
*  IF vg_grupo = abap_true.
*    SET SCREEN '0011'.
*  ELSEIF vg_otras = abap_true.
*    SET SCREEN '0012'.
*  ELSEIF sy-tcode = 'ZSDTR_0003'.
*    SET SCREEN '0051'.
*  ELSE.
*    SET SCREEN '0010'.
*  ENDIF.
  SET SCREEN 0.
ENDMODULE.                 " EXIT_COMMANDS_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_commands_0102 INPUT.

  CLEAR: tg_vbap,tg_lotes[],tg_item[],tg_dele[].
  CLEAR: vg_index,vg_line,vg_lines,vg_index2,vg_line2,vg_lines2,
         vg_entre.

  IF sy-dynnr EQ '0102'.
    LEAVE TO SCREEN '0101'.
  ELSE.
    LEAVE TO SCREEN '0013'.
  ENDIF.
*  SET SCREEN 0.
ENDMODULE.                 " EXIT_COMMANDS_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  CONTADOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE contador_102 INPUT.

  vg_index2 = sy-stepl + vg_line2.

ENDMODULE.                 " CONTADOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  CONTADOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE contador_101 INPUT.

  vg_index = sy-stepl + vg_line.
  GET CURSOR FIELD vg_field LINE vg_cursor.
ENDMODULE.                 " CONTADOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida INPUT.

* Primera validación; existe grupo
  SELECT vbss~vbeln
    INTO TABLE tg_vbs
    FROM ( vbsk
   INNER JOIN vbss
      ON vbsk~sammg EQ vbss~sammg )
   WHERE vbsk~sammg EQ vg_sammg.
*     AND vbsk~smart EQ 'K'.

  IF sy-subrc NE 0.
    PERFORM f_arma_102 USING '' 'El grupo:' vg_sammg 'no existe' vg_msg5
          space space space space space.
    CALL SCREEN '0102'.
    CLEAR vg_ok_code.
    RETURN.
  ENDIF.

* Segunda validación: Estatus de la entrega
  SELECT lips~vbeln lips~posnr lips~matnr lips~charg lips~lfimg lips~vgbel lips~vgpos
    INTO TABLE tg_lips
    FROM ( lips
*   INNER JOIN likp
*      ON lips~vbeln EQ likp~vbeln
   INNER JOIN vbuk
      ON lips~vbeln EQ vbuk~vbeln )
    FOR ALL ENTRIES IN tg_vbs
   WHERE lips~vbeln EQ tg_vbs-vbeln.
*     AND vbuk~kostk EQ 'A'.

  IF sy-subrc NE 0.
    PERFORM f_arma_102 USING '' 'Grupo' 'sin posiciones relevanntes' vg_msg4 vg_msg5
          space space space space space.
    CALL SCREEN '0102'.
    CLEAR vg_ok_code.
    RETURN.
  ENDIF.

  LOOP AT tg_vbs INTO sg_vbs.

    READ TABLE tg_lips INTO sg_lips
      WITH KEY vbeln = sg_vbs-vbeln.

    IF sy-subrc NE 0.
      DELETE tg_vbs.
    ENDIF.

  ENDLOOP.

ENDMODULE.                 " VALIDA  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_ENTREGA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_entrega INPUT.

  IF vg_entre IS INITIAL.
    MODIFY tg_vbs FROM sg_vbs INDEX vg_index.
  ENDIF.
ENDMODULE.                 " GET_ENTREGA  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDA_ENTREGA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida_entrega INPUT.

  LOOP AT tg_vbs INTO sg_vbs WHERE vbeln = vg_entre.

    sg_vbs-pick = abap_true.
    MODIFY tg_vbs FROM sg_vbs.

  ENDLOOP.
  CLEAR vg_entre.

ENDMODULE.                 " VALIDA_ENTREGA  INPUT
