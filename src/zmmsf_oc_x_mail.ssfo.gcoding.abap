types: tt_items type STANDARD TABLE OF BAPIEKPO,
       tt_sched type STANDARD TABLE OF BAPIEKET.

data: it_items    type tt_items WITH HEADER LINE,
      it_sched    type tt_sched WITH HEADER LINE,
      lv_po_item  type ekpo-ebelp.

DATA: lv_name1 TYPE adrc-name1,
      lv_name2 TYPE adrc-name2,
      lv_lines TYPE i,
      lv_mod   TYPE i,
      ls_t001  LIKE t001,
      ls_a003  TYPE a003,
      lv_kbetr  TYPE konp-kbetr.

CONSTANTS: lc_pag     TYPE i VALUE 11,
           lc_pagpie  TYPE i VALUE  8,
           lc_tax     TYPE a003-kappl VALUE 'TX',
           lc_porcent TYPE i VALUE 1000.

CLEAR: lv_po_item.
loop at it_ekpo into gv_ekpo.

CLEAR: it_items, it_sched, gs_poaddress, gs_poheader.
refresh: it_items, it_sched.

CALL FUNCTION 'BAPI_PO_GETDETAIL'
  EXPORTING
    purchaseorder                    = gv_ekpo-ebeln
    items                            = 'X'
    schedules                        = 'X'
  IMPORTING
    po_header                        = gs_poheader
    po_address                       = gs_poaddress "Provedor
  TABLES
    po_items                         = it_items
    po_item_schedules                = it_sched.

  delete it_items WHERE po_item <> gv_ekpo-ebelp.
  delete it_sched WHERE po_item <> gv_ekpo-ebelp.

  READ TABLE it_items INDEX 1.
  it_items-quantity = gv_ekpo-csur.
*  Modify GMU 05/06/2018 *******************************************
  it_items-net_value = ( it_items-net_price * it_items-quantity )
                       / it_items-price_unit.
*  End Modify GMU 05/06/2018****************************************
  MODIFY it_items INDEX 1.
  READ TABLE it_sched INDEX 1.

  APPEND it_items to gt_poitems.
  APPEND it_sched to gt_scitems.
*  IMPORTING
*    po_header                        = gs_poheader
*    po_address                       = gs_poaddress "Provedor
*  TABLES
*    po_items                         = gt_poitems
*    po_item_schedules                = gt_scitems.


endloop.

CLEAR: gv_rfc, gv_bezei, gs_socadrc.
* Se inicializa la descripción de la Sociedad, dirección y RFC
SELECT SINGLE * FROM t001 INTO ls_t001
  WHERE bukrs EQ gs_poheader-co_code.
  IF sy-subrc EQ 0.
    gv_rfc = ls_t001-stceg .
    SELECT SINGLE * FROM adrc INTO gs_socadrc
      WHERE addrnumber EQ ls_t001-adrnr.
      IF sy-subrc EQ 0.
        CONCATENATE gs_socadrc-name1 gs_socadrc-name2 INTO gv_bukrsname1
        SEPARATED BY space.
      ENDIF.
     SELECT SINGLE bezei FROM t005u INTO gv_bezei
       WHERE spras EQ sy-langu
         AND land1 EQ gs_socadrc-country
         AND bland EQ gs_socadrc-region.

  ENDIF.

*  Se coloca la descripción del pais
SELECT SINGLE landx FROM t005t INTO gv_country
  WHERE spras EQ sy-langu
    AND land1 EQ gs_poaddress-country.
  IF sy-subrc NE 0.
    gv_country = gs_poaddress-country.
  ENDIF.
*  Se coloca la denominación de las condiciones de pago
SELECT SINGLE text1 FROM t052u INTO gv_condpago
  WHERE spras EQ sy-langu
    AND zterm EQ gs_poheader-pmnttrms.
  IF sy-subrc NE 0.
    gv_condpago = gs_poheader-pmnttrms.
  ENDIF.
CLEAR: gv_total, gv_subtotal, gv_iva.
LOOP AT gt_poitems INTO gs_poitems WHERE delete_ind EQ space.
   MOVE-CORRESPONDING gs_poitems TO gs_items.
   READ TABLE gt_scitems INTO gs_scitems
   WITH KEY po_item = gs_items-po_item.
   IF sy-subrc EQ 0.
*    WRITE gs_scitems-deliv_date TO gs_items-eeind DD/MM/YYYY.  "fecha entrega
   ENDIF.
   CLEAR gs_items-eeind.
   gv_subtotal = gv_subtotal + gs_items-net_value.
*   get taxes
      SELECT * FROM a003 INTO ls_a003
        WHERE kappl EQ lc_tax
          AND aland EQ gs_poheader-taxr_cntry
          AND mwskz EQ gs_poitems-tax_code.
            SELECT SINGLE kbetr FROM konp INTO lv_kbetr
              WHERE knumh EQ ls_a003-knumh
                AND kappl EQ ls_a003-kappl
                AND kschl EQ ls_a003-kschl.
              IF sy-subrc EQ 0.
                 gv_iva = gv_iva + ( gs_items-net_value * lv_kbetr / lc_porcent ).
              ENDIF.

        ENDSELECT.
*   SELECT SINGLE name1 FROM t001w INTO gs_items-name1
*     WHERE werks EQ gs_poitems-plant.
*     IF sy-subrc NE 0.
*        CLEAR gs_items-name1.
*     ENDIF.
*
*    SELECT SINGLE lgobe FROM t001l INTO gs_items-lgobe
*      WHERE werks EQ gs_poitems-plant
*        AND lgort EQ gs_poitems-store_loc.
*      IF sy-subrc NE 0.
*         CLEAR gs_items-lgobe.
*      ENDIF.

*    SELECT SINGLE maktx FROM makt INTO gs_items-maktx
*      WHERE spras EQ sy-langu
*        AND matnr EQ gs_poitems-material.
*      IF sy-subrc NE 0.
*        CLEAR gs_items-maktx.
*      ENDIF.
    gs_items-maktx = gs_poitems-short_text.
    APPEND gs_items TO gt_items.

ENDLOOP.

gv_total = gv_subtotal + gv_iva.

* Se obtiene la dir. de donde se va a realizar la entrega
* esto está a nivel posición tomamos como referencia la
* posición 1 esperando que sea lo mismo para las otras
CLEAR gs_items.
READ TABLE gt_items INTO gs_items INDEX 1.
SELECT SINGLE * FROM adrc INTO gs_leadrc
  WHERE addrnumber EQ gs_items-address2.
  IF sy-subrc NE 0.
    CLEAR gs_leadrc.
  ENDIF.
* Realizar el salto de página para las ventanas de pie de página
CLEAR: lv_lines, gv_flag.
DESCRIBE TABLE gt_items LINES lv_lines.
*
CHECK lv_lines GT 0.
lv_mod = lv_lines MOD lc_pag.
IF lv_mod GT lc_pagpie.
  gv_flag = 'X'.
ENDIF.

* Se obtiene Nombre de usuario que Imprime ó envía el correo
SELECT SINGLE adrp~name_text INTO gv_user
  FROM ( adrp INNER JOIN usr21
         ON usr21~persnumber = adrp~persnumber )
  WHERE usr21~bname EQ sy-uname.
  IF sy-subrc NE 0.
     CLEAR gv_user.
  ENDIF.
* Fecha de Envio
  WRITE sy-datum TO gv_datesend DD/MM/YYYY.
