*&---------------------------------------------------------------------*
*& Include          ZPP_NOTIFICA_FUN
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
  DATA it_STATUS TYPE STANDARD TABLE OF jstat.
  DATA: ord_valida TYPE aufnr,e_sysst LIKE bsvx-sttxt.

  FIELD-SYMBOLS <fs> TYPE st_ordenes.

  SELECT a~aufnr,c~objnr, a~gstrp, a~gsuzp, a~gltrp, a~gluzp,
         a~gstrs, a~gsuzs, a~gltrs, a~gluzs, '@09@' AS estatus
  INTO CORRESPONDING FIELDS OF TABLE @it_ordenes
    FROM afko AS a
  INNER JOIN afpo AS p ON p~aufnr = a~aufnr
  INNER JOIN caufv AS c ON c~aufnr EQ a~aufnr
    WHERE a~aufnr IN @so_aufk
          AND p~dwerk IN @so_werks
          AND a~gstrp IN @so_fecha.


  LOOP AT it_ordenes ASSIGNING <fs>.
    CLEAR: ord_valida.
    CALL FUNCTION 'STATUS_READ'
      EXPORTING
        client           = sy-mandt
        objnr            = <fs>-objnr
        only_active      = 'X'
      TABLES
        status           = it_STATUS
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.

    IF sy-subrc EQ 0.
      READ TABLE it_status INTO DATA(wa_lib) WITH KEY stat = 'I0002'. "LIB.
      IF sy-subrc EQ 0.
        ord_valida = <fs>-aufnr.
      ENDIF.
    ENDIF.

    IF ord_valida IS NOT INITIAL.

      CALL FUNCTION 'AIP9_STATUS_READ'
        EXPORTING
          i_objnr = <fs>-objnr
          i_spras = sy-langu
        IMPORTING
          e_sysst = e_sysst.

      <fs>-istat = e_sysst.
    ENDIF.


  ENDLOOP.

  DELETE it_ordenes WHERE istat IS INITIAL.

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
  wa_fieldcat-fieldname   = 'AUFNR'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Orden'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'ISTAT'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Estatus Orden'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'GSTRP'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Fecha Inicio Ext.'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'GSUZP'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Hora Inicio Ext.'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'GLTRP'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Fecha F Ext.'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'GLUZP'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Hora F Ext.'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'GSTRS'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Fecha I Prog.'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'GSUZS'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Hora I Prog.'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'GLTRS'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Fecha F Prog.'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'GLUZS'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Hora F Prog.'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

  wa_fieldcat-fieldname   = 'ESTATUS'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = ' '. " Descripcion del campo
  wa_fieldcat-outputlen   = 4. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat. "agregamos esta fila a la tabla

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
  DATA lv_pf TYPE slis_formname.

  lv_pf = 'PF_STATUS'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       = ' '
*     I_BUFFER_ACTIVE          = ' '
      i_callback_program       = sy-repid
      i_callback_pf_status_set = lv_pf
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP_OF_PAGE'
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
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = it_ordenes
* EXCEPTIONS
*     PROGRAM_ERROR            = 1
*     OTHERS                   = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTANDARD_FULLSCREEN'.
ENDFORM.

FORM user_command USING ucomm LIKE sy-ucomm
      selfield TYPE slis_selfield.

  CASE ucomm.
    WHEN '&GRABAR'.
      PERFORM notificar_pp.
      selfield-refresh = 'X'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form notificar_pp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM notificar_pp .
  FIELD-SYMBOLS <fs> TYPE st_ordenes.

  DATA: vl_delta_time TYPE  zdecimal3,
        vl_delta_unit LIKE  mcwmit-lzeit.

  DATA flag TYPE sy-subrc.

  LOOP AT it_ordenes ASSIGNING <fs>.

    CALL FUNCTION 'ZL_MC_TIME_DIFFERENCE'
      EXPORTING
        date_from       = <fs>-gstrp
        date_to         = <fs>-gltrp
        time_from       = <fs>-gsuzp
        time_to         = <fs>-gluzp
      IMPORTING
        delta_time      = vl_delta_time
        delta_unit      = vl_delta_unit
      EXCEPTIONS
        from_greater_to = 1
        OTHERS          = 2.

    IF sy-subrc <> 0.
      <fs>-estatus = '@0A@'.
    ELSE.
      vl_delta_time = vl_delta_time / '60.00'. "EN HORAS
      PERFORM aplicar_bapi USING vl_delta_time
                                 <fs>
                          CHANGING flag.
      IF flag NE 0.
        <fs>-estatus = '@08@'.
      ELSE.
        <fs>-estatus = '@0A@'.
      ENDIF.
    ENDIF.


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form aplicar_bapi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> VL_DELTA_TIME
*&      --> <FS>
*&---------------------------------------------------------------------*
FORM aplicar_bapi  USING    p_delta_time type zdecimal3
                            p_fs TYPE st_ordenes
                   CHANGING p_flag TYPE sy-subrc.

  DATA: it_timetickets TYPE STANDARD TABLE OF bapi_pp_timeticket,
        wa_timetickets LIKE LINE OF it_timetickets.

  DATA: it_return TYPE STANDARD TABLE OF bapiret1,
        wa_return LIKE LINE OF it_return.

  DATA it_DETAIL_RETURN TYPE STANDARD TABLE OF bapi_coru_return.
  DATA: vl_valor TYPE p DECIMALS 2, activity TYPE ru_ismng.

  vl_valor = p_delta_time.
  activity = vl_valor.

  wa_timetickets-orderid = p_fs-aufnr.
  wa_timetickets-sequence = '000000'.
  wa_timetickets-operation = '0010'.
  wa_timetickets-fin_conf = 'X'.
  wa_timetickets-clear_res = 'X'.
  wa_timetickets-conf_activity1 =  activity.
  wa_timetickets-conf_activity2 =  activity.
  wa_timetickets-conf_activity3 =  activity.
  APPEND wa_timetickets TO it_timetickets.


  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    EXPORTING
      post_wrong_entries = '0'
    IMPORTING
      return             = wa_return
    TABLES
      timetickets        = it_timetickets
      detail_return      = it_DETAIL_RETURN.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
* IMPORTING
*   RETURN        =
  .

  READ TABLE it_DETAIL_RETURN INTO DATA(wr) WITH KEY type = 'ERU'.
  p_flag = sy-subrc.


ENDFORM.

FORM top_of_page.

  DATA: texto(250).

  CLEAR wa_gs_line.
  REFRESH: gt_header.



*Esto muestra el texto en grande.
  wa_gs_line-typ = 'H'.
  wa_gs_line-info = sy-title.
  APPEND wa_gs_line TO gt_header.
*Esto muestra el texto en pequeño.
  CLEAR wa_gs_line.
  CONCATENATE 'Ejecutado Por:' sy-uname 'a' sy-datum INTO
  texto SEPARATED BY space.
  wa_gs_line-typ = 'S'.
  wa_gs_line-info = texto.
  APPEND wa_gs_line TO gt_header.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header.

ENDFORM. "TOP_OF_PAGE
