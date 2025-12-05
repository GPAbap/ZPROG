*&---------------------------------------------------------------------*
*& Include          ZSD_DEL_PED_IMPRO_JHV_FUN
*&---------------------------------------------------------------------*

FORM get_data.
  SELECT h~vbeln, h~erdat, h~ernam, h~kunnr, name1, abgru, '@0A@' AS status
    INTO TABLE @it_pedidos
    FROM vbak AS h
  INNER JOIN vbap AS d ON d~vbeln = h~vbeln
  INNER JOIN kna1 AS k ON k~kunnr = h~kunnr
 WHERE h~erdat IN @so_fecha
    AND h~ernam IN @so_uname
   AND d~abgru = '79'
    .

  SORT it_pedidos BY vbeln.

  DELETE ADJACENT DUPLICATES FROM it_pedidos COMPARING vbeln.
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
  DATA ls_layout   TYPE slis_layout_alv.
  ls_layout-zebra = 'X'.
  PERFORM create_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
    TABLES
      t_outtab                 = it_pedidos
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.

FORM set_status USING rt_extab TYPE slis_t_extab..
  SET PF-STATUS 'ZSTANDARD'.
ENDFORM.

FORM user_command USING p_ucomm LIKE sy-ucomm
              p_selfield TYPE slis_selfield.

  DATA cx TYPE REF TO cx_root.
  DATA msg TYPE string.

  CASE p_ucomm.
    WHEN '&SAVE'.
      PERFORM del.
      p_selfield-refresh = 'X'.
  ENDCASE.
ENDFORM.

FORM create_fieldcat.

  DATA wa_fieldcat TYPE slis_fieldcat_alv.
  DATA lv_pos TYPE i.


  lv_pos = lv_pos + 1.
  wa_fieldcat-fieldname = 'VBELN'.
  wa_fieldcat-seltext_s = 'PEDIDO'.
  wa_fieldcat-seltext_m = 'PEDIDO'.
  wa_fieldcat-seltext_l = 'PEDIDO'.
  wa_fieldcat-col_pos = lv_pos.
  APPEND wa_fieldcat TO lt_fieldcat.


  lv_pos = lv_pos + 1.
  wa_fieldcat-fieldname = 'ERDAT'.
  wa_fieldcat-seltext_s = 'CREADO'.
  wa_fieldcat-seltext_m = 'CREADO'.
  wa_fieldcat-seltext_l = 'CREADO'.
  wa_fieldcat-col_pos = lv_pos.
  APPEND wa_fieldcat TO lt_fieldcat.


  lv_pos = lv_pos + 1.
  wa_fieldcat-fieldname = 'ERNAM'.
  wa_fieldcat-seltext_s = 'CREADO POR'.
  wa_fieldcat-seltext_m = 'CREADO POR'.
  wa_fieldcat-seltext_l = 'CREADO POR'.
  wa_fieldcat-col_pos = lv_pos.
  APPEND wa_fieldcat TO lt_fieldcat.

  lv_pos = lv_pos + 1.
  wa_fieldcat-fieldname = 'KUNNR'.
  wa_fieldcat-seltext_s = 'SOLIC.'.
  wa_fieldcat-seltext_m = 'SOLICITANTE'.
  wa_fieldcat-seltext_l = 'SOLICITANTE'.
  wa_fieldcat-col_pos = lv_pos.
  APPEND wa_fieldcat TO lt_fieldcat.

  lv_pos = lv_pos + 1.
  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-seltext_s = 'NOMBRE'.
  wa_fieldcat-seltext_m = 'NOMBRE'.
  wa_fieldcat-seltext_l = 'NOMBRE'.
  wa_fieldcat-col_pos = lv_pos.
  APPEND wa_fieldcat TO lt_fieldcat.

  lv_pos = lv_pos + 1.
  wa_fieldcat-fieldname = 'ABGRU'.
  wa_fieldcat-seltext_s = 'MOTIV.RECH'.
  wa_fieldcat-seltext_m = 'MOTIV.RECH'.
  wa_fieldcat-seltext_l = 'MOTIV.RECH'.
  wa_fieldcat-col_pos = lv_pos.
  APPEND wa_fieldcat TO lt_fieldcat.

  lv_pos = lv_pos + 1.
  wa_fieldcat-fieldname = 'STATUS'.
  wa_fieldcat-seltext_s = 'STATUS'.
  wa_fieldcat-seltext_m = 'STATUS'.
  wa_fieldcat-seltext_l = 'STATUS'.
  wa_fieldcat-col_pos = lv_pos.
  APPEND wa_fieldcat TO lt_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form del
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM del .

  DATA: order_header_in  LIKE  bapisdh1,
        order_header_inx LIKE  bapisdh1x,
        return_mo        TYPE STANDARD TABLE OF bapiret2.


  LOOP AT it_pedidos INTO wa_pedidos.

    order_header_in-sd_doc_cat  = 'C'.                            "Tipo de Documento Comercial
    order_header_inx-updateflag = 'D'.                         " La 'D' nos indica que es de borrado

    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument     = wa_pedidos-vbeln                   "Aqui se inserta el numero del documento a borrar
        order_header_in   = order_header_in
        order_header_inx  = order_header_inx
        behave_when_error = 'P'
      TABLES
        return            = return_mo.


    READ TABLE return_mo INTO DATA(wa_return) WITH KEY type = 'E'.      "Se ven los mensajes de tipo 'E' (Error)
    IF sy-subrc EQ 0.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.   "Si no hay mensajes de error se guardan cambios
      wa_pedidos-status = '@08@'.
      MODIFY it_pedidos FROM wa_pedidos TRANSPORTING status WHERE vbeln = wa_pedidos-vbeln.
    ENDIF.

  ENDLOOP.

ENDFORM.
