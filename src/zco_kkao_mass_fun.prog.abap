*&---------------------------------------------------------------------*
*& Include          ZCO_KKAO_MASS_FUN
*&---------------------------------------------------------------------*
FORM exec_bi .
  DATA: vl_par   TYPE string, vl_fname TYPE string, num TYPE i.

  TYPES: BEGIN OF st_werks,
           werks TYPE werks_d,
         END OF st_werks.

  DATA: it_werks TYPE STANDARD TABLE OF st_werks.
  FIELD-SYMBOLS <fs_werks> TYPE st_werks.

  IF so_werks-high IS NOT INITIAL.
    SELECT werks INTO TABLE it_werks
      FROM t001w WHERE werks IN so_werks.
  ELSE.
    REFRESH it_werks.
    LOOP AT so_werks INTO DATA(wa_werks).
      APPEND INITIAL LINE TO it_werks ASSIGNING <fs_werks>.
      <fs_werks>-werks = wa_werks-low.
    ENDLOOP.
  ENDIF.


  LOOP AT it_werks INTO DATA(wa).

    PERFORM bdc_dynpro USING 'SAPMKKAC' '0105'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'AUFK-WERKS'.
    PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
    PERFORM bdc_field USING 'AUFK-WERKS' wa-werks.
    PERFORM bdc_field USING 'KKA0100-IFAUF' 'X'.
    PERFORM bdc_field USING 'KKA0100-IKOSA' 'X'.
    PERFORM bdc_field USING 'KKA0100-IPAUF' 'X'.
    PERFORM bdc_field USING 'KKA0100-BIS_ABGR_M' p_wip.
    PERFORM bdc_field USING 'KKA0100-BIS_ABGR_J' p_ejer.
    PERFORM bdc_field USING 'VERS_AUSG' 'X'.
    PERFORM bdc_field USING 'KKA0100-VERSN' p_vers.
    PERFORM bdc_field USING 'KKA0100-TESTL' p_test.
    PERFORM bdc_field USING 'KKA0100-OBJLIST' 'X'. "p_sal.
    PERFORM bdc_field USING 'KKA0100-CCCUR' 'X'.
    PERFORM bdc_field USING 'KKA0100-INCACOMB' 'X'.

    PERFORM bdc_dynpro USING 'SAPMKKAC' '0105'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'AUFK-WERKS'.
    PERFORM bdc_field USING 'BDC_OKCODE' '=AUSF'.
    PERFORM bdc_field USING 'AUFK-WERKS' wa-werks.
    PERFORM bdc_field USING 'KKA0100-IFAUF' 'X'.
    PERFORM bdc_field USING 'KKA0100-IKOSA' 'X'.
    PERFORM bdc_field USING 'KKA0100-IPAUF' 'X'.
    PERFORM bdc_field USING 'KKA0100-BIS_ABGR_M' p_wip.
    PERFORM bdc_field USING 'KKA0100-BIS_ABGR_J' p_ejer.
    PERFORM bdc_field USING 'VERS_AUSG' 'X'.
    PERFORM bdc_field USING 'KKA0100-VERSN' p_vers.
    PERFORM bdc_field USING 'KKA0100-TESTL' p_test.
    PERFORM bdc_field USING 'KKA0100-OBJLIST' 'X'. "p_sal.
    PERFORM bdc_field USING 'KKA0100-CCCUR' 'X'.
    PERFORM bdc_field USING 'KKA0100-INCACOMB' 'X'.



    PERFORM bdc_dynpro USING 'SAPMSSY0' '0120'.
    PERFORM bdc_field USING 'BDC_OKCODE' '=&F12'. "Esc

    PERFORM bdc_dynpro USING 'SAPMSSY0' '0100'.
    PERFORM bdc_field USING 'BDC_OKCODE' '=YES'.

    PERFORM bdc_dynpro USING 'SAPMKKAC' '0105'.
    PERFORM bdc_field USING 'BDC_OKCODE' '/EABBR'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'AUFK-WERKS'.



    PERFORM bdc_transaction USING 'KKAO'.

  ENDLOOP.
ENDFORM.




FORM bdc_dynpro USING program dynpro.
  CLEAR bcdata_wa.
  bcdata_wa-program = program.
  bcdata_wa-dynpro = dynpro.
  bcdata_wa-dynbegin = 'X'.
  APPEND bcdata_wa TO bcdata_tab.
ENDFORM. "BDC_DYNPRO

*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  DATA nodata VALUE '000'.

  IF fval <> nodata.
    CLEAR bcdata_wa.
    bcdata_wa-fnam = fnam.
    bcdata_wa-fval = fval.
    APPEND bcdata_wa TO bcdata_tab.
  ENDIF.
ENDFORM. "BDC_FIELD

FORM bdc_transaction USING tcode.
  DATA ctumode LIKE ctu_params-dismode VALUE 'S'.
  DATA ctu VALUE 'X'.
  DATA cupdate LIKE ctu_params-updmode VALUE 'A'.

  DATA l_messtab TYPE bdcmsgcoll.
  IF ck_mode1     EQ 'X'.
    ctumode = 'N'.
  ELSEIF ck_mode2 EQ 'X'.
    ctumode = 'A'.
*  ELSEIF ck_mode3 EQ 'X'.
*    ctumode = 'S'.
  ENDIF.
* batch input session
  REFRESH messtab.
  CALL TRANSACTION tcode USING bcdata_tab
        MODE ctumode
        UPDATE cupdate
        MESSAGES INTO messtab.
  l_subrc = sy-subrc.

*  IF messtab[] IS INITIAL.
*    APPEND INITIAL LINE TO it_log ASSIGNING <fs_log>.
*    CONCATENATE 'El Centro'  'termino sin errores' INTO vl_msg SEPARATED BY space.
*    <fs_log>-msg = vl_msg.
*  ELSE.
*    READ TABLE messtab INTO DATA(wa) WITH KEY msgtyp = 'E'.
*    IF sy-subrc EQ 0.
*      APPEND INITIAL LINE TO it_log ASSIGNING <fs_log>.
*      CONCATENATE 'La orden' tab-orden 'termino con errores' wa-msgid wa-msgnr wa-msgv1 INTO vl_msg SEPARATED BY space.
*      <fs_log>-msg = vl_msg.
*    ELSE.
*      APPEND INITIAL LINE TO it_log ASSIGNING <fs_log>.
*      CONCATENATE 'La orden' tab-orden ':' wa-msgid wa-msgnr wa-msgv1 wa-msgv2  INTO vl_msg SEPARATED BY space.
*      <fs_log>-msg = vl_msg.
*    ENDIF.
*  ENDIF.



  REFRESH bcdata_tab.
ENDFORM. "BDC_TRANSACTION
