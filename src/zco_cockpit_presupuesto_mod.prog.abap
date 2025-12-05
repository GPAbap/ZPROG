*----------------------------------------------------------------------*
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_MOD .
*& 07032023
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
  DATA: fcode    TYPE TABLE OF sy-ucomm,
        wa_fcode TYPE sy-ucomm.


  IF dyn1001 EQ '0' OR dyn1001 IS INITIAL.
    wa_fcode = '&EXEC'. APPEND wa_fcode TO fcode.
    wa_fcode = '&EXECR'. APPEND wa_fcode TO fcode.
    wa_fcode = '&EXECL'. APPEND wa_fcode TO fcode.
    wa_fcode = '&EXECRP'. APPEND wa_fcode TO fcode.

    AUTHORITY-CHECK OBJECT 'ZCOUNAME'
    ID 'BTCUNAME' FIELD sy-uname
    ID 'ACTVT' FIELD '03'.

    IF sy-subrc NE 0 .
      " wa_fcode = '&CECO'. APPEND wa_fcode TO fcode.
      wa_fcode = '&EXECL'. APPEND wa_fcode TO fcode.
    ENDIF.

    IF ( sy-uname  NE 'ASANCHEZA' AND sy-uname NE 'CALARCON' AND sy-uname NE 'JHERNANDEV' ).
      wa_fcode = '&CECO'. APPEND wa_fcode TO fcode.
    ENDIF.

    "autorización para carga de presupuesto masivo

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

  ENDIF.

  SET PF-STATUS 'ZSTATUS_1000' EXCLUDING fcode.
  SET TITLEBAR 'TCP_001'.

ENDMODULE.                 " STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  DATA lv_answer.
  IF sy-ucomm EQ '&BACK' AND dyn1001 = '0'.


    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = 'Salida del Monitor de Presupuesto'
        text_question  = '¿En verdad desea salir de la Transacción?'
        text_button_1  = 'SI'(005)
        icon_button_1  = 'ICON_OKAY'
        text_button_2  = 'NO'(006)
        icon_button_2  = 'ICON_CANCEL'
        default_button = '2'
        start_column   = 25
        start_row      = 6
      IMPORTING
        answer         = lv_answer
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.
    IF lv_answer EQ '1'.
      LEAVE TO SCREEN 0.
    ENDIF.

  ELSEIF sy-ucomm EQ '&LOAD'.
    PERFORM get_ruta.
  ELSEIF sy-ucomm EQ '&AUTH'.
    gv_init = ''.
    CALL SCREEN 1001.
  ELSEIF sy-ucomm EQ '&REPORTS'.
    CREATE OBJECT g_application.
    CALL SCREEN 1002.
    "SET SCREEN 1002.
  ELSEIF sy-ucomm EQ '&CECO'.
    PERFORM containers_free103.
    CALL SCREEN 1003.
  ELSEIF sy-ucomm EQ '&REAUTH'.
    PERFORM containers_free104.
    CALL SCREEN 1004.
  ELSEIF sy-ucomm EQ '&CANCEL'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = 'Salida del Monitor de Presupuesto'
        text_question  = '¿En verdad desea salir de la Transacción?'
        text_button_1  = 'SI'(005)
        icon_button_1  = 'ICON_OKAY'
        text_button_2  = 'NO'(006)
        icon_button_2  = 'ICON_CANCEL'
        default_button = '2'
*       DISPLAY_CANCEL_BUTTON       = 'X'
*       USERDEFINED_F1_HELP         = ' '
        start_column   = 25
        start_row      = 6
      IMPORTING
        answer         = lv_answer
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.
    IF lv_answer EQ '1'.

      LEAVE TO SCREEN 0.
    ENDIF.
  ELSEIF sy-ucomm EQ '&AJUSTE'.
    PERFORM update_data.
  ELSEIF sy-ucomm EQ '&CO_MEINH'.
    PERFORM update_data_mein.
  ELSEIF sy-ucomm EQ '&MATNRPREC'.
    PERFORM upload_matnrlist.
  ELSEIF sy-ucomm EQ '&IMPORTAR'.
    PERFORM import_4ecc.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOAD_HEADER  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE load_header OUTPUT.
  PERFORM fill_event USING gt_events.
  PERFORM init_header.
  PERFORM init_fieldcat.

ENDMODULE.                 " LOAD_HEADER  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_PARAMETERS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_parameters INPUT.
*  DATA _ok.
*  DATA lv_idpres TYPE char10.
*
*
*  CALL FUNCTION 'DYNP_VALUES_READ'
*    EXPORTING
*      dyname             = sy-repid
*      dynumb             = sy-dynnr
*      translate_to_upper = 'X'
*    TABLES
*      dynpfields         = dynpro_values.
*
*  READ TABLE dynpro_values INDEX 1 INTO field_value.
*
*  PERFORM get_ruta." USING field_value-fieldvalue.
*  wa_values_tab-p_route = field_value-fieldvalue.
*  APPEND wa_values_tab TO values_tab.
*
*"UPDATE zco_tt_planpres SET TIPMOD = 'O' WHERE IDPRES = '0000003651'.
*
*  IF field_value-fieldvalue IS NOT INITIAL.
*    PERFORM load_excel_to_table CHANGING _ok.
*    IF _ok EQ '1'.
*      PERFORM create_dynamic_itab USING it_excel.
*      PERFORM fill_data USING it_excel.
*      PERFORM get_idpres CHANGING lv_idpres.
*      perform save_header_pres USING lv_idpres
*                             CHANGING _ok.
*      "PERFORM save_position_pres USING lv_idpres
*            .
*      "PERFORM display_alv USING it_planpres.
*    ENDIF.
*  ENDIF.

ENDMODULE.                 " INIT_PARAMETERS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init OUTPUT.
*  CLEAR: field_value, dynpro_values.

*  field_value-fieldname = 'P_ROUTE'.
*  field_value-fieldvalue = field_value-fieldvalue.
*  APPEND field_value TO dynpro_values.
  IF it_csks IS INITIAL.
    PERFORM fill_csks.
  ENDIF.

*  IF dyn1001 EQ '0' OR dyn1001 IS INITIAL.
*    PERFORM get_ruta.
*  ENDIF.
ENDMODULE.                 " INIT  OUTPUT
