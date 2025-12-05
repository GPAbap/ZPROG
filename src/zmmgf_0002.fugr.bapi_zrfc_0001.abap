FUNCTION bapi_zrfc_0001.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_CENTRO) TYPE  RESB-WERKS OPTIONAL
*"     VALUE(I_ARBPL) TYPE  RCRHD_A-ARBPL OPTIONAL
*"     VALUE(I_VERWE) TYPE  RCRHD_A-VERWE OPTIONAL
*"     VALUE(I_LGORT_RES) TYPE  RCRHD_A-VERWE OPTIONAL
*"  EXPORTING
*"     VALUE(E_RETURN) TYPE  BAPIRETURN
*"  TABLES
*"      T_ZPPE031 STRUCTURE  ZPPE031 OPTIONAL
*"      T_ZPPE037 STRUCTURE  ZPPE037 OPTIONAL
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ty_crhd,
    arbpl TYPE crhd-arbpl,
    werks TYPE crhd-werks,
    verwe TYPE crhd-verwe,
    veran TYPE crhd-veran,
    objid TYPE crhd-objid,
    objty TYPE crhd-objty,
    vgwts TYPE crhd-vgwts,
    endda TYPE crhd-endda,
    begda TYPE crhd-begda,
  END OF ty_crhd.
  TYPES: BEGIN OF ty_crtx,
    objid TYPE crtx-objid,
    objty TYPE crtx-objty,
    spras TYPE crtx-spras,
    ktext TYPE crtx-ktext,
  END OF ty_crtx.
  DATA:
        it_crhd TYPE TABLE OF ty_crhd,
        it_crtx TYPE TABLE OF ty_crtx,
        it_crco TYPE STANDARD TABLE OF crco.

  DATA:
        wa_crhd TYPE ty_crhd,
        wa_crtx TYPE ty_crtx,
        wa_crco TYPE crco.

  DATA:
        r_centro TYPE RANGE OF resb-werks,
        r_arbpl  TYPE RANGE OF rcrhd_a-arbpl.

  DATA:
        rs_centro LIKE LINE OF r_centro,
        rs_arbpl LIKE LINE OF r_arbpl.

  TYPES: BEGIN OF tp_tc20,
    parid TYPE tc20-parid,
    unit  TYPE tc20-unit,
    txtlg TYPE tc20t-txtlg,
  END OF tp_tc20.

  DATA:
        t_acrhd   TYPE TABLE OF rcrhd_a,
        t_tc20    TYPE TABLE OF tp_tc20,
        t_crtx    TYPE TABLE OF crtx,
        t_tc21t   TYPE TABLE OF tc21t,
        t_tc21    TYPE TABLE OF tc21,
        t_rcrhd_a TYPE TABLE OF rcrhd_a.
* DATA: r_centro TYPE RANGE OF resb-werks,
* r_arbpl TYPE RANGE OF rcrhd_a-arbpl,
  DATA:
        r_verwe TYPE RANGE OF rcrhd_a-verwe,
        r_lgort TYPE RANGE OF rcrhd_a-lgort_res.
* DATA: rs_centro LIKE LINE OF r_centro,
* rs_arbpl LIKE LINE OF r_arbpl,
  DATA:
        rs_verwe LIKE LINE OF r_verwe,
        rs_lgort LIKE LINE OF r_lgort.

  DATA:
        lw_acrhd   TYPE ty_crhd,
        lw_acrhd_a TYPE ty_crhd,
        lw_saida   TYPE zppe031,
*  lw_saida TYPE zppmiict01,
        lw_zppe037 TYPE zppe037,
        lw_tc21t   TYPE tc21t,
        lw_tc21    TYPE tc21,
        lw_tc20    TYPE tp_tc20,
        lw_crtx    TYPE crtx.
* Centro

  IF NOT i_centro IS INITIAL.
    rs_centro-option = 'EQ'.
    rs_centro-sign = 'I'.
    rs_centro-low = i_centro.
    APPEND rs_centro TO r_centro.
  ENDIF.

* Centro de trabalho
  IF NOT i_arbpl IS INITIAL.
    rs_arbpl-option = 'EQ'.
    rs_arbpl-sign = 'I'.
    rs_arbpl-low = i_arbpl.
    APPEND rs_arbpl TO r_arbpl.
  ENDIF.
  REFRESH: it_crhd, it_crtx.
  CLEAR: wa_crhd , wa_crtx.

  SELECT arbpl werks verwe veran objid objty vgwts endda begda
  FROM crhd
  INTO TABLE it_crhd
  WHERE werks IN r_centro
  AND arbpl IN r_arbpl.

  IF it_crhd[] IS NOT INITIAL.

    SELECT objid objty spras ktext FROM crtx
    INTO TABLE it_crtx
    FOR ALL ENTRIES IN it_crhd
    WHERE objid EQ it_crhd-objid.

    " Para obtener el CeCo
    SELECT * INTO TABLE it_crco
    FROM crco
    FOR ALL ENTRIES IN it_crhd
    WHERE objty EQ it_crhd-objty
    AND objid EQ it_crhd-objid.

  ENDIF.

  LOOP AT it_crhd INTO wa_crhd.

    READ TABLE it_crtx INTO wa_crtx
    WITH KEY objid = wa_crhd-objid.

    CLEAR wa_crco.
    READ TABLE it_crco INTO wa_crco
    WITH KEY objty = wa_crhd-objty
    objid = wa_crhd-objid
    endda = wa_crhd-endda
    begda = wa_crhd-begda.

    IF sy-subrc = 0.
      t_zppe031-kostl = wa_crco-kostl.
    ENDIF.

    t_zppe031-arbpl = wa_crhd-arbpl.
    t_zppe031-werks = wa_crhd-werks.
    t_zppe031-verwe = wa_crhd-verwe.
    t_zppe031-veran = wa_crhd-veran.
    t_zppe031-ktext = wa_crtx-ktext.
    t_zppe031-objid = wa_crhd-objid.
    t_zppe031-vgwts = wa_crhd-vgwts.

    APPEND t_zppe031.

  ENDLOOP.

  IF sy-subrc EQ 0.
  ENDIF.
* Atividades associadas ao recurso
  IF it_crhd[] IS NOT INITIAL.

    SELECT * INTO TABLE t_tc21t
    FROM tc21t
    FOR ALL ENTRIES IN it_crhd
    WHERE spras = sy-langu
    AND vgwts = it_crhd-vgwts.

    IF sy-subrc = 0.
      SORT t_tc21t BY spras vgwts.
    ENDIF.
    SELECT * INTO TABLE t_tc21
    FROM tc21
    FOR ALL ENTRIES IN it_crhd
    WHERE vgwts = it_crhd-vgwts.

    IF sy-subrc = 0.

      SELECT a~parid a~unit b~txtlg
      FROM tc20 AS a
      INNER JOIN tc20t AS b
      ON b~spras = sy-langu
      AND b~parid = a~parid
      INTO TABLE t_tc20
      FOR ALL ENTRIES IN t_tc21
      WHERE ( ( a~parid = t_tc21-par01 ) OR
      ( a~parid = t_tc21-par02 )   OR
      ( a~parid = t_tc21-par03 )   OR
      ( a~parid = t_tc21-par04 )   OR
      ( a~parid = t_tc21-par05 )   OR
      ( a~parid = t_tc21-par06 ) )
      AND b~spras = sy-langu.

    ENDIF.
*  IF NOT it_crhd IS INITIAL.
    LOOP AT it_crhd INTO wa_crhd WHERE arbpl <> space.
      lw_acrhd_a = wa_crhd.

      READ TABLE it_crtx INTO wa_crtx
      WITH KEY objty = wa_crhd-objty
      objid = wa_crhd-objid.
*
* IF sy-subrc = 0.
* lw_acrhd_a-ktext = wa_crtx-ktext.
* ENDIF. spras = sy-langu.
      READ TABLE t_tc21t INTO lw_tc21t
      WITH KEY spras = sy-langu
      vgwts = wa_crhd-vgwts.

      IF sy-subrc = 0.
        lw_zppe037-vgwts = lw_tc21t-vgwts.
        lw_zppe037-txt = lw_tc21t-txt.
      ENDIF.

      READ TABLE t_tc21 INTO lw_tc21
      WITH KEY vgwts = wa_crhd-vgwts.

      IF sy-subrc = 0.
*       Parametro 1
        CLEAR: lw_tc20.
        lw_zppe037-par01 = lw_tc21-par01.

        READ TABLE t_tc20 INTO lw_tc20
        WITH KEY parid = lw_tc21-par01.

        lw_zppe037-txtlg01 = lw_tc20-txtlg.
        lw_zppe037-unit01 = lw_tc20-unit.

*       Parametro 2
        CLEAR: lw_tc20.
        lw_zppe037-par02 = lw_tc21-par02.
        READ TABLE t_tc20 INTO lw_tc20
        WITH KEY parid = lw_tc21-par02.

        lw_zppe037-txtlg02 = lw_tc20-txtlg.
        lw_zppe037-unit02 = lw_tc20-unit.

*       Parametro 3
        CLEAR: lw_tc20.
        lw_zppe037-par03 = lw_tc21-par03.
        READ TABLE t_tc20 INTO lw_tc20
        WITH KEY parid = lw_tc21-par03.

        lw_zppe037-txtlg03 = lw_tc20-txtlg.
        lw_zppe037-unit03 = lw_tc20-unit.

*       Parametro 4
        CLEAR: lw_tc20.
        lw_zppe037-par04 = lw_tc21-par04.
        READ TABLE t_tc20 INTO lw_tc20
        WITH KEY parid = lw_tc21-par04.

        lw_zppe037-txtlg04 = lw_tc20-txtlg.
        lw_zppe037-unit04 = lw_tc20-unit.

*       Parametro 5
        CLEAR: lw_tc20.
        lw_zppe037-par05 = lw_tc21-par05.
        READ TABLE t_tc20 INTO lw_tc20
        WITH KEY parid = lw_tc21-par05.

        lw_zppe037-txtlg05 = lw_tc20-txtlg.
        lw_zppe037-unit05 = lw_tc20-unit.
*       Parametro 6
        CLEAR: lw_tc20.
        lw_zppe037-par06 = lw_tc21-par06.
        READ TABLE t_tc20 INTO lw_tc20
        WITH KEY parid = lw_tc21-par06.

        lw_zppe037-txtlg06 = lw_tc20-txtlg.
        lw_zppe037-unit06 = lw_tc20-unit.

      ENDIF.

      lw_saida-objid = lw_acrhd_a-objid.
      lw_saida-arbpl = lw_acrhd_a-arbpl.
      lw_saida-werks = lw_acrhd_a-werks.
      lw_saida-verwe = lw_acrhd_a-verwe.
      lw_saida-veran = lw_acrhd_a-veran.
      APPEND: lw_zppe037 TO t_zppe037.
      CLEAR: lw_acrhd_a, lw_crtx, lw_saida,
      lw_tc20, lw_acrhd, lw_zppe037.

    ENDLOOP.

    SORT: t_zppe037, t_zppe031.
    DELETE ADJACENT DUPLICATES FROM: t_zppe031, t_zppe037.
*   Seleccion realizada con existo
    e_return-type = 'S'.
    e_return-code = '00001'.
    e_return-message = 'Seleccion realizada con existo'(005).

  ELSE.
*   Não foi encontrado centros de trabalho para a seleção
    e_return-type = 'I'.
    e_return-code = '00002'.
    e_return-message = 'No se encontraron registros'(003).
  ENDIF.

ENDFUNCTION.
