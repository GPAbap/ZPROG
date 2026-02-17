*&---------------------------------------------------------------------*
*& Include          ZMM_APP_BASC_MANUAL_FUN
*&---------------------------------------------------------------------*
FORM par_seleccion .
  LOOP AT SCREEN.
    IF screen-group1 = 'AAA'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'P_NOMBRE'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  IF p_nempl IS NOT INITIAL.
    SELECT SINGLE name1
      INTO p_nombre
      FROM zautorizabascula
      WHERE numempleado = p_nempl.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form procesa_informacion
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM procesa_informacion .
  DATA lv_answer.
  CLEAR tab_autorizacion[].

  SELECT SINGLE *
    FROM zuser_bascula
    INTO tab_autorizacion
   WHERE numempleado = p_nempl
     AND clave       = p_clave
     AND planta      = p_planta
     AND zstsreg     = ' '.

  IF sy-subrc <> 0.
*---*---* Si el usuario no es valido, manda un mensaje de validación
    MESSAGE a368 WITH TEXT-f00 TEXT-f03.
  ELSE.

    READ TABLE tab_autorizacion INDEX 1.

    " PERFORM exportv.

* Graba los datos de fecha y hora de inicio de turno y el usuario

    zturnosbascula-numempleado = p_nempl.
    zturnosbascula-fecha_ent   = sy-datum.
    zturnosbascula-hora_ent    = sy-uzeit.
    zturnosbascula-planta      = p_planta.
    "zturnosbascula-terminal    = w_terminal.
    zturnosbascula-werks       = swk-werks.

    MODIFY zturnosbascula.

    IF p_nempl IS NOT INITIAL.
      SELECT SINGLE name1
        INTO p_nombre
        FROM zautorizabascula
        WHERE numempleado = p_nempl.
    ENDIF.

    w_nombre = COND #( WHEN p_nombre IS NOT INITIAL THEN to_upper( p_nombre )
                       ELSE sy-uname ).
    MOVE: p_nempl   TO w_numero,
          sy-datum  TO w_fecha,
          sy-uzeit  TO w_hora,
          sy-uname  TO w_usuario.
*---*---* Si se encuentra autorizado manda a la pantalla de opciones
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = 'Entrada/Salida Báscula'
*       diagnose_object       = space
        text_question  = 'Seleccione la opción correspondiente'
        text_button_1  = 'Entrada Bascula.'
*       icon_button_1  = space
        text_button_2  = 'Salida Bascula.'
*       icon_button_2  = space
        default_button = '1'
*       display_cancel_button = 'X'
*       userdefined_f1_help   = space
*       start_column   = 25
*       start_row      = 6
*       popup_type     =
*       iv_quickinfo_button_1 = space
*       iv_quickinfo_button_2 = space
      IMPORTING
        answer         = lv_answer
*      TABLES
*       parameter      =
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.

  ENDIF.

  IF lv_answer EQ '1'.
    CALL SCREEN '0100'.
  ELSEIF lv_answer EQ '2'.
    CALL SCREEN '0101'.
  ELSE.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.
