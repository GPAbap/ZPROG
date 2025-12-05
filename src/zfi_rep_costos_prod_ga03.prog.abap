*&---------------------------------------------------------------------*
*& Report ZFI_REP_COSTOS_PROD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_rep_costos_prod_ga03.

TABLES: acdoca, tvarvc.

TYPES: BEGIN OF ty_mara,
         matnr TYPE mara-matnr,
       END OF ty_mara.

TYPES: BEGIN OF ty_poper,
         poper TYPE acdoca-poper,
       END OF ty_poper.

DATA: it_fcat TYPE slis_t_fieldcat_alv,
      is_fcat LIKE LINE OF it_fcat.

DATA: lv_set1 TYPE setnode-setname,
      lv_set2 TYPE setnode-setname.

DATA: lv_descr14 TYPE string,
      lv_bukrs14 TYPE string.

DATA: lv_racct   TYPE acdoca-racct,
      lv_ulstar  TYPE acdoca-ulstar,
      lv_kostl   TYPE acdoca-ukostl,
      lv_setname TYPE setleaf-setname.

DATA: lv_pre   TYPE p DECIMALS 2,
      lv_por   TYPE p DECIMALS 2,
      lv_tton  TYPE p DECIMALS 2,
      lv_timp  TYPE p DECIMALS 2,
      lv_matnr TYPE mara-matnr.

DATA: it_setleaf TYPE STANDARD TABLE OF setleaf WITH HEADER LINE,
      it_setnode TYPE STANDARD TABLE OF setnode WITH HEADER LINE.

DATA: it_setleafc TYPE STANDARD TABLE OF setleaf WITH HEADER LINE,
      it_setnodec TYPE STANDARD TABLE OF setnode WITH HEADER LINE.

DATA: it_fieldcat TYPE lvc_t_fcat,
      is_fieldcat LIKE LINE OF it_fieldcat.

DATA: it_cosp TYPE STANDARD TABLE OF cosp WITH HEADER LINE,
      it_coss TYPE STANDARD TABLE OF coss WITH HEADER LINE.

DATA: go_container TYPE REF TO cl_gui_custom_container,
      r_layout     TYPE lvc_s_layo,
      ls_vari      TYPE disvariant,
      go_alv_grid  TYPE REF TO cl_gui_alv_grid.
DATA: lv_imp1 TYPE p DECIMALS 2,
      lv_imp2 TYPE p DECIMALS 2,
      lv_port TYPE c LENGTH 20.
DATA: it_acdo   TYPE STANDARD TABLE OF acdoca WITH HEADER LINE,
      it_acdoa  TYPE STANDARD TABLE OF acdoca WITH HEADER LINE,
      it_acdoc  TYPE STANDARD TABLE OF acdoca WITH HEADER LINE,
      it_mbewh  TYPE STANDARD TABLE OF mbewh WITH HEADER LINE,
      it_mbewha TYPE STANDARD TABLE OF mbewh WITH HEADER LINE,
      it_afko   TYPE STANDARD TABLE OF afko WITH HEADER LINE,
      it_afpo   TYPE STANDARD TABLE OF afpo WITH HEADER LINE,
      it_makt   TYPE STANDARD TABLE OF makt WITH HEADER LINE,
      it_jest   TYPE STANDARD TABLE OF jest WITH HEADER LINE,
      it_t001k  TYPE STANDARD TABLE OF t001k WITH HEADER LINE,
      it_ml4h   TYPE STANDARD TABLE OF ml4h_mldochd WITH HEADER LINE,
      it_mara   TYPE STANDARD TABLE OF ty_mara WITH HEADER LINE.

DATA: it_conf TYPE STANDARD TABLE OF zfi_rep_co_ga03 WITH HEADER LINE,
      it_cont TYPE STANDARD TABLE OF zfi_rep_co_ga03 WITH HEADER LINE,
      it_cons TYPE STANDARD TABLE OF zfi_rep_co_ga03 WITH HEADER LINE.

DATA: it_poper TYPE STANDARD TABLE OF ty_poper WITH HEADER LINE.

DATA: lv_lfgja TYPE mbewh-lfgja,
      ok_code  TYPE syucomm,
      lv_lin   TYPE i,
      lv_linc  TYPE i,
      lv_aufnr TYPE afko-aufnr.

DATA: set_key TYPE salv_s_layout_key,
      g_exit  TYPE c,
      set_lay TYPE slis_vari.


DATA: it_out TYPE SORTED TABLE OF zfi_rep_costos_men WITH UNIQUE KEY matnr descr WITH HEADER LINE.
DATA: it_dis TYPE STANDARD TABLE OF zfi_rep_costos_all,
      wa_dis TYPE zfi_rep_costos_all,
      wa_dit TYPE zfi_rep_costos_all,
      it_diz TYPE SORTED TABLE OF zfi_rep_costos_men WITH UNIQUE KEY matnr descr WITH HEADER LINE.
RANGES: r_racct  FOR acdoca-racct,
        r_racctc FOR acdoca-racct,
        r_rcntrc FOR acdoca-rcntr,
        r_matnr  FOR acdoca-matnr,
        r_matpt  FOR acdoca-matnr,
        r_matcp  FOR acdoca-matnr,
        r_kostl  FOR ccss-kostl,
        r_dates  FOR afpo-ltrmi,
        r_objnr  FOR jest-objnr,
        r_dauat  FOR afpo-dauat,
        r_bwkey  FOR t001k-bwkey,
        r_matkl  FOR mara-matkl,
        r_aufnr  FOR afpo-aufnr.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  SELECT-OPTIONS: s_bukrs FOR acdoca-rbukrs OBLIGATORY,
                  s_gjahr FOR acdoca-gjahr OBLIGATORY NO INTERVALS NO-EXTENSION.
  SELECT-OPTIONS: s_poper FOR acdoca-poper OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
  PARAMETERS p_vari TYPE disvariant-variant.
SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.

  ls_vari-report = sy-repid.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = ls_vari
*     I_TABNAME_HEADER          =
*     I_TABNAME_ITEM            =
*     IT_DEFAULT_FIELDCAT       =
      i_save        = 'A'
*     I_DISPLAY_VIA_GRID        = ' '
    IMPORTING
      e_exit        = g_exit
      es_variant    = ls_vari
    EXCEPTIONS
      not_found     = 1
      program_error = 2
      OTHERS        = 3.

  IF sy-subrc = 0.

    p_vari = ls_vari-variant.

    set_lay = ls_vari-variant.

  ENDIF.


START-OF-SELECTION.
  CLEAR: it_acdo[], it_mbewh[], it_afko[], it_afpo[],
         r_racct[], r_matnr[], it_conf[], r_bwkey[], it_ml4h[],
         r_matpt[], r_matcp[], r_dates[], r_objnr[], r_dauat[],
         r_aufnr[], r_kostl[].

  set_key-report = sy-repid.

  SELECT *
    INTO TABLE it_conf
    FROM zfi_rep_co_ga03
   WHERE proceso = '01'.

  SORT it_conf BY proceso id conse.

* Cuentas Costos
  READ TABLE it_conf WITH KEY id = '10'
                              valor = s_bukrs-low.
  IF sy-subrc EQ 0.
    SELECT *
      INTO TABLE it_setnode
      FROM setnode
     WHERE setclass = '0102'
       AND subclass = 'GP00'
       AND setname  = it_conf-descripcion.
    IF sy-subrc EQ 0.
      SELECT *
        INTO TABLE it_setleaf
        FROM setleaf
         FOR ALL ENTRIES IN it_setnode
       WHERE setclass = '0102'
         AND subclass = 'GP00'
         AND setname  = it_setnode-subsetname.
      IF sy-subrc EQ 0.
        CLEAR: r_racctc[], r_rcntrc[].
        LOOP AT it_setleaf.
          r_racctc-sign   =  it_setleaf-valsign.
          r_racctc-option =  it_setleaf-valoption.
          r_racctc-low    =  it_setleaf-valfrom.
          APPEND r_racctc.
        ENDLOOP.
      ENDIF.
    ELSE.
      MESSAGE 'No se encontraron cuentas para determinar costos' TYPE 'I'.
    ENDIF.
  ENDIF.

* Cecos de Costos
  READ TABLE it_conf WITH KEY id    = '09'
                              valor = s_bukrs-low.
  IF sy-subrc EQ 0.
    SELECT *
      INTO TABLE it_setleafc
      FROM setleaf
     WHERE setclass = '0101'
       AND subclass = 'GA00'
       AND setname  = it_conf-descripcion.
    IF sy-subrc EQ 0.
      CLEAR: r_kostl[].
      LOOP AT it_setleafc.
        r_kostl-sign   =  it_setleafc-valsign.
        r_kostl-option =  it_setleafc-valoption.
        r_kostl-low    =  it_setleafc-valfrom.
        APPEND r_kostl.
      ENDLOOP.
    ELSE.
      MESSAGE 'No se encontraron cecos para determinar costos' TYPE 'I'.
    ENDIF.

  ENDIF.

  SELECT *
    INTO TABLE it_conf
    FROM zfi_rep_co_ga03
   WHERE proceso = '01'.

  SORT it_conf BY proceso id conse.

  it_cont[] = it_conf[].
  SORT it_cont BY id.
  DELETE it_cont WHERE id NE '08'.
  it_cons[] = it_conf[].
  SORT it_cons BY id.
  DELETE it_cons WHERE id NE '12'.
  " Cuentas
  LOOP AT it_conf WHERE id = '01'.
    r_racct-sign   = 'I'.
    r_racct-option = 'EQ'.
    r_racct-low    = it_conf-valor.
    APPEND r_racct.
  ENDLOOP.

  " Materiales
  LOOP AT it_conf WHERE id = '02'.
    r_matnr-sign   = 'I'.
    r_matnr-option = 'EQ'.
    r_matnr-low = it_conf-valor.
    APPEND r_matnr.
  ENDLOOP.

  SELECT *
    INTO TABLE it_t001k
    FROM t001k
   WHERE bukrs IN s_bukrs.
  IF sy-subrc EQ 0.
    LOOP AT it_t001k.
      r_bwkey-sign   = 'I'.
      r_bwkey-option = 'EQ'.
      r_bwkey-low = it_t001k-bwkey.
      APPEND r_bwkey.
    ENDLOOP.
  ENDIF.

*Se agrega grupo de materiales a tabla
  CLEAR: r_matkl[].
  " Grupo de Materiales
  LOOP AT it_conf WHERE id = '13'.
    r_matkl-sign   = 'I'.
    r_matkl-option = 'EQ'.
    r_matkl-low = it_conf-valor.
    APPEND r_matkl.
  ENDLOOP.

  SELECT matnr
    INTO TABLE it_mara
    FROM mara
   WHERE matkl IN r_matkl.
  IF sy-subrc EQ 0.
    LOOP AT it_mara.
      r_matpt-sign   = 'I'.
      r_matpt-option = 'EQ'.
      r_matpt-low = it_mara-matnr.
      APPEND r_matpt.
    ENDLOOP.
  ENDIF.

  SELECT *
    INTO TABLE it_acdo
    FROM acdoca
   WHERE rbukrs IN s_bukrs
     AND gjahr  IN s_gjahr
     AND racct  IN r_racct
     AND matnr  IN r_matnr
     AND poper  IN s_poper
     AND ktopl  =  'GP00'.
*     AND xtruerev NE 'X'.
  IF sy-subrc EQ 0.
    SORT it_acdo BY matnr.
    SELECT *
      INTO TABLE it_makt
      FROM makt
       FOR ALL ENTRIES IN it_acdo
     WHERE matnr = it_acdo-matnr
       AND spras = sy-langu.
* Ventas
*    READ TABLE it_conf WITH KEY id          = '05'
*                               descripcion = it_acdo-matnr.
*    IF sy-subrc EQ 0.
*      it_out-descr = it_conf-valor.
*    ENDIF.
    LOOP AT  it_conf WHERE id = '05'.
      FIND ',' IN it_conf-descripcion.
      IF sy-subrc EQ 0.
        CLEAR: lv_matnr, lv_racct.
        SPLIT it_conf-descripcion AT ',' INTO lv_matnr lv_racct.
        LOOP AT it_acdo WHERE matnr = lv_matnr
                          AND racct = lv_racct.
          it_poper-poper = it_acdo-poper.
          APPEND it_poper.
          CLEAR it_out.
          it_out-matnr = 'Ventas'.
          it_out-descr = it_conf-valor.

          CASE it_acdo-poper.
            WHEN '001'.
              it_out-tons01  = it_acdo-msl.
              it_out-wrbtr01 = it_acdo-hsl.
              it_out-tons01  = it_out-tons01 * -1.
              it_out-wrbtr01 = it_out-wrbtr01 * -1.
            WHEN '002'.
              it_out-tons02  = it_acdo-msl.
              it_out-wrbtr02 = it_acdo-hsl.
              it_out-tons02  = it_out-tons02 * -1.
              it_out-wrbtr02 = it_out-wrbtr02 * -1.
            WHEN '003'.
              it_out-tons03  = it_acdo-msl.
              it_out-wrbtr03 = it_acdo-hsl.
              it_out-tons03  = it_out-tons03 * -1.
              it_out-wrbtr03 = it_out-wrbtr03 * -1.
            WHEN '004'.
              it_out-tons04  = it_acdo-msl.
              it_out-wrbtr04 = it_acdo-hsl.
              it_out-tons04  = it_out-tons04 * -1.
              it_out-wrbtr04 = it_out-wrbtr04 * -1.
            WHEN '005'.
              it_out-tons05  = it_acdo-msl.
              it_out-wrbtr05 = it_acdo-hsl.
              it_out-tons05  = it_out-tons05 * -1.
              it_out-wrbtr05 = it_out-wrbtr05 * -1.
            WHEN '006'.
              it_out-tons06  = it_acdo-msl.
              it_out-wrbtr06 = it_acdo-hsl.
              it_out-tons06  = it_out-tons06 * -1.
              it_out-wrbtr06 = it_out-wrbtr06 * -1.
            WHEN '007'.
              it_out-tons07  = it_acdo-msl.
              it_out-wrbtr07 = it_acdo-hsl.
              it_out-tons07  = it_out-tons07 * -1.
              it_out-wrbtr07 = it_out-wrbtr07 * -1.
            WHEN '008'.
              it_out-tons08  = it_acdo-msl.
              it_out-wrbtr08 = it_acdo-hsl.
              it_out-tons08  = it_out-tons08 * -1.
              it_out-wrbtr08 = it_out-wrbtr08 * -1.
            WHEN '009'.
              it_out-tons09  = it_acdo-msl.
              it_out-wrbtr09 = it_acdo-hsl.
              it_out-tons09  = it_out-tons09 * -1.
              it_out-wrbtr09 = it_out-wrbtr09 * -1.
            WHEN '010'.
              it_out-tons10  = it_acdo-msl.
              it_out-wrbtr10 = it_acdo-hsl.
              it_out-tons10  = it_out-tons10 * -1.
              it_out-wrbtr10 = it_out-wrbtr10 * -1.
            WHEN '011'.
              it_out-tons11  = it_acdo-msl.
              it_out-wrbtr11 = it_acdo-hsl.
              it_out-tons11  = it_out-tons11 * -1.
              it_out-wrbtr11 = it_out-wrbtr11 * -1.
            WHEN '012'.
              it_out-tons12  = it_acdo-msl.
              it_out-wrbtr12 = it_acdo-hsl.
              it_out-tons12  = it_out-tons12 * -1.
              it_out-wrbtr12 = it_out-wrbtr12 * -1.
            WHEN OTHERS.
          ENDCASE.
          COLLECT it_out.
        ENDLOOP.
      ELSE.
        CLEAR lv_matnr.
        lv_matnr = it_conf-descripcion.
        LOOP AT it_acdo WHERE matnr = lv_matnr.
          it_poper-poper = it_acdo-poper.
          APPEND it_poper.
          CLEAR it_out.
          it_out-matnr = 'Ventas'.
          it_out-descr = it_conf-valor.

          CASE it_acdo-poper.
            WHEN '001'.
              it_out-tons01  = it_acdo-msl.
              it_out-wrbtr01 = it_acdo-hsl.
              it_out-tons01  = it_out-tons01 * -1.
              it_out-wrbtr01 = it_out-wrbtr01 * -1.
            WHEN '002'.
              it_out-tons02  = it_acdo-msl.
              it_out-wrbtr02 = it_acdo-hsl.
              it_out-tons02  = it_out-tons02 * -1.
              it_out-wrbtr02 = it_out-wrbtr02 * -1.
            WHEN '003'.
              it_out-tons03  = it_acdo-msl.
              it_out-wrbtr03 = it_acdo-hsl.
              it_out-tons03  = it_out-tons03 * -1.
              it_out-wrbtr03 = it_out-wrbtr03 * -1.
            WHEN '004'.
              it_out-tons04  = it_acdo-msl.
              it_out-wrbtr04 = it_acdo-hsl.
              it_out-tons04  = it_out-tons04 * -1.
              it_out-wrbtr04 = it_out-wrbtr04 * -1.
            WHEN '005'.
              it_out-tons05  = it_acdo-msl.
              it_out-wrbtr05 = it_acdo-hsl.
              it_out-tons05  = it_out-tons05 * -1.
              it_out-wrbtr05 = it_out-wrbtr05 * -1.
            WHEN '006'.
              it_out-tons06  = it_acdo-msl.
              it_out-wrbtr06 = it_acdo-hsl.
              it_out-tons06  = it_out-tons06 * -1.
              it_out-wrbtr06 = it_out-wrbtr06 * -1.
            WHEN '007'.
              it_out-tons07  = it_acdo-msl.
              it_out-wrbtr07 = it_acdo-hsl.
              it_out-tons07  = it_out-tons07 * -1.
              it_out-wrbtr07 = it_out-wrbtr07 * -1.
            WHEN '008'.
              it_out-tons08  = it_acdo-msl.
              it_out-wrbtr08 = it_acdo-hsl.
              it_out-tons08  = it_out-tons08 * -1.
              it_out-wrbtr08 = it_out-wrbtr08 * -1.
            WHEN '009'.
              it_out-tons09  = it_acdo-msl.
              it_out-wrbtr09 = it_acdo-hsl.
              it_out-tons09  = it_out-tons09 * -1.
              it_out-wrbtr09 = it_out-wrbtr09 * -1.
            WHEN '010'.
              it_out-tons10  = it_acdo-msl.
              it_out-wrbtr10 = it_acdo-hsl.
              it_out-tons10  = it_out-tons10 * -1.
              it_out-wrbtr10 = it_out-wrbtr10 * -1.
            WHEN '011'.
              it_out-tons11  = it_acdo-msl.
              it_out-wrbtr11 = it_acdo-hsl.
              it_out-tons11  = it_out-tons11 * -1.
              it_out-wrbtr11 = it_out-wrbtr11 * -1.
            WHEN '012'.
              it_out-tons12  = it_acdo-msl.
              it_out-wrbtr12 = it_acdo-hsl.
              it_out-tons12  = it_out-tons12 * -1.
              it_out-wrbtr12 = it_out-wrbtr12 * -1.
            WHEN OTHERS.
          ENDCASE.
          COLLECT it_out.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF it_out[] IS NOT INITIAL.
      SELECT *
        INTO TABLE it_mbewh
        FROM mbewh
       WHERE matnr IN r_matnr
         AND bwkey IN r_bwkey
         AND lfgja IN s_gjahr.
      IF sy-subrc EQ 0.

        LOOP AT it_mbewh WHERE lfgja = s_gjahr-low.
          CLEAR it_out.

          it_out-matnr = 'Inventario Inicial'.
          READ TABLE it_conf WITH KEY id          = '06'
                                      descripcion = it_mbewh-matnr.
          IF sy-subrc EQ 0.
            it_out-descr = it_conf-valor.
          ENDIF.

          CASE it_mbewh-lfmon.
            WHEN '01'.
              it_out-tons02  = it_mbewh-lbkum.
              it_out-wrbtr02 = it_mbewh-salk3.
            WHEN '02'.
              it_out-tons03  = it_mbewh-lbkum.
              it_out-wrbtr03 = it_mbewh-salk3.
            WHEN '03'.
              it_out-tons04  = it_mbewh-lbkum.
              it_out-wrbtr04 = it_mbewh-salk3.
            WHEN '04'.
              it_out-tons05  = it_mbewh-lbkum.
              it_out-wrbtr05 = it_mbewh-salk3.
            WHEN '05'.
              it_out-tons06  = it_mbewh-lbkum.
              it_out-wrbtr06 = it_mbewh-salk3.
            WHEN '06'.
              it_out-tons07  = it_mbewh-lbkum.
              it_out-wrbtr07 = it_mbewh-salk3.
            WHEN '07'.
              it_out-tons08  = it_mbewh-lbkum.
              it_out-wrbtr08 = it_mbewh-salk3.
            WHEN '08'.
              it_out-tons09  = it_mbewh-lbkum.
              it_out-wrbtr09 = it_mbewh-salk3.
            WHEN '09'.
              it_out-tons10  = it_mbewh-lbkum.
              it_out-wrbtr10 = it_mbewh-salk3.
            WHEN '10'.
              it_out-tons11  = it_mbewh-lbkum.
              it_out-wrbtr11 = it_mbewh-salk3.
            WHEN '11'.
              it_out-tons12  = it_mbewh-lbkum.
              it_out-wrbtr12 = it_mbewh-salk3.
          ENDCASE.
          COLLECT it_out.
        ENDLOOP.
        lv_lfgja = s_gjahr-low - 1.
        SELECT *
  APPENDING TABLE it_mbewh
       FROM mbewh
      WHERE matnr IN r_matnr
        AND bwkey IN r_bwkey
        AND lfgja = lv_lfgja
        AND lfmon = '12'.
        IF sy-subrc EQ 0.
          LOOP AT it_mbewh WHERE lfgja = lv_lfgja
                             AND lfmon = '12'.
            CLEAR it_out.
            it_out-matnr = 'Inventario Inicial'.
            READ TABLE it_conf WITH KEY id          = '06'
                                        descripcion = it_mbewh-matnr.
            IF sy-subrc EQ 0.
              it_out-descr = it_conf-valor.
            ENDIF.
            it_out-tons01  = it_mbewh-lbkum.
            it_out-wrbtr01 = it_mbewh-salk3.
            COLLECT it_out.
          ENDLOOP.
        ENDIF.
* Inventario Final del Mes
        LOOP AT it_mbewh WHERE lfgja = s_gjahr-low.
          CLEAR it_out.

          it_out-matnr = 'Inventario Final'.
          READ TABLE it_conf WITH KEY id          = '11'
                                      descripcion = it_mbewh-matnr.
          IF sy-subrc EQ 0.
            it_out-descr = it_conf-valor.
          ELSE.
            CONTINUE.
          ENDIF.

          CASE it_mbewh-lfmon.
            WHEN '01'.
              it_out-tons01  = it_mbewh-lbkum.
              it_out-wrbtr01 = it_mbewh-salk3.
            WHEN '02'.
              it_out-tons02  = it_mbewh-lbkum.
              it_out-wrbtr02 = it_mbewh-salk3.
            WHEN '03'.
              it_out-tons03  = it_mbewh-lbkum.
              it_out-wrbtr03 = it_mbewh-salk3.
            WHEN '04'.
              it_out-tons04 = it_mbewh-lbkum.
              it_out-wrbtr04 = it_mbewh-salk3.
            WHEN '05'.
              it_out-tons05  = it_mbewh-lbkum.
              it_out-wrbtr05 = it_mbewh-salk3.
            WHEN '06'.
              it_out-tons06  = it_mbewh-lbkum.
              it_out-wrbtr06 = it_mbewh-salk3.
            WHEN '07'.
              it_out-tons07  = it_mbewh-lbkum.
              it_out-wrbtr07 = it_mbewh-salk3.
            WHEN '08'.
              it_out-tons08  = it_mbewh-lbkum.
              it_out-wrbtr08 = it_mbewh-salk3.
            WHEN '09'.
              it_out-tons09  = it_mbewh-lbkum.
              it_out-wrbtr09 = it_mbewh-salk3.
            WHEN '10'.
              it_out-tons10  = it_mbewh-lbkum.
              it_out-wrbtr10 = it_mbewh-salk3.
            WHEN '11'.
              it_out-tons11  = it_mbewh-lbkum.
              it_out-wrbtr11 = it_mbewh-salk3.
            WHEN '12'.
              it_out-tons12  = it_mbewh-lbkum.
              it_out-wrbtr12 = it_mbewh-salk3.
          ENDCASE.
          COLLECT it_out.
        ENDLOOP.
      ENDIF.

      DATA: lv_jahrper  TYPE ml4h_mldochd-jahrper,
            lv_jahrper2 TYPE ml4h_mldochd-jahrper.
      CONCATENATE s_gjahr-low '000' INTO lv_jahrper.
      CONCATENATE s_gjahr-low '012' INTO lv_jahrper2.
      SELECT *
        INTO TABLE it_ml4h
        FROM ml4h_mldochd
       WHERE matnr IN r_matpt
         AND bwkey IN r_bwkey
         AND curtp =  '10'
         AND glvor IN ('RMWE', 'RMRP')
         AND jahrper > lv_jahrper
         AND jahrper <= lv_jahrper2.
      IF sy-subrc EQ 0.

        LOOP AT it_ml4h.
          CLEAR it_out.
          it_out-matnr = 'CA'.
          it_out-descr = 'Compra de Azucar'.
          CASE it_ml4h-jahrper+4(3).
            WHEN '001'.
              it_out-tons01  = it_ml4h-quant.
              it_out-wrbtr01 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '002'.
              it_out-tons02  = it_ml4h-quant.
              it_out-wrbtr02 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '003'.
              it_out-tons03  = it_ml4h-quant.
              it_out-wrbtr03 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '004'.
              it_out-tons04  = it_ml4h-quant.
              it_out-wrbtr04 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '005'.
              it_out-tons05  = it_ml4h-quant.
              it_out-wrbtr05 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '006'.
              it_out-tons06  = it_ml4h-quant.
              it_out-wrbtr06 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '007'.
              it_out-tons07  = it_ml4h-quant.
              it_out-wrbtr07 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '008'.
              it_out-tons08  = it_ml4h-quant.
              it_out-wrbtr08 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '009'.
              it_out-tons09  = it_ml4h-quant.
              it_out-wrbtr09 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '010'.
              it_out-tons10  = it_ml4h-quant.
              it_out-wrbtr10 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '011'.
              it_out-tons11  = it_ml4h-quant.
              it_out-wrbtr11 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN '012'.
              it_out-tons12  = it_ml4h-quant.
              it_out-wrbtr12 = it_ml4h-stval + it_ml4h-prd + it_ml4h-kdm.
            WHEN OTHERS.
          ENDCASE.
          COLLECT it_out.
        ENDLOOP.
      ENDIF.
*** AFKO
      r_dates-sign   = 'I'.
      r_dates-option = 'BT'.
      CONCATENATE s_gjahr-low '0101' INTO r_dates-low.
      CONCATENATE s_gjahr-low '1231' INTO r_dates-high.
      APPEND r_dates.

      r_dauat-sign   = 'I'.
      r_dauat-option = 'CP'.
      r_dauat-low    = 'AZ*'.
      APPEND r_dauat.

      LOOP AT it_conf WHERE id = '07'.
        r_matcp-sign   = 'I'.
        r_matcp-option = 'CP'.
        r_matcp-low    = it_conf-valor.
        APPEND r_matcp.
      ENDLOOP.

      SELECT *
        INTO TABLE it_afpo
        FROM afpo
       WHERE ltrmi IN r_dates
         AND dauat IN r_dauat
         AND matnr IN r_matcp
         AND pwerk IN r_bwkey.
      IF sy-subrc EQ 0.
        r_objnr-sign = 'I'.
        r_objnr-option = 'EQ'.
        LOOP AT it_afpo.
          CONCATENATE 'OR' it_afpo-aufnr INTO r_objnr-low.
          APPEND r_objnr.
        ENDLOOP.
        SELECT *
          INTO TABLE it_jest
          FROM jest
         WHERE objnr IN r_objnr
           AND stat  = 'I0046'
           AND inact = space.
        IF sy-subrc EQ 0.
          r_aufnr-sign = 'I'.
          r_aufnr-option = 'EQ'.
          LOOP AT it_jest.
            REPLACE ALL OCCURRENCES OF 'OR' IN it_jest-objnr WITH space.
            CONDENSE it_jest-objnr.
            lv_aufnr = it_jest-objnr.
            r_aufnr-low = lv_aufnr.
            APPEND r_aufnr.
          ENDLOOP.
          SELECT *
            INTO TABLE it_acdoa
            FROM acdoca
           WHERE aufnr IN r_aufnr.
          IF sy-subrc EQ 0.

            SELECT *
              INTO TABLE it_acdoc
              FROM acdoca
               FOR ALL ENTRIES IN it_acdoa
             WHERE rbukrs = it_acdoa-rbukrs
               AND gjahr = it_acdoa-gjahr
               AND racct IN r_racctc
               AND rcntr IN r_kostl
               AND poper = it_acdoa-poper.

            IF sy-subrc EQ 0 .
              SORT it_acdoc BY rcntr.
              DELETE it_acdoc WHERE rcntr IS INITIAL.
              SORT it_acdoc BY racct poper.
            ENDIF.

            SELECT *
              INTO TABLE it_mbewha
              FROM mbewh
               FOR ALL ENTRIES IN it_acdoa
             WHERE matnr = it_acdoa-matnr
               AND bwkey IN r_bwkey
               AND lfgja IN s_gjahr.

            SELECT *
               APPENDING TABLE it_mbewha
               FROM mbewh
                FOR ALL ENTRIES IN it_acdoa
              WHERE matnr = it_acdoa-matnr
                AND bwkey IN r_bwkey
                AND lfgja = lv_lfgja
                AND lfmon = '12'.
* Validacion de nodos de costos
            LOOP AT it_conf WHERE id = '03'.
* Logica Nueva
              FIND '-' IN it_conf-descripcion.
              IF sy-subrc EQ 0.
                SPLIT it_conf-descripcion AT '-' INTO lv_kostl lv_setname.
*                lv_racct = it_conf-descripcion.
                LOOP AT it_setleaf WHERE setname = lv_setname.
                  lv_racct = it_setleaf-valfrom.
                  LOOP AT it_acdoc WHERE racct  = lv_racct.
                    CLEAR it_out.
                    it_out-matnr = 'Costos'.
*                  READ TABLE it_conf WITH KEY id          = '05'
*                                              descripcion = it_acdoa-matnr.
*                  IF sy-subrc EQ 0.
                    it_out-descr = it_conf-valor.
*                  ENDIF.
                    CASE it_acdoc-poper.
                      WHEN '001'.
                        it_out-tons01  = it_acdoc-msl.
                        it_out-wrbtr01 = it_acdoc-hsl.
                        it_out-tons01  = it_out-tons01.
                        it_out-wrbtr01 = it_out-wrbtr01.
                      WHEN '002'.
                        it_out-tons02  = it_acdoc-msl.
                        it_out-wrbtr02 = it_acdoc-hsl.
                        it_out-tons02  = it_out-tons02.
                        it_out-wrbtr02 = it_out-wrbtr02.
                      WHEN '003'.
*                      it_out-tons03  = it_acdoc-msl.
                        it_out-wrbtr03 = it_acdoc-hsl.
                        it_out-tons03  = it_out-tons03.
                        it_out-wrbtr03 = it_out-wrbtr03.
                      WHEN '004'.
                        it_out-tons04  = it_acdoc-msl.
                        it_out-wrbtr04 = it_acdoc-hsl.
                        it_out-tons04  = it_out-tons04.
                        it_out-wrbtr04 = it_out-wrbtr04.
                      WHEN '005'.
                        it_out-tons05  = it_acdoc-msl.
                        it_out-wrbtr05 = it_acdoc-hsl.
                        it_out-tons05  = it_out-tons05.
                        it_out-wrbtr05 = it_out-wrbtr05.
                      WHEN '006'.
                        it_out-tons06  = it_acdoc-msl.
                        it_out-wrbtr06 = it_acdoc-hsl.
                        it_out-tons06  = it_out-tons06.
                        it_out-wrbtr06 = it_out-wrbtr06.
                      WHEN '007'.
                        it_out-tons07  = it_acdoc-msl.
                        it_out-wrbtr07 = it_acdoc-hsl.
                        it_out-tons07  = it_out-tons07.
                        it_out-wrbtr07 = it_out-wrbtr07.
                      WHEN '008'.
                        it_out-tons08  = it_acdoc-msl.
                        it_out-wrbtr08 = it_acdoc-hsl.
                        it_out-tons08  = it_out-tons08.
                        it_out-wrbtr08 = it_out-wrbtr08.
                      WHEN '009'.
                        it_out-tons09  = it_acdoc-msl.
                        it_out-wrbtr09 = it_acdoc-hsl.
                        it_out-tons09  = it_out-tons09.
                        it_out-wrbtr09 = it_out-wrbtr09.
                      WHEN '010'.
                        it_out-tons10  = it_acdoc-msl.
                        it_out-wrbtr10 = it_acdoc-hsl.
                        it_out-tons10  = it_out-tons10.
                        it_out-wrbtr10 = it_out-wrbtr10.
                      WHEN '011'.
                        it_out-tons11  = it_acdoc-msl.
                        it_out-wrbtr11 = it_acdoc-hsl.
                        it_out-tons11  = it_out-tons11.
                        it_out-wrbtr11 = it_out-wrbtr11.
                      WHEN '012'.
                        it_out-tons12  = it_acdoc-msl.
                        it_out-wrbtr12 = it_acdoc-hsl.
                        it_out-tons12  = it_out-tons12.
                        it_out-wrbtr12 = it_out-wrbtr12.
                      WHEN OTHERS.
                    ENDCASE.
                    COLLECT it_out.
                  ENDLOOP.
                ENDLOOP.
              ENDIF.

              FIND ',' IN it_conf-descripcion.
              IF sy-subrc EQ 0.
                CLEAR: lv_matnr, lv_racct.
                SPLIT it_conf-descripcion AT ',' INTO lv_matnr lv_racct.
                LOOP AT it_acdoa WHERE racct = lv_racct
                                   AND matnr = lv_matnr.
                  CLEAR it_out.
                  it_out-matnr = 'Costos'.
                  it_out-descr = it_conf-valor.
                  READ TABLE it_mbewha WITH KEY matnr = it_acdoa-matnr
                                                lfgja = it_acdoa-gjahr
                                                lfmon = it_acdoa-poper+1(2).
                  IF it_mbewha-vprsv = 'S'.
                    CASE it_acdoa-poper.
                      WHEN '001'.
                        it_out-wrbtr01 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr01 = it_out-wrbtr01 * -1.
                      WHEN '002'.

                        it_out-wrbtr02 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr02 = it_out-wrbtr02 * -1.
                      WHEN '003'.

                        it_out-wrbtr03 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr03 = it_out-wrbtr03 * -1.
                      WHEN '004'.

                        it_out-wrbtr04 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr04 = it_out-wrbtr04 * -1.
                      WHEN '005'.
                        it_out-wrbtr05 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr05 = it_out-wrbtr05 * -1.
                      WHEN '006'.
                        it_out-wrbtr06 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr06 = it_out-wrbtr06 * -1.
                      WHEN '007'.
                        it_out-wrbtr07 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr07 = it_out-wrbtr07 * -1.
                      WHEN '008'.
                        it_out-wrbtr08 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr08 = it_out-wrbtr08 * -1.
                      WHEN '009'.
                        it_out-wrbtr09 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr09 = it_out-wrbtr09 * -1.
                      WHEN '010'.
                        it_out-wrbtr10 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr10 = it_out-wrbtr10 * -1.
                      WHEN '011'.
                        it_out-wrbtr11 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr11 = it_out-wrbtr11 * -1.
                      WHEN '012'.
                        it_out-wrbtr12 = it_acdoa-msl * it_mbewha-verpr.
*                      it_out-wrbtr12 = it_out-wrbtr12 * -1.
                      WHEN OTHERS.
                    ENDCASE.
                  ELSE.
                    CASE it_acdoa-poper.
                      WHEN '001'.
                        it_out-wrbtr01 = it_acdoa-tsl.
                      WHEN '002'.
                        it_out-wrbtr02 = it_acdoa-tsl.
                      WHEN '003'.
                        it_out-wrbtr03 = it_acdoa-tsl.
                      WHEN '004'.
                        it_out-wrbtr04 = it_acdoa-tsl.
                      WHEN '005'.
                        it_out-wrbtr05 = it_acdoa-tsl.
                      WHEN '006'.
                        it_out-wrbtr06 = it_acdoa-tsl.
                      WHEN '007'.
                        it_out-wrbtr07 = it_acdoa-tsl.
                      WHEN '008'.
                        it_out-wrbtr08 = it_acdoa-tsl.
                      WHEN '009'.
                        it_out-wrbtr09 = it_acdoa-tsl.
                      WHEN '010'.
                        it_out-wrbtr10 = it_acdoa-tsl.
                      WHEN '011'.
                        it_out-wrbtr11 = it_acdoa-tsl.
                      WHEN '012'.
                        it_out-wrbtr12 = it_acdoa-tsl.
                      WHEN OTHERS.
                    ENDCASE.
                  ENDIF.

                  COLLECT it_out.
                ENDLOOP.
              ENDIF.
              FIND '|' IN it_conf-descripcion.
              IF sy-subrc EQ 0.
                SPLIT it_conf-descripcion AT '|' INTO lv_racct lv_ulstar lv_kostl.
*                lv_racct = it_conf-descripcion.
                LOOP AT it_acdoa WHERE racct  = lv_racct
                                   AND ulstar = lv_ulstar
                                   AND ukostl = lv_kostl.
                  CLEAR it_out.
                  it_out-matnr = 'Costos'.
*                  READ TABLE it_conf WITH KEY id          = '05'
*                                              descripcion = it_acdoa-matnr.
*                  IF sy-subrc EQ 0.
                  it_out-descr = it_conf-valor.
*                  ENDIF.
                  CASE it_acdoa-poper.
                    WHEN '001'.
                      it_out-tons01  = it_acdoa-msl.
                      it_out-wrbtr01 = it_acdoa-hsl.
                      it_out-tons01  = it_out-tons01 * -1.
                      it_out-wrbtr01 = it_out-wrbtr01 * -1.
                    WHEN '002'.
                      it_out-tons02  = it_acdoa-msl.
                      it_out-wrbtr02 = it_acdoa-hsl.
                      it_out-tons02  = it_out-tons02 * -1.
                      it_out-wrbtr02 = it_out-wrbtr02 * -1.
                    WHEN '003'.
*                      it_out-tons03  = it_acdoa-msl.
                      it_out-wrbtr03 = it_acdoa-hsl.
                      it_out-tons03  = it_out-tons03 * -1.
                      it_out-wrbtr03 = it_out-wrbtr03 * -1.
                    WHEN '004'.
                      it_out-tons04  = it_acdoa-msl.
                      it_out-wrbtr04 = it_acdoa-hsl.
                      it_out-tons04  = it_out-tons04 * -1.
                      it_out-wrbtr04 = it_out-wrbtr04 * -1.
                    WHEN '005'.
                      it_out-tons05  = it_acdoa-msl.
                      it_out-wrbtr05 = it_acdoa-hsl.
                      it_out-tons05  = it_out-tons05 * -1.
                      it_out-wrbtr05 = it_out-wrbtr05 * -1.
                    WHEN '006'.
                      it_out-tons06  = it_acdoa-msl.
                      it_out-wrbtr06 = it_acdoa-hsl.
                      it_out-tons06  = it_out-tons06 * -1.
                      it_out-wrbtr06 = it_out-wrbtr06 * -1.
                    WHEN '007'.
                      it_out-tons07  = it_acdoa-msl.
                      it_out-wrbtr07 = it_acdoa-hsl.
                      it_out-tons07  = it_out-tons07 * -1.
                      it_out-wrbtr07 = it_out-wrbtr07 * -1.
                    WHEN '008'.
                      it_out-tons08  = it_acdoa-msl.
                      it_out-wrbtr08 = it_acdoa-hsl.
                      it_out-tons08  = it_out-tons08 * -1.
                      it_out-wrbtr08 = it_out-wrbtr08 * -1.
                    WHEN '009'.
                      it_out-tons09  = it_acdoa-msl.
                      it_out-wrbtr09 = it_acdoa-hsl.
                      it_out-tons09  = it_out-tons09 * -1.
                      it_out-wrbtr09 = it_out-wrbtr09 * -1.
                    WHEN '010'.
                      it_out-tons10  = it_acdoa-msl.
                      it_out-wrbtr10 = it_acdoa-hsl.
                      it_out-tons10  = it_out-tons10 * -1.
                      it_out-wrbtr10 = it_out-wrbtr10 * -1.
                    WHEN '011'.
                      it_out-tons11  = it_acdoa-msl.
                      it_out-wrbtr11 = it_acdoa-hsl.
                      it_out-tons11  = it_out-tons11 * -1.
                      it_out-wrbtr11 = it_out-wrbtr11 * -1.
                    WHEN '012'.
                      it_out-tons12  = it_acdoa-msl.
                      it_out-wrbtr12 = it_acdoa-hsl.
                      it_out-tons12  = it_out-tons12 * -1.
                      it_out-wrbtr12 = it_out-wrbtr12 * -1.
                    WHEN OTHERS.
                  ENDCASE.
                  COLLECT it_out.
                ENDLOOP.
              ENDIF.

            ENDLOOP.

          ENDIF.
        ENDIF.
      ENDIF.
* Gastos Operacion
      LOOP AT it_conf WHERE id = '14'.

        CLEAR: it_cosp, it_coss, lv_set1, lv_set2, lv_descr14, lv_bukrs14.
        SPLIT it_conf-descripcion AT ',' INTO lv_set1 lv_set2.
        SPLIT it_conf-valor AT ',' INTO lv_descr14 lv_bukrs14.
        IF lv_bukrs14 NE s_bukrs-low.
          CONTINUE.
        ENDIF.
* Cuentas gastos
        SELECT *
          INTO TABLE it_setnode
          FROM setnode
         WHERE setclass = '0102'
           AND subclass = 'GP00'
           AND setname  = lv_set2.
        IF sy-subrc EQ 0.
          SELECT *
            INTO TABLE it_setleaf
            FROM setleaf
             FOR ALL ENTRIES IN it_setnode
           WHERE setclass = '0102'
             AND subclass = 'GP00'
             AND setname  = it_setnode-subsetname.
          IF sy-subrc EQ 0.
            CLEAR: r_racctc[], r_rcntrc[].
            LOOP AT it_setleaf.
              r_racctc-sign   =  it_setleaf-valsign.
              r_racctc-option =  it_setleaf-valoption.
              r_racctc-low    =  it_setleaf-valfrom.
              APPEND r_racctc.
            ENDLOOP.
*          ENDIF.
          ELSE.
            MESSAGE 'No se encontraron cuentas para determinar gastos operacion' TYPE 'I'.
            CONTINUE.
          ENDIF.
        ELSE.
          SELECT *
         INTO TABLE it_setleaf
         FROM setleaf
        WHERE setclass = '0102'
          AND subclass = 'GP00'
          AND setname  = lv_set2.
          IF sy-subrc EQ 0.
            CLEAR: r_racctc[], r_rcntrc[].
            LOOP AT it_setleaf.
              r_racctc-sign   =  it_setleaf-valsign.
              r_racctc-option =  it_setleaf-valoption.
              r_racctc-low    =  it_setleaf-valfrom.
              APPEND r_racctc.
            ENDLOOP.
*          ENDIF.
          ELSE.
            MESSAGE 'No se encontraron cuentas para determinar gastos operacion' TYPE 'I'.
            CONTINUE.
          ENDIF.
        ENDIF.
* Cecos de Costos

        SELECT *
          INTO TABLE it_setleafc
          FROM setleaf
         WHERE setclass = '0101'
           AND subclass = 'GA00'
           AND setname  = lv_set1.
        IF sy-subrc EQ 0.
          CLEAR: r_objnr[].
          LOOP AT it_setleafc.
            r_objnr-sign   =  it_setleafc-valsign.
            r_objnr-option =  it_setleafc-valoption.
            CONCATENATE 'KSGA00' it_setleafc-valfrom INTO r_objnr-low.
            APPEND r_objnr.
          ENDLOOP.
        ELSE.
          SELECT *
            INTO TABLE it_setnode
            FROM setnode
           WHERE setclass = '0101'
             AND subclass = 'GP00'
             AND setname  = lv_set1.
          IF sy-subrc EQ 0.
            SELECT *
            INTO TABLE it_setleafc
            FROM setleaf
             FOR ALL ENTRIES IN it_setnodec
           WHERE setclass = '0101'
             AND subclass = 'GA00'
             AND setname  = it_setnodec-subsetname.
            IF sy-subrc EQ 0.
              CLEAR: r_objnr[].
              LOOP AT it_setleafc.
                r_objnr-sign   =  it_setleafc-valsign.
                r_objnr-option =  it_setleafc-valoption.
                CONCATENATE 'KSGA00' it_setleafc-valfrom INTO r_objnr-low.
                APPEND r_objnr.
              ENDLOOP.
            ENDIF.
          ENDIF.

        ENDIF.

        SELECT *
          INTO TABLE it_cosp
          FROM cosp
         WHERE objnr IN r_objnr
           AND gjahr IN s_gjahr
           AND wrttp = '04'
           AND versn = '000'
           AND kstar IN r_racctc.
        IF sy-subrc EQ 0.
          LOOP AT it_cosp.
            it_out-matnr = 'Gastos'.
            it_out-descr = lv_descr14.
            it_out-wrbtr01 = it_cosp-wog001.
            it_out-wrbtr02 = it_cosp-wog002.
            it_out-wrbtr03 = it_cosp-wog003.
            it_out-wrbtr04 = it_cosp-wog004.
            it_out-wrbtr05 = it_cosp-wog005.
            it_out-wrbtr06 = it_cosp-wog006.
            it_out-wrbtr07 = it_cosp-wog007.
            it_out-wrbtr08 = it_cosp-wog008.
            it_out-wrbtr09 = it_cosp-wog009.
            it_out-wrbtr10 = it_cosp-wog010.
            it_out-wrbtr11 = it_cosp-wog011.
            it_out-wrbtr12 = it_cosp-wog012.
            COLLECT it_out.
          ENDLOOP.
        ENDIF.

        SELECT *
          INTO TABLE it_coss
          FROM coss
         WHERE objnr IN r_objnr
           AND gjahr IN s_gjahr
           AND wrttp = '04'
           AND versn = '000'
           AND kstar IN r_racctc.
        IF sy-subrc EQ 0.
          LOOP AT it_coss.
            it_out-matnr = 'Gastos'.
            it_out-descr = lv_descr14.
            it_out-wrbtr01 = it_coss-wog001.
            it_out-wrbtr02 = it_coss-wog002.
            it_out-wrbtr03 = it_coss-wog003.
            it_out-wrbtr04 = it_coss-wog004.
            it_out-wrbtr05 = it_coss-wog005.
            it_out-wrbtr06 = it_coss-wog006.
            it_out-wrbtr07 = it_coss-wog007.
            it_out-wrbtr08 = it_coss-wog008.
            it_out-wrbtr09 = it_coss-wog009.
            it_out-wrbtr10 = it_coss-wog010.
            it_out-wrbtr11 = it_coss-wog011.
            it_out-wrbtr12 = it_coss-wog012.
            COLLECT it_out.
          ENDLOOP.
        ENDIF.

      ENDLOOP.
* Inventario Inicial Final Ajustes
      DATA: lv_glacct TYPE bapi3006_0-gl_account,
            it_acu    TYPE STANDARD TABLE OF bapi3006_4 WITH HEADER LINE,
            lv_des1   TYPE c LENGTH 40,
            lv_des2   TYPE c LENGTH 40.

      LOOP AT it_conf WHERE id = '16'.
        CLEAR: lv_glacct, it_acu[], lv_des1, lv_des2.
        lv_glacct = it_conf-valor.
        SPLIT it_conf-descripcion AT ',' INTO lv_des1 lv_des2.
* acumulado anio anterior

        CALL FUNCTION 'BAPI_GL_ACC_GETPERIODBALANCES'
          EXPORTING
            companycode      = s_bukrs-low
            glacct           = lv_glacct
            fiscalyear       = lv_lfgja
            currencytype     = '00'
          TABLES
            account_balances = it_acu.

* Inventario Inicial
        LOOP AT it_acu.
          CLEAR it_out.
          it_out-matnr = 'Inventario Inicial'.
          it_out-descr = lv_des1.
          CASE it_acu-fis_period.
            WHEN '12'.
              it_out-wrbtr01 = it_acu-balance_long * -1.
            WHEN OTHERS.
          ENDCASE.
          COLLECT it_out.
        ENDLOOP.
        CLEAR: lv_glacct, it_acu[], lv_des1, lv_des2.
        lv_glacct = it_conf-valor.
        SPLIT it_conf-descripcion AT ',' INTO lv_des1 lv_des2.

* leemos acumulado actual
        CALL FUNCTION 'BAPI_GL_ACC_GETPERIODBALANCES'
          EXPORTING
            companycode      = s_bukrs-low
            glacct           = lv_glacct
            fiscalyear       = s_gjahr-low
            currencytype     = '00'
          TABLES
            account_balances = it_acu.
* Inventario Inicial
        LOOP AT it_acu.
          CLEAR it_out.
          it_out-matnr = 'Inventario Inicial'.
          it_out-descr = lv_des1.
          CASE it_acu-fis_period.
            WHEN '01'.
              it_out-wrbtr02 = it_acu-balance_long * -1.
            WHEN '02'.
              it_out-wrbtr03 = it_acu-balance_long * -1.
            WHEN '03'.
              it_out-wrbtr04 = it_acu-balance_long * -1.
            WHEN '04'.
              it_out-wrbtr05 = it_acu-balance_long * -1.
            WHEN '05'.
              it_out-wrbtr06 = it_acu-balance_long * -1.
            WHEN '06'.
              it_out-wrbtr07 = it_acu-balance_long * -1.
            WHEN '07'.
              it_out-wrbtr08 = it_acu-balance_long * -1.
            WHEN '08'.
              it_out-wrbtr09 = it_acu-balance_long * -1.
            WHEN '09'.
              it_out-wrbtr10 = it_acu-balance_long * -1.
            WHEN '10'.
              it_out-wrbtr11 = it_acu-balance_long * -1.
            WHEN '11'.
              it_out-wrbtr12 = it_acu-balance_long * -1.
*            WHEN '12'.
*              it_out-wrbtr12 = it_acu-balance_long * -1.
            WHEN OTHERS.
          ENDCASE.
          COLLECT it_out.
        ENDLOOP.
* Inventario Final
        LOOP AT it_acu.
          CLEAR it_out.
          it_out-matnr = 'Inventario Final'.
          it_out-descr = lv_des2.
          CASE it_acu-fis_period.
            WHEN '01'.
              it_out-wrbtr01 = it_acu-balance_long * -1.
            WHEN '02'.
              it_out-wrbtr02 = it_acu-balance_long * -1.
            WHEN '03'.
              it_out-wrbtr03 = it_acu-balance_long * -1.
            WHEN '04'.
              it_out-wrbtr04 = it_acu-balance_long * -1.
            WHEN '05'.
              it_out-wrbtr05 = it_acu-balance_long * -1.
            WHEN '06'.
              it_out-wrbtr06 = it_acu-balance_long * -1.
            WHEN '07'.
              it_out-wrbtr07 = it_acu-balance_long * -1.
            WHEN '08'.
              it_out-wrbtr08 = it_acu-balance_long * -1.
            WHEN '09'.
              it_out-wrbtr09 = it_acu-balance_long * -1.
            WHEN '10'.
              it_out-wrbtr10 = it_acu-balance_long * -1.
            WHEN '11'.
              it_out-wrbtr11 = it_acu-balance_long * -1.
            WHEN '12'.
              it_out-wrbtr12 = it_acu-balance_long * -1.
            WHEN OTHERS.
          ENDCASE.
          COLLECT it_out.
        ENDLOOP.
      ENDLOOP.


* Otros Gastos
      LOOP AT it_conf WHERE id = '15'.
        CLEAR: it_acdo[].
        FIND ',' IN it_conf-descripcion.
        IF sy-subrc EQ 0.
          CLEAR: lv_matnr, lv_racct.
          SPLIT it_conf-descripcion AT ',' INTO lv_matnr lv_racct.
          SELECT *
            INTO TABLE it_acdo
            FROM acdoca
           WHERE rbukrs IN s_bukrs
             AND gjahr  IN s_gjahr
             AND racct  = lv_racct
             AND poper  IN s_poper
             AND matnr  = lv_matnr.
        ELSE.
          lv_racct =  it_conf-descripcion.
          SELECT *
            INTO TABLE it_acdo
            FROM acdoca
           WHERE rbukrs IN s_bukrs
             AND gjahr  IN s_gjahr
             AND racct  = lv_racct
             AND poper  IN s_poper.
        ENDIF.

        IF it_acdo[] IS NOT INITIAL.
          LOOP AT it_acdo.
            CLEAR it_out.
            it_out-matnr = 'OtrosGastos'.
            it_out-descr = it_conf-valor.
            CASE it_acdo-poper.
              WHEN '001'.
                it_out-wrbtr01 = it_acdo-tsl.
              WHEN '002'.
                it_out-wrbtr02 = it_acdo-tsl.
              WHEN '003'.
                it_out-wrbtr03 = it_acdo-tsl.
              WHEN '004'.
                it_out-wrbtr04 = it_acdo-tsl.
              WHEN '005'.
                it_out-wrbtr05 = it_acdo-tsl.
              WHEN '006'.
                it_out-wrbtr06 = it_acdo-tsl.
              WHEN '007'.
                it_out-wrbtr07 = it_acdo-tsl.
              WHEN '008'.
                it_out-wrbtr08 = it_acdo-tsl.
              WHEN '009'.
                it_out-wrbtr09 = it_acdo-tsl.
              WHEN '010'.
                it_out-wrbtr10 = it_acdo-tsl.
              WHEN '011'.
                it_out-wrbtr11 = it_acdo-tsl.
              WHEN '012'.
                it_out-wrbtr12 = it_acdo-tsl.
              WHEN OTHERS.
            ENDCASE.
            COLLECT it_out.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDIF.
* Salida
    IF it_out[] IS NOT INITIAL.
* Armamos salida de acuerdo con configuracion
      SORT it_poper BY poper.
      DELETE ADJACENT DUPLICATES FROM it_poper COMPARING ALL FIELDS.

      LOOP AT it_conf WHERE id = '04'.
        CLEAR: lv_pre, lv_por, lv_tton, lv_timp.
*        IF it_conf-descripcion IS INITIAL.
*          CONTINUE.
*        ENDIF.
*        IF it_conf-descripcion = 'Sumas'.
*          CONTINUE.
*        ENDIF.
        CLEAR wa_dis.
        lv_matnr     = it_conf-descripcion.
        wa_dis-segme = it_conf-descripcion.
*        IF it_conf-conse <= '06'.
*          lv_matnr = 'Ventas'.
*        ENDIF.
*        IF it_conf-conse >= '07' AND it_conf-conse <= '13'.
*          lv_matnr = 'Inventario Inicial'.
*        ENDIF.
*        IF it_conf-conse = '14'.
*          lv_matnr = 'CA'.
*        ENDIF.
*        IF it_conf-conse >= '15' AND it_conf-conse <= '38'.
*          lv_matnr = 'Costos'.
*        ENDIF.
        LOOP AT it_out WHERE matnr = lv_matnr
                         AND descr = it_conf-valor.
          LOOP AT it_poper.
            CASE it_poper.
              WHEN '001'.
                IF it_out-tons01 IS NOT INITIAL.
                  wa_dis-tons01 = it_out-tons01.
                  lv_pre = it_out-wrbtr01 / it_out-tons01.
                  wa_dis-netpr01 = lv_pre.
                ENDIF.
                wa_dis-wrbtr01 = it_out-wrbtr01.
              WHEN '002'.
                IF it_out-tons02 IS NOT INITIAL.
                  wa_dis-tons02 = it_out-tons02.
                  lv_pre = it_out-wrbtr02 / it_out-tons02.
                  wa_dis-netpr02 = lv_pre.
                ENDIF.
                wa_dis-wrbtr02 = it_out-wrbtr02.
              WHEN '003'.
                IF it_out-tons03 IS NOT INITIAL.
                  wa_dis-tons03 = it_out-tons03.
                  lv_pre = it_out-wrbtr03 / it_out-tons03.
                  wa_dis-netpr03 = lv_pre.
                ENDIF.
                wa_dis-wrbtr03 = it_out-wrbtr03.
              WHEN '004'.
                IF it_out-tons04 IS NOT INITIAL.
                  wa_dis-tons04 = it_out-tons04.
                  lv_pre = it_out-wrbtr04 / it_out-tons04.
                  wa_dis-netpr04 = lv_pre.
                ENDIF.
                wa_dis-wrbtr04 = it_out-wrbtr04.
              WHEN '005'.
                IF it_out-tons05 IS NOT INITIAL.
                  wa_dis-tons05 = it_out-tons05.
                  lv_pre = it_out-wrbtr05 / it_out-tons05.
                  wa_dis-netpr05 = lv_pre.
                ENDIF.
                wa_dis-wrbtr05 = it_out-wrbtr05.
              WHEN '006'.
                IF it_out-tons06 IS NOT INITIAL.
                  wa_dis-tons06 = it_out-tons06.
                  lv_pre = it_out-wrbtr06 / it_out-tons06.
                  wa_dis-netpr06 = lv_pre.
                ENDIF.
                wa_dis-wrbtr06 = it_out-wrbtr06.
              WHEN '007'.
                IF it_out-tons07 IS NOT INITIAL.
                  wa_dis-tons07 = it_out-tons07.
                  lv_pre = it_out-wrbtr07 / it_out-tons07.
                  wa_dis-netpr07 = lv_pre.
                ENDIF.
                wa_dis-wrbtr07 = it_out-wrbtr07.
              WHEN '008'.
                IF it_out-tons08 IS NOT INITIAL.
                  wa_dis-tons08 = it_out-tons08.
                  lv_pre = it_out-wrbtr08 / it_out-tons08.
                  wa_dis-netpr08 = lv_pre.
                ENDIF.
                wa_dis-wrbtr08 = it_out-wrbtr08.
              WHEN '009'.
                IF it_out-tons09 IS NOT INITIAL.
                  wa_dis-tons09 = it_out-tons09.
                  lv_pre = it_out-wrbtr09 / it_out-tons09.
                  wa_dis-netpr09 = lv_pre.
                ENDIF.
                wa_dis-wrbtr09 = it_out-wrbtr09.
              WHEN '010'.
                IF it_out-tons10 IS NOT INITIAL.
                  wa_dis-tons10 = it_out-tons10.
                  lv_pre = it_out-wrbtr10 / it_out-tons10.
                  wa_dis-netpr10 = lv_pre.
                ENDIF.
                wa_dis-wrbtr10 = it_out-wrbtr10.
              WHEN '011'.
                IF it_out-tons11 IS NOT INITIAL.
                  wa_dis-tons11 = it_out-tons11.
                  lv_pre = it_out-wrbtr11 / it_out-tons11.
                  wa_dis-netpr11 = lv_pre.
                ENDIF.
                wa_dis-wrbtr11 = it_out-wrbtr11.
              WHEN '012'.
                IF it_out-tons12 IS NOT INITIAL.
                  wa_dis-tons12 = it_out-tons12.
                  lv_pre = it_out-wrbtr12 / it_out-tons12.
                  wa_dis-netpr12 = lv_pre.
                ENDIF.
                wa_dis-wrbtr12 = it_out-wrbtr12.
            ENDCASE.
          ENDLOOP.

        ENDLOOP.
* Ventas.
*        IF it_conf-conse <= '06'.
*          wa_dis-segme = 'Ventas'.
*        ENDIF.
        READ TABLE it_cont WITH KEY valor       = wa_dis-segme
                                    descripcion = it_conf-conse.
        IF sy-subrc EQ 0. "it_conf-conse = '04'.
          CLEAR it_diz[].
          LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
            MOVE-CORRESPONDING wa_dit TO it_diz.
            it_diz-matnr = wa_dit-segme.
            it_diz-descr = wa_dit-segme.
            COLLECT it_diz.
          ENDLOOP.
          READ TABLE it_diz INDEX 1.
          IF sy-subrc EQ 0.
            wa_dis-color = 'C510'.
            LOOP AT it_poper.
              CASE it_poper.
                WHEN '001'.
                  wa_dis-tons01 = it_diz-tons01.
                  IF it_diz-tons01 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr01 / it_diz-tons01.
                  ELSE.
                    lv_pre = it_diz-wrbtr01.
                  ENDIF.
                  wa_dis-netpr01 = lv_pre.
                  wa_dis-wrbtr01 = it_diz-wrbtr01.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr01 IS NOT INITIAL  AND wa_dis-wrbtr01 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr01 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr01.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce01.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '002'.
                  wa_dis-tons02 = it_diz-tons02.
                  IF it_diz-tons02 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr02 / it_diz-tons02.
                  ELSE.
                    lv_pre = it_diz-wrbtr02.
                  ENDIF.
                  wa_dis-netpr02 = lv_pre.
                  wa_dis-wrbtr02 = it_diz-wrbtr02.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr02 IS NOT INITIAL  AND wa_dis-wrbtr02 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr02 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr02.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce02.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '003'.
                  wa_dis-tons03 = it_diz-tons03.
                  IF it_diz-tons03 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr03 / it_diz-tons03.
                  ELSE.
                    lv_pre = it_diz-wrbtr03.
                  ENDIF.
                  wa_dis-netpr03 = lv_pre.
                  wa_dis-wrbtr03 = it_diz-wrbtr03.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr03 IS NOT INITIAL  AND wa_dis-wrbtr03 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr03 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr03.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce03.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '004'.
                  wa_dis-tons04 = it_diz-tons04.
                  IF it_diz-tons04 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr04 / it_diz-tons04.
                  ELSE.
                    lv_pre = it_diz-wrbtr04.
                  ENDIF.
                  wa_dis-netpr04 = lv_pre.
                  wa_dis-wrbtr04 = it_diz-wrbtr04.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr04 IS NOT INITIAL AND wa_dis-wrbtr04 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr04 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr04.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce04.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '005'.
                  wa_dis-tons05 = it_diz-tons05.
                  IF it_diz-tons05 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr05 / it_diz-tons05.
                  ELSE.
                    lv_pre = it_diz-wrbtr05.
                  ENDIF.
                  wa_dis-netpr05 = lv_pre.
                  wa_dis-wrbtr05 = it_diz-wrbtr05.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr05 IS NOT INITIAL AND wa_dis-wrbtr05 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr05 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr05.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce05.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '006'.
                  wa_dis-tons06 = it_diz-tons06.
                  IF it_diz-tons06 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr06 / it_diz-tons06.
                  ELSE.
                    lv_pre = it_diz-wrbtr06.
                  ENDIF.
                  wa_dis-netpr06 = lv_pre.
                  wa_dis-wrbtr06 = it_diz-wrbtr06.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr06 IS NOT INITIAL AND wa_dis-wrbtr06 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr06 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr06.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce06.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '007'.
                  wa_dis-tons07 = it_diz-tons07.
                  IF it_diz-tons07 IS NOT INITIAL  AND wa_dis-wrbtr07 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr07 / it_diz-tons07.
                  ELSE.
                    lv_pre = it_diz-wrbtr07.
                  ENDIF.
                  wa_dis-netpr07 = lv_pre.
                  wa_dis-wrbtr07 = it_diz-wrbtr07.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr07 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr07 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr07.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce07.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '008'.
                  wa_dis-tons08 = it_diz-tons08.
                  IF it_diz-tons08 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr08 / it_diz-tons08.
                  ELSE.
                    lv_pre = it_diz-wrbtr08.
                  ENDIF.
                  wa_dis-netpr08 = lv_pre.
                  wa_dis-wrbtr08 = it_diz-wrbtr08.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr08 IS NOT INITIAL  AND wa_dis-wrbtr08 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr08 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr08.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce08.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '009'.
                  wa_dis-tons09 = it_diz-tons09.
                  IF it_diz-tons09 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr09 / it_diz-tons09.
                  ELSE.
                    lv_pre = it_diz-wrbtr09.
                  ENDIF.
                  wa_dis-netpr09 = lv_pre.
                  wa_dis-wrbtr09 = it_diz-wrbtr09.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr09 IS NOT INITIAL  AND wa_dis-wrbtr09 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr09 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr09.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce09.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '010'.
                  wa_dis-tons10 = it_diz-tons10.
                  IF it_diz-tons10 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr10 / it_diz-tons10.
                  ELSE.
                    lv_pre = it_diz-wrbtr10.
                  ENDIF.
                  wa_dis-netpr10 = lv_pre.
                  wa_dis-wrbtr10 = it_diz-wrbtr10.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr10 IS NOT INITIAL  AND wa_dis-wrbtr10 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr10 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr10.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce10.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '011'.
                  wa_dis-tons11 = it_diz-tons11.
                  IF it_diz-tons11 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr11 / it_diz-tons11.
                  ELSE.
                    lv_pre = it_diz-wrbtr11.
                  ENDIF.
                  wa_dis-netpr11 = lv_pre.
                  wa_dis-wrbtr11 = it_diz-wrbtr11.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr11 IS NOT INITIAL  AND wa_dis-wrbtr11 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr11 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr11.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce11.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
                WHEN '012'.
                  wa_dis-tons12 = it_diz-tons12.
                  IF it_diz-tons12 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr12 / it_diz-tons12.
                  ELSE.
                    lv_pre = it_diz-wrbtr12.
                  ENDIF.
                  wa_dis-netpr12 = lv_pre.
                  wa_dis-wrbtr12 = it_diz-wrbtr12.
                  LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
                    IF wa_dit-wrbtr12 IS NOT INITIAL  AND wa_dis-wrbtr12 IS NOT INITIAL.
                      lv_imp1 = wa_dit-wrbtr12 * 100.
                      lv_imp2 = lv_imp1 / wa_dis-wrbtr12.
                      lv_port = lv_imp2.
                      CONDENSE lv_port.
                      CONCATENATE lv_port '%' INTO wa_dit-porce12.
                      MODIFY it_dis FROM wa_dit.
                    ENDIF.
                  ENDLOOP.
              ENDCASE.
            ENDLOOP.
          ENDIF.

        ENDIF.
        READ TABLE it_cont WITH KEY valor       = wa_dis-segme
                                    descripcion = it_conf-conse.
        IF sy-subrc EQ 0. "IF it_conf-conse = '06'.
          CLEAR it_diz[].
          LOOP AT it_dis INTO wa_dit WHERE segme = wa_dis-segme.
            IF wa_dit-descr = 'Total Venta de Azucar'.
              CONTINUE.
            ENDIF.
            MOVE-CORRESPONDING wa_dit TO it_diz.
            it_diz-matnr = wa_dit-segme.
            it_diz-descr = wa_dit-segme.
            COLLECT it_diz.
          ENDLOOP.
          READ TABLE it_diz INDEX 1.
          IF sy-subrc EQ 0.
            wa_dis-color = 'C510'.
            LOOP AT it_poper.
              CASE it_poper.
                WHEN '001'.
                  wa_dis-tons01 = it_diz-tons01.
                  IF it_diz-tons01 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr01 / it_diz-tons01.
                  ELSE.
                    lv_pre = it_diz-wrbtr01.
                  ENDIF.
                  wa_dis-netpr01 = lv_pre.
                  wa_dis-wrbtr01 = it_diz-wrbtr01.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr01 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr01 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr01.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce01.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '002'.
                  wa_dis-tons02 = it_diz-tons02.
                  IF it_diz-tons02 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr02 / it_diz-tons02.
                  ELSE.
                    lv_pre = it_diz-wrbtr02.
                  ENDIF.
                  wa_dis-netpr02 = lv_pre.
                  wa_dis-wrbtr02 = it_diz-wrbtr02.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr02 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr02 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr02.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce02.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '003'.
                  wa_dis-tons03 = it_diz-tons03.
                  IF it_diz-tons03 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr03 / it_diz-tons03.
                  ELSE.
                    lv_pre = it_diz-wrbtr03.
                  ENDIF.
                  wa_dis-netpr03 = lv_pre.
                  wa_dis-wrbtr03 = it_diz-wrbtr03.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr03 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr03 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr03.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce03.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '004'.
                  wa_dis-tons04 = it_diz-tons04.
                  IF it_diz-tons04 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr04 / it_diz-tons04.
                  ELSE.
                    lv_pre = it_diz-wrbtr04.
                  ENDIF.
                  wa_dis-netpr04 = lv_pre.
                  wa_dis-wrbtr04 = it_diz-wrbtr04.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr04 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr04 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr04.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce04.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '005'.
                  wa_dis-tons05 = it_diz-tons05.
                  IF it_diz-tons05 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr05 / it_diz-tons05.
                  ELSE.
                    lv_pre = it_diz-wrbtr05.
                  ENDIF.
                  wa_dis-netpr05 = lv_pre.
                  wa_dis-wrbtr05 = it_diz-wrbtr05.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr05 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr05 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr05.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce05.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '006'.
                  wa_dis-tons06 = it_diz-tons06.
                  IF it_diz-tons06 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr06 / it_diz-tons06.
                  ELSE.
                    lv_pre = it_diz-wrbtr06.
                  ENDIF.
                  wa_dis-netpr06 = lv_pre.
                  wa_dis-wrbtr06 = it_diz-wrbtr06.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr06 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr06 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr06.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce06.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '007'.
                  wa_dis-tons07 = it_diz-tons07.
                  IF it_diz-tons07 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr07 / it_diz-tons07.
                  ELSE.
                    lv_pre = it_diz-wrbtr07.
                  ENDIF.
                  wa_dis-netpr07 = lv_pre.
                  wa_dis-wrbtr07 = it_diz-wrbtr07.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr07 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr07 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr07.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce07.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '008'.
                  wa_dis-tons08 = it_diz-tons08.
                  IF it_diz-tons08 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr08 / it_diz-tons08.
                  ELSE.
                    lv_pre = it_diz-wrbtr08.
                  ENDIF.
                  wa_dis-netpr08 = lv_pre.
                  wa_dis-wrbtr08 = it_diz-wrbtr08.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr08 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr08 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr08.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce08.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '009'.
                  wa_dis-tons09 = it_diz-tons09.
                  IF it_diz-tons09 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr09 / it_diz-tons09.
                  ELSE.
                    lv_pre = it_diz-wrbtr09.
                  ENDIF.
                  wa_dis-netpr09 = lv_pre.
                  wa_dis-wrbtr09 = it_diz-wrbtr09.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr09 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr09 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr09.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce09.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '010'.
                  wa_dis-tons10 = it_diz-tons10.
                  IF it_diz-tons10 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr10 / it_diz-tons10.
                  ELSE.
                    lv_pre = it_diz-wrbtr10.
                  ENDIF.
                  wa_dis-netpr10 = lv_pre.
                  wa_dis-wrbtr10 = it_diz-wrbtr10.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr10 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr10 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr10.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce10.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '011'.
                  wa_dis-tons11 = it_diz-tons11.
                  IF it_diz-tons11 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr11 / it_diz-tons11.
                  ELSE.
                    lv_pre = it_diz-wrbtr11.
                  ENDIF.
                  wa_dis-netpr11 = lv_pre.
                  wa_dis-wrbtr11 = it_diz-wrbtr11.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr11 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr11 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr11.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce11.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '012'.
                  wa_dis-tons12 = it_diz-tons12.
                  IF it_diz-tons12 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr12 / it_diz-tons12.
                  ELSE.
                    lv_pre = it_diz-wrbtr12.
                  ENDIF.
                  wa_dis-netpr12 = lv_pre.
                  wa_dis-wrbtr12 = it_diz-wrbtr12.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr12 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr12 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr12.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce12.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
              ENDCASE.
            ENDLOOP.
          ENDIF.

        ENDIF.
* Inventarios Iniciales
*        IF it_conf-conse >= '07' AND it_conf-conse <= '13'.
*          wa_dis-segme = 'Inv. Inicial'.
*        ENDIF.
        READ TABLE it_cont WITH KEY valor       = wa_dis-segme
                            descripcion = it_conf-conse.
        IF sy-subrc EQ 0. "IF it_conf-conse = '13'.
          CLEAR it_diz[].
          LOOP AT it_dis INTO wa_dit WHERE segme = 'Inventario Inicial'.
            MOVE-CORRESPONDING wa_dit TO it_diz.
            it_diz-matnr = wa_dit-segme.
            it_diz-descr = wa_dit-segme.
            COLLECT it_diz.
          ENDLOOP.
          READ TABLE it_diz INDEX 1.
          IF sy-subrc EQ 0.
            wa_dis-color = 'C510'.
            LOOP AT it_poper.
              CASE it_poper.
                WHEN '001'.
                  wa_dis-tons01 = it_diz-tons01.
                  IF it_diz-tons01 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr01 / it_diz-tons01.
                  ELSE.
                    lv_pre = it_diz-wrbtr01.
                  ENDIF.
                  wa_dis-netpr01 = lv_pre.
                  wa_dis-wrbtr01 = it_diz-wrbtr01.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr01 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr01 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr01.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce01.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '002'.
                  wa_dis-tons02 = it_diz-tons02.
                  IF it_diz-tons02 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr02 / it_diz-tons02.
                  ELSE.
                    lv_pre = it_diz-wrbtr02.
                  ENDIF.
                  wa_dis-netpr02 = lv_pre.
                  wa_dis-wrbtr02 = it_diz-wrbtr02.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr02 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr02 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr02.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce02.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '003'.
                  wa_dis-tons03 = it_diz-tons03.
                  IF it_diz-tons03 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr03 / it_diz-tons03.
                  ELSE.
                    lv_pre = it_diz-wrbtr03.
                  ENDIF.
                  wa_dis-netpr03 = lv_pre.
                  wa_dis-wrbtr03 = it_diz-wrbtr03.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr03 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr03 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr03.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce03.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '004'.
                  wa_dis-tons04 = it_diz-tons04.
                  IF it_diz-tons04 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr04 / it_diz-tons04.
                  ELSE.
                    lv_pre = it_diz-wrbtr04.
                  ENDIF.
                  wa_dis-netpr04 = lv_pre.
                  wa_dis-wrbtr04 = it_diz-wrbtr04.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr04 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr04 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr04.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce04.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '005'.
                  wa_dis-tons05 = it_diz-tons05.
                  IF it_diz-tons05 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr05 / it_diz-tons05.
                  ELSE.
                    lv_pre = it_diz-wrbtr05.
                  ENDIF.
                  wa_dis-netpr05 = lv_pre.
                  wa_dis-wrbtr05 = it_diz-wrbtr05.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr05 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr05 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr05.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce05.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '006'.
                  wa_dis-tons06 = it_diz-tons06.
                  IF it_diz-tons06 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr06 / it_diz-tons06.
                  ELSE.
                    lv_pre = it_diz-wrbtr06.
                  ENDIF.
                  wa_dis-netpr06 = lv_pre.
                  wa_dis-wrbtr06 = it_diz-wrbtr06.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr06 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr06 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr06.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce06.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '007'.
                  wa_dis-tons07 = it_diz-tons07.
                  IF it_diz-tons07 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr07 / it_diz-tons07.
                  ELSE.
                    lv_pre = it_diz-wrbtr07.
                  ENDIF.
                  wa_dis-netpr07 = lv_pre.
                  wa_dis-wrbtr07 = it_diz-wrbtr07.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr07 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr07 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr07.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce07.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '008'.
                  wa_dis-tons08 = it_diz-tons08.
                  IF it_diz-tons08 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr08 / it_diz-tons08.
                  ELSE.
                    lv_pre = it_diz-wrbtr08.
                  ENDIF.
                  wa_dis-netpr08 = lv_pre.
                  wa_dis-wrbtr08 = it_diz-wrbtr08.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr08 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr08 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr08.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce08.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '009'.
                  wa_dis-tons09 = it_diz-tons09.
                  IF it_diz-tons09 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr09 / it_diz-tons09.
                  ELSE.
                    lv_pre = it_diz-wrbtr09.
                  ENDIF.
                  wa_dis-netpr09 = lv_pre.
                  wa_dis-wrbtr09 = it_diz-wrbtr09.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr09 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr09 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr09.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce09.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '010'.
                  wa_dis-tons10 = it_diz-tons10.
                  IF it_diz-tons10 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr10 / it_diz-tons10.
                  ELSE.
                    lv_pre = it_diz-wrbtr10.
                  ENDIF.
                  wa_dis-netpr10 = lv_pre.
                  wa_dis-wrbtr10 = it_diz-wrbtr10.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr10 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr10 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr10.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce10.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '011'.
                  wa_dis-tons11 = it_diz-tons11.
                  IF it_diz-tons11 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr11 / it_diz-tons11.
                  ELSE.
                    lv_pre = it_diz-wrbtr11.
                  ENDIF.
                  wa_dis-netpr11 = lv_pre.
                  wa_dis-wrbtr11 = it_diz-wrbtr11.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr11 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr11 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr11.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce11.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
                WHEN '012'.
                  wa_dis-tons12 = it_diz-tons12.
                  IF it_diz-tons12 IS NOT INITIAL.
                    lv_pre = it_diz-wrbtr12 / it_diz-tons12.
                  ELSE.
                    lv_pre = it_diz-wrbtr12.
                  ENDIF.
                  wa_dis-netpr12 = lv_pre.
                  wa_dis-wrbtr12 = it_diz-wrbtr12.
*                  LOOP AT it_dis INTO wa_dit WHERE segme = 'Ventas'.
*                    IF wa_dit-wrbtr12 IS NOT INITIAL.
*                      lv_imp1 = wa_dit-wrbtr12 * 100.
*                      lv_imp2 = lv_imp1 / wa_dis-wrbtr12.
*                      lv_port = lv_imp2.
*                      CONDENSE lv_port.
*                      CONCATENATE lv_port '%' INTO wa_dit-porce12.
*                      MODIFY it_dis FROM wa_dit.
*                    ENDIF.
*                  ENDLOOP.
              ENDCASE.
            ENDLOOP.
          ENDIF.
        ENDIF.

        IF it_conf-descripcion = 'Sumas'.

          READ TABLE it_cons WITH KEY id    = '12'
                                      valor = it_conf-valor.
          IF sy-subrc EQ 0. "Sumas.
            CLEAR it_diz[].
            TYPES: BEGIN OF ty_sum,
                     linea TYPE n LENGTH 3,
                     signo TYPE c LENGTH 1,
                   END OF ty_sum.
            TYPES: BEGIN OF ty_text,
                     linea TYPE c LENGTH 10,
                   END OF ty_text.
            DATA: it_suma TYPE STANDARD TABLE OF ty_sum WITH HEADER LINE,
                  it_text TYPE STANDARD TABLE OF ty_text WITH HEADER LINE.
            CLEAR: it_suma[], it_text[].
            SPLIT it_cons-descripcion AT '|' INTO TABLE it_text.
            LOOP AT it_text.
              SPLIT it_text-linea AT ',' INTO it_suma-linea it_suma-signo.
              APPEND it_suma.
            ENDLOOP.
            LOOP AT it_suma.
              READ TABLE it_dis INTO wa_dit INDEX it_suma-linea.
              IF sy-subrc EQ 0.
                MOVE-CORRESPONDING wa_dit TO it_diz.
                it_diz-matnr = 'Suma'.
                it_diz-descr = 'Suma'.
                IF it_suma-signo = '-'.
                  it_diz-wrbtr01 = it_diz-wrbtr01 * -1.
                  it_diz-wrbtr02 = it_diz-wrbtr02 * -1.
                  it_diz-wrbtr03 = it_diz-wrbtr03 * -1.
                  it_diz-wrbtr04 = it_diz-wrbtr04 * -1.
                  it_diz-wrbtr05 = it_diz-wrbtr05 * -1.
                  it_diz-wrbtr06 = it_diz-wrbtr06 * -1.
                  it_diz-wrbtr07 = it_diz-wrbtr07 * -1.
                  it_diz-wrbtr08 = it_diz-wrbtr08 * -1.
                  it_diz-wrbtr09 = it_diz-wrbtr09 * -1.
                  it_diz-wrbtr10 = it_diz-wrbtr10 * -1.
                  it_diz-wrbtr11 = it_diz-wrbtr11 * -1.
                  it_diz-wrbtr12 = it_diz-wrbtr12 * -1.
                ENDIF.
                COLLECT it_diz.
              ENDIF.
            ENDLOOP.

            READ TABLE it_diz INDEX 1.
            IF sy-subrc EQ 0.
              wa_dis-color = 'C510'.
              LOOP AT it_poper.
                CASE it_poper.
                  WHEN '001'.
                    wa_dis-wrbtr01 = it_diz-wrbtr01.
                  WHEN '002'.
                    wa_dis-wrbtr02 = it_diz-wrbtr02.
                  WHEN '003'.
                    wa_dis-wrbtr03 = it_diz-wrbtr03.
                  WHEN '004'.
                    wa_dis-wrbtr04 = it_diz-wrbtr04.
                  WHEN '005'.
                    wa_dis-wrbtr05 = it_diz-wrbtr05.
                  WHEN '006'.
                    wa_dis-wrbtr06 = it_diz-wrbtr06.
                  WHEN '007'.
                    wa_dis-wrbtr07 = it_diz-wrbtr07.
                  WHEN '008'.
                    wa_dis-wrbtr08 = it_diz-wrbtr08.
                  WHEN '009'.
                    wa_dis-wrbtr09 = it_diz-wrbtr09.
                  WHEN '010'.
                    wa_dis-wrbtr10 = it_diz-wrbtr10.
                  WHEN '011'.
                    wa_dis-wrbtr11 = it_diz-wrbtr11.
                  WHEN '012'.
                    wa_dis-wrbtr12 = it_diz-wrbtr12.
                ENDCASE.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
* Compras
*        IF it_conf-conse = '14'.
*          wa_dis-segme = 'Compras'.
*        ENDIF.
* Costos prod
*        IF it_conf-conse >= '15' AND it_conf-conse <= '38'.
*          wa_dis-segme = 'Costo Prod.'.
*        ENDIF.
* Inv Final
*        IF it_conf-conse >= '39' AND it_conf-conse <= '46'.
*          wa_dis-segme = 'Inv. Final'.
*        ENDIF.
        wa_dis-descr = it_conf-valor.
        APPEND wa_dis TO it_dis.
      ENDLOOP.
* Anual
      CLEAR lv_linc.
      LOOP AT it_dis INTO wa_dis.
        ADD 1 TO lv_linc.
        IF wa_dis-segme = 'Inventario Inicial' OR wa_dis-descr = 'Suma de Inventarios Iniciales P.T.'.
          wa_dis-tons13  = wa_dis-tons01.
          wa_dis-netpr13 = wa_dis-netpr01.
          wa_dis-wrbtr13 = wa_dis-wrbtr01.
        ELSEIF wa_dis-segme = 'Inventario Final' OR wa_dis-descr = 'INVENTARIOS FINALES P.T.'.
          CLEAR lv_lin.
          DESCRIBE TABLE it_poper LINES lv_lin.
          READ TABLE it_poper INDEX lv_lin.
          CASE it_poper.
            WHEN '001'.
              wa_dis-tons13  = wa_dis-tons01.
              wa_dis-netpr13 = wa_dis-netpr01.
              wa_dis-wrbtr13 = wa_dis-wrbtr01.
            WHEN '002'.
              wa_dis-tons13  = wa_dis-tons02.
              wa_dis-netpr13 = wa_dis-netpr02.
              wa_dis-wrbtr13 = wa_dis-wrbtr02.
            WHEN '003'.
              wa_dis-tons13  = wa_dis-tons03.
              wa_dis-netpr13 = wa_dis-netpr03.
              wa_dis-wrbtr13 = wa_dis-wrbtr03.
            WHEN '004'.
              wa_dis-tons13  = wa_dis-tons04.
              wa_dis-netpr13 = wa_dis-netpr04.
              wa_dis-wrbtr13 = wa_dis-wrbtr04.
            WHEN '005'.
              wa_dis-tons13  = wa_dis-tons05.
              wa_dis-netpr13 = wa_dis-netpr05.
              wa_dis-wrbtr13 = wa_dis-wrbtr05.
            WHEN '006'.
              wa_dis-tons13  = wa_dis-tons06.
              wa_dis-netpr13 = wa_dis-netpr06.
              wa_dis-wrbtr13 = wa_dis-wrbtr06.
            WHEN '007'.
              wa_dis-tons13  = wa_dis-tons07.
              wa_dis-netpr13 = wa_dis-netpr07.
              wa_dis-wrbtr13 = wa_dis-wrbtr07.
            WHEN '008'.
              wa_dis-tons13  = wa_dis-tons08.
              wa_dis-netpr13 = wa_dis-netpr08.
              wa_dis-wrbtr13 = wa_dis-wrbtr08.
            WHEN '009'.
              wa_dis-tons13  = wa_dis-tons09.
              wa_dis-netpr13 = wa_dis-netpr09.
              wa_dis-wrbtr13 = wa_dis-wrbtr09.
            WHEN '010'.
              wa_dis-tons13  = wa_dis-tons10.
              wa_dis-netpr13 = wa_dis-netpr10.
              wa_dis-wrbtr13 = wa_dis-wrbtr10.
            WHEN '011'.
              wa_dis-tons13  = wa_dis-tons11.
              wa_dis-netpr13 = wa_dis-netpr11.
              wa_dis-wrbtr13 = wa_dis-wrbtr11.
            WHEN '012'.
              wa_dis-tons13  = wa_dis-tons12.
              wa_dis-netpr13 = wa_dis-netpr12.
              wa_dis-wrbtr13 = wa_dis-wrbtr12.
          ENDCASE.
        ELSE.
          wa_dis-tons13  = wa_dis-tons01  + wa_dis-tons02  + wa_dis-tons03  + wa_dis-tons04  +  wa_dis-tons05  +  wa_dis-tons06.
          wa_dis-netpr13 = wa_dis-netpr01 + wa_dis-netpr02 + wa_dis-netpr03 + wa_dis-netpr04 +  wa_dis-netpr05 +  wa_dis-netpr06.
          wa_dis-wrbtr13 = wa_dis-wrbtr01 + wa_dis-wrbtr02 + wa_dis-wrbtr03 + wa_dis-wrbtr04 +  wa_dis-wrbtr05 +  wa_dis-wrbtr06.
*        wa_dis-porce13 = wa_dis-porce01 + wa_dis-porce02 + wa_dis-porce03 + wa_dis-porce04 +  wa_dis-porce05 +  wa_dis-porce06.

          wa_dis-tons13  = wa_dis-tons07  + wa_dis-tons08  + wa_dis-tons09  + wa_dis-tons10  +  wa_dis-tons11  +  wa_dis-tons12  + wa_dis-tons13.
          wa_dis-netpr13 = wa_dis-netpr07 + wa_dis-netpr08 + wa_dis-netpr09 + wa_dis-netpr10 +  wa_dis-netpr11 +  wa_dis-netpr12 + wa_dis-netpr13.
          wa_dis-wrbtr13 = wa_dis-wrbtr07 + wa_dis-wrbtr08 + wa_dis-wrbtr09 + wa_dis-wrbtr10 +  wa_dis-wrbtr11 +  wa_dis-wrbtr12 + wa_dis-wrbtr13.
*        wa_dis-porce13 = wa_dis-porce07 + wa_dis-porce08 + wa_dis-porce09 + wa_dis-porce10 +  wa_dis-porce11 +  wa_dis-porce12.
        ENDIF.
        MODIFY it_dis FROM wa_dis INDEX lv_linc.
      ENDLOOP.

      IF it_dis[] IS NOT INITIAL.
        CALL SCREEN 100.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE 'No se encontraron registros' TYPE 'I'.
  ENDIF.

END-OF-SELECTION.

  INCLUDE zfi_rep_costos_prod_pbo_ga03.
*  INCLUDE zfi_rep_costos_prod_pbo.

  INCLUDE zfi_rep_costos_prod_form_ga03.
*  INCLUDE zfi_rep_costos_prod_form.

  INCLUDE zfi_rep_costos_prod_pai_ga03.
*  INCLUDE zfi_rep_costos_prod_pai.
