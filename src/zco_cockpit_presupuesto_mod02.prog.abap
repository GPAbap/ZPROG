*----------------------------------------------------------------------*
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_MOD02 .
* 0703023
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1002 OUTPUT.
  REFRESH fcode.
  CLEAR wa_fcode.

  "IF dyn1001 EQ '0' OR dyn1001 IS INITIAL.
  wa_fcode = '&EXEC'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECL'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECRP'. APPEND wa_fcode TO fcode.
  "ENDIF.

*  AUTHORITY-CHECK OBJECT 'ZCOUNAME'
*  ID 'BTCUNAME' FIELD sy-uname
*  ID 'ACTVT' FIELD '03'.
*
*  IF sy-subrc NE 0.
*    wa_fcode = '&CECO'. APPEND wa_fcode TO fcode.
*  ENDIF.

  IF ( sy-uname  NE 'ASANCHEZA' AND sy-uname NE 'CALARCON' AND sy-uname NE 'JHERNANDEV' ).
    wa_fcode = '&CECO'. APPEND wa_fcode TO fcode.
  ENDIF.

* valida autorización para carga de presupuesto masiva
  AUTHORITY-CHECK OBJECT 'ZCOPCARGA'
  ID 'BTCUNAME' FIELD sy-uname
  ID 'ACTVT' FIELD '07'.

  IF sy-subrc NE 0 .
    wa_fcode = '&LOAD'. APPEND wa_fcode TO fcode.
  ENDIF.

  " Autorización para re-autorizar plantilla por ceco
  AUTHORITY-CHECK OBJECT 'ZCOREAUTH'
  ID 'BTCUNAME' FIELD sy-uname
  ID 'ACTVT' FIELD '03'.
  IF sy-subrc NE 0 .
    wa_fcode = '&REAUTH'. APPEND wa_fcode TO fcode.
    wa_fcode = '&EXECRP'. APPEND wa_fcode TO fcode.
  ENDIF.

  SET PF-STATUS 'ZSTATUS_1000' EXCLUDING fcode.
  SET TITLEBAR 'TCP_001'.

ENDMODULE.                 " STATUS_1002  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1002 INPUT.
  CASE sy-ucomm.
    WHEN '&BACK'.
      dyn1001 = '0'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1002  INPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_1002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_1002 OUTPUT.
  IF g_tree IS INITIAL.
    " The Tree Control has not been created yet.
    " Create a Tree Control and insert nodes into it.
    PERFORM create_and_init_tree.
  ENDIF.
ENDMODULE.                 " PBO_1002  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_1002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_1002 INPUT.
  DATA: return_code TYPE i.
  gv_selectall = ''.
  CASE g_ok_code.
    WHEN 'TEST'.
      CALL METHOD g_tree->expand_node
        EXPORTING
          node_key = c_nodekey-new1.
    WHEN '&BACK'. " Finish program
      IF NOT g_custom_container IS INITIAL.
        " destroy tree container (detroys contained tree control, too)
        CALL METHOD g_custom_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        IF sy-subrc <> 0.
          "MESSAGE A000.
        ENDIF.
        CLEAR g_custom_container.
        CLEAR g_tree.
        dyn1001 = '0'.
        LEAVE TO SCREEN 0.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN '&LOAD'.
      dyn1001 = '0'.
      IF NOT g_custom_container IS INITIAL.
        " destroy tree container (detroys contained tree control, too)
        CALL METHOD g_custom_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        IF sy-subrc <> 0.
          "MESSAGE A000.
        ENDIF.
        CLEAR g_custom_container.
        CLEAR g_tree.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN '&AUTH'.
      dyn1001 = '0'.
      IF NOT g_custom_container IS INITIAL.
        " destroy tree container (detroys contained tree control, too)
        CALL METHOD g_custom_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        IF sy-subrc <> 0.
          "MESSAGE A000.
        ENDIF.
        CLEAR g_custom_container.
        CLEAR g_tree.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN '&CECO'.
      dyn1001 = '0'.
      PERFORM containers_free103.
      LEAVE TO SCREEN 0.
    WHEN '&EXECR'.
      "Se ejecutan los reportes.
      CASE id_exec.
        WHEN 'MatCantidade'.
          PERFORM containers_free.
          PERFORM get_presmat USING 'MATERIALES'.
          PERFORM get_fieldcat_rpt USING 'MEG'.
          PERFORM display_alv_tree USING it_matpres
                fieldcat102
                'ALV_CONTAINER'.
        WHEN 'MatMontos'.
          PERFORM containers_free.
          PERFORM get_presmat USING 'CUENTAS'.
          PERFORM get_fieldcat_rpt USING 'WTG'.
          PERFORM display_alv_tree USING it_matpres
                fieldcat102
                'ALV_CONTAINER'.
        WHEN 'ValidarMat'.
          AUTHORITY-CHECK OBJECT 'ZCO_RESERV'
          ID 'BTCUNAME' FIELD sy-uname
          ID 'ACTVT' FIELD '03'.

          IF sy-subrc EQ 0.

            PERFORM containers_free.
            PERFORM validar_materiales.
            PERFORM get_fieldcat USING 'ValidarMat'.
            PERFORM display_alv_tree USING gt_zco_tt_planpresm
                  fieldcat102
                  'ALV_CONTAINER'.

          ELSE.
            MESSAGE 'No tiene Autorización para esta actividad' TYPE 'S' DISPLAY LIKE 'E'.
            PERFORM containers_free.
          ENDIF.
        WHEN 'ElabSolpeds'.

          AUTHORITY-CHECK OBJECT 'ZCO_SOLPED'
          ID 'BTCUNAME' FIELD sy-uname
          ID 'ACTVT' FIELD '03'.
          IF sy-subrc EQ 0.

            PERFORM containers_free.
            PERFORM getdata4solped.
            PERFORM get_fieldcat USING 'ElabSolpeds'.
            PERFORM display_alv_tree USING gt_zco_tt_planpresm
                  fieldcat102
                  'ALV_CONTAINER'.
          ELSE.
            MESSAGE 'No tiene Autorización para esta actividad' TYPE 'S' DISPLAY LIKE 'E'.
            PERFORM containers_free.
          ENDIF.
        WHEN 'AjustePres'.
          PERFORM containers_free.
          PERFORM get_ajustepres.
          PERFORM get_fieldcat_rpt USING 'WTG'.
          PERFORM display_alv_tree USING it_ajustepres
                fieldcat102
                'ALV_CONTAINER'.
        WHEN OTHERS.
      ENDCASE.
      "---------------------------------------------------------
    WHEN '&CANCEL'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'Salida del Monitor de Presupuesto'
          text_question  = '¿En verdad desea salir de la Transacción?'
          text_button_1  = 'SI'(005)
          icon_button_1  = 'ICON_OKAY'
          text_button_2  = 'NO'(006)
          icon_button_2  = 'ICON_CANCEL'
          default_button = '2'
*         DISPLAY_CANCEL_BUTTON       = 'X'
*         USERDEFINED_F1_HELP         = ' '
          start_column   = 25
          start_row      = 6
        IMPORTING
          answer         = lv_answer
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF lv_answer EQ '1'.

        LEAVE PROGRAM.
      ENDIF.
    WHEN '&GRAPH'.
      PERFORM graph_cube.
  ENDCASE.

* CAUTION: clear ok code!
  CLEAR g_ok_code.
ENDMODULE.                 " PAI_1002  INPUT

*&---------------------------------------------------------------------*
*&      Form  containers_free
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
"containers_free
