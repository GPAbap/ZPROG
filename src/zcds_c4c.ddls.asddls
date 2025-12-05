@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@EndUserText.label: 'CDS - Table Function Para ZSD_RE_C4C'
define table function zcds_c4c
  with parameters
    @Environment.systemField: #CLIENT
    clnt       : abap.clnt,
    filter_sel : abap.char(800)
  //    p_kunag : kunag,
  //    p_vkorg : vkorg,
  //    p_vtweg : vtweg,
  //    p_spart : spart,
  //    p_werks : werks_d,
  //    p_matnr : matnr,
  //    p_FKDAT : fkdat,
  //    p_prodh : prodh_d,
  //    p_vkbur : vkbur,
  //    p_bzirk : bzirk,
  //    p_vkgrp : vkgrp,
  //    p_vbeln : vbeln

returns
{

  clnt       : abap.clnt;
  VKORG      : vkorg;
  VTWEG      : vtweg;
  SPART      : spart;
  VKBUR      : vkbur;
  VKGRP      : vkgrp;
  AUBEL      : vbeln_va;
  VBELN      : vbeln;
  FKDAT      : fkdat;
  KUNAG      : kunag;
  NAME1_SOL  : name1_gp;
  KUNWE_ANA  : kunwe;
  NAME1_DEST : name1_gp;
  BZIRK      : bzirk;
  POSNR      : posnr;
  MATNR      : matnr;
  ARKTX      : arktx;
  WERKS      : werks_d;
  CHARG      : charg_d;
  PRODH      : prodh_d;
  FKIMG      : fkimg;
  VRKME      : vrkme;
  NTGEW      : ntgew;
  GEWEI      : gewei;
  NETWR      : netwr;
  WAERK      : waerk;
  KURRF      : kurrf;
  zs01zs02   : kwert;
  zf02       : kwert;
  zd01       : kwert;
  zd02       : kwert;
  zs01       : kwert;
  zs02       : kwert;
  zf04       : kwert;
  zf05       : kwert;

}
implemented by method
  zcl_tm_c4c=>get_data;
