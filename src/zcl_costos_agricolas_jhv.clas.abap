CLASS zcl_costos_agricolas_jhv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      rg_popers TYPE RANGE OF t009b-poper .        "
    TYPES:
      rg_dauat TYPE RANGE OF afpo-dauat .        "
    TYPES:
      rg_bwart TYPE RANGE OF mseg-bwart .        "
    TYPES:
      rg_fechas TYPE RANGE OF mseg-budat_mkpf .        "
    TYPES:
      vl_i_aufnr TYPE STANDARD TABLE OF zco_tt_aufnr_fin .        "
    TYPES:
      rg_werks TYPE RANGE OF afpo-dwerk .
    TYPES:
      rg_bukrs TYPE RANGE OF t001-bukrs .
    TYPES:
      rg_matkl TYPE RANGE OF mara-matkl .
    TYPES:
      rg_aufnr TYPE RANGE OF afko-aufnr .
    TYPES:
      rg_kostl TYPE RANGE OF coep-kostl.
    TYPES:
      rg_kstar TYPE RANGE OF coep-kstar.

    METHODS get_aufnr_cte     "
      IMPORTING
        !p_gjahr   TYPE gjahr
        !p_popers  TYPE rg_popers
        !p_bukrs   TYPE rg_bukrs
        !p_clorder TYPE rg_dauat OPTIONAL
        !p_tipo    TYPE string OPTIONAL
        !p_werks   TYPE rg_werks OPTIONAL
      CHANGING
        !i_tabla   TYPE STANDARD TABLE .
    METHODS calculate_dates                                          "
      CHANGING
        !p_rgfechas TYPE rg_fechas .
    METHODS get_ventas_netas
      IMPORTING
        !p_bukrs  TYPE rg_bukrs
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .
    METHODS get_inv_inicial
      IMPORTING
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
        !i_bukrs  TYPE rg_bukrs
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .
    METHODS get_inv_final
      IMPORTING
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
        !i_bukrs  TYPE rg_bukrs
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .
    METHODS get_costos_pro
      IMPORTING
        !i_aufnr TYPE rg_aufnr
      CHANGING
        !i_tabla TYPE STANDARD TABLE .
    METHODS valida_ctos_vta
      IMPORTING
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
        !i_bukrs  TYPE rg_bukrs
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .
    METHODS get_ndi
      IMPORTING
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
        !i_bukrs  TYPE rg_bukrs
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .
    METHODS get_semilla
      IMPORTING
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
        !i_bukrs  TYPE rg_bukrs
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .

    METHODS get_gastos_cosech
      IMPORTING
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
        !i_kostl  TYPE rg_kostl
        !i_kstar  TYPE rg_kstar
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .

    METHODS get_gastos_opera
      IMPORTING
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
        !i_kostl  TYPE rg_kostl
        !i_kstar  TYPE rg_kstar
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .

    METHODS get_otros_gastos
      IMPORTING
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
        !i_bukrs  TYPE rg_bukrs
        !i_kstar  TYPE rg_kstar
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .

        METHODS get_impuestos
      IMPORTING
        !p_gjahr  TYPE gjahr
        !p_popers TYPE rg_popers
        !i_bukrs  TYPE rg_bukrs
        !i_kstar  TYPE rg_kstar
      CHANGING
        !i_tabla  TYPE STANDARD TABLE .

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA rg_fechafin TYPE rg_popers .    "
    DATA vl_gjahr TYPE gjahr .    "
    DATA vl_werks TYPE rg_werks .
    DATA:
      it_status TYPE STANDARD TABLE OF jstat .      "
    DATA ord_valida TYPE aufnr .     ""e_sysst LIKE bsvx-sttxt.
    DATA lv_objnr TYPE jsto-objnr .    "

    METHODS get_daysmonth
      IMPORTING
        !p_date    TYPE d
      CHANGING
        !p_numdays TYPE i .                                 "
ENDCLASS.



CLASS ZCL_COSTOS_AGRICOLAS_JHV IMPLEMENTATION.


  METHOD calculate_dates. "calculo de fechas "

    DATA: cadena      TYPE string,
          vl_fechaI   TYPE d,
          vl_fechaF   TYPE d,
          num_days    TYPE i,
          vl_poper(2) TYPE c,
          vl_gjahr1   TYPE gjahr.

    DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
          wa_rgfechas LIKE LINE OF rg_fechas.


    SELECT poper FROM t009b
      INTO TABLE @DATA(it_009b)
      WHERE poper IN @rg_fechafin
      GROUP BY poper  ORDER BY poper ASCENDING.

    LOOP AT it_009b INTO DATA(wa_poper).
      CLEAR wa_rgfechas.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_poper-poper
        IMPORTING
          output = vl_poper.


      CONCATENATE vl_gjahr vl_poper '01' INTO cadena.
      vl_fechaI = cadena.

      CALL METHOD get_daysmonth
        EXPORTING
          p_date    = vl_fechaI
        CHANGING
          p_numdays = num_days.


      CONCATENATE vl_gjahr vl_poper '01' INTO cadena.
      vl_fechaF = cadena.
      vl_fechaF+6(2) = num_days.
      wa_rgfechas-low = vl_fechaI.
      wa_rgfechas-high = vl_fechaF.
      wa_rgfechas-option = 'BT'.
      wa_rgfechas-sign = 'I'.
      APPEND wa_rgfechas TO rg_fechas.

    ENDLOOP.

    p_rgfechas = rg_fechas.
  ENDMETHOD.


  METHOD get_aufnr_cte. "ordenes "

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    vl_gjahr = p_gjahr.
    rg_fechafin = p_popers.

    CALL METHOD calculate_dates
      CHANGING
        p_rgfechas = lv_rgfechas.
    .

    LOOP AT lv_rgfechas INTO DATA(warg).
      IF min IS INITIAL.
        min = warg-high.
      ENDIF.
      IF max IS INITIAL.
        max = warg-high.
      ENDIF.
      IF min > warg-high.
        min = warg-high.
      ENDIF.
      IF max < warg-high.
        max = warg-high.
      ENDIF.
    ENDLOOP.

    DELETE lv_rgfechas WHERE high NE min.

    READ TABLE lv_rgfechas INTO DATA(wa) INDEX 1.
    wa-high = max.
    MODIFY lv_rgfechas FROM wa INDEX 1.



    SELECT DISTINCT a~aufnr, a~gstri, a~getri,a~gltri,a~ftrmi, p~dauat, p~pwerk, p~dwerk,c~objnr,p~ablad, a~plnbez,
       p~objnp, substring( a~getri, 5,2 ) AS popera, substring(  a~gltri,5,2 ) AS popoerb
     FROM afko AS a
    INNER JOIN afpo AS p ON p~aufnr = a~aufnr
    INNER JOIN caufv AS c ON c~aufnr EQ a~aufnr
    INNER JOIN t001k AS t ON t~bwkey = c~werks
   WHERE ( a~getri IN @lv_rgfechas )
   AND c~bukrs IN @p_bukrs
   INTO TABLE @DATA(it_aufnr_close).



    IF it_aufnr_close IS NOT INITIAL.
      LOOP AT it_aufnr_close INTO DATA(wa_aufnr).
        lv_objnr = wa_aufnr-objnr.

        CALL FUNCTION 'STATUS_READ'
          EXPORTING
            client           = sy-mandt
            objnr            = lv_objnr
            only_active      = 'X'
          TABLES
            status           = it_status
          EXCEPTIONS
            object_not_found = 1
            OTHERS           = 2.
        IF sy-subrc EQ 0.


*              READ TABLE it_status INTO DATA(wa_notie) WITH KEY stat = 'I0009'. "NOTI Excl.
*              IF sy-subrc EQ 0.
*          READ TABLE it_status INTO DATA(wa_cerre) WITH KEY stat = 'I0046'. "CERR Excl.
*          IF sy-subrc EQ 0.
**            ord_valida = wa_aufnr-aufnr.
**                ELSE.
*            READ TABLE it_status INTO DATA(wa_ctece) WITH KEY stat = 'I0045'. "CTEC
*            IF sy-subrc EQ 0.
*              ord_valida = wa_aufnr-aufnr.
*            ENDIF.
*          ELSE.
*            CLEAR ord_valida.
*          ENDIF.
**              ENDIF.
*
*          IF ord_valida IS INITIAL.
*            DELETE it_aufnr_close WHERE aufnr = wa_aufnr-aufnr.
*            .
*          ENDIF.
*
*        ELSE.

          "READ TABLE it_status INTO DATA(wa_noti) WITH KEY stat = 'I0009'. "NOTI Excl.
*          IF sy-subrc EQ 0.
          READ TABLE it_status INTO DATA(wa_cerr) WITH KEY stat = 'I0046'. "CERR Excl.
          IF sy-subrc EQ 0.
            ord_valida = wa_aufnr-aufnr.
          ELSE.
            READ TABLE it_status INTO DATA(wa_ctec) WITH KEY stat = 'I0045'. "CTEC
            IF sy-subrc EQ 0.
              ord_valida = wa_aufnr-aufnr.
            ELSE.
              CLEAR ord_valida.
            ENDIF.
          ENDIF.
*          ELSE.
*            CLEAR ord_valida.
*          ENDIF.

          IF ord_valida IS INITIAL.
            DELETE it_aufnr_close WHERE aufnr = wa_aufnr-aufnr.
            .
          ENDIF.



        ENDIF.

      ENDLOOP.


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*      SORT it_aufnr_close BY getri DESCENDING.
*
*
*
*      SELECT belnr, budat, perio, auak~objnr
*      INTO TABLE @DATA(it_auak)
*        FROM auak
*      FOR ALL ENTRIES IN @it_aufnr_close
*        WHERE objnr = @it_aufnr_close-objnr
*        .
*
*      SORT it_auak BY objnr belnr DESCENDING.
*
*
*      LOOP AT it_aufnr_close INTO DATA(wa_test) WHERE getri IS INITIAL.
*        READ TABLE it_auak INTO DATA(wa_auak) WITH KEY objnr = wa_test-objnr.
*        IF sy-subrc EQ 0.
*          "IF wa_auak-budat+4(2) EQ wa_test-gltri+4(2) .
*          wa_test-getri = wa_auak-budat.
*          wa_test-popera = wa_auak-perio+1(2).
*          MODIFY it_aufnr_close FROM wa_test TRANSPORTING getri popera WHERE objnr = wa_test-objnr.
*          "ENDIF.
*
*        ENDIF.
*      ENDLOOP.

*      DELETE it_aufnr_close WHERE getri IS INITIAL.
*      DELETE it_aufnr_close WHERE getri NOT IN lv_rgfechas.

      SORT it_aufnr_close BY aufnr DESCENDING.
      DELETE ADJACENT DUPLICATES FROM it_aufnr_close COMPARING aufnr.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ENDIF.
    i_tabla[] = it_aufnr_close[].

  ENDMETHOD.


  METHOD get_costos_pro.

    FIELD-SYMBOLS: <fs_struct> TYPE any,
                   <fs_linea>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),vl_matnr    TYPE matnr,
    vl_bwkey TYPE bwkey,
    vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    SELECT  racct, s~txt50 AS concepto , acdoca~aufnr,matnr, werks, msl, runit, hsl, rwcur, budat,
           concat( '0', substring( a~getri,5,2 ) ) AS poper, ryear
    FROM acdoca
    INNER JOIN skat AS s ON s~saknr = acdoca~racct
    INNER JOIN afko AS a ON a~aufnr = acdoca~aufnr
    WHERE acdoca~aufnr IN @i_aufnr
    INTO TABLE @DATA(it_costos_pro).

*****************SE COMENTA 10/06/2025 POR CAMBIO DE PRECIO ESTÁNDAR A VARIABLE EN CONSUMOS.
*
*    SELECT lfmon, lfgja, bwkey, matnr, verpr
*      INTO TABLE @DATA(it_mbewh)
*      FROM mbewh
*      FOR ALL ENTRIES IN @it_costos_pro
*      WHERE lfgja = @it_costos_pro-ryear
*      AND matnr = @it_costos_pro-matnr.
*
*
*    LOOP AT it_costos_pro ASSIGNING <fs_struct>.
*
*      "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
*      UNASSIGN <fs_linea>.
*      ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fs_struct> TO <fs_linea>.
*      vl_lfmon = <fs_linea>+4(2).
*      vl_lfgja = <fs_linea>+0(4).
*
*      UNASSIGN <fs_linea>.
*      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_struct> TO <fs_linea>.
*      vl_matnr = <fs_linea>.
*
*      UNASSIGN <fs_linea>.
*      ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_struct> TO <fs_linea>.
*      vl_bwkey = <fs_linea>.
*
*      READ TABLE it_mbewh INTO DATA(wa_mbewh)
*                  WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
*                           bwkey = vl_bwkey matnr = vl_matnr.
*
*      IF sy-subrc EQ 0.
*        UNASSIGN <fs_linea>.
*        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_struct> TO <fs_linea>.
*        vl_menge = <fs_linea>.
*
*        UNASSIGN <fs_linea>.
*        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_struct> TO <fs_linea>.
*        vl_dmbtr = <fs_linea>.
*
*
*        IF wa_mbewh-verpr GT 0.
*          vl_dmbtr = vl_menge * wa_mbewh-verpr.
*        ENDIF.
*
*        UNASSIGN <fs_linea>.
*        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_struct> TO <fs_linea>.
*        <fs_linea> = vl_dmbtr.
*
*      ENDIF.
*
*      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*************************************************************************************
*    ENDLOOP.
    i_tabla = it_costos_pro[].
  ENDMETHOD.


  METHOD get_daysmonth. "cálculo de dias en el mes "

    DATA: xdatum TYPE d.

    xdatum = p_date.
    xdatum+6(2) = '01'.
    xdatum = xdatum + 35.          "para llegar seguro al proximo mes
    xdatum+6(2) = '01'. xdatum = xdatum - 1.
    p_numDays = xdatum+6(2).

  ENDMETHOD.


  METHOD get_inv_final.

    DATA: vl_rglfmon TYPE RANGE OF mbewh-lfmon,
          wa_rglfmon LIKE LINE OF vl_rglfmon.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.
    DATA: gjahr_query TYPE gjahr,
          lfmon_query TYPE lfmon.

    vl_gjahr = p_gjahr.
    rg_fechafin = p_popers.


    CALL METHOD calculate_dates
      CHANGING
        p_rgfechas = lv_rgfechas.
    .

    LOOP AT lv_rgfechas INTO DATA(warg).
      IF min IS INITIAL.
        min = warg-high.
      ENDIF.
      IF max IS INITIAL.
        max = warg-high.
      ENDIF.
      IF min > warg-high.
        min = warg-high.
      ENDIF.
      IF max < warg-high.
        max = warg-high.
      ENDIF.
    ENDLOOP.

    DELETE lv_rgfechas WHERE high NE min.

    READ TABLE lv_rgfechas INTO DATA(wa) INDEX 1.
    wa-high = max.
    MODIFY lv_rgfechas FROM wa INDEX 1.



    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400007' OR mbewh~matnr EQ '000000000000400007'  ) THEN
    CAST( 'INVENTARIOS FINALES' AS CHAR( 50 ) ) ELSE 'BORRAR'
    END AS concepto,
    CAST( lbkum AS QUAN( 13,3 ) ) AS lbkum,
    CAST( salk3 AS DEC( 13,2 ) ) AS  salk3,
    CAST( concat( concat( lfgja,lfmon ),'01' ) AS DATS ) AS budat_mkpf,
     lfmon
    FROM mbewh
    INNER JOIN T001k AS t ON t~bwkey = mbewh~bwkey
    WHERE
    t~bukrs IN @i_bukrs
    "mbewh~bwkey IN @i_werks
    AND matnr IN ('000000000000400007','000000000000400007' )
    AND lfgja EQ @vl_gjahr AND lfmon IN @p_popers
    INTO TABLE @DATA(it_mbewh).


    i_tabla = it_mbewh.
  ENDMETHOD.


  METHOD get_inv_inicial.

    DATA: vl_rglfmon TYPE RANGE OF mbewh-lfmon,
          wa_rglfmon LIKE LINE OF vl_rglfmon.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.
    DATA: gjahr_query TYPE gjahr,
          lfmon_query TYPE lfmon.

    vl_gjahr = p_gjahr.
    rg_fechafin = p_popers.


    CALL METHOD calculate_dates
      CHANGING
        p_rgfechas = lv_rgfechas.
    .

    LOOP AT lv_rgfechas INTO DATA(warg).
      IF min IS INITIAL.
        min = warg-high.
      ENDIF.
      IF max IS INITIAL.
        max = warg-high.
      ENDIF.
      IF min > warg-high.
        min = warg-high.
      ENDIF.
      IF max < warg-high.
        max = warg-high.
      ENDIF.
    ENDLOOP.

    DELETE lv_rgfechas WHERE high NE min.

    READ TABLE lv_rgfechas INTO DATA(wa) INDEX 1.
    wa-high = max.
    MODIFY lv_rgfechas FROM wa INDEX 1.

    IF wa-low+4(2) EQ '01'.
      gjahr_query = vl_gjahr - 1.
    ELSE.
      gjahr_query = vl_gjahr.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    SELECT poper FROM t009b
          INTO TABLE @DATA(it_009b)
          WHERE poper IN @rg_fechafin
          GROUP BY poper  ORDER BY poper ASCENDING.

    LOOP AT it_009b ASSIGNING FIELD-SYMBOL(<fs_lfmon>).
      ASSIGN COMPONENT 'POPER' OF STRUCTURE <fs_lfmon> TO FIELD-SYMBOL(<field>).
      IF <field> EQ '01' AND gjahr_query NE vl_gjahr.
        <field> = '01'.
        lfmon_query = '12'.
      ELSE.
        <field> = <field> - 1.
      ENDIF.

      wa_rglfmon-sign = 'I'.
      wa_rglfmon-option = 'EQ'.
      wa_rglfmon-low = <field>.
      APPEND wa_rglfmon TO vl_rglfmon.
    ENDLOOP.
    DELETE ADJACENT DUPLICATES FROM vl_rglfmon COMPARING low.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400007' OR mbewh~matnr EQ '000000000000500008'  ) THEN
    CAST( 'INVENTARIOS INICIALES' AS CHAR( 50 ) ) ELSE 'BORRAR'
    END AS concepto,
    CAST( lbkum AS QUAN( 13,3 ) ) AS lbkum,
    CAST( salk3 AS DEC( 13,2 ) ) AS  salk3,
    CAST( concat( concat( lfgja,lfmon ),'01' ) AS DATS ) AS budat_mkpf,
     lfmon
    FROM mbewh
    INNER JOIN T001k AS t ON t~bwkey = mbewh~bwkey
    WHERE
    t~bukrs IN @i_bukrs
    "mbewh~bwkey IN @i_werks
    AND matnr IN ('000000000000400007','000000000000500008' )
    AND lfgja EQ @vl_gjahr AND lfmon IN @vl_rglfmon

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400007' OR mbewh~matnr EQ '000000000000500008'  ) THEN
    CAST( 'INVENTARIOS INICIALES' AS CHAR( 50 ) ) ELSE 'BORRAR'
    END AS concepto,
    CAST( lbkum AS QUAN( 13,3 ) ) AS lbkum,
    CAST( salk3 AS DEC( 13,2 ) ) AS  salk3,
    CAST( concat( concat( lfgja, @lfmon_query ),'01' ) AS DATS ) AS budat_mkpf,
     lfmon
    FROM mbewh
     INNER JOIN T001k AS t ON t~bwkey = mbewh~bwkey
    WHERE
    t~bukrs IN @i_bukrs
    "bwkey IN @i_werks
    AND matnr IN ('000000000000400007','000000000000500008' )
    AND lfgja EQ @gjahr_query AND lfmon EQ @lfmon_query
     INTO TABLE @DATA(it_mbewh).





    LOOP AT it_mbewh ASSIGNING FIELD-SYMBOL(<wa_mbewh>).
      ASSIGN COMPONENT 'BUDAT_MKPF' OF STRUCTURE <wa_mbewh> TO <field>.
      IF  gjahr_query NE vl_gjahr.
        CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
          EXPORTING
            date      = <field>
            days      = 00
            months    = 01
            signum    = '+'
            years     = 00
          IMPORTING
            calc_date = <field>.
      ELSE.
        CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
          EXPORTING
            date      = <field>
            days      = 00
            months    = 01
            signum    = '+'
            years     = 00
          IMPORTING
            calc_date = <field>.

      ENDIF.
      CLEAR max.
      max = <field>.

      ASSIGN COMPONENT 'LFMON' OF STRUCTURE <wa_mbewh> TO <field>.
      <field> =  max+4(2).

    ENDLOOP.
    i_tabla = it_mbewh.
  ENDMETHOD.


  METHOD get_ndi.

    SELECT CAST( 'NO REPARTIDOS' AS CHAR( 50 ) ) AS concepto, c2~poper,CAST( coalesce( SUM( c2~sumdif ) , 0 ) AS  DEC( 12,3 ) ) AS ndi

      FROM ckmvfm_extract AS c1
      INNER JOIN ckmvfm_out AS c2
      ON c2~exid = c1~exid
    WHERE c1~bdatj = @p_gjahr
    AND c1~poper IN @p_popers
    AND c2~bukrs IN @i_bukrs
    AND c2~pos_type EQ 'NDI'
    AND c2~curtp = '10'
    AND c1~fiacc = 'R'
    GROUP BY c2~poper
     INTO TABLE @DATA(it_ckmvfm).


    SORT it_ckmvfm BY poper.
    i_tabla = it_ckmvfm[].



  ENDMETHOD.


  METHOD get_semilla.

    FIELD-SYMBOLS: <fs_struct> TYPE any,
                   <fs_linea>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),vl_matnr    TYPE matnr,
    vl_bwkey TYPE bwkey,
    vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    SELECT  racct,CAST( 'CONSUMO SEMILLA' AS CHAR( 50 ) ) AS concepto , acdoca~aufnr,matnr, werks, msl, runit, hsl, rwcur, budat,
           acdoca~poper, ryear
    FROM acdoca
    INNER JOIN skat AS s ON s~saknr = acdoca~racct
    "INNER JOIN afko AS a ON a~aufnr = acdoca~aufnr
    WHERE acdoca~ryear = @p_gjahr
    AND acdoca~poper IN @p_popers
    AND acdoca~rbukrs IN @i_bukrs
    AND acdoca~racct = '0504025052'
    INTO TABLE @DATA(it_semillas).


    SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_semillas
      WHERE lfgja = @it_semillas-ryear
      AND matnr = @it_semillas-matnr.


    LOOP AT it_semillas ASSIGNING <fs_struct>.

      "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
      UNASSIGN <fs_linea>.
      ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fs_struct> TO <fs_linea>.
      vl_lfmon = <fs_linea>+4(2).
      vl_lfgja = <fs_linea>+0(4).

      UNASSIGN <fs_linea>.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_struct> TO <fs_linea>.
      vl_matnr = <fs_linea>.

      UNASSIGN <fs_linea>.
      ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_struct> TO <fs_linea>.
      vl_bwkey = <fs_linea>.

      READ TABLE it_mbewh INTO DATA(wa_mbewh)
                  WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                           bwkey = vl_bwkey matnr = vl_matnr.

      IF sy-subrc EQ 0.
        UNASSIGN <fs_linea>.
        ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_struct> TO <fs_linea>.
        vl_menge = <fs_linea>.

        UNASSIGN <fs_linea>.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_struct> TO <fs_linea>.
        vl_dmbtr = <fs_linea>.


        IF wa_mbewh-verpr GT 0.
          vl_dmbtr = vl_menge * wa_mbewh-verpr.
        ENDIF.

        UNASSIGN <fs_linea>.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_struct> TO <fs_linea>.
        <fs_linea> = vl_dmbtr.

      ENDIF.
    ENDLOOP.

    i_tabla = it_semillas[].
  ENDMETHOD.


  METHOD get_ventas_netas.

    DATA: vl_rgracct TYPE RANGE OF acdoca-racct,
          wa_rgracct LIKE LINE OF vl_rgracct.

    SELECT subsetname, descript
  INTO TABLE @DATA(head_activities)
  FROM setnode
  INNER JOIN setheadert AS h ON h~setclass = setnode~setclass
  AND h~subclass = setnode~subclass AND h~setname = setnode~subsetname
  WHERE setnode~setname = 'REPCTOAGVT'
  AND setnode~setclass = '0102' AND setnode~subclass = 'GP00'.

    SELECT setname, valfrom
    INTO TABLE @DATA(it_leaf)
    FROM setleaf
    FOR ALL ENTRIES IN @head_activities
    WHERE setname = @head_activities-subsetname.


    IF it_leaf[] IS NOT INITIAL.

      LOOP AT it_leaf INTO DATA(wa_leaf).

        wa_rgracct-option = 'EQ'.
        wa_rgracct-sign = 'I'.
        wa_rgracct-low = wa_leaf-valfrom.
        APPEND wa_rgracct TO vl_rgracct.
      ENDLOOP.

      SELECT racct, a~matnr,
      coalesce( CAST( m~maktx AS CHAR( 50 ) ), 'VENTA CAÑA' ) AS concepto, msl, runit, hsl, rhcur, poper "si esta vacio maktx poner "VENTA CAÑA"
      INTO TABLE @DATA(it_acdoca)
      FROM acdoca AS a
      LEFT JOIN makt AS m ON m~matnr = a~matnr
      WHERE a~rbukrs IN @p_bukrs
      AND gjahr = @p_gjahr
      AND racct IN @vl_rgracct
      AND poper IN @p_popers
      AND ktopl = 'GP00'.

    ENDIF.
    i_tabla = it_acdoca[].

  ENDMETHOD.


  METHOD valida_ctos_vta.

    FIELD-SYMBOLS: <fs_struct> TYPE any,
                   <fs_linea>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4), vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    SELECT CAST( 'VALIDACIÓN COSTO DE VENTA' AS CHAR( 50 ) ) AS concepto, poper, SUM( msl ) AS msl, SUM( hsl ) AS hsl
    FROM acdoca
    WHERE
    rbukrs IN @i_bukrs  AND gjahr = @p_gjahr AND acdoca~racct IN ('0501001004','0501001007') AND poper IN @p_popers
    GROUP BY poper
    INTO TABLE @DATA(it_costos_pro)
    .

    i_tabla = it_costos_pro[].
  ENDMETHOD.


  METHOD get_gastos_cosech.

    SELECT perio, kostl, kstar, wogbtr AS wtgbtr
    INTO TABLE @DATA(it_coep)
    FROM v_coep_view
    WHERE kokrs = 'GA00' AND perio IN @p_popers
    AND gjahr = @p_gjahr
    AND kstar IN @i_kstar
    AND kostl IN @i_kostl.

    i_tabla = it_coep[].

  ENDMETHOD.


  METHOD get_gastos_opera.

    SELECT perio, kostl, kstar, wogbtr AS wtgbtr
    INTO TABLE @DATA(it_coep)
    FROM v_coep_view
    WHERE kokrs = 'GA00' AND perio IN @p_popers
    AND gjahr = @p_gjahr
    AND kstar IN @i_kstar
    AND kostl IN @i_kostl.

    i_tabla = it_coep[].

  ENDMETHOD.


  METHOD get_otros_gastos.

    TYPES: BEGIN OF st_datos,
             perio  TYPE co_perio,
             kostl  TYPE kostl,
             kstar  TYPE kstar,
             wtgbtr TYPE wtgxxx,
           END OF st_datos.


    DATA: vl_companycode         TYPE bukrs,
          vl_glacct              TYPE saknr,
          vl_fiscalyear          TYPE gjahr,
          vl_currencytype        TYPE curtp,
          it_account_balances    TYPE STANDARD TABLE OF bapi3006_4,
          wa_it_account_balances LIKE LINE OF it_account_balances.

    DATA: it_datos TYPE STANDARD TABLE OF st_datos,
          wa_datos LIKE LINE OF it_datos.


    vl_fiscalyear = p_gjahr.
    vl_currencytype = '10'.

    LOOP AT i_bukrs INTO DATA(wa_bukrs).
      vl_companycode = wa_bukrs-low.

      LOOP AT i_kstar INTO DATA(wa_kstar).
        vl_glacct = wa_kstar-low.

        CALL FUNCTION 'BAPI_GL_ACC_GETPERIODBALANCES'
          EXPORTING
            companycode      = vl_companycode
            glacct           = vl_glacct
            fiscalyear       = vl_fiscalyear
            currencytype     = vl_currencytype
          TABLES
            account_balances = it_account_balances.

        DELETE  it_account_balances WHERE fis_period NOT IN p_popers.

        LOOP AT it_account_balances INTO DATA(wa_account).
          CLEAR wa_datos.
          wa_datos-perio = wa_account-fis_period.
          wa_datos-kstar = wa_account-gl_account.
          wa_datos-wtgbtr = wa_account-per_sales_long.
          COLLECT wa_datos INTO it_datos.
        ENDLOOP.

      ENDLOOP.
    ENDLOOP.

    i_tabla = it_datos[].
  ENDMETHOD.


  METHOD get_impuestos.

     TYPES: BEGIN OF st_datos,
             perio  TYPE co_perio,
             kostl  TYPE kostl,
             kstar  TYPE kstar,
             wtgbtr TYPE wtgxxx,
           END OF st_datos.


    DATA: vl_companycode         TYPE bukrs,
          vl_glacct              TYPE saknr,
          vl_fiscalyear          TYPE gjahr,
          vl_currencytype        TYPE curtp,
          it_account_balances    TYPE STANDARD TABLE OF bapi3006_4,
          wa_it_account_balances LIKE LINE OF it_account_balances.

    DATA: it_datos TYPE STANDARD TABLE OF st_datos,
          wa_datos LIKE LINE OF it_datos.


    vl_fiscalyear = p_gjahr.
    vl_currencytype = '10'.

    LOOP AT i_bukrs INTO DATA(wa_bukrs).
      vl_companycode = wa_bukrs-low.

      LOOP AT i_kstar INTO DATA(wa_kstar).
        vl_glacct = wa_kstar-low.

        CALL FUNCTION 'BAPI_GL_ACC_GETPERIODBALANCES'
          EXPORTING
            companycode      = vl_companycode
            glacct           = vl_glacct
            fiscalyear       = vl_fiscalyear
            currencytype     = vl_currencytype
          TABLES
            account_balances = it_account_balances.

        DELETE  it_account_balances WHERE fis_period NOT IN p_popers.

        LOOP AT it_account_balances INTO DATA(wa_account).
          CLEAR wa_datos.
          wa_datos-perio = wa_account-fis_period.
          wa_datos-kstar = wa_account-gl_account.
          wa_datos-wtgbtr = wa_account-per_sales_long.
          COLLECT wa_datos INTO it_datos.
        ENDLOOP.

      ENDLOOP.
    ENDLOOP.

    i_tabla = it_datos[].

  ENDMETHOD.
ENDCLASS.
