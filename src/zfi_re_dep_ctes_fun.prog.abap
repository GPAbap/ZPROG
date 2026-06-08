*&---------------------------------------------------------------------*
*& Include          ZFI_RE_DEP_CTES_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM  get_data .

*  SELECT k~kunnr, concat_with_space( a~sort1, a~sort2, 1 ) AS nombre,
*         CASE WHEN k~stcd3 IS INITIAL THEN k~stcd1 ELSE k~stcd3 END AS stcd3, k~stras, k~pstlz, k~ort01, k~regio,
*     b~budat, b~bldat, b~cpudt, b~wrbtr, b~blart,
*    b2~zzfpago, b2~belnr,b2~augbl,b2~bukrs,b2~gjahr, bk~stblg as anulado
*    FROM bsad_view AS b
*    INNER JOIN kna1 AS k ON k~kunnr EQ b~kunnr
*    INNER JOIN adrc AS a ON a~addrnumber = k~adrnr
*    INNER JOIN bseg AS b2 ON b2~belnr = b~belnr AND b2~bukrs = b~bukrs AND b2~gjahr = b~gjahr
*              and b2~buzei = b~buzei
*    INNER JOIN bkpf as bk on bk~belnr = b2~belnr AND bk~bukrs = b2~bukrs AND bk~gjahr = b2~gjahr
* WHERE b~bukrs = @p_bukrs AND
*    b~kunnr IN @so_kunnr AND
*    b~cpudt IN @so_cpudt AND
*    b~budat IN @so_budat AND
*    b~monat IN @so_monat AND
*    b~gjahr EQ @p_gjahr
*    "and b~belnr ne b~augbl
*     INTO TABLE @DATA(it_datos_tmp).
*
*
*  SELECT bukrs,belnr,gjahr,zzfpago,bschl
*    INTO TABLE @DATA(it_dz)
*    FROM bseg
*    FOR ALL ENTRIES IN @it_datos_tmp
*  WHERE bukrs = @it_datos_tmp-bukrs
*       AND belnr = @it_datos_tmp-belnr
*    AND gjahr = @it_datos_tmp-gjahr
*    AND  bseg~fdlev = 'F1'.


*  LOOP AT IT_dATOS_TMP ASSIGNING FIELD-SYMBOL(<wa_dz>) WHERE blart = 'DZ'.
*    READ TABLE it_dz INTO DATA(wa) WITH KEY bukrs = <wa_dz>-bukrs belnr = <wa_dz>-belnr gjahr = <wa_dz>-gjahr.
*    IF sy-subrc EQ 0.
*      <wa_dz>-zzfpago = wa-zzfpago.
*    ENDIF.
*  ENDLOOP.


  "bsid
  SELECT k~kunnr, concat_with_space( aa~sort1, aa~sort2, 1 ) AS nombre,
         CASE WHEN k~stcd3 IS INITIAL THEN k~stcd1 ELSE k~stcd3 END AS stcd3, k~stras, k~pstlz, k~ort01, k~regio,
         a~budat, a~bldat, a~cpudt, a~wrbtr, a~blart,
         a~bukrs, a~belnr, a~gjahr,
         a~shkzg, a~dmbtr,
         b~stblg AS anulado, c~zzfpago,
         CASE WHEN a~blart = 'DZ' THEN a~belnr ELSE '          ' END  AS augbl
    FROM bsid_view AS a
        LEFT JOIN bkpf AS b
      ON b~bukrs = a~bukrs
     AND b~belnr = a~belnr
     AND b~gjahr = a~gjahr
     LEFT JOIN bseg AS c
    ON c~bukrs = a~bukrs
   AND c~belnr = a~belnr
   AND c~gjahr = a~gjahr
   AND c~buzei = a~buzei

     INNER JOIN kna1 AS k ON k~kunnr EQ a~kunnr
    INNER JOIN adrc AS aa ON aa~addrnumber = k~adrnr
    WHERE a~bukrs = @p_bukrs
     AND a~kunnr IN @so_kunnr
     AND a~budat IN @so_budat
     INTO TABLE @DATA(gt_partidas).


  "bsad
  SELECT k~kunnr, concat_with_space( aa~sort1, aa~sort2, 1 ) AS nombre,
         CASE WHEN k~stcd3 IS INITIAL THEN k~stcd1 ELSE k~stcd3 END AS stcd3, k~stras, k~pstlz, k~ort01, k~regio,
         a~budat, a~bldat, a~cpudt, a~wrbtr, a~blart,
         a~bukrs, a~belnr, a~gjahr,
         a~shkzg, a~dmbtr,
         b~stblg AS anulado, c~zzfpago,
         CASE WHEN a~blart = 'DZ' THEN a~belnr ELSE '          ' END  AS augbl
    FROM bsad_view AS a
    LEFT JOIN bkpf AS b
      ON b~bukrs = a~bukrs
     AND b~belnr = a~belnr
     AND b~gjahr = a~gjahr
    LEFT JOIN bseg AS c
    ON c~bukrs = a~bukrs
   AND c~belnr = a~belnr
   AND c~gjahr = a~gjahr
   AND c~buzei = a~buzei
    INNER JOIN kna1 AS k ON k~kunnr EQ a~kunnr
    INNER JOIN adrc AS aa ON aa~addrnumber = k~adrnr

   WHERE a~bukrs = @p_bukrs
     AND a~kunnr IN @so_kunnr
     AND a~budat IN @so_budat
   APPENDING TABLE @gt_partidas.

  SELECT bukrs,belnr,augbl,dmbtr,gjahr,zzfpago,bschl
    INTO TABLE @DATA(it_dz)
    FROM bseg
    FOR ALL ENTRIES IN @gt_partidas
  WHERE bukrs = @gt_partidas-bukrs
       AND belnr = @gt_partidas-belnr
    AND gjahr = @gt_partidas-gjahr
    AND  bseg~fdlev = 'F1'.



  LOOP AT gt_partidas ASSIGNING FIELD-SYMBOL(<wa_dz>) WHERE blart = 'DZ'.
    READ TABLE it_dz INTO DATA(wa) WITH KEY bukrs = <wa_dz>-bukrs belnr = <wa_dz>-belnr gjahr = <wa_dz>-gjahr.
    IF sy-subrc EQ 0.
      <wa_dz>-zzfpago = wa-zzfpago.
      <wa_dz>-augbl = wa-augbl.
      <wa_dz>-dmbtr = wa-dmbtr.
      <wa_dz>-wrbtr = wa-dmbtr.
    ENDIF.
  ENDLOOP.

  DATA(it_Odz) = gt_partidas[].
  DELETE gt_partidas WHERE blart = 'DZ'.

  DELETE it_Odz WHERE blart NE 'DZ'.
  DELETE it_Odz WHERE blart EQ 'DZ' AND shkzg = 'S'.

  SORT it_Odz BY blart bukrs belnr gjahr dmbtr anulado zzfpago augbl.
  DELETE ADJACENT DUPLICATES FROM it_Odz COMPARING
  blart bukrs belnr gjahr dmbtr anulado zzfpago augbl.

  APPEND LINES OF it_Odz TO gt_partidas.


*LOOP AT gt_partidas INTO DATA(gs_partida).
*
*  READ TABLE gt_resumen INTO gs_resumen
*    WITH KEY bukrs = gs_partida-bukrs
*             kunnr = gs_partida-kunnr.
*
*  IF sy-subrc <> 0.
*    CLEAR gs_resumen.
*    gs_resumen-bukrs = gs_partida-bukrs.
*    gs_resumen-kunnr = gs_partida-kunnr.
*    APPEND gs_resumen TO gt_resumen.
*    READ TABLE gt_resumen INTO gs_resumen
*      WITH KEY bukrs = gs_partida-bukrs
*               kunnr = gs_partida-kunnr.
*  ENDIF.
*
*  IF gs_partida-shkzg = 'S'.
*    gs_resumen-total_fact = gs_resumen-total_fact + gs_partida-dmbtr.
*  ELSEIF gs_partida-shkzg = 'H'.
*    gs_resumen-total_pago = gs_resumen-total_pago + gs_partida-dmbtr.
*  ENDIF.
*
*  gs_resumen-saldo = gs_resumen-total_fact - gs_resumen-total_pago.
*
*  MODIFY gt_resumen FROM gs_resumen
*    TRANSPORTING total_fact total_pago saldo
*    WHERE bukrs = gs_resumen-bukrs
*      AND kunnr = gs_resumen-kunnr.
*
*ENDLOOP.



  it_datos = VALUE #(
    FOR ls_datos IN gt_partidas
    (
           kunnr   = ls_datos-kunnr
           nombre  = ls_datos-nombre
           stcd3   = ls_datos-stcd3
           stras   = ls_datos-stras
           pstlz  = ls_datos-pstlz
           ort01   = ls_datos-ort01
           regio   = ls_datos-regio
           budat  = ls_datos-budat
           bldat = ls_datos-bldat
           cpudt  = ls_datos-cpudt
           wrbtr  = ls_datos-wrbtr
           blart  = ls_datos-blart
           zzfpago = ls_datos-zzfpago
           belnr = ls_datos-belnr
           augbl = ls_datos-augbl
           anulado = ls_datos-anulado
    )
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .



  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = it_datos
      ).
      """""""""""""""""""""""""""""""""""""""""""""""""""""""
      go_columns = go_alv->get_columns( ).
      TRY.

* Columna
          go_column = go_columns->get_column( 'KUNNR' ).

          go_column->set_short_text( 'Cliente' ).
          go_column->set_medium_text( 'Cliente' ).
          go_column->set_long_text( 'Cliente' ).

*
          go_column = go_columns->get_column( 'NOMBRE' ).

          go_column->set_short_text( 'Nombre' ).
          go_column->set_medium_text( 'Nombre' ).
          go_column->set_long_text( 'Nombre' ).

*    * Columna
          go_column = go_columns->get_column( 'STCD3' ).

          go_column->set_short_text( 'RFC' ).
          go_column->set_medium_text( 'RFC' ).
          go_column->set_long_text( 'RFC' ).

*
          go_column = go_columns->get_column( 'STRAS' ).

          go_column->set_short_text( 'Calle' ).
          go_column->set_medium_text( 'Calle' ).
          go_column->set_long_text( 'Calle' ).

          go_column = go_columns->get_column( 'PSTLZ' ).
          go_column->set_short_text( 'CP' ).
          go_column->set_medium_text( 'Código P.' ).
          go_column->set_long_text( 'Código Postal' ).

          go_column = go_columns->get_column( 'PSTLZ' ).
          go_column->set_short_text( 'CP' ).
          go_column->set_medium_text( 'Código P.' ).
          go_column->set_long_text( 'Código Postal' ).

        CATCH cx_salv_not_found.
      ENDTRY.

*---------------------------------------------------
* ACTIVAR FUNCIONES STANDARD
*---------------------------------------------------
      go_alv->get_functions( )->set_all( abap_true ).

*---------------------------------------------------
* CONFIGURAR LAYOUTS
*---------------------------------------------------
      go_layout = go_alv->get_layout( ).

      gs_key-report = sy-repid.

      go_layout->set_key( gs_key ).

* Permitir guardar layouts
      go_layout->set_save_restriction(
        if_salv_c_layout=>restrict_none
      ).

* Layout por defecto
      go_layout->set_default( abap_true ).



      go_alv->display( ).

    CATCH cx_salv_msg INTO DATA(lx_msg).
      MESSAGE lx_msg->get_text( ) TYPE 'E'.
  ENDTRY.


ENDFORM.
