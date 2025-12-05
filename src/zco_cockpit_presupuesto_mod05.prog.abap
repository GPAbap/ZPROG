*----------------------------------------------------------------------*
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_MOD05.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1005 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1005 OUTPUT.
  REFRESH fcode.

  ban = '0'.
  CLEAR wa_fcode.
  wa_fcode = '&EXECR'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECL'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECRP'. APPEND wa_fcode TO fcode.

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
  dyn1001 = '1'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_1005 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_1005 OUTPUT.
  PERFORM create_fieldcatecc2hana.
  PERFORM display_alvecc USING it_zco_tt_planpres
                           fieldcat102
                           'CC_ECC2HANA'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1005 INPUT.
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
    WHEN '&REPORTS'.
      CREATE OBJECT g_application.
      CALL SCREEN 1002.

  ENDCASE.

ENDMODULE.
