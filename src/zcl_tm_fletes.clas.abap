CLASS zcl_tm_fletes DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .

    CLASS-METHODS get_fletes
        FOR TABLE FUNCTION zcds_tf_tm_fletes_jhv .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_tm_fletes IMPLEMENTATION.


  METHOD get_fletes
        BY DATABASE FUNCTION FOR HDB
           LANGUAGE SQLSCRIPT
           OPTIONS READ-ONLY
           USING likp lips ekpo rseg rbkp i_transporddocref "itordcrf
                  c_frtordgendatabasicfacts "ctorfogen
                 /scmtms/d_torrot
                 /scmtms/d_sf_rot
                 /scmtms/d_sf_doc
                 /scmtms/d_tchrgr
                  /sapapo/loc
                 adrc
                 dd07t
                 vbrp vbap
                 i_transportationorderallbp "itorbpa
                c_transpchargeitemelement "ctchrgitemelem
                zaxnare_tb001
  .

    RETURN select DISTINCT likp.mandt as clnt,
                 c_frtordgendatabasicfacts.freightorder as zorden_flete,
                  "/SCMTMS/D_TORROT".CREATED_ON AS zfechaorden,
                  likp.vbeln as zentrega,rseg.belnr as zfactura,
                  rbkp.xblnr as zreferencia,
                  "/SCMTMS/D_SF_ROT".SFIR_ID as zdoc_liquida,
*                  'NoHayRelacion' as zdoc_liquida,
                  "/SCMTMS/D_SF_ROT".lifecycle as zedo_factura,
                  dd07t.ddtext as zdes_edofact,
                  ekpo.ebeln as zpedido,
                 c_frtordgendatabasicfacts.sourcelocation as zubica_orig,
                 c_frtordgendatabasicfacts.destinationlocation as   zubica_dest,
                 adrc.city1 as zcd_destino,
                 c_frtordgendatabasicfacts.carrier as  zno_transpor, c_frtordgendatabasicfacts.carriername as znom_transpor,
                 "/SCMTMS/D_TORROT".mtr AS zmedio_trans, c_frtordgendatabasicfacts.TRANSPORDDISTANCEINDSPUNIT as zdistancia,
                  c_frtordgendatabasicfacts.displaylengthunit as   zum_distancia,
                   c_frtordgendatabasicfacts.transpchrgtotalamtindoccrcy /
                  case when c_frtordgendatabasicfacts.transporddistanceindspunit  = 0 then 1 ELSE c_frtordgendatabasicfacts.transporddistanceindspunit end as zcosto_km,
                  c_frtordgendatabasicfacts.transpchrgtotalamtindoccrcy / c_frtordgendatabasicfacts.transpordgrossweight * likp.ntgew as zimporte_fo,
                  c_frtordgendatabasicfacts.transpchargedocumentcurrency as zmoneda_fo,
                  c_frtordgendatabasicfacts.transpordquantity as zpiezas,
*                  ctorfogen.transpordgrossweight as zpeso,
                  likp.ntgew as zpeso,
                  c_frtordgendatabasicfacts.transpordgrossweightunit as zum_peso,
                  c_frtordgendatabasicfacts.transpchrgtotalamtindoccrcy /
                  case when c_frtordgendatabasicfacts.transpordgrossweight = 0 then 1 ELSE
                  CASE when c_frtordgendatabasicfacts.transpordgrossweightunit = 'KG' then c_frtordgendatabasicfacts.transpordgrossweight / 1000
                  else c_frtordgendatabasicfacts.transpordgrossweight end end as  zcosto_ton,
                  c_frtordgendatabasicfacts.transpchrgtotalamtindoccrcy /
                  case when c_frtordgendatabasicfacts.transpordgrossweight = 0 then 1 ELSE
                  CASE when c_frtordgendatabasicfacts.transpordgrossweightunit = 'KG' then c_frtordgendatabasicfacts.transpordgrossweight
                  else (c_frtordgendatabasicfacts.transpordgrossweight * 1000) END END as  zcosto_kg,
                  "/SCMTMS/D_TORROT".created_by as zfo_creadaby,DTORROT.tor_id as zno_flete,
                  CASE when  vbrp.aubel is null then lips.vgbel else vbrp.aubel end as zdocventa,
                  "/SCMTMS/D_SF_ROT".INV_DT as zfec_conta_dlf,
*                  '20231111' as zfec_conta_dlf,
                  "/SCMTMS/D_SF_ROT".CREATED_BY as zdlf_createdby,
*                  'Yo' as zdlf_createdby,
                  "/SCMTMS/D_TORROT".labeltxt as zetiqueta,
                  ekpo.werks as zcentro,
                  c_frtordgendatabasicfacts.sourcelocationlabel as zdes_ubiorigen, c_frtordgendatabasicfacts.destinationlocationlabel as zdes_ubidestino,
*                  '5125' as  zflete_vtas,
                  case when vbrp.kzwi6 is null then vbap.kzwi6 else vbrp.kzwi6 end as zflete_vtas,
                  c_transpchargeitemelement.transpchargecalcdamount as ztarifa,
                  c_transpchargeitemelement.transpchargecalcdamountcrcy as zmoneda,
*                  ctchrgitemelem.transpchrgrateamount as   zcosto_adicional,

                  c_transpchargeitemelement.transpchrgratecurrency as zmoneda_costadic,
                  c_transpchargeitemelement.transpchargetypedesc as   zdenom_costo,
                  "/SCMTMS/D_TORROT".purch_company_code,
                  likp.erdat, zaxnare_tb001.f_pago,
                  rbkp.cpudt,
                  vbrp.fkimg
           from likp
           inner join lips on lips.vbeln = likp.vbeln and lips.posnr = '000010'
           left join vbap ON vbap.vbeln = lips.vgbel
*           inner join itordcrf on ( ltrim(itordcrf.transporddocreferenceid,'0') = ltrim(likp.vbeln,'0') )
           inner join i_transporddocref on ( ltrim(i_transporddocref.transporddocreferenceid,'0') = ltrim(likp.vbeln,'0') )
           inner join "/SCMTMS/D_TORROT" on "/SCMTMS/D_TORROT".db_key = i_transporddocref.transportationorderuuid AND "/SCMTMS/D_TORROT".tor_cat = 'TO'
           inner join "/SCMTMS/D_TORROT" as DTORROT on DTORROT.base_btd_id = i_transporddocref.transporddocreferenceid
           left join vbrp on vbrp.vgbel = likp.vbeln
*           inner join c_frtordgendatabasicfacts on c_frtordgendatabasicfacts.freightorder = "/SCMTMS/D_TORROT".tor_id
           left join c_frtordgendatabasicfacts on c_frtordgendatabasicfacts.freightorder = "/SCMTMS/D_TORROT".tor_id
*           inner join ekpo ON ekpo.txz01 = ltrim( "/SCMTMS/D_TORROT".tor_id,'0')
           left join ekpo ON ekpo.txz01 = ltrim( "/SCMTMS/D_TORROT".tor_id,'0')
           left join rseg ON rseg.ebeln = ekpo.ebeln
           left join rbkp on rbkp.belnr = rseg.belnr
           left join "/SCMTMS/D_SF_DOC" on "/SCMTMS/D_SF_DOC".BTD_ID = ekpo.ebeln
*           inner join "/SCMTMS/D_SF_ROT"  on "/SCMTMS/D_SF_ROT".db_key = "/SCMTMS/D_SF_DOC".parent_key
*                        and "/SCMTMS/D_SF_ROT".lifecycle <> '06'
           left join "/SCMTMS/D_SF_ROT"  on "/SCMTMS/D_SF_ROT".db_key = "/SCMTMS/D_SF_DOC".parent_key
                        and "/SCMTMS/D_SF_ROT".lifecycle <> '06'
           left join dd07t on dd07t.domvalue_l = "/SCMTMS/D_SF_ROT".lifecycle and dd07t.ddlanguage = 'S' AND dd07t.as4local = 'A'
           and dd07t.domname = '/SCMTMS/SFIR_LC_STATUS'

*           inner join "/SCMTMS/D_TCHRGR" on "/SCMTMS/D_TCHRGR".host_key = c_frtordgendatabasicfacts.TRANSPORTATIONORDERUUID
*           inner join i_transportationorderallbp ON i_transportationorderallbp.transportationorderuuid = c_frtordgendatabasicfacts.transportationorderuuid
*           inner join "/SAPAPO/LOC" on "/SAPAPO/LOC".locno = c_frtordgendatabasicfacts.sourcelocation
*           inner join "/SAPAPO/LOC" as dest on dest.locno = c_frtordgendatabasicfacts.destinationlocation
*           inner join adrc on adrc.addrnumber = i_transportationorderallbp.businesspartneraddressid and i_transportationorderallbp.businesspartnerrole = 'WE'
*           inner join c_transpchargeitemelement ON ( c_transpchargeitemelement.transpchargehostdocumentuuid =  c_frtordgendatabasicfacts.transportationorderuuid
**                                       and c_transpchargeitemelement.transportationrate <> ' ' and transpchargecalcsheetlinenmbr = '000010')
*                                       and c_transpchargeitemelement.transportationrate <> ' ' and TRANSPCHARGECALCDAMOUNT > 0 )
           left join "/SCMTMS/D_TCHRGR" on "/SCMTMS/D_TCHRGR".host_key = c_frtordgendatabasicfacts.TRANSPORTATIONORDERUUID
           left join i_transportationorderallbp ON i_transportationorderallbp.transportationorderuuid = c_frtordgendatabasicfacts.transportationorderuuid
           left join "/SAPAPO/LOC" on "/SAPAPO/LOC".locno = c_frtordgendatabasicfacts.sourcelocation
           left join "/SAPAPO/LOC" as dest on dest.locno = c_frtordgendatabasicfacts.destinationlocation
           left join adrc on adrc.addrnumber = i_transportationorderallbp.businesspartneraddressid and i_transportationorderallbp.businesspartnerrole = 'WE'
           left join c_transpchargeitemelement ON ( c_transpchargeitemelement.transpchargehostdocumentuuid =  c_frtordgendatabasicfacts.transportationorderuuid
*                                       and c_transpchargeitemelement.transportationrate <> ' ' and transpchargecalcsheetlinenmbr = '000010')
                                       and c_transpchargeitemelement.transportationrate <> ' ' and TRANSPCHARGECALCDAMOUNT > 0 )
           left join zaxnare_tb001 on zaxnare_tb001.doc_contable = rbkp.belnr
           where
             likp.mandt                   = :clnt and
             "/SCMTMS/D_TORROT".CREATED_ON  BETWEEN :p_finicio   and :p_ffinal;
*             and likp.werks = :p_werks;
*             or likp.vbeln                     = :p_entrega;

*            or vbrk.vkorg                 = :p_vkorg
*            or vbrp.werks                 = :p_werks
*            or ctorfogen.carrier          = :p_carrier
*            or ctorfogen.TRANSPORTATIONORDERTYPE      = :p_tor_type
*            or ctorfogen.freightorder     = :p_FREIGHTORDER
*            or "/SCMTMS/D_SF_ROT".SFIR_ID = :p_SFIR_ID
*            or likp.vbeln                 = :p_entrega;

  ENDMETHOD.
ENDCLASS.
