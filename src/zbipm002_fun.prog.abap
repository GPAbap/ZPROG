*&---------------------------------------------------------------------*
*& Include zbipm002_fun
*&---------------------------------------------------------------------*

FORM get_data_zccomb.


  SELECT id_forori, no_unidad, fe_autoconsumo, hr_autoconsumo, km_diferencia,ct_autoconsumo,
         cv_unidad, fe_consumo, hr_consumo, km_odometro, lt_consumo,
        tx_vehiculo, fe_transaccion, hr_transaccion,km_transaccion, cd_mercancia
    FROM zccomb

  WHERE ( fe_transaccion IN @so_datum
        OR fe_consumo IN @so_datum
        OR fe_autoconsumo IN @so_datum )
        AND rg_procesado EQ '0'
   INTO TABLE @DATA(it_zccomb).



  IF it_zccomb IS NOT INITIAL.
    SORT it_zccomb BY fe_transaccion hr_transaccion fe_consumo hr_consumo fe_autoconsumo hr_autoconsumo .

    LOOP AT it_zccomb INTO DATA(wa_zccomb) WHERE id_forori EQ 'A'.
      CLEAR wa_consumos.
      wa_consumos-id_tipo_doc = wa_zccomb-id_forori.
      wa_consumos-id_equipo = wa_zccomb-no_unidad.
      wa_consumos-fecha_consumo = wa_zccomb-fe_autoconsumo.
      wa_consumos-hora_consumo = wa_zccomb-hr_autoconsumo.
      wa_consumos-odometro = wa_zccomb-km_diferencia.
      wa_consumos-litros = wa_zccomb-ct_autoconsumo.
      APPEND wa_consumos TO it_consumos.
    ENDLOOP.

    CLEAR wa_zccomb.
    LOOP AT it_zccomb INTO wa_zccomb WHERE id_forori EQ 'S'.
      CLEAR wa_consumos.
      wa_consumos-id_tipo_doc = wa_zccomb-id_forori.
      wa_consumos-id_equipo = wa_zccomb-cv_unidad.
      wa_consumos-fecha_consumo = wa_zccomb-fe_consumo.
      wa_consumos-hora_consumo = wa_zccomb-hr_consumo.
      wa_consumos-odometro = wa_zccomb-km_odometro.
      wa_consumos-litros = wa_zccomb-lt_consumo.
      APPEND wa_consumos TO it_consumos.
    ENDLOOP.

    CLEAR wa_zccomb.
    LOOP AT it_zccomb INTO wa_zccomb WHERE id_forori EQ 'T'.
      CLEAR wa_consumos.
      wa_consumos-id_tipo_doc = wa_zccomb-id_forori.
      wa_consumos-id_equipo = wa_zccomb-tx_vehiculo.
      wa_consumos-fecha_consumo = wa_zccomb-fe_transaccion.
      wa_consumos-hora_consumo = wa_zccomb-hr_transaccion.
      wa_consumos-odometro = wa_zccomb-km_transaccion.
      wa_consumos-litros = wa_zccomb-cd_mercancia.
      APPEND wa_consumos TO it_consumos.
    ENDLOOP.

    SORT it_consumos BY fecha_consumo hora_consumo id_equipo DESCENDING.
  ENDIF.

ENDFORM.

FORM aplicar_autoconsumos.

  DATA: vl_fecha    TYPE char10,
        vl_litros   TYPE char10,
        vl_km       TYPE char15,
        vl_error,
        vl_answer,
        vl_msgerror TYPE string,
        VL_crlf     TYPE c VALUE cl_abap_char_utilities=>newline.

  " cargas autoconsumo
  LOOP AT it_consumos INTO wa_consumos.
    REFRESH bdc_data.
    CLEAR vl_error.

    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = wa_consumos-fecha_consumo
      IMPORTING
        date_external            = vl_fecha
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.

    vl_litros = wa_consumos-litros.
    vl_km = wa_consumos-odometro.

    CONDENSE vl_litros NO-GAPS.
    CONDENSE vl_km NO-GAPS.
    CLEAR vl_error.

    CASE wa_consumos-id_tipo_doc.
      WHEN 'A'.

        PERFORM llena_tabla_bdc_a USING wa_consumos-id_equipo
                                      vl_fecha
                                      wa_consumos-hora_consumo
                                      vl_litros
                                      vl_km
                                  CHANGING vl_error.
      WHEN 'S' OR 'T'.

        PERFORM llena_tabla_bdc_st USING wa_consumos-id_equipo
                                        vl_fecha
                                        wa_consumos-hora_consumo
                                        vl_litros
                                        vl_km
                                    CHANGING vl_error.
        .
    ENDCASE.

    IF vl_error IS INITIAL.
      IF wa_consumos-id_tipo_doc EQ 'S'. "EXTERNO SIN TARJETA
        UPDATE zccomb SET rg_procesado = 'X' WHERE id_forori = 'S' AND cv_unidad = @wa_consumos-id_equipo
             AND fe_consumo = @wa_consumos-fecha_consumo AND hr_consumo = @wa_consumos-hora_consumo
             AND lt_consumo = @wa_consumos-litros AND km_odometro = @wa_consumos-odometro.

      ELSEIF wa_consumos-id_tipo_doc EQ 'T'. "EXTERNO CON TARJETA

        UPDATE zccomb SET rg_procesado = 'X' WHERE id_forori = 'T' AND tx_vehiculo = @wa_consumos-id_equipo
                AND fe_transaccion = @wa_consumos-fecha_consumo AND hr_transaccion = @wa_consumos-hora_consumo
                AND cd_mercancia = @wa_consumos-litros AND km_transaccion = @wa_consumos-odometro.
      ELSEIF wa_consumos-id_tipo_doc EQ 'A'. "AUTOCONSUMOS.
        UPDATE zccomb SET rg_procesado = 'X' WHERE id_forori = 'A' AND no_unidad = @wa_consumos-id_equipo
                 AND fe_autoconsumo = @wa_consumos-fecha_consumo AND hr_autoconsumo = @wa_consumos-hora_consumo
                 AND ct_autoconsumo = @wa_consumos-litros AND km_diferencia = @wa_consumos-odometro.
      ENDIF.
    ELSE.

      READ TABLE l_messtab INTO DATA(wa_error) INDEX 1.
      IF sy-subrc EQ 0.
        CONCATENATE wa_error-msgv2
                    'Unidad Relacionada:' wa_consumos-id_equipo 'de tipo:'  wa_consumos-id_tipo_doc 'con' VL_crlf
                    'fecha:' vl_fecha 'y hora:' wa_consumos-hora_consumo VL_crlf
                   '¿Desea Continuar registrando documentos?' INTO vl_msgerror SEPARATED BY space.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar       = 'Error al registrar documento'
            "diagnose_object       = vl_msgerror
            text_question  = vl_msgerror
            text_button_1  = 'SI'
*           icon_button_1  = space
            text_button_2  = 'NO'
*           icon_button_2  = space
            default_button = '1'
*           display_cancel_button = 'X'
*           userdefined_f1_help   = space
*           start_column   = 25
*           start_row      = 6
*           popup_type     =
*           iv_quickinfo_button_1 = space
*           iv_quickinfo_button_2 = space
          IMPORTING
            answer         = vl_answer
*          TABLES
*           parameter      =
*          EXCEPTIONS
*           text_not_found = 1
*           others         = 2
          .
        IF  vl_answer NE '1'.
          MESSAGE 'Proceso interrumpido por el usuario...' TYPE 'S' DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.

FORM llena_tabla_bdc_a USING p_equipo TYPE zid_vehiculo
                           p_fe_cons TYPE char10
                           p_hr_cons TYPE char10
                           p_litros TYPE char10
                           p_odometro TYPE char15
                       CHANGING p_error .


* Dynpro 0100
  PERFORM bdc_dynpro USING 'SAPLITOBFLTCON' '0100'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'ITOB-EQUNR'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=STRT'.
  PERFORM bdc_field  USING 'ITOB-EQUNR' p_equipo.
  PERFORM bdc_field USING 'T370FLD_STN-STATION_T' 'SA1'.

*        'CAM5039'.
  " PERFORM bdc_field  USING 'T370FLD_STN_T-STATION' 'SA1'.
* Dynpro 0200
  PERFORM bdc_dynpro USING 'SAPLITOBFLTCON' '0200'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'RIFLTCONS-RECDF(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=STRT'.
  PERFORM bdc_field  USING 'G_POST_DATE' p_fe_cons.     "rec-fecha.
  PERFORM bdc_field  USING 'G_POST_TIME' p_hr_cons.     "rec-fecha.
  PERFORM bdc_field  USING 'RIFLTCONS-RECDF(01)' p_litros.     "rec-fecha.
  PERFORM bdc_field  USING 'RIFLTCOUN-RECNT(01)' p_odometro.

  PERFORM bdc_dynpro USING 'SAPLITOBFLTCON' '0200'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'RIFLTCOUN-RECNT(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=SAVE'.

  PERFORM bdc_transaction USING 'IFCU' p_equipo
                          CHANGING p_error.


ENDFORM.                    " LLENA_TABLA_BDC

FORM llena_tabla_bdc_st USING p_equipo TYPE zid_vehiculo
                           p_fe_cons TYPE char10
                           p_hr_cons TYPE char10
                           p_litros TYPE char10
                           p_odometro TYPE char15
                        CHANGING p_error.


* Dynpro 1220
  PERFORM bdc_dynpro USING 'SAPLIMR0' '1220'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'EQUI-EQUNR'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field  USING 'EQUI-EQUNR' p_equipo.
  PERFORM bdc_field  USING 'RIMR0-DFTIM' p_hr_cons.
  PERFORM bdc_field  USING 'RIMR0-DFDAT' p_fe_cons.
  PERFORM bdc_field  USING 'RIMR0-DFRDR' sy-uname.
  PERFORM bdc_field  USING 'BDC_SUBSCR' 'SAPLIMR4                                7502MPOBJ'.


* Dynpro 4210
  PERFORM bdc_dynpro USING 'SAPLIMR0'               '4210'.
  PERFORM bdc_field  USING 'BDC_CURSOR'             'IMRG-POINT(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'             '=ADAL'.
  PERFORM bdc_field  USING 'RIMR0-DFDAT'            p_fe_cons.     "
  PERFORM bdc_field  USING 'RIMR0-DFTIM'            p_hr_cons.     ".
  PERFORM bdc_field  USING 'RIMR0-DFRDR'            sy-uname.     ".

* Dynpro 4210
  PERFORM bdc_dynpro USING 'SAPLIMR0'               '4210'.
  PERFORM bdc_field  USING 'BDC_CURSOR'             'RIMR0-CDIFC(02)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field  USING 'RIMR0-DFDAT'            p_fe_cons.     "
  PERFORM bdc_field  USING 'RIMR0-DFTIM'            p_hr_cons.     ".
  PERFORM bdc_field  USING 'RIMR0-DFRDR'            sy-uname.     ".
  PERFORM bdc_field  USING 'RIMR0-RDCNT(01)'        p_litros.     "rec-fecha.
  PERFORM bdc_field  USING 'RIMR0-RDCNT(02)'        p_odometro     .

* Dynpro 4210
  PERFORM bdc_dynpro USING 'SAPLIMR0'               '4210'.
  PERFORM bdc_field  USING 'BDC_CURSOR'             'RIMR0-FLGSL(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'             '=BU'.
  PERFORM bdc_field  USING 'RIMR0-DFDAT'            p_fe_cons.     "
  PERFORM bdc_field  USING 'RIMR0-DFTIM'            p_hr_cons.     ".
  PERFORM bdc_field  USING 'RIMR0-DFRDR'            sy-uname.     ".

  PERFORM bdc_transaction USING 'IK22' p_equipo
                          CHANGING p_error.


ENDFORM.                    " LLENA_TABLA_BDC


FORM bdc_dynpro USING program dynpro.
  CLEAR bdc_data.
  bdc_data-program = program.
  bdc_data-dynpro  = dynpro.
  bdc_data-dynbegin = 'X'.
  APPEND bdc_data.
ENDFORM.

FORM bdc_field USING program dynpro.
  CLEAR bdc_data.
  bdc_data-fnam = program.
  bdc_data-fval = dynpro.
  APPEND bdc_data.
ENDFORM.



FORM bdc_transaction USING tcode p_equipo
                     CHANGING p_error
.
  DATA ctumode LIKE ctu_params-dismode VALUE 'N'.
  DATA ctu VALUE 'X'.
  DATA cupdate LIKE ctu_params-updmode VALUE 'L'.



* batch input session
  REFRESH messtab.
  REFRESH l_messtab.
  CALL TRANSACTION tcode USING bdc_data
        MODE ctumode
        UPDATE cupdate
        MESSAGES INTO messtab.
  l_subrc = sy-subrc.

  IF messtab[] IS NOT INITIAL.
    CLEAR w_messtab.
    LOOP AT messtab. "WHERE msgtyp = 'E' OR ( msgtyp = 'S' AND msgid = '00' AND msgnr = '344' ).
      IF messtab-msgtyp NE 'S'.
        w_messtab-msgid = messtab-msgid.
        w_messtab-msgnr = messtab-msgnr.
        w_messtab-msgv1 = messtab-msgv1.

        SELECT SINGLE text INTO w_messtab-msgv2
         FROM t100
        WHERE sprsl = 'S' AND arbgb =  messtab-msgid AND msgnr = messtab-msgnr.
        APPEND w_messtab TO l_messtab.
        p_error = abap_true.
      ENDIF.




    ENDLOOP.

  ENDIF.

ENDFORM.                    " BDC_TRANSACTION

FORM show_alv USING p_table TYPE STANDARD TABLE.
  PERFORM create_fieldcat.

  ls_layout-zebra = 'X'.
  ls_layout-coltab_fieldname = 'TCOLOR'.
  "layout-info_fieldname = 'COLOR_LINE'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
*     i_callback_top_of_page   = space
*     i_callback_html_top_of_page = space
*     i_callback_html_end_of_list = space
*     i_structure_name         =
*     i_background_id          =
*     i_grid_title             =
*     i_grid_settings          =
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
    TABLES
      t_outtab                 = p_table
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
      PERFORM aplicar_autoconsumos.
      IF messtab IS NOT INITIAL.
        PERFORM show_alv_error USING l_messtab.
      ENDIF.
  ENDCASE.
ENDFORM.


FORM create_fieldcat.

  DATA wa_fieldcat TYPE slis_fieldcat_alv.
  DATA lv_pos TYPE i.



  wa_fieldcat-fieldname = 'ID_TIPO_DOC'.
  wa_fieldcat-seltext_m = 'TIPO'.
  wa_fieldcat-col_pos = 1.
  APPEND wa_fieldcat TO lt_fieldcat.

  wa_fieldcat-fieldname = 'ID_EQUIPO'.
  wa_fieldcat-seltext_m = 'UNIDAD'.
  wa_fieldcat-col_pos = 2.
  APPEND wa_fieldcat TO lt_fieldcat.

  wa_fieldcat-fieldname = 'FECHA_CONSUMO'.
  wa_fieldcat-seltext_m = 'FEC. CONSUMO'.
  wa_fieldcat-col_pos = 3.
  APPEND wa_fieldcat TO lt_fieldcat.

  wa_fieldcat-fieldname = 'HORA_CONSUMO'.
  wa_fieldcat-seltext_m = 'HR. CONSUMO'.
  wa_fieldcat-col_pos = 4.
  APPEND wa_fieldcat TO lt_fieldcat.

  wa_fieldcat-fieldname = 'ODOMETRO'.
  wa_fieldcat-seltext_m = 'ODOMETRO'.
  wa_fieldcat-col_pos = 5.
  APPEND wa_fieldcat TO lt_fieldcat.

  wa_fieldcat-fieldname = 'LITROS'.
  wa_fieldcat-seltext_m = 'LITROS'.
  wa_fieldcat-col_pos = 6.
  APPEND wa_fieldcat TO lt_fieldcat.



  SORT lt_fieldcat BY col_pos.
ENDFORM.

FORM show_alv_error USING p_table TYPE STANDARD TABLE.

  DATA: lo_table     TYPE REF TO cl_salv_table.

  cl_salv_table=>factory( IMPORTING r_salv_table = lo_table
                          CHANGING t_table = p_table ).

ENDFORM.
