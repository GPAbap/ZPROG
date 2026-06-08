*&---------------------------------------------------------------------*
*& Include          ZFI_RE_BAL_DET_FUN
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

  DATA: lt_clientes TYPE STANDARD TABLE OF ty_detalle,
        lt_prov     TYPE STANDARD TABLE OF ty_detalle.

*"Selección de cuentas
*  SELECT bukrs,
*        racct,
*        koart
*   FROM ZFI_f01_CTA_DET
*   INTO TABLE @gt_cfg
*   WHERE bukrs = @p_bukrs
*     AND racct IN @s_racct.


  SELECT
     a~racct                            AS cuentas,
     CASE
       WHEN a~kunnr IS NOT INITIAL THEN a~kunnr
       WHEN a~lifnr IS NOT INITIAL THEN a~lifnr
       ELSE '    '
     END                                AS subcuentas,
     CASE
       WHEN a~kunnr IS NOT INITIAL THEN k~name1
       WHEN a~lifnr IS NOT INITIAL THEN l~name1
       ELSE t~txt50
     END                                AS texto,
     a~rbukrs                           AS soc,
     a~rhcur                            AS mon,
     SUM( CASE
            WHEN a~poper = '000'
            THEN a~hsl
            ELSE 0
          END )                         AS arrastre,
     SUM( CASE
            WHEN a~poper >= '001'
             AND a~poper < @p_poper
            THEN a~hsl
            ELSE 0
          END )                         AS saldo_ant,
     SUM( CASE
            WHEN a~poper = @p_poper
             AND a~hsl > 0
            THEN a~hsl
            ELSE 0
          END )                         AS debe,
     SUM( CASE
            WHEN a~poper = @p_poper
             AND a~hsl < 0
            THEN 0 - a~hsl
            ELSE 0
          END )                         AS haber,
     SUM( CASE
            WHEN a~poper = @p_poper
            THEN a~hsl
            ELSE 0
          END )                         AS saldo_mes
   FROM acdoca AS a
   INNER JOIN fagl_011zc AS f
   ON a~racct BETWEEN f~vonkt AND f~biskt
  LEFT JOIN kna1 AS k
  ON k~kunnr = a~kunnr
  LEFT JOIN lfa1 AS l
  ON l~lifnr = a~lifnr
  LEFT JOIN skat AS t
  ON t~ktopl = a~ktopl
  AND t~saknr = a~racct
  AND t~spras = @sy-langu
  WHERE a~rbukrs = @p_bukrs
  AND a~rldnr  = @p_rldnr
  AND a~gjahr  = @p_gjahr
  AND a~racct  IN @s_racct
  AND a~poper <= @p_poper
  AND f~versn EQ @p_VERSN
  GROUP BY
  a~racct,
  a~kunnr,
  a~lifnr,
  k~name1,
  l~name1,
  t~txt50,
  a~rbukrs,
  a~rhcur
   INTO CORRESPONDING FIELDS OF TABLE @it_balanzad.

  SORT it_balanzad BY cuentas subcuentas.

  LOOP AT it_balanzad ASSIGNING FIELD-SYMBOL(<fs_wa>).

    <fs_wa>-saldo_mes = <fs_wa>-debe - <fs_wa>-haber + <fs_wa>-arrastre.

  ENDLOOP.

  MOVE-CORRESPONDING it_balanzad TO it_balanzah.
  DELETE ADJACENT DUPLICATES FROM it_balanzah COMPARING cuentas.


  LOOP AT it_balanzah ASSIGNING FIELD-SYMBOL(<fs_header>).

    CLEAR <fs_header>-total.

    LOOP AT it_balanzad ASSIGNING FIELD-SYMBOL(<fs_item>)
         WHERE cuentas = <fs_header>-cuentas.
      <fs_header>-total = <fs_header>-total + <fs_item>-saldo_mes.
      IF <fs_item>-subcuentas IS NOT INITIAL.
        SELECT SINGLE t~txt45 INTO <fs_header>-txt50
          FROM fagl_011qt AS t
        INNER JOIN fagl_011zc AS z
          ON z~versn = t~versn AND z~ergsl = t~ergsl
        WHERE txtyp = 'K'
        AND t~versn = p_versn
        AND z~vonkt >= <fs_header>-cuentas AND z~biskt <= <fs_header>-cuentas.
      ENDIF.

    ENDLOOP.

  ENDLOOP.


ENDFORM.


FORM show_alv.

  DATA: lo_alv TYPE REF TO cl_salv_table.
  DATA: go_layout TYPE REF TO cl_salv_layout,
        gs_key    TYPE salv_s_layout_key.

  DATA: go_columns TYPE REF TO cl_salv_columns_table,
        go_column  TYPE REF TO cl_salv_column.


  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = gt_out ). "gt_detalle ).
      """""""""""""""""""""""""""""""""""""""""""""""""""""""
      go_columns = lo_alv->get_columns( ).


* Columna
      go_column = go_columns->get_column( 'CUENTAS' ).

      go_column->set_short_text( 'Cuenta' ).
      go_column->set_medium_text( 'Cuenta' ).
      go_column->set_long_text( 'Cuenta' ).

      go_column = go_columns->get_column( 'SUBCUENTAS' ).
      go_column->set_short_text( 'SubCuenta' ).
      go_column->set_medium_text( 'SubCuenta' ).
      go_column->set_long_text( 'SubCuenta' ).

      go_column = go_columns->get_column( 'TEXTO' ).
      go_column->set_short_text( 'Texto Exp.' ).
      go_column->set_medium_text( 'Texto Exp.' ).
      go_column->set_long_text( 'Texto Explicativo' ).

      go_column = go_columns->get_column( 'SOC' ).
      go_column->set_short_text( 'Sociedad' ).
      go_column->set_medium_text( 'Sociedad' ).
      go_column->set_long_text( 'Sociedad' ).

      go_column = go_columns->get_column( 'MON' ).
      go_column->set_short_text( 'Moneda' ).
      go_column->set_medium_text( 'Moneda' ).
      go_column->set_long_text( 'Moneda' ).

      go_column = go_columns->get_column( 'ARRASTRE' ).
      go_column->set_short_text( 'Arrastre' ).
      go_column->set_medium_text( 'Arrastre' ).
      go_column->set_long_text( 'Arrastre de Saldos' ).

      go_column = go_columns->get_column( 'SALDO_ANT' ).
      go_column->set_short_text( 'Saldo Ant.' ).
      go_column->set_medium_text( 'Saldo Ant.' ).
      go_column->set_long_text( 'Saldo Anterior' ).

      go_column = go_columns->get_column( 'DEBE' ).
      go_column->set_short_text( 'Debe' ).
      go_column->set_medium_text( 'Debe' ).
      go_column->set_long_text( 'Debe' ).

      go_column = go_columns->get_column( 'HABER' ).
      go_column->set_short_text( 'Haber' ).
      go_column->set_medium_text( 'Haber' ).
      go_column->set_long_text( 'Haber' ).

      go_column = go_columns->get_column( 'SALDO_MES' ).
      go_column->set_short_text( 'Saldo P.' ).
      go_column->set_medium_text( 'Saldo P.' ).
      go_column->set_long_text( 'Saldo Periodo' ).
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

*---------------------------------------------------
* ACTIVAR FUNCIONES STANDARD
*---------------------------------------------------
      lo_alv->get_functions( )->set_all( abap_true ).

*---------------------------------------------------
* CONFIGURAR LAYOUTS
*---------------------------------------------------
      go_layout = lo_alv->get_layout( ).

      gs_key-report = sy-repid.

      go_layout->set_key( gs_key ).

* Permitir guardar layouts
      go_layout->set_save_restriction(
        if_salv_c_layout=>restrict_none
      ).

* Layout por defecto
      go_layout->set_default( abap_true ).

      lo_alv->get_columns( )->set_optimize( abap_true ).
      lo_alv->display( ).

    CATCH cx_salv_msg INTO DATA(lx_msg).
      MESSAGE lx_msg->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.

FORM show_alv_HIERSEQ.

  CLEAR st_keyinfo.

  st_keyinfo-header01 = 'CUENTAS'.
  st_keyinfo-item01 = 'CUENTAS'.
  DATA lv_pf TYPE slis_formname.

  "lv_pf = 'ZPF_STATUS'.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
  "   i_callback_pf_status_set = lv_pf
   "  i_callback_user_command  = 'USER_COMMAND'
      Is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat[]
      i_tabname_header   = 'IT_BALANZAH'
      i_tabname_item     = 'IT_BALANZAD'
      is_keyinfo         = st_keyinfo
    TABLES
      t_outtab_header    = it_balanzah
      t_outtab_item      = it_balanzad
                           EXCEPTIONS
                           program_error =1
      OTHERS             = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat .
  CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'CUENTAS'.
  wa_fieldcat-tabname = 'IT_BALANZAH'.
  wa_fieldcat-seltext_m = 'Cuenta'.
  wa_fieldcat-seltext_s = 'Cuenta'.
  wa_fieldcat-seltext_l = 'Cuenta'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'SUBCUENTAS'.
  wa_fieldcat-tabname = 'IT_BALANZAD'.
  wa_fieldcat-seltext_m = 'SubCuenta'.
  wa_fieldcat-seltext_s = 'SubCuenta'.
  wa_fieldcat-seltext_l = 'SubCuenta'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'TXT50'.
  wa_fieldcat-tabname = 'IT_BALANZAH'.
  wa_fieldcat-seltext_m = 'Nom. Cta'.
  wa_fieldcat-seltext_s = 'Nom. Cta.'.
  wa_fieldcat-seltext_l = 'Nombre Cuenta'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'TEXTO'.
  wa_fieldcat-tabname = 'IT_BALANZAD'.
  wa_fieldcat-seltext_m = 'Texto Exp.'.
  wa_fieldcat-seltext_s = 'Texto Exp.'.
  wa_fieldcat-seltext_l = 'Texto Exp.'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'SOC'.
  wa_fieldcat-tabname = 'IT_BALANZAD'.
  wa_fieldcat-seltext_m = 'Sociedad'.
  wa_fieldcat-seltext_s = 'Sociedad'.
  wa_fieldcat-seltext_l = 'Sociedad'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'MON'.
  wa_fieldcat-tabname = 'IT_BALANZAD'.
  wa_fieldcat-seltext_m = 'Moneda'.
  wa_fieldcat-seltext_s = 'Moneda'.
  wa_fieldcat-seltext_l = 'Moneda'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'ARRASTRE'.
  wa_fieldcat-tabname = 'IT_BALANZAD'.
  wa_fieldcat-seltext_m = 'Arrastre'.
  wa_fieldcat-seltext_s = 'Arrastre'.
  wa_fieldcat-seltext_l = 'Arrastre de Saldos'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'SALDO_ANT'.
  wa_fieldcat-tabname = 'IT_BALANZAD'.
  wa_fieldcat-seltext_m = 'Saldo Ant.'.
  wa_fieldcat-seltext_s = 'Saldo Ant.'.
  wa_fieldcat-seltext_l = 'Saldo Anterior'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'DEBE'.
  wa_fieldcat-tabname = 'IT_BALANZAD'.
  wa_fieldcat-seltext_m = 'Debe'.
  wa_fieldcat-seltext_s = 'Debe'.
  wa_fieldcat-seltext_l = 'Debe'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'HABER'.
  wa_fieldcat-tabname = 'IT_BALANZAD'.
  wa_fieldcat-seltext_m = 'Haber'.
  wa_fieldcat-seltext_s = 'Haber'.
  wa_fieldcat-seltext_l = 'Haber'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'SALDO_MES'.
  wa_fieldcat-tabname = 'IT_BALANZAD'.
  wa_fieldcat-seltext_m = 'Saldo Ped.'.
  wa_fieldcat-seltext_s = 'Saldo Ped.'.
  wa_fieldcat-seltext_l = 'Saldo Periodo'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'TOTAL'.
  wa_fieldcat-tabname = 'IT_BALANZAH'.
  wa_fieldcat-do_sum = 'X'.
  wa_fieldcat-seltext_m = 'Total'.
  wa_fieldcat-seltext_s = 'Total'.
  wa_fieldcat-seltext_l = 'total'.
  APPEND wa_fieldcat TO gt_fieldcat.




ENDFORM.

FORM layout_build.
  lf_layout-zebra               = 'X'.   " Streifenmuster
  lf_layout-get_selinfos        = 'X'.
  lf_layout-expand_fieldname = 'IND'.
  lf_layout-expand_all = 'X'.
  lf_layout-colwidth_optimize = 'X'.
ENDFORM. " LAYOUT_BUILD
