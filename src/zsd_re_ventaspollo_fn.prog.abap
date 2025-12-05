*&---------------------------------------------------------------------*
*& Include          ZSD_RE_VENTASPOLLO_FN
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

  select v~erdat, v~VBELN, v~KUNNR, k~name1, SORT1, SORT2
    into table @it_ventas
  from vbak as v
  INNER JOIN kna1 AS k ON k~kunnr EQ v~kunnr
  INNER JOIN adrc AS d ON d~addrnumber EQ k~adrnr
  where vkorg in @so_vkorg
     and spart in @so_spart
    and v~erdat in @so_erdat.

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

clear wa_fieldcat.
wa_fieldcat-fieldname = 'ERDAT'.
wa_fieldcat-seltext_m = 'Fecha Creación'.
wa_fieldcat-col_pos = 1.
wa_fieldcat-tabname = 'IT_VENTAS'.
Append wa_fieldcat to gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'VBELN'.
  wa_fieldcat-seltext_m = 'Pedido'.
  wa_fieldcat-col_pos = 2.
  wa_fieldcat-tabname = 'IT_VENTAS'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'KUNNR'.
  wa_fieldcat-seltext_m = 'Cliente'.
  wa_fieldcat-col_pos = 3.
  wa_fieldcat-tabname = 'IT_VENTAS'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-seltext_m = 'Nombre'.
  wa_fieldcat-col_pos = 4.
  wa_fieldcat-tabname = 'IT_VENTAS'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'SORT1'.
  wa_fieldcat-seltext_m = 'Cond. Busq. 1'.
  wa_fieldcat-col_pos = 5.
  wa_fieldcat-tabname = 'IT_VENTAS'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'SORT2'.
  wa_fieldcat-seltext_m = 'Cond. Busq. 2'.
  wa_fieldcat-col_pos = 6.
  wa_fieldcat-tabname = 'IT_VENTAS'.
  APPEND wa_fieldcat TO gt_fieldcat.

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
    t_outtab                          = it_ventas
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

ENDFORM.
