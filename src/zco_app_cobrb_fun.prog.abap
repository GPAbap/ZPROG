*&---------------------------------------------------------------------*
*& Include zco_app_cobrb_fun
*&---------------------------------------------------------------------*

FORM get_aufnr.

  FIELD-SYMBOLS <fs_alv> TYPE st_table_alv.
  DATA it_status TYPE STANDARD TABLE OF jstat.
  data lv_objnr like jsto-objnr.

  SELECT c~aufnr,c~objnr, a~matnr, wemng, '@09@' AS semaforo, 'Preparado...' AS texto,
  lfdnr, perbz,urzuo,dfreg,konty,kokrs,werks,bukrs,c~posnr,rec_objnr1,extnr
    INTO CORRESPONDING FIELDS OF TABLE @it_table_alv
  FROM afko AS k
  INNER JOIN afpo AS a ON a~aufnr = k~aufnr
  INNER JOIN cobrb AS c ON c~aufnr = a~aufnr AND c~posnr = a~posnr
  WHERE a~aufnr IN @so_aufnr
  AND a~wemng LE 0.

  SORT it_table_alv BY aufnr.
  REFRESH it_table_aufnr.
  it_table_aufnr[] = it_table_alv[].
  DELETE ADJACENT DUPLICATES FROM it_table_alv COMPARING aufnr.

  LOOP AT it_table_alv ASSIGNING <fs_alv>.
   lv_objnr = <fs_alv>-objnr.
    CALL FUNCTION 'STATUS_READ'
      EXPORTING
        client           = sy-mandt
        objnr            = lv_objnr
        only_active      = 'X'
      TABLES
        status           = it_status
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.
    IF sy-subrc EQ 0.
      READ TABLE it_status INTO DATA(wa_ctec) WITH KEY stat = 'I0045'. "CTEC
      IF sy-subrc NE 0.
        <fs_alv>-semaforo = icon_red_light.
        <fs_alv>-texto = 'Esta Orden no tiene Cierre Técnico'.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM set_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'AUFNR'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'SEMAFORO'.
  wa_fieldcat-seltext_s = 'Estatus'.
  wa_fieldcat-seltext_l = 'Estatus'.
  wa_fieldcat-seltext_m = 'Estatus'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'TEXTO'.
  wa_fieldcat-seltext_s = 'Observaciones'.
  wa_fieldcat-seltext_l = 'Observaciones'.
  wa_fieldcat-seltext_m = 'Observaciones'.
  APPEND wa_fieldcat TO gt_fieldcat.



ENDFORM.

FORM show_alv.

  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     i_interface_check        = space
*     i_bypassing_buffer       = space
*     i_buffer_active          = space
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'ZSTATUS'
      i_callback_user_command  = 'ZUSER_COMMAND'
*     i_callback_top_of_page   = space
*     i_callback_html_top_of_page = space
*     i_callback_html_end_of_list = space
*     i_structure_name         =
*     i_background_id          =
*     i_grid_title             =
*     i_grid_settings          =
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat
*     it_excluding             =
*     it_special_groups        =
*     it_sort                  =
*     it_filter                =
*     is_sel_hide              =
*     i_default                = 'X'
*     i_save                   = space
*     is_variant               =
*     it_events                =
*     it_event_exit            =
*     is_print                 =
*     is_reprep_id             =
*     i_screen_start_column    = 0
*     i_screen_start_line      = 0
*     i_screen_end_column      = 0
*     i_screen_end_line        = 0
*     i_html_height_top        = 0
*     i_html_height_end        = 0
*     it_alv_graphics          =
*     it_hyperlink             =
*     it_add_fieldcat          =
*     it_except_qinfo          =
*     ir_salv_fullscreen_adapter  =
*     o_previous_sral_handler  =
*      IMPORTING
*     e_exit_caused_by_caller  =
*     es_exit_caused_by_user   =
    TABLES
      t_outtab                 = it_table_alv
*      EXCEPTIONS
*     program_error            = 1
*     others                   = 2
    .
  IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.

FORM zstatus USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTANDARD_FULLSCREEN'.
ENDFORM.

FORM zuser_command USING ucomm LIKE sy-ucomm
      selfield TYPE slis_selfield.

  DATA lv_answer.
  CASE ucomm.
    WHEN '&ZEXCEL'.
*      PERFORM exportar_excel USING  'zst_formulacionh'
*                                    'zst_formulacionp'
*                                    'IND'
*                                    'STLNR'.
    WHEN '&AJUSTAR'.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'Ajuste de Normas de Liquidación'
          text_question  = '¿Esta Seguro(a) de continuar?'
          text_button_1  = 'Estoy Seguro'
          icon_button_1  = 'ICON_CHECKED'
          text_button_2  = 'Cancel'
          icon_button_2  = 'ICON_CANCEL'
          default_button = '2'
          display_cancel_button = ' '
*         userdefined_f1_help   = space
*         start_column   = 25
*         start_row      = 6
*         popup_type     =
*         iv_quickinfo_button_1 = space
*         iv_quickinfo_button_2 = space
        IMPORTING
          answer         = lv_answer
*      TABLES
*         parameter      =
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF lv_answer EQ '1'.
        PERFORM ajuste_norma.
        selfield-refresh = 'X'.
      ELSE.
         CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = 'Información'
        TXT1  = 'Has Cancelado la Operación.'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
      ENDIF.
  ENDCASE.


ENDFORM.
FORM ajuste_norma.

  DATA st_zcobrb TYPE zco_st_cobrb.
  DATA it_zcobrb TYPE STANDARD TABLE OF zco_st_cobrb.
  DATA vl_objnr TYPE string.
  DATA lv_subrc TYPE sy-subrc.
  CREATE OBJECT cl_norma.

  LOOP AT it_table_alv ASSIGNING <fs_alv> WHERE semaforo = icon_yellow_light.

    LOOP AT it_table_aufnr ASSIGNING <fs_cobrb> WHERE aufnr = <fs_alv>-aufnr.
      IF  <fs_cobrb>-wemng LE 0.
        CONCATENATE 'OR' <fs_cobrb>-aufnr INTO vl_objnr.
*        st_zcobrb-objnr = vl_objnr.
*        st_zcobrb-aufnr = <fs_cobrb>-aufnr.
*        st_zcobrb-posnr = <fs_cobrb>-posnr.
*        st_zcobrb-aqzif = 0.
*        st_zcobrb-lfdnr = <fs_cobrb>-lfdnr.
        MOVE-CORRESPONDING <fs_cobrb> TO st_zcobrb.
        st_zcobrb-objnr = vl_objnr.
        APPEND st_zcobrb TO it_zcobrb.
      ENDIF.

    ENDLOOP.
    UNASSIGN <fs_cobrb>.
    <fs_alv>-zcobrb = it_zcobrb.
    REFRESH it_zcobrb.
    CLEAR st_zcobrb.
    CALL METHOD cl_norma->ajusta_norma
      EXPORTING
        i_aufnr = <fs_alv>-aufnr
        i_tabla = <fs_alv>-zcobrb
      RECEIVING
        r_subrc = lv_subrc.

    CASE lv_subrc.
      WHEN 0.
        <fs_alv>-semaforo = icon_green_light.
        <fs_alv>-texto = 'Norma Ajustada correctamente'.
      WHEN 1.
        <fs_alv>-semaforo = icon_red_light.
        <fs_alv>-texto = 'Error durante ejecución de K_SRULE'.
      WHEN 4.
        <fs_alv>-semaforo = icon_red_light.
        <fs_alv>-texto = 'No hubo necesidad de Ajustar Norma para esta Orden'.
    ENDCASE.

  ENDLOOP.






ENDFORM.
