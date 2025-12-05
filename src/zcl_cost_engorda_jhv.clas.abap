class ZCL_COST_ENGORDA_JHV definition
  public
  final
  create public .

public section.

  types:
    rg_popers TYPE RANGE OF t009b-poper .      "
  types:
    rg_dauat TYPE RANGE OF afpo-dauat .      "
  types:
    rg_bwart TYPE RANGE OF mseg-bwart .      "
  types:
    rg_fechas TYPE RANGE OF mseg-budat_mkpf .      "
  types:
    rg_aufnr type range of aufk-aufnr .
  types:
    vl_i_aufnr TYPE STANDARD TABLE OF zco_tt_aufnr_fin .      "
  types:
    rg_werks TYPE RANGE OF afpo-dwerk .
  types:
    rg_matkl TYPE RANGE OF mara-matkl .

  methods GET_AUFNR_CTE   "
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !P_CLORDER type RG_DAUAT
      !P_TIPO type STRING optional
      !P_WERKS type RG_WERKS optional
    changing
      !I_TABLA type STANDARD TABLE optional
      !I_AUFNR type STANDARD TABLE optional .
  methods GET_AUFNR_ABLAD   "
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !P_CLORDER type RG_DAUAT
      !P_WERKS type RG_WERKS
      !I_AUFNR type VL_I_AUFNR optional
    changing
      !I_MTS2 type STANDARD TABLE .
  methods GET_MB51   "
    importing
      !I_AUFNR type VL_I_AUFNR
      !I_RGBWART type RG_BWART
    changing
      !CH_MB51 type STANDARD TABLE .
  methods GET_MB51_POST   "
    importing
      !I_AUFNR type VL_I_AUFNR
      !I_RGBWART type RG_BWART
    changing
      !CH_MB51 type STANDARD TABLE .
  methods GET_MB51_CRIANZA   "
    importing
      !I_AUFNR type VL_I_AUFNR
      !I_RGBWART type RG_BWART
    changing
      !CH_MB51 type STANDARD TABLE .
  methods GET_MB51_INCUBADORA   "
    importing
      !I_AUFNR type VL_I_AUFNR
      !I_RGBWART type RG_BWART
    changing
      !CH_MB51 type STANDARD TABLE .
  methods GET_MB51_DEP
    importing
      !I_WERKS type RG_WERKS
      !I_MATKL type RG_MATKL
      !I_RGBWART type RG_BWART
    changing
      !CH_MB51_DEP type STANDARD TABLE .
  methods GET_MB51_ENG   "
    importing
      !I_AUFNR type VL_I_AUFNR
      !I_RGBWART type RG_BWART
    changing
      !CH_MB51 type STANDARD TABLE .
  methods GET_MB51_HUEVO   "
    importing
      !I_AUFNR type VL_I_AUFNR
      !I_RGBWART type RG_BWART
    changing
      !CH_MB51 type STANDARD TABLE .
  methods GET_MB51_ALIM   "
    importing
      !I_AUFNR type VL_I_AUFNR
      !I_RGBWART type RG_BWART
    changing
      !CH_MB51 type STANDARD TABLE .
  methods GET_ACDOCA   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_ACDOCA type STANDARD TABLE .
  methods GET_ACDOCA_PPA_DET   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_ACDOCA type STANDARD TABLE .
  methods GET_ACDOCA_POST   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_ACDOCA type STANDARD TABLE .
  methods GET_ACDOCA_CRIANZA   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_ACDOCA type STANDARD TABLE .
  methods GET_ACDOCA_ENG   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_ACDOCA type STANDARD TABLE .
  methods GET_ACDOCA_FLETE   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_ACDOCA type STANDARD TABLE .
  methods GET_APARCERIA   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_APARCERIA type STANDARD TABLE .
  methods GET_MERMAS   "
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !I_RGBWART type RG_BWART
      !I_WERKS type RG_WERKS
    changing
      !CH_MERMAS type STANDARD TABLE .
  methods GET_MERMAS_MAQ   "
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !I_RGBWART type RG_BWART
    changing
      !CH_MERMAS_MAQ type STANDARD TABLE .
  methods GET_RECUPERACIONES   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_RECUPERA type STANDARD TABLE .
  methods GET_RECUPERACIONES_POST   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_RECUPERA type STANDARD TABLE .
  methods GET_RECUPERACIONES_CRIANZA   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_RECUPERA type STANDARD TABLE .
  methods GET_SUB_HC   "
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !I_BWART type RG_BWART
      !I_WERKS type RG_WERKS
    changing
      !CH_SUB_HC type STANDARD TABLE .
  methods GET_SUBPRD_GAPESA   "
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !I_BWART type RG_BWART
      !I_WERKS type RG_WERKS
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_SUB_HC type STANDARD TABLE .
  methods GET_ESTADISTICOS_POST  "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_RECUPERA type STANDARD TABLE .
  methods GET_COSTOWIP
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_RECUPERA type STANDARD TABLE .
  methods GET_ESTADISTICOS_CRIANZA  "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_RECUPERA type STANDARD TABLE .
  methods GET_RECUPERA_ALIM   "
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
    changing
      !CH_RECUPERA type STANDARD TABLE .
  methods GET_MAQUILA   " maquila
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !P_WERKS type RG_WERKS
    changing
      !CH_MAQUILA type STANDARD TABLE .
  methods GET_MAQUILA_ACA   " maquila
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !P_WERKS type RG_WERKS
    changing
      !CH_MAQUILA type STANDARD TABLE .
  methods GET_MAQUILA_GAPESA   " maquila
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !P_WERKS type RG_WERKS
    changing
      !CH_MAQUILA type STANDARD TABLE .
  methods GET_ALPESUR   "
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !P_WERKS type RG_WERKS
    changing
      !CH_ALPESUR type STANDARD TABLE .
  methods GET_KGS_PZAS   "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_KGS_PZAS type STANDARD TABLE .
  methods GET_KGS_PZAS_PROCPPA   "
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
    changing
      !CH_KGS_PZAS type STANDARD TABLE .
  methods GET_KGS_PZAS_DEP   "
    importing
      !I_WERKS type RG_WERKS
      !I_MATKL type RG_MATKL
      !I_AUFNR type VL_I_AUFNR optional
      !I_RGBWART type RG_BWART
    changing
      !CH_KGS_PZAS type STANDARD TABLE .
  methods GET_KGS_PRO_EMP
    importing
      !I_WERKS type RG_WERKS
      !I_AUFNR type VL_I_AUFNR
      !I_RGBWART type RG_BWART
    changing
      !CH_KGS_EMP type STANDARD TABLE .
  methods CALCULATE_DATES                                        "
    changing
      !P_RGFECHAS type RG_FECHAS .
  methods CALCULATE_MORTAL    "
    importing
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_MORTANDAD type STANDARD TABLE .
  methods MORTAL_DEPOSITO    "
    importing
      !I_WERKS type RG_WERKS
      !I_MATKL type MATKL
      !I_RGBWART type RG_BWART
    changing
      !CH_MORTANDAD type STANDARD TABLE .
  methods KGS_PROCESA_DEP    "
    importing
      !I_WERKS type RG_WERKS
      !I_MATKL type MATKL
      !I_RGBWART type RG_BWART
    changing
      !CH_KGSPROCES type STANDARD TABLE .
  methods KGS_PROCESA_PPA    "
    importing
      !I_WERKS type RG_WERKS
      !I_MATKL type MATKL
      !I_RGBWART type RG_BWART
      !I_AUFNR type VL_I_AUFNR
    changing
      !CH_KGSPROCES type STANDARD TABLE .
  methods DECOMISO_DEP_MAQ    "
    importing
      !I_WERKS type RG_WERKS
      !I_MATKL type MATKL
      !I_RGBWART type RG_BWART
    changing
      !CH_DECOMISO type STANDARD TABLE .
  methods ESTAD_HUEVO_INC
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !I_WERKS type RG_WERKS
      !I_BWART type RG_BWART
      !I_AUFNR type VL_I_AUFNR
      !I_AUFNR_IN02 type VL_I_AUFNR
    changing
      !CH_ESTAD_HUE_INC type STANDARD TABLE .
  methods ESTAD_GAPESA
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !I_WERKS type RG_WERKS
      !I_BWART type RG_BWART
      !I_AUFNR type VL_I_AUFNR
      !I_AUFNR_IN02 type VL_I_AUFNR
    changing
      !CH_ESTAD_HUE_INC type STANDARD TABLE .
  methods ESTAD_HUEVO_INC2
    importing
      !P_GJAHR type GJAHR
      !P_POPERS type RG_POPERS
      !I_WERKS type RG_WERKS
      !I_BWART type RG_BWART
      !I_AUFNR type VL_I_AUFNR
      !I_AUFNR_0100 type RG_AUFNR
    changing
      !CH_ESTAD_HUE_INC type STANDARD TABLE .
  PROTECTED SECTION.

private section.

  data RG_FECHAFIN type RG_POPERS .    "
  data VL_GJAHR type GJAHR .    "
  data VL_WERKS type RG_WERKS .
  data:
    it_status TYPE STANDARD TABLE OF jstat .      "
  data ORD_VALIDA type AUFNR .     ""e_sysst LIKE bsvx-sttxt.
  data LV_OBJNR type JSTO-OBJNR .    "

  methods GET_DAYSMONTH
    importing
      !P_DATE type D
    changing
      !P_NUMDAYS type I .                                 "
ENDCLASS.



CLASS ZCL_COST_ENGORDA_JHV IMPLEMENTATION.


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


METHOD calculate_mortal. "calcula mortalidad

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    TYPES: BEGIN OF st_aux,
             aufnr TYPE aufnr,
             matnr TYPE char40,
             menge TYPE p LENGTH 13 DECIMALS 3,
           END OF st_aux.
    "
    DATA: it_aux TYPE STANDARD TABLE OF st_aux,
          wa_aux LIKE LINE OF it_aux.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    SELECT aufnr,
    CAST( CASE WHEN matnr = 'NATURAL' THEN 'Mortandad en Granja'
    ELSE CASE WHEN matnr = 'DESCARTES' THEN 'Descartes'
    ELSE CASE WHEN matnr = 'DESEMBARQUE' THEN 'Mortandad al Desembarque'
    END END END AS CHAR( 40 ) )  AS matnr, SUM(
    CASE WHEN bwart = '532' THEN menge * -1 ELSE menge END )
    AS menge
    FROM ztpp_mov_engorda
    WHERE aufnr IN @rg_aufnr
    AND bwart IN ('531', '532')
    GROUP BY  aufnr, matnr
     INTO TABLE @DATA(it_mortalidad).


    SORT it_mortalidad BY aufnr matnr.


    LOOP AT it_mortalidad INTO DATA(wa_mortalidad).

      IF wa_mortalidad-matnr EQ 'Descartes' OR wa_mortalidad-matnr EQ 'Mortandad en Granja'.
        wa_aux-aufnr = wa_mortalidad-aufnr.
        wa_aux-matnr = 'Mortandad en Granja'.
        wa_aux-menge = wa_mortalidad-menge.
        COLLECT wa_aux INTO it_aux.
      ELSE.
        wa_aux-aufnr = wa_mortalidad-aufnr.
        wa_aux-matnr = wa_mortalidad-matnr.
        wa_aux-menge = wa_mortalidad-menge.
        COLLECT wa_aux INTO it_aux.
      ENDIF.

    ENDLOOP.


    ch_mortandad[]  = it_aux[].

  ENDMETHOD.


METHOD decomiso_dep_maq. "calcula mortalidad

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    TYPES: BEGIN OF st_aux,
             aufnr TYPE aufnr,
             matnr TYPE char40,
             menge TYPE p LENGTH 13 DECIMALS 3,
           END OF st_aux.
    "
    DATA: it_aux TYPE STANDARD TABLE OF st_aux,
          wa_aux LIKE LINE OF it_aux.

    DATA: rg_matkl   TYPE RANGE OF mara-matkl,
          wa_rgmatkl LIKE LINE OF rg_matkl.

    CLEAR wa_rgmatkl.
    wa_rgmatkl-sign = 'I'.
    wa_rgmatkl-option = 'EQ'.
    wa_rgmatkl-low = i_matkl.
    APPEND wa_rgmatkl TO rg_matkl.

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



    SELECT aufnr,CAST( 'Decomiso Kgs.' AS CHAR( 40 ) ) AS wgbez60,  budat_mkpf,
    CASE WHEN bwart = '532' THEN menge * -1 ELSE menge END
    AS /cwm/menge
    INTO TABLE @DATA(it_decomiso)
    FROM mseg
    INNER JOIN mara ON mara~matnr = mseg~matnr
    WHERE budat_mkpf IN @lv_rgfechas
    AND mseg~werks IN @i_werks
    AND mseg~bwart IN @i_rgbwart
    AND mseg~matnr EQ '000000000000400191'
    AND mara~matkl IN @rg_matkl.



    SORT it_decomiso BY aufnr budat_mkpf.
    ch_decomiso[]  = it_decomiso[].

  ENDMETHOD.


METHOD estad_gapesa.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.
    DATA: gjahr_query TYPE gjahr,
          lfmon_query TYPE lfmon.

    DATA: vl_rglfmon TYPE RANGE OF mbewh-lfmon,
          wa_rglfmon LIKE LINE OF vl_rglfmon.


    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    DATA: rg_aufnr_nac   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr_nac LIKE LINE OF rg_aufnr.

    DATA(vl_tt_aufnr) = i_aufnr_in02.
    DATA(vl_tt_aufnr_nac) = i_aufnr.

    SORT vl_tt_aufnr BY dauat.
    SORT vl_tt_aufnr_nac BY dauat.

    DELETE vl_tt_aufnr_nac WHERE dauat NE 'IN03'.

    LOOP AT vl_tt_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.

    CLEAR wa_aufnr.

    LOOP AT vl_tt_aufnr_nac INTO wa_aufnr.
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr_nac.
    ENDLOOP.

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
    CASE WHEN ( ( mseg~matnr EQ '000000000000400188' OR mseg~matnr EQ '000000000000400190' )
              AND ( bwart EQ '101' OR bwart EQ '102' ) ) THEN
    CAST( '01Pollitos Enviados a Granjas' AS CHAR( 40 ) )
     ELSE 'BORRAR'  END AS wgbez60,
    CAST( CASE WHEN bwart EQ '102' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400188','000000000000400190')
    AND aufnr IN @rg_aufnr_nac
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

    SELECT matnr,
    CASE WHEN ( ( mseg~matnr EQ '000000000000300690' )
              AND ( bwart EQ '261' OR bwart EQ '262' ) ) THEN
    CAST( '01Pollitos Comprados' AS CHAR( 40 ) )
     ELSE 'BORRAR'  END AS wgbez60,
    CAST( CASE WHEN bwart EQ '262' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000300690')
    AND budat_mkpf IN @lv_rgfechas
    INTO TABLE @DATA(it_mseg).
    .

    SORT it_mseg BY wgbez60 budat_mkpf.
    ch_estad_hue_inc[] = it_mseg[].


  ENDMETHOD.


METHOD estad_huevo_inc.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.
    DATA: gjahr_query TYPE gjahr,
          lfmon_query TYPE lfmon.

    DATA: vl_rglfmon TYPE RANGE OF mbewh-lfmon,
          wa_rglfmon LIKE LINE OF vl_rglfmon.


    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    DATA: rg_aufnr_nac   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr_nac LIKE LINE OF rg_aufnr.

    DATA(vl_tt_aufnr) = i_aufnr_in02.
    DATA(vl_tt_aufnr_nac) = i_aufnr.

    SORT vl_tt_aufnr BY dauat.
    SORT vl_tt_aufnr_nac BY dauat.

    DELETE vl_tt_aufnr_nac WHERE dauat EQ 'IN02'.

    LOOP AT vl_tt_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.

    CLEAR wa_aufnr.

    LOOP AT vl_tt_aufnr_nac INTO wa_aufnr.
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr_nac.
    ENDLOOP.

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
    CASE WHEN ( ( mseg~matnr EQ '000000000000400145' OR mseg~matnr EQ '000000000000400194' )
              AND ( bwart EQ '641' OR bwart EQ '642' ) ) THEN
    CAST( '01Huevo Incubable del mes' AS CHAR( 40 ) ) ELSE 'BORRAR' END AS wgbez60,
    CAST( CASE WHEN bwart EQ '642' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400145','000000000000400194')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

    SELECT matnr,
      CASE WHEN  ( ( mseg~matnr EQ '000000000000400145' OR mseg~matnr EQ '000000000000400194' )
              AND ( bwart EQ '301' OR  bwart EQ '302' ) )  THEN
    CAST( '03Huevo Incub.(Trasp/Incubadoras)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN ( shkzg EQ 'H' AND ( mseg~matnr EQ '000000000000400145' OR mseg~matnr EQ '000000000000400194' ) )
           THEN menge * -1 ELSE
           CASE WHEN ( shkzg EQ 'S' AND mseg~matnr EQ '000000000000400194' ) THEN
           abs( menge ) ELSE menge END END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400145','000000000000400194')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

        SELECT matnr,
      CASE WHEN  ( ( mseg~matnr EQ '000000000000300688' )
              AND ( bwart EQ '101' OR  bwart EQ '102' ) )  THEN
    CAST( '04Hvo Incub(Comprado)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN  bwart EQ '102' THEN menge * -1 ELSE menge END  AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000300688')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

SELECT matnr,
      CASE WHEN  ( ( mseg~matnr EQ '000000000000400194' )
              AND ( bwart EQ '601' OR  bwart EQ '602' ) )  THEN
    CAST( '05Hvo Incub(Vendido)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN  bwart EQ '601' THEN menge * -1 ELSE menge END  AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400194')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' OR mbewh~matnr EQ '000000000000300688' ) THEN
    CAST( '02Inv. Inicial(Cuarto frío)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( lbkum AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( salk3 AS DEC( 13,2 ) ) AS  dmbtr, CAST( salk3 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194', '000000000000300688')
    AND lfgja EQ @vl_gjahr AND lfmon IN @vl_rglfmon


    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' OR mbewh~matnr EQ '000000000000300688' ) THEN
    CAST( '02Inv. Inicial(Cuarto frío)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( lbkum AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, @lfmon_query ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( salk3 AS DEC( 13,2 ) ) AS  dmbtr, CAST( salk3 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194','000000000000300688')
    AND lfgja EQ @gjahr_query AND lfmon EQ @lfmon_query

    UNION ALL

    SELECT matnr,
    CASE WHEN  mseg~matnr EQ '000000000000400194' OR mseg~matnr EQ '000000000000300688' AND ( mseg~bwart EQ '261' OR mseg~bwart EQ '262' ) THEN
    CAST( '06Huevo Incubable a comercial' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN bwart EQ '261' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND aufnr IN @rg_aufnr
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400194','000000000000300688') "alfo paso
    "AND budat_mkpf IN @lv_rgfechas

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mseg~matnr EQ '000000000000400145' OR mseg~matnr EQ '000000000000400194' OR mseg~matnr EQ '000000000000300688' )
    AND ( mseg~bwart EQ '551' OR mseg~bwart EQ '552' ) THEN
    CAST( '07Huevo Incubable Decomiso' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    "CAST( menge * -1  AS QUAN( 13,3 ) ) AS menge,
    CASE WHEN bwart = '551' THEN CAST( menge * -1  AS QUAN( 13,3 ) ) ELSE menge END AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400145','000000000000400194', '000000000000300688') "alfo paso
    AND budat_mkpf IN @lv_rgfechas


    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '08Huevo Incub disp.para Carga' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '09Huevo cargado en el mes' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin
    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '10Inv. Final del mes' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( lbkum AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( salk3 AS DEC( 13,2 ) ) AS  dmbtr, CAST( salk3 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    UNION ALL

    SELECT matnr,

    CASE WHEN ( mseg~matnr EQ '000000000000400145' OR mseg~matnr EQ '000000000000400194' OR mseg~matnr EQ '000000000000300688' ) THEN
    CAST( '11Huevo cargado para nacimiento del mes' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN bwart EQ '262' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    afko~getri AS budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM afko
    INNER JOIN mseg ON mseg~aufnr EQ afko~aufnr
    WHERE mseg~werks IN @i_werks
    AND mseg~aufnr IN @rg_aufnr_nac
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400145','000000000000400194', '000000000000300688')

    UNION ALL

     SELECT matnr,
    CASE WHEN  mseg~matnr EQ '000000000000400189' AND ( mseg~bwart EQ '531' OR mseg~bwart EQ '532' ) THEN
    CAST( '12Decomiso(Infertil, embrión, descartes)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN bwart EQ '532' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND aufnr IN @rg_aufnr_nac
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400189')

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '13Total Pollitos Nacidos' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '14% de Nacimiento' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    UNION ALL

    SELECT matnr,
    CASE WHEN ( ( mseg~matnr EQ '000000000000400188' OR mseg~matnr EQ '000000000000400190' )
              AND ( bwart EQ '101' OR bwart EQ '102' OR
                    bwart EQ '601' OR bwart EQ '602' ) ) THEN
    CAST( '15Pollitos Enviados a Granjas' AS CHAR( 40 ) )
     ELSE 'BORRAR'  END AS wgbez60,
    CAST( CASE WHEN bwart EQ '102' OR bwart EQ '601' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400188','000000000000400190')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

    SELECT matnr,
    CASE WHEN ( ( mseg~matnr EQ '000000000000400188' OR mseg~matnr EQ '000000000000400190' )
              AND ( bwart EQ '601' OR bwart EQ '602' ) ) THEN
    CAST( '16Pollitos de Casa Vendidos' AS CHAR( 40 ) )
     ELSE 'BORRAR'  END AS wgbez60,
    CAST( CASE WHEN bwart EQ '602' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400188','000000000000400190')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '17Costo  de Huevo' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    INTO TABLE @DATA(it_mseg).

    LOOP AT it_mseg ASSIGNING FIELD-SYMBOL(<wa_mseg>).
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <wa_mseg> TO <field>.
      IF <field> EQ '02Inv. Inicial(Cuarto frío)'.
        ASSIGN COMPONENT 'BUDAT_MKPF' OF STRUCTURE <wa_mseg> TO <field>.
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



      ENDIF.
    ENDLOOP.

    SORT it_mseg BY wgbez60 budat_mkpf.
    ch_estad_hue_inc[] = it_mseg[].


  ENDMETHOD.


METHOD estad_huevo_inc2.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.
    DATA: gjahr_query TYPE gjahr,
          lfmon_query TYPE lfmon.

    DATA: vl_rglfmon TYPE RANGE OF mbewh-lfmon,
          wa_rglfmon LIKE LINE OF vl_rglfmon.


    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    DATA: rg_aufnr_nac   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr_nac LIKE LINE OF rg_aufnr.

   " DATA(vl_tt_aufnr) = i_aufnr_0100.
    DATA(vl_tt_aufnr_nac) = i_aufnr.

    "SORT vl_tt_aufnr BY dauat.
    SORT vl_tt_aufnr_nac BY dauat.

    DELETE vl_tt_aufnr_nac WHERE dauat EQ 'IN02'.

*    LOOP AT vl_tt_aufnr INTO DATA(wa_aufnr).
*      wa_rgaufnr-sign = 'I'.
*      wa_rgaufnr-option = 'EQ'.
*      wa_rgaufnr-low = wa_aufnr-aufnr.
*      APPEND wa_rgaufnr TO rg_aufnr.
*    ENDLOOP.

    CLEAR wa_rgaufnr.

    LOOP AT vl_tt_aufnr_nac INTO data(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr_nac.
    ENDLOOP.

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
    CASE WHEN ( ( mseg~matnr EQ '000000000000400145' OR mseg~matnr EQ '000000000000400194' )
              AND ( bwart EQ '641' OR bwart EQ '642' ) ) THEN
    CAST( '01Huevo Incubable del mes' AS CHAR( 40 ) ) ELSE 'BORRAR' END AS wgbez60,
    CAST( CASE WHEN bwart EQ '642' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400145','000000000000400194')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

    SELECT matnr,
      CASE WHEN  ( ( mseg~matnr EQ '000000000000400145' OR mseg~matnr EQ '000000000000400194' )
              AND ( bwart EQ '301' OR  bwart EQ '302' ) )  THEN
    CAST( '03Huevo Incub.(Trasp/Incubadoras)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN  bwart EQ '301' THEN menge * -1 ELSE menge END  AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400145','000000000000400194')
    AND budat_mkpf IN @lv_rgfechas


    UNION ALL

    SELECT matnr,
      CASE WHEN  ( ( mseg~matnr EQ '000000000000300688' )
              AND ( bwart EQ '101' OR  bwart EQ '102' ) )  THEN
    CAST( '04Hvo Incub(Comprado)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN  bwart EQ '301' THEN menge * -1 ELSE menge END  AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000300688')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

        SELECT matnr,
      CASE WHEN  ( ( mseg~matnr EQ '000000000000400194' )
              AND ( bwart EQ '601' OR  bwart EQ '602' ) )  THEN
    CAST( '05Hvo Incub(Vendido)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN  bwart EQ '301' THEN menge * -1 ELSE menge END  AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400194')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL


    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194'  OR mbewh~matnr EQ '000000000000300688' ) THEN
    CAST( '02Inv. Inicial(Cuarto frío)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( lbkum AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( salk3 AS DEC( 13,2 ) ) AS  dmbtr, CAST( salk3 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194','000000000000300688')
    AND lfgja EQ @vl_gjahr AND lfmon IN @vl_rglfmon


    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' OR mbewh~matnr EQ '000000000000300688' ) THEN
    CAST( '02Inv. Inicial(Cuarto frío)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( lbkum AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, @lfmon_query ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( salk3 AS DEC( 13,2 ) ) AS  dmbtr, CAST( salk3 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194','000000000000300688')
    AND lfgja EQ @gjahr_query AND lfmon EQ @lfmon_query

    UNION ALL


    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '06Huevo Incubable a comercial' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    "CAST( CASE WHEN bwart EQ '261' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin



    UNION ALL

    SELECT matnr,
    CASE WHEN ( mseg~matnr EQ '000000000000400145' OR mseg~matnr EQ '000000000000400194' ) AND ( mseg~bwart EQ '551' OR mseg~bwart EQ '552' ) THEN
    CAST( '07Huevo Incubable Decomiso' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CASE WHEN bwart = '551' THEN CAST( menge * -1  AS QUAN( 13,3 ) ) ELSE menge END AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400145','000000000000400194') "alfo paso
    AND budat_mkpf IN @lv_rgfechas


    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '08Huevo Incub disp.para Carga' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '09Huevo cargado en el mes' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin
    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '10Inv. Final del mes' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( lbkum AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( salk3 AS DEC( 13,2 ) ) AS  dmbtr, CAST( salk3 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    UNION ALL

    SELECT matnr,

    CASE WHEN ( mseg~matnr EQ '000000000000400145' OR mseg~matnr EQ '000000000000400194' ) THEN
    CAST( '11Huevo cargado para nacimiento del mes' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN bwart EQ '262' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    aufk~idat2 AS budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM aufk
    INNER JOIN mseg ON mseg~aufnr EQ aufk~aufnr
    WHERE mseg~werks IN @i_werks
    "AND mseg~aufnr IN @i_aufnr_0100
    and aufk~auart = '0100'
    AND mseg~bwart IN @i_bwart
    AND mseg~matnr IN ('000000000000400145','000000000000400194')

    UNION ALL

     SELECT matnr,
    CASE WHEN ( mseg~matnr EQ '000000000000400188' OR mseg~matnr EQ '000000000000400194'
               OR mseg~matnr EQ '000000000000400190' )
               AND ( mseg~bwart EQ '221' OR mseg~bwart EQ '222' OR
               mseg~bwart EQ '261' OR mseg~bwart EQ '262' ) THEN
    CAST( '12Decomiso(Infertil, embrión, descartes)' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( CASE WHEN bwart EQ '221' OR bwart EQ '261' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND aufnr IN @rg_aufnr
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400188','000000000000400194','000000000000400190')

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '13Total Pollitos Nacidos' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '14% de Nacimiento' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    UNION ALL

    SELECT matnr,
    CASE WHEN ( ( mseg~matnr EQ '000000000000400188' OR mseg~matnr EQ '000000000000400190' )
              AND ( bwart EQ '221' OR bwart EQ '222' ) ) THEN
    CAST( '15Pollitos Enviados a Granjas' AS CHAR( 40 ) )
     ELSE 'BORRAR'  END AS wgbez60,
    CAST( CASE WHEN bwart EQ '222' THEN menge * -1 ELSE menge END AS QUAN( 13,3 ) ) AS menge,
    budat_mkpf, CAST( dmbtr AS DEC( 13,2 ) ) AS  dmbtr, CAST( dmbtr AS DEC( 13,2 ) ) AS dmbtr_st,shkzg
    FROM mseg
    WHERE werks IN @i_werks
    AND bwart IN @i_bwart
    AND matnr IN ('000000000000400188','000000000000400190')
    AND budat_mkpf IN @lv_rgfechas

    UNION ALL

 SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '16Pollitos de Casa Vendidos' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin


    UNION ALL

    SELECT matnr,
    CASE WHEN ( mbewh~matnr EQ '000000000000400145' OR mbewh~matnr EQ '000000000000400194' ) THEN
    CAST( '17Costo  de Huevo' AS CHAR( 40 ) ) ELSE 'BORRAR'
    END AS wgbez60,
    CAST( 0 AS QUAN( 13,3 ) ) AS menge,
    CAST( concat( concat( lfgja, lfmon ),'01' ) AS DATS ) AS budat_mkpf,
    CAST( 0 AS DEC( 13,2 ) ) AS  dmbtr, CAST( 0 AS DEC( 13,2 ) ) AS dmbtr_st,'x' AS shkzg
    FROM mbewh
    WHERE bwkey IN @i_werks
    AND matnr IN ('000000000000400145','000000000000400194')
    AND lfgja EQ @vl_gjahr AND lfmon IN @rg_fechafin

    INTO TABLE @DATA(it_mseg).

    LOOP AT it_mseg ASSIGNING FIELD-SYMBOL(<wa_mseg>).
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <wa_mseg> TO <field>.
      IF <field> EQ '02Inv. Inicial(Cuarto frío)'.
        ASSIGN COMPONENT 'BUDAT_MKPF' OF STRUCTURE <wa_mseg> TO <field>.
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



      ENDIF.
    ENDLOOP.

*    LOOP AT it_mseg ASSIGNING FIELD-SYMBOL(<wa_mseg1>).
*      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <wa_mseg1> TO <field>.
*      IF <field> EQ '08Huevo cargado para nacimiento del mes'.
*        ASSIGN COMPONENT 'BUDAT_MKPF' OF STRUCTURE <wa_mseg> TO <field>.
*
*          CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
*            EXPORTING
*              date      = <field>
*              days      = 00
*              months    = 01
*              signum    = '+'
*              years     = 01
*            IMPORTING
*              calc_date = <field>.
*
*      ENDIF.
*    ENDLOOP.


    SORT it_mseg BY wgbez60 budat_mkpf.
    ch_estad_hue_inc[] = it_mseg[].


  ENDMETHOD.


METHOD get_acdoca. "costos indirectos "

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.


    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.

    SELECT aufnr, racct ,
    CASE WHEN racct EQ 'S43CFB002' THEN 'CARGA FABRIL' ELSE
    CASE WHEN racct EQ 'S43TPM002' THEN 'TIEMPO MÁQUINA' ELSE
    CASE WHEN racct EQ 'S43TPM001' THEN 'TIEMPO MÁQUINA' ELSE
    CASE WHEN racct EQ 'S43CFB001' THEN 'CARGA FABRIL' ELSE
    CASE WHEN racct EQ 'S43MOD001' THEN 'MANO DE OBRA' ELSE
    skat~txt50 END END END END END AS txt50, hsl, poper, budat, ryear, awref,awitem,belnr,docln

    FROM acdoca
    INNER JOIN skat ON skat~saknr = acdoca~racct
    "FOR ALL ENTRIES IN @i_aufnr
    WHERE aufnr IN @rg_aufnr AND
    substring( acdoca~racct,1,3 ) EQ 'S43'
    INTO TABLE @DATA(it_acdoca)
.
    SORT it_acdoca BY aufnr racct.



    ch_acdoca[] = it_acdoca[].


  ENDMETHOD.


METHOD get_acdoca_crianza. "costos indirectos "

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.


    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.

    SELECT aufnr, racct ,
    CASE WHEN racct EQ 'S43CFB002' THEN '1.GASTOS INDIRECTOS' ELSE
    CASE WHEN racct EQ 'S43TPM002' THEN '3.GASTOS DE EQUIPO' ELSE
    CASE WHEN racct EQ 'S43MOD001' THEN '2.MANO DE OBRA' ELSE
    skat~txt50 END END END AS txt50, hsl, poper, budat, ryear, awref,awitem,belnr,docln

    FROM acdoca
    INNER JOIN skat ON skat~saknr = acdoca~racct
    "FOR ALL ENTRIES IN @i_aufnr
    WHERE aufnr IN @rg_aufnr AND
    substring( acdoca~racct,1,3 ) EQ 'S43'
    INTO TABLE @DATA(it_acdoca)
.
    SORT it_acdoca BY aufnr racct.



    ch_acdoca[] = it_acdoca[].


  ENDMETHOD.


METHOD get_acdoca_eng. "costos indirectos engorda "

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.


    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.

    SELECT aufnr, racct ,
    CASE WHEN racct EQ 'S43CFB002' THEN '2.CARGA FABRIL' ELSE
    CASE WHEN racct EQ 'S43TPM002' THEN '3.TIEMPO MÁQUINA' ELSE
    CASE WHEN racct EQ 'S43TPM001' OR racct EQ 'S43CFB001'
    OR racct EQ 'S43MOD001' THEN '1.MANO DE OBRA' ELSE
    skat~txt50 END END END AS txt50, hsl, poper, budat, ryear, awref,awitem,belnr,docln

    FROM acdoca
    INNER JOIN skat ON skat~saknr = acdoca~racct
    "FOR ALL ENTRIES IN @i_aufnr
    WHERE aufnr IN @rg_aufnr AND
    substring( acdoca~racct,1,3 ) EQ 'S43'
    INTO TABLE @DATA(it_acdoca)
.



    SORT it_acdoca BY aufnr racct.



    ch_acdoca[] = it_acdoca[].


  ENDMETHOD.


METHOD get_acdoca_flete. "costo indirecto solo flete "

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

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

    SELECT aufnr, racct ,
     CASE WHEN racct EQ 'S42SG0173' OR racct EQ '0601001033' OR racct EQ 'S42SG0179' THEN 'FLETE DE ABASTO' ELSE
     skat~txt50 END AS txt50, hsl, poper, budat, ryear, awref,awitem,belnr,docln, werks,rcntr
     FROM acdoca
     INNER JOIN skat ON skat~saknr = acdoca~racct
     "FOR ALL ENTRIES IN @i_aufnr
     WHERE acdoca~budat IN @lv_rgfechas AND
     acdoca~racct IN ( 'S42SG0173','0601001033', 'S42SG0179' ) AND acdoca~rcntr IN
     ('GPB62008','GPPR2024', 'GPPR2034','GPPR2035','GPPR2036','GPPR2039','GPPR2040', "cecos para ppa
     'GPMQ2165','GPMQ2125','GPMQ2115','GPMQ2273' ) "cecos para deposito
    INTO TABLE @DATA(it_acdoca)
 .
    SORT it_acdoca BY aufnr racct.



    ch_acdoca[] = it_acdoca[].


  ENDMETHOD.


METHOD get_acdoca_post. "costos indirectos "

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.


    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.

    SELECT aufnr, racct ,
    CASE WHEN racct EQ 'S43CFB002' THEN '1.GASTOS INDIRECTOS' ELSE
    CASE WHEN racct EQ 'S43TPM002' THEN '3.TIEMPO MÁQUINA' ELSE
    CASE WHEN racct EQ 'S43TPM001' OR racct EQ 'S43CFB001'
    OR racct EQ 'S43MOD001' THEN '2.MANO DE OBRA' ELSE
    skat~txt50 END END END AS txt50, hsl, poper, budat, ryear, awref,awitem,belnr,docln

    FROM acdoca
    INNER JOIN skat ON skat~saknr = acdoca~racct
    "FOR ALL ENTRIES IN @i_aufnr
    WHERE aufnr IN @rg_aufnr AND
    substring( acdoca~racct,1,3 ) EQ 'S43'
    INTO TABLE @DATA(it_acdoca)
.
    SORT it_acdoca BY aufnr racct.



    ch_acdoca[] = it_acdoca[].


  ENDMETHOD.


METHOD get_acdoca_ppa_det. "costos indirectos "

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.


    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.

    SELECT  acdoca~matnr,racct,maktx, aufnr, msl, runit, hsl, rwcur, budat,hsl AS r_hsl,
    CASE WHEN racct EQ '0504025111' OR racct EQ '0504025192' THEN 'Kilos Producidos' ELSE  skat~txt50 END  AS wgbez60
    FROM acdoca
    INNER JOIN skat ON skat~saknr = acdoca~racct
    LEFT JOIN makt ON makt~matnr = acdoca~matnr
    WHERE aufnr IN @rg_aufnr
    INTO TABLE @DATA(it_acdoca)
.
    SORT it_acdoca BY aufnr racct.



    ch_acdoca[] = it_acdoca[]. "it_ppa_det


  ENDMETHOD.


METHOD get_alpesur. "alimento alpesur "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: lv_rgwerks  TYPE RANGE OF t001w-werks,
          lv_wrgwerks LIKE LINE OF lv_rgwerks.

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

*    IF p_werks IS INITIAL.
*      lv_wrgwerks-sign = 'I'.
*      lv_wrgwerks-option = 'EQ'.
*      lv_wrgwerks-low = 'PA01'.
*      APPEND lv_wrgwerks TO lv_rgwerks.
*    ELSE.
*      lv_wrgwerks-sign = 'I'.
*      lv_wrgwerks-option = 'EQ'.
*      lv_wrgwerks-low = p_werks.
*      APPEND lv_wrgwerks TO lv_rgwerks.
*    ENDIF.


    SELECT aufnr, mseg~matnr, CAST( 'ALPESUR' AS CHAR( 40 ) ) AS wgbez60, werks, lgort,
    CASE WHEN bwart EQ '262' THEN CAST( mseg~menge * -1 AS DEC( 10,3 ) ) ELSE mseg~menge END AS menge,
    mara~meins, budat_mkpf,
    dmbtr, dmbtr AS dmbtr_st
    FROM mseg
    INNER JOIN mara ON mara~matnr = mseg~matnr
    INNER JOIN t023t ON t023t~matkl = mara~matkl
    INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
    WHERE
    mseg~bwart IN ('261', '262') AND
    mseg~lgort EQ 'GPMP' AND werks IN @lv_rgwerks
    AND budat_mkpf IN @lv_rgfechas
    AND mseg~matnr LIKE '%NV%'
    INTO TABLE @DATA(it_mseg).

    SORT it_mseg BY aufnr budat_mkpf.
    ch_alpesur[] = it_mseg[].


  ENDMETHOD.


METHOD get_aparceria. "aparceria para enngorda "

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.



    SELECT aufnr, racct ,CAST(  'COSTO PARTICIPACIÓN APARCERÍA' AS CHAR( 50 ) ) AS txt50, hsl, poper, budat, ryear, awref,awitem,belnr,docln
    INTO TABLE @DATA(it_acdoca)
    FROM acdoca
    INNER JOIN skat ON skat~saknr = acdoca~racct
    "FOR ALL ENTRIES IN @i_aufnr
    WHERE aufnr IN @rg_aufnr
    AND racct IN ( '0504025001' ).

    SORT it_acdoca BY aufnr racct.



    ch_aparceria[] = it_acdoca[].


  ENDMETHOD.


METHOD get_aufnr_ablad. "ordenes extra "

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    vl_gjahr = p_gjahr.
    rg_fechafin = p_popers.

    DATA: rg_aufnr TYPE RANGE OF afpo-aufnr,
          wa_aufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(waa).
      wa_aufnr-sign = 'I'.
      wa_aufnr-option = 'EQ'.
      wa_aufnr-low = waa-aufnr.
      APPEND wa_aufnr TO rg_aufnr.
    ENDLOOP.

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


    SELECT DISTINCT a~aufnr, a~gstri, a~getri,a~gltri,a~ftrmi, p~dauat, p~pwerk, p~dwerk,c~objnr,p~ablad,
       p~objnp, substring( a~getri, 5,2 ) AS popera, substring(  a~gltri,5,2 ) AS popoerb
     FROM afko AS a
    INNER JOIN afpo AS p ON p~aufnr = a~aufnr AND p~posnr EQ '1'
    INNER JOIN caufv AS c ON c~aufnr EQ a~aufnr
   WHERE a~aufnr IN @rg_aufnr  "( a~getri IN @lv_rgfechas OR a~gltri IN @lv_rgfechas )
   AND dauat IN @p_clorder "'EN01'
   AND dwerk IN @p_werks
   INTO TABLE @DATA(it_aufnr_close).


*    IF it_aufnr_close IS NOT INITIAL.
*      LOOP AT it_aufnr_close INTO DATA(wa_aufnr).
*        lv_objnr = wa_aufnr-objnr.
*
*        CALL FUNCTION 'STATUS_READ'
*          EXPORTING
*            client           = sy-mandt
*            objnr            = lv_objnr
*            only_active      = 'X'
*          TABLES
*            status           = it_status
*          EXCEPTIONS
*            object_not_found = 1
*            OTHERS           = 2.
*        IF sy-subrc EQ 0.
*
*
**          READ TABLE it_status INTO DATA(wa_noti) WITH KEY stat = 'I0009'. "NOTI Excl.
**          IF sy-subrc EQ 0.
*          READ TABLE it_status INTO DATA(wa_cerr) WITH KEY stat = 'I0046'. "CERR Excl.
*          IF sy-subrc EQ 0.
*            ord_valida = wa_aufnr-aufnr.
**            ELSE.
**              READ TABLE it_status INTO DATA(wa_ctec) WITH KEY stat = 'I0045'. "CTEC
**              IF sy-subrc EQ 0.
**                ord_valida = wa_aufnr-aufnr.
**              ENDIF.
*          ENDIF.
**          ENDIF.
*
*          IF ord_valida IS INITIAL.
*            DELETE it_aufnr_close WHERE aufnr = wa_aufnr-aufnr.
*            .
*          ENDIF.
*
*        ENDIF.
*
*      ENDLOOP.
*    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    SORT it_aufnr_close BY getri DESCENDING.
*
*
*    SELECT belnr, budat, perio, objnr
*    INTO TABLE @DATA(it_auak)
*      FROM auak
*    FOR ALL ENTRIES IN @it_aufnr_close
*      WHERE objnr = @it_aufnr_close-objnr
*      .
*
*    SORT it_auak BY objnr belnr DESCENDING.
*
*
*    LOOP AT it_aufnr_close INTO DATA(wa_test) WHERE getri IS INITIAL.
*      READ TABLE it_auak INTO DATA(wa_auak) WITH KEY objnr = wa_test-objnr.
*      IF sy-subrc EQ 0.
*        IF wa_auak-budat+4(2) EQ wa_test-gltri+4(2) .
*          wa_test-getri = wa_auak-budat.
*          wa_test-popera = wa_auak-perio.
*          MODIFY it_aufnr_close FROM wa_test TRANSPORTING getri popera WHERE objnr = wa_test-objnr.
*        ENDIF.
*
*      ENDIF.
*    ENDLOOP.
*
*    DELETE it_aufnr_close WHERE getri IS INITIAL.
*    DELETE it_aufnr_close WHERE getri NOT IN lv_rgfechas.

    SORT it_aufnr_close BY aufnr DESCENDING.
*    DELETE ADJACENT DUPLICATES FROM it_aufnr_close COMPARING aufnr.
*    DELETE it_aufnr_close WHERE ablad IS INITIAL.


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""""""SE IGUAlAN LAS FECHAS""""""""""""""""""""""""""""""""""""
    LOOP AT i_aufnr INTO waa.
      READ TABLE it_aufnr_close ASSIGNING FIELD-SYMBOL(<st_aufnr>) WITH KEY aufnr = waa-aufnr.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT 'GETRI' OF STRUCTURE <st_aufnr> TO FIELD-SYMBOL(<row>).
        <row> = waa-getri.
      ENDIF.
    ENDLOOP.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    i_mts2[] = it_aufnr_close[].

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

    READ TABLE p_clorder INTO DATA(wa_clord) INDEX 1.
    IF wa_clord-low EQ 'PR02'.
      REFRESH lv_rgfechas.
    ENDIF.


    IF  wa_clord-low EQ '0100'.

      SELECT DISTINCT a~aufnr
      FROM aufk AS a
      WHERE idat2 IN @lv_rgfechas
      AND werks eq 'PQ01'
     INTO TABLE @DATA(it_aufnr_0100).

    ELSE.

      SELECT DISTINCT a~aufnr, a~gstri, a~getri,a~gltri,a~ftrmi, p~dauat, p~pwerk, p~dwerk,c~objnr,p~ablad, a~plnbez,
         p~objnp, substring( a~getri, 5,2 ) AS popera, substring(  a~gltri,5,2 ) AS popoerb
       FROM afko AS a
      INNER JOIN afpo AS p ON p~aufnr = a~aufnr
      INNER JOIN caufv AS c ON c~aufnr EQ a~aufnr
     WHERE ( a~getri IN @lv_rgfechas OR a~gltri IN @lv_rgfechas )
     AND dauat IN @p_clorder
     AND dwerk IN @p_werks
     INTO TABLE @DATA(it_aufnr_close).

    ENDIF.

    IF wa_clord-low EQ '0100'.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ELSE.
      IF wa_clord-low NE 'PR02'.

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
              IF p_tipo EQ 'ENGORDA'  OR p_tipo = 'CRIANZA' OR p_tipo = 'INCUBADORA' OR p_tipo = 'PPA_DET'.

*              READ TABLE it_status INTO DATA(wa_notie) WITH KEY stat = 'I0009'. "NOTI Excl.
*              IF sy-subrc EQ 0.
                READ TABLE it_status INTO DATA(wa_cerre) WITH KEY stat = 'I0046'. "CERR Excl.
                IF sy-subrc EQ 0.
                  ord_valida = wa_aufnr-aufnr.
*                ELSE.
*                  READ TABLE it_status INTO DATA(wa_ctece) WITH KEY stat = 'I0045'. "CTEC
*                  IF sy-subrc EQ 0.
*                    ord_valida = wa_aufnr-aufnr.
*                  ENDIF.
                ELSE.
                  CLEAR ord_valida.
                ENDIF.
*              ENDIF.

                IF ord_valida IS INITIAL.
                  DELETE it_aufnr_close WHERE aufnr = wa_aufnr-aufnr.
                  .
                ENDIF.

              ELSE.

                READ TABLE it_status INTO DATA(wa_noti) WITH KEY stat = 'I0009'. "NOTI Excl.
                IF sy-subrc EQ 0.
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
                ELSE.
                  CLEAR ord_valida.
                ENDIF.

                IF ord_valida IS INITIAL.
                  DELETE it_aufnr_close WHERE aufnr = wa_aufnr-aufnr.
                  .
                ENDIF.


              ENDIF.
            ENDIF.

          ENDLOOP.
        ENDIF.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        SORT it_aufnr_close BY getri DESCENDING.



        SELECT belnr, budat, perio, auak~objnr
        INTO TABLE @DATA(it_auak)
          FROM auak
        FOR ALL ENTRIES IN @it_aufnr_close
          WHERE objnr = @it_aufnr_close-objnr
          .

        SORT it_auak BY objnr belnr DESCENDING.


        LOOP AT it_aufnr_close INTO DATA(wa_test) WHERE getri IS INITIAL.
          READ TABLE it_auak INTO DATA(wa_auak) WITH KEY objnr = wa_test-objnr.
          IF sy-subrc EQ 0.
            "IF wa_auak-budat+4(2) EQ wa_test-gltri+4(2) .
            wa_test-getri = wa_auak-budat.
            wa_test-popera = wa_auak-perio+1(2).
            MODIFY it_aufnr_close FROM wa_test TRANSPORTING getri popera WHERE objnr = wa_test-objnr.
            "ENDIF.

          ENDIF.
        ENDLOOP.

        DELETE it_aufnr_close WHERE getri IS INITIAL.
        DELETE it_aufnr_close WHERE getri NOT IN lv_rgfechas.

        SORT it_aufnr_close BY aufnr DESCENDING.
        DELETE ADJACENT DUPLICATES FROM it_aufnr_close COMPARING aufnr.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      ENDIF.
    ENDIF.
    i_tabla[] = it_aufnr_close[].
    i_aufnr[] = it_aufnr_0100[].
  ENDMETHOD.


METHOD get_costowip.

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.


    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.

      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CAST( CASE WHEN acdoca~racct = '0504025190' THEN 'COSTO WIP' END AS CHAR( 40 ) ) AS wgbez60, acdoca~werks,
      CAST( 0 AS QUAN( 13, 3 ) ) AS menge, mara~meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem
 FROM acdoca
 "INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 LEFT JOIN mara ON mara~matnr = acdoca~matnr
 LEFT JOIN t023t ON t023t~matkl = mara~matkl
 LEFT JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
WHERE acdoca~aufnr IN @rg_aufnr
AND acdoca~racct = '0504025190'
INTO TABLE @DATA(it_mseg).


      SORT it_mseg BY wgbez60 aufnr budat.

    ENDIF.
    ch_recupera[] = it_mseg[].



  ENDMETHOD.


METHOD get_daysMonth. "cálculo de dias en el mes "

    DATA: xdatum TYPE d.

    xdatum = p_date.
    xdatum+6(2) = '01'.
    xdatum = xdatum + 35.          "para llegar seguro al proximo mes
    xdatum+6(2) = '01'. xdatum = xdatum - 1.
    p_numDays = xdatum+6(2).

  ENDMETHOD.


METHOD get_estadisticos_crianza. "recuperaciones "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.


    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.

      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CASE WHEN mara~matnr EQ '000000000000400047' AND acdoca~racct EQ '0504025111' THEN '1.HEMBRAS FINALES' ELSE
      CASE WHEN mara~matnr EQ '000000000000400195' AND acdoca~racct EQ '0504025192' THEN '2.MACHOS FINALES' ELSE
      CASE WHEN mara~matnr EQ '000000000000400046' AND acdoca~racct EQ '0504025111' THEN '3.GALLINA JOVEN' ELSE
      CASE WHEN mara~matnr EQ '000000000000400185' AND acdoca~racct EQ '0504025192' THEN '4.GALLO JOVEN' ELSE
      CAST( 'BORRAR' AS CHAR( 40 ) ) END END END END AS wgbez60, acdoca~werks,
      CAST( CASE WHEN mseg~bwart EQ '102' OR mseg~bwart EQ '532' THEN mseg~menge * -1 ELSE  mseg~menge END AS QUAN( 13,3 ) )
      AS menge ,
      mara~meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 INNER JOIN mara ON mara~matnr = acdoca~matnr
INNER JOIN t023t ON t023t~matkl = mara~matkl
INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
WHERE acdoca~aufnr IN @rg_aufnr
AND mseg~bwart IN ('101','102','531','532')
AND mara~matkl EQ 'ST0002'
AND acdoca~racct IN ('0504025111','0504025192')
INTO TABLE @DATA(it_mseg).


      SORT it_mseg BY wgbez60 aufnr budat.

    ENDIF.
    ch_recupera[] = it_mseg[].





  ENDMETHOD.


METHOD get_estadisticos_post. "recuperaciones "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.


    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.

      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CASE WHEN mara~matnr EQ '000000000000400145' THEN '1.HUEVO HP' ELSE
      CASE WHEN mara~matnr EQ '000000000000400050' THEN '2.HUEVO PLATO (SUCIO, CHICO, DEFORME)' ELSE
      CASE WHEN mara~matnr EQ '000000000000400051' THEN '3.HUEVO DESECHO (ROTO - CANICA)' ELSE
      CASE WHEN mara~matnr EQ '000000000000400151' THEN '4.HUEVO DOBLE YEMA' ELSE
      CASE WHEN mara~matnr EQ '000000000000400193' THEN '5.HUEVO FISURADO' ELSE
      CASE WHEN mara~matnr EQ '000000000000400194' THEN '6.HUEVO INCUBABLE' ELSE
      CAST( 'BORRAR' AS CHAR( 40 ) ) END END END END END END AS wgbez60, acdoca~werks,
      CAST( CASE WHEN mseg~bwart EQ '532' OR mseg~bwart EQ '102' THEN mseg~menge * -1 ELSE  mseg~menge END AS QUAN( 13,3 ) )
      AS menge ,
      mara~meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 INNER JOIN mara ON mara~matnr = acdoca~matnr
INNER JOIN t023t ON t023t~matkl = mara~matkl
INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
WHERE acdoca~aufnr IN @rg_aufnr
AND mseg~bwart IN ('531', '532','101','102')
AND mara~matkl EQ 'ST0002'
INTO TABLE @DATA(it_mseg).


      SORT it_mseg BY wgbez60 aufnr budat.

    ENDIF.
    ch_recupera[] = it_mseg[].





  ENDMETHOD.


METHOD get_kgs_pro_emp. "cantidad kilos y piezas empacadora

    FIELD-SYMBOLS: <fs_mseg> TYPE any,
                   <f_field> TYPE any.

    DATA: vl_kilos  TYPE /cwm/menge, vl_piezas TYPE menge_d, vl_dmbtr TYPE dmbtr.
    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.


    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min    TYPE mseg-budat_mkpf,
          max    TYPE mseg-budat_mkpf,
          lineas TYPE i.

    CALL METHOD calculate_dates
      CHANGING
        p_rgfechas = lv_rgfechas.
    .


    IF i_aufnr IS NOT INITIAL.
      LOOP AT i_aufnr INTO DATA(wa_aufnr).
        wa_rgaufnr-sign = 'I'.
        wa_rgaufnr-option = 'EQ'.
        wa_rgaufnr-low = wa_aufnr-aufnr.
        APPEND wa_rgaufnr TO rg_aufnr.
      ENDLOOP.

    ENDIF.


    CALL METHOD calculate_dates
      CHANGING
        p_rgfechas = lv_rgfechas.
    . "

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

    SELECT aufnr,CAST( 'Kilos Producidos' AS CHAR( 40 ) ) AS wgbez60,  budat_mkpf,
      CASE WHEN bwart = '102' THEN menge * -1 ELSE menge END
      AS /cwm/menge
      INTO TABLE @DATA(it_mseg)
      FROM mseg
      INNER JOIN mara ON mara~matnr = mseg~matnr
      WHERE budat_mkpf IN @lv_rgfechas
      AND mseg~werks IN @i_werks
      AND mseg~bwart IN @i_rgbwart
      AND mseg~aufnr IN @rg_aufnr
      .


*    IF it_mseg IS NOT INITIAL.
*      LOOP AT it_mseg ASSIGNING <fs_mseg>.
*
*        UNASSIGN <f_field>.
*        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
*        vl_kilos = <f_field>.
**
**        UNASSIGN <f_field>.
**        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
**        vl_piezas = <f_field>.
*
**        UNASSIGN <f_field>.
**        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_mseg> TO <f_field>.
**        vl_dmbtr = <f_field>.
*
**        UNASSIGN <f_field>.
**        ASSIGN COMPONENT 'BWART' OF STRUCTURE <fs_mseg> TO <f_field>.
**
**        IF <f_field> EQ '102'.
**          vl_piezas = vl_piezas * -1.
**          vl_kilos = vl_kilos * -1.
**          "vl_dmbtr = vl_dmbtr * -1.
**        ENDIF.
*
*        UNASSIGN <f_field>.
*        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
*        <f_field> = vl_kilos.
**
**        UNASSIGN <f_field>.
**        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
**        <f_field> = vl_piezas.
*
**        UNASSIGN <f_field>.
**        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_mseg> TO <f_field>.
**        <f_field> = vl_dmbtr.
*
**        IF vl_piezas < 0.
**          UNASSIGN <f_field>.
**          ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fs_mseg> TO <f_field>.
**          " <f_field> = <f_field> * -1.
**        ENDIF.
*      ENDLOOP.
    ch_kgs_emp[] = it_mseg[].
**    ENDIF.

  ENDMETHOD.


METHOD get_kgs_pzas. "cantidad de kilos y piezas "

    FIELD-SYMBOLS: <fs_mseg> TYPE any,
                   <f_field> TYPE any.

    DATA: vl_kilos  TYPE /cwm/menge, vl_piezas TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    SELECT mseg~aufnr, bwart, mseg~matnr, mseg~werks, lgort, erfme, budat_mkpf,
          dmbtr, dmbtr AS dmbtr_st, /cwm/menge, /cwm/meins, menge, meins,mblnr,zeile,acdoca~racct
    FROM mseg
    INNER JOIN acdoca ON acdoca~awref = mseg~mblnr AND mseg~zeile = substring( acdoca~awitem, 3,4 )
    WHERE mseg~aufnr IN @rg_aufnr
    AND bwart IN ( '101','102' ) AND acdoca~racct LIKE '050%'

    INTO TABLE @DATA(it_mseg).

    IF it_mseg IS NOT INITIAL.
      LOOP AT it_mseg ASSIGNING <fs_mseg>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        vl_kilos = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        vl_piezas = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_mseg> TO <f_field>.
        vl_dmbtr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BWART' OF STRUCTURE <fs_mseg> TO <f_field>.

        IF <f_field> EQ '102'.
          vl_piezas = vl_piezas * -1.
          vl_kilos = vl_kilos * -1.
          "vl_dmbtr = vl_dmbtr * -1.
        ENDIF.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        <f_field> = vl_kilos.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        <f_field> = vl_piezas.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_mseg> TO <f_field>.
        <f_field> = vl_dmbtr.

        IF vl_piezas < 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fs_mseg> TO <f_field>.
          " <f_field> = <f_field> * -1.
        ENDIF.
      ENDLOOP.
      ch_kgs_pzas[] = it_mseg[].
    ENDIF.

  ENDMETHOD.


METHOD get_kgs_pzas_dep. "cantidad kilos y piezas deposito

    FIELD-SYMBOLS: <fs_mseg> TYPE any,
                   <f_field> TYPE any.

    DATA: vl_kilos  TYPE /cwm/menge, vl_piezas TYPE menge_d, vl_dmbtr TYPE dmbtr.
    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.


    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min    TYPE mseg-budat_mkpf,
          max    TYPE mseg-budat_mkpf,
          lineas TYPE i.

    DATA: rg_werks   TYPE RANGE OF t001w-werks,
          wa_rgwerks LIKE LINE OF rg_werks.

    CALL METHOD calculate_dates
      CHANGING
        p_rgfechas = lv_rgfechas.
    .


    IF i_aufnr IS NOT INITIAL.
      LOOP AT i_aufnr INTO DATA(wa_aufnr).
        wa_rgaufnr-sign = 'I'.
        wa_rgaufnr-option = 'EQ'.
        wa_rgaufnr-low = wa_aufnr-aufnr.
        APPEND wa_rgaufnr TO rg_aufnr.
      ENDLOOP.

    ENDIF.



*    IF i_werks IS NOT INITIAL.
*      CLEAR wa_rgwerks.
*      wa_rgwerks-sign = 'I'.
*      wa_rgwerks-option = 'EQ'.
*      wa_rgwerks-low = i_werks.
*      APPEND wa_rgwerks TO rg_werks.
*    ENDIF.

    CALL METHOD calculate_dates
      CHANGING
        p_rgfechas = lv_rgfechas.
    . "

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

    DESCRIBE TABLE i_rgbwart LINES lineas.

    IF lineas EQ 4.

      DATA(aufnr_empty) = rg_aufnr.
      DATA(vivo_bwart) = i_rgbwart.
      DATA(maq_bwart) = i_rgbwart.
      REFRESH aufnr_empty.
      DELETE vivo_bwart WHERE low EQ '261' OR low EQ '262'.
      DELETE maq_bwart WHERE low EQ '601' OR low EQ '602'.

      SELECT aufnr, bwart, mseg~matnr, werks, lgort, erfme, budat_mkpf,
            dmbtr, dmbtr AS dmbtr_st, /cwm/menge, /cwm/meins, menge, mseg~meins,mblnr,zeile
      FROM mseg
      INNER JOIN mara ON mara~matnr = mseg~matnr
      WHERE budat_mkpf IN @lv_rgfechas
      AND mseg~werks IN @i_werks
      AND mseg~bwart IN @vivo_bwart "601 602
      AND mseg~aufnr IN @aufnr_empty "vacio
      AND mara~matkl IN @i_matkl

      UNION ALL

      SELECT aufnr, bwart, mseg~matnr, werks, lgort, erfme, budat_mkpf,
            dmbtr, dmbtr AS dmbtr_st, /cwm/menge, /cwm/meins, menge, mseg~meins,mblnr,zeile
      FROM mseg
      INNER JOIN mara ON mara~matnr = mseg~matnr
      WHERE budat_mkpf IN @lv_rgfechas
      AND mseg~werks IN @i_werks
      AND mseg~bwart IN @maq_bwart "261 262
      AND mseg~aufnr IN @rg_aufnr "ordenes
      AND mara~matkl IN @i_matkl
      INTO TABLE @DATA(it_mseg_g).
    ELSE.

      SELECT aufnr, bwart, mseg~matnr, werks, lgort, erfme, budat_mkpf,
              dmbtr, dmbtr AS dmbtr_st, /cwm/menge, /cwm/meins, menge, mseg~meins,mblnr,zeile
        FROM mseg
        INNER JOIN mara ON mara~matnr = mseg~matnr
        WHERE budat_mkpf IN @lv_rgfechas
        AND mseg~werks IN @i_werks
        AND mseg~bwart IN @i_rgbwart
        AND mseg~aufnr IN @rg_aufnr
        AND mara~matkl IN @i_matkl
      INTO TABLE @DATA(it_msegvc).

    ENDIF.

    DATA(it_mseg) = it_mseg_g.
    IF it_mseg IS INITIAL.
      REFRESH it_mseg.
      it_mseg[] = it_msegvc[].
    ENDIF.


    IF it_mseg IS NOT INITIAL.
      LOOP AT it_mseg ASSIGNING <fs_mseg>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        vl_kilos = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        vl_piezas = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_mseg> TO <f_field>.
        vl_dmbtr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BWART' OF STRUCTURE <fs_mseg> TO <f_field>.

        IF <f_field> EQ '262' OR <f_field> EQ '602'.
          vl_piezas = vl_piezas * -1.
          vl_kilos = vl_kilos * -1.
          "vl_dmbtr = vl_dmbtr * -1.
        ENDIF.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        <f_field> = vl_kilos.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        <f_field> = vl_piezas.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_mseg> TO <f_field>.
        <f_field> = vl_dmbtr.

        IF vl_piezas < 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fs_mseg> TO <f_field>.
          " <f_field> = <f_field> * -1.
        ENDIF.
      ENDLOOP.
      ch_kgs_pzas[] = it_mseg[].
    ENDIF.

  ENDMETHOD.


METHOD get_kgs_pzas_procppa. "cantidad kilos y piezas ppa "

    FIELD-SYMBOLS: <fs_mseg> TYPE any,
                   <f_field> TYPE any.

    DATA: vl_kilos  TYPE /cwm/menge, vl_piezas TYPE menge_d, vl_dmbtr TYPE dmbtr.

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


    SELECT aufnr, bwart, mseg~matnr, werks, lgort, erfme, budat_mkpf,
          dmbtr, dmbtr AS dmbtr_st, /cwm/menge, /cwm/meins, menge, mseg~meins,mblnr,zeile
    INTO TABLE @DATA(it_mseg)
    FROM mseg
    INNER JOIN mara ON mara~matnr = mseg~matnr
    WHERE budat_mkpf IN @lv_rgfechas
    AND bwart IN ( '101','102' ) AND werks = 'PP01' AND lgort = 'GPMP'
    AND mara~matkl = 'PT0001'.

    IF it_mseg IS NOT INITIAL.
      LOOP AT it_mseg ASSIGNING <fs_mseg>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        vl_kilos = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        vl_piezas = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_mseg> TO <f_field>.
        vl_dmbtr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BWART' OF STRUCTURE <fs_mseg> TO <f_field>.

        IF <f_field> EQ '102'.
          vl_piezas = vl_piezas * -1.
          vl_kilos = vl_kilos * -1.
          "vl_dmbtr = vl_dmbtr * -1.
        ENDIF.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        <f_field> = vl_kilos.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_mseg> TO <f_field>.
        <f_field> = vl_piezas.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_mseg> TO <f_field>.
        <f_field> = vl_dmbtr.

        IF vl_piezas < 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fs_mseg> TO <f_field>.
          " <f_field> = <f_field> * -1.
        ENDIF.
      ENDLOOP.
      ch_kgs_pzas[] = it_mseg[].
    ENDIF.

  ENDMETHOD.


METHOD get_maquila. "maquila alimento "

    FIELD-SYMBOLS: <fst_maquila> TYPE any,
                   <f_field>     TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: lv_rgfechas TYPE rg_fechas,
          lv_werks    TYPE RANGE OF afpo-dwerk,
          lv_wawerks  LIKE LINE OF lv_werks.

    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    vl_gjahr = p_gjahr.
    rg_fechafin = p_popers.
    "vl_werks = p_werks.

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

*    lv_wawerks-sign = 'I'.
*    lv_wawerks-option = 'BT'.
*    lv_wawerks-low = vl_werks.
*    APPEND lv_wawerks TO lv_werks.


    SELECT mseg~aufnr, mseg~matnr, menge, bwart,
        CAST( 'Costo Materia Prima Maquila' AS CHAR( 40 ) ) AS wgbez60,
        mseg~werks, budat_mkpf,
        dmbtr, dmbtr AS dmbtr_st
    FROM mseg
    INNER JOIN mara ON mara~matnr = mseg~matnr
    INNER JOIN t023t ON t023t~matkl = mara~matkl
    INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
    WHERE
    mseg~bwart IN ('543', '544')
    AND budat_mkpf IN @lv_rgfechas
    AND werks = 'AA01'
    AND mseg~lifnr EQ 'IC0000SA01'
    INTO TABLE @DATA(it_mseg).


    SORT it_mseg BY aufnr budat_mkpf.

    IF it_mseg IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mseg
      WHERE lfgja = @it_mseg-budat_mkpf+0(4)
      AND matnr = @it_mseg-matnr
      AND bwkey = 'AA01'.


      LOOP AT it_mseg ASSIGNING <fst_maquila>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT_MKPF' OF STRUCTURE <fst_maquila> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_maquila> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_maquila> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_maquila> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_maquila> TO <f_field>.
          vl_dmbtr = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'BWART' OF STRUCTURE <fst_maquila> TO <f_field>.

          IF <f_field> EQ '543'.
            vl_menge = vl_menge * -1.
            IF wa_mbewh-verpr GT 0.
              vl_dmbtr = vl_menge * wa_mbewh-verpr.
            ENDIF.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_maquila> TO <f_field>.
            <f_field> = vl_dmbtr.

            IF vl_menge < 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_maquila> TO <f_field>.
              <f_field> = <f_field> * -1.
            ENDIF.
          ENDIF.
        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_maquila[] = it_mseg[].
    ENDIF.


  ENDMETHOD.


METHOD get_maquila_aca. "maquila alimento "

    FIELD-SYMBOLS: <fst_maquila> TYPE any,
                   <f_field>     TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: lv_rgfechas TYPE rg_fechas,
          lv_werks    TYPE RANGE OF afpo-dwerk,
          lv_wawerks  LIKE LINE OF lv_werks.

    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    vl_gjahr = p_gjahr.
    rg_fechafin = p_popers.
    "vl_werks = p_werks.

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

*    lv_wawerks-sign = 'I'.
*    lv_wawerks-option = 'BT'.
*    lv_wawerks-low = vl_werks.
*    APPEND lv_wawerks TO lv_werks.


    SELECT acdoca~aufnr, acdoca~matnr, CAST( msl AS DEC( 13,2 ) ) AS menge, bwart,
      CAST( CASE WHEN mara~matkl EQ 'ST0002' OR mara~matkl EQ 'HI0001' THEN '1.HUEVO INCUBABLE' ELSE
      CASE WHEN mara~matkl EQ 'VC0001' THEN '2.VACUNAS' ELSE
      CASE WHEN mara~matkl EQ 'MD0005' THEN '3.MEDICINAS' ELSE
      CASE WHEN mara~matkl EQ 'PT0001' THEN '4.POLLITO GAPESA' ELSE
      CAST( 'BORRAR' AS CHAR( 40 ) )  END END END END AS CHAR( 40 ) ) AS wgbez60,
        mseg~werks, budat AS budat_mkpf,
      CAST(  hsl AS DEC( 13,2 ) ) AS dmbtr, CAST( hsl AS DEC( 13,2 ) ) AS dmbtr_st
    FROM acdoca
    INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
    INNER JOIN aufk ON aufk~aufnr = acdoca~aufnr
    INNER JOIN mara ON mara~matnr = acdoca~matnr
    INNER JOIN t023t ON t023t~matkl = mara~matkl
    INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
    WHERE aufk~auart EQ '0100'
    AND budat IN @lv_rgfechas
    AND racct EQ '0504025051'
    AND acdoca~werks IN @p_werks
    INTO TABLE @DATA(it_mseg).


    SORT it_mseg BY aufnr budat_mkpf.

    IF it_mseg IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mseg
      WHERE lfgja = @it_mseg-budat_mkpf+0(4)
      AND matnr = @it_mseg-matnr
      AND bwkey = @it_mseg-werks.


      LOOP AT it_mseg ASSIGNING <fst_maquila>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT_MKPF' OF STRUCTURE <fst_maquila> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_maquila> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_maquila> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_maquila> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_maquila> TO <f_field>.
          vl_dmbtr = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'BWART' OF STRUCTURE <fst_maquila> TO <f_field>.

*          IF <f_field> EQ '543'.
*            vl_menge = vl_menge * -1.
          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_maquila> TO <f_field>.
          <f_field> = vl_dmbtr.

**            IF vl_menge < 0.
*              UNASSIGN <f_field>.
*              ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_maquila> TO <f_field>.
*              <f_field> = vl_dmbtr."<f_field> * -1.
*            ENDIF.
*          ENDIF.
        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_maquila[] = it_mseg[].
    ENDIF.


  ENDMETHOD.


METHOD get_maquila_gapesa. "maquila gapesa"

    FIELD-SYMBOLS: <fst_maquila> TYPE any,
                   <f_field>     TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: lv_rgfechas TYPE rg_fechas,
          lv_werks    TYPE RANGE OF afpo-dwerk,
          lv_wawerks  LIKE LINE OF lv_werks.

    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    vl_gjahr = p_gjahr.
    rg_fechafin = p_popers.
    "vl_werks = p_werks.

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

*    lv_wawerks-sign = 'I'.
*    lv_wawerks-option = 'BT'.
*    lv_wawerks-low = vl_werks.
*    APPEND lv_wawerks TO lv_werks.


    SELECT acdoca~aufnr, acdoca~matnr, CAST( msl AS DEC( 13,2 ) ) AS menge, bwart,
      CAST( CASE WHEN mara~matkl EQ 'ST0002' OR mara~matkl EQ 'HI0001' THEN '1.HUEVO INCUBABLE' ELSE
      CASE WHEN mara~matkl EQ 'VC0001' THEN '2.VACUNAS' ELSE
      CASE WHEN mara~matkl EQ 'MD0005' THEN '3.MEDICINAS' ELSE
      CASE WHEN mara~matkl EQ 'PT0001' THEN '4.POLLITO GAPESA' ELSE
      CAST( 'BORRAR' AS CHAR( 40 ) )  END END END END AS CHAR( 40 ) ) AS wgbez60,
        mseg~werks, budat AS budat_mkpf,
      CAST(  hsl AS DEC( 13,2 ) ) AS dmbtr, CAST( hsl AS DEC( 13,2 ) ) AS dmbtr_st
    FROM acdoca
    INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
    INNER JOIN aufk ON aufk~aufnr = acdoca~aufnr
    INNER JOIN mara ON mara~matnr = acdoca~matnr
    INNER JOIN t023t ON t023t~matkl = mara~matkl
    INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
    WHERE aufk~auart EQ 'IN03'
    AND budat IN @lv_rgfechas
    AND racct EQ '0504025051'
    AND acdoca~werks IN @p_werks
    INTO TABLE @DATA(it_mseg).


    SORT it_mseg BY aufnr budat_mkpf.

    IF it_mseg IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mseg
      WHERE lfgja = @it_mseg-budat_mkpf+0(4)
      AND matnr = @it_mseg-matnr
      AND bwkey = @it_mseg-werks.


      LOOP AT it_mseg ASSIGNING <fst_maquila>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT_MKPF' OF STRUCTURE <fst_maquila> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_maquila> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_maquila> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_maquila> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_maquila> TO <f_field>.
          vl_dmbtr = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'BWART' OF STRUCTURE <fst_maquila> TO <f_field>.

*          IF <f_field> EQ '543'.
*            vl_menge = vl_menge * -1.
          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_maquila> TO <f_field>.
          <f_field> = vl_dmbtr.

**            IF vl_menge < 0.
*              UNASSIGN <f_field>.
*              ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_maquila> TO <f_field>.
*              <f_field> = vl_dmbtr."<f_field> * -1.
*            ENDIF.
*          ENDIF.
        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_maquila[] = it_mseg[].
    ENDIF.


  ENDMETHOD.


METHOD get_mb51. "costos directos ppa depositos empacadora "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.


    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.



      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CASE WHEN mara~matkl EQ 'ST0002' THEN 'POLLITO' ELSE
      "CASE WHEN substring( acdoca~werks,1,2 ) EQ 'PA' THEN 'MATERIAS PRIMAS' ELSE
      CASE WHEN mara~matkl EQ 'PT0001' THEN 'TRASP. DIARIO POLLO VIVO' ELSE
      CASE WHEN mara~matkl EQ 'PT0011' THEN 'MATERIA PRIMA' ELSE
      CASE WHEN mara~matkl EQ 'PT0010' THEN 'TRASP. DIARIO POLLO MAQUILA' ELSE
      CASE WHEN mara~matkl EQ 'CM0001' THEN 'PAJILLA' ELSE
      CASE WHEN racct EQ '0504025051' OR racct EQ '0504025106' AND mara~matkl NE 'CM0001' THEN 'CONSUMO DE INSUMOS' ELSE
      CASE WHEN mara~matkl EQ 'PT0004' THEN 'ALIMENTO' ELSE

      CASE WHEN mara~matkl EQ 'VC0001' THEN 'VACUNAS' ELSE
      CASE WHEN racct IS NOT INITIAL AND substring( acdoca~werks,1,2 ) EQ 'PA' THEN skat~txt50 ELSE
      t023t~wgbez60 END END
      END END END END END END END AS wgbez60,
      acdoca~werks,
      acdoca~msl AS menge,mara~meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem,racct
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 INNER JOIN mara ON mara~matnr = acdoca~matnr
 INNER JOIN t023t ON t023t~matkl = mara~matkl
 INNER JOIN skat ON skat~saknr = acdoca~racct
"FOR ALL ENTRIES IN @i_aufnr
WHERE acdoca~aufnr IN @rg_aufnr"@i_aufnr-aufnr
AND mseg~bwart IN @i_rgbwart "('261', '262')
INTO TABLE @DATA(it_mb51).


      SORT it_mb51 BY aufnr budat.

    ENDIF.

    IF it_mb51 IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mb51
      WHERE lfgja = @it_mb51-budat+0(4)
      AND matnr = @it_mb51-matnr.


      LOOP AT it_mb51 ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_dmbtr = <f_field>.

*          UNASSIGN <f_field>.
*          ASSIGN COMPONENT 'BWART' OF STRUCTURE <fst_mb51> TO <f_field>.
*
*          IF <f_field> EQ '262'.
          " vl_menge = vl_menge * -1.
          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.
*          ELSE.
*            IF wa_mbewh-verpr GT 0.
*              vl_dmbtr = vl_menge * wa_mbewh-verpr.
*            ENDIF.
*          ENDIF.

*          UNASSIGN <f_field>.
*          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
*          <f_field> = vl_menge.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          <f_field> = vl_dmbtr.

*          IF vl_menge < 0.
*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_mb51> TO <f_field>.
*            "<f_field> = <f_field> * -1.
*          ENDIF.
        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_mb51[] = it_mb51[].
    ENDIF.

  ENDMETHOD.


METHOD get_mb51_alim. "costos directos alimento "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.


    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.



      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CASE WHEN racct EQ '0504025051' OR racct EQ '0504025106' OR racct EQ '0504025053'
      THEN 'MATERIA PRIMA' ELSE
      CASE WHEN racct IS NOT INITIAL THEN skat~txt20 ELSE
      t023t~wgbez60 END END AS  wgbez60,
      acdoca~werks,
      acdoca~msl AS menge,mara~meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem,racct
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 INNER JOIN mara ON mara~matnr = acdoca~matnr
 INNER JOIN t023t ON t023t~matkl = mara~matkl
 INNER JOIN skat ON skat~saknr = acdoca~racct
WHERE acdoca~aufnr IN @rg_aufnr
AND mseg~bwart IN @i_rgbwart
INTO TABLE @DATA(it_mb51).

      DELETE it_mb51 WHERE racct EQ '0504025052'.

      SORT it_mb51 BY aufnr budat.

    ENDIF.

    IF it_mb51 IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mb51
      WHERE lfgja = @it_mb51-budat+0(4)
      AND matnr = @it_mb51-matnr.


      LOOP AT it_mb51 ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_menge = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_dmbtr = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.

          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.


          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          <f_field> = vl_dmbtr.

        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_mb51[] = it_mb51[].
    ENDIF.

  ENDMETHOD.


METHOD get_mb51_crianza. "costos directos crianza "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.


    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.



      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CASE WHEN racct EQ '0504025051' AND mara~matkl NE 'PT0001' THEN '3.CONSUMO DE MATERIAS PRIMAS' ELSE
      CASE WHEN racct EQ '0504025051' AND mara~matkl EQ 'PT0001' THEN '2.POLLITA' ELSE
      CASE WHEN racct EQ '0504025053' THEN '1.CONSUMO ALIMENTO' ELSE
      CASE WHEN racct EQ '0504025052' THEN '4.CONSUMO SEMITERMINADO' ELSE
      CAST( 'BORRAR' AS CHAR( 60 ) )  END END END END AS wgbez60,
      acdoca~werks,
      acdoca~msl AS menge,CAST( 'PZA' AS UNIT( 3 ) ) AS meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem,racct
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 LEFT JOIN mara ON mara~matnr = acdoca~matnr
 "left JOIN t023t ON t023t~matkl = mara~matkl
 INNER JOIN skat ON skat~saknr = acdoca~racct
"FOR ALL ENTRIES IN @i_aufnr
WHERE acdoca~aufnr IN @rg_aufnr"@i_aufnr-aufnr
AND mseg~bwart IN @i_rgbwart
AND racct IN ('0504025051','0504025052','0504025053')
INTO TABLE @DATA(it_mb51).


      SORT it_mb51 BY wgbez60 aufnr budat.

    ENDIF.

    IF it_mb51 IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mb51
      WHERE lfgja = @it_mb51-budat+0(4)
      AND matnr = @it_mb51-matnr.


      LOOP AT it_mb51 ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_dmbtr = <f_field>.

          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          <f_field> = vl_dmbtr.

        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_mb51[] = it_mb51[].
    ENDIF.

  ENDMETHOD.


METHOD get_mb51_dep. "costos directos ppa depositos empacadora "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

*    DATA: rg_werks   TYPE RANGE OF t001w-werks,
*          wa_rgwerks LIKE LINE OF rg_werks.



    DATA: rg_matkl   TYPE RANGE OF mara-matkl,
          wa_rgmatkl LIKE LINE OF rg_matkl.



    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

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

*    IF i_werks IS NOT INITIAL.
*      CLEAR wa_rgwerks.
*      wa_rgwerks-sign = 'I'.
*      wa_rgwerks-option = 'EQ'.
*      wa_rgwerks-low = i_werks.
*      APPEND wa_rgwerks TO rg_werks.
*    ENDIF.

*    CLEAR wa_rgmatkl.
*    wa_rgmatkl-sign = 'I'.
*    wa_rgmatkl-option = 'EQ'.
*    wa_rgmatkl-low = i_matkl.
*    APPEND wa_rgmatkl TO rg_matkl.




    SELECT mseg~aufnr, mseg~matnr, mara~matkl,mseg~bwart,
    CASE WHEN mara~matkl EQ 'ST0002' THEN 'POLLITO' ELSE
    CASE WHEN mara~matkl EQ 'PT0001' THEN 'TRASP. DIARIO POLLO VIVO' ELSE
    CASE WHEN mara~matkl EQ 'PT0010' THEN 'TRASP. DIARIO POLLO CALIENTE' ELSE
    CASE WHEN mara~matkl EQ 'CM0001' THEN 'PAJILLA' ELSE
    CASE WHEN mara~matkl EQ 'PT0004' THEN 'ALIMENTO' ELSE
    CASE WHEN mara~matkl EQ 'VC0001' THEN 'VACUNAS' ELSE
    t023t~wgbez60 END END
    END END END END AS wgbez60,
    mseg~werks,
    mseg~menge,mara~meins, mseg~budat_mkpf,
    mseg~dmbtr, mseg~dmbtr AS dmbtr_st

FROM mseg
INNER JOIN mara ON mara~matnr = mseg~matnr
INNER JOIN t023t ON t023t~matkl = mara~matkl
WHERE mseg~werks IN @i_werks
AND mseg~bwart IN @i_rgbwart
AND mara~matkl IN @i_matkl
AND budat_mkpf IN @lv_rgfechas
INTO TABLE @DATA(it_mb51).


    SORT it_mb51 BY aufnr budat_mkpf.



    IF it_mb51 IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mb51
      WHERE lfgja = @it_mb51-budat_mkpf+0(4)
      AND matnr = @it_mb51-matnr.


      LOOP AT it_mb51 ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT_MKPF' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_dmbtr = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'BWART' OF STRUCTURE <fst_mb51> TO <f_field>.

          IF <f_field> EQ '602'.
            vl_menge = vl_menge * -1.
            IF wa_mbewh-verpr GT 0.
              vl_dmbtr = vl_menge * wa_mbewh-verpr.
            ENDIF.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
            <f_field> = vl_dmbtr.

            IF vl_menge < 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_mb51> TO <f_field>.
              <f_field> = <f_field> * -1.
            ENDIF.
          ENDIF.
        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_mb51_dep[] = it_mb51[].
    ENDIF.

  ENDMETHOD.


METHOD get_mb51_eng. "costos directos engorda "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.


    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.



      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CASE WHEN mara~matkl EQ 'ST0002' THEN CAST( '2.POLLITO' AS CHAR( 60 ) ) ELSE
      CASE WHEN mara~matkl EQ 'PT0001' THEN CAST( 'TRASP. DIARIO POLLO VIVO' AS CHAR( 60 ) ) ELSE
      CASE WHEN mara~matkl EQ 'CM0001' THEN CAST( '4.PAJILLA' AS CHAR( 60 ) ) ELSE
      CASE WHEN mara~matkl EQ 'VC0001' THEN CAST( '3.VACUNAS' AS CHAR( 60 ) ) ELSE
      CASE WHEN mara~matkl EQ 'PT0004' THEN CAST( '1.ALIMENTO' AS CHAR( 60 ) ) ELSE
      CASE WHEN racct IS NOT INITIAL AND substring( acdoca~werks,1,2 ) EQ 'PA' THEN skat~txt50 ELSE
      "t023t~wgbez60 END END
      CAST( '5.CONSUMO DE INSUMOS' AS CHAR( 60 ) ) END END
      END END END END AS wgbez60,
      acdoca~werks,
      acdoca~msl AS menge,mara~meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem,racct
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 INNER JOIN mara ON mara~matnr = acdoca~matnr
 INNER JOIN t023t ON t023t~matkl = mara~matkl
 INNER JOIN skat ON skat~saknr = acdoca~racct
"FOR ALL ENTRIES IN @i_aufnr
WHERE acdoca~aufnr IN @rg_aufnr"@i_aufnr-aufnr
AND mseg~bwart IN @i_rgbwart "('261', '262')
INTO TABLE @DATA(it_mb51).


      SORT it_mb51 BY wgbez60 aufnr budat .

    ENDIF.

    IF it_mb51 IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mb51
      WHERE lfgja = @it_mb51-budat+0(4)
      AND matnr = @it_mb51-matnr.


      LOOP AT it_mb51 ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_dmbtr = <f_field>.

*          UNASSIGN <f_field>.
*          ASSIGN COMPONENT 'BWART' OF STRUCTURE <fst_mb51> TO <f_field>.
*
*          IF <f_field> EQ '262'.
          " vl_menge = vl_menge * -1.
          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.
*          ELSE.
*            IF wa_mbewh-verpr GT 0.
*              vl_dmbtr = vl_menge * wa_mbewh-verpr.
*            ENDIF.
*          ENDIF.

*          UNASSIGN <f_field>.
*          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
*          <f_field> = vl_menge.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          <f_field> = vl_dmbtr.

*          IF vl_menge < 0.
*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_mb51> TO <f_field>.
*            "<f_field> = <f_field> * -1.
*          ENDIF.
        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_mb51[] = it_mb51[].
    ENDIF.

  ENDMETHOD.


METHOD get_mb51_huevo. "costos directos alimento "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.


    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.



      SELECT mseg~aufnr, mseg~matnr, mara~matkl,
      CASE WHEN hkont EQ '0504025051' THEN 'MATERIA PRIMA' ELSE
      CASE WHEN hkont EQ '0504025053' THEN 'ALIMENTO' ELSE
      CASE WHEN hkont EQ '0504025001' THEN 'APARCERIA' ELSE
      CASE WHEN hkont EQ '0504025052' THEN 'CRIANZA' ELSE
      CASE WHEN hkont IS NOT INITIAL THEN skat~txt20 ELSE
      t023t~wgbez60 END END END END END AS  wgbez60,
      mseg~werks,
      mseg~menge,mara~meins, mseg~budat_mkpf,
      mseg~dmbtr,mseg~dmbtr  AS dmbtr_st
 FROM mseg
 INNER JOIN mara ON mara~matnr = mseg~matnr
 INNER JOIN bseg ON bseg~aufnr = mseg~aufnr
 INNER JOIN t023t ON t023t~matkl = mara~matkl
 INNER JOIN skat ON skat~saknr = bseg~hkont
WHERE mseg~aufnr IN @rg_aufnr"@i_aufnr-aufnr
AND mseg~bwart IN @i_rgbwart "('261', '262')
INTO TABLE @DATA(it_mb51).



      SORT it_mb51 BY aufnr budat_mkpf.

    ENDIF.

    IF it_mb51 IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mb51
      WHERE lfgja = @it_mb51-budat_mkpf+0(4)
      AND matnr = @it_mb51-matnr.


      LOOP AT it_mb51 ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_dmbtr = <f_field>.

*          UNASSIGN <f_field>.
*          ASSIGN COMPONENT 'BWART' OF STRUCTURE <fst_mb51> TO <f_field>.
*
*          IF <f_field> EQ '262'.
          " vl_menge = vl_menge * -1.
          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.
*          ELSE.
*            IF wa_mbewh-verpr GT 0.
*              vl_dmbtr = vl_menge * wa_mbewh-verpr.
*            ENDIF.
*          ENDIF.

*          UNASSIGN <f_field>.
*          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
*          <f_field> = vl_menge.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          <f_field> = vl_dmbtr.

*          IF vl_menge < 0.
*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_mb51> TO <f_field>.
*            "<f_field> = <f_field> * -1.
*          ENDIF.
        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_mb51[] = it_mb51[].
    ENDIF.

  ENDMETHOD.


METHOD get_mb51_incubadora. "costos directos crianza "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.


    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.



      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
       CASE WHEN mara~matkl EQ 'ST0002' OR mara~matkl EQ 'HI0001' THEN '1.HUEVO INCUBABLE' ELSE
      CASE WHEN mara~matkl EQ 'VC0001' THEN '2.VACUNAS' ELSE
      CASE WHEN mara~matkl EQ 'MD0005' THEN '3.MEDICINAS' ELSE
      CASE WHEN mara~matkl EQ 'PT0001' THEN '4.POLLITO GAPESA' ELSE
      CAST( 'BORRAR' AS CHAR( 60 ) )  END END END END AS wgbez60,
      "t023t~wgbez60,
      acdoca~werks,
      acdoca~msl AS menge,CAST( 'PZA' AS UNIT( 3 ) ) AS meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem,racct
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 LEFT JOIN mara ON mara~matnr = acdoca~matnr
 LEFT JOIN t023t ON t023t~matkl = mara~matkl
 INNER JOIN skat ON skat~saknr = acdoca~racct
"FOR ALL ENTRIES IN @i_aufnr
WHERE acdoca~aufnr IN @rg_aufnr"@i_aufnr-aufnr
AND mseg~bwart IN @i_rgbwart
AND racct IN ('0504025051','0504025052')
INTO TABLE @DATA(it_mb51).


      SORT it_mb51 BY wgbez60 aufnr budat.

    ENDIF.

    IF it_mb51 IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mb51
      WHERE lfgja = @it_mb51-budat+0(4)
      AND matnr = @it_mb51-matnr.


      LOOP AT it_mb51 ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_dmbtr = <f_field>.

          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          <f_field> = vl_dmbtr.

        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_mb51[] = it_mb51[].
    ENDIF.

  ENDMETHOD.


METHOD get_mb51_post. "costos directos empacadora "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.


    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.



      SELECT acdoca~aufnr, acdoca~matnr, CAST( 'GPOART' AS CHAR( 9 ) ) AS matkl,
      CASE WHEN racct EQ '0504025051' THEN '3.CONSUMO DE MATERIAS PRIMAS' ELSE
      CASE WHEN racct EQ '0504025053' THEN '1.ALIMENTO' ELSE
      CASE WHEN racct EQ '0504025052' THEN '2.AGOTAMIENTO/COSTO CRIANZA' ELSE
      CASE WHEN racct EQ '0504025001' THEN '4.COSTO PARTICIPACION APARCERIA' ELSE
      CAST( 'BORRAR' AS CHAR( 60 ) )  END END END END AS wgbez60,
      acdoca~werks,
      acdoca~msl AS menge,CAST( 'PZA' AS UNIT( 3 ) ) AS meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem,racct
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 "left JOIN mara ON mara~matnr = acdoca~matnr
 "left JOIN t023t ON t023t~matkl = mara~matkl
 INNER JOIN skat ON skat~saknr = acdoca~racct
"FOR ALL ENTRIES IN @i_aufnr
WHERE acdoca~aufnr IN @rg_aufnr"@i_aufnr-aufnr
AND mseg~bwart IN @i_rgbwart
AND racct IN ('0504025051','0504025053','0504025052','0504025001')
INTO TABLE @DATA(it_mb51).


      SORT it_mb51 BY wgbez60 aufnr budat.

    ENDIF.

    IF it_mb51 IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mb51
      WHERE lfgja = @it_mb51-budat+0(4)
      AND matnr = @it_mb51-matnr.


      LOOP AT it_mb51 ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_dmbtr = <f_field>.

          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          <f_field> = vl_dmbtr.

        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.

      ch_mb51[] = it_mb51[].
    ENDIF.

  ENDMETHOD.


METHOD get_mermas. "mermas para alimento "


    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    FIELD-SYMBOLS: <fst_mermas> TYPE any,
                   <f_field>    TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.


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

*    IF i_werks IS INITIAL OR i_werks NE 'PA01'.
*
*      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
*         CAST( 'MERMAS' AS CHAR( 40 ) ) AS wgbez60,
*         acdoca~werks,
*         mseg~menge,mara~meins, budat,
*         acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
*         awref,awitem
*     FROM acdoca
*     INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
*     INNER JOIN mara ON mara~matnr = acdoca~matnr
*     INNER JOIN t023t ON t023t~matkl = mara~matkl
*     INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
*     "FOR ALL ENTRIES IN @i_aufnr
*     WHERE "acdoca~aufnr = @i_aufnr-aufnr
*     mseg~bwart IN @i_rgbwart
*     AND mseg~budat_mkpf IN @lv_rgfechas
*     AND substring( acdoca~werks,1,2 ) EQ 'PA'
*     AND acdoca~racct LIKE '05%'
*     UNION ALL
*      SELECT mseg~aufnr, mseg~matnr, mara~matkl,
*       CAST( 'MERMAS' AS CHAR( 40 ) ) AS wgbez60,
*      mseg~werks,
*      mseg~menge,mara~meins, budat_mkpf AS budat,
*      mseg~dmbtr, mseg~dmbtr AS dmbtr_st,
*      '0000000000' AS awref, CAST( '000001' AS NUMC ) AS awitem
*      FROM mseg
*     " INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
*      INNER JOIN mara ON mara~matnr = mseg~matnr
*      INNER JOIN t023t ON t023t~matkl = mara~matkl
*      INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
*      WHERE mseg~bwart IN @i_rgbwart
*      AND mseg~budat_mkpf IN @lv_rgfechas
*      AND mseg~werks EQ 'AA01'
*      AND mseg~lgort IN ( 'GPST','GPPT', 'GPMP', 'GPEP' )
*      INTO TABLE @DATA(it_mseg_m).
*
*      ch_mermas[] = it_mseg_m[].
*
*
*    ELSEIF i_werks EQ 'PA01'.

    SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
       "makt~maktx AS wgbez60,
       CAST( 'MERMAS' AS CHAR( 40 ) ) AS wgbez60,
       acdoca~werks,
       CASE WHEN mseg~bwart EQ '551' OR mseg~bwart EQ '702' THEN CAST( mseg~menge * -1 AS DEC( 10,3 ) ) ELSE mseg~menge  END AS menge,
       mara~meins, budat,
       acdoca~hsl AS dmbtr,
       acdoca~hsl AS dmbtr_st,
       awref,awitem
   FROM acdoca
   INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
   INNER JOIN mara ON mara~matnr = acdoca~matnr
   INNER JOIN t023t ON t023t~matkl = mara~matkl
   INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
   "FOR ALL ENTRIES IN @i_aufnr
   WHERE "acdoca~aufnr = @i_aufnr-aufnr
   mseg~bwart IN @i_rgbwart
   AND mseg~budat_mkpf IN @lv_rgfechas
   AND substring( acdoca~werks,1,2 ) EQ 'PA'
   AND acdoca~racct LIKE '011500%'
   INTO TABLE @DATA(it_mseg).

    ch_mermas[] = it_mseg[].


*    ENDIF.

*    DATA(it_local) = it_mseg[].
*
*    IF it_local IS INITIAL.
*      it_local = it_mseg_m[].
*    ENDIF.

    IF it_mseg IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
            INTO TABLE @DATA(it_mbewh)
            FROM mbewh
            FOR ALL ENTRIES IN @it_mseg
            WHERE lfgja = @it_mseg-budat+0(4)
            AND matnr = @it_mseg-matnr
            "AND bwkey = 'PA01'.
            AND bwkey = @it_mseg-werks.



      LOOP AT ch_mermas ASSIGNING <fst_mermas>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mermas> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mermas> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mermas> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mermas> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mermas> TO <f_field>.
          vl_dmbtr = <f_field>.

          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mermas> TO <f_field>.
          <f_field> = vl_dmbtr.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_mermas> TO <f_field>.
          <f_field> = <f_field>.

        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.




    ENDIF.


  ENDMETHOD.


METHOD get_mermas_maq. "mermas para alimento "


    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    FIELD-SYMBOLS: <fst_mermas> TYPE any,
                   <f_field>    TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.



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

*
*
*    SELECT mseg~aufnr, mseg~matnr, mara~matkl,
*    CAST( 'Mermas de Maquila' AS CHAR( 40 ) ) AS wgbez60,
*    mseg~werks,
*    CASE WHEN mseg~bwart EQ '551' OR mseg~bwart EQ '702' THEN CAST( mseg~menge * -1 AS DEC( 10,3 ) ) ELSE mseg~menge  END AS menge,
*    mara~meins, budat_mkpf,
*    mseg~dmbtr,
*    mseg~dmbtr AS dmbtr_st
*  FROM acdoca
*   INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
*  INNER JOIN mara ON mara~matnr = mseg~matnr
*  INNER JOIN t023t ON t023t~matkl = mara~matkl
*  INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
*  WHERE mseg~bwart IN ( '551','552','701','702' )"@i_rgbwart
*  AND mseg~budat_mkpf IN @lv_rgfechas
*  AND mseg~werks EQ 'AA01'
*  AND mseg~lgort IN ( 'GPST','GPPT' )
*  AND acdoca~racct LIKE '011500%'
*  UNION ALL
    SELECT mseg~aufnr, mseg~matnr, mara~matkl,
      CAST( 'Mermas de Maquila' AS CHAR( 40 ) ) AS wgbez60,
      mseg~werks,
      CASE WHEN mseg~bwart EQ '702' OR mseg~bwart EQ '551' THEN CAST( mseg~menge * -1 AS DEC( 10,3 ) ) ELSE mseg~menge  END AS menge,
      mara~meins, budat_mkpf,
      mseg~dmbtr,
      mseg~dmbtr AS dmbtr_st
    FROM acdoca
     INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
    INNER JOIN mara ON mara~matnr = mseg~matnr
    INNER JOIN t023t ON t023t~matkl = mara~matkl
    INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
    WHERE mseg~bwart IN ( '701','702','551','552' )
    AND mseg~budat_mkpf IN @lv_rgfechas
    AND mseg~werks EQ 'AA01'
    AND mseg~lgort IN ('GPST','GPPT', 'GPMP', 'GPEP','GPRP' )
  AND acdoca~racct LIKE '011500%'
    INTO TABLE @DATA(it_mseg).


    IF it_mseg IS NOT INITIAL.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
            INTO TABLE @DATA(it_mbewh)
            FROM mbewh
            FOR ALL ENTRIES IN @it_mseg
            WHERE lfgja = @it_mseg-budat_mkpf+0(4)
            AND matnr = @it_mseg-matnr
            AND bwkey = 'AA01'.



      LOOP AT it_mseg ASSIGNING <fst_mermas>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT_MKPF' OF STRUCTURE <fst_mermas> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mermas> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mermas> TO <f_field>.
        vl_bwkey = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mermas> TO <f_field>.
        vl_menge = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mermas> TO <f_field>.
        vl_dmbtr = <f_field>.


        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

*        IF sy-subrc EQ 0.
*
*          IF wa_mbewh-verpr GT 0.
*            vl_dmbtr = vl_menge * wa_mbewh-verpr.
*          ENDIF.
*
*          UNASSIGN <f_field>.
*          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mermas> TO <f_field>.
*          <f_field> = vl_dmbtr.
*
*          IF vl_menge < 0.
*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_mermas> TO <f_field>.
*            <f_field> = <f_field> * -1.
*          ENDIF.
*        ELSE.
*
*          UNASSIGN <f_field>.
*          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mermas> TO <f_field>.
*          IF vl_menge < 0.
*            <f_field> = vl_dmbtr * -1.
*
*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_mermas> TO <f_field>.
*            <f_field> = <f_field> * -1.
*
*          ENDIF.
*
*        ENDIF.
*

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mermas> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mermas> TO <f_field>.
          vl_dmbtr = <f_field>.

          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mermas> TO <f_field>.
          <f_field> = vl_dmbtr.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR_ST' OF STRUCTURE <fst_mermas> TO <f_field>.
          IF vl_menge LT 0.
            <f_field> = <f_field> * -1.
          ENDIF.
        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.




    ENDIF.
    ch_mermas_maq[] = it_mseg[].


  ENDMETHOD.


METHOD get_recuperaciones. "recuperaciones "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.


    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.

      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CASE WHEN mara~matnr EQ '000000000000400187' THEN 'RECUPERACIÓN DECOMISOS POLLO' ELSE
      CASE WHEN mara~matnr EQ '000000000000400054' OR  mara~matnr EQ '000000000000400055' THEN 'POLLINAZA' ELSE
      CASE WHEN mara~matkl EQ 'PT0004' THEN 'RECUPERACION ALIMENTO TOLVAS' ELSE makt~maktx END END END AS wgbez60, acdoca~werks,
      mseg~menge,mara~meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 INNER JOIN mara ON mara~matnr = acdoca~matnr
INNER JOIN t023t ON t023t~matkl = mara~matkl
INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
"FOR ALL ENTRIES IN @i_aufnr
WHERE acdoca~aufnr IN @rg_aufnr
AND mseg~bwart IN ('531', '532')
INTO TABLE @DATA(it_mseg).


      SORT it_mseg BY aufnr budat.

    ENDIF.
    ch_recupera[] = it_mseg[].





  ENDMETHOD.


METHOD get_recuperaciones_crianza. "recuperaciones "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.


    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.

      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CASE WHEN racct EQ '0504025111' OR racct EQ '0504025192'
      THEN 'RECUPERACIÓN GALLINAZA' ELSE makt~maktx END AS wgbez60, acdoca~werks,
      mseg~menge,mara~meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 INNER JOIN mara ON mara~matnr = acdoca~matnr
INNER JOIN t023t ON t023t~matkl = mara~matkl
INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
"FOR ALL ENTRIES IN @i_aufnr
WHERE acdoca~aufnr IN @rg_aufnr
AND mseg~bwart IN ('531', '532')
AND racct IN ('0504025111','0504025192')
INTO TABLE @DATA(it_mseg).


      SORT it_mseg BY aufnr budat.

    ENDIF.
    ch_recupera[] = it_mseg[].





  ENDMETHOD.


METHOD get_recuperaciones_post. "recuperaciones "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.


    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    IF i_aufnr IS NOT INITIAL.

      SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
      CASE WHEN racct EQ '0504025111' THEN 'RECUPERACIONES (PRODUC SEMITERMINADA)' ELSE makt~maktx END AS wgbez60, acdoca~werks,
      mseg~menge,mara~meins, budat,
      acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
      awref,awitem
 FROM acdoca
 INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
 INNER JOIN mara ON mara~matnr = acdoca~matnr
INNER JOIN t023t ON t023t~matkl = mara~matkl
INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
"FOR ALL ENTRIES IN @i_aufnr
WHERE acdoca~aufnr IN @rg_aufnr
AND mseg~bwart IN ('531', '532')
AND racct EQ '0504025111'
INTO TABLE @DATA(it_mseg).


      SORT it_mseg BY aufnr budat.

    ENDIF.
    ch_recupera[] = it_mseg[].





  ENDMETHOD.


METHOD get_recupera_alim. "recuperaciones alimento "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.

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



    SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
    "makt~maktx AS wgbez60,
    CAST( 'RECUPERACIONES' AS CHAR( 40 ) ) AS wgbez60,
    acdoca~werks,
    "mseg~menge,
    mara~meins, budat,
    acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
    awref,awitem
FROM acdoca
" INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
INNER JOIN aufk ON aufk~aufnr = acdoca~aufnr
INNER JOIN mara ON mara~matnr = acdoca~matnr
INNER JOIN t023t ON t023t~matkl = mara~matkl
INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
"FOR ALL ENTRIES IN @i_aufnr
WHERE
"acdoca~aufnr = @i_aufnr-aufnr
"AND mseg~bwart IN ('531', '532')
budat IN @lv_rgfechas AND
aufk~auart IN ( 'SUAT','SUVE','SUCB','SUCH' )
AND racct EQ '0504025111'
INTO TABLE @DATA(it_mseg).


    SORT it_mseg BY aufnr budat.





    ch_recupera[] = it_mseg[].
*    ENDIF.




  ENDMETHOD.


METHOD get_subprd_gapesa. "recuperaciones "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.


    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    DATA(vl_tt_aufnr_nac) = i_aufnr.
    SORT vl_tt_aufnr_nac BY dauat.

    DELETE vl_tt_aufnr_nac WHERE dauat NE 'IN03'.



    LOOP AT vl_tt_aufnr_nac INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.

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


    SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
    CAST( CASE WHEN mara~matkl EQ 'ST0002' THEN '1.DECOMISO' ELSE 'BORRAR' END AS CHAR( 40 ) ) AS wgbez60, acdoca~werks,
     CAST( CASE WHEN mseg~bwart EQ '532' THEN mseg~menge * -1 ELSE mseg~menge END AS QUAN( 13,3 ) )  AS menge ,mara~meins, budat,
    acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
    awref,awitem
    FROM acdoca
    INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
   INNER JOIN aufk ON aufk~aufnr = acdoca~aufnr
    INNER JOIN mara ON mara~matnr = acdoca~matnr
    INNER JOIN t023t ON t023t~matkl = mara~matkl
    INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
    WHERE mseg~bwart IN ( '531','532' )
    AND aufk~aufnr IN @rg_aufnr
    AND mseg~werks IN @i_werks
    AND acdoca~budat IN @lv_rgfechas


    INTO TABLE @DATA(it_mseg).


    SORT it_mseg BY wgbez60 aufnr budat.

    IF it_mseg IS NOT INITIAL.

      DELETE it_mseg WHERE wgbez60 = 'BORRAR'.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mseg
      WHERE lfgja = @it_mseg-budat+0(4)
      AND matnr = @it_mseg-matnr.


      LOOP AT it_mseg ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_dmbtr = <f_field>.

          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.


          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          <f_field> = vl_dmbtr.

        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.


    ENDIF.

    ch_sub_hc[] = it_mseg[].

  ENDMETHOD.


METHOD get_sub_hc. "recuperaciones "

    FIELD-SYMBOLS: <fst_mb51> TYPE any,
                   <f_field>  TYPE any.

    DATA: vl_lfmon(2), vl_lfgja(4),
          vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
          vl_menge    TYPE menge_d, vl_dmbtr TYPE dmbtr.


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



    SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
    CAST( CASE WHEN acdoca~matnr EQ '000000000000400259' THEN '1.HUEVO COMERCIAL' ELSE 'BORRAR' END AS CHAR( 40 ) ) AS wgbez60, acdoca~werks,
    CAST( CASE WHEN mseg~bwart EQ '102' THEN mseg~menge * -1 ELSE mseg~menge END AS QUAN( 13,3 ) )  AS menge,mara~meins, budat,
    acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
    awref,awitem
    FROM acdoca
    INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
    INNER JOIN mara ON mara~matnr = acdoca~matnr
    INNER JOIN t023t ON t023t~matkl = mara~matkl
    INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
    WHERE mseg~bwart IN @i_bwart
    AND mseg~werks IN @i_werks
    AND acdoca~matnr EQ '000000000000400259'
    AND acdoca~racct EQ '0504025111'
    AND acdoca~budat IN @lv_rgfechas
    UNION ALL
    SELECT acdoca~aufnr, acdoca~matnr, mara~matkl,
    CAST( CASE WHEN mara~matkl EQ 'ST0002' THEN '2.DECOMISO' ELSE 'BORRAR' END AS CHAR( 40 ) ) AS wgbez60, acdoca~werks,
     CAST( CASE WHEN mseg~bwart EQ '532' THEN mseg~menge * -1 ELSE mseg~menge END AS QUAN( 13,3 ) )  AS menge ,mara~meins, budat,
    acdoca~hsl AS dmbtr, acdoca~hsl AS dmbtr_st,
    awref,awitem
    FROM acdoca
    INNER JOIN mseg ON mseg~mblnr = acdoca~awref AND mseg~zeile = substring( acdoca~awitem, 3,4 )
   INNER JOIN aufk ON aufk~aufnr = acdoca~aufnr
    INNER JOIN mara ON mara~matnr = acdoca~matnr
    INNER JOIN t023t ON t023t~matkl = mara~matkl
    INNER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = 'S'
    WHERE mseg~bwart IN ( '531','532' )
    AND aufk~auart EQ 'IN01'
    AND mseg~werks IN @i_werks
    AND acdoca~racct EQ '0504025111'
    AND acdoca~budat IN @lv_rgfechas


    INTO TABLE @DATA(it_mseg).


    SORT it_mseg BY wgbez60 aufnr budat.

    IF it_mseg IS NOT INITIAL.

      DELETE it_mseg WHERE wgbez60 = 'BORRAR'.

      SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_mseg
      WHERE lfgja = @it_mseg-budat+0(4)
      AND matnr = @it_mseg-matnr.


      LOOP AT it_mseg ASSIGNING <fst_mb51>.

        "SE VALIDA EL PRECIO REAL DE CUANDO FUE CONTABILIZADO EL MOVIMIENTO
        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_lfmon = <f_field>+4(2).
        vl_lfgja = <f_field>+0(4).

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_matnr = <f_field>.

        UNASSIGN <f_field>.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fst_mb51> TO <f_field>.
        vl_bwkey = <f_field>.

        READ TABLE it_mbewh INTO DATA(wa_mbewh)
                    WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                             bwkey = vl_bwkey matnr = vl_matnr.

        IF sy-subrc EQ 0.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_menge = <f_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          vl_dmbtr = <f_field>.

          IF wa_mbewh-verpr GT 0.
            vl_dmbtr = vl_menge * wa_mbewh-verpr.
          ENDIF.


          UNASSIGN <f_field>.
          ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fst_mb51> TO <f_field>.
          <f_field> = vl_dmbtr.

        ENDIF.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDLOOP.


    ENDIF.

    ch_sub_hc[] = it_mseg[].

  ENDMETHOD.


METHOD kgs_procesa_dep.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    TYPES: BEGIN OF st_aux,
             aufnr TYPE aufnr,
             matnr TYPE char40,
             menge TYPE p LENGTH 13 DECIMALS 3,
           END OF st_aux.
    "
    DATA: it_aux TYPE STANDARD TABLE OF st_aux,
          wa_aux LIKE LINE OF it_aux.

    DATA: rg_matkl   TYPE RANGE OF mara-matkl,
          wa_rgmatkl LIKE LINE OF rg_matkl.

    CLEAR wa_rgmatkl.
    wa_rgmatkl-sign = 'I'.
    wa_rgmatkl-option = 'EQ'.
    wa_rgmatkl-low = i_matkl.
    APPEND wa_rgmatkl TO rg_matkl.

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



    SELECT aufnr,CAST( 'Kilos Procesados' AS CHAR( 40 ) ) AS wgbez60,  budat_mkpf,
    CASE WHEN bwart = '602' THEN menge * -1 ELSE menge END
    AS /cwm/menge
    INTO TABLE @DATA(it_kgsproces)
    FROM mseg
    INNER JOIN mara ON mara~matnr = mseg~matnr
    WHERE budat_mkpf IN @lv_rgfechas
    AND mseg~werks IN @i_werks
    AND mseg~bwart IN @i_rgbwart
    AND mseg~matnr EQ '000000000000500020'
    AND mara~matkl IN @rg_matkl.



    SORT it_kgsproces BY aufnr budat_mkpf.
    ch_kgsproces[]  = it_kgsproces[].
  ENDMETHOD.


METHOD kgs_procesa_ppa.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    TYPES: BEGIN OF st_aux,
             aufnr TYPE aufnr,
             matnr TYPE char40,
             menge TYPE p LENGTH 13 DECIMALS 3,
           END OF st_aux.
    "
    DATA: it_aux TYPE STANDARD TABLE OF st_aux,
          wa_aux LIKE LINE OF it_aux.

    DATA: rg_matkl   TYPE RANGE OF mara-matkl,
          wa_rgmatkl LIKE LINE OF rg_matkl.

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    CLEAR wa_rgmatkl.
    wa_rgmatkl-sign = 'I'.
    wa_rgmatkl-option = 'EQ'.
    wa_rgmatkl-low = i_matkl.
    APPEND wa_rgmatkl TO rg_matkl.

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

    LOOP AT i_aufnr INTO DATA(wa_aufnr).
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.



    SELECT aufnr,CAST( 'Kilos Procesados' AS CHAR( 40 ) ) AS wgbez60,  budat_mkpf,
    CASE WHEN bwart = '102' THEN menge * -1 ELSE menge END
    AS /cwm/menge
    INTO TABLE @DATA(it_kgsproces)
    FROM mseg
    "INNER JOIN mara ON mara~matnr = mseg~matnr
    WHERE budat_mkpf IN @lv_rgfechas
    AND mseg~aufnr IN @rg_aufnr
    AND mseg~werks IN @i_werks
    AND mseg~bwart IN @i_rgbwart.
    "AND mseg~matnr EQ '000000000000500020'
    "AND mara~matkl IN @rg_matkl.



    SORT it_kgsproces BY aufnr budat_mkpf.
    ch_kgsproces[]  = it_kgsproces[].
  ENDMETHOD.


METHOD mortal_deposito. "calcula mortalidad

    DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
          wa_rgaufnr LIKE LINE OF rg_aufnr.

    DATA: lv_rgfechas TYPE rg_fechas.
    DATA: min TYPE mseg-budat_mkpf,
          max TYPE mseg-budat_mkpf.

    TYPES: BEGIN OF st_aux,
             aufnr TYPE aufnr,
             matnr TYPE char40,
             menge TYPE p LENGTH 13 DECIMALS 3,
           END OF st_aux.
    "
    DATA: it_aux TYPE STANDARD TABLE OF st_aux,
          wa_aux LIKE LINE OF it_aux.

    DATA: rg_matkl   TYPE RANGE OF mara-matkl,
          wa_rgmatkl LIKE LINE OF rg_matkl.

    CLEAR wa_rgmatkl.
    wa_rgmatkl-sign = 'I'.
    wa_rgmatkl-option = 'EQ'.
    wa_rgmatkl-low = i_matkl.
    APPEND wa_rgmatkl TO rg_matkl.

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



    SELECT aufnr,CAST( 'Mortalidad Kgs.' AS CHAR( 40 ) ) AS wgbez60,  budat_mkpf,
    CASE WHEN bwart = '552' THEN /cwm/menge * -1 ELSE /cwm/menge END
    AS /cwm/menge
    INTO TABLE @DATA(it_mortalidad)
    FROM mseg
    INNER JOIN mara ON mara~matnr = mseg~matnr
    WHERE budat_mkpf IN @lv_rgfechas
    AND mseg~werks IN @i_werks
    AND mseg~bwart IN @i_rgbwart
    "AND mseg~aufnr IN @rg_aufnr
    AND mara~matkl IN @rg_matkl.



    SORT it_mortalidad BY aufnr budat_mkpf.
    ch_mortandad[]  = it_mortalidad[].

  ENDMETHOD.
ENDCLASS.
