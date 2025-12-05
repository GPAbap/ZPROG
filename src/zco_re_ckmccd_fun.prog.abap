*&---------------------------------------------------------------------*
*& Include          ZCO_RE_CKMCCD_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_ckml
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_werks changing p_rg_werks.
Data: rg_werks type RANGE OF t001w-werks,
      wrg_werks like line of rg_werks.

    if so_werks-high is initial.
      loop at so_werks.
        wrg_werks-low = so_werks-low.
       append wrg_werks to rg_werks.
      endloop.

    else.
        select werks
          into table @DATA(it_werks)
          from t001w
          where werks in @so_werks.

       if it_werks is not initial.
          loop at it_werks into data(wa_werks).
            wrg_werks-low = wa_werks-werks.
            append wrg_werks to rg_werks.
          endloop.
       endif.
    endif.
p_rg_werks = rg_werks.
ENDFORM.


FORM get_data_ckml USING p_werks TYPE werks_d .

  CLEAR: gs_wwo,ls_marv.

  CALL FUNCTION 'CKML_F_SET_PLANT'
    EXPORTING
      plant           = p_werks
    EXCEPTIONS
      plant_not_found = 01
      internal_error  = 02.

  CALL FUNCTION 'CKML_F_GET_WWO'
    IMPORTING
      wwo = gs_wwo.


  PERFORM get_marv USING gs_wwo-bukrs.
  PERFORM get_t001 USING p_werks.
  PERFORM get_kalnr USING p_werks.
  PERFORM get_waers USING p_werks.
  PERFORM get_mlccs.
  PERFORM get_mlcd.
  PERFORM get_keph.
  PERFORM get_tckh4.
  "


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_marv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SO_WERKS_LOW
*&---------------------------------------------------------------------*
FORM get_marv  USING    p_bukrs TYPE bukrs.
  CALL FUNCTION 'MARV_SINGLE_READ'
    EXPORTING
      bukrs      = p_bukrs
    IMPORTING
      wmarv      = ls_marv
    EXCEPTIONS
      not_found  = 1
      wrong_call = 2
      OTHERS     = 3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_t001
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SO_WERKS_LOW
*&---------------------------------------------------------------------*
FORM get_t001  USING    p_werks TYPE werks_d.
  CALL FUNCTION 'T001W_SINGLE_READ'
    EXPORTING
      t001w_werks = p_werks
    IMPORTING
      wt001w      = ls_t001w
    EXCEPTIONS
      not_found   = 1
      OTHERS      = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_kalnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_kalnr USING p_bwkey TYPE bwkey.
  DATA lv_kalnr TYPE ck_kalnr .
  CLEAR ls_kalnr.
  refresh lt_kalnr.
  SELECT SINGLE kalnr FROM ckmlhd INTO lv_kalnr
                            WHERE matnr = p_matnr
                            AND   bwkey = p_bwkey
                            AND   bwtar = space
                            AND   sobkz = space
                            AND   vbeln = space
                            AND   posnr = '000000'
                            AND   pspnr = '00000000'.

  IF sy-subrc EQ 0.

    ls_kalnr-kalnr = lv_kalnr.
    ls_kalnr-bwkey = p_bwkey.
    APPEND ls_kalnr TO lt_kalnr.

    mlccskey-kalnr = lv_kalnr.
    mlccskey-bdatj = p_gjahr.
    mlccskey-poper = p_poper.
    mlccskey-untper = '000'.
    mlccskey-categ = 'ZU'.
    mlccskey-ptyp = 'BF'.
    mlccskey-keart = 'H'.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mlccs
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mlccs .
REFRESH lt_keph_mlcd.


  PERFORM ccs_set_keph_ranges USING mlccskey
                                CHANGING lr_keart lr_mlcct lr_kkzst.

  CALL FUNCTION 'MLCCS_KEPH_MLCD_READ'
    EXPORTING
      i_refresh_buffer = space
      it_kalnr         = lt_kalnr
      i_from_bdatj     = p_gjahr
      i_from_poper     = p_poper
      i_runid          = '000000000000'
      ir_keart         = lr_keart
      ir_mlcct         = lr_mlcct
      ir_kkzst         = lr_kkzst
      i_condense_cons  = 'X'
    IMPORTING
      et_keph_mlcd     = lt_keph_mlcd
    EXCEPTIONS
      error_message    = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ccs_set_keph_ranges
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> MLCCSKEY
*&      <-- LR_KEART
*&      <-- LR_MLCCT
*&      <-- LR_KKZST
*&---------------------------------------------------------------------*
FORM ccs_set_keph_ranges USING is_mlccskey TYPE mlccskey
                         CHANGING er_keart TYPE ckmv0_yt_keart
                                  er_mlcct TYPE ckmv0_yt_mlcct
                                  er_kkzst TYPE ckmv0_yt_kkzst.

  DATA: ls_keart TYPE LINE OF ckmv0_yt_keart,
        ls_mlcct TYPE LINE OF ckmv0_yt_mlcct,
        ls_kkzst TYPE LINE OF ckmv0_yt_kkzst.

  CLEAR: er_keart, er_mlcct, er_kkzst.


* Dado que los cambios en la etapa/pre-escenario también se ajustan al valor general
* (etapa + pre-etapa) requerido, siempre debemos todo
* ¡leer!

  ls_kkzst-sign   = 'I'.
  ls_kkzst-option = 'EQ'.
  ls_kkzst-low = ' '.
  APPEND ls_kkzst TO er_kkzst.
  ls_kkzst-low = 'X'.
  APPEND ls_kkzst TO er_kkzst.

  ls_mlcct-sign   = 'I'.
  ls_mlcct-option = 'EQ'.
  CASE is_mlccskey-mlcct.
    WHEN ' ' OR 'V' OR 'E' OR 'F' OR 'M' OR 'N'.
      ls_mlcct-low = is_mlccskey-mlcct.
      APPEND ls_mlcct TO er_mlcct.
    WHEN 'D'.
      ls_mlcct-low = 'F'. APPEND ls_mlcct TO er_mlcct.
      ls_mlcct-low = 'N'. APPEND ls_mlcct TO er_mlcct.
      ls_mlcct-low = 'E'. APPEND ls_mlcct TO er_mlcct.
      ls_mlcct-low = 'M'. APPEND ls_mlcct TO er_mlcct.
    WHEN 'P'.
      ls_mlcct-low = 'E'. APPEND ls_mlcct TO er_mlcct.
      ls_mlcct-low = 'M'. APPEND ls_mlcct TO er_mlcct.
    WHEN 'K'.
      ls_mlcct-low = 'F'. APPEND ls_mlcct TO er_mlcct.
      ls_mlcct-low = 'N'. APPEND ls_mlcct TO er_mlcct.
    WHEN 'G'.
      ls_mlcct-low = 'E'. APPEND ls_mlcct TO er_mlcct.
      ls_mlcct-low = 'F'. APPEND ls_mlcct TO er_mlcct.
    WHEN 'O'.
      ls_mlcct-low = 'M'. APPEND ls_mlcct TO er_mlcct.
      ls_mlcct-low = 'N'. APPEND ls_mlcct TO er_mlcct.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_tckh4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_tckh4 .



  REFRESH: mt_tckh3, mt_tckh1.
  l_elehk = 'Z1'.


  ls_tckh8-besbw = 'X'.
  ls_tckh8-sicht = '00'.

  CALL FUNCTION 'CK_F_TCKH4_HIERARCHY_READING'
    EXPORTING
      p_elehk          = l_elehk
      f_tckh8_standard = ls_tckh8
    TABLES
      t_tckh3          = mt_tckh3
      t_tckh1          = mt_tckh1.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .
  DATA: l_index TYPE sy-tabix,
        l_subrc TYPE sy-subrc.

  FIELD-SYMBOLS: <l_kst>     TYPE mlccs_d_kstel,
                 <l_kst_vor> TYPE mlccs_d_kstel,
                 <l_kst_fix> TYPE mlccs_d_kstel.

  LOOP AT mt_tckh3 INTO ls_tckh3.
    CLEAR: ls_ckml.
    ls_ckml-element = ls_tckh3-elemt.
    READ TABLE mt_tckh1 INTO DATA(ls_tckh1) WITH KEY elemt = ls_tckh3-elemt
                                               spras = sy-langu.
    IF sy-subrc = 0.
      ls_ckml-txele = ls_tckh1-txele.
      ls_ckml-werks = ls_t001w-werks.
      ls_ckml-name1 = ls_t001w-name1.
    ELSE.
      CLEAR: ls_ckml-txele.
    ENDIF.

    LOOP AT mt_curtp INTO DATA(ls_curtp).

      l_index = sy-tabix.

      IF mlccskey-kalnr IS INITIAL.
        READ TABLE gt_ckmlkeph INTO DATA(ls_ckmlkeph)
                               WITH KEY keart = mlccskey-keart
                                        mlcct = mlccskey-mlcct
                                        kkzst = mlccskey-kkzst
                                        curtp = ls_curtp-curtp.
        l_subrc = sy-subrc.
      ELSE.
        IF mlccskey-kkzst = 'S'.
*         Bei "Stufe" müssen wir Gesamt - Vorstufe rechnen!
          READ TABLE gt_ckmlkeph INTO ls_ckmlkeph
                                 WITH KEY kalnr = mlccskey-kalnr
                                          bdatj = mlccskey-bdatj
                                          poper = mlccskey-poper
                                         untper = mlccskey-untper
                                          categ = mlccskey-categ
                                          ptyp  = mlccskey-ptyp
                                          bvalt = mlccskey-bvalt
                                          keart = mlccskey-keart
                                          mlcct = mlccskey-mlcct
                                            kkzst = ' '
                                            curtp = ls_curtp-curtp.
          l_subrc = sy-subrc.
          READ TABLE gt_ckmlkeph INTO DATA(ls_ckmlkeph_vorstufe)
                                 WITH KEY kalnr = mlccskey-kalnr
                                          bdatj = mlccskey-bdatj
                                          poper = mlccskey-poper
                                         untper = mlccskey-untper
                                          categ = mlccskey-categ
                                          ptyp  = mlccskey-ptyp
                                          bvalt = mlccskey-bvalt
                                          keart = mlccskey-keart
                                          mlcct = mlccskey-mlcct
                                          kkzst = 'X'
                                          curtp = ls_curtp-curtp.
          IF sy-subrc <> 0.
            CLEAR: ls_ckmlkeph_vorstufe.
          ENDIF.
        ELSE.
          READ TABLE gt_ckmlkeph INTO ls_ckmlkeph
                                 WITH KEY kalnr = mlccskey-kalnr
                                          bdatj = mlccskey-bdatj
                                          poper = mlccskey-poper
                                         untper = mlccskey-untper
                                          categ = mlccskey-categ
                                          ptyp  = mlccskey-ptyp
                                          bvalt = mlccskey-bvalt
                                          keart = mlccskey-keart
                                          mlcct = mlccskey-mlcct
                                          kkzst = mlccskey-kkzst
                                          curtp = ls_curtp-curtp.
          l_subrc = sy-subrc.
        ENDIF.
      ENDIF.
      IF l_subrc = 0.
        MOVE ls_tckh3-el_hv TO ls_name-number.
        ASSIGN COMPONENT ls_name OF STRUCTURE ls_ckmlkeph TO <l_kst>.
        IF mlccskey-kkzst = 'S'.
          ASSIGN COMPONENT ls_name OF STRUCTURE ls_ckmlkeph_vorstufe TO <l_kst_vor>.
          IF sy-subrc = 0 AND <l_kst> IS ASSIGNED.
            SUBTRACT <l_kst_vor> FROM <l_kst>.
          ENDIF.
        ENDIF.
        MOVE ls_tckh3-el_hf TO ls_name-number.
        ASSIGN COMPONENT ls_name OF STRUCTURE ls_ckmlkeph TO <l_kst_fix>.
        IF mlccskey-kkzst = 'S'.
          ASSIGN COMPONENT ls_name OF STRUCTURE ls_ckmlkeph_vorstufe TO <l_kst_vor>.
          IF sy-subrc = 0 AND <l_kst_fix> IS ASSIGNED.
            SUBTRACT <l_kst_vor> FROM <l_kst_fix>.
          ENDIF.
        ENDIF.
        CASE l_index.
*         1. Währung
          WHEN '1'.
            IF <l_kst> IS ASSIGNED.
              ls_ckml-gesamt1 = <l_kst>.
            ELSE.
              CLEAR: ls_ckml-gesamt1.
            ENDIF.
            IF <l_kst_fix> IS ASSIGNED.
              ls_ckml-fix1 = <l_kst_fix>.
*              IF sy-tcode NE 'CKMCCE'.
*                ls_celltab-fieldname = 'FIX1'.
*                ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
*                MODIFY TABLE lt_celltab FROM ls_celltab.
*              ENDIF.
            ELSE.
              CLEAR: ls_ckml-fix1.
*              ls_celltab-fieldname = 'FIX1'.
*              ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*              MODIFY TABLE lt_celltab FROM ls_celltab.
            ENDIF.
            ls_ckml-variabel1 = ls_ckml-gesamt1 - ls_ckml-fix1.
            IF ls_tckh3-besbw = 'V'.
              CLEAR: ls_ckml-fix1.
              ls_ckml-gesamt1 = ls_ckml-variabel1.
            ENDIF.
            ls_ckml-waers1 = ls_ckmlkeph-waers.

            IF sy-tcode EQ 'CKMCCE' AND ls_tckh3-besbw IS INITIAL.
*              ls_celltab-fieldname = 'VARIABEL1'.
*              ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
*              MODIFY TABLE lt_celltab FROM ls_celltab.
              IF NOT ls_tckh3-el_hf IS INITIAL.
*                ls_celltab-fieldname = 'FIX1'.
*                ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
*                MODIFY TABLE lt_celltab FROM ls_celltab.
              ENDIF.
            ENDIF.

*         2. Währung
          WHEN '2'.
            IF <l_kst> IS ASSIGNED.
              ls_ckml-gesamt2 = <l_kst>.
            ELSE.
              CLEAR: ls_ckml-gesamt2.
            ENDIF.
            IF <l_kst_fix> IS ASSIGNED.
              ls_ckml-fix2 = <l_kst_fix>.
              IF sy-tcode NE 'CKMCCE'.
*                ls_celltab-fieldname = 'FIX2'.
*                ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
*                MODIFY TABLE lt_celltab FROM ls_celltab.
              ENDIF.
            ELSE.
              CLEAR: ls_ckml-fix2.
*              ls_celltab-fieldname = 'FIX2'.
*              ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*              MODIFY TABLE lt_celltab FROM ls_celltab.
            ENDIF.
            ls_ckml-variabel2 = ls_ckml-gesamt2 - ls_ckml-fix2.
            IF ls_tckh3-besbw = 'V'.
              CLEAR: ls_ckml-fix2.
              ls_ckml-gesamt2 = ls_ckml-variabel2.
            ENDIF.
            ls_ckml-waers2 = ls_ckmlkeph-waers.

*         3. Währung
          WHEN '3'.
            IF <l_kst> IS ASSIGNED.
              ls_ckml-gesamt3 = <l_kst>.
            ELSE.
              CLEAR: ls_ckml-gesamt3.
            ENDIF.
            IF <l_kst_fix> IS ASSIGNED.
              ls_ckml-fix3 = <l_kst_fix>.
              IF sy-tcode NE 'CKMCCE'.
*                ls_celltab-fieldname = 'FIX3'.
*                ls_ckml-style = cl_gui_alv_grid=>mc_style_enabled.
*                MODIFY TABLE lt_celltab FROM ls_celltab.
              ENDIF.
            ELSE.
              CLEAR: ls_ckml-fix3.
*              ls_celltab-fieldname = 'FIX3'.
*              ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*              MODIFY TABLE lt_celltab FROM ls_celltab.
            ENDIF.
            ls_ckml-variabel3 = ls_ckml-gesamt3 -
                                     ls_ckml-fix3.
            IF ls_tckh3-besbw = 'V'.
              CLEAR: ls_ckml-fix3.
              ls_ckml-gesamt3 = ls_ckml-variabel3.
            ENDIF.
            ls_ckml-waers3 = ls_ckmlkeph-waers.

        ENDCASE.

      ELSE.

        CASE l_index.
*         1. Währung
          WHEN '1'.
            CLEAR: ls_ckml-gesamt1,
                   ls_ckml-fix1,
                   ls_ckml-variabel1.
            ls_ckml-waers1 = ls_curtp-waers.
*         2. Währung
          WHEN '2'.
            CLEAR: ls_ckml-gesamt2,
                   ls_ckml-fix2,
                   ls_ckml-variabel2.
            ls_ckml-waers2 = ls_curtp-waers.
*         3. Währung
          WHEN '3'.
            CLEAR: ls_ckml-gesamt3,
                   ls_ckml-fix3,
                   ls_ckml-variabel3.
            ls_ckml-waers3 = ls_curtp-waers.
        ENDCASE.
      ENDIF.
      UNASSIGN: <l_kst>, <l_kst_vor>, <l_kst_fix>.
    ENDLOOP.

*   Summe bilden für Delta-Zeile
    ls_grid_data_sum-gesamt1 = ls_grid_data_sum-gesamt1 +
                               ls_ckml-gesamt1.
    ls_grid_data_sum-fix1 = ls_grid_data_sum-fix1 + ls_ckml-fix1.
    ls_grid_data_sum-variabel1 = ls_grid_data_sum-variabel1 +
                                 ls_ckml-variabel1.
    ls_grid_data_sum-waers1 = ls_ckml-waers1.
    ls_grid_data_sum-gesamt2 = ls_grid_data_sum-gesamt2 +
                               ls_ckml-gesamt2.
    ls_grid_data_sum-fix2 = ls_grid_data_sum-fix2 + ls_ckml-fix2.
    ls_grid_data_sum-variabel2 = ls_grid_data_sum-variabel2 +
                                 ls_ckml-variabel2.
    ls_grid_data_sum-waers2 = ls_ckml-waers2.
    ls_grid_data_sum-gesamt3 = ls_grid_data_sum-gesamt3 +
                               ls_ckml-gesamt3.
    ls_grid_data_sum-fix3 = ls_grid_data_sum-fix3 + ls_ckml-fix3.
    ls_grid_data_sum-variabel3 = ls_grid_data_sum-variabel3 +
                                 ls_ckml-variabel3.
    ls_grid_data_sum-waers3 = ls_ckml-waers3.
*    INSERT LINES OF lt_celltab INTO TABLE ls_ckml-celltab.
    APPEND ls_ckml TO it_ckml.
  ENDLOOP.
*
  delete it_ckml where gesamt1 eq 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_waers
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SO_WERKS_LOW
*&---------------------------------------------------------------------*
FORM get_waers  USING  p_bwkey TYPE bwkey.

REFRESH mt_curtp.

  CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
    EXPORTING
      bwkey               = p_bwkey
      i_run_id            = '000000000000'
    TABLES
      t_curtp_for_va      = mt_curtp
    EXCEPTIONS
      bwkey_not_found     = 1
      bwkey_not_active    = 2
      matled_not_found    = 3
      internal_error      = 4
      more_than_3_curtp   = 5
      customizing_changed = 6
      OTHERS              = 7.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_keph
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_keph .



  DATA:
    ht_keph_mlcd      TYPE ccs01_t_keph_mlcd,
    lt_ckmlkeph_ptyp  TYPE ckmlkeph OCCURS 0,
    lt_ckmlkeph_categ TYPE ckmlkeph OCCURS 0,
    lt_ckmlkeph_kb    TYPE ckmlkeph OCCURS 0,
    lt_ckmlkeph_d     TYPE ckmlkeph OCCURS 0,
    lt_ckmlkeph_p     TYPE ckmlkeph OCCURS 0,
    lt_ckmlkeph_k     TYPE ckmlkeph OCCURS 0,
    lt_ckmlkeph_g     TYPE ckmlkeph OCCURS 0,
    lt_ckmlkeph_o     TYPE ckmlkeph OCCURS 0,
    lr_keart          TYPE ckmv0_yt_keart,
    lr_mlcct          TYPE ckmv0_yt_mlcct,
    lr_kkzst          TYPE ckmv0_yt_kkzst,
    ls_keart          LIKE LINE OF lr_keart,
    ls_mlcct          LIKE LINE OF lr_mlcct,
    ls_kkzst          LIKE LINE OF lr_kkzst,
    ls_keph_mlcd      TYPE ccs01_keph_mlcd,
    ls_ckmlkeph       TYPE ckmlkeph,
    ls_ckmlkeph_ca    TYPE ckmlkeph,
    ls_vektor         TYPE mlccs_s_cost_components.



  REFRESH: gt_ckmlkeph, lt_ckmlkeph_ptyp, lt_ckmlkeph_categ,
           lt_ckmlkeph_kb, lt_ckmlkeph_d, lt_ckmlkeph_p, lt_ckmlkeph_k,
           lt_ckmlkeph_g, lt_ckmlkeph_o.

  LOOP AT lt_keph_mlcd INTO ls_keph_mlcd.
    IF ls_keph_mlcd-categ = 'AB' AND
       ( ls_keph_mlcd-objtyp = 'PO' OR ls_keph_mlcd-objtyp = 'PC' ).
      CONTINUE.
    ENDIF.

    CLEAR: ls_ckmlkeph, ls_ckmlkeph_ca.

    MOVE-CORRESPONDING ls_keph_mlcd TO ls_ckmlkeph.
    INSERT ls_ckmlkeph INTO TABLE gt_ckmlkeph.
*   Zeilen für zusätzliche MLCCT erzeugen
    CASE ls_ckmlkeph-mlcct.
      WHEN 'E'.
        ls_ckmlkeph-mlcct = 'D'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_d.
        ls_ckmlkeph-mlcct = 'P'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_p.
        ls_ckmlkeph-mlcct = 'G'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_g.
      WHEN 'F'.
        ls_ckmlkeph-mlcct = 'D'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_d.
        ls_ckmlkeph-mlcct = 'K'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_k.
        ls_ckmlkeph-mlcct = 'G'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_g.
      WHEN 'M'.
        ls_ckmlkeph-mlcct = 'D'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_d.
        ls_ckmlkeph-mlcct = 'P'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_p.
        ls_ckmlkeph-mlcct = 'O'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_o.
      WHEN 'N'.
        ls_ckmlkeph-mlcct = 'D'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_d.
        ls_ckmlkeph-mlcct = 'K'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_k.
        ls_ckmlkeph-mlcct = 'O'.
        COLLECT ls_ckmlkeph INTO lt_ckmlkeph_o.
    ENDCASE.

    MOVE-CORRESPONDING ls_keph_mlcd TO ls_ckmlkeph.

*   Prozesstyp-Zeilen erzeugen
    IF ls_keph_mlcd-objtyp = 'BV' AND
       NOT ls_ckmlkeph-bvalt IS INITIAL.
      CLEAR: ls_ckmlkeph-bvalt.
      COLLECT ls_ckmlkeph INTO lt_ckmlkeph_ptyp.
*     Nochmal: Zeilen für zusätzliche MLCCT erzeugen
      CASE ls_ckmlkeph-mlcct.
        WHEN 'E'.
          ls_ckmlkeph-mlcct = 'D'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_d.
          ls_ckmlkeph-mlcct = 'P'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_p.
          ls_ckmlkeph-mlcct = 'G'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_g.
        WHEN 'F'.
          ls_ckmlkeph-mlcct = 'D'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_d.
          ls_ckmlkeph-mlcct = 'K'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_k.
          ls_ckmlkeph-mlcct = 'G'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_g.
        WHEN 'M'.
          ls_ckmlkeph-mlcct = 'D'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_d.
          ls_ckmlkeph-mlcct = 'P'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_p.
          ls_ckmlkeph-mlcct = 'O'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_o.
        WHEN 'N'.
          ls_ckmlkeph-mlcct = 'D'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_d.
          ls_ckmlkeph-mlcct = 'K'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_k.
          ls_ckmlkeph-mlcct = 'O'.
          COLLECT ls_ckmlkeph INTO lt_ckmlkeph_o.
      ENDCASE.
    ENDIF.
*   Kategorie-Zeilen erzeugen
    IF ls_keph_mlcd-objtyp = 'CA'.
      MOVE-CORRESPONDING ls_keph_mlcd TO ls_ckmlkeph_ca.
***      COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
*     Nochmal: Zeilen für zusätzliche MLCCT erzeugen
      CASE ls_ckmlkeph_ca-mlcct.
        WHEN 'E'.
          ls_ckmlkeph_ca-mlcct = 'D'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
          ls_ckmlkeph_ca-mlcct = 'P'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
          ls_ckmlkeph_ca-mlcct = 'G'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
        WHEN 'F'.
          ls_ckmlkeph_ca-mlcct = 'D'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
          ls_ckmlkeph_ca-mlcct = 'K'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
          ls_ckmlkeph_ca-mlcct = 'G'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
        WHEN 'M'.
          ls_ckmlkeph_ca-mlcct = 'D'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
          ls_ckmlkeph_ca-mlcct = 'P'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
          ls_ckmlkeph_ca-mlcct = 'O'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
        WHEN 'N'.
          ls_ckmlkeph_ca-mlcct = 'D'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
          ls_ckmlkeph_ca-mlcct = 'K'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
          ls_ckmlkeph_ca-mlcct = 'O'.
          COLLECT ls_ckmlkeph_ca INTO lt_ckmlkeph_categ.
      ENDCASE.
    ENDIF.
*   Kumulierter Bestand-Zeile erzeugen
    IF ls_keph_mlcd-objtyp = 'CA' AND
       ( ls_ckmlkeph-categ = 'AB' OR
         ls_ckmlkeph-categ = 'ZU' OR
         ls_ckmlkeph-categ = 'VP' ).
      CLEAR: ls_ckmlkeph-ptyp, ls_ckmlkeph-bvalt.
      ls_ckmlkeph-categ = 'KB'.
      COLLECT ls_ckmlkeph INTO lt_ckmlkeph_kb.
    ENDIF.
  ENDLOOP.
  INSERT LINES OF lt_ckmlkeph_ptyp INTO TABLE gt_ckmlkeph.
  INSERT LINES OF lt_ckmlkeph_kb INTO TABLE gt_ckmlkeph.
  INSERT LINES OF lt_ckmlkeph_d INTO TABLE gt_ckmlkeph.
  INSERT LINES OF lt_ckmlkeph_p INTO TABLE gt_ckmlkeph.
  INSERT LINES OF lt_ckmlkeph_g INTO TABLE gt_ckmlkeph.
  INSERT LINES OF lt_ckmlkeph_k INTO TABLE gt_ckmlkeph.
  INSERT LINES OF lt_ckmlkeph_o INTO TABLE gt_ckmlkeph.
  LOOP AT lt_ckmlkeph_categ INTO ls_ckmlkeph_ca.
    READ TABLE gt_ckmlkeph INTO ls_ckmlkeph
                           WITH KEY kalnr = ls_ckmlkeph_ca-kalnr
                                    bdatj = ls_ckmlkeph_ca-bdatj
                                    poper = ls_ckmlkeph_ca-poper
                                   untper = ls_ckmlkeph_ca-untper
                                    categ = ls_ckmlkeph_ca-categ
                                    ptyp  = ls_ckmlkeph_ca-ptyp
                                    bvalt = ls_ckmlkeph_ca-bvalt
                                    keart = ls_ckmlkeph_ca-keart
                                    mlcct = ls_ckmlkeph_ca-mlcct
                                    kkzst = ls_ckmlkeph_ca-kkzst
                                    curtp = ls_ckmlkeph_ca-curtp.
    IF sy-subrc = 0.
      CLEAR: ls_vektor.
      MOVE-CORRESPONDING ls_ckmlkeph_ca TO ls_vektor.
      MOVE-CORRESPONDING ls_vektor TO ls_ckmlkeph.
      MODIFY TABLE gt_ckmlkeph FROM ls_ckmlkeph.
    ELSE.
      INSERT ls_ckmlkeph_ca INTO TABLE gt_ckmlkeph.
    ENDIF.
  ENDLOOP.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mlcd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mlcd .

refresh lt_mlcd.

  CALL FUNCTION 'CKMCD_MLCD_READ'
    EXPORTING
      i_from_bdatj = mlccskey-bdatj
      i_from_poper = mlccskey-poper
      i_untper     = mlccskey-untper
      i_run_id     = '000000000000'
    TABLES
      it_kalnr     = lt_kalnr
      ot_mlcd      = lt_mlcd
    EXCEPTIONS
      data_error   = 1
      OTHERS       = 2.

  DELETE lt_mlcd WHERE categ = 'VN'.
  READ TABLE lt_mlcd INTO DATA(ls_mlcd) INDEX 1.
  mlccskey-bvalt = ls_mlcd-bvalt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fieldcat .
 clear wa_fieldcat.
 REFRESH gt_fieldcat.
 wa_fieldcat-fieldname = 'WERKS'.
 wa_fieldcat-seltext_m = 'Centro'.
 wa_fieldcat-seltext_l = 'Centro'.
 APPEND wa_fieldcat to gt_fieldcat.

 wa_fieldcat-fieldname = 'NAME1'.
 wa_fieldcat-seltext_m = 'Descricpión'.
 wa_fieldcat-seltext_l = 'Descripción'.
 APPEND wa_fieldcat to gt_fieldcat.

 wa_fieldcat-fieldname = 'TXELE'.
 wa_fieldcat-seltext_m = 'Elem. de Costo'.
 wa_fieldcat-seltext_l = 'Elem. de costo'.
 APPEND wa_fieldcat to gt_fieldcat.

 wa_fieldcat-fieldname = 'GESAMT1'.
 wa_fieldcat-seltext_m = 'Valor Total'.
 wa_fieldcat-seltext_l = 'Valor Total'.
 wa_fieldcat-do_sum = 'X'.
 APPEND wa_fieldcat to gt_fieldcat.

 wa_fieldcat-fieldname = 'FIX1'.
 wa_fieldcat-seltext_m = 'Valor Fijo'.
 wa_fieldcat-seltext_l = 'Valor Fijo'.
 wa_fieldcat-do_sum = 'X'.
 APPEND wa_fieldcat to gt_fieldcat.

wa_fieldcat-fieldname = 'VARIABEL1'.
wa_fieldcat-seltext_m = 'Valor Variable'.
 wa_fieldcat-seltext_l = 'Valor Variable'.
 wa_fieldcat-do_sum = 'X'.
 APPEND wa_fieldcat to gt_fieldcat.

 wa_fieldcat-fieldname = 'GESAMT2'.
 wa_fieldcat-seltext_m = 'Valor Total 2'.
 wa_fieldcat-seltext_l = 'Valor Total 2'.
 wa_fieldcat-do_sum = 'X'.
 APPEND wa_fieldcat to gt_fieldcat.

wa_fieldcat-fieldname = 'FIX2'.
wa_fieldcat-seltext_m = 'Valor Fijo 2'.
 wa_fieldcat-seltext_l = 'Valor Fijo 2'.
 wa_fieldcat-do_sum = 'X'.
 APPEND wa_fieldcat to gt_fieldcat.

wa_fieldcat-fieldname = 'WAERS1'.
wa_fieldcat-seltext_m = 'Moneda'.
 wa_fieldcat-seltext_l = 'Moneda'.
 APPEND wa_fieldcat to gt_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .

gl_layout-zebra = 'X'.
gl_layout-colwidth_optimize = 'X'.

ls_sort-fieldname = 'WERKS'.
ls_sort-down = abap_true.
ls_sort-subtot = abap_true.
APPEND ls_sort to gt_sort.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
    I_CALLBACK_PROGRAM                = sy-repid
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
    IS_LAYOUT                         = gl_layout
    IT_FIELDCAT                       = gt_fieldcat
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
    IT_SORT                           = gt_sort
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
*   O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    t_outtab                          = it_ckml
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

ENDFORM.
