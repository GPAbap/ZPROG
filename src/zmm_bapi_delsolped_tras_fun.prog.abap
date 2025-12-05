*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_DELSOLPED_TRAS_FUN
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
  FIELD-SYMBOLS <fs_eban> TYPE st_eban.

  SELECT e~banfn, e~bnfpo, e~werks, t~name1, e~bsart, e~pstyp, e~statu
    INTO TABLE @it_eban
    FROM eban AS e
  INNER JOIN t001w AS t
    ON t~werks = e~werks
  WHERE e~werks IN @so_werks
    AND e~pstyp = '7'
    AND e~statu = 'N'
    AND e~bsart = 'NB'.


  LOOP AT it_eban ASSIGNING <fs_eban>.
    <fs_eban>-estatus = icon_yellow_light.
  ENDLOOP.

ENDFORM.

FORM create_fieldcat.
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-seltext_m = 'Centro'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-seltext_m = 'Descripción'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BANFN'.
  wa_fieldcat-seltext_m = 'Sol. Ped.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BNFPO'.
  wa_fieldcat-seltext_m = 'Posición'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BSART'.
  wa_fieldcat-seltext_m = 'Tip. Doc.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'PSTYP'.
  wa_fieldcat-seltext_m = 'Tip. Posición'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'STATU'.
  wa_fieldcat-seltext_m = 'Tip. Tratam.'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ESTATUS'.
  wa_fieldcat-seltext_m = 'Estatus'.
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.


ENDFORM.


FORM show_alv.

  lf_layout-zebra = 'X'.
  lf_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      is_layout                = lf_layout
      it_fieldcat              = gt_fieldcat
      i_callback_pf_status_set = 'ZSTATUS'
      i_callback_user_command  = 'USER_COMMAND'
    TABLES
      t_outtab                 = it_eban
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

ENDFORM.

FORM zstatus USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTATUS'.

ENDFORM.

FORM user_command USING r_ucomm TYPE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN '&DELETE'.
      PERFORM begin_delete_solped.
      rs_selfield-refresh = 'X'.
  ENDCASE.
ENDFORM.

FORM begin_delete_solped.
  FIELD-SYMBOLS <fs_eban> type st_eban.

  DATA solped LIKE bapieban-preq_no.
  DATA: items_to_delete    TYPE STANDARD TABLE OF bapieband,
        wa_items_to_delete LIKE LINE OF items_to_delete.



  DATA: vl_return TYPE STANDARD TABLE OF bapireturn.

  LOOP AT it_eban ASSIGNING <fs_eban>.


    AT NEW banfn.
      CLEAR wa_items_to_delete.
      solped = <fs_eban>-banfn.

      wa_items_to_delete-preq_item = <fs_eban>-bnfpo.
      wa_items_to_delete-delete_ind = 'X'.
      APPEND wa_items_to_delete TO items_to_delete.

    ENDAT.

    AT END OF banfn.
      "ejecucion de la Bapi.
      CALL FUNCTION 'BAPI_REQUISITION_DELETE'
        EXPORTING
          number                      = solped
        TABLES
          requisition_items_to_delete = items_to_delete
          return                      = vl_return.
      READ TABLE vl_return INTO DATA(wa) WITH KEY type = 'E'.
      IF sy-subrc NE 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
           WAIT          = 'X'
        .
        <fs_eban>-estatus = icon_green_light.

      else.
        <fs_eban>-estatus = icon_red_light.
      ENDIF.

  REFRESH items_to_delete.
    ENDAT.


  ENDLOOP.

ENDFORM.
