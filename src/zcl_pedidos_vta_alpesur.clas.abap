class ZCL_PEDIDOS_VTA_ALPESUR definition
  public
  final
  create public .

public section.

  types:
    rg_sectores  TYPE RANGE OF vbak-spart .
  types:
    rg_dzterm    TYPE RANGE OF zsd_tt_plantsan-dzterm .
  types:
    rg_form_pago TYPE RANGE OF zsd_tt_plantsan-formapago .

  methods GET_SECTORES
    importing
      !I_TT_PEDIDOS type STANDARD TABLE
    exporting
      !E_SECTORES type RG_SECTORES .
  methods GET_COND_PREC
    importing
      !I_TT_PEDIDOS type STANDARD TABLE
    exporting
      !E_DZTERM type RG_DZTERM .
  methods GET_FORM_PAGO
    importing
      !I_TT_PEDIDOS type STANDARD TABLE
    exporting
      !E_FORM_PAGO type RG_FORM_PAGO .
  methods GET_VPG
    importing
      !I_SECTOR type SPART
      !I_C_VPG type KUNNR
      !I_TT_PEDIDOS type STANDARD TABLE
    changing
      !C_VPG type STANDARD TABLE
      !C_VPGI type STANDARD TABLE .
  methods GET_NOVPG
    importing
      !I_SECTOR type SPART
      !I_C_VPG type KUNNR
      !I_TT_PEDIDOS type STANDARD TABLE
    changing
      !C_VPG type STANDARD TABLE
      !C_VPGI type STANDARD TABLE .
  methods SET_CREA_VPG
    importing
      !I_SECTOR type SPART
      !I_INDICAVPG type C
      !I_TT_PEDIDOS type STANDARD TABLE
      !I_TT_PEDIDOSI type STANDARD TABLE .
  methods BAPI_CREAR_PEDIDO
    importing
      !I_TT_PEDIDOS type STANDARD TABLE .
protected section.
private section.

  data:
    ztt_pedidos TYPE STANDARD TABLE OF zsd_st_datos_pedidos .
  data:
    ztt_pedidos_bapi0 TYPE STANDARD TABLE OF zsd_st_datos_pedidos .
  data:
    ztt_pedidos_bapi1 TYPE STANDARD TABLE OF zsd_st_datos_pedidos .
  data:
    ztt_vpg  TYPE STANDARD TABLE OF zsd_st_datos_pedidos .
  data:
    ztt_vpgi TYPE STANDARD TABLE OF zsd_st_datos_pedidos .
  data:
    workarea LIKE LINE OF ztt_pedidos .
  data:
    logic_switch TYPE STANDARD TABLE OF  bapisdls INITIAL SIZE 0 .
  data HEADER type BAPISDHD1 .
  data HEADERX type BAPISDHD1X .
  data:
    item    TYPE STANDARD TABLE OF bapisditm  INITIAL SIZE 0 .
  data:
    itemx   TYPE STANDARD TABLE OF bapisditmx INITIAL SIZE 0 .
  data:
    partner TYPE STANDARD TABLE OF bapiparnr  INITIAL SIZE 0 .
  data:
    itext   TYPE STANDARD TABLE OF bapisdtext INITIAL SIZE 0 .
  data:
    return  TYPE STANDARD TABLE OF bapiret2   INITIAL SIZE 0 .
  data:
    return_all TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0 .
  data:
    lt_schedules_inx   TYPE STANDARD TABLE OF  bapischdlx .
  data:
    lt_schedules_in    TYPE STANDARD TABLE OF bapischdl .
  data:
    order_cond TYPE STANDARD TABLE OF bapicond INITIAL SIZE 0 .
  data:
    order_condx TYPE STANDARD TABLE OF bapicondx INITIAL SIZE 0 .
ENDCLASS.



CLASS ZCL_PEDIDOS_VTA_ALPESUR IMPLEMENTATION.


METHOD bapi_crear_pedido.

    REFRESH ztt_pedidos.

    ztt_pedidos = i_tt_pedidos[].
    DATA lv_mensaje TYPE string.

    DATA: it_logp   TYPE STANDARD TABLE OF zsd_tt_logsanp,
          it_logh   TYPE STANDARD TABLE OF zsd_tt_logsanh,
          wa_logp   LIKE LINE OF it_logp,
          wa_logh   LIKE LINE OF it_logh,
          posnr_aux TYPE posnr, contador TYPE i,
          v_vbeln   TYPE vbeln_va.

    DATA: it_pedvssan TYPE STANDARD TABLE OF zsd_tt_pedticsan,
          wa_pedvssan LIKE LINE OF it_pedvssan.
    DATA: it_pedvssan2 TYPE STANDARD TABLE OF zsd_tt_pedticsan,
          wa_pedvssan2 LIKE LINE OF it_pedvssan2.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA: w_logic_switch     LIKE LINE OF logic_switch,
          w_partner          LIKE LINE OF partner,
          w_item             LIKE LINE OF item,
          w_itemx            LIKE LINE OF itemx,
          w_order_cond       LIKE LINE OF order_cond,
          w_order_condx      LIKE LINE OF order_condx,
          w_lt_schedules_in  LIKE LINE OF lt_schedules_in,
          w_lt_schedules_inx LIKE LINE OF lt_schedules_inx,
          w_itext            LIKE LINE OF itext.


    DATA: indice      TYPE i, t TYPE i,
          dsched_line TYPE char4.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    t = 0.

    dsched_line = '0001'.
    indice = 1.


    LOOP AT ztt_pedidos INTO DATA(wa_pedidos).

      w_logic_switch-cond_handl = 'X'.

** HEADER DATA
      header-doc_type = wa_pedidos-auart. "Clase de documento
      headerx-doc_type = 'X'.
      header-sales_org = wa_pedidos-vkorg. "Organizacion de ventas
      headerx-sales_org = 'X'.
      header-bill_block = ''. "Para evitar bloqueo de Factura
      headerx-bill_block = 'X'.
      header-ref_1  = '0000'.
      headerx-ref_1 = 'X'.

      IF wa_pedidos-vkorg = 'AV02' OR wa_pedidos-vkorg = 'AV06' OR wa_pedidos-vkorg = 'AV03'.
        header-ord_reason = 'A05'.
        headerx-ord_reason  = 'X'.
      ENDIF.
************** *********************************
      header-distr_chan  = wa_pedidos-vtweg. "canal de distribucion.
      headerx-distr_chan = 'X'.
      header-division = wa_pedidos-spart. "Sector
      headerx-division = 'X'.
      header-sales_grp = wa_pedidos-vkgrp. "Grupo de Vendedores
      headerx-sales_grp = 'X'.
      header-sales_off = wa_pedidos-vkbur. "Oficina de Ventas
      headerx-sales_off = 'X'.
      header-req_date_h = sy-datum. "fecha preferente de entrega
      headerx-req_date_h = 'X'.
      header-purch_date = sy-datum. "Fecha Referencia del cliente
      headerx-purch_date = 'X'.
      header-purch_no_c = wa_pedidos-bstkd. "Datos referencia Cliente
      headerx-purch_no_c = 'X'.
      header-currency = wa_pedidos-waerk. "Moneda
      headerx-currency = 'X'.
      headerx-updateflag = 'I'.

******* AJUSTE CABECERA
      header-cust_grp1 = wa_pedidos-cust_grp1. "METODO DE PAGO
      headerx-cust_grp1 = 'X'.
*
*    header-CUST_GRP2 = wa_pedidos-CUST_GRP2. "FORMA
      IF wa_pedidos-metpag EQ space.
        header-cust_grp2 = 'PUE'. "FORMA
      ELSE.
        header-cust_grp2 = wa_pedidos-metpag. "FORMA
      ENDIF.

      headerx-cust_grp2 = 'X'.
      "************* Se agrega la clase de pedido de Ventas de Mostrador, porque son de deposito. en Hana.
      header-po_method = wa_pedidos-bsark.
      headerx-po_method = 'X'.
***=======================================================28/11/2022
** PARTNER DATA
      w_partner-partn_role = 'AG'.
      w_partner-partn_numb = wa_pedidos-sold. "Cliente
      APPEND w_partner TO partner.

      w_partner-partn_role = 'WE'.
      w_partner-partn_numb = wa_pedidos-ship. "Envio Cliente
      APPEND w_partner TO partner.


* ITEM DATA
      w_itemx-updateflag = 'I'.
      w_item-material = wa_pedidos-matnr. "MAterial
      w_itemx-material = 'X'.
      w_item-exchg_rate = wa_pedidos-kursk. "tipo de cambio
      w_itemx-exchg_rate = 'X'.
      w_item-target_qty = wa_pedidos-bmeng. " Cantidad Prevista
      w_itemx-target_qty = 'X'.
      w_item-target_qu = wa_pedidos-vrkme. "unidad de medida "'EA'.
      w_itemx-target_qu = 'X'.
      w_item-itm_number = wa_pedidos-posnr.    "posicion del documento                               "'000010'.
      w_itemx-itm_number = wa_pedidos-posnr. "corregido por Michael Chavez
      w_item-purch_no_s = wa_pedidos-ticket.
      w_itemx-purch_no_s = 'X'.
* Se omite, dado que el dato maeatro trae la clase correspondiente-
*     item-PMNTTRMS = wa_pedidos-dzterm. "Clase de condiciones de pago
*     itemx-PMNTTRMS = 'X'.
*---------------28/11/2022
      w_item-route = wa_pedidos-route. "ruta
      w_itemx-route = 'X'.
      " Se cambia a GPPT debido a que en Hana, todos los productos que se venden en depositos  vienen de ese almacen.
      w_item-store_loc = 'GPPT'. "wa_pedidos-lgort. "Almacen
      w_itemx-store_loc = 'X'.

      w_item-plant    = wa_pedidos-werks. "Centro
      w_itemx-plant   = 'X'.

*   Fill schedule lines
      w_lt_schedules_in-itm_number = wa_pedidos-posnr.      "'000010'.
      w_lt_schedules_in-sched_line = dsched_line.
      w_lt_schedules_in-req_qty    = wa_pedidos-kwmeng.

*   Fill schedule line flags
      w_lt_schedules_inx-itm_number  = wa_pedidos-posnr.    "'000010'.
      w_lt_schedules_inx-sched_line  = dsched_line.
      w_lt_schedules_inx-updateflag  = 'X'.
      w_lt_schedules_inx-req_qty     = 'X'.

      w_order_cond-itm_number   = wa_pedidos-posnr."posicion.
      w_order_condx-itm_number   = wa_pedidos-posnr. "corregido Michael TAMBIEN LLEVANUMERO
      w_order_cond-cond_type    = wa_pedidos-dzterm.""'ZP01'.
      w_order_condx-cond_type    = 'X'.
      w_order_cond-cond_value   = wa_pedidos-kbetr. "monto
      w_order_condx-cond_value   = 'X'.
      w_order_cond-currency     = wa_pedidos-waerk."moneda.
      w_order_condx-currency    = 'X'.
************ PRUEBA MICHAEL MODIFICACIONES 04.09.2020 INI
      w_order_cond-cond_updat   = 'X'.
      w_order_condx-updateflag  = 'U'.
************ PRUEBA MICHAEL MODIFICACIONES 04.09.2020 FIN

      IF wa_pedidos-texto IS NOT INITIAL.
        w_itext-text_id = '0001'.
        w_itext-langu = 'E'.
        w_itext-text_line = wa_pedidos-texto. "texto de cabecera
        w_itext-function = '005'.
        APPEND w_itext TO itext.
      ENDIF.

      APPEND w_item TO item.
      APPEND w_itemx TO itemx.
      APPEND w_lt_schedules_in TO lt_schedules_in.
      APPEND w_lt_schedules_inx TO lt_schedules_inx.
      APPEND w_order_cond TO order_cond.
      APPEND w_order_condx TO order_condx.
      APPEND w_logic_switch TO logic_switch.

      IF wa_pedidos-desc NE space.
        w_order_cond-itm_number   = wa_pedidos-posnr."posicion.
        w_order_condx-itm_number   = wa_pedidos-posnr. "corregido Michael TAMBIEN LLEVANUMERO
        w_order_cond-cond_type    = wa_pedidos-desc.""'ZP01'.
        w_order_condx-cond_type    = 'X'.
        w_order_cond-cond_value   = wa_pedidos-porc. "monto
        w_order_condx-cond_value   = 'X'.
        w_order_cond-calctypcon   = wa_pedidos-tippor.
        w_order_cond-currency     = ''."moneda.
        w_order_cond-cond_unit    = ''."i_tab_dtl-kmein.
        APPEND w_order_cond TO order_cond.
      ENDIF.

********* TABLA RELACIón PEDIDOS vs SAN
      READ TABLE it_pedvssan INTO wa_pedvssan WITH KEY ticket = wa_pedidos-ticket.

      IF sy-subrc NE 0.

        wa_pedvssan-ticket = wa_pedidos-ticket.
        wa_pedvssan-posnr = wa_pedidos-posnr.
        wa_pedvssan-werks = wa_pedidos-werks.
        wa_pedvssan-bsark = wa_pedidos-bsark.
*      wa_pedvssan-vbeln = wa_pedidos-vbeln.

        APPEND wa_pedvssan TO it_pedvssan.

      ENDIF.
***** MODIFICACIONES MICHAEL 18.08.2020 FIN
      indice = indice + 1.

      READ TABLE ztt_pedidos INTO wa_pedidos WITH KEY row = indice."indice + 1.
      IF sy-subrc EQ 0.
        posnr_aux = wa_pedidos-posnr.
      ELSE.
        posnr_aux = '000010'.

      ENDIF.

      IF posnr_aux = '000010'.

* Call the BAPI
*        GET RUN TIME FIELD t1.
        REFRESH return.
        CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2' "'BAPI_SALESDOCU_CREATEFROMDATA1'
          EXPORTING
            order_header_in      = header
            order_header_inx     = headerx
            logic_switch         = w_logic_switch
          IMPORTING
            salesdocument        = v_vbeln
          TABLES
            return               = return
            order_items_in       = item[]
            order_items_inx      = itemx[]
            order_schedules_in   = lt_schedules_in[]
            order_schedules_inx  = lt_schedules_inx[]
            order_partners       = partner
            order_conditions_in  = order_cond[]
            order_conditions_inx = order_condx[]
            order_text           = itext.

        CLEAR header.
        CLEAR headerx.
        REFRESH partner.
        REFRESH item.

        REFRESH itemx.
        REFRESH lt_schedules_in.
        REFRESH lt_schedules_inx.
        REFRESH order_cond.
        REFRESH order_condx.
        REFRESH itext.

        "      GET RUN TIME FIELD t2.

        contador = contador + 1.

        IF v_vbeln IS NOT INITIAL.
          TRY.
            update zsd_tt_san_files set procesado = 'X' where ruta_file = wa_pedidos-p_file.
          CATCH cx_sy_sql_error .
              MESSAGE s001(00) WITH 'No update File in table'.
          ENDTRY.

**************
          LOOP AT it_pedvssan INTO wa_pedvssan.

            IF v_vbeln NE space.
              wa_pedvssan2-ticket = wa_pedvssan-ticket.
              wa_pedvssan2-posnr = wa_pedvssan-posnr.
              wa_pedvssan2-werks = wa_pedvssan-werks.
              wa_pedvssan2-vbeln = v_vbeln.
              wa_pedvssan2-fechacrea = sy-datum.
              wa_pedvssan2-bsark = wa_pedvssan-bsark.

              INSERT zsd_tt_pedticsan FROM wa_pedvssan2.

            ENDIF.


          ENDLOOP.

          CLEAR: wa_pedvssan, wa_pedvssan2.
          REFRESH: it_pedvssan, it_pedvssan2.
**************
*
*          READ TABLE ztt_pedidos INTO wa_pedidos WITH KEY row = indice.
*          wa_pedidosg-vbeln = v_vbeln.
*          wa_pedidosg-auart = wa_pedidos-auart.
*          wa_pedidosg-vkorg = wa_pedidos-vkorg.
*          wa_pedidosg-vtweg = wa_pedidos-vtweg.
*          wa_pedidosg-spart = wa_pedidos-spart.
*          wa_pedidosg-route = wa_pedidos-route.
*          wa_pedidosg-lgort = wa_pedidos-lgort.
*          wa_pedidosg-bstdk = wa_pedidos-bstdk.
*          wa_pedidosg-sold  = wa_pedidos-sold.
*          wa_pedidosg-name1 = wa_pedidos-name1.
*          wa_pedidosg-bmeng = wa_pedidos-bmeng.
*          wa_pedidosg-kbetr = last_price. "wa_pedidos-kbetr.
*          wa_pedidosg-status = 'Creado'.
*          APPEND wa_pedidosg TO it_pedidosg.
*
*********************************** MICHAEL CREACION DE PEDIDO ************
*          wa_zpedido-vbeln = v_vbeln.
*          wa_zpedido-fechacrea = sy-datum.
*          wa_zpedido-auart = wa_pedidos-auart.
*          wa_zpedido-vkorg = wa_pedidos-vkorg.
*          wa_zpedido-vtweg = wa_pedidos-vtweg.
*          wa_zpedido-spart = wa_pedidos-spart.
*          wa_zpedido-route = wa_pedidos-route.
*          wa_zpedido-lgort = wa_pedidos-lgort.
*          wa_zpedido-bstdk = wa_pedidos-bstdk.
*          wa_zpedido-sold  = wa_pedidos-sold.
*          wa_zpedido-name1 = wa_pedidos-name1.
*          wa_zpedido-bmeng = wa_pedidos-bmeng.
*          wa_zpedido-kbetr = last_price. "wa_pedidos-kbetr.
*          wa_zpedido-bsark = wa_pedidos-bsark.
*
*
*          INSERT zsd_tt_pedcreaut FROM wa_zpedido.
********************************** MICHAEL CREACION DE PEDIDO ************
          COMMIT WORK AND WAIT.
        ELSE.
          CLEAR lv_mensaje.
          LOOP AT it_pedvssan INTO wa_pedvssan.

            LOOP AT return INTO DATA(wa_ret) WHERE ( type = 'E' OR type = 'A' OR type = 'W' ) AND number NE 219.
              wa_logp-ticket = wa_pedvssan-ticket.
              wa_logp-pos    = wa_pedvssan-posnr.
              wa_logp-auart = wa_pedidos-auart.
              wa_logp-vkorg = wa_pedidos-vkorg.
              wa_logp-vtweg = wa_pedidos-vtweg.
              wa_logp-spart = wa_pedidos-spart.
              wa_logp-route = wa_pedidos-route.
              wa_logp-lgort = wa_pedidos-lgort.
              wa_logp-bstdk = wa_pedidos-bstdk.
              wa_logp-sold  = wa_pedidos-sold.
              wa_logp-name1 = wa_pedidos-name1.
              wa_logp-bmeng = wa_pedidos-bmeng.
              wa_logp-kbetr = wa_pedidos-kbetr.
              CONCATENATE wa_ret-message wa_ret-message_v1
                          wa_ret-message_v2 wa_ret-message_v3
                          wa_ret-message_v4 INTO lv_mensaje SEPARATED BY space.

              wa_logp-message = lv_mensaje.
            ENDLOOP.

            SELECT SINGLE ticket
              FROM zsd_tt_logsanh
              INTO @DATA(it_nocrea2)
              WHERE ticket = @wa_pedvssan-ticket.

            wa_logh-ticket = wa_pedvssan-ticket.
            wa_logh-werks = wa_pedvssan-werks.
            wa_logh-fecha = wa_pedvssan-fechacrea.


            IF it_nocrea2 IS NOT INITIAL.
              INSERT zsd_tt_logsanp FROM wa_logp.
            ELSE.
              INSERT zsd_tt_logsanp FROM wa_logp.
              INSERT zsd_tt_logsanh FROM wa_logh.
            ENDIF.
          ENDLOOP.

*          CLEAR: wa_nocreados.
*          REFRESH: it_nocreados,
          REFRESH it_pedvssan.

        ENDIF.
      ENDIF.
    ENDLOOP.
** Check the return table.
*    LOOP AT return_all WHERE type = 'E' OR type = 'A'.
*      EXIT.
*    ENDLOOP.

*
*    CLEAR it_tab.REFRESH it_tab.

  ENDMETHOD.


METHOD get_cond_prec.
    DATA lt_ztt_pedidos TYPE STANDARD TABLE OF zsd_st_datos_pedidos.
    DATA wa_dzterm LIKE LINE OF e_dzterm.

    lt_ztt_pedidos = i_tt_pedidos[].

    SORT lt_ztt_pedidos BY dzterm.

    DELETE ADJACENT DUPLICATES FROM lt_ztt_pedidos COMPARING dzterm.

    LOOP AT lt_ztt_pedidos INTO DATA(wa_pedidos).
      CLEAR wa_dzterm.
      wa_dzterm-option = 'EQ'.
      wa_dzterm-sign = 'I'.
      wa_dzterm-low = wa_pedidos-dzterm.
      APPEND wa_dzterm TO e_dzterm.

    ENDLOOP.


  ENDMETHOD.


METHOD get_form_pago.
    DATA lt_ztt_pedidos TYPE STANDARD TABLE OF zsd_st_datos_pedidos.
    DATA wa_f_pago LIKE LINE OF e_form_pago.

    lt_ztt_pedidos = i_tt_pedidos[].

    SORT lt_ztt_pedidos BY cust_grp1.

    DELETE ADJACENT DUPLICATES FROM lt_ztt_pedidos COMPARING cust_grp1.

    LOOP AT lt_ztt_pedidos INTO DATA(wa_pedidos).
      CLEAR wa_f_pago.
      wa_f_pago-option = 'EQ'.
      wa_f_pago-sign = 'I'.
      wa_f_pago-low = wa_pedidos-cust_grp1.
      APPEND wa_f_pago TO e_form_pago.

    ENDLOOP.


  ENDMETHOD.


METHOD get_novpg.
    DATA row    TYPE i.
    DATA lv_rfc TYPE stcd1.

    REFRESH: ztt_pedidos, ztt_vpg, ztt_vpgi.

    ztt_pedidos = i_tt_pedidos[].
    row = 0.
    LOOP AT ztt_pedidos INTO DATA(wa_pedidos) WHERE vpg <> 'X' AND spart = i_sector.
      CLEAR lv_rfc.
      MOVE-CORRESPONDING wa_pedidos TO workarea.
      workarea-row = row.
      " se determina el RFC generico o nominativo
      SELECT SINGLE CASE WHEN stcd1 IS INITIAL THEN stcd3 ELSE stcd1 END AS rfc
        FROM kna1
        WHERE kunnr = @workarea-sold
        INTO @lv_rfc.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      IF workarea-sold = i_c_vpg. " si el dato de SAN del cliente es igual al cliente VPG registrado por Centro
        row += 10.
        workarea-row   = 1.
        workarea-posnr = row.
        workarea-sold  = i_c_vpg.
        workarea-ship  = i_c_vpg.
        CONCATENATE workarea-bstkd(11) 'VPG' INTO workarea-bstkd SEPARATED BY space.
      ELSE.
        IF lv_rfc <> 'XAXX010101000'. " si el RFC no es generico, entonces es de un cliente nominativo
          row += 10.
          workarea-row   = 1.
          workarea-posnr = row.
          "workarea-sold  = i_c_vpg. "cliente nominativo
          "workarea-ship  = i_c_vpg. "cliente nominativo
          CONCATENATE workarea-bstkd(11) 'VPG' INTO workarea-bstkd SEPARATED BY space.
        ELSE.
          workarea-row = 1. " ajuste 3 de febrero automatización
          CONCATENATE workarea-bstkd(11) 'VPG' INTO workarea-bstkd SEPARATED BY space.
          workarea-posnr = 10.
          APPEND workarea TO ztt_vpgi.
        ENDIF.
      ENDIF.

      APPEND workarea TO ztt_vpg.

    ENDLOOP.

    " se ordenan los tickets"""""""""""""""""""""""""""""""""""""""""""
    SORT ztt_vpg BY ticket.
    CLEAR row.
    row = 0.
    LOOP AT ztt_vpg ASSIGNING FIELD-SYMBOL(<fs_vpg>).
      row += 10.
      <fs_vpg>-posnr = row.

      AT END OF ticket.
        row = 0.
      ENDAT.
    ENDLOOP.

    """"""""""""""""""""""""""""""""""""""
    SORT ztt_vpgi BY ticket.
    CLEAR row.
    row = 0.
    LOOP AT ztt_vpgi ASSIGNING FIELD-SYMBOL(<fs_vpgi>).
      row += 10.
      <fs_vpgi>-posnr = row.

      AT END OF ticket.
        row = 0.
      ENDAT.
    ENDLOOP.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""

    c_vpg = ztt_vpg.
    c_vpgi = ztt_vpgi.
  ENDMETHOD.


METHOD get_sectores.

    DATA wa_sectores LIKE LINE OF e_sectores.

    ztt_pedidos = i_tt_pedidos[].

    SORT ztt_pedidos BY spart.

    DELETE ADJACENT DUPLICATES FROM ztt_pedidos COMPARING spart.

    LOOP AT ztt_pedidos INTO DATA(wa_pedidos).
      CLEAR wa_sectores.
      wa_sectores-option = 'EQ'.
      wa_sectores-sign = 'I'.
      wa_sectores-low = wa_pedidos-spart.
      APPEND wa_sectores TO e_sectores.

    ENDLOOP.

  ENDMETHOD.


METHOD get_vpg.

    DATA: row    TYPE i,
          lv_rfc TYPE stcd1.

    REFRESH: ztt_pedidos, ztt_vpg, ztt_vpgi.

    ztt_pedidos = i_tt_pedidos[].
    row = 0.
    LOOP AT ztt_pedidos INTO DATA(wa_pedidos) WHERE vpg = 'X' AND spart = i_sector.
      CLEAR lv_rfc.
      MOVE-CORRESPONDING wa_pedidos TO workarea.
      workarea-row = row.
      "se determina el RFC generico o nominativo
      SELECT SINGLE CASE WHEN stcd1 IS INITIAL THEN stcd3 ELSE stcd1 END AS rfc
      FROM kna1
      WHERE kunnr = @workarea-sold
      INTO @lv_rfc.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      IF workarea-sold EQ i_c_vpg. "si el dato de SAN del cliente es igual al cliente VPG registrado por Centro
        row = row + 10.
        workarea-row = 1.
        workarea-posnr = row.
        workarea-sold = i_c_vpg.
        workarea-ship = i_c_vpg.
        CONCATENATE workarea-bstkd(11) 'VPG' INTO workarea-bstkd SEPARATED BY space.
      ELSE.
        IF lv_rfc NE 'XAXX010101000'. "si el RFC no es generico, entonces es de un cliente nominativo
          row = row + 10.
          workarea-row = 1.
          workarea-posnr = row.
*          workarea-sold = i_c_vpg.
*          workarea-ship = i_c_vpg.
          CONCATENATE workarea-bstkd(11) 'VPG' INTO workarea-bstkd SEPARATED BY space.
        ELSE.
          workarea-row = 1. "ajuste 3 de febrero automatización
          CONCATENATE workarea-bstkd(11) 'VPG' INTO workarea-bstkd SEPARATED BY space.
          workarea-posnr = 10.
          APPEND workarea TO ztt_vpgi.
        ENDIF.
      ENDIF.

      APPEND workarea TO ztt_vpg.

    ENDLOOP.

    "se ordenan los tickets"""""""""""""""""""""""""""""""""""""""""""
    SORT ztt_vpg BY ticket.
    CLEAR row.
    row = 0 + 10.
    LOOP AT ztt_vpg ASSIGNING FIELD-SYMBOL(<fs_vpg>).
      <fs_vpg>-posnr = row.
    ENDLOOP.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    c_vpg = ztt_vpg.
    c_vpgi = ztt_vpgi.
  ENDMETHOD.


METHOD set_crea_vpg.
    DATA rg_dzterm TYPE RANGE OF zsd_tt_plantsan-dzterm.
    DATA rg_form_pag TYPE RANGE OF zsd_tt_plantsan-formapago.
    DATA lv_ztable TYPE STANDARD TABLE OF zsd_st_datos_pedidos.

    REFRESH ztt_pedidos.
    DATA: row  TYPE i, nrow TYPE i.

    ztt_pedidos = i_tt_pedidos[].

    SORT ztt_pedidos BY dzterm.
    refresh rg_dzterm.
    me->get_cond_prec(
      EXPORTING
        i_tt_pedidos = ztt_pedidos
      IMPORTING
         e_dzterm     = rg_dzterm
    ).




    LOOP AT rg_dzterm INTO DATA(wa_dzterm).
*      LOOP AT ztt_pedidos INTO DATA(wa_pedidos) WHERE dzterm = wa_dzterm and spart = i_sector.
      REFRESH ztt_pedidos_bapi0.
      REFRESH ztt_pedidos_bapi1.
      ztt_pedidos_bapi0 = i_tt_pedidos.
      SORT ztt_pedidos_bapi0 BY dzterm.
      DELETE ztt_pedidos_bapi0 WHERE dzterm NE wa_dzterm-low.
      IF ztt_pedidos_bapi0 IS NOT INITIAL.
        """"""""""""""""""""""""""""""""""""""""""""""""""""
        """"""se separan por metodo de pago.
         refresh rg_form_pag.
        """""""""""""""""""""""""""""""""""""""""""""""""""""
        me->get_form_pago(
          EXPORTING
            i_tt_pedidos = ztt_pedidos
          IMPORTING
             e_form_pago = rg_form_pag
        ).

        SORT ztt_pedidos_bapi0 BY ticket.
        LOOP AT  ztt_pedidos_bapi0 INTO DATA(wa_ped_bapi).
          wa_ped_bapi-row = 0.
          MODIFY ztt_pedidos_bapi0 FROM wa_ped_bapi INDEX sy-tabix TRANSPORTING row.
        ENDLOOP.

        """""""""""""""""""""""""""""""""""""""""""""""""""""
        LOOP AT rg_form_pag INTO DATA(wa_f_pago).

          ztt_pedidos_bapi1[] = ztt_pedidos_bapi0[].
          SORT ztt_pedidos_bapi1 BY cust_grp1.
          DELETE ztt_pedidos_bapi1 WHERE cust_grp1 NE wa_f_pago-low.
          IF ztt_pedidos_bapi1 IS NOT INITIAL.

            IF i_indicavpg EQ abap_false. "Si es X es VPG TODO SE AGRUPA, sino se separan por ticket.
              CLEAR row.
              row = 0.
              nrow = 0.
              LOOP AT ztt_pedidos_bapi1 ASSIGNING FIELD-SYMBOL(<fs_vpgi>).
                row += 10.
                "nrow =  nrow + 1.
                <fs_vpgi>-posnr = row.
                "<fs_vpgi>-row = nrow.
                AT END OF ticket.
                  row = 0.
                ENDAT.
              ENDLOOP.
            ELSE. "si es vpg
              CLEAR row.
              row = 0.
              nrow = 0.
              LOOP AT ztt_pedidos_bapi1 ASSIGNING <fs_vpgi>.
                row += 10.
                nrow = nrow + 1.
                <fs_vpgi>-posnr = row.
                <fs_vpgi>-row = nrow.
              ENDLOOP.
            ENDIF.
            clear wa_ped_bapi.
            nrow = 0.
            LOOP AT  ztt_pedidos_bapi1 INTO wa_ped_bapi.
            nrow = nrow + 1.
              wa_ped_bapi-row = nrow.
              MODIFY ztt_pedidos_bapi1 FROM wa_ped_bapi INDEX sy-tabix TRANSPORTING row.
            ENDLOOP.

            me->bapi_crear_pedido( i_tt_pedidos =  ztt_pedidos_bapi1 ).
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDLOOP.
*    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
