*&---------------------------------------------------------------------*
*& Include          ZCONS_POST_ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CREAR_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM crear_alv .
  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-seltext_m = 'Centro'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'LGORT'.
  wa_fieldcat-seltext_m = 'Almacén'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MBLNR'.
  wa_fieldcat-seltext_m = 'Núm. doc. mat.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MJAHR'.
  wa_fieldcat-seltext_m = 'Ej. doc.  mat.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'ZEILE'.
  wa_fieldcat-seltext_m = 'Pos. doc. mat.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'AUFNR'.
  wa_fieldcat-seltext_m = 'Número de orden'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-no_zero = 'X'.
  wa_fieldcat-seltext_m = 'Número de material'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MAKTX'.
  wa_fieldcat-seltext_l = 'Descripción del material'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'BWART'.
  wa_fieldcat-seltext_m = 'Cla. mov.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'GRUND'.
  wa_fieldcat-seltext_m = 'Movimiento'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'GRTXT'.
  wa_fieldcat-seltext_m = 'Motivo de movimiento'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'SHKZG'.
  wa_fieldcat-seltext_m = 'debe/haber'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'GJAHR'.
  wa_fieldcat-seltext_m = 'Ejercicio'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'POPER'.
  wa_fieldcat-seltext_m = 'Periodo'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'BUKRS'.
  wa_fieldcat-seltext_m = 'Sociedad'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'PRCTR'.
  wa_fieldcat-seltext_m = 'Centro de beneficio'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'SAKTO'.
  wa_fieldcat-seltext_m = 'Núm. cta.may.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'PPRCTR'.
  wa_fieldcat-seltext_m = 'Cen. ben. int.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'LFBNR'.
  wa_fieldcat-seltext_m = 'Núm. doc. doc.de ref.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'CPUTM_MKPF'.
  wa_fieldcat-seltext_m = 'HORA DE ENTRADA'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'BUDAT_MKPF'.
  wa_fieldcat-seltext_m = 'Fec. cont. doc.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'CPUDT_MKPF'.
  wa_fieldcat-seltext_m = 'Día  reg. doc. con.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'DMBTR'.
  wa_fieldcat-seltext_m = 'Imp. mon. local'.
  wa_fieldcat-currency = 'X'.
*  wa_fieldcat-edit = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'WAERS'.
  wa_fieldcat-seltext_m = 'Clave de moneda'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MENGE'.
  wa_fieldcat-seltext_m = 'Cantidad'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MEINS'.
  wa_fieldcat-seltext_m = 'UMB'.
  APPEND wa_fieldcat TO gt_fieldcat.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form Mostrar_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM Mostrar_alv .

  gt_layout-colwidth_optimize = 'X'.
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
      is_layout   = gt_layout
      it_fieldcat = gt_fieldcat
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT     =
*     IT_FILTER   =
*     IS_SEL_HIDE =
*     I_DEFAULT   = 'X'
*     I_SAVE      = ' '
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
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab    = gt_mseg
* EXCEPTIONS
*     PROGRAM_ERROR                     = 1
*     OTHERS      = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
