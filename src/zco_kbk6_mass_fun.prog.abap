*&---------------------------------------------------------------------*
*& Include          ZCO_KBK6_MASS_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form exec_bi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exec_bi .
  DATA: vl_par   TYPE string, vl_fname TYPE string, num TYPE i.




  LOOP AT it_tabla INTO wa_tabla.
      num = 0.
    PERFORM genera_parametro USING num 'KPP0B-VALUE('
                             CHANGING vl_par
                                      num.
    IF rb_plan eq 'X'.
        PERFORM bdc_dynpro USING 'SAPLKPP0' '1000'.
        PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
        PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
        PERFORM bdc_field USING 'KPP1B-ONLY' 'X'.
        PERFORM bdc_field USING vl_par p_versn.
        PERFORM bdc_field USING 'BDC_SUBSCR' 'SAPLKPP0                                1100APPLIKAT'.

    else.
      num = 0.
  ENDIF.

 PERFORM genera_parametro USING num 'KPP0B-VALUE('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP0' '1000'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field USING 'KPP1B-ONLY' 'X'.
  PERFORM bdc_field USING vl_par        wa_tabla-periodoi.
  PERFORM bdc_field USING 'BDC_SUBSCR' 'SAPLKPP0                                1100APPLIKAT'.

      PERFORM genera_parametro USING num 'KPP0B-VALUE('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP0' '1000'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field USING 'KPP1B-ONLY' 'X'.
  PERFORM bdc_field USING vl_par       wa_tabla-periodof.
  PERFORM bdc_field USING 'BDC_SUBSCR' 'SAPLKPP0                                1100APPLIKAT'.

      PERFORM genera_parametro USING num 'KPP0B-VALUE('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP0' '1000'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field USING 'KPP1B-ONLY' 'X'.
  PERFORM bdc_field USING vl_par       wa_tabla-ejercicio.
  PERFORM bdc_field USING 'BDC_SUBSCR' 'SAPLKPP0                                1100APPLIKAT'.

      num = num + 1.
      PERFORM genera_parametro USING num 'KPP0B-VALUE('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP0' '1000'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field USING 'KPP1B-ONLY' 'X'.
  PERFORM bdc_field USING vl_par wa_tabla-ceco.
  PERFORM bdc_field USING 'BDC_SUBSCR' 'SAPLKPP0                                1100APPLIKAT'.


 num = num + 2.
  PERFORM genera_parametro USING num 'KPP0B-VALUE('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP0' '1000'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field USING 'KPP1B-ONLY' 'X'.
  PERFORM bdc_field USING vl_par wa_tabla-actividad.
  PERFORM bdc_field USING 'BDC_SUBSCR' 'SAPLKPP0                                1100APPLIKAT'.

  num = 0.
  PERFORM genera_parametro USING num 'KPP0B-VALUE('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP0' '1000'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '=CSUB'.
  PERFORM bdc_field USING 'KPP1B-ONLY' 'X'.
  PERFORM bdc_field USING 'BDC_SUBSCR' 'SAPLKPP0                                1100APPLIKAT'.

  IF rb_real eq 'X'.

  num = 0.
  PERFORM genera_parametro USING num 'Z-BDC02('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP2' '0112'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field USING  vl_par      wa_tabla-importe.

  num = 0.
  PERFORM genera_parametro USING num 'Z-BDC02('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP2' '0112'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '=CBUC'.

    PERFORM bdc_transaction USING 'KBK6'.
  ELSE.
  num = 0.
  PERFORM genera_parametro USING num 'Z-BDC07('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP2' '0112'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field USING  vl_par      wa_tabla-importe.

  num = 0.
  PERFORM genera_parametro USING num 'Z-BDC07('
                             CHANGING vl_par
                                      num.
  PERFORM bdc_dynpro USING 'SAPLKPP2' '0112'.
  PERFORM bdc_field USING 'BDC_CURSOR' vl_par.
  PERFORM bdc_field USING 'BDC_OKCODE' '=CBUC'.
    PERFORM bdc_transaction USING 'KP26'.
  ENDIF.

*    IF messtab[] IS INITIAL.
*      <fs_data>-status = '@0A@'.
*    ELSE.
*      <fs_data>-status = '@08@'.
*    ENDIF.

ENDLOOP.
ENDFORM.

FORM genera_parametro USING num TYPE i
                      name type string
                      CHANGING vl_par
                               rnum.
  data vl_num(2) type c.
  DATA indice(2) TYPE c.

  num = num + 1.
  vl_num = num.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = vl_num
    IMPORTING
      output = indice.

  CONCATENATE name indice ')' INTO vl_par.


ENDFORM.

FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program = program.
  bdcdata-dynpro = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM. "BDC_DYNPRO

*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  DATA nodata VALUE '/'.

  IF fval <> nodata.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM. "BDC_FIELD

*&---------------------------------------------------------------------*
*& Form BDC_TRANSACTION
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* -->TCODE text
*----------------------------------------------------------------------*
FORM bdc_transaction USING tcode.
  DATA ctumode LIKE ctu_params-dismode VALUE 'S'.
  DATA ctu VALUE 'X'.
  DATA cupdate LIKE ctu_params-updmode VALUE 'L'.

  DATA l_messtab TYPE bdcmsgcoll.

* batch input session
  REFRESH messtab.
  CALL TRANSACTION tcode USING bdcdata
        MODE ctumode
        UPDATE cupdate
        MESSAGES INTO messtab.
  l_subrc = sy-subrc.

  IF messtab[] IS INITIAL.
    l_messtab-msgid = 'F2'.
    l_messtab-msgnr = '174'.
    l_messtab-msgv1 = 'Registro actualizado o ya limitado'.
    APPEND l_messtab TO messtab.
  ENDIF.

  REFRESH bdcdata.
ENDFORM. "BDC_TRANSACTION
