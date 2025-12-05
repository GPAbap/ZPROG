*----------------------------------------------------------------------*
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_MOD04.
*07032023
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1004 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1004 OUTPUT.
  REFRESH fcode.
  CLEAR wa_fcode.

  "IF dyn1001 EQ '0' OR dyn1001 IS INITIAL.
  wa_fcode = '&EXEC'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECR'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECL'. APPEND wa_fcode TO fcode.
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

  SET PF-STATUS 'ZSTATUS_1000' EXCLUDING fcode.
  SET TITLEBAR 'TCP_001'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1004  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1004 INPUT.

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
    WHEN '&CECO'.
      dyn1001 = '0'.
      LEAVE TO SCREEN 0.
    WHEN '&EXECRP'.
      PERFORM containers_free104.
      PERFORM get_cecos_reauth.
      PERFORM create_fieldcat104.
      IF it_kostl IS NOT INITIAL.
        it_only_kostl[] = it_kostl[].
        DELETE ADJACENT DUPLICATES FROM it_only_kostl COMPARING kostl idpres.
        DELETE ADJACENT DUPLICATES FROM it_kostl COMPARING kostl kstar idpres.
        PERFORM display_alv104 USING it_only_kostl
              fieldcat102
              'CCONTAINER_1004'.
      ELSE.
        MESSAGE 'No existen CeCos Afectados, que se deban ReAutorizar' TYPE 'S'.
      ENDIF.

    WHEN '&REPORTS'.
      CREATE OBJECT g_application.
      CALL SCREEN 1002.
  ENDCASE.
ENDMODULE.
