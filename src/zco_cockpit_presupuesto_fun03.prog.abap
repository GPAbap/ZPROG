*----------------------------------------------------------------------*
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_FUN03 .
* 07032023
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_PRESMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_presmat USING p_tipo TYPE char20 .
  REFRESH: it_cecos, it_cecos_indice.
  FIELD-SYMBOLS: <ls_wa> TYPE any,
                 <linea> TYPE any.

  TYPES: BEGIN OF st_t001w,
           werks TYPE werks_d,
           name1 TYPE name1,
         END OF st_t001w,

         BEGIN OF st_t023t,
           matkl TYPE matkl,
           wgbez TYPE wgbez,
         END OF st_t023t.

  DATA: rg_tipo TYPE RANGE OF zco_tt_planpres-tipo,
        wg_tipo LIKE LINE OF rg_tipo.

  DATA: rg_kstar TYPE RANGE OF zco_tt_planpres-kstar,
        wg_kstar LIKE LINE OF rg_kstar.

  DATA: it_t001w     TYPE STANDARD TABLE OF st_t001w,
        wa_t001w     LIKE LINE OF it_t001w,
        it_t023t     TYPE STANDARD TABLE OF st_t023t,
        wa_t023t     LIKE LINE OF it_t023t,
        wa_acumulado LIKE LINE OF it_matpres,
        lv_matnr     TYPE matnr,
        lv_werks     TYPE werks_d,
        lv_tipo      TYPE char20.

  DATA: lv_kokrs  TYPE kokrs,
        lv_gjahr  TYPE gjahr,
        lv_ptipo  TYPE char20,
        lv_pmonat TYPE monat.

  DATA: it_collect TYPE TABLE OF st_matpres,
        wa_collect LIKE LINE OF it_collect.

* Se quita la validación de CeCos autorizados
* 11/08/2022
* Jaime Hernandez Velasquez
  "se validan los CeCos autorizados por Usuario Logeado
*  SELECT   z1~kostl z2~idpres
*  INTO CORRESPONDING FIELDS OF TABLE it_cecos_indice
*  FROM zco_tt_cecoaut AS z1
*  INNER JOIN  zco_tt_planpres AS z2 ON z1~kokrs EQ z2~kokrs AND z1~kostl EQ z2~kostl
*  WHERE z1~bname = sy-uname
*  AND z2~kokrs EQ p__kokrs
*  AND z2~matnr NE space.
*
*  wa_cecos_indice-mandt = sy-mandt.
*  MODIFY it_cecos_indice FROM wa_cecos_indice TRANSPORTING mandt WHERE mandt EQ ''.
*
*  SORT it_cecos_indice BY kostl idpres DESCENDING.
*  DELETE ADJACENT DUPLICATES FROM it_cecos_indice COMPARING kostl idpres.
*
*
*  DELETE FROM zcecos_tt_indice.
*  INSERT zcecos_tt_indice CLIENT SPECIFIED FROM TABLE it_cecos_indice.
*--------------
  IF p_tipo EQ 'MATERIALES'.
    wg_tipo-sign = 'I'.
    wg_tipo-option = 'EQ'.
    wg_tipo-low = 'MATERIAL'.
    APPEND wg_tipo TO  rg_tipo.
  ELSE.
    IF ptipo IS INITIAL.
      wg_tipo-sign = 'I'.
      wg_tipo-option = 'EQ'.
      wg_tipo-low = 'CUENTA'.
      APPEND wg_tipo TO  rg_tipo.

      wg_tipo-sign = 'I'.
      wg_tipo-option = 'EQ'.
      wg_tipo-low = 'SERVICIO'.
      APPEND wg_tipo TO  rg_tipo.
    ELSE.
      wg_tipo-sign = 'I'.
      wg_tipo-option = 'EQ'.
      wg_tipo-low = ptipo.
      APPEND wg_tipo TO  rg_tipo.

    ENDIF.
    "clases de coste
    LOOP AT skstar.
      wg_kstar-sign = 'I'.
      wg_kstar-option = 'EQ'.
      wg_kstar-low = skstar-low.
      APPEND wg_kstar TO  rg_kstar.
    ENDLOOP.

  ENDIF.

  IF p_tipo NE 'MATERIALES'.
    lv_kokrs = pkokrs.
    lv_gjahr = pgjahr.
    lv_ptipo  = ptipo.

  ELSE.
    lv_gjahr = p__gjahr.
    lv_kokrs = p__kokrs.
  ENDIF.

*PARAMETERS: pgjahr TYPE gjahr DEFAULT '2022' OBLIGATORY,
*            pkokrs TYPE kokrs DEFAULT 'SA00' OBLIGATORY,
*            ptipo TYPE char20 DEFAULT 'CUENTA'.

  "obtenemos los centros utilizados
  SELECT t~werks t~name1
  INTO TABLE it_t001w
  FROM t001w AS t
  INNER JOIN zco_tt_planpres AS z
  ON z~werks EQ t~werks
  WHERE z~tipo IN rg_tipo
  AND z~tipmod EQ 'F'
  AND z~gjahr EQ lv_gjahr
  AND kokrs EQ lv_kokrs
  .
  SORT it_t001w BY werks name1 ASCENDING.
  DELETE ADJACENT DUPLICATES FROM it_t001w COMPARING werks name1.
  "---------------------------------
  "obtenemos los textos de los grupos de articulos
  SELECT t~matkl t~wgbez
  INTO TABLE it_t023t
  FROM t023t AS t
  INNER JOIN zco_tt_planpres AS z
  ON z~matkl EQ t~matkl
  WHERE z~tipo IN rg_tipo
  AND z~tipmod EQ 'F'
  AND z~gjahr EQ lv_gjahr
  AND z~kokrs EQ lv_kokrs
  AND t~spras EQ 'S'  .

  SORT it_t023t BY matkl wgbez ASCENDING.
  DELETE ADJACENT DUPLICATES FROM it_t023t COMPARING matkl wgbez.
  "---------------------------------------

  SELECT idpres, prespos, gjahr, kokrs, bukrs, z~kostl, kstar, preunipres, werks,
  CASE WHEN matnr IS INITIAL THEN
       CASE WHEN servno IS INITIAL THEN cuenta ELSE servno END ELSE matnr END AS matnr, cuenta,
  co_meinh, maktx,
  matkl,  meg001, meg002, meg003, meg004, meg005, meg006, meg007, meg008,
  meg009, meg010, meg011, meg012, megtot,
  wtg001, wtg002, wtg003, wtg004, wtg005, wtg006, wtg007, wtg008,
  wtg009, wtg010, wtg011, wtg012, wtgtot,
  wog001, wog002, wog003, wog004, wog005, wog006, wog007, wog008,
  wog009, wog010, wog011, wog012, wogtot

  FROM zco_tt_planpres AS z
  "    INNER JOIN  zcecos_tt_indice AS @i ON i~idpres = z~idpres
  "    AND i~kostl = z~kost@l
  WHERE "idpres = it_cecos_indice-idpres
  gjahr EQ @lv_gjahr
  AND kokrs EQ @lv_kokrs
  AND bukrs IN @s_bukrs
  AND kostl IN @s__kostl
  AND werks IN @s__werks
  AND matkl IN @s__matkl
  AND matnr IN @s__matnr "rango materiales
  AND tipmod = 'F'
  AND cecoaut = 'X'
  AND tipo IN @rg_tipo
  AND kstar IN @rg_kstar
  AND versn EQ @p__versn
  INTO CORRESPONDING FIELDS OF TABLE @it_matpres.

  "se copia para mantener el detalle.
  SORT it_matpres ASCENDING BY gjahr bukrs kostl matnr DESCENDING.



  LOOP AT it_matpres INTO wa_matpres.
    IF wa_matpres-matnr IS INITIAL.
      wa_matpres-matnr = wa_matpres-cuenta.
      MODIFY it_matpres FROM wa_matpres TRANSPORTING matnr
      WHERE idpres = wa_matpres-idpres AND prespos = wa_matpres-prespos.
    ENDIF.
  ENDLOOP.


  it_matpresd[] = it_matpres[].

  REFRESH it_matpres.
  CLEAR wa_acumulado.
  lv_matnr = ''.
  lv_werks = ''.
  SORT it_matpresd BY matnr werks ASCENDING.

  LOOP AT it_matpresd INTO wa_matpresd.
    MOVE-CORRESPONDING wa_matpresd TO wa_collect.
    wa_collect-idpres = space.
    wa_collect-prespos = space.
    wa_collect-kostl = space.
    wa_collect-kstar = space.
    wa_collect-werks = space.
    wa_collect-bukrs = space.
    wa_collect-co_meinh = space.
    COLLECT wa_collect INTO it_collect.
  ENDLOOP.

  "break jhernandev.
*  LOOP AT it_matpresd INTO wa_matpresd.
*    IF lv_matnr NE wa_matpresd-matnr and lv_werks NE wa_matpresd-werks.
*
*      MODIFY it_matpres FROM wa_acumulado TRANSPORTING meg001 meg002 meg003 meg004 meg005
*      meg006 meg007 meg008 meg009 meg010
*      meg011 meg012 wtg001 wtg002 wtg003
*      wtg004 wtg005 wtg006 wtg007 wtg008
*      wtg009 wtg010 wtg011 wtg012 wog001
*      wog002 wog003 wog004 wog005 wog006
*      wog007 wog008 wog009 wog010 wog011
*      wog012 megtot wtgtot wogtot
*      WHERE matnr = lv_matnr and werks = lv_werks.
*
*      MOVE-CORRESPONDING wa_matpresd TO wa_acumulado.
*      APPEND wa_acumulado TO it_matpres.
*
*      lv_matnr = wa_matpresd-matnr.
*      lv_werks = wa_matpresd-werks.
*
*
*    ELSE.
*      wa_acumulado-meg001 = wa_acumulado-meg001 + wa_matpresd-meg001. wa_acumulado-meg002 = wa_acumulado-meg002 + wa_matpresd-meg002.
*      wa_acumulado-meg003 = wa_acumulado-meg003 + wa_matpresd-meg003. wa_acumulado-meg004 = wa_acumulado-meg004 + wa_matpresd-meg004.
*      wa_acumulado-meg005 = wa_acumulado-meg005 + wa_matpresd-meg005. wa_acumulado-meg006 = wa_acumulado-meg006 + wa_matpresd-meg006.
*      wa_acumulado-meg007 = wa_acumulado-meg007 + wa_matpresd-meg007. wa_acumulado-meg008 = wa_acumulado-meg008 + wa_matpresd-meg008.
*      wa_acumulado-meg009 = wa_acumulado-meg009 + wa_matpresd-meg009. wa_acumulado-meg010 = wa_acumulado-meg010 + wa_matpresd-meg010.
*      wa_acumulado-meg011 = wa_acumulado-meg011 + wa_matpresd-meg011. wa_acumulado-meg012 = wa_acumulado-meg012 + wa_matpresd-meg012.
*      wa_acumulado-megtot = wa_acumulado-meg001 + wa_acumulado-meg002 + wa_acumulado-meg003 + wa_acumulado-meg004
*      + wa_acumulado-meg005 + wa_acumulado-meg006 + wa_acumulado-meg007 + wa_acumulado-meg008 + wa_acumulado-meg009 +
*      wa_acumulado-meg010 + wa_acumulado-meg011 + wa_acumulado-meg012.
*
*      wa_acumulado-wtg001 = wa_acumulado-wtg001 + wa_matpresd-wtg001. wa_acumulado-wtg002 = wa_acumulado-wtg002 + wa_matpresd-wtg002.
*      wa_acumulado-wtg003 = wa_acumulado-wtg003 + wa_matpresd-wtg003. wa_acumulado-wtg004 = wa_acumulado-wtg004 + wa_matpresd-wtg004.
*      wa_acumulado-wtg005 = wa_acumulado-wtg005 + wa_matpresd-wtg005. wa_acumulado-wtg006 = wa_acumulado-wtg006 + wa_matpresd-wtg006.
*      wa_acumulado-wtg007 = wa_acumulado-wtg007 + wa_matpresd-wtg007. wa_acumulado-wtg008 = wa_acumulado-wtg008 + wa_matpresd-wtg008.
*      wa_acumulado-wtg009 = wa_acumulado-wtg009 + wa_matpresd-wtg009. wa_acumulado-wtg010 = wa_acumulado-wtg010 + wa_matpresd-wtg010.
*      wa_acumulado-wtg011 = wa_acumulado-wtg011 + wa_matpresd-wtg011. wa_acumulado-wtg012 = wa_acumulado-wtg012 + wa_matpresd-wtg012.
*      wa_acumulado-wtgtot = wa_acumulado-wtg001 + wa_acumulado-wtg002 + wa_acumulado-wtg003 + wa_acumulado-wtg004
*      + wa_acumulado-wtg005 + wa_acumulado-wtg006 + wa_acumulado-wtg007 + wa_acumulado-wtg008 + wa_acumulado-wtg009 +
*      wa_acumulado-wtg010 + wa_acumulado-wtg011 + wa_acumulado-wtg012.
*
*      wa_acumulado-wog001 = wa_acumulado-wog001 + wa_matpresd-wog001. wa_acumulado-wog002 = wa_acumulado-wog002 + wa_matpresd-wog002.
*      wa_acumulado-wog003 = wa_acumulado-wog003 + wa_matpresd-wog003. wa_acumulado-wog004 = wa_acumulado-wog004 + wa_matpresd-wog004.
*      wa_acumulado-wog005 = wa_acumulado-wog005 + wa_matpresd-wog005. wa_acumulado-wog006 = wa_acumulado-wog006 + wa_matpresd-wog006.
*      wa_acumulado-wog007 = wa_acumulado-wog007 + wa_matpresd-wog007. wa_acumulado-wog008 = wa_acumulado-wog008 + wa_matpresd-wog008.
*      wa_acumulado-wog009 = wa_acumulado-wog009 + wa_matpresd-wog009. wa_acumulado-wog010 = wa_acumulado-wog010 + wa_matpresd-wog010.
*      wa_acumulado-wog011 = wa_acumulado-wog011 + wa_matpresd-wog011. wa_acumulado-wog012 = wa_acumulado-wog012 + wa_matpresd-wog012.
*      wa_acumulado-wogtot = wa_acumulado-wog001 + wa_acumulado-wog002 + wa_acumulado-wog003 + wa_acumulado-wog004
*      + wa_acumulado-wog005 + wa_acumulado-wog006 + wa_acumulado-wog007 + wa_acumulado-wog008 + wa_acumulado-wog009 +
*      wa_acumulado-wog010 + wa_acumulado-wog011 + wa_acumulado-wog012.
*
*    ENDIF.

* ENDLOOP.



*  MODIFY it_matpres FROM wa_acumulado TRANSPORTING meg001 meg002 meg003 meg004 meg005
*  meg006 meg007 meg008 meg009 meg010
*  meg011 meg012 wtg001 wtg002 wtg003
*  wtg004 wtg005 wtg006 wtg007 wtg008
*  wtg009 wtg010 wtg011 wtg012 wog001
*  wog002 wog003 wog004 wog005 wog006
*  wog007 wog008 wog009 wog010 wog011
*  wog012 megtot wtgtot wogtot
*  WHERE matnr = lv_matnr AND werks = lv_werks.
*  CLEAR wa_acumulado.

  it_matpres[] = it_collect[].
  SORT it_matpres ASCENDING BY gjahr bukrs kostl matnr DESCENDING.

  DELETE ADJACENT DUPLICATES FROM it_matpres COMPARING gjahr bukrs kostl matnr.

  LOOP AT it_matpres ASSIGNING <ls_wa>.
    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <ls_wa> TO <linea>.
    READ TABLE it_t001w INTO wa_t001w WITH KEY werks = <linea>.
    IF sy-subrc EQ 0.
      "       CLEAR wa_matpres.
      "wa_matpres-name1 = wa_t001w-name1.
      "MODIFY it_matpres FROM wa_matpres TRANSPORTING name1 WHERE werks = <linea>.
      UNASSIGN <linea>.
      ASSIGN COMPONENT 'NAME1' OF STRUCTURE <ls_wa> TO <linea>.
      <linea> = wa_t001w-name1.
    ENDIF.


    ASSIGN COMPONENT 'MATKL' OF STRUCTURE <ls_wa> TO <linea>.
    READ TABLE it_t023t INTO wa_t023t WITH KEY matkl = <linea>.
    IF sy-subrc EQ 0.
      CLEAR wa_matpres.
      "wa_matpres-wgbez = wa_t023t-wgbez.
      "MODIFY it_matpres FROM wa_matpres TRANSPORTING wgbez WHERE matkl = <linea>.
      UNASSIGN <linea>.
      ASSIGN COMPONENT 'WGBEZ' OF STRUCTURE <ls_wa> TO <linea>.
      <linea> = wa_t023t-wgbez.

    ENDIF.


    ASSIGN COMPONENT 'MATNR' OF STRUCTURE <ls_wa> TO <linea>.
    select single meins into @data(wa_matnr) from mara where matnr = @<linea>.
    UNASSIGN <linea>.

    ASSIGN COMPONENT 'CO_MEINH' OF STRUCTURE <ls_wa> TO <linea>.
    SELECT SINGLE mseh3 INTO <linea> FROM t006a WHERE msehi =  wa_matnr.
    UNASSIGN <linea>.
  ENDLOOP.


  SORT it_matpres BY gjahr kokrs bukrs matnr werks DESCENDING.


ENDFORM.                    " GET_PRESMAT
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCAT_RPT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_fieldcat_rpt USING prefijo TYPE char3.
  DATA ls_fieldcat TYPE lvc_s_fcat.
  DATA mes_corto LIKE t247-ktx.
  DATA mes_display LIKE t247-ltx.
  DATA num_mes LIKE t247-mnr.
  DATA lv_txtcant(20) TYPE c.
  DATA lv_txtmonto(20) TYPE c.
  DATA lv_fldnmecat TYPE lvc_fname.
  DATA lv_fldnmemont TYPE lvc_fname.


  REFRESH fieldcat102.
  IF id_exec EQ 'AjustePres'.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CHECK'.
    ls_fieldcat-scrtext_m = 'Sel'.
    ls_fieldcat-checkbox = 'X'.
    ls_fieldcat-edit = 'X'.
    ls_fieldcat-col_opt = 'X'.
    ls_fieldcat-key = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
  ENDIF.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KOKRS'.
  ls_fieldcat-outputlen = 4.
  ls_fieldcat-scrtext_m = 'Soc. CO'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-outputlen = 4.
  ls_fieldcat-scrtext_m = 'Soc. FI'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-key = 'X'.
  IF id_exec EQ 'AjustePres'.
    ls_fieldcat-no_out = ''.
  ELSE.
    ls_fieldcat-no_out = 'X'.
  ENDIF.

  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'KOSTL'.
  ls_fieldcat-outputlen = 6.
  ls_fieldcat-scrtext_m = 'CeCo'.
  "ls_fieldcat-no_out = 'X'.
  ls_fieldcat-key = 'X'.
  IF id_exec EQ 'AjustePres'.
    ls_fieldcat-no_out = ''.
  ELSE.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'KTEXT'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-scrtext_s = 'Desc.'.
  ls_fieldcat-col_opt = ''.
  ls_fieldcat-key = 'X'.
  IF id_exec EQ 'AjustePres'.
    ls_fieldcat-no_out = ''.
  ELSE.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'KSTAR'.
  ls_fieldcat-outputlen = 6.
  ls_fieldcat-scrtext_m = 'Cl.Cos.'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-key = 'X'.
  IF id_exec EQ 'AjustePres'.
    ls_fieldcat-no_out = ''.
  ELSE.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'TXT20'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-scrtext_s = 'Desc.'.
  ls_fieldcat-col_opt = ''.
  ls_fieldcat-key = 'X'.
  IF id_exec EQ 'AjustePres'.
    ls_fieldcat-no_out = ''.
  ELSE.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.


  ls_fieldcat-fieldname = 'WERKS'.
  ls_fieldcat-outputlen = 4.
  ls_fieldcat-scrtext_m = 'Centro'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-key = 'X'.
  IF id_exec EQ 'AjustePres'.
    ls_fieldcat-no_out = ''.
  ELSE.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'NAME1'.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-scrtext_m = 'Descr. Centro'.
  IF id_exec EQ 'AjustePres'.
    ls_fieldcat-no_out = ''.
  ELSE.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'MATNR'.
  ls_fieldcat-outputlen = 18.
  ls_fieldcat-datatype = 'NUMC'.
  ls_fieldcat-scrtext_m = 'Material'.
  ls_fieldcat-col_opt = 'X'.
  IF id_exec EQ 'AjustePres'.
    ls_fieldcat-hotspot = ''.
  ELSE.
    ls_fieldcat-hotspot = 'X'.
  ENDIF.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'MAKTX'.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-scrtext_m = 'Descripcion'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  IF id_exec NE 'MatMontos'.
    ls_fieldcat-fieldname = 'CO_MEINH'.
    ls_fieldcat-scrtext_m = 'U.M.'.
    ls_fieldcat-col_opt = 'X'.
    ls_fieldcat-key = 'X'.

    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'MATKL'.
    ls_fieldcat-outputlen = 9.
    ls_fieldcat-scrtext_m = 'Gpo. Arts.'.
    ls_fieldcat-col_opt = 'X'.
    ls_fieldcat-key = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'WGBEZ'.
    ls_fieldcat-outputlen = 10.
    ls_fieldcat-scrtext_s = 'Descr. Gpo.'.
    ls_fieldcat-col_opt = ''.
    ls_fieldcat-key = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.
  ENDIF.
  num_mes = 0.
  DO 12 TIMES.
    num_mes = num_mes + 1.

    PERFORM get_periodo USING num_mes
    CHANGING num_mes
      mes_corto
      lv_fldnmecat
      lv_fldnmemont.

    IF prefijo EQ 'MEG'.
      ls_fieldcat-fieldname = lv_fldnmecat.
      mes_display = mes_corto.
    ELSE.
      ls_fieldcat-fieldname = lv_fldnmemont.
      CONCATENATE '$' mes_corto INTO mes_display SEPARATED BY space.
    ENDIF.
    ls_fieldcat-outputlen = 6.
    ls_fieldcat-scrtext_m = mes_display.
    ls_fieldcat-col_opt = 'X'.
    ls_fieldcat-do_sum = 'X'.
    IF id_exec EQ 'AjustePres'.
      ls_fieldcat-hotspot = ''. " Shows the field as a = hotspot.
      ls_fieldcat-edit = 'X'. " Shows the field as a = hotspot.
      ls_fieldcat-datatype = 'P'.
    ELSE.
      ls_fieldcat-hotspot = 'X'. " Shows the field as a = hotspot.
    ENDIF.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.

  ENDDO.

  IF prefijo EQ 'MEG'.
    ls_fieldcat-fieldname = 'MEGTOT'.
  ELSE.
    ls_fieldcat-fieldname = 'WTGTOT'.
  ENDIF.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-scrtext_m = 'TOTAL'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-do_sum = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

ENDFORM.                    " GET_FIELDCAT_RPT
*&---------------------------------------------------------------------*
*&      Form  ITEM_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM item_click  USING    p_e_row_id TYPE lvc_s_row
      p_e_column_id TYPE lvc_s_col
      p_es_row_no TYPE lvc_s_roid.

  DATA lv_column(3) TYPE c.
  FIELD-SYMBOLS <lfs_it> TYPE st_matpres.

  READ TABLE it_matpres ASSIGNING <lfs_it>
  INDEX p_e_row_id.

  lv_column = p_e_column_id+0(3).
  IF lv_column EQ 'MEG' OR lv_column EQ 'WTG'.

  ELSEIF lv_column EQ 'RSN'.
    IF <lfs_it> IS ASSIGNED.
      UNASSIGN <lfs_it>.
    ENDIF.
    PERFORM mostrar_reserva USING  p_e_row_id.
  ELSEIF lv_column EQ 'SOL'.
    IF <lfs_it> IS ASSIGNED.
      UNASSIGN <lfs_it>.
    ENDIF.

    PERFORM mostrar_solped USING  p_e_row_id.
  ELSE.
    lv_column =   p_e_column_id.
  ENDIF.

  IF <lfs_it> IS ASSIGNED.
    CASE lv_column.
      WHEN 'MAT'.
        PERFORM show_details_matnr USING <lfs_it>-matnr <lfs_it>-werks.

      WHEN OTHERS.
        PERFORM show_details_mw USING p_e_column_id
              <lfs_it>-matnr
              <lfs_it>-werks
              <lfs_it>-bukrs.
    ENDCASE.
  ENDIF.
ENDFORM.                    " ITEM_CLICK
*&---------------------------------------------------------------------*
*&      Form  SHOW_DETAILS_MATNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_IT>_MATNR  text
*      -->P_<LFS_IT>_WERKS  text
*----------------------------------------------------------------------*
FORM show_details_matnr  USING    p_matnr TYPE matnr18
      p_werks TYPE werks_d.

  TYPES:
    BEGIN OF st_precio,
      infnr TYPE infnr,
      erdat TYPE erdat,
      umrez	TYPE umbsz, "correspondencia
      lifnr TYPE lifnr,
      name1 TYPE name1_gp,
      ebeln TYPE ebeln,
      ebelp TYPE ebelp,
      bedat TYPE bedat,
      preis TYPE bprei,
      bwaer TYPE waers,
      lprei TYPE preis,
      peinh TYPE epein, "cantidad pedido
      werks TYPE werks_d,
    END OF st_precio.

  DATA: it_precio TYPE STANDARD TABLE OF st_precio.

************************* tabla de precios y proveedores *************************
  SELECT a~infnr a~erdat a~umrez a~lifnr b~name1 c~ebeln c~ebelp c~bedat c~preis
  c~bwaer c~lprei c~peinh c~werks
  INTO TABLE it_precio
  FROM eina AS a
  INNER JOIN lfa1 AS b
  ON b~lifnr = a~lifnr
  INNER JOIN eipa AS c
  ON c~infnr = a~infnr
  WHERE a~matnr = p_matnr
  AND c~werks = p_werks
  .
  SORT it_precio BY bedat DESCENDING.



  PERFORM show_alvpopup3 USING it_precio 'Historial precios'.

ENDFORM.                    " SHOW_DETAILS_MATNR
*&---------------------------------------------------------------------*
*&      Form  SHOW_DETAILS_MW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM show_details_mw  USING  p_p_e_column_id TYPE lvc_s_col
      p_matnr TYPE matnr18
      p_werks TYPE werks_d
      p_bukrs TYPE bukrs.

  FIELD-SYMBOLS: <ls_struct> TYPE any,
                 <ls_wa>     TYPE any.

  TYPES: BEGIN OF ty_detail_per,
           bukrs      TYPE bukrs, " CHAR  4 0 Sociedad
           kostl      TYPE kostl, " CHAR  10  0 Centro de coste
           kstar      TYPE kstar, " CHAR  10  0 Clase de coste
           matnr      TYPE matnr, " CHAR  18  0 Número de material
           "    cuenta  TYPE kstar, " CHAR  10  0 Clase de coste
           maktx      TYPE maktx, " CHAR  40  0 Texto breve de material
           werks      TYPE werks_d,
           co_meinh   TYPE co_meinh,  " UNIT  3 0 Unidad de medida
           preunipres TYPE wtgxxx,  " CURR  15  2 Valor total en moneda de transacción
           cantidad   TYPE megxxx,  " CURR
         END OF ty_detail_per.

  DATA: it_detail_mat TYPE STANDARD TABLE OF ty_detail_per,
        wa_detail_mat LIKE LINE OF it_detail_mat.

  LOOP AT it_matpresd ASSIGNING <ls_struct>
  WHERE matnr = p_matnr
  "werks = p_werks
  "bukrs = p_bukrs
  "AND .
  .
    CLEAR wa_detail_mat.
    MOVE-CORRESPONDING: <ls_struct> TO wa_detail_mat.
    ASSIGN COMPONENT p_p_e_column_id OF STRUCTURE <ls_struct> TO <ls_wa>.
    IF <ls_wa> IS ASSIGNED.
      wa_detail_mat-cantidad = <ls_wa>.
    ENDIF.
    SELECT SINGLE msehi INTO wa_detail_mat-co_meinh FROM t006a WHERE mseh3 =  wa_detail_mat-co_meinh.

    APPEND wa_detail_mat TO it_detail_mat.
  ENDLOOP.

  PERFORM show_alvpopup3 USING it_detail_mat 'Detalle materiales'.


ENDFORM.                    " SHOW_DETAILS_MW

*&---------------------------------------------------------------------*
*&      Form  show_alvpopup3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TABLE    text
*      -->P_LEYENDA  text
*----------------------------------------------------------------------*
FORM show_alvpopup3 USING p_table TYPE STANDARD TABLE
    p_leyenda TYPE string.
  CALL FUNCTION 'ZUT_FLOATALV'
    EXPORTING
      i_start_column = 50
      i_start_line   = 10
      i_end_column   = 170
      i_end_line     = 30
      i_title        = p_leyenda
      i_popup        = 'X'
    TABLES
      it_alv         = p_table.

ENDFORM.                    "show_alvpopup3
*&---------------------------------------------------------------------*
*&      Form  ANALIZAR_PTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM analizar_pto .

  DATA: f_lenght TYPE i.

  DATA: lv_objnr   TYPE string,
        lv_wtgtot  TYPE wtgxxx,
        lv_wtggral TYPE wtgxxx.

  DATA: it_cosp_copy TYPE STANDARD TABLE OF st_cosp,
        wa_cosp_copy LIKE LINE OF it_cosp_copy.


  FIELD-SYMBOLS: <fs_wa>    TYPE st_cosp,
                 <fs_field> TYPE any.

  CONCATENATE 'KS' p__kokrs '%'  INTO lv_objnr.

  REFRESH it_cosp.

  SELECT objnr, kstar, vrgng, wtg001, wtg002, wtg003, wtg004, wtg005,
  wtg006, wtg007, wtg008, wtg009, wtg010, wtg011, wtg012
  INTO TABLE @it_cosp
  FROM v_cosp_view "cosp
  WHERE lednr = '00'
  AND objnr LIKE @lv_objnr "'KSGA00%'
  AND gjahr = @p__gjahr
  AND versn = '000'

  AND perbl = 16.


  IF sy-subrc EQ 0.
    SORT it_cosp BY vrgng.
    DELETE it_cosp WHERE vrgng EQ 'RMBA'.
    DELETE it_cosp WHERE vrgng EQ 'RMBE'.
    SORT it_cosp BY objnr kstar vrgng.
*-------calculamos totales del presupuesto planeado
    CLEAR lv_wtggral.
    CLEAR wa_cosp.

    "solo se dejan los que esten en la tabla matpres que son los materiales presupuestados4
    LOOP AT it_cosp INTO wa_cosp.
      f_lenght = strlen( wa_cosp-objnr ).
      f_lenght = f_lenght - 6.
      lv_objnr = wa_cosp+6(f_lenght).

      READ TABLE it_matpres INTO wa_matpres WITH KEY kostl = lv_objnr.
      IF sy-subrc EQ 0.
        wa_cosp_copy =  wa_cosp.
        APPEND wa_cosp_copy TO it_cosp_copy.
      ENDIF.
    ENDLOOP.
    REFRESH it_cosp.
    it_cosp[] = it_cosp_copy[].
    "------------------------------------------------------------------------------------------


    SORT it_cosp BY vrgng ASCENDING.
    LOOP AT it_cosp ASSIGNING <fs_wa> WHERE vrgng = 'RKP1'.
      CLEAR lv_wtgtot.
      lv_wtgtot = <fs_wa>-wtg001 + <fs_wa>-wtg002 + <fs_wa>-wtg003 +
      <fs_wa>-wtg004 + <fs_wa>-wtg005 + <fs_wa>-wtg006 +
      <fs_wa>-wtg007 + <fs_wa>-wtg008 + <fs_wa>-wtg009 +
      <fs_wa>-wtg010 + <fs_wa>-wtg011 + <fs_wa>-wtg012.
      <fs_wa>-wtgtot = lv_wtgtot.
      wa_cosp-objnr = 'TOTAL RKP1 POR MES'.
      wa_cosp-wtg001 = wa_cosp-wtg001 + <fs_wa>-wtg001.
      wa_cosp-wtg002 = wa_cosp-wtg002 + <fs_wa>-wtg002.
      wa_cosp-wtg003 = wa_cosp-wtg003 + <fs_wa>-wtg003.
      wa_cosp-wtg004 = wa_cosp-wtg004 + <fs_wa>-wtg004.
      wa_cosp-wtg005 = wa_cosp-wtg005 + <fs_wa>-wtg005.
      wa_cosp-wtg006 = wa_cosp-wtg006 + <fs_wa>-wtg006.
      wa_cosp-wtg007 = wa_cosp-wtg007 + <fs_wa>-wtg007.
      wa_cosp-wtg008 = wa_cosp-wtg008 + <fs_wa>-wtg008.
      wa_cosp-wtg009 = wa_cosp-wtg009 + <fs_wa>-wtg009.
      wa_cosp-wtg010 = wa_cosp-wtg010 + <fs_wa>-wtg010.
      wa_cosp-wtg011 = wa_cosp-wtg011 + <fs_wa>-wtg011.
      wa_cosp-wtg012 = wa_cosp-wtg012 + <fs_wa>-wtg012.
      wa_cosp-wtgtot = wa_cosp-wtgtot + <fs_wa>-wtgtot.

    ENDLOOP.
    SORT it_cosp BY objnr vrgng ASCENDING.
    LOOP AT it_cosp ASSIGNING <fs_wa> WHERE vrgng = 'RKP1' AND wtgtot > 0.
      AT END OF objnr.
        lv_wtggral = lv_wtggral +  <fs_wa>-wtgtot.
      ENDAT.
      <fs_wa>-wtggral = lv_wtggral.
      CLEAR lv_wtggral.

    ENDLOOP.
*----------------------------------------------------------
*-----------calulamos totales del presupuesto  consumido
    CLEAR lv_wtggral.
    CLEAR wa_cospreal.
    SORT it_cosp BY vrgng DESCENDING.
    LOOP AT it_cosp ASSIGNING <fs_wa> WHERE vrgng = 'COIN'.
      CLEAR lv_wtgtot.
      lv_wtgtot = <fs_wa>-wtg001 + <fs_wa>-wtg002 + <fs_wa>-wtg003 +
      <fs_wa>-wtg004 + <fs_wa>-wtg005 + <fs_wa>-wtg006 +
      <fs_wa>-wtg007 + <fs_wa>-wtg008 + <fs_wa>-wtg009 +
      <fs_wa>-wtg010 + <fs_wa>-wtg011 + <fs_wa>-wtg012.
      <fs_wa>-wtgtot = lv_wtgtot.
      wa_cospreal-objnr = 'TOTAL COIN POR MES'.
      wa_cospreal-wtg001 = wa_cospreal-wtg001 + <fs_wa>-wtg001.
      wa_cospreal-wtg002 = wa_cospreal-wtg002 + <fs_wa>-wtg002.
      wa_cospreal-wtg003 = wa_cospreal-wtg003 + <fs_wa>-wtg003.
      wa_cospreal-wtg004 = wa_cospreal-wtg004 + <fs_wa>-wtg004.
      wa_cospreal-wtg005 = wa_cospreal-wtg005 + <fs_wa>-wtg005.
      wa_cospreal-wtg006 = wa_cospreal-wtg006 + <fs_wa>-wtg006.
      wa_cospreal-wtg007 = wa_cospreal-wtg007 + <fs_wa>-wtg007.
      wa_cospreal-wtg008 = wa_cospreal-wtg008 + <fs_wa>-wtg008.
      wa_cospreal-wtg009 = wa_cospreal-wtg009 + <fs_wa>-wtg009.
      wa_cospreal-wtg010 = wa_cospreal-wtg010 + <fs_wa>-wtg010.
      wa_cospreal-wtg011 = wa_cospreal-wtg011 + <fs_wa>-wtg011.
      wa_cospreal-wtg012 = wa_cospreal-wtg012 + <fs_wa>-wtg012.
      wa_cospreal-wtgtot = wa_cospreal-wtgtot + <fs_wa>-wtgtot.
    ENDLOOP.

    SORT it_cosp BY objnr vrgng DESCENDING.
    LOOP AT it_cosp ASSIGNING <fs_wa> WHERE vrgng = 'COIN'.
      lv_wtggral = lv_wtggral +  <fs_wa>-wtgtot.
      AT END OF objnr.
        <fs_wa>-wtggral = lv_wtggral.
        CLEAR lv_wtggral.
      ENDAT.
    ENDLOOP.

*---------------------------------------------------------------------
*TOTALES POR MES POR SOCIEDAD CO
    APPEND wa_cosp TO it_cosp.
    APPEND wa_cospreal TO it_cosp.
  ENDIF.
  IF it_cosp IS NOT INITIAL.
    IF gref_alvgrid102 IS NOT INITIAL.
      TRY.
          CALL METHOD gref_alvgrid102->free.
        CATCH cx_sy_ref_is_initial.

      ENDTRY.
      CLEAR gref_alvgrid102.
    ENDIF.


    graph_type = 'SOC'.
    PERFORM graph_cube.
  ENDIF.

ENDFORM.                    " ANALIZAR_PTO

*&---------------------------------------------------------------------*
*&      Form  graficar_pto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM graficar_pto.

  DATA: f_lenght TYPE i.
  DATA: f_xstring TYPE xstring.
  DATA: fo_ixml_mf TYPE REF TO if_ixml.
  DATA: fo_ixml_sf TYPE REF TO if_ixml_stream_factory.
  DATA: f_ixml_data_doc   TYPE REF TO if_ixml_document.
  DATA: scat    TYPE string, vlserie TYPE string, vlvalor TYPE string.
  DATA: lv_valuecat TYPE string.

  FIELD-SYMBOLS: <fs_wa> TYPE any,
                 <cell>  TYPE any.

  DATA: f_ostream         TYPE REF TO if_ixml_ostream.
  DATA: f_encoding        TYPE REF TO if_ixml_encoding.
* chart data elements:
  DATA: f_chartdata  TYPE REF TO if_ixml_element,
        f_categories TYPE REF TO if_ixml_element,
        f_category   TYPE REF TO if_ixml_element,
        f_series     TYPE REF TO if_ixml_element,
        f_point      TYPE REF TO if_ixml_element,
        f_value      TYPE REF TO if_ixml_element,
        l_element    TYPE REF TO if_ixml_element.



  "IF go_chart IS INITIAL.
*    TRY.
*        CALL METHOD gref_alvgrid102->free.
*      CATCH cx_sy_ref_is_initial.
*
*    ENDTRY.
*
*    TRY.
*        CALL METHOD gref_ccontainer102->free.
*      CATCH cx_sy_ref_is_initial.
*
*    ENDTRY.


  "create container
*    CREATE OBJECT gref_ccontainer102
*      EXPORTING
*        container_name = 'ALV_CONTAINER'.
*    "create an engine assigned to our container
*    CREATE OBJECT go_chart
*      EXPORTING
*        parent = gref_ccontainer102.
  "ENDIF.


* processing data
  fo_ixml_mf = cl_ixml=>create( ).
  fo_ixml_sf = fo_ixml_mf->create_stream_factory( ).
* create an empty document and set encoding
  f_ixml_data_doc = fo_ixml_mf->create_document( ).


  f_encoding = fo_ixml_mf->create_encoding(
  byte_order    = if_ixml_encoding=>co_little_endian
  character_set = 'utf-8' ).

  f_ixml_data_doc->set_encoding( f_encoding ).


* Now build a DOM, representing an XML document with chart data
  f_chartdata = f_ixml_data_doc->create_simple_element(
  name   = 'SimpleChartData'
  parent = f_ixml_data_doc ).


* Categories (parent)
  f_categories = f_ixml_data_doc->create_simple_element(
  name   = 'Categories'
  parent = f_chartdata ).

  vlserie = 'Comparativa'."<wfieldalv>.
*Serie
  f_series = f_ixml_data_doc->create_simple_element(
  name = 'Series'
  parent = f_chartdata ).

  f_series->set_attribute( name = 'label'
  value = vlserie  ).


  READ TABLE it_cosp ASSIGNING <fs_wa> WITH KEY objnr = 'TOTAL RKP1 POR MES'.
  ASSIGN COMPONENT 'WTGTOT' OF STRUCTURE <fs_wa> TO <cell>.
  vlvalor = <cell>. "<wfieldalv>.
  lv_valuecat = <cell>.
  PERFORM convert_string_curr USING lv_valuecat
  CHANGING lv_valuecat .

  CONCATENATE 'Pto Cargado:' lv_valuecat INTO scat SEPARATED BY space.
  f_category = f_ixml_data_doc->create_simple_element(
  name   = 'C'
  parent = f_categories ).
  f_category->if_ixml_node~set_value( scat ).
  UNASSIGN <cell>.


  l_element = f_ixml_data_doc->create_simple_element(
  name = 'S' parent = f_series ).
  l_element->if_ixml_node~set_value( vlvalor ).

  READ TABLE it_cosp ASSIGNING <fs_wa> WITH KEY objnr = 'TOTAL COIN POR MES'.
  ASSIGN COMPONENT 'WTGTOT' OF STRUCTURE <fs_wa> TO <cell>.
  vlvalor = <cell>.
  lv_valuecat = <cell>.
  PERFORM convert_string_curr USING lv_valuecat
  CHANGING lv_valuecat .
  CONCATENATE 'Pto Consumido:' lv_valuecat INTO scat SEPARATED BY space.
  f_category = f_ixml_data_doc->create_simple_element(
  name   = 'C'
  parent = f_categories ).
  f_category->if_ixml_node~set_value( scat ).

  UNASSIGN <cell>.
  l_element = f_ixml_data_doc->create_simple_element(
  name = 'S' parent = f_series ).
  l_element->if_ixml_node~set_value( vlvalor ).

* create ostream (into string variable) and render document into stream
  f_ostream = fo_ixml_sf->create_ostream_xstring( f_xstring ).
  f_ixml_data_doc->render( f_ostream ). "here f_xstring is filled

  "set data to chart
  go_chart->set_data( xdata = f_xstring ).

  "get customizing from Standard text

  "f_xstring = chart_customizing using
  PERFORM chart_customizing USING
        'ZGRAPH_PTO_SOC'
        'Analisis Presupuesto'
        'Grupo Porres'
        'Montos'
  CHANGING
    f_xstring
    .
  "set customizing
  go_chart->set_customizing( xdata = f_xstring ).

  "render chart
  go_chart->render( ).

  graph_type = 'CECO'.

ENDFORM.                    "graficar_pto

*&---------------------------------------------------------------------*
*&      Form  chart_customizing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXNAME  text
*      -->P_TITLE    text
*      -->P_SUBTITLE text
*      <--P_XSTRING  text
*----------------------------------------------------------------------*
FORM chart_customizing USING p_texname TYPE thead-tdname
    p_title TYPE string
    p_subtitle TYPE string
    p_axis   TYPE string
CHANGING
p_xstring.

  DATA: ft_raw255 TYPE solix_tab.
  DATA: fs_raw255 TYPE solix.
  DATA: f_tablenght TYPE i.
  DATA: f_string TYPE string.
  DATA: f_xstring TYPE xstring.
  DATA: fo_ixml TYPE REF TO if_ixml.
  DATA: fo_streamfactory TYPE REF TO if_ixml_stream_factory.
  DATA: fo_istream TYPE REF TO if_ixml_istream.
  DATA: fo_document TYPE REF TO if_ixml_document. "<=== here is IF_IXML_DOCUMENT
  DATA: fo_parser TYPE REF TO if_ixml_parser.
  DATA: f_ostream  TYPE REF TO if_ixml_ostream.
  DATA: f_subtitle TYPE string.
  DATA: f_title TYPE string.
  DATA: ft_itf_text TYPE TABLE OF tline.
  FIELD-SYMBOLS: <itf> TYPE tline.

  f_subtitle =  p_title.
  f_title = p_subtitle.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id        = 'ST'
      language  = 'E'
      name      = p_texname
      object    = 'TEXT'
    TABLES
      lines     = ft_itf_text
    EXCEPTIONS
      id        = 1
      language  = 2
      name      = 3
      not_found = 4
      object    = 5
      OTHERS    = 8.
  IF sy-subrc <> 0.
*    raise error_reading_standard_text.
  ELSE.
    LOOP AT ft_itf_text ASSIGNING <itf>.
      CONCATENATE f_string <itf>-tdline INTO f_string.
    ENDLOOP.
  ENDIF.

  IF f_string IS NOT INITIAL.  "if you have other special html characters in titles or variables in configurations then add it here
    REPLACE ALL OCCURRENCES OF '&' IN f_subtitle WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '&' IN f_title WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN f_subtitle WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '<' IN f_title WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN f_subtitle WITH '&gt;'.
    REPLACE ALL OCCURRENCES OF '>' IN f_title WITH '&gt;'.
    REPLACE ALL OCCURRENCES OF 'SUBTITLE_REPLACE' IN f_string WITH f_subtitle.
    REPLACE ALL OCCURRENCES OF 'TITLE_REPLACE' IN f_string WITH f_title.
    REPLACE ALL OCCURRENCES OF 'AXIS_REPLACE' IN f_string WITH f_title.
    CLEAR f_xstring.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = f_string
*       MIMETYPE = ' '
*       ENCODING = ENCODING
      IMPORTING
        buffer = f_xstring
      EXCEPTIONS
        failed = 1
        OTHERS = 2.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer        = f_xstring
*         APPEND_TO_TABLE = ' '
        IMPORTING
          output_length = f_tablenght
        TABLES
          binary_tab    = ft_raw255.
    ENDIF.

    CHECK ft_raw255[] IS NOT INITIAL.

    fo_ixml = cl_ixml=>create( ).
    fo_streamfactory = fo_ixml->create_stream_factory( ).
    fo_document = fo_ixml->create_document( ).
    fo_istream = fo_streamfactory->create_istream_itable(
    size = f_tablenght
    table = ft_raw255 ).
    fo_parser = fo_ixml->create_parser( stream_factory = fo_streamfactory
    istream        = fo_istream
    document       = fo_document ).
    fo_parser->parse( ).
    CLEAR p_xstring.
    f_ostream = fo_streamfactory->create_ostream_xstring( p_xstring ).
    CALL METHOD fo_document->render
      EXPORTING
        ostream = f_ostream.

  ENDIF.

ENDFORM.                    "chart_customizing
*&---------------------------------------------------------------------*
*&      Form  convert_string_curr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->STRNUM     text
*      <--STR_OUTPUT text
*----------------------------------------------------------------------*
FORM convert_string_curr USING strnum TYPE string
CHANGING str_output TYPE string.

  DATA: nchar TYPE num,char, i TYPE i, j TYPE i, k TYPE i.
  DATA: str_dec    TYPE string, str_salida TYPE string.

  nchar = strlen( strnum ).
  DO nchar TIMES.
    char = strnum+i(1).
    IF char EQ '.'.
      str_dec = strnum+i(3).
      EXIT.
    ELSE.
      i = i + 1.
    ENDIF.

  ENDDO.

  j = i - 1.
  k = 0.
  DO i TIMES.
    char = strnum+j(1).
    j = j - 1.
    k = k + 1.
    IF str_salida IS INITIAL.
      CONCATENATE char str_dec INTO str_salida.
    ELSE.
      CONCATENATE char str_salida INTO str_salida.
    ENDIF.

    IF k EQ 3 .
      k = 0.
      CONCATENATE ',' str_salida INTO str_salida.
    ENDIF.
  ENDDO.

  char = str_salida+0(1).
  IF char EQ ','.
    i = strlen( str_salida ).
    i = i - 1.
    str_salida = str_salida+1(i).

  ENDIF.
  CONCATENATE '$' str_salida INTO str_output SEPARATED BY space.


ENDFORM.                    "convert_string_curr
*&---------------------------------------------------------------------*
*&      Form  GRAPH_CUBE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM graph_cube .

  IF go_chart IS NOT INITIAL.
    CLEAR go_chart.
    TRY.
        CALL METHOD gref_ccontainer102->free.
      CATCH cx_sy_ref_is_initial.

    ENDTRY.
    CLEAR gref_ccontainer102.


  ENDIF.



  "create container
  CREATE OBJECT gref_ccontainer102
    EXPORTING
      container_name = 'ALV_CONTAINER'.
  "create an engine assigned to our container
  CREATE OBJECT go_chart
    EXPORTING
      parent = gref_ccontainer102.

  CASE graph_type.
    WHEN 'SOC'.
      graph_type = 'SOC'.
      PERFORM graficar_pto.
    WHEN 'CECO'.
      graph_type = 'CECO'.
      PERFORM graph_pto_byceco.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " GRAPH_CUBE
*&---------------------------------------------------------------------*
*&      Form  GRAPH_PTO_BYCECO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM graph_pto_byceco .
  DATA: f_lenght TYPE i.
  DATA: f_xstring TYPE xstring.
  DATA: fo_ixml_mf TYPE REF TO if_ixml.
  DATA: fo_ixml_sf TYPE REF TO if_ixml_stream_factory.
  DATA: f_ixml_data_doc   TYPE REF TO if_ixml_document.
  DATA: scat    TYPE string, vlserie TYPE string, vlvalor TYPE string.
  DATA: lv_valuecat TYPE string.

  FIELD-SYMBOLS: <fs_wa> TYPE any,
                 <cell>  TYPE any.
  DATA: it_cosp_ceco TYPE STANDARD TABLE OF st_cosp,
        wa_cosp_ceco LIKE LINE OF it_cosp_ceco,
        it_cosp_copy TYPE STANDARD TABLE OF st_cosp,
        wa_cosp_copy LIKE LINE OF it_cosp_copy.

  DATA: f_ostream         TYPE REF TO if_ixml_ostream.
  DATA: f_encoding        TYPE REF TO if_ixml_encoding.
* chart data elements:
  DATA: f_chartdata  TYPE REF TO if_ixml_element,
        f_categories TYPE REF TO if_ixml_element,
        f_category   TYPE REF TO if_ixml_element,
        f_series     TYPE REF TO if_ixml_element,
        f_point      TYPE REF TO if_ixml_element,
        f_value      TYPE REF TO if_ixml_element,
        l_element    TYPE REF TO if_ixml_element.

* processing data
  fo_ixml_mf = cl_ixml=>create( ).
  fo_ixml_sf = fo_ixml_mf->create_stream_factory( ).
* create an empty document and set encoding
  f_ixml_data_doc = fo_ixml_mf->create_document( ).


  f_encoding = fo_ixml_mf->create_encoding(
  byte_order    = if_ixml_encoding=>co_little_endian
  character_set = 'utf-8' ).

  f_ixml_data_doc->set_encoding( f_encoding ).


* Now build a DOM, representing an XML document with chart data
  f_chartdata = f_ixml_data_doc->create_simple_element(
  name   = 'SimpleChartData'
  parent = f_ixml_data_doc ).


* Categories (parent)
  f_categories = f_ixml_data_doc->create_simple_element(
  name   = 'Categories'
  parent = f_chartdata ).
* Categories (cecos)

  LOOP AT it_cosp INTO wa_cosp WHERE vrgng = 'RKP1' AND wtggral > 0.
    f_lenght = strlen( wa_cosp-objnr ).
    f_lenght = f_lenght - 6.
    lv_valuecat = wa_cosp+6(f_lenght).

    READ TABLE it_matpres INTO wa_matpres WITH KEY kostl = lv_valuecat.
    IF sy-subrc EQ 0.
      wa_cosp_ceco-objnr = wa_cosp-objnr.
      scat = lv_valuecat.

      f_category = f_ixml_data_doc->create_simple_element(
      name   = 'C'
      parent = f_categories ).
      f_category->if_ixml_node~set_value( scat ).
      APPEND wa_cosp_ceco TO it_cosp_ceco.
      CLEAR wa_cosp_ceco.
    ENDIF.
  ENDLOOP.

  vlserie = 'Presupuesto'.
  scat = 'RKP1'.
  SORT it_cosp BY objnr.
  it_cosp_copy[] = it_cosp[].

  DELETE it_cosp WHERE wtggral <= 0.
  DO 2 TIMES.
    f_series = f_ixml_data_doc->create_simple_element(
    name = 'Series'
    parent = f_chartdata ).

    f_series->set_attribute( name = 'label'
    value = vlserie  ).


    SORT it_cosp BY objnr vrgng ASCENDING.
    LOOP AT it_cosp INTO wa_cosp WHERE  vrgng = scat AND wtggral > 0.
      READ TABLE it_cosp_ceco INTO wa_cosp_ceco WITH KEY objnr = wa_cosp-objnr.
      IF sy-subrc EQ 0.
        CLEAR vlvalor.
        vlvalor = wa_cosp-wtggral.
        l_element = f_ixml_data_doc->create_simple_element(
        name = 'S' parent = f_series ).
        l_element->if_ixml_node~set_value( vlvalor ).
      ENDIF.
    ENDLOOP.
    vlserie = 'Consumido'.
    scat = 'COIN'.
  ENDDO.
  REFRESH it_cosp.
  it_cosp[] = it_cosp_copy[].

* create ostream (into string variable) and render document into stream
  f_ostream = fo_ixml_sf->create_ostream_xstring( f_xstring ).
  f_ixml_data_doc->render( f_ostream ). "here f_xstring is filled

  "set data to chart
  go_chart->set_data( xdata = f_xstring ).

  "get customizing from Standard text

  "f_xstring = chart_customizing using
  PERFORM chart_customizing USING
        'ZGRAPH_PTO_CECO'
        'Analisis Presupuesto - CeCo'
        'Grupo Porres'
        'Centros de Coste'
  CHANGING
    f_xstring
    .
  "set customizing
  go_chart->set_customizing( xdata = f_xstring ).
  graph_type = 'SOC'.
  "render chart
  go_chart->render( ).

ENDFORM.                    " GRAPH_PTO_BYCECO
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_all.
  FIELD-SYMBOLS: <fs_wa>    TYPE any,<checkbox> TYPE any.

  IF gt_zco_tt_planpresm IS NOT INITIAL.

    LOOP AT gt_zco_tt_planpresm ASSIGNING <fs_wa> WHERE solped EQ space.
      ASSIGN COMPONENT 'BEKNZ' OF STRUCTURE <fs_wa> TO <linea>.

      <linea> = 'X'.

    ENDLOOP.
    PERFORM update_checkbox.
    gv_selectall = 'X'.
  ENDIF.
ENDFORM.                    " SELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  limpiar_checkbox
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM limpiar_checkbox.
  FIELD-SYMBOLS: <fs_wa>    TYPE any,<checkbox> TYPE any.

  IF gt_zco_tt_planpresm IS NOT INITIAL.

    LOOP AT gt_zco_tt_planpresm ASSIGNING <fs_wa> WHERE solped EQ space.
      ASSIGN COMPONENT 'BEKNZ' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = ''.

    ENDLOOP.
    PERFORM update_checkbox.
    gv_selectall = ''.
  ENDIF.
ENDFORM.                    " SELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  UPDATE_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM update_checkbox.

  stable-row  = 'X'.
  stable-col = 'X'.

  CALL METHOD gref_alvgrid102->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = stable.


ENDFORM.                    " UPDATE_CHECKBOX

*&---------------------------------------------------------------------*
*&      Form  select_all_ajuste
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM select_all_ajuste.
  FIELD-SYMBOLS: <fs_wa>    TYPE any,<checkbox> TYPE any.

  IF it_ajustepres IS NOT INITIAL.

    LOOP AT it_ajustepres ASSIGNING <fs_wa> WHERE autorizado NE 'X'.
      ASSIGN COMPONENT 'CHECK' OF STRUCTURE <fs_wa> TO <linea>.

      <linea> = 'X'.

    ENDLOOP.
    PERFORM update_checkbox.
    gv_selectall = 'X'.
  ENDIF.
ENDFORM.                    "select_all_ajuste

*&---------------------------------------------------------------------*
*&      Form  limpiar_checkbox_ajuste
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM limpiar_checkbox_ajuste.
  FIELD-SYMBOLS: <fs_wa>    TYPE any,<checkbox> TYPE any.

  IF it_ajustepres IS NOT INITIAL.

    LOOP AT it_ajustepres ASSIGNING <fs_wa> .
      ASSIGN COMPONENT 'CHECK' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = ''.

    ENDLOOP.
    PERFORM update_checkbox.
    gv_selectall = ''.
  ENDIF.
ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  GET_CECOS_CLEAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_cecos_clean .

  REFRESH: it_kostl, it_only_kostl.

  DATA it_only_kostl TYPE STANDARD TABLE OF st_kostl.

  SELECT p~idpres c~kostl t~ktext c~objnr p~kstar
  INTO TABLE it_kostl
  FROM csks AS c
  INNER JOIN cskt AS t ON t~kostl EQ c~kostl AND t~spras EQ 'S'
  AND  t~datbi GE sy-datum
*    INNER JOIN cosp AS co
*    ON co~objnr EQ c~objnr
  INNER JOIN zco_tt_planpres AS p
  ON p~kostl EQ c~kostl AND tipmod EQ 'F'
  WHERE c~kostl IN s6_kostl
  AND c~datbi GE sy-datum
  AND p~gjahr EQ p6_gjahr
  "AND co~vrgng EQ 'RKP1'
.
  SORT it_kostl BY kostl kstar.
  DELETE ADJACENT DUPLICATES FROM it_kostl COMPARING kostl kstar.

  LOOP AT it_kostl INTO wa_kostl.
    wa_kostl-status  = '@09@'.
    wa_kostl-descripcion = 'Preparado...'.
    MODIFY it_kostl FROM wa_kostl TRANSPORTING status descripcion
    WHERE kostl = wa_kostl-kostl.
  ENDLOOP.


ENDFORM.                    " GET_CECOS_CLEAN
*&---------------------------------------------------------------------*
*&      Form  CONTAINERS_FREE103
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM containers_free103 .
  IF NOT gref_alvgrid103 IS INITIAL.
    " destroy tree container (detroys contained tree control, too)
    CALL METHOD gref_alvgrid103->free
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
    IF sy-subrc <> 0.
      "MESSAGE A000.
    ENDIF.


    CALL METHOD gref_ccontainer103->free
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
    IF sy-subrc <> 0.
      "MESSAGE A000.
    ENDIF.

    CLEAR gref_ccontainer103.
    CLEAR gref_alvgrid103.
  ENDIF.
ENDFORM.                    " CONTAINERS_FREE103
*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELDCAT103
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_fieldcat103 .
  DATA ls_fieldcat TYPE lvc_s_fcat.
  CLEAR fieldcat102.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KOSTL'.
  ls_fieldcat-outputlen = 6.
  ls_fieldcat-scrtext_m = 'Centro de Coste'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KTEXT'.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-scrtext_m = 'Descripción'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-outputlen = 4.
  ls_fieldcat-scrtext_m = 'Status'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DESCRIPCION'.
  ls_fieldcat-outputlen = 100.
  ls_fieldcat-scrtext_m = '           '.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

ENDFORM.                    " CREATE_FIELDCAT103
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_TREE103
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ZCO_TT_PLANPRESM  text
*      -->P_FIELDCAT102  text
*      -->P_0085   text
*----------------------------------------------------------------------*
FORM display_alv103  USING  p_it_outtable TYPE STANDARD TABLE
    p_fieldcat TYPE lvc_t_fcat
    container TYPE char20.


  it_layout-sel_mode = 'A'.
  it_layout-no_rowmark = 'X'.
  it_layout-cwidth_opt = 'X'.

  TRY.
      CALL METHOD gref_alvgrid103->free.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.

  TRY.
      CALL METHOD gref_ccontainer103->free.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.


  CREATE OBJECT gref_ccontainer103
    EXPORTING
      container_name              = container
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  CREATE OBJECT gref_alvgrid103
    EXPORTING
      i_parent          = gref_ccontainer103
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.


  CALL METHOD gref_alvgrid103->set_table_for_first_display
    EXPORTING
      is_layout                     = it_layout
*     it_toolbar_excluding          = lt_excl_func1
    CHANGING
      it_outtab                     = p_it_outtable[]
      it_fieldcatalog               = p_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  CALL METHOD gref_alvgrid103->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.


  CREATE OBJECT event_handlerdyn103.

  SET HANDLER event_handlerdyn103->handle_user_command FOR gref_alvgrid103.
  SET HANDLER event_handlerdyn103->handle_toolbar FOR gref_alvgrid103.
*  SET HANDLER event_handlerDyn102->on_link_click FOR gref_alvgrid102.

  CALL METHOD gref_alvgrid103->set_toolbar_interactive.

**** REGISTRO DE BOTON ENTER
*  CALL METHOD gref_alvgrid102->register_edit_event
*  EXPORTING
*    i_event_id = cl_gui_alv_grid=>mc_evt_enter.

*  CREATE OBJECT grid_handlerdyn102.
*  SET HANDLER grid_handlerdyn102->handle_data_changed FOR gref_alvgrid102.



ENDFORM.                    " DISPLAY_ALV_TREE103
*&---------------------------------------------------------------------*
*&      Form  HANDLE_USER_COMMAND103
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM handle_user_command103  USING    p_e_ucomm.

  CASE p_e_ucomm.
    WHEN 'LIMPIAR'.
      PERFORM limpiar_cecos.
  ENDCASE.
ENDFORM.                    " HANDLE_USER_COMMAND103
*&---------------------------------------------------------------------*
*&      Form  LIMPIAR_CECOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM limpiar_cecos .
  DATA lv_answer TYPE c.
  TYPES: BEGIN OF st_kostlaut,
           kostl      TYPE kostl,
           autorizado TYPE c,
         END OF st_kostlaut.

  DATA: it_kostlaut TYPE STANDARD TABLE OF st_kostlaut,
        wa_kostlaut LIKE LINE OF it_kostlaut.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Limpieza de Centros de Coste'
      text_question  = 'Confirme la Limpieza de los CeCos Mostrados'
      text_button_1  = 'SI'(005)
      icon_button_1  = 'ICON_OKAY'
      text_button_2  = 'NO'(006)
      icon_button_2  = 'ICON_CANCEL'
      default_button = '2'
      start_column   = 25
      start_row      = 6
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF lv_answer EQ '1'.

    SELECT kostl autorizado INTO TABLE it_kostlaut
    FROM zco_tt_planpres
    FOR ALL ENTRIES IN it_only_kostl
    WHERE kostl EQ it_only_kostl-kostl
    AND autorizado = 'X' AND  kokrs = p6_kokrs
    AND gjahr = p6_gjahr AND tipmod = 'F'.

    LOOP AT it_kostlaut INTO wa_kostlaut.
      CLEAR wa_only_kostl.
      wa_only_kostl-status = '@0A@'. "Error
      wa_only_kostl-descripcion = 'Existen Materiales Autorizados'.
      MODIFY it_only_kostl FROM wa_only_kostl TRANSPORTING status descripcion
      WHERE kostl = wa_kostlaut-kostl.

    ENDLOOP.

    LOOP AT it_only_kostl INTO wa_only_kostl WHERE status NE '@0A@'.
      PERFORM aplicar_limpieza_cecos USING wa_only_kostl-kostl.
    ENDLOOP.

    CALL METHOD gref_alvgrid103->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'.

    MESSAGE 'La tarea ha sido finalizada' TYPE 'S'.
  ENDIF.
ENDFORM.                    " LIMPIAR_CECOS
*&---------------------------------------------------------------------*
*&      Form  APLICAR_LIMPIEZA_CECOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM aplicar_limpieza_cecos USING p_kostl TYPE kostl.

  DATA: i_rku01_cur LIKE rku01_cur, "Interfase de planif.: grupos de campos de moneda traspasados
        itrku01g    TYPE TABLE OF rku01g WITH HEADER LINE, "Traspaso de datos CO: Interfase costes con valores totales
        irku01ja    TYPE TABLE OF rku01ja WITH HEADER LINE. "Traspaso de datos CO: Interfase costes por año

  DATA: headerinfo     LIKE bapiplnhdr,
        indexstructure LIKE bapiacpstru OCCURS 0 WITH HEADER LINE,
        coobject       LIKE bapipcpobj OCCURS 0 WITH HEADER LINE,
        pervalue       LIKE bapipcpval OCCURS 0 WITH HEADER LINE,
        return         LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  DATA: lv_bukrs     TYPE bukrs, lv_kostl TYPE kostl,lv_lines TYPE i, lv_indicador,
        lv_statustx  TYPE char20.
  DATA: tr_kostl TYPE RANGE OF kostl,
        wr_kostl LIKE LINE OF tr_kostl.

  DATA: indice        TYPE obj_indx, lv_autorizado TYPE c.
  FIELD-SYMBOLS: <itab> TYPE STANDARD TABLE,
                 <wa>   TYPE any.

  REFRESH: itrku01g,
  irku01ja,
  it_collect,
  indexstructure,
  coobject,
  pervalue.

  indice = '000000'.

  CLEAR headerinfo.

  REFRESH: return,
  indexstructure,
  coobject,
  pervalue.

  LOOP AT it_kostl INTO wa_kostl WHERE kostl EQ p_kostl.
*  Grabamos posiciones
*  ********************************************************
    indice = indice + 1.
    headerinfo-co_area = p6_kokrs.
    headerinfo-fisc_year = p6_gjahr.
    headerinfo-period_from = 1. "periodo de
    headerinfo-period_to = 12. "periodo a
    headerinfo-version = '0'. "version

    headerinfo-plan_currtype = 'T'.

*    indice de structura
    indexstructure-object_index = indice.
    indexstructure-value_index = indice.
    APPEND indexstructure.
*********************************************************
**********Objeto CO
    coobject-object_index = indice.
    coobject-costcenter = wa_kostl-kostl.
    APPEND coobject.
*********************************************************
    pervalue-value_index = indice.
    pervalue-cost_elem = wa_kostl-kstar.
    pervalue-trans_curr = 'MXN'.
    pervalue-fix_val_per01 = 0.
    pervalue-fix_val_per02 = 0.
    pervalue-fix_val_per03 = 0.
    pervalue-fix_val_per04 = 0.
    pervalue-fix_val_per05 = 0.
    pervalue-fix_val_per06 = 0.
    pervalue-fix_val_per07 = 0.
    pervalue-fix_val_per08 = 0.
    pervalue-fix_val_per09 = 0.
    pervalue-fix_val_per10 = 0.
    pervalue-fix_val_per11 = 0.
    pervalue-fix_val_per12 = 0.
    APPEND pervalue.

  ENDLOOP.
*              ******  BAPI PARA CARGA DE PLAN DE PRESUPUESTO
  CALL FUNCTION 'BAPI_COSTACTPLN_POSTPRIMCOST'
    EXPORTING
      headerinfo     = headerinfo
      delta          = '' " = 'X' los valores nuevos y existentes se totalizan. '' se reemplazan
    TABLES
      indexstructure = indexstructure
      coobject       = coobject
      pervalue       = pervalue
      return         = return.

  " Se hace commit
  IF sy-subrc = 0.
    IF return[] IS NOT INITIAL.
      wa_only_kostl-status = '@0A@'. "Rojo
      READ TABLE return INTO DATA(wa_error) WITH KEY type = 'E'.
      CONCATENATE 'Error interno' wa_error-message_v1 wa_error-message_v2
        INTO wa_only_kostl-descripcion  SEPARATED BY space.
      MODIFY it_only_kostl FROM wa_only_kostl TRANSPORTING status descripcion WHERE kostl EQ p_kostl.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*        IMPORTING
*          return =                  " Return Messages
        .

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'                 " Use of Command `COMMIT AND WAIT`
*        IMPORTING
*         return =                  " Return Messages
        .

      UPDATE zco_tt_planpres SET tipmod = 'O' cecoaut = 'F' WHERE kostl = p_kostl AND kokrs = p6_kokrs
      AND gjahr = p6_gjahr.

      wa_only_kostl-status = '@08@'. "Verde
      wa_only_kostl-descripcion = 'Limpiado Correctamente'.
      MODIFY it_only_kostl FROM wa_only_kostl TRANSPORTING status descripcion WHERE kostl EQ p_kostl.
    ENDIF.

    CALL METHOD gref_alvgrid103->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'.

  ENDIF.


ENDFORM.                    " APLICAR_LIMPIEZA_CECOS
