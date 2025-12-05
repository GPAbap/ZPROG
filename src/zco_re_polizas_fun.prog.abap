*&---------------------------------------------------------------------*
*& Include          ZCO_RE_POLIZAS_FUN
*&---------------------------------------------------------------------*
FORM get_data.
  DATA vl_values_tab TYPE STANDARD TABLE OF dd07v.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = 'KOART'
      text            = 'X'
    TABLES
      values_tab      = vl_values_tab
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.


  SELECT bseg~bukrs ,t001~butxt AS text_bseg_bukrs, bseg~augbl ,bkpf~blart,
    bseg~augdt , bseg~bschl , tbslt~ltext AS text_bseg_bschl,bseg~koart,
    t003t~ltext AS text_bkpf_blart,
    bseg~shkzg , bseg~mwskz , bseg~txdat_from ,
    CAST( CASE WHEN bseg~shkzg EQ 'S' THEN bseg~dmbtr ELSE bseg~dmbtr * -1 END AS DEC( 13,2 ) )  AS cargo,
    bseg~dmbtr , t001~waers ,t001~waers AS waers001,
    bseg~qsskz , bseg~hwbas , bseg~zuonr , bseg~sgtxt , bseg~vorgn , bseg~kostl,
    bseg~hkont , bseg~kunnr ,
    kna1~name1 AS text_bseg_kunnr,
    bseg~lifnr ,
    lfa1~name1 AS text_bseg_lifnr,
    bseg~zlsch , bseg~nebtr ,
    t001w~name1 AS text_bseg_werks,
    bseg~menge, bseg~meins,
    t006A~msehl AS text_bseg_meins,
    bseg~erfmg , bseg~erfme ,
    ekko~desp AS text_bseg_ebeln,
    ekpo~externalreferenceid AS text_bseg_ebelp,
    bseg~prctr , bseg~rdif2 , bkpf~hwae2,  bkpf~reindat, bseg~belnr ,bkpf~budat,

    v_addr_usr~name_text AS text_bkpf_usnam
    INTO CORRESPONDING FIELDS OF TABLE @it_polizas
             FROM bkpf
             INNER JOIN bseg ON bseg~bukrs EQ bkpf~bukrs AND bseg~belnr EQ bkpf~belnr AND bseg~gjahr EQ bkpf~gjahr
             INNER JOIN t001 ON t001~bukrs EQ bseg~bukrs
             INNER JOIN tbslt ON tbslt~bschl EQ bseg~bschl AND tbslt~umskz EQ bseg~umskz AND tbslt~spras EQ 'S'
             INNER JOIN t003t ON t003t~blart EQ bkpf~blart AND t003t~spras EQ 'S'
             inner join usr21 on usr21~bname eq bkpf~usnam
             inner join v_addr_usr on v_addr_usr~persnumber eq usr21~persnumber and v_addr_usr~addrnumber eq usr21~addrnumber
             LEFT JOIN kna1 ON kna1~kunnr EQ bseg~kunnr
             LEFT JOIN lfa1 ON lfa1~lifnr EQ bseg~lifnr
             LEFT JOIN t001w ON t001w~werks EQ bseg~werks
             LEFT JOIN t006a ON t006a~msehi EQ bseg~meins
             LEFT JOIN ekko ON ekko~ebeln EQ bseg~ebeln
             LEFT JOIN ekpo ON ekpo~ebeln EQ ekko~ebeln AND ekpo~ebelp EQ   bseg~ebelp
             WHERE bseg~bukrs IN @sp$00001
               AND bseg~belnr IN @sp$00002
               AND bseg~gjahr IN @sp$00003
               AND bseg~hkont IN @sp$00004
               AND bseg~kunnr IN @sp$00005
               AND bseg~lifnr IN @sp$00006
               AND bkpf~blart IN @sp$00007
               AND bkpf~budat IN @sp$00008.

  " cargo = REDUCE i( INIT sum = 0 FOR wa_polizas IN it_polizas NEXT sum = sum + wa_polizas-cargo ).

  LOOP AT it_polizas ASSIGNING FIELD-SYMBOL(<wa>).

    LOOP AT vl_values_tab INTO DATA(wa_koart) WHERE domvalue_l EQ <wa>-koart.
      <wa>-text_bseg_koart = wa_koart-ddtext.
    ENDLOOP.

  ENDLOOP.
ENDFORM.

FORM create_fieldcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZCO_ST_POLIZAS'
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.


LOOP AT gt_fieldcat ASSIGNING FIELD-SYMBOL(<wa_fs>).

  CASE <wa_fs>-fieldname.
    WHEN 'CARGO'.
      <wa_fs>-seltext_s = 'Cargo/Abono'.
      <wa_fs>-seltext_m = 'Cargo/Abono'.
      <wa_fs>-seltext_l = 'Cargo/Abono'.

    WHEN OTHERS.
  ENDCASE.
ENDLOOP.

ENDFORM.

FORM show_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
*     IS_LAYOUT   =
      it_fieldcat = gt_fieldcat
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT     =
*     IT_FILTER   =
*     IS_SEL_HIDE =
*     I_DEFAULT   = 'X'
      i_save      = 'A'
*     IS_VARIANT  =
*     IT_EVENTS   =
*     IT_EVENT_EXIT                     =
*     IS_PRINT    =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
*     O_COMMON_HUB                      =
*     IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab    = it_polizas
     EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS      = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
