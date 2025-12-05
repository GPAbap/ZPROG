*&---------------------------------------------------------------------*
*& Include ztm_re_fletes_fun
*&---------------------------------------------------------------------*


FORM get_data_tm.

  DATA vl_fechai LIKE /scmtms/d_torrot-created_on.
  DATA vl_fechaf LIKE /scmtms/d_torrot-created_on.

  vl_fechai = so_fecha-low.
  IF so_fecha-high IS INITIAL.
    vl_fechaf = so_fecha-low.
  ELSE.
    vl_fechaf = so_fecha-high.

  ENDIF.

  SELECT
    zcds_tf_tm_fletes_jhv~zorden_flete,
    zcds_tf_tm_fletes_jhv~zfechaorden,
    zcds_tf_tm_fletes_jhv~zentrega,
    zcds_tf_tm_fletes_jhv~zfactura,
    zcds_tf_tm_fletes_jhv~zreferencia,
    zcds_tf_tm_fletes_jhv~zdoc_liquida,
    zcds_tf_tm_fletes_jhv~zedo_factura,
    zcds_tf_tm_fletes_jhv~zdes_edofact,
    zcds_tf_tm_fletes_jhv~zpedido,
    zcds_tf_tm_fletes_jhv~zubica_orig,
    zcds_tf_tm_fletes_jhv~zubica_dest,
    zcds_tf_tm_fletes_jhv~zcd_destino,
    zcds_tf_tm_fletes_jhv~zno_transpor,
    zcds_tf_tm_fletes_jhv~znom_transpor,
    zcds_tf_tm_fletes_jhv~zmedio_trans,
    zcds_tf_tm_fletes_jhv~zdistancia,
    zcds_tf_tm_fletes_jhv~zum_distancia,
    zcds_tf_tm_fletes_jhv~zcosto_km,
    zcds_tf_tm_fletes_jhv~zimporte_fo,
    zcds_tf_tm_fletes_jhv~zmoneda_fo,
    zcds_tf_tm_fletes_jhv~zpiezas,
    zcds_tf_tm_fletes_jhv~zpeso,
    zcds_tf_tm_fletes_jhv~zum_peso,
    zcds_tf_tm_fletes_jhv~zcosto_ton,
    zcds_tf_tm_fletes_jhv~zcosto_kg,
    zcds_tf_tm_fletes_jhv~zfo_creadaby,
    zcds_tf_tm_fletes_jhv~zno_flete,
    zcds_tf_tm_fletes_jhv~zdocventa,
    zcds_tf_tm_fletes_jhv~zfec_conta_dlf,
    zcds_tf_tm_fletes_jhv~zdlf_createdby,
    zcds_tf_tm_fletes_jhv~zetiqueta,
    zcds_tf_tm_fletes_jhv~zcentro,
    zcds_tf_tm_fletes_jhv~zdes_ubiorigen,
    zcds_tf_tm_fletes_jhv~zdes_ubidestino,
    zcds_tf_tm_fletes_jhv~zflete_vtas,
    zcds_tf_tm_fletes_jhv~ztarifa,
    zcds_tf_tm_fletes_jhv~zmoneda,
    zcds_tf_tm_fletes_jhv~zmoneda_costadic,
    zcds_tf_tm_fletes_jhv~zdenom_costo,
    zcds_tf_tm_fletes_jhv~purch_company_code,
    zcds_tf_tm_fletes_jhv~erdat,
    zcds_tf_tm_fletes_jhv~f_pago,
    zcds_tf_tm_fletes_jhv~cpudt,
    zcds_tf_tm_fletes_jhv~fkimg
  FROM
   zcds_tf_tm_fletes_jhv( p_finicio = @vl_fechai ,
    p_ffinal = @vl_fechaf )
    INTO TABLE @it_fletes
    .

if  it_fletes is not INITIAL.
  IF SO_VBELN is not INITIAL.
    delete it_fletes where zentrega not in so_vbeln.
  ENDIF.

  if so_werks is not INITIAL.
    delete it_fletes where zcentro not in so_werks.
  ENDIF.

    if so_bukrs is not INITIAL.
    delete it_fletes where kkber not in so_bukrs.
  ENDIF.


ENDIF.






ENDFORM.

FORM create_fieldcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
     i_program_name         = sy-repid
*     i_internal_tabname     = it_fletes
      i_structure_name       = 'ZTM_ST_FLETES'
      i_client_never_display = 'X'
*     i_inclname             =
*     i_bypassing_buffer     =
*     i_buffer_active        =
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT gt_fieldcat INTO wa_fieldcat.

    CASE wa_fieldcat-fieldname.
      WHEN 'ZFO_CREADABY'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZNO_FLETE'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZFEC_CONTA-DLF'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZDLF_CREATEDBY'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZETIQUETA'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZCENTRO'.
        wa_fieldcat-no_out = 'X'.
      WHEN  'ZDES_UBIORIGEN'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZDES_UBIDESTINO'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZDES_EDOFACT'.
        wa_fieldcat-no_out = ''.
      WHEN 'ZFLETE_VTAS'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZTARIFA'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZMONEA'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZCOSTO_ADICIONAL'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZMONEDA_COSTASIC'.
        wa_fieldcat-no_out = 'X'.
      WHEN 'ZDEM_COSTO'.
        wa_fieldcat-no_out = 'X'.

    ENDCASE.
    MODIFY gt_fieldcat from wa_fieldcat.
    clear wa_fieldcat.
  ENDLOOP.


endform.



FORM show_alv.

  lf_layout-zebra = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     i_interface_check  = space
*     i_bypassing_buffer = space
*     i_buffer_active    = space
      i_callback_program = sy-repid
*     i_callback_pf_status_set    = space
*     i_callback_user_command     = space
*     i_callback_top_of_page      = space
*     i_callback_html_top_of_page = space
*     i_callback_html_end_of_list = space
*     i_structure_name   =
*     i_background_id    =
*     i_grid_title       =
*     i_grid_settings    =
      is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat
*     it_excluding       =
*     it_special_groups  =
*     it_sort            =
*     it_filter          =
*     is_sel_hide        =
*     i_default          = 'X'
      i_save             = 'X'
*     is_variant         =
      it_events          = ti_event
*     it_event_exit      =
*     is_print           =
*     is_reprep_id       =
*     i_screen_start_column       = 0
*     i_screen_start_line         = 0
*     i_screen_end_column         = 0
*     i_screen_end_line  = 0
*     i_html_height_top  = 0
*     i_html_height_end  = 0
*     it_alv_graphics    =
*     it_hyperlink       =
*     it_add_fieldcat    =
*     it_except_qinfo    =
*     ir_salv_fullscreen_adapter  =
*     o_previous_sral_handler     =
*  IMPORTING
*     e_exit_caused_by_caller     =
*     es_exit_caused_by_user      =
    TABLES
      t_outtab           = it_fletes
*  EXCEPTIONS
*     program_error      = 1
*     others             = 2
    .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.

FORM build_event.

  DATA : wa_eve TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = 0
    IMPORTING
      et_events       = ti_event
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.
ENDFORM.
