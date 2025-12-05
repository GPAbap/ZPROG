@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@EndUserText.label: 'CDS - Table Function Para ZTM_RE_FLETES'
define table function zcds_tf_tm_fletes_jhv
  with parameters
    @Environment.systemField: #CLIENT
    clnt      : abap.clnt,
    //    p_entrega      : vbeln,
    p_finicio : /bofu/tstmp_creation_time,
    p_ffinal  : /bofu/tstmp_creation_time
  //    p_werks   : werks_d
  ////    p_vkorg        : /scmb/org_ext_id,

  ////    p_carrier      : abap.char(10),
  ////    p_tor_type     : /scmtms/tor_type,
  ////    p_FREIGHTORDER : /scmtms/tor_id,
  ////    p_SFIR_ID      : /scmtms/sfir_id,
  ////    p_vbeln      : vbeln
returns
{

  clnt               : abap.clnt;
  zorden_flete       : /scmtms/tor_id;
  zfechaorden        : /bofu/tstmp_creation_time;
  zentrega           : vbeln;
  zfactura           : vbeln;
  zreferencia        : xblnr;
  zdoc_liquida       : /scmtms/sfir_id;
  zedo_factura       : /scmtms/invoicing_status_code;
  zdes_edofact       : zddtext;
  zpedido            : ebeln;
  zubica_orig        : /scmtms/location_id;
  zubica_dest        : /scmtms/location_id;
  zcd_destino        : ad_city1;
  zno_transpor       : abap.char(10);
  znom_transpor      : abap.char(81);
  zmedio_trans       : /scmtms/transmeanstypecode;
  zdistancia         : /scmtms/quantity_13_3;
  zum_distancia      : /scmtms/vdm_dsp_length_unit;
  zcosto_km          : abap.curr(31,3);
  zimporte_fo        : abap.curr(31,3);
  zmoneda_fo         : /scmtms/doc_currency;
  zpiezas            : /scmtms/quantity_13_3;
  zpeso              : /scmtms/quantity_13_3;
  zum_peso           : /scmtms/qua_gro_wei_uni;
  zcosto_ton         : abap.curr(31,3);
  zcosto_kg          : abap.curr(31,3);
  zfo_creadaby       : /bofu/user_id_created_by;
  zno_flete          : /scmtms/tor_id;
  zdocventa          : vbeln_va;
  zfec_conta_dlf     : /scmtms/invdt;
  zdlf_createdby     : /bofu/user_id_created_by;
  zetiqueta          : /scmtms/tor_label;
  zcentro            : werks_d;
  zdes_ubiorigen     : abap.char(117);
  zdes_ubidestino    : abap.char(117);
  zflete_vtas        : kzwi6;
  ztarifa            : kzwi6; //scmtms/tc_ratetable_id;
  zmoneda            : /scmtms/vdm_calc_amount_crcy;
  zmoneda_costadic   : /scmtms/vdm_rate_amount_crcy;
  zdenom_costo       : /scmtms/charge_desc;
  purch_company_code : /scmtms/purch_company_code;
  erdat              : erdat;
  f_pago             : zaxnare_el017;
  cpudt              : cpudt;
  fkimg              : fkimg;


}
implemented by method
  zcl_tm_fletes=>get_fletes;
