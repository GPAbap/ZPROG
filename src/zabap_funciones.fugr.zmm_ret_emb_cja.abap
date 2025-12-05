FUNCTION zmm_ret_emb_cja.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(P_FECHA) LIKE  BAPI_RANGESAUDAT STRUCTURE
*"        BAPI_RANGESAUDAT
*"     VALUE(P_VKORG) LIKE  BAPI_RANGESVKORG STRUCTURE
*"        BAPI_RANGESVKORG OPTIONAL
*"     VALUE(P_VTWEG) LIKE  BAPI_RANGESVTWEG STRUCTURE
*"        BAPI_RANGESVTWEG OPTIONAL
*"     VALUE(P_SPART) LIKE  BAPI_RANGESSPART STRUCTURE
*"        BAPI_RANGESSPART OPTIONAL
*"     VALUE(P_VKBUR) LIKE  BAPI_RANGESVKBUR STRUCTURE
*"        BAPI_RANGESVKBUR OPTIONAL
*"     VALUE(P_KUNNR) LIKE  BAPI_RANGESKUNNR STRUCTURE
*"        BAPI_RANGESKUNNR OPTIONAL
*"  CHANGING
*"     REFERENCE(P_TABLE) TYPE  ANY TABLE OPTIONAL
*"  RAISING
*"      CX_SY_ZERODIVIDE
*"     RESUMABLE(CX_SY_ASSIGN_CAST_ERROR)
*"----------------------------------------------------------------------
  DATA: it_pedidos  TYPE STANDARD TABLE OF st_pedidos,
        it_entregas TYPE STANDARD TABLE OF st_entregas.


  DATA: vl_kgs_dev  TYPE lfimg,
        vl_pzas_dev TYPE i.
  DATA: gen_vbeln TYPE vbeln.

  PERFORM get_data USING p_fecha p_vkorg
                         p_vtweg p_spart
                         p_vkbur p_kunnr
                   CHANGING it_pedidos it_entregas .


  DELETE it_entregas WHERE ( disgr  NE '4002' AND disgr  NE '5001' ).

  SORT it_entregas BY vbeln.
  SORT it_pedidos BY vbeln.

  DATA(it_single_entregas) = it_entregas[].
  DELETE ADJACENT DUPLICATES FROM it_single_entregas COMPARING vbeln.

  LOOP AT it_single_entregas INTO DATA(wa_entregas).

    vl_kgs_dev = REDUCE i( INIT x = '0.000'
                              FOR wa IN it_entregas
                              WHERE ( vbeln = wa_entregas-vbeln AND disgr = '4002')
                              NEXT x = x + wa-lfimg ).

    vl_pzas_dev = vl_kgs_dev / '20.00'.

    vl_pzas_dev = ceil( vl_pzas_dev ).

    READ TABLE it_pedidos INTO DATA(wa_pedidos) WITH KEY vbeln = wa_entregas-vgbel.
    IF sy-subrc EQ 0.
      PERFORM devolucion_cajas TABLES it_entregas USING wa_pedidos
                                                     'PP01'
                                                     vl_pzas_dev
                                                     vl_kgs_dev

                             CHANGING gen_vbeln.
    ENDIF.
  ENDLOOP.



ENDFUNCTION.

FORM f_pedido_venta TABLES pit_entregas TYPE STANDARD TABLE
                           USING i_wapedidos i_werks
                                 vl_pzas_dev vl_kgs_dev
                 CHANGING p_documento TYPE vbak-vbeln.

  DATA: ls_header      TYPE bapisdhd1,
        lt_partners    TYPE STANDARD TABLE OF bapiparnr,
        ls_partner     TYPE bapiparnr,
        lt_items       TYPE STANDARD TABLE OF bapisditm,
        ls_item        TYPE bapisditm,
        ti_itemx       TYPE STANDARD TABLE OF bapisditmx WITH HEADER LINE,
        lt_schedule    TYPE STANDARD TABLE OF bapischdl,
        ls_schedule    TYPE bapischdl,
        ti_schex       TYPE STANDARD TABLE OF bapischdlx WITH HEADER LINE,
        lt_condiciones TYPE STANDARD TABLE OF bapicond,
        ls_condicion   TYPE bapicond,
        ti_condx       TYPE STANDARD TABLE OF bapicondx  WITH HEADER LINE,
        lt_return      TYPE STANDARD TABLE OF bapiret2,
        ls_return      TYPE bapiret2,
        posicion(6)    TYPE n.

  DATA detalle TYPE st_entregas.
  DATA ref_pedido TYPE st_pedidos.

  ref_pedido = i_wapedidos.


  CLEAR: ls_header,
         lt_items[],
         lt_condiciones[],
         lt_partners[],
         lt_schedule[],
         lt_return[].

  ls_header-doc_type = 'ZDEM'.
  ls_header-sales_org = ref_pedido-vkbur.
  ls_header-distr_chan = ref_pedido-vtweg.
  ls_header-division =  ref_pedido-spart.
  ls_header-req_date_h = sy-datlo.

  ls_partner-partn_role = 'AG'.
  ls_partner-partn_numb = ref_pedido-kunnr.
  APPEND ls_partner TO lt_partners.
  posicion = '0'.

  LOOP AT pit_entregas INTO detalle.

    IF detalle-matnr EQ '000000000000250036' OR detalle-matnr EQ '000000000000250037'.

      CLEAR: ls_item,
             ls_condicion,
             ls_schedule.
      posicion = posicion + 10.
      ls_item-itm_number = posicion.
      ls_item-material = detalle-matnr.
      ls_item-target_qty = vl_pzas_dev.
      ls_item-plant = i_werks.
      ls_item-store_loc = 'GPEP'.
      IF detalle-matnr EQ '000000000000250036'.
        ls_item-gross_wght  = vl_kgs_dev.
        ls_item-net_weight  = vl_kgs_dev.
      ELSE.
        ls_item-gross_wght  = 0.
        ls_item-net_weight  = 0.
      ENDIF.
      ls_item-untof_wght  = 'KG'.
      APPEND ls_item TO lt_items.

      ti_itemx-itm_number  = posicion.
      ti_itemx-material    = 'X'.
      ti_itemx-target_qty  = 'X'.
      ti_itemx-plant       = 'X'.
      ti_itemx-store_loc   = 'X'.
      ti_itemx-gross_wght  = 'X'.
      ti_itemx-net_weight  = 'X'.
      ti_itemx-untof_wght  = 'X'.
      APPEND ti_itemx.
      """""


*
*      ls_condicion-itm_number = posicion.
*      ls_condicion-cond_type = 'PCOND'.

*      DATA ld_monto LIKE bapicurr-bapicurr.
*      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
*        EXPORTING
*          currency        = detalle-waerk
*          amount_internal = detalle-kwert
*        IMPORTING
*          amount_external = ld_monto.
*
*      ls_condicion-cond_value = ld_monto.
*      ls_condicion-currency = detalle-waerk.
*      APPEND ls_condicion TO lt_condiciones.

      ls_schedule-itm_number = posicion.
      ls_schedule-req_qty = vl_pzas_dev.
      APPEND ls_schedule TO lt_schedule.

      ti_schex-itm_number = posicion.
      ti_schex-req_qty = 'X'.


    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
    EXPORTING
      order_header_in     = ls_header
      behave_when_error   = space
    IMPORTING
      salesdocument       = p_documento
    TABLES
      return              = lt_return
      order_items_in      = lt_items
      order_partners      = lt_partners
      order_schedules_in  = lt_schedule
      order_conditions_in = lt_condiciones.

  IF p_documento IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = 'X'
      IMPORTING
        return = ls_return.

    COMMIT WORK AND WAIT.
* Pedido de Venta grabado
    MESSAGE ID 'V1' TYPE 'S' NUMBER '311'
    WITH 'Pedido de Venta'(s01)
          p_documento.
  ELSE.
    LOOP AT lt_return INTO ls_return WHERE type = 'E'.
      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
      WITH ls_return-message_v1
           ls_return-message_v2
           ls_return-message_v3
           ls_return-message_v4.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "f_pedido_venta

FORM get_data USING p_fecha LIKE bapi_rangesaudat
                    p_vkorg LIKE bapi_rangesvkorg
                    p_vtweg LIKE bapi_rangesvtweg
                    p_spart LIKE bapi_rangesspart
                    p_vkbur LIKE bapi_rangesvkbur
                    p_kunnr LIKE bapi_rangeskunnr

              CHANGING p_pedidos p_entregas.

  DATA: rg_fecha TYPE STANDARD TABLE OF bapi_rangesaudat,
        wa_fecha LIKE LINE OF rg_fecha,
        rg_vkorg TYPE STANDARD TABLE OF bapi_rangesvkorg,
        wa_vkorg LIKE LINE OF rg_vkorg,
        rg_vtweg TYPE STANDARD TABLE OF bapi_rangesvtweg,
        wa_vtweg LIKE LINE OF rg_vtweg,
        rg_spart TYPE STANDARD TABLE OF bapi_rangesspart,
        wa_spart LIKE LINE OF rg_spart,
        rg_vkbur TYPE STANDARD TABLE OF bapi_rangesvkbur,
        wa_vkbur LIKE LINE OF rg_vkbur,
        rg_kunnr TYPE STANDARD TABLE OF bapi_rangeskunnr,
        wa_kunnr LIKE LINE OF rg_kunnr.


  APPEND p_fecha TO rg_fecha.
  APPEND p_vkorg TO rg_vkorg.
  APPEND p_vtweg TO rg_vtweg.
  APPEND p_spart TO rg_spart.
  APPEND p_vkbur TO rg_vkbur.
  APPEND p_kunnr TO rg_kunnr.




  READ TABLE rg_fecha WITH KEY sign = 'I' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    REFRESH rg_fecha.
  ENDIF.

  READ TABLE rg_vkorg WITH KEY sign = 'I' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    REFRESH rg_vkorg.
  ENDIF.

  READ TABLE rg_vtweg WITH KEY sign = 'I' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    REFRESH rg_vtweg.
  ENDIF.

  READ TABLE rg_spart WITH KEY sign = 'I' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    REFRESH rg_spart.
  ENDIF.

  READ TABLE rg_vkbur WITH KEY sign = 'I' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    REFRESH rg_vkbur.
  ENDIF.

  READ TABLE rg_kunnr WITH KEY sign = 'I' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    REFRESH rg_kunnr.
  ENDIF.


  SELECT e~vbeln , e~erdat, vkorg, vtweg, e~spart, vkbur, kunnr
  INTO TABLE @DATA(it_pedidos)
  FROM vbak AS e
 INNER JOIN vbap AS d ON d~vbeln = e~vbeln
  WHERE e~erdat IN @rg_fecha
  AND vkorg IN @rg_vkorg
  AND vtweg IN @rg_vtweg
  AND e~spart IN @rg_spart
  AND vkbur IN @rg_vkbur
  AND kunnr IN @rg_kunnr.

  IF it_pedidos[] IS NOT INITIAL.

    SELECT vbeln, erdat, lips~matnr, lfimg, lips~werks, disgr , vgbel
      INTO TABLE @DATA(it_entregas)
      FROM lips
    INNER JOIN marc AS m ON m~matnr = lips~matnr AND m~werks = lips~werks
    FOR ALL ENTRIES IN @it_pedidos
    WHERE vgbel = @it_pedidos-vbeln
    AND lips~werks EQ 'PP01'.

    SELECT vbeln, erdat, lips~matnr, lfimg, lips~werks, disgr, vgbel
    FROM lips
    INNER JOIN marc AS m ON m~matnr = lips~matnr AND m~werks = lips~werks
    FOR ALL ENTRIES IN @it_entregas
    WHERE vbeln = @it_entregas-vbeln AND lips~vgbel IS INITIAL
    AND lips~werks EQ 'PP01'
    APPENDING TABLE @it_entregas.



  ENDIF.

  p_pedidos = it_pedidos[].
  p_entregas = it_entregas[].


ENDFORM.

FORM devolucion_cajas TABLES pit_entregas TYPE STANDARD TABLE
                           USING i_wapedidos i_werks
                                 vl_pzas_dev vl_kgs_dev
                 CHANGING p_documento TYPE vbak-vbeln.


  .

  DATA: salesdocumentin         LIKE  bapivbeln-vbeln,
        salesdocument           LIKE  bapivbeln-vbeln,
        return_header_in        LIKE  bapisdhd1,
        return_header_inx       LIKE  bapisdhd1x,
        convert                 LIKE  bapiflag-bapiflag,
        posicion(6)             TYPE n,
        entrega                 TYPE vbeln,

        return_partners         TYPE STANDARD TABLE OF bapiparnr,
        wa_return_partners      LIKE LINE OF return_partners,

        return_items_in         TYPE STANDARD TABLE OF bapisditm,
        wa_return_items_in      LIKE LINE OF return_items_in,

        return_schedules_in     TYPE STANDARD TABLE OF bapischdl,
        wa_return_schedules_in  LIKE LINE OF return_schedules_in,

        return_schedules_inx    TYPE STANDARD TABLE OF bapischdlx,
        wa_return_schedules_inx LIKE LINE OF return_schedules_inx,

        return_items_inx        TYPE STANDARD TABLE OF bapisditmx WITH HEADER LINE,
        lt_return               TYPE STANDARD TABLE OF bapiret2.


  DATA detalle TYPE st_entregas.
  DATA ref_pedido TYPE st_pedidos.

  ref_pedido = i_wapedidos.


  CLEAR:
         return_items_in[],
         return_partners[],
         lt_return[].

*------------------------------------------------------------------
  CLEAR wa_return_partners.
  wa_return_partners-partn_role = 'AG'.
  wa_return_partners-partn_numb = ref_pedido-kunnr.
  APPEND wa_return_partners TO return_partners.

*-------------------------

* Build order header
*------------------------------------------------------------------* Sales document type
  return_header_in-doc_type = 'ZDEM'.
  return_header_inx-doc_type = 'X'.

  "Order Reason
  return_header_in-ord_reason = 'A13'.
  return_header_inx-ord_reason = 'X'. " SD document Category
  return_header_in-sd_doc_cat = 'H'.
  return_header_inx-sd_doc_cat = 'X'. " Reference Document (Invoice)
  " return_header_in-ref_doc = ref_pedido-vbeln. ".
  " return_header_inx-ref_doc = 'X'. " Reference Document Category
  RETURN_header_in-sales_off = ref_pedido-vkbur.
  return_header_inx-sales_off = 'X'.
  return_header_in-sales_org = ref_pedido-vkorg.
  return_header_inx-sales_org = 'X'.
  return_header_in-division = ref_pedido-spart.
  return_header_inx-division = 'X'.
  return_header_in-distr_chan = ref_pedido-vtweg.
  return_header_inx-distr_chan = 'X'.
*return_header_in-purch_no_c = gs_itab5-docid.
*return_header_inx-purch_no_c = gc_x. " Reference Document Category
*return_header_in-refdoc_cat = gc_m.
*return_header_inx-refdoc_cat = gc_x. " Currency
*return_header_in-currency = text-035.
*return_header_inx-currency = gc_x.


  posicion = '0'.

  LOOP AT pit_entregas INTO detalle.

    IF detalle-matnr EQ '000000000000250036' OR detalle-matnr EQ '000000000000250037'.

      CLEAR:  wa_return_items_in.


      posicion = posicion + 10.
      wa_return_items_in-itm_number = posicion.
      wa_return_items_in-material = detalle-matnr.
      wa_return_items_in-target_qty = vl_pzas_dev.
      wa_return_items_in-plant = i_werks.
      wa_return_items_in-store_loc = 'GPEP'.
      IF detalle-matnr EQ '000000000000250036'.
        wa_return_items_in-gross_wght  = vl_kgs_dev.
        wa_return_items_in-net_weight  = vl_kgs_dev.
      ELSE.
        wa_return_items_in-gross_wght  = 0.
        wa_return_items_in-net_weight  = 0.
      ENDIF.
      wa_return_items_in-untof_wght  = 'KG'.
      APPEND  wa_return_items_in TO  return_items_in.

      return_items_inx-itm_number  = posicion.
      return_items_inx-material    = 'X'.
      return_items_inx-target_qty  = 'X'.
      return_items_inx-plant       = 'X'.
      return_items_inx-store_loc   = 'X'.
      return_items_inx-gross_wght  = 'X'.
      return_items_inx-net_weight  = 'X'.
      return_items_inx-untof_wght  = 'X'.
      APPEND return_items_inx.



      wa_return_schedules_in-itm_number = posicion.
      wa_return_schedules_in-req_qty = vl_pzas_dev.
      APPEND wa_return_schedules_in TO return_schedules_in.

      wa_return_schedules_inx-itm_number = posicion.
      wa_return_schedules_inx-req_qty = 'X'.
      APPEND wa_return_schedules_inx TO return_schedules_inx.


    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_CUSTOMERRETURN_CREATE'
    EXPORTING
*     salesdocumentin      = ref_pedido-vbeln.
      return_header_in     = return_header_in
      RETURN_HEADER_INx    = return_header_inx
    IMPORTING
      salesdocument        = p_documento
    TABLES
      return               = lt_return
      return_items_in      = return_items_in
      return_items_inx     = return_items_inx
      return_partners      = return_partners
      return_schedules_in  = return_schedules_in
      return_schedules_inx = return_schedules_inx
*     order_conditions_in  = lt_condiciones
    .

  IF p_documento IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'
*      IMPORTING
*       return = lt_return
      .

    COMMIT WORK AND WAIT.
* Pedido de Venta grabado
    MESSAGE ID 'V1' TYPE 'S' NUMBER '311'
    WITH 'Devolución Número: '(s01)
          p_documento.

    READ TABLE lt_return INTO DATA(wa_vbeln) WITH KEY type = 'S' id = 'V1' number = '260'.
    IF sy-subrc EQ 0.
      entrega = wa_vbeln-message_v3.
      PERFORM contab_entrega USING entrega.
    ENDIF.
  ELSE.
    LOOP AT lt_return INTO DATA(ls_return) WHERE type = 'E'.
      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
      WITH ls_return-message_v1
           ls_return-message_v2
           ls_return-message_v3
           ls_return-message_v4.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDFORM.


FORM contab_entrega USING p_vbeln TYPE vbeln.

  DATA: it_hd    LIKE bapiobdlvhdrcon,
        it_hc    LIKE bapiobdlvhdrctrlcon,
        it_hds   LIKE /spe/bapiobdlvhdrconf,
        it_hcs   LIKE /spe/bapiobdlvhdrctrlcon,
        it_ret   LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        vl_vbeln TYPE vbeln.

  vl_vbeln = |{ p_vbeln ALPHA = IN }|.

  it_hd-deliv_numb  = vl_vbeln.
  it_hc-deliv_numb  = vl_vbeln.
  it_hc-post_gi_flg = 'X'.     "<<<
  it_hds-deliv_numb = vl_vbeln.
  it_hcs-deliv_numb = vl_vbeln.




  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CONFIRM_DEC'
    EXPORTING
      header_data        = it_hd
      header_control     = it_hc
      delivery           = vl_vbeln
      header_data_spl    = it_hds
      header_control_spl = it_hcs
    TABLES
      return             = it_ret.

  READ TABLE it_ret WITH KEY type = 'E'.
  IF sy-subrc NE 0.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
ENDFORM.
