*&---------------------------------------------------------------------*
*&  Include           ZRMM0005B_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_OBTIENE_MARA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_obtiene_mara .
  DATA: BEGIN OF li_mara OCCURS 0,
    matnr LIKE mara-matnr,
    prdha LIKE mara-prdha,
    vtext LIKE t179t-vtext,
  END OF li_mara,
BEGIN OF lt_t001l OCCURS 0,
  werks TYPE t001l-werks,
  lgort TYPE t001l-lgort,
  lgobe TYPE t001l-lgobe,
END OF lt_t001l.
  DATA: li_rec LIKE TABLE OF rec WITH HEADER LINE.
  DATA: lv_tabix TYPE sytabix.
  li_rec[] = rec[].
  SORT li_rec
    BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_rec
  COMPARING matnr.

  SELECT a~matnr
         a~prdha
         b~vtext
    FROM mara AS a
    LEFT JOIN t179t AS b
    ON b~prodh =  a~prdha
    AND b~spras = sy-langu
    INTO TABLE li_mara
    FOR ALL ENTRIES IN li_rec
    WHERE a~matnr = li_rec-matnr.
  SORT li_mara
    BY matnr.

  li_rec[] = rec[].
  SORT li_rec
    BY werks
       lgort.
  DELETE ADJACENT DUPLICATES FROM li_rec
  COMPARING werks
            lgort.

  SELECT werks
         lgort
         lgobe
    FROM t001l
    INTO TABLE lt_t001l
    FOR ALL ENTRIES IN li_rec
    WHERE werks = li_rec-werks
      AND lgort = li_rec-lgort.

  SORT lt_t001l
    BY werks
       lgort.

  LOOP AT rec.

    lv_tabix = sy-tabix.

    CLEAR: li_mara.
    READ TABLE li_mara
    WITH KEY matnr = rec-matnr
    BINARY SEARCH.

    CLEAR: lt_t001l.
    READ TABLE lt_t001l
    WITH KEY werks = rec-werks
             lgort = rec-lgort
    BINARY SEARCH.

    IF li_mara-prdha NOT IN s_prdha.

      DELETE rec
      INDEX lv_tabix.
      CONTINUE.
    ENDIF.

    MOVE: li_mara-prdha TO rec-prdha,
          li_mara-vtext TO rec-vtext,
          lt_t001l-lgobe TO rec-lgobe.

*    PERFORM f_format
*    USING 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    CHANGING rec-matnr.
    MODIFY rec
    INDEX lv_tabix
    TRANSPORTING prdha
                 vtext
                 matnr
                 lgobe.
  ENDLOOP.
ENDFORM.                    " F_OBTIENE_MARA
*&---------------------------------------------------------------------*
*&      Form  F_LLENA_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT  text
*      -->P_0016   text
*      -->P_TEXT_T01  text
*      -->P_0018   text
*      -->P_0019   text
*      -->P_0020   text
*----------------------------------------------------------------------*
FORM f_llena_fieldcat
  TABLES pt_fieldcat STRUCTURE lvc_s_fcat "gt_fieldcat
  USING    p_field
           p_text
           p_outlen
           p_num.
*           p_icon.

  DATA: ls_fieldcat       TYPE lvc_s_fcat.

  CLEAR: "pt_fieldcat[],
         ls_fieldcat.
  ls_fieldcat-row_pos   = 1.
  ls_fieldcat-col_pos   = p_num.
  ls_fieldcat-fieldname = p_field.
  ls_fieldcat-tooltip   = 'X'.
  ls_fieldcat-col_opt   = 'X'.
*  ls_fieldcat-hotspot   = c_true.
  ls_fieldcat-scrtext_m = p_text.
  ls_fieldcat-outputlen = p_outlen.
*  ls_fieldcat-icon = p_icon.

  IF p_field = 'RECON'.
    ls_fieldcat-checkbox = 'X'.
*    ls_fieldcat-edit = 'X'.
    ls_fieldcat-hotspot = 'X'.
  ENDIF.

  APPEND ls_fieldcat TO pt_fieldcat.
ENDFORM.                    " F_LLENA_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0123   text
*      <--P_REC_MATNR  text
*----------------------------------------------------------------------*
FORM f_format
  USING p_func
  CHANGING p_field.

  CALL FUNCTION p_func
    EXPORTING
      input  = p_field
    IMPORTING
      output = p_field.

ENDFORM.                    " F_FORMAT
*&---------------------------------------------------------------------*
*&      Form  F_LLENA_LVC_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_LVC_S_SORT  text
*      -->P_0102   text
*      -->P_0103   text
*      -->P_0104   text
*----------------------------------------------------------------------*
FORM f_llena_lvc_sort
  TABLES p_lvc_t_sort STRUCTURE w_lvc_s_sort
  USING  p_fieldname
         p_up
         p_down
         p_group
         p_subtot.

  MOVE:  p_fieldname TO w_lvc_s_sort-fieldname,
         p_up TO w_lvc_s_sort-up,
         p_down TO w_lvc_s_sort-down,
         p_group TO w_lvc_s_sort-group,
         p_subtot TO w_lvc_s_sort-subtot.

  APPEND w_lvc_s_sort TO g_lvc_t_sort.
ENDFORM.                    " F_LLENA_LVC_SORT
*&---------------------------------------------------------------------*
*&      Form  F_OBTIENE_VBFA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_obtiene_vbfa .

  DATA: lt_rec LIKE TABLE OF rec WITH HEADER LINE,
        lt_vbfa_b LIKE TABLE OF t_vbfa_b WITH HEADER LINE,
        lt_vbap_sum LIKE TABLE OF t_vbap_sum WITH HEADER LINE,
        lt_vbap LIKE TABLE OF t_vbap WITH HEADER LINE,
        lt_vbap2 LIKE TABLE OF t_vbap WITH HEADER LINE,
        lt_vbak LIKE TABLE OF t_vbak WITH HEADER LINE.
  DATA: lv_tabix TYPE sytabix.
*Proceti2 10/JUN/2016
  data: lw_angdt type vbak-angdt,   "Fecha cotizacion
        lw_angma type vbak-angdt,   "Fecha mañana
        lw_angpa type vbak-angdt.   "Fecha pasado mañana
  lw_angma = sy-datum + 1.
  lw_angpa = sy-datum + 2.
*Proceti2 10/JUN/2016
* Obtiene todas las ofertas
  SELECT vbeln
         vbtyp
    FROM vbak
    INTO TABLE t_vbak
    WHERE vbtyp = 'B'.
    "and erdat ge sy-datum.

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
* Obtiene ofertas con pedido
  SELECT vbelv
         posnv
         vbeln
         posnn
         vbtyp_n
         rfmng
         meins
         rfwrt
         waers
         vbtyp_v
         plmin
    FROM vbfa
     INTO TABLE t_vbfa_b
    FOR ALL ENTRIES IN t_vbak
    WHERE vbelv = t_vbak-vbeln
      AND NOT posnv IS NULL
      AND NOT posnn IS NULL
      AND vbtyp_n = 'C'.

  DELETE t_vbfa_b
  WHERE posnv IS INITIAL.

  SORT t_vbfa_b
    BY vbelv.
* Elimina ofertas con pedido de tabla general de ofertas
  LOOP AT t_vbak.
    lv_tabix = sy-tabix.

    READ TABLE t_vbfa_b
    WITH KEY vbelv = t_vbak-vbeln
    BINARY SEARCH.

    IF sy-subrc = 0.
      DELETE t_vbak
      INDEX lv_tabix.
    ENDIF.

  ENDLOOP.

* Obtiene datos de ofertas sin pedido
  SELECT vbeln
         matnr
         klmeng
         ntgew
         werks
         lgort
    FROM vbap
    INTO
*Proceti2 10/JUN/2016
    corresponding fields of
*Proceti2 10/JUN/2016
    TABLE t_vbap
    FOR ALL ENTRIES IN t_vbak
    WHERE vbeln = t_vbak-vbeln.
*Proceti2 10/JUN/2016
*Actualiza Fecha de Oferta para cotizacion
  sort  t_vbap by vbeln.
  clear lw_angdt.
  loop at t_vbap.
    lv_tabix = sy-tabix.
    at new vbeln.
      select single angdt into lw_angdt
        from vbak where vbeln = t_vbap-vbeln.
    endat.
    t_vbap-angdt = lw_angdt.
    modify t_vbap index lv_tabix transporting angdt.
  endloop.
*Proceti2 10/JUN/2016

* Obtiene pedidos de tabla de Flujo de Documentos
  SELECT vbelv
         posnv
         vbeln
         posnn
         vbtyp_n
         rfmng
         meins
         rfwrt
         waers
         vbtyp_v
         plmin
    FROM vbfa
     INTO TABLE lt_vbfa_b
    FOR ALL ENTRIES IN t_vbfa_b
    WHERE vbelv = t_vbfa_b-vbeln
      AND NOT posnv IS NULL
      AND NOT posnn IS NULL.
*      AND vbtyp_n = 'M'.

  DELETE lt_vbfa_b
  WHERE posnv IS INITIAL.

* Obtiene datos de pedidos sin factura
  SELECT vbeln
         matnr
         klmeng
         ntgew
         werks
         lgort
    FROM vbap
*Proceti2 10/JUN/2016
    INTO
     corresponding fields of
*Proceti2 10/JUN/2016
    TABLE lt_vbap
    FOR ALL ENTRIES IN t_vbfa_b
    WHERE vbeln = t_vbfa_b-vbeln
      AND posnr = t_vbfa_b-posnn.
*      AND NOT b~vbtyp_n = 'M'.
*  lt_vbap2[] = lt_vbap[].
  SORT lt_vbfa_b
    BY vbelv
       vbtyp_n.
  LOOP AT lt_vbap.
    lv_tabix = sy-tabix.
* Busca pedidos con factura generada
    READ TABLE lt_vbfa_b
    WITH KEY vbelv = lt_vbap-vbeln
             vbtyp_n = 'M'
    BINARY SEARCH.

* Si ya tiene factura, se elimina
    IF sy-subrc = 0.
      DELETE lt_vbap
      INDEX lv_tabix.
    ENDIF.

  ENDLOOP.
  SORT t_vbfa_b
    BY vbelv
       vbtyp_n.

  IF NOT t_vbap[] IS INITIAL.
* Sumariza ofertas sin pedidos
    LOOP AT t_vbap
      INTO t_vbap.

      CLEAR: t_vbap_sum.

      MOVE: t_vbap-matnr TO t_vbap_sum-matnr,
            t_vbap-werks TO t_vbap_sum-werks,
            t_vbap-lgort TO t_vbap_sum-lgort.

      CLEAR: t_vbfa_b.
      READ TABLE t_vbfa_b
      WITH KEY vbelv = t_vbap-vbeln
                     vbtyp_n = 'C'
      BINARY SEARCH.

      IF NOT sy-subrc = 0.
        MOVE: t_vbap-klmeng TO t_vbap_sum-klmenc,
              t_vbap-ntgew TO t_vbap_sum-ntgew.
*Proceti2 10/JUN/2016
**Cotiza hoy
        if t_vbap-angdt = sy-datum.
          move t_vbap-ntgew TO t_vbap_sum-cothoy.
        endif.
***Cotiza mañana
        if t_vbap-angdt = lw_angma.
          move t_vbap-ntgew TO t_vbap_sum-cotma.
        endif.
***Cotiza pasado mañana
        if t_vbap-angdt = lw_angpa.
          move t_vbap-ntgew TO t_vbap_sum-cotpas.
        endif.
*Proceti2 10/JUN/2016

        COLLECT t_vbap_sum.
*      ELSE.
*        MOVE: t_vbap-klmeng TO t_vbap_sum-klmenb.
      ENDIF.


    ENDLOOP.
  ENDIF.

  SORT lt_vbap_sum
    BY matnr.
  SORT t_vbfa_b
    BY vbeln.
  IF NOT lt_vbap[] IS INITIAL.
* Sumariza pedidos sin Factura.
    LOOP AT lt_vbap
      INTO lt_vbap.

      CLEAR: lt_vbap_sum.

      MOVE: lt_vbap-matnr TO lt_vbap_sum-matnr,
            lt_vbap-werks TO  lt_vbap_sum-werks,
            lt_vbap-lgort TO  lt_vbap_sum-lgort.

      CLEAR: lt_vbfa_b.
      READ TABLE lt_vbfa_b
      WITH KEY vbelv = lt_vbap-vbeln
                     vbtyp_n = 'M'
      BINARY SEARCH.

      IF NOT sy-subrc = 0.
        MOVE: lt_vbap-klmeng TO lt_vbap_sum-klmenc,
              lt_vbap-ntgew TO lt_vbap_sum-ntgew.

        COLLECT lt_vbap_sum.
      ENDIF.


    ENDLOOP.
    SORT: t_vbap_sum
      BY matnr
         werks
         lgort,
          lt_vbap_sum
      BY matnr
         werks
         lgort.
    LOOP AT rec.
      lv_tabix = sy-tabix.

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = rec-matnr
*        IMPORTING
*          output = rec-matnr.

      CLEAR: t_vbap_sum.
      READ TABLE t_vbap_sum
        WITH KEY matnr = rec-matnr
                 werks = rec-werks
                 lgort = rec-lgort
        BINARY SEARCH.

      CLEAR: lt_vbap_sum.
      READ TABLE lt_vbap_sum
        WITH KEY matnr = rec-matnr
                 werks = rec-werks
                 lgort = rec-lgort
        BINARY SEARCH.

      MOVE: t_vbap_sum-ntgew TO rec-klmenb,
*Proceti2 10/JUN/2016
            t_vbap_sum-cothoy  to rec-cothoy,
            t_vbap_sum-cotma   to rec-cotma,
            t_vbap_sum-cotpas  to rec-cotpas,
*Proceti2 10/JUN/2016
            lt_vbap_sum-ntgew TO rec-klmenc.
*Proceti2 10/JUN/2016
*      rec-klmend = rec-lbkum - ( rec-klmenc + rec-klmenb ).
            rec-klmend = rec-lbkum - ( rec-cothoy + rec-cotma + rec-cotpas + rec-klmenc ).
*Proceti2 10/JUN/2016
      MODIFY rec
      INDEX lv_tabix
      TRANSPORTING klmenb
*Proceti2 10/JUN/2016
                   cothoy
                   cotma
                   cotpas
*Proceti2 10/JUN/2016
                   klmenc
                   klmend.
    ENDLOOP.
    sort rec by matnr.
    delete ADJACENT DUPLICATES FROM rec COMPARING ALL FIELDS.
  ENDIF.

ENDFORM.                    " F_OBTIENE_VBFA
