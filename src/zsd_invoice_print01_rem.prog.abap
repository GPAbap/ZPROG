*&---------------------------------------------------------------------*
*& Report  SD_INVOICE_PRINT01
*&
*&---------------------------------------------------------------------*
*&              Print Program for Billing Documents
*&
*&---------------------------------------------------------------------*

REPORT  zsd_invoice_print01_rem MESSAGE-ID vd_pdf.

TABLES: nast,
        tnapr,
        toa_dara,
        vbdkr,                                    "#EC NEEDED sapscript
        komk,                                     "#EC NEEDED sapscript
        tvko.                                     "#EC NEEDED sapscript

*--- SD-SEPA
INCLUDE item_topdata.
*--- SD-SEPA

TYPE-POOLS: szadr.

TYPES: BEGIN OF vbeln_posnr_s,
         vbeln TYPE vbeln,
         posnr TYPE posnr,
       END OF vbeln_posnr_s,
       vbeln_posnr_t TYPE TABLE OF vbeln_posnr_s.

DATA: gs_interface        TYPE invoice_s_prt_interface,
      gv_screen_display   TYPE char1,
      gv_price_print_mode TYPE char1,
      gt_komv             TYPE TABLE OF komv,
      gs_komk             TYPE komk,
      gt_vbtyp_fix_values TYPE TABLE OF dd07v,
      gv_language         TYPE sylangu,
      gv_dummy            TYPE char1,                       "#EC NEEDED
      gt_sdaccdpc_doc     TYPE vbeln_posnr_t,
      gt_sdaccdpc         TYPE sdaccdpc_t,
      gv_downpay_refresh  TYPE c,
      BEGIN OF gs_nast.
        INCLUDE STRUCTURE nast.
DATA: email_addr TYPE ad_smtpadr,
      END OF gs_nast.

DATA: gv_badi_filter             TYPE char30.
DATA: bd_sd_bil                  TYPE REF TO badi_sd_bil_print01.

DATA it_remision TYPE STANDARD TABLE OF zsd_st_data_cli.
DATA it_bascula  TYPE STANDARD TABLE OF zbascula_rem_pv.

DATA: vl_ZM02, vl_ZM03.

DATA: gv_bascula   TYPE tdbool,
      gv_nomgranja TYPE string.
FIELD-SYMBOLS:
  <gs_vbdkr>      TYPE vbdkr,
  <gv_returncode> TYPE sysubrc.

CONSTANTS:
  gc_pr_kappl TYPE char1 VALUE 'V',
  gc_true     TYPE char1 VALUE 'X',
  gc_false    TYPE char1 VALUE space,
  gc_english  TYPE char1 VALUE 'E',
  gc_pdf      TYPE char1 VALUE '2',
  gc_equal    TYPE char2 VALUE 'EQ',
  gc_include  TYPE char1 VALUE 'I',
  BEGIN OF gc_nacha,
    printer       TYPE na_nacha VALUE 1,
    fax           TYPE na_nacha VALUE 2,
    external_send TYPE na_nacha VALUE 5,
  END OF gc_nacha,
  BEGIN OF gc_device,
    printer    TYPE output_device VALUE 'P',
    fax        TYPE output_device VALUE 'F',
    email      TYPE output_device VALUE 'E',
    web_dynpro TYPE output_device VALUE 'W',
  END OF gc_device.

* >>>>> BUNDLING <<<<< *************************************************
INCLUDE check_bundling_print.
* >>>>> BUNDLING <<<<< *************************************************

* handle preview output
DATA gv_has_transient_data TYPE c.
INCLUDE sd_invoice_get_transient_data IF FOUND.

*---------------------------------------------------------------------*
*       FORM ENTRY                                                    *
*---------------------------------------------------------------------*
FORM entry                                                  "#EC CALLED
  USING cv_returncode        TYPE sysubrc
        uv_screen            TYPE char1.

  TRY.
*     Get BAdI handle
      GET BADI bd_sd_bil
        FILTERS
          filter_billing = tnapr-sform.
    CATCH cx_badi_not_implemented.
*     This should not occur due to fallback class but to be save...
      CLEAR bd_sd_bil.
    CATCH cx_badi_multiply_implemented.
*     Several implementations exist for the filter 'form name'.
*     This appears to be very unlikely but to be save...
      CLEAR bd_sd_bil.
  ENDTRY.

* Assign RC
  ASSIGN cv_returncode TO <gv_returncode>.

* Refresh global data
  PERFORM initialize_data.

  gv_screen_display = uv_screen.
  gs_nast           = nast.

* start processing
  PERFORM processing.

ENDFORM.                    "entry

*&---------------------------------------------------------------------*
*&      Form  processing
*&---------------------------------------------------------------------*
FORM processing.

*--- Retrieve the data
  PERFORM get_data.
  CHECK <gv_returncode> IS INITIAL.

*--- Print, fax, send data
  PERFORM print_data.
  CHECK <gv_returncode> IS INITIAL.

ENDFORM.                    " processing

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
FORM get_data.

  DATA: ls_comwa TYPE vbco3,
        lt_vbdpr TYPE tbl_vbdpr.
  DATA: ls_druckprofil TYPE ledruckprofil, "IBGI
        ls_nast        TYPE nast.          "IBGI
  DATA: ro_print    TYPE REF TO cl_tm_invoice,
        lv_sim_flag TYPE boolean.


  DATA: vl_cantidad_mh TYPE char10, vl_valor TYPE string,aux_pp type p DECIMALS 2,
        vl_zona        TYPE string,
        vl_posnr       TYPE posnr,
        vl_tdname      TYPE tdobname.



  DATA: vl_cant10     TYPE char20,vl_cant20 TYPE char20,vl_cant30 TYPE char20,vl_cant40 TYPE char20,
        vl_pp10       TYPE char20,vl_pp20 TYPE char20,vl_pp30 TYPE char20,vl_pp40 TYPE char20,
        vl_pigmento10 TYPE char20,vl_pigmento20 TYPE char20,vl_pigmento30 TYPE char20,vl_pigmento40 TYPE char20,
        vl_zona10     TYPE char20,vl_zona20 TYPE char20,vl_zona30 TYPE char20,vl_zona40 TYPE char20,
        vl_caseta10   TYPE char20,vl_caseta20 TYPE char20,vl_caseta30 TYPE char20,vl_caseta40 TYPE char20,
        vl_edad10     TYPE char20,vl_edad20 TYPE char20,vl_edad30 TYPE char20,vl_edad40 TYPE char20,
        vl_lote10     TYPE charg_d,vl_lote20 TYPE charg_d,vl_lote30 TYPE charg_d,vl_lote40 TYPE charg_d,
        vl_vtext10    TYPE vtext, vl_vtext20 TYPE vtext, vl_vtext30 TYPE vtext,vl_vtext40 TYPE vtext,
        lv_timestamp  TYPE char10,
        vl_total_aves TYPE menge_d,
        vl_peso_prom  TYPE zpesop.



  CLEAR gv_has_transient_data.
  PERFORM get_transient_data IN PROGRAM sd_invoice_print01 IF FOUND
                             CHANGING gv_has_transient_data
                                      gt_komv[].
  IF gv_has_transient_data IS INITIAL.
    CALL FUNCTION 'RV_PRICE_PRINT_REFRESH'
      TABLES
        tkomv = gt_komv.
  ENDIF.

  ro_print = cl_tm_invoice=>get_instance( ).
  lv_sim_flag = ro_print->get_simulation_flag( ).
  IF lv_sim_flag IS NOT INITIAL.
    gt_komv = cl_tm_invoice=>gt_komv.
  ENDIF.

  ls_comwa-mandt = sy-mandt.
  ls_comwa-spras = gs_nast-spras.
  ls_comwa-kunde = gs_nast-parnr.
  ls_comwa-parvw = gs_nast-parvw.
  IF gs_nast-objky+10(6) NE space.
    ls_comwa-vbeln = gs_nast-objky+16(10).
  ELSE.
    ls_comwa-vbeln = gs_nast-objky.
  ENDIF.

*--- Call the famous print view
  CALL FUNCTION 'RV_BILLING_PRINT_VIEW'
    EXPORTING
      comwa                        = ls_comwa
    IMPORTING
      kopf                         = gs_interface-head_detail-vbdkr
    TABLES
      pos                          = lt_vbdpr
    EXCEPTIONS
      terms_of_payment_not_in_t052 = 1
      error_message                = 2
      OTHERS                       = 3.

  IF sy-subrc = 1.
    sy-msgty = 'I'.
    PERFORM protocol_update.
  ELSEIF sy-subrc <> 0.
    <gv_returncode> = sy-subrc.
    PERFORM protocol_update.
    RETURN.
  ENDIF.

*--- Assign a global pointer to the VBDKR
  ASSIGN gs_interface-head_detail-vbdkr TO <gs_vbdkr>.

*--- Set default language
  gv_language = gs_nast-spras.

*--- Set Country for display conversions e.g. WRITE TO
  SET COUNTRY <gs_vbdkr>-land1.

*--- Get the item details
  PERFORM get_item_details   USING lt_vbdpr.
  CHECK <gv_returncode> IS INITIAL.

*--- Get the header details
  PERFORM get_head_details.
  CHECK <gv_returncode> IS INITIAL.

*  ENHANCEMENT-POINT EHP3_GET_DATA_01 SPOTS ES_SD_INVOICE_PRINT01.

  CLEAR: gv_bascula, vl_cant10,vl_cant20, vl_cant30,vl_cant40, vl_cantidad_mh,
         vl_caseta10, vl_caseta20, vl_caseta30,vl_caseta40, vl_edad10, vl_edad20,
         vl_edad30,vl_edad40, vl_lote10, vl_lote20, vl_lote30,vl_lote40, vl_peso_prom,
         vl_pigmento10, vl_pigmento20, vl_pigmento30,vl_pigmento40, vl_posnr,
         vl_pp10, vl_pp20, vl_pp30,vl_pp40,vl_total_aves,gv_nomgranja.


  REFRESH: it_remision, it_bascula.

  """""""""""query"""""""""""""""""""""""
  SELECT CASE WHEN k~ktokd EQ 'CVPG' THEN
  concat_with_space( a~sort1, a~sort2,1 )
  ELSE k~name1 END AS zcliente,
  k2~stras AS zdireccion,
  CASE WHEN k~ktokd EQ 'CVPG' THEN
  k~stcd3 ELSE k~stcd1 END AS zrfc,
  concat_with_space( k2~ort01, k2~pstlz,1 ) AS zdestino,
  k~kunnr AS zcodigo_sap,k~telf1 AS ztelefono,
  "concat_with_space( v~bstnk,concat_with_space( '/', f~vbeln ,  1 ),1 ) AS zid_portal,
  v~bstnk AS zid_portal,
  v~erdat AS zfecha, concat_with_space( v~vkgrp, t~bezei ,  1 ) AS zvendedor,
  v~vbeln AS zpedido_sap,
  v~vdatu AS zfecha_entr, l~lfuhr AS zhora_entr,

  '000000' AS zcant_mh10,'000000' AS zcant_mh20,'000000' AS zcant_mh30,'000000' AS zcant_mh40,
  '000.0' AS zpeso_prom10,'000.0' AS zpeso_prom20,'000.0' AS zpeso_prom30,'000.0' AS zpeso_prom40,
  '25.5' AS zpigmento10,'25.5' AS zpigmento20,'25.5' AS zpigmento30,'25.5' AS zpigmento40,
  l~lfuhr AS zhr_lleg_cte,
  ' ' AS zzona_carga10,' ' AS zzona_carga20,' ' AS zzona_carga30,' ' AS zzona_carga40,
  p~werks AS zno_granja10,p~werks AS zno_granja20,p~werks AS zno_granja30,p~werks AS zno_granja40,
  'sin dato' AS zcaseta10,'sin dato' AS zcaseta20,'sin dato' AS zcaseta30,'sin dato' AS zcaseta40,
  p~charg AS zlote10,p~charg AS zlote20,p~charg AS zlote30,p~charg AS zlote40,
  'EDAD' AS zedad10,'EDAD' AS zedad20,'EDAD' AS zedad30,'EDAD' AS zedad40,
  'zobservaciones del pedido a 50 caracteres' AS zobservaciones,p~kwmeng AS zkwmeng,
  concat( v~vbeln, p~posnr ) AS txid, p~posnr, v~spart,
  CASE WHEN p~spart EQ '92' THEN 'M' ELSE
  CASE WHEN p~spart EQ '91' THEN 'H' ELSE
  CASE WHEN p~spart EQ '93' THEN 'R' ELSE
  CASE WHEN p~spart EQ '94' THEN 'HL' ELSE ts~vtext END END END END  AS txtspart
  FROM vbak AS v
INNER JOIN vbap AS p ON p~vbeln EQ v~vbeln
INNER JOIN vbpa AS vb ON vb~vbeln = v~vbeln AND vb~parvw = 'WE'
LEFT JOIN vbfa AS f ON f~vbelv EQ v~vbeln AND vbtyp_n = 'J'
LEFT JOIN likp AS l ON l~vbeln EQ f~vbeln
LEFT  JOIN tvgrt AS t ON t~vkgrp EQ v~vkgrp
INNER JOIN tspat AS ts ON ts~spart EQ v~spart AND ts~spras = 'S'
INNER JOIN kna1 AS k ON k~kunnr EQ v~kunnr
INNER JOIN kna1 AS k2 ON k2~kunnr EQ vb~kunnr
LEFT JOIN adrc AS a ON a~addrnumber EQ k~adrnr
WHERE v~vbeln = @nast-objky
  INTO  TABLE @it_remision.


  SELECT SINGLE vbeln INTO @DATA(wa_vbeln)
    FROM vbfa
  WHERE vbelv EQ @nast-objky AND vbtyp_n = 'J'.

  SELECT vbeln, kschl
    INTO TABLE @DATA(it_condPago)
  FROM vbak AS v
  INNER JOIN prcd_elements AS p
    ON p~knumv = v~knumv
  WHERE v~vbeln = @nast-objky.

  IF it_condPago IS NOT INITIAL.
    READ TABLE it_condPago INTO DATA(WA_zm02) WITH KEY kschl = 'ZM02'.
    IF sy-subrc EQ 0.
      vl_zm02 = abap_true.
    ELSE.
      vl_zm02 = abap_false.
    ENDIF.

    READ TABLE it_condPago INTO DATA(WA_zm03) WITH KEY kschl = 'ZM03'.
    IF sy-subrc EQ 0.
      vl_zm03 = abap_true.
    ELSE.
      vl_zm03 = abap_false.
    ENDIF.

  ENDIF.





  LOOP AT it_remision ASSIGNING FIELD-SYMBOL(<fs_wa>).

    ASSIGN COMPONENT 'ZNO_GRANJA10' OF STRUCTURE <fs_wa> TO FIELD-SYMBOL(<fs_field>).

    SELECT SINGLE name1
      INTO gv_nomgranja
      FROM t001w
    WHERE Werks = <fs_field>.

    ASSIGN COMPONENT 'TXID' OF STRUCTURE <fs_wa> TO <fs_field>.
    vl_tdname = <fs_field>.

    IF wa_vbeln IS NOT INITIAL.
      ASSIGN COMPONENT 'ZID_PORTAL' OF STRUCTURE <fs_wa> TO <fs_field>.
      CONCATENATE <fs_field>  wa_vbeln INTO <fs_field> SEPARATED BY '/'.
    ENDIF.

    ASSIGN COMPONENT 'POSNR' OF STRUCTURE <fs_wa> TO <fs_field>.
    vl_posnr = <fs_field>.

    ASSIGN COMPONENT 'zhora_entr' OF STRUCTURE <fs_wa> TO <fs_field>.
    lv_timestamp = <fs_field>.

    CONCATENATE lv_timestamp+0(2)':' lv_timestamp+2(2) INTO lv_timestamp.
    <fs_field> = lv_timestamp.

    CLEAR vl_valor.
    PERFORM get_textos USING 'TX18' vl_tdname 'VBBP'"caseta
                       CHANGING vl_valor.
    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZCASETA10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_caseta10 = vl_valor.
      WHEN '000020'.
        ASSIGN COMPONENT 'ZCASETA20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_caseta20 = vl_valor.
      WHEN '000030'.
        ASSIGN COMPONENT 'ZCASETA30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_caseta30 = vl_valor.
      WHEN '000040'.
        ASSIGN COMPONENT 'ZCASETA40' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_caseta40 = vl_valor.
      WHEN OTHERS.
    ENDCASE.
    .

    CLEAR vl_valor.
    PERFORM get_textos USING 'TX19' vl_tdname 'VBBP'"ZONA de carga
                       CHANGING vl_valor.


    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZZONA_CARGA10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_zona10 = vl_valor.
      WHEN '000020'.
        ASSIGN COMPONENT 'ZZONA_CARGA20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_zona20 = vl_valor.
      WHEN '000030'.
        ASSIGN COMPONENT 'ZZONA_CARGA30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_zona30 = vl_valor.
      WHEN '000040'.
        ASSIGN COMPONENT 'ZZONA_CARGA40' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_zona40 = vl_valor.
      WHEN OTHERS.
    ENDCASE.

    CLEAR vl_valor.
    PERFORM get_textos USING 'TX20' vl_tdname 'VBBP'"Peso Prom
                       CHANGING vl_valor.
    aux_pp = vl_valor.
    aux_pp = vl_valor / '1000.0'.
    IF aux_pp GT 0.
     vl_valor = aux_pp.
    ENDIF.

    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZPESO_PROM10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_pp10 = vl_valor.
      WHEN '000020'.
        ASSIGN COMPONENT 'ZPESO_PROM20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_pp20 = vl_valor.
      WHEN '000030'.
        vl_pp30 = vl_valor.
        ASSIGN COMPONENT 'ZPESO_PROM30' OF STRUCTURE <fs_wa> TO <fs_field>.
      WHEN '000040'.
        vl_pp40 = vl_valor.
        ASSIGN COMPONENT 'ZPESO_PROM40' OF STRUCTURE <fs_wa> TO <fs_field>.
      WHEN OTHERS.
    ENDCASE.

    CLEAR vl_valor.
    PERFORM get_textos USING 'TX21' vl_tdname 'VBBP'"Peso Prom
                       CHANGING vl_valor.

    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZPIGMENTO10' OF STRUCTURE <fs_wa> TO <fs_field>.
        "vl_pigmento10 = vl_valor.
      WHEN '000020'.
        ASSIGN COMPONENT 'ZPIGMENTO20' OF STRUCTURE <fs_wa> TO <fs_field>.
        "vl_pigmento20 = vl_valor.
      WHEN '000030'.
        ASSIGN COMPONENT 'ZPIGMENTO30' OF STRUCTURE <fs_wa> TO <fs_field>.
        "vl_pigmento30 = vl_valor.
      WHEN '000040'.
        ASSIGN COMPONENT 'ZPIGMENTO40' OF STRUCTURE <fs_wa> TO <fs_field>.
        "vl_pigmento40 = vl_valor.
      WHEN OTHERS.
    ENDCASE.

    CLEAR vl_valor.
    PERFORM get_textos USING 'TX22' vl_tdname 'VBBP'"Edad
                       CHANGING vl_valor.
    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZEDAD10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_edad10 = vl_valor.
      WHEN '000020'.
        ASSIGN COMPONENT 'ZEDAD20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_edad20 = vl_valor.
      WHEN '000030'.
        ASSIGN COMPONENT 'ZEDAD30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_edad30 = vl_valor.
      WHEN '000040'.
        ASSIGN COMPONENT 'ZEDAD40' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_edad40 = vl_valor.
      WHEN OTHERS.
    ENDCASE.
    <fs_field> = vl_valor.



    ASSIGN COMPONENT 'ZPEDIDO_SAP' OF STRUCTURE <fs_wa> TO <fs_field>.
    vl_tdname = <fs_field>.

    CLEAR vl_valor.
    PERFORM get_textos USING 'ZS06' vl_tdname 'VBBK'
                       CHANGING vl_valor.

    PERFORM get_textos USING 'ZS12' vl_tdname 'VBBK'
                       CHANGING vl_valor.

    ASSIGN COMPONENT 'ZOBSERVACIONES' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_valor.


    "se suma la cantidad de las posiciones

    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZKWMENG' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_cant10 = <fs_field>.
        vl_total_aves = vl_total_aves + <fs_field>.
        SPLIT vl_cant10 AT '.' INTO vl_cant10 vl_cantidad_mh.
        CONDENSE vl_cant10 NO-GAPS.
      WHEN '000020'.
        ASSIGN COMPONENT 'ZKWMENG' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_cant20 = <fs_field>.
        vl_total_aves = vl_total_aves + <fs_field>.
        SPLIT vl_cant20 AT '.' INTO vl_cant20 vl_cantidad_mh.
        "translate vl_cant20 using '.'.
        CONDENSE vl_cant20 NO-GAPS.
      WHEN '000030'.
        ASSIGN COMPONENT 'ZKWMENG' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_cant30 = <fs_field>.
        vl_total_aves = vl_total_aves + <fs_field>.
        SPLIT vl_cant30 AT '.' INTO vl_cant30 vl_cantidad_mh.
        " translate vl_cant30 using '.'.
        CONDENSE vl_cant30 NO-GAPS.
      WHEN '000040'.
        ASSIGN COMPONENT 'ZKWMENG' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_cant40 = <fs_field>.
        vl_total_aves = vl_total_aves + <fs_field>.
        SPLIT vl_cant40 AT '.' INTO vl_cant40 vl_cantidad_mh.
        " translate vl_cant30 using '.'.
        CONDENSE vl_cant40 NO-GAPS.
      WHEN OTHERS.
    ENDCASE.

    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'TXTSPART' OF STRUCTURE <fs_wa> TO <fs_field>.
        CONCATENATE vl_cant10 '-' <fs_field> INTO vl_cant10.
        CONDENSE vl_cant10 NO-GAPS.
      WHEN '000020'.
        ASSIGN COMPONENT 'TXTSPART' OF STRUCTURE <fs_wa> TO <fs_field>.
        CONCATENATE vl_cant20 '-' <fs_field> INTO vl_cant20.
        CONDENSE vl_cant20 NO-GAPS.
      WHEN '000030'.
        ASSIGN COMPONENT 'TXTSPART' OF STRUCTURE <fs_wa> TO <fs_field>.
        CONCATENATE vl_cant30 '-' <fs_field> INTO vl_cant30.
        CONDENSE vl_cant30 NO-GAPS.
      WHEN '000040'.
        ASSIGN COMPONENT 'TXTSPART' OF STRUCTURE <fs_wa> TO <fs_field>.
        CONCATENATE vl_cant40 '-' <fs_field> INTO vl_cant40.
        CONDENSE vl_cant40 NO-GAPS.
      WHEN OTHERS.
    ENDCASE.


    CASE vl_posnr.
      WHEN '000010'.
        ASSIGN COMPONENT 'ZLOTE10' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_lote10 = <fs_field>.
      WHEN '000020'.
        ASSIGN COMPONENT 'ZLOTE20' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_lote20 = <fs_field>.
      WHEN '000030'.
        ASSIGN COMPONENT 'ZLOTE30' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_lote30 = <fs_field>.
      WHEN '000040'.
        ASSIGN COMPONENT 'ZLOTE40' OF STRUCTURE <fs_wa> TO <fs_field>.
        vl_lote40 = <fs_field>.
      WHEN OTHERS.
    ENDCASE.

    """""""""""""""""""""""""""""""""""""""


  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM it_remision COMPARING zcliente.

  LOOP AT it_remision ASSIGNING <fs_wa>.
    ASSIGN COMPONENT 'ZCANT_MH10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_cant10.
    ASSIGN COMPONENT 'ZCANT_MH20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_cant20.
    ASSIGN COMPONENT 'ZCANT_MH30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_cant30.
    ASSIGN COMPONENT 'ZCANT_MH40' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_cant40.

    ASSIGN COMPONENT 'ZPESO_PROM10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pp10.
    ASSIGN COMPONENT 'ZPESO_PROM20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pp20.
    ASSIGN COMPONENT 'ZPESO_PROM30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pp30.
    ASSIGN COMPONENT 'ZPESO_PROM40' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pp40.

    ASSIGN COMPONENT 'ZPIGMENTO10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pigmento10.
    ASSIGN COMPONENT 'ZPIGMENTO20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_pigmento20.
    ASSIGN COMPONENT 'ZPIGMENTO30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> =  vl_pigmento30.
    ASSIGN COMPONENT 'ZPIGMENTO40' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> =  vl_pigmento40.

    ASSIGN COMPONENT 'ZZONA_CARGA10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_zona10.
    ASSIGN COMPONENT 'ZZONA_CARGA20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_zona20.
    ASSIGN COMPONENT 'ZZONA_CARGA30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_zona30.
    ASSIGN COMPONENT 'ZZONA_CARGA40' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_zona40.

    ASSIGN COMPONENT 'ZCASETA10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_caseta10.
    ASSIGN COMPONENT 'ZCASETA20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_caseta20.
    ASSIGN COMPONENT 'ZCASETA30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_caseta30.
    ASSIGN COMPONENT 'ZCASETA40' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_caseta40.

    ASSIGN COMPONENT 'ZLOTE10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_lote10.
    ASSIGN COMPONENT 'ZLOTE20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_lote20.
    ASSIGN COMPONENT 'ZLOTE30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_lote30.
    ASSIGN COMPONENT 'ZLOTE40' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_lote40.

    ASSIGN COMPONENT 'ZEDAD10' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_edad10.
    ASSIGN COMPONENT 'ZEDAD20' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_edad20.
    ASSIGN COMPONENT 'ZEDAD30' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_edad30.
    ASSIGN COMPONENT 'ZEDAD40' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field> = vl_edad40.
  ENDLOOP.

  """"""""buscamos los pesos en bascula
  UNASSIGN <fs_wa>.
  SELECT
    z2~ticket, z1~f_proc_ent, z1~h_proc_ent, CAST( z1~pbas_ent AS CHAR( 20 ) ) AS pbas_ent, z1~umpbas_ent,
    z1~placac,
    z1~f_proc_sal, z1~h_proc_sal, CAST( z1~pbas_sal AS CHAR( 20 ) ) AS pbas_sal, z1~umpbas_sal,
    CAST( z1~dif_pentpsal AS CHAR( 20 ) ) AS dif_pentpsal,z2~uname_ent, z2~uname_sal
    INTO TABLE @it_bascula
    FROM zbasculavtas_1 AS z1
    INNER JOIN zbasculavtas_2 AS z2 ON z2~vbeln = z1~vbeln
    WHERE z1~vbeln = @nast-objky.

  IF it_bascula IS NOT INITIAL.

    READ TABLE it_bascula ASSIGNING FIELD-SYMBOL(<wa_bas>) INDEX 1.
    ASSIGN COMPONENT 'DIF_PENTPSAL' OF STRUCTURE <wa_bas> TO FIELD-SYMBOL(<row>).
    IF <row> GT 0.
      gv_bascula = abap_true.
      vl_peso_prom = <row> / vl_total_aves.

      ASSIGN COMPONENT 'TOTAL_AVES' OF STRUCTURE <wa_bas> TO <row>.
      <row> = vl_total_aves.
      CONDENSE <row>  NO-GAPS.
      ASSIGN COMPONENT 'PESO_PROM' OF STRUCTURE <wa_bas> TO <row>.
      <row> = vl_peso_prom.
      CONDENSE <row>  NO-GAPS.

      "formatting
      ASSIGN COMPONENT 'PBAS_ENT' OF STRUCTURE <wa_bas> TO <row>.
      SPLIT <row> AT '.' INTO <row> vl_cantidad_mh.
      CONDENSE <row>  NO-GAPS.

      ASSIGN COMPONENT 'PBAS_SAL' OF STRUCTURE <wa_bas> TO <row>.
      SPLIT <row> AT '.' INTO <row> vl_cantidad_mh.
      CONDENSE <row>  NO-GAPS.

      ASSIGN COMPONENT 'DIF_PENTPSAL' OF STRUCTURE <wa_bas> TO <row>.
      SPLIT <row> AT '.' INTO <row> vl_cantidad_mh.
      CONDENSE <row>  NO-GAPS.

      """"""""""""""""222

    ELSE.
      gv_bascula = abap_false.
    ENDIF.

  ENDIF.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

ENDFORM.                    " get_data

*&---------------------------------------------------------------------*
*&      Form  protocol_update
*&---------------------------------------------------------------------*
FORM protocol_update .
  CHECK gv_screen_display = gc_false.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = sy-msgid
      msg_nr    = sy-msgno
      msg_ty    = sy-msgty
      msg_v1    = sy-msgv1
      msg_v2    = sy-msgv2
      msg_v3    = sy-msgv3
      msg_v4    = sy-msgv4
    EXCEPTIONS
      OTHERS    = 0.
ENDFORM.                    " protocol_update

*&---------------------------------------------------------------------*
*&      Form  print_data
*&---------------------------------------------------------------------*
FORM print_data.

  DATA: ls_outputparams TYPE sfpoutputparams,
        ls_docparams    TYPE sfpdocparams,
        lv_form         TYPE tdsfname,
        lv_fm_name      TYPE rs38l_fnam,
        ls_pdf_file     TYPE fpformoutput,
        lv_device       TYPE output_device,
        lv_failed       TYPE boole_d,
        lv_anzal        TYPE nast-anzal.   "Number of outputs (Orig. + Cop.)



  """"""""""""""""""""""""""""""""""""""""2
  lv_form = tnapr-sform.
  CLEAR : lv_fm_name."nast.

  """"""""""""""
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_form
*     VARIANT            = ' '
*     DIRECT_CALL        = ‘ ‘
    IMPORTING
      fm_name            = lv_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  IF NOT lv_fm_name IS INITIAL.

    CALL FUNCTION lv_fm_name
      EXPORTING
        gv_datos_bascula = gv_bascula
        gv_zm02          = vl_zm02
        gv_zm03          = vl_zm03
        gv_granja        = gv_nomgranja
      TABLES
        it_datos_cli     = it_remision
        it_datos_bas     = it_bascula
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        user_canceled    = 4
        OTHERS           = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDIF.

ENDFORM.                    " print_data
FORM get_textos USING td_id TYPE tdid
                      td_tdname TYPE tdobname
                      td_obj TYPE tdobject
                CHANGING p_valor TYPE string.

  DATA: it_lines TYPE STANDARD TABLE OF tline.


  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = td_id
      language                = 'S'
      name                    = td_tdname
      object                  = td_obj
    TABLES
      lines                   = it_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.


  READ TABLE it_lines INTO DATA(wa_lines) INDEX 1.
  CONCATENATE p_valor wa_lines-tdline INTO p_valor SEPARATED BY space.
  "p_valor = .
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_item_details
*&---------------------------------------------------------------------*
FORM get_item_details
  USING ut_vbdpr              TYPE tbl_vbdpr.

  DATA: ls_dd07v       TYPE dd07v,
        ls_text        TYPE tline,
        ls_item_detail TYPE invoice_s_prt_item_detail.

  FIELD-SYMBOLS:
    <ls_vbdpr>       TYPE vbdpr,
    <ls_item_detail> TYPE invoice_s_prt_item_detail.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname        = 'VBTYPL'
      text           = gc_true
      langu          = gv_language
    TABLES
      dd07v_tab      = gt_vbtyp_fix_values
    EXCEPTIONS
      wrong_textflag = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
    <gv_returncode> = sy-subrc.
    MESSAGE e000 WITH <gs_vbdkr>-vbeln
                 INTO gv_dummy.
    PERFORM protocol_update.
    RETURN.
  ENDIF.

  LOOP AT ut_vbdpr ASSIGNING <ls_vbdpr>.

    CLEAR ls_item_detail.

*   Clearing items (Verrechnungspositionen) will be printed only in
*   down payment requests
    IF ( <gs_vbdkr>-fktyp EQ 'P'  )
    OR    ( <gs_vbdkr>-fktyp NE 'P'
    AND     <ls_vbdpr>-fareg NA '45' ).

*--- Fill the VBDPR structure
      ls_item_detail-vbdpr = <ls_vbdpr>.

*--- Get the type text of the reference document
      IF NOT ls_item_detail-vbdpr-vbeln_vg2 IS INITIAL.
        READ TABLE gt_vbtyp_fix_values  INTO ls_dd07v
                  WITH KEY domvalue_l = ls_item_detail-vbdpr-vgtyp.

        IF sy-subrc IS INITIAL.
          ls_item_detail-vgtyp_text = ls_dd07v-ddtext.
        ENDIF.
      ENDIF.

*--- Get the item prices
      PERFORM get_item_prices              CHANGING ls_item_detail.
      IF <gv_returncode> <> 0.
        RETURN.
      ENDIF.

*--- Get configurations
      PERFORM get_item_characteristics     CHANGING ls_item_detail.
      IF <gv_returncode> <> 0.
        RETURN.
      ENDIF.

      IF bd_sd_bil IS BOUND.
*       Call BAdI concerning item details
        CALL BADI bd_sd_bil->get_item_details
          EXPORTING
            is_vbdkr       = <gs_vbdkr>
            is_nast        = nast
            iv_language    = gv_language
          CHANGING
            cs_item_detail = ls_item_detail.
      ENDIF.
      APPEND ls_item_detail TO gs_interface-item_detail.

    ELSEIF ( <gs_vbdkr>-fktyp NE 'P'
    AND      <ls_vbdpr>-fareg CA '45' ).
*--- Get downpayment data
      PERFORM get_item_downpayment         USING <ls_vbdpr>.
      IF <gv_returncode> <> 0.
        RETURN.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " get_item_details
*&---------------------------------------------------------------------*
*&      Form  get_item_prices
*&---------------------------------------------------------------------*
FORM get_item_prices
  CHANGING
        cs_item_detail  TYPE invoice_s_prt_item_detail.

  DATA: ls_komp  TYPE komp,
        ls_komvd TYPE komvd,
        lv_lines TYPE i.

  DATA: ro_print     TYPE REF TO cl_tm_invoice,
        lv_sim_flag  TYPE boolean,
        lt_tax_items TYPE komvd_t,
        ls_tax_items TYPE komvd,
        ls_komv      TYPE komv.

*--- Fill the communication structure
  IF gs_komk-knumv NE <gs_vbdkr>-knumv OR
     gs_komk-knumv IS INITIAL.
    CLEAR gs_komk.
    gs_komk-mandt     = sy-mandt.
    gs_komk-fkart     = <gs_vbdkr>-fkart.
    gs_komk-kalsm     = <gs_vbdkr>-kalsm.
    gs_komk-kappl     = gc_pr_kappl.
    gs_komk-waerk     = <gs_vbdkr>-waerk.
    gs_komk-knumv     = <gs_vbdkr>-knumv.
    gs_komk-knuma     = <gs_vbdkr>-knuma.
    gs_komk-vbtyp     = <gs_vbdkr>-vbtyp.
    gs_komk-land1     = <gs_vbdkr>-land1.
    gs_komk-vkorg     = <gs_vbdkr>-vkorg.
    gs_komk-vtweg     = <gs_vbdkr>-vtweg.
    gs_komk-spart     = <gs_vbdkr>-spart.
    gs_komk-bukrs     = <gs_vbdkr>-bukrs.
    gs_komk-hwaer     = <gs_vbdkr>-waers.
    gs_komk-prsdt     = <gs_vbdkr>-erdat.
    gs_komk-kurst     = <gs_vbdkr>-kurst.
    gs_komk-kurrf     = <gs_vbdkr>-kurrf.
    gs_komk-kurrf_dat = <gs_vbdkr>-kurrf_dat.
  ENDIF.
  ls_komp-kposn     = cs_item_detail-vbdpr-posnr.
  ls_komp-kursk     = cs_item_detail-vbdpr-kursk.
  ls_komp-kursk_dat = cs_item_detail-vbdpr-kursk_dat.
  IF cl_sd_doc_category_util=>is_any_retour( <gs_vbdkr>-vbtyp ).
    IF cs_item_detail-vbdpr-shkzg CA ' A'.
      ls_komp-shkzg = gc_true.
    ENDIF.
  ELSE.
    IF cs_item_detail-vbdpr-shkzg CA 'BX'.
      ls_komp-shkzg = gc_true.
    ENDIF.
  ENDIF.
  IF bd_sd_bil IS BOUND.
* BAdI
    CALL BADI bd_sd_bil->prepare_item_prices
      EXPORTING
        is_vbdkr       = <gs_vbdkr>
        iv_language    = gv_language
        is_item_detail = cs_item_detail
        is_nast        = nast
      CHANGING
        cs_komp        = ls_komp
        cs_komk        = gs_komk.
  ENDIF.

*--- Get the item prices
* ERP TM Integration
  IF cl_ops_switch_check=>aci_sfws_sc_erptms_ii( ) EQ abap_true.
    IF gv_price_print_mode EQ 'A'.
      CALL FUNCTION 'RV_PRICE_PRINT_ITEM'
        EXPORTING
          comm_head_i = gs_komk
          comm_item_i = ls_komp
          language    = gv_language
        IMPORTING
          comm_head_e = gs_komk
          comm_item_e = ls_komp
        TABLES
          tkomv       = gt_komv
          tkomvd      = cs_item_detail-conditions.
    ELSE.
      CALL FUNCTION 'RV_PRICE_PRINT_ITEM_BUFFER'
        EXPORTING
          comm_head_i = gs_komk
          comm_item_i = ls_komp
          language    = gv_language
        IMPORTING
          comm_head_e = gs_komk
          comm_item_e = ls_komp
        TABLES
          tkomv       = gt_komv
          tkomvd      = cs_item_detail-conditions.
    ENDIF.
  ELSE.
    IF gv_price_print_mode EQ 'A'.
      CALL FUNCTION 'RV_PRICE_PRINT_ITEM'
        EXPORTING
          comm_head_i = gs_komk
          comm_item_i = ls_komp
          language    = gv_language
        IMPORTING
          comm_head_e = gs_komk
          comm_item_e = ls_komp
        TABLES
          tkomv       = gt_komv
          tkomvd      = cs_item_detail-conditions.
    ELSE.
      CALL FUNCTION 'RV_PRICE_PRINT_ITEM_BUFFER'
        EXPORTING
          comm_head_i = gs_komk
          comm_item_i = ls_komp
          language    = gv_language
        IMPORTING
          comm_head_e = gs_komk
          comm_item_e = ls_komp
        TABLES
          tkomv       = gt_komv
          tkomvd      = cs_item_detail-conditions.
    ENDIF.
  ENDIF.

  IF NOT cs_item_detail-conditions IS INITIAL.
*   The conditions have always one initial line
    DESCRIBE TABLE cs_item_detail-conditions LINES lv_lines.
    IF lv_lines EQ 1.
      READ TABLE cs_item_detail-conditions INTO ls_komvd
                                           INDEX 1.
      IF NOT ls_komvd IS INITIAL.
        cs_item_detail-ex_conditions = gc_true.
      ENDIF.
    ELSE.
      cs_item_detail-ex_conditions = gc_true.
    ENDIF.
  ENDIF.

*--- Fill the tax code
  CALL FUNCTION 'SD_TAX_CODE_MAINTAIN'
    EXPORTING
      key_knumv           = gs_komk-knumv
      key_kposn           = ls_komp-kposn
      i_application       = ' '
      i_pricing_procedure = gs_komk-kalsm
    TABLES
      xkomv               = gt_komv.

ENDFORM.                    " get_item_prices
*&---------------------------------------------------------------------*
*&      Form  get_head_details
*&---------------------------------------------------------------------*
FORM get_head_details.

*--- Get Sales Org detail
  PERFORM get_head_tvko.
  CHECK <gv_returncode> IS INITIAL.

*--- Get Campany Code texts in case of cross company
  PERFORM get_head_comp_code_texts.
  CHECK <gv_returncode> IS INITIAL.

*--- Get header prices
  PERFORM get_head_prices.
  CHECK <gv_returncode> IS INITIAL.

*--- Get dynamic texts
  PERFORM get_head_text.
  CHECK <gv_returncode> IS INITIAL.

*--- Get sending country
*  perform get_head_sending_country.
*  check <gv_returncode> is initial.

*--- Check repeat printout
  PERFORM get_head_repeat_flag.
  CHECK <gv_returncode> IS INITIAL.

*--- Get Payment_split
  PERFORM get_payment_split.
  CHECK <gv_returncode> IS INITIAL.

*--- Get Downpayment
  PERFORM get_head_downpayment.
  CHECK <gv_returncode> IS INITIAL.

*--- Get Payment Cards
  PERFORM get_head_paymentcards.
  CHECK <gv_returncode> IS INITIAL.

*--- SD SEPA: Get Mandate details
  INCLUDE sd_sepa_faktura_004_pdf.
*--- SD SEPA

  IF bd_sd_bil IS BOUND.
* BAdI
    CALL BADI bd_sd_bil->get_head_details
      EXPORTING
        iv_language  = gv_language
        is_nast      = nast
      CHANGING
        cs_interface = gs_interface.
  ENDIF.
ENDFORM.                    " get_head_details
*&---------------------------------------------------------------------*
*&      Form  get_head_repeat_flag
*&---------------------------------------------------------------------*
FORM get_head_repeat_flag.

  DATA: lv_nast TYPE nast.

  SELECT SINGLE * INTO lv_nast FROM nast
                                WHERE kappl = gs_nast-kappl "#EC *
                                AND   objky = gs_nast-objky
                                AND   kschl = gs_nast-kschl
                                AND   spras = gs_nast-spras
                                AND   parnr = gs_nast-parnr
                                AND   parvw = gs_nast-parvw
                                AND   nacha BETWEEN '1' AND '5'
                                AND   vstat = '1'.
  IF sy-subrc IS INITIAL.
    gs_interface-head_detail-repeat = gc_true.
  ENDIF.

ENDFORM.                    " get_head_repeat_flag
*&---------------------------------------------------------------------*
*&      Form  get_head_sending_country
*&---------------------------------------------------------------------*
FORM get_head_sending_country.

  DATA: ls_address    TYPE sdpartner_address.

  CHECK <gs_vbdkr>-sland IS INITIAL.

  CALL FUNCTION 'SD_ADDRESS_GET'
    EXPORTING
      fif_address_number      = gs_interface-head_detail-tvko-adrnr
      fif_address_type        = '1'
    IMPORTING
      fes_sdpartner_address   = ls_address
    EXCEPTIONS
      address_not_found       = 1
      address_type_not_exists = 2
      no_person_number        = 3
      OTHERS                  = 4.

  IF sy-subrc IS INITIAL.
    <gs_vbdkr>-sland = ls_address-country.
  ELSE.
    <gv_returncode> = sy-subrc.
    MESSAGE e004 WITH <gs_vbdkr>-vbeln
                      gs_interface-head_detail-tvko-vkorg
                 INTO gv_dummy.
    PERFORM protocol_update.
    RETURN.
  ENDIF.

ENDFORM.                    " get_head_sending_country

*&---------------------------------------------------------------------*
*&      Form  get_head_text
*&---------------------------------------------------------------------*
FORM get_head_text.

  DATA: ls_dd07v       TYPE dd07v.

*--- VBDKR-VBTYP
  READ TABLE gt_vbtyp_fix_values  INTO ls_dd07v
             WITH KEY domvalue_l = <gs_vbdkr>-vbtyp
 .

  IF sy-subrc IS INITIAL.
    gs_interface-head_detail-vbtyp_text = ls_dd07v-ddtext.
  ENDIF.

*--- VBDKR-VGTYP
  IF NOT <gs_vbdkr>-vbeln_vg2 IS INITIAL.
    READ TABLE gt_vbtyp_fix_values  INTO ls_dd07v
        WITH KEY domvalue_l = <gs_vbdkr>-vgtyp.

    IF sy-subrc IS INITIAL.
      gs_interface-head_detail-vgtyp_text = ls_dd07v-ddtext.
    ENDIF.
  ENDIF.

*--- Header and Footer Text
  IF gs_interface-head_detail-vbdkr-vbtyp = if_sd_doc_category=>intercompany_invoice OR
     gs_interface-head_detail-vbdkr-vbtyp = if_sd_doc_category=>intercompany_credit_memo.
    gs_interface-head_detail-head_tdname   =
              gs_interface-head_detail-t001g-txtko.
    gs_interface-head_detail-head_tdobject = 'TEXT'.
    gs_interface-head_detail-head_tdid     = 'ADRS'.

    gs_interface-head_detail-foot_tdname   =
              gs_interface-head_detail-t001g-txtfu.
    gs_interface-head_detail-foot_tdobject = 'TEXT'.
    gs_interface-head_detail-foot_tdid     = 'ADRS'.
  ELSE.
    gs_interface-head_detail-head_tdname   =
              gs_interface-head_detail-tvko-txnam_kop.
    gs_interface-head_detail-head_tdobject = 'TEXT'.
    gs_interface-head_detail-head_tdid     = 'ADRS'.

    gs_interface-head_detail-foot_tdname   =
              gs_interface-head_detail-tvko-txnam_fus.
    gs_interface-head_detail-foot_tdobject = 'TEXT'.
    gs_interface-head_detail-foot_tdid     = 'ADRS'.
  ENDIF.

ENDFORM.                    " get_head_text
*&---------------------------------------------------------------------*
*&      Form  get_item_characteristics
*&---------------------------------------------------------------------*
FORM get_item_characteristics
  CHANGING
        cs_item_detail TYPE invoice_s_prt_item_detail.

  DATA: lt_conf TYPE TABLE OF conf_out,
        ls_conf TYPE conf_out,
        lt_cabn TYPE TABLE OF cabn,
        ls_cabn TYPE cabn.

  RANGES: lr_cabn FOR ls_cabn-atinn.

* Check appropriate config exists
  CHECK NOT cs_item_detail-vbdpr-cuobj IS INITIAL AND
            cs_item_detail-vbdpr-attyp NE '02'.

  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      instance      = cs_item_detail-vbdpr-cuobj
      language      = gv_language
      print_sales   = gc_true
    TABLES
      configuration = lt_conf
    EXCEPTIONS
      OTHERS        = 4.

  IF sy-subrc <> 0.
    <gv_returncode> = sy-subrc.
    MESSAGE e001 WITH <gs_vbdkr>-vbeln
                 INTO gv_dummy.
    PERFORM protocol_update.
    RETURN.
  ENDIF.

  IF NOT lt_conf IS INITIAL.
    LOOP AT lt_conf INTO ls_conf.
      lr_cabn-option = gc_equal.
      lr_cabn-sign   = gc_include.
      lr_cabn-low    = ls_conf-atinn.
      COLLECT lr_cabn.
    ENDLOOP.

    CALL FUNCTION 'CLSE_SELECT_CABN'
      TABLES
        in_cabn        = lr_cabn
        t_cabn         = lt_cabn
      EXCEPTIONS
        no_entry_found = 1
        OTHERS         = 2.

    IF sy-subrc <> 0.
      <gv_returncode> = sy-subrc.
      MESSAGE e001 WITH <gs_vbdkr>-vbeln
                   INTO gv_dummy.
      PERFORM protocol_update.
      RETURN.
    ENDIF.

    SORT lt_cabn BY atinn.
    LOOP AT lt_conf INTO ls_conf.
      READ TABLE lt_cabn INTO ls_cabn
                         WITH KEY atinn = ls_conf-atinn
                         BINARY SEARCH.
      IF sy-subrc <> 0 OR
         ( ls_cabn-attab = 'SDCOM' AND ls_cabn-atfel = 'VKOND' )
         OR  ls_cabn-attab = 'VCSD_UPDATE'.
        DELETE lt_conf.
      ENDIF.
    ENDLOOP.

    cs_item_detail-configuration = lt_conf.

    IF NOT cs_item_detail-configuration IS INITIAL.
      cs_item_detail-ex_configuration = gc_true.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_item_characteristics
*&---------------------------------------------------------------------*
*&      Form  GET_head_PRICES
*&---------------------------------------------------------------------*
FORM get_head_prices.

  DATA: ro_print      TYPE REF TO cl_tm_invoice,
        lv_sim_flag   TYPE boolean,
        lt_tax_header TYPE komvd_t.

* BAdI
  IF bd_sd_bil IS BOUND.
    CALL BADI bd_sd_bil->prepare_head_prices
      EXPORTING
        is_interface = gs_interface
        iv_language  = gv_language
        is_nast      = nast
      CHANGING
        cs_komk      = gs_komk.
  ENDIF.

* ERP TM Integration
  IF cl_ops_switch_check=>aci_sfws_sc_erptms_ii( ) EQ abap_true.
    IF gv_price_print_mode EQ 'A'.
      CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
        EXPORTING
          comm_head_i = gs_komk
          language    = gv_language
        IMPORTING
          comm_head_e = gs_komk
        TABLES
          tkomv       = gt_komv
          tkomvd      = gs_interface-head_detail-conditions.
    ELSE.
      CALL FUNCTION 'RV_PRICE_PRINT_HEAD_BUFFER'
        EXPORTING
          comm_head_i = gs_komk
          language    = gv_language
        IMPORTING
          comm_head_e = gs_komk
        TABLES
          tkomv       = gt_komv
          tkomvd      = gs_interface-head_detail-conditions.
    ENDIF.

  ELSE.
    IF gv_price_print_mode EQ 'A'.
      CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
        EXPORTING
          comm_head_i = gs_komk
          language    = gv_language
        IMPORTING
          comm_head_e = gs_komk
        TABLES
          tkomv       = gt_komv
          tkomvd      = gs_interface-head_detail-conditions.
    ELSE.
      CALL FUNCTION 'RV_PRICE_PRINT_HEAD_BUFFER'
        EXPORTING
          comm_head_i = gs_komk
          language    = gv_language
        IMPORTING
          comm_head_e = gs_komk
        TABLES
          tkomv       = gt_komv
          tkomvd      = gs_interface-head_detail-conditions.
    ENDIF.
  ENDIF.

* Fill gross value
  gs_interface-head_detail-doc_currency = gs_komk-waerk.
  IF gs_interface-head_detail-gross_value IS INITIAL.
    gs_interface-head_detail-gross_value  = gs_komk-fkwrt.
  ENDIF.
  IF gs_interface-head_detail-supos IS INITIAL.
    gs_interface-head_detail-supos  = gs_komk-supos.
  ENDIF.
  IF NOT gs_interface-head_detail-conditions IS INITIAL.
    gs_interface-head_detail-ex_conditions = gc_true.
  ENDIF.

ENDFORM.                    " GET_head_PRICES
*&---------------------------------------------------------------------*
*&      Form  get_head_tvko
*&---------------------------------------------------------------------*
FORM get_head_tvko.

  CALL FUNCTION 'TVKO_SINGLE_READ'
    EXPORTING
      vkorg     = <gs_vbdkr>-vkorg
    IMPORTING
      wtvko     = gs_interface-head_detail-tvko
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  IF sy-subrc <> 0.
    <gv_returncode> = sy-subrc.
    MESSAGE e003 WITH <gs_vbdkr>-vbeln
                      <gs_vbdkr>-vkorg
                 INTO gv_dummy.
    PERFORM protocol_update.
    RETURN.
  ENDIF.

ENDFORM.                    " get_tvko
*&---------------------------------------------------------------------*
*&      Form  get_head_comp_code_texts
*&---------------------------------------------------------------------*
FORM get_head_comp_code_texts.

  STATICS ss_t001g        TYPE t001g.

  CHECK <gs_vbdkr>-vbtyp = if_sd_doc_category=>intercompany_invoice OR
        <gs_vbdkr>-vbtyp = if_sd_doc_category=>intercompany_credit_memo.

  IF ss_t001g-bukrs NE <gs_vbdkr>-bukrs.
    SELECT SINGLE * FROM t001g INTO ss_t001g
                                 WHERE bukrs EQ <gs_vbdkr>-bukrs
                                 AND   programm EQ sy-repid
                                 AND   txtid EQ 'SD'.
    IF sy-subrc <> 0.
      <gv_returncode> = sy-subrc.
      MESSAGE e000 WITH <gs_vbdkr>-vbeln
                   INTO gv_dummy.
      PERFORM protocol_update.
      RETURN.
    ENDIF.
  ENDIF.

  gs_interface-head_detail-t001g = ss_t001g.

ENDFORM.                                                    " get_t001g
*&---------------------------------------------------------------------*
*&      Form  send_data
*&---------------------------------------------------------------------*
FORM send_data
  USING uv_device           TYPE output_device
        us_pdf_file         TYPE fpformoutput.

  DATA: lv_date(14)       TYPE c,
        lv_mail_subject   TYPE so_obj_des,
        lt_mail_text      TYPE bcsy_text,
        lv_send_to_all    TYPE os_boolean,
        lt_adsmtp         TYPE TABLE OF adsmtp,
        ls_adsmtp         TYPE adsmtp,
        lt_adfax          TYPE TABLE OF adfax,
        ls_adfax          TYPE adfax,
        ls_address        TYPE sdprt_addr_s,
        lv_vbeln          TYPE vbeln,

*output control badi change

        ls_enh_flag       TYPE char1,
        ls_email_rcp      TYPE smtp_sd_sls_addr_s,
        ls_email_sendr    TYPE smtp_sd_sls_addr_s,
        lo_cl_bcs         TYPE REF TO cl_bcs,
        ls_file_attribs   TYPE file_attributes_s,
        lo_badi_mapper    TYPE REF TO badi_sd_obj_mapper,
        lt_email_addr     TYPE adr6_tt,
        lo_badi_sls_email TYPE REF TO badi_sd_sls_email.

  CHECK gv_screen_display NE gc_true.

*--- Determine the subject text
  lv_mail_subject = gs_nast-tdcovtitle.
  IF lv_mail_subject = space.
    WRITE <gs_vbdkr>-fkdat TO lv_date.
    WRITE <gs_vbdkr>-vbeln TO lv_vbeln NO-ZERO.
* Type, number, date
    CONCATENATE gs_interface-head_detail-vbtyp_text
                lv_vbeln
                lv_date
           INTO lv_mail_subject
           SEPARATED BY space.
  ENDIF.

  CASE uv_device.

    WHEN gc_device-email.
*o/p contrl badi enhancement
      TRY.

          GET BADI lo_badi_sls_email
            FILTERS
              sd_email_progs = if_sd_email_process_constant=>invoice_print01.

          IF lo_badi_sls_email IS BOUND.

            IF lo_badi_sls_email->imps IS NOT INITIAL.

              ls_enh_flag = abap_true.

            ENDIF.
          ENDIF.
*Catch not implemented exception or multiple implementation
        CATCH cx_badi_not_implemented.
          ls_enh_flag = abap_false.
          CLEAR lo_badi_sls_email.
      ENDTRY.
*end of o/p contrl badi enhancement


*--- Get the e-mail-text
      PERFORM get_mail_body CHANGING lt_mail_text.
      CHECK <gv_returncode> IS INITIAL.

*--- Get the e-mail address of the recipient
      ls_address-recip_email_addr = gs_nast-email_addr.

*--- Get the e-mail address of the sender
*     Try to get the e-mail of the sales org.
*     Otherwise takes the user's e-mail
      CALL FUNCTION 'ADDR_COMM_GET'
        EXPORTING
          address_number    = gs_interface-head_detail-tvko-adrnr
          language          = gv_language
          table_type        = 'ADSMTP'
        TABLES
          comm_table        = lt_adsmtp
        EXCEPTIONS
          parameter_error   = 1
          address_not_exist = 2
          internal_error    = 3
          OTHERS            = 4.

      IF sy-subrc <> 0.
        <gv_returncode> = sy-subrc.
        PERFORM protocol_update.
        RETURN.
      ENDIF.

      READ TABLE lt_adsmtp INTO ls_adsmtp
           WITH KEY flgdefault = gc_true.

      IF sy-subrc IS INITIAL.
        ls_address-sender_email_addr = ls_adsmtp-smtp_addr.
      ENDIF.

    WHEN gc_device-fax.

*--- Get the e-mail address of the recipient
      ls_address-recip_fax_country = gs_nast-tland.
      ls_address-recip_fax_number = gs_nast-telfx(30).

*--- Get the fax address of the sender
*     Try to get the fax address of the sales org.
*     Otherwise takes the user's
      CALL FUNCTION 'ADDR_COMM_GET'
        EXPORTING
          address_number    = gs_interface-head_detail-tvko-adrnr
          language          = gv_language
          table_type        = 'ADFAX'
        TABLES
          comm_table        = lt_adfax
        EXCEPTIONS
          parameter_error   = 1
          address_not_exist = 2
          internal_error    = 3
          OTHERS            = 4.

      IF sy-subrc <> 0.
        <gv_returncode> = sy-subrc.
        PERFORM protocol_update.
        RETURN.
      ENDIF.

      READ TABLE lt_adfax INTO ls_adfax
           WITH KEY flgdefault = gc_true.

      IF sy-subrc IS INITIAL.
        ls_address-sender_fax_country = ls_adfax-country.
        ls_address-sender_fax_number  = ls_adfax-fax_number.
      ENDIF.

  ENDCASE.

* CC217581: mail subject and body text is retrieved
  INCLUDE send_data_get_email_content IF FOUND.

*   o/p control badi call

  IF ls_enh_flag EQ abap_true.

    IF lo_badi_sls_email IS BOUND.

      TRY.

*   get Badi handle for obj mapper
*   filters  any filters implement here
          GET BADI lo_badi_mapper
            FILTERS
              sd_process_filter = if_sd_email_process_constant=>invoice_print01.

*  Catch not implemented exception or multiple implementation
        CATCH cx_badi_not_implemented.
          CLEAR lo_badi_mapper.
      ENDTRY.

      IF lo_badi_mapper IS BOUND.

        IF lo_badi_mapper->imps IS NOT INITIAL.

          CALL BADI lo_badi_mapper->set_sd_inv_to_generic
            EXPORTING
              is_inv_details = gs_interface.

*    Call BAdI for modify email details
          CALL BADI lo_badi_sls_email->set_mapper
            EXPORTING
              io_mapper = lo_badi_mapper->imp.

          IF sy-subrc <> 0.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
      ls_email_sendr-email_addr = ls_address-sender_email_addr.
*    move default rcp address to badi impl
      ls_email_rcp-email_addr = ls_address-recip_email_addr.
      INCLUDE send_data_remove_default IF FOUND.
      CALL BADI lo_badi_sls_email->modify_email
        EXPORTING
          iv_language      = gv_language
          is_email_rcp     = ls_email_rcp
          is_email_sendr   = ls_email_sendr
        CHANGING
          io_cl_bcs        = lo_cl_bcs
        EXCEPTIONS
          exc_send_req_bcs = 1
          exc_address_bcs  = 2
          OTHERS           = 3.
      IF sy-subrc <> 0.
        MESSAGE e000 WITH <gs_vbdkr>-vbeln
                   INTO gv_dummy.
        PERFORM protocol_update.
        <gv_returncode> = 99.
        RETURN.
      ENDIF.
      INCLUDE send_data_add_email_badi IF FOUND.
*   add Exceptions for process document method and check response.
      ls_file_attribs-pdf_file = us_pdf_file.
      CALL BADI lo_badi_sls_email->process_document
        EXPORTING
          iv_language      = gv_language
          iv_text          = lt_mail_text
          iv_subject       = lv_mail_subject
          is_file_attribs  = ls_file_attribs
        CHANGING
          io_cl_bcs        = lo_cl_bcs
        EXCEPTIONS
          exc_send_req_bcs = 1
          exc_document_bcs = 2
          OTHERS           = 3.

      IF sy-subrc <> 0.
        MESSAGE e000 WITH <gs_vbdkr>-vbeln
                   INTO gv_dummy.
        PERFORM protocol_update.
        <gv_returncode> = 99.
        RETURN.

      ENDIF.

*   Send Document
      CALL BADI lo_badi_sls_email->send_document
        EXPORTING
          io_cl_bcs        = lo_cl_bcs
        CHANGING
          ev_send_to_all   = lv_send_to_all
        EXCEPTIONS
          exc_send_req_bcs = 1
          OTHERS           = 2.

      IF sy-subrc <> 0.
        MESSAGE e000 WITH <gs_vbdkr>-vbeln
                      INTO gv_dummy.
        PERFORM protocol_update.
        <gv_returncode> = 99.
        RETURN.
      ENDIF.

      IF lv_send_to_all = gc_true.
*     Write success message into log
        MESSAGE i022(so)
                INTO gv_dummy.
        PERFORM protocol_update.
      ELSE.
*     Write fail message into log
        MESSAGE i023(so)
                WITH <gs_vbdkr>-vbeln
                INTO gv_dummy.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.

*  end of o/p contrl badi call. continue old way in else.
  ELSE.

    CALL FUNCTION 'SD_PDF_SEND_DATA'
      EXPORTING
        iv_device        = uv_device
        iv_email_subject = lv_mail_subject
        it_email_text    = lt_mail_text
        is_main_data     = us_pdf_file
        iv_language      = gv_language
        is_address       = ls_address
        iv_nast          = nast
      IMPORTING
        ev_send_to_all   = lv_send_to_all
      EXCEPTIONS
        exc_document     = 1
        exc_send_request = 2
        exc_address      = 3
        OTHERS           = 4.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH <gs_vbdkr>-vbeln
                   INTO gv_dummy.
      PERFORM protocol_update.
      <gv_returncode> = 99.
      RETURN.
    ENDIF.

    IF lv_send_to_all = gc_true.
      MESSAGE i022(so) INTO gv_dummy.
      PERFORM protocol_update.
    ELSE.
      MESSAGE i023(so) WITH <gs_vbdkr>-vbeln
              INTO gv_dummy.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.
ENDFORM.                    " send_data
*&---------------------------------------------------------------------*
*&      Form  get_output_params
*&---------------------------------------------------------------------*
FORM get_output_params
   CHANGING
        cs_outputparams  TYPE sfpoutputparams
        cs_docparams     TYPE sfpdocparams
        cv_device        TYPE output_device.

  DATA: lv_comm_type   TYPE ad_comm,
        ls_comm_values TYPE szadr_comm_values.

  CASE gs_nast-nacha.
    WHEN gc_nacha-external_send.
      DATA: lv_email_enabled TYPE abap_bool.
      INCLUDE get_output_params_check_emails IF FOUND.
      IF lv_email_enabled NE abap_true.
        IF NOT gs_nast-tcode IS INITIAL.
          CALL FUNCTION 'ADDR_GET_NEXT_COMM_TYPE'
            EXPORTING
              strategy           = gs_nast-tcode
              address_type       = <gs_vbdkr>-address_type
              address_number     = <gs_vbdkr>-adrnr
              person_number      = <gs_vbdkr>-adrnp
            IMPORTING
              comm_type          = lv_comm_type
              comm_values        = ls_comm_values
            EXCEPTIONS
              address_not_exist  = 1
              person_not_exist   = 2
              no_comm_type_found = 3
              internal_error     = 4
              parameter_error    = 5
              OTHERS             = 6.

          IF sy-subrc <> 0.
            <gv_returncode> = sy-subrc.
            PERFORM protocol_update.
            RETURN.
          ENDIF.

          CASE lv_comm_type.
            WHEN 'INT'.  "e-mail
              cs_outputparams-getpdf = gc_true.
              cv_device              = gc_device-email.
              gs_nast-email_addr     = ls_comm_values-adsmtp-smtp_addr.
            WHEN 'FAX'.
              cs_outputparams-getpdf = gc_true.
              cv_device              = gc_device-fax.
              gs_nast-telfx          = ls_comm_values-adfax-fax_number.
              gs_nast-tland          = ls_comm_values-adfax-country.
            WHEN 'LET'.   "Printer
              cv_device              = gc_device-printer.
          ENDCASE.
        ELSE.
          cv_device              = gc_device-printer.
        ENDIF.
      ENDIF.
    WHEN gc_nacha-printer.
      cv_device              = gc_device-printer.
    WHEN gc_nacha-fax.
      cs_outputparams-getpdf = gc_true.
      cv_device              = gc_device-fax.
  ENDCASE.

* The original document should be printed only once
  IF NOT gv_screen_display IS INITIAL
  AND gs_interface-head_detail-repeat EQ gc_false.
    cs_outputparams-noprint   = gc_true.
    cs_outputparams-nopributt = gc_true.
    cs_outputparams-noarchive = gc_true.
  ENDIF.
  IF gv_screen_display     = 'X'.
    cs_outputparams-getpdf  = gc_false.
    cs_outputparams-preview = gc_true.
  ELSEIF gv_screen_display = 'W'. "Web dynpro
    cs_outputparams-getpdf  = gc_true.
    cv_device               = gc_device-web_dynpro.
  ENDIF.
  cs_outputparams-nodialog  = gc_true.
  cs_outputparams-dest      = gs_nast-ldest.
  cs_outputparams-copies    = gs_nast-anzal.
  cs_outputparams-dataset   = gs_nast-dsnam.
  cs_outputparams-suffix1   = gs_nast-dsuf1.
  cs_outputparams-suffix2   = gs_nast-dsuf2.
  cs_outputparams-cover     = gs_nast-tdocover.
  cs_outputparams-covtitle  = gs_nast-tdcovtitle.
  cs_outputparams-authority = gs_nast-tdautority.
  cs_outputparams-receiver  = gs_nast-tdreceiver.
  cs_outputparams-division  = gs_nast-tddivision.
  cs_outputparams-arcmode   = gs_nast-tdarmod.
  cs_outputparams-reqimm    = gs_nast-dimme.
  cs_outputparams-reqdel    = gs_nast-delet.
  cs_outputparams-senddate  = gs_nast-vsdat.
  cs_outputparams-sendtime  = gs_nast-vsura.

*--- Set language and default language
  cs_docparams-langu     = gv_language.
  cs_docparams-replangu1 = <gs_vbdkr>-spras_vko.
  cs_docparams-replangu2 = gc_english.
  cs_docparams-country   = <gs_vbdkr>-land1.

* Archiving
  APPEND toa_dara TO cs_docparams-daratab.

ENDFORM.                    " get_output_params
*&---------------------------------------------------------------------*
*&      Form  get_mail_body
*&---------------------------------------------------------------------*
FORM get_mail_body
  CHANGING
        ct_mail_text    TYPE bcsy_text.

  DATA: ls_options TYPE itcpo,
        lt_lines   TYPE TABLE OF tline,
        lt_otfdata TYPE TABLE OF itcoo.

  CHECK NOT tnapr-fonam IS INITIAL.

  ls_options-tdgetotf = gc_true.
  ls_options-tddest   = gs_nast-ldest.
  ls_options-tdprogram = tnapr-pgnam.

  vbdkr = <gs_vbdkr>.
  komk  = gs_komk.
  tvko  = gs_interface-head_detail-tvko.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      dialog                      = ' '
      form                        = tnapr-fonam
      language                    = gv_language
      options                     = ls_options
    EXCEPTIONS
      canceled                    = 1
      device                      = 2
      form                        = 3
      options                     = 4
      unclosed                    = 5
      mail_options                = 6
      archive_error               = 7
      invalid_fax_number          = 8
      more_params_needed_in_batch = 9
      spool_error                 = 10
      codepage                    = 11
      OTHERS                      = 12.

  IF sy-subrc <> 0.
    <gv_returncode> = sy-subrc.
    PERFORM protocol_update.
    RETURN.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                  = 'MAIL_BODY'
    EXCEPTIONS
      element                  = 1
      function                 = 2
      type                     = 3
      unopened                 = 4
      unstarted                = 5
      window                   = 6
      bad_pageformat_for_print = 7
      spool_error              = 8
      codepage                 = 9
      OTHERS                   = 10.

  IF sy-subrc <> 0.
    <gv_returncode> = sy-subrc.
    PERFORM protocol_update.
    RETURN.
  ENDIF.

  CALL FUNCTION 'CLOSE_FORM'
    TABLES
      otfdata                  = lt_otfdata
    EXCEPTIONS
      unopened                 = 1
      bad_pageformat_for_print = 2
      send_error               = 3
      spool_error              = 4
      codepage                 = 5
      OTHERS                   = 6.

  IF sy-subrc <> 0.
    <gv_returncode> = sy-subrc.
    PERFORM protocol_update.
    RETURN.
  ENDIF.

  CALL FUNCTION 'CONVERT_OTF'
    TABLES
      otf                   = lt_otfdata
      lines                 = lt_lines
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      err_bad_otf           = 4
      OTHERS                = 5.

  IF sy-subrc <> 0.
    <gv_returncode> = sy-subrc.
    PERFORM protocol_update.
    RETURN.
  ENDIF.

  CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
    EXPORTING
      language    = gv_language
    TABLES
      itf_text    = lt_lines
      text_stream = ct_mail_text.

ENDFORM.                    " get_mail_body
*&---------------------------------------------------------------------*
*&      Form  get_item_downpayment
*&---------------------------------------------------------------------*
FORM get_item_downpayment
  USING us_vbdpr        TYPE vbdpr.

  DATA: lv_xfilkd       TYPE xfilkd_vf,
        ls_sdaccdpc_doc TYPE vbeln_posnr_s.

  CHECK <gs_vbdkr>-fktyp NE 'P'.
  CHECK us_vbdpr-fareg CA '45'.

* Can there be a head office?
  CASE <gs_vbdkr>-xfilkd.
*   Ordering party
    WHEN 'A'.
      IF <gs_vbdkr>-knkli IS INITIAL OR
         <gs_vbdkr>-knkli EQ <gs_vbdkr>-kunag.
        lv_xfilkd = <gs_vbdkr>-xfilkd.
      ENDIF.
*   Payer
    WHEN 'B'.
      lv_xfilkd = <gs_vbdkr>-xfilkd.
  ENDCASE.

* Remember the headno and itemno
  IF NOT us_vbdpr-vbelv IS INITIAL.
    ls_sdaccdpc_doc-vbeln = us_vbdpr-vbelv.
    ls_sdaccdpc_doc-posnr = us_vbdpr-posnv.
  ELSE.
    ls_sdaccdpc_doc-vbeln = us_vbdpr-vbeln_vauf.
    ls_sdaccdpc_doc-posnr = us_vbdpr-posnr_vauf.
  ENDIF.
  APPEND ls_sdaccdpc_doc TO gt_sdaccdpc_doc.


  CALL FUNCTION 'SD_DOWNPAYMENT_READ'
    EXPORTING
      i_waerk           = <gs_vbdkr>-waerk
      i_bukrs           = <gs_vbdkr>-bukrs
      i_kunnr           = <gs_vbdkr>-kunrg
      i_vbel2           = ls_sdaccdpc_doc-vbeln
      i_vbeln           = <gs_vbdkr>-vbeln
      i_sfakn           = <gs_vbdkr>-sfakn
      i_xfilkd          = lv_xfilkd
      i_gesanz          = gc_true
    TABLES
      t_sdaccdpc        = gt_sdaccdpc
    CHANGING
      c_downpay_refresh = gv_downpay_refresh
    EXCEPTIONS
      no_downpayments   = 1
      in_downpayments   = 2
      OTHERS            = 3.

ENDFORM.                    " get_item_downpayment
*&---------------------------------------------------------------------*
*&      Form  get_head_downpayment
*&---------------------------------------------------------------------*
FORM get_head_downpayment .

  DATA: ls_sdaccdpc TYPE sdaccdpc.

  SORT gt_sdaccdpc_doc BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM gt_sdaccdpc_doc.

  LOOP AT gt_sdaccdpc INTO ls_sdaccdpc.
    READ TABLE gt_sdaccdpc_doc WITH KEY vbeln = ls_sdaccdpc-vgbel
                                        posnr = ls_sdaccdpc-vgpos
                                        BINARY SEARCH
                                        TRANSPORTING NO FIELDS.
    IF NOT sy-subrc IS INITIAL.
      DELETE gt_sdaccdpc.
    ENDIF.

  ENDLOOP.

  IF NOT <gs_vbdkr>-dpval IS INITIAL.
    <gs_vbdkr>-dpend = gs_interface-head_detail-gross_value.
    SUBTRACT <gs_vbdkr>-dpval FROM <gs_vbdkr>-dpend.
    <gs_vbdkr>-dpmws_end = <gs_vbdkr>-mwsbk - <gs_vbdkr>-dpmws.
  ENDIF.

  gs_interface-head_detail-down_payments = gt_sdaccdpc.

  IF NOT gs_interface-head_detail-down_payments IS INITIAL.
    gs_interface-head_detail-ex_down_payments = gc_true.
  ENDIF.

ENDFORM.                    " get_head_downpayment
*&---------------------------------------------------------------------*
*&      Form  initialize_data
*&---------------------------------------------------------------------*
FORM initialize_data .

  CLEAR: gs_interface,
         gv_screen_display,
         gv_price_print_mode,
         gt_komv,
         gs_komk,
         gt_vbtyp_fix_values,
         gv_language,
         gv_dummy,
         gt_sdaccdpc_doc,
         gt_sdaccdpc,
         gs_nast,
         gv_downpay_refresh,
         <gv_returncode>.

* BAdI
  IF bd_sd_bil IS BOUND.
    CALL BADI bd_sd_bil->initialize_data.
  ENDIF.
ENDFORM.                    " initialize_data
*&---------------------------------------------------------------------*
*&      Form  get_head_paymentcards
*&---------------------------------------------------------------------*
FORM get_head_paymentcards.

  DATA: lt_fplt          TYPE TABLE OF fpltvb,
        ls_fplt          TYPE fpltvb,
        ls_payment_cards TYPE bil_s_prt_payment_cards.

  STATICS:
        ss_tvcint        TYPE tvcint.

  CHECK NOT <gs_vbdkr>-rplnr IS INITIAL.
* Read from the Database
  CALL FUNCTION 'BILLING_SCHEDULE_READ'
    EXPORTING
      fplnr         = <gs_vbdkr>-rplnr
    TABLES
      zfplt         = lt_fplt
    EXCEPTIONS
      error_message = 0
      OTHERS        = 0.

* Loop at Cards
  LOOP AT lt_fplt INTO ls_fplt.
    ls_payment_cards = ls_fplt.
*   Get text
    IF ls_fplt-ccins NE ss_tvcint-ccins.
      SELECT SINGLE * FROM tvcint INTO ss_tvcint
             WHERE spras = gv_language
             AND   ccins = ls_fplt-ccins.
      IF sy-subrc =  0.
        ls_payment_cards-description = ss_tvcint-vtext.
      ELSE.
        ls_payment_cards-description = ls_fplt-ccins.
      ENDIF.
    ELSE.
      ls_payment_cards-description = ss_tvcint-vtext.
    ENDIF.
    APPEND ls_payment_cards TO gs_interface-head_detail-payment_cards.

    ADD ls_fplt-fakwr TO <gs_vbdkr>-ccval.
  ENDLOOP.

  IF NOT gs_interface-head_detail-payment_cards IS INITIAL.
    gs_interface-head_detail-ex_payment_cards = gc_true.
  ENDIF.

ENDFORM.                    " get_paymentcards
*&---------------------------------------------------------------------*
*&      Form  GET_PAYMENT_SPLIT
*&---------------------------------------------------------------------*
FORM get_payment_split .

  DATA: h_skfbt LIKE acccr-skfbt.
  DATA: h_fkdat LIKE <gs_vbdkr>-fkdat.
  DATA: h_fkwrt LIKE acccr-wrbtr.
  DATA : BEGIN OF payment_split OCCURS 3.
           INCLUDE STRUCTURE vtopis.
  DATA : END OF payment_split.
  DATA ls_payment_split TYPE bil_s_prt_payment_split.

  CHECK <gs_vbdkr>-zterm NE space.

  h_skfbt = <gs_vbdkr>-skfbk.
  h_fkwrt = gs_komk-fkwrt.
  h_fkdat = <gs_vbdkr>-fkdat.
  IF <gs_vbdkr>-valdt NE 0.
    h_fkdat = <gs_vbdkr>-valdt.
  ENDIF.
  IF <gs_vbdkr>-valtg NE 0.
    h_fkdat = <gs_vbdkr>-fkdat + <gs_vbdkr>-valtg.
  ENDIF.
  CALL FUNCTION 'SD_PRINT_TERMS_OF_PAYMENT_SPLI'
    EXPORTING
      i_country                     = <gs_vbdkr>-land1
      bldat                         = h_fkdat
      budat                         = h_fkdat
      cpudt                         = h_fkdat
      language                      = gv_language
      terms_of_payment              = <gs_vbdkr>-zterm
      wert                          = h_fkwrt  "Warenwert + Tax
      waerk                         = <gs_vbdkr>-waerk
      fkdat                         = <gs_vbdkr>-fkdat
      skfbt                         = h_skfbt
      i_company_code                = <gs_vbdkr>-bukrs
    TABLES
      top_text_split                = payment_split
    EXCEPTIONS
      terms_of_payment_not_in_t052  = 01
      terms_of_payment_not_in_t052s = 02.

  LOOP AT payment_split.

    MOVE payment_split-line  TO ls_payment_split-line.
    APPEND ls_payment_split TO gs_interface-head_detail-payment_split.

  ENDLOOP.

  IF NOT gs_interface-head_detail-payment_split IS INITIAL.
    gs_interface-head_detail-ex_payment_split = gc_true.
  ENDIF.

ENDFORM.                    "PAYMENT_SPLIT
