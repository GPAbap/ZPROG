*&---------------------------------------------------------------------*
*& Include          ZMM_AMPLIA_MATERIALES_MASS_FUN
*&---------------------------------------------------------------------*


FORM download_data.
  SELECT * FROM marc  WHERE lvorm EQ ' '
                        AND werks IN plant
                        AND matnr IN material.
    CLEAR mara.
    SELECT SINGLE * FROM mara WHERE matnr =  marc-matnr.
*    CHECK matltype.
*    CHECK division.
    CLEAR mbew.
    SELECT SINGLE * FROM mbew WHERE matnr =  marc-matnr
                                AND bwkey =  marc-werks.

    CLEAR makt.
    SELECT SINGLE * FROM makt WHERE spras =  'EN'
                                AND matnr =  marc-matnr.

    CLEAR mvke.
    SELECT SINGLE * FROM mvke WHERE
                    matnr = marc-matnr.
*                    vkorg = to_sorg-low   AND
*                    vtweg = to_dchnl-low.

    IF sy-subrc = 0. "SELECT SINGLE * FROM mvke
      int_mat-mvke = 'X'.
    ENDIF. "sy-subrc = 0. "SELECT SINGLE * FROM mvke

    WRITE:/ marc-werks,    "Plant
            mara-mtart,    "Material type
            mara-matnr,    "Material number
            mara-matkl,    "Material group
            mara-mbrsh,    "Industry sector
            mara-meins,    "Base unit of measure
            mvke-vkorg,    "Sales Organization
            mvke-vtweg,    "Distribution Channel
            mara-gewei,    "Weight Unit
            mara-spart,    "Division
            marc-ekgrp,    "Purchasing group
            mbew-bwkey,    "Valuation Area
            mbew-bwtar,    "Valuation Type
            mbew-vprsv,    "Price control indicator
            mbew-stprs,    "Standard price
            mbew-peinh,    "Price unit
            makt-spras,    "Language key
            makt-maktx.    "Material description

    int_mat-werks = marc-werks.    "Plant
    int_mat-mtart = mara-mtart.    "Material type
    int_mat-matnr = mara-matnr.    "Material number
    int_mat-matkl = mara-matkl.    "Material group
    int_mat-mbrsh = mara-mbrsh.    "Industry sector
    int_mat-meins = mara-meins.    "Base unit of measure
    int_mat-gewei = mara-gewei.    "Weight Unit
    int_mat-spart = mara-spart.    "Division
    int_mat-ekgrp = marc-ekgrp.    "Purchasing group
    int_mat-bwkey = mbew-bwkey.    "Valuation Area
    int_mat-bwtar = mbew-bwtar.    "Valuation Type
    int_mat-vprsv = mbew-vprsv.    "Price control indicator
    int_mat-stprs = mbew-stprs.    "Standard price
    int_mat-peinh = mbew-peinh.    "Price unit
    int_mat-spras = makt-spras.    "Language key
    int_mat-maktx = makt-maktx.    "Material description
    int_mat-vkorg = mvke-vkorg.    "Sales Organization
    int_mat-vtweg = mvke-vtweg.    "Distribution Channel
    APPEND int_mat.
    CLEAR  int_mat.
  ENDSELECT.
ENDFORM.                    "DOWNLOAD_DATA

FORM download_file.
  CALL FUNCTION 'WS_DOWNLOAD'
    EXPORTING
      filename                = f_file
      filetype                = 'DAT'
    TABLES
      data_tab                = int_mat
    EXCEPTIONS
      file_open_error         = 1
      file_write_error        = 2
      invalid_filesize        = 3
      invalid_type            = 4
      no_batch                = 5
      unknown_error           = 6
      invalid_table_width     = 7
      gui_refuse_filetransfer = 8
      customer_error          = 9
      OTHERS                  = 10.

  IF sy-subrc = 0.
    FORMAT COLOR COL_GROUP.
    WRITE:/ 'Data Download Successfully to your local harddisk'.
    SKIP.
  ENDIF.
ENDFORM.                    "DOWNLOAD_FILE

FORM upload_file.
  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename                = f_file
      filetype                = 'DAT'
*     FILETYPE                = 'WK1'
    TABLES
      data_tab                = int_mat
    EXCEPTIONS
      file_open_error         = 1
      file_write_error        = 2
      invalid_filesize        = 3
      invalid_type            = 4
      no_batch                = 5
      unknown_error           = 6
      invalid_table_width     = 7
      gui_refuse_filetransfer = 8
      customer_error          = 9
      OTHERS                  = 10.

  IF sy-subrc = 0.
    FORMAT COLOR COL_GROUP.
    WRITE:/ 'Data Upload Successfully from your local harddisk'.
    SKIP.
  ENDIF.

ENDFORM.                    "UPLOAD_FILE

FORM update_mm.
  DATA:
    ls_clientdata                 TYPE bapi_mara_ga,
    ls_plantdata                  TYPE bapi_marc_ga,
    ls_forecastparameters         TYPE bapi_mpop_ga,
    ls_planningdata               TYPE bapi_mpgd_ga,
    ls_storagelocationdata        TYPE bapi_mard_ga,
    ls_valuationdata              TYPE bapi_mbew_ga,
    ls_warehousenumberdata        TYPE bapi_mlgn_ga,
    ls_salesdata                  TYPE bapi_mvke_ga,
    ls_storagetypedata            TYPE bapi_mlgt_ga,
    ls_productionresourcetooldata TYPE bapi_mfhm_ga,
    ls_lifovaluationdata          TYPE bapi_myms_ga.

  DATA:
    lt_bapi_makt_ga TYPE STANDARD TABLE OF bapi_makt_ga,
    ls_bapi_makt_ga TYPE bapi_makt_ga,

    ls_bapi_mlan_ga TYPE bapi_mlan_ga,
    lt_bapi_mlan_ga TYPE STANDARD TABLE OF bapi_mlan_ga.
  DATA:
lt_job_log                TYPE STANDARD TABLE OF bapiret2.

  LOOP AT int_mat.
    "************************Get All Data of the material*********************************

    CALL FUNCTION 'BAPI_MATERIAL_GETALL'
      EXPORTING
        material                   = int_mat-matnr "material
*       COMPANYCODE                =
        valuationarea              = int_mat-bwkey
        valuationtype              = int_mat-bwtar
        plant                      = int_mat-werks
*       STORAGELOCATION            =
        salesorganisation          = int_mat-vkorg
        distributionchannel        = int_mat-vtweg
*       WAREHOUSENUMBER            =
*       STORAGETYPE                =
*       LIFOVALUATIONLEVEL         =
*       MATERIAL_EVG               =
*       KZRFB_ALL                  =
      IMPORTING
        clientdata                 = ls_clientdata
        plantdata                  = ls_plantdata
*       forecastparameters         = ls_forecastparameters
*       planningdata               = ls_planningdata
        storagelocationdata        = ls_storagelocationdata
        valuationdata              = ls_valuationdata
        warehousenumberdata        = ls_warehousenumberdata
        salesdata                  = ls_salesdata
        storagetypedata            = ls_storagetypedata
        productionresourcetooldata = ls_productionresourcetooldata
        lifovaluationdata          = ls_lifovaluationdata
      TABLES
        materialdescription        = lt_bapi_makt_ga
*       UNITSOFMEASURE             =
*       INTERNATIONARTICLENUMBERS  =
*       MATERIALTEXT               =
        taxclassifications         = lt_bapi_mlan_ga
*       EXTENSIONOUT               =
*       RETURN                     =
      .
    "************************End Get All Data of Material********************************

* Header
    bapi_head-material        = ls_clientdata-material.
    bapi_head-ind_sector      = ls_clientdata-ind_sector.
    bapi_head-matl_type       = ls_clientdata-matl_type.
*    bapi_head-ekwsl           = ls_clientdata-ekwsl.

    bapi_head-basic_view      = 'X'.
    bapi_head-purchase_view   = 'X'.
    bapi_head-account_view    = 'X'.
    bapi_head-mrp_view        = 'X'.
    bapi_head-work_sched_view = 'X'.
    bapi_head-cost_view       = 'X'.

    IF     int_mat-mvke = 'X'.
      bapi_head-sales_view       = 'X'.
    ENDIF.
    bapi_head-storage_view    = 'X'.

    "For Extending Quality View Data.
    SELECT * INTO TABLE lt_qmat
      FROM qmat
      WHERE matnr = int_mat-matnr AND
            werks EQ plant-low.
    IF sy-subrc = 0.
      bapi_head-inp_fld_check    = 'W'.
      bapi_head-quality_view    = 'X'.
    ENDIF.

* Material Description
    READ TABLE lt_bapi_makt_ga INTO ls_bapi_makt_ga INDEX 1.
    IF sy-subrc = 0.
      REFRESH int_makt.
      int_makt-langu           = ls_bapi_makt_ga-langu.
      int_makt-matl_desc       = ls_bapi_makt_ga-matl_desc.
      APPEND int_makt.
      CLEAR ls_bapi_makt_ga.
    ENDIF.

* Client Data - Basic
    bapi_mara1-pur_valkey     = ls_clientdata-pur_valkey.
    bapi_mara1-matl_group     = ls_clientdata-matl_group.
    bapi_mara1-base_uom       = ls_clientdata-base_uom.
    bapi_mara1-unit_of_wt     = ls_clientdata-unit_of_wt.
    bapi_mara1-division       = ls_clientdata-division.
    bapi_mara1-dsn_office     = ls_clientdata-dsn_office.
    bapi_mara1-mat_grp_sm     = ls_clientdata-mat_grp_sm.
    bapi_mara1-trans_grp      = ls_clientdata-trans_grp.
    bapi_mara1-std_descr      = ls_clientdata-std_descr.

    bapi_marax-std_descr  = 'X'.
    bapi_marax-pur_valkey = 'X'.
    bapi_marax-dsn_office = 'X'.
    bapi_marax-mat_grp_sm = 'X'.
    bapi_marax-trans_grp  = 'X'.
    bapi_marax-matl_group = 'X'.
    bapi_marax-base_uom   = 'X'.
    bapi_marax-unit_of_wt = 'X'.
    bapi_marax-division   = 'X'.


* Plant - Purchasing
    bapi_marc1-plant      = to_plant-low. "ls_plantdata-plant.
    bapi_marc1-pur_group  = ls_plantdata-pur_group. "Purch Group
    bapi_marc1-availcheck = ls_plantdata-availcheck.
    bapi_marc1-loadinggrp = ls_plantdata-loadinggrp.
    bapi_marc1-base_qty_plan = ls_plantdata-base_qty_plan. "Base Qty
    bapi_marc1-gr_pr_time = ls_plantdata-gr_pr_time. "Purchasing time for GR
    bapi_marc1-quotausage = ls_plantdata-quotausage. "Quota Arrangement usage
    bapi_marc1-auto_p_ord = ls_plantdata-auto_p_ord. "Auto purch allow
    bapi_marc1-mrp_group  = ls_plantdata-mrp_group.
    bapi_marc1-mrp_type   = ls_plantdata-mrp_type.
    bapi_marc1-pl_ti_fnce = ls_plantdata-pl_ti_fnce.
    bapi_marc1-mrp_ctrler = ls_plantdata-mrp_ctrler.
    bapi_marc1-lotsizekey = ls_plantdata-lotsizekey.
    bapi_marc1-round_val  = ls_plantdata-round_val.
    bapi_marc1-proc_type  = ls_plantdata-proc_type.
    bapi_marc1-spproctype = ls_plantdata-spproctype.
    bapi_marc1-batchentry = ls_plantdata-batchentry.
    bapi_marc1-iss_st_loc = ls_plantdata-iss_st_loc.
    bapi_marc1-backflush  = ls_plantdata-backflush.
    bapi_marc1-plnd_delry   = ls_plantdata-plnd_delry.
    bapi_marc1-sm_key     = ls_plantdata-sm_key.
    bapi_marc1-plan_strgp  = ls_plantdata-plan_strgp.
    bapi_marc1-prodprof   = ls_plantdata-prodprof.
    bapi_marc1-consummode  = ls_plantdata-consummode.
    bapi_marc1-fwd_cons      = ls_plantdata-fwd_cons.
    bapi_marc1-bwd_cons     = ls_plantdata-bwd_cons.
    bapi_marc1-variance_key    = ls_plantdata-variance_key.
    bapi_marc1-profit_ctr  = space. "'ECCA050065'."ls_plantdata-profit_ctr.
    bapi_marc1-determ_grp = ls_plantdata-determ_grp.
    bapi_marc1-ctrl_key     = ls_plantdata-ctrl_key.
    bapi_marc1-ctrl_code = ls_plantdata-ctrl_code.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = to_plant-low
      IMPORTING
        output = ls_plantdata-profit_ctr.

    bapi_marc1-profit_ctr  = 'ECCA050065'."ls_plantdata-profit_ctr. "ls_plantdata-plant.  "PROFIT_CTR
    bapi_marc1-determ_grp = ls_plantdata-determ_grp.

*    bapi_marcx-DEL_FLAG   = 'X'.
    bapi_marcx-plant      = to_plant-low. "ls_plantdata-plant.
    bapi_marcx-pur_group  = 'X'.
    bapi_marcx-availcheck = 'X'.
    bapi_marcx-loadinggrp = 'X'.
    bapi_marcx-base_qty_plan = 'X'.
    bapi_marcx-gr_pr_time = 'X'.
    bapi_marcx-quotausage = 'X'.
    bapi_marcx-auto_p_ord = 'X'.
    bapi_marcx-mrp_group  = 'X'.
    bapi_marcx-mrp_type   = 'X'.
    bapi_marcx-pl_ti_fnce = 'X'.
    bapi_marcx-mrp_ctrler = 'X'.
    bapi_marcx-lotsizekey = 'X'.
    bapi_marcx-round_val  = 'X'.
    bapi_marcx-proc_type  = 'X'.
    bapi_marcx-spproctype = 'X'.
    bapi_marcx-batchentry = 'X'.
    bapi_marcx-iss_st_loc = 'X'.
    bapi_marcx-backflush  = 'X'.
    bapi_marcx-plnd_delry   = 'X'.
    bapi_marcx-sm_key     = 'X'.
    bapi_marcx-plan_strgp  = 'X'.
    bapi_marcx-prodprof   = 'X'.
    bapi_marcx-consummode  = 'X'.
    bapi_marcx-fwd_cons      = 'X'.
    bapi_marcx-bwd_cons     = 'X'.
    bapi_marcx-variance_key    = 'X'.
    bapi_marcx-profit_ctr  = 'X'.
    bapi_marcx-determ_grp = 'X'.
    bapi_marcx-ctrl_key = 'X'.
    bapi_marcx-ctrl_code = 'X'.

* Storage Location Data
    IF ls_storagelocationdata-stge_loc IS INITIAL.
      select SINGLE lgort into ls_storagelocationdata-stge_loc
        from mard where matnr =  int_mat-matnr and werks = int_mat-werks.
      "ls_storagelocationdata-stge_loc = 'AGMP'.
    ENDIF. "ls_storagelocationdata-stge_loc IS INITIAL.

    bapi_mard-plant    = to_plant-low.
    bapi_mard-stge_loc = ls_storagelocationdata-stge_loc.

    bapi_mardx-plant    = to_plant-low.
    bapi_mardx-stge_loc = ls_storagelocationdata-stge_loc.

* Accounting - VALUATIONDATA
    bapi_mbew1-val_area   = to_plant-low.
    bapi_mbew1-val_type   = ls_valuationdata-val_type.
    bapi_mbew1-val_class  = ls_valuationdata-val_class.
    bapi_mbew1-price_ctrl = ls_valuationdata-price_ctrl.
    bapi_mbew1-std_price  = ls_valuationdata-std_price.
    bapi_mbew1-price_unit = ls_valuationdata-price_unit.
    bapi_mbew1-qty_struct      = ls_valuationdata-qty_struct.
    bapi_mbew1-orig_mat = ls_valuationdata-orig_mat.
    bapi_mbew1-pr_ctrl_pp = ls_valuationdata-pr_ctrl_pp. "'V'.
    bapi_mbew1-pr_ctrl_py = ls_valuationdata-pr_ctrl_py."'V'.
    bapi_mbew1-ml_active = ls_valuationdata-ml_active. "'X'.
    bapi_mbew1-ml_settle = ls_valuationdata-ml_settle. "2.

    bapi_mbewx-val_area   = to_plant-low. "ls_valuationdata-val_area.
    bapi_mbewx-val_type   = ls_valuationdata-val_type.
    bapi_mbewx-val_class   = 'X'.
    bapi_mbewx-price_ctrl = 'X'.
    bapi_mbewx-std_price  = 'X'.
    bapi_mbewx-price_unit = 'X'.
    bapi_mbewx-qty_struct      = 'X'.
    bapi_mbewx-orig_mat = 'X'.
    bapi_mbewx-pr_ctrl_pp = 'X'.
    bapi_mbewx-pr_ctrl_py = 'X'.
    bapi_mbewx-ml_settle = 'X'.
    bapi_mbewx-ml_active = 'X'.
* Tax Classification
    LOOP AT lt_bapi_mlan_ga INTO ls_bapi_mlan_ga.
      ls_bapi_mlan-depcountry = ls_bapi_mlan_ga-depcountry.
      ls_bapi_mlan-depcountry_iso = ls_bapi_mlan_ga-depcountry_iso.
      CASE sy-tabix.
        WHEN 1.
          ls_bapi_mlan-tax_type_1      = ls_bapi_mlan_ga-tax_type_1.
          ls_bapi_mlan-taxclass_1      = ls_bapi_mlan_ga-taxclass_1.
        WHEN 2.
          ls_bapi_mlan-tax_type_2      = ls_bapi_mlan_ga-tax_type_1.
          ls_bapi_mlan-taxclass_2      = ls_bapi_mlan_ga-taxclass_1.
        WHEN 3.
          ls_bapi_mlan-tax_type_3      = ls_bapi_mlan_ga-tax_type_1.
          ls_bapi_mlan-taxclass_3      = ls_bapi_mlan_ga-taxclass_1.
        WHEN 4.
          ls_bapi_mlan-tax_type_4      = ls_bapi_mlan_ga-tax_type_1.
          ls_bapi_mlan-taxclass_4      = ls_bapi_mlan_ga-taxclass_1.
      ENDCASE. "sy-tabix.
    ENDLOOP. "AT lt_bapi_mlan_ga INTO ls_bapi_mlan_ga.

    CLEAR bapi_mlan.
    IF ls_bapi_mlan IS NOT INITIAL.
      APPEND ls_bapi_mlan TO bapi_mlan.
    ENDIF. "ls_bapi_mlan is not INITIAL.

    "SALES DATA
    IF     int_mat-mvke = 'X'.
      bapi_mvke1-sales_org = ls_salesdata-sales_org. "to_sorg-low.
      bapi_mvke1-matl_stats = ls_salesdata-matl_stats.
      bapi_mvke1-mat_pr_grp = ls_salesdata-mat_pr_grp.
      bapi_mvke1-acct_assgt = ls_salesdata-acct_assgt.
      bapi_mvke1-distr_chan = ls_salesdata-distr_chan. "to_dchnl-low.
      bapi_mvke1-item_cat = ls_salesdata-item_cat.
      bapi_mvke1-matl_grp_1 = ls_salesdata-matl_grp_1.
      bapi_mvke1-matl_grp_2 = ls_salesdata-matl_grp_2.
      bapi_mvke1-matl_grp_3 = ls_salesdata-matl_grp_3.
      bapi_mvke1-matl_grp_4 = ls_salesdata-matl_grp_4.
      bapi_mvke1-matl_grp_5 = ls_salesdata-matl_grp_5.
      bapi_mvke1-sales_unit = ls_salesdata-sales_unit.
      bapi_mvke1-acct_assgt = ls_salesdata-acct_assgt.

      bapi_mvkex-sales_org = ls_salesdata-sales_org."to_sorg-low.
      bapi_mvkex-matl_stats = 'X'.
      bapi_mvkex-mat_pr_grp = 'X'.
      bapi_mvkex-acct_assgt = 'X'.
      bapi_mvkex-distr_chan = ls_salesdata-distr_chan."to_dchnl-low.
      bapi_mvkex-item_cat = 'X'.
      bapi_mvkex-matl_grp_1 = 'X'.
      bapi_mvkex-matl_grp_2 = 'X'.
      bapi_mvkex-matl_grp_3 = 'X'.
      bapi_mvkex-matl_grp_4 = 'X'.
      bapi_mvkex-matl_grp_5 = 'X'.
      bapi_mvkex-sales_unit = 'X'.
      bapi_mvkex-acct_assgt = 'X'.
    ENDIF. "  IF     int_mat-mvke = 'X'.

*    WRITE:/ bapi_head, bapi_marc1-plant, to_plant-low.

    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata             = bapi_head
        clientdata           = bapi_mara1
        clientdatax          = bapi_marax
        plantdata            = bapi_marc1
        plantdatax           = bapi_marcx
*       FORECASTPARAMETERS   =
*       FORECASTPARAMETERSX  =
*       PLANNINGDATA         =
*       PLANNINGDATAX        =
        storagelocationdata  = bapi_mard
        storagelocationdatax = bapi_mardx
        valuationdata        = bapi_mbew1
        valuationdatax       = bapi_mbewx
        salesdata            = bapi_mvke1
        salesdatax           = bapi_mvkex
*       STORAGETYPEDATA      =
*       STORAGETYPEDATAX     =
      IMPORTING
        return               = bapi_return
      TABLES
        materialdescription  = int_makt
        taxclassifications   = bapi_mlan.
    WRITE:/ 'BAPI Message ', ls_clientdata-material, bapi_return-message.
    APPEND bapi_return TO lt_job_log.

    IF bapi_return-type = 'S'. "Material SAve/Extend Success
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'
*         IMPORTING
*         RETURN        =
        .
      IF bapi_head-quality_view    = 'X'.
        LOOP AT lt_qmat INTO ls_qmat.
          CLEAR : ls_bapi_qmat.
          CALL FUNCTION 'MAP2E_QMAT_TO_BAPI1001004_QMAT'
            EXPORTING
              qmat             = ls_qmat
            CHANGING
              bapi1001004_qmat = ls_bapi_qmat.

          ls_bapi_qmat-plant    = to_plant-low.
          APPEND ls_bapi_qmat TO bapi_qmat.
        ENDLOOP. "AT lt_qmat INTO ls_qmat.

        CALL FUNCTION 'BAPI_MATINSPCTRL_SAVEREPLICA'
          TABLES
            return         = lt_bapi_return
            inspectionctrl = bapi_qmat.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

      ENDIF. "bapi_head-QUALITY_VIEW    = 'X'.

    ENDIF. "bapi_return-type = 'S'. "Material SAve/Extend Success

  ENDLOOP.

ENDFORM.                    "UPDATE_MM
