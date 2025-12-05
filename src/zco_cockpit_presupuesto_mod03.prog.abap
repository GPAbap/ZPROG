*----------------------------------------------------------------------*
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_MOD03 .
*07032023
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1003 OUTPUT.
  REFRESH fcode.
  CLEAR wa_fcode.

  " IF dyn1001 EQ '0' OR dyn1001 IS INITIAL.
  wa_fcode = '&EXEC'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECR'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECRP'. APPEND wa_fcode TO fcode.
  "ENDIF.


*valida autorización para carga de presupuesto masiva
  AUTHORITY-CHECK OBJECT 'ZCOPCARGA'
  ID 'BTCUNAME' FIELD sy-uname
  ID 'ACTVT' FIELD '07'.

  IF sy-subrc NE 0 .
    wa_fcode = '&LOAD'. APPEND wa_fcode TO fcode.
  ENDIF.

  IF ( sy-uname  NE 'ASANCHEZA' AND sy-uname NE 'CALARCON' AND sy-uname NE 'JHERNANDEV' ).
    wa_fcode = '&CECO'. APPEND wa_fcode TO fcode.
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

ENDMODULE.                 " STATUS_1003  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1003 INPUT.


  CASE sy-ucomm.
    WHEN '&BACK'.
      dyn1001 = '0'.
      LEAVE TO SCREEN 0.
    WHEN '&LOAD'.
      dyn1001 = '0'.
      LEAVE TO SCREEN 0.
    WHEN '&AUTH'.
      dyn1001 = '0'.
      LEAVE TO SCREEN 0.
    WHEN '&REPORTS'.
      dyn1001 = '0'.
      LEAVE TO SCREEN 0.
    WHEN '&EXECL'.
      PERFORM containers_free103.
      PERFORM get_cecos_clean.
      PERFORM create_fieldcat103.
      IF it_kostl IS NOT INITIAL.
        it_only_kostl[] = it_kostl[].
        DELETE ADJACENT DUPLICATES FROM it_only_kostl COMPARING kostl.
        PERFORM display_alv103 USING it_only_kostl
              fieldcat102
              'CCALVCECO'.
      ELSE.
        MESSAGE 'No existen CeCos Afectados, que se deban limpiar' TYPE 'S'.
      ENDIF.

    WHEN '&REPORTS'.
      CREATE OBJECT g_application.
      CALL SCREEN 1002.
    WHEN 'LIMPIAR'.
      MESSAGE 'EJECUTO LIMPIAR' TYPE 'S'.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1003  INPUT
