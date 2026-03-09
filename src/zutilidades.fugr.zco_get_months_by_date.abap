

FUNCTION zco_get_months_by_date..
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(P_FECHA) TYPE  ZTY_DATE_RANGE
*"  TABLES
*"      NMESES TYPE  ZCO_TT_MESES
*"----------------------------------------------------------------------
  DATA vl_string TYPE string.
  DATA: vl_nmeses_i TYPE i, vl_nmeses_f TYPE i, vl_mes_c(2) TYPE c.
  DATA wa_nmeses TYPE zco_st_nmeses.

  IF p_fecha IS NOT INITIAL.


    IF p_fecha-high IS INITIAL.
      vl_mes_c = p_fecha-low+4(2).
         vl_nmeses_i = vl_mes_c.

      CONCATENATE 'M' vl_mes_c INTO vl_string.
      wa_nmeses-zmonth = vl_string.
      APPEND wa_nmeses TO nmeses.

    ELSE.
      vl_nmeses_i = p_fecha-low+4(2).
      vl_nmeses_f = p_fecha-high+4(2).

      WHILE vl_nmeses_i LE vl_nmeses_f.
        vl_mes_c =  vl_nmeses_i .
        vl_mes_c = |{ vl_mes_c ALPHA = IN }|.
        CONCATENATE 'M' vl_mes_c INTO vl_string.
        wa_nmeses-zmonth = vl_string.
        APPEND wa_nmeses TO nmeses.
        vl_nmeses_i = vl_nmeses_i + 1.
      ENDWHILE.
    ENDIF.

  ENDIF.

ENDFUNCTION.
