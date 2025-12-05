*&---------------------------------------------------------------------*
*& Include zco_cobrb_eng_fun
*&---------------------------------------------------------------------*

FORM get_data.

  SELECT c~aufnr,c~objnr, a~matnr, wemng, '@09@' AS semaforo, 'Preparado...' AS texto,
         c~aqzif, lfdnr, perbz,urzuo,dfreg,konty,kokrs,werks,bukrs,c~posnr,rec_objnr1,extnr
INTO CORRESPONDING FIELDS OF TABLE @it_table_alv
FROM afko AS k
INNER JOIN afpo AS a ON a~aufnr = k~aufnr
INNER JOIN cobrb AS c ON c~aufnr = a~aufnr AND c~posnr = a~posnr
WHERE a~aufnr IN @so_aufnr.
  SORT it_table_alv BY aufnr.

  REFRESH it_table_aufnr.
  it_table_aufnr[] = it_table_alv[].
  DELETE ADJACENT DUPLICATES FROM it_table_alv COMPARING aufnr.


  SELECT mandt aufnr posnr matnr aqzif aqzif1 aqzif2 aqzif3 mes_exec
      INTO TABLE it_aufnr
      FROM zco_tt_histcobrb
      WHERE aufnr IN so_aufnr.



ENDFORM.

FORM prepare_data.
  DATA lv_mes_actual(2) TYPE c.

  LOOP AT it_table_alv ASSIGNING <fs_alvh>.
    CLEAR wa_aufnr.
    READ TABLE it_aufnr INTO wa_aufnr WITH KEY aufnr = <fs_alvh>-aufnr.
    IF sy-subrc NE 0.   "sino existe la orden en el historico, la agrega
      CLEAR wa_aufnr.
      LOOP AT it_table_aufnr INTO DATA(wa_hist) WHERE aufnr = <fs_alvh>-aufnr.
        wa_aufnr-aufnr = wa_hist-aufnr.
        wa_aufnr-posnr = wa_hist-posnr.
        wa_aufnr-matnr = wa_hist-matnr.
        wa_aufnr-aqzif = wa_hist-aqzif.
        wa_aufnr-mes_exec = '00'.
        APPEND wa_aufnr TO it_aufnr.
        INSERT zco_tt_histcobrb FROM wa_aufnr.
        CLEAR wa_aufnr.
      ENDLOOP.
    ENDIF.




    READ TABLE it_aufnr INTO wa_aufnr WITH KEY aufnr = <fs_alvh>-aufnr.
    lv_mes_actual = sy-datum+4(2).
    IF WA_aufnr-mes_exec EQ lv_mes_actual.
       <fs_alvh>-semaforo = icon_red_light.
      <fs_alvh>-texto = 'Esta Orden ya se Ejecuto en este mes'.
       CONTINUE.
    else.
      IF wa_aufnr-aqzif1 EQ 0. "sino tiene valor aqzif1 entonces es el mes 1

        PERFORM ajuste_norma USING <fs_alvh>-aufnr '1' lv_mes_actual.

      ELSEIF wa_aufnr-aqzif2 EQ 0. "sino tiene valor aqzif1 entonces es el mes 2
        PERFORM ajuste_norma USING <fs_alvh>-aufnr '2' lv_mes_actual.
      ELSEIF wa_aufnr-aqzif3 EQ 0. "sino tiene valor aqzif1 entonces es el mes final
        PERFORM ajuste_norma USING <fs_alvh>-aufnr '3' lv_mes_actual.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.


FORM ajuste_norma USING p_aufnr TYPE aufnr
                        p_periodo TYPE c
                        p_mes_actual type c.

  DATA st_zcobrb TYPE zco_st_cobrb.
  DATA it_zcobrb TYPE STANDARD TABLE OF zco_st_cobrb.
  DATA vl_objnr TYPE string.
  DATA lv_subrc TYPE sy-subrc.
  CREATE OBJECT cl_norma.

  LOOP AT it_table_aufnr ASSIGNING <fs_cobrb> WHERE aufnr = p_aufnr.

    CONCATENATE 'OR' <fs_cobrb>-aufnr INTO vl_objnr.
    MOVE-CORRESPONDING <fs_cobrb> TO st_zcobrb.

    IF p_periodo EQ '1'.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      IF <fs_cobrb>-wemng EQ 0.
        CONCATENATE 'OR' <fs_cobrb>-aufnr INTO vl_objnr.
        MOVE-CORRESPONDING <fs_cobrb> TO st_zcobrb.
        st_zcobrb-objnr = vl_objnr.
        st_zcobrb-aqzif = 0.
      ENDIF.

      IF st_zcobrb-aqzif EQ 0.
        UPDATE zco_tt_histcobrb SET aqzif1 = -1 mes_exec = p_mes_actual datum = sy-datum
                                           WHERE aufnr = p_aufnr
                                           AND matnr = <fs_cobrb>-matnr
                                           AND posnr = <fs_cobrb>-posnr.
      ELSE.
        UPDATE zco_tt_histcobrb SET aqzif1 = st_zcobrb-aqzif mes_exec = p_mes_actual datum = sy-datum
                                             WHERE aufnr = p_aufnr
                                             AND matnr = <fs_cobrb>-matnr
                                             AND posnr = <fs_cobrb>-posnr.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSEIF p_periodo EQ '2'.

      READ TABLE it_aufnr INTO DATA(wa_aqzif2) WITH KEY aufnr = p_aufnr matnr = <fs_cobrb>-matnr posnr = <fs_cobrb>-posnr.

      IF <fs_cobrb>-wemng EQ 0.
        CONCATENATE 'OR' <fs_cobrb>-aufnr INTO vl_objnr.
        MOVE-CORRESPONDING <fs_cobrb> TO st_zcobrb.
        st_zcobrb-objnr = vl_objnr.
        st_zcobrb-aqzif = 0.
      ELSE.
        st_zcobrb-aqzif = wa_aqzif2-aqzif.
      ENDIF.

      IF st_zcobrb-aqzif EQ 0.
        UPDATE zco_tt_histcobrb SET aqzif2 = -1 mes_exec = p_mes_actual datum = sy-datum
                                           WHERE aufnr = p_aufnr
                                           AND matnr = <fs_cobrb>-matnr
                                           AND posnr = <fs_cobrb>-posnr.
      ELSE.
        UPDATE zco_tt_histcobrb SET aqzif2 = st_zcobrb-aqzif mes_exec = p_mes_actual datum = sy-datum
                                             WHERE aufnr = p_aufnr
                                             AND matnr = <fs_cobrb>-matnr
                                             AND posnr = <fs_cobrb>-posnr.
      ENDIF.

    ELSEIF p_periodo EQ '3'.
      READ TABLE it_aufnr INTO DATA(wa_aqzif3) WITH KEY aufnr = p_aufnr matnr = <fs_cobrb>-matnr posnr = <fs_cobrb>-posnr.

      IF <fs_cobrb>-wemng EQ 0.
        CONCATENATE 'OR' <fs_cobrb>-aufnr INTO vl_objnr.
        MOVE-CORRESPONDING <fs_cobrb> TO st_zcobrb.
        st_zcobrb-objnr = vl_objnr.
        st_zcobrb-aqzif = 0.
      ELSE.
        st_zcobrb-aqzif = wa_aqzif3-aqzif.
      ENDIF.

      IF st_zcobrb-aqzif EQ 0.
        UPDATE zco_tt_histcobrb SET aqzif3 = -1 mes_exec = p_mes_actual datum = sy-datum
                                           WHERE aufnr = p_aufnr
                                           AND matnr = <fs_cobrb>-matnr
                                           AND posnr = <fs_cobrb>-posnr.
      ELSE.
        UPDATE zco_tt_histcobrb SET aqzif3 = st_zcobrb-aqzif mes_exec = p_mes_actual datum = sy-datum
                                             WHERE aufnr = p_aufnr
                                             AND matnr = <fs_cobrb>-matnr
                                             AND posnr = <fs_cobrb>-posnr.
      ENDIF.

    ENDIF.

    APPEND st_zcobrb TO it_zcobrb.


  ENDLOOP.


  UNASSIGN <fs_cobrb>.
  READ TABLE it_table_alv ASSIGNING <fs_alv> WITH KEY aufnr = p_aufnr.
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


  UNASSIGN <fs_alv>.
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

      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'ZSTATUS'
      i_callback_user_command  = 'ZUSER_COMMAND'
*     i_callback_top_of_page   = space
*     i_callback_html_top_of_page = space

      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat

    TABLES
      t_outtab                 = it_table_alv
      EXCEPTIONS
     program_error            = 1
     others                   = 2
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
          titlebar              = 'Ajuste de Normas de Liquidación'
          text_question         = '¿Esta Seguro(a) de continuar?'
          text_button_1         = 'Estoy Seguro'
          icon_button_1         = 'ICON_CHECKED'
          text_button_2         = 'Cancel'
          icon_button_2         = 'ICON_CANCEL'
          default_button        = '2'
          display_cancel_button = ' '
*         userdefined_f1_help   = space
*         start_column          = 25
*         start_row             = 6
*         popup_type            =
*         iv_quickinfo_button_1 = space
*         iv_quickinfo_button_2 = space
        IMPORTING
          answer                = lv_answer
*      TABLES
*         parameter             =
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.
      IF lv_answer EQ '1'.
        PERFORM prepare_data.
        selfield-refresh = 'X'.
      ELSE.
        CALL FUNCTION 'POPUP_TO_INFORM'
          EXPORTING
            titel = 'Información'
            txt1  = 'Has Cancelado la Operación.'
            txt2  = ' '
            txt3  = ' '
            txt4  = ' '.
      ENDIF.
  ENDCASE.


ENDFORM.
