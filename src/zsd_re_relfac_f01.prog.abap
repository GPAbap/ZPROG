*&---------------------------------------------------------------------*
*& Include          ZSD_RE_RELFAC_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialize_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> FIELDTAB
*&---------------------------------------------------------------------*
FORM obtener_datos.

  DATA: lt_tab LIKE TABLE OF tab.

** INI PROCETI CJTC-DESK929556
  SELECT vbrp~vkbur
  vbrk~vkorg
  vbrk~spart
  vbrk~vtweg
  vbak~vkgrp
  t~bezei
  vbrk~fkdat
  vbrk~vbeln
  vbrk~fkart
  vbrk~kunag
  vbrk~knumv
  vbrk~bzirk
  vbrk~kurrf
  vbrk~fktyp
  vbrk~vbtyp
  vbrk~fksto
  vbrp~werks
  vbrp~posnr
  vbrp~fkimg
  vbrp~vrkme
  vbrp~matnr
  vbrp~kzwi1
  vbrp~kzwi5
  vbrp~netwr
  vbrp~ntgew
  vbrp~gewei
  vbrp~aubel
  vbrp~aupos
*         vbap~kzwi2
  vbap~kzwi1
  vbap~kzwi2
  vbap~kzwi5
  vbak~kostl
*  SELECT vbrp~vkbur  " PROCETI CJTC-DESK929556
*         vbrk~vkorg vbrk~spart vbrk~fkdat vbrk~vbeln vbrk~fkart
*         vbrk~kunag vbrk~knumv vbrk~bzirk vbrk~vtweg
*         vbrk~kurrf vbrk~fktyp vbrk~vbtyp vbrk~fksto
*         vbrp~fkimg vbrp~vrkme vbrp~matnr vbrp~kzwi1 vbrp~kzwi5
*         vbrp~vkbur vbrp~ntgew vbrp~werks vbrp~gewei vbrp~posnr
*         vbrp~aubel vbrp~aupos vbrp~netwr
** FIN PROCETI CJTC-DESK929556
  FROM  vbrk INNER JOIN vbrp
  ON  vbrk~vbeln = vbrp~vbeln
* INI PROCETI CJTC-DESK929556
  LEFT OUTER JOIN vbap ON
  vbap~vbeln = vbrp~aubel
  AND vbap~posnr =  vbrp~aupos
  INNER JOIN vbak ON
  vbak~vbeln = vbap~vbeln
  INNER JOIN TVGRT as t ON t~vkgrp = vbak~vkgrp and t~spras = 'S'
  INTO TABLE vbr
*    INTO CORRESPONDING FIELDS OF TABLE vbr
* FIN PROCETI CJTC-DESK929556
  WHERE vbrk~vkorg IN vkorg_p
  AND   vbrk~spart IN spart_p
  AND   vbrp~vkbur IN vkbur_p
  AND   vbrk~vbtyp =  'M'     " sólo facturas 20120809
  AND   vbrk~fkdat IN fkdat_p
  AND   vbrk~kunag IN o_kunag  " PROCETI CJTC-DESK929556
  AND   vbak~kostl IN o_kostl " PROCETI CJTC-DESK929658
  and   vbak~vkgrp in so_VKGRP.
* INI PROCETI CJTC DESK929556
  IF NOT sy-subrc = 0.
    MESSAGE s001(00)
    WITH 'No se encontraron datos para este criterio '
    ' de búsqueda'.
    EXIT.
  ENDIF.
* FIN PROCETI CJTC DESK929556

*--Detalles

  LOOP AT vbr.
    MOVE-CORRESPONDING vbr TO tab.
* Si la moneda de documento es diferente a mxn, lo convierte.
    tab-kzwi1 = tab-kzwi1 * tab-kurrf.
    tab-kzwi5 = tab-kzwi5 * tab-kurrf.
    tab-netwr = tab-netwr * tab-kurrf.

* Modifica la naturaleza de las cantidades dependiendo del documento
    IF tab-fktyp EQ 'L' AND tab-vbtyp EQ 'O'.       " Devoluciones
      tab-fkimg = tab-fkimg * ( -1 ) .
      tab-kzwi1 = tab-kzwi1 * -1 .
      tab-kzwi5 = tab-kzwi5 * -1 .
      tab-netwr = tab-netwr * -1 .
* INI PROCETI CJTC-DESK929556
      tab-kzwib1 = tab-kzwib1 * -1 .
      tab-kzwib5 = tab-kzwib5 * -1 .
* FIN PROCETI CJTC-DESK929556
  ELSEIF tab-fktyp EQ 'A' AND tab-vbtyp EQ 'O'.   " Notas de Crédito
*      tab-fkimg = 0.
      tab-kzwi1 = tab-kzwi1 * ( -1 ) .
      tab-kzwi5 = tab-kzwi5 * -1.
      tab-netwr = tab-netwr * -1.
* INI PROCETI CJTC-DESK929556
      tab-kzwib1 = tab-kzwib1 * -1 .
      tab-kzwib5 = tab-kzwib5 * -1 .
* FIN PROCETI CJTC-DESK929556
  ELSEIF tab-fktyp EQ 'A' AND tab-vbtyp EQ 'M'.    " Notas de Cargo
    ENDIF.
* Destinatario de mercancías
    SELECT SINGLE * FROM  vbpa
    WHERE vbeln EQ vbr-aubel
    AND   parvw EQ 'WE'.
    IF sy-subrc = 0.
      MOVE vbpa-kunnr TO tab-kunnr.
    ENDIF.
* Nombre del solicitante.
    SELECT SINGLE * FROM kna1
    WHERE kunnr EQ vbr-kunag.
    IF sy-subrc = 0.
      MOVE kna1-name1 TO tab-name1.
      MOVE kna1-ort01 TO tab-ort01.
    ENDIF.
* Nombre del Destinatario de Mercancías
    SELECT SINGLE * FROM kna1
    WHERE kunnr EQ vbpa-kunnr.

    IF sy-subrc = 0.
      MOVE kna1-name2 TO tab-namewe.
*      move kna1-ort01 to tab-ort01.
    ENDIF.
* Nombre de la Zona de Ventas
    SELECT SINGLE * FROM t171t
    WHERE spras EQ 'S'
    AND bzirk EQ tab-bzirk.
    IF sy-subrc = 0.
      MOVE t171t-bztxt TO tab-bztxt.
    ENDIF.
* Nombre del Material
    SELECT SINGLE * FROM makt
    WHERE spras EQ 'S'
    AND matnr EQ tab-matnr.
    IF sy-subrc = 0.
      tab-maktx = makt-maktx.
    ENDIF.
*PROCETI2 8/JULIO/2016
    SELECT SINGLE * FROM mara
    WHERE matnr = tab-matnr.
    IF sy-subrc = 0.
      tab-prdha = mara-prdha.
    ENDIF.
    SELECT SINGLE * FROM t179t
    WHERE spras = sy-langu
    AND prodh = tab-prdha.
    IF sy-subrc = 0.
      tab-vtext1 = t179t-vtext.
    ENDIF.
*PROCETI2 8/JULIO/2016
* Documento de Ventas
    SELECT SINGLE * FROM  vbkd
    WHERE  vbeln  = tab-aubel
    AND    posnr  = tab-aupos.
    IF sy-subrc = 0.
      MOVE vbkd-ihrez TO tab-ihrez.
      MOVE vbkd-bstkd TO tab-bstkd.
    ELSE.
        SELECT SINGLE * FROM  vbkd
          WHERE  vbeln  = tab-aubel
          AND    posnr  = '000000'.
          IF SY-SUBRC EQ 0.
              MOVE vbkd-ihrez TO tab-ihrez.
              MOVE vbkd-bstkd TO tab-bstkd.
          ENDIF.
    ENDIF.
* Obtiene datos del pedido
    SELECT SINGLE * FROM  vbap
    WHERE  vbeln  = tab-aubel
    AND    posnr  = tab-aupos.
    IF sy-subrc = 0.
      MOVE vbap-posex TO tab-posex.
* INI PROCETI CJTC-DESK929404
      MOVE vbap-vstel TO tab-vstel.
* FIN PROCETI CJTC-DESK929404

    ENDIF.
* Descripción de clase de documento
    SELECT SINGLE * FROM  tvfkt
    WHERE  spras  = 'S'
    AND    fkart  = tab-fkart.
    IF sy-subrc = 0.
      MOVE tvfkt-vtext TO tab-vtext.
    ENDIF.
* Nombre de Granja
    SELECT SINGLE * FROM  t001w
    WHERE  werks  = tab-werks.
    IF sy-subrc = 0.
      MOVE t001w-name1 TO tab-name1c.
    ENDIF.
* Precio de Producto
    SELECT SINGLE * FROM  konv
    WHERE  knumv  = tab-knumv
    AND    kposn  = tab-posnr
    AND    kschl  = 'PR0C'.
    IF sy-subrc = 0.
      tab-precio = konv-kbetr.
    ENDIF.
* busca condiciones de bonificación
    SELECT SINGLE * FROM  konv
    WHERE  knumv  =  tab-knumv
    AND    kposn  =  tab-posnr
    AND    kntyp  =  ' '
    AND    kschl  NE 'PR0C'.
    IF sy-subrc = 0.
      tab-bonif = konv-kwert.
    ENDIF.
* Busca notas de crédito
    SELECT SINGLE * FROM  vbfa
    WHERE  vbelv    = tab-vbeln
    AND    posnv    = tab-posnr
    AND    vbtyp_n  = 'O'.

    IF sy-subrc = 0.

      SELECT SINGLE * FROM  vbrk
      WHERE  vbeln  = vbfa-vbeln.
      IF sy-subrc = 0.

        MOVE vbrk-vbeln TO tab-bovbe.

        SELECT SINGLE * FROM  vbrp
        WHERE  vbeln  = vbrk-vbeln
        AND  posnr  = tab-posnr.
        MOVE vbrp-fkimg TO tab-bocan.
        MOVE vbrp-vrkme TO tab-bounv.
        MOVE vbrp-ntgew TO tab-bokgs.
        MOVE vbrp-gewei TO tab-boump.
        SELECT SINGLE * FROM  konv
        WHERE  knumv  =  vbrk-knumv
        AND    kposn  =  vbrp-posnr
        AND    kntyp  =  ' '
        AND    kschl  NE 'PR0C'.
        IF sy-subrc = 0.
* INI PROCETI CJTC-DESK929556
*          tab-bonif = tab-bonif + konv-kwert.
          tab-bonif = tab-kzwib2 - konv-kwert.
* FIN PROCETI CJTC-DESK929556
        ENDIF.
      ENDIF.
* INI PROCETI CJTC-DESK929556
    ELSE.

* Busca anulaciones de factúra
      SELECT SINGLE * FROM  vbfa
      WHERE  vbelv    = tab-vbeln
      AND    posnv    = tab-posnr
      AND    vbtyp_n  = 'N'.

      IF sy-subrc = 0.

        SELECT SINGLE * FROM  vbrk
        WHERE  vbeln  = vbfa-vbeln.
        IF sy-subrc = 0.

          APPEND tab.

*          MOVE vbrk-vbeln TO tab-bovbe.
          MOVE vbrk-vbeln TO tab-vbeln.

          SELECT SINGLE * FROM  vbrp
          WHERE  vbeln  = vbrk-vbeln
          AND  posnr  = tab-posnr.

          MOVE vbrp-fkimg TO tab-bocan.
          MOVE vbrp-vrkme TO tab-bounv.
          MOVE vbrp-ntgew TO tab-bokgs.
          MOVE vbrp-gewei TO tab-boump.

          SELECT SINGLE * FROM  konv
          WHERE  knumv  =  vbrk-knumv
          AND    kposn  =  vbrp-posnr
          AND    kntyp  =  ' '
          AND    kschl  NE 'PR0C'.

          IF sy-subrc = 0.

*            SUBTRACT konv-kwert FROM tab-kzwib2.
*            tab-bonif  =
*            tab-kzwib2 =
*            tab-kzwib2 - konv-kwert.

            tab-netwr = tab-netwr * -1.
            tab-kzwi1 = tab-kzwi1 * -1.

            tab-kzwib1 = tab-kzwib1 * -1.
            tab-kzwib2 = tab-kzwib2 * -1.
            tab-kzwib5 = tab-kzwib5 * -1.
*            tab-bonif = tab-kzwib2 - konv-kwert.

* FIN PROCETI CJTC-DESK929556
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    APPEND tab.
    CLEAR tab.
  ENDLOOP.

* INI PROCETI CJTC-DESK929556
* Se cancela esta parte del códgo por no
* representar utilidad o justificación alguna
*---Pedidos
*  LOOP AT vbr.
*    LOOP AT tab
*       WHERE vbeln = vbr-vbeln.
*
*      MOVE vbr-vkbur TO tab-vkbur.
*      MOVE vbr-spart TO tab-spart.
*      MOVE vbr-vkorg TO tab-vkorg.
*      MODIFY tab INDEX sy-tabix.
*    ENDLOOP.
*  ENDLOOP.
* FIN PROCETI CJTC-DESK929556

* INI PROCETI CJTC-DESK929556
*************************************************
* Se pide cancelar pedidos sin factura          *
*************************************************
** Selecciona los pedidos que estan pendientes de facturar.
*  SELECT DISTINCT vbuk~vbeln vbuk~gbstk vbak~vbeln vbak~vkorg vbak~vtweg
*    vbak~spart vbak~vkbur vbak~audat vbak~ernam vbak~kunnr
*    vbak~bstnk vbak~zuonr
*  FROM vbuk INNER JOIN vbak
*  ON vbuk~vbeln = vbak~vbeln
*  INTO CORRESPONDING FIELDS OF TABLE tab_p
*    WHERE vbuk~gbstk NE 'C'
*    AND vbak~vkorg IN vkorg_p
**    and vbak~vtweg in vtweg_p
*    AND vbak~spart IN spart_p
*    AND vbak~vkbur IN vkbur_p
*    AND audat GE '20101001'.
*  LOOP AT tab_p.
*    SELECT * FROM vbap
*      WHERE vbeln = tab_p-vbeln
*      AND   abgru <> '10'.
*      IF sy-subrc = 0.
*        MOVE-CORRESPONDING tab_p  TO tab.
*        MOVE tab_p-audat TO tab-fkdat.
*        MOVE tab_p-vbeln TO tab-aubel.
*        MOVE-CORRESPONDING vbap TO tab.
*        MOVE vbap-arktx TO tab-maktx.
*        MOVE vbap-kwmeng TO tab-fkimg.
*        MOVE vbap-brgew TO tab-ntgew.
*        MOVE tab_p-vtweg TO tab-vtweg.
*        SELECT SINGLE * FROM vbpa
*        WHERE vbeln = tab-vbeln
*        AND   parvw = 'AG'.
*        IF sy-subrc = 0.
** Solicitante
*          MOVE vbpa-kunnr TO tab-kunag.
*        ENDIF.
*        SELECT SINGLE * FROM vbpa
*        WHERE vbeln = tab-vbeln
*        AND   parvw = 'WE'.
*        IF sy-subrc = 0.
*          MOVE vbpa-kunnr TO tab-kunnr.
*        ENDIF.
** Destinatario de Mercancías
*        SELECT SINGLE * FROM kna1
*        WHERE kunnr = tab-kunnr.
*        IF sy-subrc = 0.
*          MOVE kna1-name1 TO tab-name1.
*        ENDIF.
**        CLEAR tab-vbeln. " PROCETI CJTC-DESK929556
*        APPEND tab.
*        CLEAR tab.
*        CLEAR tab.
*      ENDIF.
*    ENDSELECT.
*  ENDLOOP.
** FIN PROCETI CJTC-DESK929556

* INI PROCETI CJTC-DESK929404
  lt_tab[] = tab[].
  SORT lt_tab
  BY vstel.
  DELETE ADJACENT DUPLICATES FROM lt_tab
  COMPARING vstel.

  SELECT spras
  vstel
  vtext
  FROM tvstt
  INTO TABLE t_tvstt
  FOR ALL ENTRIES IN lt_tab
  WHERE spras = sy-langu
  AND vstel = lt_tab-vstel.

  IF sy-subrc = 0.
    SORT t_tvstt
    BY vstel.
  ENDIF.
* FIN PROCETI CJTC-DESK929404

ENDFORM.                    "obtener_datos

*&---------------------------------------------------------------------
*&      Form  INITIALIZE_FIELDCAT
*&---------------------------------------------------------------------
FORM initialize_fieldcat USING p_fieldtab TYPE slis_t_fieldcat_alv.
  DATA: l_fieldcat TYPE slis_fieldcat_alv.
* fixed columns (obligatory)
  CLEAR l_fieldcat.
  l_fieldcat-tabname    = 'IT_SALIDA'.
  l_fieldcat-fix_column = 'X'.
  l_fieldcat-no_out     = 'O'.
*  l_fieldcat-fieldname  = 'LIFNR'.
**  l_fieldcat-key        = 'X'.
*  APPEND l_fieldcat TO p_fieldtab.
*  l_fieldcat-fieldname  = 'NAME1'.
*  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'FKDAT'.
  l_fieldcat-reptext_ddic = 'Fecha'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'VBELN'.
  l_fieldcat-reptext_ddic = 'Factura'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'AUBEL'.
  l_fieldcat-reptext_ddic = 'Pedido'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'IHREZ'.
  l_fieldcat-reptext_ddic = 'Remisión'.

  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'BSTKD'.
  l_fieldcat-reptext_ddic = 'Ref. Cliente'.

  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'VKBUR'.
  l_fieldcat-reptext_ddic = 'Oficina de Ventas'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'SPART'.
  l_fieldcat-reptext_ddic = 'Sector'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'VTWEG'.
  l_fieldcat-reptext_ddic = 'Canal de Distribucion'.
  APPEND l_fieldcat TO p_fieldtab.

  l_fieldcat-fieldname  = 'VKGRP'.
  l_fieldcat-reptext_ddic = 'Grupo de Vendedores'.
  APPEND l_fieldcat TO p_fieldtab.

  l_fieldcat-fieldname  = 'BEZEI'.
  l_fieldcat-reptext_ddic = 'Descripción'.
  APPEND l_fieldcat TO p_fieldtab.

  l_fieldcat-fieldname  = 'VTEXT'.
  l_fieldcat-reptext_ddic = 'Clase Factura'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'KUNAG'.
  l_fieldcat-reptext_ddic = 'Cliente'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'NAME1'.
  l_fieldcat-reptext_ddic = 'Nombre'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'ORT01'.
  l_fieldcat-reptext_ddic = 'Destino'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'NAME1C'.
  l_fieldcat-reptext_ddic = 'Pto. Expedición'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'POSEX'.
  l_fieldcat-reptext_ddic = 'Cas.  '.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'MATNR'.
  l_fieldcat-reptext_ddic = 'Material'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'MAKTX'.
  l_fieldcat-reptext_ddic = 'Descripción'.
  APPEND l_fieldcat TO p_fieldtab.
*PROCETI2 8/JULIO/2016
  l_fieldcat-fieldname  = 'PRDHA'.
  l_fieldcat-reptext_ddic = 'Jerarquia de Productos'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'VTEXT1'.
  l_fieldcat-reptext_ddic = 'Denominacion'.
  APPEND l_fieldcat TO p_fieldtab.
*PROCETI2 8/JULIO/2016
  l_fieldcat-fieldname  = 'FKIMG'.
  l_fieldcat-reptext_ddic = 'Piezas'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'VRKME'.
  l_fieldcat-reptext_ddic = ' '.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'NTGEW'.
  l_fieldcat-reptext_ddic = 'KILOS'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'GEWEI'.
  l_fieldcat-reptext_ddic = ' '.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'PROMEDIO'.
  l_fieldcat-reptext_ddic = 'Promedio'.
*  APPEND l_fieldcat TO p_fieldtab.
*  l_fieldcat-fieldname  = 'GEWEI'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'BZTXT'.
  l_fieldcat-reptext_ddic = 'Zona'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'PRECIO'.
  l_fieldcat-reptext_ddic = '$ / Kg'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'NETWR'.
  l_fieldcat-reptext_ddic = 'Total '.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'BOCAN'.
  l_fieldcat-reptext_ddic = 'Muertos'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'BOUNV'.
  l_fieldcat-reptext_ddic = ' '.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'BOKGS'.
  l_fieldcat-reptext_ddic = 'Kilos'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'BOUMP'.
  l_fieldcat-reptext_ddic = ' '.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'BONIF'.
  l_fieldcat-reptext_ddic = 'Total'.
  APPEND l_fieldcat TO p_fieldtab.
  l_fieldcat-fieldname  = 'BOVBE'.
  l_fieldcat-reptext_ddic = 'NCR'.
  APPEND l_fieldcat TO p_fieldtab.

ENDFORM.                               " INITIALIZE_FIELDCAT


*&---------------------------------------------------------------------
*&      Form  modify_fieldcatalog
*&---------------------------------------------------------------------
FORM modify_fieldcatalog USING p_fieldtab TYPE slis_t_fieldcat_alv.
  DATA: l_fieldcat TYPE slis_fieldcat_alv.
* fixed columns (obligatory)
  READ TABLE p_fieldtab WITH KEY fieldname  = 'SELEC' INTO l_fieldcat.
  l_fieldcat-no_out = 'X'.
  MODIFY p_fieldtab FROM l_fieldcat INDEX sy-tabix.

ENDFORM.                               " INITIALIZE_FIELDCAT


*&---------------------------------------------------------------------
*&      Form  BUILD_EVENTTAB
*&---------------------------------------------------------------------

FORM build_eventtab USING p_events TYPE slis_t_event.
  DATA: ls_event TYPE slis_alv_event.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
  EXPORTING
    i_list_type = 0
  IMPORTING
    et_events   = p_events.

  READ TABLE p_events WITH KEY name = slis_ev_top_of_page
  INTO ls_event.

ENDFORM.                               " BUILD_EVENTTAB

*&---------------------------------------------------------------------
*&      Form  BUILD_COMMENT
*&---------------------------------------------------------------------

FORM build_comment USING p_heading TYPE slis_t_listheader.
  DATA: hline TYPE slis_listheader,
        TEXT(60) TYPE C,
        text1(120) TYPE C,
        text2(120) TYPE C,
        sep(20) TYPE C.
  CLEAR: hline, TEXT.
  hline-typ  = 'H'.
  "hline-info = 'ZRSD0045_ALV'.
  APPEND hline TO p_heading.

  SELECT SINGLE * FROM  t247
  WHERE  spras  = 'S'
  AND    mnr    = fkdat_p+7(2).

  CLEAR TEXT.
  CONCATENATE 'Fecha: ' sy-datum ' / ' sy-uname
  INTO TEXT SEPARATED BY space.
  hline-typ = 'A'.
  hline-info = TEXT.
  APPEND hline TO p_heading.

  CLEAR text1.
  text1 = 'Relación de Ventas del'.
  hline-typ = 'A'.
  hline-info = text1.

  CLEAR text2.
  CONCATENATE fkdat_p+9(2) 'de' t247-ltx 'de' fkdat_p+3(4)
  'al' fkdat_p+17(2) 'de' t247-ltx 'de' fkdat_p+11(4)
  INTO text2 SEPARATED BY space.
  hline-typ = 'A'.
  hline-info = text2.
  APPEND hline TO p_heading.
ENDFORM.                    " BUILD_COMMENT

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
  EXPORTING
    i_logo             = 'IMAGEN3'
    it_list_commentary = heading.
ENDFORM.                    "top_of_page


*&---------------------------------------------------------------------

*&      Form  ALVL_VALUE_REQUEST
*&---------------------------------------------------------------------

FORM alvl_value_request USING    pi_alv
      VALUE(p_0158).
  DATA: l_disvariant TYPE disvariant.

* Wertehilfe
  l_disvariant-REPORT  = sy-cprog.
*  l_disvariant-report(1) = 'A'.
  l_disvariant-variant = pi_alv.
  l_disvariant-log_group = p_0158.
  CALL FUNCTION 'LVC_VARIANT_SAVE_LOAD'
  EXPORTING
    i_save_load = 'F'
    i_tabname   = '1'
  CHANGING
    cs_variant  = l_disvariant
  EXCEPTIONS
    OTHERS      = 1.
  IF sy-subrc = 0.
    pi_alv = l_disvariant-variant.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " ALVL_VALUE_REQUEST

*&---------------------------------------------------------------------
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------

FORM build_layout USING p_layout TYPE slis_layout_alv.
  p_layout-f2code       = f2code.
  p_layout-zebra        = 'X'.
  p_layout-detail_popup = 'X'.
  p_layout-box_fieldname = 'SELEC'.
  p_layout-colwidth_optimize = 'X'.
  p_layout-cell_merge = 'X'.
  p_layout-detail_initial_lines = 'X'.
  p_layout-window_titlebar = 'LISTADO DE PROVEEDORES'.


ENDFORM.                               " BUILD_LAYOUT

*&---------------------------------------------------------------------
*&      Form  WRITE_OUTPUT
*&---------------------------------------------------------------------
FORM write_output.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
  EXPORTING
    i_program_name     = repname
    i_internal_tabname = 'it_salida'
    i_inclname         = repname
  CHANGING
    ct_fieldcat        = fieldtab.
  IF sy-subrc <> 0.
    WRITE: 'SY-SUBRC: ', sy-subrc, 'REUSE_ALV_FIELDCATALOG_MERGE'.
  ENDIF.

* INI PROCETI CJTC-DESK929404
  PERFORM f_insert_fieldcat
  TABLES fieldtab
  USING 'NAME1C'
        ''
        'IT_SALIDA'
        'CENTRO'.

  PERFORM f_insert_fieldcat
  TABLES fieldtab
  USING 'NAME1C'
        'VSTEL'
        'IT_SALIDA'
        'PUESTO DE EXPEDICION'.

  PERFORM f_insert_fieldcat
  TABLES fieldtab
  USING 'VSTEL' " INDEX
        'VTEX2' " INAERT
        'IT_SALIDA' " TABLE
        'DENOMINACIÓN PUESTO DE EXPEDICION'. " TEXTO

* FIN PROCETI CJTC-DESK929404
* INI PROCETI CJTC-DESK929556
  PERFORM f_insert_fieldcat
  TABLES fieldtab
  USING 'BOVBE'
        'KZWIB1'
        'IT_SALIDA'
        'PRECIO BRUTO'.

  PERFORM f_insert_fieldcat
  TABLES fieldtab
  USING 'KZWIB1'
        'KZWIB5'
        'IT_SALIDA'
        'DESCUENTO'.

  PERFORM f_insert_fieldcat
  TABLES fieldtab
  USING 'KZWIB5'
        'KZWIB2'
        'IT_SALIDA'
        'PRECIO NETO'.

  PERFORM f_insert_fieldcat
  TABLES fieldtab
  USING 'KZWIB2'
        'KOSTL'
        'IT_SALIDA'
        'CENTRO DE COSTO'.
* FIN PROCETI CJTC-DESK929556
*  PERFORM f_insert_fieldcat
*  TABLES fieldtab
*  USING 'VTEXT1'
*        'PRDHA'
*        'IT_SALIDA'
*        'Jerarquia de Productos'.
*  PERFORM f_insert_fieldcat
*  TABLES fieldtab
*  USING 'PRDHA'
*        'VTEXT1'
*        'IT_SALIDA'
*        'Denominacion'.

* Modificamos el catálogo de campos.
*  PERFORM modify_fieldcatalog  USING fieldtab[].


* Tabla con los campos por los se ordenarán el listado en el
* List Viewer
* La ordenación se realizará por: destinatario, ciente, pedido y
* posición de pedido.
*  PERFORM ordenar_listado USING: 1 'LIFNR' 'X' ' '.
*                                 2 'VBELN'  'X' ' '.
*                                 3 'POSNR'  'X' ' '.

** Informar Disposición de Salida
*  CLEAR g_variant.
*  g_variant-report    = sy-repid.
*  g_variant-variant   = p_alvasg.
*  g_variant-log_group = '   '.
*
*
*  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
*    EXPORTING
*      i_callback_program = v_repid.

*  REFRESH p_events.
  PERFORM build_comment USING heading[].
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program       = repname
*      i_callback_pf_status_set = 'PF_STATUS'
    i_callback_user_command  = 'USER_COMMAND'
    i_callback_top_of_page   = 'TOP_OF_PAGE'
    i_structure_name         = 'it_salida'
    is_layout                = layout
    it_fieldcat              = fieldtab
    i_default                = 'X'
    i_save                   = g_save
    is_variant               = g_variant
    it_events                = EVENTS[]
  TABLES
    t_outtab                 = it_salida
  EXCEPTIONS
    program_error            = 1
    OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                               " WRITE_OUTPUT
*---------------------------------------------------------------------
*      Form  ordenar_listado
*---------------------------------------------------------------------
* Tabla con los campos por los se ordenarán el listado en el
* List Viewer
*----------------------------------------------------------------------

FORM ordenar_listado USING p_spos p_fieldname p_up p_subtot.

  CLEAR t_sort.
  CLEAR e_sort.
  e_sort-spos = p_spos.
  e_sort-fieldname = p_fieldname.
  e_sort-UP = p_up.
  e_sort-subtot = p_subtot.
  APPEND e_sort TO t_sort.

ENDFORM.                    " ordenar_listado

*---------------------------------------------------------------------
*      Form  refrescar
*---------------------------------------------------------------------

FORM refrescar USING p_refresh.
  p_refresh = 'X'.
ENDFORM.                    " refrescar

*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->CE_FUNC_EXCLUDE  text
*----------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.
  SET PF-STATUS '100'.
ENDFORM.                    "PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UCOMM        text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command  USING ucomm LIKE sy-ucomm
*
      rs_selfield TYPE slis_selfield.
**  data : e_datos like ZES_LIBER_USUARIO.
*  COMMIT WORK.
*
  CASE ucomm.

  WHEN '&F05'.
    MESSAGE i000(zaviso).
*
*    WHEN 'FC01'.
*
*             .........
*
*
*
  ENDCASE.
*
*  RS_SELFIELD-REFRESH = 'X'.
*
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  ARMAR_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM armar_output .
  CLEAR it_salida.
  REFRESH it_salida.
  LOOP AT tab.
    IF tab-fkimg = 0.
      tab-fkimg = 1.
    ENDIF.
    IF tab-vrkme = 'ST'.
      tab-vrkme = 'PZA'.
    ENDIF.
    IF tab-bounv = 'ST'.
      tab-bounv = 'PZA'.
    ENDIF.
    promedio = tab-ntgew / tab-fkimg.
    MOVE tab-fkdat TO it_salida-fkdat.
    MOVE tab-vbeln TO it_salida-vbeln.
    MOVE tab-aubel TO it_salida-aubel.
    MOVE tab-ihrez TO it_salida-ihrez.
    MOVE tab-bstkd TO it_salida-bstkd.
    MOVE tab-vtext TO it_salida-vtext.
    MOVE tab-vkbur TO it_salida-vkbur.
    MOVE tab-vkorg TO it_salida-vkorg.
    MOVE tab-spart TO it_salida-spart.
    MOVE tab-vkgrp TO it_salida-vkgrp.
    MOVE tab-bezei TO it_salida-bezei.
    MOVE tab-kunag TO it_salida-kunag.
    MOVE tab-name1 TO it_salida-name1.
    MOVE tab-ort01 TO it_salida-ort01.
    MOVE tab-name1c TO it_salida-name1c.
    MOVE tab-posex TO it_salida-posex.
*PROCETI2 8/JULIO/2016
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = tab-matnr
    IMPORTING
      OUTPUT = tab-matnr.
*PROCETI2 8/JULIO/2016
    MOVE tab-matnr TO it_salida-matnr.
    MOVE tab-maktx+0(20) TO it_salida-maktx.
*PROCETI2 8/JULIO/2016
    MOVE tab-prdha  TO it_salida-prdha.   "Jerarquía de productos
    MOVE tab-vtext1 TO it_salida-vtext1.         "Denominación
*PROCETI2 8/JULIO/2016

    MOVE tab-fkimg TO it_salida-fkimg.
    MOVE tab-vrkme TO it_salida-vrkme.
    MOVE tab-ntgew TO it_salida-ntgew.
    MOVE tab-gewei TO it_salida-gewei.
    MOVE promedio TO it_salida-promedio.
    MOVE tab-bztxt+0(15) TO it_salida-bztxt.
    MOVE tab-precio TO it_salida-precio.
    MOVE tab-netwr TO it_salida-netwr.
    MOVE tab-bocan TO it_salida-bocan.
    MOVE tab-bounv TO it_salida-bounv.
    MOVE tab-bokgs TO it_salida-bokgs.
    MOVE tab-boump TO it_salida-boump.
* INI PROCETI CJTC-DESK929556
    IF tab-bovbe IS INITIAL.
      MOVE tab-kzwib2 TO it_salida-bonif.
    ELSE.
      MOVE tab-bonif TO it_salida-bonif.
    ENDIF.
* FIN PROCETI CJTC-DESK929556
    MOVE tab-bovbe TO it_salida-bovbe.
    MOVE tab-vtweg TO it_salida-vtweg.
* INI PROCETI CJTC-DESK929556
    MOVE tab-kzwi1 TO it_salida-kzwi1.
    MOVE tab-kzwi2 TO it_salida-kzwi2.
    MOVE tab-kzwi5 TO it_salida-kzwi5.
    MOVE tab-kzwib1 TO it_salida-kzwib1.
    MOVE tab-kzwib2 TO it_salida-kzwib2.
    MOVE tab-kzwib5 TO it_salida-kzwib5.
    MOVE tab-kostl TO it_salida-kostl.
* FIN PROCETI CJTC-DESK929556

* INI PROCETI CJTC-DESK929404

    MOVE tab-vstel TO it_salida-vstel.
    CLEAR: w_tvstt.

    READ TABLE t_tvstt
    INTO w_tvstt
    WITH KEY vstel = tab-vstel
    BINARY SEARCH.

    MOVE: w_tvstt-vtext TO it_salida-vtex2.

* FIN PROCETI CJTC-DESK929404

    APPEND it_salida.
    CLEAR it_salida.
  ENDLOOP.
ENDFORM.                    " ARMAR_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FIELDTAB  text
*      -->P_2069   text
*      -->P_2070   text
*----------------------------------------------------------------------*
FORM f_insert_fieldcat
TABLES p_fieldcat STRUCTURE w_fieldcat
USING  p_findex
      p_finsert
      p_tabname
      p_ftext.
  DATA: lv_index TYPE sytabix.
  READ TABLE p_fieldcat
  INTO w_fieldcat
  WITH KEY fieldname = p_findex.
  IF sy-subrc = 0.

    lv_index = sy-tabix.

    CASE p_finsert.
    WHEN space.

      MOVE: p_ftext TO w_fieldcat-reptext_ddic.
      MODIFY p_fieldcat FROM w_fieldcat
      INDEX lv_index
      TRANSPORTING reptext_ddic.

    WHEN OTHERS.

      ADD 1 TO lv_index.
      CLEAR: w_fieldcat.
      MOVE: p_finsert TO w_fieldcat-fieldname,
      p_tabname TO w_fieldcat-tabname,
      p_ftext   TO w_fieldcat-reptext_ddic.

      INSERT w_fieldcat
      INTO p_fieldcat
      INDEX lv_index.

    ENDCASE.
  ENDIF.

ENDFORM.                    " F_INSERT_FIELDCAT
