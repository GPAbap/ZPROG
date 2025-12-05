*&---------------------------------------------------------------------*
*& Include zmm_re_pa_cbr_jhv_fun
*&---------------------------------------------------------------------*

FORM get_data.

  SELECT m1~matnr, m3~maktx,
    m2~meins, m1~werks,
 CAST( '0.000' AS DEC( 13,3 ) ) AS stock,
  SUM( CASE WHEN m4~bwart EQ '262' THEN m4~menge * -1 ELSE m4~menge END )  AS menge
   INTO CORRESPONDING FIELDS OF TABLE @it_data
   FROM marc AS m1
  INNER JOIN mara AS m2 ON m2~matnr = m1~matnr
  INNER JOIN makt AS m3 ON m3~matnr = m2~matnr AND m3~spras = 'S'
  INNER JOIN mseg AS m4 ON m4~matnr = m1~matnr AND m4~werks = m1~werks
  WHERE m1~matnr IN @so_matnr
  AND m1~werks IN @so_werks
  AND m1~dispo IN @so_dispo
  AND m4~budat_mkpf IN @so_budat
  AND m4~bwart IN ('261','262')
  GROUP BY m1~matnr, m3~maktx,m2~meins, m1~werks.


ENDFORM.


FORM init_calculations.

  LOOP AT it_data ASSIGNING FIELD-SYMBOL(<wa_data>).
    DATA: ult_dia_mes TYPE sy-datum,
          dif_dias    TYPE i.


    "se obtiene numero de dias mes de ejecución
    CALL FUNCTION 'FKK_LAST_DAY_OF_MONTH'
      EXPORTING
        day_in            = sy-datum
      IMPORTING
        last_day_of_month = ult_dia_mes
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.

    CALL FUNCTION 'DAYS_BETWEEN_TWO_DATES'
      EXPORTING
        i_datum_bis = ult_dia_mes
        i_datum_von = sy-datum
*       i_kz_excl_von           = '0'
*       i_kz_incl_bis           = '0'
*       i_kz_ult_bis            = space
*       i_kz_ult_von            = space
*       i_stgmeth   = '0'
*       i_szbmeth   = '1'
      IMPORTING
        e_tage      = dif_dias
*  EXCEPTIONS
*       days_method_not_defined = 1
*       others      = 2
      .
*    SELECT  menge
**    INTO <wa_data>-reqxmeskg
*    INTO TABLE @DATA(it_nb)
*    FROM ekko AS k
*    INNER JOIN ekpo AS e ON e~ebeln = k~ebeln
*    WHERE k~bedat IN @so_budat
*    AND k~bsart EQ 'NB'
*    AND e~matnr EQ @<wa_data>-matnr
*    AND e~werks EQ @<wa_data>-werks.


    SELECT
      b~menge AS cant_solped,
      c~menge AS cant_req_ini,
      c~bsmng AS cant_pedida,
       b~elikz
      FROM ekko AS a INNER JOIN ekpo AS b
        ON b~ebeln EQ a~ebeln AND b~werks EQ @<wa_data>-werks
       LEFT JOIN eban AS c  ON c~ebeln EQ b~ebeln
      WHERE  a~bedat IN @so_budat
      AND  a~bsart EQ 'NB'
      AND b~matnr EQ @<wa_data>-matnr
      AND b~werks EQ @<wa_data>-werks
       INTO TABLE @DATA(it_salir_mes)
      BYPASSING BUFFER.

    DATA(vl_sum_solpeds) = REDUCE #( INIT a TYPE dmbtr
                          FOR wa IN it_salir_mes
                          WHERE ( elikz NE 'X' )
                         NEXT a = a + wa-cant_solped ).

    DATA(vl_requerido) = REDUCE #( INIT b TYPE dmbtr
                          FOR wa1 IN it_salir_mes
                         NEXT b = b + wa1-cant_req_ini ).


    DATA(vl_pedido) = REDUCE #( INIT c TYPE dmbtr
                          FOR wa2 IN it_salir_mes
                         NEXT c = c + wa2-cant_pedida ).

    <wa_data>-porsalirmes = vl_requerido - vl_pedido + vl_sum_solpeds.


    "consumo x dia
    <wa_data>-consum_diario = <wa_data>-menge / p_dias.
    <wa_data>-diasxconsum = <wa_data>-consum_diario * dif_dias.

    "stock en transito

    CALL FUNCTION 'BAPI_MATERIAL_STOCK_REQ_LIST'
      EXPORTING
        material         = <wa_data>-matnr
        plant            = <wa_data>-werks
        get_ind_lines    = 'X'
      IMPORTING
        mrp_stock_detail = t_mrp_stock_detail
      TABLES
        mrp_ind_lines    = t_mrp_ind_lines.



    LOOP AT t_mrp_ind_lines INTO DATA(wa_stock).

      IF wa_stock-rec_reqd_qty LT '0'.
        "<wa_data>-porsalirmes = <wa_data>-porsalirmes + wa_stock-rec_reqd_qty.
        <wa_data>-reqxmeskg = <wa_data>-reqxmeskg + wa_stock-rec_reqd_qty.
      ENDIF.
    ENDLOOP.

    <wa_data>-reqxmeskg = abs( <wa_data>-reqxmeskg ).


    IF <wa_data>-reqxmeskg > 0.
      <wa_data>-reqxmeskg = <wa_data>-reqxmeskg." / 1000.
    ENDIF.

    <wa_data>-reqxdia = <wa_data>-reqxmeskg / p_dias.






    <wa_data>-stock = t_mrp_stock_detail-unrestricted_stck.
    "Inv. Fin de mes: (Valor Calculado).
    <wa_data>-invfinmes = ( <wa_data>-stock - <wa_data>-diasxconsum ) + <wa_data>-porsalirmes.

    "j) Cobertura Sig. Mes: (Valor Calculado).
    <wa_data>-cobertura = <wa_data>-invfinmes / <wa_data>-consum_diario.

   IF <wa_data>-reqxmeskg > 0.
      <wa_data>-reqxmeston = <wa_data>-reqxmeskg / 1000.
    ENDIF.



  ENDLOOP.

ENDFORM.

FORM init_fieldcat.

  ls_layout-zebra = 'X'.
  "ls_layout-colwidth_optimize = 'X'.

  CLEAR ls_fieldcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
*     i_internal_tabname     =
      i_structure_name       = 'ZPP_ST_PLANTA_ALIMENTO'
*     i_client_never_display = 'X'
*     i_inclname             =
*     i_bypassing_buffer     =
*     i_buffer_active        =
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT gt_fieldcat ASSIGNING FIELD-SYMBOL(<wa_fc>).

    CASE <wa_fc>-fieldname.
      WHEN 'MATNR'.
        <wa_fc>-seltext_s = 'Cod.Mat.'.
        <wa_fc>-seltext_l = 'Código Material'.
        <wa_fc>-seltext_m = 'Código Material'.
        <wa_fc>-outputlen = 10.
      WHEN 'MAKTX'.
        <wa_fc>-seltext_s = 'Descrip.'.
        <wa_fc>-seltext_m = 'Descripción'.
        <wa_fc>-seltext_l = 'Descripción'.
        <wa_fc>-outputlen = 20.
      WHEN 'MEINS'.
        <wa_fc>-seltext_s = 'U.M.B.'.
        <wa_fc>-seltext_m = 'U.M.B.'.
        <wa_fc>-seltext_l = 'U.M.B.'.
      WHEN 'WERKS'.
        <wa_fc>-seltext_s = 'Centro'.
        <wa_fc>-seltext_m = 'Centro'.
        <wa_fc>-seltext_L = 'Centro'.
*    WHEN 'STOCK'.
*    <wa_fc>-seltext_s = 'Stock'.
*    <wa_fc>-seltext_m = 'Stock Lib.'.
*    <wa_fc>-seltext_l = 'Stock Lib.'.
*    when 'CONSUM_DIARIO'.
*    <wa_fc>-seltext_s = 'Consum. D.'.
*    <wa_fc>-seltext_m = 'Consumo Diario'.
*    <wa_fc>-seltext_L = 'Consumo Diario'.
*    when 'DIASXCONSUM'.
*    <wa_fc>-seltext_s = 'Días x Con'.
*    <wa_fc>-seltext_m = 'Dias por Consumir'.
*    <wa_fc>-seltext_L = 'Dias por Consumir'.
*    when 'TRANSITO'.
*    <wa_fc>-seltext_s = 'P Entregar'.
*    <wa_fc>-seltext_m = 'Por Entregar'.
*    <wa_fc>-seltext_L = 'Por Entregar'.
*    when 'PORSALIRMES'.
*    <wa_fc>-seltext_s = 'P Salir M'.
*    <wa_fc>-seltext_m = 'P/ Salir Mes'.
*    <wa_fc>-seltext_L = 'P/ Salir Mes'.
*    when 'COBERTURA'.
*    <wa_fc>-seltext_s = 'Cobertura'.
*    <wa_fc>-seltext_m = 'Cobertura Sig. Mes'.
*    <wa_fc>-seltext_L = 'Cobertura Sig. Mes'.
*    when 'INVFINMES'.
*    <wa_fc>-seltext_s = 'Inv. Mes'.
*    <wa_fc>-seltext_m = 'Inv. Fin de Mes'.
*    <wa_fc>-seltext_L = 'Inv. Fin de Mes'.
*    when 'REQXMESKG'.
*    <wa_fc>-seltext_s = 'Req Mes Kg'.
*    <wa_fc>-seltext_m = 'Req. Mes Kgs.'.
*    <wa_fc>-seltext_L = 'Req. Mes Kgs.'.
*    when 'REQXDIA'.
*    <wa_fc>-seltext_s = 'Req Mes Dia'.
*    <wa_fc>-seltext_m = 'Req. Día'.
*    <wa_fc>-seltext_L = 'Req. Día'.
*    when 'REQXMESTON'.
*    <wa_fc>-seltext_s = 'Req Mes Ton'.
*    <wa_fc>-seltext_m = 'Req. Mes Tons.'.
*    <wa_fc>-seltext_L = 'Req. Mes Tons.'.
      WHEN 'MENGE'.
        <wa_fc>-no_out = 'X'.

    ENDCASE.
    <wa_fc>-fix_column = 'X'.
  ENDLOOP.

ENDFORM.

FORM show_alv.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = gt_fieldcat
      is_layout          = ls_layout
    TABLES
      t_outtab           = it_data.

ENDFORM.
