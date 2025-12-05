*&---------------------------------------------------------------------*
*& Include zco_re_costo_prod_real_jhv_fun General
*&---------------------------------------------------------------------*

FORM set_textos. "funciones
  IF gv_tipore EQ 'ENGORDA'.
    gv_txtunit = 'Unitario'.
    gv_txtcostodir = 'COSTOS DIRECTOS'.
    gv_txtcostoindir = 'COSTOS INDIRECTOS'.
    gv_txtcostorecup = 'COSTO RECUPERACIONES'.
    gv_txttotalcostprod = 'TOTAL COSTO PRODUCCIÓN'.
    gv_txttotalpollosp = 'TOTAL POLLOS PRODUCIDOS'.
    gv_txttotalkilosp = 'TOTAL KILOS PRODUCIDOS'.

  ELSEIF gv_tipore EQ 'ALIMENTO'.
    gv_txtunit = 'Por Tonelada.'.
    gv_txtcostodir = 'COSTOS DIRECTOS'.
    gv_txtcostoindir = 'COSTOS INDIRECTOS'.
    gv_txtcostorecup = 'COSTO RECUPERACIONES'.
    gv_txttotalcostprod = 'TOTAL COSTO PRODUCCIÓN'.
    gv_txttotalcostomermas = '*'.
    gv_txttotalpollosp = '*'.
    gv_txttotalkilosp = '*'.
  ELSEIF gv_tipore EQ 'PPA'.
    gv_txtunit = 'Unitario'.
    gv_txtcostodir = 'COSTOS DIRECTOS'.
    gv_txtcostoindir = 'COSTOS INDIRECTOS'.
    gv_txtcostorecup = '*'.
    gv_txttotalcostprod = 'TOTAL COSTO PRODUCCIÓN'.
    gv_txttotalpollosp = '*'."'POLLOS RECIBOS DE GRANJA'. "
    gv_txttotalkilosp = '*'."'KILOS RECIBOS DE GRANJA'. "
  ELSEIF gv_tipore EQ 'DEPOSITOS'.
    gv_txtunit = 'Unitario'.
    gv_txtcostodir = 'COSTOS DIRECTOS'.
    gv_txtcostoindir = 'COSTOS INDIRECTOS'.
    gv_txtcostorecup = '*'.
    gv_txttotalcostprod = 'TOTAL COSTO PRODUCCIÓN'.
    gv_txttotalpollosp = 'POLLOS RECIBOS DE GRANJA'.
    gv_txttotalkilosp = 'KILOS RECIBOS DE GRANJA'.
  ELSEIF gv_tipore EQ 'EMPACADORA'.
    gv_txtunit = 'Unitario'.
    gv_txtcostodir = 'COSTOS DIRECTOS'.
    gv_txtcostoindir = 'COSTOS INDIRECTOS'.
    gv_txtcostorecup = '*'.
    gv_txttotalcostprod = 'TOTAL COSTO PRODUCCIÓN'.
    gv_txttotalcostomermas = '*'.
    gv_txttotalpollosp = '*'.
    gv_txttotalkilosp = '*'.
  ELSEIF gv_tipore EQ 'POSTURA'.
    gv_txtunit = 'Unitario'.
    gv_txtcostodir = 'COSTOS DIRECTOS'.
    gv_txtcostoindir = 'COSTOS INDIRECTOS'.
    gv_txtcostorecup = 'HUEVO RECIBIDO DE GRANJA'.
    gv_txttotalcostprod = 'TOTAL COSTO PRODUCCIÓN'.
    gv_txttotalcostomermas = '*'.
    gv_txttotalpollosp = '*'.
    gv_txttotalkilosp = '*'.
  ELSEIF gv_tipore EQ 'CRIANZA'.
    gv_txtunit = 'Unitario'.
    gv_txtcostodir = 'COSTOS DIRECTOS'.
    gv_txtcostoindir = 'COSTOS INDIRECTOS'.
    gv_txtcostorecup = '*'.
    gv_txttotalcostprod = 'TOTAL COSTO PRODUCCIÓN'.
    gv_txttotalcostomermas = '*'.
    gv_txttotalpollosp = '*'.
    gv_txttotalkilosp = '*'.
  ELSEIF gv_tipore EQ 'INCUBADORA'.
    gv_txtunit = 'Unitario'.
    gv_txtcostodir = 'COSTOS DIRECTOS'.
    gv_txtcostoindir = 'COSTOS INDIRECTOS'.
    gv_txtcostorecup = 'SUBPRODUCTOS'.
    gv_txttotalcostprod = 'TOTAL COSTO PRODUCCIÓN'.
    gv_txttotalcostomermas = '*'.
    gv_txttotalpollosp = '*'.
    gv_txttotalkilosp = '*'.

  ENDIF.
ENDFORM.

FORM filter_ppa.
  TYPES: BEGIN OF st_dauat,
           auart TYPE auart,
           aprof TYPE aprof,
           txt   TYPE txt,
         END OF st_dauat.

  DATA: it_clorden TYPE STANDARD TABLE OF st_dauat,
        wa_clorden LIKE LINE OF it_clorden,
        lv_hktid   TYPE t012k-hktid,
        i_return   LIKE ddshretval OCCURS 0 WITH HEADER LINE.


  SELECT t003o~auart,aprof, t003p~txt
  INTO TABLE @it_clorden
  FROM t003o
  INNER JOIN T003p ON t003p~auart = t003o~auart
  WHERE aprof EQ 'PP01'
  AND t003o~auart IN (
  'PA00','PA01','PA02','PA03','PA04','PP01','PP02',
  'PP04','PPC1','PPK1' )
  AND t003p~spras = 'S'
  .

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'AUART'
      window_title    = 'Clase de Orden'
      value_org       = 'S'
    TABLES
      value_tab       = it_clorden
      return_tab      = i_return
    EXCEPTIONS "
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  READ TABLE i_return INDEX 1.
  MOVE i_return-fieldval TO p_clord.

ENDFORM.

FORM get_ordenes_fin.

  CREATE OBJECT obj_engorda.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat
        .
  DATA: vl_rgwerks  TYPE RANGE OF t001w-werks,
        vl_wrgwerks LIKE LINE OF vl_rgwerks.


  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'EN01'.
  APPEND wa_rgdauat TO vl_rgdauat.


  obj_engorda->get_aufnr_cte(
    EXPORTING
      p_gjahr   =  p_gjahr
      p_popers  = vl_rgpoper
      p_clorder = vl_rgdauat
      p_tipo    = 'ENGORDA'
    CHANGING
      i_tabla   = it_aufnr_end
  ).




  SORT it_aufnr_end BY aufnr getri.

  IF p_werks IS NOT INITIAL.
    DELETE it_aufnr_end WHERE pwerk NOT IN p_werks.
  ENDIF.

  IF p_zona IS NOT INITIAL.
    SELECT werks INTO TABLE @DATA(it_werks)
    FROM t001w WHERE name2 EQ @p_zona.

    IF sy-subrc EQ 0.
      SORT it_werks BY werks.
      DELETE ADJACENT DUPLICATES FROM it_werks COMPARING werks.
      LOOP AT it_werks INTO DATA(wa_werks).
        vl_wrgwerks-sign = 'I'.
        vl_wrgwerks-option = 'EQ'.
        vl_wrgwerks-low = wa_werks-werks.
        APPEND vl_wrgwerks TO vl_rgwerks.
      ENDLOOP.

      DELETE it_aufnr_end WHERE pwerk NOT IN vl_rgwerks.
    ENDIF.
  ENDIF.



ENDFORM.

FORM get_ordenes_huevo.

  CREATE OBJECT obj_engorda.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat
        .
  DATA: vl_rgwerks  TYPE RANGE OF t001w-werks,
        vl_wrgwerks LIKE LINE OF vl_rgwerks.


  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PR02'.
  APPEND wa_rgdauat TO vl_rgdauat.


  obj_engorda->get_aufnr_cte(
    EXPORTING
      p_gjahr   =  p_gjahr
      p_popers  = vl_rgpoper
      p_clorder = vl_rgdauat
    CHANGING
      i_tabla   = it_aufnr_end
  ).




  SORT it_aufnr_end BY aufnr getri.

  IF p_werks IS NOT INITIAL.
    DELETE it_aufnr_end WHERE pwerk NOT IN p_werks.
  ENDIF.

ENDFORM.

FORM get_ordenes_crianza.

  CREATE OBJECT obj_engorda.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat,
        vl_rgwerks TYPE RANGE OF afpo-dwerk,
        wa_rgwerks LIKE LINE OF vl_rgwerks
        .

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  IF p_werks-high IS INITIAL.

    LOOP AT p_werks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = p_werks-low.
      APPEND wa_rgwerks TO vl_rgwerks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'BT'.
    wa_rgwerks-low = p_werks-low.
    wa_rgwerks-low = p_werks-high.
    APPEND wa_rgwerks TO vl_rgwerks.
  ENDIF.




  IF ( c_cria EQ abap_false AND c_recria EQ abap_false )
     OR ( c_cria EQ abap_true AND c_recria EQ abap_true ).

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'CR01'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PR01'.
    APPEND wa_rgdauat TO vl_rgdauat.

  ELSE.

    IF c_cria EQ abap_true.

      wa_rgdauat-sign = 'I'.
      wa_rgdauat-option = 'EQ'.
      wa_rgdauat-low = 'CR01'.
      APPEND wa_rgdauat TO vl_rgdauat.
    ELSEIF c_recria EQ abap_true.

      wa_rgdauat-sign = 'I'.
      wa_rgdauat-option = 'EQ'.
      wa_rgdauat-low = 'PR01'.
      APPEND wa_rgdauat TO vl_rgdauat.

    ENDIF.
  ENDIF.


  obj_engorda->get_aufnr_cte(
    EXPORTING
      p_gjahr   =  p_gjahr
      p_popers  = vl_rgpoper
      p_clorder = vl_rgdauat
      p_werks = vl_rgwerks
    CHANGING
      i_tabla   = it_aufnr_end
  ).

  SORT it_aufnr_end BY aufnr getri.



ENDFORM.


FORM get_ordenes_incubadora USING p_clorden TYPE aufart.

  CREATE OBJECT obj_engorda.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat
        .

  DATA: vl_rgwerks  TYPE RANGE OF afpo-dwerk,
        vl_wrgwerks LIKE LINE OF vl_rgwerks.


  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = p_clorden.
  APPEND wa_rgdauat TO vl_rgdauat.


  IF p_werks-high IS INITIAL.
    LOOP AT p_werks.
      vl_wrgwerks-sign = 'I'.
      vl_wrgwerks-option = 'EQ'.
      vl_wrgwerks-low = p_werks-low.
      APPEND vl_wrgwerks TO vl_rgwerks.

    ENDLOOP.
  ELSE.
    vl_wrgwerks-sign = 'I'.
    vl_wrgwerks-option = 'BT'.
    vl_wrgwerks-low = p_werks-low.
    vl_wrgwerks-high = p_werks-high.
    APPEND vl_wrgwerks TO vl_rgwerks.
  ENDIF.




  obj_engorda->get_aufnr_cte(
    EXPORTING
      p_gjahr   =  p_gjahr
      p_popers  = vl_rgpoper
      p_clorder = vl_rgdauat
      p_tipo    = 'INCUBADORA'
      p_werks   = vl_rgwerks
    CHANGING
      i_tabla   = it_aufnr_end
  ).

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  REFRESH vl_rgdauat.
  CLEAR wa_rgdauat.
  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'IN02'.
  APPEND wa_rgdauat TO vl_rgdauat.

  obj_engorda->get_aufnr_cte(
  EXPORTING
    p_gjahr   =  p_gjahr
    p_popers  = vl_rgpoper
    p_clorder = vl_rgdauat
    p_tipo    = 'INCUBADORA'
    p_werks   = vl_rgwerks
  CHANGING
    i_tabla   = it_aufnr_in02
).

  SORT it_aufnr_in02 BY aufnr getri.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  REFRESH vl_rgdauat.
  CLEAR wa_rgdauat.
  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = '0100'.
  APPEND wa_rgdauat TO vl_rgdauat.

  obj_engorda->get_aufnr_cte(
  EXPORTING
    p_gjahr   =  p_gjahr
    p_popers  = vl_rgpoper
    p_clorder = vl_rgdauat
    p_tipo    = 'INCUBADORA'
    p_werks   = vl_rgwerks
  CHANGING
    i_aufnr   = it_aufnr_0100

).

  SORT it_aufnr_in02 BY aufnr getri.



ENDFORM.

FORM get_ordenes_emp .

  CREATE OBJECT obj_engorda.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat
        .

  SORT so_poper BY low.

  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  obj_engorda->get_aufnr_cte(
    EXPORTING
      p_gjahr   =  p_gjahr
      p_popers  = vl_rgpoper
      p_clorder = vl_rgdauat
    CHANGING
      i_tabla   = it_aufnr_end
  ).

  SORT it_aufnr_end BY aufnr getri.


  DELETE it_aufnr_end WHERE pwerk NE 'PP31'.

  IF it_aufnr_end IS NOT INITIAL.

  ENDIF.


ENDFORM.

FORM create_alv_option .

  DATA: li_spopli TYPE STANDARD TABLE OF spopli,
        wa_spopli TYPE spopli,
        lv_answer TYPE c.

  CLEAR: rg_aufnr_det, rg_matnr_det,rg_racct_det.

* Types
  DATA:
    t_fieldcat TYPE slis_t_fieldcat_alv,
    t_events   TYPE slis_t_event.

* Workareas
  DATA:
    w_fieldcat TYPE slis_fieldcat_alv,
    w_events   TYPE slis_alv_event,
    w_layout   TYPE slis_layout_alv.


  CLEAR: w_fieldcat.

  w_fieldcat-fieldname = 'MATNR'.
  w_fieldcat-tabname   = 'it_matnr'.
  w_fieldcat-seltext_m = 'Material'.
  APPEND w_fieldcat TO t_fieldcat.
  CLEAR w_fieldcat.
  w_fieldcat-fieldname = 'MAKTX'.
  w_fieldcat-tabname   = 'it_matnr'.
  w_fieldcat-seltext_m = 'Descripción'.
  w_fieldcat-seltext_l = 'Descripción'.
  w_fieldcat-outputlen = 60.
  APPEND w_fieldcat TO t_fieldcat.




  TYPES: BEGIN OF st_matnr,
           checkbox,
           matnr    TYPE matnr,
           maktx    TYPE maktx,
           aufnr    TYPE aufnr,
         END OF st_matnr.

  DATA: it_matnr TYPE STANDARD TABLE OF st_matnr,
        wa_matnr LIKE LINE OF it_matnr.




  IF it_ppa_det IS NOT INITIAL.

    DATA(list_matnr) = it_ppa_det.
    SORT list_matnr BY racct.

    wrg_racct-option = 'EQ'.
    wrg_racct-sign = 'I'.
    wrg_racct-low = '0504025014'.
    APPEND wrg_racct TO rg_racct_det.

    wrg_racct-option = 'EQ'.
    wrg_racct-sign = 'I'.
    wrg_racct-low = '0504025192'.
    APPEND wrg_racct TO rg_racct_det.

    wrg_racct-option = 'EQ'.
    wrg_racct-sign = 'I'.
    wrg_racct-low = '0504025030'.
    APPEND wrg_racct TO rg_racct_det.

    wrg_racct-option = 'EQ'.
    wrg_racct-sign = 'I'.
    wrg_racct-low = '0504025111'.
    APPEND wrg_racct TO rg_racct_det.


    DELETE list_matnr WHERE racct NOT IN rg_racct_det.
    SORT list_matnr BY matnr.
    "DELETE ADJACENT DUPLICATES FROM list_matnr COMPARING matnr aufnr.
    DELETE list_matnr WHERE matnr IS INITIAL.
    SORT list_matnr BY maktx.

    LOOP AT list_matnr INTO DATA(temp).
      MOVE-CORRESPONDING temp TO wa_matnr.
      APPEND wa_matnr TO it_matnr.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM it_matnr COMPARING matnr.

    IF it_matnr IS NOT INITIAL.

      CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
        EXPORTING
          i_title              = 'Filtro por Material Producido'
          i_tabname            = 'it_matnr'
          i_checkbox_fieldname = 'CHECKBOX' "Checkbox field defined in the internal table
          it_fieldcat          = t_fieldcat
          i_callback_program   = sy-repid
        TABLES
          t_outtab             = it_matnr.

      IF sy-subrc EQ 0.

        DELETE it_matnr WHERE checkbox NE 'X'.

        REFRESH rg_aufnr_det.
        REFRESH rg_matnr_det.
        LOOP AT it_matnr INTO wa_matnr.
          LOOP AT list_matnr INTO DATA(wa_matnr2) WHERE matnr = wa_matnr-matnr.
            wrg_aufnr-low = wa_matnr2-aufnr.
            wrg_aufnr-sign = 'I'.
            wrg_aufnr-option = 'EQ'.
            APPEND wrg_aufnr TO rg_aufnr_det.
          ENDLOOP.
        ENDLOOP.

        SORT rg_aufnr_det BY low.
        DELETE ADJACENT DUPLICATES FROM rg_aufnr_det COMPARING low.


        LOOP AT it_matnr INTO wa_matnr.

          wrg_matnr-low = wa_matnr-matnr.
          wrg_matnr-sign = 'I'.
          wrg_matnr-option = 'EQ'.
          APPEND wrg_matnr TO rg_matnr_det.
        ENDLOOP.



        IF rg_aufnr_det IS NOT INITIAL.
          DELETE it_ppa_det WHERE aufnr NOT IN rg_aufnr_det.
          "DELETE it_ppa_det WHERE matnr NOT IN rg_matnr.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE 'Producción de semiterminados no utilizados' TYPE 'S'.
    ENDIF.

  ENDIF.
ENDFORM.

FORM get_ordenes_alim.

  CREATE OBJECT obj_engorda.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat
        .

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'AL01'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'AL02'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'AL03'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'AL10'.
  APPEND wa_rgdauat TO vl_rgdauat.

  obj_engorda->get_aufnr_cte(
    EXPORTING
      p_gjahr   =  p_gjahr
      p_popers  = vl_rgpoper
      p_clorder = vl_rgdauat
    CHANGING
      i_tabla   = it_aufnr_end
  ).

  SORT it_aufnr_end BY aufnr getri.

  IF p_werks IS NOT INITIAL.
    DELETE it_aufnr_end WHERE pwerk NOT IN p_werks.
  ENDIF.

  IF p_werks-high IS INITIAL.
    IF vl_solo_maquila EQ abap_true AND  p_werks-low NE 'PA01'.
      IF p_werks IS NOT INITIAL.
        REFRESH it_aufnr_end.
      ENDIF.
    ENDIF.
  ELSE.
    DATA vl_pa01.

    vl_pa01 = abap_false.
    LOOP AT p_werks.
      IF p_werks-low EQ 'PA01'.
        vl_pa01 = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF vl_solo_maquila EQ abap_true AND  vl_pa01 = abap_false.
      IF p_werks IS NOT INITIAL.
        REFRESH it_aufnr_end.
      ENDIF.
    ENDIF.


  ENDIF.

ENDFORM.


FORM get_ordenes_dep.

  CREATE OBJECT obj_engorda.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat
        .

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PA05'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PP01'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PP02'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PP04'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PPC1'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PPK1'.
  APPEND wa_rgdauat TO vl_rgdauat.

  obj_engorda->get_aufnr_cte(
    EXPORTING
      p_gjahr   =  p_gjahr
      p_popers  = vl_rgpoper
      p_clorder = vl_rgdauat
    CHANGING
      i_tabla   = it_aufnr_end
  ).

  SORT it_aufnr_end BY aufnr getri.

  REFRESH vl_rgdauat.

  IF p_werks IS INITIAL.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'BT'.
    wa_rgdauat-low = 'PP01'.
    wa_rgdauat-high = 'PP03'.
    APPEND wa_rgdauat TO vl_rgdauat.

    DELETE it_aufnr_end WHERE pwerk IN vl_rgdauat.
    REFRESH vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'BT'.
    wa_rgdauat-low = 'PP31'.
    wa_rgdauat-high = 'PP34'.
    APPEND wa_rgdauat TO vl_rgdauat.
    DELETE it_aufnr_end WHERE pwerk IN vl_rgdauat.

  ELSE.

    IF p_werks-high IS NOT INITIAL.
      wa_rgdauat-sign = 'I'.
      wa_rgdauat-option = 'BT'.
      wa_rgdauat-low = p_werks-low.
      wa_rgdauat-high = p_werks-high.
      APPEND wa_rgdauat TO vl_rgdauat.
    ELSE.
      LOOP AT p_werks.
        wa_rgdauat-sign = 'I'.
        wa_rgdauat-option = 'EQ'.
        wa_rgdauat-low = p_werks-low.
        APPEND wa_rgdauat TO vl_rgdauat.
      ENDLOOP.
    ENDIF.
    DELETE it_aufnr_end WHERE pwerk NOT IN vl_rgdauat.
  ENDIF.

ENDFORM.

FORM get_ordenes_ppa.
  CREATE OBJECT obj_engorda.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat

        .

  DATA wa_materiales LIKE LINE OF it_materiales.


  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  IF p_clord IS INITIAL.
    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA00'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA01'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA02'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA03'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PA04'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PP01'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PP02'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PP04'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PPC1'.
    APPEND wa_rgdauat TO vl_rgdauat.

    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = 'PPK1'.
    APPEND wa_rgdauat TO vl_rgdauat.
  ELSE.
    REFRESH vl_rgdauat.
    wa_rgdauat-sign = 'I'.
    wa_rgdauat-option = 'EQ'.
    wa_rgdauat-low = p_clord.
    APPEND wa_rgdauat TO vl_rgdauat.
  ENDIF.

  obj_engorda->get_aufnr_cte(
    EXPORTING
      p_gjahr   =  p_gjahr
      p_popers  = vl_rgpoper
      p_clorder = vl_rgdauat
    CHANGING
      i_tabla   = it_aufnr_end
  ).

  SORT it_aufnr_end BY aufnr getri.
*  it_aufnr_bk_ppa[] = it_aufnr_end[].
*
*  LOOP AT it_aufnr_end INTO DATA(wa_aufnr).
*    wa_materiales-aufnr = wa_aufnr-aufnr.
*    wa_materiales-matnr = wa_aufnr-plnbez.
*    APPEND wa_materiales TO it_materiales.
*  ENDLOOP.
*
*  SORT it_materiales BY matnr.
ENDFORM.

FORM get_ordenes_ppa_detalle.
  CREATE OBJECT obj_engorda.
  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgdauat TYPE RANGE OF afpo-dauat,
        wa_rgdauat LIKE LINE OF vl_rgdauat,
        rg_werks   TYPE RANGE OF afpo-dwerk,
        wa_rgwerks LIKE LINE OF rg_werks.
  .

  DATA wa_materiales LIKE LINE OF it_materiales.


  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  "IF p_clord IS INITIAL.
  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PA00'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PA01'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PA02'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PA03'.
  APPEND wa_rgdauat TO vl_rgdauat.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'PA04'.
  APPEND wa_rgdauat TO vl_rgdauat.
*  ELSE.
*    REFRESH vl_rgdauat.
*    wa_rgdauat-sign = 'I'.
*    wa_rgdauat-option = 'EQ'.
*    wa_rgdauat-low = p_clord.
*    APPEND wa_rgdauat TO vl_rgdauat.
*  ENDIF.

  wa_rgwerks-sign = 'I'.
  wa_rgwerks-option = 'EQ'.
  wa_rgwerks-low = 'PP01'.
  APPEND wa_rgwerks TO rg_werks.

  obj_engorda->get_aufnr_cte(
    EXPORTING
      p_gjahr   =  p_gjahr
      p_popers  = vl_rgpoper
      p_clorder = vl_rgdauat
      p_tipo    = 'PPA_DET'
      p_werks = rg_werks
    CHANGING
      i_tabla   = it_aufnr_ppa_det
  ).

  SORT it_aufnr_ppa_det BY aufnr getri.

  IF rg_aufnr_det IS NOT INITIAL.
    DELETE it_aufnr_ppa_det WHERE aufnr NOT IN rg_aufnr_det.
  ENDIF.

ENDFORM.

FORM get_metros2.
  DATA: rg_fechas    TYPE RANGE OF mseg-budat_mkpf,
        vl_rgdauat   TYPE RANGE OF afpo-dauat,
        wa_rgdauat   LIKE LINE OF vl_rgdauat,
        vl_mes(5)    TYPE c,vl_messt(5)  TYPE c,
        vl_totalmts2 TYPE menge_d,
        vl_find,
        vl_sytabix   TYPE sy-tabix.

  FIELD-SYMBOLS <fs_field> TYPE any.

  DATA it_aufnr_mts TYPE STANDARD TABLE OF zco_tt_aufnr_fin.

  DATA: vl_rgwerks  TYPE RANGE OF afpo-dwerk,
        vl_wrgwerks LIKE LINE OF vl_rgwerks.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.



  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  wa_rgdauat-sign = 'I'.
  wa_rgdauat-option = 'EQ'.
  wa_rgdauat-low = 'EN01'.
  APPEND wa_rgdauat TO vl_rgdauat.


  IF p_werks-high IS INITIAL.
    LOOP AT p_werks.
      vl_wrgwerks-sign = 'I'.
      vl_wrgwerks-option = 'EQ'.
      vl_wrgwerks-low = p_werks-low.
      APPEND vl_wrgwerks TO vl_rgwerks.

    ENDLOOP.
  ELSE.
    vl_wrgwerks-sign = 'I'.
    vl_wrgwerks-option = 'BT'.
    vl_wrgwerks-low = p_werks-low.
    vl_wrgwerks-high = p_werks-high.
    APPEND vl_wrgwerks TO vl_rgwerks.
  ENDIF.

  obj_engorda->get_aufnr_ablad(
    EXPORTING
      p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      p_clorder = vl_rgdauat
      p_werks = vl_rgwerks
      i_aufnr = it_aufnr_end
    CHANGING
      i_mts2   = it_aufnr_mts
  ).


  obj_engorda->calculate_dates(
CHANGING
p_rgfechas = rg_fechas
).



  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_mts[].
    DELETE aux_aufnr WHERE ablad IS INITIAL.
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_mts2-columna = vl_mes.
          wa_mts2-metros = wa_auxaufnr-ablad.
          COLLECT wa_mts2 INTO it_mts2.
      ENDCASE.

    ENDLOOP.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    vl_find = abap_false.
    IF it_mts2 IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_mts2 INTO wa_mts2.
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ 'Metros Cuadrados'.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_mts2-metros.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_mts2-metros.

            vl_find = abap_false.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = 'Metros Cuadrados'.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_mts2-metros.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_mts2-metros.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_mts2 INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = 'Metros Cuadrados'.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa_mts2-metros.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa_mts2-metros.

        ENDLOOP.
      ENDIF.
    ENDIF.
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    REFRESH it_mts2.
  ENDLOOP.

ENDFORM.

FORM get_kgs_pzas.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any.

  TYPES: BEGIN OF st_aux_out,
           concepto   TYPE wgbez60,
           /cwm/menge TYPE /cwm/menge,
           piezas     TYPE menge_d,
           month      TYPE dmbtr,
           monthst    TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.




  REFRESH it_aux_acum.


  IF it_aufnr_end IS NOT INITIAL.

    obj_engorda->get_kgs_pzas(
  EXPORTING
    i_aufnr  = it_aufnr_end
  CHANGING
    ch_kgs_pzas = it_kgs_pzas
  ).

  ENDIF.


  SORT it_kgs_pzas BY aufnr budat_mkpf.

  DELETE it_kgs_pzas WHERE racct NE '0504025192'.


  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_kgs_pzas INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            IF gv_tipore EQ 'ENGORDA'  OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            IF gv_tipore EQ 'ENGORDA'  OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            IF gv_tipore EQ 'ENGORDA'  OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA'.
              wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
              wa_aux_out-piezas = wa_recupera-menge.
            ELSEIF gv_tipore EQ 'ALIMENTO'.
              wa_aux_out-/cwm/menge = wa_recupera-menge / 1000.
              "wa_aux_out-piezas = wa_recupera-menge.
            ENDIF.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
    IF it_aux_out IS NOT INITIAL.
      APPEND INITIAL LINE TO it_aux_acum ASSIGNING <linea>.
      ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
      <fs_field> = vl_mes.
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

      LOOP AT it_aux_out INTO DATA(wa).
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-/cwm/menge.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-piezas.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-month.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-monthst.
        UNASSIGN <fs_field>.

      ENDLOOP.
    ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    REFRESH it_aux_out.
  ENDLOOP.



  ""----------------

ENDFORM.


FORM get_kgs_pzasPPA.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgmatkl  TYPE RANGE OF mara-matkl,
        wa_rgmatkl  LIKE LINE OF vl_rgmatkl.


  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any.

  TYPES: BEGIN OF st_aux_out,
           concepto   TYPE wgbez60,
           /cwm/menge TYPE /cwm/menge,
           piezas     TYPE menge_d,
           month      TYPE dmbtr,
           monthst    TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA: rg_werks   TYPE RANGE OF afpo-dwerk,
        wa_rgwerks LIKE LINE OF rg_werks.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.


  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  REFRESH it_aux_acum.



  IF p_werks-high IS INITIAL.

    LOOP AT p_werks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = p_werks-low.
      APPEND wa_rgwerks TO rg_werks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'BT'.
    wa_rgwerks-low = p_werks-low.
    wa_rgwerks-high = p_werks-high.
    APPEND wa_rgwerks TO rg_werks.
  ENDIF.


  SORT so_poper BY low.

  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  IF gv_tipore = 'PPA'.

    obj_engorda->get_kgs_pzas_procppa(
      EXPORTING
        p_gjahr     = p_gjahr
        p_popers    = vl_rgpoper
      CHANGING
        ch_kgs_pzas = it_kgs_pzas
    ).
  ELSEIF gv_tipore = 'DEPOSITOS'.

    wa_rgmatkl-sign = 'I'.
    wa_rgmatkl-option = 'EQ'.
    wa_rgmatkl-low = 'PT0001'.
    APPEND wa_rgmatkl TO vl_rgmatkl.

    IF vl_solo_vivo EQ abap_true.

      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '601'.
      APPEND wa_rgbwart TO vl_rgbwart.

      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '602'.
      APPEND wa_rgbwart TO vl_rgbwart.

      obj_engorda->get_kgs_pzas_dep(
        EXPORTING
          i_werks     = rg_werks
          i_matkl     = vl_rgmatkl
          i_rgbwart   = vl_rgbwart
        CHANGING
          ch_kgs_pzas = it_kgs_pzas
      ).
    ELSEIF vl_solo_caliente EQ abap_true.

      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '261'.
      APPEND wa_rgbwart TO vl_rgbwart.

      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '262'.
      APPEND wa_rgbwart TO vl_rgbwart.

      obj_engorda->get_kgs_pzas_dep(
          EXPORTING
            i_werks     = rg_werks
            i_matkl     = vl_rgmatkl
            i_aufnr     = it_aufnr_end
            i_rgbwart   = vl_rgbwart
          CHANGING
            ch_kgs_pzas = it_kgs_pzas
        ).
    ELSEIF vl_globald EQ abap_true.
      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '601'.
      APPEND wa_rgbwart TO vl_rgbwart.

      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '602'.
      APPEND wa_rgbwart TO vl_rgbwart.

      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '261'.
      APPEND wa_rgbwart TO vl_rgbwart.

      wa_rgbwart-sign = 'I'.
      wa_rgbwart-option = 'EQ'.
      wa_rgbwart-low = '262'.
      APPEND wa_rgbwart TO vl_rgbwart.

      obj_engorda->get_kgs_pzas_dep(
          EXPORTING
            i_werks     = rg_werks
            i_matkl     = vl_rgmatkl
            i_aufnr     = it_aufnr_end
            i_rgbwart   = vl_rgbwart
          CHANGING
            ch_kgs_pzas = it_kgs_pzas
        ).

    ENDIF.


  ENDIF.

  SORT it_kgs_pzas BY aufnr budat_mkpf.

  IF p_werks IS NOT INITIAL AND gv_tipore EQ 'DEPOSITOS'.
    DELETE it_kgs_pzas WHERE werks NOT IN p_werks.
  ENDIF.


  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_kgs_pzas[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
*      LOOP AT it_kgs_pzas INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          IF gv_tipore EQ 'ENGORDA'  OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          IF gv_tipore EQ 'ENGORDA'  OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          IF gv_tipore EQ 'ENGORDA'  OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.
            wa_aux_out-/cwm/menge = wa_recupera-/cwm/menge.
            wa_aux_out-piezas = wa_recupera-menge.
          ELSEIF gv_tipore EQ 'ALIMENTO'.
            wa_aux_out-/cwm/menge = wa_recupera-menge.
            "wa_aux_out-piezas = wa_recupera-menge.
          ENDIF.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

*      ENDLOOP.
    ENDLOOP.

    """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
    IF it_aux_out IS NOT INITIAL.
      APPEND INITIAL LINE TO it_aux_acum ASSIGNING <linea>.
      ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
      <fs_field> = vl_mes.
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

      LOOP AT it_aux_out INTO DATA(wa).
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-/cwm/menge.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-piezas.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-month.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = wa-monthst.
        UNASSIGN <fs_field>.

      ENDLOOP.
    ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    REFRESH it_aux_out.
  ENDLOOP.



  ""----------------

ENDFORM.

FORM get_mermas_maq.

  DATA: vl_rgbwart TYPE RANGE OF mseg-bwart,
        wa_rgbwart LIKE LINE OF vl_rgbwart,
        vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '551'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '552'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '701'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '702'.
  APPEND wa_rgbwart TO vl_rgbwart.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  obj_engorda->get_mermas_maq(
    EXPORTING
      p_gjahr = p_gjahr
      p_popers = vl_rgpoper
      i_rgbwart = vl_rgbwart
    CHANGING
      ch_mermas_maq = it_mermas_maq
  ).

  obj_engorda->calculate_dates(
   CHANGING
     p_rgfechas = rg_fechas
 ).

  IF vl_solo_maquila EQ abap_true.
    LOOP AT it_mermas_maq ASSIGNING FIELD-SYMBOL(<fsw_mermas>).
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fsw_mermas> TO <f_field>.
      <f_field> = 'MERMAS'.
    ENDLOOP.
  ENDIF.


  IF vl_solo_maquila EQ abap_true AND p_werks-low NE 'PA01'.
    IF p_werks IS NOT INITIAL.
      REFRESH it_mermas_maq.
    ENDIF.
  ENDIF.


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_mermas_maq[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.


    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month * -1.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst * -1.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month * -1.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst * -1.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month * -1.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst * -1.
*
          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.


ENDFORM.

FORM get_mermas.

  DATA: vl_rgbwart TYPE RANGE OF mseg-bwart,
        wa_rgbwart LIKE LINE OF vl_rgbwart,
        vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  DATA: rg_werks   TYPE RANGE OF afpo-dwerk,
        wa_rgwerks LIKE LINE OF rg_werks.


  IF p_werks-high IS INITIAL.

    LOOP AT p_werks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = p_werks-low.
      APPEND wa_rgwerks TO rg_werks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'BT'.
    wa_rgwerks-low = p_werks-low.
    wa_rgwerks-high = p_werks-high.
    APPEND wa_rgwerks TO rg_werks.
  ENDIF.


  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '551'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '552'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '701'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '702'.
  APPEND wa_rgbwart TO vl_rgbwart.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  obj_engorda->get_mermas(
    EXPORTING
      p_gjahr = p_gjahr
      p_popers = vl_rgpoper
      i_rgbwart = vl_rgbwart
      i_werks = rg_werks
    CHANGING
      ch_mermas = it_mermas
  ).

  obj_engorda->calculate_dates(
   CHANGING
     p_rgfechas = rg_fechas
 ).


  IF p_werks IS NOT INITIAL.
    DELETE it_mermas WHERE werks NOT IN p_werks.
  ENDIF.


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_mermas[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.


    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            IF wa_aux-month > 0.
              <f_field> = wa_aux-month * -1.
            ELSE.
              <f_field> = wa_aux-month.
            ENDIF.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            IF wa_aux-monthst > 0.
              <f_field> = wa_aux-monthst * -1.
            ELSE.
              <f_field> = wa_aux-monthst.
            ENDIF.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  IF wa_aux-month > 0.
                    <f_field> =  wa_aux-month * -1 / <fs_data>.
                  ELSE.
                    <f_field> =  wa_aux-month  / <fs_data>.
                  ENDIF.


                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .

                  IF wa_aux-monthst > 0.
                    <f_field> =  wa_aux-monthst * -1 / <fs_data>.
                  ELSE.
                    <f_field> =  wa_aux-monthst  / <fs_data>.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            IF wa_aux-month > 0.
              <f_field> = wa_aux-month * -1.
            ELSE.
              <f_field> = wa_aux-month.
            ENDIF.


            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            IF wa_aux-monthst > 0.
              <f_field> = wa_aux-monthst * -1.
            ELSE.
              <f_field> = wa_aux-monthst.
            ENDIF.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  IF wa_aux-month > 0.
                    <f_field> =  wa_aux-month * -1 / <fs_data1>.
                  ELSE.
                    <f_field> =  wa_aux-month / <fs_data1>.
                  ENDIF.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  IF wa_aux-monthst > 0.
                    <f_field> = wa_aux-monthst * -1 / <fs_data1> .
                  ELSE.
                    <f_field> = wa_aux-monthst  / <fs_data1> .
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          IF wa2-month > 0.
            <f_field> = wa2-month * -1.
          ELSE.
            <f_field> = wa2-month.
          ENDIF.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          IF wa2-monthst > 0.
            <f_field> = wa2-monthst * -1.
          ELSE.
            <f_field> = wa2-monthst.
          ENDIF.
          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                IF wa2-month > 0.
                  <f_field> =  wa2-month * -1 / <fs_data2>.
                ELSE.
                  <f_field> =  wa2-month / <fs_data2>.
                ENDIF.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF wa2-monthst > 0.
                  <f_field> =  wa2-monthst * -1 / <fs_data2>.
                ELSE.
                  <f_field> =  wa2-monthst / <fs_data2>.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

ENDFORM.





FORM get_costosdirectos_huevo.

ENDFORM.

FORM get_costosdirectos_dep_v.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF t001w-werks,
        wa_rgwerks  LIKE LINE OF vl_rgwerks,
        vl_rgmatkl  TYPE RANGE OF mara-matkl,
        wa_rgmatkl  LIKE LINE OF vl_rgmatkl,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.



  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.
  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.



  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '601'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '602'.
  APPEND wa_rgbwart TO vl_rgbwart.

  IF p_werks IS INITIAL.
    LOOP AT it_aufnr_end INTO DATA(wa_aufnr).
      CLEAR wa_rgwerks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = wa_aufnr-dwerk.
      APPEND wa_rgwerks TO vl_rgwerks.
    ENDLOOP.
  ELSE.

    IF p_werks-high IS INITIAL.
      LOOP AT p_werks.
        wa_rgwerks-sign = 'I'.
        wa_rgwerks-option = 'EQ'.
        wa_rgwerks-low = p_werks-low.
        APPEND wa_rgwerks TO vl_rgwerks.
      ENDLOOP.
    ELSE.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'BT'.
      wa_rgwerks-low = p_werks-low.
      wa_rgwerks-high = p_werks-high.
      APPEND wa_rgwerks TO vl_rgwerks.
    ENDIF.

  ENDIF.


  IF gv_tipore EQ 'DEPOSITOS' AND vl_solo_vivo EQ abap_true.



    wa_rgmatkl-sign = 'I'.
    wa_rgmatkl-option = 'EQ'.
    wa_rgmatkl-low = 'PT0001'.
    APPEND wa_rgmatkl TO vl_rgmatkl.

    obj_engorda->get_mb51_dep(
      EXPORTING
        i_werks   = vl_rgwerks
        i_matkl   = vl_rgmatkl
        i_rgbwart = vl_rgbwart
      CHANGING
        ch_mb51_dep   = it_mb51_dep
    ).

  ELSEIF gv_tipore EQ 'DEPOSITOS' AND vl_solo_caliente EQ abap_true.

    wa_rgmatkl-sign = 'I'.
    wa_rgmatkl-option = 'EQ'.
    wa_rgmatkl-low = 'PT0010'.
    APPEND wa_rgmatkl TO vl_rgmatkl.

    obj_engorda->get_mb51_dep(
      EXPORTING
        i_werks   = vl_rgwerks
        i_matkl   = vl_rgmatkl
        i_rgbwart = vl_rgbwart
      CHANGING
        ch_mb51_dep   = it_mb51_dep
    ).
  ELSEIF gv_tipore EQ 'DEPOSITOS' AND vl_globald EQ abap_true.
    wa_rgmatkl-sign = 'I'.
    wa_rgmatkl-option = 'EQ'.
    wa_rgmatkl-low = 'PT0001'.
    APPEND wa_rgmatkl TO vl_rgmatkl.

    wa_rgmatkl-sign = 'I'.
    wa_rgmatkl-option = 'EQ'.
    wa_rgmatkl-low = 'PT0010'.
    APPEND wa_rgmatkl TO vl_rgmatkl.

    obj_engorda->get_mb51_dep(
      EXPORTING
        i_werks   = vl_rgwerks
        i_matkl   = vl_rgmatkl
        i_rgbwart = vl_rgbwart
      CHANGING
        ch_mb51_dep   = it_mb51_dep
        ).

  ENDIF.

  IF vl_globald EQ abap_true.
    DELETE it_mb51_dep WHERE matkl  NE 'PT0001' AND matkl NE 'PT0010'.
    LOOP AT it_mb51_dep ASSIGNING FIELD-SYMBOL(<fs_dep>).
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_dep> TO FIELD-SYMBOL(<fs_line>).
      <fs_line> = 'TRASP. DIARIO POLLO'.
    ENDLOOP.
  ENDIF.

  SORT it_mb51_dep BY aufnr budat_mkpf.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).




  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_mb51_dep.
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_mb51).
      CLEAR wa_aux_out.
*      LOOP AT it_mb51 INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

*      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.
                ENDIF.

                IF <fs_data1> GT 0.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                ENDIF.
                <f_field> = wa_aux-monthst / <fs_data1> .
              ENDLOOP.
            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.
              ENDIF..
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
              IF <fs_data2> GT 0.
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.

          IF vl_solo_vivo EQ abap_true.
            IF <f_field> EQ 'TRASP. DIARIO POLLO VIVO'.
              vl_existe = 'X'.
            ENDIF.
          ELSEIF vl_solo_caliente EQ abap_true.
            IF <f_field> EQ 'TRASP. DIARIO POLLO CALIENTE'.
              vl_existe = 'X'.
            ENDIF.
          ELSE.
            IF <f_field> EQ 'TRASP. DIARIO POLLO'.
              vl_existe = 'X'.
            ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .

        IF vl_solo_vivo EQ abap_true.
          <f_field> = 'TRASP. DIARIO POLLO VIVO'.
        ELSEIF vl_solo_caliente EQ abap_true.
          <f_field> = 'TRASP. DIARIO POLLO CALIENTE'.


        ELSE.
          <f_field> = 'TRASP. DIARIO POLLO'.


        ENDIF.


        "unitario
        UNASSIGN <f_field>.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = gv_txtunit.

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.


  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostodir.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.
  DATA: vl_mp       TYPE dmbtr, vl_mpst TYPE dmbtr,
        vl_merma    TYPE dmbtr, vl_mermast TYPE dmbtr,
        vl_i_mp     TYPE i, vl_i_maq TYPE i, vl_i_merma TYPE i, vl_i_mermam TYPE i.

  LOOP AT it_totales ASSIGNING <fs_linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
    "se suma aparceria

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " break jhernandev.
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.

      "se obtiene el valor de materia prima
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MATERIA PRIMA'.
        vl_i_mp = sy-tabix.

        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = <fs_field> .
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'COSTO PARTICIPACIÓN APARCERÍA'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_acum_messt = vl_acum_messt + <fs_field> .
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MERMAS'.
        vl_i_merma = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        "vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_merma = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        " vl_acum_messt = vl_acum_messt + <fs_field> .
        vl_mermast = <fs_field> .

      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Costo Materia Prima Maquila' AND vl_global EQ abap_true .
        vl_i_maq = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = vl_mp + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = vl_mpst + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_mp ASSIGNING FIELD-SYMBOL(<fs_mp>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field>.
        <fs_field> = vl_mp.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field> .
        <fs_field> = vl_mpst.
        REPLACE 'S' IN <f_field> WITH 'R'.
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Mermas de Maquila' AND vl_global EQ abap_true.

        vl_i_mermam = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_merma  = vl_merma + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mermast = vl_mermast + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_merma ASSIGNING FIELD-SYMBOL(<fs_merma>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field>.
        <fs_field> = vl_merma.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field> .
        <fs_field> = vl_mermast.
        REPLACE 'S' IN <f_field> WITH 'R'.



      ENDIF.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostodir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.

        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "          ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.
            ENDIF.

            REPLACE 'R' IN <f_field> WITH 'S'.
            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.



ENDFORM.

FORM get_costosdirectos.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF t001w-werks,
        wa_rgwerks  LIKE LINE OF vl_rgwerks,
        vl_rgmatkl  TYPE RANGE OF mara-matkl,
        wa_rgmatkl  LIKE LINE OF vl_rgmatkl,

        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.



  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.
  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  IF gv_tipore EQ 'DEPOSITOS'.

    wa_rgbwart-sign = 'I'.
    wa_rgbwart-option = 'EQ'.
    wa_rgbwart-low = '601'.
    APPEND wa_rgbwart TO vl_rgbwart.

    wa_rgbwart-sign = 'I'.
    wa_rgbwart-option = 'EQ'.
    wa_rgbwart-low = '602'.
    APPEND wa_rgbwart TO vl_rgbwart.
  ELSE.
    wa_rgbwart-sign = 'I'.
    wa_rgbwart-option = 'EQ'.
    wa_rgbwart-low = '261'.
    APPEND wa_rgbwart TO vl_rgbwart.

    wa_rgbwart-sign = 'I'.
    wa_rgbwart-option = 'EQ'.
    wa_rgbwart-low = '262'.
    APPEND wa_rgbwart TO vl_rgbwart.
  ENDIF.

  IF it_aufnr_end IS NOT INITIAL.

    IF gv_tipore = 'ENGORDA'.

      obj_engorda->get_mb51_eng(
        EXPORTING
          i_aufnr  = it_aufnr_end
          i_rgbwart = vl_rgbwart
        CHANGING
          ch_mb51 = it_mb51
      ).

    ELSEIF  gv_tipore = 'ALIMENTO'.

      obj_engorda->get_mb51_alim(
    EXPORTING
      i_aufnr  = it_aufnr_end
      i_rgbwart = vl_rgbwart
    CHANGING
      ch_mb51 = it_mb51 ).

      SORT it_mb51 BY werks.

      IF p_werks IS INITIAL.
        DELETE it_mb51 WHERE werks EQ 'PA04' OR werks EQ 'PA07'.
      ENDIF.

    ELSEIF gv_tipore = 'DEPOSITOS'.

      obj_engorda->get_mb51_dep(
        EXPORTING
          i_werks   = vl_rgwerks
          i_matkl   = vl_rgmatkl
          i_rgbwart = vl_rgbwart
        CHANGING
          ch_mb51_dep   = it_mb51
      ).


    ELSE.

      obj_engorda->get_mb51(
        EXPORTING
          i_aufnr  = it_aufnr_end
          i_rgbwart = vl_rgbwart
        CHANGING
          ch_mb51 = it_mb51 ).

    ENDIF.
  ENDIF.

  IF gv_tipore EQ 'PPA'.
    DELETE it_mb51 WHERE ( matkl NE 'PT0001' AND racct NE '0504025051' AND racct NE'0504025106' ).
  ELSEIF gv_tipore EQ 'DEPOSITOS' AND vl_solo_vivo EQ abap_true.
    DELETE it_mb51 WHERE matkl  NE 'PT0001'.
  ELSEIF gv_tipore EQ 'DEPOSITOS' AND vl_solo_caliente EQ abap_true.
    DELETE it_mb51 WHERE matkl NE 'PT0010'.
  ENDIF.




*  SORT it_mb51 BY aufnr budat .

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).




  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].


    IF gv_tipore EQ 'DEPOSITOS'.
      DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.
    ELSE.
      DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.
    ENDIF.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_mb51 INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.
                ENDIF.

                IF <fs_data1> GT 0.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                ENDIF.
                <f_field> = wa_aux-monthst / <fs_data1> .
              ENDLOOP.
            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.
              ENDIF..
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
              IF <fs_data2> GT 0.
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.

          IF gv_tipore EQ 'ALIMENTO'.
            IF <f_field> EQ 'MATERIA PRIMA'.
              vl_existe = 'X'.
            ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .

          <f_field> = 'MATERIA PRIMA'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.

  IF gv_tipore EQ 'ENGORDA'.
    PERFORM get_aparceria.
  ENDIF.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'
       OR <f_field>+0(2) EQ '4.' OR <f_field>+0(2) EQ '5.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

  """"""""""""""""""""""""""



  IF gv_tipore EQ 'ALIMENTO'.
    IF vl_solo_maquila EQ abap_false.
      PERFORM get_mermas.
    ENDIF.
    IF p_werks IS INITIAL OR p_werks-low EQ 'PA01'.

      PERFORM get_maquila.
      PERFORM get_mermas_maq.

    ENDIF.
  ENDIF.

  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostodir.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.
  DATA: vl_mp       TYPE dmbtr, vl_mpst TYPE dmbtr,
        vl_merma    TYPE dmbtr, vl_mermast TYPE dmbtr,
        vl_i_mp     TYPE i, vl_i_maq TYPE i, vl_i_merma TYPE i, vl_i_mermam TYPE i.

  IF  vl_global EQ abap_false AND gv_tipore EQ 'ALIMENTO'.
    REFRESH it_totales.
    LOOP AT rg_fechas INTO wa_fechas.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
      ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
      <fs_field> = vl_mes.
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

      LOOP AT <fs_outtable> ASSIGNING <fs_linea>.
        ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_linea> TO <f_field>.
        IF <f_field> EQ 'MATERIA PRIMA' OR <f_field> EQ 'MERMAS'.
          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_linea> TO <f_field>.
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.
          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = <f_field>.
          UNASSIGN <fs_field>.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_linea> TO <f_field>.
          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = <f_field>..
          UNASSIGN <fs_field>.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  LOOP AT it_totales ASSIGNING <fs_linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
    "se suma aparceria

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " break jhernandev.
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.

      "se obtiene el valor de materia prima
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MATERIA PRIMA'.
        vl_i_mp = sy-tabix.

        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = <fs_field> .
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'COSTO PARTICIPACIÓN APARCERÍA'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_acum_messt = vl_acum_messt + <fs_field> .
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MERMAS'.
        vl_i_merma = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        "vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_merma = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        " vl_acum_messt = vl_acum_messt + <fs_field> .
        vl_mermast = <fs_field> .

      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Costo Materia Prima Maquila' AND vl_global EQ abap_true .
        vl_i_maq = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = vl_mp + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = vl_mpst + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_mp ASSIGNING FIELD-SYMBOL(<fs_mp>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field>.
        <fs_field> = vl_mp.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field> .
        <fs_field> = vl_mpst.
        REPLACE 'S' IN <f_field> WITH 'R'.
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Mermas de Maquila' AND vl_global EQ abap_true.

        vl_i_mermam = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_merma  = vl_merma + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mermast = vl_mermast + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_merma ASSIGNING FIELD-SYMBOL(<fs_merma>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field>.
        <fs_field> = vl_merma.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field> .
        <fs_field> = vl_mermast.
        REPLACE 'S' IN <f_field> WITH 'R'.



      ENDIF.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostodir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.

        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "          ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.
            ENDIF.

            REPLACE 'R' IN <f_field> WITH 'S'.
            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.


  LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_existe>).
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_existe> TO <f_field>.
    IF sy-subrc EQ 0.
      IF <f_field> EQ 'Costo Materia Prima Maquila'.
        vl_i_maq = sy-tabix.
      ENDIF.

      IF <f_field> EQ 'Mermas de Maquila'.
        vl_i_mermam = sy-tabix.
      ENDIF.

    ENDIF.
  ENDLOOP.

  IF vl_i_maq GT 0.
    DELETE <fs_outtable> INDEX vl_i_maq.
    DELETE <fs_outtable> INDEX vl_i_maq.
  ENDIF.



  IF vl_i_mermam GT 0.
    DELETE <fs_outtable> INDEX vl_i_mermam - 2.
    DELETE <fs_outtable> INDEX vl_i_mermam - 2.
  ENDIF.

ENDFORM.

FORM get_costosdirectos_postura.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF t001w-werks,
        wa_rgwerks  LIKE LINE OF vl_rgwerks,
        vl_rgmatkl  TYPE RANGE OF mara-matkl,
        wa_rgmatkl  LIKE LINE OF vl_rgmatkl,

        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.



  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.
  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '261'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '262'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '101'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '102'.
  APPEND wa_rgbwart TO vl_rgbwart.

  IF it_aufnr_end IS NOT INITIAL.
    obj_engorda->get_mb51_post(
      EXPORTING
        i_aufnr  = it_aufnr_end
        i_rgbwart = vl_rgbwart
      CHANGING
        ch_mb51 = it_mb51 ).
  ENDIF.

  SORT it_mb51 BY aufnr budat .

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_mb51[].

    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_mb51).
      CLEAR wa_aux_out.
      "LOOP AT it_mb51 INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
          wa_aux_out-month = wa_mb51-dmbtr.
          wa_aux_out-monthst = wa_mb51-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.
                ENDIF.

                IF <fs_data1> GT 0.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                ENDIF.
                <f_field> = wa_aux-monthst / <fs_data1> .
              ENDLOOP.
            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.
              ENDIF..
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
              IF <fs_data2> GT 0.
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.

          IF gv_tipore EQ 'ALIMENTO'.
            "IF <f_field> EQ 'MATERIA PRIMA'.
            vl_existe = 'X'.
            " ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .

          <f_field> = 'MATERIA PRIMA'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'
       OR <f_field>+0(2) EQ '4.' OR <f_field>+0(2) EQ '5.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

  """"""""""""""""""""""""""


  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostodir.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.
  DATA: vl_mp       TYPE dmbtr, vl_mpst TYPE dmbtr,
        vl_merma    TYPE dmbtr, vl_mermast TYPE dmbtr,
        vl_i_mp     TYPE i, vl_i_maq TYPE i, vl_i_merma TYPE i, vl_i_mermam TYPE i.

  LOOP AT it_totales ASSIGNING <fs_linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
    "se suma aparceria

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " break jhernandev.
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.

      "se obtiene el valor de materia prima
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MATERIA PRIMA'.
        vl_i_mp = sy-tabix.

        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = <fs_field> .
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'COSTO PARTICIPACIÓN APARCERÍA'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_acum_messt = vl_acum_messt + <fs_field> .
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MERMAS'.
        vl_i_merma = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        "vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_merma = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        " vl_acum_messt = vl_acum_messt + <fs_field> .
        vl_mermast = <fs_field> .

      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Costo Materia Prima Maquila' AND vl_global EQ abap_true .
        vl_i_maq = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = vl_mp + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = vl_mpst + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_mp ASSIGNING FIELD-SYMBOL(<fs_mp>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field>.
        <fs_field> = vl_mp.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field> .
        <fs_field> = vl_mpst.
        REPLACE 'S' IN <f_field> WITH 'R'.
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Mermas de Maquila' AND vl_global EQ abap_true.

        vl_i_mermam = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_merma  = vl_merma + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mermast = vl_mermast + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_merma ASSIGNING FIELD-SYMBOL(<fs_merma>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field>.
        <fs_field> = vl_merma.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field> .
        <fs_field> = vl_mermast.
        REPLACE 'S' IN <f_field> WITH 'R'.



      ENDIF.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostodir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.

        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "          ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.
            ENDIF.

            REPLACE 'R' IN <f_field> WITH 'S'.
            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.



ENDFORM.



FORM get_costosdirectos_crianza.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF t001w-werks,
        wa_rgwerks  LIKE LINE OF vl_rgwerks,
        vl_rgmatkl  TYPE RANGE OF mara-matkl,
        wa_rgmatkl  LIKE LINE OF vl_rgmatkl,

        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.



  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.
  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '261'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '262'.
  APPEND wa_rgbwart TO vl_rgbwart.

  IF it_aufnr_end IS NOT INITIAL.
    obj_engorda->get_mb51_crianza(
      EXPORTING
        i_aufnr  = it_aufnr_end
        i_rgbwart = vl_rgbwart
      CHANGING
        ch_mb51 = it_mb51 ).
  ENDIF.

  SORT it_mb51 BY aufnr budat .

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).


  IF p_werks IS NOT INITIAL.

    DELETE it_mb51 WHERE werks NOT IN p_werks.

  ENDIF.

  IF ( c_recria EQ abap_true AND c_cria EQ abap_true ) OR
     ( c_recria EQ abap_false AND c_cria EQ abap_false ).

    DELETE it_mb51 WHERE racct EQ '0504025052'.
  ELSEIF c_cria EQ abap_true AND c_recria EQ abap_false.
    DELETE it_mb51 WHERE racct EQ '0504025052'.
  ENDIF.

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].

    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_mb51 INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.
                ENDIF.

                IF <fs_data1> GT 0.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                ENDIF.
                <f_field> = wa_aux-monthst / <fs_data1> .
              ENDLOOP.
            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.
              ENDIF..
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
              IF <fs_data2> GT 0.
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.

          IF gv_tipore EQ 'ALIMENTO'.
            "IF <f_field> EQ 'MATERIA PRIMA'.
            vl_existe = 'X'.
            " ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .

          <f_field> = 'MATERIA PRIMA'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'
       OR <f_field>+0(2) EQ '4.' OR <f_field>+0(2) EQ '5.' OR <f_field>+0(2) EQ '6.'
       OR <f_field>+0(2) EQ '7.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

  """"""""""""""""""""""""""


  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostodir.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.
  DATA: vl_mp       TYPE dmbtr, vl_mpst TYPE dmbtr,
        vl_merma    TYPE dmbtr, vl_mermast TYPE dmbtr,
        vl_i_mp     TYPE i, vl_i_maq TYPE i, vl_i_merma TYPE i, vl_i_mermam TYPE i.

  LOOP AT it_totales ASSIGNING <fs_linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
    "se suma aparceria

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " break jhernandev.
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.

      "se obtiene el valor de materia prima
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MATERIA PRIMA'.
        vl_i_mp = sy-tabix.

        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = <fs_field> .
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'COSTO PARTICIPACIÓN APARCERÍA'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_acum_messt = vl_acum_messt + <fs_field> .
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MERMAS'.
        vl_i_merma = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        "vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_merma = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        " vl_acum_messt = vl_acum_messt + <fs_field> .
        vl_mermast = <fs_field> .

      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Costo Materia Prima Maquila' AND vl_global EQ abap_true .
        vl_i_maq = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = vl_mp + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = vl_mpst + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_mp ASSIGNING FIELD-SYMBOL(<fs_mp>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field>.
        <fs_field> = vl_mp.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field> .
        <fs_field> = vl_mpst.
        REPLACE 'S' IN <f_field> WITH 'R'.
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Mermas de Maquila' AND vl_global EQ abap_true.

        vl_i_mermam = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_merma  = vl_merma + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mermast = vl_mermast + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_merma ASSIGNING FIELD-SYMBOL(<fs_merma>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field>.
        <fs_field> = vl_merma.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field> .
        <fs_field> = vl_mermast.
        REPLACE 'S' IN <f_field> WITH 'R'.



      ENDIF.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostodir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.

        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "          ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.
            ENDIF.

            REPLACE 'R' IN <f_field> WITH 'S'.
            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.



ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM get_costosdirectos_incubadora.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF t001w-werks,
        wa_rgwerks  LIKE LINE OF vl_rgwerks,
        vl_rgmatkl  TYPE RANGE OF mara-matkl,
        wa_rgmatkl  LIKE LINE OF vl_rgmatkl,

        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.



  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.
  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '261'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '262'.
  APPEND wa_rgbwart TO vl_rgbwart.

  IF it_aufnr_end IS NOT INITIAL.
    obj_engorda->get_mb51_incubadora(
      EXPORTING
        i_aufnr  = it_aufnr_end
        i_rgbwart = vl_rgbwart
      CHANGING
        ch_mb51 = it_mb51 ).
  ENDIF.

  SORT it_mb51 BY aufnr budat .

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).


  IF p_werks IS NOT INITIAL.

    DELETE it_mb51 WHERE werks NOT IN p_werks.

  ENDIF.


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].

    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_mb51 INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.
                ENDIF.

                IF <fs_data1> GT 0.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                ENDIF.
                <f_field> = wa_aux-monthst / <fs_data1> .
              ENDLOOP.
            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.
              ENDIF..
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
              IF <fs_data2> GT 0.
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.

          IF gv_tipore EQ 'ALIMENTO'.
            "IF <f_field> EQ 'MATERIA PRIMA'.
            vl_existe = 'X'.
            " ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .

          <f_field> = 'MATERIA PRIMA'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'
       OR <f_field>+0(2) EQ '4.' OR <f_field>+0(2) EQ '5.' OR <f_field>+0(2) EQ '6.'
       OR <f_field>+0(2) EQ '7.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

*  """"""""""""""""""""""""""
*  IF c_aca EQ abap_true.
*    PERFORM get_maquila_aca.
*    REFRESH it_totales.
*    DATA flag.
*    LOOP AT rg_fechas INTO wa_fechas.
*      CASE wa_fechas-low+4(2).
*        WHEN '01'.
*          vl_mes = 'C001R'.
*          vl_messt = 'C001S'.
*        WHEN '02'.
*          vl_mes = 'C002R'.
*          vl_messt = 'C002S'.
*        WHEN '03'.
*          vl_mes = 'C003R'.
*          vl_messt = 'C003S'.
*        WHEN '04'.
*          vl_mes = 'C004R'.
*          vl_messt = 'C004S'.
*        WHEN '05'.
*          vl_mes = 'C005R'.
*          vl_messt = 'C005S'.
*        WHEN '06'.
*          vl_mes = 'C006R'.
*          vl_messt = 'C006S'.
*        WHEN '07'.
*          vl_mes = 'C007R'.
*          vl_messt = 'C007S'.
*        WHEN '08'.
*          vl_mes = 'C008R'.
*          vl_messt = 'C008S'.
*        WHEN '09'.
*          vl_mes = 'C009R'.
*          vl_messt = 'C009S'.
*        WHEN '10'.
*          vl_mes = 'C010R'.
*          vl_messt = 'C010S'.
*        WHEN '11'.
*          vl_mes = 'C011R'.
*          vl_messt = 'C011S'.
*        WHEN '12'.
*          vl_mes = 'C012R'.
*          vl_messt = 'C012S'.
*      ENDCASE.
*      flag = abap_false.
*      "se recalculan los totales
*      LOOP AT <fs_outtable> ASSIGNING <linea>.
*        ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
*        IF <f_field> NE gv_txtunit.
*
*
*          IF flag EQ abap_false.
*            APPEND INITIAL LINE TO it_totales ASSIGNING <fs_linea>.
*            ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <fs_field>.
*            <fs_field> = vl_mes.
*            UNASSIGN <fs_field>.
*            flag = abap_true.
*
*          ENDIF.
*
*          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
*          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.
*          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field>.
*
*          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
*          <fs_field> = <f_field>.
*          UNASSIGN <fs_field>.
*
*          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
*          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field>.
*          <fs_field> = <f_field>.
*          UNASSIGN <fs_field>.
*
*        ENDIF.
*      ENDLOOP.
*    ENDLOOP.
*  ENDIF.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostodir.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.
  DATA: vl_mp       TYPE dmbtr, vl_mpst TYPE dmbtr,
        vl_merma    TYPE dmbtr, vl_mermast TYPE dmbtr,
        vl_i_mp     TYPE i, vl_i_maq TYPE i, vl_i_merma TYPE i, vl_i_mermam TYPE i.

  LOOP AT it_totales ASSIGNING <fs_linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
    "se suma aparceria

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " break jhernandev.
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.

      "se obtiene el valor de materia prima
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MATERIA PRIMA'.
        vl_i_mp = sy-tabix.

        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = <fs_field> .
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'COSTO PARTICIPACIÓN APARCERÍA'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_acum_messt = vl_acum_messt + <fs_field> .
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'MERMAS'.
        vl_i_merma = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        "vl_acum_mes  = vl_acum_mes + <fs_field> .
        vl_merma = <fs_field> .

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        " vl_acum_messt = vl_acum_messt + <fs_field> .
        vl_mermast = <fs_field> .

      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Costo Materia Prima Maquila' AND vl_global EQ abap_true .
        vl_i_maq = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mp  = vl_mp + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mpst = vl_mpst + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_mp ASSIGNING FIELD-SYMBOL(<fs_mp>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field>.
        <fs_field> = vl_mp.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_mp> TO <fs_field> .
        <fs_field> = vl_mpst.
        REPLACE 'S' IN <f_field> WITH 'R'.
      ENDIF.

      UNASSIGN <fs_field>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ 'Mermas de Maquila' AND vl_global EQ abap_true.

        vl_i_mermam = sy-tabix.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_merma  = vl_merma + <fs_field> .
        vl_acum_mes = vl_acum_mes + <fs_field>.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        vl_mermast = vl_mermast + <fs_field>.
        vl_acum_messt = vl_acum_messt + <fs_field> .


        READ TABLE <fs_outtable> INDEX vl_i_merma ASSIGNING FIELD-SYMBOL(<fs_merma>).
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field>.
        <fs_field> = vl_merma.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_merma> TO <fs_field> .
        <fs_field> = vl_mermast.
        REPLACE 'S' IN <f_field> WITH 'R'.



      ENDIF.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostodir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.

        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "          ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.
            ENDIF.

            REPLACE 'R' IN <f_field> WITH 'S'.
            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.



ENDFORM.



FORM get_kgs_prod.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF afpo-dwerk,
        wa_rgwerks  LIKE LINE OF vl_rgwerks
        .

  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.
  REFRESH it_aux_acum.

  IF p_werks IS NOT INITIAL.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'EQ'.
    wa_rgwerks-low = p_werks-low.
    APPEND wa_rgwerks TO vl_rgwerks.
  ENDIF.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '101'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '102'.
  APPEND wa_rgbwart TO vl_rgbwart.



  obj_engorda->get_kgs_pro_emp(
    EXPORTING
      i_werks    = vl_rgwerks
      i_aufnr    = it_aufnr_end
      i_rgbwart  = vl_rgbwart
    CHANGING
      ch_kgs_emp = it_mortal_dep
  ).

  IF vl_solo_vivo EQ abap_true.
    REFRESH it_mortal_dep.
  ENDIF.



  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).
    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_mortal_dep INTO DATA(wa_mortandad) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mortandad-wgbez60.
            wa_aux_out-month = wa_mortandad-/cwm/menge.
            wa_aux_out-monthst = wa_mortandad-/cwm/menge.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.
    "
    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_find = abap_false.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF <f_field> EQ 'Kilos Producidos'.
            vl_existe = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = 'Kilos Producidos'.


      ENDIF.
    ENDIF.

    """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
    IF it_aux_out IS NOT INITIAL.
      UNASSIGN <linea>.
      UNASSIGN <f_field>.

      APPEND INITIAL LINE TO it_aux_acum ASSIGNING <linea>.
      ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
      <f_field> = vl_mes.

      UNASSIGN <f_field>.
      ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

      LOOP AT it_aux_out INTO DATA(wa).
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).
        ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_field_a> TO <f_field>.
        <f_field> = wa-menge.
        UNASSIGN <f_field>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <f_field>.
        <f_field> = wa-month.
        UNASSIGN <f_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <f_field>.
        <f_field> = wa-monthst.
        UNASSIGN <f_field>.

      ENDLOOP.
    ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    REFRESH it_aux_out.
    "
  ENDLOOP.


ENDFORM.

FORM get_unitarios_post.


  DATA: rg_fechas    TYPE RANGE OF acdoca-budat,
        vl_mes(5)    TYPE c,vl_messt(5)  TYPE c,
        vl_kgs_pro   TYPE dmbtr, vl_kgs_prost TYPE dmbtr,
        vl_index     TYPE sy-tabix,
        vl_huevo_inc TYPE menge_d.



  FIELD-SYMBOLS: <fs_tt>         TYPE table,
                 <fs_st>         TYPE any,
                 <fs_mes>        TYPE any,
                 <fs_field>      TYPE any,
                 <fs_stout>      TYPE any,
                 <fs_rowout>     TYPE any,
                 <fs_chuevo_inc> TYPE any,
                 <fs_acum>       TYPE table.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      IF <fs_field> EQ 'HUEVO INCUBABLE'.
        READ TABLE <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_huevo_inc>) INDEX sy-tabix.
        ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_huevo_inc> TO <fs_chuevo_inc>.
        vl_huevo_inc = <fs_chuevo_inc>.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF <fs_chuevo_inc> IS NOT ASSIGNED.
      vl_huevo_inc = 0.
    ENDIF.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.

      CASE <fs_field>.
        WHEN gv_txtcostodir.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.

            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN gv_txtcostoindir.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN 'ALIMENTO'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN 'CONSUMO DE MATERIAS PRIMAS'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.
        WHEN 'AGOTAMIENTO/COSTO CRIANZA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN 'COSTO PARTICIPACION APARCERIA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN 'GASTOS INDIRECTOS'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN 'MANO DE OBRA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN 'TIEMPO MÁQUINA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN 'RECUPERACIONES (PRODUC SEMITERMINADA)'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN 'COSTO WIP'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

        WHEN gv_txttotalcostprod.

          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_huevo_inc GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_huevo_inc.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_huevo_inc.


          ENDIF.

      ENDCASE.

    ENDLOOP.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.


FORM get_unitarios_crianza.


  DATA: rg_fechas    TYPE RANGE OF acdoca-budat,
        vl_mes(5)    TYPE c,vl_messt(5)  TYPE c,
        vl_kgs_pro   TYPE dmbtr, vl_kgs_prost TYPE dmbtr,
        vl_index     TYPE sy-tabix,
        vl_huevo_inc TYPE menge_d,
        vl_ok.



  FIELD-SYMBOLS: <fs_tt>        TYPE table,
                 <fs_st>        TYPE any,
                 <fs_mes>       TYPE any,
                 <fs_field>     TYPE any,
                 <fs_stout>     TYPE any,
                 <fs_rowout>    TYPE any,
                 <fs_hembras_t> TYPE any,
                 <fs_acum>      TYPE table.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.


    vl_ok = abap_false.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      IF <fs_field> EQ 'HEMBRAS FINALES'.
        READ TABLE <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_hembras_i>) INDEX sy-tabix.
        ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_hembras_i> TO <fs_hembras_t>.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF <fs_hembras_t> IS NOT ASSIGNED.

      LOOP AT <fs_outtable> ASSIGNING <fs_st>.
        ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
        IF <fs_field> EQ 'GALLINA JOVEN'.
          READ TABLE <fs_outtable> ASSIGNING <fs_hembras_i> INDEX sy-tabix.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_hembras_i> TO <fs_hembras_t>.
          vl_ok = abap_true.
          EXIT.
        ENDIF.

      ENDLOOP.
      IF vl_ok EQ abap_false.
        ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_hembras_t>.
        <fs_hembras_t> = 0.
      ENDIF.
    ENDIF.


    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.

      CASE <fs_field>.
        WHEN gv_txtcostodir.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.

            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.

        WHEN gv_txtcostoindir.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.

        WHEN 'CONSUMO ALIMENTO'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.

        WHEN 'CONSUMO DE MATERIAS PRIMAS'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.
        WHEN 'POLLITA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.

        WHEN 'CONSUMO SEMITERMINADO'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.

        WHEN 'GASTOS INDIRECTOS'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.

        WHEN 'MANO DE OBRA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.

        WHEN 'GASTOS DE EQUIPO'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.

        WHEN 'RECUPERACIÓN GALLINAZA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.


        WHEN gv_txttotalcostprod.

          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / <fs_hembras_t>.


          ENDIF.

      ENDCASE.

    ENDLOOP.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM get_unitarios_incuba2.


  DATA: rg_fechas    TYPE RANGE OF acdoca-budat,
        vl_mes(5)    TYPE c,vl_messt(5)  TYPE c,
        vl_kgs_pro   TYPE dmbtr, vl_kgs_prost TYPE dmbtr,
        vl_index     TYPE sy-tabix,
        vl_huevo_inc TYPE menge_d,
        vl_ok, vl_total_pn TYPE menge_d.



  FIELD-SYMBOLS: <fs_tt>        TYPE table,
                 <fs_st>        TYPE any,
                 <fs_mes>       TYPE any,
                 <fs_field>     TYPE any,
                 <fs_stout>     TYPE any,
                 <fs_rowout>    TYPE any,
                 <fs_hembras_t> TYPE any,
                 <fs_acum>      TYPE table.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  vl_total_pn = 0.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.


    vl_ok = abap_false.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      IF <fs_field> EQ 'Total Pollitos Nacidos' OR <fs_field> EQ 'Pollitos Enviados a Granjas' .
        READ TABLE <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_hembras_i>) INDEX sy-tabix.
        ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_hembras_i> TO <fs_hembras_t>.
        IF sy-subrc EQ 0.
          vl_total_pn = <fs_hembras_t>.

          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.



    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.

      CASE <fs_field>.
        WHEN gv_txtcostodir.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.

            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN gv_txtcostoindir.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN 'HUEVO INCUBABLE'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN 'VACUNAS'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.
        WHEN 'MEDICINAS'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN 'POLLITO GAPESA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN 'GASTOS INDIRECTOS'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN 'MANO DE OBRA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN 'GASTOS DE EQUIPO'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN 'HUEVO COMERCIAL'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN 'DECOMISO'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

        WHEN 'SUBPRODUCTOS'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.


        WHEN gv_txttotalcostprod.

          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          IF vl_total_pn GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            <fs_rowout> = <fs_mes> / vl_total_pn.

            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            <fs_rowout> = <fs_mes> / vl_total_pn.


          ENDIF.

      ENDCASE.

    ENDLOOP.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

FORM get_unitarios_emp.


  DATA: rg_fechas    TYPE RANGE OF acdoca-budat,
        vl_mes(5)    TYPE c,vl_messt(5)  TYPE c,
        vl_kgs_pro   TYPE dmbtr, vl_kgs_prost TYPE dmbtr,
        vl_index     TYPE sy-tabix.



  FIELD-SYMBOLS: <fs_tt>     TYPE table,
                 <fs_st>     TYPE any,
                 <fs_mes>    TYPE any,
                 <fs_field>  TYPE any,
                 <fs_stout>  TYPE any,
                 <fs_rowout> TYPE any,
                 <fs_acum>   TYPE table.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.



    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.
        WHEN gv_txtcostodir.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          READ TABLE it_aux_acum INTO DATA(wa_cd) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_cd TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit3>).
              ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_unit3> TO FIELD-SYMBOL(<fs_kilos>).
              IF <fs_kilos> GT 0.
                "<fs_mes> = <fs_kilos>.

                <fs_rowout> = <fs_mes> / <fs_kilos>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
                <fs_rowout> = <fs_mes> / <fs_kilos>.


              ENDIF.
            ENDLOOP.

          ENDIF.
        WHEN gv_txtcostoindir.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          READ TABLE it_aux_acum INTO DATA(wa_ci) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_ci TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_kilosi>).
              IF <fs_kilosi> GT 0.
                "<fs_mes> = <fs_kilos>.

                <fs_rowout> = <fs_mes> / <fs_kilosi>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
                <fs_rowout> = <fs_mes> / <fs_kilosi>.


              ENDIF.
            ENDLOOP.

          ENDIF.

        WHEN 'CONSUMO DE INSUMOS'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          READ TABLE it_aux_acum INTO DATA(wa_ins) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_ins TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit2>).
              ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_unit2> TO FIELD-SYMBOL(<fs_kilos2>).
              IF <fs_kilos2> GT 0.
                "<fs_mes> = <fs_kilos>.

                <fs_rowout> = <fs_mes> / <fs_kilos2>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
                <fs_rowout> = <fs_mes> / <fs_kilos2>.


              ENDIF.
            ENDLOOP.

          ENDIF.
        WHEN 'MATERIA PRIMA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          READ TABLE it_aux_acum INTO DATA(wa_mp) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_mp TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit4>).
              ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_unit4> TO FIELD-SYMBOL(<fs_kilos4>).
              IF <fs_kilos4> GT 0.
                "<fs_mes> = <fs_kilos>.

                <fs_rowout> = <fs_mes> / <fs_kilos4>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
                <fs_rowout> = <fs_mes> / <fs_kilos4>.


              ENDIF.
            ENDLOOP.

          ENDIF.
        WHEN 'MANO DE OBRA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          READ TABLE it_aux_acum INTO DATA(wa_cp) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_cp TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit5>).
              ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_unit5> TO FIELD-SYMBOL(<fs_kilos5>).
              IF <fs_kilos5> GT 0.
                "<fs_mes> = <fs_kilos>.

                <fs_rowout> = <fs_mes> / <fs_kilos5>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
                <fs_rowout> = <fs_mes> / <fs_kilos5>.


              ENDIF.
            ENDLOOP.

          ENDIF.
        WHEN 'CARGA FABRIL'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          READ TABLE it_aux_acum INTO DATA(wa_cf) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_cf TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit6>).
              ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_unit6> TO FIELD-SYMBOL(<fs_kilos6>).
              IF <fs_kilos6> GT 0.
                "<fs_mes> = <fs_kilos>.

                <fs_rowout> = <fs_mes> / <fs_kilos6>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
                <fs_rowout> = <fs_mes> / <fs_kilos6>.


              ENDIF.
            ENDLOOP.

          ENDIF.

        WHEN 'TIEMPO MÁQUINA'.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          READ TABLE it_aux_acum INTO DATA(wa_tm) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tm TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit7>).
              ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_unit7> TO FIELD-SYMBOL(<fs_kilos7>).
              IF <fs_kilos7> GT 0.
                "<fs_mes> = <fs_kilos>.

                <fs_rowout> = <fs_mes> / <fs_kilos7>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
                <fs_rowout> = <fs_mes> / <fs_kilos7>.


              ENDIF.
            ENDLOOP.

          ENDIF.

        WHEN gv_txttotalcostprod.

          CLEAR vl_index.
          vl_index = sy-tabix + 1.

          READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario

          READ TABLE it_aux_acum INTO DATA(wa_cpd) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_cpd TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit9>).
              ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_unit9> TO FIELD-SYMBOL(<fs_kilos9>).
              IF <fs_kilos9> GT 0.
                "<fs_mes> = <fs_kilos>.

                <fs_rowout> = <fs_mes> / <fs_kilos9>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
                <fs_rowout> = <fs_mes> / <fs_kilos9>.


              ENDIF.
            ENDLOOP.

          ENDIF.

      ENDCASE.

    ENDLOOP.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.

FORM get_costosindirectos.
  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  IF gv_tipore = 'ENGORDA'.

    obj_engorda->get_acdoca_eng(
      EXPORTING
        i_aufnr  = it_aufnr_end
      CHANGING
        ch_acdoca = it_acdoca
    ).
  ELSE.

    obj_engorda->get_acdoca(
      EXPORTING
        i_aufnr  = it_aufnr_end
      CHANGING
        ch_acdoca = it_acdoca
    ).

  ENDIF.

  IF gv_tipore EQ 'DEPOSITOS' AND vl_solo_vivo EQ abap_true.
    REFRESH it_acdoca.
  ENDIF.


  SORT it_acdoca BY aufnr budat txt50.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).



  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_acdoca INTO DATA(wa_acdoca) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

*

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.


          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF gv_tipore EQ 'ALIMENTO'.
            IF <f_field> EQ 'COSTO DE PROCESO '.
              vl_existe = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.


        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = 'COSTO DE PROCESO'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.
      ENDIF.

    ENDIF.

    REFRESH it_aux_out.
    " ENDIF.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

  """"""""""""""""""""""""""

  "TOTAL
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostoindir.
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ""----------------
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.

    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostoindir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.




ENDFORM.

FORM get_costosindirectos_postura.
  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  IF gv_tipore = 'ENGORDA'.

    obj_engorda->get_acdoca_eng(
      EXPORTING
        i_aufnr  = it_aufnr_end
      CHANGING
        ch_acdoca = it_acdoca
    ).
  ELSEIF  gv_tipore = 'POSTURA'.
    obj_engorda->get_acdoca_post(
       EXPORTING
         i_aufnr  = it_aufnr_end
       CHANGING
         ch_acdoca = it_acdoca
     ).
  ELSE.

    obj_engorda->get_acdoca(
      EXPORTING
        i_aufnr  = it_aufnr_end
      CHANGING
        ch_acdoca = it_acdoca
    ).

  ENDIF.

  IF gv_tipore EQ 'DEPOSITOS' AND vl_solo_vivo EQ abap_true.
    REFRESH it_acdoca.
  ENDIF.


  SORT it_acdoca BY aufnr budat txt50.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).



  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_acdoca[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_acdoca).
      CLEAR wa_aux_out.
      "LOOP AT it_acdoca INTO DATA(wa_acdoca) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

*

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.


          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF gv_tipore EQ 'ALIMENTO'.
            IF <f_field> EQ 'COSTO DE PROCESO '.
              vl_existe = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.


        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = 'COSTO DE PROCESO'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.
      ENDIF.

    ENDIF.

    REFRESH it_aux_out.
    " ENDIF.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

  """"""""""""""""""""""""""

  "TOTAL
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostoindir.
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ""----------------
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.

    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostoindir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.




ENDFORM.

FORM get_costosindirectos_crianza.
  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->get_acdoca_crianza(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_acdoca = it_acdoca )
.

  SORT it_acdoca BY aufnr budat txt50.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_acdoca INTO DATA(wa_acdoca) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

*

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.


          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF gv_tipore EQ 'ALIMENTO'.
            IF <f_field> EQ 'COSTO DE PROCESO '.
              vl_existe = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.


        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = 'COSTO DE PROCESO'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.
      ENDIF.

    ENDIF.

    REFRESH it_aux_out.
    " ENDIF.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

  """"""""""""""""""""""""""

  "TOTAL
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostoindir.
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ""----------------
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.

    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostoindir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.




ENDFORM.

FORM get_costosind_aca.
  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  SELECT aufnr, racct,'COSTO MAQUILA' AS txt50, hsl, poper, budat,
         ryear, awref, awitem, belnr, docln, werks,
         rcntr
  INTO TABLE @it_acdoca
  FROM acdoca
  WHERE ryear EQ @p_gjahr
  AND racct EQ '0601001038'
  AND poper IN @so_poper
  AND werks IN @p_werks.


  SORT it_acdoca BY aufnr budat txt50.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_acdoca[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_acdoca).
      CLEAR wa_aux_out.
      "LOOP AT it_acdoca INTO DATA(wa_acdoca) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      " ENDLOOP.
    ENDLOOP.

*

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.


          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF gv_tipore EQ 'ALIMENTO'.
            IF <f_field> EQ 'COSTO DE PROCESO '.
              vl_existe = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.


        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = 'COSTO DE PROCESO'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.
      ENDIF.

    ENDIF.

    REFRESH it_aux_out.
    " ENDIF.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

  """"""""""""""""""""""""""

  "TOTAL
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostoindir.
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ""----------------
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.

    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostoindir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.




ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM get_costosindirectos_incuba.
  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->get_acdoca_crianza(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_acdoca = it_acdoca )
.

  SORT it_acdoca BY aufnr budat txt50.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_acdoca INTO DATA(wa_acdoca) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

*

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.


          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF gv_tipore EQ 'ALIMENTO'.
            IF <f_field> EQ 'COSTO DE PROCESO '.
              vl_existe = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.


        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = 'COSTO DE PROCESO'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.
      ENDIF.

    ENDIF.

    REFRESH it_aux_out.
    " ENDIF.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

  """"""""""""""""""""""""""

  "TOTAL
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostoindir.
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ""----------------
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.

    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostoindir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.




ENDFORM.

"""""""""""""""""""""costos de flete """"""""""""""""""""""""""""""""
FORM get_costosindirectos_flete.
  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->get_acdoca_flete(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_acdoca = it_acdoca
  ).

  SORT it_acdoca BY aufnr budat.
  "filtro de cecos y centro Depositos
  IF gv_tipore EQ 'DEPOSITOS'.
    DELETE it_acdoca WHERE rcntr = 'GPB62008'.
    DELETE it_acdoca WHERE rcntr = 'GPPR2024'.
    DELETE it_acdoca WHERE rcntr = 'GPPR2034'.
    DELETE it_acdoca WHERE rcntr = 'GPPR2035'.
    DELETE it_acdoca WHERE rcntr = 'GPPR2036'.
    DELETE it_acdoca WHERE rcntr = 'GPPR2039'.
    DELETE it_acdoca WHERE rcntr = 'GPPR2040'.

    IF p_werks-low IS NOT INITIAL.
      LOOP AT p_werks.
        CASE p_werks-low.
          WHEN 'PP27'.
            DELETE it_acdoca WHERE rcntr NE 'GPMQ2125'.
          WHEN 'PP28'.
            DELETE it_acdoca WHERE rcntr NE 'GPMQ2115'.
          WHEN 'PP29'.
            DELETE it_acdoca WHERE rcntr NE 'GPMQ2165'.
          WHEN 'PP30'.
            DELETE it_acdoca WHERE rcntr NE 'GPMQ2273'.
        ENDCASE.
      ENDLOOP.
    ELSEIF p_werks-high IS NOT INITIAL..

      CASE p_werks-high.
        WHEN 'PP27'.
          DELETE it_acdoca WHERE rcntr NE 'GPMQ2125'.
        WHEN 'PP28'.
          DELETE it_acdoca WHERE rcntr NE 'GPMQ2115'.
        WHEN 'PP29'.
          DELETE it_acdoca WHERE rcntr NE 'GPMQ2165'.
        WHEN 'PP30'.
          DELETE it_acdoca WHERE rcntr NE 'GPMQ2273'.
      ENDCASE.

    ENDIF.

    IF vl_solo_vivo EQ abap_true.
      REFRESH it_acdoca.
    ENDIF.

  ELSE.
    DELETE it_acdoca WHERE racct = '0601001033'.
    DELETE it_acdoca WHERE racct = 'S42SG0173'.
    DELETE it_acdoca WHERE racct = 'S42SG0179'.
    DELETE it_acdoca WHERE rcntr = 'GPMQ2165'.
    DELETE it_acdoca WHERE rcntr = 'GPMQ2125'.
    DELETE it_acdoca WHERE rcntr = 'GPMQ2115'.
    DELETE it_acdoca WHERE rcntr = 'GPMQ2273'.

  ENDIF.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_acdoca[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_acdoca).
      CLEAR wa_aux_out.
      "LOOP AT it_acdoca INTO DATA(wa_acdoca) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.


          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF <f_field> EQ 'FLETE DE ABASTO'.
            vl_existe = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = 'FLETE DE ABASTO'.

        "unitario
        UNASSIGN <f_field>.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = gv_txtunit.
      ENDIF.

    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.



ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

FORM get_aparceria.
  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.
  REFRESH it_acdoca.

  obj_engorda->get_aparceria(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_aparceria = it_acdoca
  ).

  SORT it_acdoca BY aufnr budat.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_acdoca INTO DATA(wa_acdoca) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_acdoca-txt50.
            wa_aux_out-month = wa_acdoca-hsl.
            wa_aux_out-monthst = wa_acdoca-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.


          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF <f_field> EQ 'COSTO PARTICIPACIÓN APARCERÍA'.
            vl_existe = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = 'COSTO PARTICIPACIÓN APARCERÍA'.

        "unitario
        UNASSIGN <f_field>.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = gv_txtunit.
      ENDIF.
    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

  "TOTAL
*  UNASSIGN <f_field>.
*  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*  <f_field> = 'COSTOS APARCERIA'.
*  "TOTAL UNITARIO
*  UNASSIGN <f_field>.
*  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*  <f_field> = gv_txtunit.
*  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*  ""----------------
*  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
*  DATA vl_acum_menge TYPE menge_d.
*
*  UNASSIGN <linea>.
*  LOOP AT it_totales ASSIGNING <linea>.
*    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.
*
*    UNASSIGN <fs_tt>.
*
*    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
*    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
*      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
*      vl_acum_mes = vl_acum_mes + <fs_field>.
*      UNASSIGN <fs_field>.
*
*      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
*      vl_acum_messt = vl_acum_messt + <fs_field>.
*      UNASSIGN <fs_field>.
*    ENDLOOP.
*
*    UNASSIGN <fs_acumulado>.
*    UNASSIGN <fs_field>.
*
*    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
*      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
*      IF <fs_field> EQ 'COSTOS APARCERIA'.
*        CLEAR vl_sytabix.
*        vl_sytabix = sy-tabix + 1.
*        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
*        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
*        <fs_field> = vl_acum_mes.
*
*        REPLACE 'R' IN <f_field> WITH 'S'.
*        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
*        <fs_field> = vl_acum_messt.
*
*        REPLACE 'S' IN <f_field> WITH 'R'.
*        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.
*
*        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
*        IF sy-subrc = 0.
*
*          ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).
*
*          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <f_data> TO <fs_acum>.
*          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
*            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_totales>).
*
*            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
*            IF <fs_totales> GT 0.
*              <fs_field_a> = vl_acum_mes / <fs_totales>.
*
*
*              REPLACE 'R' IN <f_field> WITH 'S'.
*              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
*              <fs_field_a> = vl_acum_messt / <fs_totales>.
*            ENDIF.
*          ENDLOOP.
*        ENDIF.
*
*      ENDIF.
*
*
*    ENDLOOP.
*
*
*  ENDLOOP.




ENDFORM.


"-------------
FORM get_recuperaciones.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->get_recuperaciones(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_recupera = it_recupera
  ).

  SORT it_recupera BY aufnr budat.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr .
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr .
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr .
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostorecup.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ""----------------

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.

    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostorecup.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.


ENDFORM.


FORM get_recuperaciones_post.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->get_recuperaciones_post(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_recupera = it_recupera
  ).

  SORT it_recupera BY aufnr budat.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_recupera[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

*  "TOTALES
*  UNASSIGN <f_field>.
*  UNASSIGN <fs_tt>.
*  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*  <f_field> = gv_txtcostorecup.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
*  UNASSIGN <f_field>.
*  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*  <f_field> = gv_txtunit.
*  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ""----------------

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
*  DATA vl_acum_menge TYPE menge_d.
*
*  UNASSIGN <linea>.
*  LOOP AT it_totales ASSIGNING <linea>.
*    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.
*
*    UNASSIGN <fs_tt>.
*
*    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
*    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
*      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
*      vl_acum_mes = vl_acum_mes + <fs_field>.
*      UNASSIGN <fs_field>.
*
*      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
*      vl_acum_messt = vl_acum_messt + <fs_field>.
*      UNASSIGN <fs_field>.
*    ENDLOOP.
*
*    UNASSIGN <fs_acumulado>.
*    UNASSIGN <fs_field>.
*
*    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
*      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
*      IF <fs_field> EQ gv_txtcostorecup.
*        CLEAR vl_sytabix.
*        vl_sytabix = sy-tabix + 1.
*        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
*        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
*        <fs_field> = vl_acum_mes.
*
*        REPLACE 'R' IN <f_field> WITH 'S'.
*        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
*        <fs_field> = vl_acum_messt.
*
*        REPLACE 'S' IN <f_field> WITH 'R'.
*        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.
*
*        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
*        IF sy-subrc = 0.
*
*          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).
*
*          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
*          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
*            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_totales>).
*
*            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
*            IF <fs_totales> GT 0.
*              <fs_field_a> = vl_acum_mes / <fs_totales>.
*
*
*              REPLACE 'R' IN <f_field> WITH 'S'.
*              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
*              <fs_field_a> = vl_acum_messt / <fs_totales>.
*            ENDIF.
*          ENDLOOP.
*        ENDIF.
*
*      ENDIF.
*
*
*    ENDLOOP.
*
*
*  ENDLOOP.


ENDFORM.


FORM get_recuperaciones_crianza.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->get_recuperaciones_crianza(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_recupera = it_recupera
  ).

  SORT it_recupera BY aufnr budat.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[]."it_recupera[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr .
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-dmbtr.
            wa_aux_out-monthst = wa_recupera-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.



ENDFORM.
""""""""""""subproductos_incubadora"""""""""""""""""""""""""""""""""""
FORM get_subproductos_inc.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  DATA: vl_rgbwart TYPE RANGE OF mseg-bwart,
        wa_rgbwart LIKE LINE OF vl_rgbwart,
        vl_rgwerks TYPE RANGE OF t001w-werks,
        wa_rgwerks LIKE LINE OF vl_rgwerks.


  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '101'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '102'.
  APPEND wa_rgbwart TO vl_rgbwart.

  IF p_werks-high IS INITIAL.
    LOOP AT p_werks.
      CLEAR wa_rgwerks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = p_werks-low.
      APPEND wa_rgwerks TO vl_rgwerks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'BT'.
    wa_rgwerks-low = p_werks-low.
    wa_rgwerks-high = p_werks-high.
    APPEND wa_rgwerks TO vl_rgwerks.
  ENDIF.

  IF gv_dauat NE 'IN03'.

    obj_engorda->get_sub_hc(
      EXPORTING
       p_gjahr  = p_gjahr
        p_popers = vl_rgpoper
        i_bwart   = vl_rgbwart
        i_werks   = vl_rgwerks
      CHANGING
        ch_sub_hc = it_recupera
    ).

  ELSE.
    obj_engorda->get_subprd_gapesa(
    EXPORTING
     p_gjahr  = p_gjahr
      p_popers = vl_rgpoper
      i_bwart   = vl_rgbwart
      i_werks   = vl_rgwerks
      i_aufnr   = it_aufnr_end
    CHANGING
      ch_sub_hc = it_recupera
  ).

  ENDIF.
  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_recupera[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.

      LOOP AT it_aux_out ASSIGNING <linea>.
        ASSIGN COMPONENT 'MONTH' OF STRUCTURE <linea> TO <f_field>.
        IF <f_field> LT 0.
          <f_field> = <f_field> * -1.
        ENDIF.

        ASSIGN COMPONENT 'MONTHST' OF STRUCTURE <linea> TO <f_field>.
        IF <f_field> LT 0.
          <f_field> = <f_field> * -1.
        ENDIF.
      ENDLOOP.

      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.



  "TOTAL
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostorecup.
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ""----------------
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.

    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostorecup.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.


ENDFORM.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""estadisticos incubadora
FORM estadisticos_hue_inc.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA: vl_rgbwart TYPE RANGE OF mseg-bwart,
        wa_rgbwart LIKE LINE OF vl_rgbwart,
        vl_rgwerks TYPE RANGE OF t001w-werks,
        wa_rgwerks LIKE LINE OF vl_rgwerks,
        vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.


  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '101'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '102'.
  APPEND wa_rgbwart TO vl_rgbwart.


  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '261'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '262'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '301'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '302'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '531'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '532'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '551'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '552'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '601'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '602'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '641'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '642'.
  APPEND wa_rgbwart TO vl_rgbwart.

  IF p_werks IS INITIAL.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'BT'.
    wa_rgwerks-low = 'PI01'.
    wa_rgwerks-high = 'PI04'.
    APPEND wa_rgwerks TO vl_rgwerks.
  ELSE.

    IF p_werks-high IS INITIAL.
      LOOP AT p_werks.
        CLEAR wa_rgwerks.
        wa_rgwerks-sign = 'I'.
        wa_rgwerks-option = 'EQ'.
        wa_rgwerks-low = p_werks-low.
        APPEND wa_rgwerks TO vl_rgwerks.
      ENDLOOP.
    ELSE.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'BT'.
      wa_rgwerks-low = p_werks-low.
      wa_rgwerks-high = p_werks-high.
      APPEND wa_rgwerks TO vl_rgwerks.
    ENDIF.
  ENDIF.

  IF gv_dauat NE 'IN03'.
    obj_engorda->estad_huevo_inc(
      EXPORTING
        p_gjahr          = p_gjahr
        p_popers         = vl_rgpoper
        i_werks          = vl_rgwerks
        i_bwart          = vl_rgbwart
        i_aufnr          = it_aufnr_end
        i_aufnr_in02     = it_aufnr_in02
      CHANGING
        ch_estad_hue_inc = it_estad_huevo_inc
    ).

  ELSE.

    obj_engorda->estad_gapesa(
    EXPORTING
      p_gjahr          = p_gjahr
      p_popers         = vl_rgpoper
      i_werks          = vl_rgwerks
      i_bwart          = vl_rgbwart
      i_aufnr          = it_aufnr_end
      i_aufnr_in02     = it_aufnr_in02
    CHANGING
      ch_estad_hue_inc = it_estad_huevo_inc
  ).

  ENDIF.

  "SORT it_recupera BY aufnr budat.

  DELETE it_estad_huevo_inc WHERE wgbez60 = 'BORRAR'.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).


  """""""""""conceptos
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '01Huevo Incubable del mes'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '02Inv. Inicial(Cuarto frío)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '03Huevo Incub.(Trasp/Incubadoras)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '04Hvo Incub(Comprado)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '05Hvo Incub(Vendido)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '06Huevo Incubable a comercial'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '07Huevo Incubable Decomiso'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '08Huevo Incub disp.para Carga'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '09Huevo cargado en el mes'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '10Inv. Final del mes'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '11Huevo cargado para nacimiento del mes'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '12Decomiso(Infertil, embrión, descartes)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '13Total Pollitos Nacidos'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '14% de Nacimiento'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '15Pollitos Enviados a Granjas'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '16Pollitos de Casa Vendidos'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '17Costo  de Huevo'.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_estad_huevo_inc[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge .
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.


    "se quitan los numeros
    UNASSIGN <linea>.


    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


*            "unitario
*            UNASSIGN <f_field>.
*            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

*          "unitario
*          UNASSIGN <f_field>.
*          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '01' OR <f_field>+0(2) EQ '02' OR <f_field>+0(2) EQ '03'
       OR <f_field>+0(2) EQ '04' OR <f_field>+0(2) EQ '05' OR <f_field>+0(2) EQ '06'
       OR <f_field>+0(2) EQ '07' OR <f_field>+0(2) EQ '08' OR <f_field>+0(2) EQ '09'
       OR <f_field>+0(2) EQ '10' OR <f_field>+0(2) EQ '11' OR <f_field>+0(2) EQ '12'
       OR <f_field>+0(2) EQ '13' OR <f_field>+0(2) EQ '14' OR <f_field>+0(2) EQ '15'
       OR <f_field>+0(2) EQ '16' OR <f_field>+0(2) EQ '17' OR <f_field>+0(2) EQ '18'
       OR <f_field>+0(2) EQ '19' OR <f_field>+0(2) EQ '20'.


      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.


ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM estadisticos_hue_aca.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA: vl_rgbwart TYPE RANGE OF mseg-bwart,
        wa_rgbwart LIKE LINE OF vl_rgbwart,
        vl_rgwerks TYPE RANGE OF t001w-werks,
        wa_rgwerks LIKE LINE OF vl_rgwerks,
        vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgaufnr TYPE RANGE OF aufk-aufnr,
        wa_rgaufnr LIKE LINE OF vl_rgaufnr.


  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '101'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '102'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '221'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '222'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '261'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '262'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '301'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '302'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '531'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '532'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '551'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '552'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '601'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '602'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '641'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '642'.
  APPEND wa_rgbwart TO vl_rgbwart.

*  IF p_werks IS INITIAL.
*    wa_rgwerks-sign = 'I'.
*    wa_rgwerks-option = 'BT'.
*    wa_rgwerks-low = 'PI01'.
*    wa_rgwerks-high = 'PI04'.
*    APPEND wa_rgwerks TO vl_rgwerks.
*  ELSE.
*
*    IF p_werks-high IS INITIAL.
*      LOOP AT p_werks.
*        CLEAR wa_rgwerks.
*        wa_rgwerks-sign = 'I'.
*        wa_rgwerks-option = 'EQ'.
*        wa_rgwerks-low = p_werks-low.
*        APPEND wa_rgwerks TO vl_rgwerks.
*      ENDLOOP.
*    ELSE.
*      wa_rgwerks-sign = 'I'.
*      wa_rgwerks-option = 'BT'.
*      wa_rgwerks-low = p_werks-low.
*      wa_rgwerks-high = p_werks-high.
*      APPEND wa_rgwerks TO vl_rgwerks.
*    ENDIF.
*  ENDIF.

  wa_rgwerks-sign = 'I'.
  wa_rgwerks-option = 'EQ'.
  wa_rgwerks-low = 'PQ01'.
  APPEND wa_rgwerks TO vl_rgwerks.

  LOOP AT it_aufnr_0100 INTO DATA(wa_0100).
    wa_rgaufnr-sign = 'I'.
    wa_rgaufnr-option = 'EQ'.
    wa_rgaufnr-low = wa_0100-aufnr.
    APPEND wa_rgaufnr TO vl_rgaufnr.


  ENDLOOP.

  obj_engorda->estad_huevo_inc2(
    EXPORTING
      p_gjahr          = p_gjahr
      p_popers         = vl_rgpoper
      i_werks          = vl_rgwerks
      i_bwart          = vl_rgbwart
      i_aufnr          = it_aufnr_end
      i_aufnr_0100     = vl_rgaufnr
    CHANGING
      ch_estad_hue_inc = it_estad_huevo_inc
  ).


  "SORT it_recupera BY aufnr budat.

  DELETE it_estad_huevo_inc WHERE wgbez60 = 'BORRAR'.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  """""""""""conceptos
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '01Huevo Incubable del mes'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '02Inv. Inicial(Cuarto frío)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '03Huevo Incub.(Trasp/Incubadoras)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '04Hvo Incub(Comprado)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '05Hvo Incub(Vendido)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '06Huevo Incubable a comercial'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '07Huevo Incubable Decomiso'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '08Huevo Incub disp.para Carga'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '09Huevo cargado en el mes'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '10Inv. Final del mes'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '11Huevo cargado para nacimiento del mes'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '12Decomiso(Infertil, embrión, descartes)'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '13Total Pollitos Nacidos'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '14% de Nacimiento'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '15Pollitos Enviados a Granjas'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '16Pollitos de Casa Vendidos'.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = '17Costo  de Huevo'.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_estad_huevo_inc[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge .
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.


    "se quitan los numeros
    UNASSIGN <linea>.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


*            "unitario
*            UNASSIGN <f_field>.
*            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

*          "unitario
*          UNASSIGN <f_field>.
*          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

  LOOP AT <fs_outtable> ASSIGNING <linea>.

    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '01' OR <f_field>+0(2) EQ '02' OR <f_field>+0(2) EQ '03'
       OR <f_field>+0(2) EQ '04' OR <f_field>+0(2) EQ '05' OR <f_field>+0(2) EQ '06'
       OR <f_field>+0(2) EQ '07' OR <f_field>+0(2) EQ '08' OR <f_field>+0(2) EQ '09'
       OR <f_field>+0(2) EQ '10' OR <f_field>+0(2) EQ '11' OR <f_field>+0(2) EQ '12'
       OR <f_field>+0(2) EQ '13' OR <f_field>+0(2) EQ '14' OR <f_field>+0(2) EQ '15'
       OR <f_field>+0(2) EQ '16' OR <f_field>+0(2) EQ '17' OR <f_field>+0(2) EQ '18'
       OR <f_field>+0(2) EQ '19' OR <f_field>+0(2) EQ '20' OR <f_field>+0(2) EQ '21'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM get_unitarios_incuba.


  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_index    TYPE sy-tabix.

  DATA:

    vl_totalprod        TYPE dmbtr_cs, vl_totalprodst    TYPE dmbtr_cs,
    vl_total_pollitos   TYPE menge_d,
    vl_hue_inc_mes      TYPE menge_d,
    vl_inv_inicial      TYPE menge_d,
    vl_hue_inc_tras     TYPE menge_d,
    vl_hue_inc_comer    TYPE menge_d,
    vl_hue_inc_carga    TYPE menge_d,
    vl_inv_final        TYPE menge_d,
    vl_hue_carg_mes     TYPE menge_d,
    vl_hue_carg_nac_mes TYPE menge_d,
    vl_decomiso         TYPE menge_d,
    vl_hue_inc_deco     TYPE menge_d,
    vl_hue_inc_comp     TYPE menge_d,
    vl_hue_inc_vend     TYPE menge_d,
    vl_huevo_inc_cd     TYPE dmbtr_cs, vl_huevo_inc_cdst TYPE dmbtr_cs.



  FIELD-SYMBOLS: <fs_st>     TYPE any,
                 <fs_mes>    TYPE any,
                 <fs_field>  TYPE any,
                 <fs_st2>    TYPE any,
                 <fs_field2> TYPE any.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.
        WHEN gv_txttotalcostprod.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_totalprod = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_totalprodst = <fs_mes>.

        WHEN 'HUEVO INCUBABLE'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_huevo_inc_cd = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_huevo_inc_cdst = <fs_mes>.

        WHEN 'Huevo Incubable del mes'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_inc_mes = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_inc_mes = <fs_mes>.

        WHEN 'Huevo cargado para nacimiento del mes'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_carg_nac_mes = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_carg_nac_mes = <fs_mes>.


        WHEN 'Inv. Inicial(Cuarto frío)'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_inv_inicial = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_inv_inicial = <fs_mes>.

        WHEN 'Huevo Incubable Decomiso'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_inc_deco = <fs_mes>.

        WHEN 'Hvo Incub(Comprado)'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_inc_comp = <fs_mes>.

        WHEN 'Hvo Incub(Vendido)'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_inc_vend = <fs_mes>.

        WHEN 'Huevo Incub.(Trasp/Incubadoras)'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_inc_tras = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_inc_tras = <fs_mes>.

        WHEN 'Decomiso(Infertil, embrión, descartes)'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_decomiso = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_decomiso = <fs_mes>.
        WHEN 'Inv. Final del mes'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_inv_final = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_inv_final = <fs_mes>.
        WHEN 'Huevo Incubable a comercial'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_hue_inc_comer = <fs_mes>.

      ENDCASE.

    ENDLOOP.


    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.
        WHEN gv_txttotalcostprod.
          CLEAR vl_index.
          vl_index = sy-tabix + 1.


        WHEN 'Total Pollitos Nacidos'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_field>.
          <fs_field> = vl_hue_carg_nac_mes - vl_decomiso.

          UNASSIGN <fs_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_field>.
          <fs_field> = vl_hue_carg_nac_mes - vl_decomiso.

          vl_total_pollitos = <fs_field>.

          READ TABLE <fs_outtable> ASSIGNING <fs_st2> INDEX vl_index.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st2> TO <fs_field2>.
          IF vl_total_pollitos GT 0.
            <fs_field2> = vl_totalprod / vl_total_pollitos.

            UNASSIGN <fs_field2>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st2> TO <fs_field2>.
            <fs_field2> = vl_totalprodst / vl_total_pollitos.

          ENDIF.

        WHEN 'Huevo Incub disp.para Carga'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_field>.
          <fs_field> = vl_hue_inc_mes + vl_inv_inicial + vl_hue_inc_tras + vl_hue_inc_comer
          + vl_hue_inc_deco + vl_hue_inc_comp + vl_hue_inc_vend.

          UNASSIGN <fs_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_field>.
          <fs_field> = vl_hue_inc_mes + vl_inv_inicial + vl_hue_inc_tras + vl_hue_inc_comer
          + vl_hue_inc_deco + vl_hue_inc_comp + vl_hue_inc_vend.

          vl_hue_inc_carga = <fs_field>.

        WHEN 'Huevo cargado en el mes'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_field>.
          <fs_field> = vl_hue_inc_carga - vl_inv_final.

          UNASSIGN <fs_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_field>.
          <fs_field> = vl_hue_inc_carga - vl_inv_final.

          vl_hue_carg_mes = <fs_field>.

        WHEN '% de Nacimiento'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_field>.
          IF vl_total_pollitos GT 0.
            <fs_field> =  vl_total_pollitos / vl_hue_carg_mes .

            UNASSIGN <fs_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_field>.
            <fs_field> = vl_total_pollitos / vl_hue_carg_mes .
          ENDIF.

        WHEN 'Costo  de Huevo'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_field>.
          IF vl_hue_carg_mes GT 0.
            <fs_field> = vl_huevo_inc_cd / vl_hue_carg_mes.

            UNASSIGN <fs_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_field>.
            <fs_field> = vl_huevo_inc_cdst / vl_hue_carg_mes.
          ENDIF.

      ENDCASE.
    ENDLOOP.




    CLEAR:  vl_totalprod, vl_totalprodst,
            vl_total_pollitos,
            vl_hue_inc_mes,
            vl_inv_inicial,
            vl_hue_inc_tras,
            vl_hue_inc_comer,
            vl_hue_inc_carga,
            vl_inv_final,
            vl_hue_carg_mes,
            vl_decomiso,
            vl_huevo_inc_cd, vl_huevo_inc_cdst.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM estadisticos_postura.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->get_estadisticos_post(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_recupera = it_recupera
  ).

  "SORT it_recupera BY aufnr budat.

  DELETE it_recupera WHERE wgbez60 = 'BORRAR'.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostorecup.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = '% Huevo Incubable Granjas'.

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_recupera[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge .
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


*            "unitario
*            UNASSIGN <f_field>.
*            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

*          "unitario
*          UNASSIGN <f_field>.
*          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'
       OR <f_field>+0(2) EQ '4.' OR <f_field>+0(2) EQ '5.' OR <f_field>+0(2) EQ '6.'
       OR <f_field>+0(2) EQ '7.'.


      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

**  "TOTALES
*  UNASSIGN <f_field>.
*  UNASSIGN <fs_tt>.
*  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*  <f_field> = gv_txtcostorecup.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <fs_field>.
  <fs_field> = '% Huevo Incubable'.

*
*  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*  "TOTAL UNITARIO
*  UNASSIGN <f_field>.
*  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*  <f_field> = gv_txtunit.
*  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ""----------------

*  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.
*
    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
*
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostorecup.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.
*
*
  ENDLOOP.
ENDFORM.
""""""""""""CALCULO DEL WIP"""""""""""""""""""""""""""""""
FORM get_costowip.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->get_costowip(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_recupera = it_recupera
  ).

  "SORT it_recupera BY aufnr budat.

  DELETE it_recupera WHERE wgbez60 = 'BORRAR'.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_recupera[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr .
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.


            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.


ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

FORM estadisticos_crianza.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->get_estadisticos_crianza(
    EXPORTING
      i_aufnr  = it_aufnr_end
    CHANGING
      ch_recupera = it_recupera
  ).

  "SORT it_recupera BY aufnr budat.

  DELETE it_recupera WHERE wgbez60 = 'BORRAR'.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge .
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_recupera-wgbez60.
            wa_aux_out-month = wa_recupera-menge.
            wa_aux_out-monthst = wa_recupera-menge.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


*            "unitario
*            UNASSIGN <f_field>.
*            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

*          "unitario
*          UNASSIGN <f_field>.
*          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'
       OR <f_field>+0(2) EQ '4.' OR <f_field>+0(2) EQ '5.' OR <f_field>+0(2) EQ '6.'
       OR <f_field>+0(2) EQ '7.'.


      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

*  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.
*
    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
*
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostorecup.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.
*
*
  ENDLOOP.
ENDFORM.

"""recuperaciones Alimento
FORM get_recupera_alim.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  obj_engorda->get_recupera_alim(
    EXPORTING
       p_gjahr = p_gjahr
       p_popers = vl_rgpoper
    CHANGING
      ch_recupera = it_recupera_alim
  ).

  SORT it_recupera_alim BY aufnr budat.

  IF p_werks IS NOT INITIAL.
    DELETE it_recupera_alim WHERE werks NOT IN p_werks.
  ENDIF.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  IF vl_solo_maquila EQ abap_true.
    REFRESH it_recupera_alim.
  ENDIF.

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_recupera_alim[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.

  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostorecup.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ""----------------

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.

    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostorecup.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.


ENDFORM.
"maquila """"""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM get_maquila.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  DATA: rg_werks   TYPE RANGE OF afpo-dwerk,
        wa_rgwerks LIKE LINE OF rg_werks.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  obj_engorda->get_maquila(
    EXPORTING
       p_gjahr = p_gjahr
       p_popers = vl_rgpoper
       p_werks = rg_werks
    CHANGING
      ch_maquila = it_maquila
  ).

  SORT it_maquila BY aufnr budat_mkpf.

  IF vl_solo_maquila EQ abap_true .
    LOOP AT it_maquila ASSIGNING FIELD-SYMBOL(<fsw_maquila>).
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fsw_maquila> TO <f_field>.
      <f_field> = 'MATERIA PRIMA'.
    ENDLOOP.
  ENDIF.

  IF vl_solo_maquila EQ abap_true AND p_werks-low NE 'PA01'.
    IF p_werks IS NOT INITIAL.
      REFRESH it_maquila.
    ENDIF.
  ENDIF.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_maquila[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.
          IF wa_aux-month LT 0.
            wa_aux-month = wa_aux-month * -1.
            wa_aux-monthst = wa_aux-monthst * - 1.
          ENDIF.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF <f_field> EQ 'MATERIA PRIMA'.
            vl_existe = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = 'MATERIA PRIMA'.

        "unitario
        UNASSIGN <f_field>.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = gv_txtunit.
      ENDIF.
    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.


ENDFORM.
""""""""""""""""""""""""""maquila ACA!"""""""""""""""""""""""""""""""""""
FORM get_maquila_aca.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_tt>        TYPE table,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  DATA: rg_werks   TYPE RANGE OF afpo-dwerk,
        wa_rgwerks LIKE LINE OF rg_werks.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  IF p_werks-high IS INITIAL.

    LOOP AT p_werks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = p_werks-low.
      APPEND wa_rgwerks TO rg_werks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'BT'.
    wa_rgwerks-low = p_werks-low.
    wa_rgwerks-high = p_werks-high.
    APPEND wa_rgwerks TO rg_werks.
  ENDIF.


  obj_engorda->get_maquila_aca(
    EXPORTING
       p_gjahr = p_gjahr
       p_popers = vl_rgpoper
       p_werks = rg_werks
    CHANGING
      ch_maquila = it_maquila
  ).

  SORT it_maquila BY aufnr budat_mkpf.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_maquila[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

*    "se quitan los numeros
*    UNASSIGN <linea>.
*
*    LOOP AT it_aux_out ASSIGNING <linea>.
*      ASSIGN COMPONENT 'CONCEPTO'  OF STRUCTURE <linea> TO <f_field> .
*      DATA(len) = strlen( <f_field> ).
*      len = len - 2.
*      IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.' OR <f_field>+0(2) EQ '4.'.
*        <f_field> = <f_field>+2(len).
*      ENDIF.
*    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.
                ENDIF.

                IF <fs_data1> GT 0.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                ENDIF.
                <f_field> = wa_aux-monthst / <fs_data1> .
              ENDLOOP.
            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.
              ENDIF..
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
              IF <fs_data2> GT 0.
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.

          IF gv_tipore EQ 'ALIMENTO'.
            "IF <f_field> EQ 'MATERIA PRIMA'.
            vl_existe = 'X'.
            " ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .

          <f_field> = 'MATERIA PRIMA'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'
       OR <f_field>+0(2) EQ '4.' OR <f_field>+0(2) EQ '5.' OR <f_field>+0(2) EQ '6.'
       OR <f_field>+0(2) EQ '7.'.
      <f_field> = <f_field>+2(len).
    ENDIF.

  ENDLOOP.

  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostodir.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.
  DATA: vl_mp       TYPE dmbtr, vl_mpst TYPE dmbtr,
        vl_merma    TYPE dmbtr, vl_mermast TYPE dmbtr,
        vl_i_mp     TYPE i, vl_i_maq TYPE i, vl_i_merma TYPE i, vl_i_mermam TYPE i.

  LOOP AT it_totales ASSIGNING <fs_linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
    "se suma aparceria

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " break jhernandev.
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostodir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.

        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "          ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.
            ENDIF.

            REPLACE 'R' IN <f_field> WITH 'S'.
            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.


ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""MAQUILA GAPESA"""""""""""""""""""""""""""""""""""""""""""
FORM get_maquila_gapesa.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_tt>        TYPE table,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  DATA: rg_werks   TYPE RANGE OF afpo-dwerk,
        wa_rgwerks LIKE LINE OF rg_werks.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.

  IF p_werks-high IS INITIAL.

    LOOP AT p_werks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = p_werks-low.
      APPEND wa_rgwerks TO rg_werks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'BT'.
    wa_rgwerks-low = p_werks-low.
    wa_rgwerks-high = p_werks-high.
    APPEND wa_rgwerks TO rg_werks.
  ENDIF.


  obj_engorda->get_maquila_gapesa(
    EXPORTING
       p_gjahr = p_gjahr
       p_popers = vl_rgpoper
       p_werks = rg_werks
    CHANGING
      ch_maquila = it_maquila
  ).

  SORT it_maquila BY aufnr budat_mkpf.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_maquila[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-dmbtr.
          wa_aux_out-monthst = wa_recupera-dmbtr_st.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

*    "se quitan los numeros
*    UNASSIGN <linea>.
*
*    LOOP AT it_aux_out ASSIGNING <linea>.
*      ASSIGN COMPONENT 'CONCEPTO'  OF STRUCTURE <linea> TO <f_field> .
*      DATA(len) = strlen( <f_field> ).
*      len = len - 2.
*      IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.' OR <f_field>+0(2) EQ '4.'.
*        <f_field> = <f_field>+2(len).
*      ENDIF.
*    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.
                ENDIF.

                IF <fs_data1> GT 0.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                ENDIF.
                <f_field> = wa_aux-monthst / <fs_data1> .
              ENDLOOP.
            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.
              ENDIF..
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
              IF <fs_data2> GT 0.
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.

          IF gv_tipore EQ 'ALIMENTO'.
            "IF <f_field> EQ 'MATERIA PRIMA'.
            vl_existe = 'X'.
            " ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .

          <f_field> = 'MATERIA PRIMA'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'
       OR <f_field>+0(2) EQ '4.' OR <f_field>+0(2) EQ '5.' OR <f_field>+0(2) EQ '6.'
       OR <f_field>+0(2) EQ '7.'.
      <f_field> = <f_field>+2(len).
    ENDIF.

  ENDLOOP.

  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostodir.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.
  DATA: vl_mp       TYPE dmbtr, vl_mpst TYPE dmbtr,
        vl_merma    TYPE dmbtr, vl_mermast TYPE dmbtr,
        vl_i_mp     TYPE i, vl_i_maq TYPE i, vl_i_merma TYPE i, vl_i_mermam TYPE i.

  LOOP AT it_totales ASSIGNING <fs_linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
    "se suma aparceria

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " break jhernandev.
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostodir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.

        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "          ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.
            ENDIF.

            REPLACE 'R' IN <f_field> WITH 'S'.
            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.


ENDFORM.
""""""""""""costos indirectos gapesa
FORM get_costosind_gapesa.
  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  SELECT aufnr, racct,'COSTO MAQUILA' AS txt50, hsl, poper, budat,
         ryear, awref, awitem, belnr, docln, werks,
         rcntr
  INTO TABLE @it_acdoca
  FROM acdoca
  WHERE ryear EQ @p_gjahr
  AND racct EQ '0601001038'
  AND poper IN @so_poper
  AND werks IN @p_werks.


  SORT it_acdoca BY aufnr budat txt50.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_acdoca[].
    DELETE aux_aufnr WHERE budat NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_acdoca).
      CLEAR wa_aux_out.
      "LOOP AT it_acdoca INTO DATA(wa_acdoca) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_acdoca-txt50.
          wa_aux_out-month = wa_acdoca-hsl.
          wa_aux_out-monthst = wa_acdoca-hsl.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      " ENDLOOP.
    ENDLOOP.

*

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.


          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF gv_tipore EQ 'ALIMENTO'.
            IF <f_field> EQ 'COSTO DE PROCESO '.
              vl_existe = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.


        IF gv_tipore EQ 'ALIMENTO'.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = 'COSTO DE PROCESO'.


          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.
        ENDIF.
      ENDIF.

    ENDIF.

    REFRESH it_aux_out.
    " ENDIF.
  ENDLOOP.

  "se quitan los numeros
  UNASSIGN <linea>.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
    DATA(len) = strlen( <f_field> ).
    len = len - 2.
    IF <f_field>+0(2) EQ '1.' OR <f_field>+0(2) EQ '2.' OR <f_field>+0(2) EQ '3.'.
      <f_field> = <f_field>+2(len).
    ENDIF.
  ENDLOOP.

  """"""""""""""""""""""""""

  "TOTAL
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostoindir.
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ""----------------
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.

  UNASSIGN <linea>.
  LOOP AT it_totales ASSIGNING <linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    UNASSIGN <fs_tt>.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_acumulado>).
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.

    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      IF <fs_field> EQ gv_txtcostoindir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          "ASSIGN COMPONENT <f_field> OF STRUCTURE wa_tot1 TO FIELD-SYMBOL(<f_data>).

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.


              REPLACE 'R' IN <f_field> WITH 'S'.
              ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.




ENDFORM.

"""""""""""""""estadisticos huevo gapesa
FORM estadisticos_hue_gapesa.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA: vl_rgbwart TYPE RANGE OF mseg-bwart,
        wa_rgbwart LIKE LINE OF vl_rgbwart,
        vl_rgwerks TYPE RANGE OF t001w-werks,
        wa_rgwerks LIKE LINE OF vl_rgwerks,
        vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper,
        vl_rgaufnr TYPE RANGE OF aufk-aufnr,
        wa_rgaufnr LIKE LINE OF vl_rgaufnr
        .


  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '101'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '102'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '221'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '222'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '261'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '262'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '301'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '302'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '531'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '532'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '551'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '552'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '601'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '602'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '641'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '642'.
  APPEND wa_rgbwart TO vl_rgbwart.

*  IF p_werks IS INITIAL.
*    wa_rgwerks-sign = 'I'.
*    wa_rgwerks-option = 'BT'.
*    wa_rgwerks-low = 'PI01'.
*    wa_rgwerks-high = 'PI04'.
*    APPEND wa_rgwerks TO vl_rgwerks.
*  ELSE.
*
*    IF p_werks-high IS INITIAL.
*      LOOP AT p_werks.
*        CLEAR wa_rgwerks.
*        wa_rgwerks-sign = 'I'.
*        wa_rgwerks-option = 'EQ'.
*        wa_rgwerks-low = p_werks-low.
*        APPEND wa_rgwerks TO vl_rgwerks.
*      ENDLOOP.
*    ELSE.
*      wa_rgwerks-sign = 'I'.
*      wa_rgwerks-option = 'BT'.
*      wa_rgwerks-low = p_werks-low.
*      wa_rgwerks-high = p_werks-high.
*      APPEND wa_rgwerks TO vl_rgwerks.
*    ENDIF.
*  ENDIF.

  wa_rgwerks-sign = 'I'.
  wa_rgwerks-option = 'EQ'.
  wa_rgwerks-low = 'PQ01'.
  APPEND wa_rgwerks TO vl_rgwerks.

  LOOP AT it_aufnr_0100 INTO DATA(wa_0100).
    wa_rgaufnr-sign = 'I'.
    wa_rgaufnr-option = 'EQ'.
    wa_rgaufnr-low = wa_0100-aufnr.
    APPEND wa_rgaufnr TO vl_rgaufnr.

  ENDLOOP.


  obj_engorda->estad_huevo_inc2(
    EXPORTING
      p_gjahr          = p_gjahr
      p_popers         = vl_rgpoper
      i_werks          = vl_rgwerks
      i_bwart          = vl_rgbwart
      i_aufnr          = it_aufnr_end
      i_aufnr_0100     = vl_rgaufnr
    CHANGING
      ch_estad_hue_inc = it_estad_huevo_inc
  ).


  "SORT it_recupera BY aufnr budat.

  DELETE it_estad_huevo_inc WHERE wgbez60 = 'BORRAR'.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_estad_huevo_inc[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge .
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.


    "se quitan los numeros
    UNASSIGN <linea>.

    LOOP AT it_aux_out ASSIGNING <linea>.

      ASSIGN COMPONENT 'CONCEPTO'  OF STRUCTURE <linea> TO <f_field> .
      DATA(len) = strlen( <f_field> ).
      len = len - 2.
      IF <f_field>+0(2) EQ '01' OR <f_field>+0(2) EQ '02' OR <f_field>+0(2) EQ '03'
         OR <f_field>+0(2) EQ '04' OR <f_field>+0(2) EQ '05' OR <f_field>+0(2) EQ '06'
         OR <f_field>+0(2) EQ '07' OR <f_field>+0(2) EQ '08' OR <f_field>+0(2) EQ '09'
         OR <f_field>+0(2) EQ '10' OR <f_field>+0(2) EQ '11' OR <f_field>+0(2) EQ '12'
         OR <f_field>+0(2) EQ '13' OR <f_field>+0(2) EQ '14' OR <f_field>+0(2) EQ '15'
         OR <f_field>+0(2) EQ '16' OR <f_field>+0(2) EQ '17' OR <f_field>+0(2) EQ '18'
         OR <f_field>+0(2) EQ '19' OR <f_field>+0(2) EQ '20' OR <f_field>+0(2) EQ '21'.
        <f_field> = <f_field>+2(len).
      ENDIF.
    ENDLOOP.




    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.

                  UNASSIGN <f_field>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


*            "unitario
*            UNASSIGN <f_field>.
*            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.

                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                  <f_field> = wa_aux-monthst / <fs_data1> .
                ENDIF.
              ENDLOOP.
            ENDIF.


          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

*          "unitario
*          UNASSIGN <f_field>.
*          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.

                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.




        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.


ENDFORM.
"""""""""""""""""""""""""""""""""""""""""""""""""""
FORM build_rows_aca.

  FIELD-SYMBOLS: <fs_st>   TYPE any,
                 <fs_row>  TYPE any,
                 <fs_cell> TYPE any.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = 'GASTOS INDIRECTOS'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = gv_txtunit.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = 'MANO DE OBRA'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = gv_txtunit.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = 'GASTOS DE EQUIPO'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = gv_txtunit.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = gv_txttotalcostprod.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = gv_txtunit.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = gv_txtcostoindir.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_row>.
  <fs_row> = gv_txtunit.






ENDFORM.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM get_prom_edad.

  DATA: rg_fechas    TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix   TYPE sy-tabix,
        vl_mes(5)    TYPE c,vl_messt(5)  TYPE c,
        vl_diasfecha TYPE i.

  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE i,
           monthst  TYPE i,
           month7   TYPE dmbtr,
           monthd   TYPE i,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->calculate_dates(
      CHANGING
        p_rgfechas = rg_fechas
    ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).
    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.

      PERFORM get_ndiasfechas
        USING
          wa_auxaufnr-getri
          wa_auxaufnr-ftrmi
        CHANGING
          vl_diasfecha
        .
      vl_diasfecha = abs( vl_diasfecha ).

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = 'Edad Prom. Días'.
          wa_aux_out-month = vl_diasfecha.
          wa_aux_out-monthst = 1.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.
    ENDLOOP.
    "
    vl_find = abap_false.
    CLEAR wa_aux_out.
    READ TABLE it_aux_out INTO DATA(wa_semana) INDEX 1.
    wa_semana-monthd = wa_semana-month / wa_semana-monthst.
    wa_semana-month7 = wa_semana-monthd / 7.
    MODIFY it_aux_out FROM wa_semana INDEX 1.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthd.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthd.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.

            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month7.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month7.

            vl_find = abap_false.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthd.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthd.

            """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = 'Edad Prom. Semanas'.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month7.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month7.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

        ENDLOOP.
      ENDIF.
    ENDIF.

    REFRESH it_aux_out.
    "
  ENDLOOP.


ENDFORM.

FORM get_ndiasFechas USING p_fechai TYPE datum
                           p_fechaf TYPE datum
                     CHANGING p_dias_fecha TYPE i.



  CALL FUNCTION 'HR_SGPBS_YRS_MTHS_DAYS'
    EXPORTING
      beg_da     = p_fechai
      end_da     = p_fechaf
    IMPORTING
*     no_day     =
*     no_month   =
*     no_year    =
      no_cal_day = p_dias_fecha
*    EXCEPTIONS
*     dateint_error = 1
*     others     = 2
    .

ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM get_mortandad.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->calculate_mortal(
EXPORTING
  i_aufnr  = it_aufnr_end
CHANGING
  ch_mortandad = it_mortandad
).

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).
    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_mortandad INTO DATA(wa_mortandad) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mortandad-matnr.
            wa_aux_out-month = wa_mortandad-menge.
            wa_aux_out-monthst = wa_mortandad-menge.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.
    "
    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_find = abap_false.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

        ENDLOOP.
      ENDIF.
    ENDIF.

    REFRESH it_aux_out.
    "
  ENDLOOP.


ENDFORM.
"get pollitos
FORM get_pollitos.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.



  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.
  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.



  SORT it_mb51 BY aufnr budat.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).


  DATA(it_pollitos) = it_mb51[].

  DELETE it_pollitos WHERE ( matnr <> '000000000000400188' AND matnr <> '000000000000400190' ).

  LOOP AT it_pollitos ASSIGNING FIELD-SYMBOL(<fs_pollito>).
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_pollito> TO FIELD-SYMBOL(<fs_lpollito>).
    <fs_lpollito> = 'Pollito recibido incubadora'.
  ENDLOOP.

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_pollitos INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
            "wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge. "wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_find = abap_false.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.



          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.


        ENDLOOP.
      ENDIF.

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.


ENDFORM.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM get_kgsAlimento.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.



  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.
  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.



  SORT it_mb51 BY aufnr budat.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).


  DATA(it_kgsalimento) = it_mb51[].

  DELETE it_kgsalimento WHERE matkl <> 'PT0004'.

  LOOP AT it_kgsalimento ASSIGNING FIELD-SYMBOL(<fs_kgsalim>).
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_kgsalim> TO FIELD-SYMBOL(<fs_lkgs>).
    <fs_lkgs> = 'Kgs. Alimento Consum.'.
  ENDLOOP.

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_end[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_kgsalimento INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
            "wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge. "wa_mb51-dmbtr_st.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-menge. "wa_mb51-dmbtr.
            wa_aux_out-monthst = wa_mb51-menge.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_find = abap_false.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.



          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.


        ENDLOOP.
      ENDIF.

    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.


ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM set_indicadores.

  DATA: rg_fechas        TYPE RANGE OF acdoca-budat,
        vl_mes(5)        TYPE c,vl_messt(5)  TYPE c,
        vl_pollitos      TYPE menge_d, vl_pollitosst    TYPE menge_d,
        vl_desembar      TYPE menge_d, vl_desembarst TYPE menge_d,
        vl_pollito_cd    TYPE menge_d,
        vl_granja        TYPE menge_d,vl_granjast TYPE menge_d,
        vl_totalp        TYPE menge_d, vl_totalpst TYPE menge_d,
        vl_faltantes     TYPE menge_d, vl_faltantesst   TYPE menge_d,
        vl_porc_falt     TYPE menge_d,vl_porc_faltst TYPE menge_d,
        vl_porc_desem    TYPE menge_d,vl_porc_desemst  TYPE menge_d,
        vl_porc_granja   TYPE menge_d, vl_porc_granjast TYPE menge_d.

  DATA:

    vl_costoalim      TYPE menge_d,vl_costoalimst    TYPE menge_d,
    vl_costopollito   TYPE menge_d, vl_costopollitost TYPE menge_d,
    vl_kilosalim      TYPE menge_d,vl_kilosalimst    TYPE menge_d,
    vl_metros2        TYPE menge_d,
    vl_pollosp        TYPE menge_d, vl_pollospst      TYPE menge_d,
    vl_kilosp         TYPE menge_d, vl_kilospst TYPE menge_d,
    vl_pp_ave         TYPE menge_d, vl_pp_avest       TYPE menge_d,
    vl_conversion     TYPE menge_d, vl_conversionst TYPE menge_d,
    vl_edad_dias      TYPE i, vl_edad_diasst    TYPE i,
    vl_total_mort     TYPE menge_d, vl_total_mortst TYPE menge_d,
    vl_ganancia       TYPE menge_d, vl_gananciast     TYPE menge_d.



  FIELD-SYMBOLS: <fs_st>     TYPE any,
                 <fs_mes>    TYPE any,
                 <fs_field>  TYPE any,
                 <fs_st2>    TYPE any,
                 <fs_field2> TYPE any.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Pollos iniciados en granja'.


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = '% Mortandad en desembarque'.


  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Faltantes/sobrantes fin lote'.


  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = '% Mortandad Faltante/Sobrante'.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = '% Mortalidad en granja'.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = '% Total Mortandad'.

  PERFORM get_totalespro. "TOTALES AVES/KILOS PRODUCIDOS Y PESO PROMEDIO

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Costo Tonelada Alimento'.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Consumo por Ave'.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Conversión Alimenticia'.


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.
        WHEN 'ALIMENTO'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costoalim = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costoalimst = <fs_mes>.

        WHEN gv_txttotalpollosp.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollosp = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollospst = <fs_mes>.

        WHEN gv_txttotalkilosp.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilosp = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilospst = <fs_mes>.


        WHEN 'Peso Promedio Pollo'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pp_ave = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pp_avest = <fs_mes>.


        WHEN 'Pollito recibido incubadora'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollitos = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollitosst = <fs_mes>.

        WHEN 'POLLITO'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costopollito = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costopollitost = <fs_mes>.

        WHEN 'Edad Prom. Días'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_edad_dias = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_edad_diasst = <fs_mes>.

        WHEN 'Kgs. Alimento Consum.'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilosalim = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilosalimst = <fs_mes>.


        WHEN 'TOTAL POLLOS PRODUCIDOS'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_totalp = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_totalpst = <fs_mes>.

        WHEN 'Mortandad en Granja'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_granja = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_granjast = <fs_mes>.


        WHEN 'Mortandad al Desembarque'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_desembar = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_desembarst = <fs_mes>.

        WHEN '% Mortandad en desembarque'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_pollitos GT 0.
            <fs_mes> = vl_desembar / vl_pollitos * 100.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_desembarst / vl_pollitosst * 100.

          ENDIF.
          vl_porc_desem = <fs_mes>.
        WHEN 'Pollos iniciados en granja'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_pollitos - vl_desembar.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_pollitosst - vl_desembarst.

        WHEN 'Costo Tonelada Alimento'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_kilosalim GT 0.
            <fs_mes> = vl_costoalim / vl_kilosalim.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_costoalimst / vl_kilosalimst.

          ENDIF.
        WHEN 'Consumo por Ave'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_kilosalim GT 0.
            <fs_mes> =  vl_kilosalim / vl_pollosp .

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> =  vl_kilosalimst / vl_pollospst .


          ENDIF.
        WHEN 'Conversión Alimenticia'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_kilosp GT 0.
            <fs_mes> =  vl_kilosalim / vl_kilosp.
            vl_conversion = <fs_mes>.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> =  vl_kilosalimst / vl_kilospst.

          ENDIF.
      ENDCASE.

    ENDLOOP.
    CLEAR: vl_pollitos, vl_desembar,
        vl_granja, vl_totalp ,
        vl_faltantes , vl_porc_falt,
        vl_porc_desem , vl_porc_granja.
  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.
FORM set_indicadores_post.

  DATA: rg_fechas      TYPE RANGE OF acdoca-budat,
        vl_mes(5)      TYPE c,vl_messt(5)  TYPE c,
        vl_huevo_inc   TYPE menge_d,
        vl_huevo_gra   TYPE menge_d,
        vl_huevo_plato TYPE menge_d,
        vl_huevo_hp    TYPE menge_d,
        vl_huevo_dy    TYPE menge_d,
        vl_huevo_fis   TYPE menge_d,
        vl_huevo_comer TYPE menge_d,
        vl_huevo_des   TYPE menge_d.
  DATA:

    vl_costoalim      TYPE menge_d,vl_costoalimst    TYPE menge_d,
    vl_costopollito   TYPE menge_d, vl_costopollitost TYPE menge_d,
    vl_kilosalim      TYPE menge_d,vl_kilosalimst    TYPE menge_d,
    vl_metros2        TYPE menge_d,
    vl_pollosp        TYPE menge_d, vl_pollospst      TYPE menge_d,
    vl_kilosp         TYPE menge_d, vl_kilospst TYPE menge_d,
    vl_pp_ave         TYPE menge_d, vl_pp_avest       TYPE menge_d,
    vl_conversion     TYPE menge_d, vl_conversionst TYPE menge_d,
    vl_edad_dias      TYPE i, vl_edad_diasst    TYPE i,
    vl_total_mort     TYPE menge_d, vl_total_mortst TYPE menge_d,
    vl_ganancia       TYPE menge_d, vl_gananciast     TYPE menge_d.



  FIELD-SYMBOLS: <fs_st>     TYPE any,
                 <fs_mes>    TYPE any,
                 <fs_field>  TYPE any,
                 <fs_st2>    TYPE any,
                 <fs_field2> TYPE any.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Huevo Comercial'.


  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = '% Huevo Comercial'.


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      IF <fs_field> EQ '% Huevo Incubable Granjas'.
        READ TABLE <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_huevo_inc>) INDEX sy-tabix.
        ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_huevo_inc> TO FIELD-SYMBOL(<fs_chuevo_inc>).
        EXIT.
      ENDIF.
    ENDLOOP.


    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.
        WHEN 'HUEVO HP'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_huevo_hp = <fs_mes>.

        WHEN 'HUEVO PLATO (SUCIO, CHICO, DEFORME)'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_huevo_plato = <fs_mes>.

        WHEN 'HUEVO DOBLE YEMA'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_huevo_dy = <fs_mes>.

        WHEN 'HUEVO INCUBABLE'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_huevo_inc = <fs_mes>.

        WHEN 'HUEVO FISURADO'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_huevo_fis = <fs_mes>.

        WHEN 'HUEVO RECIBIDO DE GRANJA'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_huevo_gra = <fs_mes>.

        WHEN 'HUEVO DESECHO (ROTO - CANICA)'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_huevo_des = <fs_mes>.

        WHEN '% Huevo Incubable'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_huevo_inc / vl_huevo_gra * 100.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_huevo_inc / vl_huevo_gra * 100.

        WHEN '% Huevo Incubable Granjas'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = ( vl_huevo_inc + vl_huevo_hp ) / vl_huevo_gra * 100.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = ( vl_huevo_inc + vl_huevo_plato ) / vl_huevo_gra * 100.

        WHEN 'Huevo Comercial'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_huevo_hp + vl_huevo_plato + vl_huevo_dy + vl_huevo_fis .

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_huevo_hp + vl_huevo_plato + vl_huevo_dy + vl_huevo_fis .
          vl_huevo_comer = <fs_mes>.
        WHEN '% Huevo Comercial'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_huevo_comer / vl_huevo_gra * 100.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_huevo_comer / vl_huevo_gra * 100.

          "se calcula aqui el % de huevo incubable

          "ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_huevo_inc> TO FIELD-SYMBOL(<fs_chuevo_inc>).
          <fs_chuevo_inc> = ( vl_huevo_inc + vl_huevo_hp ) / vl_huevo_gra * 100.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_huevo_inc> TO <fs_chuevo_inc>.
          <fs_chuevo_inc> = ( vl_huevo_inc + vl_huevo_hp ) / vl_huevo_gra * 100.
      ENDCASE.

    ENDLOOP.
    CLEAR: vl_huevo_inc,
        vl_huevo_gra,
        vl_huevo_plato,
        vl_huevo_hp,
        vl_huevo_dy,
        vl_huevo_fis,
        vl_huevo_comer,
        vl_huevo_des.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.

FORM set_indicadores_crianza.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_hembras  TYPE menge_d,
        vl_machos   TYPE menge_d.
  DATA:

    vl_costoalim      TYPE menge_d,vl_costoalimst    TYPE menge_d,
    vl_costopollito   TYPE menge_d, vl_costopollitost TYPE menge_d,
    vl_kilosalim      TYPE menge_d,vl_kilosalimst    TYPE menge_d,
    vl_metros2        TYPE menge_d,
    vl_pollosp        TYPE menge_d, vl_pollospst      TYPE menge_d,
    vl_kilosp         TYPE menge_d, vl_kilospst TYPE menge_d,
    vl_pp_ave         TYPE menge_d, vl_pp_avest       TYPE menge_d,
    vl_conversion     TYPE menge_d, vl_conversionst TYPE menge_d,
    vl_edad_dias      TYPE i, vl_edad_diasst    TYPE i,
    vl_total_mort     TYPE menge_d, vl_total_mortst TYPE menge_d,
    vl_ganancia       TYPE menge_d, vl_gananciast     TYPE menge_d.

  DATA vl_index TYPE sy-tabix.
  DATA vl_ok.
  FIELD-SYMBOLS: <fs_st>     TYPE any,
                 <fs_mes>    TYPE any,
                 <fs_field>  TYPE any,
                 <fs_st2>    TYPE any,
                 <fs_field2> TYPE any.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).

  IF c_recria EQ abap_true OR ( c_recria EQ abap_true AND c_cria EQ abap_true ) .
    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = '% Machos sobre Hembras'.


    LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_gallina>).
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_gallina> TO FIELD-SYMBOL(<fs_valor>).
      IF <fs_valor> = 'GALLINA JOVEN' OR <fs_valor> = 'GALLO JOVEN'.
        DELETE <fs_outtable> INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDIF.

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.
    vl_ok = abap_false.
    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      IF <fs_field> EQ 'HEMBRAS FINALES'.
        READ TABLE <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_hembras_i>) INDEX sy-tabix.
        ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_hembras_i> TO FIELD-SYMBOL(<fs_hembras_t>).
      ELSEIF <fs_field> EQ 'MACHOS FINALES'.
        READ TABLE <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_machos_i>) INDEX sy-tabix.
        ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_machos_i> TO FIELD-SYMBOL(<fs_machos_t>).
      ENDIF.
    ENDLOOP.

    IF <fs_hembras_t> IS NOT ASSIGNED.
      LOOP AT <fs_outtable> ASSIGNING <fs_st>.
        ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
        IF <fs_field> EQ 'GALLINA JOVEN'.
          READ TABLE <fs_outtable> ASSIGNING <fs_hembras_i> INDEX sy-tabix.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_hembras_i> TO <fs_hembras_t>.
          vl_ok = abap_true.
          EXIT.
        ENDIF.

      ENDLOOP.
      IF vl_ok EQ abap_false.
        ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_hembras_t>.

      ENDIF.

    ENDIF.


    IF <fs_machos_t> IS NOT ASSIGNED.
      ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_machos_t>.

    ENDIF.


    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.

        WHEN '% Machos sobre Hembras'.
          IF <fs_hembras_t> GT 0.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = <fs_machos_t> / <fs_hembras_t> * 100.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = <fs_mes> = <fs_machos_t> / <fs_hembras_t> * 100.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.


FORM set_indicadores2.

  DATA: rg_fechas         TYPE RANGE OF acdoca-budat,
        vl_mes(5)         TYPE c,vl_messt(5)  TYPE c,
        vl_costoalim      TYPE menge_d, vl_costoalimst TYPE menge_d,
        vl_desembar       TYPE menge_d, vl_desembarst TYPE menge_d,
        vl_costopollito   TYPE menge_d, vl_costopollitost TYPE menge_d,
        vl_kilosalim      TYPE menge_d, vl_kilosalimst TYPE menge_d,
        vl_totalp         TYPE menge_d, vl_totalpst TYPE menge_d,
        vl_metros2        TYPE menge_d,
        vl_porc_falt      TYPE menge_d, vl_porc_faltst TYPE menge_d,
        vl_pollito        TYPE menge_d, vl_pollitost TYPE menge_d,
        vl_porc_granja    TYPE menge_d, vl_porc_granjast TYPE menge_d,
        vl_pollosp        TYPE menge_d, vl_pollospst TYPE menge_d,
        vl_kilosp         TYPE menge_d, vl_kilospst TYPE menge_d,
        vl_pp_ave         TYPE menge_d, vl_pp_avest TYPE menge_d,
        vl_conversion     TYPE menge_d, vl_conversionst TYPE menge_d,
        vl_edad_dias      TYPE i, vl_edad_diasst TYPE i,
        vl_total_mort     TYPE menge_d, vl_total_mortst TYPE menge_d,
        vl_ganancia       TYPE menge_d, vl_gananciast TYPE menge_d,
        l_pollitos        TYPE menge_d,
        vl_pollito_cd     TYPE menge_d,
        vl_granja         TYPE menge_d, vl_granjast TYPE menge_d,
        vl_faltantes      TYPE menge_d, vl_faltantesst TYPE menge_d,
        vl_porc_desem     TYPE menge_d, vl_porc_desemst TYPE menge_d,
        vl_totalcp        TYPE dmbtr, vl_totalcpst TYPE dmbtr.



  FIELD-SYMBOLS: <fs_st>     TYPE any,
                 <fs_mes>    TYPE any,
                 <fs_field>  TYPE any,
                 <fs_st2>    TYPE any,
                 <fs_field2> TYPE any.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).


  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Kgs/mts2'.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Densidad'.



  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.
        WHEN gv_txttotalpollosp.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollosp = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollospst = <fs_mes>.

        WHEN gv_txttotalkilosp.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilosp = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilospst = <fs_mes>.

        WHEN gv_txttotalcostprod.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_totalcp = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_totalcpst = <fs_mes>.


        WHEN 'Mortandad en Granja'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_granja = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_granjast = <fs_mes>.

        WHEN 'Mortandad al Desembarque'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_desembar = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_desembarst = <fs_mes>.

        WHEN 'Pollito recibido incubadora'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollito = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollitost = <fs_mes>.

        WHEN '% Mortandad en desembarque'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_porc_desem = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_porc_desemst = <fs_mes>.

      ENDCASE.
    ENDLOOP.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_total_mort = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_total_mortst = <fs_mes>.

        WHEN 'ALIMENTO'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costoalim = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costoalimst = <fs_mes>.



        WHEN 'Peso Promedio Pollo'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pp_ave = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pp_avest = <fs_mes>.

        WHEN 'POLLITO'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costopollito = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costopollitost = <fs_mes>.

        WHEN 'Edad Prom. Días'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_edad_dias = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_edad_diasst = <fs_mes>.

        WHEN 'Kgs. Alimento Consum.'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilosalim = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilosalimst = <fs_mes>.

        WHEN '% Eficiencia'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_conversion GT 0.
            <fs_mes> =  ( vl_pp_ave / vl_conversion ) * 100.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> =  ( vl_pp_avest / vl_conversionst ) * 100.

          ENDIF.
        WHEN 'Costo Pollito iniciado'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_pollito GT 0.
            <fs_mes> =  vl_costopollito / vl_pollito.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> =  vl_costopollitost / vl_pollitost.

          ENDIF.
        WHEN 'Ganancia Diaria'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_edad_dias GT 0.
            <fs_mes> = vl_pp_ave / vl_edad_dias.
            vl_ganancia = <fs_mes>.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_pp_avest / vl_edad_diasst.
            vl_gananciast = <fs_mes>.

          ENDIF.
        WHEN 'Índice de Productividad'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_conversion GT 0.
            <fs_mes> = ( ( 100  - vl_total_mort ) * vl_ganancia ) / vl_conversion * 100 .

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = ( ( 100  - vl_total_mortst ) * vl_gananciast ) / vl_conversionst * 100 .

          ENDIF.

        WHEN 'Faltantes/sobrantes fin lote'.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_pollito - vl_desembar - vl_granja - vl_pollosp.
          vl_faltantes = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_pollitost - vl_desembarst - vl_granjast - vl_pollospst.
          vl_faltantesst = <fs_mes>.

        WHEN '% Mortandad Faltante/Sobrante'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_pollito GT 0.
            <fs_mes> = vl_faltantes / vl_pollito * 100 .
            vl_porc_falt = <fs_mes>.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_faltantesst / vl_pollitost * 100 .
            vl_porc_faltst = <fs_mes>.


          ENDIF.
        WHEN '% Mortalidad en granja'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_pollito GT 0.
            <fs_mes> = vl_granja / vl_pollito * 100 .
            vl_porc_granja = <fs_mes>.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_granjast / vl_pollitost * 100 .
            vl_porc_granjast = <fs_mes>.

          ENDIF.
        WHEN '% Total Mortandad'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_porc_desem + vl_porc_falt + vl_porc_granja.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_porc_desemst + vl_porc_faltst + vl_porc_granjast.

        WHEN gv_txttotalcostprod.
          READ TABLE <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_uni>) INDEX sy-tabix + 1.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<unitario>).
          IF vl_kilosp GT 0.
            <unitario> = vl_totalcp / vl_kilosp.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_uni> TO <unitario>.
            <unitario> = vl_totalcpst / vl_kilospst.
          ENDIF.


      ENDCASE.

    ENDLOOP.
    CLEAR: vl_costoalim, vl_desembar,
        vl_kilosalim, vl_totalp,
        vl_metros2, vl_pollito,vl_porc_granja,
        vl_pollosp, vl_kilosp, vl_conversion, vl_costopollito,
        vl_pp_ave.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.
""""""""""""""""indicadores""""""""""""""""""""""""""""""""""""""""""""""""""""""

FORM set_indicadores3.

  DATA: rg_fechas         TYPE RANGE OF acdoca-budat,
        vl_mes(5)         TYPE c,vl_messt(5)  TYPE c,
        vl_costoalim      TYPE menge_d, vl_desembar TYPE menge_d,
        vl_costopollito   TYPE menge_d,vl_costopollitost TYPE menge_d,
        vl_kilosalim      TYPE menge_d, vl_kilosalimst TYPE menge_d,
        vl_totalp         TYPE menge_d,
        vl_metros2        TYPE menge_d, vl_porc_falt TYPE menge_d,
        vl_pollito        TYPE menge_d, vl_pollitost TYPE menge_d,
        vl_porc_granja    TYPE menge_d,
        vl_pollosp        TYPE menge_d,
        vl_kilosp         TYPE menge_d,vl_kilospst TYPE menge_d,
        vl_pp_ave         TYPE menge_d, vl_pp_avest TYPE menge_d,
        vl_conversion     TYPE menge_d, vl_conversionst TYPE menge_d,
        vl_edad_dias      TYPE i, vl_edad_diasst TYPE i,
        vl_total_mort     TYPE menge_d, vl_total_mortst TYPE menge_d,
        vl_ganancia       TYPE menge_d, vl_gananciast TYPE menge_d.


  FIELD-SYMBOLS: <fs_st>     TYPE any,
                 <fs_mes>    TYPE any,
                 <fs_field>  TYPE any,
                 <fs_st2>    TYPE any,
                 <fs_field2> TYPE any.
  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.


  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = '% Eficiencia'.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Ganancia Diaria'.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Índice de Productividad'.


  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Costo Pollito iniciado granja'.





  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.

        WHEN gv_txttotalkilosp.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilosp = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kilospst = <fs_mes>.

        WHEN 'Peso Promedio Pollo'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pp_ave = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pp_avest = <fs_mes>.

        WHEN 'Conversión Alimenticia'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_conversion = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_conversionst = <fs_mes>.

        WHEN 'POLLITO'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costopollito = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_costopollitost = <fs_mes>.

        WHEN 'Pollito recibido incubadora'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollito = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_pollitost = <fs_mes>.

        WHEN 'Edad Prom. Días'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_edad_dias = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_edad_diasst = <fs_mes>.


        WHEN '% Total Mortandad'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_total_mort = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_total_mortst = <fs_mes>.

        WHEN '% Eficiencia'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_conversion GT 0.
            <fs_mes> =  vl_pp_ave / vl_conversion * 100.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> =  vl_pp_avest / vl_conversionst * 100.

          ENDIF.
        WHEN 'Costo Pollito iniciado granja'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_pollito GT 0.
            <fs_mes> =  vl_costopollito / vl_pollito.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> =  vl_costopollitost / vl_pollitost.

          ENDIF.
        WHEN 'Ganancia Diaria'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_edad_dias GT 0.
            <fs_mes> = vl_pp_ave / vl_edad_dias.
            vl_ganancia = <fs_mes>.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_pp_avest / vl_edad_diasst.
            vl_gananciast = <fs_mes>.

          ENDIF.
        WHEN 'Índice de Productividad'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_conversion GT 0.
            <fs_mes> = ( ( 100  - vl_total_mort ) * vl_ganancia ) / vl_conversion * 100 .

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = ( ( 100  - vl_total_mortst ) * vl_gananciast ) / vl_conversionst * 100 .

          ENDIF.

        WHEN 'Kgs/mts2'.
          LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_mts>).
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_mts> TO FIELD-SYMBOL(<fs_temp>).
            IF <fs_temp> = 'Metros Cuadrados'.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_mts> TO <fs_mes>.
              vl_metros2 = <fs_mes>.
              CONTINUE.
            ENDIF.
          ENDLOOP.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_metros2 GT 0.
            <fs_mes> = vl_kilosp / vl_metros2.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_kilospst / vl_metros2.
          ENDIF.

        WHEN 'Densidad'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_metros2 GT 0.
            <fs_mes> = vl_pollito / vl_metros2.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_pollitost / vl_metros2.
          ENDIF.
      ENDCASE.

    ENDLOOP.
    CLEAR: vl_costoalim, vl_desembar,
        vl_kilosalim, vl_totalp,
        vl_metros2, vl_pollito,vl_porc_granja,
        vl_pollosp, vl_kilosp, vl_conversion, vl_costopollito,
        vl_pp_ave.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.

ENDFORM.

FORM get_totales.

  DATA: rg_fechas       TYPE RANGE OF acdoca-budat,
        vl_mes(5)       TYPE c,vl_messt(5)  TYPE c,
        vl_acum_mes     TYPE dmbtr, vl_acum_messt TYPE dmbtr,
        vl_flete        TYPE dmbtr, vl_costo_proc TYPE dmbtr,
        vl_fletest      TYPE dmbtr, vl_costo_procst TYPE dmbtr,
        vl_alpesur      TYPE dmbtr, vl_alpesurst TYPE dmbtr,
        vl_ci           TYPE dmbtr, vl_cist TYPE dmbtr,
        vl_grupesa      TYPE dmbtr, vl_grupesast TYPE dmbtr,
        vl_recupera     TYPE dmbtr, vl_recuperast TYPE dmbtr.


  FIELD-SYMBOLS: <fs_tt>    TYPE table,
                 <fs_st>    TYPE any,
                 <fs_mes>   TYPE any,
                 <fs_field> TYPE any,
                 <fs_acum>  TYPE table.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = gv_txttotalcostprod.
  IF gv_tipore EQ 'ENGORDA' OR gv_tipore EQ 'PPA' OR gv_tipore EQ 'DEPOSITOS'.

    IF it_ppa_det IS INITIAL.
      UNASSIGN <fs_st>.
      UNASSIGN <fs_field>.
      APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      <fs_field> = 'Unitario'. "'Unitario por Kilo'.

      UNASSIGN <fs_st>.
      UNASSIGN <fs_field>.
      "APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
      "ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      "<fs_field> = 'Unitario por Pollo'.
    ELSE.
      UNASSIGN <fs_st>.
      UNASSIGN <fs_field>.
      APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      <fs_field> = 'Unitario'.
    ENDIF.
  ELSEIF gv_tipore EQ 'ALIMENTO'.

    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_txtunit.
  ELSEIF gv_tipore EQ 'POSTURA'OR gv_tipore EQ 'CRIANZA'.
    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_txtunit.
  ELSEIF gv_tipore EQ 'INCUBADORA'.
    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_txtunit.

  ENDIF.

  UNASSIGN <fs_st>.
  UNASSIGN <fs_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.

  IF gv_tipore EQ 'ALIMENTO'.
    PERFORM get_alpesur_alim.
  ENDIF.
  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.



    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.
        WHEN 'FLETE DE ABASTO'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_flete = <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_fletest = <fs_mes>.

        WHEN 'COSTO DE PROCESO'.


          LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_alpesur>).
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_alpesur> TO FIELD-SYMBOL(<fs_temp>).
            IF <fs_temp> = 'ALPESUR'.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_alpesur> TO <fs_mes>.
              vl_alpesur = <fs_mes>.

              ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_alpesur> TO <fs_mes>.
              vl_alpesurst = <fs_mes>.

            ENDIF.

            IF <fs_temp> EQ gv_txtcostoindir.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_alpesur> TO <fs_mes>.
              vl_ci = <fs_mes>.

              ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_alpesur> TO <fs_mes>.
              vl_cist = <fs_mes>.

            ENDIF.
          ENDLOOP.



          IF vl_solo_maquila EQ abap_false.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = <fs_mes> - vl_flete.


            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = <fs_mes> - vl_fletest.
          ELSE.

            READ TABLE it_aux_acum INTO DATA(wa_) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_ TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  vl_grupesa = <fs_data> - vl_alpesur.      " / 1000.

                  vl_grupesast = <fs_data> - vl_alpesurst.  " / 1000.
                ENDIF.
              ENDLOOP.
            ENDIF.

            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = ( vl_ci / ( vl_grupesa + vl_alpesur ) ) * vl_alpesur.


            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = ( vl_ci / ( vl_grupesast + vl_alpesurst ) ) * vl_alpesurst.
            "actualiza costo indirecto

            LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_indirecto>).
              ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_indirecto> TO FIELD-SYMBOL(<fs_tempo>).
              IF <fs_tempo> = gv_txtcostoindir.
                ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_indirecto> TO <fs_mes>.
                <fs_mes> = ( vl_ci / ( vl_grupesa + vl_alpesur ) ) * vl_alpesur.

                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_indirecto> TO <fs_mes>.
                <fs_mes> = ( vl_cist / ( vl_grupesast + vl_alpesurst ) ) * vl_alpesurst.
                CONTINUE.
              ENDIF.

            ENDLOOP.

          ENDIF.

        WHEN gv_txtcostodir.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = <fs_mes>.

        WHEN 'RECUPERACIONES (PRODUC SEMITERMINADA)'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = vl_acum_mes + <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = vl_acum_messt + <fs_mes>.

        WHEN 'COSTO WIP'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = vl_acum_mes + <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = vl_acum_messt + <fs_mes>.

        WHEN 'RECUPERACIÓN GALLINAZA'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = vl_acum_mes + <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = vl_acum_messt + <fs_mes>.

        WHEN 'COSTOS APARCERIA'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = vl_acum_mes + <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = vl_acum_messt + <fs_mes>.

        WHEN gv_txtcostoindir.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = vl_acum_mes + <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = vl_acum_messt + <fs_mes>.

        WHEN 'SUBPRODUCTOS'.
*        WHEN gv_txtcostorecup.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = vl_acum_mes + <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = vl_acum_messt + <fs_mes>.
        WHEN gv_txttotalcostprod.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_acum_mes.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_acum_messt.

          READ TABLE <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_tmp>) INDEX sy-tabix + 1.
          IF sy-subrc EQ 0.
            READ TABLE it_aux_acum INTO DATA(wa_acum3) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <fs_mes>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_tmp> TO <fs_mes> .
              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_acum3 TO <fs_acum>.

              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit3>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit3> TO FIELD-SYMBOL(<fs_kilos>).
                IF <fs_kilos> GT 0.
                  <fs_mes> = vl_acum_mes / <fs_kilos>.

                  UNASSIGN <fs_mes>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_tmp> TO <fs_mes> .
                  <fs_mes> =  vl_acum_messt / <fs_kilos>.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

        WHEN 'Unitario por Kilo'.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.

          READ TABLE it_aux_acum INTO DATA(wa_unikg) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_unikg TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unikg>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unikg> TO FIELD-SYMBOL(<fs_unikilos>).
              IF <fs_unikilos> GT 0.
                <fs_mes> = vl_acum_mes / <fs_unikilos>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                <fs_mes> =  vl_acum_messt / <fs_unikilos>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        WHEN 'Por Tonelada'.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.

          READ TABLE it_aux_acum INTO DATA(wa_uniton) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_uniton TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uniton>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uniton> TO FIELD-SYMBOL(<fs_unitons>).
              IF <fs_unitons> GT 0.
                <fs_mes> = vl_acum_mes / <fs_unitons>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                <fs_mes> =  vl_acum_messt / <fs_unitons>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        WHEN 'Unitario por Pollo'.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.

          READ TABLE it_aux_acum INTO DATA(wa_unipza) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_unipza TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unipza>).
              ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_unikg> TO FIELD-SYMBOL(<fs_unipzas>).
              <fs_mes> = vl_acum_mes / <fs_unipzas>.

              UNASSIGN <fs_mes>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
              <fs_mes> =  vl_acum_messt / <fs_unipzas>.
            ENDLOOP.
          ENDIF.

        WHEN gv_txttotalpollosp.

          READ TABLE it_aux_acum INTO DATA(wa_acum) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_acum TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_piezas>).
              <fs_mes> = <fs_piezas>.

              UNASSIGN <fs_mes>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
              <fs_mes> =  <fs_piezas>.
            ENDLOOP.

          ENDIF.
        WHEN gv_txttotalkilosp.

          READ TABLE it_aux_acum INTO wa_acum3 WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_acum3 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING <fs_unit3>.
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit3> TO <fs_kilos>.
              IF <fs_kilos> GT 0.
                <fs_mes> = <fs_kilos>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                <fs_mes> =  <fs_kilos>.
              ENDIF.
            ENDLOOP.
          ENDIF.
        WHEN 'Peso Promedio Pollo'.

          READ TABLE it_aux_acum INTO DATA(wa_prom) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_prom TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_prom>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_prom> TO FIELD-SYMBOL(<fs_datakg>).
              ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_prom> TO FIELD-SYMBOL(<fs_datapza>).
              IF <fs_datapza> GT 0.
                <fs_mes> = <fs_datakg> / <fs_datapza>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                <fs_mes> = <fs_datakg> / <fs_datapza>.
              ENDIF.
            ENDLOOP.
          ENDIF.


      ENDCASE.

    ENDLOOP.
    CLEAR: vl_acum_mes, vl_acum_messt.
  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.





ENDFORM.

FORM get_totalespro.

  DATA: rg_fechas       TYPE RANGE OF acdoca-budat,
        vl_mes(5)       TYPE c,vl_messt(5)  TYPE c,
        vl_acum_mes     TYPE dmbtr, vl_acum_messt TYPE dmbtr,
        vl_mortal_dep   TYPE dmbtr, vl_mortal_depst TYPE dmbtr,
        vl_pollos_pro   TYPE dmbtr, vl_pollos_prost TYPE dmbtr,
        vl_kgs_pro      TYPE dmbtr, vl_kgs_prost TYPE dmbtr,
        vl_decomiso     TYPE dmbtr, vl_decomisost TYPE dmbtr,
        vl_kgsproc      TYPE dmbtr, vl_kgsprocst TYPE dmbtr.

  FIELD-SYMBOLS: <fs_tt>    TYPE table,
                 <fs_st>    TYPE any,
                 <fs_mes>   TYPE any,
                 <fs_field> TYPE any,
                 <fs_acum>  TYPE table.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).

  IF gv_tipore EQ 'ENGORDA'.

    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_txttotalpollosp.

    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_txttotalkilosp .


    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = 'Peso Promedio Pollo'.
  ELSEIF gv_tipore EQ 'ALIMENTO'.

    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = 'Unitario por tonelada'.
  ELSEIF gv_tipore = 'DEPOSITOS'." orngv_tipore = 'PPA'.
    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_txttotalpollosp.

    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = gv_txttotalkilosp .


    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = 'Peso Promedio'.


    PERFORM mortal_deposito.


    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = '% Merma de Proceso y Menudencia'.

    PERFORM kgs_proces_dep.
    PERFORM decomiso_dep_maq.

    UNASSIGN <fs_st>.
    UNASSIGN <fs_field>.
    APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
    <fs_field> = '% Merma de Proceso Menudencia'.

  ELSEIF gv_tipore EQ 'PPA'.
    PERFORM kgs_proces_ppa.
  ENDIF.

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.
        WHEN gv_txtcostodir.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = <fs_mes>.

        WHEN 'Decomiso Kgs.'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_decomiso = <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_decomisost =  <fs_mes>.

        WHEN 'Kilos Procesados'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kgsproc = <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_kgsprocst =  <fs_mes>.

        WHEN 'Mortalidad Kgs.'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_mortal_dep = <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_mortal_depst =  <fs_mes>.
        WHEN 'COSTOS APARCERIA'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = vl_acum_mes + <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = vl_acum_messt + <fs_mes>.

        WHEN gv_txtcostoindir.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = vl_acum_mes + <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = vl_acum_messt + <fs_mes>.

        WHEN gv_txtcostorecup.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_mes = vl_acum_mes - (  <fs_mes> * -1 ).

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_acum_messt = vl_acum_messt - (  <fs_mes> * -1 ).

        WHEN gv_txttotalcostprod.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_acum_mes.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_acum_messt.

        WHEN 'Unitario por Kilo'.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.

          READ TABLE it_aux_acum INTO DATA(wa_unikg) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_unikg TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unikg>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unikg> TO FIELD-SYMBOL(<fs_unikilos>).
              IF <fs_unikilos> GT 0.
                <fs_mes> = vl_acum_mes / <fs_unikilos>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                <fs_mes> =  vl_acum_messt / <fs_unikilos>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        WHEN 'Unitario por tonelada'.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.

          READ TABLE it_aux_acum INTO DATA(wa_uniton) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_uniton TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uniton>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uniton> TO FIELD-SYMBOL(<fs_unitons>).
              IF <fs_unitons> GT 0.
                <fs_mes> = vl_acum_mes / <fs_unitons>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                <fs_mes> =  vl_acum_messt / <fs_unitons>.
              ENDIF.
            ENDLOOP.
          ENDIF.


        WHEN 'Unitario por Pollo'.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.

          READ TABLE it_aux_acum INTO DATA(wa_unipza) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_unipza TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unipza>).
              ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_unikg> TO FIELD-SYMBOL(<fs_unipzas>).
              <fs_mes> = vl_acum_mes / <fs_unipzas>.

              UNASSIGN <fs_mes>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
              <fs_mes> =  vl_acum_messt / <fs_unipzas>.
            ENDLOOP.
          ENDIF.

        WHEN gv_txttotalpollosp.

          READ TABLE it_aux_acum INTO DATA(wa_acum) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_acum TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_piezas>).
              <fs_mes> = <fs_piezas>.
              vl_pollos_pro = <fs_piezas>.

              UNASSIGN <fs_mes>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
              <fs_mes> =  <fs_piezas>.
              vl_pollos_prost = <fs_piezas>.
            ENDLOOP.




          ENDIF.
        WHEN gv_txttotalkilosp.

          READ TABLE it_aux_acum INTO DATA(wa_acum3) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_acum3 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit3>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit3> TO FIELD-SYMBOL(<fs_kilos>).
              IF <fs_kilos> GT 0.
                <fs_mes> = <fs_kilos>.
                vl_kgs_pro = <fs_kilos>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                <fs_mes> =  <fs_kilos>.
                vl_kgs_prost = <fs_kilos>.
              ENDIF.
            ENDLOOP.
          ENDIF.





        WHEN 'Peso Promedio' OR 'Peso Promedio Pollo'.

          READ TABLE it_aux_acum INTO DATA(wa_prom) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <fs_mes>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_prom TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_prom>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_prom> TO FIELD-SYMBOL(<fs_datakg>).
              ASSIGN COMPONENT 'PIEZAS' OF STRUCTURE <fs_prom> TO FIELD-SYMBOL(<fs_datapza>).
              IF <fs_datapza> GT 0.
                <fs_mes> = <fs_datakg> / <fs_datapza>.

                UNASSIGN <fs_mes>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                <fs_mes> = <fs_datakg> / <fs_datapza>.
              ENDIF.
            ENDLOOP.
          ENDIF.
        WHEN '% Merma de Proceso y Menudencia'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_kgs_pro GT 0.
            <fs_mes> = vl_mortal_dep / vl_kgs_pro * 100.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_mortal_depst / vl_kgs_prost * 100.

          ENDIF.

        WHEN '% Merma de Proceso Menudencia'.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          IF vl_kgsproc GT 0.
            <fs_mes> = vl_decomiso / vl_kgsproc * 100.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
            <fs_mes> = vl_decomisost / vl_kgsprocst * 100.

          ENDIF.

      ENDCASE.

    ENDLOOP.
    CLEAR: vl_acum_mes, vl_acum_messt.
  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.





ENDFORM.


FORM mortal_deposito.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF afpo-dwerk,
        wa_rgwerks  LIKE LINE OF vl_rgwerks
        .

  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  IF p_werks IS INITIAL.
    LOOP AT it_aufnr_end INTO DATA(wa_aufnr).
      CLEAR wa_rgwerks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = wa_aufnr-dwerk.
      APPEND wa_rgwerks TO vl_rgwerks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'EQ'.
    wa_rgwerks-low = p_werks-low.
    APPEND wa_rgwerks TO vl_rgwerks.
  ENDIF.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '551'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '552'.
  APPEND wa_rgbwart TO vl_rgbwart.



  obj_engorda->mortal_deposito(
          EXPORTING
          i_werks     = vl_rgwerks
          i_matkl     = 'PT0001'
          i_rgbwart   = vl_rgbwart
CHANGING
  ch_mortandad = it_mortal_dep
).
  IF vl_solo_caliente EQ abap_true.
    REFRESH it_mortal_dep.
  ENDIF.



  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).
    DATA(aux_aufnr) = it_mortal_dep[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_mortandad).
      CLEAR wa_aux_out.
      "LOOP AT it_mortandad INTO DATA(wa_mortandad) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      " ENDLOOP.
    ENDLOOP.
    "
    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_find = abap_false.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF <f_field> EQ 'Mortalidad Kgs.'.
            vl_existe = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = 'Mortalidad Kgs.'.


      ENDIF.
    ENDIF.

    REFRESH it_aux_out.
    "
  ENDLOOP.
ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM kgs_proces_dep.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF afpo-dwerk,
        wa_rgwerks  LIKE LINE OF vl_rgwerks
        .

  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  IF p_werks IS INITIAL.
    LOOP AT it_aufnr_end INTO DATA(wa_aufnr).
      CLEAR wa_rgwerks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = wa_aufnr-dwerk.
      APPEND wa_rgwerks TO vl_rgwerks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'EQ'.
    wa_rgwerks-low = p_werks-low.
    APPEND wa_rgwerks TO vl_rgwerks.
  ENDIF.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '601'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '602'.
  APPEND wa_rgbwart TO vl_rgbwart.



  obj_engorda->kgs_procesa_dep(
    EXPORTING
      i_werks      = vl_rgwerks
      i_matkl      = 'PT0010'
      i_rgbwart    = vl_rgbwart
    CHANGING
      ch_kgsproces = it_mortal_dep
  ).

  IF vl_solo_vivo EQ abap_true.
    REFRESH it_mortal_dep.
  ENDIF.



  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).
    DATA(aux_aufnr) = it_mortal_dep[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_mortandad).
      CLEAR wa_aux_out.
      "LOOP AT it_mortandad INTO DATA(wa_mortandad) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      " ENDLOOP.
    ENDLOOP.
    "
    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_find = abap_false.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF <f_field> EQ 'Kilos Procesados'.
            vl_existe = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = 'Kilos Procesados'.


      ENDIF.
    ENDIF.

    REFRESH it_aux_out.
    "
  ENDLOOP.
ENDFORM.

FORM kgs_proces_ppa.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF afpo-dwerk,
        wa_rgwerks  LIKE LINE OF vl_rgwerks
        .

  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  IF p_werks IS INITIAL.
    LOOP AT it_aufnr_end INTO DATA(wa_aufnr).
      CLEAR wa_rgwerks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = wa_aufnr-dwerk.
      APPEND wa_rgwerks TO vl_rgwerks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'EQ'.
    wa_rgwerks-low = p_werks-low.
    APPEND wa_rgwerks TO vl_rgwerks.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM vl_rgwerks COMPARING low.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '101'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '102'.
  APPEND wa_rgbwart TO vl_rgbwart.



  obj_engorda->kgs_procesa_ppa(
    EXPORTING
      i_werks      = vl_rgwerks
      i_matkl      = 'PT0010'
      i_rgbwart    = vl_rgbwart
      i_aufnr      = it_aufnr_end
    CHANGING
      ch_kgsproces = it_mortal_dep
  ).

  IF vl_solo_vivo EQ abap_true.
    REFRESH it_mortal_dep.
  ENDIF.



  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).
    DATA(aux_aufnr) = it_mortal_dep[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_mortandad).
      CLEAR wa_aux_out.
      "LOOP AT it_mortandad INTO DATA(wa_mortandad) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      " ENDLOOP.
    ENDLOOP.
    "
    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_find = abap_false.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF <f_field> EQ 'Kilos Procesados'.
            vl_existe = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = 'Kilos Procesados'.


      ENDIF.
    ENDIF.

    REFRESH it_aux_out.
    "
  ENDLOOP.
ENDFORM.

"---------------------
FORM set_title_header.
  CLEAR wa_header.
  REFRESH it_header.

  DATA date_ext(10).

  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = sy-datum
    IMPORTING
      date_external            = date_ext
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.

  CASE gv_tipore.
    WHEN 'ENGORDA'.

      wa_header-titulo1 = 'Resultados Costos Producción Engorda'.
      CONCATENATE 'Fecha Elaboración:' date_ext INTO wa_header-titulo2 SEPARATED BY space.
      IF p_werks IS INITIAL AND p_zona IS INITIAL.
        wa_header-titulo3 = 'Reporte Global'.
      ELSEIF p_werks IS NOT INITIAL.
        wa_header-titulo3 = 'Reporte por Centro'.
        SELECT SINGLE concat_with_space( 'Nombre del Centro: ', name1,1 )
         FROM t001w WHERE werks IN @p_werks
          INTO @wa_header-titulo4.

      ELSEIF p_zona IS NOT INITIAL.
        wa_header-titulo3 = 'Reporte por zona'.
        CONCATENATE 'Nombre de la zona: ' p_zona INTO wa_header-titulo4 SEPARATED BY space.

      ENDIF.

    WHEN 'ALIMENTO'.

      wa_header-titulo1 = 'Resultados Costos Producción Alimento'.
      CONCATENATE 'Fecha Elaboración:' date_ext INTO wa_header-titulo2 SEPARATED BY space.
      IF p_werks IS INITIAL.
        wa_header-titulo3 = 'Reporte Global'.
      ELSEIF p_werks IS NOT INITIAL.
        wa_header-titulo3 = 'Reporte por Centro'.
        SELECT SINGLE concat_with_space( 'Nombre del Centro: ', name1,1 )
         FROM t001w WHERE werks IN @p_werks
          INTO @wa_header-titulo4.
      ENDIF.

    WHEN 'PPA'.

      wa_header-titulo1 = 'Resultados Costos Producción PPA'.
      CONCATENATE 'Fecha Elaboración:' date_ext INTO wa_header-titulo2 SEPARATED BY space.
      IF p_clord IS INITIAL.
        wa_header-titulo3 = 'Reporte Global'.
      ELSEIF p_clord IS NOT INITIAL.
        wa_header-titulo3 = 'Reporte por Clase de Orden'.
        SELECT SINGLE concat_with_space( 'Clase de Orden: ', txt ,1 )
         FROM t003p WHERE auart EQ @p_clord AND spras EQ 'S'
          INTO @wa_header-titulo4.
      ENDIF.
    WHEN 'DEPOSITOS'.
      wa_header-titulo1 = 'Resultados Costos Producción Depósitos'.
      CONCATENATE 'Fecha Elaboración:' date_ext INTO wa_header-titulo2 SEPARATED BY space.
      IF p_werks IS INITIAL.
        wa_header-titulo3 = 'Reporte Global'.
      ELSEIF p_werks IS NOT INITIAL.
        wa_header-titulo3 = 'Reporte por Centro'.
        SELECT SINGLE concat_with_space( 'Centro: ', txt ,1 )
         FROM t003p WHERE auart EQ @p_clord AND spras EQ 'S'
          INTO @wa_header-titulo4.
      ENDIF.
    WHEN 'EMPACADORA'.
      wa_header-titulo1 = 'Resultados Costos Producción Empacadora'.
      CONCATENATE 'Fecha Elaboración:' date_ext INTO wa_header-titulo2 SEPARATED BY space.
      wa_header-titulo3 = 'Reporte Global'.
    WHEN 'POSTURA'.
      wa_header-titulo1 = 'Resultados Costos Producción Postura'.
      CONCATENATE 'Fecha Elaboración:' date_ext INTO wa_header-titulo2 SEPARATED BY space.
      wa_header-titulo3 = 'Reporte Global'.
    WHEN 'CRIANZA'.
      wa_header-titulo1 = 'Resultados Costos Producción Crianza'.
      CONCATENATE 'Fecha Elaboración:' date_ext INTO wa_header-titulo2 SEPARATED BY space.
      wa_header-titulo3 = 'Reporte Global'.
    WHEN 'INCUBADORA'.
      wa_header-titulo1 = 'Resultados Costos Producción Incubadora'.
      CONCATENATE 'Fecha Elaboración:' date_ext INTO wa_header-titulo2 SEPARATED BY space.
      wa_header-titulo3 = 'Reporte Global'.
  ENDCASE.

  APPEND wa_header TO it_header.

ENDFORM.


FORM show_results.

  DATA: lv_text    TYPE string.

  <fs_outtable_o> = <fs_outtable>.

  cl_salv_table=>factory( IMPORTING r_salv_table = o_alv
         CHANGING t_Table = <fs_outtable>
                  ).

  PERFORM set_functions_alv.
  PERFORM calculate_columns.
  "PERFORM set_aggregations.
  PERFORM set_colors.
  PERFORM set_title_header.
  PERFORM report_header
                    CHANGING o_alv.

  o_alv->display( ).

ENDFORM.

FORM report_header
                 CHANGING p_o_alv  TYPE REF TO cl_salv_table.

*-- ALV Header declarations

  DATA: lv_lines        TYPE i,
        lv_linesc(10)   TYPE c,
        lv_row          TYPE i,
        lv_column       TYPE i,
        lv_date_from    TYPE char10,
        lv_date_to      TYPE char10,
        lv_text         TYPE char255,
        lo_header       TYPE REF TO  cl_salv_form_element,
        lo_layout_grid  TYPE REF TO cl_salv_form_layout_grid,
        lo_layout_mgrid TYPE REF TO cl_salv_form_layout_grid,
        lo_value        TYPE REF TO cl_salv_form_header_info,
        lv_title        TYPE string.

*-- Creating the layout object

  CREATE OBJECT lo_layout_mgrid.

*-- Setting the Header Text

  lo_layout_mgrid->create_grid( EXPORTING row    = 1
                                column = 1
                                RECEIVING r_value = lo_layout_grid ).

  lv_row = 1.

  READ TABLE it_header INTO wa_header INDEX 1.

  lo_layout_grid->create_label( row     = lv_row
                             column  = 1
                             text    = wa_header-titulo1 ).

  lo_layout_mgrid->create_grid( EXPORTING row     = 2
                                column  = 1
                                RECEIVING r_value = lo_layout_grid ).


  lv_row = lv_row + 1.
  lo_layout_grid->create_label( row     = lv_row
                                column  = 1
                                text    = wa_header-titulo2 ).

  lv_row = lv_row + 1.
  lo_layout_grid->create_label( row     = lv_row
                                column  = 1
                                text    = wa_header-titulo3 ).

  IF wa_header-titulo4 IS NOT INITIAL.
    lv_row = lv_row + 1.
    lo_layout_grid->create_label( row     = lv_row
                                  column  = 1
                                  text    = wa_header-titulo4 ).

  ENDIF.

*  lo_layout_grid->create_text( row      = lv_row
*                               column   = 2
*                               text     = sy-datum ).



*
*
*
*  lv_row = lv_row + 1.
*
*
*  lo_layout_grid->create_label( row     = lv_row
*                                column  = 1
*                                text    = 'Run by' ).
*
*  lo_layout_grid->create_text( row      = lv_row
*
*                              column   = 2
*
*                              text     = sy-uname ).

  lo_header = lo_layout_mgrid.

  p_o_alv->set_top_of_list( lo_header ).
ENDFORM.

FORM set_functions_alv.
  lo_layout = o_alv->get_layout( ).
  gs_layout-ctab_fname = lv_fname.

  o_alv->get_columns( )->set_color_column( lv_fname ).
  o_alv->get_functions( )->set_export_spreadsheet( value = if_salv_c_bool_sap=>true
  ).." set_all( abap_false ). "Set all standard functions of ALV
  o_alv->get_columns( )->set_optimize( abap_true ). "Optimize column length
  o_alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ). "Line and Column Selection
  o_alv->get_display_settings( )->set_striped_pattern( cl_salv_display_settings=>true ). "zebra stripes

* Set up saving of layouts for this report
  o_alv->get_layout( )->set_key( VALUE salv_s_layout_key( report = sy-repid ) ).
  o_alv->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
  o_alv->get_layout( )->set_default( if_salv_c_bool_sap=>true ). "Allow layout preset


*   set Layout save restriction
*   1. Set Layout Key .. Unique key identifies the Differenet ALVs
  ls_key-report = sy-repid.
  lo_layout->set_key( ls_key ).

*   2. Remove Save layout the restriction.
*  lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
*
*   set initial Layout
*  lf_variant = 'DEFAULT'.
*  lo_layout->set_initial_layout( lf_variant ).
**
*
*lo_function = o_alv->get_functions( ).
*lo_function->set_all('X').
*
*
*try.
*  lo_function->add_function(
*    name     = 'MATNR'
*    icon     = CONV string( icon_complete )
*    text     = 'Mat. Producidos'
*    tooltip  = 'Materiales Producidos'
*    position = if_salv_c_function_position=>right_of_salv_functions ).
*  catch cx_salv_existing cx_salv_wrong_call.
*endtry.

  IF gv_tipore = 'PPA'.
    o_alv->set_screen_status(
        pfstatus      =  'ZSTANDARD'
        report        =  sy-repid
        set_functions = o_alv->c_functions_all ).

    lr_events = o_alv->get_event( ).

    CREATE OBJECT gr_events.

*... §6.1 register to the event USER_COMMAND
    SET HANDLER gr_events->on_user_command FOR lr_events.
  ENDIF.
ENDFORM.

FORM handle_user_command USING i_ucomm TYPE salv_de_function.


  DATA: it_aufnr TYPE STANDARD TABLE OF sval,
        wa_aufnr LIKE LINE OF it_aufnr.


  CASE i_ucomm.
    WHEN '&MATNR'.
      IF sy-uname EQ 'IDELACRUZ' OR sy-uname EQ 'JHERNANDEV' OR sy-uname EQ 'FBAYONA'
      OR sy-uname EQ 'JGUTIERREZ' OR sy-uname EQ 'EVELAZQUEZ'.
        wa_aufnr-tabname = 'AFKO'.
        wa_aufnr-fieldname = 'AUFNR'.
        APPEND wa_aufnr TO it_aufnr.

        CALL FUNCTION 'POPUP_GET_VALUES'
          EXPORTING
*           no_value_check  = space
            popup_title = 'Órdenes de Fabricación'
*           start_column    = '5'
*           start_row   = '5'
*          IMPORTING
*           returncode  =
          TABLES
            fields      = it_aufnr
*          EXCEPTIONS
*           error_in_fields = 1
*           others      = 2
          .
        IF sy-subrc EQ 0.
          CLEAR wrg_aufnr.
          REFRESH rg_aufnr_det.
          LOOP AT it_aufnr INTO wa_aufnr WHERE value IS NOT INITIAL.
            wrg_aufnr-option = 'EQ'.
            wrg_aufnr-sign = 'I'.
            wrg_aufnr-low = wa_aufnr-value.
            APPEND wrg_aufnr TO rg_aufnr_det.
          ENDLOOP.
        ENDIF.

      ENDIF.
      PERFORM reproceso_bymatnr.
      IF rg_aufnr_det IS NOT INITIAL.
        DELETE it_aufnr_ppa_det WHERE aufnr NOT IN rg_aufnr_det.
      ENDIF.
      PERFORM recalcular_pantalla_cd.
      PERFORM recalcular_pantalla_ci.
      PERFORM get_totales.
      PERFORM estadistico_ppa_det.
      PERFORM set_unitario_ppa_det.
      REFRESH it_ppa_det.
    WHEN '&GENERAL'.
      REFRESH <fs_outtable>.
      <fs_outtable> = <fs_outtable_o>.
      o_alv->refresh( refresh_mode = if_salv_c_refresh=>full ).
      cl_gui_cfw=>flush( ).
  ENDCASE.
  PERFORM set_colors.
ENDFORM.                    " handle_user_command


FORM reproceso_bymatnr.

  DATA: vl_line_o TYPE i, vl_line_d TYPE i.
  CLEAR: vl_acum_prod, vl_acum_prod_r.

  PERFORM get_ordenes_ppa_detalle.

  IF it_aufnr_ppa_det IS NOT INITIAL.

    obj_engorda->get_acdoca_ppa_det(
      EXPORTING
        i_aufnr   = it_aufnr_ppa_det
      CHANGING
        ch_acdoca = it_ppa_det
    ).

    PERFORM create_alv_option.
    REFRESH <fs_outtable>.
    "se recalculan los datos con las ordenes de los materiales.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    PERFORM ppa_by_matnr_1.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    PERFORM set_colors.
    "-------------------
    o_alv->refresh( refresh_mode = if_salv_c_refresh=>full ).
    cl_gui_cfw=>flush( ).
  ELSE.
    MESSAGE 'No hay órdenes con el criterio establecido' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.

FORM ppa_by_matnr_1.
  DATA: vl_lfmon(2), vl_lfgja(4),
        vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
        vl_menge    TYPE menge_d, vl_dmbtr TYPE p DECIMALS 7.


  REFRESH it_sum_racct.
  REFRESH it_sum_matnr.

  SORT it_ppa_det BY racct matnr.


*  sort it_ppa_det by matnr.

*  data(it_temp) = it_ppa_det[].
*
*  delete it_ppa_det where matnr not in rg_matnr_det .
*  delete it_temp where matnr is not INITIAL.
*
*  append lines of it_temp to it_ppa_det[].


  LOOP AT it_ppa_det ASSIGNING FIELD-SYMBOL(<wa_ppa_det>).

    ASSIGN COMPONENT 'MATNR' OF STRUCTURE <wa_ppa_det> TO <linea>.
    wa_sum_racct-matnr = <linea>.

    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <wa_ppa_det> TO <linea>.
    wa_sum_racct-wgbez60 = <linea>.

    ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <wa_ppa_det> TO <linea>.
    wa_sum_racct-aufnr = <linea>.

    ASSIGN COMPONENT 'RACCT' OF STRUCTURE <wa_ppa_det> TO <linea>.
    wa_sum_racct-racct = <linea>.

    ASSIGN COMPONENT 'R_HSL' OF STRUCTURE <wa_ppa_det> TO <linea>.
    wa_sum_racct-r_hsl = <linea>.

    ASSIGN COMPONENT 'MSL' OF STRUCTURE <wa_ppa_det> TO <linea>.
    wa_sum_racct-msl = <linea>.

    ASSIGN COMPONENT 'HSL' OF STRUCTURE <wa_ppa_det> TO <linea>.
    IF wa_sum_racct-racct EQ '0504025014' OR wa_sum_racct-racct EQ '0504025030'.

      <linea> = <linea> * -1.
      ASSIGN COMPONENT 'MSL' OF STRUCTURE <wa_ppa_det> TO <linea>.
      <linea> = <linea> * -1.
      wa_sum_racct-msl = <linea>.
    ELSE.
      wa_sum_racct-hsl = <linea>.
      wa_sum_racct-o_hsl = <linea>.
    ENDIF.
    vl_acum_prod = vl_acum_prod + wa_sum_racct-hsl.
    COLLECT wa_sum_racct INTO it_sum_racct.




  ENDLOOP.

  DELETE it_sum_racct WHERE racct EQ '0504025192'.
  DELETE it_sum_racct WHERE racct EQ '0504025111'.
  DELETE it_sum_racct WHERE racct EQ '0504025014'.
  DELETE it_sum_racct WHERE racct EQ '0504025030'.
  DELETE it_sum_racct WHERE aufnr NOT IN rg_aufnr_det.


*
*  "POR MATERIAL
  CLEAR vl_acum_prod.
  SORT it_ppa_det BY aufnr matnr racct.


  LOOP AT it_ppa_det ASSIGNING <wa_ppa_det> WHERE aufnr IN rg_aufnr_det AND matnr IN rg_matnr_det.
    ASSIGN COMPONENT 'RACCT' OF STRUCTURE <wa_ppa_det> TO <linea>.
    IF <linea> EQ '0504025014' OR <linea> EQ '0504025192' OR
       <linea> EQ '0504025030' OR <linea> EQ '0504025111'.

      ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <wa_ppa_det> TO <linea>.
      wa_sum_matnr-aufnr = <linea>.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <wa_ppa_det> TO <linea>.
      wa_sum_matnr-matnr = <linea>.
      ASSIGN COMPONENT 'HSL' OF STRUCTURE <wa_ppa_det> TO <linea>.
      wa_sum_matnr-hsl = <linea>.
      vl_acum_prod = vl_acum_prod + <linea>.
      COLLECT wa_sum_matnr INTO it_sum_matnr.
      CLEAR wa_sum_matnr.
    ENDIF.


  ENDLOOP.



  SORT it_sum_matnr BY aufnr.
  SORT it_sum_racct BY aufnr.
  REFRESH it_equivalencias.
  "se obtiene el costo real de los materiales
  LOOP AT it_sum_matnr INTO wa_sum_matnr.
    PERFORM recursive_racct
      TABLES
        it_sum_racct
      USING
        wa_sum_matnr-aufnr
        wa_sum_matnr-matnr
      CHANGING
       it_sum_matnr
      .
  ENDLOOP.

  "se aplican las equivalencias por material



  PERFORM recalcular_racct.

ENDFORM.

FORM recursive_racct TABLES p_sum_racct LIKE it_sum_racct
                     USING p_aufnr TYPE aufnr
                           p_matnr TYPE matnr
                     CHANGING p_it_sum_matnr LIKE it_sum_matnr.
  DATA: vl_acum     TYPE fins_vhcur12,
        vl_hsl      TYPE fins_vhcur12,
        vl_equivale TYPE  p DECIMALS 7.



  LOOP AT p_sum_racct INTO DATA(wa_racct) WHERE aufnr = p_aufnr.
    vl_acum = vl_acum + wa_racct-o_hsl.
  ENDLOOP.

  LOOP AT p_it_sum_matnr ASSIGNING FIELD-SYMBOL(<wa_matnr>) WHERE aufnr = p_aufnr AND matnr = p_matnr.
    ASSIGN COMPONENT 'HSL' OF STRUCTURE <wa_matnr> TO FIELD-SYMBOL(<row>).
    vl_hsl = <row>.

    ASSIGN COMPONENT 'EQUIVALE' OF STRUCTURE <wa_matnr> TO <row>.
    IF vl_acum GT 0.
      vl_equivale = vl_hsl / vl_acum.
    ELSE.
      vl_equivale = 0.
    ENDIF.
    <row> = vl_equivale.

  ENDLOOP.

  CLEAR wa_equivalencias.
  wa_equivalencias-aufnr = p_aufnr.
  wa_equivalencias-equivale = vl_equivale.
  COLLECT wa_equivalencias INTO it_equivalencias.

ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM recalcular_racct.

  DATA: vl_acum     TYPE fins_vhcur12,
        vl_hsl      TYPE fins_vhcur12,
        vl_equivale TYPE  p DECIMALS 7,
        vl_aufnr    TYPE aufnr.

  DATA: vl_lfmon(2), vl_lfgja(4),
        vl_matnr    TYPE matnr,vl_bwkey TYPE bwkey,
        vl_menge    TYPE menge_d, vl_dmbtr TYPE p DECIMALS 7.


  LOOP AT it_sum_racct ASSIGNING FIELD-SYMBOL(<fs_st>).

    ASSIGN COMPONENT 'O_HSL' OF STRUCTURE <fs_st>  TO FIELD-SYMBOL(<row>).
    vl_hsl = <row>.

    ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <fs_st>  TO <row>.
    vl_aufnr = <row>.

    READ TABLE it_equivalencias INTO wa_equivalencias WITH KEY aufnr = vl_aufnr.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_st>  TO <row>.
      <row> = vl_hsl * wa_equivalencias-equivale.
    ENDIF.

    READ TABLE it_aufnr_ppa_det INTO DATA(w_aufnr) WITH KEY aufnr = vl_aufnr.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'GETRI' OF STRUCTURE <fs_st>  TO <row>.
      <row> = w_aufnr-getri.
    ENDIF.

  ENDLOOP.

  "costo real
  SELECT lfmon, lfgja, bwkey, matnr, verpr
      INTO TABLE @DATA(it_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @it_sum_racct
      WHERE lfgja = @it_sum_racct-getri+0(4)
      AND matnr = @it_sum_racct-matnr
      AND bwkey = 'PP01'.

  LOOP AT it_sum_racct ASSIGNING <fs_st>.

    ASSIGN COMPONENT 'GETRI' OF STRUCTURE <fs_st> TO <linea>.

    vl_lfmon = <linea>+4(2).
    vl_lfgja = <linea>+0(4).
    vl_bwkey = 'PP01'.

    UNASSIGN <linea>.
    ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_st> TO <linea>.
    vl_matnr = <linea>.

    UNASSIGN <linea>.
    ASSIGN COMPONENT 'MSL' OF STRUCTURE <fs_st> TO <linea>.
    vl_menge = <linea>.

    ASSIGN COMPONENT 'O_HSL' OF STRUCTURE <fs_st> TO <linea>.
    vl_dmbtr = <linea>.

    ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <fs_st>  TO <row>.
    vl_aufnr = <row>.

    ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_st> TO <linea>.
    IF <linea> LT 0.
      <linea> = <linea> * -1.
    ENDIF.

    READ TABLE it_mbewh INTO DATA(wa_mbewh)
            WITH KEY lfmon = vl_lfmon lfgja = vl_lfgja
                     bwkey = vl_bwkey matnr = vl_matnr.

    IF sy-subrc EQ 0.

      IF vl_menge NE 0.
        IF wa_mbewh-verpr GT 0.
          vl_dmbtr = vl_menge * wa_mbewh-verpr.
        ENDIF.
      ENDIF.

      UNASSIGN <linea>.
      ASSIGN COMPONENT 'R_HSL' OF STRUCTURE <fs_st> TO <linea>.
      <linea> =  vl_dmbtr.

      CLEAR wa_equivalencias.
      READ TABLE it_equivalencias INTO wa_equivalencias WITH KEY aufnr = vl_aufnr.
      IF sy-subrc EQ 0.
        <linea> =  vl_dmbtr * abs( wa_equivalencias-equivale ).
      ENDIF.
    ELSE.
      ASSIGN COMPONENT 'RACCT' OF STRUCTURE <fs_st> TO <linea>.
      IF <linea>+0(3) EQ 'S43'.
        ASSIGN COMPONENT 'HSL' OF STRUCTURE <fs_st> TO <linea>.
        CLEAR: vl_dmbtr.
        vl_dmbtr = <linea>.
        ASSIGN COMPONENT 'R_HSL' OF STRUCTURE <fs_st> TO <linea>.
        <linea> = vl_dmbtr.
      ENDIF.
    ENDIF.

  ENDLOOP.


  UNASSIGN <fs_st>.

ENDFORM.




FORM recalcular_pantalla_cd.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_find.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.


  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_ppa_det[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_sum_racct INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr AND
         ( racct EQ '0504025051' OR racct EQ '0504025052' OR racct EQ '0504025053'
         OR racct EQ '0504025106' ) .
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

*            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
*            IF sy-subrc = 0.
*
*
*              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
*              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
*                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
*                IF <fs_data> GT 0.
*                  <f_field> =  wa_aux-month / <fs_data>.
*                ENDIF.
*                UNASSIGN <f_field>.
*                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
*                IF <fs_data> GT 0.
*                  <f_field> = wa_aux-monthst / <fs_data>.
*                ENDIF.
*              ENDLOOP.
*            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

*            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
*            IF sy-subrc = 0.
*              UNASSIGN <f_field>.
*              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
*
*              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
*              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
*                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
*                IF <fs_data1> GT 0.
*                  <f_field> =  wa_aux-month / <fs_data1>.
*                ENDIF.
*
*                IF <fs_data1> GT 0.
*                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
*                ENDIF.
*                <f_field> = wa_aux-monthst / <fs_data1> .
*              ENDLOOP.
*            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

*          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
*          IF sy-subrc = 0.
*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
*            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.
*
*            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
*              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
*              IF <fs_data2> GT 0.
*                <f_field> =  wa2-month / <fs_data2>.
*              ENDIF..
*              UNASSIGN <f_field>.
*              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
*              IF <fs_data2> GT 0.
*                <f_field> =  wa2-monthst / <fs_data2>.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      DATA vl_existe.
*      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
*        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
*        IF sy-subrc EQ 0.
*
*          IF gv_tipore EQ 'ALIMENTO'.
*            IF <f_field> EQ 'MATERIA PRIMA'.
*              vl_existe = 'X'.
*            ENDIF.
*          ENDIF.
*
*        ENDIF.
*      ENDLOOP.

      IF vl_existe IS INITIAL.

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.

  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostodir.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.
  DATA: vl_mp       TYPE dmbtr, vl_mpst TYPE dmbtr,
        vl_merma    TYPE dmbtr, vl_mermast TYPE dmbtr,
        vl_i_mp     TYPE i, vl_i_maq TYPE i, vl_i_merma TYPE i, vl_i_mermam TYPE i.


  LOOP AT it_totales ASSIGNING <fs_linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
    "se suma aparceria

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " break jhernandev.
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.

      IF <fs_field> EQ gv_txtcostodir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.

        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.
            ENDIF.

            REPLACE 'R' IN <f_field> WITH 'S'.
            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.

ENDFORM.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""COSTOS INDIRECTOS """""""""""""""""""""""""""""""""""
FORM recalcular_pantalla_ci.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_find.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.


  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_ppa_det[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_sum_racct INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr AND
         ( racct EQ 'S43CFB001' OR racct EQ 'S43MOD001' OR racct EQ 'S43TPM001' ).
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-r_hsl.
            wa_aux_out-monthst = wa_mb51-hsl.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


            "unitario
            UNASSIGN <f_field>.
            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
                IF <fs_data1> GT 0.
                  <f_field> =  wa_aux-month / <fs_data1>.
                ENDIF.

                IF <fs_data1> GT 0.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                ENDIF.
                <f_field> = wa_aux-monthst / <fs_data1> .
              ENDLOOP.
            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

          "unitario
          UNASSIGN <f_field>.
          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = gv_txtunit.

          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
          IF sy-subrc = 0.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.

            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
              IF <fs_data2> GT 0.
                <f_field> =  wa2-month / <fs_data2>.
              ENDIF..
              UNASSIGN <f_field>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
              IF <fs_data2> GT 0.
                <f_field> =  wa2-monthst / <fs_data2>.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.

          IF gv_tipore EQ 'ALIMENTO'.
            IF <f_field> EQ 'MATERIA PRIMA'.
              vl_existe = 'X'.
            ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.

  "TOTALES
  UNASSIGN <f_field>.
  UNASSIGN <fs_tt>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtcostoindir.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "TOTAL UNITARIO
  UNASSIGN <f_field>.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
  <f_field> = gv_txtunit.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: vl_acum_mes   TYPE dmbtr, vl_acum_messt TYPE dmbtr.
  DATA vl_acum_menge TYPE menge_d.
  DATA: vl_mp       TYPE dmbtr, vl_mpst TYPE dmbtr,
        vl_merma    TYPE dmbtr, vl_mermast TYPE dmbtr,
        vl_i_mp     TYPE i, vl_i_maq TYPE i, vl_i_merma TYPE i, vl_i_mermam TYPE i.


  LOOP AT it_totales ASSIGNING <fs_linea>.
    CLEAR: vl_acum_menge, vl_acum_mes,vl_acum_messt.

    ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <fs_linea> TO <fs_tt>.
    LOOP AT <fs_tt> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_mes = vl_acum_mes + <fs_field>.
      UNASSIGN <fs_field>.

      ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_acumulado> TO <fs_field>.
      vl_acum_messt = vl_acum_messt + <fs_field>.
      UNASSIGN <fs_field>.
    ENDLOOP.

    UNASSIGN <fs_acumulado>.
    UNASSIGN <fs_field>.
    "se suma aparceria

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " break jhernandev.
    LOOP AT <fs_outtable> ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_acumulado> TO <fs_field>.

      IF <fs_field> EQ gv_txtcostoindir.
        CLEAR vl_sytabix.
        vl_sytabix = sy-tabix + 1.

        REPLACE 'S' IN <f_field> WITH 'R'.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <fs_linea> TO <f_field>.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_mes.

        REPLACE 'R' IN <f_field> WITH 'S'.
        ASSIGN COMPONENT <f_field> OF STRUCTURE <fs_acumulado> TO <fs_field> .
        <fs_field> = vl_acum_messt.

        REPLACE 'S' IN <f_field> WITH 'R'.
        READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea2>.

        READ TABLE it_aux_acum INTO DATA(wa_tot1) WITH KEY columna = <f_field>.
        IF sy-subrc = 0.

          ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_tot1 TO <fs_acum>.
          LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_suma>).
            ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_suma> TO FIELD-SYMBOL(<fs_totales>).

            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_mes / <fs_totales>.
            ENDIF.

            REPLACE 'R' IN <f_field> WITH 'S'.
            ASSIGN COMPONENT <f_field> OF STRUCTURE <linea2> TO <fs_field_a>.
            IF <fs_totales> GT 0.
              <fs_field_a> = vl_acum_messt / <fs_totales>.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.


    ENDLOOP.


  ENDLOOP.

ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""estadistico de kilos en ppa det
FORM estadistico_ppa_det.

  DATA: rg_fechas   TYPE RANGE OF mseg-budat_mkpf,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_find.

  FIELD-SYMBOLS: <fs_acumulado> TYPE any,
                 <fs_linea>     TYPE any,
                 <fs_field>     TYPE any,
                 <fs_field_a>   TYPE any,
                 <fs_acum>      TYPE table.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA acum_mes TYPE zco_st_acumfield.
  FIELD-SYMBOLS <fs_tt> TYPE table.


  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_aufnr_ppa_det[].
    DELETE aux_aufnr WHERE getri NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_auxaufnr).
      CLEAR wa_aux_out.
      LOOP AT it_ppa_det INTO DATA(wa_mb51) WHERE aufnr EQ wa_auxaufnr-aufnr AND
         ( racct EQ '0504025111' OR racct EQ '0504025192') AND matnr IN rg_matnr_det.
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
            wa_aux_out-concepto = wa_mb51-wgbez60.
*            wa_aux_out-menge = wa_mb51-menge.
            wa_aux_out-month = wa_mb51-msl.
            wa_aux_out-monthst = wa_mb51-msl.
            COLLECT wa_aux_out INTO it_aux_out.
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    LOOP AT it_aux_out ASSIGNING <fs_acumulado>.
      ASSIGN COMPONENT 'MONTH' OF STRUCTURE <fs_acumulado> TO <linea>.

      IF <linea> LT 0.
        <linea> = <linea> * -1.
        ASSIGN COMPONENT 'MONTHST' OF STRUCTURE <fs_acumulado> TO <linea>.
        <linea> = <linea> * -1.
      ENDIF.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_sytabix = vl_sytabix + 1.
            READ TABLE <fs_outtable> INDEX vl_sytabix ASSIGNING <linea>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .

            READ TABLE it_aux_acum INTO DATA(wa_kgs) WITH KEY columna = vl_mes.
            IF sy-subrc = 0.


              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_kgs TO <fs_acum>.
              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_wa>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_data>).
                IF <fs_data> GT 0.
                  <f_field> =  wa_aux-month / <fs_data>.
                ENDIF.
                UNASSIGN <f_field>.
                ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
                IF <fs_data> GT 0.
                  <f_field> = wa_aux-monthst / <fs_data>.
                ENDIF.
              ENDLOOP.
            ENDIF.

            vl_find = abap_false.
            vl_sytabix = 0.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.


*            "unitario
*            UNASSIGN <f_field>.
*            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = gv_txtunit.

*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT 'MENGE'  OF STRUCTURE <linea> TO <f_field> .
*            <f_field> = wa_aux-menge.

*            READ TABLE it_aux_acum INTO DATA(wa) WITH KEY columna = vl_mes.
*            IF sy-subrc = 0.
*              UNASSIGN <f_field>.
*              ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
*
*              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa TO <fs_acum>.
*              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_uni>).
*                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_uni> TO FIELD-SYMBOL(<fs_data1>).
*                IF <fs_data1> GT 0.
*                  <f_field> =  wa_aux-month / <fs_data1>.
*                ENDIF.
*
*                IF <fs_data1> GT 0.
*                  ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
*                ENDIF.
*                <f_field> = wa_aux-monthst / <fs_data1> .
*              ENDLOOP.
*            ENDIF.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

*          "unitario
*          UNASSIGN <f_field>.
*          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*          <f_field> = gv_txtunit.
*
*          READ TABLE it_aux_acum INTO DATA(wa1) WITH KEY columna = vl_mes.
*          IF sy-subrc = 0.
*            UNASSIGN <f_field>.
*            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
*            ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa1 TO <fs_acum>.
*
*            LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_unit>).
*              ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_unit> TO FIELD-SYMBOL(<fs_data2>).
*              IF <fs_data2> GT 0.
*                <f_field> =  wa2-month / <fs_data2>.
*              ENDIF..
*              UNASSIGN <f_field>.
*              ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
*              IF <fs_data2> GT 0.
*                <f_field> =  wa2-monthst / <fs_data2>.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.

        ENDLOOP.
      ENDIF.

      "ENDIF.
      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ELSE.
        "SE determinan los meses si no hay costos directos
        CASE wa_fechas-low+4(2).
          WHEN '01'.
            vl_mes = 'C001R'.
            vl_messt = 'C001S'.
          WHEN '02'.
            vl_mes = 'C002R'.
            vl_messt = 'C002S'.
          WHEN '03'.
            vl_mes = 'C003R'.
            vl_messt = 'C003S'.
          WHEN '04'.
            vl_mes = 'C004R'.
            vl_messt = 'C004S'.
          WHEN '05'.
            vl_mes = 'C005R'.
            vl_messt = 'C005S'.
          WHEN '06'.
            vl_mes = 'C006R'.
            vl_messt = 'C006S'.
          WHEN '07'.
            vl_mes = 'C007R'.
            vl_messt = 'C007S'.
          WHEN '08'.
            vl_mes = 'C008R'.
            vl_messt = 'C008S'.
          WHEN '09'.
            vl_mes = 'C009R'.
            vl_messt = 'C009S'.
          WHEN '10'.
            vl_mes = 'C010R'.
            vl_messt = 'C010S'.
          WHEN '11'.
            vl_mes = 'C011R'.
            vl_messt = 'C011S'.
          WHEN '12'.
            vl_mes = 'C012R'.
            vl_messt = 'C012S'.
        ENDCASE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
        <fs_field> = vl_mes.

        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.

        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.
        UNASSIGN <fs_field>.

        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
        <fs_field> = 0.


      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.

      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
      ENDCASE.

*      DATA vl_existe.
*      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
*        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
*        IF sy-subrc EQ 0.
*
*          IF gv_tipore EQ 'ALIMENTO'.
*            IF <f_field> EQ 'MATERIA PRIMA'.
*              vl_existe = 'X'.
*            ENDIF.
*          ENDIF.
*
*        ENDIF.
*      ENDLOOP.

*      IF vl_existe IS INITIAL.
*
*        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
*        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO <fs_field>.
*        <fs_field> = vl_mes.
*
*        UNASSIGN <fs_field>.
*        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.
*        APPEND INITIAL LINE TO <fs_tt> ASSIGNING <fs_field_a>.
*
*        ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
*        <fs_field> = 0.
*        UNASSIGN <fs_field>.
*
*        ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
*        <fs_field> = 0.
*
*
*      ENDIF.
    ENDIF.
    REFRESH it_aux_out.
  ENDLOOP.

ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM set_colors.
*.....Color for COLUMN.....
  DATA: lo_cols_tab TYPE REF TO cl_salv_columns_table,
        lo_col_tab  TYPE REF TO cl_salv_column_table.
  DATA: ls_color TYPE lvc_s_colo.    " Colors strucutre
*
*   get Columns object
  lo_cols_tab = o_alv->get_columns( ).
*
  INCLUDE <color>.
*
  LOOP AT lt_fcat INTO DATA(wa_fcat).
    IF wa_fcat-fieldname+4(1) EQ 'R'.
      TRY.
          lo_col_tab ?= lo_cols_tab->get_column( wa_fcat-fieldname ).
          ls_color-col = col_total.
          lo_col_tab->set_color( ls_color ).
        CATCH cx_salv_not_found.
      ENDTRY.
    ENDIF.

  ENDLOOP.


  DATA: lt_s_color TYPE lvc_t_scol,
        ls_s_color TYPE lvc_s_scol.
*
  FIELD-SYMBOLS <fs_tt> TYPE table.

  LOOP AT <fs_outtable> ASSIGNING <linea>.
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.

    CASE <f_field>.

      WHEN gv_txtcostodir.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        "ls_s_color-fname = 'WGBEZ60' .
        ls_s_color-color-col = 5.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'COSTOS APARCERIA'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        "ls_s_color-fname = 'WGBEZ60' .
        ls_s_color-color-col = 5.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
*
*       Apply GREEN color to the entire row # 5
*         For entire row, we don't pass the Fieldname
      WHEN gv_txtcostoindir.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 5.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.

      WHEN gv_txtcostorecup.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.

        "ls_s_color-fname = 'WGBEZ60' .
        ls_s_color-color-col = 5.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.

      WHEN gv_txttotalcostprod.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.

      WHEN gv_txttotalcostomermas.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.

      WHEN gv_txttotalpollosp.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        IF gv_tipore = 'PPA' OR gv_tipore = 'DEPOSITOS'.
          ls_s_color-color-col = 3.
        ELSE.
          ls_s_color-color-col = alv_style_color_key.
        ENDIF.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.

      WHEN gv_txttotalkilosp.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        IF gv_tipore = 'PPA' OR gv_tipore = 'DEPOSITOS'.
          ls_s_color-color-col = 3.
        ELSE.
          ls_s_color-color-col = alv_style_color_key.
        ENDIF.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN gv_txtunit.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 1.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Unitario por Kilo'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 1.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Unitario por Pollo'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 1.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Peso Promedio Pollo' OR 'Peso Promedio'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3."alv_style_color_key.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.

      WHEN 'Pollito recibido incubadora'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Mortandad en Granja'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Mortandad al Desembarque'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Mortandad en desembarque'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Pollos iniciados en granja'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Faltantes/sobrantes fin lote'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Mortandad Faltante/Sobrante'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Mortalidad en granja'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.

        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Total Mortandad'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Kgs. Alimento Consum.'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = alv_style_color_key.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Metros Cuadrados'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Kgs/mts2'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Densidad'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Costo Tonelada Alimento'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Consumo por Ave'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Conversión Alimenticia'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Eficiencia'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Costo Pollito iniciado granja'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Edad Prom. Días'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Edad Prom. Semanas'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Índice de Productividad'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Ganancia Diaria'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
        CLEAR  ls_s_color.
      WHEN 'Costo Materia Prima Maquila'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Mortalidad Kgs.'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Merma de Proceso y Menudencia'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Merma de Proceso Menudencia'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Costo Proceso Maquila'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Mermas de Maquila'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Grupesa Granel'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'ALPESUR'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Toneladas Producidas'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Kilos Procesados'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Decomiso Kgs.'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Kilos Producidos'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'HUEVO HP'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'HUEVO PLATO (SUCIO, CHICO, DEFORME)'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'HUEVO DOBLE YEMA'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'HUEVO INCUBABLE'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'HUEVO FISURADO'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
*      WHEN 'HUEVO RECIBIDO DE GRANJA'.
*      ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
*        ls_s_color-color-col = 3.
*        APPEND ls_s_color TO <fs_tt>.
*        CLEAR  ls_s_color.
      WHEN '% Huevo Incubable'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Huevo Incubable Granjas'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'Huevo Comercial'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Huevo Comercial'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'HUEVO DESECHO (ROTO - CANICA)'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'HEMBRAS FINALES'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN 'MACHOS FINALES'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
      WHEN '% Machos sobre Hembras'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.

      WHEN 'Huevo Incubable del mes' OR
            'Inv. Inicial(Cuarto frío)' OR
            'Huevo Incub.(Trasp/Incubadoras)' OR
            'Huevo Incub disp.para Carga' OR
            'Huevo cargado en el mes' OR
            'Inv. Final del mes' OR
            'Huevo cargado para nacimiento del mes' OR
            'Decomiso(Infertil, embrión, descartes)' OR
            'Total Pollitos Nacidos' OR
            '% de Nacimiento' OR
            'Pollitos Enviados a Granjas' OR
            'Pollitos de Casa Vendidos' OR
            'Costo  de Huevo' OR
            'Huevo Incubable a comercial' OR
            'Huevo Incubable Decomiso' OR
            'Hvo Incub(Comprado)' OR
            'Hvo Incub(Vendido)' OR
            'Pollitos Comprados'.

        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.

      WHEN 'GALLINA JOVEN' OR 'GALLO JOVEN'.
        ASSIGN COMPONENT lv_fname OF STRUCTURE <linea> TO <fs_tt>.
        ls_s_color-color-col = 3.
        APPEND ls_s_color TO <fs_tt>.
        CLEAR  ls_s_color.
    ENDCASE.
    CLEAR  lt_s_color.
  ENDLOOP.

*   We will set this COLOR table field name of the internal table to
*   COLUMNS tab reference for the specific colors
  TRY.
      lo_cols_tab->set_color_column( lv_fname ).
    CATCH cx_salv_data_error.                           "#EC NO_HANDLER
  ENDTRY.
ENDFORM.

FORM set_unitario_ppa_det.

  DATA: rg_fechas      TYPE RANGE OF acdoca-budat,
        vl_mes(5)      TYPE c,vl_messt(5)  TYPE c,
        vl_kgs_pro     TYPE dmbtr,
        vl_monto_ant   TYPE dmbtr,vl_monto_antst TYPE dmbtr,
        vl_index       TYPE sy-tabix.



  FIELD-SYMBOLS: <fs_tt>     TYPE table,
                 <fs_st>     TYPE any,
                 <fs_mes>    TYPE any,
                 <fs_field>  TYPE any,
                 <fs_stout>  TYPE any,
                 <fs_rowout> TYPE any,
                 <fs_acum>   TYPE table.



  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).


  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.

    UNASSIGN <fs_st>.
    LOOP AT <fs_outtable> ASSIGNING <fs_st>. ".WITH KEY wgbez60 = 'Kilos Producidos'.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      IF <fs_field> EQ 'Kilos Producidos' OR <fs_field> EQ 'Kilos Procesados'.
        ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_field>.
        vl_kgs_pro = <fs_field>.


      ENDIF.
    ENDLOOP.




    LOOP AT <fs_outtable> ASSIGNING <fs_st> .
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      IF <fs_field> IS NOT INITIAL.
        vl_index = sy-tabix.
        CASE <fs_field>.
          WHEN 'Unitario'.

            IF vl_kgs_pro GT 0.
              READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout> .
              <fs_rowout> = vl_monto_ant / vl_kgs_pro.

              UNASSIGN <fs_rowout>.
              ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout> .
              <fs_rowout> = vl_monto_antst / vl_kgs_pro.
*
*
            ENDIF.

          WHEN OTHERS.
            READ TABLE <fs_outtable> ASSIGNING <fs_stout> INDEX vl_index.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            vl_monto_ant = <fs_rowout>.

            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_stout> TO <fs_rowout>. "unitario
            vl_monto_antst = <fs_rowout>.

        ENDCASE.
      ENDIF.



    ENDLOOP.

  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.
ENDFORM.



FORM build_fieldcatalog.
  DATA: campocu       TYPE string,
        ncolumnas     TYPE i,
        nmeses        TYPE i,
        vl_date       TYPE dats,
        vl_name_month TYPE zfcltx,
        vl_poper      TYPE poper.

  ncolumnas = 0.
  nmeses = 0.


  SORT so_poper BY low.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'WGBEZ60'.
  ls_fcat-outputlen = '60'.
  ls_fcat-coltext   = 'CONCEPTO'.
  ls_fcat-fix_column = 'X'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.


  IF so_poper-high IS INITIAL.
    LOOP AT so_poper.
      ncolumnas = ncolumnas + 1.
      CONCATENATE 'C' so_poper-low 'S' INTO ls_fcat-fieldname.
      ls_fcat-col_pos   = ncolumnas.
      "ls_fcat-fieldname = so_poper-low.
      "ls_fcat-datatype  = 'CURR'.
      ls_fcat-ref_table = 'MSEG'.
      ls_fcat-ref_field = 'MENGE'.
      ls_fcat-decimals = '3'.
      ls_fcat-outputlen = '22'.
      ls_fcat-do_sum    = 'X'.
      APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

      CONCATENATE 'C' so_poper-low 'R' INTO ls_fcat-fieldname.
      ls_fcat-col_pos   = ncolumnas.
      "ls_fcat-fieldname = so_poper-low.
      "ls_fcat-datatype  = 'CURR'.
      ls_fcat-ref_table = 'MSEG'.
      ls_fcat-ref_field = 'MENGE'.
      ls_fcat-decimals = '3'.
      ls_fcat-outputlen = '22'.
      ls_fcat-do_sum    = 'X'.
      APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

    ENDLOOP.
  ELSE.
    nmeses = so_poper-high - so_poper-low + 1.
    vl_poper = so_poper-low.
    DO nmeses TIMES.

      ncolumnas = ncolumnas + 1.
      CONCATENATE 'C' vl_poper 'S' INTO ls_fcat-fieldname.
      ls_fcat-col_pos   = ncolumnas.
      "ls_fcat-fieldname = so_poper-low.
      "ls_fcat-datatype  = 'CURR'.
      ls_fcat-ref_table = 'MSEG'.
      ls_fcat-ref_field = 'MENGE'.
      ls_fcat-decimals = '3'.
      ls_fcat-outputlen = '22'.
      ls_fcat-do_sum    = 'X'.
      APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

      ncolumnas = ncolumnas + 1.
      CONCATENATE 'C' vl_poper 'R' INTO ls_fcat-fieldname.
      ls_fcat-col_pos   = ncolumnas.
      "ls_fcat-fieldname = so_poper-low.
      "ls_fcat-datatype  = 'CURR'.
      ls_fcat-ref_table = 'MSEG'.
      ls_fcat-ref_field = 'MENGE'.
      ls_fcat-decimals = '3'.
      ls_fcat-outputlen = '22'.
      ls_fcat-do_sum    = 'X'.
      APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

      vl_poper = vl_poper + 1.

    ENDDO.

  ENDIF.

  IF gv_tipore = 'ALIMENTO' OR gv_tipore = 'CRIANZA' .
    ncolumnas = ncolumnas + 1.
    ls_fcat-col_pos   = ncolumnas.
    ls_fcat-fieldname = 'TOTALS'.
    ls_fcat-coltext   = 'TOTAL'.
    "ls_fcat-datatype  = 'CURR'.
    ls_fcat-ref_table = 'MSEG'.
    ls_fcat-ref_field = 'MENGE'.
    ls_fcat-decimals = '3'.
    ls_fcat-outputlen = '22'.
    APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

    ncolumnas = ncolumnas + 1.
    ls_fcat-col_pos   = ncolumnas.
    ls_fcat-fieldname = 'TOTALR'.
    ls_fcat-coltext   = 'TOTAL'.
    "ls_fcat-datatype  = 'CURR'.
    ls_fcat-ref_table = 'MSEG'.
    ls_fcat-ref_field = 'MENGE'.
    ls_fcat-decimals = '3'.
    ls_fcat-outputlen = '22'.
    APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.
  ENDIF.

  ncolumnas = ncolumnas + 1.
  ls_fcat-col_pos   = ncolumnas.
  ls_fcat-fieldname = 'TABCOLOR'.
  ls_fcat-ref_field = 'COLTAB'.
  ls_fcat-ref_table = 'CALENDAR_TYPE'.
  APPEND ls_fcat TO lt_fcat. CLEAR  ls_fcat.

ENDFORM.

FORM calculate_columns.

  DATA: campocu        TYPE string,
        vl_date        TYPE dats,
        vl_name_month  TYPE fcltx,
        vl_zname_month TYPE zfcltx.

  DATA: vl_scrtext_s TYPE SCRTEXT_s,
        vl_scrtext_m TYPE SCRTEXT_m,
        vl_scrtext_l TYPE scrtext_l,
        columnname   TYPE lvc_fname.

  lr_columns = o_alv->get_columns( ).
  lr_columns->set_optimize( abap_true ).

  DATA column TYPE REF TO cl_salv_column.

  column = lr_columns->get_column( columnname = 'WGBEZ60' ).
  column->set_short_text('CONCEPTO' ).
  column->set_medium_text('CONCEPTO' ).
  column->set_long_text('CONCEPTO' ).

  IF gv_tipore = 'ALIMENTO' OR gv_tipore = 'CRIANZA'.
    column = lr_columns->get_column( columnname = 'TOTALS' ).
    column->set_short_text('TOTAL STD.' ).
    column->set_medium_text('TOTAL STD.' ).
    column->set_long_text('TOTAL STD.' ).

    column = lr_columns->get_column( columnname = 'TOTALR' ).
    column->set_short_text('TOTAL REAL' ).
    column->set_medium_text('TOTAL REAL' ).
    column->set_long_text('TOTAL REAL' ).
  ENDIF.

  LOOP AT lt_fcat INTO DATA(wa_fcat) WHERE fieldname NE 'WGBEZ60' AND fieldname NE 'TOTALS' AND fieldname NE 'TOTALR' AND fieldname NE lv_fname.

    CONCATENATE sy-datum+0(4) wa_fcat-fieldname+2(2) '01' INTO campocu.
    vl_date = campocu.
    CALL FUNCTION '/SAPCE/IURU_GET_MONTH_NAME'
      EXPORTING
        iv_date       = vl_date
      IMPORTING
        ev_month_name = vl_name_month.

    vl_zname_month = vl_name_month.
    TRANSLATE vl_zname_month TO UPPER CASE.
    IF wa_fcat-fieldname+4(1) EQ 'R'.
      CONCATENATE vl_zname_month 'REAL' INTO vl_zname_month SEPARATED BY space.
      TRANSLATE vl_zname_month TO UPPER CASE.
      vl_scrtext_m = vl_zname_month.
      vl_scrtext_l = vl_zname_month.
      CONCATENATE vl_zname_month+0(3) 'REAL' INTO vl_zname_month SEPARATED BY space.
      vl_scrtext_s = vl_zname_month.

    ELSE.
      CONCATENATE vl_zname_month 'STD.' INTO vl_zname_month SEPARATED BY space.
      TRANSLATE vl_zname_month TO UPPER CASE.

      vl_scrtext_m = vl_zname_month.
      vl_scrtext_l = vl_zname_month.
      CONCATENATE vl_zname_month+0(3) 'STD.' INTO vl_zname_month SEPARATED BY space.
      vl_scrtext_s = vl_zname_month.
    ENDIF.

    column = lr_columns->get_column( columnname = wa_fcat-fieldname ).
    column->set_short_text( vl_scrtext_s ).
    column->set_medium_text( vl_scrtext_m ).
    column->set_long_text( vl_scrtext_l ).
    columnname = wa_fcat-fieldname.
  ENDLOOP.

ENDFORM.

FORM set_aggregations.
  CALL METHOD o_alv->get_aggregations
    RECEIVING
      value = lo_aggregations.

  LOOP AT lt_fcat INTO DATA(wa_fcat) WHERE fieldname NE 'WGBEZ60'.

    TRY.
        CALL METHOD lo_aggregations->add_aggregation
          EXPORTING
            columnname  = wa_fcat-fieldname
            aggregation = if_salv_c_aggregation=>total.
      CATCH cx_salv_data_error .
      CATCH cx_salv_not_found .
      CATCH cx_salv_existing .
    ENDTRY.

  ENDLOOP.

ENDFORM.

FORM build_dinamic_table.
*  "se construyen las columnas de acuerdo a los lotes
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      " i_style_table   = 'X'
      it_fieldcatalog = lt_fcat
    IMPORTING
      ep_table        = lo_tabla
      "e_style_fname   = lv_fname.
    .
*
  ASSIGN lo_tabla->* TO <fs_outtable>.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      " i_style_table   = 'X'
      it_fieldcatalog = lt_fcat
    IMPORTING
      ep_table        = lo_tabla_o
      "e_style_fname   = lv_fname.
    .

  ASSIGN lo_tabla_o->* TO <fs_outtable_o>.
  lv_fname = 'TABCOLOR'.
*  CREATE DATA lo_linea LIKE LINE OF <fs_outtable>.
*  ASSIGN lo_linea_out->* TO <linea>.
**
ENDFORM.

FORM set_indica_alim.

  DATA: rg_fechas    TYPE RANGE OF acdoca-budat,
        vl_mes(5)    TYPE c,vl_messt(5)  TYPE c,
        vl_grupesa   TYPE menge_d,
        vl_grupesast TYPE menge_d,
        vl_alpesur   TYPE menge_d,
        vl_alpesurst TYPE menge_d,
        vl_maquila   TYPE menge_d,
        vl_maquilast TYPE menge_d,
        vl_ci        TYPE menge_d,
        vl_cist      TYPE menge_d,
        vl_tonpro    TYPE menge_d,
        vl_tonprost  TYPE menge_d.


  FIELD-SYMBOLS: <fs_st>     TYPE any,
                 <fs_mes>    TYPE any,
                 <fs_field>  TYPE any,
                 <fs_st2>    TYPE any,
                 <fs_field2> TYPE any,
                 <fs_acum>   TYPE table.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  obj_engorda->calculate_dates(
  CHANGING
    p_rgfechas = rg_fechas
).



  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Grupesa Granel'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <fs_st>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
  <fs_field> = 'Toneladas Producidas'.

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.

      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.

      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.

      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.

      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.

      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.

      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.

      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.

      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.

      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.

      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.

    ENDCASE.

    LOOP AT <fs_outtable> ASSIGNING <fs_st>.

      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_st> TO <fs_field>.
      CASE <fs_field>.
        WHEN 'ALPESUR'.

          "IF vl_solo_granel EQ abap_false.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_alpesur = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_alpesurst = <fs_mes>.
*          ELSE.
*            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
*            vl_alpesur = 0.
*
*            ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
*            vl_alpesurst = 0.
*          ENDIF.

        WHEN gv_txtcostoindir.

          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_ci = <fs_mes>.

          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes>.
          vl_cist = <fs_mes>.

        WHEN 'Grupesa Granel'.

          IF vl_solo_maquila EQ abap_false.

            ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
            READ TABLE it_aux_acum INTO DATA(wa_prom) WITH KEY columna = vl_mes.

            IF sy-subrc = 0.
              UNASSIGN <fs_mes>.
              ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes> .
              ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE wa_prom TO <fs_acum>.

              LOOP AT <fs_acum>  ASSIGNING FIELD-SYMBOL(<fs_prom>).
                ASSIGN COMPONENT '/CWM/MENGE' OF STRUCTURE <fs_prom> TO FIELD-SYMBOL(<fs_datakg>).

                IF <fs_datakg> GT 0.
                  <fs_mes> = <fs_datakg> - vl_alpesur.      " / 1000.
                  vl_grupesa = <fs_mes>.

                  UNASSIGN <fs_mes>.
                  ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
                  <fs_mes> = <fs_datakg> - vl_alpesurst.    " / 1000.
                  vl_grupesast = <fs_mes>.

                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

        WHEN 'Toneladas Producidas'.

          IF vl_solo_granel EQ abap_true.
            vl_alpesur = 0.
            vl_alpesurst = vl_alpesur.

            LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_alpesur>).
              ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <fs_alpesur> TO FIELD-SYMBOL(<fs_tempo>).
              IF <fs_tempo> = 'ALPESUR'.
                ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_alpesur> TO <fs_mes>.
                <fs_mes> = vl_alpesur.

                ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_alpesur> TO <fs_mes>.
                <fs_mes> = vl_alpesurst.
                CONTINUE.
              ENDIF.

            ENDLOOP.
          ENDIF.


          ASSIGN COMPONENT vl_mes OF STRUCTURE <fs_st> TO <fs_mes>.
          <fs_mes> = vl_grupesa + vl_alpesur.
          vl_tonpro = <fs_mes>.

          UNASSIGN <fs_mes>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <fs_st> TO <fs_mes> .
          <fs_mes> = vl_grupesast + vl_alpesurst.
          vl_tonprost = <fs_mes>.



      ENDCASE.

    ENDLOOP.
    CLEAR: vl_grupesa, vl_alpesur.
  ENDLOOP.


  UNASSIGN <fs_field>.
  UNASSIGN <fs_mes>.


ENDFORM.


"""Alimento Alpesur
FORM get_alpesur_alim.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c.
  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.

  DATA: vl_rgpoper TYPE RANGE OF t009b-poper,
        wa_rgpoper LIKE LINE OF vl_rgpoper.

  DATA: rg_werks   TYPE RANGE OF afpo-dwerk,
        wa_rgwerks LIKE LINE OF rg_werks.

  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.

  IF p_werks-high IS INITIAL.

    LOOP AT p_werks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = p_werks-low.
      APPEND wa_rgwerks TO rg_werks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'BT'.
    wa_rgwerks-low = p_werks-low.
    wa_rgwerks-high = p_werks-high.
    APPEND wa_rgwerks TO rg_werks.
  ENDIF.



  SORT so_poper BY low.
  IF so_poper-high IS INITIAL.

    LOOP AT so_poper.
      wa_rgpoper-sign = 'I'.
      wa_rgpoper-option = 'EQ'.
      wa_rgpoper-low = so_poper-low.
      APPEND wa_rgpoper TO vl_rgpoper.
    ENDLOOP.
  ELSE.
    wa_rgpoper-sign = 'I'.
    wa_rgpoper-option = 'BT'.
    wa_rgpoper-low = so_poper-low.
    wa_rgpoper-high = so_poper-high.
    APPEND wa_rgpoper TO vl_rgpoper.
  ENDIF.


  obj_engorda->get_alpesur(
    EXPORTING
       p_gjahr = p_gjahr
       p_popers = vl_rgpoper
       p_werks = rg_werks
    CHANGING
      ch_alpesur = it_alpesur
  ).

  SORT it_alpesur BY aufnr budat_mkpf.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    DATA(aux_aufnr) = it_alpesur[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_recupera).
      CLEAR wa_aux_out.
      "LOOP AT it_recupera INTO DATA(wa_recupera) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_recupera-wgbez60.
          wa_aux_out-month = wa_recupera-menge.
          wa_aux_out-monthst = wa_recupera-menge.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      "ENDLOOP.
    ENDLOOP.

    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month / 1000.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst / 1000.

            vl_find = abap_false.
            vl_sytabix = 0.



          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month / 1000.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst / 1000.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month / 1000.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst / 1000.

        ENDLOOP.
      ENDIF.

      """""""""""se guardan los acumulados""""""""""""""""""""""""""""""
      IF it_aux_out IS NOT INITIAL.
        APPEND INITIAL LINE TO it_totales ASSIGNING <linea>.
        ASSIGN COMPONENT 'COLUMNA' OF STRUCTURE <linea> TO FIELD-SYMBOL(<fs_field>).
        <fs_field> = vl_mes.
        UNASSIGN <fs_field>.
        ASSIGN COMPONENT 'ACUMULADO' OF STRUCTURE <linea> TO <fs_tt>.

        LOOP AT it_aux_out INTO DATA(it_wa).
          APPEND INITIAL LINE TO <fs_tt> ASSIGNING FIELD-SYMBOL(<fs_field_a>).

          ASSIGN COMPONENT 'ZMONTH' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-month.
          UNASSIGN <fs_field>.

          ASSIGN COMPONENT 'ZMONTHST' OF STRUCTURE <fs_field_a> TO <fs_field>.
          <fs_field> = it_wa-monthst.
          UNASSIGN <fs_field>.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF <f_field> EQ 'ALPESUR'.
            vl_existe = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = 'ALPESUR'.

*        "unitario
*        UNASSIGN <f_field>.
*        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
*        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
*        <f_field> = gv_txtunit.
      ENDIF.
    ENDIF.

    REFRESH it_aux_out.
  ENDLOOP.



ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM create_screen_ensaca.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = 'MATERIA PRIMA'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtunit.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = 'MERMAS'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtunit.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtcostodir.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtunit.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = 'COSTO DE PROCESO'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtunit.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtcostoindir.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtunit.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = 'RECUPERACIONES'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtunit.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtcostorecup.
  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtunit.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txttotalcostprod.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = gv_txtunit.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = 'ALPESUR'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = 'Grupesa Granel'.

  APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
  ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
  <f_field> = 'Toneladas Producidas'.


ENDFORM.

FORM calc_column_total_al.
  DATA: vl_acumulados  TYPE dmbtr,
        vl_acumulador  TYPE dmbtr,
        vl_ton_pro_con TYPE dmbtr,
        vl_ton_pro_al  TYPE dmbtr,
        vl_ton_pro_gra TYPE dmbtr,
        vl_cell_costo  TYPE dmbtr,
        vl_acum_gral   TYPE dmbtr.



  DATA: vl_mes(5)   TYPE c, vl_messt(5)  TYPE c.
  DATA: rg_fechas      TYPE RANGE OF acdoca-budat,
        vl_tabix       TYPE sy-tabix,
        vl_columna(40) TYPE c.

  TYPES:BEGIN OF st_ton_pro,
          mes(5)  TYPE c,
          ton_pro TYPE dmbtr,
        END OF st_ton_pro.

  DATA: it_ton_pro TYPE STANDARD TABLE OF st_ton_pro,
        wa_ton_pro LIKE LINE OF it_ton_pro.

  FIELD-SYMBOLS: <fs_stunit> TYPE any, <fs_unit> TYPE any.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.
      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.
      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.
      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.
      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.
      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.
      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.
      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.
      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.
      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.
      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.
    ENDCASE.



    LOOP AT <fs_outtable> ASSIGNING <linea>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.

      IF vl_global EQ abap_true.
        IF <f_field> EQ 'Toneladas Producidas'.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field>.
          wa_ton_pro-mes = vl_messt.
          wa_ton_pro-ton_pro = <f_field>.
          APPEND wa_ton_pro TO it_ton_pro.
        ENDIF.
      ENDIF.


      IF vl_solo_maquila EQ abap_true.
        IF <f_field> EQ 'ALPESUR'.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field>.
          wa_ton_pro-mes = vl_messt.
          wa_ton_pro-ton_pro = <f_field>.
          APPEND wa_ton_pro TO it_ton_pro.
        ENDIF.
      ENDIF.


      IF vl_solo_granel EQ abap_true.
        IF <f_field> EQ 'Grupesa Granel'.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field>.
          wa_ton_pro-mes = vl_messt.
          wa_ton_pro-ton_pro = <f_field>.
          APPEND wa_ton_pro TO it_ton_pro.
        ENDIF.
      ENDIF.



    ENDLOOP.

  ENDLOOP.

  LOOP AT it_ton_pro INTO wa_ton_pro.
    vl_acum_gral = vl_acum_gral + wa_ton_pro-ton_pro.
  ENDLOOP.


  LOOP AT <fs_outtable> ASSIGNING <linea>.
    CLEAR: vl_acumulados, vl_acumulador .
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
    vl_columna = <f_field>.
    IF vl_columna EQ gv_txtunit.
      vl_tabix = sy-tabix.
    ENDIF.

    LOOP AT lt_fcat INTO ls_fcat WHERE fieldname NE 'WGBEZ60' AND fieldname NE 'TOTAL' AND fieldname NE lv_fname.
      ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <linea> TO <f_field>.
      IF sy-subrc EQ 0.

        ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <fs_unit>.
        IF <fs_unit> NE gv_txtunit.
          FIND ALL OCCURRENCES OF 'S' IN ls_fcat-fieldname MATCH COUNT sy-subrc.
          IF sy-subrc EQ 0.

            vl_acumulados = vl_acumulados + <f_field>.
          ELSE.
            REPLACE 'S' WITH 'R' INTO ls_fcat-fieldname.

            ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <linea> TO <f_field>.
            vl_acumulador = vl_acumulador + <f_field>.
          ENDIF.

          REPLACE 'R' WITH 'S' INTO ls_fcat-fieldname.


        ENDIF.

        READ TABLE it_ton_pro INTO wa_ton_pro WITH KEY mes = ls_fcat-fieldname.
        IF sy-subrc EQ 0.

          READ TABLE <fs_outtable> ASSIGNING <fs_stunit> INDEX vl_tabix - 1.
          ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_stunit> TO <fs_unit>.
          IF vl_columna EQ gv_txtunit.
            vl_cell_costo = <fs_unit>.
            ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <linea> TO <fs_unit>.
            IF wa_ton_pro-ton_pro GT 0.
              <fs_unit> = vl_cell_costo / wa_ton_pro-ton_pro.
            ELSE.
              <fs_unit> = 0.
            ENDIF.
          ENDIF.
        ELSE.
          REPLACE 'S' WITH 'R' INTO ls_fcat-fieldname.
          READ TABLE it_ton_pro INTO wa_ton_pro WITH KEY mes = ls_fcat-fieldname.
          READ TABLE <fs_outtable> ASSIGNING <fs_stunit> INDEX vl_tabix - 1.
          ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_stunit> TO <fs_unit>.
          IF vl_columna EQ gv_txtunit.
            vl_cell_costo = <fs_unit>.
            ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <linea> TO <fs_unit>.
            IF wa_ton_pro-ton_pro GT 0.
              <fs_unit> = vl_cell_costo / wa_ton_pro-ton_pro.
            ELSE.
              <fs_unit> = 0.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF vl_columna EQ gv_txtunit.
      ASSIGN COMPONENT 'TOTALS' OF STRUCTURE <fs_stunit> TO <fs_unit>.
      ASSIGN COMPONENT 'TOTALS' OF STRUCTURE <linea> TO <f_field>.
      IF vl_acum_gral GT 0.
        <f_field> = <fs_unit> / vl_acum_gral.
      ENDIF.
      ASSIGN COMPONENT 'TOTALR' OF STRUCTURE <fs_stunit> TO <fs_unit>.
      ASSIGN COMPONENT 'TOTALR' OF STRUCTURE <linea> TO <f_field>.
      IF vl_acum_gral GT 0.
        <f_field> = <fs_unit> / vl_acum_gral.
      ENDIF.
    ELSE.
      ASSIGN COMPONENT 'TOTALS' OF STRUCTURE <linea> TO <f_field>.
      <f_field> = vl_acumulados.

      ASSIGN COMPONENT 'TOTALR' OF STRUCTURE <linea> TO <f_field>.
      <f_field> = vl_acumulador.
    ENDIF.

  ENDLOOP.


ENDFORM.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

FORM calc_column_total_cr.
  DATA: vl_acumulados  TYPE dmbtr,
        vl_acumulador  TYPE dmbtr,
        vl_ton_pro_con TYPE dmbtr,
        vl_ton_pro_al  TYPE dmbtr,
        vl_ton_pro_gra TYPE dmbtr,
        vl_cell_costo  TYPE dmbtr,
        vl_acum_gral   TYPE dmbtr.



  DATA: vl_mes(5)   TYPE c, vl_messt(5)  TYPE c.
  DATA: rg_fechas      TYPE RANGE OF acdoca-budat,
        vl_tabix       TYPE sy-tabix,
        vl_columna(40) TYPE c.

  TYPES:BEGIN OF st_ton_pro,
          mes(5)  TYPE c,
          ton_pro TYPE dmbtr,
        END OF st_ton_pro.

  DATA: it_ton_pro TYPE STANDARD TABLE OF st_ton_pro,
        wa_ton_pro LIKE LINE OF it_ton_pro.

  FIELD-SYMBOLS: <fs_stunit> TYPE any, <fs_unit> TYPE any.

  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).

    CASE wa_fechas-low+4(2).
      WHEN '01'.
        vl_mes = 'C001R'.
        vl_messt = 'C001S'.

      WHEN '02'.
        vl_mes = 'C002R'.
        vl_messt = 'C002S'.
      WHEN '03'.
        vl_mes = 'C003R'.
        vl_messt = 'C003S'.
      WHEN '04'.
        vl_mes = 'C004R'.
        vl_messt = 'C004S'.
      WHEN '05'.
        vl_mes = 'C005R'.
        vl_messt = 'C005S'.
      WHEN '06'.
        vl_mes = 'C006R'.
        vl_messt = 'C006S'.
      WHEN '07'.
        vl_mes = 'C007R'.
        vl_messt = 'C007S'.
      WHEN '08'.
        vl_mes = 'C008R'.
        vl_messt = 'C008S'.
      WHEN '09'.
        vl_mes = 'C009R'.
        vl_messt = 'C009S'.
      WHEN '10'.
        vl_mes = 'C010R'.
        vl_messt = 'C010S'.
      WHEN '11'.
        vl_mes = 'C011R'.
        vl_messt = 'C011S'.
      WHEN '12'.
        vl_mes = 'C012R'.
        vl_messt = 'C012S'.
    ENDCASE.



    LOOP AT <fs_outtable> ASSIGNING <linea>.
      ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.

      IF c_recria EQ abap_true OR ( c_recria EQ abap_true AND c_cria EQ abap_true ).
        IF <f_field> EQ 'HEMBRAS FINALES'.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field>.
          wa_ton_pro-mes = vl_messt.
          wa_ton_pro-ton_pro = <f_field>.
          APPEND wa_ton_pro TO it_ton_pro.
        ENDIF.
      ENDIF.


      IF c_cria EQ abap_true AND c_recria EQ abap_false.
        IF <f_field> EQ 'GALLINA JOVEN'.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field>.
          wa_ton_pro-mes = vl_messt.
          wa_ton_pro-ton_pro = <f_field>.
          APPEND wa_ton_pro TO it_ton_pro.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDLOOP.

  LOOP AT it_ton_pro INTO wa_ton_pro.
    vl_acum_gral = vl_acum_gral + wa_ton_pro-ton_pro.
  ENDLOOP.


  LOOP AT <fs_outtable> ASSIGNING <linea>.
    CLEAR: vl_acumulados, vl_acumulador .
    ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
    vl_columna = <f_field>.
    IF vl_columna EQ gv_txtunit.
      vl_tabix = sy-tabix.
    ENDIF.

    LOOP AT lt_fcat INTO ls_fcat WHERE fieldname NE 'WGBEZ60' AND fieldname NE 'TOTAL' AND fieldname NE lv_fname.
      ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <linea> TO <f_field>.
      IF sy-subrc EQ 0.

        ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <fs_unit>.
        IF <fs_unit> NE gv_txtunit.
          FIND ALL OCCURRENCES OF 'S' IN ls_fcat-fieldname MATCH COUNT sy-subrc.
          IF sy-subrc EQ 0.

            vl_acumulados = vl_acumulados + <f_field>.
          ELSE.
            REPLACE 'S' WITH 'R' INTO ls_fcat-fieldname.

            ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <linea> TO <f_field>.
            vl_acumulador = vl_acumulador + <f_field>.
          ENDIF.

          REPLACE 'R' WITH 'S' INTO ls_fcat-fieldname.


        ENDIF.

        READ TABLE it_ton_pro INTO wa_ton_pro WITH KEY mes = ls_fcat-fieldname.
        IF sy-subrc EQ 0.

          READ TABLE <fs_outtable> ASSIGNING <fs_stunit> INDEX vl_tabix - 1.
          ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_stunit> TO <fs_unit>.
          IF vl_columna EQ gv_txtunit.
            vl_cell_costo = <fs_unit>.
            ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <linea> TO <fs_unit>.
            IF wa_ton_pro-ton_pro GT 0.
              <fs_unit> = vl_cell_costo / wa_ton_pro-ton_pro.
            ELSE.
              <fs_unit> = 0.
            ENDIF.
          ENDIF.
        ELSE.
          REPLACE 'S' WITH 'R' INTO ls_fcat-fieldname.
          READ TABLE it_ton_pro INTO wa_ton_pro WITH KEY mes = ls_fcat-fieldname.
          READ TABLE <fs_outtable> ASSIGNING <fs_stunit> INDEX vl_tabix - 1.
          ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_stunit> TO <fs_unit>.
          IF vl_columna EQ gv_txtunit.
            vl_cell_costo = <fs_unit>.
            ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <linea> TO <fs_unit>.
            IF wa_ton_pro-ton_pro GT 0.
              <fs_unit> = vl_cell_costo / wa_ton_pro-ton_pro.
            ELSE.
              <fs_unit> = 0.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF vl_columna EQ gv_txtunit.
      ASSIGN COMPONENT 'TOTALS' OF STRUCTURE <fs_stunit> TO <fs_unit>.
      ASSIGN COMPONENT 'TOTALS' OF STRUCTURE <linea> TO <f_field>.
      IF vl_acum_gral GT 0.
        <f_field> = <fs_unit> / vl_acum_gral.
      ENDIF.
      ASSIGN COMPONENT 'TOTALR' OF STRUCTURE <fs_stunit> TO <fs_unit>.
      ASSIGN COMPONENT 'TOTALR' OF STRUCTURE <linea> TO <f_field>.
      IF vl_acum_gral GT 0.
        <f_field> = <fs_unit> / vl_acum_gral.
      ENDIF.
    ELSE.
      ASSIGN COMPONENT 'TOTALS' OF STRUCTURE <linea> TO <f_field>.
      <f_field> = vl_acumulados.

      ASSIGN COMPONENT 'TOTALR' OF STRUCTURE <linea> TO <f_field>.
      <f_field> = vl_acumulador.
    ENDIF.

  ENDLOOP.


ENDFORM.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

FORM decomiso_dep_maq.

  DATA: rg_fechas   TYPE RANGE OF acdoca-budat,
        vl_find,
        vl_sytabix  TYPE sy-tabix,
        vl_mes(5)   TYPE c,vl_messt(5)  TYPE c,
        vl_rgbwart  TYPE RANGE OF mseg-bwart,
        wa_rgbwart  LIKE LINE OF vl_rgbwart,
        vl_rgwerks  TYPE RANGE OF afpo-dwerk,
        wa_rgwerks  LIKE LINE OF vl_rgwerks
        .

  FIELD-SYMBOLS: <fs_tt>   TYPE table,
                 <fs_acum> TYPE table.


  TYPES: BEGIN OF st_aux_out,
           concepto TYPE wgbez60,
           menge    TYPE menge_d,
           month    TYPE dmbtr,
           monthst  TYPE dmbtr,
         END OF st_aux_out.

  DATA: it_aux_out TYPE STANDARD TABLE OF st_aux_out,
        wa_aux_out LIKE LINE OF it_aux_out.

  DATA it_totales TYPE STANDARD TABLE OF st_acumulado.


  IF p_werks IS INITIAL.
    LOOP AT it_aufnr_end INTO DATA(wa_aufnr).
      CLEAR wa_rgwerks.
      wa_rgwerks-sign = 'I'.
      wa_rgwerks-option = 'EQ'.
      wa_rgwerks-low = wa_aufnr-dwerk.
      APPEND wa_rgwerks TO vl_rgwerks.
    ENDLOOP.
  ELSE.
    wa_rgwerks-sign = 'I'.
    wa_rgwerks-option = 'EQ'.
    wa_rgwerks-low = p_werks-low.
    APPEND wa_rgwerks TO vl_rgwerks.
  ENDIF.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '531'.
  APPEND wa_rgbwart TO vl_rgbwart.

  wa_rgbwart-sign = 'I'.
  wa_rgbwart-option = 'EQ'.
  wa_rgbwart-low = '532'.
  APPEND wa_rgbwart TO vl_rgbwart.


  obj_engorda->decomiso_dep_maq(
          EXPORTING
          i_werks     = vl_rgwerks
          i_matkl     = 'ST0002'
          i_rgbwart   = vl_rgbwart
CHANGING
  ch_decomiso = it_mortal_dep
).
  IF vl_solo_vivo EQ abap_true.
    REFRESH it_mortal_dep.
  ENDIF.



  obj_engorda->calculate_dates(
    CHANGING
      p_rgfechas = rg_fechas
  ).

  LOOP AT rg_fechas INTO DATA(wa_fechas).
    DATA(aux_aufnr) = it_mortal_dep[].
    DELETE aux_aufnr WHERE budat_mkpf NOT BETWEEN wa_fechas-low AND wa_fechas-high.

    LOOP AT aux_aufnr INTO DATA(wa_mortandad).
      CLEAR wa_aux_out.
      "LOOP AT it_mortandad INTO DATA(wa_mortandad) WHERE aufnr EQ wa_auxaufnr-aufnr.
      CASE wa_fechas-low+4(2).
        WHEN '01'.
          vl_mes = 'C001R'.
          vl_messt = 'C001S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '02'.
          vl_mes = 'C002R'.
          vl_messt = 'C002S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '03'.
          vl_mes = 'C003R'.
          vl_messt = 'C003S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '04'.
          vl_mes = 'C004R'.
          vl_messt = 'C004S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '05'.
          vl_mes = 'C005R'.
          vl_messt = 'C005S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '06'.
          vl_mes = 'C006R'.
          vl_messt = 'C006S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '07'.
          vl_mes = 'C007R'.
          vl_messt = 'C007S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '08'.
          vl_mes = 'C008R'.
          vl_messt = 'C008S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '09'.
          vl_mes = 'C009R'.
          vl_messt = 'C009S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '10'.
          vl_mes = 'C010R'.
          vl_messt = 'C010S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '11'.
          vl_mes = 'C011R'.
          vl_messt = 'C011S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
        WHEN '12'.
          vl_mes = 'C012R'.
          vl_messt = 'C012S'.
          wa_aux_out-concepto = wa_mortandad-wgbez60.
          wa_aux_out-month = wa_mortandad-/cwm/menge.
          wa_aux_out-monthst = wa_mortandad-/cwm/menge.
          COLLECT wa_aux_out INTO it_aux_out.
      ENDCASE.

      " ENDLOOP.
    ENDLOOP.
    "
    vl_find = abap_false.
    IF it_aux_out IS NOT INITIAL.
      IF <fs_outtable> IS NOT INITIAL.
        LOOP AT it_aux_out INTO DATA(wa_aux).
          vl_find = abap_false.

          LOOP AT <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60' OF STRUCTURE <linea> TO <f_field>.
            IF <f_field> EQ wa_aux-concepto.
              vl_find = abap_true.
              vl_sytabix = sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF vl_find EQ abap_true.
            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

            vl_find = abap_false.

          ELSE.

            APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
            ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-concepto.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-month.

            UNASSIGN <f_field>.
            ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
            <f_field> = wa_aux-monthst.

          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT it_aux_out INTO DATA(wa2).

          APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
          ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-concepto.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_mes OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-month.

          UNASSIGN <f_field>.
          ASSIGN COMPONENT vl_messt OF STRUCTURE <linea> TO <f_field> .
          <f_field> = wa2-monthst.

        ENDLOOP.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ELSE.
      DATA vl_existe.
      LOOP AT <fs_outtable> ASSIGNING FIELD-SYMBOL(<fs_apar>).
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <fs_apar> TO <f_field>.
        IF sy-subrc EQ 0.
          IF <f_field> EQ 'Decomiso Kgs.'.
            vl_existe = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF vl_existe IS INITIAL.
        APPEND INITIAL LINE TO <fs_outtable> ASSIGNING <linea>.
        ASSIGN COMPONENT 'WGBEZ60'  OF STRUCTURE <linea> TO <f_field> .
        <f_field> = 'Decomiso Kgs.'.


      ENDIF.
    ENDIF.

    REFRESH it_aux_out.
    "
  ENDLOOP.
ENDFORM.
