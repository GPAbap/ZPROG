class ZCL_IM_MRM_HEADER_CHECK definition
  public
  final
  create public .

public section.

  interfaces IF_EX_MRM_HEADER_CHECK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_MRM_HEADER_CHECK IMPLEMENTATION.


  METHOD if_ex_mrm_header_check~headerdata_check.

*    DATA lt_errprot TYPE mrm_tab_errprot.
*    DATA ls_errprot TYPE mrm_errprot.
*
*    DATA: lv_existe_anticipo     TYPE abap_bool,
*          lv_anticipo_compensado,
*          lv_ebeln               TYPE ebeln,
*          lv_ebelp               TYPE ebelp.
*
*
*
*    CHECK sy-tcode = 'MIRO' AND sy-ucomm EQ 'BU'.
*    IF ti_drseg IS NOT INITIAL.
*      READ TABLE ti_drseg INTO DATA(webeln)  INDEX 1.
*      lv_ebeln = webeln-ebeln.
*    ENDIF.
*
*    CHECK lv_ebeln IS NOT INITIAL.
*    CLEAR lv_existe_anticipo.
*    CLEAR lv_anticipo_compensado.
*    "Aquí validar si la factura tiene OC con anticipo pendiente
*    "y si el anticipo no fue compensado.
*    LOOP AT ti_drseg INTO DATA(wa) .
*
*
*      "Buscar anticipos abiertos ligados a la OC
*      SELECT SINGLE @abap_true
*        FROM bsik_view
*        WHERE bukrs = @i_rbkpv-bukrs
*          AND lifnr = @i_rbkpv-lifnr
*          AND ebeln = @wa-ebeln "lv_ebeln
*          AND ebelp = @wa-ebelp"lv_ebelp
*          AND umskz <> ''
*        INTO @lv_existe_anticipo.
*
*      SELECT SINGLE @abap_true
*  FROM bsak_view
*  WHERE bukrs = @i_rbkpv-bukrs
*    AND lifnr = @i_rbkpv-lifnr
*    AND ebeln = @wa-ebeln"lv_ebeln
*    AND ebelp = @wa-ebelp"lv_ebelp
*    AND umskz = 'A'          "Validar CME de anticipo
*    AND augbl IS NOT INITIAL
*  INTO @lv_anticipo_compensado.
*
*
*      IF lv_existe_anticipo = abap_true
*         AND lv_anticipo_compensado = abap_false.
*
**        CLEAR ls_errprot.
**        ls_errprot-msgty = 'E'.
**        ls_errprot-msgid = 'M8'.
**        ls_errprot-msgno = '318'.
**        ls_errprot-msgv1 = wa-ebeln. "lv_ebeln.
**
**        APPEND ls_errprot TO lt_errprot.
**
**        CALL FUNCTION 'MRM_PROT_FILL'
**          TABLES
**            t_errprot = lt_errprot.
*        MESSAGE e318(m8) WITH wa-ebeln wa-ebelp. "lv_ebeln lv_ebelp.
*
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
