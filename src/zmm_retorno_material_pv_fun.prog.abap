*&---------------------------------------------------------------------*
*& Include          ZMM_RETORNO_MATERIAL_PV_FUN
*&---------------------------------------------------------------------*


*FORM sel_file.
*
*  DATA: lt_file TYPE TABLE OF file_table,
*        ls_file TYPE file_table,
*        lv_file TYPE string,
*        lv_rc   TYPE i.
*
*  CALL METHOD cl_gui_frontend_services=>file_open_dialog
*    EXPORTING
*      window_title            = 'Seleccione su archivo...'
*    CHANGING
*      file_table              = lt_file
*      rc                      = lv_rc
*"     user_action             = gw_user_action
**     file_encoding           =
*    EXCEPTIONS
*      file_open_dialog_failed = 1
*      cntl_error              = 2
*      error_no_gui            = 3
*      not_supported_by_gui    = 4
*      OTHERS                  = 5.
*
*  READ TABLE lt_file INTO ls_file INDEX 1.
*  IF sy-subrc EQ 0.
*    p_file = ls_file-filename.
*    CLEAR ls_file.
*  ENDIF.
*ENDFORM.
*
*FORM load_file.
*  CREATE OBJECT obj_upload.
*  DATA vl_filename TYPE rlgrap-filename.
*  DATA: vl_valida, vl_ok.
*
*  vl_filename = p_file.
*  obj_upload->max_rows = 53000.
*  obj_upload->filename = vl_filename.
*  obj_upload->header_rows_count = 1.
*  obj_upload->upload( CHANGING ct_data = it_interno ).
*
*
*
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form get_datos_material
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM get_datos_material .
*
*  DATA: t_mrp_stock_detail TYPE bapi_mrp_stock_detail,
*        t_mrp_list         TYPE bapi_mrp_list,
*        t_return           TYPE bapiret2.
*
*
*  SELECT charg, matnr
*    INTO TABLE @DATA(it_matnr)
*  FROM afpo
*    FOR ALL ENTRIES IN @it_interno
*  WHERE charg = @it_interno-lote.
*
*  LOOP AT it_matnr INTO DATA(wa_matnr).
*    CALL FUNCTION 'BAPI_MATERIAL_STOCK_REQ_LIST'
*      EXPORTING
*        material         = wa_matnr-matnr
*        plant            = wa_matnr-charg+0(4)              " Plant
*        get_ind_lines    = 'X'              " Indicator: Determination of Single-Line Display
*      IMPORTING
*        mrp_stock_detail = t_mrp_stock_detail
*        mrp_list         = t_mrp_list
*        return           = t_return.
*
*    .
*  ENDLOOP.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_datos
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_datos .


  FIELD-SYMBOLS: <fs_struct> TYPE any, <fs_row> TYPE any, <fs_aux> TYPE any.

  DATA: rg_charg   TYPE RANGE OF mseg-charg,
        wa_rgcharg LIKE LINE OF rg_charg.



  IF sy-sysid EQ 'SPD'.
    gv_uname = 'VIATICOS2'.
  ELSE.
    gv_uname = 'PORTALVTAS'.
  ENDIF.

  "



  SELECT werks, m~matnr, m~charg,
   SUM( CASE WHEN m~bwart EQ '102' THEN m~menge * -1 ELSE m~menge
      END ) AS menge ,
   SUM( CASE WHEN bwart EQ '102' THEN m~/cwm/menge * -1 ELSE m~/cwm/menge END ) AS /cwm/menge
    FROM mseg AS m
    INNER JOIN mkpf AS mk ON mk~mblnr = m~mblnr
  INTO TABLE @DATA(it_mseg)
 WHERE m~usnam_mkpf  = @gv_uname
 " AND m~cpudt_mkpf = @gv_consulta  "del dia de ejecución
  "AND m~budat_mkpf = @gv_consulta
  AND mk~bldat = @gv_consulta
  AND bwart IN ('101','102')
  GROUP BY m~werks,m~matnr, m~charg.


  LOOP AT it_mseg INTO DATA(wa_mseg).
    wa_rgcharg-option = 'EQ'.
    wa_rgcharg-sign = 'I'.
    wa_rgcharg-low = wa_mseg-charg.
    APPEND wa_rgcharg TO rg_charg.
  ENDLOOP.

  IF rg_charg IS NOT INITIAL.
    SELECT charg,
      SUM( klmeng ) AS klmeng, SUM( ntgew ) AS ntgew
    FROM vbap AS v
    WHERE charg IN @rg_charg
      AND ernam  =  @gv_uname
    "AND erdat = @gv_consulta
    AND audat_ana = @gv_consulta
    AND abgru IS INITIAL
    GROUP BY charg
      INTO TABLE @DATA(it_vbap)
         .
  ENDIF.
* " gv_consulta = gv_consulta + 1.
*  SELECT l~charg, SUM( l~lfimg ) AS menge, SUM( l~/cwm/pikmg ) AS ntgew
*"    INTO TABLE @DATA(it_entregas)
*    FROM likp AS k
*    INNER JOIN lips AS l ON l~vbeln = k~vbeln
*    WHERE k~lfdat = @gv_consulta
*    AND k~ernam =  @gv_uname
*     AND l~charg IN @rg_charg
*   GROUP BY l~charg
*  union all
  SELECT l~charg, SUM( l~lfimg ) AS menge, SUM( l~/cwm/pikmg ) AS ntgew
    FROM lips AS l
    INNER JOIN ekko AS e ON e~ebeln = l~vgbel
    WHERE e~bedat = @gv_consulta
    AND e~ernam =  @gv_uname
    GROUP BY l~charg
    INTO TABLE @DATA(it_entregas)
    .


  LOOP AT it_mseg INTO wa_mseg.
    APPEND INITIAL LINE TO it_diferencias ASSIGNING <fs_struct>.
    ASSIGN COMPONENT 'PESO_PROM' OF STRUCTURE <fs_struct> TO <fs_aux>.

    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_struct> TO <fs_row>.
    <fs_row> = wa_mseg-werks.

    ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_struct> TO <fs_row>.
    <fs_row> = wa_mseg-matnr.

    ASSIGN COMPONENT 'CHARG' OF STRUCTURE <fs_struct> TO <fs_row>.
    <fs_row> = wa_mseg-charg.

    ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_struct> TO <fs_row>.
    <fs_row> = wa_mseg-menge.

    ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_struct> TO <fs_row>.
    <fs_row> = wa_mseg-/cwm/menge.

    ASSIGN COMPONENT 'PESO_PROM' OF STRUCTURE <fs_struct> TO <fs_row>.
    <fs_row> = wa_mseg-/cwm/menge / wa_mseg-menge .


    READ TABLE it_vbap INTO DATA(wa_vbap) WITH KEY charg = wa_mseg-charg.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'KLMENG' OF STRUCTURE <fs_struct> TO <fs_row>.
      <fs_row> = wa_vbap-klmeng.

      ASSIGN COMPONENT 'NTGEW' OF STRUCTURE <fs_struct> TO <fs_row>.

      IF wa_vbap-klmeng = wa_vbap-ntgew.

        <fs_row> = wa_vbap-klmeng * <fs_aux>.
      ELSE.
        <fs_row> = wa_vbap-ntgew.
      ENDIF.

    ENDIF.

    READ TABLE it_entregas INTO DATA(wa_entregas) WITH KEY charg = wa_mseg-charg.
    IF sy-subrc EQ 0.

      ASSIGN COMPONENT 'TRAS_PZAS' OF STRUCTURE <fs_struct> TO <fs_row>.
      <fs_row> = wa_entregas-menge.

      ASSIGN COMPONENT 'TRAS_KG' OF STRUCTURE <fs_struct> TO <fs_row>.
      IF wa_entregas-ntgew EQ 0.
        <fs_row> = wa_entregas-menge * <fs_aux>.
        wa_entregas-ntgew = <fs_row>.
      ELSE.
        <fs_row> = wa_entregas-ntgew.

      ENDIF.
    ENDIF.


    ASSIGN COMPONENT 'DIF_PZAS' OF STRUCTURE <fs_struct> TO <fs_row>.
    <fs_row> = abs(  wa_mseg-menge - ( wa_vbap-klmeng + wa_entregas-menge ) ).



    ASSIGN COMPONENT 'DIF_KGS' OF STRUCTURE <fs_struct> TO <fs_row>.
    <fs_row> = abs( wa_mseg-/cwm/menge - ( wa_vbap-ntgew  + wa_entregas-ntgew ) ).

    CLEAR: wa_entregas, wa_vbap.
  ENDLOOP.


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*  DATA: gr_alv TYPE REF TO cl_salv_table.
*  CALL METHOD cl_salv_table=>factory
*    IMPORTING
*      r_salv_table = gr_alv
*    CHANGING
*      t_table      = it_diferencias.
** display ALV
*  gr_alv->display( ).

ENDFORM.

FORM bapi_goodsmvt_create.
  "  Structure: goodsmvt_header
  DATA: vl_goodsmvt_header   TYPE bapi2017_gm_head_01,
        vl_goodsmvt_return   TYPE STANDARD TABLE OF bapiret2,
*  pstng_date       = sy_datum "- (SYSTEM Date)
*  doc_date         = sy_datum "- (SYSTEM Date)
*  gr_gi_slip_no    = 3 "as default
*  ref_doc_no       = aufnr "   - (Production Order) You can maintian any as per your convenience
        "Structure: goodsmvt_code
        vl_goodsmvt_cod      TYPE bapi2017_gm_code,
*gm_code         = 02 as default - (For foods Receipt)
        "Structure: goodsmvt_item
        vl_goodsmvt_item     TYPE STANDARD TABLE OF bapi2017_gm_item_create,
        w_goodsmvt_item      LIKE LINE OF vl_goodsmvt_item,
        vl_GOODSMVT_ITEM_CWM TYPE STANDARD TABLE OF /cwm/bapi2017_gm_item_create,
        w_GOODSMVT_ITEM_CWM  LIKE LINE OF vl_goodsmvt_item_cwm.
*MATERIAL        = AFPO-MATNR        - (Header material of the Production order)
*PLANT           = AFPO-PWERK        - (Plant)
*STGE_LOC        = AFPO-LGORT        - (Storage location)
*MOVE_TYPE       = 101 as default    - (Movement Type for Goods Receipt)
*ENTRY_QNT       = AFPO-PSMNG        - (Yield Quantity to be posted to unrectricted)
*ENTRY_UOM       = AFPO-MEINS        - (Unit Of Measure)
*ORDERPR_UN_ISO  = AFPO-MEINS in T006 as MSEHI to get the ISOCODE - (ISO code)
*ORDERID         = AFPO-AUFNR        - (Production/Purchase/Sales order for reference)
*ORDER_ITNO      = 0001 as default   - (Item Number of the order)
*RESERV_NO       = RESB-RSNUM        - (Pass the reservation number if you need to clear reservation)
*RES_ITEM        = RESB-RSPOS        - (Pass reservation item number if you need to clear reservation)
*MVT_IND         = F as default
  vl_goodsmvt_header-pstng_date = sy-datum.
  vl_goodsmvt_header-doc_date = sy-datum.
  vl_goodsmvt_header-gr_gi_slip_no = 3.
  vl_goodsmvt_header-pr_uname = sy-uname.

  vl_goodsmvt_cod-gm_code = '01'.

  REFRESH: vl_goodsmvt_item, vl_goodsmvt_item_cwm.

  LOOP AT it_diferencias INTO wa_diferencias WHERE dif_pzas > 0 .

    w_goodsmvt_item-material = wa_diferencias-matnr. "'000000000000500022'.
    w_goodsmvt_item-plant = wa_diferencias-werks."'PE04'.
    w_goodsmvt_item-stge_loc = 'GPPT'.
    w_goodsmvt_item-move_type = '102'.
    w_goodsmvt_item-mvt_ind = 'F'.
    w_goodsmvt_item-entry_qnt = abs( wa_diferencias-dif_pzas ). "'40'.
    w_goodsmvt_item-entry_uom = 'PZA'.

    w_goodsmvt_item-order_itno ='0001'.
    w_goodsmvt_item-batch = wa_diferencias-charg. "'PE04230201'.
    w_goodsmvt_item-orderid = wa_diferencias-charg. "'PE04230201'.
    APPEND w_goodsmvt_item TO vl_goodsmvt_item.

    w_goodsmvt_item_cwm-matdoc_itm = '0001'.
    w_goodsmvt_item_cwm-quantity_pme = abs( wa_diferencias-dif_pzas )."'40'.
    w_goodsmvt_item_cwm-entry_qnt_pme = abs( wa_diferencias-dif_kgs ). "'110'.
    w_goodsmvt_item_cwm-entry_uom_pme = 'KG'.

    APPEND w_goodsmvt_item_cwm TO vl_goodsmvt_item_cwm.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header   = vl_goodsmvt_header
        goodsmvt_code     = vl_goodsmvt_cod
*       TESTRUN           = ' '
      TABLES
        goodsmvt_item     = vl_goodsmvt_item
        goodsmvt_item_cwm = vl_goodsmvt_item_cwm
        return            = vl_goodsmvt_return.

    IF vl_goodsmvt_return IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ELSE.
      " se guarda Log del error.
      LOOP AT vl_goodsmvt_return INTO DATA(wa_log1).
        wa_log-ztype = wa_log1-type.
        wa_log-zfecha = sy-datum.
        wa_log-ztime = sy-uzeit.
        wa_log-zfield = wa_log1-field.
        wa_log-zid = wa_log1-id.
        wa_log-zlog_msg_no = wa_log1-log_msg_no.
        wa_log-zlog_no = wa_log1-log_no.
        wa_log-zmessage = wa_log1-message.
        wa_log-zmessage_v1 = wa_log1-message_v1.
        wa_log-zmessage_v2 = wa_log1-message_v2.
        wa_log-zmessage_v3 = wa_log1-message_v3.
        wa_log-zmessage_v4 = wa_log1-message_v4.
        wa_log-znumber = wa_log1-number.
        wa_log-zparameter = wa_log1-parameter.
        wa_log-zrow = wa_log1-row.
        wa_log-zsystem = wa_log1-system.
        APPEND wa_log TO it_log.
      ENDLOOP.
      TRY.
          INSERT zlog_dev_mm_migo FROM TABLE it_log.
        CATCH cx_sql_exception.

      ENDTRY.
    ENDIF.

    REFRESH: vl_goodsmvt_item,
         vl_goodsmvt_item_cwm,
         vl_goodsmvt_return.


  ENDLOOP.


ENDFORM.
