*&---------------------------------------------------------------------*
*& Include          ZCO_COSTOS_EQUIV_CIERRE_FUN
*&---------------------------------------------------------------------*

FORM copy_makg.

  DATA wa_makg LIKE LINE OF it_makg.

  SELECT  matnr, werks, csplit, sczuo, crule
    INTO TABLE @DATA(it_makg_aux)
    FROM makg
    WHERE werks = 'PP01'.

  SELECT SINGLE poper, gjahr
    INTO @DATA(existe)
  FROM zmakg
    WHERE poper = @p_poper AND gjahr = @p_gjahr
    AND reverse ne 'X'.

  IF sy-subrc ne 0.
    LOOP AT it_makg_aux INTO DATA(wa).
      MOVE-CORRESPONDING wa TO wa_makg.

      wa_makg-uname = sy-uname.
      wa_makg-poper = p_poper.
      wa_makg-gjahr = p_gjahr.
      APPEND wa_makg TO it_makg.
    ENDLOOP.
    INSERT zmakg FROM TABLE it_makg.
    vg_seguir = 0.
  ELSE.
    MESSAGE 'Ya se ejecuto este programa para este periodo' TYPE 'S' DISPLAY LIKE 'E'.
    vg_seguir = 4.
  ENDIF.


ENDFORM.

FORM copy_makz.

  DATA wa_makz LIKE LINE OF it_makz.

  SELECT matnr, werks, csplit, sczuo, kuppl,
        bwart, datub, ziffr, bmeng, bmein
  INTO TABLE @DATA(it_makz_aux)
  FROM makz
  WHERE werks = 'PP01'.

  SELECT SINGLE poper, gjahr
    INTO @DATA(existe)
  FROM zmakz
    WHERE poper = @p_poper AND gjahr = @p_gjahr
  AND reverse NE 'X'.

  IF sy-subrc ne 0.

    LOOP AT it_makz_aux INTO DATA(wa).
      MOVE-CORRESPONDING wa TO wa_makz.

      wa_makz-uname = sy-uname.
      wa_makz-poper = p_poper.
      wa_makz-gjahr = p_gjahr.
      APPEND wa_makz TO it_makz.
    ENDLOOP.


    INSERT zmakz FROM TABLE it_makz.
    vg_seguir = 0.
  ELSE.
    MESSAGE 'Ya se ejecuto este programa para este periodo' TYPE 'S' DISPLAY LIKE 'E'.
vg_seguir = 4.
  ENDIF.



ENDFORM.

FORM get_ordenes.

  DATA: lv_rgfechas TYPE RANGE OF mseg-budat_mkpf.
  DATA: min        TYPE mseg-budat_mkpf,
        max        TYPE mseg-budat_mkpf,
        vl_gjahr   TYPE gjahr,
        it_status  TYPE STANDARD TABLE OF jstat,
        ord_valida TYPE aufnr.




  PERFORM calculate_dates
    CHANGING
      lv_rgfechas.
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


  SELECT DISTINCT a~aufnr, a~gstri, a~getri,a~gltri,a~ftrmi, p~dauat, p~pwerk, p~dwerk,c~objnr,p~ablad, a~plnbez
   FROM afko AS a
  INNER JOIN afpo AS p ON p~aufnr = a~aufnr
  INNER JOIN caufv AS c ON c~aufnr EQ a~aufnr
 WHERE ( a~getri IN @lv_rgfechas OR a~gltri IN @lv_rgfechas )
 AND dwerk = 'PP01'
 INTO TABLE @it_aufnr_end.

  IF it_aufnr_end IS NOT INITIAL.
    LOOP AT it_aufnr_end INTO DATA(wa_aufnr).
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
        READ TABLE it_status INTO DATA(wa_cerre) WITH KEY stat = 'I0046'. "CERR Excl.
        IF sy-subrc EQ 0.
          ord_valida = wa_aufnr-aufnr.
        ELSE.
          CLEAR ord_valida.
        ENDIF.

*
        IF ord_valida IS INITIAL.
          DELETE it_aufnr_end WHERE aufnr = wa_aufnr-aufnr.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  SORT it_aufnr_end BY aufnr DESCENDING.
  DELETE ADJACENT DUPLICATES FROM it_aufnr_end COMPARING aufnr.

ENDFORM.

FORM calculate_dates CHANGING p_rgfechas.
  "calculo de fechas "

  DATA: cadena      TYPE string,
        vl_fechaI   TYPE d,
        vl_fechaF   TYPE d,
        num_days    TYPE i,
        vl_poper(2) TYPE c,
        vl_gjahr    TYPE gjahr.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        wa_rgfechas LIKE LINE OF rg_fechas.

  vl_gjahr = p_gjahr.


  SELECT poper FROM t009b
    INTO TABLE @DATA(it_009b)
    WHERE poper = @p_poper
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

    PERFORM get_daysmonth
            USING vl_fechaI
            CHANGING num_days.


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

ENDFORM.
FORM  get_daysMonth USING p_date TYPE d
                  CHANGING p_numDays. "cálculo de dias en el mes "

  DATA: xdatum TYPE d.

  xdatum = p_date.
  xdatum+6(2) = '01'.
  xdatum = xdatum + 35.          "para llegar seguro al proximo mes
  xdatum+6(2) = '01'. xdatum = xdatum - 1.
  p_numDays = xdatum+6(2).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mseg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mseg .

  DATA: rg_aufnr   TYPE RANGE OF afko-aufnr,
        wa_rgaufnr LIKE LINE OF rg_aufnr.





  IF it_aufnr_end IS NOT INITIAL.

    LOOP AT it_aufnr_end INTO DATA(wa_aufnr).
      wa_rgaufnr-option = 'EQ'.
      wa_rgaufnr-sign = 'I'.
      wa_rgaufnr-low = wa_aufnr-aufnr.
      APPEND wa_rgaufnr TO rg_aufnr.
    ENDLOOP.


    SELECT mseg~aufnr, plnbez ,mseg~matnr,
      SUM( CASE WHEN bwart EQ '102' THEN menge * -1 ELSE menge END )  AS menge
      INTO TABLE @it_mseg
      FROM mseg
      INNER JOIN afko AS a ON a~aufnr = mseg~aufnr
      WHERE a~aufnr IN @rg_aufnr
      AND bwart IN ('101','102')
      GROUP BY mseg~aufnr, plnbez, mseg~matnr
      .

    DELETE it_mseg WHERE menge EQ 0.




  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_matnr_precio
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_matnr_precio .

  DATA: rg_matnr TYPE RANGE OF marc-matnr,
        wa_matnr LIKE LINE OF rg_matnr.


  SELECT matnr
    INTO TABLE @DATA(it_marc)
   FROM marc
  WHERE werks EQ 'PP01'
    AND fxpru = 'X'.

  IF it_marc IS NOT INITIAL.

    LOOP AT it_marc INTO DATA(wa_marc).
      wa_matnr-option = 'EQ'.
      wa_matnr-sign = 'I'.
      wa_matnr-low = wa_marc-matnr.
      APPEND wa_matnr TO rg_matnr.
    ENDLOOP.

    DELETE it_mseg WHERE matnr IN rg_matnr.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_zmakz
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_zmakz .

  DATA: vl_supertotal TYPE menge_d,
        vl_subtotal   TYPE menge_d,
        vl_cant_prod  TYPE menge_d,
        vl_plnbez     TYPE matnr,
        vl_matnr      TYPE matnr,
        vl_ZIFFR      TYPE aequi.

  DATA wa_acum LIKE LINE OF it_mseg_acum.
  SORT it_mseg BY plnbez matnr.

  LOOP AT it_mseg INTO DATA(wa).
    MOVE-CORRESPONDING wa TO wa_acum.
    APPEND wa_acum TO it_mseg_acum.
  ENDLOOP.

  it_mseg_final = it_mseg_acum.

  DELETE ADJACENT DUPLICATES FROM it_mseg_final COMPARING plnbez matnr.

  LOOP AT it_mseg_acum INTO DATA(wa_mseg)."1

    vl_subtotal = vl_subtotal + wa_mseg-menge.

    AT END OF matnr.

      vl_plnbez = wa_mseg-plnbez.
      vl_matnr = wa_mseg-matnr.

      READ TABLE it_mseg_final ASSIGNING FIELD-SYMBOL(<fs_str>) WITH KEY plnbez = wa_mseg-plnbez matnr = wa_mseg-matnr.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT 'SUBTOTAL' OF STRUCTURE <fs_str> TO FIELD-SYMBOL(<linea>).
        <linea> = vl_subtotal.
      ENDIF.
      CLEAR vl_subtotal.
    ENDAT.

  ENDLOOP."1


  LOOP AT it_mseg_final INTO wa_mseg."1

    vl_supertotal = vl_supertotal + wa_mseg-subtotal.

    AT END OF plnbez.
      LOOP AT it_mseg_final ASSIGNING <fs_str> WHERE plnbez = wa_mseg-plnbez.

        ASSIGN COMPONENT 'SUPER_TOTAL' OF STRUCTURE <fs_str> TO <linea>.
        <linea> = vl_supertotal.
      ENDLOOP.
      CLEAR vl_supertotal.
    ENDAT.

  ENDLOOP."1
  """""""""""""""""""""""""""""""""
  CLEAR: vl_subtotal, vl_supertotal, vl_ziffr.
  LOOP AT it_mseg_final ASSIGNING <fs_str>."1
    ASSIGN COMPONENT 'SUBTOTAL' OF STRUCTURE <fs_str>  TO <linea>.
    vl_subtotal = <linea>.

    ASSIGN COMPONENT 'SUPER_TOTAL' OF STRUCTURE <fs_str>  TO <linea>.
    vl_supertotal = <linea>.

    vl_ziffr = vl_subtotal / vl_supertotal * 100.
    ASSIGN COMPONENT 'ZIFFR' OF STRUCTURE <fs_str>  TO <linea>.
    <linea> = vl_ziffr.

    CLEAR: vl_subtotal, vl_supertotal, vl_ziffr.
  ENDLOOP."1

  DELETE it_mseg_final WHERE ziffr = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calc_dif
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM calc_dif .
  FIELD-SYMBOLS: <fs_str> TYPE any,
                 <linea>  TYPE any.

  DATA: vl_supertotal TYPE menge_d,
        vl_subtotal   TYPE menge_d.

  DATA: vl_ziffr TYPE aequi, aux TYPE aequi.

  LOOP AT it_mseg_final INTO DATA(wa_mseg)."1

    vl_ziffr = vl_ziffr + wa_mseg-ziffr.

    AT END OF plnbez.
      LOOP AT it_mseg_final ASSIGNING <fs_str> WHERE plnbez = wa_mseg-plnbez.

        ASSIGN COMPONENT 'TOTAL' OF STRUCTURE <fs_str> TO <linea>.
        <linea> = vl_ziffr.
      ENDLOOP.
      CLEAR vl_ziffr.
    ENDAT.

  ENDLOOP."1



  CLEAR vl_ziffr.
  DATA(it_plnbez) = it_mseg_final[].

  DELETE ADJACENT DUPLICATES FROM it_plnbez COMPARING plnbez.
  DELETE it_plnbez WHERE total = 100.

  LOOP AT it_plnbez INTO DATA(wa_plnbez).
    CLEAR vl_ziffr.
    CLEAR aux.
    LOOP AT it_mseg_final INTO DATA(wa_ziffr) WHERE total NE 100 AND plnbez = wa_plnbez-plnbez.
      aux = wa_ziffr-ziffr.

      IF aux > vl_ziffr.
        vl_ziffr = aux.
      ENDIF.
    ENDLOOP.

    READ TABLE it_mseg_final ASSIGNING <fs_str> WITH KEY ziffr = vl_ziffr plnbez = wa_plnbez-plnbez.
    ASSIGN COMPONENT 'TOTAL' OF STRUCTURE <fs_str> TO <linea>.
    aux = <linea>.
    IF aux GT 100.
      ASSIGN COMPONENT 'ZIFFR' OF STRUCTURE <fs_str> TO <linea>.
      <linea> = <linea> - ( aux - 100 ).
    ELSEIF aux LT 100..
      ASSIGN COMPONENT 'ZIFFR' OF STRUCTURE <fs_str> TO <linea>.
      <linea> = <linea> + ( 100 - aux ).
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form armado_makz_final
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM armado_makz_final .
  DATA wa_makz_final LIKE LINE OF it_makz_final.

  DATA vl_sczuo TYPE co_sczuo.
  DATA(it_plnbez) = it_mseg_final[].
  DATA vl_contador TYPE i.


  DELETE ADJACENT DUPLICATES FROM it_plnbez COMPARING plnbez.




  LOOP AT it_plnbez INTO DATA(wa_plnbez).
    vl_sczuo = '010'.

    DO 4 TIMES.
      LOOP AT it_mseg_final INTO DATA(wa_mseg) WHERE plnbez = wa_plnbez-plnbez.
        MOVE-CORRESPONDING wa_mseg TO wa_makz_final.
        wa_makz_final-sczuo = vl_sczuo.
        wa_makz_final-matnr = wa_mseg-plnbez.
        wa_makz_final-csplit = '01'.
        wa_makz_final-werks = 'PP01'.
        wa_makz_final-datub = '99991231'.
        wa_makz_final-kuppl = wa_mseg-matnr.
        wa_makz_final-ziffr = wa_mseg-ziffr.
        APPEND wa_makz_final TO it_makz_final.

      ENDLOOP.
      vl_sczuo = vl_sczuo + 10.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = vl_sczuo
        IMPORTING
          output = vl_sczuo.

    ENDDO.
  ENDLOOP.

  "ACTUALIZA MAKZ NUEVAS CIFRAS MATERIALES EFECTIVAMENTE PRODUCIDOS
  DELETE FROM makz WHERE werks = 'PP01'.
  INSERT makz FROM TABLE it_makz_final.
  """""""""""""""""""""""""""""""""""""""""""""""
  "ACTUALIZAMOS MAKG CON 2 EN CRULE

  UPDATE makg SET crule = '2' WHERE werks = 'PP01'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form valida_makz
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM valida_makz CHANGING p_seguir type sy-subrc.

  DATA vl_answer.

  SELECT SINGLE poper, gjahr
    INTO @DATA(existe)
  FROM zmakz
    WHERE poper = @p_poper AND gjahr = @p_gjahr
  AND reverse NE 'X'.
  p_seguir = sy-subrc.
  IF sy-subrc EQ 0.


    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = 'Restaurar MAKG MAKZ'
*       DIAGNOSE_OBJECT             = ' '
        text_question  = 'Se encontró Modificación de Tablas.¿Desea Reversar?'
        text_button_1  = 'SI'
*       ICON_BUTTON_1  = ' '
        text_button_2  = 'NO'
*       ICON_BUTTON_2  = ' '
        default_button = '2'
       IMPORTING
        answer         = vl_answer
       EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.

    IF vl_answer EQ '1'.
      PERFORM reversal_tables.
    ENDIF.
ENDIF.
ENDFORM.

FORM reversal_tables.
refresh it_makz_final.

  SELECT mandt, matnr, werks,csplit,sczuo,kuppl,bwart,datub,ziffr
        ,bmeng,bmein
  into table @it_makz_final
  from zmakz
 where poper = @p_poper and gjahr = @p_gjahr.

  "ACTUALIZA MAKZ NUEVAS CIFRAS MATERIALES EFECTIVAMENTE PRODUCIDOS
  DELETE FROM makz WHERE werks = 'PP01'.
  INSERT makz FROM TABLE it_makz_final.
  """""""""""""""""""""""""""""""""""""""""""""""
  "ACTUALIZAMOS MAKG

    SELECT mandt, matnr, werks, csplit, sczuo, crule
  into table @it_makg_final
  from zmakg
 where poper = @p_poper and gjahr = @p_gjahr.

   DELETE FROM makg WHERE werks = 'PP01'.
  INSERT makg FROM TABLE it_makg_final.

  update zmakg set reverse = 'X' where poper = p_poper and gjahr = p_gjahr.
  update zmakz set reverse = 'X' where poper = p_poper and gjahr = p_gjahr.


ENDFORM.
