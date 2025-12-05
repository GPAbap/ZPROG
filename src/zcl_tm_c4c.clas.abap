class ZCL_TM_C4C definition
  public
  final
  create public .

public section.

  interfaces IF_AMDP_MARKER_HDB .

  class-methods GET_DATA
    for table function ZCDS_C4C .
protected section.
private section.
ENDCLASS.



CLASS ZCL_TM_C4C IMPLEMENTATION.


METHOD get_data
        BY DATABASE FUNCTION FOR HDB
           LANGUAGE SQLSCRIPT
           OPTIONS READ-ONLY
           USING vbrk vbrp
          kna1
           prcd_elements.


    Lt_select = select DISTINCT vbrk.mandt as clnt, vbrk.vkorg, vbrk.vtweg, vbrk.spart,
                  vbrp.vkbur, vbrp.vkgrp, vbrp.aubel,
                  vbrk.vbeln, vbrk.fkdat, vbrk.kunag,
*                  kna1.kunnr,
                  kna1.name1 as name1_sol,
*                  'TEST0001' name1_sol,
                  vbrp.kunwe_ana,
                  'destinatari' as name1_dest,
*                  kna1.name1 as name1_dest,
                  vbrk.bzirk,
                  vbrp.posnr,vbrp.matnr,vbrp.arktx,
                  vbrp.werks, vbrp.charg, vbrp.prodh,
                  vbrp.fkimg, vbrp.vrkme, vbrp.ntgew,
                  vbrp.gewei, vbrk.netwr, vbrk.waerk,
                  vbrk.kurrf,
                   cast( '0.00' as decimal (13,2) ) AS zs01zs02,
                   CASE WHEN pe.kschl = 'ZF02' THEN pe.kwert else cast( '0.00' as decimal (13,2) ) end AS zf02,
                   CASE WHEN pe.kschl = 'ZD01' THEN pe.kwert else cast( '0.00' as decimal (13,2) ) end AS zd01,
                   CASE WHEN pe.kschl = 'ZD02' THEN pe.kwert else cast( '0.00' as decimal (13,2) ) end AS zd02,
                   CASE WHEN pe.kschl = 'ZS01' THEN pe.kwert else cast( '0.00' as decimal (13,2) ) end AS zs01,
                   CASE WHEN pe.kschl = 'ZS02' THEN pe.kwert else cast( '0.00' as decimal (13,2) ) end AS zs02,
                   CASE WHEN pe.kschl = 'ZF04' THEN pe.kwert else cast( '0.00' as decimal (13,2) ) end AS zf04,
                   CASE WHEN pe.kschl = 'ZF05' THEN pe.kwert else cast( '0.00' as decimal (13,2) ) end AS zf05
    from vbrk
    inner join kna1 on kna1.kunnr = vbrk.kunag
    inner join vbrp ON vbrk.vbeln = vbrp.vbeln
*    inner join kna1 as k2 on vbrp.kunwe_ana = k2.kunnr;
    left join prcd_elements as pe on pe.knumv = vbrk.knumv and pe.kposn = vbrp.posnr
    and pe.kschl in ('ZS01','ZS02','ZD01','ZD02','ZF02','ZF04','ZF05');

*    where vbrk.mandt = :clnt and
*     vbrk.kunag = p_kunag or
*     vbrk.vkorg = p_vkorg or
*     vbrk.vtweg = p_vtweg or
*     vbrk.spart = p_spart or
*     vbrp.werks = p_werks or
*     vbrp.matnr = p_matnr or
*     vbrk.fkdat = p_fkdat or
*     vbrp.prodh = p_prodh or
*     vbrp.vkbur = p_vkbur or
*     vbrk.bzirk = p_bzirk or
*     vbrp.vkgrp = p_vkgrp or
*     vbrk.vbeln = p_vbeln;

    lt_return = apply_filter ( :lt_select, :filter_sel );

    RETURN SELECT clnt, vkorg, vtweg, spart, vkbur, vkgrp, aubel,
                  vbeln, fkdat, kunag,
                  name1_sol, kunwe_ana,
                  name1_dest,bzirk,
                  posnr,matnr,arktx,
                  werks, charg, prodh,
                  fkimg, vrkme, ntgew,
                  gewei, netwr, waerk,
                  kurrf,
                  zs01zs02, zf02,
                  zd01, zd02,
                  zs01, zs02,
                  zf04, zf05
                  from :lt_return;


  ENDMETHOD.
ENDCLASS.
