*----------------------------------------------------------------------*
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_MOD01 .
*& 07032023
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  F4_FRGCO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_frgco INPUT.
*
*  TYPES: BEGIN OF st_auth,
*        frggr TYPE frggr,
*        frgco TYPE frgco,
*        frgct TYPE frgct,
*    END OF st_auth.
*
*  DATA it_auth TYPE STANDARD TABLE OF st_auth.
*  REFRESH it_auth.
*
*  SELECT c~frggr c~frgco t~frgct
*  INTO TABLE it_auth
*  FROM t16fc AS c
*    INNER JOIN t16fd AS t ON t~frggr EQ c~frggr
*                          AND t~frgco EQ c~frgco
*  WHERE t~spras EQ 'S'.
*  .
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      retfield        = 'FRGGR'
*      dynprofield     = 'FRGCO'
*      value_org       = 'S'
*      dynpprog        = sy-repid
*      dynpnr          = sy-dynnr
*    TABLES
*      value_tab       = it_auth
*    EXCEPTIONS
*      parameter_error = 1
*      no_values_found = 2
*      OTHERS          = 3.
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

ENDMODULE.                 " F4_FRGCO  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  REFRESH fcode.
  DATA ban.
  ban = '0'.
  CLEAR wa_fcode.
  wa_fcode = '&EXECR'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECL'. APPEND wa_fcode TO fcode.
  wa_fcode = '&EXECRP'. APPEND wa_fcode TO fcode.

*  AUTHORITY-CHECK OBJECT 'ZCOUNAME'
*  ID 'BTCUNAME' FIELD sy-uname
*  ID 'ACTVT' FIELD '03'.
*
  "IF sy-subrc NE 0.
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


ENDMODULE.                 " STATUS_1001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.
  DATA ok TYPE I.
  CASE sy-ucomm.
  WHEN '&BACK'.
    dyn1001 = '0'.
    LEAVE TO SCREEN 0.
  WHEN '&LOAD'.
    dyn1001 = '0'.
    LEAVE TO SCREEN 0.
  WHEN '&EXEC'.

    PERFORM exec_auth_pres CHANGING ok.
    IF it_pendientes IS NOT INITIAL.
      PERFORM field_catalog.
*      PERFORM set_layout.
      PERFORM display_alv USING it_pendientes po_fieldcat 'CCONTAINER01'.
    ENDIF.
  WHEN '&CECO'.

    dyn1001 = '0'.
    PERFORM containers_free103.
    LEAVE TO SCREEN 0.
  WHEN '&REPORTS'.
    CREATE OBJECT g_application.
    CALL SCREEN 1002.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_AUTH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_auth INPUT.
*  REFRESH it_autorizar.
*  CLEAR wa_autorizar.
*
*  SELECT bukrs butxt
*  FROM T001
*  INTO CORRESPONDING FIELDS OF TABLE it_autorizar
*  where spras = 'S'
*    .
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      retfield        = 'BUKRS'
*      dynprofield     = 'BUKRS'
*      dynpprog        = sy-repid
*      dynpnr          = sy-dynnr
*      value_org       = 'S'
*    TABLES
*      value_tab       = it_autorizar
*    EXCEPTIONS
*      parameter_error = 1
*      no_values_found = 2
*      OTHERS          = 3.
*
*  IF sy-subrc EQ 0.
*
*
*
*  ENDIF.

ENDMODULE.                 " F4_AUTH  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_AUTH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_auth INPUT.
*  DATA: w_bukrs LIKE dynpread-fieldvalue,
*        w_kostl LIKE dynpread-fieldvalue.
*
*  DATA lv_kostl TYPE kostl.
*  data lv_lines type i.
*  DATA: name TYPE vrm_id,
*        list TYPE vrm_values,
*        value LIKE LINE OF list.
*
*  DATA: it_responsables TYPE zco_tt_autpres OCCURS 0 WITH HEADER LINE.
*  Data: dyfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
*
*  CLEAR list. REFRESH list.
*  clear value.
*
*  name = 'ZCO_TT_AUTPRES-RESPONSABLE'.
*  gv_init = 'X'.
*  CALL FUNCTION 'C14Z_DYNP_READ_FIELD'
*    EXPORTING
*      i_program      = sy-repid
*      i_dynpro       = sy-dynnr
*      i_fieldname    = 'ZCO_TT_AUTPRES-BUKRS'
*      i_flg_steploop = 'X'
*    CHANGING
*      e_value        = w_bukrs.
*
*  CALL FUNCTION 'C14Z_DYNP_READ_FIELD'
*    EXPORTING
*      i_program      = sy-repid
*      i_dynpro       = sy-dynnr
*      i_fieldname    = 'ZCO_TT_AUTPRES-KOSTL'
*      i_flg_steploop = 'X'
*    CHANGING
*      e_value        = w_kostl.
*
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = w_kostl
*    IMPORTING
*      output = lv_kostl.
*
*
*  SELECT mandt codlib bukrs kostl  responsable denominacion
*    FROM zco_tt_autpres
*  INTO TABLE it_responsables
*  WHERE bukrs EQ w_bukrs
*    AND kostl EQ lv_kostl
*  .
*
*  LOOP AT it_responsables.
*    CLEAR value.
*    value-key = it_responsables-responsable.
*    value-text = it_responsables-responsable.
*    APPEND value TO list.
*  ENDLOOP.
*REFRESH: dyfields. clear value.
*
*
*  READ TABLE list INTO VALUE INDEX 1."Read first record from Dropdown values
*  dyfields-fieldname =  name.
*  dyfields-fieldvalue = value-text.
*  APPEND dyfields.
*
*  CALL FUNCTION 'VRM_SET_VALUES'
*    EXPORTING
*      id     = name
*      values = list.
*
*
*
*  "ZCO_TT_AUTPRES-RESPONSABLE
*  CALL FUNCTION 'DYNP_VALUES_UPDATE'
*  EXPORTING
*    dyname                     = sy-cprog
*    dynumb                     = sy-dynnr
*  TABLES
*    dynpfields                 = dyfields
*
*    .
*


ENDMODULE.                 " FILL_AUTH  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_LISTBOX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_LISTBOX INPUT.



ENDMODULE.                 " MODIFY_LISTBOX  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FILL_AUTH OUTPUT.
*DATA: wa_bukrs LIKE dynpread-fieldvalue,
*      wa_kostl LIKE dynpread-fieldvalue.
*
**DATA lv__kostl TYPE kostl.
**
**DATA: lv_name TYPE vrm_id,
**      lv_list TYPE vrm_values,
**      lv_VALUE LIKE LINE OF list.
*
*DATA: it_responsables1 TYPE zco_tt_autpres OCCURS 0 WITH HEADER LINE.
*DATA: dyfields1 LIKE dynpread OCCURS 1 WITH HEADER LINE.
*
*
*
*if gv_init eq ''.
*CLEAR list. REFRESH list.
*name = 'ZCO_TT_AUTPRES-RESPONSABLE'.
*
*CALL FUNCTION 'C14Z_DYNP_READ_FIELD'
*EXPORTING
*  i_program      = sy-repid
*  i_dynpro       = sy-dynnr
*  i_fieldname    = 'ZCO_TT_AUTPRES-BUKRS'
*  i_flg_steploop = 'X'
*CHANGING
*  e_value        = w_bukrs.
*
*CALL FUNCTION 'C14Z_DYNP_READ_FIELD'
*EXPORTING
*  i_program      = sy-repid
*  i_dynpro       = sy-dynnr
*  i_fieldname    = 'ZCO_TT_AUTPRES-KOSTL'
*  i_flg_steploop = 'X'
*CHANGING
*  e_value        = w_kostl.
*
*
*CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*EXPORTING
*  INPUT  = w_kostl
*IMPORTING
*  OUTPUT = lv_kostl.
*
*
*SELECT mandt codlib bukrs kostl pernr responsable denominacion
*FROM zco_tt_autpres
*INTO TABLE it_responsables
*WHERE bukrs EQ w_bukrs
*AND kostl EQ lv_kostl
*.
*
*LOOP AT it_responsables.
*  CLEAR VALUE.
*  VALUE-KEY = it_responsables-responsable.
*  VALUE-TEXT = it_responsables-responsable.
*  APPEND VALUE TO list.
*ENDLOOP.
*REFRESH dyfields.
*READ TABLE list INTO VALUE INDEX 1."Read first record from Dropdown values
*dyfields-fieldname =  name.
*dyfields-fieldvalue = VALUE-TEXT.
*APPEND dyfields.
*
*CALL FUNCTION 'VRM_SET_VALUES'
*EXPORTING
*  ID     = name
*  values = list.
*
*
*CALL FUNCTION 'DYNP_VALUES_UPDATE'
*EXPORTING
*  dyname                     = sy-cprog
*  dynumb                     = sy-dynnr
*TABLES
*  dynpfields                 = dyfields
*
*  .
*else.
*
*  REFRESH dyfields.
*  clear value.
*  READ TABLE list INTO VALUE INDEX 1."Read first record from Dropdown values
*  dyfields-fieldname =  name.
*  dyfields-fieldvalue = VALUE-TEXT.
*  APPEND dyfields.
*
*  CALL FUNCTION 'DYNP_VALUES_UPDATE'
*  EXPORTING
*    dyname                     = sy-cprog
*    dynumb                     = sy-dynnr
*  TABLES
*    dynpfields                 = dyfields
*.
*ENDIF.
ENDMODULE.                 " FILL_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INITIALIZATION INPUT.
  DATA: dyfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
  REFRESH it_auth.

  SELECT kostl bname  name_text
  INTO TABLE it_auth
  FROM zco_tt_autpres AS a
  inner JOIN user_addrp AS u ON u~bname EQ sy-uname
  WHERE bukrs EQ p_bukrs1 AND uname EQ sy-uname.

  CLEAR wa_auth.
  READ TABLE it_auth INTO wa_auth INDEX 1.
  dyfields-fieldname =  'P_AUTH'.
  dyfields-fieldvalue = wa_auth-name_text.
  APPEND dyfields.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
  EXPORTING
    dyname                     = sy-cprog
    dynumb                     = sy-dynnr
  TABLES
    dynpfields                 = dyfields[].

  p_auth = wa_auth-name_text.
  gv_p_bukrs1 = p_bukrs1.
  PERFORM containers_free101.

ENDMODULE.                 " INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INITIALIZATION OUTPUT.
  " DATA: dyfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
  REFRESH it_auth.

  IF ban EQ '0' OR ban IS INITIAL.
    SELECT kostl bname  name_text
    INTO TABLE it_auth
    FROM zco_tt_autpres AS a
    inner JOIN user_addrp AS u ON u~bname EQ sy-uname
    WHERE bukrs EQ p_bukrs1 AND uname EQ sy-uname.

    CLEAR wa_auth.
    READ TABLE it_auth INTO wa_auth INDEX 1.
    dyfields-fieldname =  'P_AUTH'.
    dyfields-fieldvalue = wa_auth-name_text.
    APPEND dyfields.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname                     = sy-cprog
      dynumb                     = sy-dynnr
    TABLES
      dynpfields                 = dyfields[].

    p_auth = wa_auth-name_text.
    gv_p_bukrs1 = p_bukrs1.
    ban = '1'.
  ENDIF.
ENDMODULE.                 " INITIALIZATION  OUTPUT
