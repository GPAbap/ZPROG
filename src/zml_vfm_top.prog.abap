REPORT  ml_value_flow_monitor MESSAGE-ID c+ .
ENHANCEMENT-POINT ml_vfm_top_g4 SPOTS es_ml_value_flow_monitor STATIC.
ENHANCEMENT-POINT ml_vfm_top_g5 SPOTS es_ml_value_flow_monitor.
ENHANCEMENT-POINT ml_vfm_top_g6 SPOTS es_ml_value_flow_monitor STATIC.
ENHANCEMENT-POINT ml_vfm_top_g7 SPOTS es_ml_value_flow_monitor.
*&---------------------------------------------------------------------*
*&  Include           ML_VFM_TOP                                       *
*&---------------------------------------------------------------------*
*4.70 Extensions 2.00
*SLEE6K030430  030211 see note 1541284
*SLEE5K003653  111208 see note 1285905
*SLE4EK010284  060608 see note 1166046
*SLE4EK004036  190308 see note 1136145
*SLE36K010859  280807 see note 1087427
*SLE36K009916  210807 see note 1086064
*SLE36K003059  200807 see note 1059507
*SLP7EK020597  180806 see note 973674
*SLP7EK007998  290506 see note 912984
*SLP7EK007952  050106 see note 890578
*SLP7EK000606  050106 see note 878365
*SLXENK003926  270705 see note 857671
*SLPENK019618  220605 see note 849065
*SLPENK027888  160605 see note 803383
*SLPENK027640  160605 see note 800762
*SLPENK028589  160605 see note 783347
*SLXENK005582  270705 see note 770270
*SLXENK005589  270705 see note 768814
*SLXENK004152  220705 see note 755401
*HOMPLNK060557 080703 See note 621340
*4.70
*HOMALNK005514 171001 Retrofit XBA

INCLUDE rkasmawf.
INCLUDE schedman_events.

TYPE-POOLS: slis, ckmv0, vrm, ckru0, ccs00.

TABLES: mlkey, mara, marv, marc, mbew, tcurm, t001, t030, t001k, t001w, ckmlhd,
        ckmlpp, ckmlrunperiod, t025t, ckml_vfm, ckmlcur, sscrfields,
        ckml_vfm_tree, ckml_indx_run, mlrunlist, bseg, bsis,
        ckmvfm_bseg_out, ckmvfm_extract, ckmvfm_out, acctit.

RANGES: r_bwkey FOR ckmlhd-bwkey.      "Hilfsrange Bewertungskreis
RANGES: r_bwkey_no_auth FOR ckmlhd-bwkey.  "Hilfsrange Bewertungskreis
*----------------------------------------------------------------------*
*     Typen
*----------------------------------------------------------------------*
TYPES:
* Material/valuated sales order/project stock data
  BEGIN OF s_mats,
    kalnr TYPE ckmlhd-kalnr,
    mlast TYPE ckmlhd-mlast,
    vprsv TYPE ckmlcr-vprsv,
    matnr TYPE ckmlhd-matnr,
    bwkey TYPE ckmlhd-bwkey,
    bwtar TYPE ckmlhd-bwtar,
    sobkz TYPE ckmlhd-sobkz,
    vbeln TYPE ckmlhd-vbeln,
    posnr TYPE ckmlhd-posnr,
    pspnr TYPE ckmlhd-pspnr,
    bklas TYPE mbew-bklas,
    mtart TYPE mara-mtart,
    matkl TYPE mara-matkl,
    spart TYPE mara-spart,
    prctr TYPE marc-prctr,
    meins TYPE mara-meins,
  END OF s_mats,
  ty_mats TYPE STANDARD TABLE OF s_mats WITH KEY kalnr,
* Output
  BEGIN OF s_out,
    kalnr             TYPE ckmlhd-kalnr,
    mlast             TYPE ckmlhd-mlast,
    vprsv             TYPE ckmlcr-vprsv,
    bdatj             TYPE ckmlpp-bdatj,
    poper             TYPE ckmlpp-poper,
    untper            TYPE ckmlpp-untper,
    curtp             TYPE ckmlcr-curtp,
    matnr             TYPE ckmlhd-matnr,
    bwkey             TYPE ckmlhd-bwkey,
    bukrs             TYPE t001-bukrs,
    butxt             TYPE t001-butxt,
    bklas             TYPE mbew-bklas,
    bkbez             TYPE t025t-bkbez,
    werks             TYPE t001w-werks,
    name1             TYPE t001w-name1,
    bwtar             TYPE ckmlhd-bwtar,
    vbeln             TYPE ckmlhd-vbeln,
    posnr             TYPE ckmlhd-posnr,
    pspnr             TYPE ckmlhd-pspnr,
    mtart             TYPE mara-mtart,
    matkl             TYPE mara-matkl,
    spart             TYPE mara-spart,
    prctr             TYPE marc-prctr,
    meins             TYPE ckmlpp-meins,
    status            TYPE ckmlpp-status,
    lbkum             TYPE ckmlpp-lbkum,
    quantity_cum      TYPE ckml_quantity_cum,
    pbpopo            TYPE ckmlpp-pbpopo,
    salk3             TYPE ckmlcr-salk3,
    value_cum         TYPE ckml_value_cum,
    stprs             TYPE ckmlcr-stprs,
    pvprs             TYPE ckmlcr-pvprs,
    peinh             TYPE ckmlcr-peinh,
    waers             TYPE ckmlcr-waers,
    pbprd_o           TYPE ckmlcr-pbprd_o,
    pbkdm_o           TYPE ckmlcr-pbkdm_o,
    estprd            TYPE ckml_estprd,
    estkdm            TYPE ckml_estkdm,
    mstprd            TYPE ckml_mstprd,
    mstkdm            TYPE ckml_mstkdm,
    estdif            TYPE ck_singlelevel_dif,
    mstdif            TYPE ck_multilevel_dif,
    prdif             TYPE ck_sum_prdif,
    krdif             TYPE ck_sum_krdif,
    sumdif            TYPE ck_sum_dif,
    pb_price          TYPE ckml_pb_price,
    price_cum         TYPE ckml_price_cum,
    icon              TYPE ckml_status_icon,
    icon_settle       TYPE ckml_status_icon,
    icon_clo          TYPE ckml_status_icon,
    icon_fia          TYPE ckml_status_icon,
    rescale           TYPE ml_flag_rescale,
    pos_type          TYPE ckml_pos_type,
    pos_type_text(40),
  END OF s_out,
  ty_out TYPE STANDARD TABLE OF s_out WITH KEY kalnr,
  BEGIN OF s_sum,
    matnr    TYPE ckmlhd-matnr,
    werks    TYPE t001w-werks,
    bwtar    TYPE ckmlhd-bwtar,
    curtp    TYPE ckmlcr-curtp,
    diff_fis TYPE ck_sum_dif,
  END OF s_sum,
  ty_sum TYPE STANDARD TABLE OF s_sum WITH KEY matnr werks bwtar curtp,
  BEGIN OF s_hkont,
    hkont TYPE hkont,
    ktosl TYPE ktosl,
    shkzg TYPE shkzg,
  END OF s_hkont,
  ty_hkont TYPE RANGE OF hkont,
  BEGIN OF s_bkpf,
    bukrs TYPE bkpf-bukrs,
    belnr TYPE bkpf-belnr,
    gjahr TYPE bkpf-gjahr,
    glvor TYPE bkpf-glvor,
    awtyp TYPE bkpf-awtyp,
    awkey TYPE bkpf-awkey,
    budat TYPE bkpf-budat,
    monat TYPE bkpf-monat,
    tcode TYPE bkpf-tcode,
    waers TYPE bkpf-waers,
  END OF s_bkpf,
  ty_bkpf TYPE STANDARD TABLE OF s_bkpf WITH KEY bukrs belnr gjahr,
  BEGIN OF s_acctit,
    awtyp TYPE awtyp,
    awref TYPE awref,
    aworg TYPE aworg,
    posnr TYPE posnr_acc,
    bukrs TYPE bukrs,
    belnr TYPE belnr_d,
    gjahr TYPE gjahr,
    kzbws TYPE kzbws,
    sobkz TYPE sobkz,
  END OF s_acctit,
  ty_acctit TYPE STANDARD TABLE OF s_acctit,
  BEGIN OF s_bseg_out,
    matnr    TYPE bseg-matnr,
    bwkey    TYPE bseg-bwkey,
    bwtar    TYPE bseg-bwtar,
    vbel2    TYPE bseg-vbel2,
    posn2    TYPE bseg-posn2,
    projk    TYPE bseg-projk,
    vbeln    TYPE ckmlhd-vbeln,
    posnr    TYPE ckmlhd-posnr,
    pspnr    TYPE ckmlhd-pspnr,
    dmbtr    TYPE bseg-dmbtr,
    dmbe2    TYPE bseg-dmbe2,
    dmbe3    TYPE bseg-dmbe3,
    shkzg    TYPE bseg-shkzg,
    waers    TYPE t001-waers,
    hkont    TYPE bseg-hkont,
    ktosl    TYPE bseg-ktosl,
    glvor    TYPE bkpf-glvor,
    text(30) TYPE c,
    vorgn    TYPE bseg-vorgn,
    awtyp    TYPE bkpf-awtyp,
    tcode    TYPE bkpf-tcode,
    bustw    TYPE bseg-bustw,
    belnr    TYPE bseg-belnr,
    buzei    TYPE bseg-buzei,
    budat    TYPE bkpf-budat,
    monat    TYPE bkpf-monat,
    gjahr    TYPE bkpf-gjahr,
    bukrs    TYPE bseg-bukrs,
  END OF s_bseg_out,
  ty_bseg_out TYPE STANDARD TABLE OF s_bseg_out
              WITH KEY matnr bwkey bwtar,
  BEGIN OF s_mat_bal,
    kalnr    TYPE ckmlhd-kalnr,
    balance  TYPE summ9,
    balance2 TYPE summ9,
    balance3 TYPE summ9,
    curtp2   TYPE t001a-curtp,
    curtp3   TYPE t001a-curtp2,
  END OF s_mat_bal,
  ty_mat_bal TYPE STANDARD TABLE OF s_mat_bal WITH KEY kalnr,
  BEGIN OF s_vfm_tree,
    level        TYPE int1,
    mlast        TYPE ck_ml_abst,
    vprsv        TYPE vprsv,
    bklas        TYPE bklas,
    werks        TYPE werks_d,
    kalnr        TYPE ckmlhd-kalnr,
    node_key     TYPE lvc_nkey,
    htext        TYPE lvc_value,
    icon         TYPE ckml_vfm_icon,
    icon_settle  TYPE ckml_icon_mst,
    icon_clo     TYPE ml_icon_clo,
    icon_fia     TYPE ml_icon_fia,
    status       TYPE ck_mlstat,
    matnr        TYPE matnr,
    bwtar        TYPE bwtar_d,
    vbeln        TYPE vbeln,
    posnr        TYPE posnr,
    pspnr        TYPE ps_psp_pnr,
    mtart        TYPE mtart,
    matkl        TYPE matkl,
    spart        TYPE spart,
    prctr        TYPE prctr,
    curtp        TYPE curtp,
    waers        TYPE waers,
    meins        TYPE meins,
    diff_ndi     TYPE ckml_diff_ndi,
    diff_nin     TYPE ckml_diff_nin,
    diff_cum     TYPE ckml_diff_cum,
    diff_pra     TYPE ckml_diff_cum,
    diff_rsc     TYPE ckml_diff_rsc,
    diff_eiv     TYPE ckml_diff_eiv,
    diff_nle     TYPE ckml_diff_nle,
    diff_wip     TYPE ckml_diff_wip,
    diff_vno     TYPE ckml_diff_vno,
    diff_ost     TYPE ckml_diff_ost,
    diff_mls     TYPE ml_diff_fia,
    diff_fia     TYPE ml_diff_fia,
    diff_fis     TYPE ml_diff_fis,
    diff_umb     TYPE ml_diff_umb,
    diff_abc     TYPE ml_diff_abc,
    value_cum    TYPE ckml_value_cum,
    pb_price     TYPE ckml_pb_price,
    price_cum    TYPE ckml_price_cum,
    stprs        TYPE stprs,
    lbkum        TYPE ck_lbkum,
    pb_quantity  TYPE ckml_pb_quantity,
    quantity_cum TYPE ckml_quantity_cum,
    salk3        TYPE ck_salk3_1,
    rescale      TYPE ml_flag_rescale,
  END OF s_vfm_tree,
  ty_t_ckml_vfm_tree TYPE STANDARD TABLE OF s_vfm_tree
                        WITH KEY level mlast bklas werks kalnr curtp,

  BEGIN OF is_mlavrscale,
    mandt       TYPE mandt,
    run_id      TYPE ckml_run_id,
    kalnr_out   TYPE ck_kalnr1,
    kalnr_in    TYPE ck_kalnr1,
    kalnr_ba    TYPE ck_kalnr_bvalt,
    kalnr_va    TYPE ck_kalnr_bvalt,
    curtp_out   TYPE curtp,
    curtp_in    TYPE curtp,
    gjahr_out   TYPE ckml_run_gjahr,
    poper_out   TYPE ckml_run_poper,
    categ       TYPE ckml_categ,
    ptyp        TYPE ck_ptyp_bvalt,
    xcumrec(1)  TYPE c,
    btyp_out    TYPE ckml_btyp,
    gjahr_in    TYPE ckml_run_gjahr,
    poper_in    TYPE ckml_run_poper,
    diff_out    TYPE ckml_rescale_diff,
    waers_out   TYPE waers,
    diff_in     TYPE ckml_rescale_diff,
    waers_in    TYPE waers,
    ratio(3)    TYPE p,
    scaletyp(1) TYPE c,
    otyp_in     TYPE ckml_otyp,
    xcum(1)     TYPE c,
    xcls(1)     TYPE c,
  END OF is_mlavrscale,

  ty_t_mlavrscale    TYPE STANDARD TABLE OF is_mlavrscale
     WITH KEY mandt run_id kalnr_out kalnr_in kalnr_ba kalnr_va curtp_out
     curtp_in gjahr_out poper_out categ ptyp xcumrec,

  ty_ckmvfm_out      TYPE ckmvfm_out OCCURS 0,
  ty_ckmvfm_bseg_out TYPE ckmvfm_bseg_out OCCURS 0.

*----------------------------------------------------------------------*
*     Tabellen
*----------------------------------------------------------------------*
DATA: t_t001k_auth        LIKE t001k OCCURS 0 WITH HEADER LINE,
      t_t001k             LIKE t001k OCCURS 0 WITH HEADER LINE,
      t_t001w             LIKE t001w OCCURS 0 WITH HEADER LINE,
      t_ckmvfm_out        TYPE ty_ckmvfm_out,
      t_ckmvfm_bseg_out   TYPE ty_ckmvfm_bseg_out WITH HEADER LINE,
      t_del_from_bseg_out TYPE ty_ckmvfm_bseg_out WITH HEADER LINE,
      t_out               TYPE ty_out,
      t_tree_data         TYPE ty_t_ckml_vfm_tree,
      t_tree_data_new     TYPE ty_t_ckml_vfm_tree,
      t_tree_show         TYPE ty_t_ckml_vfm_tree,
      t_tree_compressor   TYPE SORTED TABLE OF s_vfm_tree
              WITH UNIQUE KEY level mlast bklas werks kalnr curtp,
      t_fieldcat          TYPE lvc_t_fcat,
      t_sort              TYPE lvc_t_sort,
      t_mats              TYPE ty_mats,
      t_mats_all          TYPE ty_mats,
      tr_hkont            TYPE ty_hkont,
      t_bkpf              TYPE ty_bkpf,
      t_bseg_out          TYPE ty_bseg_out,
      t_acctit            TYPE ty_acctit,
      t_mat_bal           TYPE ty_mat_bal,
      t_kalnr             TYPE ckmv0_matobj_tbl,
      t_mlavrscale        TYPE ty_t_mlavrscale WITH HEADER LINE,
      t_mlrunlist         TYPE TABLE OF mlrunlist,
      t_ckmlpp            TYPE STANDARD TABLE OF ckmlpp
                          WITH KEY kalnr bdatj poper
                          WITH HEADER LINE,
      t_ckmlcr            TYPE STANDARD TABLE OF ckmlcr
                          WITH KEY kalnr bdatj poper curtp
                          WITH HEADER LINE,
      t_ckmlcr_act        TYPE STANDARD TABLE OF ckmlcr
                          WITH KEY kalnr bdatj poper curtp
                          WITH HEADER LINE,
      t_mlcd              TYPE STANDARD TABLE OF mlcd
                            WITH KEY kalnr bdatj poper untper categ ptyp bvalt curtp
                            WITH HEADER LINE,
      t_mlcd_not_alloc    TYPE STANDARD TABLE OF mlcd
                  WITH KEY kalnr bdatj poper untper categ ptyp bvalt curtp
                  WITH HEADER LINE,
      t_curtp             LIKE cki_ml_cty OCCURS 0 WITH HEADER LINE,
      t_plants            TYPE ckml_run_t_plant,
      t_ckmlct            TYPE SORTED TABLE OF ckmlct WITH NON-UNIQUE KEY bwkey,
      t_dd07v_appl        LIKE dd07v OCCURS 0 WITH HEADER LINE,
      t_dd07v             LIKE dd07v OCCURS 0 WITH HEADER LINE.
* Tabellen für Dropdown-Box des CURTP
DATA: t_curtp_dropdown TYPE vrm_values.
DATA: BEGIN OF t_curtp_f4 OCCURS 0,
        curtp LIKE mlkey-curtp,
        text  LIKE ckmlcur-ddtext,
      END OF t_curtp_f4.
* data: g_sit_active type boole_d.

*----------------------------------------------------------------------*
*     Feldleisten                                                      *
*----------------------------------------------------------------------*
DATA: s_runperiod TYPE ckml_run_period_data,
      s_plants    TYPE ckmlrunplant,
      s_t001w     TYPE t001w.
* Für Dropdown-Box des CURTP
DATA: s_curtp_dropdown TYPE vrm_value.

*----------------------------------------------------------------------*
*     Globale Hilfsfelder                                              *
*----------------------------------------------------------------------*
DATA: h_last_bwkey            TYPE bwkey,
      h_sele_lauf             TYPE boole_d,
      h_expan                 TYPE boole_d,
      h_mlswitch(2)           TYPE n,
      h_first_bwkey           TYPE boole_d,
      h_first_mat             TYPE boole_d,
      h_exdate                TYPE sy-datum,
      h_extime                TYPE sy-uzeit,
      h_exunam                TYPE sy-uname,
      h_show_fia              TYPE boole_d VALUE 'X',
      dynpro0042_extract(132) TYPE c,
      dynpro0042_appl_text    LIKE dd07v-ddtext,
      gs_extract              TYPE ckmvfm_extract,
      ls_ckmvfm_out           TYPE ckmvfm_out,
      h_exid                  TYPE num4,
      h_count                 TYPE i,
      h_sobkz                 TYPE c,
      lh_doit                 TYPE c,                 " lh_doit for warning pop-up
      lh_lines                LIKE sy-dbcnt,
      lh_count                TYPE i,
      no_auth                 TYPE boole_d,
      h_no_acctit             TYPE boole_d,
      gd_sobkze               type boole_d,
      gd_sobkzq               type boole_d.

* Checkman:
DATA: okcode TYPE sy-ucomm.

FIELD-SYMBOLS: <s_out> TYPE s_out.

*----------------------------------------------------------------------*
*     Includes                                                         *
*----------------------------------------------------------------------*
INCLUDE: lckm0top_status,
         <icon>.

*----------------------------------------------------------------------*
*     Klassen + Controls (Referenzvariablen)                           *
*----------------------------------------------------------------------*
DATA: custom           TYPE REF TO cl_gui_custom_container,
      alv_tree         TYPE REF TO cl_gui_alv_tree,
      alv_tree_toolbar TYPE REF TO cl_gui_toolbar,
      alv_grid         TYPE REF TO cl_gui_alv_grid,
      alv_grid_toolbar TYPE REF TO cl_gui_toolbar.
*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:

      my_function_selected
                    FOR EVENT function_selected OF cl_gui_toolbar
        IMPORTING fcode,

      my_node_double_click
                    FOR EVENT node_double_click OF cl_gui_alv_tree
        IMPORTING node_key,

      my_node_context_menu_request
                    FOR EVENT node_context_menu_request OF cl_gui_alv_tree
        IMPORTING node_key menu,

      my_node_context_menu_selected
                    FOR EVENT node_context_menu_selected OF cl_gui_alv_tree
        IMPORTING node_key fcode,

      my_item_double_click
                    FOR EVENT item_double_click OF cl_gui_alv_tree
        IMPORTING node_key fieldname,

      my_item_context_menu_request
                    FOR EVENT item_context_menu_request OF cl_gui_alv_tree
        IMPORTING node_key fieldname menu,

      my_item_context_menu_selected
                    FOR EVENT item_context_menu_selected OF cl_gui_alv_tree
        IMPORTING node_key fieldname fcode,

      my_before_user_command
                    FOR EVENT before_user_command OF cl_gui_alv_tree
        IMPORTING ucomm,

      my_top_of_list
        FOR EVENT top_of_list OF cl_gui_alv_tree.


ENDCLASS.                    "lcl_event_receiver DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.

* Toolbar-Funktionen
  METHOD my_function_selected.
    CASE fcode.
      WHEN 'DETAIL'.
        PERFORM tree_detail.
      WHEN 'DET_NDI'.
        PERFORM tree_explain_ndi.
      WHEN 'DET_FIA'.
        PERFORM tree_explain_fia.
      WHEN 'DEL_PB'.
        PERFORM tree_delete_pb.
      WHEN 'LEGE'.
*        PERFORM tree_legende.
    ENDCASE.
  ENDMETHOD.                    "my_function_selected

* Doppelklick auf Knoten
  METHOD my_node_double_click.
    PERFORM tree_double_click USING node_key.
  ENDMETHOD.                    "my_node_double_click

* Kontext-Menü auf Knoten
  METHOD my_node_context_menu_request.
    PERFORM tree_context_menu USING node_key menu.
  ENDMETHOD.                    "my_node_context_menu_request

* Eigene Funktion aus Kontextmenü
  METHOD my_node_context_menu_selected.
    CASE fcode.
      WHEN 'DETAIL'.
        PERFORM tree_double_click USING node_key.
      WHEN 'DET_NDI'.
        PERFORM tree_explain_ndi.
      WHEN 'DET_FIA'.
        PERFORM tree_explain_fia.
      WHEN 'DEL_PB'.
        PERFORM tree_delete_pb.
    ENDCASE.
  ENDMETHOD.                    "my_node_context_menu_selected

* Doppelklick auf Item
  METHOD my_item_double_click.
    PERFORM tree_double_click USING node_key.
  ENDMETHOD.                    "my_item_double_click

* Kontext-Menü auf Item
  METHOD my_item_context_menu_request.
    PERFORM tree_context_menu USING node_key menu.
  ENDMETHOD.                    "my_item_context_menu_request

* Eigene Funktion aus Kontext-Menü
  METHOD my_item_context_menu_selected.
    CASE fcode.
      WHEN 'DETAIL'.
        PERFORM tree_detail.
      WHEN 'DET_NDI'.
        PERFORM tree_explain_ndi.
      WHEN 'DET_FIA'.
        PERFORM tree_explain_fia.
      WHEN 'DEL_PB'.
        PERFORM tree_delete_pb.
    ENDCASE.
  ENDMETHOD.                    "my_item_context_menu_selected

* F1-Hilfe auf der Hierarchie
  METHOD my_before_user_command.
***    PERFORM tree_hierarchy_help USING ucomm.
  ENDMETHOD.                    "my_before_user_command

* Listenkopf für Druckausgabe
  METHOD my_top_of_list.
  ENDMETHOD.                    "my_top_of_list

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

DATA: event_receiver TYPE REF TO lcl_event_receiver.

*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver_grid DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_event_receiver_grid DEFINITION.
  PUBLIC SECTION.
    METHODS:
      my_handle_toolbar
                    FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      my_handle_user_command
                    FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

      my_handle_double_click
                    FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column.

ENDCLASS.                    "lcl_event_receiver_grid DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver_grid IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_event_receiver_grid IMPLEMENTATION.
  METHOD my_handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.

*   append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.
*   append a button
    CLEAR ls_toolbar.
    MOVE 'DET_NDI' TO ls_toolbar-function.
    MOVE icon_detail TO ls_toolbar-icon.
    MOVE TEXT-015 TO ls_toolbar-quickinfo.
    MOVE TEXT-014 TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "my_handle_toolbar
  METHOD my_handle_user_command.
    DATA: lt_rows TYPE lvc_t_row.

    CASE e_ucomm.
      WHEN 'DET_NDI'.
        CALL METHOD alv_grid->get_selected_rows
          IMPORTING
            et_index_rows = lt_rows.
        CALL METHOD cl_gui_cfw=>flush.
        IF sy-subrc = 0.
          PERFORM grid_explain_ndi TABLES lt_rows.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                           "handle_user_command
  METHOD my_handle_double_click.
    PERFORM grid_double_click USING e_row e_column.
  ENDMETHOD.                    "my_handle_double_click
ENDCLASS.                    "lcl_event_receiver_grid IMPLEMENTATION

DATA: event_receiver_grid TYPE REF TO lcl_event_receiver_grid.

CONSTANTS: y_package_size   LIKE sy-dbcnt   VALUE 1000.

*----------------------------------------------------------------------*
*     Includes
*----------------------------------------------------------------------*
