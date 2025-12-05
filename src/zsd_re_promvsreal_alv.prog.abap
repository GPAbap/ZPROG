*&---------------------------------------------------------------------*
*& Include          ZSD_RE_PROMVSREAL_ALV
*&---------------------------------------------------------------------*

FORM create_fieldcat .
  DATA wa_fieldcat TYPE slis_fieldcat_alv.
  REFRESH gt_fieldcat.

  wa_fieldcat-fieldname = 'ERDAT'.
  wa_fieldcat-seltext_s = 'Fec. Pedido'.
  wa_fieldcat-seltext_l = 'Fec. Pedido'.
  wa_fieldcat-seltext_m = 'Fec. Pedido'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VBELN'.
  wa_fieldcat-seltext_s = 'Ped. Venta'.
  wa_fieldcat-seltext_l = 'Ped. Venta'.
  wa_fieldcat-seltext_m = 'Ped. Venta'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-seltext_s = 'Centro'.
  wa_fieldcat-seltext_l = 'Centro'.
  wa_fieldcat-seltext_m = 'Centro'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME1W'.
  wa_fieldcat-seltext_s = 'Nombre'.
  wa_fieldcat-seltext_l = 'Nombre'.
  wa_fieldcat-seltext_m = 'Nombre'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'PARVADA'.
  wa_fieldcat-seltext_s = 'Referencia'.
  wa_fieldcat-seltext_l = 'Referencia'.
  wa_fieldcat-seltext_m = 'Referencia'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ID'.
  wa_fieldcat-seltext_s = 'ID'.
  wa_fieldcat-seltext_l = 'ID'.
  wa_fieldcat-seltext_m = 'ID'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'POSNR'.
  wa_fieldcat-seltext_s = 'Posicion Ped.'.
  wa_fieldcat-seltext_l = 'Posicion Ped.'.
  wa_fieldcat-seltext_m = 'Posicion Ped.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'CHARG'.
  wa_fieldcat-seltext_s = 'Lote'.
  wa_fieldcat-seltext_l = 'Lote'.
  wa_fieldcat-seltext_m = 'Lote'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'CASETA'.
  wa_fieldcat-seltext_s = 'Caseta'.
  wa_fieldcat-seltext_l = 'Caseta'.
  wa_fieldcat-seltext_m = 'Caseta'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BSTKD'.
  wa_fieldcat-seltext_s = 'Remisión'.
  wa_fieldcat-seltext_l = 'Remisión'.
  wa_fieldcat-seltext_m = 'Remisión'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'LOTE'.
  wa_fieldcat-seltext_s = 'Lote'.
  wa_fieldcat-seltext_l = 'Lote'.
  wa_fieldcat-seltext_m = 'Lote'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'CANTIDAD'.
  wa_fieldcat-seltext_s = 'Cantidad'.
  wa_fieldcat-seltext_l = 'Cantidad'.
  wa_fieldcat-seltext_m = 'Cantidad'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'PRODUCTO'.
  wa_fieldcat-seltext_s = 'Producto'.
  wa_fieldcat-seltext_l = 'Producto'.
  wa_fieldcat-seltext_m = 'Producto'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.
*

  wa_fieldcat-fieldname = 'KWMENG'.
  wa_fieldcat-seltext_s = 'Cant. Pedido'.
  wa_fieldcat-seltext_l = 'Cant. Pedido'.
  wa_fieldcat-seltext_m = 'Cant. Pedido'.
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NTGEW'.
  wa_fieldcat-seltext_s = 'Kgs. Pedido'.
  wa_fieldcat-seltext_l = 'Kgs. Pedido'.
  wa_fieldcat-seltext_m = 'Kgs. Pedido'.
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VKORG'.
  wa_fieldcat-seltext_s = 'Org. Ventas'.
  wa_fieldcat-seltext_l = 'Org. Ventas'.
  wa_fieldcat-seltext_m = 'Org. Ventas'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VKBUR'.
  wa_fieldcat-seltext_s = 'Ofic. Ventas'.
  wa_fieldcat-seltext_l = 'Ofic. Ventas'.
  wa_fieldcat-seltext_m = 'Ofic. Ventas'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VTWEG'.
  wa_fieldcat-seltext_s = 'Canal Dist.'.
  wa_fieldcat-seltext_l = 'Canal Dist.'.
  wa_fieldcat-seltext_m = 'Canal Dist'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'SPART'.
  wa_fieldcat-seltext_s = 'Sector'.
  wa_fieldcat-seltext_l = 'Sector'.
  wa_fieldcat-seltext_m = 'Sector'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ERNAM'.
  wa_fieldcat-seltext_s = 'Usuario Ped.'.
  wa_fieldcat-seltext_l = 'Usuario Ped.'.
  wa_fieldcat-seltext_m = 'Usuario Ped.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'NETWR'.
  wa_fieldcat-seltext_s = 'Valor Neto'.
  wa_fieldcat-seltext_l = 'Valor Neto'.
  wa_fieldcat-seltext_m = 'Valor Neto'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'KUNNR'.
  wa_fieldcat-seltext_s = 'Solicitante'.
  wa_fieldcat-seltext_l = 'Solicitante'.
  wa_fieldcat-seltext_m = 'Solicitante'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'STCD1'.
  wa_fieldcat-seltext_s = 'R.F.C.'.
  wa_fieldcat-seltext_l = 'R.F.C.'.
  wa_fieldcat-seltext_m = 'R.F.C.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-seltext_s = 'Nombre'.
  wa_fieldcat-seltext_l = 'Nombre'.
  wa_fieldcat-seltext_m = 'Nombre'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  "entrega
  wa_fieldcat-fieldname = 'ERDATE'.
  wa_fieldcat-seltext_s = 'Fec. Entrega'.
  wa_fieldcat-seltext_l = 'Fec. Entrega'.
  wa_fieldcat-seltext_m = 'Fec. Entrega'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VBELNE'.
  wa_fieldcat-seltext_s = 'Num. Entrega'.
  wa_fieldcat-seltext_l = 'Num. Entrega'.
  wa_fieldcat-seltext_m = 'Num. Entrega'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'LFIMG'.
  wa_fieldcat-seltext_s = 'Cant. Entrega'.
  wa_fieldcat-seltext_l = 'Cant. Entrega'.
  wa_fieldcat-seltext_m = 'Cant. Entrega'.
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NTGEWE'.
  wa_fieldcat-seltext_s = 'Kgs. Entrega'.
  wa_fieldcat-seltext_l = 'Kgs. Entrega'.
  wa_fieldcat-seltext_m = 'Kgs. Entrega'.
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  "factura
  wa_fieldcat-fieldname = 'FKDAT'.
  wa_fieldcat-seltext_s = 'Fec. Factura'.
  wa_fieldcat-seltext_l = 'Fec. Factura'.
  wa_fieldcat-seltext_m = 'Fec. Factura'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VBELNF'.
  wa_fieldcat-seltext_s = 'Doc. Factura'.
  wa_fieldcat-seltext_l = 'Doc. Factura'.
  wa_fieldcat-seltext_m = 'Doc. Factura'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'POSNRF'.
  wa_fieldcat-seltext_s = 'Posicion Fact.'.
  wa_fieldcat-seltext_l = 'Posicion Fact.'.
  wa_fieldcat-seltext_m = 'Posicion Fact.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'FKIMG'.
  wa_fieldcat-seltext_s = 'Cant. Fac. Real'.
  wa_fieldcat-seltext_l = 'Cant. Fac. Real'.
  wa_fieldcat-seltext_m = 'Cant. Fac. Real'.
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VRKME'.
  wa_fieldcat-seltext_s = 'U.M.V.'.
  wa_fieldcat-seltext_l = 'U.M.V.'.
  wa_fieldcat-seltext_m = 'U.M.V.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NTGEWF'.
  wa_fieldcat-seltext_s = 'Kgs. Fac. Real'.
  wa_fieldcat-seltext_l = 'Kgs. Fac. Real'.
  wa_fieldcat-seltext_m = 'Kgs. Fac. Real'.
  wa_fieldcat-do_sum = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'ERNAMF'.
  wa_fieldcat-seltext_s = 'Usuario. Fact.'.
  wa_fieldcat-seltext_l = 'Usuario. Fact.'.
  wa_fieldcat-seltext_m = 'Usuario. Fact.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BZIRK'.
  wa_fieldcat-seltext_s = 'Cve. Zona'.
  wa_fieldcat-seltext_l = 'Cve. Zona'.
  wa_fieldcat-seltext_m = 'Cve. Zona'.
  wa_fieldcat-no_out = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BZTXT'.
  wa_fieldcat-seltext_s = 'Zona de Ventas'.
  wa_fieldcat-seltext_l = 'Zona de Ventas'.
  wa_fieldcat-seltext_m = 'Zona de Ventas'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-seltext_s = 'Material'.
  wa_fieldcat-seltext_l = 'Material'.
  wa_fieldcat-seltext_m = 'Material'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'MAKTX'.
  wa_fieldcat-seltext_s = 'Descripcion'.
  wa_fieldcat-seltext_l = 'Descripcion'.
  wa_fieldcat-seltext_m = 'Descripcion'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.



  wa_fieldcat-fieldname = 'NETWRF'.
  wa_fieldcat-seltext_s = 'Valor Neto Fac.'.
  wa_fieldcat-seltext_l = 'Valor Neto Fac.'.
  wa_fieldcat-seltext_m = 'Valor Neto Fac.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'DIFPEDFACT'.
  wa_fieldcat-seltext_s = 'Dif. Ped-Fact'.
  wa_fieldcat-seltext_l = 'Dif. Ped-Fact'.
  wa_fieldcat-seltext_m = 'Dif. Ped-Fact'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.


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

  lf_layout-zebra               = 'X'.   " Streifenmuster
  lf_layout-colwidth_optimize = 'X'.
  CLEAR wa_sort.
  wa_sort-spos = 1.
  wa_sort-fieldname = 'WERKS'.
  wa_sort-GROUP = '*'.     "-->ADD THIS
  wa_sort-subtot = 'X'.
  APPEND wa_sort TO t_sort.

  CLEAR wa_sort.
  wa_sort-spos = 1.
  wa_sort-fieldname = 'MATNR'.
  wa_sort-GROUP = '*'.     "-->ADD THIS
  wa_sort-subtot = 'X'.
  APPEND wa_sort TO t_sort.

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
    it_fieldcat        = gt_fieldcat
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
    it_sort            = t_sort
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
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
  TABLES
    t_outtab           = it_datos
*   EXCEPTIONS
*     PROGRAM_ERROR      = 1
*     OTHERS             = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
