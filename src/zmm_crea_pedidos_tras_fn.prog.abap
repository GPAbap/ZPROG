*&---------------------------------------------------------------------*
*& Include zmm_crea_pedidos_tras_fn
*&---------------------------------------------------------------------*

FORM load_excel_to_table USING p_wa_xls_archivo
CHANGING p_ok .
  DATA vl_filename TYPE rlgrap-filename.
  DATA: lo_uploader TYPE REF TO zcl_upload_xls.


  REFRESH it_outtable.
  p_ok = abap_false.

  vl_filename = p_wa_xls_archivo .
  CREATE OBJECT lo_uploader.
  lo_uploader->max_rows = 53000.
  lo_uploader->filename = vl_filename.
  lo_uploader->header_rows_count = 1.
  lo_uploader->upload( CHANGING ct_data = it_outtable ).

  IF sy-subrc EQ 0.
    p_ok = abap_true.
  ENDIF.
ENDFORM.

FORM calcular_inventario.
  DATA aves TYPE menge_d.
  DATA: vl_material     TYPE matnr18,
        vl_werks        TYPE bapimatvp-werks,
        vl_unit         TYPE bapiadmm-unit,
        vl_lgort        TYPE bapicm61v-lgort,
        vl_charg        TYPE bapicm61v-charg,
        vl_rec_reqd_qty TYPE mng01.

  DATA: vl_peso_prom         TYPE p DECIMALS 2 VALUE '2.7',
        vl_kgs_pend          TYPE p DECIMALS 3,
        vl_UNRESTRICTED_STCK TYPE p DECIMALS 3.

  SORT it_outtable BY lote_sap almacen centro_sum.
  it_auxtable = it_outtable[].

  REFRESH: it_log.

  DELETE ADJACENT DUPLICATES FROM it_auxtable COMPARING lote_sap almacen centro_sum.

  LOOP AT it_auxtable INTO DATA(wa_aux_outtable).

    APPEND INITIAL LINE TO it_inventario ASSIGNING FIELD-SYMBOL(<fs_wa>).

    IF wa_aux_outtable-material EQ '500021'.
      vl_peso_prom = '2.7'.
    ELSEIF wa_aux_outtable-material EQ '500022'.
      vl_peso_prom = '3.2'.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_aux_outtable-material
      IMPORTING
        output = vl_material.

    <fs_wa>-material = vl_material.
    <fs_wa>-lote = wa_aux_outtable-lote_sap.
    <fs_wa>-almacen = wa_aux_outtable-almacen.
    <fs_wa>-caseta = wa_aux_outtable-caseta.
    <fs_wa>-centro_recep = wa_aux_outtable-centro_recep.
    <fs_wa>-centro_sum = wa_aux_outtable-centro_sum.
    <fs_wa>-unit = 'KG'.
    <fs_wa>-unit_pzas = 'PZA'.
    <fs_wa>-p_prom = wa_aux_outtable-p_promedio.
    <fs_wa>-pigmento = wa_aux_outtable-pigmento.


    <fs_wa>-inventario1 = REDUCE menge_d( INIT val TYPE menge_d
                                      FOR wa IN
                                      FILTER #( it_outtable
                                                USING KEY pk
                                                WHERE  almacen EQ <fs_wa>-almacen AND
                                                       lote_sap EQ  <fs_wa>-lote AND
                                                       centro_sum EQ <fs_wa>-centro_sum )
                                      NEXT val = val + ( wa-aves * wa-p_promedio )  ).


    <fs_wa>-cant_pzas = REDUCE menge_d( INIT val TYPE menge_d
                                  FOR wa IN
                                  FILTER #( it_outtable
                                            USING KEY pk
                                            WHERE  almacen EQ <fs_wa>-almacen AND
                                                   lote_sap EQ  <fs_wa>-lote AND
                                                   centro_sum EQ <fs_wa>-centro_sum )
                                  NEXT val = val + ( wa-aves ) ).


    <fs_wa>-inventario2 = <fs_wa>-inventario1 * '1.10'.

    vl_werks = <fs_wa>-centro_sum.
    vl_charg = <fs_wa>-lote.
    vl_unit = <fs_wa>-unit.
    vl_lgort = 'GPPT'."<fs_wa>-almacen.

    SELECT SINGLE /cwm/labst INTO @DATA(stk_kgs)
    FROM mard WHERE matnr = @vl_material AND werks = @vl_werks AND lgort = @vl_lgort.


    CALL FUNCTION 'BAPI_MATERIAL_STOCK_REQ_LIST'
      EXPORTING
        material         = vl_material
        plant            = vl_werks
        get_ind_lines    = 'X'
      IMPORTING
*       mrp_list         =
*       mrp_control_param =
        mrp_stock_detail = t_mrp_stock_detail
*       return           =
      TABLES
*       mrp_items        =
        mrp_ind_lines    = t_mrp_ind_lines.


    vl_unrestricted_stck = t_mrp_stock_detail-unrestricted_stck.

    LOOP AT t_mrp_ind_lines INTO DATA(wa_stock).

      IF wa_stock-rec_reqd_qty LT '0'.
        vl_rec_reqd_qty = vl_rec_reqd_qty + wa_stock-rec_reqd_qty.
      ENDIF.

    ENDLOOP.



    vl_rec_reqd_qty = abs( vl_rec_reqd_qty ).

    vl_rec_reqd_qty = vl_rec_reqd_qty * '1.10'.


    vl_kgs_pend =  vl_rec_reqd_qty * vl_peso_prom .


    IF stk_kgs GT vl_kgs_pend.

      stk_kgs = stk_kgs - vl_kgs_pend.
      <fs_wa>-inventariot =  abs( stk_kgs - <fs_wa>-inventario2 ).
    ELSE.
      <fs_wa>-inventariot = <fs_wa>-inventario2.
    ENDIF.


    IF vl_unrestricted_stck GT vl_rec_reqd_qty.
      vl_unrestricted_stck = vl_unrestricted_stck - vl_rec_reqd_qty.
      IF vl_unrestricted_stck GT <fs_wa>-cant_pzas.
        <fs_wa>-genera_entrada = abap_false.
      ELSE.
        <fs_wa>-cant_pzas =  <fs_wa>-cant_pzas - vl_unrestricted_stck.
        <fs_wa>-genera_entrada = abap_true.
      ENDIF.
    ELSE.
      <fs_wa>-genera_entrada = abap_true.
    ENDIF.




    <fs_wa>-peso = REDUCE menge_d( INIT val_p TYPE menge_d
                                          FOR wa_p IN
                                          FILTER #( it_outtable
                                                    USING KEY pk
                                                    WHERE  almacen EQ <fs_wa>-almacen AND
                                                           lote_sap EQ  <fs_wa>-lote AND
                                                           centro_sum EQ <fs_wa>-centro_sum )
                                          NEXT val_p = val_p + ( wa_p-aves * wa_p-p_promedio ) ).

    vl_lgort = 'GPPT'.
    UNASSIGN <fs_wa>.
    CLEAR: vl_rec_reqd_qty, vl_unrestricted_stck, stk_kgs, vl_kgs_pend.
  ENDLOOP.
ENDFORM.

FORM set_carga_stock .

  REFRESH t_return.

  DATA: lt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
        lt_return TYPE STANDARD TABLE OF bapiret2.
  DATA: ls_hdr     TYPE bapi2017_gm_head_01,
        ls_code    TYPE bapi2017_gm_code VALUE '01',
        ls_item    TYPE bapi2017_gm_item_create,
        ls_icwm    TYPE /cwm/bapi2017_gm_item_create,
        lt_icwm    TYPE STANDARD TABLE OF /cwm/bapi2017_gm_item_create,
        ls_hdr_ret TYPE bapi2017_gm_head_ret,
        ls_posnr   TYPE posnr,
        lv_mblnr   TYPE mblnr.

  DATA: vl_cant TYPE string, vl_kgs TYPE string.

  CLEAR: ls_hdr, ls_item,lt_item,lt_return.

  ls_hdr-pstng_date  = sy-datum.
  ls_hdr-doc_date    = sy-datum.
  ls_hdr-ref_doc_no  = sy-datum.

  ls_hdr-header_txt  = 'Carga Inventario para Ped. Traslado'.
  ls_posnr = '0000'.

  LOOP AT it_inventario ASSIGNING FIELD-SYMBOL(<fs_stock>).

    SELECT SINGLE posnr
    INTO @ls_item-order_itno
    FROM afpo
   WHERE aufnr = @<fs_stock>-lote
     AND matnr = @<fs_stock>-material.



    "ls_item-order_itno = ls_posnr.
    ls_item-material  = <fs_stock>-material.
    ls_item-plant     = <fs_stock>-centro_sum.
    ls_item-stge_loc  = 'GPPT'.
    ls_item-batch     = <fs_stock>-lote.
    ls_item-move_type = '101'. "Entrada
    ls_item-mvt_ind     = 'F'.
    ls_item-entry_qnt = <fs_stock>-cant_pzas.
    ls_item-entry_uom = <fs_stock>-unit_pzas.
    ls_item-orderid = <fs_stock>-lote.
    APPEND ls_item TO lt_item.

    ls_icwm-matdoc_itm = ls_item-order_itno.
    ls_icwm-quantity_pme  = <fs_stock>-cant_pzas.
    ls_icwm-entry_qnt_pme = <fs_stock>-inventariot.
    ls_icwm-entry_uom_pme = <fs_stock>-unit.
    APPEND ls_icwm TO lt_icwm.

    IF <fs_stock>-genera_entrada EQ abap_true.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header   = ls_hdr
          goodsmvt_code     = ls_code
*         TESTRUN           = ' '
        IMPORTING
          materialdocument  = lv_mblnr
        TABLES
          goodsmvt_item     = lt_item
          goodsmvt_item_cwm = lt_icwm
          return            = t_return.

      IF lv_mblnr IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.

        ls_log-message = 'Documento creado con éxito'.
        ls_log-message_v1 = lv_mblnr.
        ls_log-message_v2 = <fs_stock>-lote.
        vl_cant = <fs_stock>-cant_pzas.
        vl_kgs = <fs_stock>-inventariot.
        CONCATENATE   vl_cant  '/' vl_kgs INTO ls_log-message_v3.
        APPEND ls_log TO it_log.

      ELSE.
        READ TABLE t_return INTO DATA(wa_return) WITH KEY id = 'E'.
        ls_log-message = wa_return-message.
        APPEND ls_log TO it_log.
      ENDIF.
    ELSE.
      ls_log-message = 'Stock Suficiente. No se genero Entrada'.
      ls_log-message_v1 = <fs_stock>-centro_sum.
      ls_log-message_v2 = <fs_stock>-lote.
      APPEND ls_log TO it_log.
    ENDIF.

    CLEAR:  ls_icwm, ls_item, vl_cant, vl_kgs, ls_log-message,
            ls_log-message_v1,ls_log-message_v2, ls_log-message_v3.
    REFRESH: lt_item, lt_icwm, t_return.


  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_results
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_results .
  TYPE-POOLS: slis.

  DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fieldcat TYPE slis_fieldcat_alv,
        ls_layout   TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.

  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'MESSAGE'.
  ls_fieldcat-seltext_m = 'Mensaje'.
  ls_fieldcat-seltext_l = 'Mensaje'.
  APPEND ls_fieldcat TO gt_fieldcat.

  ls_fieldcat-fieldname = 'MESSAGE_V1'.
  ls_fieldcat-seltext_m = 'Documento'.
  ls_fieldcat-seltext_l = 'Documento'.
  APPEND ls_fieldcat TO gt_fieldcat.

  ls_fieldcat-fieldname = 'MESSAGE_V2'.
  ls_fieldcat-seltext_m = 'Lote'.
  ls_fieldcat-seltext_l = 'Lote'.
  APPEND ls_fieldcat TO gt_fieldcat.

  ls_fieldcat-fieldname = 'MESSAGE_V3'.
  ls_fieldcat-seltext_m = 'Cant/Peso'.
  ls_fieldcat-seltext_l = 'Cant/Peso'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = gt_fieldcat
    TABLES
      t_outtab           = it_log.

ENDFORM.

FORM set_crea_pedidos_trasl.

  DATA: poheader         LIKE bapimepoheader,
        poheaderx        LIKE bapimepoheaderx,
        poitem           TYPE STANDARD TABLE OF bapimepoitem WITH HEADER LINE,
        poitemx          TYPE STANDARD TABLE OF bapimepoitemx WITH HEADER LINE,
        ls_poitem        LIKE LINE OF poitem,
        ls_poitemx       LIKE LINE OF poitemx,
        return           LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        return2          LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        exppurchaseorder LIKE bapimepoheader-po_number.

  DATA: vl_posnr       TYPE posnr, vl_full, vl_index TYPE sy-tabix, vl_fin_archivo, vl_indice TYPE sy-tabix.
  DATA: wa_next       LIKE LINE OF it_outtable,wa_inventario LIKE LINE OF it_outtable.

  DATA: it_lines  TYPE STANDARD TABLE OF tline, vl_posne TYPE ebelp,
        vl_string TYPE string, wa_lines LIKE LINE OF it_lines.




  TYPES:BEGIN OF st_ped_entregas,
          pedido  LIKE bapimepoheader-po_number,
          entrega LIKE lips-vbeln,
        END OF st_ped_entregas.

  DATA: it_entregas TYPE STANDARD TABLE OF st_ped_entregas,
        wa_entregas LIKE LINE OF it_entregas.

  poheader-doc_type = 'ZTR1'.
  poheader-doc_date = sy-datum.
  poheader-purch_org = 'GP01'.
  poheader-pur_group = '211'.
  poheader-comp_code = 'SA01'.

  poheaderx-doc_type = 'X'.
  poheaderx-doc_date = 'X'.
  poheaderx-purch_org = 'X'.
  poheaderx-pur_group = 'X'.
  poheaderx-comp_code = 'X'.
  poheaderx-suppl_plnt = 'X'.


  vl_posnr = '00000'.
  CLEAR wa_inventario.
  vl_fin_archivo = abap_false.

  READ TABLE it_outtable INTO DATA(wa_viaje) INDEX 1.
  wa_next-viaje = wa_viaje-viaje.
  LOOP AT it_outtable INTO wa_inventario.
    IF vl_indice IS INITIAL.
      vl_indice = sy-tabix.
    ENDIF.

    CHECK wa_inventario-viaje = wa_next-viaje.


    WHILE vl_full EQ abap_false AND vl_fin_archivo = abap_false.
      IF vl_index IS INITIAL.
        vl_index = sy-tabix.

      ENDIF.

      READ TABLE it_outtable INTO DATA(wa_inventario2) INDEX vl_index.

      poheader-suppl_plnt = wa_inventario2-centro_sum.
      vl_posnr = vl_posnr + 10.
      ls_poitem-po_item = vl_posnr.
      ls_poitem-plant = wa_inventario2-centro_recep.
      ls_poitem-stge_loc = wa_inventario2-almacen.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_inventario2-material
        IMPORTING
          output = ls_poitem-material.

      ls_poitem-quantity = wa_inventario2-aves.
      ls_poitem-po_unit = 'PZA'.
      ls_poitem-batch = wa_inventario2-lote_sap.

      ls_poitemx-po_item     = vl_posnr.
      ls_poitemx-po_itemx     = 'X'.
      ls_poitemx-material     = 'X'.
      ls_poitemx-plant        = 'X'.
      ls_poitemx-stge_loc     = 'X'.
      ls_poitemx-quantity     = 'X'.
      ls_poitemx-po_unit      = 'X'.
      ls_poitemx-batch        = 'X'.

      APPEND ls_poitem TO poitem.
      APPEND ls_poitemx TO poitemx.

      READ TABLE it_outtable INTO wa_next INDEX vl_index + 1.
      IF sy-subrc EQ 0.
        vl_index = vl_index + 1.
        IF wa_next-viaje NE wa_inventario-viaje.
          vl_full = abap_true.

        ELSE.
          vl_full = abap_false.
        ENDIF.
      ELSE.
        vl_full = abap_true.
        vl_fin_archivo = abap_true.
      ENDIF.

    ENDWHILE.



    IF poitem[] IS NOT INITIAL.
      CALL FUNCTION 'BAPI_PO_CREATE1'
        EXPORTING
          poheader         = poheader
          poheaderx        = poheaderx
        IMPORTING
          exppurchaseorder = exppurchaseorder
*         expheader        = expheader
*         exppoexpimpheader = exppoexpimpheader
        TABLES
          poitem           = poitem
          poitemx          = poitemx
*         poschedule       = poschedule
*         poschedulex      = poschedulex
          return           = return.


      IF exppurchaseorder IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
        "se obtiene la entrega generada
        WAIT UP TO 2 SECONDS.
        ls_log-message = 'Pedido de Traslado creado con éxito'.
        ls_log-message_v1 = exppurchaseorder.
        ls_log-message_v2 = wa_inventario-lote.
        APPEND ls_log TO it_log.

        LOOP AT poitem INTO DATA(wa_item).

           CLEAR vl_string.
           CONCATENATE exppurchaseorder wa_item-po_item INTO vl_string. "tdname
          READ TABLE it_outtable INTO DATA(wa_txt) INDEX vl_indice.

          wa_lines-tdline = wa_txt-caseta.
          APPEND wa_lines TO it_lines.

          PERFORM crea_textos TABLES it_lines
                              USING 'EKPO' 'F01' 'S' vl_string.

          REFRESH it_lines.
          wa_lines-tdline = '   '.
          APPEND wa_lines TO it_lines.

          wa_lines-tdline = wa_txt-pigmento.
          APPEND wa_lines TO it_lines.

          wa_lines-tdline = wa_txt-p_promedio.
          APPEND wa_lines TO it_lines.

          PERFORM crea_textos TABLES it_lines
                              USING 'EKPO' 'F02' 'S' vl_string.

          REFRESH it_lines.
          vl_indice = vl_indice + 1.

        ENDLOOP.


      ELSE.
        READ TABLE return INTO DATA(wa_return) WITH KEY id = 'E'.
        ls_log-message = wa_return-message.
        APPEND ls_log TO it_log.
      ENDIF.
      CLEAR: exppurchaseorder,ls_log-message,ls_log-message_v1,ls_log-message_v2,ls_log-message_v3,
             wa_inventario.
      REFRESH: poitem,poitemx, return.
      vl_full = abap_false.
      vl_posnr = '00000'.

    ENDIF.
  ENDLOOP.

ENDFORM.

FORM get_entregas.
  WAIT UP TO 3 SECONDS.

  LOOP AT it_log ASSIGNING FIELD-SYMBOL(<wa_log>).

    IF <wa_log>-message_v1 CP '48*'.
      SELECT vbeln INTO TABLE @DATA(it_vbeln)
         FROM lips WHERE vgbel = @<wa_log>-message_v1.

      IF sy-subrc EQ 0.
        READ TABLE it_vbeln INTO DATA(wa_vbeln) INDEX 1.
        "CONCATENATE 'Entreg' wa_vbeln-vbeln INTO <wa_log>-message_v3 SEPARATED BY ':'.
        <wa_log>-message_v3 = wa_vbeln-vbeln.
      ELSE.
        CONCATENATE 'Entrega no generada aún de ' <wa_log>-message_v1  INTO <wa_log>-message_v3 SEPARATED BY ':'.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM crea_textos TABLES p_lines USING p_tdobject TYPE tdobject
                       p_tdid TYPE tdid
                       p_tdspras TYPE tdspras
                       p_tdname TYPE string.

  DATA: vl_header LIKE thead.

  CLEAR vl_header.
  vl_header-tdobject = p_tdobject.
  vl_header-tdid = p_tdid.
  vl_header-tdspras = p_tdspras.
  vl_header-tdname = p_tdname.


  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client          = sy-mandt         " Mandante
      header          = vl_header       " Cabecera del texto que se ha de grabar
      insert          = abap_true         " Indicador: El texto es nuevo
      savemode_direct = abap_true         " Indicador: Grabar texto inmediatamente
    TABLES
      lines           = p_lines                " Líneas del texto que se ha de grabar
    EXCEPTIONS
      id              = 1                " ID de texto no válida en cabecera texto
      language        = 2                " Idioma no válido en cabecera de texto
      name            = 3                " Nombre de texto no válido en cabecera de texto
      object          = 4                " Objeto de texto no válido en cabecera de texto
      OTHERS          = 5.


  IF sy-subrc <> 0.
    MESSAGE 'No se pudo grabar el texto de posición' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    CALL FUNCTION 'COMMIT_TEXT'.
  ENDIF.
ENDFORM.
