*&---------------------------------------------------------------------*
*& Include          ZCONS_POST_FN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CONSULTA_zcons_post
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONSULTA_zcons_post.
*****************************************************************************
  DATA rg_fechas TYPE RANGE OF mseg-budat_mkpf.
  Field-SYMBOLS <fs_mseg> type te_mseg.
*  TYPES: BEGIN OF te_interna  ,
*           ejercicio  LIKE mseg-gjahr,
**           ejercicio(4) TYPE n,
*           mes(2)     TYPE c,
*           dia_ini(2) TYPE c,
*           dia_fin(2) TYPE c,
*           periodo    LIKE   t009b-poper,
*           fec_ini    LIKE mseg-budat_mkpf,
*           fec_fin    LIKE mseg-budat_mkpf,
**           fec_ini(8)   TYPE d,
**           fec_fin(8)   TYPE d,
*         END OF te_interna.
*  DATA: ti_mseg TYPE STANDARD TABLE OF te_interna WITH HEADER LINE.
*  DATA: gt_interna LIKE LINE OF ti_mseg.
*
*  DATA: ti_009b TYPE STANDARD TABLE OF t009b WITH HEADER LINE.
*
*  REFRESH: ti_mseg, ti_009b, gt_mseg.
*
*  SELECT poper FROM t009b
*    INTO CORRESPONDING FIELDS OF TABLE
*    ti_009b WHERE
*    poper IN peri
*    GROUP BY poper  ORDER BY poper ASCENDING.
*
*  LOOP AT ti_009b.
*    IF ti_009b-poper IN peri.
*      gt_interna-ejercicio = ejer.
*      CASE ti_009b-poper.
*        WHEN '001'.
*          gt_interna-periodo = '001'.
*          gt_interna-mes = 1.
*          gt_interna-dia_fin = 31.
*        WHEN '002'.
*          gt_interna-periodo = '002'.
*          gt_interna-mes = 2.
*          gt_interna-dia_fin = 29.
*        WHEN '003'.
*          gt_interna-periodo = '003'.
*          gt_interna-mes = 3.
*          gt_interna-dia_fin = 31.
*        WHEN '004'.
*          gt_interna-periodo = '004'.
*          gt_interna-mes = 4.
*          gt_interna-dia_fin = 30.
*        WHEN '005'.
*          gt_interna-periodo = '005'.
*          gt_interna-mes = 5.
*          gt_interna-dia_fin = 31.
*        WHEN '006'.
*          gt_interna-periodo = '006'.
*          gt_interna-mes = 6.
*          gt_interna-dia_fin = 30.
*        WHEN '007'.
*          gt_interna-periodo = '007'.
*          gt_interna-mes = 7.
*          gt_interna-dia_fin = 31.
*        WHEN '008'.
*          gt_interna-periodo = '008'.
*          gt_interna-mes = 8.
*          gt_interna-dia_fin = 31.
*        WHEN '009'.
*          gt_interna-periodo = '009'.
*          gt_interna-mes = 9.
*          gt_interna-dia_fin = 30.
*        WHEN '010'.
*          gt_interna-periodo = '010'.
*          gt_interna-mes = 10.
*          gt_interna-dia_fin = 31.
*        WHEN '011'.
*          gt_interna-periodo = '011'.
*          gt_interna-mes = 11.
*          gt_interna-dia_fin = 30.
*        WHEN '012'.
*          gt_interna-periodo = '012'.
*          gt_interna-mes = 12.
*          gt_interna-dia_fin = 31.
*      ENDCASE.
*      gt_interna-dia_ini = '01'.
*      IF gt_interna-mes >= 10.
*        CONCATENATE gt_interna-ejercicio gt_interna-mes gt_interna-dia_ini INTO gt_interna-fec_ini.
*        CONCATENATE gt_interna-ejercicio gt_interna-mes gt_interna-dia_fin INTO gt_interna-fec_fin.
*      ELSE.
*        CONCATENATE gt_interna-ejercicio '0' gt_interna-mes gt_interna-dia_ini INTO gt_interna-fec_ini.
*        CONCATENATE gt_interna-ejercicio '0' gt_interna-mes gt_interna-dia_fin INTO gt_interna-fec_fin.
*      ENDIF.
*      INSERT gt_interna INTO TABLE ti_mseg.
*    ENDIF.
*  ENDLOOP.

  IF cen[] IS INITIAL.
    PERFORM fill_cen_PRPC.
  ENDIF.

  PERFORM create_dates CHANGING rg_fechas.
  SORT rg_fechas BY low high ASCENDING.

  SELECT a~werks, lgort, a~mblnr, mjahr,
    zeile, a~aufnr, a~matnr, c~maktx, cast( '0001' as numc ) as grund, 'xxx' as grtxt,
    a~bwart, shkzg, gjahr,substring( a~budat_mkpf,5,2 ) AS poper, bukrs,
    prctr, sakto, pprctr, lfbnr,
    cputm_mkpf, budat_mkpf, cpudt_mkpf,
    CASE WHEN shkzg = 'H' THEN  dmbtr * -1 ELSE dmbtr END AS dmbtr,
    waers,CASE WHEN shkzg = 'H' THEN  a~menge * -1 ELSE a~menge END AS menge,
    a~meins,z1~matnr  as zmatnr
    FROM ( mseg AS a INNER JOIN mara AS b ON  a~matnr = b~matnr )
    INNER JOIN  makt AS c ON a~matnr = c~matnr
    INNER JOIN ztpp_mov_postura as z1 on z1~mblnr = a~mblnr and z1~bwart = a~bwart and z1~werks = a~werks
    WHERE b~mtart IN @tipo
    AND a~bukrs IN @soc
    AND a~matnr IN @mat
    "AND gjahr in @ejer
    AND lgort IN @alma
    AND a~werks IN @cen
    AND a~bwart IN @cla_mov
    AND charg IN @lote
    AND budat_mkpf IN @rg_fechas
  UNION ALL
   SELECT a~werks, lgort, a~mblnr, mjahr,
    zeile, a~aufnr, a~matnr, c~maktx, cast( '0001' as numc ) as grund, 'xxx' as grtxt,
    a~bwart, shkzg, gjahr,substring( a~budat_mkpf,5,2 ) AS poper, bukrs,
    prctr, sakto, pprctr, lfbnr,
    cputm_mkpf, budat_mkpf, cpudt_mkpf,
    CASE WHEN shkzg = 'H' THEN  dmbtr * -1 ELSE dmbtr END AS dmbtr,
    waers,CASE WHEN shkzg = 'H' THEN  a~menge * -1 ELSE a~menge END AS menge,
    a~meins,z2~matnr  as zmatnr
    FROM ( mseg AS a INNER JOIN mara AS b ON  a~matnr = b~matnr )
    INNER JOIN  makt AS c ON a~matnr = c~matnr
    INNER JOIN ztpp_mov_crianza as z2 on z2~mblnr = a~mblnr and z2~bwart = a~bwart and z2~werks = a~werks
    WHERE b~mtart IN @tipo
    AND a~bukrs IN @soc
    AND a~matnr IN @mat
    AND lgort IN @alma
    AND a~werks IN @cen
    AND a~bwart IN @cla_mov
    AND charg IN @lote
    AND budat_mkpf IN @rg_fechas
    INTO TABLE @gt_mseg
.


  SORT gt_mseg BY shkzg ASCENDING.

   SELECT zprogram, zcampo, zconstante, zvalor, zcomentario
     into table @data(it_zcons_pp)
   from zcons_pp.


   select bwart, grund, grtxt
     FROM t157e
   INTO TABLE @data(it_t157e)
   where spras eq 'S'.


  LOOP AT gt_mseg ASSIGNING <fs_mseg>.
      IF ( <fs_mseg>-werks+0(2) EQ 'PR').
        read table it_zcons_pp into data(wa_post) WITH KEY zconstante = <fs_mseg>-zmatnr zprogram = 'POSTURA'.
        IF ( sy-subrc eq 0 ).
             <fs_mseg>-grund = wa_post-zvalor+0(4).
             clear <fs_mseg>-grtxt.
             read table it_t157e into data(txtpos) WITH KEY bwart = <fs_mseg>-bwart grund = <fs_mseg>-grund.
             <fs_mseg>-grtxt = txtpos-grtxt.
        ELSE.
          read table it_zcons_pp into data(wa_postalt) WITH KEY zconstante = <fs_mseg>-bwart zprogram = 'POSTURA'.
          IF ( sy-subrc eq 0 ).
            clear <fs_mseg>-grund.
            <fs_mseg>-grtxt = wa_postalt-zcomentario.
          else.
            clear <fs_mseg>-grund.
            clear <fs_mseg>-grtxt.
          ENDIF.
        ENDIF.
      ELSEIF ( <fs_mseg>-werks+0(2) EQ 'PC').
        read table it_zcons_pp into data(wa_cria) WITH KEY zconstante = <fs_mseg>-zmatnr zprogram = 'CRIANZA'.
           IF ( sy-subrc eq 0 ).
              <fs_mseg>-grund = wa_cria-zvalor+0(4).
              clear <fs_mseg>-grtxt.
              read table it_t157e into data(txtcri) WITH KEY bwart = <fs_mseg>-bwart grund = <fs_mseg>-grund.
              <fs_mseg>-grtxt = txtcri-grtxt.
           else.
             read table it_zcons_pp into data(wa_criaalt) WITH KEY zconstante = <fs_mseg>-bwart zprogram = 'CRIANZA'.
              IF ( sy-subrc eq 0 ).
                clear <fs_mseg>-grund.
                <fs_mseg>-grtxt = wa_postalt-zcomentario.
              else.
                clear <fs_mseg>-grund.
                clear <fs_mseg>-grtxt.
              ENDIF.
           ENDIF.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input         = <fs_mseg>-matnr
       IMPORTING
         OUTPUT        = <fs_mseg>-matnr
                .


  ENDLOOP.



*  LOOP AT gt_mseg.
**    IF gt_mseg-bwart = 261 OR gt_mseg-bwart = 102 OR gt_mseg-bwart = 601 OR gt_mseg-bwart = 641.
**      gt_mseg-dmbtr =  gt_mseg-dmbtr * -1 .
**    ELSEIF gt_mseg-bwart = 262 OR gt_mseg-bwart = 101 OR gt_mseg-bwart = 602 OR gt_mseg-bwart = 642.
**      gt_mseg-dmbtr =  gt_mseg-dmbtr.
**    ENDIF.
**    MODIFY gt_mseg.
*    IF gt_mseg-shkzg = 'H'.
*      gt_mseg-dmbtr =  gt_mseg-dmbtr * -1.
*      gt_mseg-menge = gt_mseg-menge * -1.
*      MODIFY gt_mseg.
*    ENDIF.
*  ENDLOOP.

*261 - negativo
*262 - positivo
*101 -  Positivo
*102- Negativo
*601 - Negativo
*602 - Positivo
*641 - Negativo
*642 - Positivo
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_dates
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_dates CHANGING p_rg_fechas.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        wa_rgfechas LIKE LINE OF rg_fechas.


  DATA: cadena      TYPE string,
        vl_fechaI   TYPE d,
        vl_fechaF   TYPE d,
        num_days    TYPE i,
        vl_poper(2) TYPE c,
        vl_gjahr    TYPE gjahr.

  SELECT poper FROM t009b
    INTO TABLE @DATA(it_009b)
    WHERE
    poper IN @peri
    GROUP BY poper  ORDER BY poper ASCENDING.

  REFRESH rg_fechas.
  LOOP AT it_009b INTO DATA(wa_poper).
    CLEAR wa_rgfechas.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_poper-poper
      IMPORTING
        output = vl_poper.

    IF ejer-high IS INITIAL. "solo hay un año.
      LOOP AT ejer.

        CONCATENATE ejer-low vl_poper '01' INTO cadena.
        vl_fechaI = cadena.
        PERFORM get_daysMonth USING vl_fechaI
                             CHANGING num_days.

        CONCATENATE ejer-low vl_poper '01' INTO cadena.
        vl_fechaF = cadena.
        vl_fechaF+6(2) = num_days.
        wa_rgfechas-low = vl_fechaI.
        wa_rgfechas-high = vl_fechaF.
        wa_rgfechas-option = 'BT'.
        wa_rgfechas-sign = 'I'.
        APPEND wa_rgfechas TO rg_fechas.
      ENDLOOP.
    ELSE. "Rango de años
      CLEAR vl_gjahr.
      vl_gjahr = ejer-low.
      WHILE vl_gjahr LE ejer-high.

        CONCATENATE vl_gjahr vl_poper '01' INTO cadena.
        vl_fechaI = cadena.

        PERFORM get_daysMonth USING vl_fechaI
                        CHANGING num_days.

        CONCATENATE vl_gjahr vl_poper '01' INTO cadena.
        vl_fechaF = cadena.
        vl_fechaF+6(2) = num_days.
        wa_rgfechas-low = vl_fechaI.
        wa_rgfechas-high = vl_fechaF.
        wa_rgfechas-option = 'BT'.
        wa_rgfechas-sign = 'I'.
        APPEND wa_rgfechas TO rg_fechas.
        vl_gjahr = vl_gjahr + 1.
      ENDWHILE.
    ENDIF.



  ENDLOOP.

  p_rg_fechas = rg_fechas.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_daysMonth
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- NUM_DATES
*&---------------------------------------------------------------------*
FORM get_daysMonth USING p_date TYPE d
                  CHANGING p_num_dates.

  DATA: xdatum TYPE d.

  xdatum = p_date.
  xdatum+6(2) = '01'.
  xdatum = xdatum + 35.          "para llegar seguro al proximo mes
  xdatum+6(2) = '01'. xdatum = xdatum - 1.
  p_num_dates = xdatum+6(2).


ENDFORM.

FORM validate_werks CHANGING flag.

  LOOP AT SCREEN.
    IF screen-name EQ 'CEN-LOW'.
      LOOP AT cen.
        IF NOT ( cen-low CP 'PR*'  OR  cen-low CP 'PC*' ).

          flag = '1'.

        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDLOOP.

ENDFORM.

FORM fill_cen_PRPC.

  DATA wa_cen LIKE LINE OF cen.

  MOVE: 'I' TO wa_cen-sign,
  'CP' TO wa_cen-option,
  'PR*' TO wa_cen-low.
  APPEND wa_cen TO cen.

  MOVE: 'I' TO wa_cen-sign,
    'CP' TO wa_cen-option,
    'PC*' TO wa_cen-low.
  APPEND wa_cen TO cen.

ENDFORM.
