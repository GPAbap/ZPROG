*&---------------------------------------------------------------------* *& Report            ML_VALUE_FLOW_MONITOR                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*5.00 ERP Support Package
*              201211 see note 1784465
*SL            201211 see note 1765962
*AL            200712 see note 1744712
*SL            201211 see note 1666236
*SL            061011 see note 1638370
*SL            010911 see note 1625217
*SLEE6K035550  060311 see note 1565296
*SLEE6K030430  030211 see note 1541284
*ALEE5K023232  190509 see note 1343607
*SLEE5K023651  170309 see note 1302729
*SLEE5K005189  270109 see note 1296520
*SLEE5K004335  070109 see note 1291786
*SLEE5K003653  111208 see note 1285905
*SLEE5K001397  291008 see note 1267982
*SLEE5K000586  141008 see note 1260581
*SLEE5K000257  091008 see note 1259622
*SLE4EK019681  050808 see note 1228294
*SLE4EK015293  060608 see note 1176915
*SLE4EK010284  140508 see note 1166046
*SLE4EK009743  240408 see note 1164002
*SLE4EK008681  140408 see note 1160229
*SLE4EK007749  280308 see note 1153419
*SLE4EK004036  190308 see note 1136145
*SLE4EK004453  040208 see note 1138299
*SLE4EK003003  140108 see note 1132152
*SLE4EK001665  171207 see note 1121070
*SLE4EK001403  291107 see note 1119516
*SLE36K011354  040907 see note 1088394
*SLE36K010859  280807 see note 1087427
*SLE36K009916  210807 see note 1086064
*SLE36K006300  250707 see note 1071181
*SLE36K003059  200807 see note 1059507
*SLEAEK002379  210507 see note 1045124
*SLEAEK002726  210507 see note 1046705
*SLEAEK001589  210507 see note 1041453
*SLEAEK001365  210507 see note 1040061
*SLEAEK000680  210507 see note 1032547
*SLP7EK020963  080906 see note 975447
*SLP7EK020597  180806 see note 973674
*SLP7EK018564  140806 see note 963263
*SLP7EK018941  110806 see note 965058
*SLP7EK018356  110806 see note 962259
*SLP7EK017766  110806 see note 959316
*SLP7EK017382  110806 see note 957133
*SLP7EK017345  110806 see note 956726
*SLP7EK016313  100806 see note 951512
*SLP7EK007998  290506 see note 912984
*SlP7EK010898  150206 see note 924343
*SLP7EK007952  050106 see note 890578
*SLP7EK000606  050106 see note 878365
*SLP7EK007949  050106 see note 875669
*SLXENK001374  270705 see note 861709
*SLXENK003926  270705 see note 857671
*SLXENK003923  270705 see note 857043
*SLPENK019618  220605 see note 849065
*SLPENK028766  160605 see note 805391
*SLPENK027888  160605 see note 803383
*SLPENK027640  160605 see note 800762
*SLPENK028589  160605 see note 783347
*SLXENK005582  270705 see note 770270
*SLXENK005584  270705 see note 768815
*SLXENK005589  270705 see note 768814
*SLXENK005591  270705 see note 767958
*SLXENK004152  220705 see note 755401
*HOMP3EK001610 180604 See note 745766
*SLPLNK085136  120304 see note 715186
*HOMPLNK080496 250204 See note 710018
*5.00 ERP
*HOMALNK071355 261103 See note 684039
*4.70 Extensions 2.00
*HOMPLNK060557 080703 See note 621340
*4.70
*HOMPLNK020698 100502 WIP Nachbewertung
*HOMPLNK016038 260402 Varianten-Handle
*HOMPLNK014514 220402 CLEAR der Werte zwischen den Währungen
*HOMPLNK009508 170402 EXPLAIN_NDI: ML_ANALYSE_NOT_DIST
*HOMPLNK006295 250302 Transaktion CKMVAL -> CKMVFM
*HOMALNK005514 171001 Retrofit XBA

INCLUDE ZML_VFM_TOP.
*INCLUDE ml_vfm_top.
INCLUDE ZML_VFM_PARA.
*INCLUDE ml_vfm_para.

DATA:

  lt_valutab       TYPE STANDARD TABLE OF rsparams WITH HEADER LINE,
  h_mloldswitch(2) TYPE n.


***************************
AT SELECTION-SCREEN OUTPUT.
***************************
  IF NOT sy-batch IS INITIAL.
* Check if the report is started with a variant
    CALL FUNCTION 'RS_VARIANT_CONTENTS'
      EXPORTING
        report  = 'ML_VALUE_FLOW_MONITOR'
        variant = sy-slset
      TABLES
*       L_PARAMS      =
*       L_PARAMS_NONV =
*       L_SELOP =
*       L_SELOP_NONV  =
        valutab = lt_valutab.
    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.

  GET PARAMETER ID 'MLSWITCH' FIELD h_mlswitch.
  h_mloldswitch = h_mlswitch.
  IF NOT sy-batch IS INITIAL OR
     NOT lt_valutab IS INITIAL.
    h_mlswitch = '11'.
  ENDIF.
  IF h_mlswitch(1) = '1'.
    h_sele_lauf = 'X'.
  ELSE.
    CLEAR: h_sele_lauf.
  ENDIF.
  IF h_mlswitch+1(1) = '1'.
    h_expan = 'X'.
  ELSE.
    CLEAR: h_expan.
  ENDIF.
  IF NOT sy-batch IS INITIAL OR
  NOT lt_valutab IS INITIAL.
    CLEAR h_mlswitch.
    SET PARAMETER ID 'MLSWITCH' FIELD h_mloldswitch.
  ENDIF.
  IF NOT h_sele_lauf IS INITIAL.
    knopf = TEXT-003.
    LOOP AT SCREEN.
      IF screen-group1 = 'PER'.
        screen-invisible = '1'.
        screen-active    = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    knopf = TEXT-001.
    LOOP AT SCREEN.
      IF screen-group1 = 'LAU'.
        screen-invisible = '1'.
        screen-active    = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* OSS Note 1260581: p_fiacc is not 'X' per default, skip this check
*  IF p_fiacc IS INITIAL.
*** Buchungskreis muß eingegeben werden.
*    IF ( p_bukrs IS INITIAL AND p_exrea IS INITIAL ).
*      MESSAGE e069(c+).
*      LEAVE TO TRANSACTION 'CKMVFM'.
*    ENDIF.
*  ENDIF.

**** Begin of SIT ML
*  CLEAR g_sit_active.
*
*  CALL METHOD cl_fcml_sit_switch_check=>fin_co_sit_rs
*    RECEIVING
*      rv_active = g_sit_active.
*
*  IF g_sit_active IS INITIAL.
*    LOOP AT SCREEN.
*      IF screen-group1 = 'SBZ'.
*        screen-invisible = '1'.
*        screen-active    = '0'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*** End of SIT ML


  IF NOT p_exrea IS INITIAL.
    LOOP AT SCREEN.
      IF screen-name <> 'P_NOEX' AND screen-name <> 'P_EXWRI' AND
         screen-name <> 'P_EXREA' AND screen-name <> 'P_EXNAM'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF NOT h_expan IS INITIAL.
    CONCATENATE TEXT-018 TEXT-002
                INTO expan SEPARATED BY space.
    LOOP AT SCREEN.
      IF screen-group1 = 'PUK'.
        screen-invisible = '0'.
        screen-active    = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    REFRESH: r_vbeln, r_posnr, r_pspnr, r_bklas, r_mtart, r_matkl,
             r_spart, r_prctr.
    CONCATENATE TEXT-017 TEXT-002
                INTO expan SEPARATED BY space.
    LOOP AT SCREEN.
      IF screen-group1 = 'PUK'.
        screen-invisible = '1'.
        screen-active    = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

********************
AT SELECTION-SCREEN.
********************
  IF tcurm-bwkrs_cus IS INITIAL.
    READ TABLE tcurm.
  ENDIF.
  IF tcurm-bwkrs_cus = '3'.            "Bewertungsebene BURKS
    REFRESH: r_bwkey.
    CLEAR: r_bwkey.
    r_bwkey-sign = 'I'.
    r_bwkey-option = 'EQ'.
    r_bwkey-low = p_bukrs.
    APPEND r_bwkey.
  ELSE.
    r_bwkey[] = r_werks[].
  ENDIF.
  IF sscrfields-ucomm = 'SELE'.
    IF h_sele_lauf IS INITIAL.
      h_sele_lauf = 'X'.
      h_mlswitch(1) = '1'.
    ELSE.
      CLEAR: h_sele_lauf, p_lauf.
      h_mlswitch(1) = '0'.
    ENDIF.
  ENDIF.
  IF sscrfields-ucomm = 'EXPAN'.
    IF h_expan IS INITIAL.
      h_expan = 'X'.
      h_mlswitch+1(1) = '1'.
    ELSE.
      CLEAR: h_expan.
      h_mlswitch+1(1) = '0'.
      CLEAR: p_mlast.
      REFRESH: r_vbeln, r_posnr, r_pspnr, r_bklas, r_mtart, r_matkl,
               r_spart, r_prctr.
    ENDIF.
  ENDIF.
  SET PARAMETER ID 'MLSWITCH' FIELD h_mlswitch.

  IF ( p_exrea IS INITIAL AND p_bukrs IS INITIAL ).
    MESSAGE e069(c+).
  ENDIF.

  IF p_all = 'X' AND ( ( NOT p_limndi IS INITIAL ) OR
                       ( NOT p_limnin IS INITIAL ) ).
    MESSAGE e014(ckmlmc).
  ENDIF.

  IF p_exrea IS INITIAL.
    IF NOT p_exnam IS INITIAL.
      SELECT SINGLE * FROM ckmvfm_extract WHERE exnam = p_exnam.
      IF sy-subrc = 0.
        PERFORM popup_dialog
                USING    'Y'
                         TEXT-044 TEXT-045 TEXT-046
                CHANGING lh_doit.
        IF lh_doit = 'N' OR
           lh_doit = 'A'.
          STOP.
        ELSE.
          PERFORM delete_exnam.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*******************
START-OF-SELECTION.
*******************

* Batch mode only for extract creation
  IF NOT sy-batch IS INITIAL AND p_exwri IS INITIAL.
    MESSAGE e003(ckmldisplay).
  ENDIF.

* Absolutwerte der Schwellwerte bilden
  p_limndi = abs( p_limndi ).
  p_limnin = abs( p_limnin ).
* Für's Dynpro: Schwellwerte
  ckml_vfm_tree-diff_ndi = p_limndi.
  ckml_vfm_tree-diff_nin = p_limnin.

  IF NOT p_lauf IS INITIAL.
    CALL FUNCTION 'CKML_RUN_PERIOD_GET'
      EXPORTING
*       I_RUN_ID         =
        i_run_type       = p_lauf
*       I_LAST_DAY       = p_lday
        i_langu          = sy-langu
        i_poper          = p_lpop
        i_gjahr          = p_lgja
        i_appl           = p_appl
      IMPORTING
        es_runperiod     = s_runperiod
      EXCEPTIONS
        run_not_existent = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      CLEAR: s_runperiod.
      MESSAGE s112(ckmlrun) WITH p_lauf p_lpop p_lgja p_appl.
      LEAVE TO TRANSACTION 'CKMVFM'.
    ELSE.
*     Für's Dynpro:
      ckmlrunperiod = s_runperiod.
      CALL FUNCTION 'DD_DD07V_GET'
        EXPORTING
          domain_name    = 'CKML_RUN_APPL'
*         LANGU          = SY-LANGU
*         WITHTEXT       = 'X'
        TABLES
          dd07v_tab      = t_dd07v_appl
        EXCEPTIONS
          access_failure = 1
          OTHERS         = 2.
      READ TABLE t_dd07v_appl WITH KEY domvalue_l = ckmlrunperiod-appl.
      IF sy-subrc = 0.
        dynpro0042_appl_text = t_dd07v_appl-ddtext.
      ELSE.
        CLEAR: dynpro0042_appl_text.
      ENDIF.
      p_bdatj = s_runperiod-gjahr.
      p_poper = s_runperiod-poper.
      CALL FUNCTION 'CKML_RUN_PLANTS_GET'
        EXPORTING
          i_run_id         = s_runperiod-run_id
*         I_RUN_TYPE       =
*         I_LAST_DAY       =
*         I_POPER          =
*         I_GJAHR          =
*         I_APPL           = CKRU0_CO_APPL_ACT
        IMPORTING
          et_plants        = t_plants
        EXCEPTIONS
          run_not_existent = 1
          no_plants        = 2
          OTHERS           = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
    REFRESH t_mlrunlist.

    IF NOT s_runperiod IS INITIAL.
      SELECT * FROM mlrunlist INTO TABLE t_mlrunlist
          WHERE run_id = s_runperiod-run_id
          AND   xrelevant = 'X'.
    ENDIF.
  ENDIF.

  IF p_exrea IS INITIAL.

    REFRESH: t_t001k.

*   Bewertungskreise bestimmen
*   ACHTUNG! Funktioniert so nicht mehr, wenn Bewertung auf Buchungskreis!
    IF NOT t_plants IS INITIAL.
      SELECT bwkey bukrs mlbwa FROM t001k
                               INTO CORRESPONDING FIELDS OF TABLE t_t001k
                               FOR ALL ENTRIES IN t_plants
                               WHERE bwkey = t_plants-werks
                               AND   bwkey IN r_bwkey
                               AND   bukrs = p_bukrs.
    ELSE.
      SELECT bwkey bukrs mlbwa FROM t001k
                               INTO CORRESPONDING FIELDS OF TABLE t_t001k
                               WHERE bwkey IN r_bwkey
                               AND   bukrs = p_bukrs.
    ENDIF.
* filter plant with ML not productive based on CKMLCT
    IF NOT t_t001k[] IS INITIAL.
      SELECT bwkey FROM ckmlct
                   INTO CORRESPONDING FIELDS OF TABLE t_ckmlct
                   FOR ALL ENTRIES IN t_t001k
                   WHERE bwkey = t_t001k-bwkey.
      SELECT * FROM t001w INTO CORRESPONDING FIELDS OF TABLE t_t001w
                 FOR ALL ENTRIES IN t_t001k
                 WHERE bwkey = t_t001k-bwkey.
    ENDIF.

    SORT t_t001k.

    CLEAR: no_auth, h_last_bwkey.

    TYPES:
      BEGIN OF ty_s_ckmlv,
        include   TYPE ckmlv,
        poper_mig TYPE poper,
        bdatj_mig TYPE bdatj,
      END OF ty_s_ckmlv.

    DATA:
      ld_prev_pop   TYPE poper,
      ld_prev_bdatj TYPE bdatj.

    DATA: ls_wwo  TYPE cki_wwo_ml,
          ls_t001 TYPE t001.

    DATA  mig_poper TYPE boole_d.

    DATA  ls_ckmlv        TYPE ty_s_ckmlv.

    LOOP AT t_t001k.

      CLEAR mig_poper.

      CALL FUNCTION 'CKML_F_SET_BWKEY'
        EXPORTING
          bwkey             = t_t001k-bwkey
        EXCEPTIONS
          bwkey_not_found   = 1
          internal_error    = 2
          aschema_not_found = 3
          OTHERS            = 4.

      CALL FUNCTION 'CKML_F_GET_WWO'
        IMPORTING
          wwo = ls_wwo.

      CALL FUNCTION 'T001_SINGLE_READ'
        EXPORTING
          bukrs      = ls_wwo-bukrs
        IMPORTING
          wt001      = ls_t001
        EXCEPTIONS
          not_found  = 1
          wrong_call = 2
          OTHERS     = 3.

      ls_ckmlv = cl_ml_data_select=>get_ckmlv_mig( t_t001k-bwkey ).

      CALL FUNCTION 'CKML_F_GET_PREVIOUS_PERIOD'
        EXPORTING
          input_period    = ls_ckmlv-poper_mig
          input_year      = ls_ckmlv-bdatj_mig
          input_periv     = ls_t001-periv
        IMPORTING
          previous_period = ld_prev_pop
          previous_year   = ld_prev_bdatj.


      IF ( ls_ckmlv-poper_mig = p_poper AND ls_ckmlv-bdatj_mig = p_bdatj ) OR
         ( ld_prev_pop        = p_poper AND ld_prev_bdatj = p_bdatj ).
        mig_poper = 'X'.
      ELSE.
        CLEAR mig_poper.
      ENDIF.

      READ TABLE t_ckmlct WITH TABLE KEY bwkey = t_t001k-bwkey TRANSPORTING NO FIELDS. " filter not productive plant
      IF sy-subrc <> 0.
        DELETE t_t001k.
        CONTINUE.
      ELSEIF NOT t_t001k-mlbwa IS INITIAL AND h_last_bwkey IS INITIAL.
        h_last_bwkey = t_t001k-bwkey.
      ENDIF.

      CLEAR s_t001w.

      READ TABLE t_t001w INTO s_t001w WITH KEY bwkey = t_t001k-bwkey.
      IF sy-subrc = 0 AND s_t001w-mgvupd <> 'X'.
        DELETE t_t001k.
        CONTINUE.
      ENDIF.
      AUTHORITY-CHECK OBJECT 'K_ML_VA'
               ID 'BWKEY' FIELD t_t001k-bwkey
               ID 'ACTVT' FIELD '03'.
      IF sy-subrc NE 0.
        MESSAGE i054 WITH t_t001k-bwkey.
*   Keine Berechtigung zum Ausf#Eren im Bewertungskreis &
        DELETE t_t001k.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    IF no_auth = 'X'.
      MESSAGE i101 WITH TEXT-063.
    ENDIF.

    CLEAR: no_auth.

    PERFORM write_exinfo USING h_last_bwkey s_runperiod CHANGING h_exid.

    IF  NOT s_runperiod IS INITIAL.

      DATA: ls_witem   LIKE scma_witem,
            l_function TYPE schedman_function.
      CLEAR ls_witem.

      ls_witem-wf_witem = wf_witem.
      ls_witem-wf_wlist = wf_wlist.
      l_function = 'ML16'.

      CALL FUNCTION 'CKML_SCHEDMAN_RECORD_OPEN'
        EXPORTING
          i_function   = l_function
          i_activity   = ckru0_pepaction-n16
          i_scma_witem = ls_witem
          i_repid      = sy-repid
*         I_TCODE      = SY-TCODE
*         I_TEST       = ' '
          i_run_id     = s_runperiod-run_id.

      COMMIT WORK.

    ENDIF.


    IF NOT p_fiacc IS INITIAL.

      PERFORM get_fi_accounts USING p_finor          "chg note 1377333
                           CHANGING tr_hkont.

      PERFORM get_bsis USING p_bukrs
                             p_bdatj
                             p_poper
                             s_runperiod
                             tr_hkont
                                h_exid
                       CHANGING t_bkpf.

      h_first_bwkey = 'X'.
      h_first_mat   = 'X'.
    ENDIF.
    IF t_dd07v IS INITIAL.
      CALL FUNCTION 'DD_DD07V_GET'
        EXPORTING
          domain_name = 'CKML_POS_TYPE'
*         LANGU       = SY-LANGU
*         WITHTEXT    = 'X'
        TABLES
          dd07v_tab   = t_dd07v.
*   EXCEPTIONS
*     ACCESS_FAILURE       = 1
*     OTHERS               = 2
    ENDIF.           .

    LOOP AT t_t001k.
      REFRESH: t_mats, t_mats_all, t_kalnr, t_ckmlpp,
               t_ckmlcr, t_ckmlcr_act,
               t_mlcd, t_mlcd_not_alloc.                 "note 1489887
      IF NOT t_t001k-mlbwa IS INITIAL.
        h_last_bwkey = t_t001k-bwkey.
        PERFORM get_materials USING t_t001k
                                    t_mlrunlist
                              CHANGING t_mats_all
                                       t_kalnr
                                       t_ckmlpp[]
                                       t_ckmlcr[]
                                       t_mlcd[]          "note 1489887
                                       t_mlcd_not_alloc[].  "n. 1489887
        CHECK NOT t_mats_all IS INITIAL.
*        mlcd wird bereits in get_materials gelesen      "note 1489887
*        PERFORM get_mlcd_data USING t_mats_all
*                              CHANGING t_mlcd[]
*                                       t_mlcd_not_alloc[].
        SORT t_mlcd BY kalnr bdatj poper untper categ curtp.
        SORT t_mlcd_not_alloc BY kalnr bdatj poper untper curtp.

        IF NOT s_runperiod IS INITIAL.
          IF s_runperiod-appl = 'ACRU'.
            PERFORM get_act_period_data USING t_kalnr
                                              s_runperiod
                                        CHANGING t_ckmlcr_act[].
          ELSE.
            PERFORM get_mlavrscale USING t_kalnr
                                         s_runperiod
                                   CHANGING t_mlavrscale[].
          ENDIF.
        ENDIF.

        DATA: ls_mats_all   TYPE s_mats,
              lh_matnr      TYPE matnr,
              lh_bwkey      TYPE bwkey,
              lh_bwtar      TYPE bwtar_d,
              current_matnr TYPE matnr,
              current_bwkey TYPE bwkey,
              current_bwtar TYPE bwtar_d.

        READ TABLE t_mats_all INDEX 1 INTO ls_mats_all.
        lh_matnr = ls_mats_all-matnr.
        lh_bwkey = ls_mats_all-bwkey.
        lh_bwtar = ls_mats_all-bwtar.

        CLEAR ls_mats_all.

        LOOP AT t_mats_all INTO ls_mats_all.
          current_matnr = ls_mats_all-matnr.
          current_bwkey = ls_mats_all-bwkey.
          current_bwtar = ls_mats_all-bwtar.

          IF ( current_matnr <> lh_matnr )
            OR ( current_bwkey <> lh_bwkey )
            OR ( current_bwtar <> lh_bwtar ).
            IF NOT p_fiacc IS INITIAL.
              LOOP AT t_mats TRANSPORTING NO FIELDS WHERE sobkz <> ''.
                EXIT.
              ENDLOOP.

              IF sy-subrc = 0.
                h_sobkz = 'X'.
              ELSE.
                h_sobkz = ''.
              ENDIF.
              PERFORM complete_bseg_out_for_mat
                     USING lh_matnr lh_bwkey lh_bwtar
                           t_bkpf tr_hkont h_sobkz
             CHANGING t_ckmvfm_bseg_out[] t_del_from_bseg_out[] h_no_acctit.

              DATA: ht_t001k LIKE t001k OCCURS 0 WITH HEADER LINE,
                    h_bwkey  TYPE bwkey.

              ht_t001k[] = t_t001k[].
              SORT ht_t001k BY bwkey.
              h_bwkey  = t_t001k-bwkey.

              PERFORM get_mat_balance TABLES   ht_t001k
                                      USING    h_bwkey
                                               t_bkpf
                                               t_mats
                                               h_no_acctit
                                          CHANGING    t_ckmvfm_bseg_out[]
                                                      t_del_from_bseg_out[]
t_mat_bal.
            ENDIF.
            SORT t_mats BY kalnr.
            PERFORM find_bad_boys USING t_mats
                                        t_ckmlpp[]
                                        t_ckmlcr[]
                                        t_ckmlcr_act[]
                                        t_mlavrscale[]
                                        t_mlcd[]
                                        t_mlcd_not_alloc[]
                                        t_mat_bal
                                        h_exid
                                  CHANGING t_ckmvfm_out[]
                                           t_ckmvfm_bseg_out[].
            PERFORM process_2_mats USING t_mats
                                        t_ckmlpp[]
                                        t_ckmlcr[]
                                        t_ckmlcr_act[]
                                        t_mlavrscale[]
                                        t_mlcd[]
                                        t_mat_bal
                                        h_exid
                                  CHANGING t_ckmvfm_out[]
                                           t_ckmvfm_bseg_out[].
            CLEAR: h_first_bwkey, h_first_mat.

            IF NOT t_ckmvfm_out[] IS INITIAL.
              INSERT ckmvfm_out FROM TABLE t_ckmvfm_out.
            ENDIF.
            IF NOT t_del_from_bseg_out[] IS INITIAL.
              DELETE ckmvfm_bseg_out FROM TABLE t_del_from_bseg_out.
            ENDIF.
            IF NOT t_ckmvfm_bseg_out[] IS INITIAL.
              MODIFY ckmvfm_bseg_out FROM TABLE t_ckmvfm_bseg_out.
            ENDIF.

            DESCRIBE TABLE t_mats LINES lh_lines.
            lh_count = lh_count + lh_lines.
            CLEAR lh_lines.
            IF lh_count >= 100.
              COMMIT WORK.
              CLEAR lh_count.
            ENDIF.

            REFRESH: t_ckmvfm_out, t_ckmvfm_bseg_out,
                     t_del_from_bseg_out, t_mats, t_mat_bal.
            lh_matnr = current_matnr.
            lh_bwkey = current_bwkey.
            lh_bwtar = current_bwtar.
            REFRESH t_mats.
          ENDIF.

          APPEND ls_mats_all TO t_mats.
          CLEAR ls_mats_all.

        ENDLOOP.

        COMMIT WORK.

        IF NOT t_mats[] IS INITIAL.       "nur ein Material
          IF NOT p_fiacc IS INITIAL.
            LOOP AT t_mats TRANSPORTING NO FIELDS WHERE sobkz <> ''.
              EXIT.
            ENDLOOP.

            IF sy-subrc = 0.
              h_sobkz = 'X'.
            ELSE.
              h_sobkz = ''.
            ENDIF.


            PERFORM complete_bseg_out_for_mat
            USING lh_matnr lh_bwkey lh_bwtar t_bkpf tr_hkont h_sobkz
            CHANGING t_ckmvfm_bseg_out[] t_del_from_bseg_out[] h_no_acctit.

            ht_t001k[] = t_t001k[].
            SORT ht_t001k BY bwkey.
            h_bwkey  = t_t001k-bwkey.

            PERFORM get_mat_balance TABLES   ht_t001k
                                       USING    h_bwkey
                                                t_bkpf
                                                t_mats
                                                h_no_acctit
                                    CHANGING    t_ckmvfm_bseg_out[]
                                                t_del_from_bseg_out[]
t_mat_bal.



          ENDIF.
          SORT t_mats BY kalnr.
          PERFORM find_bad_boys USING t_mats
                                      t_ckmlpp[]
                                      t_ckmlcr[]
                                      t_ckmlcr_act[]
                                      t_mlavrscale[]
                                      t_mlcd[]
                                      t_mlcd_not_alloc[]
                                      t_mat_bal
                                        h_exid
                                  CHANGING t_ckmvfm_out[]
                                           t_ckmvfm_bseg_out[].
          PERFORM process_2_mats USING t_mats
                                      t_ckmlpp[]
                                      t_ckmlcr[]
                                      t_ckmlcr_act[]
                                      t_mlavrscale[]
                                      t_mlcd[]
                                      t_mat_bal
                                        h_exid
                                  CHANGING t_ckmvfm_out[]
                                           t_ckmvfm_bseg_out[].
          CLEAR: h_first_bwkey, h_first_mat.

          IF NOT t_ckmvfm_out[] IS INITIAL.
            INSERT ckmvfm_out FROM TABLE t_ckmvfm_out.
          ENDIF.
          IF NOT t_del_from_bseg_out[] IS INITIAL.
            DELETE ckmvfm_bseg_out FROM TABLE t_del_from_bseg_out.
          ENDIF.
          IF NOT t_ckmvfm_bseg_out[] IS INITIAL.
            MODIFY ckmvfm_bseg_out FROM TABLE t_ckmvfm_bseg_out.
          ENDIF.
          COMMIT WORK.
          REFRESH: t_ckmvfm_out, t_ckmvfm_bseg_out, t_del_from_bseg_out,
                   t_mats, t_mat_bal.

        ENDIF.                "nur ein Material


      ENDIF.
    ENDLOOP.

** For SchedMan, see note 1059507
    IF  NOT s_runperiod IS INITIAL.
      DATA: ls_scma_event LIKE scma_event,
            l_aplstat     TYPE  schedman_job_stati.
      CLEAR ls_scma_event.
      ls_scma_event-wf_witem = wf_witem.
      ls_scma_event-wf_okey  = wf_okey.
      l_aplstat = '0'.
      ls_scma_event-wf_event = cs_wf_events-finished.
***

      CALL FUNCTION 'CKML_SCHEDMAN_RECORD_CLOSE'
        EXPORTING
*         I_OBJECTS           =
          i_aplication_status = l_aplstat
*         i_prot_number       = g_cmf_nr
          i_scma_event        = ls_scma_event.          "#EC ARGCHECKED

      COMMIT WORK.

    ENDIF.

  ELSE.

*  Read data from extract
    CLEAR gs_extract.
    SELECT SINGLE * FROM ckmvfm_extract INTO gs_extract
    WHERE exnam = p_exnam.

    IF sy-subrc <> 0.
      IF sy-batch IS INITIAL.
        MESSAGE s002(ckmldisplay) WITH p_exnam.
        LEAVE TO TRANSACTION 'CKMVFM'.
      ELSE.
        MESSAGE e002(ckmldisplay) WITH p_exnam.
      ENDIF.
    ELSE.

      SELECT SINGLE * FROM ckmvfm_out INTO ls_ckmvfm_out
      WHERE exid = gs_extract-exid.
      IF sy-subrc <> 0.
        MESSAGE s154.
        IF sy-batch IS INITIAL.
          LEAVE TO TRANSACTION 'CKMVFM'.
        ENDIF.
      ENDIF.
      IF NOT sy-batch IS INITIAL.
        EXIT.
      ENDIF.
** t_t001k füllen aus ckmvfm_out.
      SELECT bwkey bukrs mlbwa FROM t001k
                               INTO CORRESPONDING FIELDS OF TABLE
                               t_t001k_auth
                               WHERE   bukrs = ls_ckmvfm_out-bukrs.
      SORT t_t001k_auth.

      DATA: lh_count_all     TYPE i,
            lh_count_no_auth TYPE i.

      CLEAR: no_auth, r_bwkey_no_auth.
      REFRESH: r_bwkey_no_auth.

      LOOP AT t_t001k_auth.
        SELECT SINGLE * FROM ckmvfm_out INTO ls_ckmvfm_out
        WHERE exid = gs_extract-exid
        AND   bwkey = t_t001k_auth-bwkey.
        IF sy-subrc = 0.
          lh_count_all = lh_count_all + 1.
          AUTHORITY-CHECK OBJECT 'K_ML_VA'
                   ID 'BWKEY' FIELD t_t001k_auth-bwkey
                   ID 'ACTVT' FIELD '03'.
          IF sy-subrc NE 0.
            no_auth = 'X'.
            lh_count_no_auth = lh_count_no_auth + 1.
            CLEAR: r_bwkey_no_auth.
            r_bwkey_no_auth-sign = 'I'.
            r_bwkey_no_auth-option = 'EQ'.
            r_bwkey_no_auth-low = t_t001k_auth-bwkey.
            APPEND r_bwkey_no_auth.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF no_auth = 'X'.
** Meldung: Es fehlen x von y Berechtigungen. Please check SU53.
        IF lh_count_all = lh_count_no_auth.
          MESSAGE i101 WITH TEXT-063.
*   Keine Berechtigung zum AusfEren im Bewertungskreis &
          LEAVE TO TRANSACTION 'CKMVFM'.
        ENDIF.
        IF lh_count_all <> lh_count_no_auth.
          MESSAGE i101 WITH TEXT-063.
*   Keine Berechtigung zum AusfEren im Bewertungskreis &
        ENDIF.
      ENDIF.

      CLEAR: lh_count_all, lh_count_no_auth.
      CLEAR: ls_ckmvfm_out.

      h_exid       = gs_extract-exid.
      h_exdate     = gs_extract-exdate.
      h_extime     = gs_extract-extime.
      h_exunam     = gs_extract-exuname.
      p_bdatj      = gs_extract-bdatj.
      p_poper      = gs_extract-poper.
      p_fiacc      = gs_extract-fiacc.
      h_last_bwkey = gs_extract-bwkey.

      IF NOT gs_extract-run_id IS INITIAL.
        CALL FUNCTION 'CKML_RUN_PERIOD_GET'
          EXPORTING
            i_run_id     = gs_extract-run_id
          IMPORTING
            es_runperiod = s_runperiod.

        IF sy-subrc = 0.
          ckmlrunperiod = s_runperiod.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Ausgabe
  SELECT SINGLE * FROM ckmvfm_out INTO ls_ckmvfm_out
  WHERE exid = h_exid.
  IF sy-subrc <> 0.

    MESSAGE s154.
    IF sy-batch IS INITIAL.
*      LEAVE TO TRANSACTION 'CKMVFM'.
      EXIT.
    ENDIF.
  ENDIF.
  IF NOT sy-batch IS INITIAL.
    EXIT.
  ENDIF.

  CALL SCREEN '0042'.

*----------------------------------------------------------------------*

************************************************************************
*    MODULE
************************************************************************
INCLUDE ZML_VFM_MODULE.
*  INCLUDE ml_vfm_module.

************************************************************************
*    FORM-Routinen
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  get_materials
*&---------------------------------------------------------------------*
FORM get_materials USING    pf_t001k TYPE t001k
                            pt_mlrunlist LIKE t_mlrunlist[]
                   CHANGING pt_mats LIKE t_mats[]
                            ct_kalnr TYPE ckmv0_matobj_tbl
                            pt_ckmlpp LIKE t_ckmlpp[]
                            pt_ckmlcr LIKE t_ckmlcr[]
                            pt_mlcd   LIKE t_mlcd[]      "note 1489887
                    pt_mlcd_not_alloc LIKE t_mlcd_not_alloc[]. "1489887

  DATA: lt_kalnr          TYPE ckmv0_matobj_tbl,
        pack_kalnr        TYPE ckmv0_matobj_tbl,
        ls_mats           TYPE s_mats,
        ls_kalnr          TYPE ckmv0_matobj_str,
        lw_mlrunlist      TYPE mlrunlist,
        lt_ckmlpp         LIKE t_ckmlpp[],
        lt_ckmlcr         LIKE t_ckmlcr[],
        lt_mlcd           LIKE t_mlcd[],                           "note 1489887
        lt_mlcd_not_alloc LIKE t_mlcd_not_alloc[],       "note 1489887
        l_pack_size       TYPE i,
        l_counter         TYPE i.
  DATA:
    lt_mlast     TYPE RANGE OF ckmlhd-mlast,
    ls_mlast     LIKE LINE OF lt_mlast,
    lt_mats      LIKE t_mats[],
    lt_mlrunlist LIKE pt_mlrunlist[].
  FIELD-SYMBOLS:
    <lr_mats>      LIKE LINE OF pt_mats,
    <lr_mlrunlist> LIKE LINE OF pt_mlrunlist.

* Buchungskreis lesen (für Bezeichnung u.a.)
  CALL FUNCTION 'T001_SINGLE_READ'
    EXPORTING
*     KZRFB      = ' '
*     MAXTZ      = 0
      bukrs      = pf_t001k-bukrs
    IMPORTING
      wt001      = t001
    EXCEPTIONS
      not_found  = 1
      wrong_call = 2
      OTHERS     = 3.
  IF sy-subrc <> 0.
    CLEAR: t001.
  ENDIF.
* Aktuelle Periode als Default / Hauswährung lesen
  IF p_bdatj IS INITIAL OR p_poper IS INITIAL.
    IF marv-bukrs <> pf_t001k-bukrs.
      SELECT SINGLE * FROM marv WHERE bukrs = pf_t001k-bukrs.
      IF sy-subrc <> 0.
        CLEAR: marv.
      ENDIF.
    ENDIF.
    IF NOT marv IS INITIAL.
      p_bdatj = marv-lfgja.
      IF p_poper IS INITIAL.
        p_poper = marv-lfmon.
      ENDIF.
    ENDIF.
    SET PARAMETER ID 'MLJ' FIELD p_bdatj.
    SET PARAMETER ID 'MLB' field p_bdatj.
    SET PARAMETER ID 'MLP' FIELD p_poper.
  ENDIF.
  REFRESH: pt_mats.

  IF p_mlast IS INITIAL AND NOT s_runperiod IS INITIAL.
    p_mlast = '3'.
  ENDIF.

*
* note 1409058
* change of selection statements due to performance issues
*
  IF NOT p_mlast IS INITIAL.
    ls_mlast-sign   = 'I'.
    ls_mlast-option = 'EQ'.
    ls_mlast-low    = p_mlast.
    APPEND ls_mlast TO lt_mlast.
  ENDIF.
  IF pt_mlrunlist[] IS INITIAL.

    IF ( r_vbeln[] IS INITIAL AND r_posnr[] IS INITIAL ) .
      CLEAR gd_sobkze.
    ELSE.
      gd_sobkze = 'X'. "sales order stock selected explicitely
    ENDIF.
    IF ( r_pspnr[] IS INITIAL ).
      CLEAR gd_sobkzq.
    ELSE.
      gd_sobkzq = 'X'.  "project stock selected explicitely
    ENDIF.

*   We always select MBEW except if any of the special stocks is selected explicitely
    IF gd_sobkze = '' AND gd_sobkzq = ''.
      SELECT h~bwkey h~kalnr h~mlast h~matnr h~bwtar
             h~sobkz h~vbeln h~posnr h~pspnr
             m~mtart m~matkl m~spart m~meins c~prctr b~bklas b~vprsv
         APPENDING CORRESPONDING FIELDS OF TABLE pt_mats
         FROM ( ( ckmlhd AS h JOIN mara AS m
                ON h~matnr = m~matnr )
                JOIN marc AS c
                ON h~matnr = c~matnr AND h~bwkey = c~werks )
              JOIN mbew AS b
              ON h~kalnr = b~kaln1
         WHERE h~mlast IN lt_mlast
         AND   h~bwkey = pf_t001k-bwkey
         AND   h~matnr IN r_matnr
         AND   h~bwtar IN r_bwtar
         AND   h~sobkz IN r_sobkz
         AND   h~vbeln IN r_vbeln
         AND   h~posnr IN r_posnr
         AND   h~pspnr IN r_pspnr
         AND   b~bklas IN r_bklas
         AND   m~mtart IN r_mtart
         AND   m~matkl IN r_matkl
         AND   m~spart IN r_spart
         AND   c~prctr IN r_prctr.
    ENDIF.

*   We select EBEW always except if only QBEW is selected explicitely
    IF NOT ( gd_sobkze IS INITIAL AND gd_sobkzq = 'X' ).
      SELECT h~bwkey h~kalnr h~mlast h~matnr h~bwtar
             h~sobkz h~vbeln h~posnr h~pspnr
             m~mtart m~matkl m~spart m~meins c~prctr b~bklas b~vprsv
        APPENDING CORRESPONDING FIELDS OF TABLE pt_mats
        FROM ( ( ckmlhd AS h JOIN mara AS m
               ON h~matnr = m~matnr )
               JOIN marc AS c
               ON h~matnr = c~matnr AND h~bwkey = c~werks )
             JOIN ebew AS b
             ON h~matnr = b~matnr AND h~bwkey = b~bwkey
             AND h~bwtar = b~bwtar AND h~sobkz = b~sobkz
             AND h~vbeln = b~vbeln AND h~posnr = b~posnr "chg 1444254
        WHERE h~mlast IN lt_mlast
        AND   h~bwkey = pf_t001k-bwkey
        AND   h~matnr IN r_matnr
        AND   h~bwtar IN r_bwtar
        AND   h~sobkz IN r_sobkz
        AND   h~vbeln IN r_vbeln
        AND   h~posnr IN r_posnr
        AND   h~pspnr IN r_pspnr
        AND   b~bklas IN r_bklas
        AND   m~mtart IN r_mtart
        AND   m~matkl IN r_matkl
        AND   m~spart IN r_spart
        AND   c~prctr IN r_prctr.
    ENDIF.

*   We select QBEW always except if only EBEW is selected explicitely
    IF NOT ( gd_sobkze = 'X' AND gd_sobkzq IS INITIAL ).
      SELECT h~bwkey h~kalnr h~mlast h~matnr h~bwtar
             h~sobkz h~vbeln h~posnr h~pspnr
             m~mtart m~matkl m~spart m~meins c~prctr b~bklas b~vprsv
         APPENDING CORRESPONDING FIELDS OF TABLE pt_mats
         FROM ( ( ckmlhd AS h JOIN mara AS m
                ON h~matnr = m~matnr )
                JOIN marc AS c
                ON h~matnr = c~matnr AND h~bwkey = c~werks )
              JOIN qbew AS b
              ON h~matnr = b~matnr AND h~bwkey = b~bwkey
              AND h~bwtar = b~bwtar AND h~sobkz = b~sobkz
              AND h~pspnr = b~pspnr
         WHERE h~mlast IN lt_mlast
         AND   h~bwkey = pf_t001k-bwkey
         AND   h~matnr IN r_matnr
         AND   h~bwtar IN r_bwtar
         AND   h~sobkz IN r_sobkz
         AND   h~vbeln IN r_vbeln
         AND   h~posnr IN r_posnr
         AND   h~pspnr IN r_pspnr
         AND   b~bklas IN r_bklas
         AND   m~mtart IN r_mtart
         AND   m~matkl IN r_matkl
         AND   m~spart IN r_spart
         AND   c~prctr IN r_prctr.
    ENDIF.

  ELSE.
*   Selektion über die Materialien eines Laufs
    lt_mlrunlist = pt_mlrunlist[].
*   hier schon die weiteren Selektionsbedingungen verproben,
*   um den DB-Zugriff billiger zu machen
    DELETE lt_mlrunlist WHERE NOT matnr IN r_matnr
                    OR        bwkey NE pf_t001k-bwkey.

    IF lt_mlrunlist[] IS INITIAL.
      REFRESH: pt_ckmlpp, pt_ckmlcr.
      EXIT.
    ENDIF.
    SORT lt_mlrunlist BY kalnr.
*   nur diejenigen Felder holen, die nicht in mv011 stehen
*   OSS note 1625217: Select ALL materials from run
    SELECT h~kalnr h~matnr h~bwtar h~sobkz h~vbeln h~posnr h~pspnr
           m~mtart m~matkl m~meins m~spart
           c~prctr
      INTO CORRESPONDING FIELDS OF TABLE pt_mats
      FROM ( ( ckmlhd AS h JOIN mara AS m
      ON h~matnr = m~matnr )
      JOIN marc AS c
      ON h~matnr = c~matnr AND h~bwkey = c~werks )
       FOR ALL ENTRIES IN lt_mlrunlist
       WHERE h~kalnr = lt_mlrunlist-kalnr
       AND   h~mlast IN lt_mlast
       AND   h~bwtar IN r_bwtar
       AND   h~vbeln IN r_vbeln
       AND   h~posnr IN r_posnr
       AND   h~sobkz IN r_sobkz
       AND   h~pspnr IN r_pspnr
       AND   c~prctr IN r_prctr.

*   fehlende Daten aus mv011 ergänzen
    LOOP AT pt_mats ASSIGNING <lr_mats>.
      <lr_mats>-vprsv = 'S'.
      <lr_mats>-mlast = '3'.
      <lr_mats>-bwkey = pf_t001k-bwkey.
      IF <lr_mats>-sobkz IS INITIAL.
        SELECT bklas FROM mbew INTO <lr_mats>-bklas
          WHERE kaln1 = <lr_mats>-kalnr.
        ENDSELECT.
      ENDIF.
      IF <lr_mats>-sobkz = 'E'.
        SELECT bklas FROM ebew INTO <lr_mats>-bklas
          WHERE kaln1 = <lr_mats>-kalnr.
        ENDSELECT.
      ENDIF.
      IF  <lr_mats>-sobkz = 'Q'.
        SELECT bklas FROM qbew INTO <lr_mats>-bklas
          WHERE kaln1 = <lr_mats>-kalnr.
        ENDSELECT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT pt_mats BY matnr bwkey bwtar.
  IF pt_mats[] IS INITIAL.
    REFRESH: pt_ckmlpp, pt_ckmlcr.
    EXIT.
  ENDIF.
  REFRESH: lt_kalnr.

  CLEAR: ls_kalnr.
  LOOP AT pt_mats INTO ls_mats.
    ls_kalnr-kalnr = ls_mats-kalnr.
    ls_kalnr-bwkey = ls_mats-bwkey.
    APPEND ls_kalnr TO lt_kalnr.
  ENDLOOP.

**For performance reasons, function module 'CKMS_PERIOD_READ_WITH_ITAB'
**is read per packages of kalnr, see note 1160229.
  l_pack_size = 100.
  CLEAR: ls_kalnr, l_counter.
  REFRESH: pack_kalnr, lt_ckmlpp, lt_ckmlcr.

  CALL FUNCTION 'CKMS_BUFFER_REFRESH_COMPLETE'.

  LOOP AT lt_kalnr INTO ls_kalnr.
    APPEND ls_kalnr TO pack_kalnr.
    l_counter = l_counter + 1.

    IF l_counter = l_pack_size.
* Periodensätze lesen
      CALL FUNCTION 'CKMS_PERIOD_READ_WITH_ITAB'
        EXPORTING
*         I_REFRESH_BUFFER          =
*         I_READ_ONLY_BUFFER        = ' '
*         I_USE_BUFFER              = 'X'
*         I_BUILD_SMBEW             =
          i_bdatj_1                 = p_bdatj
          i_poper_1                 = p_poper
*         I_BDATJ_2                 =
*         I_POPER_2                 =
*         I_BDATJ_3                 =
*         I_POPER_3                 =
*         I_BETWEEN_1_AND_2         =
          i_untper                  = s_runperiod-untper
          i_call_by_reporting       = 'X'
          i_no_chk_periods_complete = 'X'
        TABLES
          t_kalnr                   = pack_kalnr
          t_ckmlpp                  = lt_ckmlpp
          t_ckmlcr                  = lt_ckmlcr
*         T_MISS_CKMLPP             =
*         T_MISS_CKMLCR             =
        EXCEPTIONS
          no_data_found             = 1
          input_data_inconsistent   = 2
          buffer_inconsistent       = 3
          OTHERS                    = 4.
      IF sy-subrc <> 0 AND
         NOT ( sy-subrc = 1 AND
            NOT ( pt_ckmlpp[] IS INITIAL AND pt_ckmlcr[] IS INITIAL ) ).
*   Probleme
        REFRESH: pt_mats, pt_ckmlpp, pt_ckmlcr.
        EXIT.
      ENDIF.
      IF sy-subrc = 0.
        APPEND LINES OF lt_ckmlpp TO pt_ckmlpp.
        APPEND LINES OF lt_ckmlcr TO pt_ckmlcr.

      ENDIF.

*     start of                                            note 1489887
*     jetzt die MLCD-Sätze holen, wobei die CR- und PP-Daten
*     noch im Puffer sind
      CALL FUNCTION 'CKMCD_MLCD_READ'
        EXPORTING
          i_from_bdatj      = p_bdatj
          i_from_poper      = p_poper
*         I_TO_BDATJ        =
*         I_TO_POPER        =
          i_untper          = s_runperiod-untper
*         I_RUN_ID          =
          i_no_buffer       = 'X'   "nicht in Puffer schreiben
          i_refresh_buffer  = ' '
          i_online          = ' '
*         I_NO_MLCD_CREATE  =
        TABLES
          it_kalnr          = pack_kalnr
          ot_mlcd           = lt_mlcd
          ot_mlcd_not_alloc = lt_mlcd_not_alloc
        EXCEPTIONS
          data_error        = 1
          OTHERS            = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      IF sy-subrc = 0.
        APPEND LINES OF lt_mlcd           TO pt_mlcd.
        APPEND LINES OF lt_mlcd_not_alloc TO pt_mlcd_not_alloc.
      ENDIF.
      REFRESH: lt_mlcd, lt_mlcd_not_alloc.
      CALL FUNCTION 'CKMS_BUFFER_REFRESH_COMPLETE'.
*     end   of                                            note 1489887

      CLEAR l_counter.
      REFRESH: pack_kalnr, lt_ckmlpp, lt_ckmlcr.
    ENDIF.

  ENDLOOP.

  IF NOT pack_kalnr IS INITIAL.

* Periodensätze lesen
    CALL FUNCTION 'CKMS_PERIOD_READ_WITH_ITAB'
      EXPORTING
*       I_REFRESH_BUFFER          =
*       I_READ_ONLY_BUFFER        = ' '
*       I_USE_BUFFER              = 'X'
*       I_BUILD_SMBEW             =
        i_bdatj_1                 = p_bdatj
        i_poper_1                 = p_poper
*       I_BDATJ_2                 =
*       I_POPER_2                 =
*       I_BDATJ_3                 =
*       I_POPER_3                 =
*       I_BETWEEN_1_AND_2         =
        i_untper                  = s_runperiod-untper
        i_call_by_reporting       = 'X'
        i_no_chk_periods_complete = 'X'
      TABLES
        t_kalnr                   = pack_kalnr
        t_ckmlpp                  = lt_ckmlpp
        t_ckmlcr                  = lt_ckmlcr
*       T_MISS_CKMLPP             =
*       T_MISS_CKMLCR             =
      EXCEPTIONS
        no_data_found             = 1
        input_data_inconsistent   = 2
        buffer_inconsistent       = 3
        OTHERS                    = 4.
    IF sy-subrc <> 0 AND
       NOT ( sy-subrc = 1 AND
             NOT ( pt_ckmlpp[] IS INITIAL AND pt_ckmlcr[] IS INITIAL ) ).
*   Probleme
      REFRESH: pt_mats, pt_ckmlpp, pt_ckmlcr.
      EXIT.
    ENDIF.
    IF sy-subrc = 0.
      APPEND LINES OF lt_ckmlpp TO pt_ckmlpp.
      APPEND LINES OF lt_ckmlcr TO pt_ckmlcr.
    ENDIF.

*   start of                                              note 1489887
*   jetzt die MLCD-Sätze holen, wobei die CR- und PP-Daten
*   noch im Puffer sind
    CALL FUNCTION 'CKMCD_MLCD_READ'
      EXPORTING
        i_from_bdatj      = p_bdatj
        i_from_poper      = p_poper
*       I_TO_BDATJ        =
*       I_TO_POPER        =
        i_untper          = s_runperiod-untper
*       I_RUN_ID          =
        i_no_buffer       = 'X'   "nicht in Puffer schreiben
        i_refresh_buffer  = ' '
        i_online          = ' '
*       I_NO_MLCD_CREATE  =
      TABLES
        it_kalnr          = pack_kalnr
        ot_mlcd           = lt_mlcd
        ot_mlcd_not_alloc = lt_mlcd_not_alloc
      EXCEPTIONS
        data_error        = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF sy-subrc = 0.
      APPEND LINES OF lt_mlcd           TO pt_mlcd.
      APPEND LINES OF lt_mlcd_not_alloc TO pt_mlcd_not_alloc.
    ENDIF.
    REFRESH: lt_mlcd, lt_mlcd_not_alloc.
    CALL FUNCTION 'CKMS_BUFFER_REFRESH_COMPLETE'.
*   end  of                                              note 1489887

    CLEAR l_counter.
    REFRESH: pack_kalnr, lt_ckmlpp, lt_ckmlcr.

  ENDIF.

  SORT: pt_ckmlpp, pt_ckmlcr.
  ct_kalnr[] = lt_kalnr[].

ENDFORM.                               " get_materials
*&---------------------------------------------------------------------*
*&      Form  find_bad_boys
*&---------------------------------------------------------------------*
FORM find_bad_boys USING pt_mats LIKE t_mats[]
                         pt_ckmlpp LIKE t_ckmlpp[]
                         pt_ckmlcr LIKE t_ckmlcr[]
                         pt_ckmlcr_act LIKE t_ckmlcr_act[]
                         pt_mlavrscale LIKE t_mlavrscale[]
                         pt_mlcd LIKE t_mlcd[]
                         pt_mlcd_not_alloc LIKE t_mlcd_not_alloc[]
                         pt_mat_bal TYPE ty_mat_bal
               p_exid TYPE num4
     CHANGING  pt_ckmvfm_out LIKE t_ckmvfm_out[]
               pt_ckmvfm_bseg_out LIKE t_ckmvfm_bseg_out[].

  DATA: pt_out           LIKE t_out[],
        ct_bseg_out      TYPE ty_bseg_out,
        lt_out           LIKE t_out[],
        lt_kalnr_t5      TYPE ckml_t_mgv_kalnr,
        lt_t005_extended TYPE ckml_t_t005_extended.
  DATA: ls_ckmvfm_bseg_out TYPE ckmvfm_bseg_out,
        ls_ckmvfm_out      TYPE ckmvfm_out,
        ls_out             TYPE s_out,
        ls_out_ndi         TYPE s_out,
        ls_out_cum         TYPE s_out,
        ls_out_nin         TYPE s_out,
        ls_out_mls         TYPE s_out,
        ls_out_rsc         TYPE s_out,
        ls_out_nle         TYPE s_out,
        ls_out_eiv         TYPE s_out,
        ls_out_vno         TYPE s_out,
        ls_out_ost         TYPE s_out,
        ls_out_wip         TYPE s_out,
        ls_out_fia         TYPE s_out,
        ls_out_fis         TYPE s_out,
        ls_out_umb         TYPE s_out,
        ls_out_abc         TYPE s_out,
        ls_out_dummy       TYPE s_out,
        ls_mats            TYPE s_mats,
        ls_ckmlpp          TYPE ckmlpp,
        ls_ckmlcr          TYPE ckmlcr,
        ls_mlcd            TYPE mlcd,
        ls_mlcd_not_alloc  TYPE mlcd,
        ls_t001w           TYPE t001w,
        ls_t025t           TYPE t025t,
        ls_kalnr_t5        TYPE ckml_s_mgv_kalnr,
        ls_mat_bal         TYPE s_mat_bal,
        ls_bseg_out_ab     TYPE s_bseg_out,
        ls_bseg_out_prd    TYPE s_bseg_out,
        ls_bseg_out_pry    TYPE s_bseg_out,
        ls_bseg_out_umb    TYPE s_bseg_out,
        ls_bseg_out_vp     TYPE s_bseg_out,
        ls_bseg_out_vn     TYPE s_bseg_out,
        ls_bseg_out_cor    TYPE s_bseg_out,
        ls_bseg_out        TYPE s_bseg_out,
        ls_ckmlcr_act      TYPE ckmlcr,
        ls_coltab          TYPE slis_specialcol_alv,
        ls_mlavrscale      TYPE is_mlavrscale,
        ls_runperiod_prev  TYPE ckml_run_period_data,
        l_ab_menge         LIKE mlcd-lbkum,
        l_nin              TYPE boole_d,
        l_ndi              TYPE boole_d,
        l_limit            TYPE ckml_diff_ndi,
        l_sumdif_abs       TYPE ck_sum_dif,
        l_checksum         TYPE ck_sum_dif,
        l_ab_correction    TYPE ckml_estprd,
        l_kalnr_space      TYPE ck_kalnr,
        l_counter          TYPE i,
        l_part_ndi         TYPE f,
        BEGIN OF l_clear_values,
          pbprd_o TYPE ckmlcr-pbprd_o,
          pbkdm_o TYPE ckmlcr-pbkdm_o,
          estprd  TYPE ckml_estprd,
          estkdm  TYPE ckml_estkdm,
          mstprd  TYPE ckml_mstprd,
          mstkdm  TYPE ckml_mstkdm,
          estdif  TYPE ck_singlelevel_dif,
          mstdif  TYPE ck_multilevel_dif,
          prdif   TYPE ck_sum_prdif,
          krdif   TYPE ck_sum_krdif,
          sumdif  TYPE ck_sum_dif,
        END OF l_clear_values.
  DATA: ls_mlcd_vnprd_ea LIKE mlcd-salk3,
        ls_mlcd_vnkdm_ea LIKE mlcd-salk3,
        ls_mlcd_salk3    LIKE mlcd-salk3.

  CLEAR: l_clear_values.
  REFRESH: pt_out, ct_bseg_out.

  LOOP AT pt_mats INTO ls_mats WHERE mlast = '3'.
    REFRESH: lt_out.
    READ TABLE pt_ckmlpp INTO ls_ckmlpp
                         WITH KEY kalnr = ls_mats-kalnr
                                  bdatj = p_bdatj
                                  poper = p_poper
                                  untper = s_runperiod-untper
                                  BINARY SEARCH.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
    CLEAR: ls_out_ndi, ls_out_cum, ls_out_nin, ls_out_rsc, ls_out_nle,
           ls_out_eiv, ls_out_wip, ls_out_vno, ls_out_ost,
           ls_out_fia, ls_out_fis, ls_out_umb, ls_out_abc,
           ls_out_mls.
    ls_out_ndi-bukrs = t001-bukrs.
    ls_out_ndi-butxt = t001-butxt.
    ls_out_cum-bukrs = t001-bukrs.
    ls_out_cum-butxt = t001-butxt.
    MOVE-CORRESPONDING ls_ckmlpp TO ls_out_ndi.
    MOVE-CORRESPONDING ls_ckmlpp TO ls_out_cum.
    ls_out_cum-icon = icon_led_green.
    ls_out_cum-icon_settle = icon_led_inactive.
    ls_out_cum-icon_clo = icon_led_inactive.
    IF ls_ckmlpp-status >= '50'.
      ls_out_cum-icon_settle = icon_led_green.
      IF ls_ckmlpp-status = '70'.
        ls_out_cum-icon = icon_led_red.
        ls_out_cum-icon_clo = icon_led_green.
      ENDIF.
      READ TABLE pt_ckmlcr WITH KEY kalnr = ls_mats-kalnr
                                    bdatj = p_bdatj
                                    poper = p_poper
                                    untper = s_runperiod-untper
                                    BINARY SEARCH
                                    TRANSPORTING NO FIELDS.
      LOOP AT pt_ckmlcr INTO ls_ckmlcr FROM sy-tabix.
        IF ls_ckmlcr-kalnr <> ls_ckmlpp-kalnr OR
           ls_ckmlcr-bdatj <> ls_ckmlpp-bdatj OR
           ls_ckmlcr-poper <> ls_ckmlpp-poper OR
           ls_ckmlcr-untper <> ls_ckmlpp-untper.
          EXIT.
        ENDIF.
*       Werte aus voriger Währung löschen!
        MOVE-CORRESPONDING l_clear_values TO ls_out_ndi.
        MOVE-CORRESPONDING l_clear_values TO ls_out_cum.
        MOVE-CORRESPONDING ls_ckmlcr TO ls_out_ndi.
        MOVE-CORRESPONDING ls_ckmlcr TO ls_out_cum.

        MOVE-CORRESPONDING ls_out_ndi TO ls_out_nin.
        MOVE-CORRESPONDING ls_out_ndi TO ls_out_rsc.
        MOVE-CORRESPONDING ls_out_ndi TO ls_out_mls.
        MOVE-CORRESPONDING ls_out_ndi TO ls_out_nle.
        MOVE-CORRESPONDING ls_out_ndi TO ls_out_eiv.
        MOVE-CORRESPONDING ls_out_ndi TO ls_out_vno.
        MOVE-CORRESPONDING ls_out_ndi TO ls_out_ost.
        MOVE-CORRESPONDING ls_out_ndi TO ls_out_wip.
        MOVE-CORRESPONDING ls_out_ndi TO ls_out_fia.

*       Kumulierter Bestand
        ls_out_cum-estprd = ls_ckmlcr-abprd_o + ls_ckmlcr-zuprd_o +
                            ls_ckmlcr-vpprd_o.
        ls_out_cum-estkdm = ls_ckmlcr-abkdm_o + ls_ckmlcr-zukdm_o +
                            ls_ckmlcr-vpkdm_o.
*       ACHTUNG: Bei Status "Abschluss storniert" könnte das falsch
**       sein, da evtl. nur einstufig preisermittelt wurde!
**        IF ls_ckmlpp-status >= y_mehrstufig_abgerechnet.
*        IF ls_ckmlpp-status = y_abschlussbuchung_erfolgt.
*          ls_out_cum-mstprd = ls_ckmlcr-abprd_mo + ls_ckmlcr-zuprd_mo.
*          ls_out_cum-mstkdm = ls_ckmlcr-abkdm_mo + ls_ckmlcr-zukdm_mo.
*        ELSE.
*          ls_out_cum-mstprd = ls_ckmlcr-abprd_mo.
*          ls_out_cum-mstkdm = ls_ckmlcr-abkdm_mo.
*        ENDIF.
        ls_out_cum-mstprd = ls_ckmlcr-abprd_mo.
        ls_out_cum-mstkdm = ls_ckmlcr-abkdm_mo.
        ls_out_cum-sumdif = ls_out_cum-estprd + ls_out_cum-estkdm +
                            ls_out_cum-mstprd + ls_out_cum-mstkdm.

******* Gibt's eine 'Nicht verrechnet'-Zeile? **************************
        CLEAR: l_nin.
        READ TABLE pt_mlcd_not_alloc INTO ls_mlcd_not_alloc
                                     WITH KEY kalnr = ls_ckmlcr-kalnr
                                              bdatj = ls_ckmlcr-bdatj
                                              poper = ls_ckmlcr-poper
                                             untper = ls_ckmlcr-untper
                                              curtp = ls_ckmlcr-curtp
                                              BINARY SEARCH.
        IF sy-subrc = 0.
          ls_out_nin-estprd = ls_mlcd_not_alloc-estprd.
          ls_out_nin-estkdm = ls_mlcd_not_alloc-estkdm.
          ls_out_nin-mstprd = ls_mlcd_not_alloc-mstprd.
          ls_out_nin-mstkdm = ls_mlcd_not_alloc-mstkdm.
          ls_out_nin-sumdif = ls_out_nin-estprd + ls_out_nin-estkdm +
                              ls_out_nin-mstprd + ls_out_nin-mstkdm.
*         Liegt die Differenz über dem Schwellwert?
          l_sumdif_abs = abs( ls_out_nin-sumdif ).
          IF ls_out_nin-curtp = '10'.
            IF l_sumdif_abs > p_limnin.
              l_nin = 'X'.
            ENDIF.
          ELSE.
            CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
              EXPORTING
*               CLIENT           = SY-MANDT
                date             = sy-datum
                foreign_currency = ls_out_nin-waers
                local_amount     = p_limnin
                local_currency   = t001-waers
*               RATE             = 0
*               TYPE_OF_RATE     = 'M'
*               READ_TCURR       = 'X'
              IMPORTING
*               EXCHANGE_RATE    =
                foreign_amount   = l_limit
*               FOREIGN_FACTOR   =
*               LOCAL_FACTOR     =
*               EXCHANGE_RATEX   =
*               DERIVED_RATE_TYPE =
*               FIXED_RATE       =
              EXCEPTIONS
                no_rate_found    = 1
                overflow         = 2
                no_factors_found = 3
                no_spread_found  = 4
                derived_2_times  = 5
                OTHERS           = 6.
            IF sy-subrc = 0 AND l_sumdif_abs > l_limit.
              l_nin = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.

*       ls_ckmlcr, vnprd_ea, vnkdm_ea have rounding errors,
*       so we calculate them from MLCD
        CLEAR:
          ls_mlcd_vnprd_ea,
          ls_mlcd_vnkdm_ea.
        LOOP AT pt_mlcd INTO ls_mlcd
                                   WHERE    kalnr = ls_ckmlcr-kalnr
                                   AND      bdatj = ls_ckmlcr-bdatj
                                   AND      poper = ls_ckmlcr-poper
                                   AND      untper = ls_ckmlcr-untper
                                   AND      curtp = ls_ckmlcr-curtp
                                   AND      categ = 'VN'.
          ls_mlcd_vnprd_ea = ls_mlcd_vnprd_ea + ls_mlcd-estprd.
          ls_mlcd_vnkdm_ea = ls_mlcd_vnkdm_ea + ls_mlcd-estkdm.
          ls_mlcd_salk3    = ls_mlcd_salk3    + ls_mlcd-salk3.
        ENDLOOP.
        ls_ckmlcr-vnprd_ea = ls_mlcd_vnprd_ea.
        ls_ckmlcr-vnkdm_ea = ls_mlcd_vnkdm_ea.

******* Gibt's nicht verteilte Differenzen? ****************************

        CLEAR: l_ndi.

        ls_out_ndi-estprd = ls_out_cum-estprd.
        ls_out_ndi-estkdm = ls_out_cum-estkdm.
        ls_out_ndi-mstprd = ls_out_cum-mstprd.
        ls_out_ndi-mstkdm = ls_out_cum-mstkdm.
        ls_out_ndi-estprd = ls_out_ndi-estprd -
                            ( ls_ckmlcr-vnprd_ea + ls_ckmlcr-ebprd_ea +
                              ls_out_nin-estprd ).
        ls_out_ndi-estkdm = ls_out_ndi-estkdm -
                            ( ls_ckmlcr-vnkdm_ea + ls_ckmlcr-ebkdm_ea +
                              ls_out_nin-estkdm ).
        ls_out_ndi-mstprd = ls_out_ndi-mstprd -
                            ( ls_ckmlcr-vnprd_ma + ls_ckmlcr-ebprd_ma ).
        ls_out_ndi-mstkdm = ls_out_ndi-mstkdm -
                            ( ls_ckmlcr-vnkdm_ma + ls_ckmlcr-ebkdm_ma ).
        ls_out_ndi-sumdif = ls_out_ndi-estprd + ls_out_ndi-estkdm +
                            ls_out_ndi-mstprd + ls_out_ndi-mstkdm.

        IF ls_ckmlpp-vnkumo IS INITIAL and ls_mlcd_salk3 = '' AND l_nin = 'X'.
          ls_out_ndi-estprd = ls_out_ndi-estprd - ls_out_nin-estprd.
          ls_out_ndi-estkdm = ls_out_ndi-estkdm - ls_out_nin-estkdm.
          ls_out_ndi-mstprd = ls_out_ndi-mstprd - ls_out_nin-mstprd.
          ls_out_ndi-mstkdm = ls_out_ndi-mstkdm - ls_out_nin-mstkdm.
          ls_out_ndi-sumdif = ls_out_ndi-sumdif - ls_out_nin-sumdif.
        ENDIF.

*       Liegt die Differenz über dem Schwellwert?
        l_sumdif_abs = abs( ls_out_ndi-sumdif ).
        IF ls_out_ndi-curtp = '10'.
          IF l_sumdif_abs > p_limndi.
            l_ndi = 'X'.
          ENDIF.
        ELSE.
          CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
            EXPORTING
*             CLIENT           = SY-MANDT
              date             = sy-datum
              foreign_currency = ls_out_ndi-waers
              local_amount     = p_limndi
              local_currency   = t001-waers
*             RATE             = 0
*             TYPE_OF_RATE     = 'M'
*             READ_TCURR       = 'X'
            IMPORTING
*             EXCHANGE_RATE    =
              foreign_amount   = l_limit
*             FOREIGN_FACTOR   =
*             LOCAL_FACTOR     =
*             EXCHANGE_RATEX   =
*             DERIVED_RATE_TYPE =
*             FIXED_RATE       =
            EXCEPTIONS
              no_rate_found    = 1
              overflow         = 2
              no_factors_found = 3
              no_spread_found  = 4
              derived_2_times  = 5
              OTHERS           = 6.
          IF sy-subrc = 0 AND l_sumdif_abs > l_limit.
            l_ndi = 'X'.
          ENDIF.
        ENDIF.

******* Was sind einstufige bzw. mehrstufige Alternativen/Prozesse? ****
        REFRESH: lt_kalnr_t5.
        READ TABLE pt_mlcd WITH KEY kalnr = ls_mats-kalnr
                                    bdatj = p_bdatj
                                    poper = p_poper
                                    untper = s_runperiod-untper
                                    categ = 'VN'
                                    curtp = ls_ckmlcr-curtp
                              BINARY SEARCH
                              TRANSPORTING NO FIELDS.

        LOOP AT pt_mlcd INTO ls_mlcd FROM sy-tabix.
          IF ls_mlcd-kalnr <> ls_mats-kalnr OR
             ls_mlcd-bdatj <> p_bdatj OR
             ls_mlcd-poper <> p_poper OR
             ls_mlcd-untper <> s_runperiod-untper OR
             ls_mlcd-categ <> 'VN' OR
             ls_mlcd-curtp <> ls_ckmlcr-curtp.
            EXIT.
          ENDIF.
          ls_kalnr_t5-kalnr = ls_mlcd-bvalt.
          APPEND ls_kalnr_t5 TO lt_kalnr_t5.
        ENDLOOP.

        CALL FUNCTION 'CKML_T5_BUFFER_CLEAR'.

        CALL FUNCTION 'CKML_BUF_T5_SINGLE_READ'
          EXPORTING
            it_kalnr         = lt_kalnr_t5
          IMPORTING
            et_t005_extended = lt_t005_extended.

        SORT lt_t005_extended BY kalnr.

*       Wie steht's um die Verbrauchsnachbewertung bzw. nächste Stufe? Oder WIP?
        READ TABLE pt_mlcd WITH KEY kalnr = ls_mats-kalnr
                                    bdatj = p_bdatj
                                    poper = p_poper
                                    untper = s_runperiod-untper
                                    categ = 'VN'
                                    curtp = ls_ckmlcr-curtp
                              BINARY SEARCH
                              TRANSPORTING NO FIELDS.
        LOOP AT pt_mlcd INTO ls_mlcd FROM sy-tabix.
          IF ls_mlcd-kalnr <> ls_mats-kalnr OR
             ls_mlcd-bdatj <> p_bdatj OR
             ls_mlcd-poper <> p_poper OR
             ls_mlcd-untper <> s_runperiod-untper OR
             ls_mlcd-categ <> 'VN' OR
             ls_mlcd-curtp <> ls_ckmlcr-curtp.
            EXIT.
          ENDIF.
          IF ls_mlcd-ptyp = 'VW'.
            ls_out_wip-estprd = ls_out_wip-estprd + ls_mlcd-estprd.
            ls_out_wip-estkdm = ls_out_wip-estkdm + ls_mlcd-estkdm.
            ls_out_wip-mstprd = ls_out_wip-mstprd + ls_mlcd-mstprd.
            ls_out_wip-mstkdm = ls_out_wip-mstkdm + ls_mlcd-mstkdm.
            ls_out_wip-sumdif = ls_out_wip-estprd + ls_out_wip-estkdm +
                                ls_out_wip-mstprd + ls_out_wip-mstkdm.
          ELSE.
            READ TABLE lt_t005_extended WITH KEY kalnr = ls_mlcd-bvalt
             BINARY SEARCH TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
*             Ein einstufiger Verbrauch
              ls_out_rsc-estprd = ls_out_rsc-estprd + ls_mlcd-estprd.
              ls_out_rsc-estkdm = ls_out_rsc-estkdm + ls_mlcd-estkdm.
              ls_out_rsc-mstprd = ls_out_rsc-mstprd + ls_mlcd-mstprd.
              ls_out_rsc-mstkdm = ls_out_rsc-mstkdm + ls_mlcd-mstkdm.
              ls_out_rsc-sumdif = ls_out_rsc-estprd + ls_out_rsc-estkdm +
                                  ls_out_rsc-mstprd + ls_out_rsc-mstkdm.
            ELSE.
*             Ein mehrstufiger Verbrauch
              ls_out_nle-estprd = ls_out_nle-estprd + ls_mlcd-estprd.
              ls_out_nle-estkdm = ls_out_nle-estkdm + ls_mlcd-estkdm.
              ls_out_nle-mstprd = ls_out_nle-mstprd + ls_mlcd-mstprd.
              ls_out_nle-mstkdm = ls_out_nle-mstkdm + ls_mlcd-mstkdm.
              ls_out_nle-sumdif = ls_out_nle-estprd + ls_out_nle-estkdm +
                                  ls_out_nle-mstprd + ls_out_nle-mstkdm.
            ENDIF.
          ENDIF.
        ENDLOOP.
******* Endbestand, huhu? **********************************************
        ls_out_eiv-estprd = ls_ckmlcr-ebprd_ea.
        ls_out_eiv-estkdm = ls_ckmlcr-ebkdm_ea.
        ls_out_eiv-mstprd = ls_ckmlcr-ebprd_ma.
        ls_out_eiv-mstkdm = ls_ckmlcr-ebkdm_ma.
        ls_out_eiv-sumdif = ls_out_eiv-estprd + ls_out_eiv-estkdm +
                            ls_out_eiv-mstprd + ls_out_eiv-mstkdm.
******* Hallo Abgänge! *************************************************
** Nicht preisbildende Abgänge gibt es nur in der alten Logik.
** Daher wird nur im Fall der Migrationsperiode oder der Periode vor der Migration
** in der alten CKMLCR der entsprechende Wert gelesen.
        DATA: ls_ckmlcr_old TYPE ckmlcr.

        IF mig_poper = 'X'.
          SELECT SINGLE * FROM ckmlcr INTO ls_ckmlcr_old
                  WHERE kalnr = ls_ckmlcr-kalnr
                  AND   bdatj = ls_ckmlcr-bdatj
                  AND   poper = ls_ckmlcr-poper
                  AND   untper = ls_ckmlcr-untper
                  AND   curtp  = ls_ckmlcr-curtp.
          ls_out_vno-estprd = ls_ckmlcr_old-vnprd_o.
          ls_out_vno-estkdm = ls_ckmlcr_old-vnkdm_o.
        ELSE.
*          ls_out_vno-estprd = ls_ckmlcr-vnprd_o.
*          ls_out_vno-estkdm = ls_ckmlcr-vnkdm_o.
        ENDIF.

        ls_out_vno-sumdif = ls_out_vno-estprd + ls_out_vno-estkdm.

******* nicht bestandsrelevante kursdifferenzen***************************
        ls_out_ost-estkdm = ls_ckmlcr-zukdm_ost + ls_ckmlcr-vnkdm_ost.
        ls_out_ost-sumdif = ls_out_ost-estkdm.
******* Und der FI Saldo! **********************************************
        IF NOT p_fiacc IS INITIAL.
          MOVE-CORRESPONDING ls_out_fia TO ls_out_fis.
          MOVE-CORRESPONDING ls_out_fia TO ls_out_umb.
          MOVE-CORRESPONDING ls_out_fia TO ls_out_abc.
          READ TABLE pt_mat_bal INTO ls_mat_bal
                                WITH KEY kalnr = ls_mats-kalnr
                                BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_ckmlcr-curtp = '10'.
              ls_out_fia-estprd = ls_mat_bal-balance.
            ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
              ls_out_fia-estprd = ls_mat_bal-balance2.
            ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
              ls_out_fia-estprd = ls_mat_bal-balance3.
            ENDIF.
          ELSE.
            CLEAR: ls_out_fia-estprd.
          ENDIF.
**         Kumulation!
*          IF NOT s_runperiod-untper IS INITIAL.
**           ABCO nur ermitteln, falls Vorgängerlauf nicht bucht.
*            CLEAR: ls_runperiod_prev.
*            IF NOT s_runperiod-prev_run_id IS INITIAL.
*              CALL FUNCTION 'CKML_RUN_PERIOD_GET'
*                EXPORTING
*                  i_run_id         = s_runperiod-prev_run_id
*                IMPORTING
*                  es_runperiod     = ls_runperiod_prev
*                EXCEPTIONS
*                  run_not_existent = 1
*                  OTHERS           = 2.
*              IF sy-subrc <> 0.
*                CLEAR: ls_runperiod_prev.
*              ENDIF.
*            ENDIF.
*            IF ls_runperiod_prev-xposting IS INITIAL.
**           Korrektur des Saldo's um fehlende Anfangsbestandsdifferenzen
*              READ TABLE pt_ckmlcr_act INTO ls_ckmlcr_act
*                         WITH KEY kalnr = ls_mats-kalnr
*                                  bdatj = s_runperiod-from_gjahr
*                                  poper = s_runperiod-from_poper
*                                 untper = '000'
*                                  curtp = ls_ckmlcr-curtp
*                                  BINARY SEARCH.
*              READ TABLE pt_mlavrscale INTO ls_mlavrscale
*                         WITH KEY run_id = s_runperiod-run_id
**                      with key run_id = '000000000154'
*                                  kalnr_in = ls_mats-kalnr
*                                  curtp_in = ls_ckmlcr-curtp
*                                  categ = 'AB'
*                                  BINARY SEARCH.
*              IF sy-subrc <> 0.
*                CLEAR: ls_mlavrscale.
*              ENDIF.
*              l_ab_correction = ls_ckmlcr-abprd_o +
*                                ls_ckmlcr-abkdm_o +
*                                ls_ckmlcr-abprd_mo +
*                                ls_ckmlcr-abkdm_mo -
*                                ls_mlavrscale-diff_in -
*                                ls_ckmlcr_act-abprd_o -
*                                ls_ckmlcr_act-abkdm_o -
*                                ls_ckmlcr_act-abprd_mo -
*                                ls_ckmlcr_act-abkdm_mo -
*                                ls_ckmlcr_act-zuumb_o.
*              ls_out_fia-estprd = ls_out_fia-estprd + l_ab_correction.
*              ls_out_umb-estprd = 0 - ls_ckmlcr_act-zuumb_o.
*              ls_out_umb-sumdif = ls_out_umb-estprd.
*              ls_out_abc-estprd = l_ab_correction + ls_ckmlcr_act-zuumb_o.
*              ls_out_abc-sumdif = ls_out_abc-estprd.
*              IF ls_ckmlcr-curtp = '10'.
*                CLEAR: ls_bseg_out_ab, ls_coltab.
*                ls_bseg_out_ab-matnr = ls_mats-matnr.
*                ls_bseg_out_ab-bwkey = ls_mats-bwkey.
*                ls_bseg_out_ab-bwtar = ls_mats-bwtar.
*                ls_bseg_out_ab-dmbtr = l_ab_correction.
*                ls_bseg_out_ab-waers = ls_ckmlcr-waers.
*                ls_bseg_out_ab-ktosl = 'AB'.
*                ls_bseg_out_ab-glvor = 'ABCO'.
*                ls_coltab-color-col = '6'.
**                ls_coltab-nokeycol = 'X'.
**                REFRESH: ls_bseg_out_ab-coltab.
**                APPEND ls_coltab TO ls_bseg_out_ab-coltab.
*              ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
*                ls_bseg_out_ab-dmbe2 = l_ab_correction.
*              ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
*                ls_bseg_out_ab-dmbe3 = l_ab_correction.
*              ENDIF.
*            ENDIF.
*          ENDIF.
          ls_out_fia-sumdif = ls_out_fia-estprd.
          IF ls_ckmlpp-status = y_abschlussbuchung_erfolgt.
            l_checksum = ls_out_ndi-sumdif + ls_out_nin-sumdif +
                         ls_out_vno-sumdif + ls_out_ost-sumdif.
          ELSE.
            l_checksum = ls_out_cum-sumdif + ls_out_ost-sumdif - ls_ckmlcr-zuprd_mo - ls_ckmlcr-zukdm_mo.
          ENDIF.
          IF ls_out_fia-sumdif <> l_checksum.
            ls_out_cum-icon_fia = icon_led_red.
            ls_out_fis-estprd = l_checksum - ls_out_fia-sumdif.
            ls_out_fis-sumdif = ls_out_fis-estprd.
          ELSE.
            ls_out_cum-icon_fia = icon_led_green.
          ENDIF.
*         ML balance
          IF ls_ckmlpp-status = y_abschlussbuchung_erfolgt.
            ls_out_mls-estprd = ls_out_ndi-estprd + ls_out_nin-estprd +
                                ls_out_vno-estprd.
            ls_out_mls-estkdm = ls_out_ndi-estkdm + ls_out_nin-estkdm +
                               ls_out_vno-estkdm + ls_out_ost-estkdm.
            ls_out_mls-mstprd = ls_out_ndi-mstprd + ls_out_nin-mstprd +
             ls_out_vno-mstprd.
            ls_out_mls-mstkdm = ls_out_ndi-mstkdm + ls_out_nin-mstkdm +
                                ls_out_vno-mstkdm.
*            ls_out_mls-prdif  = ls_out_ndi-prdif + ls_out_nin-prdif +
*                                ls_out_vno-prdif.
*            ls_out_mls-krdif  = ls_out_ndi-krdif + ls_out_nin-krdif +
*                                ls_out_vno-krdif.
            ls_out_mls-sumdif = ls_out_ndi-sumdif + ls_out_nin-sumdif +
                                ls_out_vno-sumdif + ls_out_ost-sumdif.
          ELSE.
            ls_out_mls-estprd = ls_out_cum-estprd - ls_ckmlcr-zuprd_mo.
            ls_out_mls-estkdm = ls_out_cum-estkdm + ls_out_ost-estkdm - ls_ckmlcr-zukdm_mo.
            ls_out_mls-mstprd = ls_out_cum-mstprd.
            ls_out_mls-mstkdm = ls_out_cum-mstkdm.
*            ls_out_mls-prdif  = ls_out_cum-prdif.
*            ls_out_mls-krdif  = ls_out_cum-krdif.
            ls_out_mls-sumdif = ls_out_cum-sumdif + ls_out_ost-sumdif - ls_ckmlcr-zuprd_mo - ls_ckmlcr-zukdm_mo.
          ENDIF.
          CLEAR: ls_out_cum-rescale.
*         Rescaling flag
          READ TABLE pt_mlavrscale WITH KEY run_id = s_runperiod-run_id
                                            kalnr_in = ls_mats-kalnr
                                   BINARY SEARCH TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            ls_out_cum-rescale = 'X'.
          ENDIF.
*         Rescaling differences in FI postings
          IF ls_ckmlcr-curtp = '10'.
            CLEAR: ls_bseg_out_prd, ls_bseg_out_pry,
                   ls_bseg_out_umb, ls_bseg_out_vp,
                   ls_bseg_out_vn, ls_coltab.
            ls_bseg_out_prd-matnr = ls_mats-matnr.
            ls_bseg_out_prd-bwkey = ls_mats-bwkey.
            ls_bseg_out_prd-bwtar = ls_mats-bwtar.
            ls_bseg_out_prd-budat = '99999999'.
            ls_bseg_out_prd-waers = ls_ckmlcr-waers.
*            ls_coltab-color-col = '6'.
*            ls_coltab-nokeycol = 'X'.
*            REFRESH: ls_bseg_out_prd-coltab.
*            APPEND ls_coltab TO ls_bseg_out_prd-coltab.
            MOVE-CORRESPONDING ls_bseg_out_prd TO ls_bseg_out_pry.
            MOVE-CORRESPONDING ls_bseg_out_prd TO ls_bseg_out_umb.
            MOVE-CORRESPONDING ls_bseg_out_prd TO ls_bseg_out_vp.
            MOVE-CORRESPONDING ls_bseg_out_prd TO ls_bseg_out_vn.
          ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
            CLEAR: ls_bseg_out_prd-dmbe2,
                   ls_bseg_out_pry-dmbe2,
                   ls_bseg_out_umb-dmbe2,
                   ls_bseg_out_vp-dmbe2,
                   ls_bseg_out_vn-dmbe2.
          ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
            CLEAR: ls_bseg_out_prd-dmbe3,
                   ls_bseg_out_pry-dmbe3,
                   ls_bseg_out_umb-dmbe3,
                   ls_bseg_out_vp-dmbe3,
                   ls_bseg_out_vn-dmbe3.
          ENDIF.
          READ TABLE pt_mlavrscale
                     WITH KEY run_id = s_runperiod-run_id
                              kalnr_in = ls_mats-kalnr
                              curtp_in = ls_ckmlcr-curtp
                              BINARY SEARCH
                              TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            LOOP AT pt_mlavrscale INTO ls_mlavrscale FROM sy-tabix.
              IF ls_mlavrscale-run_id <> s_runperiod-run_id OR
                 ls_mlavrscale-kalnr_in <> ls_mats-kalnr OR
                 ls_mlavrscale-curtp_in <> ls_ckmlcr-curtp.
                EXIT.
              ENDIF.
              IF ( ls_mlavrscale-categ = 'ZU' AND
                   ls_mlavrscale-kalnr_ba IS INITIAL ) OR
                 ls_mlavrscale-categ = space.
                ls_bseg_out_prd-ktosl = 'PRD'.
                ls_bseg_out_prd-glvor = 'PRDR'.
                ls_bseg_out_prd-text = TEXT-029.
                IF ls_ckmlcr-curtp = '10'.
                  ls_bseg_out_prd-dmbtr = ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
                  ls_bseg_out_prd-dmbe2 = ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
                  ls_bseg_out_prd-dmbe3 = ls_mlavrscale-diff_in.
                ENDIF.
              ELSEIF ls_mlavrscale-categ = 'AB'.
                ls_bseg_out_umb-ktosl = 'AB'.
                ls_bseg_out_umb-glvor = 'ABRE'.
                ls_bseg_out_prd-text = TEXT-030.
                IF ls_ckmlcr-curtp = '10'.
                  ls_bseg_out_umb-dmbtr = ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
                  ls_bseg_out_umb-dmbe2 = ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
                  ls_bseg_out_umb-dmbe3 = ls_mlavrscale-diff_in.
                ENDIF.
              ELSEIF ls_mlavrscale-categ = 'ZU' AND
                     NOT ls_mlavrscale-kalnr_ba IS INITIAL.
                ls_bseg_out_pry-ktosl = 'PRY'.
                ls_bseg_out_pry-glvor = 'PRYR'.
                ls_bseg_out_prd-text = TEXT-031.
                IF ls_ckmlcr-curtp = '10'.
                  ls_bseg_out_pry-dmbtr = ls_bseg_out_pry-dmbtr +
                                          ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
                  ls_bseg_out_pry-dmbe2 = ls_bseg_out_pry-dmbe2 +
                                          ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
                  ls_bseg_out_pry-dmbe3 = ls_bseg_out_pry-dmbe3 +
                                          ls_mlavrscale-diff_in.
                ENDIF.
              ELSEIF ls_mlavrscale-categ = 'VP'.
                ls_bseg_out_vp-ktosl = 'VP'.
                ls_bseg_out_vp-glvor = 'VPRE'.
                ls_bseg_out_prd-text = TEXT-032.
                IF ls_ckmlcr-curtp = '10'.
                  ls_bseg_out_vp-dmbtr = ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
                  ls_bseg_out_vp-dmbe2 = ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
                  ls_bseg_out_vp-dmbe3 = ls_mlavrscale-diff_in.
                ENDIF.
              ELSEIF ls_mlavrscale-categ = 'VN' AND
                     NOT ls_mlavrscale-kalnr_ba IS INITIAL.
                ls_bseg_out_vn-ktosl = 'PRY'.
                ls_bseg_out_vn-glvor = 'VNRE'.
                ls_bseg_out_prd-text = TEXT-033.
                IF ls_ckmlcr-curtp = '10'.
                  ls_bseg_out_vn-dmbtr = ls_bseg_out_vn-dmbtr +
                                          ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
                  ls_bseg_out_vn-dmbe2 = ls_bseg_out_vn-dmbe2 +
                                          ls_mlavrscale-diff_in.
                ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
                  ls_bseg_out_vn-dmbe3 = ls_bseg_out_vn-dmbe3 +
                                          ls_mlavrscale-diff_in.


                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.

******* So, die relevanten Zeilen werden erzeugt! **********************

        IF NOT l_ndi IS INITIAL OR NOT l_nin IS INITIAL
           OR NOT p_all IS INITIAL.
          MOVE-CORRESPONDING ls_mats TO ls_out_ndi.
          MOVE-CORRESPONDING ls_mats TO ls_out_cum.
          MOVE-CORRESPONDING ls_mats TO ls_out_mls.
          MOVE-CORRESPONDING ls_mats TO ls_out_nin.
          MOVE-CORRESPONDING ls_mats TO ls_out_rsc.
          MOVE-CORRESPONDING ls_mats TO ls_out_nle.
          MOVE-CORRESPONDING ls_mats TO ls_out_eiv.
          MOVE-CORRESPONDING ls_mats TO ls_out_vno.
          MOVE-CORRESPONDING ls_mats TO ls_out_ost.
          MOVE-CORRESPONDING ls_mats TO ls_out_wip.
          MOVE-CORRESPONDING ls_mats TO ls_out_fia.
          MOVE-CORRESPONDING ls_mats TO ls_out_fis.
          MOVE-CORRESPONDING ls_mats TO ls_out_umb.
          MOVE-CORRESPONDING ls_mats TO ls_out_abc.
          CALL FUNCTION 'T025T_SINGLE_READ'
            EXPORTING
*             KZRFB       = ' '
              t025t_spras = sy-langu
              t025t_bklas = ls_mats-bklas
            IMPORTING
              wt025t      = ls_t025t
            EXCEPTIONS
              not_found   = 1
              OTHERS      = 2.
          IF sy-subrc = 0.
            ls_out_ndi-bkbez = ls_t025t-bkbez.
            ls_out_cum-bkbez = ls_t025t-bkbez.
            ls_out_mls-bkbez = ls_t025t-bkbez.
            ls_out_nin-bkbez = ls_t025t-bkbez.
            ls_out_mls-bkbez = ls_t025t-bkbez.
            ls_out_rsc-bkbez = ls_t025t-bkbez.
            ls_out_nle-bkbez = ls_t025t-bkbez.
            ls_out_eiv-bkbez = ls_t025t-bkbez.
            ls_out_vno-bkbez = ls_t025t-bkbez.
            ls_out_ost-bkbez = ls_t025t-bkbez.
            ls_out_wip-bkbez = ls_t025t-bkbez.
            ls_out_fia-bkbez = ls_t025t-bkbez.
            ls_out_fis-bkbez = ls_t025t-bkbez.
            ls_out_umb-bkbez = ls_t025t-bkbez.
            ls_out_abc-bkbez = ls_t025t-bkbez.
          ENDIF.
          IF tcurm-bwkrs_cus <> '3'.            "Bewertungsebene WERKS
            ls_out_ndi-werks = ls_mats-bwkey.
            ls_out_cum-werks = ls_mats-bwkey.
            ls_out_nin-werks = ls_mats-bwkey.
            ls_out_mls-werks = ls_mats-bwkey.
            ls_out_rsc-werks = ls_mats-bwkey.
            ls_out_nle-werks = ls_mats-bwkey.
            ls_out_eiv-werks = ls_mats-bwkey.
            ls_out_vno-werks = ls_mats-bwkey.
            ls_out_ost-werks = ls_mats-bwkey.
            ls_out_wip-werks = ls_mats-bwkey.
            ls_out_fia-werks = ls_mats-bwkey.
            ls_out_fis-werks = ls_mats-bwkey.
            ls_out_umb-werks = ls_mats-bwkey.
            ls_out_abc-werks = ls_mats-bwkey.
            CALL FUNCTION 'T001W_SINGLE_READ'
              EXPORTING
*               KZRFB       = ' '
                t001w_werks = ls_out_ndi-werks
              IMPORTING
                wt001w      = ls_t001w
              EXCEPTIONS
                not_found   = 1
                OTHERS      = 2.
            ls_out_ndi-name1 = ls_t001w-name1.
            ls_out_cum-name1 = ls_t001w-name1.
            ls_out_nin-name1 = ls_t001w-name1.
            ls_out_mls-name1 = ls_t001w-name1.
            ls_out_rsc-name1 = ls_t001w-name1.
            ls_out_nle-name1 = ls_t001w-name1.
            ls_out_eiv-name1 = ls_t001w-name1.
            ls_out_vno-name1 = ls_t001w-name1.
            ls_out_ost-name1 = ls_t001w-name1.
            ls_out_wip-name1 = ls_t001w-name1.
            ls_out_fia-name1 = ls_t001w-name1.
            ls_out_fis-name1 = ls_t001w-name1.
            ls_out_umb-name1 = ls_t001w-name1.
            ls_out_abc-name1 = ls_t001w-name1.
          ENDIF.
********* Nicht verteilt ***********************************************
          IF NOT l_ndi IS INITIAL.
            ls_out_ndi-pos_type = 'NDI'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_ndi-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_ndi-pos_type_text = t_dd07v-ddtext.
            ls_out_ndi-prdif = ls_out_ndi-estprd + ls_out_ndi-mstprd.
            ls_out_ndi-krdif = ls_out_ndi-estkdm + ls_out_ndi-mstkdm.
            ls_out_ndi-estdif = ls_out_ndi-estprd + ls_out_ndi-estkdm.
            ls_out_ndi-mstdif = ls_out_ndi-mstprd + ls_out_ndi-mstkdm.
            APPEND ls_out_ndi TO lt_out.
          ENDIF.
********* Kumuliert ****************************************************
          ls_out_cum-pos_type = 'CUM'.
          READ TABLE t_dd07v
                     WITH KEY domvalue_l = ls_out_cum-pos_type.
          IF sy-subrc <> 0.
            CLEAR t_dd07v.
          ENDIF.
          ls_out_cum-pos_type_text = t_dd07v-ddtext.
*         Anfangsbestands-Menge (Rückbuchungen) aus MLCD
          CLEAR: l_ab_menge.
          READ TABLE pt_mlcd WITH KEY kalnr = ls_ckmlcr-kalnr
                            bdatj = ls_ckmlcr-bdatj
                            poper = ls_ckmlcr-poper
                            untper = ls_ckmlcr-untper
                            categ = 'AB'
                            curtp = ls_ckmlcr-curtp
                      BINARY SEARCH
                      TRANSPORTING NO FIELDS.
          LOOP AT pt_mlcd INTO ls_mlcd FROM sy-tabix.
            IF ls_mlcd-kalnr <> ls_ckmlcr-kalnr OR
               ls_mlcd-bdatj <> ls_ckmlcr-bdatj OR
               ls_mlcd-poper <> ls_ckmlcr-poper OR
               ls_mlcd-untper <> ls_ckmlcr-untper OR
               ls_mlcd-categ <> 'AB' OR
               ls_mlcd-curtp <> ls_ckmlcr-curtp.
              EXIT.
            ENDIF.
            l_ab_menge = l_ab_menge + ls_mlcd-lbkum.
          ENDLOOP.
          ls_out_cum-prdif = ls_out_cum-estprd + ls_out_cum-mstprd.
          ls_out_cum-krdif = ls_out_cum-estkdm + ls_out_cum-mstkdm.
          ls_out_cum-estdif = ls_out_cum-estprd + ls_out_cum-estkdm.
          ls_out_cum-mstdif = ls_out_cum-mstprd + ls_out_cum-mstkdm.
          ls_out_cum-quantity_cum = ls_ckmlpp-abkumo +
                                    ls_ckmlpp-zukumo +
                                    ls_ckmlpp-vpkumo + l_ab_menge.
          ls_out_cum-value_cum = ls_out_cum-quantity_cum *
                                 ls_out_cum-stprs / ls_out_cum-peinh.
          IF ls_out_cum-quantity_cum <> 0.
            CATCH SYSTEM-EXCEPTIONS conversion_errors = 1
                                    arithmetic_errors = 2.
              ls_out_cum-price_cum = ls_out_cum-stprs +
                            ( ( ( ls_out_cum-sumdif - ls_out_ndi-sumdif ) /
                                       ls_out_cum-quantity_cum ) *
                                       ls_out_cum-peinh ).
            ENDCATCH.
            IF sy-subrc <> 0.
              ls_out_cum-price_cum = '999999999.99'.
            ENDIF.
            CATCH SYSTEM-EXCEPTIONS conversion_errors = 1
                                    arithmetic_errors = 2.
              ls_out_cum-pb_price = ls_out_cum-stprs +
                       ( ( ls_out_cum-sumdif / ls_out_cum-quantity_cum ) *
                                    ls_out_cum-peinh ).
            ENDCATCH.
            IF sy-subrc <> 0.
              ls_out_cum-pb_price = '999999999.99'.
            ENDIF.
          ENDIF.
          IF ls_out_cum-pb_price < 0.
            ls_out_cum-icon = icon_led_red.
          ENDIF.
          APPEND ls_out_cum TO lt_out.
********* Nicht verrechnet *********************************************
          IF NOT l_nin IS INITIAL.
            ls_out_nin-pos_type = 'NIN'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_nin-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_nin-pos_type_text = t_dd07v-ddtext.
            ls_out_nin-prdif = ls_out_nin-estprd + ls_out_nin-mstprd.
            ls_out_nin-krdif = ls_out_nin-estkdm + ls_out_nin-mstkdm.
            ls_out_nin-estdif = ls_out_nin-estprd + ls_out_nin-estkdm.
            ls_out_nin-mstdif = ls_out_nin-mstprd + ls_out_nin-mstkdm.
            APPEND ls_out_nin TO lt_out.
          ENDIF.
********* Verbrauchsnachbewertung **************************************
          IF NOT ls_out_rsc-sumdif IS INITIAL.
            ls_out_rsc-pos_type = 'RSC'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_rsc-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_rsc-pos_type_text = t_dd07v-ddtext.
            ls_out_rsc-prdif = ls_out_rsc-estprd + ls_out_rsc-mstprd.
            ls_out_rsc-krdif = ls_out_rsc-estkdm + ls_out_rsc-mstkdm.
            ls_out_rsc-estdif = ls_out_rsc-estprd + ls_out_rsc-estkdm.
            ls_out_rsc-mstdif = ls_out_rsc-mstprd + ls_out_rsc-mstkdm.
            APPEND ls_out_rsc TO lt_out.
          ENDIF.
********* WIP-Nachbewertung ********************************************
          IF NOT ls_out_wip-sumdif IS INITIAL.
            ls_out_wip-pos_type = 'WIP'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_wip-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_wip-pos_type_text = t_dd07v-ddtext.
            ls_out_wip-prdif = ls_out_wip-estprd + ls_out_wip-mstprd.
            ls_out_wip-krdif = ls_out_wip-estkdm + ls_out_wip-mstkdm.
            ls_out_wip-estdif = ls_out_wip-estprd + ls_out_wip-estkdm.
            ls_out_wip-mstdif = ls_out_wip-mstprd + ls_out_wip-mstkdm.
            APPEND ls_out_wip TO lt_out.
          ENDIF.
********* Nächste Stufe ************************************************
          IF NOT ls_out_nle-sumdif IS INITIAL.
            ls_out_nle-pos_type = 'NLE'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_nle-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_nle-pos_type_text = t_dd07v-ddtext.
            ls_out_nle-prdif = ls_out_nle-estprd + ls_out_nle-mstprd.
            ls_out_nle-krdif = ls_out_nle-estkdm + ls_out_nle-mstkdm.
            ls_out_nle-estdif = ls_out_nle-estprd + ls_out_nle-estkdm.
            ls_out_nle-mstdif = ls_out_nle-mstprd + ls_out_nle-mstkdm.
            APPEND ls_out_nle TO lt_out.
          ENDIF.
********* Endbestand ***************************************************
          IF NOT ls_out_eiv-sumdif IS INITIAL.
            ls_out_eiv-pos_type = 'EIV'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_eiv-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_eiv-pos_type_text = t_dd07v-ddtext.
            ls_out_eiv-prdif = ls_out_eiv-estprd + ls_out_eiv-mstprd.
            ls_out_eiv-krdif = ls_out_eiv-estkdm + ls_out_eiv-mstkdm.
            ls_out_eiv-estdif = ls_out_eiv-estprd + ls_out_eiv-estkdm.
            ls_out_eiv-mstdif = ls_out_eiv-mstprd + ls_out_eiv-mstkdm.
            APPEND ls_out_eiv TO lt_out.
          ENDIF.
********* Abgänge ******************************************************
          IF NOT ls_out_vno-sumdif IS INITIAL.
            ls_out_vno-pos_type = 'VNO'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_vno-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_vno-pos_type_text = t_dd07v-ddtext.
            ls_out_vno-prdif = ls_out_vno-estprd.
            ls_out_vno-krdif = ls_out_vno-estkdm.
            ls_out_vno-estdif = ls_out_vno-estprd + ls_out_vno-estkdm.
            APPEND ls_out_vno TO lt_out.
          ENDIF.
********* nicht bestandsrelevante Kursdifferenzen ******
          IF NOT ls_out_ost-sumdif IS INITIAL.
            ls_out_ost-pos_type = 'OST'.
            ls_out_ost-pos_type_text = TEXT-059.
            ls_out_ost-krdif = ls_out_ost-estkdm.
            ls_out_ost-estdif = ls_out_ost-estkdm.
            APPEND ls_out_ost TO lt_out.
          ENDIF.
********* ML Saldo *************************************
          IF NOT ls_out_mls-sumdif IS INITIAL.
            ls_out_mls-pos_type = 'MLS'.
            ls_out_mls-pos_type_text = TEXT-038.
            ls_out_mls-prdif  = ls_out_mls-estprd + ls_out_mls-mstprd.
            ls_out_mls-krdif  = ls_out_mls-estkdm + ls_out_mls-mstkdm.

            APPEND ls_out_mls TO lt_out.
          ENDIF.
********* FI Saldo *****************************************************
          IF NOT ls_out_fia-sumdif IS INITIAL.
            ls_out_fia-pos_type = 'FIA'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_fia-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_fia-pos_type_text = t_dd07v-ddtext.
            ls_out_fia-prdif = ls_out_fia-estprd.
            ls_out_fia-estdif = ls_out_fia-estprd.
            APPEND ls_out_fia TO lt_out.
          ENDIF.
          IF NOT ls_out_fis-sumdif IS INITIAL.
            ls_out_fis-pos_type = 'FIS'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_fis-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_fis-pos_type_text = t_dd07v-ddtext.
            ls_out_fis-prdif = ls_out_fis-estprd.
            ls_out_fis-estdif = ls_out_fis-estprd.
            APPEND ls_out_fis TO lt_out.
          ENDIF.
          IF NOT ls_out_umb-sumdif IS INITIAL.
            ls_out_umb-pos_type = 'UMB'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_umb-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_umb-pos_type_text = t_dd07v-ddtext.
            ls_out_umb-prdif = ls_out_umb-estprd.
            ls_out_umb-estdif = ls_out_umb-estprd.
            APPEND ls_out_umb TO lt_out.
          ENDIF.
          IF NOT ls_out_abc-sumdif IS INITIAL.
            ls_out_abc-pos_type = 'ABC'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_abc-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_abc-pos_type_text = t_dd07v-ddtext.
            ls_out_abc-prdif = ls_out_abc-estprd.
            ls_out_abc-estdif = ls_out_abc-estprd.
            APPEND ls_out_abc TO lt_out.
          ENDIF.
        ENDIF.
      ENDLOOP.
*     Wenn alle Währungen eines Materials durch sind...
      IF sy-subrc = 0.
        IF NOT ls_bseg_out_ab-ktosl IS INITIAL.
          APPEND ls_bseg_out_ab TO ct_bseg_out.
        ENDIF.
        IF NOT ls_bseg_out_prd-ktosl IS INITIAL.
          APPEND ls_bseg_out_prd TO ct_bseg_out.
        ENDIF.
        IF NOT ls_bseg_out_umb-ktosl IS INITIAL.
          APPEND ls_bseg_out_umb TO ct_bseg_out.
        ENDIF.
        IF NOT ls_bseg_out_pry-ktosl IS INITIAL.
          APPEND ls_bseg_out_pry TO ct_bseg_out.
        ENDIF.
        IF NOT ls_bseg_out_vp-ktosl IS INITIAL.
          APPEND ls_bseg_out_vp TO ct_bseg_out.
        ENDIF.
        IF NOT ls_bseg_out_vn-ktosl IS INITIAL.
          APPEND ls_bseg_out_vn TO ct_bseg_out.
        ENDIF.
        ls_bseg_out_cor-matnr = ls_mats-matnr.
        ls_bseg_out_cor-bwkey = ls_mats-bwkey.
        ls_bseg_out_cor-bwtar = ls_mats-bwtar.
        ls_bseg_out_cor-waers = ls_bseg_out_prd-waers.
        ls_bseg_out_cor-glvor = 'RESC'.
*        ls_coltab-color-col = '6'.
*        ls_coltab-nokeycol = 'X'.
*        REFRESH: ls_bseg_out_cor-coltab.
*        APPEND ls_coltab TO ls_bseg_out_cor-coltab.
        ls_bseg_out_cor-dmbtr = 0 - ls_bseg_out_prd-dmbtr -
                                    ls_bseg_out_pry-dmbtr -
                                    ls_bseg_out_umb-dmbtr -
                                    ls_bseg_out_vp-dmbtr -
                                    ls_bseg_out_vn-dmbtr.
        ls_bseg_out_cor-dmbe2 = 0 - ls_bseg_out_prd-dmbe2 -
                                    ls_bseg_out_pry-dmbe2 -
                                    ls_bseg_out_umb-dmbe2 -
                                    ls_bseg_out_vp-dmbe2 -
                                    ls_bseg_out_vn-dmbe2.
        ls_bseg_out_cor-dmbe3 = 0 - ls_bseg_out_prd-dmbe3 -
                                    ls_bseg_out_pry-dmbe3 -
                                    ls_bseg_out_umb-dmbe3 -
                                    ls_bseg_out_vp-dmbe3 -
                                    ls_bseg_out_vn-dmbe3.
        IF NOT ( ls_bseg_out_cor-dmbtr IS INITIAL AND
                 ls_bseg_out_cor-dmbe2 IS INITIAL AND
                 ls_bseg_out_cor-dmbe3 IS INITIAL ).
          APPEND ls_bseg_out_cor TO ct_bseg_out.
        ENDIF.
      ENDIF.
    ELSE.
*   Da kommt noch was!
      READ TABLE pt_ckmlcr WITH KEY kalnr = ls_mats-kalnr
                                    bdatj = p_bdatj
                                    poper = p_poper
                                    untper = s_runperiod-untper
                                    BINARY SEARCH
                                    TRANSPORTING NO FIELDS.
      LOOP AT pt_ckmlcr INTO ls_ckmlcr FROM sy-tabix.
        IF ls_ckmlcr-kalnr <> ls_ckmlpp-kalnr OR
           ls_ckmlcr-bdatj <> ls_ckmlpp-bdatj OR
           ls_ckmlcr-poper <> ls_ckmlpp-poper OR
           ls_ckmlcr-untper <> ls_ckmlpp-untper.
          EXIT.
        ENDIF.
        MOVE-CORRESPONDING ls_ckmlcr TO ls_out_ndi.
        MOVE-CORRESPONDING ls_ckmlcr TO ls_out_cum.
        MOVE-CORRESPONDING ls_ckmlcr TO ls_out_fia.
        ls_out_cum-quantity_cum = ls_ckmlpp-abkumo +
                                  ls_ckmlpp-zukumo +
                                  ls_ckmlpp-vpkumo + l_ab_menge.
******* Könnte es zu nicht verteilten Differenzen kommen? **************
        CLEAR: l_ndi.
        IF ls_ckmlpp-pbpopo > 0 AND
           ( ls_ckmlcr-pbprd_o <> 0 OR ls_ckmlcr-pbkdm_o <> 0 ) AND
           ls_ckmlpp-pbpopo > ls_out_cum-quantity_cum.
          l_part_ndi = ( ls_ckmlpp-pbpopo - ls_out_cum-quantity_cum ) /
                       ls_ckmlpp-pbpopo.
          ls_out_ndi-estprd = ls_ckmlcr-pbprd_o * l_part_ndi.
          ls_out_ndi-estkdm = ls_ckmlcr-pbkdm_o * l_part_ndi.
          ls_out_ndi-estprd = ls_out_ndi-estprd -
                            ( ls_ckmlcr-vnprd_ea + ls_ckmlcr-ebprd_ea ).
          ls_out_ndi-estkdm = ls_out_ndi-estkdm -
                            ( ls_ckmlcr-vnkdm_ea + ls_ckmlcr-ebkdm_ea ).
          ls_out_ndi-sumdif = ls_out_ndi-estprd + ls_out_ndi-estkdm.
*         Liegt die Differenz über dem Schwellwert?
          l_sumdif_abs = abs( ls_out_ndi-sumdif ).
          IF ls_out_ndi-curtp = '10'.
            IF l_sumdif_abs > p_limndi.
              l_ndi = 'X'.
            ENDIF.
          ELSE.
            CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
              EXPORTING
*               CLIENT           = SY-MANDT
                date             = sy-datum
                foreign_currency = ls_out_ndi-waers
                local_amount     = p_limndi
                local_currency   = t001-waers
*               RATE             = 0
*               TYPE_OF_RATE     = 'M'
*               READ_TCURR       = 'X'
              IMPORTING
*               EXCHANGE_RATE    =
                foreign_amount   = l_limit
*               FOREIGN_FACTOR   =
*               LOCAL_FACTOR     =
*               EXCHANGE_RATEX   =
*               DERIVED_RATE_TYPE =
*               FIXED_RATE       =
              EXCEPTIONS
                no_rate_found    = 1
                overflow         = 2
                no_factors_found = 3
                no_spread_found  = 4
                derived_2_times  = 5
                OTHERS           = 6.
            IF sy-subrc = 0 AND l_sumdif_abs > l_limit.
              l_ndi = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
******* Und der FI Saldo! **********************************************
        IF NOT p_fiacc IS INITIAL.
          MOVE-CORRESPONDING ls_out_fia TO ls_out_fis.
          MOVE-CORRESPONDING ls_out_fia TO ls_out_umb.
          MOVE-CORRESPONDING ls_out_fia TO ls_out_abc.
          READ TABLE pt_mat_bal INTO ls_mat_bal
                                WITH KEY kalnr = ls_mats-kalnr
                                BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_ckmlcr-curtp = '10'.
              ls_out_fia-estprd = ls_mat_bal-balance.
            ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
              ls_out_fia-estprd = ls_mat_bal-balance2.
            ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
              ls_out_fia-estprd = ls_mat_bal-balance3.
            ENDIF.
          ELSE.
            CLEAR: ls_out_fia-estprd.
          ENDIF.
**         Korrektur des Saldo's um fehlende Anfangsbestandsdifferenzen
**         in der Kumulation!
*          IF NOT s_runperiod-untper IS INITIAL.
*            READ TABLE pt_ckmlcr_act INTO ls_ckmlcr_act
*                                     WITH KEY kalnr = ls_mats-kalnr
*                                              bdatj = s_runperiod-from_gjahr
*                                              poper = s_runperiod-from_poper
*                                              untper = '000'
*                                              curtp = ls_ckmlcr-curtp
*                                              BINARY SEARCH.
*            READ TABLE pt_mlavrscale INTO ls_mlavrscale
*                       WITH KEY run_id = s_runperiod-run_id
*                                kalnr_in = ls_mats-kalnr
*                                curtp_in = ls_ckmlcr-curtp
*                                categ = 'AB'
*                                BINARY SEARCH.
*            IF sy-subrc <> 0.
*              CLEAR: ls_mlavrscale.
*            ENDIF.
*            l_ab_correction = ls_ckmlcr-abprd_o +
*                              ls_ckmlcr-abkdm_o +
*                              ls_ckmlcr-abprd_mo +
*                              ls_ckmlcr-abkdm_mo -
*                              ls_mlavrscale-diff_in -
*                              ls_ckmlcr_act-abprd_o -
*                              ls_ckmlcr_act-abkdm_o -
*                              ls_ckmlcr_act-abprd_mo -
*                              ls_ckmlcr_act-abkdm_mo -
*                              ls_ckmlcr_act-zuumb_o.
*            ls_out_fia-estprd = ls_out_fia-estprd + l_ab_correction.
*            ls_out_umb-estprd = 0 - ls_ckmlcr_act-zuumb_o.
*            ls_out_umb-sumdif = ls_out_umb-estprd.
*            ls_out_abc-estprd = l_ab_correction + ls_ckmlcr_act-zuumb_o.
*            ls_out_abc-sumdif = ls_out_abc-estprd.
*            IF ls_ckmlcr-curtp = '10'.
*              CLEAR: ls_bseg_out_ab, ls_coltab.
*              ls_bseg_out_ab-matnr = ls_mats-matnr.
*              ls_bseg_out_ab-bwkey = ls_mats-bwkey.
*              ls_bseg_out_ab-bwtar = ls_mats-bwtar.
*              ls_bseg_out_ab-dmbtr = l_ab_correction.
*              ls_bseg_out_ab-waers = ls_ckmlcr-waers.
*              ls_bseg_out_ab-ktosl = 'AB'.
*              ls_bseg_out_ab-glvor = 'ABCO'.
**              ls_coltab-color-col = '6'.
**              ls_coltab-nokeycol = 'X'.
**              REFRESH: ls_bseg_out_ab-coltab.
**              APPEND ls_coltab TO ls_bseg_out_ab-coltab.
*            ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
*              ls_bseg_out_ab-dmbe2 = l_ab_correction.
*            ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
*              ls_bseg_out_ab-dmbe3 = l_ab_correction.
*            ENDIF.
*          ENDIF.
          ls_out_fia-sumdif = ls_out_fia-estprd.
          IF ls_ckmlpp-status = y_abschlussbuchung_erfolgt.
            l_checksum = ls_out_ndi-sumdif + ls_out_nin-sumdif +
                         ls_out_vno-sumdif.
          ELSE.
            l_checksum = ls_out_cum-sumdif - ls_ckmlcr-zuprd_mo - ls_ckmlcr-zukdm_mo.
          ENDIF.
          IF ls_out_fia-sumdif <> l_checksum.
            ls_out_cum-icon_fia = icon_led_red.
            ls_out_fis-estprd = l_checksum - ls_out_fia-sumdif.
            ls_out_fis-sumdif = ls_out_fis-estprd.
          ELSE.
            ls_out_cum-icon_fia = icon_led_green.
          ENDIF.
        ENDIF.

******* So, die relevanten Zeilen werden erzeugt! **********************

        IF NOT l_ndi IS INITIAL OR NOT p_all IS INITIAL.
          MOVE-CORRESPONDING ls_mats TO ls_out_ndi.
          MOVE-CORRESPONDING ls_mats TO ls_out_cum.
          MOVE-CORRESPONDING ls_mats TO ls_out_fia.
          MOVE-CORRESPONDING ls_mats TO ls_out_fis.
          MOVE-CORRESPONDING ls_mats TO ls_out_umb.
          MOVE-CORRESPONDING ls_mats TO ls_out_abc.
          CALL FUNCTION 'T025T_SINGLE_READ'
            EXPORTING
*             KZRFB       = ' '
              t025t_spras = sy-langu
              t025t_bklas = ls_mats-bklas
            IMPORTING
              wt025t      = ls_t025t
            EXCEPTIONS
              not_found   = 1
              OTHERS      = 2.
          IF sy-subrc = 0.
            ls_out_ndi-bkbez = ls_t025t-bkbez.
            ls_out_cum-bkbez = ls_t025t-bkbez.
            ls_out_fia-bkbez = ls_t025t-bkbez.
            ls_out_fis-bkbez = ls_t025t-bkbez.
            ls_out_umb-bkbez = ls_t025t-bkbez.
            ls_out_abc-bkbez = ls_t025t-bkbez.
          ENDIF.
          IF tcurm-bwkrs_cus <> '3'.            "Bewertungsebene WERKS
            ls_out_ndi-werks = ls_mats-bwkey.
            ls_out_cum-werks = ls_mats-bwkey.
            ls_out_fia-werks = ls_mats-bwkey.
            ls_out_fis-werks = ls_mats-bwkey.
            ls_out_umb-werks = ls_mats-bwkey.
            ls_out_abc-werks = ls_mats-bwkey.
            CALL FUNCTION 'T001W_SINGLE_READ'
              EXPORTING
*               KZRFB       = ' '
                t001w_werks = ls_out_ndi-werks
              IMPORTING
                wt001w      = ls_t001w
              EXCEPTIONS
                not_found   = 1
                OTHERS      = 2.
            ls_out_ndi-name1 = ls_t001w-name1.
            ls_out_cum-name1 = ls_t001w-name1.
            ls_out_fia-name1 = ls_t001w-name1.
            ls_out_fis-name1 = ls_t001w-name1.
            ls_out_umb-name1 = ls_t001w-name1.
            ls_out_abc-name1 = ls_t001w-name1.
          ENDIF.
********* Nicht verteilt ***********************************************
          IF NOT l_ndi IS INITIAL.
            ls_out_ndi-pos_type = 'NDI'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_ndi-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_ndi-pos_type_text = t_dd07v-ddtext.
            ls_out_ndi-prdif = ls_out_ndi-estprd + ls_out_ndi-mstprd.
            ls_out_ndi-krdif = ls_out_ndi-estkdm + ls_out_ndi-mstkdm.
            ls_out_ndi-estdif = ls_out_ndi-estprd + ls_out_ndi-estkdm.
            ls_out_ndi-mstdif = ls_out_ndi-mstprd + ls_out_ndi-mstkdm.
            APPEND ls_out_ndi TO lt_out.
          ENDIF.
********* Kumuliert ****************************************************
          ls_out_cum-pos_type = 'CUM'.
          READ TABLE t_dd07v
                     WITH KEY domvalue_l = ls_out_cum-pos_type.
          IF sy-subrc <> 0.
            CLEAR t_dd07v.
          ENDIF.
          ls_out_cum-pos_type_text = t_dd07v-ddtext.
          ls_out_cum-estprd = ls_ckmlcr-abprd_o + ls_ckmlcr-zuprd_o +
                              ls_ckmlcr-vpprd_o.
          ls_out_cum-estkdm = ls_ckmlcr-abkdm_o + ls_ckmlcr-zukdm_o +
                              ls_ckmlcr-vpkdm_o.
          ls_out_cum-mstprd = ls_ckmlcr-abprd_mo.
          ls_out_cum-mstkdm = ls_ckmlcr-abkdm_mo.
*         Anfangsbestands-Menge (Rückbuchungen) aus MLCD
          CLEAR: l_ab_menge.
          READ TABLE pt_mlcd WITH KEY kalnr = ls_ckmlcr-kalnr
                           bdatj = ls_ckmlcr-bdatj
                           poper = ls_ckmlcr-poper
                           untper = ls_ckmlcr-untper
                           categ = 'AB'
                           curtp = ls_ckmlcr-curtp
                     BINARY SEARCH
                     TRANSPORTING NO FIELDS.
          LOOP AT pt_mlcd INTO ls_mlcd FROM sy-tabix.
            IF ls_mlcd-kalnr <> ls_ckmlcr-kalnr OR
               ls_mlcd-bdatj <> ls_ckmlcr-bdatj OR
               ls_mlcd-poper <> ls_ckmlcr-poper OR
               ls_mlcd-untper <> ls_ckmlcr-untper OR
               ls_mlcd-categ <> 'AB' OR
               ls_mlcd-curtp <> ls_ckmlcr-curtp.
              EXIT.
            ENDIF.
            l_ab_menge = l_ab_menge + ls_mlcd-lbkum.
          ENDLOOP.
          ls_out_cum-prdif = ls_out_cum-estprd + ls_out_cum-mstprd.
          ls_out_cum-krdif = ls_out_cum-estkdm + ls_out_cum-mstkdm.
          ls_out_cum-estdif = ls_out_cum-estprd + ls_out_cum-estkdm.
          ls_out_cum-mstdif = ls_out_cum-mstprd + ls_out_cum-mstkdm.
          ls_out_cum-sumdif = ls_out_cum-estprd + ls_out_cum-estkdm +
                              ls_out_cum-mstprd + ls_out_cum-mstkdm.
          ls_out_cum-value_cum = ls_out_cum-quantity_cum *
                                 ls_out_cum-stprs.
          IF ls_out_cum-quantity_cum <> 0.
            CATCH SYSTEM-EXCEPTIONS conversion_errors = 1
                                  arithmetic_errors = 2.
              ls_out_cum-price_cum = ls_out_cum-stprs +
                            ( ( ( ls_out_cum-sumdif - ls_out_ndi-sumdif ) /
                                       ls_out_cum-quantity_cum ) *
                                       ls_out_cum-peinh ).
            ENDCATCH.
            IF sy-subrc <> 0.
              ls_out_cum-price_cum = '999999999.99'.
            ENDIF.
            CATCH SYSTEM-EXCEPTIONS conversion_errors = 1
                                        arithmetic_errors = 2.
              ls_out_cum-pb_price = ls_out_cum-stprs +
                       ( ( ls_out_cum-sumdif / ls_out_cum-quantity_cum ) *
                                    ls_out_cum-peinh ).
            ENDCATCH.
            IF sy-subrc <> 0.
              ls_out_cum-pb_price = '999999999.99'.
            ENDIF.
          ENDIF.
          IF ls_out_cum-pb_price < 0.
            ls_out_cum-icon = icon_led_red.
          ENDIF.
          APPEND ls_out_cum TO lt_out.
********* FI Saldo *****************************************************
          IF NOT ls_out_fia-sumdif IS INITIAL.
            ls_out_fia-pos_type = 'FIA'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_fia-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_fia-pos_type_text = t_dd07v-ddtext.
            ls_out_fia-prdif = ls_out_fia-estprd.
            ls_out_fia-estdif = ls_out_fia-estprd.
            APPEND ls_out_fia TO lt_out.
          ENDIF.
          IF NOT ls_out_fis-sumdif IS INITIAL.
            ls_out_fis-pos_type = 'FIS'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_fis-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_fis-pos_type_text = t_dd07v-ddtext.
            ls_out_fis-prdif = ls_out_fis-estprd.
            ls_out_fis-estdif = ls_out_fis-estprd.
            APPEND ls_out_fis TO lt_out.
          ENDIF.
          IF NOT ls_out_umb-sumdif IS INITIAL.
            ls_out_umb-pos_type = 'UMB'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_umb-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_umb-pos_type_text = t_dd07v-ddtext.
            ls_out_umb-prdif = ls_out_umb-estprd.
            ls_out_umb-estdif = ls_out_umb-estprd.
            APPEND ls_out_umb TO lt_out.
          ENDIF.
          IF NOT ls_out_abc-sumdif IS INITIAL.
            ls_out_abc-pos_type = 'ABC'.
            READ TABLE t_dd07v
                       WITH KEY domvalue_l = ls_out_abc-pos_type.
            IF sy-subrc <> 0.
              CLEAR t_dd07v.
            ENDIF.
            ls_out_abc-pos_type_text = t_dd07v-ddtext.
            ls_out_abc-prdif = ls_out_abc-estprd.
            ls_out_abc-estdif = ls_out_abc-estprd.
            APPEND ls_out_abc TO lt_out.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
*   Wenn es für ein Material keine Zeile mit Währungstyp '10' gibt,
*   dann erzeugen wir hier eine Dummy-Zeile, da der angezeigte ALV Tree
*   (zu Beginn immer Währungstyp = '10') sonst unvollständig aufgebaut
*   würde bzw. sogar ganz leer wäre (Fehlermeldung).
    IF NOT lt_out IS INITIAL.
      READ TABLE lt_out WITH KEY curtp = '10' TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        READ TABLE lt_out INTO ls_out_dummy INDEX 1.
        CLEAR: ls_out_dummy-lbkum, ls_out_dummy-quantity_cum,
               ls_out_dummy-pbpopo, ls_out_dummy-salk3,
               ls_out_dummy-value_cum, ls_out_dummy-stprs,
               ls_out_dummy-pvprs, ls_out_dummy-peinh,
               ls_out_dummy-pbprd_o, ls_out_dummy-pbkdm_o,
               ls_out_dummy-estprd, ls_out_dummy-estkdm,
               ls_out_dummy-mstprd, ls_out_dummy-mstkdm,
               ls_out_dummy-estdif, ls_out_dummy-mstdif,
               ls_out_dummy-prdif, ls_out_dummy-krdif,
               ls_out_dummy-sumdif, ls_out_dummy-pb_price,
               ls_out_dummy-price_cum, ls_out_dummy-icon_fia,
               ls_out_dummy-rescale.
        ls_out_dummy-curtp = '10'.
        ls_out_dummy-waers = t001-waers.
        APPEND ls_out_dummy TO lt_out.
      ENDIF.
    ENDIF.
    APPEND LINES OF lt_out TO pt_out.
  ENDLOOP.
* Neu Sortieren, da Zeilen angehängt wurden!
  SORT ct_bseg_out BY bwkey matnr bwtar.

******* FI Saldo für Buchungen ohne Material anhängen! *****************
  IF NOT p_fiacc IS INITIAL AND
     NOT p_finom IS INITIAL AND
     NOT h_first_bwkey IS INITIAL AND
     NOT h_first_mat IS INITIAL .
    READ TABLE pt_mat_bal WITH KEY kalnr = l_kalnr_space
                          BINARY SEARCH
INTO ls_mat_bal.

    IF sy-subrc = 0.
      CLEAR: ls_out_fia.
      ls_out_fia-bukrs = t001-bukrs.
      ls_out_fia-butxt = t001-butxt.
      ls_out_fia-waers = t001-waers.
      ls_out_fia-pos_type = 'FIA'.
      ls_out_fia-curtp = '10'.
      ls_out_fia-estprd = ls_mat_bal-balance.
      ls_out_fia-sumdif = ls_out_fia-estprd.
      ls_out_fia-prdif = ls_out_fia-estprd.
      ls_out_fia-estdif = ls_out_fia-estprd.
      APPEND ls_out_fia TO pt_out.
      CLEAR ls_out_fia.
      IF NOT ls_mat_bal-curtp2 IS INITIAL.
        ls_out_fia-bukrs = t001-bukrs.
        ls_out_fia-butxt = t001-butxt.
        ls_out_fia-pos_type = 'FIA'.
        ls_out_fia-curtp = ls_mat_bal-curtp2.
        ls_out_fia-estprd = ls_mat_bal-balance2.
        ls_out_fia-sumdif = ls_out_fia-estprd.
        ls_out_fia-prdif = ls_out_fia-estprd.
        ls_out_fia-estdif = ls_out_fia-estprd.

        APPEND ls_out_fia TO pt_out.
        CLEAR ls_out_fia.
      ENDIF.
      IF NOT ls_mat_bal-curtp3 IS INITIAL.
        ls_out_fia-bukrs = t001-bukrs.
        ls_out_fia-butxt = t001-butxt.
        ls_out_fia-pos_type = 'FIA'.
        ls_out_fia-curtp = ls_mat_bal-curtp3.
        ls_out_fia-estprd = ls_mat_bal-balance3.
        ls_out_fia-sumdif = ls_out_fia-estprd.
        ls_out_fia-prdif = ls_out_fia-estprd.
        ls_out_fia-estdif = ls_out_fia-estprd.
        APPEND ls_out_fia TO pt_out.
        CLEAR ls_out_fia.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR: ls_bseg_out, ls_ckmvfm_bseg_out.
  LOOP AT pt_ckmvfm_bseg_out INTO ls_ckmvfm_bseg_out.
    READ TABLE ct_bseg_out INTO ls_bseg_out
    WITH KEY matnr = ls_ckmvfm_bseg_out-matnr
             bwkey = ls_ckmvfm_bseg_out-bwkey
             bwtar = ls_ckmvfm_bseg_out-bwtar
             belnr = ls_ckmvfm_bseg_out-belnr
             buzei = ls_ckmvfm_bseg_out-buzei
             gjahr = ls_ckmvfm_bseg_out-gjahr
             bukrs = ls_ckmvfm_bseg_out-bukrs.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_bseg_out TO ls_ckmvfm_bseg_out.
      MODIFY pt_ckmvfm_bseg_out FROM ls_ckmvfm_bseg_out.
    ENDIF.
    CLEAR: ls_bseg_out, ls_ckmvfm_bseg_out.
  ENDLOOP.

  CLEAR: ls_out, ls_ckmvfm_out.
  LOOP AT pt_out INTO ls_out.
    MOVE-CORRESPONDING ls_out TO ls_ckmvfm_out.
    ls_ckmvfm_out-exid = p_exid.
    APPEND ls_ckmvfm_out TO pt_ckmvfm_out.
    CLEAR: ls_out, ls_ckmvfm_out.
  ENDLOOP.


ENDFORM.                               " find_bad_boys
*&---------------------------------------------------------------------*
*&      Form  get_mlcd_data
*&---------------------------------------------------------------------*
FORM get_mlcd_data USING pt_mats LIKE t_mats[]
             CHANGING pt_mlcd LIKE t_mlcd[]
                      pt_mlcd_not_alloc LIKE t_mlcd_not_alloc[].

  DATA: lt_kalnr TYPE ckmv0_matobj_tbl,
        ls_mats  TYPE s_mats,

        ls_kalnr TYPE ckmv0_matobj_str.

  REFRESH: lt_kalnr.

* Funktionsbaustein wird hier zunächst aufgerufen, um MLCD-Puffer zu
* löschen.
  CALL FUNCTION 'CKMCD_MLCD_READ'
    EXPORTING
      i_from_bdatj      = p_bdatj
      i_from_poper      = p_poper
*     I_TO_BDATJ        =
*     I_TO_POPER        =
*     I_UNTPER          =
*     I_RUN_ID          =
*     I_NO_BUFFER       =
      i_refresh_buffer  = 'X'
*     I_ONLINE          = 'X'
*     I_NO_MLCD_CREATE  =
    TABLES
      it_kalnr          = lt_kalnr
      ot_mlcd           = pt_mlcd
      ot_mlcd_not_alloc = pt_mlcd_not_alloc
    EXCEPTIONS
      data_error        = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT pt_mats INTO ls_mats.
    CLEAR: ls_kalnr.
    ls_kalnr-kalnr = ls_mats-kalnr.
    ls_kalnr-bwkey = ls_mats-bwkey.
    APPEND ls_kalnr TO lt_kalnr.
  ENDLOOP.
*Der Funktionsbaustein wird jetzt aufgerufen, ohne refresh-flag. Der
*Puffer für Periodensätze wurde bereits in der Routine get_materials
*refresht, der Puffer für die mlcd-Sätze oben.
  CALL FUNCTION 'CKMCD_MLCD_READ'
    EXPORTING
      i_from_bdatj      = p_bdatj
      i_from_poper      = p_poper
*     I_TO_BDATJ        =
*     I_TO_POPER        =
      i_untper          = s_runperiod-untper
*     I_RUN_ID          =
*     I_NO_BUFFER       =
      i_refresh_buffer  = ' '
      i_online          = ' '
*     I_NO_MLCD_CREATE  =
    TABLES
      it_kalnr          = lt_kalnr
      ot_mlcd           = pt_mlcd
      ot_mlcd_not_alloc = pt_mlcd_not_alloc
    EXCEPTIONS
      data_error        = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " get_mlcd_data

*&---------------------------------------------------------------------*
*&      Form  screen_0042_initialize
*&---------------------------------------------------------------------*
FORM screen_0042_initialize.

  DATA: lh_ddtext   LIKE ckmlcur-ddtext,
        l_text1(10) TYPE c,
        l_text2(8)  TYPE c,
        l_text3(50) TYPE c.

  GET PARAMETER ID 'VFMVIEW' FIELD ckml_vfm-view.

  SET PF-STATUS '0042'.
  SET TITLEBAR '42'.

  mlkey-poper = p_poper.
  mlkey-bdatj = p_bdatj.

* Modify the dropdown box for currency types
  IF NOT h_last_bwkey IS INITIAL.
    CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
      EXPORTING
        bwkey             = h_last_bwkey
*       CALL_BY_INIT_PROG = ' '
*       I_CUSTOMIZING     = ' '
      TABLES
        t_curtp_for_va    = t_curtp
      EXCEPTIONS
        bwkey_not_found   = 1
        bwkey_not_active  = 2
        matled_not_found  = 3
        internal_error    = 4
        more_than_3_curtp = 5
        OTHERS            = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    LOOP AT t_curtp.
      CLEAR: s_curtp_dropdown.
      s_curtp_dropdown-key = t_curtp-curtp.
      s_curtp_dropdown-text = t_curtp-text.
      APPEND s_curtp_dropdown TO t_curtp_dropdown.
    ENDLOOP.
    IF sy-subrc <> 0.
      SELECT SINGLE ddtext FROM ckmlcur INTO lh_ddtext
                           WHERE sprsl = sy-langu
                           AND   curtp = '10'.
      CLEAR: s_curtp_dropdown.
      s_curtp_dropdown-key = '10'.
      s_curtp_dropdown-text = lh_ddtext.
      APPEND s_curtp_dropdown TO t_curtp_dropdown.
    ENDIF.
  ELSE.
    SELECT SINGLE ddtext FROM ckmlcur INTO lh_ddtext
                         WHERE sprsl = sy-langu
                         AND   curtp = '10'.
    CLEAR: s_curtp_dropdown.
    s_curtp_dropdown-key = '10'.
    s_curtp_dropdown-text = lh_ddtext.
    APPEND s_curtp_dropdown TO t_curtp_dropdown.
  ENDIF.
  READ TABLE t_curtp_dropdown WITH KEY key = mlkey-curtp
                              TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0 OR
     mlkey-curtp IS INITIAL.
    mlkey-curtp = '10'.
  ENDIF.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'MLKEY-CURTP'
      values = t_curtp_dropdown
*      EXCEPTIONS
*     ID_ILLEGAL_NAME = 1
*     OTHERS = 2
    .
  READ TABLE t_curtp WITH KEY curtp = mlkey-curtp.
  mlkey-waers = t_curtp-waers.

  IF ckml_vfm-sel_anzeige_diff IS INITIAL.
    ckml_vfm-sel_anzeige_diff = 'D'.
  ENDIF.
  IF ckml_vfm-view IS INITIAL.
    ckml_vfm-view = 'MO'.
  ENDIF.

* Information about used DB extract
  IF NOT p_exrea IS INITIAL.
    WRITE: h_exdate TO l_text1,
           h_extime TO l_text2.
    CONCATENATE p_exnam l_text1 l_text2 INTO l_text3 SEPARATED BY ' / '.
    CONCATENATE TEXT-027 l_text3 INTO dynpro0042_extract
                                 SEPARATED BY space.
  ENDIF.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'RUN'.
        IF ckmlrunperiod-run_type IS INITIAL.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'LND'.
        IF ckml_vfm_tree-diff_ndi IS INITIAL.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'LNI'.
        IF ckml_vfm_tree-diff_nin IS INITIAL.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
    CASE screen-group2.
      WHEN 'CUM'.
        IF ckmlrunperiod-appl <> 'CUM'.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
    CASE screen-name.
      WHEN 'DYNPRO0042_EXTRACT'.
        IF p_exrea IS INITIAL.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  SET CURSOR FIELD 'MLKEY-BDATJ'.

ENDFORM.                    " screen_0042_initialize
*&---------------------------------------------------------------------*
*&      Form  fieldcat_fill
*&---------------------------------------------------------------------*
FORM fieldcat_fill.

  DATA: ls_fieldcat   TYPE lvc_s_fcat,
        ls_out        TYPE s_out,
        ls_sort       TYPE lvc_s_sort,
        ls_tree_dummy TYPE s_vfm_tree,
        l_index       TYPE i,
        l_bwtar_space TYPE bwtar_d,
        l_vbeln_space TYPE vbeln,
        l_posnr_space TYPE posnr,
        l_pspnr_space TYPE ps_psp_pnr.

  REFRESH: t_fieldcat.
  CLEAR: l_index, l_bwtar_space, l_vbeln_space, l_posnr_space,
         l_pspnr_space.

  IF ckml_vfm-view = 'FM'.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'MATNR'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-key = 'X'.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'WERKS'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-key = 'X'.
    APPEND ls_fieldcat TO t_fieldcat.

    ls_fieldcat-fieldname = 'BKLAS'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-key = 'X'.
    LOOP AT t_tree_data INTO ls_tree_dummy
                        WHERE bklas <> ''.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      ls_fieldcat-no_out = 'X'.
    ENDIF.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BWTAR'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-key = 'X'.
    LOOP AT t_tree_data INTO ls_tree_dummy
                        WHERE bwtar <> l_bwtar_space.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      ls_fieldcat-no_out = 'X'.
    ENDIF.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VBELN'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-key = 'X'.
    LOOP AT t_tree_data INTO ls_tree_dummy
                        WHERE vbeln <> l_vbeln_space.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      ls_fieldcat-no_out = 'X'.
    ENDIF.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'POSNR'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-key = 'X'.
    LOOP AT t_tree_data INTO ls_tree_dummy
                        WHERE posnr <> l_posnr_space.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      ls_fieldcat-no_out = 'X'.
    ENDIF.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PSPNR'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-key = 'X'.
    LOOP AT t_tree_data INTO ls_tree_dummy
                        WHERE pspnr <> l_pspnr_space.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      ls_fieldcat-no_out = 'X'.
    ENDIF.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'MLAST'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-scrtext_s = TEXT-048.
    ls_fieldcat-scrtext_m = TEXT-049.
    ls_fieldcat-scrtext_l = TEXT-050.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-no_out = 'X'.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VPRSV'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-scrtext_s = TEXT-051.
    ls_fieldcat-scrtext_m = TEXT-052.
    ls_fieldcat-scrtext_l = TEXT-053.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-no_out = 'X'.
    APPEND ls_fieldcat TO t_fieldcat.
  ENDIF.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MTART'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MATKL'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SPART'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRCTR'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_CUM'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view = 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_PRA'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-just = 'R'.
*  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-scrtext_s = TEXT-036.
  ls_fieldcat-scrtext_m = TEXT-036.
  ls_fieldcat-scrtext_l = TEXT-036.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view = 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'DIFF_VPR'.
*  ls_fieldcat-tabname = 'T_TREE_DATA'.
*  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
*  ls_fieldcat-cfieldname = 'WAERS'.
*  ls_fieldcat-SCRTEXT_M = text-037.
*  l_index = l_index + 1.
*  ls_fieldcat-col_pos = l_index.
*  ls_fieldcat-no_zero = 'X'.
*  IF ckml_vfm-view = 'NV'.
*    ls_fieldcat-no_out = 'X'.
*  ENDIF.
*  APPEND ls_fieldcat TO t_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_NDI'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_NIN'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_RSC'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  IF ckml_vfm-view <> 'FM'.
    ls_fieldcat-colddictxt = 'S'.
  ENDIF.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view = 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_NLE'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
*  IF ckml_vfm-view <> 'FM'.
  ls_fieldcat-colddictxt = 'S'.
*  ENDIF.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view = 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_WIP'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  IF ckml_vfm-view <> 'FM'.
    ls_fieldcat-colddictxt = 'S'.
  ENDIF.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view = 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_VNO'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view = 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_OST'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-scrtext_s = TEXT-060.
  ls_fieldcat-scrtext_m = TEXT-061.
  ls_fieldcat-scrtext_l = TEXT-062.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view = 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_EIV'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view = 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIFF_MLS'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-just = 'R'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-scrtext_s = TEXT-038.
  ls_fieldcat-scrtext_m = TEXT-038.
  ls_fieldcat-scrtext_l = TEXT-038.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view = 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.


  IF NOT p_fiacc IS INITIAL.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DIFF_FIA'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    ls_fieldcat-cfieldname = 'WAERS'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-no_zero = 'X'.
    IF ckml_vfm-view = 'NV'.
      ls_fieldcat-no_out = 'X'.
    ENDIF.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DIFF_FIS'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    ls_fieldcat-cfieldname = 'WAERS'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-no_zero = 'X'.
    IF ckml_vfm-view = 'NV'.
      ls_fieldcat-no_out = 'X'.
    ENDIF.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ICON_FIA'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    APPEND ls_fieldcat TO t_fieldcat.

    IF s_runperiod-untper <> '000'.
      CLEAR ls_fieldcat.
      ls_fieldcat-fieldname = 'RESCALE'.
      ls_fieldcat-tabname = 'T_TREE_DATA'.
      ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
      l_index = l_index + 1.
      ls_fieldcat-col_pos = l_index.
      ls_fieldcat-checkbox = 'X'.
      APPEND ls_fieldcat TO t_fieldcat.
    ENDIF.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DIFF_UMB'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    ls_fieldcat-cfieldname = 'WAERS'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-no_zero = 'X'.
    ls_fieldcat-no_out = 'X'.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DIFF_ABC'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    ls_fieldcat-cfieldname = 'WAERS'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-no_zero = 'X'.
    ls_fieldcat-no_out = 'X'.
    APPEND ls_fieldcat TO t_fieldcat.

  ENDIF.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VALUE_CUM'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  IF ckml_vfm-view <> 'FM'.
    ls_fieldcat-colddictxt = 'S'.
  ENDIF.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
*  IF ckml_vfm-view = 'NV'.
  ls_fieldcat-no_out = 'X'.
*  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRICE_CUM'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view <> 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PB_PRICE'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view <> 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

  IF ckml_vfm-view <> 'NV'.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ICON_SETTLE'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ICON_CLO'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'STATUS'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-no_out = 'X'.
    APPEND ls_fieldcat TO t_fieldcat.
  ENDIF.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'QUANTITY_CUM'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-qfieldname = 'MEINS'.
  ls_fieldcat-colddictxt = 'M'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view <> 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PB_QUANTITY'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-qfieldname = 'MEINS'.
  ls_fieldcat-colddictxt = 'M'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  IF ckml_vfm-view <> 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MEINS'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  IF ckml_vfm-view <> 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ICON'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  IF ckml_vfm-view <> 'NV'.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO t_fieldcat.

  IF ckml_vfm-view = 'NV'.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ICON_SETTLE'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    APPEND ls_fieldcat TO t_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'STATUS'.
    ls_fieldcat-tabname = 'T_TREE_DATA'.
    ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
    l_index = l_index + 1.
    ls_fieldcat-col_pos = l_index.
    ls_fieldcat-no_out = 'X'.
    APPEND ls_fieldcat TO t_fieldcat.
  ENDIF.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STPRS'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'LBKUM'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-qfieldname = 'MEINS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SALK3'.
  ls_fieldcat-tabname = 'T_TREE_DATA'.
  ls_fieldcat-ref_table = 'CKML_VFM_TREE'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-no_zero = 'X'.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO t_fieldcat.

* Sortierung
  REFRESH t_sort.
  CLEAR: t_sort, l_index.

  CLEAR ls_sort.
  l_index = l_index + 1.
  ls_sort-spos = l_index.
  ls_sort-fieldname = 'MATNR'.
  ls_sort-up = 'X'.
  ls_sort-group = 'X'.
  APPEND ls_sort TO t_sort.

  CLEAR ls_sort.
  l_index = l_index + 1.
  ls_sort-spos = l_index.
  ls_sort-fieldname = 'WERKS'.
  ls_sort-up = 'X'.
  ls_sort-group = 'X'.
  APPEND ls_sort TO t_sort.

  CLEAR ls_sort.
  l_index = l_index + 1.
  ls_sort-spos = l_index.
  ls_sort-fieldname = 'BWTAR'.
  ls_sort-up = 'X'.
  ls_sort-group = 'X'.
  APPEND ls_sort TO t_sort.
ENDFORM.                    " fieldcat_fill
*&---------------------------------------------------------------------*
*&      Form  tree_controls_create
*&---------------------------------------------------------------------*
FORM tree_controls_create.

* Custom-Container erzeugen
  IF custom IS INITIAL.
    CREATE OBJECT custom
      EXPORTING
        container_name = 'CUSTOM'.
  ENDIF.

* ALV-Tree erzeugen
  CREATE OBJECT alv_tree
    EXPORTING
      parent         = custom
      item_selection = 'X'
      no_toolbar     = ' '
      no_html_header = 'X'.


ENDFORM.                    " tree_controls_create
*&---------------------------------------------------------------------*
*&      Form  tree_initialize
*&---------------------------------------------------------------------*
FORM tree_initialize.

  DATA: lt_exclude         TYPE ui_functions,
        lt_list_commentary TYPE slis_t_listheader,
        ls_variant         TYPE disvariant,
        l_hierarchy_header TYPE treev_hhdr,
        l_func             TYPE ui_func.

* Varianten
  CLEAR: ls_variant.
  ls_variant-report = sy-repid.
  IF ckml_vfm-view = 'MO'.
    ls_variant-handle = 'MON'.
  ELSE.
    ls_variant-handle = 'NIV'.
  ENDIF.

* Toolbar-Funktionen ausblenden
  REFRESH: lt_exclude.
*  CLEAR: l_func.
*  l_func = cl_alv_tree_base=>mc_fc_calculate.
*  APPEND l_func TO lt_exclude.

* Create header
*  perform tree_header_create using lt_list_commentary.
  DATA: t_dd07v    LIKE dd07v OCCURS 0 WITH HEADER LINE,
        ls_comment TYPE slis_listheader,
        l_jahrper  TYPE jahrper.

  CLEAR: ls_comment.
  ls_comment-typ = 'H'.
  ls_comment-info = TEXT-005.
  APPEND ls_comment TO lt_list_commentary.

  CLEAR: ls_comment.
  ls_comment-typ = 'S'.
  ls_comment-key = TEXT-040.
  WRITE p_bukrs TO ls_comment-info.
  APPEND ls_comment TO lt_list_commentary.

  CLEAR: ls_comment.
  ls_comment-typ = 'S'.
  ls_comment-key = TEXT-003.
  CONCATENATE p_bdatj p_poper INTO l_jahrper.
  WRITE l_jahrper TO ls_comment-info.
  APPEND ls_comment TO lt_list_commentary.

* Create hierarchy header
  l_hierarchy_header-heading = TEXT-005.
  l_hierarchy_header-tooltip = TEXT-005.
  l_hierarchy_header-width = 60.
  l_hierarchy_header-width_pix = ''.

  REFRESH: t_tree_show.

  CALL METHOD alv_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header  = l_hierarchy_header
*     it_list_commentary   = lt_list_commentary
      is_variant           = ls_variant
      i_save               = 'A'
      it_toolbar_excluding = lt_exclude
    CHANGING
      it_outtab            = t_tree_show
      it_fieldcatalog      = t_fieldcat.


ENDFORM.                    " tree_initialize
*&---------------------------------------------------------------------*
*&      Form  tree_show
*&---------------------------------------------------------------------*
FORM tree_show.

  DATA: lt_item_layout    TYPE lvc_t_layi,
        ls_item_layout    TYPE lvc_s_layi,
        ls_node_layout    TYPE lvc_s_layn,
        ls_tree_data      TYPE s_vfm_tree,
        ls_tree_mlast     TYPE s_vfm_tree,
        ls_tree_werks     TYPE s_vfm_tree,
        ls_tree_bklas     TYPE s_vfm_tree,
        ls_tree_mat       TYPE s_vfm_tree,
        l_relat_key       TYPE lvc_nkey,
        l_relat_key_bklas TYPE lvc_nkey,
        l_relat_key_werks TYPE lvc_nkey,
        l_header_node_key TYPE lvc_nkey,
        l_index           TYPE sy-tabix.

  CLEAR: l_relat_key.
  READ TABLE t_tree_data INTO ls_tree_data WITH KEY level = 1
                                           BINARY SEARCH.
  l_index = sy-tabix.

  LOOP AT t_tree_data INTO ls_tree_mlast FROM sy-tabix.
    IF ls_tree_mlast-level <> 1.
      EXIT.
    ENDIF.
    CLEAR: l_relat_key.
    CLEAR: ls_node_layout.
    ls_node_layout-exp_image = '@IH@'. "ICON_COMPANY_CODE
    ls_node_layout-n_image = '@IH@'.   "ICON_COMPANY_CODE
*   To activate icons in the icon column, we have to support the
*   "item_layout"!
    REFRESH: lt_item_layout.
    CLEAR: ls_item_layout.
    ls_item_layout-fieldname = 'ICON'.
    ls_item_layout-t_image   = ls_tree_mlast-icon.
    APPEND ls_item_layout TO lt_item_layout.
    CLEAR: ls_item_layout.
    ls_item_layout-fieldname = 'ICON_SETTLE'.
    ls_item_layout-t_image   = ls_tree_mlast-icon_settle.
    APPEND ls_item_layout TO lt_item_layout.
    CLEAR: ls_item_layout.
    ls_item_layout-fieldname = 'ICON_CLO'.
    ls_item_layout-t_image   = ls_tree_mlast-icon_clo.
    APPEND ls_item_layout TO lt_item_layout.
    CLEAR: ls_item_layout.
    ls_item_layout-fieldname = 'ICON_FIA'.
    ls_item_layout-t_image   = ls_tree_mlast-icon_fia.
    APPEND ls_item_layout TO lt_item_layout.
    CLEAR: ls_tree_mlast-icon, ls_tree_mlast-icon_settle,
           ls_tree_mlast-icon_clo,
           ls_tree_mlast-icon_fia.
    CALL METHOD alv_tree->add_node
      EXPORTING
        i_relat_node_key = l_relat_key
        i_relationship   = cl_gui_column_tree=>relat_last_child
        is_outtab_line   = ls_tree_mlast
        is_node_layout   = ls_node_layout
        it_item_layout   = lt_item_layout
        i_node_text      = ls_tree_mlast-htext
      IMPORTING
        e_new_node_key   = l_header_node_key.
    ls_tree_mlast-node_key = l_header_node_key.
    MODIFY t_tree_data FROM ls_tree_mlast.
    READ TABLE t_tree_data WITH KEY level = 2
                                    mlast = ls_tree_mlast-mlast
                         BINARY SEARCH
                         TRANSPORTING NO FIELDS.
    LOOP AT t_tree_data INTO ls_tree_bklas FROM sy-tabix.
      IF ls_tree_bklas-level <> 2 OR
         ls_tree_bklas-mlast <> ls_tree_mlast-mlast.
        EXIT.
      ENDIF.
      CLEAR: ls_node_layout.
      ls_node_layout-isfolder = 'X'.
*    ls_node_layout-exp_image = '@OO@'. "ICON_PROCUREMENT_ALTERNATIVE
*    ls_node_layout-n_image = '@OO@'.   "ICON_PROCUREMENT_ALTERNATIVE
      REFRESH: lt_item_layout.
      CLEAR: ls_item_layout.
      ls_item_layout-fieldname = 'ICON'.
      ls_item_layout-t_image   = ls_tree_bklas-icon.
      APPEND ls_item_layout TO lt_item_layout.
      CLEAR: ls_item_layout.
      ls_item_layout-fieldname = 'ICON_SETTLE'.
      ls_item_layout-t_image   = ls_tree_bklas-icon_settle.
      APPEND ls_item_layout TO lt_item_layout.
      CLEAR: ls_item_layout.
      ls_item_layout-fieldname = 'ICON_CLO'.
      ls_item_layout-t_image   = ls_tree_bklas-icon_clo.
      APPEND ls_item_layout TO lt_item_layout.
      CLEAR: ls_item_layout.
      ls_item_layout-fieldname = 'ICON_FIA'.
      ls_item_layout-t_image   = ls_tree_bklas-icon_fia.
      APPEND ls_item_layout TO lt_item_layout.
      CLEAR: ls_tree_bklas-icon, ls_tree_bklas-icon_settle,
             ls_tree_bklas-icon_clo,
             ls_tree_bklas-icon_fia.
      CALL METHOD alv_tree->add_node
        EXPORTING
          i_relat_node_key = l_header_node_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = ls_tree_bklas
          is_node_layout   = ls_node_layout
          it_item_layout   = lt_item_layout
          i_node_text      = ls_tree_bklas-htext
        IMPORTING
          e_new_node_key   = l_relat_key_bklas.
      ls_tree_bklas-node_key = l_relat_key_bklas .
      MODIFY t_tree_data FROM ls_tree_bklas.
      READ TABLE t_tree_data WITH KEY level = 3
                                      mlast = ls_tree_bklas-mlast
                                      bklas = ls_tree_bklas-bklas
                             BINARY SEARCH
                             TRANSPORTING NO FIELDS.
      LOOP AT t_tree_data INTO ls_tree_werks FROM sy-tabix.
        IF ls_tree_werks-level <> 3 OR
           ls_tree_werks-mlast <> ls_tree_bklas-mlast OR
           ls_tree_werks-bklas <> ls_tree_bklas-bklas.
          EXIT.
        ENDIF.
        CLEAR: ls_node_layout.
        ls_node_layout-isfolder = 'X'.
        ls_node_layout-exp_image = '@A8@'.           "ICON_PLANT
        ls_node_layout-n_image = '@A8@'.          "ICON_PLANT





        REFRESH: lt_item_layout.
        CLEAR: ls_item_layout.
        ls_item_layout-fieldname = 'ICON'.
        ls_item_layout-t_image   = ls_tree_werks-icon.
        APPEND ls_item_layout TO lt_item_layout.
        CLEAR: ls_item_layout.
        ls_item_layout-fieldname = 'ICON_SETTLE'.
        ls_item_layout-t_image   = ls_tree_werks-icon_settle.
        APPEND ls_item_layout TO lt_item_layout.
        CLEAR: ls_item_layout.
        ls_item_layout-fieldname = 'ICON_CLO'.
        ls_item_layout-t_image   = ls_tree_werks-icon_clo.
        APPEND ls_item_layout TO lt_item_layout.
        CLEAR: ls_item_layout.
        ls_item_layout-fieldname = 'ICON_FIA'.
        ls_item_layout-t_image   = ls_tree_werks-icon_fia.
        APPEND ls_item_layout TO lt_item_layout.
        CLEAR: ls_tree_werks-icon, ls_tree_werks-icon_settle,
               ls_tree_werks-icon_clo,
               ls_tree_werks-icon_fia.
        CALL METHOD alv_tree->add_node
          EXPORTING
            i_relat_node_key = l_relat_key_bklas
            i_relationship   = cl_gui_column_tree=>relat_last_child
            is_outtab_line   = ls_tree_werks
            is_node_layout   = ls_node_layout
            it_item_layout   = lt_item_layout
            i_node_text      = ls_tree_werks-htext
          IMPORTING
            e_new_node_key   = l_relat_key_werks.
        ls_tree_werks-node_key = l_relat_key_werks.
        MODIFY t_tree_data FROM ls_tree_werks.
        READ TABLE t_tree_data WITH KEY level = 4
                                          mlast = ls_tree_werks-mlast
                                        bklas = ls_tree_werks-bklas
                                        werks = ls_tree_werks-werks
                               BINARY SEARCH
                               TRANSPORTING NO FIELDS.
        LOOP AT t_tree_data INTO ls_tree_mat FROM sy-tabix.
          IF ls_tree_mat-level <> 4 OR
             ls_tree_mat-mlast <> ls_tree_werks-mlast OR
             ls_tree_mat-bklas <> ls_tree_werks-bklas OR
             ls_tree_mat-werks <> ls_tree_werks-werks.
            EXIT.
          ENDIF.
          CLEAR: ls_node_layout.
          IF ls_tree_mat-htext IS INITIAL.
            ls_node_layout-n_image = '@AR@'. "icon_document
          ELSE.
            ls_node_layout-n_image = '@A6@'. "ICON_MATERIAL
          ENDIF.
*       To activate icons in the icon column, we have to support the
*       "item_layout"!
          REFRESH: lt_item_layout.
          CLEAR: ls_item_layout.
          ls_item_layout-fieldname = 'ICON'.
          ls_item_layout-t_image   = ls_tree_mat-icon.
          APPEND ls_item_layout TO lt_item_layout.
          CLEAR: ls_item_layout.
          ls_item_layout-fieldname = 'ICON_SETTLE'.
          ls_item_layout-t_image   = ls_tree_mat-icon_settle.
          APPEND ls_item_layout TO lt_item_layout.
          CLEAR: ls_item_layout.
          ls_item_layout-fieldname = 'ICON_CLO'.
          ls_item_layout-t_image   = ls_tree_mat-icon_clo.
          APPEND ls_item_layout TO lt_item_layout.
          CLEAR: ls_item_layout.
          ls_item_layout-fieldname = 'ICON_FIA'.
          ls_item_layout-t_image   = ls_tree_mat-icon_fia.
          APPEND ls_item_layout TO lt_item_layout.
          IF ls_tree_mat-pb_price < 0.
            CLEAR: ls_item_layout.
            ls_item_layout-fieldname = 'PB_PRICE'.
            ls_item_layout-style =
                    cl_gui_column_tree=>style_emphasized_negative.
            APPEND ls_item_layout TO lt_item_layout.
          ENDIF.
          CLEAR: ls_tree_mat-icon, ls_tree_mat-icon_settle,
                 ls_tree_mat-icon_clo,
                 ls_tree_mat-icon_fia.
          CALL METHOD alv_tree->add_node
            EXPORTING
              i_relat_node_key = l_relat_key_werks
              i_relationship   = cl_gui_column_tree=>relat_last_child
              is_outtab_line   = ls_tree_mat
              is_node_layout   = ls_node_layout
              it_item_layout   = lt_item_layout
              i_node_text      = ls_tree_mat-htext
            IMPORTING
              e_new_node_key   = l_relat_key.
          ls_tree_mat-node_key = l_relat_key.
          MODIFY t_tree_data FROM ls_tree_mat.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

* Expand levels higher than materials
  LOOP AT t_tree_data INTO ls_tree_data WHERE level = 1
                                        OR    level = 2.
    CALL METHOD alv_tree->expand_node
      EXPORTING
        i_node_key       = ls_tree_data-node_key
        i_expand_subtree = ' '.
  ENDLOOP.

* Let the show begin...
  CALL METHOD alv_tree->frontend_update.

* Omtimize columns
  CALL METHOD alv_tree->column_optimize.


ENDFORM.                                                    " tree_show
*&---------------------------------------------------------------------*
*&      Form  exit_command_0042
*&---------------------------------------------------------------------*
FORM exit_command_0042.

  DATA: l_ucomm LIKE sy-ucomm.

  SET PARAMETER ID 'VFMVIEW' FIELD ckml_vfm-view.

  l_ucomm = sy-ucomm.
  CASE l_ucomm.
    WHEN 'ENDE'.
      PERFORM fcode_ende.
    WHEN 'ABBR'.
      PERFORM fcode_abbr.
  ENDCASE.

ENDFORM.                    " exit_command_0042
*&---------------------------------------------------------------------*
*&      Form  fcode_ende
*&---------------------------------------------------------------------*
FORM fcode_ende.

  PERFORM free_tree.
  PERFORM free_grid.
  CALL METHOD custom->free.
  FREE custom.
  CALL METHOD cl_gui_cfw=>flush.

  LEAVE PROGRAM.

ENDFORM.                    " fcode_ende
*&---------------------------------------------------------------------*
*&      Form  fcode_abbr
*&---------------------------------------------------------------------*
FORM fcode_abbr.

  PERFORM free_tree.
  PERFORM free_grid.
  CALL METHOD custom->free.
  FREE custom.
  CALL METHOD cl_gui_cfw=>flush.

  LEAVE PROGRAM.

ENDFORM.                    " fcode_abbr
*&---------------------------------------------------------------------*
*&      Form  fcode_back
*&---------------------------------------------------------------------*
FORM fcode_back.

  PERFORM free_tree.
  PERFORM free_grid.
  CALL METHOD custom->free.
  FREE custom.
  CALL METHOD cl_gui_cfw=>flush.

  IF NOT sy-calld IS INITIAL.
    LEAVE PROGRAM.
  ELSE.
*   Leave klappt nicht, also machen wir einen Restart, um auf das
*   Selektionsbild zu kommen.
    LEAVE TO TRANSACTION 'CKMVFM'.
  ENDIF.


ENDFORM.                    " fcode_back
*&---------------------------------------------------------------------*
*&      Form  user_command_0042
*&---------------------------------------------------------------------*
FORM user_command_0042.

  DATA: l_ucomm LIKE sy-ucomm.

  SET PARAMETER ID 'VFMVIEW' FIELD ckml_vfm-view.
  SET PARAMETER ID 'BUK' FIELD p_bukrs.
  SET PARAMETER ID 'MAT' FIELD r_matnr-low.
  SET PARAMETER ID 'WRK' FIELD r_werks-low.
  SET PARAMETER ID 'BKL' FIELD r_bklas-low.
  SET PARAMETER ID 'BWT' FIELD r_bwtar-low.
  SET PARAMETER ID 'AUN' FIELD r_vbeln-low.
  SET PARAMETER ID 'APO' FIELD r_posnr-low.
  SET PARAMETER ID 'PRO' FIELD r_pspnr-low.
  SET PARAMETER ID 'MTA' FIELD r_mtart-low.
  SET PARAMETER ID 'MKL' FIELD r_matkl-low.
  SET PARAMETER ID 'SPA' FIELD r_spart-low.
  SET PARAMETER ID 'PRC' FIELD r_prctr-low.
  SET PARAMETER ID 'CKML_RUN_TYPE' FIELD p_lauf.
  SET PARAMETER ID 'CKML_RUN_APPL' FIELD p_appl.
  SET PARAMETER ID 'MLP' FIELD p_lpop.
  SET PARAMETER ID 'MLJ' FIELD p_lgja.
  SET PARAMETER ID 'MLB' FIELD p_lgja.
  SET PARAMETER ID 'EXNAM' FIELD p_exnam.

  l_ucomm = sy-ucomm.
  CASE l_ucomm.
    WHEN 'BACK'.
      PERFORM fcode_back.
    WHEN 'CURTP' OR 'ADIFF'.
      PERFORM fcode_curtp_adiff.
    WHEN 'VIEW'.
      PERFORM free_tree.
      PERFORM free_grid.
  ENDCASE.

ENDFORM.                    " user_command_0042
*&---------------------------------------------------------------------*
*&      Form  compressor
*&---------------------------------------------------------------------*
FORM compressor USING    p_view TYPE ckml_vfm_view
                CHANGING pt_tree_compressor LIKE t_tree_compressor[]
                         pt_tree_data LIKE t_tree_data[].

  DATA: pt_ckmvfm_out     LIKE t_ckmvfm_out[],
        ls_tree_data      TYPE s_vfm_tree,
        ls_tree_sum       TYPE s_vfm_tree,
        l_kalnr_space     TYPE ck_kalnr,
        l_werks_space     TYPE werks_d,
        l_bklas_space     TYPE bklas,
        l_mat_values_long TYPE string,
        lt_sum            TYPE ty_sum,
        ls_sum            LIKE LINE OF lt_sum,
        lh_value          TYPE ck_sum_dif,
        ls_ckmvfm_out     TYPE ckmvfm_out,
        ls_out            TYPE s_out,
        pt_out            LIKE t_out[].

  REFRESH: pt_tree_compressor, lt_sum, pt_ckmvfm_out, pt_out.
  CLEAR: ls_sum, lh_value, ls_out, ls_ckmvfm_out.

  SELECT * FROM ckmvfm_out INTO TABLE pt_ckmvfm_out
   WHERE exid = h_exid.

  IF no_auth = 'X'.
    DELETE pt_ckmvfm_out
    WHERE  bwkey IN r_bwkey_no_auth.
  ENDIF.

  LOOP AT pt_ckmvfm_out INTO ls_ckmvfm_out.
    MOVE-CORRESPONDING ls_ckmvfm_out TO ls_out.
    APPEND ls_out TO pt_out.
    CLEAR: ls_ckmvfm_out.
  ENDLOOP.

  IF p_view = 'NV'.
    DELETE pt_out WHERE mlast = '2'.
  ENDIF.

  LOOP AT pt_out ASSIGNING <s_out> WHERE pos_type = 'FIS'.
    MOVE-CORRESPONDING <s_out> TO ls_sum.
    lh_value = <s_out>-sumdif.
    ls_sum-diff_fis = lh_value.
    COLLECT ls_sum INTO lt_sum.
    CLEAR:   ls_sum, lh_value.
  ENDLOOP.

  DELETE lt_sum WHERE diff_fis <> 0.
  SORT lt_sum BY matnr werks bwtar.

  LOOP AT pt_out ASSIGNING <s_out> WHERE curtp = mlkey-curtp.

    CLEAR: ls_tree_data.
    ls_tree_data-level = 4.
    IF NOT <s_out>-kalnr IS INITIAL.
      CALL FUNCTION 'CKMH_F_SET_MSG_VARIABLE_MAT'
        EXPORTING
          i_kalnr       = <s_out>-kalnr
*         I_MATNR       =
*         I_BWTAR       =
*         I_BWKEY       =
*         I_VBELN       =
*         I_POSNR       =
*         I_PSPNR       =
*         I_LIFNR       =
        IMPORTING
*         E_VARIABLE_VALUES        =
*         E_VARIABLE_TEXTS         =
          e_values_long = l_mat_values_long
*       EXCEPTIONS
*         MISSING_INPUT = 1
*         INCONSISTENT_INPUT       = 2
*         INTERNAL_ERROR           = 3
*         OTHERS        = 4
        .
    ELSE.
      l_mat_values_long = TEXT-035.
    ENDIF.
    ls_tree_data-htext = l_mat_values_long.
    ls_tree_data-mlast = <s_out>-mlast.
    ls_tree_data-vprsv = <s_out>-vprsv.
    ls_tree_data-bklas = <s_out>-bklas.
    ls_tree_data-werks = <s_out>-werks.
    ls_tree_data-kalnr = <s_out>-kalnr.
    ls_tree_data-matnr = <s_out>-matnr.
    ls_tree_data-bwtar = <s_out>-bwtar.
    ls_tree_data-vbeln = <s_out>-vbeln.
    ls_tree_data-posnr = <s_out>-posnr.
    ls_tree_data-pspnr = <s_out>-pspnr.
    ls_tree_data-curtp = <s_out>-curtp.
    ls_tree_data-waers = <s_out>-waers.
    ls_tree_data-meins = <s_out>-meins.
    ls_tree_data-mtart = <s_out>-mtart.
    ls_tree_data-matkl = <s_out>-matkl.
    ls_tree_data-spart = <s_out>-spart.
    ls_tree_data-prctr = <s_out>-prctr.
    ls_tree_data-stprs = <s_out>-stprs.
    IF <s_out>-pos_type = 'CUM'.
      ls_tree_data-value_cum = <s_out>-value_cum.
      ls_tree_data-pb_price = <s_out>-pb_price.
      ls_tree_data-price_cum = <s_out>-price_cum.
      ls_tree_data-lbkum = <s_out>-lbkum.
      ls_tree_data-pb_quantity = <s_out>-pbpopo.
      ls_tree_data-quantity_cum = <s_out>-quantity_cum.
      ls_tree_data-salk3 = <s_out>-salk3.
      ls_tree_data-icon = <s_out>-icon.
      ls_tree_data-icon_settle = <s_out>-icon_settle.
      ls_tree_data-icon_clo = <s_out>-icon_clo.
      ls_tree_data-icon_fia = <s_out>-icon_fia.
      ls_tree_data-rescale = <s_out>-rescale.
      ls_tree_data-status = <s_out>-status.
    ENDIF.
    CASE ckml_vfm-sel_anzeige_diff.
      WHEN 'D'.
        PERFORM move_diff USING <s_out>-pos_type
                                <s_out>-sumdif
                          CHANGING ls_tree_data.
      WHEN 'P'.
        PERFORM move_diff USING <s_out>-pos_type
                                <s_out>-prdif
                          CHANGING ls_tree_data.
      WHEN 'K'.
        PERFORM move_diff USING <s_out>-pos_type
                                <s_out>-krdif
                          CHANGING ls_tree_data.
      WHEN 'G'.
        PERFORM move_diff USING <s_out>-pos_type
                                <s_out>-estdif
                          CHANGING ls_tree_data.
      WHEN 'O'.
        PERFORM move_diff USING <s_out>-pos_type
                                <s_out>-mstdif
                          CHANGING ls_tree_data.
      WHEN 'E'.
        PERFORM move_diff USING <s_out>-pos_type
                                <s_out>-estprd
                          CHANGING ls_tree_data.
      WHEN 'F'.
        PERFORM move_diff USING <s_out>-pos_type
                                <s_out>-estkdm
                          CHANGING ls_tree_data.
      WHEN 'M'.
        PERFORM move_diff USING <s_out>-pos_type
                                <s_out>-mstprd
                          CHANGING ls_tree_data.
      WHEN 'N'.
        PERFORM move_diff USING <s_out>-pos_type
                                <s_out>-mstkdm
                          CHANGING ls_tree_data.
    ENDCASE.
    IF <s_out>-pos_type = 'CUM' AND <s_out>-icon_fia = icon_led_red.
      READ TABLE lt_sum WITH KEY matnr = <s_out>-matnr
                                 werks = <s_out>-werks
                                 bwtar = <s_out>-bwtar
                                 BINARY SEARCH TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.
        ls_tree_data-icon_fia = icon_led_yellow.
      ENDIF.

    ENDIF.

    INSERT ls_tree_data INTO TABLE pt_tree_compressor.
    IF sy-subrc <> 0.
      CASE <s_out>-pos_type.
        WHEN 'NDI'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_ndi.
        WHEN 'CUM'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_cum value_cum pb_price
                                    price_cum icon icon_settle
                                    icon_clo icon_fia rescale
                                    lbkum salk3 status
                                    pb_quantity quantity_cum.
        WHEN 'PRA'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_pra.
        WHEN 'MLS'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_mls.
        WHEN 'NIN'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_nin.
        WHEN 'RSC'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_rsc.
        WHEN 'NLE'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_nle.
        WHEN 'WIP'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_wip.
        WHEN 'VNO'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_vno.
        WHEN 'OST'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_ost.
        WHEN 'EIV'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                         TRANSPORTING diff_eiv.
        WHEN 'FIA'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_fia.
        WHEN 'FIS'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_fis.
        WHEN 'UMB'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_umb.
        WHEN 'ABC'.
          MODIFY TABLE pt_tree_compressor FROM ls_tree_data
                       TRANSPORTING diff_abc.
      ENDCASE.
    ENDIF.

*   Bei flachem ALV-Grid sind wir hier fertig!
    CHECK p_view <> 'FM'.

*   Aggregieren!

    CLEAR: l_kalnr_space, l_werks_space, l_bklas_space.
*   Level 3 (Werke):
    CLEAR: ls_tree_sum.
    READ TABLE pt_tree_compressor INTO ls_tree_sum
                                  WITH KEY level = 3
mlast = ls_tree_data-mlast
                                           bklas = ls_tree_data-bklas
                                           werks = ls_tree_data-werks
                                           kalnr = l_kalnr_space
                                           curtp = ls_tree_data-curtp
                                           BINARY SEARCH.
    IF sy-subrc = 0.
      PERFORM sum_it_up USING ls_tree_data
                        CHANGING ls_tree_sum.
      MODIFY TABLE pt_tree_compressor FROM ls_tree_sum.
    ELSE.
      MOVE-CORRESPONDING ls_tree_data TO ls_tree_sum.
      ls_tree_sum-level = 3.
      CLEAR: ls_tree_sum-kalnr, ls_tree_sum-mtart, ls_tree_sum-matkl,
             ls_tree_sum-spart, ls_tree_sum-prctr, ls_tree_sum-pb_price,
             ls_tree_sum-price_cum, ls_tree_sum-status.
      CONCATENATE ls_tree_sum-werks <s_out>-name1
                  INTO ls_tree_sum-htext
                  SEPARATED BY space.
      INSERT ls_tree_sum INTO TABLE pt_tree_compressor.
    ENDIF.
*   Level 2 (Bewertungsklassen):
    CLEAR: ls_tree_sum.
    READ TABLE pt_tree_compressor INTO ls_tree_sum
                                  WITH KEY level = 2
mlast = ls_tree_data-mlast
                                           bklas = ls_tree_data-bklas
                                           werks = l_werks_space
                                           kalnr = l_kalnr_space
                                           curtp = ls_tree_data-curtp
                                           BINARY SEARCH.
    IF sy-subrc = 0.
      PERFORM sum_it_up USING ls_tree_data
                        CHANGING ls_tree_sum.
      MODIFY TABLE pt_tree_compressor FROM ls_tree_sum.
    ELSE.
      MOVE-CORRESPONDING ls_tree_data TO ls_tree_sum.
      ls_tree_sum-level = 2.
      CLEAR: ls_tree_sum-kalnr, ls_tree_sum-werks, ls_tree_sum-mtart,
             ls_tree_sum-matkl, ls_tree_sum-spart, ls_tree_sum-prctr,
             ls_tree_sum-pb_price, ls_tree_sum-price_cum,
             ls_tree_sum-status.
      CONCATENATE ls_tree_sum-bklas <s_out>-bkbez
                  INTO ls_tree_sum-htext
                  SEPARATED BY space.
      INSERT ls_tree_sum INTO TABLE pt_tree_compressor.
    ENDIF.
*   Level 1 (Buchungskreis (nur einer)):
    CLEAR: ls_tree_sum.
    READ TABLE pt_tree_compressor INTO ls_tree_sum
                                  WITH KEY level = 1
mlast = ls_tree_data-mlast
                                           bklas = l_bklas_space
                                           werks = l_werks_space
                                           kalnr = l_kalnr_space
                                           curtp = ls_tree_data-curtp
                                           BINARY SEARCH.
    IF sy-subrc = 0.
      PERFORM sum_it_up USING ls_tree_data
                        CHANGING ls_tree_sum.
      MODIFY TABLE pt_tree_compressor FROM ls_tree_sum.
    ELSE.
      MOVE-CORRESPONDING ls_tree_data TO ls_tree_sum.
      ls_tree_sum-level = 1.
      CLEAR: ls_tree_sum-kalnr, ls_tree_sum-werks, ls_tree_sum-bklas,
             ls_tree_sum-matnr, ls_tree_sum-mtart, ls_tree_sum-matkl,
             ls_tree_sum-spart, ls_tree_sum-prctr, ls_tree_sum-pb_price,
             ls_tree_sum-price_cum, ls_tree_sum-status.
      CONCATENATE TEXT-041  <s_out>-mlast
                  INTO ls_tree_sum-htext
                  SEPARATED BY space.
      INSERT ls_tree_sum INTO TABLE pt_tree_compressor.
    ENDIF.

  ENDLOOP.

  pt_tree_data[] = pt_tree_compressor[].
  SORT pt_tree_data BY level mlast bklas werks kalnr.

ENDFORM.                    " compressor
*&---------------------------------------------------------------------*
*&      Form  sum_it_up
*&---------------------------------------------------------------------*
FORM sum_it_up USING    ps_tree_data TYPE s_vfm_tree
               CHANGING ps_tree_sum TYPE s_vfm_tree.

  ps_tree_sum-diff_ndi = ps_tree_sum-diff_ndi + ps_tree_data-diff_ndi.
  ps_tree_sum-diff_pra = ps_tree_sum-diff_pra + ps_tree_data-diff_pra.
  ps_tree_sum-diff_mls = ps_tree_sum-diff_mls + ps_tree_data-diff_mls.
  ps_tree_sum-diff_cum = ps_tree_sum-diff_cum + ps_tree_data-diff_cum.
  ps_tree_sum-diff_nin = ps_tree_sum-diff_nin + ps_tree_data-diff_nin.
  ps_tree_sum-diff_rsc = ps_tree_sum-diff_rsc + ps_tree_data-diff_rsc.
  ps_tree_sum-diff_nle = ps_tree_sum-diff_nle + ps_tree_data-diff_nle.
  ps_tree_sum-diff_wip = ps_tree_sum-diff_wip + ps_tree_data-diff_wip.
  ps_tree_sum-diff_vno = ps_tree_sum-diff_vno + ps_tree_data-diff_vno.
  ps_tree_sum-diff_ost = ps_tree_sum-diff_ost + ps_tree_data-diff_ost.
  ps_tree_sum-diff_eiv = ps_tree_sum-diff_eiv + ps_tree_data-diff_eiv.
  ps_tree_sum-diff_fia = ps_tree_sum-diff_fia + ps_tree_data-diff_fia.
  ps_tree_sum-diff_fis = ps_tree_sum-diff_fis + ps_tree_data-diff_fis.
  ps_tree_sum-diff_umb = ps_tree_sum-diff_umb + ps_tree_data-diff_umb.
  ps_tree_sum-diff_abc = ps_tree_sum-diff_abc + ps_tree_data-diff_abc.
  CATCH SYSTEM-EXCEPTIONS conversion_errors = 1
                          arithmetic_errors = 2.
    ps_tree_sum-value_cum = ps_tree_sum-value_cum +
                            ps_tree_data-value_cum.
  ENDCATCH.
  IF sy-subrc <> 0.
    ps_tree_sum-value_cum = '9999999999999.99'.
  ENDIF.

* Mengen zu summieren macht wegen verschiedener Mengeneinheiten kaum
* Sinn!
* Preise auch nicht!
  CLEAR: ps_tree_sum-lbkum, ps_tree_sum-pb_quantity,
         ps_tree_sum-quantity_cum, ps_tree_sum-meins,
         ps_tree_sum-price_cum, ps_tree_sum-pb_price,
         ps_tree_sum-status.
*  ps_tree_sum-lbkum = ps_tree_sum-lbkum + ps_tree_data-lbkum.
*  ps_tree_sum-pb_quantity = ps_tree_sum-pb_quantity +
*                            ps_tree_data-pb_quantity.
*  ps_tree_sum-quantity_cum = ps_tree_sum-quantity_cum +
*                             ps_tree_data-quantity_cum.
  ps_tree_sum-salk3 = ps_tree_sum-salk3 + ps_tree_data-salk3.
  IF ps_tree_sum-icon <> icon_led_red AND
     NOT ps_tree_data-icon IS INITIAL.
    ps_tree_sum-icon = ps_tree_data-icon.
  ENDIF.
  IF ps_tree_sum-icon_settle <> icon_led_inactive AND
     NOT ps_tree_data-icon_settle IS INITIAL.
    ps_tree_sum-icon_settle = ps_tree_data-icon_settle.
  ENDIF.
  IF ps_tree_sum-icon_clo <> icon_led_inactive AND
     NOT ps_tree_data-icon_clo IS INITIAL.
    ps_tree_sum-icon_clo = ps_tree_data-icon_clo.
  ENDIF.
  IF ps_tree_sum-icon_fia <> icon_led_red AND
     NOT ps_tree_data-icon_fia IS INITIAL.
    ps_tree_sum-icon_fia = ps_tree_data-icon_fia.
  ENDIF.
  IF ps_tree_sum-rescale IS INITIAL AND
     NOT ps_tree_data-rescale IS INITIAL.
    ps_tree_sum-rescale = ps_tree_data-rescale.
  ENDIF.

ENDFORM.                                                    " sum_it_up
*&---------------------------------------------------------------------*
*&      Form  free_tree
*&---------------------------------------------------------------------*
FORM free_tree.

  IF NOT alv_tree IS INITIAL.
    CALL METHOD alv_tree->free.
  ENDIF.
  FREE alv_tree.

ENDFORM.                                                    " free_tree
*&---------------------------------------------------------------------*
*&      Form  free_grid
*&---------------------------------------------------------------------*
FORM free_grid.

  IF NOT alv_grid IS INITIAL.
    CALL METHOD alv_grid->free.
  ENDIF.
  FREE alv_grid.

ENDFORM.                                                    " free_grid
*&---------------------------------------------------------------------*
*&      Form  grid_controls_create
*&---------------------------------------------------------------------*
FORM grid_controls_create.

* Custom-Container erzeugen
  IF custom IS INITIAL.
    CREATE OBJECT custom
      EXPORTING
        container_name = 'CUSTOM'.
  ENDIF.

* ALV-Tree erzeugen
  CREATE OBJECT alv_grid
    EXPORTING
      i_parent = custom.

ENDFORM.                    " grid_controls_create
*&---------------------------------------------------------------------*
*&      Form  grid_show
*&---------------------------------------------------------------------*
FORM grid_show.

  DATA: ls_variant TYPE disvariant,
        ls_layout  TYPE lvc_s_layo,
        l_func     TYPE ui_func.

* Varianten
  CLEAR: ls_variant.
  ls_variant-report = sy-repid.
  ls_variant-handle = 'LIS'.

* Layout
  CLEAR ls_layout.
*  ls_layout-keyhot = 'X'.
  ls_layout-cwidth_opt = 'X'.
  ls_layout-zebra = 'X'.

  CALL METHOD alv_grid->set_table_for_first_display
    EXPORTING
      is_variant      = ls_variant
      i_save          = 'A'
      is_layout       = ls_layout
*     it_toolbar_excluding = lt_exclude
    CHANGING
      it_outtab       = t_tree_data
      it_sort         = t_sort
      it_fieldcatalog = t_fieldcat.

ENDFORM.                                                    " grid_show
*&---------------------------------------------------------------------*
*&      Form  tree_double_click
*&---------------------------------------------------------------------*
FORM tree_double_click USING p_node_key.

  DATA: ls_tree_data TYPE s_vfm_tree,
        ls_exit      TYPE slis_exit_by_user,
        l_tabix      TYPE sytabix,
        l_bwkey      TYPE bwkey.

  PERFORM tree_tabix_holen USING    p_node_key
                           CHANGING l_tabix.
  READ TABLE t_tree_show INTO ls_tree_data INDEX l_tabix.
  IF sy-subrc = 0.
    CASE ls_tree_data-level.
      WHEN '1'.
      WHEN '2'.
      WHEN '3'.
      WHEN '4'.
        IF tcurm-bwkrs_cus = '3'.            "Bewertungsebene BURKS
          l_bwkey = p_bukrs.
        ELSE.
          l_bwkey = ls_tree_data-werks.
        ENDIF.
        CALL FUNCTION 'CKM8_ML_DATA_DISPLAY'
          EXPORTING
            i_matnr  = ls_tree_data-matnr
            i_bwkey  = l_bwkey
            i_bwtar  = ls_tree_data-bwtar
            i_vbeln  = ls_tree_data-vbeln
            i_posnr  = ls_tree_data-posnr
            i_pspnr  = ls_tree_data-pspnr
            i_bdatj  = p_bdatj
            i_poper  = p_poper
            i_curtp  = ls_tree_data-curtp
            i_run_id = s_runperiod-run_id
          IMPORTING
            e_exit   = ls_exit.
*       Falls 'BEENDEN' gewählt, ganz raus
        IF ls_exit-exit EQ 'X'.
          PERFORM fcode_ende.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    " tree_double_click
*&---------------------------------------------------------------------*
*&      Form  tree_context_menu
*&---------------------------------------------------------------------*
FORM tree_context_menu USING VALUE(p_node_key) TYPE lvc_nkey
                             menu              TYPE REF TO cl_ctmenu.

  DATA: ls_tree_data TYPE s_vfm_tree,
        l_tabix      TYPE sytabix,
        l_fcode      TYPE ui_func,
        l_text       TYPE gui_text.

  PERFORM tree_tabix_holen USING    p_node_key
                           CHANGING l_tabix.
  READ TABLE t_tree_show INTO ls_tree_data INDEX l_tabix.
  IF sy-subrc = 0.
    CLEAR: l_fcode.
    CASE ls_tree_data-level.
      WHEN '1'.
        IF ckml_vfm-view = 'NV'.
          l_fcode = 'DEL_PB'.
          l_text  = TEXT-013.
        ENDIF.
      WHEN '2'.
        IF ckml_vfm-view = 'NV'.
          l_fcode = 'DEL_PB'.
          l_text  = TEXT-013.
        ENDIF.
      WHEN '3'.
        IF ckml_vfm-view = 'NV'.
          l_fcode = 'DEL_PB'.
          l_text  = TEXT-013.
        ENDIF.
      WHEN '4'.
        l_fcode = 'DETAIL'.
        l_text  = TEXT-009.
        CALL METHOD menu->add_function
          EXPORTING
            fcode = l_fcode
            text  = l_text.
        l_fcode = 'DET_NDI'.
        l_text  = TEXT-015.
        CALL METHOD menu->add_function
          EXPORTING
            fcode = l_fcode
            text  = l_text.
        IF ckml_vfm-view = 'MO' AND NOT p_fiacc IS INITIAL.
          l_fcode = 'DET_FIA'.
          l_text  = TEXT-023.
          CALL METHOD menu->add_function
            EXPORTING
              fcode = l_fcode
              text  = l_text.
        ENDIF.
        IF ckml_vfm-view = 'NV'.
          l_fcode = 'DEL_PB'.
          l_text  = TEXT-013.
        ELSE.
          CLEAR: l_fcode.
        ENDIF.
    ENDCASE.
  ENDIF.
  IF NOT l_fcode IS INITIAL.
    CALL METHOD menu->add_function
      EXPORTING
        fcode = l_fcode
        text  = l_text.
  ENDIF.


ENDFORM.                    " tree_context_menu
*&---------------------------------------------------------------------*
*&      Form  tree_toolbar_change
*&---------------------------------------------------------------------*
FORM tree_toolbar_change.

  DATA: l_disabled TYPE c.

* Toolbar holen
  CALL METHOD alv_tree->get_toolbar_object
    IMPORTING
      er_toolbar = alv_tree_toolbar.

  CALL METHOD alv_tree_toolbar->add_button
    EXPORTING
      fcode     = ''
      icon      = ''
      butn_type = 3
      quickinfo = ''.
  CALL METHOD alv_tree_toolbar->add_button
    EXPORTING
      fcode     = 'DETAIL'
      icon      = '@16@'         "icon_select_detail
      butn_type = 0
      quickinfo = TEXT-010.      "Detail auswählen
  CALL METHOD alv_tree_toolbar->add_button
    EXPORTING
      fcode     = 'DET_NDI'
      icon      = '@3R@'         "icon_detail
      butn_type = 0
      text      = TEXT-014       ""Nicht verteilt"
      quickinfo = TEXT-015.      "Erklärung "Nicht verteilt"
  IF NOT p_fiacc IS INITIAL.
    CALL METHOD alv_tree_toolbar->add_button
      EXPORTING
        fcode     = 'DET_FIA'
        icon      = '@AR@'         "icon_document
        butn_type = 0
        text      = TEXT-022       "FI Buchungen
        quickinfo = TEXT-023.      "Erklärung FI Buchungen
  ENDIF.
* Button für "Preisbegrenzermenge löschen" nur auf Sicht "Analyse "Nicht
* verteilt"" aktiv!
  IF ckml_vfm-view = 'NV'.
*    clear: l_disabled.
*  else.
*    l_disabled = 'X'.
*  endif.
    CALL METHOD alv_tree_toolbar->add_button
      EXPORTING
        fcode       = 'DEL_PB'
        icon        = '@11@'         "icon_delete
        is_disabled = l_disabled
        butn_type   = 0
        text        = TEXT-012
        quickinfo   = TEXT-013.      "PB-Menge löschen
  ENDIF.
*  CALL METHOD alv_tree_toolbar->add_button
*       EXPORTING
*            fcode     = 'LEGE'
*            icon      = '@3D@'         "icon_icon_list
*            butn_type = 0
**           text      = text-028.
*            quickinfo = text-011.      "Legende anzeigen


ENDFORM.                    " tree_toolbar_change
*&---------------------------------------------------------------------*
*&      Form  tree_events_register
*&---------------------------------------------------------------------*
FORM tree_events_register.

  DATA: lt_events TYPE cntl_simple_events,
        ls_event  TYPE cntl_simple_event.

* Ereignisse Toolbar
  CLEAR: ls_event.
  ls_event-appl_event = 'X'.
  ls_event-eventid = cl_gui_toolbar=>m_id_function_selected.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_toolbar=>m_id_dropdown_clicked.
  APPEND ls_event TO lt_events.

  CALL METHOD alv_tree_toolbar->set_registered_events
    EXPORTING
      events = lt_events.

* Ereignisse ALV-Tree
  REFRESH: lt_events.
  CLEAR: ls_event.
  ls_event-appl_event = 'X'.
  ls_event-eventid = cl_gui_column_tree=>eventid_expand_no_children.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_column_tree=>eventid_node_context_menu_req.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_column_tree=>eventid_item_context_menu_req.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_column_tree=>eventid_item_keypress.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_column_tree=>eventid_header_click.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_column_tree=>eventid_header_context_men_req.
  APPEND ls_event TO lt_events.

  CALL METHOD alv_tree->set_registered_events
    EXPORTING
      events = lt_events.

* Event-Handler anschließen
  CREATE OBJECT event_receiver.
  SET HANDLER event_receiver->my_function_selected
                              FOR alv_tree_toolbar.
  SET HANDLER event_receiver->my_node_double_click
                              FOR alv_tree.
  SET HANDLER event_receiver->my_node_context_menu_request
                              FOR alv_tree.
  SET HANDLER event_receiver->my_node_context_menu_selected
                              FOR alv_tree.
  SET HANDLER event_receiver->my_item_double_click
                              FOR alv_tree.
  SET HANDLER event_receiver->my_item_context_menu_request
                              FOR alv_tree.
  SET HANDLER event_receiver->my_item_context_menu_selected
                              FOR alv_tree.
  SET HANDLER event_receiver->my_before_user_command
                              FOR alv_tree.
  SET HANDLER event_receiver->my_top_of_list
                              FOR alv_tree.


ENDFORM.                    " tree_events_register
*&---------------------------------------------------------------------*
*&      Form  tree_detail
*&---------------------------------------------------------------------*
FORM tree_detail.

  DATA: lt_selected_nodes TYPE lvc_t_nkey,
        l_node_key        TYPE lvc_nkey,
        l_fieldname       TYPE lvc_fname.

  REFRESH: lt_selected_nodes.
  CALL METHOD alv_tree->get_selected_nodes
    CHANGING
      ct_selected_nodes = lt_selected_nodes.
  IF lt_selected_nodes[] IS INITIAL.
    CALL METHOD alv_tree->get_selected_item
      IMPORTING
        e_selected_node = l_node_key
        e_fieldname     = l_fieldname.
  ELSE.
    READ TABLE lt_selected_nodes INTO l_node_key INDEX 1.
  ENDIF.
  IF NOT l_node_key IS INITIAL.
    PERFORM tree_double_click USING l_node_key.
  ENDIF.

ENDFORM.                    " tree_detail
*&---------------------------------------------------------------------*
*&      Form  tree_tabix_holen
*&---------------------------------------------------------------------*
FORM tree_tabix_holen USING VALUE(i_node_key) TYPE lvc_nkey
                      CHANGING VALUE(e_tabix) TYPE sytabix.

  DATA: lt_nodes    TYPE lvc_t_nkey,
        l_top_node  TYPE lvc_nkey,
        l_top_index TYPE sytabix,
        l_sel_index TYPE sytabix.

  CALL METHOD alv_tree->get_children
    EXPORTING
      i_node_key  = cl_gui_alv_tree=>c_virtual_root_node
    IMPORTING
      et_children = lt_nodes.
  READ TABLE lt_nodes INTO l_top_node INDEX 1.

  MOVE l_top_node TO l_top_index.
  MOVE i_node_key TO l_sel_index.
  e_tabix = l_sel_index - l_top_index + 1.

ENDFORM.                    " tree_tabix_holen
*&---------------------------------------------------------------------*
*&      Form  tree_explain_ndi
*&---------------------------------------------------------------------*
FORM tree_explain_ndi.

  DATA: lt_selected_nodes TYPE lvc_t_nkey,
        ls_tree_data      TYPE s_vfm_tree,
        l_tabix           TYPE sytabix,
        l_node_key        TYPE lvc_nkey,
        l_fieldname       TYPE lvc_fname.

  REFRESH: lt_selected_nodes.
  CALL METHOD alv_tree->get_selected_nodes
    CHANGING
      ct_selected_nodes = lt_selected_nodes.
  IF lt_selected_nodes[] IS INITIAL.
    CALL METHOD alv_tree->get_selected_item
      IMPORTING
        e_selected_node = l_node_key
        e_fieldname     = l_fieldname.
  ELSE.
    READ TABLE lt_selected_nodes INTO l_node_key INDEX 1.
  ENDIF.
  IF NOT l_node_key IS INITIAL.
    PERFORM tree_tabix_holen USING    l_node_key
                             CHANGING l_tabix.
    READ TABLE t_tree_show INTO ls_tree_data INDEX l_tabix.
    IF sy-subrc = 0 AND ls_tree_data-level = '4'.
      SUBMIT ml_analyse_not_dist WITH p_kalnr = ls_tree_data-kalnr
                                 WITH p_matnr = ls_tree_data-matnr
                                 WITH p_bukrs = p_bukrs
                                 WITH p_werks = ls_tree_data-werks
                                 WITH p_bdatj = p_bdatj
                                 WITH p_poper = p_poper
                                 WITH p_untper = s_runperiod-untper
                                 WITH p_curtp = mlkey-curtp
                                 AND RETURN.
    ELSE.
      MESSAGE s663.
    ENDIF.
  ENDIF.

ENDFORM.                    " tree_explain_ndi
*&---------------------------------------------------------------------*
*&      Form  tree_delete_pb
*&---------------------------------------------------------------------*
FORM tree_delete_pb.

  DATA: lt_selected_nodes TYPE lvc_t_nkey,
        lt_kalnr          TYPE ckmv0_matobj_tbl,
        lt_item_layout    TYPE lvc_t_laci,
        ls_kalnr          TYPE ckmv0_matobj_str,
        ls_tree_data      TYPE s_vfm_tree,
        ls_tree_upd       TYPE s_vfm_tree,
        ls_tree_change    TYPE s_vfm_tree,
        ls_item_layout    TYPE lvc_s_laci,
        ls_ckmlpp         TYPE ckmlpp,
        l_tabix           TYPE sytabix,
        l_node_key        TYPE lvc_nkey,
        l_fieldname       TYPE lvc_fname,
        l_pbpopo_clear    LIKE ckmlpp-pbpopo,
        l_lines           TYPE i,
        l_help            TYPE string,                      "chg note 1697430
        l_text(60)        TYPE c,
        l_rtc             TYPE sy-subrc.                             "note 1477309

  REFRESH: lt_selected_nodes.
  IF NOT alv_tree IS INITIAL.
    CALL METHOD alv_tree->get_selected_nodes
      CHANGING
        ct_selected_nodes = lt_selected_nodes.
    IF lt_selected_nodes[] IS INITIAL.
      CALL METHOD alv_tree->get_selected_item
        IMPORTING
          e_selected_node = l_node_key
          e_fieldname     = l_fieldname.
    ELSE.
      READ TABLE lt_selected_nodes INTO l_node_key INDEX 1.
    ENDIF.
  ENDIF.
  IF NOT l_node_key IS INITIAL.
    PERFORM tree_tabix_holen USING    l_node_key
                             CHANGING l_tabix.
    READ TABLE t_tree_show INTO ls_tree_data INDEX l_tabix.
    IF sy-subrc = 0.
      CLEAR: l_pbpopo_clear.
      REFRESH: lt_item_layout.
      CLEAR: ls_item_layout.
      ls_item_layout-fieldname = 'ICON_EST'.
      ls_item_layout-t_image   = icon_led_inactive.
      ls_item_layout-u_t_image = 'X'.
      APPEND ls_item_layout TO lt_item_layout.
      CLEAR: ls_item_layout.
      ls_item_layout-fieldname = 'ICON_MST'.
      ls_item_layout-t_image   = icon_led_inactive.
      ls_item_layout-u_t_image = 'X'.
      APPEND ls_item_layout TO lt_item_layout.

      CASE ls_tree_data-level.
        WHEN '1'.
          REFRESH: lt_kalnr.
          LOOP AT t_tree_show INTO ls_tree_upd
                              WHERE level = '4'
                              AND   mlast = ls_tree_data-mlast.
            IF ( ls_tree_upd-status = y_abschlussbuchung_erfolgt ).
              CONTINUE.
            ENDIF.
            CLEAR: ls_kalnr.
            ls_kalnr-kalnr = ls_tree_upd-kalnr.
            APPEND ls_kalnr TO lt_kalnr.
          ENDLOOP.
          CLEAR: l_lines, l_text.
* Customer can make a mass update, but has to confirm:
          DESCRIBE TABLE lt_kalnr LINES l_lines.
          IF l_lines = 0.
            EXIT.
          ENDIF.
          l_help = l_lines.
          CONCATENATE TEXT-056 l_help INTO l_text SEPARATED BY space.
          PERFORM popup_dialog
                  USING    'Y' l_text TEXT-057 TEXT-058
                  CHANGING lh_doit.
          IF lh_doit = 'N' OR
             lh_doit = 'A'.
          ELSE.
*           start of                                     "note 1477309
*           check change authorization for valuation area
            PERFORM auth_check_for_del_pbpopo
              TABLES   lt_kalnr
              CHANGING l_rtc.
            IF l_rtc NE 0.
              EXIT.
            ENDIF.
*           end   of                                     "note 1477309
            IF NOT alv_tree IS INITIAL.
              LOOP AT t_tree_show INTO ls_tree_upd
                                WHERE level = '4'
                                AND   mlast = ls_tree_data-mlast.
                READ TABLE t_tree_data INTO ls_tree_change
                                     WITH KEY level = ls_tree_upd-level
                                              mlast = ls_tree_upd-mlast
                                              bklas = ls_tree_upd-bklas
                                              werks = ls_tree_upd-werks
                                              kalnr = ls_tree_upd-kalnr
                                                 BINARY SEARCH.
                IF sy-subrc = 0.
                  CLEAR: ls_tree_change-pb_quantity.
                  MODIFY TABLE t_tree_data FROM ls_tree_change.
                  CALL METHOD alv_tree->change_node
                    EXPORTING
                      i_node_key     = ls_tree_change-node_key
                      i_outtab_line  = ls_tree_change
                      it_item_layout = lt_item_layout.
                ENDIF.
              ENDLOOP.
            ENDIF.
            PERFORM tree_del_pbpopo_from_kalnr USING lt_kalnr.
          ENDIF.
        WHEN '2'.
          REFRESH: lt_kalnr.
          LOOP AT t_tree_show INTO ls_tree_upd
                              WHERE level = '4'
                              AND   mlast  = ls_tree_data-mlast
                              AND   bklas = ls_tree_data-bklas.
            IF ( ls_tree_upd-pb_price < 0 ).
              CONTINUE.
            ENDIF.
            CLEAR: ls_kalnr.
            ls_kalnr-kalnr = ls_tree_upd-kalnr.
            APPEND ls_kalnr TO lt_kalnr.
          ENDLOOP.
          CLEAR: l_lines, l_text.
* Customer can make a mass update, but has to confirm:
          DESCRIBE TABLE lt_kalnr LINES l_lines.
          IF l_lines = 0.
            EXIT.
          ENDIF.
          l_help = l_lines.
          CONCATENATE TEXT-056 l_help INTO l_text SEPARATED BY space.
          PERFORM popup_dialog
                  USING    'Y' l_text TEXT-057 TEXT-058
                  CHANGING lh_doit.
          IF lh_doit = 'N' OR
             lh_doit = 'A'.
          ELSE.
*           start of                                     "note 1477309
*           check change authorization for valuation area
            PERFORM auth_check_for_del_pbpopo
              TABLES   lt_kalnr
              CHANGING l_rtc.
            IF l_rtc NE 0.
              EXIT.
            ENDIF.
*           end   of                                     "note 1477309
            IF NOT alv_tree IS INITIAL.
              LOOP AT t_tree_show INTO ls_tree_upd
                 WHERE level = '4'
                 AND   mlast  = ls_tree_data-mlast
                 AND   bklas = ls_tree_data-bklas.
                READ TABLE t_tree_data INTO ls_tree_change
                                     WITH KEY level = ls_tree_upd-level
                                              mlast = ls_tree_upd-mlast
                                              bklas = ls_tree_upd-bklas
                                              werks = ls_tree_upd-werks
                                              kalnr = ls_tree_upd-kalnr
                                               BINARY SEARCH.
                IF sy-subrc = 0.
                  CLEAR: ls_tree_change-pb_quantity.
                  MODIFY TABLE t_tree_data FROM ls_tree_change.
                  CALL METHOD alv_tree->change_node
                    EXPORTING
                      i_node_key     = ls_tree_change-node_key
                      i_outtab_line  = ls_tree_change
                      it_item_layout = lt_item_layout.
                ENDIF.
              ENDLOOP.
            ENDIF.
            PERFORM tree_del_pbpopo_from_kalnr USING lt_kalnr.
          ENDIF.
        WHEN '3'.
          REFRESH: lt_kalnr.
          LOOP AT t_tree_show INTO ls_tree_upd
                              WHERE level = '4'
                              AND   mlast = ls_tree_data-mlast
                              AND   bklas = ls_tree_data-bklas
                              AND   werks = ls_tree_data-werks.
            IF ( ls_tree_upd-pb_price < 0 ).
              CONTINUE.
            ENDIF.
            CLEAR: ls_kalnr.
            ls_kalnr-kalnr = ls_tree_upd-kalnr.
            APPEND ls_kalnr TO lt_kalnr.
          ENDLOOP.
          CLEAR: l_lines, l_text.
* Customer can make a mass update, but has to confirm:
          DESCRIBE TABLE lt_kalnr LINES l_lines.
          IF l_lines = 0.
            EXIT.
          ENDIF.
          l_help = l_lines.
          CONCATENATE TEXT-056 l_help INTO l_text SEPARATED BY space.
          PERFORM popup_dialog
                  USING    'Y' l_text TEXT-057 TEXT-058
                  CHANGING lh_doit.
          IF lh_doit = 'N' OR
             lh_doit = 'A'.
          ELSE.
*           start of                                     "note 1477309
*           check change authorization for valuation area
            PERFORM auth_check_for_del_pbpopo
              TABLES   lt_kalnr
              CHANGING l_rtc.
            IF l_rtc NE 0.
              EXIT.
            ENDIF.
*           end   of                                     "note 1477309
            IF NOT alv_tree IS INITIAL.
              LOOP AT t_tree_show INTO ls_tree_upd
                              WHERE level = '4'
                              AND   mlast = ls_tree_data-mlast
                              AND   bklas = ls_tree_data-bklas
                              AND   werks = ls_tree_data-werks.
                READ TABLE t_tree_data INTO ls_tree_change
                                     WITH KEY level = ls_tree_upd-level
                                              mlast = ls_tree_upd-mlast
                                              bklas = ls_tree_upd-bklas
                                              werks = ls_tree_upd-werks
                                              kalnr = ls_tree_upd-kalnr
                                                   BINARY SEARCH.
                IF sy-subrc = 0.
                  CLEAR: ls_tree_change-pb_quantity.
                  MODIFY TABLE t_tree_data FROM ls_tree_change.
                  CALL METHOD alv_tree->change_node
                    EXPORTING
                      i_node_key     = ls_tree_change-node_key
                      i_outtab_line  = ls_tree_change
                      it_item_layout = lt_item_layout.
                ENDIF.
              ENDLOOP.
            ENDIF.
            PERFORM tree_del_pbpopo_from_kalnr USING lt_kalnr.
          ENDIF.
        WHEN '4'.
          IF ( ls_tree_data-pb_price < 0 ).
            MESSAGE s004(ckmlmc).
          ELSE.
            REFRESH: lt_kalnr.
            CLEAR: ls_kalnr.
            ls_kalnr-kalnr = ls_tree_data-kalnr.
            APPEND ls_kalnr TO lt_kalnr.
*           start of                                     "note 1477309
*           check change authorization for valuation area
            PERFORM auth_check_for_del_pbpopo
              TABLES   lt_kalnr
              CHANGING l_rtc.
            IF l_rtc NE 0.
              EXIT.
            ENDIF.
*           end   of                                     "note 1477309
            IF NOT alv_tree IS INITIAL.
              READ TABLE t_tree_data INTO ls_tree_change
                                    WITH KEY level = ls_tree_data-level
                                             mlast = ls_tree_data-mlast
                                             bklas = ls_tree_data-bklas
                                             werks = ls_tree_data-werks
                                             kalnr = ls_tree_data-kalnr
                                             BINARY SEARCH.
              IF sy-subrc = 0.
                CLEAR: ls_tree_change-pb_quantity.
                MODIFY TABLE t_tree_data FROM ls_tree_change.
                CALL METHOD alv_tree->change_node
                  EXPORTING
                    i_node_key     = ls_tree_change-node_key
                    i_outtab_line  = ls_tree_change
                    it_item_layout = lt_item_layout.
              ENDIF.
            ENDIF.
            PERFORM tree_del_pbpopo_from_kalnr USING lt_kalnr.
          ENDIF.
      ENDCASE.
      IF NOT alv_tree IS INITIAL.
        CALL METHOD alv_tree->frontend_update.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " tree_delete_pb
*&---------------------------------------------------------------------*
*&      Form  grid_toolbar_change
*&---------------------------------------------------------------------*
FORM grid_toolbar_change.

** Toolbar holen
*  CALL METHOD alv_grid->get_toolbar_object
*       IMPORTING
*            er_toolbar = alv_grid_toolbar.
*
*  CALL METHOD alv_grid_toolbar->add_button
*       EXPORTING
*            fcode     = ''
*            icon      = ''
*            butn_type = 3
*            quickinfo = ''.
*  CALL METHOD alv_grid_toolbar->add_button
*       EXPORTING
*            fcode     = 'DETAIL'
*            icon      = '@16@'         "icon_select_detail
*            butn_type = 0
*            quickinfo = text-010.      "Detail auswählen
*  CALL METHOD alv_grid_toolbar->add_button
*       EXPORTING
*            fcode     = 'DET_NDI'
*            icon      = '@3R@'         "icon_detail
*            butn_type = 0
*            text      = text-014       ""Nicht verteilt"
*            quickinfo = text-015.      "Erklärung "Nicht verteilt"
*  CALL METHOD alv_tree_toolbar->add_button
*       EXPORTING
*            fcode     = 'LEGE'
*            icon      = '@3D@'         "icon_icon_list
*            butn_type = 0
**           text      = text-028.
*            quickinfo = text-011.      "Legende anzeigen


ENDFORM.                    " grid_toolbar_change
*&---------------------------------------------------------------------*
*&      Form  grid_explain_ndi
*&---------------------------------------------------------------------*
FORM grid_explain_ndi TABLES pt_index_rows STRUCTURE lvc_s_row.

  DATA: ls_selected_line LIKE lvc_s_row,
        ls_tree_data     TYPE s_vfm_tree,
        l_index          TYPE lvc_index.

  READ TABLE pt_index_rows INTO ls_selected_line INDEX 1.
  IF sy-subrc = 0.
    l_index = ls_selected_line-index.
    READ TABLE t_tree_data INTO ls_tree_data INDEX l_index.
    IF sy-subrc = 0.
      SUBMIT ml_analyse_not_dist WITH p_kalnr = ls_tree_data-kalnr
                                 WITH p_matnr = ls_tree_data-matnr
                                 WITH p_bukrs = p_bukrs
                                 WITH p_werks = ls_tree_data-werks
                                 WITH p_bdatj = p_bdatj
                                 WITH p_poper = p_poper
                                 WITH p_untper = s_runperiod-untper
                                 WITH p_curtp = mlkey-curtp
                                 AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    " grid_explain_ndi
*&---------------------------------------------------------------------*
*&      Form  grid_events_register
*&---------------------------------------------------------------------*
FORM grid_events_register.

  CREATE OBJECT event_receiver_grid.
  SET HANDLER event_receiver_grid->my_handle_double_click FOR alv_grid.
  SET HANDLER event_receiver_grid->my_handle_user_command FOR alv_grid.
  SET HANDLER event_receiver_grid->my_handle_toolbar FOR alv_grid.

  CALL METHOD alv_grid->set_toolbar_interactive.

ENDFORM.                    " grid_events_register
*&---------------------------------------------------------------------*
*&      Form  grid_double_click
*&---------------------------------------------------------------------*
FORM grid_double_click USING ps_row TYPE lvc_s_row
                             ps_column TYPE lvc_s_col.

  DATA: ls_tree_data TYPE s_vfm_tree,
        ls_exit      TYPE slis_exit_by_user,
        l_bwkey      TYPE bwkey.

  READ TABLE t_tree_data INTO ls_tree_data INDEX ps_row-index.
  IF sy-subrc = 0.
    IF tcurm-bwkrs_cus = '3'.            "Bewertungsebene BURKS
      l_bwkey = p_bukrs.
    ELSE.
      l_bwkey = ls_tree_data-werks.
    ENDIF.
    CALL FUNCTION 'CKM8_ML_DATA_DISPLAY'
      EXPORTING
        i_matnr  = ls_tree_data-matnr
        i_bwkey  = l_bwkey
        i_bwtar  = ls_tree_data-bwtar
        i_vbeln  = ls_tree_data-vbeln
        i_posnr  = ls_tree_data-posnr
        i_pspnr  = ls_tree_data-pspnr
        i_bdatj  = p_bdatj
        i_poper  = p_poper
        i_curtp  = ls_tree_data-curtp
        i_run_id = s_runperiod-run_id
      IMPORTING
        e_exit   = ls_exit.
*   Falls 'BEENDEN' gewählt, ganz raus
    IF ls_exit-exit EQ 'X'.
      PERFORM fcode_ende.
    ENDIF.
  ENDIF.

ENDFORM.                    " grid_double_click
*&---------------------------------------------------------------------*
*&      Form  tree_del_pbpopo_from_kalnr
*&---------------------------------------------------------------------*
FORM tree_del_pbpopo_from_kalnr USING pt_kalnr TYPE ckmv0_matobj_tbl.

  DATA: lt_new_ckmlpp LIKE ckmlpp OCCURS 0 WITH HEADER LINE,
        lt_old_ckmlpp LIKE ckmlpp OCCURS 0 WITH HEADER LINE,
        lt_new_ckmlcr LIKE ckmlcr OCCURS 0 WITH HEADER LINE,
        lt_old_ckmlcr LIKE ckmlcr OCCURS 0 WITH HEADER LINE,
        ls_kalnr      TYPE ckmv0_matobj_str.

  DATA: l_xvnb LIKE ckmlpp-xvnb,  "note 1438863
        l_xwip LIKE ckmlpp-xwip.  "note 1438863

  CLEAR: l_xvnb, l_xwip.  "note 1438863

* Following changes have been made with OSS note 112070:
* PBPOPO will be deleted in any case.
* Status is now read from the database tables in order to get the
* correct and current status. It will only be reset in case it was not
* '70' or '05' or '01' before.
  IF pt_kalnr IS INITIAL.

    MESSAGE s004(ckmlmc).
  ELSE.

    LOOP AT pt_kalnr INTO ls_kalnr.

      UPDATE ckmlpp SET pbpopo = 0
      WHERE kalnr = ls_kalnr-kalnr
      AND bdatj = p_bdatj
      AND poper = p_poper
      AND untper = s_runperiod-untper.

      COMMIT WORK.

      UPDATE ckmlpp SET status = y_mengen_und_werte_erfasst
                        xvnb = l_xvnb  "note 1438863
                        xwip = l_xwip  "note 1438863
      WHERE kalnr = ls_kalnr-kalnr
      AND bdatj = p_bdatj
      AND poper = p_poper
      AND untper = s_runperiod-untper
      AND status <> '70'
      AND status <> '05'
      AND status <> '01'.

      COMMIT WORK.

    ENDLOOP.

    MESSAGE s030(ckmlmv).

  ENDIF.




ENDFORM.                    " tree_del_pbpopo_from_kalnr

*&---------------------------------------------------------------------*
*&      Form  get_fi_accounts
*&---------------------------------------------------------------------*
FORM get_fi_accounts  USING    p_excl_umb TYPE c     "chg note 1377333
                      CHANGING pr_hkont TYPE ty_hkont.
  DATA: t_t030   LIKE t030 OCCURS 0 WITH HEADER LINE,
        ls_hkont LIKE LINE OF pr_hkont,
        ls_t030  LIKE LINE OF t_t030.

* Relevante Konten für Value Flow Monitor bestimmen
* (Preisdifferenzkonten)

  CONSTANTS:

    BEGIN OF ccs00_sign,
      inclusive(1) TYPE c VALUE 'I',
    END   OF ccs00_sign,

    BEGIN OF ccs00_option,
      equal(2) TYPE c VALUE 'EQ',
    END   OF ccs00_option.

  REFRESH: t_t030, pr_hkont.

  SELECT SINGLE * FROM t001 WHERE bukrs = p_bukrs.
  SELECT * FROM t030 INTO TABLE t_t030
    WHERE ktopl = t001-ktopl
      AND ( ktosl = 'AKO'
       OR   ktosl = 'AUM'
       OR   ( ktosl = 'KDM' AND komok <> 'ERA' )
       OR   ktosl = 'KDV'
       OR   ktosl = 'KDY'
       OR   ktosl = 'PRD'
       OR   ktosl = 'PRV'
       OR   ktosl = 'PRY'
       OR   ktosl = 'UMB'
       OR   ktosl = 'UMD' ).

* start of                                                note 1377333
* delete UMD and UMB accounts if excluded in selection
  IF p_excl_umb = 'X'.
    DELETE t_t030 WHERE ktosl = 'UMD'
                     OR ktosl = 'UMB'.
  ENDIF.
* end   of                                                note 1377333

  LOOP AT t_t030 INTO ls_t030.

    ls_hkont-sign   = ccs00_sign-inclusive.
    ls_hkont-option = ccs00_option-equal.
    ls_hkont-low    = ls_t030-konts.
    APPEND ls_hkont TO pr_hkont.
    ls_hkont-sign   = ccs00_sign-inclusive.
    ls_hkont-option = ccs00_option-equal.
    ls_hkont-low    = ls_t030-konth.
    APPEND ls_hkont TO pr_hkont.

    CLEAR: ls_t030, ls_hkont.
  ENDLOOP.

  SORT pr_hkont BY low.
  DELETE pr_hkont WHERE low IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM pr_hkont.


ENDFORM.                    " get_fi_accounts
*&---------------------------------------------------------------------*
*&      Form  get_fi_accounts
*&                                                                     *
*FORM get_fi_accounts USING p_bukrs TYPE bukrs
*                           p_runperiod TYPE ckml_run_period_data
*                     CHANGING cr_hkont TYPE tr_hkont.
*
*  DATA: ls_hkont LIKE LINE OF cr_hkont.
*
*  REFRESH: cr_hkont.
*  CLEAR: ls_hkont.
*  ls_hkont-sign = 'I'.
*  ls_hkont-option = 'BT'.
*  ls_hkont-low = '0005004300'.
*  ls_hkont-high = '0005004340'.
*  APPEND ls_hkont TO cr_hkont.
*  ls_hkont-low = '0005004400'.
*  ls_hkont-high = '0005004430'.
*  APPEND ls_hkont TO cr_hkont.
** No LKW accounts
**  if not p_runperiod is initial.
**    ls_hkont-low = '0005004550'.
**    ls_hkont-high = '0005004580'.
**    append ls_hkont to cr_hkont.
**  endif.
*  ls_hkont-low = '0005004600'.
*  ls_hkont-high = '0005004630'.
*  APPEND ls_hkont TO cr_hkont.
*  ls_hkont-low = '0005004650'.
*  ls_hkont-high = '0005004680'.
*  APPEND ls_hkont TO cr_hkont.
*  CLEAR: ls_hkont.
*  ls_hkont-sign = 'I'.
*  ls_hkont-option = 'EQ'.
*  ls_hkont-low = '0005004360'.
*  APPEND ls_hkont TO cr_hkont.
*
*ENDFORM.                    " get_fi_accounts
*&---------------------------------------------------------------------*
FORM get_bseg USING p_bukrs TYPE bukrs
                    p_bdatj TYPE bdatj
                    p_poper TYPE poper
                    p_runperiod TYPE ckml_run_period_data
                    pr_hkont TYPE ty_hkont
                 CHANGING ct_bkpf TYPE ty_bkpf
                          ct_bseg_out TYPE ty_bseg_out.

  DATA: l_monat      TYPE bkpf-monat,
        l_from_monat TYPE bkpf-monat,
        ls_bkpf      TYPE s_bkpf,
        ls_acctit    TYPE s_acctit,
        lh_posnr(10) TYPE n,
        lh_awref(10) TYPE c,
        lh_aworg(10) TYPE c,
        t_t030       LIKE t030 OCCURS 0 WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_bseg_out> TYPE s_bseg_out.

  IF p_runperiod IS INITIAL.
    l_monat = p_poper.
    SELECT bukrs belnr gjahr glvor awtyp budat monat tcode FROM bkpf
           INTO CORRESPONDING FIELDS OF TABLE ct_bkpf
           WHERE bukrs = p_bukrs
           AND   gjahr = p_bdatj
           AND   monat = l_monat
           AND   awtyp <> 'MLCU'.
    SORT ct_bkpf BY bukrs belnr gjahr.
    SELECT bukrs belnr gjahr matnr bwkey bwtar vbel2 posn2 projk
           dmbtr dmbe2 dmbe3 shkzg hkont ktosl belnr buzei vorgn bustw
           FROM bseg
           INTO CORRESPONDING FIELDS OF TABLE ct_bseg_out
           FOR ALL ENTRIES IN ct_bkpf
           WHERE bukrs = ct_bkpf-bukrs
           AND   belnr = ct_bkpf-belnr
           AND   gjahr = ct_bkpf-gjahr.
*           and   hkont in pr_hkont.
    DELETE ct_bseg_out WHERE NOT hkont IN pr_hkont.
  ELSE.
    l_monat = p_runperiod-poper.
    l_from_monat = p_runperiod-from_poper.
    SELECT bukrs belnr gjahr glvor awtyp budat monat tcode FROM bkpf
           INTO CORRESPONDING FIELDS OF TABLE ct_bkpf
           WHERE bukrs = p_bukrs
           AND   gjahr = p_bdatj
           AND   monat >= l_from_monat
           AND   monat <= l_monat
           AND   awtyp <> 'MLCU'.
    SORT ct_bkpf BY bukrs belnr gjahr.
    SELECT bukrs belnr gjahr matnr bwkey bwtar vbel2 posn2 projk
           dmbtr dmbe2 dmbe3 shkzg hkont ktosl belnr buzei vorgn bustw
           FROM bseg
           INTO CORRESPONDING FIELDS OF TABLE ct_bseg_out
           FOR ALL ENTRIES IN ct_bkpf
           WHERE bukrs = ct_bkpf-bukrs
           AND   belnr = ct_bkpf-belnr
           AND   gjahr = ct_bkpf-gjahr
           AND   hkont IN pr_hkont.
  ENDIF.

  SELECT awtyp awref aworg posnr bukrs belnr gjahr kzbws
         sobkz FROM acctit
         INTO CORRESPONDING FIELDS OF TABLE t_acctit
         FOR ALL ENTRIES IN ct_bkpf
         WHERE
         awtyp = ct_bkpf-awtyp AND
         awref = ct_bkpf-awkey(10) AND
         aworg = ct_bkpf-awkey+10(10) AND
         kzbws = 'M'.

  SORT t_acctit BY bukrs belnr gjahr posnr.

  LOOP AT ct_bseg_out ASSIGNING <fs_bseg_out>.
    READ TABLE t_acctit INTO ls_acctit
    WITH KEY bukrs      = <fs_bseg_out>-bukrs
             belnr      = <fs_bseg_out>-belnr
             gjahr      = <fs_bseg_out>-gjahr
             posnr      = <fs_bseg_out>-buzei
    BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR <fs_bseg_out>-vbel2.
      CLEAR <fs_bseg_out>-posn2.
      CLEAR <fs_bseg_out>-projk.
    ELSE.
      IF ls_acctit-sobkz = 'E' OR ls_acctit-sobkz = 'T'.
        CLEAR <fs_bseg_out>-projk.
      ELSEIF ls_acctit-sobkz = 'Q'.
        CLEAR <fs_bseg_out>-vbel2.
        CLEAR <fs_bseg_out>-posn2.
      ELSE.
        CLEAR <fs_bseg_out>-vbel2.
        CLEAR <fs_bseg_out>-posn2.
        CLEAR <fs_bseg_out>-projk.
      ENDIF.
    ENDIF.
    <fs_bseg_out>-vbeln = <fs_bseg_out>-vbel2.
    <fs_bseg_out>-posnr = <fs_bseg_out>-posn2.
    <fs_bseg_out>-pspnr = <fs_bseg_out>-projk.
  ENDLOOP.

ENDFORM.                    " get_bseg


*&---------------------------------------------------------------------*
*&      Form  get_mat_balance
*&---------------------------------------------------------------------*
FORM get_mat_balance TABLES it_t001k STRUCTURE t001k
                     USING  i_bwkey  TYPE bwkey
                            pt_bkpf TYPE ty_bkpf
                            pt_mats TYPE ty_mats
                            p_no_acctit TYPE boole_d
                    CHANGING ct_ckmvfm_bseg_out LIKE t_ckmvfm_bseg_out[]
                             ct_del_from_bseg_out TYPE ty_ckmvfm_bseg_out
ct_mat_bal TYPE ty_mat_bal.

  DATA: ls_bkpf            TYPE s_bkpf,
        ls_ckmvfm_bseg_out TYPE ckmvfm_bseg_out,
        ls_mat_bal         TYPE s_mat_bal,
        ls_mats            TYPE s_mats,
        ls_t001a           TYPE t001a,
        ls_t022t           TYPE t022t,
        l_current_matnr    TYPE bseg-matnr,
        l_current_bwkey    TYPE bseg-bwkey,
        l_current_bwtar    TYPE bseg-bwtar,
        l_current_vbeln    TYPE ckmlhd-vbeln,
        l_current_posnr    TYPE ckmlhd-posnr,
        l_current_pspnr    TYPE ckmlhd-pspnr,
        l_balance          TYPE summ9,
        l_balance2         TYPE summ9,
        l_balance3         TYPE summ9.

  SELECT SINGLE * FROM finsv_t001a INTO ls_t001a WHERE bukrs = p_bukrs.

  SORT pt_mats BY matnr bwkey bwtar vbeln posnr pspnr.

  LOOP AT ct_ckmvfm_bseg_out INTO ls_ckmvfm_bseg_out.
    CLEAR ls_mats.
    READ TABLE pt_mats INTO ls_mats
                       WITH KEY matnr = ls_ckmvfm_bseg_out-matnr
                                bwkey = ls_ckmvfm_bseg_out-bwkey
                                bwtar = ls_ckmvfm_bseg_out-bwtar
                                vbeln = ls_ckmvfm_bseg_out-vbeln
                                posnr = ls_ckmvfm_bseg_out-posnr
                                pspnr = ls_ckmvfm_bseg_out-pspnr
                                BINARY SEARCH.
    IF sy-subrc <> 0 AND p_no_acctit IS INITIAL.

      IF ( ls_ckmvfm_bseg_out-matnr IS INITIAL
           AND h_first_bwkey IS INITIAL AND h_first_mat IS INITIAL ).
        CONTINUE.
      ENDIF.

      IF NOT ls_ckmvfm_bseg_out-matnr IS INITIAL.
        IF ls_ckmvfm_bseg_out-bwkey = i_bwkey.
          DELETE ct_ckmvfm_bseg_out.
          CONTINUE.
        ELSE.
          READ TABLE it_t001k WITH KEY bwkey = ls_ckmvfm_bseg_out-bwkey
          BINARY SEARCH TRANSPORTING NO FIELDS.
** Note 1153419: there may exist entries with matnr <>''
** but bwkey = ''. Those have to be kept.
          IF sy-subrc <> 0 AND NOT ls_ckmvfm_bseg_out-bwkey IS INITIAL.
            DELETE ct_ckmvfm_bseg_out.
            CONTINUE.
          ENDIF.

        ENDIF.
      ENDIF.

      IF ls_ckmvfm_bseg_out-matnr IS INITIAL OR
      ls_ckmvfm_bseg_out-bwkey IS INITIAL.
        CLEAR: ls_ckmvfm_bseg_out-matnr, ls_ckmvfm_bseg_out-bwkey,
               ls_ckmvfm_bseg_out-bwtar, ls_ckmvfm_bseg_out-vbeln,
               ls_ckmvfm_bseg_out-posnr, ls_ckmvfm_bseg_out-pspnr.
      ENDIF.

    ELSE.
      IF sy-subrc <> 0 AND p_no_acctit = 'X' AND
         ls_ckmvfm_bseg_out-matnr <> '' AND
      ls_ckmvfm_bseg_out-bwkey <> '' AND ls_ckmvfm_bseg_out-bwtar <> ''.

*select mat von MBEW und erzeuge einen Eintrag in pt_mats OHNe BWTAR.
        "       here ls_mats is initial
        READ TABLE pt_mats TRANSPORTING NO FIELDS
          WITH KEY matnr = ls_ckmvfm_bseg_out-matnr
                   bwkey = ls_ckmvfm_bseg_out-bwkey
                   bwtar = ls_mats-bwtar  "initial
                   vbeln = ls_mats-vbeln  "initial
                   posnr = ls_mats-posnr  "initial
                   pspnr = ls_mats-pspnr. "initial
        IF sy-subrc NE 0.

          SELECT SINGLE matnr bwkey vprsv bklas mlast INTO CORRESPONDING
          FIELDS OF ls_mats
             FROM mbew
             WHERE matnr = ls_ckmvfm_bseg_out-matnr
             AND bwkey   = ls_ckmvfm_bseg_out-bwkey
             AND bwtar   = ''.

          SELECT SINGLE kaln1 INTO ls_mats-kalnr            "1744712
             FROM mbew
             WHERE matnr   = ls_mats-matnr
             AND   bwkey   = ls_mats-bwkey
             AND   bwtar   = ''.

          SELECT SINGLE mtart matkl meins spart INTO CORRESPONDING
          FIELDS OF ls_mats
          FROM mara
          WHERE matnr   = ls_mats-matnr.

          SELECT SINGLE prctr INTO CORRESPONDING FIELDS OF ls_mats
          FROM marc
          WHERE matnr   = ls_mats-matnr
          AND   werks   = ls_mats-bwkey.

          APPEND ls_mats TO pt_mats.
          SORT pt_mats BY matnr bwkey bwtar vbeln posnr pspnr.
        ENDIF.

        CLEAR ls_mats.
        CLEAR ls_ckmvfm_bseg_out-bwtar.

      ENDIF.
*   Für 2er-Materialien werden UMBs generell ignoriert

      IF p_finor = 'X'.

        IF ls_mats-mlast = '2' AND ls_ckmvfm_bseg_out-ktosl = 'UMB'.
          APPEND ls_ckmvfm_bseg_out TO ct_del_from_bseg_out.
          DELETE ct_ckmvfm_bseg_out.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.            "If sy-aubrc <> 0.
    READ TABLE pt_bkpf INTO ls_bkpf WITH KEY bukrs = ls_ckmvfm_bseg_out-bukrs
                                             belnr = ls_ckmvfm_bseg_out-belnr
                                             gjahr = ls_ckmvfm_bseg_out-gjahr
                                             BINARY SEARCH.
    IF sy-subrc <> 0.
      DELETE ct_ckmvfm_bseg_out.
      CONTINUE.
    ENDIF.
    MOVE-CORRESPONDING ls_bkpf TO ls_ckmvfm_bseg_out.
    ls_ckmvfm_bseg_out-waers = t001-waers.
    IF ls_ckmvfm_bseg_out-shkzg = 'H'.
      ls_ckmvfm_bseg_out-dmbtr = 0 - ls_ckmvfm_bseg_out-dmbtr.
      ls_ckmvfm_bseg_out-dmbe2 = 0 - ls_ckmvfm_bseg_out-dmbe2.
      ls_ckmvfm_bseg_out-dmbe3 = 0 - ls_ckmvfm_bseg_out-dmbe3.
    ENDIF.
*   Show other receipts/consumptions with own "transaction" VP
    IF ls_ckmvfm_bseg_out-vorgn = 'RMBL' AND ls_mats-mlast <> '2'.
      ls_ckmvfm_bseg_out-ktosl = 'VP'.
    ENDIF.

    MODIFY ct_ckmvfm_bseg_out FROM ls_ckmvfm_bseg_out.

  ENDLOOP.



  CLEAR: l_balance, l_balance2, l_balance3.
  SORT ct_ckmvfm_bseg_out BY matnr bwkey bwtar vbeln posnr pspnr.
  READ TABLE ct_ckmvfm_bseg_out INTO ls_ckmvfm_bseg_out INDEX 1.
  l_current_matnr = ls_ckmvfm_bseg_out-matnr.
  l_current_bwkey = ls_ckmvfm_bseg_out-bwkey.
  l_current_bwtar = ls_ckmvfm_bseg_out-bwtar.
  l_current_vbeln = ls_ckmvfm_bseg_out-vbeln.
  l_current_posnr = ls_ckmvfm_bseg_out-posnr.
  l_current_pspnr = ls_ckmvfm_bseg_out-pspnr.
  LOOP AT ct_ckmvfm_bseg_out INTO ls_ckmvfm_bseg_out.
*   new material
    IF ls_ckmvfm_bseg_out-matnr <> l_current_matnr
    OR ls_ckmvfm_bseg_out-bwkey <> l_current_bwkey
    OR ls_ckmvfm_bseg_out-bwtar <> l_current_bwtar
    OR ls_ckmvfm_bseg_out-vbeln <> l_current_vbeln
    OR ls_ckmvfm_bseg_out-posnr <> l_current_posnr
    OR ls_ckmvfm_bseg_out-pspnr <> l_current_pspnr.

      IF l_balance <> 0 OR l_balance2 <> 0 OR l_balance3 <> 0.
        READ TABLE pt_mats INTO ls_mats
                           WITH KEY matnr = l_current_matnr
                                    bwkey = l_current_bwkey
                                    bwtar = l_current_bwtar
                                    vbeln = l_current_vbeln
                                    posnr = l_current_posnr
                                    pspnr = l_current_pspnr
                                    BINARY SEARCH.
        IF sy-subrc = 0.
          ls_mat_bal-kalnr = ls_mats-kalnr.
          ls_mat_bal-balance = l_balance.
          ls_mat_bal-balance2 = l_balance2.
          ls_mat_bal-balance3 = l_balance3.
          ls_mat_bal-curtp2 = ls_t001a-curtp.
          ls_mat_bal-curtp3 = ls_t001a-curtp2.
          APPEND ls_mat_bal TO ct_mat_bal.
        ELSEIF l_current_matnr IS INITIAL AND
               NOT h_first_bwkey IS INITIAL AND
               NOT h_first_mat IS INITIAL.
*         should be posting with material = space
          CLEAR: ls_mat_bal-kalnr.
          ls_mat_bal-balance = l_balance.
          ls_mat_bal-balance2 = l_balance2.
          ls_mat_bal-balance3 = l_balance3.
          ls_mat_bal-curtp2 = ls_t001a-curtp.
          ls_mat_bal-curtp3 = ls_t001a-curtp2.
          APPEND ls_mat_bal TO ct_mat_bal.
        ENDIF.
      ENDIF.
      CLEAR: l_balance, l_balance2, l_balance3.
      l_current_matnr = ls_ckmvfm_bseg_out-matnr.
      l_current_bwkey = ls_ckmvfm_bseg_out-bwkey.
      l_current_bwtar = ls_ckmvfm_bseg_out-bwtar.
      l_current_vbeln = ls_ckmvfm_bseg_out-vbeln.
      l_current_posnr = ls_ckmvfm_bseg_out-posnr.
      l_current_pspnr = ls_ckmvfm_bseg_out-pspnr.
*     first line of a new material
      l_balance = ls_ckmvfm_bseg_out-dmbtr.
      l_balance2 = ls_ckmvfm_bseg_out-dmbe2.
      l_balance3 = ls_ckmvfm_bseg_out-dmbe3.
    ELSE.
*     same material again. build balance per Material
      l_balance = l_balance + ls_ckmvfm_bseg_out-dmbtr.
      l_balance2 = l_balance2 + ls_ckmvfm_bseg_out-dmbe2.
      l_balance3 = l_balance3 + ls_ckmvfm_bseg_out-dmbe3.

    ENDIF.
  ENDLOOP.
* balance of last material
  IF l_balance <> 0 OR l_balance2 <> 0 OR l_balance3 <> 0.
    READ TABLE pt_mats INTO ls_mats
                       WITH KEY matnr = l_current_matnr
                                bwkey = l_current_bwkey
                                bwtar = l_current_bwtar
                                vbeln = l_current_vbeln
                                posnr = l_current_posnr
                                pspnr = l_current_pspnr
                                BINARY SEARCH.
    IF sy-subrc = 0.
      ls_mat_bal-kalnr = ls_mats-kalnr.
      ls_mat_bal-balance = l_balance.
      ls_mat_bal-balance2 = l_balance2.
      ls_mat_bal-balance3 = l_balance3.
      ls_mat_bal-curtp2 = ls_t001a-curtp.
      ls_mat_bal-curtp3 = ls_t001a-curtp2.
      APPEND ls_mat_bal TO ct_mat_bal.
    ELSEIF l_current_matnr IS INITIAL AND NOT h_first_bwkey IS INITIAL
    AND NOT h_first_mat IS INITIAL.
*     should be postings with material = space
      CLEAR: ls_mat_bal-kalnr.
      ls_mat_bal-balance = l_balance.
      ls_mat_bal-balance2 = l_balance2.
      ls_mat_bal-balance3 = l_balance3.
      ls_mat_bal-curtp2 = ls_t001a-curtp.
      ls_mat_bal-curtp3 = ls_t001a-curtp2.
      APPEND ls_mat_bal TO ct_mat_bal.
    ENDIF.
  ENDIF.
  SORT ct_mat_bal BY kalnr.

ENDFORM.                    " get_mat_balance
*&---------------------------------------------------------------------*
*&      Form  get_act_period_data
*&---------------------------------------------------------------------*
FORM get_act_period_data USING pt_kalnr TYPE ckmv0_matobj_tbl
                               p_runperiod TYPE ckml_run_period_data
                         CHANGING ct_ckmlcr_act LIKE t_ckmlcr[].

  DATA: lt_ckmlpp_dummy   TYPE STANDARD TABLE OF ckmlpp
                        WITH KEY kalnr bdatj poper
                        WITH HEADER LINE,
        ls_runperiod_prev TYPE ckml_run_period_data.

  CALL FUNCTION 'CKMS_PERIOD_READ_WITH_ITAB'
    EXPORTING
*     I_REFRESH_BUFFER          =
*     I_READ_ONLY_BUFFER        = ' '
*     I_USE_BUFFER              = 'X'
*     I_BUILD_SMBEW             =
      i_bdatj_1                 = p_runperiod-from_gjahr
      i_poper_1                 = p_runperiod-from_poper
*     I_BDATJ_2                 =
*     I_POPER_2                 =
*     I_BDATJ_3                 =
*     I_POPER_3                 =
*     I_BETWEEN_1_AND_2         =
      i_untper                  = '000'
      i_call_by_reporting       = 'X'
      i_no_chk_periods_complete = 'X'
    TABLES
      t_kalnr                   = pt_kalnr
      t_ckmlpp                  = lt_ckmlpp_dummy
      t_ckmlcr                  = ct_ckmlcr_act
*     T_MISS_CKMLPP             =
*     T_MISS_CKMLCR             =
    EXCEPTIONS
      no_data_found             = 1
      input_data_inconsistent   = 2
      buffer_inconsistent       = 3
      OTHERS                    = 4.
  IF sy-subrc <> 0 AND
     NOT ( sy-subrc = 1 AND
           NOT ( lt_ckmlpp_dummy[] IS INITIAL AND
                 ct_ckmlcr_act[] IS INITIAL ) ).
*     Probleme
    REFRESH: ct_ckmlcr_act.
    EXIT.
  ENDIF.
  SORT: ct_ckmlcr_act.


ENDFORM.                    "get_act_period_data
*&---------------------------------------------------------------------*
*&      Form  get_ckmlrunscale
*&---------------------------------------------------------------------*
FORM get_mlavrscale USING pt_kalnr TYPE ckmv0_matobj_tbl
                            p_runperiod TYPE ckml_run_period_data
                      CHANGING ct_mlavrscale LIKE t_mlavrscale[].

  DATA: tabname(12).

  tabname = 'MLAVRSCALE'.

  TRY.

      SELECT * FROM (tabname) INTO TABLE ct_mlavrscale
               FOR ALL ENTRIES IN pt_kalnr
               WHERE run_id   = p_runperiod-run_id
               AND   kalnr_in = pt_kalnr-kalnr
               AND   xcumrec = 'X'.

    CATCH cx_sy_dynamic_osql_semantics.

      EXIT.
  ENDTRY.

  IF NOT ct_mlavrscale IS INITIAL.
    SORT: ct_mlavrscale BY run_id kalnr_in curtp_in categ.
  ENDIF.


ENDFORM.                    " get_ckmlrunscale

*&---------------------------------------------------------------------*
*&      Form  tree_explain_fia
*&---------------------------------------------------------------------*
FORM tree_explain_fia.

  DATA: lt_selected_nodes TYPE lvc_t_nkey,
        lt_bseg_alv       TYPE ty_bseg_out,
        ht_bseg_alv       TYPE ty_bseg_out,
        lt_fieldcat       TYPE slis_t_fieldcat_alv,
        lt_sort           TYPE slis_t_sortinfo_alv,
        ls_tree_data      TYPE s_vfm_tree,
        ls_bseg_alv       TYPE s_bseg_out,
        ls_layout         TYPE slis_layout_alv,
        ls_variant        TYPE disvariant,
        l_tabix           TYPE sytabix,
        l_node_key        TYPE lvc_nkey,
        l_fieldname       TYPE lvc_fname.

  REFRESH: lt_selected_nodes.
  CALL METHOD alv_tree->get_selected_nodes
    CHANGING
      ct_selected_nodes = lt_selected_nodes.
  IF lt_selected_nodes[] IS INITIAL.
    CALL METHOD alv_tree->get_selected_item
      IMPORTING
        e_selected_node = l_node_key
        e_fieldname     = l_fieldname.
  ELSE.
    READ TABLE lt_selected_nodes INTO l_node_key INDEX 1.
  ENDIF.
  IF NOT l_node_key IS INITIAL.
    PERFORM tree_tabix_holen USING    l_node_key
                             CHANGING l_tabix.
    READ TABLE t_tree_show INTO ls_tree_data INDEX l_tabix.
    IF sy-subrc = 0 AND ls_tree_data-level = '4'.

      SELECT * FROM ckmvfm_bseg_out INTO CORRESPONDING FIELDS OF TABLE
   ht_bseg_alv WHERE exid  = h_exid
               AND   bwkey = ls_tree_data-werks
               AND   matnr = ls_tree_data-matnr
               AND   bwtar = ls_tree_data-bwtar .
      IF sy-subrc = 0.
        REFRESH: lt_bseg_alv.


        LOOP AT ht_bseg_alv INTO ls_bseg_alv.

* If matnr is initial, ignore if bwkey is changing:
          IF ls_tree_data-matnr IS INITIAL.
            IF ls_bseg_alv-matnr <> ls_tree_data-matnr.
              EXIT.
            ENDIF.
          ELSE.
            IF ls_bseg_alv-bwkey <> ls_tree_data-werks OR
               ls_bseg_alv-matnr <> ls_tree_data-matnr OR
               ls_bseg_alv-bwtar <> ls_tree_data-bwtar.
              EXIT.
            ENDIF.
          ENDIF.
*          IF ls_bseg_alv-shkzg = 'H'.
*            ls_bseg_alv-dmbtr = 0 - ls_bseg_alv-dmbtr.
*            ls_bseg_alv-dmbe2 = 0 - ls_bseg_alv-dmbe2.
*            ls_bseg_alv-dmbe3 = 0 - ls_bseg_alv-dmbe3.
*          ENDIF.
          APPEND ls_bseg_alv TO lt_bseg_alv.
        ENDLOOP.
      ENDIF.
      IF lt_bseg_alv[] IS INITIAL.
        MESSAGE s090(c+) DISPLAY LIKE 'W'.
        EXIT.
      ENDIF.
      PERFORM fieldcat_fill_fia USING ls_tree_data
                                CHANGING ls_layout
                                         ls_variant
                                         lt_fieldcat
                                         lt_sort.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
*         I_INTERFACE_CHECK                 = ' '
*         I_BYPASSING_BUFFER                =
*         I_BUFFER_ACTIVE                   = ' '
*         I_CALLBACK_PROGRAM                = ' '
*         I_CALLBACK_PF_STATUS_SET          = ' '
*         I_CALLBACK_USER_COMMAND           = ' '
*         I_CALLBACK_TOP_OF_PAGE            = ' '
*         I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*         I_CALLBACK_HTML_END_OF_LIST       = ' '
*         I_STRUCTURE_NAME                  =
*         I_BACKGROUND_ID                   = ' '
*         I_GRID_TITLE                      =
*         I_GRID_SETTINGS                   =
          is_layout   = ls_layout
          it_fieldcat = lt_fieldcat
*         IT_EXCLUDING                      =
*         IT_SPECIAL_GROUPS                 =
          it_sort     = lt_sort
*         IT_FILTER   =
*         IS_SEL_HIDE =
*         I_DEFAULT   = 'X'
          i_save      = 'A'
          is_variant  = ls_variant
*         IT_EVENTS   =
*         IT_EVENT_EXIT                     =
*         IS_PRINT    =
*         IS_REPREP_ID                      =
*         I_SCREEN_START_COLUMN             = 0
*         I_SCREEN_START_LINE               = 0
*         I_SCREEN_END_COLUMN               = 0
*         I_SCREEN_END_LINE                 = 0
*         IT_ALV_GRAPHICS                   =
*         IT_ADD_FIELDCAT                   =
*         IT_HYPERLINK                      =
*       IMPORTING
*         E_EXIT_CAUSED_BY_CALLER           =
*         ES_EXIT_CAUSED_BY_USER            =
        TABLES
          t_outtab    = lt_bseg_alv
*       EXCEPTIONS
*         PROGRAM_ERROR                     = 1
*         OTHERS      = 2
        .
    ELSE.
      MESSAGE s663.
    ENDIF.
  ENDIF.

ENDFORM.                    " tree_explain_fia
*&---------------------------------------------------------------------*
*&      Form  fieldcat_fill_fia
*&---------------------------------------------------------------------*
FORM fieldcat_fill_fia USING ps_tree_data TYPE s_vfm_tree
                       CHANGING cs_layout TYPE slis_layout_alv
                                cs_variant TYPE disvariant
                                ct_fieldcat TYPE slis_t_fieldcat_alv
                                ct_sort TYPE slis_t_sortinfo_alv.


  DATA: ls_fieldcat TYPE slis_fieldcat_alv,
        ls_sort     TYPE slis_sortinfo_alv,
        l_index     TYPE i.

  REFRESH: ct_fieldcat.
  CLEAR: l_index.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MATNR'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'CKMLHD'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BWKEY'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'CKMLHD'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BWTAR'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'CKMLHD'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-key = 'X'.
  IF ps_tree_data-bwtar IS INITIAL.
    ls_fieldcat-no_out = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VBELN'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'CKMLHD'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'POSNR'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'CKMLHD'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PSPNR'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'CKMLHD'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DMBTR'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BSEG'.
  ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-do_sum = 'X'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DMBE2'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BSEG'.
* ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DMBE3'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BSEG'.
* ls_fieldcat-cfieldname = 'WAERS'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SHKZG'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BSEG'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'T001'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'HKONT'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BSEG'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KTOSL'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BSEG'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GLVOR'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BKPF'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TEXT'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'T022T'.
  ls_fieldcat-seltext_s = TEXT-028.
  ls_fieldcat-seltext_m = TEXT-028.
  ls_fieldcat-seltext_l = TEXT-028.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AWTYP'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BKPF'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TCODE'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BKPF'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUSTW'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BSEG'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BELNR'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BSEG'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUZEI'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BSEG'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUDAT'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BKPF'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MONAT'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BKPF'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GJAHR'.
  ls_fieldcat-tabname = 'LT_BSEG_ALV'.
  ls_fieldcat-ref_tabname = 'BKPF'.
  l_index = l_index + 1.
  ls_fieldcat-col_pos = l_index.
  APPEND ls_fieldcat TO ct_fieldcat.

  cs_layout-zebra               = 'X'.
  cs_layout-colwidth_optimize   = 'X'.
  cs_layout-numc_sum = 'X'.
*  cs_layout-coltab_fieldname = 'COLTAB'.

  cs_variant-report = sy-repid.
  cs_variant-handle = 'FIAC'.

* Sortierung
  REFRESH ct_sort.
  CLEAR: l_index.

  CLEAR ls_sort.
  l_index = l_index + 1.
  ls_sort-spos = l_index.
  ls_sort-fieldname = 'KTOSL'.
  ls_sort-up = 'X'.
  ls_sort-group = 'X'.
  ls_sort-subtot = 'X'.
  APPEND ls_sort TO ct_sort.
  CLEAR ls_sort.
  l_index = l_index + 1.
  ls_sort-spos = l_index.
  ls_sort-fieldname = 'BUDAT'.
  ls_sort-up = 'X'.
  ls_sort-group = 'X'.
  APPEND ls_sort TO ct_sort.

ENDFORM.                    " fieldcat_fill_fia
*&---------------------------------------------------------------------*
*&      Form  move_diff
*&---------------------------------------------------------------------*
FORM move_diff USING p_pos_type TYPE ckml_pos_type
                     p_diff TYPE ckml_estprd
               CHANGING cs_tree_data TYPE s_vfm_tree.

  CASE p_pos_type.
    WHEN 'PRA'.
      cs_tree_data-diff_pra = p_diff.
    WHEN 'MLS'.
      cs_tree_data-diff_mls = p_diff.
    WHEN 'NDI'.
      cs_tree_data-diff_ndi = p_diff.
    WHEN 'CUM'.
      cs_tree_data-diff_cum = p_diff.
    WHEN 'NIN'.
      cs_tree_data-diff_nin = p_diff.
    WHEN 'RSC'.
      cs_tree_data-diff_rsc = p_diff.
    WHEN 'NLE'.
      cs_tree_data-diff_nle = p_diff.
    WHEN 'WIP'.
      cs_tree_data-diff_wip = p_diff.
    WHEN 'VNO'.
      cs_tree_data-diff_vno = p_diff.
    WHEN 'OST'.
      cs_tree_data-diff_ost = p_diff.
    WHEN 'EIV'.
      cs_tree_data-diff_eiv = p_diff.
    WHEN 'FIA'.
      cs_tree_data-diff_fia = p_diff.
    WHEN 'FIS'.
      cs_tree_data-diff_fis = p_diff.
    WHEN 'UMB'.
      cs_tree_data-diff_umb = p_diff.
    WHEN 'ABC'.
      cs_tree_data-diff_abc = p_diff.
  ENDCASE.

ENDFORM.                    " move_diff
*&---------------------------------------------------------------------*
*&      Form  fcode_curtp_adiff
*&---------------------------------------------------------------------*
FORM fcode_curtp_adiff.

  DATA: ls_tree_data     TYPE s_vfm_tree,
        ls_tree_data_new TYPE s_vfm_tree.

  READ TABLE t_curtp WITH KEY curtp = mlkey-curtp.
  mlkey-waers = t_curtp-waers.
  REFRESH: t_tree_data_new.
  CLEAR: t_tree_data_new.
  PERFORM compressor USING    ckml_vfm-view
                     CHANGING t_tree_compressor[]
                              t_tree_data_new[].
  IF NOT alv_tree IS INITIAL.
    SORT t_tree_data_new BY level mlast bklas werks kalnr.
    LOOP AT t_tree_data INTO ls_tree_data.
      READ TABLE t_tree_data_new INTO ls_tree_data_new
                                 WITH KEY level = ls_tree_data-level
                                          mlast = ls_tree_data-mlast
                                          bklas = ls_tree_data-bklas
                                          werks = ls_tree_data-werks
                                          kalnr = ls_tree_data-kalnr
                                          BINARY SEARCH.
      IF sy-subrc = 0.
        ls_tree_data-curtp = ls_tree_data_new-curtp.
        ls_tree_data-waers = ls_tree_data_new-waers.
        ls_tree_data-diff_ndi = ls_tree_data_new-diff_ndi.
        ls_tree_data-diff_nin = ls_tree_data_new-diff_nin.
        ls_tree_data-diff_pra = ls_tree_data_new-diff_pra.
        ls_tree_data-diff_cum = ls_tree_data_new-diff_cum.
        ls_tree_data-diff_rsc = ls_tree_data_new-diff_rsc.
        ls_tree_data-diff_vno = ls_tree_data_new-diff_vno.
        ls_tree_data-diff_mls = ls_tree_data_new-diff_mls.
        ls_tree_data-diff_ost = ls_tree_data_new-diff_ost.
        ls_tree_data-diff_eiv = ls_tree_data_new-diff_eiv.
        ls_tree_data-diff_nle = ls_tree_data_new-diff_nle.
        ls_tree_data-diff_wip = ls_tree_data_new-diff_wip.
        ls_tree_data-diff_fia = ls_tree_data_new-diff_fia.
        ls_tree_data-diff_fis = ls_tree_data_new-diff_fis.
        ls_tree_data-diff_umb = ls_tree_data_new-diff_umb.
        ls_tree_data-diff_abc = ls_tree_data_new-diff_abc.
        ls_tree_data-value_cum = ls_tree_data_new-value_cum.
        ls_tree_data-pb_price = ls_tree_data_new-pb_price.
        ls_tree_data-price_cum = ls_tree_data_new-price_cum.
        ls_tree_data-stprs = ls_tree_data_new-stprs.
        ls_tree_data-salk3 = ls_tree_data_new-salk3.
      ELSE.
        ls_tree_data-curtp = mlkey-curtp.
        ls_tree_data-waers = mlkey-waers.
        CLEAR: ls_tree_data-diff_ndi, ls_tree_data-diff_nin,
               ls_tree_data-diff_cum, ls_tree_data-diff_rsc,
               ls_tree_data-diff_vno, ls_tree_data-diff_mls,
               ls_tree_data-diff_ost, ls_tree_data-diff_eiv,
               ls_tree_data-diff_nle, ls_tree_data-diff_wip,
               ls_tree_data-diff_fia, ls_tree_data-diff_fis,
               ls_tree_data-diff_umb, ls_tree_data-diff_abc,
               ls_tree_data-diff_pra, ls_tree_data-value_cum,
               ls_tree_data-pb_price, ls_tree_data-price_cum,
               ls_tree_data-stprs, ls_tree_data-salk3.
      ENDIF.
      MODIFY t_tree_data FROM ls_tree_data.
      CALL METHOD alv_tree->change_node
        EXPORTING
          i_node_key    = ls_tree_data-node_key
          i_outtab_line = ls_tree_data.
    ENDLOOP.
    CALL METHOD alv_tree->frontend_update.
  ELSEIF NOT alv_grid IS INITIAL.
    t_tree_data[] = t_tree_data_new[].
    CALL METHOD alv_grid->refresh_table_display.
  ENDIF.


ENDFORM.                    " fcode_curtp_adiff

*&                                                                     *
*&      Form  process_2_mats
*&                                                                     *
FORM process_2_mats USING pt_mats LIKE t_mats[]
                         pt_ckmlpp LIKE t_ckmlpp[]
                         pt_ckmlcr LIKE t_ckmlcr[]
                         pt_ckmlcr_act LIKE t_ckmlcr_act[]
                         pt_mlavrscale LIKE t_mlavrscale[]
                         pt_mlcd LIKE t_mlcd[]
                         pt_mat_bal TYPE ty_mat_bal
               p_exid TYPE num4
     CHANGING  pt_ckmvfm_out LIKE t_ckmvfm_out[]
               pt_ckmvfm_bseg_out LIKE t_ckmvfm_bseg_out[].

  DATA: pt_out           LIKE t_out[],
        ct_bseg_out      TYPE ty_bseg_out,
        lt_out           LIKE t_out[],
        lt_kalnr_t5      TYPE ckml_t_mgv_kalnr,
        lt_t005_extended TYPE ckml_t_t005_extended.
  DATA: ls_ckmvfm_bseg_out TYPE ckmvfm_bseg_out,
        ls_ckmvfm_out      TYPE ckmvfm_out,
        ls_out             TYPE s_out,
        ls_bseg_out        TYPE s_bseg_out,
        ls_out_cum         TYPE s_out,
        ls_out_pra         TYPE s_out,                      "abgerechnete Diffs.
        ls_out_mls         TYPE s_out,                      "ML-Saldo
        ls_out_vno         TYPE s_out,
        ls_out_ost         TYPE s_out,
        ls_out_fia         TYPE s_out,
        ls_out_fis         TYPE s_out,
        ls_out_umb         TYPE s_out,
        ls_out_dummy       TYPE s_out,
        ls_mats            TYPE s_mats,
        ls_ckmlpp          TYPE ckmlpp,
        ls_ckmlcr          TYPE ckmlcr,
        ls_mlcd            TYPE mlcd,
        ls_t001w           TYPE t001w,
        ls_t025t           TYPE t025t,
        ls_kalnr_t5        TYPE ckml_s_mgv_kalnr,
        ls_mat_bal         TYPE s_mat_bal,
        ls_bseg_out_ab     TYPE s_bseg_out,
        ls_bseg_out_prd    TYPE s_bseg_out,
        ls_bseg_out_pry    TYPE s_bseg_out,
        ls_bseg_out_umb    TYPE s_bseg_out,
        ls_bseg_out_vp     TYPE s_bseg_out,
        ls_bseg_out_vn     TYPE s_bseg_out,
        ls_bseg_out_cor    TYPE s_bseg_out,
        ls_ckmlcr_act      TYPE ckmlcr,
        ls_coltab          TYPE slis_specialcol_alv,
        ls_runperiod_prev  TYPE ckml_run_period_data,
        l_ab_menge         LIKE mlcd-lbkum,
        l_fia              TYPE boole_d,
        l_vno              TYPE boole_d,
        l_limit            TYPE ckml_diff_ndi,
        l_sumdif_abs       TYPE ck_sum_dif,
        l_checksum         TYPE ck_sum_dif,
        l_ab_correction    TYPE ckml_estprd,
        l_kalnr_space      TYPE ck_kalnr,
        l_counter          TYPE i,
        BEGIN OF l_clear_values,
          pbprd_o TYPE ckmlcr-pbprd_o,
          pbkdm_o TYPE ckmlcr-pbkdm_o,
          estprd  TYPE ckml_estprd,
          estkdm  TYPE ckml_estkdm,
          mstprd  TYPE ckml_mstprd,
          mstkdm  TYPE ckml_mstkdm,
          estdif  TYPE ck_singlelevel_dif,
          mstdif  TYPE ck_multilevel_dif,
          prdif   TYPE ck_sum_prdif,
          krdif   TYPE ck_sum_krdif,
          sumdif  TYPE ck_sum_dif,
        END OF l_clear_values.

  CLEAR: l_clear_values.

*In diesem Loop werden entsprechend der Selektion alle Buchungen mit
*Materialbezug verarbeitet, d.h. hier findet die komplette Verarbeitung,
*sowohl für 2er Materialien als auch für 3er Materialien, statt.
  LOOP AT pt_mats INTO ls_mats
    WHERE mlast = '2'.
    REFRESH: lt_out.
    READ TABLE pt_ckmlpp INTO ls_ckmlpp
                         WITH KEY kalnr = ls_mats-kalnr
                                  bdatj = p_bdatj
                                  poper = p_poper
                                  untper = s_runperiod-untper
                                  BINARY SEARCH.
*    IF sy-subrc <> 0.
*      PERFORM build_extra_fia_lines CHANGING ls_out_fia
*                                             ls_out_cum.
*      CONTINUE.
*    ENDIF.
    CLEAR: ls_out_cum, ls_out_vno, ls_out_ost, ls_out_fia,
           ls_out_fis, ls_out_umb, ls_out_pra, ls_out_mls.
    ls_out_cum-bukrs = t001-bukrs.
    ls_out_cum-butxt = t001-butxt.
    MOVE-CORRESPONDING ls_ckmlpp TO ls_out_cum.
    ls_out_cum-icon = icon_led_green.
*    ls_out_cum-icon_est = icon_led_inactive.
*    ls_out_cum-icon_mst = icon_led_inactive.
*    ls_out_cum-icon_clo = icon_led_inactive.

    READ TABLE pt_ckmlcr WITH KEY kalnr = ls_mats-kalnr
                              bdatj = p_bdatj
                              poper = p_poper
                              untper = s_runperiod-untper
                              BINARY SEARCH
                              TRANSPORTING NO FIELDS.
    LOOP AT pt_ckmlcr INTO ls_ckmlcr FROM sy-tabix.
      IF ls_ckmlcr-kalnr <> ls_ckmlpp-kalnr OR
         ls_ckmlcr-bdatj <> ls_ckmlpp-bdatj OR
         ls_ckmlcr-poper <> ls_ckmlpp-poper OR
         ls_ckmlcr-untper <> ls_ckmlpp-untper.
        EXIT.
      ENDIF.
*       Werte aus voriger Währung löschen!
      MOVE-CORRESPONDING l_clear_values TO ls_out_cum.
      MOVE-CORRESPONDING ls_ckmlcr TO ls_out_cum.
      MOVE-CORRESPONDING ls_out_cum TO ls_out_pra.
      MOVE-CORRESPONDING ls_out_cum TO ls_out_mls.
      MOVE-CORRESPONDING ls_out_cum TO ls_out_vno.
      MOVE-CORRESPONDING ls_out_cum TO ls_out_ost.
      MOVE-CORRESPONDING ls_out_cum TO ls_out_fia.
* Kumulierter Bestand, d.h. das sind alle fortgeschriebenen PRDIFFs.
      ls_out_cum-prdif  = ls_ckmlcr-zuprd_o + ls_ckmlcr-vpprd_o +
                          ls_ckmlcr-vnprd_o + ls_ckmlcr-abprd_o.
      ls_out_cum-krdif  = ls_ckmlcr-zukdm_o + ls_ckmlcr-vpkdm_o +
                          ls_ckmlcr-vnkdm_o + ls_ckmlcr-abkdm_o.
      ls_out_cum-sumdif = ls_out_cum-prdif + ls_out_cum-krdif.

      ls_out_cum-quantity_cum = ls_ckmlpp-abkumo + ls_ckmlpp-zukumo +
                                ls_ckmlpp-vpkumo + l_ab_menge.
******* Hallo Abgänge! *************************************************
      ls_out_vno-prdif = ls_ckmlcr-vnprd_o.
      ls_out_vno-krdif = ls_ckmlcr-vnkdm_o.
      ls_out_vno-sumdif = ls_out_vno-prdif + ls_out_vno-krdif.
******* nicht bestandsrelevante Kursdifferenzen *************************
      ls_out_ost-krdif = ls_ckmlcr-zukdm_ost + ls_ckmlcr-ekkdm_ost +
                         ls_ckmlcr-pbkdm_ost + ls_ckmlcr-vpkdm_ost +
                         ls_ckmlcr-vppbkdm_ost + ls_ckmlcr-vnkdm_ost.
      ls_out_ost-sumdif = ls_out_ost-krdif.
******* ML-Saldo, d.h. diese PRDIFFs sind noch abzurechnen *************
      ls_out_mls-prdif = ls_ckmlcr-zuprd_a.
      ls_out_mls-krdif = ls_ckmlcr-zukdm_a + ls_out_ost-sumdif.
** Force ML-Saldo equals cumulated differences.
      IF p_2s = 'X' AND ls_mats-vprsv = 'S'.
        ls_out_mls-prdif = ls_out_cum-prdif.
        ls_out_mls-krdif = ls_out_cum-krdif.
      ENDIF.
      ls_out_mls-sumdif = ls_out_mls-prdif + ls_out_mls-krdif.
******* Abgerechnete Differenzen **************
      ls_out_pra-prdif = ls_out_cum-prdif - ls_out_mls-prdif.
      ls_out_pra-krdif = ls_out_cum-krdif - ls_out_mls-krdif.
      ls_out_pra-sumdif = ls_out_pra-prdif + ls_out_pra-krdif.
******* Und der FI Saldo! **********************************************
      IF NOT p_fiacc IS INITIAL.
        MOVE-CORRESPONDING ls_out_fia TO ls_out_fis.
        MOVE-CORRESPONDING ls_out_fia TO ls_out_umb.
        READ TABLE pt_mat_bal INTO ls_mat_bal
                              WITH KEY kalnr = ls_mats-kalnr
                              BINARY SEARCH.
        IF sy-subrc = 0.
          IF ls_ckmlcr-curtp = '10'.
            ls_out_fia-prdif = ls_mat_bal-balance.
          ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp2.
            ls_out_fia-prdif = ls_mat_bal-balance2.
          ELSEIF ls_ckmlcr-curtp = ls_mat_bal-curtp3.
            ls_out_fia-prdif = ls_mat_bal-balance3.
          ENDIF.
        ELSE.
          CLEAR: ls_out_fia-prdif.
        ENDIF.

        ls_out_fia-sumdif = ls_out_fia-prdif.
***********************************************************************
        l_checksum = ls_out_mls-sumdif.

        IF ls_out_fia-sumdif <> ls_out_mls-sumdif.
          ls_out_cum-icon_fia = icon_led_red.
          ls_out_fis-prdif = ls_out_mls-sumdif - ls_out_fia-sumdif.
          ls_out_fis-sumdif = ls_out_fis-prdif.
        ELSE.
          ls_out_cum-icon_fia = icon_led_green.
        ENDIF.
        IF ls_out_cum-icon_fia <> icon_led_green.
          l_fia = 'X'.
        ENDIF.

      ENDIF.
******* So, die relevanten Zeilen werden erzeugt! **********************
      IF ( p_all = 'X' ) OR ( l_vno = 'X' OR l_fia = 'X'  ).

        MOVE-CORRESPONDING ls_mats TO ls_out_cum.
        MOVE-CORRESPONDING ls_mats TO ls_out_pra.
        MOVE-CORRESPONDING ls_mats TO ls_out_mls.
        MOVE-CORRESPONDING ls_mats TO ls_out_vno.
        MOVE-CORRESPONDING ls_mats TO ls_out_ost.
        MOVE-CORRESPONDING ls_mats TO ls_out_fia.
        MOVE-CORRESPONDING ls_mats TO ls_out_fis.
        MOVE-CORRESPONDING ls_mats TO ls_out_umb.
        CALL FUNCTION 'T025T_SINGLE_READ'
          EXPORTING
*           KZRFB       = ' '
            t025t_spras = sy-langu
            t025t_bklas = ls_mats-bklas
          IMPORTING
            wt025t      = ls_t025t
          EXCEPTIONS
            not_found   = 1
            OTHERS      = 2.

        IF sy-subrc = 0.
          ls_out_cum-bkbez = ls_t025t-bkbez.
          ls_out_pra-bkbez = ls_t025t-bkbez.
          ls_out_mls-bkbez = ls_t025t-bkbez.
          ls_out_vno-bkbez = ls_t025t-bkbez.
          ls_out_ost-bkbez = ls_t025t-bkbez.
          ls_out_fia-bkbez = ls_t025t-bkbez.
          ls_out_fis-bkbez = ls_t025t-bkbez.
          ls_out_umb-bkbez = ls_t025t-bkbez.
        ENDIF.

        IF tcurm-bwkrs_cus <> '3'.            "Bewertungsebene WERKS
          ls_out_cum-werks = ls_mats-bwkey.
          ls_out_pra-werks = ls_mats-bwkey.
          ls_out_mls-werks = ls_mats-bwkey.
          ls_out_vno-werks = ls_mats-bwkey.
          ls_out_ost-werks = ls_mats-bwkey.
          ls_out_fia-werks = ls_mats-bwkey.
          ls_out_fis-werks = ls_mats-bwkey.
          ls_out_umb-werks = ls_mats-bwkey.
          CALL FUNCTION 'T001W_SINGLE_READ'
            EXPORTING
*             KZRFB       = ' '
              t001w_werks = ls_out_cum-werks
            IMPORTING
              wt001w      = ls_t001w
            EXCEPTIONS
              not_found   = 1
              OTHERS      = 2.
          ls_out_cum-name1 = ls_t001w-name1.
          ls_out_pra-name1 = ls_t001w-name1.
          ls_out_mls-name1 = ls_t001w-name1.
          ls_out_vno-name1 = ls_t001w-name1.
          ls_out_ost-name1 = ls_t001w-name1.
          ls_out_fia-name1 = ls_t001w-name1.
          ls_out_fis-name1 = ls_t001w-name1.
          ls_out_umb-name1 = ls_t001w-name1.
        ENDIF.
********* Kumuliert ****************************************************
        ls_out_cum-pos_type = 'CUM'.
        READ TABLE t_dd07v
                   WITH KEY domvalue_l = ls_out_cum-pos_type.
        IF sy-subrc <> 0.
          CLEAR t_dd07v.
        ENDIF.
        ls_out_cum-pos_type_text = t_dd07v-ddtext.
*         Anfangsbestands-Menge (Rückbuchungen) aus MLCD
        CLEAR: l_ab_menge.
        READ TABLE pt_mlcd WITH KEY kalnr = ls_ckmlcr-kalnr
                  bdatj = ls_ckmlcr-bdatj
                  poper = ls_ckmlcr-poper
                  untper = ls_ckmlcr-untper
                  categ = 'AB'
                  curtp = ls_ckmlcr-curtp
            BINARY SEARCH
            TRANSPORTING NO FIELDS.

        LOOP AT pt_mlcd INTO ls_mlcd FROM sy-tabix.
          IF ls_mlcd-kalnr <> ls_ckmlcr-kalnr OR
             ls_mlcd-bdatj <> ls_ckmlcr-bdatj OR
             ls_mlcd-poper <> ls_ckmlcr-poper OR
             ls_mlcd-untper <> ls_ckmlcr-untper OR
             ls_mlcd-categ <> 'AB' OR
             ls_mlcd-curtp <> ls_ckmlcr-curtp.
            EXIT.
          ENDIF.
          l_ab_menge = l_ab_menge + ls_mlcd-lbkum.
        ENDLOOP.

        ls_out_cum-quantity_cum = ls_ckmlpp-abkumo + ls_ckmlpp-zukumo +
                                  ls_ckmlpp-vpkumo + l_ab_menge.
        ls_out_cum-value_cum = ls_out_cum-quantity_cum *
                                ls_out_cum-stprs / ls_out_cum-peinh.
        IF ls_out_cum-quantity_cum <> 0.
          CATCH SYSTEM-EXCEPTIONS conversion_errors = 1
                                 arithmetic_errors = 2.
            ls_out_cum-price_cum = ls_out_cum-stprs +
                         ( ( ls_out_cum-sumdif /
                                    ls_out_cum-quantity_cum ) *
                                    ls_out_cum-peinh ).
          ENDCATCH.
          IF sy-subrc <> 0.
            ls_out_cum-price_cum = '999999999.99'.
          ENDIF.
          CATCH SYSTEM-EXCEPTIONS conversion_errors = 1
                                      arithmetic_errors = 2.
            ls_out_cum-pb_price = ls_out_cum-stprs +
                     ( ( ls_out_cum-sumdif / ls_out_cum-quantity_cum )
                     *
                                  ls_out_cum-peinh ).
          ENDCATCH.
          IF sy-subrc <> 0.
            ls_out_cum-pb_price = '999999999.99'.
          ENDIF.
        ENDIF.
        IF ls_out_cum-pb_price < 0.
          ls_out_cum-icon = icon_led_red.
        ENDIF.
        APPEND ls_out_cum TO lt_out.

********* ML-Saldo *****************************************************
        IF NOT ls_out_mls-sumdif IS INITIAL.
          ls_out_mls-pos_type = 'MLS'.
          ls_out_mls-pos_type_text = TEXT-038.
          APPEND ls_out_mls TO lt_out.
        ENDIF.

********* Abgerechnete Differenzen *************************************
        IF NOT ls_out_pra-sumdif IS INITIAL.
          ls_out_pra-pos_type = 'PRA'.
          ls_out_pra-pos_type_text = TEXT-039.
          APPEND ls_out_pra TO lt_out.
        ENDIF.

********* Abgänge ******************************************************
        IF NOT ls_out_vno-sumdif IS INITIAL.
          ls_out_vno-pos_type = 'VNO'.
          READ TABLE t_dd07v
                     WITH KEY domvalue_l = ls_out_vno-pos_type.
          IF sy-subrc <> 0.
            CLEAR t_dd07v.
          ENDIF.
          ls_out_vno-pos_type_text = t_dd07v-ddtext.
          APPEND ls_out_vno TO lt_out.
        ENDIF.
********* FI Saldo *****************************************************
        IF NOT ls_out_fia-sumdif IS INITIAL.
          ls_out_fia-pos_type = 'FIA'.
          READ TABLE t_dd07v
                     WITH KEY domvalue_l = ls_out_fia-pos_type.
          IF sy-subrc <> 0.
            CLEAR t_dd07v.
          ENDIF.
          ls_out_fia-pos_type_text = t_dd07v-ddtext.
          APPEND ls_out_fia TO lt_out.
        ENDIF.
        IF NOT ls_out_fis-sumdif IS INITIAL.
          ls_out_fis-pos_type = 'FIS'.
          READ TABLE t_dd07v
                     WITH KEY domvalue_l = ls_out_fis-pos_type.
          IF sy-subrc <> 0.
            CLEAR t_dd07v.
          ENDIF.
          ls_out_fis-pos_type_text = t_dd07v-ddtext.
          APPEND ls_out_fis TO lt_out.
        ENDIF.
        IF NOT ls_out_umb-sumdif IS INITIAL.
          ls_out_umb-pos_type = 'UMB'.
          READ TABLE t_dd07v
                     WITH KEY domvalue_l = ls_out_umb-pos_type.
          IF sy-subrc <> 0.
            CLEAR t_dd07v.
          ENDIF.
          ls_out_umb-pos_type_text = t_dd07v-ddtext.
          APPEND ls_out_umb TO lt_out.
        ENDIF.
      ENDIF.
    ENDLOOP.        " loop über ckmlcr

*     Wenn alle Währungen eines Materials durch sind...
    IF sy-subrc = 0.
      IF NOT ls_bseg_out_ab-ktosl IS INITIAL.
        APPEND ls_bseg_out_ab TO ct_bseg_out.
      ENDIF.
      IF NOT ls_bseg_out_prd-ktosl IS INITIAL.
        APPEND ls_bseg_out_prd TO ct_bseg_out.
      ENDIF.
      IF NOT ls_bseg_out_umb-ktosl IS INITIAL.
        APPEND ls_bseg_out_umb TO ct_bseg_out.
      ENDIF.
      IF NOT ls_bseg_out_pry-ktosl IS INITIAL.
        APPEND ls_bseg_out_pry TO ct_bseg_out.
      ENDIF.
      IF NOT ls_bseg_out_vp-ktosl IS INITIAL.
        APPEND ls_bseg_out_vp TO ct_bseg_out.
      ENDIF.
      IF NOT ls_bseg_out_vn-ktosl IS INITIAL.
        APPEND ls_bseg_out_vn TO ct_bseg_out.
      ENDIF.
      ls_bseg_out_cor-matnr = ls_mats-matnr.
      ls_bseg_out_cor-bwkey = ls_mats-bwkey.
      ls_bseg_out_cor-bwtar = ls_mats-bwtar.
      ls_bseg_out_cor-waers = ls_bseg_out_prd-waers.
      ls_bseg_out_cor-glvor = 'RESC'.
*      ls_coltab-color-col = '6'.
*      ls_coltab-nokeycol = 'X'.
*      REFRESH: ls_bseg_out_cor-coltab.
*      APPEND ls_coltab TO ls_bseg_out_cor-coltab.
      ls_bseg_out_cor-dmbtr = 0 - ls_bseg_out_prd-dmbtr -
                                  ls_bseg_out_pry-dmbtr -
                                  ls_bseg_out_umb-dmbtr -
                                  ls_bseg_out_vp-dmbtr -
                                  ls_bseg_out_vn-dmbtr.
      ls_bseg_out_cor-dmbe2 = 0 - ls_bseg_out_prd-dmbe2 -
                                  ls_bseg_out_pry-dmbe2 -
                                  ls_bseg_out_umb-dmbe2 -
                                  ls_bseg_out_vp-dmbe2 -
                                  ls_bseg_out_vn-dmbe2.
      ls_bseg_out_cor-dmbe3 = 0 - ls_bseg_out_prd-dmbe3 -
                                  ls_bseg_out_pry-dmbe3 -
                                  ls_bseg_out_umb-dmbe3 -
                                  ls_bseg_out_vp-dmbe3 -
                                  ls_bseg_out_vn-dmbe3.
      IF NOT ( ls_bseg_out_cor-dmbtr IS INITIAL AND
               ls_bseg_out_cor-dmbe2 IS INITIAL AND
               ls_bseg_out_cor-dmbe3 IS INITIAL ).
        APPEND ls_bseg_out_cor TO ct_bseg_out.
      ENDIF.
    ENDIF.

*   Wenn es für ein Material keine Zeile mit Währungstyp '10' gibt,
*   dann erzeugen wir hier eine Dummy-Zeile, da der angezeigte ALV Tree
*   (zu Beginn immer Währungstyp = '10') sonst unvollständig aufgebaut
*   würde bzw. sogar ganz leer wäre (Fehlermeldung).
    IF NOT lt_out IS INITIAL.
      READ TABLE lt_out WITH KEY curtp = '10' TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        READ TABLE lt_out INTO ls_out_dummy INDEX 1.
        CLEAR: ls_out_dummy-lbkum, ls_out_dummy-quantity_cum,
               ls_out_dummy-pbpopo, ls_out_dummy-salk3,
               ls_out_dummy-value_cum, ls_out_dummy-stprs,
               ls_out_dummy-pvprs, ls_out_dummy-peinh,
               ls_out_dummy-pbprd_o, ls_out_dummy-pbkdm_o,
               ls_out_dummy-estprd, ls_out_dummy-estkdm,
               ls_out_dummy-mstprd, ls_out_dummy-mstkdm,
               ls_out_dummy-estdif, ls_out_dummy-mstdif,
               ls_out_dummy-prdif, ls_out_dummy-krdif,
               ls_out_dummy-sumdif, ls_out_dummy-pb_price,
               ls_out_dummy-price_cum, ls_out_dummy-icon_fia,
               ls_out_dummy-rescale.
        ls_out_dummy-curtp = '10'.
        ls_out_dummy-waers = t001-waers.
        APPEND ls_out_dummy TO lt_out.
      ENDIF.
    ENDIF.
    APPEND LINES OF lt_out TO pt_out.
  ENDLOOP.                                      " loop at pt_mats
* Neu Sortieren, da Zeilen angehängt wurden!
  SORT ct_bseg_out BY bwkey matnr bwtar.


  CLEAR: ls_bseg_out, ls_ckmvfm_bseg_out.
  LOOP AT pt_ckmvfm_bseg_out INTO ls_ckmvfm_bseg_out.
    READ TABLE ct_bseg_out INTO ls_bseg_out
    WITH KEY matnr = ls_ckmvfm_bseg_out-matnr
             bwkey = ls_ckmvfm_bseg_out-bwkey
             bwtar = ls_ckmvfm_bseg_out-bwtar
             belnr = ls_ckmvfm_bseg_out-belnr
             buzei = ls_ckmvfm_bseg_out-buzei
             gjahr = ls_ckmvfm_bseg_out-gjahr
             bukrs = ls_ckmvfm_bseg_out-bukrs.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_bseg_out TO ls_ckmvfm_bseg_out.
      MODIFY pt_ckmvfm_bseg_out FROM ls_ckmvfm_bseg_out.
    ENDIF.
    CLEAR: ls_bseg_out, ls_ckmvfm_bseg_out.
  ENDLOOP.

  CLEAR: ls_out, ls_ckmvfm_out.
  LOOP AT pt_out INTO ls_out.
    MOVE-CORRESPONDING ls_out TO ls_ckmvfm_out.
    ls_ckmvfm_out-exid = p_exid.
    APPEND ls_ckmvfm_out TO pt_ckmvfm_out.
    CLEAR: ls_out, ls_ckmvfm_out.
  ENDLOOP.

ENDFORM.                               " process_2_mats


*&---------------------------------------------------------------------*
*&      Form  get_bsis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS      text
*      -->P_BDATJ      text
*      -->P_POPER      text
*      -->P_RUNPERIOD  text
*      -->PR_HKONT     text
*      -->P_EXID       text
*      -->CT_BKPF      text
*----------------------------------------------------------------------*
FORM get_bsis USING p_bukrs TYPE bukrs
                    p_bdatj TYPE bdatj
                    p_poper TYPE poper
                    p_runperiod TYPE ckml_run_period_data
                    pr_hkont TYPE ty_hkont
                    p_exid TYPE num4
                 CHANGING ct_bkpf TYPE ty_bkpf.
  TYPES:
    BEGIN OF s_bsis,
      bukrs TYPE bsis-bukrs,
      belnr TYPE bsis-belnr,
      gjahr TYPE bsis-gjahr,
    END OF s_bsis,
    ty_bsis TYPE STANDARD TABLE OF s_bsis WITH KEY bukrs belnr gjahr.

  DATA: l_monat            TYPE bkpf-monat,
        l_from_monat       TYPE bkpf-monat,
        s_bsim             TYPE bsim,
        lt_bsis            TYPE ty_bsis,
        lt_ckmvfm_bseg_out TYPE TABLE OF ckmvfm_bseg_out,
        ls_bsis            TYPE s_bsis,
        l_hkont            LIKE LINE OF pr_hkont,
        h_cursor           TYPE cursor,
        h_count            TYPE i,
        lt_bkpf            TYPE ty_bkpf,
        ls_bkpf            TYPE s_bkpf.

  FIELD-SYMBOLS: <f_bseg_out> LIKE ckmvfm_bseg_out.

  IF p_runperiod IS INITIAL OR
    ( NOT p_runperiod IS INITIAL AND p_runperiod-untper = '000' ).

    l_monat = p_poper.
    SELECT bukrs belnr gjahr INTO TABLE lt_bsis
    FROM bsis WHERE bukrs = p_bukrs
              AND   hkont IN pr_hkont
              AND   gjahr = p_bdatj
              AND   monat = l_monat.

    CHECK NOT lt_bsis[] IS INITIAL.
    SORT lt_bsis BY bukrs belnr gjahr.  "buzei.
    DELETE ADJACENT DUPLICATES FROM lt_bsis.

    SELECT bukrs belnr gjahr glvor awtyp awkey budat monat tcode waers
    FROM bkpf INTO CORRESPONDING FIELDS OF TABLE ct_bkpf
           FOR ALL ENTRIES IN lt_bsis
           WHERE bukrs = lt_bsis-bukrs
           AND   gjahr = lt_bsis-gjahr
           AND   belnr = lt_bsis-belnr
           AND   awtyp <> 'MLCU'.

*Deleting table t_bsis to save memory
    CLEAR lt_bsis.
    REFRESH lt_bsis.
    FREE lt_bsis.

    SORT ct_bkpf BY bukrs belnr gjahr.

    CLEAR: h_count, ls_bkpf.
    REFRESH lt_bkpf.

    LOOP AT ct_bkpf INTO ls_bkpf.
      APPEND ls_bkpf TO lt_bkpf.
      h_count = h_count + 1.

      IF h_count < 1000.
        CLEAR ls_bkpf.
        CONTINUE.
      ELSE.

        SELECT mandt matnr bwkey bwtar belnr buzei gjahr
               bukrs  vbel2 posn2 vbeln projk dmbtr dmbe2
               dmbe3 shkzg hkont ktosl vorgn bustw
               INTO CORRESPONDING FIELDS OF TABLE lt_ckmvfm_bseg_out
               FROM bseg FOR ALL ENTRIES IN lt_bkpf
                   WHERE bukrs = lt_bkpf-bukrs
                   AND   belnr = lt_bkpf-belnr
                   AND   gjahr = lt_bkpf-gjahr.
        IF sy-subrc = 0.
          IF NOT lt_ckmvfm_bseg_out IS INITIAL.
            DELETE lt_ckmvfm_bseg_out WHERE NOT hkont IN pr_hkont.
** Note 1153419: delete all entries with matnr and bwkey <> ''
** and not in the selected ranges.
            DELETE lt_ckmvfm_bseg_out
            WHERE NOT matnr IN r_matnr AND NOT matnr IS INITIAL
            AND   NOT bwkey IN r_bwkey AND NOT bwkey IS INITIAL.

            DELETE lt_ckmvfm_bseg_out WHERE NOT bukrs = p_bukrs.
* Note 1947608: delete entry UMB/UMD in case 'Without Revaluation Accounts' is selected
            IF p_finor = 'X'.
              DELETE lt_ckmvfm_bseg_out WHERE  ktosl = 'UMD'
                                            OR ktosl = 'UMB'.
            ENDIF.
            LOOP AT lt_ckmvfm_bseg_out ASSIGNING <f_bseg_out>.
              <f_bseg_out>-exid = p_exid.
            ENDLOOP.

            SORT lt_ckmvfm_bseg_out
            BY matnr bwkey bwtar belnr buzei gjahr bukrs.
            INSERT ckmvfm_bseg_out FROM TABLE lt_ckmvfm_bseg_out.
            REFRESH lt_ckmvfm_bseg_out.
          ENDIF.
        ENDIF.

        REFRESH lt_bkpf.
        CLEAR: ls_bkpf, h_count.
        COMMIT WORK.
      ENDIF.
    ENDLOOP.

    IF NOT lt_bkpf[] IS INITIAL.
      SELECT mandt matnr bwkey bwtar belnr buzei gjahr
      bukrs  vbel2 posn2 vbeln projk dmbtr dmbe2 dmbe3
      shkzg hkont ktosl vorgn bustw
           INTO CORRESPONDING FIELDS OF TABLE lt_ckmvfm_bseg_out
           FROM bseg FOR ALL ENTRIES IN lt_bkpf
               WHERE bukrs = lt_bkpf-bukrs
               AND   belnr = lt_bkpf-belnr
               AND   gjahr = lt_bkpf-gjahr.
      IF sy-subrc = 0.
        IF NOT lt_ckmvfm_bseg_out IS INITIAL.
          DELETE lt_ckmvfm_bseg_out WHERE NOT hkont IN pr_hkont.
** Note 1153419: delete all entries with matnr and bwkey <> ''
** and not in the selected ranges.
          DELETE lt_ckmvfm_bseg_out
          WHERE NOT matnr IN r_matnr AND NOT matnr IS INITIAL
          AND   NOT bwkey IN r_bwkey AND NOT bwkey IS INITIAL.
          DELETE lt_ckmvfm_bseg_out WHERE NOT bukrs = p_bukrs.

* Note 1947608: delete entry UMB/UMD in case 'Without Revaluation Accounts' is selected
          IF p_finor = 'X'.
            DELETE lt_ckmvfm_bseg_out WHERE  ktosl = 'UMD'
                                          OR ktosl = 'UMB'.
          ENDIF.

          LOOP AT lt_ckmvfm_bseg_out ASSIGNING <f_bseg_out>.
            <f_bseg_out>-exid = p_exid.
          ENDLOOP.
          SORT lt_ckmvfm_bseg_out
          BY matnr bwkey bwtar belnr buzei gjahr bukrs.

          INSERT ckmvfm_bseg_out FROM TABLE lt_ckmvfm_bseg_out.
          REFRESH lt_ckmvfm_bseg_out.
        ENDIF.
      ENDIF.
      REFRESH lt_bkpf.
      CLEAR: ls_bkpf, h_count.
      COMMIT WORK.
    ENDIF.

  ELSE.
    l_monat = p_runperiod-poper.
    l_from_monat = p_runperiod-from_poper.
    SELECT bukrs belnr gjahr INTO TABLE lt_bsis
    FROM bsis WHERE bukrs = p_bukrs
              AND   hkont IN pr_hkont
              AND   gjahr = p_bdatj
              AND   monat >= l_from_monat
              AND   monat <= l_monat.

    CHECK NOT lt_bsis[] IS INITIAL.
    SORT lt_bsis BY bukrs belnr gjahr.  "buzei.
    DELETE ADJACENT DUPLICATES FROM lt_bsis.

    SELECT bukrs belnr gjahr glvor awtyp budat monat tcode waers
           INTO CORRESPONDING FIELDS OF TABLE ct_bkpf FROM bkpf
           FOR ALL ENTRIES IN lt_bsis
           WHERE bukrs = lt_bsis-bukrs
           AND   gjahr = lt_bsis-gjahr
           AND   belnr = lt_bsis-belnr
           AND   awtyp <> 'MLCU'.

*Deleting table t_bsis to save memory
    CLEAR lt_bsis.
    REFRESH lt_bsis.
    FREE lt_bsis.

    SORT ct_bkpf BY bukrs belnr gjahr.

    CLEAR: ls_bkpf, h_count.
    REFRESH lt_bkpf.

    LOOP AT ct_bkpf INTO ls_bkpf.
      APPEND ls_bkpf TO lt_bkpf.
      h_count = h_count + 1.

      IF h_count < 1000.
        CLEAR ls_bkpf.
        CONTINUE.

      ELSE.
        SELECT mandt matnr bwkey bwtar belnr buzei gjahr
               bukrs  vbel2 posn2 vbeln projk dmbtr dmbe2
               dmbe3 shkzg hkont ktosl vorgn bustw
               INTO CORRESPONDING FIELDS OF TABLE lt_ckmvfm_bseg_out
               FROM bseg FOR ALL ENTRIES IN lt_bkpf
                   WHERE bukrs = lt_bkpf-bukrs
                   AND   belnr = lt_bkpf-belnr
                   AND   gjahr = lt_bkpf-gjahr.
        IF sy-subrc = 0.
          IF NOT lt_ckmvfm_bseg_out IS INITIAL.
            DELETE lt_ckmvfm_bseg_out WHERE NOT hkont IN pr_hkont.
** Note 1153419: delete all entries with matnr and bwkey <> ''
** and not in the selected ranges.
            DELETE lt_ckmvfm_bseg_out
            WHERE NOT matnr IN r_matnr AND NOT matnr IS INITIAL
            AND   NOT bwkey IN r_bwkey AND NOT bwkey IS INITIAL.
            DELETE lt_ckmvfm_bseg_out WHERE NOT bukrs = p_bukrs.

* Note 1947608: delete entry UMB/UMD in case 'Without Revaluation Accounts' is selected
            IF p_finor = 'X'.
              DELETE lt_ckmvfm_bseg_out WHERE  ktosl = 'UMD'
                                            OR ktosl = 'UMB'.
            ENDIF.

            LOOP AT lt_ckmvfm_bseg_out ASSIGNING <f_bseg_out>.
              <f_bseg_out>-exid = p_exid.
            ENDLOOP.
            SORT lt_ckmvfm_bseg_out
            BY matnr bwkey bwtar belnr buzei gjahr bukrs.
            INSERT ckmvfm_bseg_out FROM TABLE lt_ckmvfm_bseg_out.
            REFRESH lt_ckmvfm_bseg_out.
          ENDIF.

        ENDIF.

        REFRESH lt_bkpf.
        CLEAR: ls_bkpf, h_count.
        COMMIT WORK.
      ENDIF.

    ENDLOOP.

    IF NOT lt_bkpf[] IS INITIAL.
      SELECT mandt matnr bwkey bwtar belnr buzei gjahr
             bukrs  vbel2 posn2 vbeln projk dmbtr dmbe2
             dmbe3 shkzg hkont ktosl vorgn bustw
           INTO CORRESPONDING FIELDS OF TABLE lt_ckmvfm_bseg_out
           FROM bseg FOR ALL ENTRIES IN lt_bkpf
               WHERE bukrs = lt_bkpf-bukrs
               AND   belnr = lt_bkpf-belnr
               AND   gjahr = lt_bkpf-gjahr.
      IF sy-subrc = 0.
        IF NOT lt_ckmvfm_bseg_out IS INITIAL.
          DELETE lt_ckmvfm_bseg_out WHERE NOT hkont IN pr_hkont.
** Note 1153419: delete all entries with matnr and bwkey <> ''
** and not in the selected ranges.
          DELETE lt_ckmvfm_bseg_out
          WHERE NOT matnr IN r_matnr AND NOT matnr IS INITIAL
          AND   NOT bwkey IN r_bwkey AND NOT bwkey IS INITIAL.
          DELETE lt_ckmvfm_bseg_out WHERE NOT bukrs = p_bukrs.

* Note 1947608: delete entry UMB/UMD in case 'Without Revaluation Accounts' is selected
          IF p_finor = 'X'.
            DELETE lt_ckmvfm_bseg_out WHERE  ktosl = 'UMD'
                                          OR ktosl = 'UMB'.
          ENDIF.

          LOOP AT lt_ckmvfm_bseg_out ASSIGNING <f_bseg_out>.
            <f_bseg_out>-exid = p_exid.
          ENDLOOP.
          SORT lt_ckmvfm_bseg_out
          BY matnr bwkey bwtar belnr buzei gjahr bukrs.
          INSERT ckmvfm_bseg_out FROM TABLE lt_ckmvfm_bseg_out.
          REFRESH lt_ckmvfm_bseg_out.
        ENDIF.
      ENDIF.
      REFRESH lt_bkpf.
      CLEAR: ls_bkpf, h_count.
      COMMIT WORK.
    ENDIF.
  ENDIF.          "p_runperiod is initial

ENDFORM.                    " get_bsis
*&---------------------------------------------------------------------*
*&      Form  complete_bseg_out_for_mat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CURRENT_MATNR  text
*      -->P_CURRENT_BWKEY  text
*      -->P_CURRENT_BWKEY  text
*----------------------------------------------------------------------*
FORM complete_bseg_out_for_mat  USING  p_matnr TYPE matnr
                                       p_bwkey TYPE bwkey
                                       p_bwtar TYPE bwtar_d
                                       pt_bkpf TYPE ty_bkpf
                                       pr_hkont TYPE ty_hkont
                                       p_sobkz TYPE c
  CHANGING pt_ckmvfm_bseg_out TYPE ty_ckmvfm_bseg_out
           ct_del_from_bseg_out TYPE ty_ckmvfm_bseg_out
           p_no_acctit TYPE boole_d.

  DATA: ls_ckmvfm_bseg_out TYPE ckmvfm_bseg_out,
        ls_bseg            TYPE bseg,
        l_monat            TYPE bkpf-monat,
        l_from_monat       TYPE bkpf-monat,
        ls_bkpf            TYPE s_bkpf,
        ls_acctit          TYPE s_acctit,
        lh_posnr(10)       TYPE n,
        lh_awref(10)       TYPE c,
        lh_aworg(10)       TYPE c,
        ls_t022t           TYPE t022t,
        lt_bkpf            TYPE ty_bkpf,
        lt_t022t           LIKE t022t OCCURS 0 WITH HEADER LINE,
        t_t030             LIKE t030 OCCURS 0 WITH HEADER LINE.


  REFRESH: pt_ckmvfm_bseg_out, lt_bkpf, lt_t022t.

  IF h_first_bwkey IS INITIAL AND h_first_mat IS INITIAL.
    SELECT * FROM ckmvfm_bseg_out INTO TABLE pt_ckmvfm_bseg_out
    WHERE exid  = h_exid
    AND   matnr = p_matnr
    AND   bwkey = p_bwkey
    AND   bwtar = p_bwtar.
  ENDIF.

  IF NOT h_first_bwkey IS INITIAL AND NOT h_first_mat IS INITIAL.
    SELECT * FROM ckmvfm_bseg_out INTO TABLE pt_ckmvfm_bseg_out
    WHERE exid  = h_exid
    AND ( ( matnr = p_matnr AND bwkey = p_bwkey AND bwtar = p_bwtar ) OR
          ( matnr = '' OR bwkey = '' ) ).
  ENDIF.


  SELECT * FROM t022t INTO TABLE lt_t022t
  WHERE langu    = sy-langu.

  IF p_sobkz = 'X'.
    SELECT awtyp awref aworg posnr bukrs belnr gjahr kzbws
           sobkz FROM acctit
           INTO CORRESPONDING FIELDS OF TABLE t_acctit
           FOR ALL ENTRIES IN pt_bkpf
           WHERE
           awtyp = pt_bkpf-awtyp AND
           awref = pt_bkpf-awkey(10) AND
           aworg = pt_bkpf-awkey+10(10) AND
           kzbws = 'M'.

    SORT t_acctit BY bukrs belnr gjahr posnr.
  ENDIF.

  LOOP AT pt_ckmvfm_bseg_out INTO ls_ckmvfm_bseg_out.
*   Exception: No UMB from MR22
    IF ls_ckmvfm_bseg_out-vorgn = 'RMBL'
    AND ls_ckmvfm_bseg_out-ktosl = 'UMB'.
      APPEND ls_ckmvfm_bseg_out TO ct_del_from_bseg_out.
      DELETE pt_ckmvfm_bseg_out.
      CONTINUE.
    ENDIF.

    CLEAR ls_bkpf.

    READ TABLE pt_bkpf INTO ls_bkpf WITH KEY
    bukrs = ls_ckmvfm_bseg_out-bukrs
    belnr = ls_ckmvfm_bseg_out-belnr
    gjahr = ls_ckmvfm_bseg_out-gjahr
    BINARY SEARCH.

    ls_ckmvfm_bseg_out-glvor = ls_bkpf-glvor.
    ls_ckmvfm_bseg_out-budat = ls_bkpf-budat.
    ls_ckmvfm_bseg_out-monat = ls_bkpf-monat.
    ls_ckmvfm_bseg_out-waers = ls_bkpf-waers.

*   AVR-Belege nur anzeigen im Falle alternativer Bewertung
    IF ls_bkpf-tcode = 'CKMLCPAVR'.
      IF s_runperiod IS INITIAL OR s_runperiod-appl <> 'CUM'.
        APPEND ls_ckmvfm_bseg_out TO ct_del_from_bseg_out.

        DELETE pt_ckmvfm_bseg_out.
        CONTINUE.
      ENDIF.
    ELSE.
      ls_ckmvfm_bseg_out-tcode = ls_bkpf-tcode.
    ENDIF.
* p_sobkz = 'X': Nur in dem Fall, daß es Sonderbestände gibt, findet
* diese Verarbeitung statt.
    IF p_sobkz = 'X'.
      READ TABLE t_acctit INTO ls_acctit
      WITH KEY bukrs      = ls_ckmvfm_bseg_out-bukrs
               belnr      = ls_ckmvfm_bseg_out-belnr
               gjahr      = ls_ckmvfm_bseg_out-gjahr
               posnr      = ls_ckmvfm_bseg_out-buzei
      BINARY SEARCH.
      IF sy-subrc <> 0.
        p_no_acctit = 'X'.
        CLEAR ls_ckmvfm_bseg_out-vbel2.
        CLEAR ls_ckmvfm_bseg_out-posn2.
        CLEAR ls_ckmvfm_bseg_out-projk.
      ELSE.
        ls_ckmvfm_bseg_out-awtyp = ls_acctit-awtyp.
        IF ls_acctit-sobkz = 'E' OR ls_acctit-sobkz = 'T'.
          CLEAR ls_ckmvfm_bseg_out-projk.
        ELSEIF ls_acctit-sobkz = 'Q'.
          CLEAR ls_ckmvfm_bseg_out-vbel2.
          CLEAR ls_ckmvfm_bseg_out-posn2.
        ELSE.
          CLEAR ls_ckmvfm_bseg_out-vbel2.
          CLEAR ls_ckmvfm_bseg_out-posn2.
          CLEAR ls_ckmvfm_bseg_out-projk.
        ENDIF.
      ENDIF.
      ls_ckmvfm_bseg_out-vbeln = ls_ckmvfm_bseg_out-vbel2.
      ls_ckmvfm_bseg_out-posnr = ls_ckmvfm_bseg_out-posn2.
      ls_ckmvfm_bseg_out-pspnr = ls_ckmvfm_bseg_out-projk.
    ELSE.
      CLEAR ls_ckmvfm_bseg_out-vbeln.
      CLEAR ls_ckmvfm_bseg_out-posnr.
      CLEAR ls_ckmvfm_bseg_out-pspnr.
    ENDIF.

*   Text zum betriebswirtschaftlichen Vorgang ermitteln
    READ TABLE lt_t022t INTO ls_t022t
    WITH KEY  langu    = sy-langu
              activity = ls_ckmvfm_bseg_out-vorgn.

    IF sy-subrc = 0.
      ls_ckmvfm_bseg_out-text = ls_t022t-txt.
    ENDIF.

    MODIFY pt_ckmvfm_bseg_out FROM ls_ckmvfm_bseg_out.
    CLEAR ls_ckmvfm_bseg_out.

  ENDLOOP.




ENDFORM.                    " complete_bseg_out_for_mat
*&---------------------------------------------------------------------*
*&      Form  get_exid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_H_EXID  text
*----------------------------------------------------------------------*
FORM write_exinfo USING h_bwkey TYPE bwkey
                        h_runperiod TYPE ckml_run_period_data
                  CHANGING p_exid TYPE num4.

  DATA:
    ls_ckmvfm_extract TYPE ckmvfm_extract,
    lt_ckmvfm_extract TYPE ckmvfm_extract OCCURS 0,
    extracts          TYPE i,
    sptab             TYPE rstable,
    r_code            TYPE sysubrc.

  REFRESH: lt_ckmvfm_extract.
  CLEAR: ls_ckmvfm_extract, p_exid, extracts.

  sptab-tabname = 'CKMVFM_EXTRACT'.
  sptab-varkey  = sy-mandt.

  r_code = 1.

  WHILE r_code <> 0.
    CALL FUNCTION 'ENQUEUE_E_TABLE'
      EXPORTING
        tabname        = sptab-tabname
        varkey         = sptab-varkey
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    r_code = sy-subrc.
  ENDWHILE.

  SELECT * INTO TABLE lt_ckmvfm_extract FROM ckmvfm_extract.

  SORT lt_ckmvfm_extract BY exid.

  DELETE lt_ckmvfm_extract WHERE exid IS INITIAL.

  DESCRIBE TABLE lt_ckmvfm_extract LINES extracts.

  LOOP AT lt_ckmvfm_extract INTO ls_ckmvfm_extract.
    IF ls_ckmvfm_extract-exid <> sy-tabix.
      p_exid = sy-tabix.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF p_exid <> '0000'.

    CLEAR ls_ckmvfm_extract.

    ls_ckmvfm_extract-exid    = p_exid.
    ls_ckmvfm_extract-exnam   = p_exnam.
    ls_ckmvfm_extract-exdate  = sy-datum.
    ls_ckmvfm_extract-extime  = sy-uzeit.
    ls_ckmvfm_extract-exuname = sy-uname.
    ls_ckmvfm_extract-run_id  = h_runperiod-run_id.
    ls_ckmvfm_extract-fiacc   = 'R'."p_fiacc.
    ls_ckmvfm_extract-bwkey   = h_bwkey.
    ls_ckmvfm_extract-poper   = p_poper.
    ls_ckmvfm_extract-bdatj   = p_bdatj.

    INSERT ckmvfm_extract FROM ls_ckmvfm_extract.
    CLEAR ls_ckmvfm_extract.
    IF sy-subrc = 0.
      MESSAGE s007(ckmlmc) WITH p_exnam.
    ENDIF.

    COMMIT WORK.
    CALL FUNCTION 'DEQUEUE_E_TABLE'
      EXPORTING
        tabname = sptab-tabname
        varkey  = sptab-varkey.

  ELSE.
    IF extracts < 9999.
      p_exid = extracts + 1.

      CLEAR ls_ckmvfm_extract.

      ls_ckmvfm_extract-exid    = p_exid.
      ls_ckmvfm_extract-exnam   = p_exnam.
      ls_ckmvfm_extract-exdate  = sy-datum.
      ls_ckmvfm_extract-extime  = sy-uzeit.
      ls_ckmvfm_extract-exuname = sy-uname.
      ls_ckmvfm_extract-run_id  = h_runperiod-run_id.
      ls_ckmvfm_extract-fiacc   = 'R'."p_fiacc.
      ls_ckmvfm_extract-bwkey   = h_bwkey.
      ls_ckmvfm_extract-poper   = p_poper.
      ls_ckmvfm_extract-bdatj   = p_bdatj.

      INSERT ckmvfm_extract FROM ls_ckmvfm_extract.
      CLEAR ls_ckmvfm_extract.
      IF sy-subrc = 0.
        MESSAGE s007(ckmlmc) WITH p_exnam.
      ENDIF.

      COMMIT WORK.

      CALL FUNCTION 'DEQUEUE_E_TABLE'
        EXPORTING
          tabname = sptab-tabname
          varkey  = sptab-varkey.

    ELSE.
*  error: max. Anzahl von Extrakten im System. Bitte löschen.
      MESSAGE e101(c+) WITH TEXT-054 TEXT-055.
    ENDIF.
  ENDIF.
ENDFORM.                    " write ex_info
*&---------------------------------------------------------------------*
*&      Form  delete_exnam
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_exnam.

  DATA:
    ls_ckmvfm_extract TYPE ckmvfm_extract,
    lt_ckmvfm_extract TYPE ckmvfm_extract OCCURS 0.

  SELECT * INTO TABLE lt_ckmvfm_extract FROM ckmvfm_extract
  WHERE exnam = p_exnam.

  LOOP AT lt_ckmvfm_extract[] INTO ls_ckmvfm_extract.
    DELETE FROM ckmvfm_out      WHERE exid = ls_ckmvfm_extract-exid.
    DELETE FROM ckmvfm_bseg_out WHERE exid = ls_ckmvfm_extract-exid.
    DELETE FROM ckmvfm_extract  WHERE exid = ls_ckmvfm_extract-exid.
    COMMIT WORK.
    CLEAR ls_ckmvfm_extract.
  ENDLOOP.

  REFRESH: lt_ckmvfm_extract.

ENDFORM.                    "delete_exnam
*&---------------------------------------------------------------------*
*&      Form  popup_dialog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0337   text
*      -->P_0338   text
*      -->P_0339   text
*      -->P_0340   text
*      <--P_LH_DOIT  text
*----------------------------------------------------------------------*
FORM popup_dialog USING    default TYPE c
                           text1   TYPE c
                           text2   TYPE c
                           title   TYPE c
                  CHANGING answer  TYPE c.

  IF sy-batch IS INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = default
        textline1     = text1
        textline2     = text2
        titel         = title
      IMPORTING
        answer        = answer.
  ELSE.
    answer = default.
    WRITE: / 'Popup:', title, text1, text2, 'Answer = ', answer.
  ENDIF.

ENDFORM.                    "POPUP_DIALOG
*&---------------------------------------------------------------------*
*&      Form  auth_check_for_del_pbpopo                   "note 1477309
*&---------------------------------------------------------------------*
*  Ermittelt zu den KALNRs, bei denen PBPOPO zurueckgesetzt werden
*  soll, die Bewertungskreise und prüft für diese die Berechtigung
*----------------------------------------------------------------------*
FORM auth_check_for_del_pbpopo TABLES it_kalnr TYPE ckmv0_matobj_tbl
                             CHANGING ch_rtc TYPE sy-subrc.
  DATA:
    l_bwkey TYPE ckmlhd-bwkey.
  CLEAR ch_rtc.
  CHECK NOT it_kalnr[] IS INITIAL.
* Select valuation areas
  SELECT DISTINCT bwkey INTO l_bwkey FROM ckmlhd
    FOR ALL ENTRIES IN it_kalnr
    WHERE kalnr = it_kalnr-kalnr.
*   check if user has change authorization
    AUTHORITY-CHECK OBJECT 'K_ML_VA'
             ID 'BWKEY' FIELD l_bwkey
             ID 'ACTVT' FIELD '02'.
    CHECK sy-subrc NE 0.
*   ...no -->  reset of PBPOPO not allowed
    ch_rtc = 8.
    MESSAGE i054 WITH l_bwkey.
    EXIT.
  ENDSELECT.
ENDFORM.                    " auth_check_for_del_pbpopo
