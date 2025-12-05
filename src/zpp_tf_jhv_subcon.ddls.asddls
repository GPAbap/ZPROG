@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@EndUserText.label: 'Table Function para Datos Subcontratacion'
define table function ZPP_TF_JHV_SUBCON
  with parameters
    @Environment.systemField: #CLIENT
    clnt    : abap.clnt,
    sel_opt : abap.char(100)
  //    p_aufnr : aufnr,
  //    p_ebeln : bstnr,
  //    p_budat : budat
returns
{
  clnt       : abap.clnt;
  werks      : werks_d;
  aufnr      : aufnr;
  matnr      : matnr;
  maktx      : maktx;
  erfmg      : erfmg;
  erfme      : erfme;
//  bwart      : bwart;
  werks_s    : werks_d;
  ebeln_s    : bstnr;
  matnr_s    : matnr;
  erfmg_s    : erfmg;
  erfme_s    : erfme;
  bwart_s    : bwart;
  diferencia : erfmg;
  budat      : budat;

}
implemented by method
  zcl_pp_subcon=>get_data;
