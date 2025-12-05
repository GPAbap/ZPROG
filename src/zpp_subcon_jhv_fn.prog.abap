*&---------------------------------------------------------------------*
*& Include zpp_subcon_jhv_fn
*&---------------------------------------------------------------------*

FORM get_data.

  FIELD-SYMBOLS <fs_matdoc> TYPE zpp_tf_jhv_subcon.
  DATA zmblnr TYPE mblnr.
  DATA zmatnr TYPE string.

  l_where = cl_shdb_seltab=>combine_seltabs(
                                     EXPORTING it_named_seltabs =
                                           VALUE #(  ( name = 'AUFNR' dref = REF #( s_aufnr[] ) )
                                                    ( name = 'EBELN' dref = REF #( s_ebeln[] ) )
                                                    ( name = 'BUDAT' dref = REF #( s_budat[] ) )
                                                   )
                                           iv_client_field = 'MANDT'
                               ).

*  SELECT * FROM zpp_tf_jhv_subcon( sel_opt = @l_where ) into table @lt_tab.
*  SORT lt_tab by matnr matnr_s.

  SELECT   "matdoc.mandt as clnt,
            "   SELECT
                    mseg~werks,
                    mseg~aufnr,
                    mseg~matnr,
                    makt~maktx,
                  SUM(
                  CASE WHEN mseg~bwart = '262' THEN mseg~erfmg * -1
                  ELSE CASE WHEN mseg~bwart = '544' THEN mseg~erfmg * -1
                  ELSE CASE WHEN mseg~bwart = '102' THEN mseg~erfmg * -1
                  ELSE mseg~erfmg END END END
                  ) AS erfmg,
"                    0 AS erfmg,
                    mseg~erfme
*                  matdoc.bwart,
*                    m2~werks AS werks_s,
*                    m2~ebeln AS ebeln_s,
*                    m2~matnr AS matnr_s,
*                    mseg~werks AS werks_s,
*                    mseg~ebeln AS ebeln_s,
*                    mseg~matnr AS matnr_s,

*                  SUM(
*                  CASE WHEN m2~bwart = '262' THEN m2~erfmg * -1
*                  ELSE CASE WHEN m2~bwart = '544' THEN m2~erfmg * -1
*                  ELSE CASE WHEN m2~bwart = '102' THEN m2~erfmg * -1
*                  ELSE m2~erfmg END END END
*                  ) AS erfmg_s,
*                    0 AS erfmg_s,
**                    m2~erfme AS   erfme_s,
**                    m2~bwart AS  bwart_s,
*                    mseg~erfme AS erfme_s,
*                    mseg~bwart AS  bwart_s,
*"                    '0' AS  bwart_s,
*                      0 AS diferencia
*                     "mseg~erfmg - m2~erfmg AS Diferencia
*                    ",m2~budat
*                    ",mseg~budat_mkpf as budat
             FROM mseg
*             LEFT JOIN mkpf ON rtrim( mkpf~bktxt,' ' ) = rtrim( mseg~aufnr, ' ' )
*                  AND mkpf~budat >= mseg~budat_mkpf

*             LEFT JOIN matdoc AS m2 ON m2~mblnr = mkpf~mblnr
*                       AND ltrim( m2~matnr,'0' )
*                       = ltrim( rtrim( replace( mseg~matnr,'NV',' ' ), ' ' ),'0' )
*                       AND m2~budat >= mseg~budat_mkpf

             INNER JOIN makt ON makt~matnr = mseg~matnr AND makt~spras = 'S'

             WHERE
                mseg~aufnr IN @s_aufnr AND
                mseg~budat_mkpf IN @s_budat AND
                mseg~ebeln IN @s_ebeln
             GROUP BY mseg~mandt, "mseg~erfmg,m2~erfmg,
                      mseg~werks, mseg~aufnr,mseg~matnr,
                      makt~maktx,mseg~erfme
*                    matdoc.bwart,
*                      m2~werks,m2~matnr,m2~erfme,
*                      m2~bwart,
*                       mseg~bwart,
*                      m2~ebeln
*                       mseg~ebeln
*                       ,m2~budat
                       "mseg~budat_mkpf
              INTO TABLE @lt_tab
                      .
  SORT lt_tab BY aufnr matnr matnr_s.


  DATA(lt_tab_aux) = lt_tab[].

  SORT lt_tab_aux BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_tab_aux COMPARING aufnr.

  LOOP AT lt_tab_aux INTO DATA(wa_aux).


    SELECT  MAX( mblnr ) AS mblnr
      FROM mkpf
    WHERE rtrim( mkpf~bktxt,' ' ) = @wa_aux-aufnr
    INTO TABLE @DATA(it_mblnr)
     .

    IF sy-subrc EQ 0.

      READ TABLE it_mblnr INTO DATA(wmblnr) INDEX 1.
      zmblnr = wmblnr-mblnr.
      SELECT
                   rtrim( mseg~bktxt, ' ' ) AS aufnr,
                   mseg~werks AS werks_s,
                   mseg~ebeln AS ebeln_s,
                   ltrim( mseg~matnr,'0' ) AS matnr_s,
                   SUM(
                    CASE WHEN mseg~bwart = '262' THEN mseg~erfmg * -1
                    ELSE CASE WHEN mseg~bwart = '544' THEN mseg~erfmg * -1
                    ELSE CASE WHEN mseg~bwart = '102' THEN mseg~erfmg * -1
                    ELSE mseg~erfmg END END END
                    ) AS erfmg_s,
                   mseg~erfme AS erfme_s,
                   mseg~bwart,
                   mseg~budat
               FROM matdoc AS mseg
                    WHERE mseg~mblnr = @zmblnr
                    GROUP BY
                       mseg~bktxt,
                       mseg~werks,mseg~ebeln, mseg~matnr,
                       mseg~erfme,mseg~bwart, mseg~budat
               INTO TABLE @DATA(it_pedido).

    ENDIF.

    IF it_pedido IS NOT INITIAL.



      LOOP AT lt_tab ASSIGNING <fs_matdoc> WHERE aufnr EQ wa_aux-aufnr.

        IF it_pedido IS NOT INITIAL.
          zmatnr = <fs_matdoc>-matnr.

          REPLACE 'NV' WITH ' ' INTO zmatnr .
          CONDENSE zmatnr NO-GAPS.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = zmatnr
            IMPORTING
              output = zmatnr.



          READ TABLE it_pedido INTO DATA(wa_erfmg_s) WITH KEY aufnr = <fs_matdoc>-aufnr
                     matnr_s = zmatnr .
          IF sy-subrc EQ 0.


            <fs_matdoc>-werks_s     =  wa_erfmg_s-werks_s.
            <fs_matdoc>-ebeln_s     = wa_erfmg_s-ebeln_s.
            <fs_matdoc>-matnr_s     = wa_erfmg_s-matnr_s.
            <fs_matdoc>-erfme_s     = wa_erfmg_s-erfme_s.
            <fs_matdoc>-erfmg_s     =  wa_erfmg_s-erfmg_s.
            <fs_matdoc>-diferencia  = <fs_matdoc>-erfmg - wa_erfmg_s-erfmg_s.
            <fs_matdoc>-bwart_s     = wa_erfmg_s-bwart.
            <fs_matdoc>-budat       = wa_erfmg_s-budat.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDLOOP.

ENDFORM.

FORM set_fieldcat.
  CLEAR st_fieldcat.
  REFRESH gt_fieldcat.

  st_fieldcat-fieldname = 'WERKS'.
  st_fieldcat-seltext_s = 'Centro'.
  st_fieldcat-seltext_m = 'Centro'.
  st_fieldcat-seltext_l = 'Centro'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'AUFNR'.
  st_fieldcat-seltext_s = 'Orden'.
  st_fieldcat-seltext_m = 'Orden'.
  st_fieldcat-seltext_l = 'Orden'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'MATNR'.
  st_fieldcat-seltext_s = 'Num. Material'.
  st_fieldcat-seltext_m = 'Num. Material'.
  st_fieldcat-seltext_l = 'Num. MAterial'.
  st_fieldcat-datatype = 'NUMC'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'MAKTX'.
  st_fieldcat-seltext_s = 'Descripción'.
  st_fieldcat-seltext_m = 'Descripción'.
  st_fieldcat-seltext_l = 'Descripción'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'ERFMG'.
  st_fieldcat-seltext_s = 'Cantidad'.
  st_fieldcat-seltext_m = 'Cantidad'.
  st_fieldcat-seltext_l = 'Cantidad'.
  st_fieldcat-do_sum    = 'X'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'ERFME'.
  st_fieldcat-seltext_s = 'Unidad'.
  st_fieldcat-seltext_m = 'Unidad'.
  st_fieldcat-seltext_l = 'Unidad'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'WERKS_S'.
  st_fieldcat-seltext_s = 'Centro'.
  st_fieldcat-seltext_m = 'Centro'.
  st_fieldcat-seltext_l = 'Centro'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'EBELN_S'.
  st_fieldcat-seltext_s = 'Pedido'.
  st_fieldcat-seltext_m = 'Pedido'.
  st_fieldcat-seltext_l = 'Pedido'.
  st_fieldcat-datatype = 'NUMC'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'MATNR_S'.
  st_fieldcat-seltext_s = 'Num. Material'.
  st_fieldcat-seltext_m = 'Num. Material'.
  st_fieldcat-seltext_l = 'Num. MAterial'.
  st_fieldcat-datatype = 'NUMC'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'ERFMG_S'.
  st_fieldcat-seltext_s = 'Cantidad'.
  st_fieldcat-seltext_m = 'Cantidad'.
  st_fieldcat-seltext_l = 'Cantidad'.
  st_fieldcat-do_sum    = 'X'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'ERFME_S'.
  st_fieldcat-seltext_s = 'Unidad'.
  st_fieldcat-seltext_m = 'Unidad'.
  st_fieldcat-seltext_l = 'Unidad'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'BWART_S'.
  st_fieldcat-seltext_s = 'Movimiento'.
  st_fieldcat-seltext_m = 'Movimiento'.
  st_fieldcat-seltext_l = 'Movimiento'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'DIFERENCIA'.
  st_fieldcat-seltext_s = 'Diferencia'.
  st_fieldcat-seltext_m = 'Diferencia'.
  st_fieldcat-seltext_l = 'Diferencia'.
  st_fieldcat-quantity  = 'X'.
  st_fieldcat-do_sum    = 'X'.
  APPEND st_fieldcat TO gt_fieldcat.

  CLEAR st_fieldcat.
  st_fieldcat-fieldname = 'BUDAT'.
  st_fieldcat-seltext_s = 'Fec. Contable'.
  st_fieldcat-seltext_m = 'Fec. Contable'.
  st_fieldcat-seltext_l = 'Fec. Contable'.
  APPEND st_fieldcat TO gt_fieldcat.

ENDFORM.

FORM show_data.

*  cl_salv_table=>factory(
*   IMPORTING
*     r_salv_table = lo_alv
*   CHANGING
*     t_table      = lt_tab ).
*
*  lo_alv->display( ).

  ls_layout-zebra = 'X'.

  CLEAR: wa_sort.
  wa_sort-spos = 1.
  wa_sort-fieldname = 'AUFNR'. "
  wa_sort-up = 'X'.
  wa_sort-subtot = 'X'.
  APPEND wa_sort TO it_sort.


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
      is_layout          = ls_layout
      it_fieldcat        = gt_fieldcat
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
      it_sort            = it_sort
*     IT_FILTER          =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
      i_save             = 'A'
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
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab           = lt_tab
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.



ENDFORM.
