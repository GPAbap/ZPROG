*&---------------------------------------------------------------------*
*& Include zpp_app_notifica_fun
*&---------------------------------------------------------------------*

FORM get_data.

  FIELD-SYMBOLS: <fs_linea> TYPE st_ordenes.
  DATA it_STATUS TYPE STANDARD TABLE OF jstat.
  DATA: ord_valida TYPE aufnr,e_sysst LIKE bsvx-sttxt.

  SELECT a1~aufnr, a1~werks, c~objnr,
  CASE WHEN a3~vornr IS NULL THEN '0010' ELSE a3~vornr END AS vornr
  INTO TABLE @DATA(it_temp)
  FROM aufk AS a1
  INNER JOIN afko AS a2 ON a2~aufnr EQ a1~aufnr
  INNER JOIN caufv AS c ON c~aufnr EQ a1~aufnr
  LEFT JOIN afru AS a3 ON a3~aufnr EQ a1~aufnr AND a3~rmzhl EQ '00000001'
  WHERE a1~aufnr IN @so_aufnr
  AND a1~werks IN @so_werks
  AND a2~gstrp IN @so_gstrp
  .

  LOOP AT it_temp INTO DATA(wa_temp).

    CLEAR ord_valida.

    CALL FUNCTION 'STATUS_READ'
      EXPORTING
        client           = sy-mandt
        objnr            = wa_temp-objnr
        only_active      = 'X'
      TABLES
        status           = it_STATUS
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.
    IF sy-subrc EQ 0.

      READ TABLE it_status INTO DATA(wa_noti) WITH KEY stat = 'I0009'. "NOTI Excl.
      IF sy-subrc NE 0.
        READ TABLE it_status INTO DATA(wa_cerr) WITH KEY stat = 'I0046'. "CERR Excl.
        IF sy-subrc NE 0.
          ord_valida = wa_temp-aufnr.
        ENDIF.
      ENDIF.


*      READ TABLE it_status INTO DATA(wa_notp) WITH KEY stat = 'I0010'. "NOTP
*      IF sy-subrc EQ 0.
*        READ TABLE it_status INTO DATA(wa_ctec) WITH KEY stat = 'I0045'. "CTEC
*        IF sy-subrc EQ 0.
*          ord_valida = wa_temp-aufnr.
*        ELSE.
*          READ TABLE it_status INTO DATA(wa_lib) WITH KEY stat = 'I0002'. "LIB.
*          IF sy-subrc EQ 0.
*            ord_valida = wa_temp-aufnr.
*          ENDIF.
*        ENDIF.
*        "Si no es NOTP
*       else.
*        READ TABLE it_status INTO DATA(wa_ctec2) WITH KEY stat = 'I0045'. "CTEC
*        IF sy-subrc EQ 0.
*          READ TABLE it_status INTO DATA(wa_noti) WITH KEY stat = 'I0009'. "NOTI Excl.
*          IF sy-subrc ne 0.
*            ord_valida = wa_temp-aufnr.
*          ENDIF.
*        ELSE.
*          READ TABLE it_status INTO DATA(wa_lib2) WITH KEY stat = 'I0002'. "LIB.
*          IF sy-subrc EQ 0.
*
*            ord_valida = wa_temp-aufnr.
*          ENDIF.
*
*        ENDIF.
*
*      ENDIF.


      IF ord_valida IS NOT INITIAL.

        CALL FUNCTION 'AIP9_STATUS_READ'
          EXPORTING
            i_objnr = wa_temp-objnr
            i_spras = sy-langu
          IMPORTING
            e_sysst = e_sysst
*           E_ANWST =
          .


        APPEND INITIAL LINE TO it_ordenes ASSIGNING <fs_linea>.
        <fs_linea>-aufnr = ord_valida.
        <fs_linea>-vornr = wa_temp-vornr.
        <fs_linea>-werks = wa_temp-werks.
        <fs_linea>-istat = e_sysst.
        <fs_linea>-status = icon_yellow_light.

        UNASSIGN <fs_linea>.


      ENDIF.

    ENDIF.

  ENDLOOP.


ENDFORM.

FORM create_fieldcat.

  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'AUFNR'.
  wa_fieldcat-seltext_l = 'Ord. Prod.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-seltext_l = 'Centro'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VORNR'.
  wa_fieldcat-seltext_l = 'Operación'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ISTAT'.
  wa_fieldcat-seltext_l = 'Texto Estatus'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'STATUS'.
  wa_fieldcat-seltext_l = 'Estatus'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

ENDFORM.

FORM show_alv.

  lf_layout-zebra = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       = ' '
*     I_BUFFER_ACTIVE          = ' '
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE   = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME         =
*     I_BACKGROUND_ID          = ' '
*     I_GRID_TITLE             =
*     I_GRID_SETTINGS          =
      is_layout                = lf_layout
      it_fieldcat              = gt_fieldcat
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
*     IT_SORT                  =
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     I_DEFAULT                = 'X'
*     I_SAVE                   = ' '
*     IS_VARIANT               =
*     IT_EVENTS                =
*     IT_EVENT_EXIT            =
*     IS_PRINT                 =
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*     I_HTML_HEIGHT_TOP        = 0
*     I_HTML_HEIGHT_END        = 0
*     IT_ALV_GRAPHICS          =
*     IT_HYPERLINK             =
*     IT_ADD_FIELDCAT          =
*     IT_EXCEPT_QINFO          =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER  =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = it_ordenes
*   EXCEPTIONS
*     PROGRAM_ERROR            = 1
*     OTHERS                   = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM pf_status USING rt_extab TYPE slis_t_extab.
  "APPEND '' TO RT_EXTAB.
  SET PF-STATUS 'ZSTANDAR' EXCLUDING rt_extab.

ENDFORM.

FORM user_command  USING r_ucomm LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.

  IF r_ucomm EQ '&STATUS'.

    PERFORM change_status.
    "MESSAGE 'Please highlight the rows to be deleted!' TYPE 'S'.
    rs_selfield-refresh = 'X'.

  ENDIF.
ENDFORM.

FORM change_status.

  DATA ref1 TYPE REF TO cl_gui_alv_grid.

  DATA: timetickets TYPE STANDARD TABLE OF bapi_pp_timeticket,
        wa_tickets  LIKE LINE OF timetickets.

  DATA details_return TYPE STANDARD TABLE OF bapi_coru_return.


  FIELD-SYMBOLS <fs_ordenes> TYPE st_ordenes.
  LOOP AT it_ordenes ASSIGNING <fs_ordenes>.
    CLEAR wa_tickets.
    REFRESH timetickets.

    wa_tickets-orderid = <fs_ordenes>-aufnr.
    wa_tickets-operation = <fs_ordenes>-vornr.
    wa_tickets-fin_conf = 'X'.
    wa_tickets-clear_res = 'X'.
    wa_tickets-postg_date = sy-datum.

    APPEND wa_tickets TO timetickets.

    CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
*         EXPORTING
*           POST_WRONG_ENTRIES             = '0'
*           TESTRUN                        =
*           CALL_ON_INBOUND_QUEUE          = ' '
*         IMPORTING
*           RETURN                         =
      TABLES
        timetickets   = timetickets
*       GOODSMOVEMENTS                 =
*       LINK_CONF_GOODSMOV             =
*       CHARACTERISTICS_WIPBATCH       =
*       LINK_CONF_CHAR_WIPBATCH        =
        detail_return = details_return
*       CHARACTERISTICS_BATCH          =
*       LINK_GM_CHAR_BATCH             =
      .

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'
*   IMPORTING
*       RETURN        =
      .



    IF details_return IS NOT INITIAL.
      READ TABLE details_return INTO DATA(wa_return) WITH KEY type = 'E'.
      IF sy-subrc EQ 0.
        <fs_ordenes>-status = icon_red_light.
      ELSE.
        <fs_ordenes>-status = icon_green_light.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
