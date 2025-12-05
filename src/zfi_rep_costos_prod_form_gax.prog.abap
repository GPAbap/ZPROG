*----------------------------------------------------------------------*
***INCLUDE ZFI_REP_COSTOS_PROD_FORM.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form datos_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM datos_alv .
  DATA: ind TYPE i,
        lin TYPE c LENGTH 10.

  CLEAR: it_fcat[], is_fcat, it_fieldcat[], is_fieldcat, ind, r_layout.

*Orden ALV
  r_layout-box_fname  = 'SEL'.
  r_layout-sel_mode   = 'A'.
*  r_layout-no_f4      = 'X'.
  r_layout-zebra      = 'X'.
  r_layout-cwidth_opt = 'X'.
  r_layout-INFO_FNAME = 'COLOR'.
  DESCRIBE TABLE it_dis LINES ind.
  MOVE ind TO lin.
  CONDENSE lin.
  CONCATENATE 'Costos de Produccion Mensuales' s_bukrs-low s_gjahr-low
  INTO r_layout-grid_title SEPARATED BY space.
  r_layout-smalltitle = 'X'.
*Armamos el Field Catalog
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name   = 'ZFI_REP_COSTOS_ALL'
      i_bypassing_buffer = 'X'
    CHANGING
      ct_fieldcat        = it_fcat[].

  IF it_fcat[] IS NOT INITIAL.
    LOOP AT it_fcat INTO is_fcat.

      MOVE-CORRESPONDING is_fcat TO is_fieldcat.
      is_fieldcat-col_pos   = ind.
      is_fieldcat-fieldname = is_fcat-fieldname.
      is_fieldcat-ref_field = is_fcat-fieldname.
      is_fieldcat-ref_table = is_fcat-ref_tabname.
      CASE is_fieldcat-fieldname.
        WHEN 'SEGME'.
          is_fieldcat-coltext   = 'Concepto'.
          is_fieldcat-scrtext_l = 'Concepto'.
          is_fieldcat-scrtext_m = 'Concepto'.
          is_fieldcat-scrtext_s = 'Concepto'.
        WHEN 'DESCR'.
          is_fieldcat-coltext   = 'Descripcion'.
          is_fieldcat-scrtext_l = 'Descripcion'.
          is_fieldcat-scrtext_m = 'Descripcion'.
          is_fieldcat-scrtext_s = 'Descripcion'.
        WHEN 'TONS01'.
          is_fieldcat-coltext   = 'Ene.Tons.'.
          is_fieldcat-scrtext_l = 'Ene.Tons.'.
          is_fieldcat-scrtext_m = 'Ene.Tons.'.
          is_fieldcat-scrtext_s = 'Ene.Tons.'.
        WHEN 'NETPR01'.
          is_fieldcat-coltext   = 'Ene.Precio'.
          is_fieldcat-scrtext_l = 'Ene.Precio'.
          is_fieldcat-scrtext_m = 'Ene.Precio'.
          is_fieldcat-scrtext_s = 'Ene.Precio'.
        WHEN 'WRBTR01'.
          is_fieldcat-coltext   = 'Ene.Importe'.
          is_fieldcat-scrtext_l = 'Ene.Importe'.
          is_fieldcat-scrtext_m = 'Ene.Importe'.
          is_fieldcat-scrtext_s = 'Ene.Importe'.
        WHEN 'PORCE01'.
          is_fieldcat-coltext   = 'Ene.Porcentaje'.
          is_fieldcat-scrtext_l = 'Ene.Porcentaje'.
          is_fieldcat-scrtext_m = 'Ene.Porcentaje'.
          is_fieldcat-scrtext_s = 'Ene.Porcentaje'.
        WHEN 'TONS02'.
          is_fieldcat-coltext   = 'Feb.Tons.'.
          is_fieldcat-scrtext_l = 'Feb.Tons.'.
          is_fieldcat-scrtext_m = 'Feb.Tons.'.
          is_fieldcat-scrtext_s = 'Feb.Tons.'.
        WHEN 'NETPR02'.
          is_fieldcat-coltext   = 'Feb.Precio'.
          is_fieldcat-scrtext_l = 'Feb.Precio'.
          is_fieldcat-scrtext_m = 'Feb.Precio'.
          is_fieldcat-scrtext_s = 'Feb.Precio'.
        WHEN 'WRBTR02'.
          is_fieldcat-coltext   = 'Feb.Importe'.
          is_fieldcat-scrtext_l = 'Feb.Importe'.
          is_fieldcat-scrtext_m = 'Feb.Importe'.
          is_fieldcat-scrtext_s = 'Feb.Importe'.
        WHEN 'PORCE02'.
          is_fieldcat-coltext   = 'Feb.Porcentaje'.
          is_fieldcat-scrtext_l = 'Feb.Porcentaje'.
          is_fieldcat-scrtext_m = 'Feb.Porcentaje'.
          is_fieldcat-scrtext_s = 'Feb.Porcentaje'.
        WHEN 'TONS03'.
          is_fieldcat-coltext   = 'Mar.Tons.'.
          is_fieldcat-scrtext_l = 'Mar.Tons.'.
          is_fieldcat-scrtext_m = 'Mar.Tons.'.
          is_fieldcat-scrtext_s = 'Mar.Tons.'.
        WHEN 'NETPR03'.
          is_fieldcat-coltext   = 'Mar.Precio'.
          is_fieldcat-scrtext_l = 'Mar.Precio'.
          is_fieldcat-scrtext_m = 'Mar.Precio'.
          is_fieldcat-scrtext_s = 'Mar.Precio'.
        WHEN 'WRBTR03'.
          is_fieldcat-coltext   = 'Mar.Importe'.
          is_fieldcat-scrtext_l = 'Mar.Importe'.
          is_fieldcat-scrtext_m = 'Mar.Importe'.
          is_fieldcat-scrtext_s = 'Mar.Importe'.
        WHEN 'PORCE03'.
          is_fieldcat-coltext   = 'Mar.Porcentaje'.
          is_fieldcat-scrtext_l = 'Mar.Porcentaje'.
          is_fieldcat-scrtext_m = 'Mar.Porcentaje'.
          is_fieldcat-scrtext_s = 'Mar.Porcentaje'.
        WHEN 'TONS04'.
          is_fieldcat-coltext   = 'Abr.Tons.'.
          is_fieldcat-scrtext_l = 'Abr.Tons.'.
          is_fieldcat-scrtext_m = 'Abr.Tons.'.
          is_fieldcat-scrtext_s = 'Abr.Tons.'.
        WHEN 'NETPR04'.
          is_fieldcat-coltext   = 'Abr.Precio'.
          is_fieldcat-scrtext_l = 'Abr.Precio'.
          is_fieldcat-scrtext_m = 'Abr.Precio'.
          is_fieldcat-scrtext_s = 'Abr.Precio'.
        WHEN 'WRBTR04'.
          is_fieldcat-coltext   = 'Abr.Importe'.
          is_fieldcat-scrtext_l = 'Abr.Importe'.
          is_fieldcat-scrtext_m = 'Abr.Importe'.
          is_fieldcat-scrtext_s = 'Abr.Importe'.
        WHEN 'PORCE04'.
          is_fieldcat-coltext   = 'Abr.Porcentaje'.
          is_fieldcat-scrtext_l = 'Abr.Porcentaje'.
          is_fieldcat-scrtext_m = 'Abr.Porcentaje'.
          is_fieldcat-scrtext_s = 'Abr.Porcentaje'.
        WHEN 'TONS05'.
          is_fieldcat-coltext   = 'May.Tons.'.
          is_fieldcat-scrtext_l = 'May.Tons.'.
          is_fieldcat-scrtext_m = 'May.Tons.'.
          is_fieldcat-scrtext_s = 'May.Tons.'.
        WHEN 'NETPR05'.
          is_fieldcat-coltext   = 'May.Precio'.
          is_fieldcat-scrtext_l = 'May.Precio'.
          is_fieldcat-scrtext_m = 'May.Precio'.
          is_fieldcat-scrtext_s = 'May.Precio'.
        WHEN 'WRBTR05'.
          is_fieldcat-coltext   = 'May.Importe'.
          is_fieldcat-scrtext_l = 'May.Importe'.
          is_fieldcat-scrtext_m = 'May.Importe'.
          is_fieldcat-scrtext_s = 'May.Importe'.
        WHEN 'PORCE05'.
          is_fieldcat-coltext   = 'May.Porcentaje'.
          is_fieldcat-scrtext_l = 'May.Porcentaje'.
          is_fieldcat-scrtext_m = 'May.Porcentaje'.
          is_fieldcat-scrtext_s = 'May.Porcentaje'.
        WHEN 'TONS06'.
          is_fieldcat-coltext   = 'Jun.Tons.'.
          is_fieldcat-scrtext_l = 'Jun.Tons.'.
          is_fieldcat-scrtext_m = 'Jun.Tons.'.
          is_fieldcat-scrtext_s = 'Jun.Tons.'.
        WHEN 'NETPR06'.
          is_fieldcat-coltext   = 'Jun.Precio'.
          is_fieldcat-scrtext_l = 'Jun.Precio'.
          is_fieldcat-scrtext_m = 'Jun.Precio'.
          is_fieldcat-scrtext_s = 'Jun.Precio'.
        WHEN 'WRBTR06'.
          is_fieldcat-coltext   = 'Jun.Importe'.
          is_fieldcat-scrtext_l = 'Jun.Importe'.
          is_fieldcat-scrtext_m = 'Jun.Importe'.
          is_fieldcat-scrtext_s = 'Jun.Importe'.
        WHEN 'PORCE06'.
          is_fieldcat-coltext   = 'Jun.Porcentaje'.
          is_fieldcat-scrtext_l = 'Jun.Porcentaje'.
          is_fieldcat-scrtext_m = 'Jun.Porcentaje'.
          is_fieldcat-scrtext_s = 'Jun.Porcentaje'.
        WHEN 'TONS07'.
          is_fieldcat-coltext   = 'Jul.Tons.'.
          is_fieldcat-scrtext_l = 'Jul.Tons.'.
          is_fieldcat-scrtext_m = 'Jul.Tons.'.
          is_fieldcat-scrtext_s = 'Jul.Tons.'.
        WHEN 'NETPR07'.
          is_fieldcat-coltext   = 'Jul.Precio'.
          is_fieldcat-scrtext_l = 'Jul.Precio'.
          is_fieldcat-scrtext_m = 'Jul.Precio'.
          is_fieldcat-scrtext_s = 'Jul.Precio'.
        WHEN 'WRBTR07'.
          is_fieldcat-coltext   = 'Jul.Importe'.
          is_fieldcat-scrtext_l = 'Jul.Importe'.
          is_fieldcat-scrtext_m = 'Jul.Importe'.
          is_fieldcat-scrtext_s = 'Jul.Importe'.
        WHEN 'PORCE07'.
          is_fieldcat-coltext   = 'Jul.Porcentaje'.
          is_fieldcat-scrtext_l = 'Jul.Porcentaje'.
          is_fieldcat-scrtext_m = 'Jul.Porcentaje'.
          is_fieldcat-scrtext_s = 'Jul.Porcentaje'.
        WHEN 'TONS08'.
          is_fieldcat-coltext   = 'Ago.Tons.'.
          is_fieldcat-scrtext_l = 'Ago.Tons.'.
          is_fieldcat-scrtext_m = 'Ago.Tons.'.
          is_fieldcat-scrtext_s = 'Ago.Tons.'.
        WHEN 'NETPR08'.
          is_fieldcat-coltext   = 'Ago.Precio'.
          is_fieldcat-scrtext_l = 'Ago.Precio'.
          is_fieldcat-scrtext_m = 'Ago.Precio'.
          is_fieldcat-scrtext_s = 'Ago.Precio'.
        WHEN 'WRBTR08'.
          is_fieldcat-coltext   = 'Ago.Importe'.
          is_fieldcat-scrtext_l = 'Ago.Importe'.
          is_fieldcat-scrtext_m = 'Ago.Importe'.
          is_fieldcat-scrtext_s = 'Ago.Importe'.
        WHEN 'PORCE08'.
          is_fieldcat-coltext   = 'Ago.Porcentaje'.
          is_fieldcat-scrtext_l = 'Ago.Porcentaje'.
          is_fieldcat-scrtext_m = 'Ago.Porcentaje'.
          is_fieldcat-scrtext_s = 'Ago.Porcentaje'.
        WHEN 'TONS09'.
          is_fieldcat-coltext   = 'Sep.Tons.'.
          is_fieldcat-scrtext_l = 'Sep.Tons.'.
          is_fieldcat-scrtext_m = 'Sep.Tons.'.
          is_fieldcat-scrtext_s = 'Sep.Tons.'.
        WHEN 'NETPR09'.
          is_fieldcat-coltext   = 'Sep.Precio'.
          is_fieldcat-scrtext_l = 'Sep.Precio'.
          is_fieldcat-scrtext_m = 'Sep.Precio'.
          is_fieldcat-scrtext_s = 'Sep.Precio'.
        WHEN 'WRBTR09'.
          is_fieldcat-coltext   = 'Sep.Importe'.
          is_fieldcat-scrtext_l = 'Sep.Importe'.
          is_fieldcat-scrtext_m = 'Sep.Importe'.
          is_fieldcat-scrtext_s = 'Sep.Importe'.
        WHEN 'PORCE09'.
          is_fieldcat-coltext   = 'Sep.Porcentaje'.
          is_fieldcat-scrtext_l = 'Sep.Porcentaje'.
          is_fieldcat-scrtext_m = 'Sep.Porcentaje'.
          is_fieldcat-scrtext_s = 'Sep.Porcentaje'.
        WHEN 'TONS10'.
          is_fieldcat-coltext   = 'Oct.Tons.'.
          is_fieldcat-scrtext_l = 'Oct.Tons.'.
          is_fieldcat-scrtext_m = 'Oct.Tons.'.
          is_fieldcat-scrtext_s = 'Oct.Tons.'.
        WHEN 'NETPR10'.
          is_fieldcat-coltext   = 'Oct.Precio'.
          is_fieldcat-scrtext_l = 'Oct.Precio'.
          is_fieldcat-scrtext_m = 'Oct.Precio'.
          is_fieldcat-scrtext_s = 'Oct.Precio'.
        WHEN 'WRBTR10'.
          is_fieldcat-coltext   = 'Oct.Importe'.
          is_fieldcat-scrtext_l = 'Oct.Importe'.
          is_fieldcat-scrtext_m = 'Oct.Importe'.
          is_fieldcat-scrtext_s = 'Oct.Importe'.
        WHEN 'PORCE10'.
          is_fieldcat-coltext   = 'Oct.Porcentaje'.
          is_fieldcat-scrtext_l = 'Oct.Porcentaje'.
          is_fieldcat-scrtext_m = 'Oct.Porcentaje'.
          is_fieldcat-scrtext_s = 'Oct.Porcentaje'.
        WHEN 'TONS11'.
          is_fieldcat-coltext   = 'Nov.Tons.'.
          is_fieldcat-scrtext_l = 'Nov.Tons.'.
          is_fieldcat-scrtext_m = 'Nov.Tons.'.
          is_fieldcat-scrtext_s = 'Nov.Tons.'.
        WHEN 'NETPR11'.
          is_fieldcat-coltext   = 'Nov.Precio'.
          is_fieldcat-scrtext_l = 'Nov.Precio'.
          is_fieldcat-scrtext_m = 'Nov.Precio'.
          is_fieldcat-scrtext_s = 'Nov.Precio'.
        WHEN 'WRBTR11'.
          is_fieldcat-coltext   = 'Nov.Importe'.
          is_fieldcat-scrtext_l = 'Nov.Importe'.
          is_fieldcat-scrtext_m = 'Nov.Importe'.
          is_fieldcat-scrtext_s = 'Nov.Importe'.
        WHEN 'PORCE11'.
          is_fieldcat-coltext   = 'Nov.Porcentaje'.
          is_fieldcat-scrtext_l = 'Nov.Porcentaje'.
          is_fieldcat-scrtext_m = 'Nov.Porcentaje'.
          is_fieldcat-scrtext_s = 'Nov.Porcentaje'.
        WHEN 'TONS12'.
          is_fieldcat-coltext   = 'Dic.Tons.'.
          is_fieldcat-scrtext_l = 'Dic.Tons.'.
          is_fieldcat-scrtext_m = 'Dic.Tons.'.
          is_fieldcat-scrtext_s = 'Dic.Tons.'.
        WHEN 'NETPR12'.
          is_fieldcat-coltext   = 'Dic.Precio'.
          is_fieldcat-scrtext_l = 'Dic.Precio'.
          is_fieldcat-scrtext_m = 'Dic.Precio'.
          is_fieldcat-scrtext_s = 'Dic.Precio'.
        WHEN 'WRBTR12'.
          is_fieldcat-coltext   = 'Dic.Importe'.
          is_fieldcat-scrtext_l = 'Dic.Importe'.
          is_fieldcat-scrtext_m = 'Dic.Importe'.
          is_fieldcat-scrtext_s = 'Dic.Importe'.
        WHEN 'PORCE12'.
          is_fieldcat-coltext   = 'Dic.Porcentaje'.
          is_fieldcat-scrtext_l = 'Dic.Porcentaje'.
          is_fieldcat-scrtext_m = 'Dic.Porcentaje'.
          is_fieldcat-scrtext_s = 'Dic.Porcentaje'.
        WHEN 'TONS13'.
          is_fieldcat-coltext   = 'Anual.Tons.'.
          is_fieldcat-scrtext_l = 'Anual.Tons.'.
          is_fieldcat-scrtext_m = 'Anual.Tons.'.
          is_fieldcat-scrtext_s = 'Anual.Tons.'.
        WHEN 'NETPR13'.
          is_fieldcat-coltext   = 'Anual.Precio'.
          is_fieldcat-scrtext_l = 'Anual.Precio'.
          is_fieldcat-scrtext_m = 'Anual.Precio'.
          is_fieldcat-scrtext_s = 'Anual.Precio'.
        WHEN 'WRBTR13'.
          is_fieldcat-coltext   = 'Anual.Importe'.
          is_fieldcat-scrtext_l = 'Anual.Importe'.
          is_fieldcat-scrtext_m = 'Anual.Importe'.
          is_fieldcat-scrtext_s = 'Anual.Importe'.
        WHEN 'PORCE13'.
          is_fieldcat-coltext   = 'Anual.Porcentaje'.
          is_fieldcat-scrtext_l = 'Anual.Porcentaje'.
          is_fieldcat-scrtext_m = 'Anual.Porcentaje'.
          is_fieldcat-scrtext_s = 'Anual.Porcentaje'.
      ENDCASE.
      APPEND is_fieldcat TO it_fieldcat.
    ENDLOOP.
  ENDIF.

ENDFORM.
