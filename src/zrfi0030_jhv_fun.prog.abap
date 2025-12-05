*&---------------------------------------------------------------------*
*& Include          ZRFI0030_JHV_FUN
*&---------------------------------------------------------------------*

FORM get_data.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE cab FROM bkpf
  WHERE  bukrs  IN bukrs_p
  AND    gjahr  EQ cpudt_p+3(4)
  AND    cpudt  IN cpudt_p
  AND    blart  EQ 'KZ'.

* Busco documento de provisión ligados a los pagos
  LOOP AT cab.
    MOVE-CORRESPONDING cab TO tab_pago.
    CASE cab-tcode.
    WHEN 'F110'.
* Busca detalle del documento de pago encontrado en el ciclo anterior
      SELECT * FROM reguh
      WHERE laufd = cab-cpudt
      AND   xvorl  = ' '
      AND   zbukr = cab-bukrs
      AND   vblnr = cab-belnr
      AND   dorigin = 'FI-AP'.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING reguh TO tab_pago.
          SELECT * FROM  regup
          WHERE  laufd  = reguh-laufd
          AND    laufi  = reguh-laufi
          AND    xvorl  = ' '
          AND    zbukr  = reguh-zbukr
          AND    lifnr  = reguh-lifnr
*          AND    blart  = 'KZ'
          AND    vblnr  = reguh-vblnr.
            IF sy-subrc = 0.
              MOVE regup-belnr TO tab_pago-belnr_d.
              MOVE regup-xblnr TO tab_pago-xblnr_d.
              MOVE regup-dmbtr TO tab_pago-dmbtr_d.
              MOVE regup-wrbtr TO tab_pago-wrbtr_d.
              APPEND tab_pago.
            ENDIF.
          ENDSELECT.   "regup
        ENDIF.
      ENDSELECT.   "reguh
    WHEN 'FBZ2'.
      SELECT * FROM  bsak
      WHERE bukrs EQ cab-bukrs
      AND   augbl EQ cab-belnr
      AND   gjahr EQ cpudt_p+3(4)
      AND   belnr EQ  cab-belnr.
        IF sy-subrc = 0.
          MOVE:
          bsak-cpudt TO tab_pago-budat,
          bsak-waers TO tab_pago-waers,
          bsak-xblnr TO tab_pago-xblnr,
          bsak-dmbtr TO tab_pago-rwbtr,
          bsak-lifnr TO tab_pago-lifnr.
          SELECT SINGLE * FROM  lfa1
          WHERE  lifnr  = bsak-lifnr.
          MOVE lfa1-name1 TO tab_pago-name1.
          APPEND tab_pago.
        ENDIF.
      ENDSELECT.

    ENDCASE.
  ENDLOOP.

SORT tab_pago.
ENDFORM.


form fieldcat.

clear wa_fieldcat.
* bkpf
  wa_fieldcat-fieldname = 'BUDAT'.
  wa_fieldcat-col_pos = 1.
  wa_fieldcat-seltext_l = 'Fec. Cont.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BELNR'.
  wa_fieldcat-col_pos = 2.
  wa_fieldcat-seltext_l = 'Doc. Pago'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-col_pos = 3.
  wa_fieldcat-seltext_l = 'Acreedor'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-col_pos = 4.
  wa_fieldcat-seltext_l = 'Nombre 1'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'RBETR'.
  wa_fieldcat-col_pos = 5.
  wa_fieldcat-seltext_l = 'Imp. ML.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'RWBTR'.
  wa_fieldcat-col_pos = 6.
  wa_fieldcat-seltext_l = 'Imp. Pagado'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WAERS'.
  wa_fieldcat-col_pos = 7.
  wa_fieldcat-seltext_l = 'Moneda'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BELNR_D'.
  wa_fieldcat-col_pos = 8.
  wa_fieldcat-seltext_l = 'Doc. Cont.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'DMBTR_D'.
  wa_fieldcat-col_pos = 9.
  wa_fieldcat-seltext_l = 'Imp. ML.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WRBTR_D'.
  wa_fieldcat-col_pos = 10.
  wa_fieldcat-seltext_l = 'Imp. MD.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'XBLNR'.
  wa_fieldcat-col_pos = 11.
  wa_fieldcat-seltext_l = 'Doc. Ref.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

ENDFORM.

FORM show_Alv.

lf_layout-zebra = 'X'.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
    I_CALLBACK_PROGRAM                = sy-repid
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
    IS_LAYOUT                         = lf_layout
    IT_FIELDCAT                       = gt_fieldcat
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
*   O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    t_outtab                          = tab_pago
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.


ENDFORM.
