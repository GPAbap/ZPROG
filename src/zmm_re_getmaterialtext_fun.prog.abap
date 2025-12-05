*&---------------------------------------------------------------------*
*& Include          ZMM_RE_GETMATERIALTEXT_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA it_lines TYPE STANDARD TABLE OF tline.
  DATA lv_name LIKE thead-tdname.

  SELECT m~matnr maktx
    INTO TABLE it_materiales
  FROM mara AS m
INNER JOIN makt AS t ON t~matnr = m~matnr AND t~spras EQ 'S'
    WHERE m~matnr IN so_matnr.




  IF sy-subrc EQ 0.
    SORT it_materiales BY matnr.

    LOOP AT it_materiales INTO DATA(wa).

      lv_name = wa-matnr.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = 'BEST'
          language                = sy-langu
          name                    = lv_name
          object                  = 'MATERIAL'
*     IMPORTING
*         HEADER                  = header
*         OLD_LINE_COUNTER        =
        TABLES
          lines                   = it_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.

      IF sy-subrc EQ 0.
        LOOP AT it_lines into data(wt).
          wa-texto = wt-tdline.
        ENDLOOP.

        MODIFY it_materiales FROM wa TRANSPORTING texto WHERE matnr = wa-matnr.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fieldcat .

  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-seltext_m = 'Material'.
  wa_fieldcat-col_pos = 1.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'MAKTX'.
  wa_fieldcat-seltext_m = 'Descr. Material'.
  wa_fieldcat-col_pos = 2.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'TEXTO'.
  wa_fieldcat-seltext_m = 'Texto Material'.
  wa_fieldcat-col_pos = 3.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .

  lf_layout-zebra = 'X'.
  lf_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER = ' '
*     I_BUFFER_ACTIVE    = ' '
      i_callback_program = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME   =
*     I_BACKGROUND_ID    = ' '
*     I_GRID_TITLE       =
*     I_GRID_SETTINGS    =
      is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat[]
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
*     IT_SORT            =
*     IT_FILTER          =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
*     I_SAVE             = ' '
*     IS_VARIANT         =
*     IT_EVENTS          =
*     IT_EVENT_EXIT      =
*     IS_PRINT           =
*     IS_REPREP_ID       =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE  = 0
*     I_HTML_HEIGHT_TOP  = 0
*     I_HTML_HEIGHT_END  = 0
*     IT_ALV_GRAPHICS    =
*     IT_HYPERLINK       =
*     IT_ADD_FIELDCAT    =
*     IT_EXCEPT_QINFO    =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab           = it_materiales
* EXCEPTIONS
*     PROGRAM_ERROR      = 1
*     OTHERS             = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
