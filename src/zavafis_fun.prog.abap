*&---------------------------------------------------------------------*
*& Include zavafis_fun
*&---------------------------------------------------------------------*

FORM get_jerarquia USING p_setname TYPE setnamenew.




  REFRESH it_jerarquia.




  SELECT subsetname, h~descript AS header1, h2~descript AS header2
  FROM setnode
  INNER JOIN setheadert AS h ON h~setclass = setnode~setclass
  AND h~subclass = setnode~subclass AND h~setname = setnode~setname
  INNER JOIN setheadert AS h2 ON h2~setclass = setnode~setclass
  AND h2~subclass = setnode~subclass AND h2~setname = setnode~subsetname
  WHERE setnode~setname EQ @p_setname "'HXTRA'
  AND setnode~setclass = '0101' AND setnode~subclass = 'GA00'
  INTO TABLE @DATA(head_activities).

  SELECT setname, valfrom, cskt~ltext
  INTO TABLE @DATA(it_leaf)
  FROM setleaf
  INNER JOIN cskt ON cskt~kostl = setleaf~valfrom
  FOR ALL ENTRIES IN @head_activities
  WHERE setname = @head_activities-subsetname.

  SORT it_leaf BY setname.

  it_jerarquia = VALUE #( FOR ls_activities IN head_activities
                          FOR ls_leaf IN it_leaf WHERE ( setname = ls_activities-subsetname )
                          (
                             header1 = ls_activities-header1
                             header2 = ls_activities-header2
                             kostl = ls_leaf-valfrom
                             ltext = ls_leaf-ltext
                          ) ).
ENDFORM.

FORM get_datos.
  DATA: vl_arbei TYPE char8,
        vl_ismnw TYPE char8.

  DATA: lv_feini   TYPE dats,
        lv_fefin   TYPE dats,
        lv_femin   TYPE dats,
        lv_femax   TYPE dats,
        lv_sem     TYPE i,
        str_concat TYPE string,
        lv_lines   TYPE i.

 data: rg_stat type ranGE OF jest-stat,
       wrg_stat like liNE OF rg_stat.



  DATA: lv_fecha TYPE datum,
        lv_flag.

  DATA: vl_opera1 TYPE menge_d, vl_opera2 TYPE menge_d.

  DATA: vl_total_plan_t TYPE p DECIMALS 1,
        vl_total_plan_a TYPE p DECIMALS 1,
        vl_total_real_a TYPE p DECIMALS 1.


  CASE p_sowrk.
    WHEN 'HXIN'.
      PERFORM get_jerarquia
        USING
          'HXTRA'.

  ENDCASE.

  CONCATENATE sy-datum+0(4) '01' '01' INTO str_concat.
  lv_feini = str_concat.
  CLEAR str_concat.
  CONCATENATE sy-datum+0(4) '12' '31' INTO str_concat.
  lv_fefin = str_concat.


  "paso 1
  SELECT au~sowrk, kostl, plgrp, vaplz, af~aufnr,
         gstrs, gsuzs , gltrs, gluzs,gsuzi,
         gstri, gltri, af~aufpl,
         CASE WHEN av~arbeh EQ 'MIN'  THEN division( av~arbei,60,2 ) ELSE av~arbei END AS arbei,
         CASE WHEN av~arbeh EQ 'MIN'  THEN division( av~ismnw,60,2 ) ELSE av~ismnw END AS ismnw,
         av~ofmnw,
         CASE WHEN  av~arbeh EQ 'STD' THEN 'HRA' ELSE av~arbeh END AS arbeh,
         CASE WHEN av~arbeh EQ 'MIN'  THEN division( av~arbei,60,2 ) ELSE av~arbei END AS hrs_prog,
         avc~vornr, j~stat, j~inact, avc~objnr

  FROM aufk AS au
  INNER JOIN afko AS af ON af~aufnr = au~aufnr
  INNER JOIN afvc AS avc ON avc~aufpl = af~aufpl
  INNER JOIN afvv AS av ON av~aufpl = af~aufpl AND av~aplzl = avc~aplzl
  INNER JOIN jest AS j ON j~objnr = avc~objnr
  WHERE auart = 'PM22'
  AND au~loekz IS INITIAL
  AND af~aufnr IN @so_aufnr
  AND au~sowrk EQ @p_sowrk
  "AND af~gstrs BETWEEN @lv_feini AND @lv_fefin
  AND af~gstrs BETWEEN @lv_feini AND @lv_fefin
  INTO TABLE @DATA(it_datos).


  "se obtienen las semanas de la consulta de limitadap por planeación en el año
  SORT it_datos BY gstrs ASCENDING. "se ordena por inicio programado para obtener
  "inicio de mtto.

  IF it_Datos IS NOT INITIAL.
    DELETE it_Datos WHERE gltrs GT lv_fefin.
  ELSE.
    MESSAGE 'No hay datos para presentar...' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  READ TABLE it_datos INTO DATA(wa_min) INDEX 1.
  lv_femin = wa_min-gstrs. "fecha inicial programado primer orden

  "se obtienen las semanas de la consulta de limitadap por planeación en el año
  SORT it_datos BY gltrs DESCENDING. "se ordena por FIN programado para obtener
  "fin de mtto.


  READ TABLE it_datos INTO DATA(wa_max) INDEX 1.
  lv_femax = wa_max-gltrs.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  CALL FUNCTION 'GET_NUMBER_WEEKS'
    EXPORTING
      p_fecha  = lv_femax
    IMPORTING
      num_week = lv_sem.
  .
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "lv_sem = abs( lv_femax - lv_femin ) / 7.

  st_header_mtto-semanas_mtto = lv_sem.
  st_header_mtto-fecha_elabora = lv_femin.
  CLEAR: wa_min, wa_max.

  DATA(set_semanas) = it_datos[].

  SORT set_semanas BY gstrs ASCENDING. "fecha inicial programado
  DELETE ADJACENT DUPLICATES FROM set_semanas COMPARING gstrs.
  CLEAR lv_sem.
  lv_flag = abap_false.
  LOOP AT set_semanas INTO DATA(wa_setsemanas).
    CLEAR wa_semanas.
    IF lv_flag EQ abap_false.
      lv_fecha = wa_setsemanas-gstrs.
      lv_flag = abap_true.
    ELSE.
      lv_fecha = lv_fecha + 1.
    ENDIF.

    wa_semanas-feini = lv_fecha.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    lv_fecha = lv_fecha + 6.
    wa_semanas-fefin = lv_fecha.


    lv_sem = lv_sem + 1.
    wa_semanas-nsem = lv_sem.
    APPEND wa_semanas TO it_semanas.
  ENDLOOP.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  CLEAR wa_semanas.
  READ TABLE it_semanas INTO wa_semanas WITH KEY nsem = p_numsem.

  IF sy-subrc EQ 0.
    st_header_mtto-inicio_sem = wa_semanas-feini.
    st_header_mtto-corte_sem = wa_semanas-fefin.
  ENDIF.

  DATA(it_datos_consul) = it_datos[].
*
  SORT it_datos_consul BY gltrs ASCENDING. "se ordena por fin programado
  DELETE it_datos_consul WHERE gltrs GT st_header_mtto-corte_sem. "se dejan unicamente los registros
  ""calculando las semanas transcurridas

  lv_sem = ceil( ( ( st_header_mtto-corte_sem - lv_femin ) + 1 ) / '7.00' ).

  st_header_mtto-semanas_trans = lv_sem."lv_sem.


  st_header_mtto-semanas_holgura = st_header_mtto-semanas_mtto - st_header_mtto-semanas_trans.
  st_header_mtto-version_plan = '1'.
  st_header_mtto-emision_reporte = sy-datum.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""Recorremos para validar status por ódenes
  DELETE it_datos WHERE stat = 'I0013'.
  DELETE it_datos WHERE inact = 'X'.

  """"""""obteniendo solo los números de órdenes.
  DATA(it_aufnr) = it_datos[].

  SORT it_aufnr BY aufnr.
  DELETE ADJACENT DUPLICATES FROM it_aufnr COMPARING aufnr.

wrg_stat-low = 'I0009'.
wrg_stat-sign = 'I'.
wrg_stat-option = 'EQ'.
appeND wrg_stat to rg_stat.

wrg_stat-low = 'I0010'.
wrg_stat-sign = 'I'.
wrg_stat-option = 'EQ'.
appeND wrg_stat to rg_stat.

wrg_stat-low = 'I0002'.
wrg_stat-sign = 'I'.
wrg_stat-option = 'EQ'.
appeND wrg_stat to rg_stat.

wrg_stat-low = 'I0001'.
wrg_stat-sign = 'I'.
wrg_stat-option = 'EQ'.
appeND wrg_stat to rg_stat.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
delete it_datos where stat not in rg_stat.

sort it_datos bY aufnr objnr stat.

delete adJACENT DUPLICATES FROM it_datos cOMPARING aufnr objnr.
"""""""""""""""""""""""""""03-12-2025
*  LOOP AT it_aufnr INTO DATA(wa_aufnr).
*
*
*    READ TABLE it_datos  WITH KEY aufnr = wa_aufnr-aufnr stat = 'I0009'  TRANSPORTING NO FIELDS ."si tiene notificacion final
*    IF sy-subrc NE 0.
*      READ TABLE it_datos  WITH KEY aufnr = wa_aufnr-aufnr stat = 'I0010'  TRANSPORTING NO FIELDS . "noti. parcial
*      IF sy-subrc NE 0.
*        READ TABLE it_datos  WITH KEY aufnr = wa_aufnr-aufnr stat = 'I0002'  TRANSPORTING NO FIELDS .
*        IF sy-subrc NE 0.
*          DELETE it_datos WHERE aufnr = wa_aufnr-aufnr AND stat NE 'I0001'.
*        ELSE.
*          DELETE it_datos WHERE aufnr = wa_aufnr-aufnr AND stat NE 'I0002'.
*        ENDIF.
*      ELSE.
*        DELETE it_datos WHERE aufnr = wa_aufnr-aufnr AND stat NE 'I0010'.
*      ENDIF.
*    ELSE.
*      DELETE it_datos WHERE aufnr = wa_aufnr-aufnr AND stat NE 'I0009'.
*    ENDIF.
*
*
*
*  ENDLOOP.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


*  SORT it_datos BY kostl aufnr aufpl vornr stat.
*
*  DELETE ADJACENT DUPLICATES FROM it_datos COMPARING kostl aufnr aufpl vornr stat.

  SORT it_datos BY kostl.

  LOOP AT it_datos INTO DATA(wa_datos) .
    CLEAR wa_acum_kostl.
    wa_acum_kostl-kostl = wa_Datos-kostl.
    wa_acum_kostl-arbei = wa_Datos-hrs_prog."wa_datos-arbei.
    wa_acum_kostl-ismnw = WA_datos-ismnw.
    wa_acum_kostl-ofmnw = wa_Datos-ofmnw.
    COLLECT wa_acum_kostl INTO it_acum_kostl.
  ENDLOOP.

  DATA(acum_consul) = it_acum_kostl[].
  REFRESH acum_consul.

  SORT it_datos_consul BY kostl.

  CLEAR wa_semanas.
  READ TABLE it_semanas INTO wa_semanas WITH KEY nsem = p_numsem.
  IF  sy-subrc EQ 0.
    READ TABLE it_semanas INTO DATA(wa_sem_1) WITH KEY nsem = 1.

    LOOP AT it_datos INTO DATA(wa_acum_datos) WHERE gstrs BETWEEN wa_sem_1-feini AND wa_semanas-fefin.
      CLEAR wa_acum_kostl.
      wa_acum_kostl-kostl = wa_acum_datos-kostl.
      wa_acum_kostl-arbei = wa_acum_datos-hrs_prog.
      wa_acum_kostl-ismnw = wa_acum_datos-ismnw.
      wa_acum_kostl-ofmnw = wa_Datos-ofmnw.
      COLLECT wa_acum_kostl INTO acum_consul.
    ENDLOOP.

  ENDIF.



  DATA(aux_jerarquia) = it_jerarquia.

  SORT aux_jerarquia BY header1 header2.
  DELETE ADJACENT DUPLICATES FROM aux_jerarquia COMPARING header1 header2.

  LOOP AT aux_jerarquia INTO DATA(waux).
    APPEND INITIAL LINE TO it_outtable ASSIGNING <fs_struct>.
    <fs_struct>-header = waux-header1.
    <fs_struct>-kostl = waux-header2.
    UNASSIGN <fs_struct>.

    LOOP AT it_jerarquia INTO wa_jerarquia WHERE header1 EQ waux-header1 AND header2 = waux-header2.
      APPEND INITIAL LINE TO it_outtable ASSIGNING <fs_struct>.
      <fs_struct>-kostl = wa_jerarquia-kostl.
      <fs_struct>-ltext = wa_jerarquia-ltext.
      <fs_struct>-porc_ava_total = 0.
      READ TABLE it_acum_kostl INTO wa_acum_kostl WITH KEY kostl = wa_jerarquia-kostl.
      IF sy-subrc EQ 0.
        CLEAR: vl_arbei, vl_ismnw.
        vl_arbei = wa_acum_kostl-arbei.
*        vl_ismnw = wa_acum_kostl-ismnw. "tiempo real
        CONDENSE vl_arbei NO-GAPS.
        CONDENSE vl_ismnw NO-GAPS.
        <fs_struct>-plan_total = vl_arbei.
        vl_total_plan_t = vl_total_plan_t + vl_arbei.
      ENDIF.

      CLEAR wa_acum_kostl.
      READ TABLE acum_consul INTO wa_acum_kostl WITH KEY kostl = wa_jerarquia-kostl.
      IF sy-subrc EQ 0.
        CLEAR: vl_arbei, vl_ismnw.
        vl_arbei = wa_acum_kostl-arbei.
        vl_ismnw = wa_acum_kostl-ismnw. "tiempo real
        CONDENSE vl_arbei NO-GAPS.
        CONDENSE vl_ismnw NO-GAPS.
        IF vl_arbei IS INITIAL.
          vl_arbei = '0.0'.
        ENDIF.

        <fs_struct>-plan_acum = vl_arbei.
        <fs_struct>-real_acum = vl_ismnw.
        vl_total_plan_a = vl_total_plan_a + vl_arbei.
        vl_total_real_a = vl_total_real_a + vl_ismnw.
      ELSE.

        vl_arbei = '0.0'.
        vl_ismnw = '0.0'.
        <fs_struct>-plan_acum = vl_arbei.
        <fs_struct>-real_acum = vl_ismnw.
      ENDIF.

      "calculos
      vl_opera1 = <fs_struct>-plan_acum.
      vl_opera2 = <fs_struct>-real_acum.

      <fs_struct>-dife_acum = vl_opera1 - vl_opera2. "<fs_struct>-plan_acum - <fs_struct>-real_acum.
      CONDENSE <fs_struct>-dife_acum NO-GAPS.
      "IF <fs_struct>-dife_acum > 0 or .
      <fs_struct>-porc_avance = ( vl_opera2 / vl_opera1 ) * 100. "( <fs_struct>-real_acum / <fs_struct>-plan_acum ) * 100.
      CONDENSE <fs_struct>-porc_avance NO-GAPS.
      "ELSE.

*        IF wa_acum_kostl-ofmnw GT 0.
*          <fs_struct>-porc_avance = ( vl_opera2 / wa_acum_kostl-ofmnw ) * 100. "( <fs_struct>-real_acum / wa_acum_kostl-ofmnw ) * 100.
*          CONDENSE <fs_struct>-porc_avance NO-GAPS.
*        ELSE.
*          <fs_struct>-porc_avance = 0.
*          CONDENSE <fs_struct>-porc_avance NO-GAPS.
*        ENDIF.

      "ENDIF.

      IF <fs_struct>-dife_acum GT 0.
        <fs_struct>-porc_atraso = 100 - <fs_struct>-porc_avance.
        CONDENSE <fs_struct>-porc_atraso NO-GAPS.
      ELSE.
        <fs_struct>-porc_atraso = 0.
        CONDENSE <fs_struct>-porc_atraso NO-GAPS.
      ENDIF.

      IF <fs_struct>-porc_atraso LE 5.
        <fs_struct>-semaforo = 'SIN RIESGO'.
      ELSEIF <fs_struct>-porc_atraso GT 5 AND <fs_struct>-porc_atraso LE 10.
        <fs_struct>-semaforo = 'RIESGO MENOR'.
      ELSEIF <fs_struct>-porc_atraso GT 10.
        <fs_struct>-semaforo = 'RIESGO MAYOR'.
      ENDIF.
      CONDENSE <fs_struct>-semaforo.

      "IF <fs_struct>-porc_atraso GT 0.
      <fs_struct>-porc_ava_total = <fs_struct>-real_acum / <fs_struct>-plan_total * 100.
      "ELSE.
      " <fs_struct>-porc_ava_total = 0.
      "ENDIF.
      CONDENSE <fs_struct>-porc_ava_total NO-GAPS.

      <fs_struct>-trabajo_realzar = <fs_struct>-plan_total - <fs_struct>-real_acum.
      CONDENSE <fs_struct>-trabajo_realzar NO-GAPS.
      IF <fs_struct>-trabajo_realzar GT 0.
        <fs_struct>-porc_x_ejercer = 100 - <fs_struct>-porc_ava_total.
      ELSE.
        <fs_struct>-porc_x_ejercer = 0.
      ENDIF.
      CONDENSE <fs_struct>-porc_x_ejercer NO-GAPS.


    ENDLOOP.
  ENDLOOP.

  APPEND INITIAL LINE TO it_outtable ASSIGNING <fs_struct>.
  <fs_struct>-kostl = 'AVANCE TOTAL'.
  <fs_struct>-plan_total = vl_total_plan_t.
  CONDENSE <fs_struct>-plan_total NO-GAPS.
  <fs_struct>-plan_acum = vl_total_plan_a.
  CONDENSE <fs_struct>-plan_acum NO-GAPS.
  <fs_struct>-real_acum = vl_total_real_a.
  CONDENSE <fs_struct>-real_acum NO-GAPS.

  <fs_struct>-dife_acum = vl_total_plan_a - vl_total_real_a.
  CONDENSE <fs_struct>-dife_acum NO-GAPS.
  <fs_struct>-porc_avance = ( vl_total_real_a / vl_total_plan_a ) * 100.
  CONDENSE <fs_struct>-porc_avance NO-GAPS.
  <fs_struct>-porc_atraso = 100 - ( ( vl_total_real_a / vl_total_plan_a ) * 100 ).
  CONDENSE <fs_struct>-porc_atraso NO-GAPS.

  IF <fs_struct>-porc_atraso LE 5.
    <fs_struct>-semaforo = 'SIN RIESGO'.
  ELSEIF <fs_struct>-porc_atraso GT 5 AND <fs_struct>-porc_atraso LE 10.
    <fs_struct>-semaforo = 'RIESGO MENOR'.
  ELSEIF <fs_struct>-porc_atraso GT 10.
    <fs_struct>-semaforo = 'RIESGO MAYOR'.
  ENDIF.
  CONDENSE <fs_struct>-semaforo.

  <fs_struct>-porc_ava_total = ( vl_total_real_a / vl_total_plan_t ) * 100.
  CONDENSE <fs_struct>-porc_ava_total NO-GAPS.

  <fs_struct>-porc_x_ejercer = 100 - ( ( vl_total_real_a / vl_total_plan_t ) * 100 ).
  CONDENSE <fs_struct>-porc_x_ejercer NO-GAPS.

  <fs_struct>-trabajo_realzar = vl_total_plan_t - vl_total_real_a.
  CONDENSE <fs_struct>-trabajo_realzar NO-GAPS.
ENDFORM.



FORM show_form.

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = cp_outparam.

  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = 'ZFORM_MTTO_MAYOR1' " Pass the FORM name and
    IMPORTING " it will give the fundtion odule name
      e_funcname = ip_funcname.

  CALL FUNCTION ip_funcname
    EXPORTING
*     /1BCDWB/DOCPARAMS        =
      P_it_datos     = it_outtable
      p_st_header    = st_header_mtto
* IMPORTING
*     /1BCDWB/FORMOUTPUT       =
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.

  CALL FUNCTION 'FP_JOB_CLOSE'
* IMPORTING
*   E_RESULT             =
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.



ENDFORM.
