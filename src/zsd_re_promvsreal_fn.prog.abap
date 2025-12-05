*&---------------------------------------------------------------------*
*& Include          ZSD_RE_PROMVSREAL_FN
*&---------------------------------------------------------------------*


FORM get_data.

  FIELD-SYMBOLS <fs_data> TYPE st_datos.
  DATA vl_data TYPE kdmat.

  SELECT vk~vbeln, vp~posnr,vk3~bstkd, l~charg,l~werks,t~name1 AS name1w,
         substring( l~charg,5,4 ) AS parvada, substring( l~charg,9,2 ) AS id,  vp~kwmeng,vp~ntgew,
         vk~erdat,vk~vkorg, vk~vkbur, vk~spart, vk~ernam,
         vk~vtweg, vp~netwr, vk~kunnr, k~stcd1, k~name1,
         vk2~fkdat, vk2~vbeln AS vbelnf, v2~posnr AS posnrf,
         vk2~ernam AS ernamf, vk2~bzirk, z~bztxt, vk2~kurrf,
         v2~fkimg, v2~vrkme, v2~ntgew AS ntgewf, v2~matnr,
         m~maktx, v2~netwr AS netwrf,l~erdat AS erdate, l~vbeln AS vbelne, l~lfimg, l~ntgew AS ntgewe,
         dats_days_between( vk~erdat, vk2~fkdat ) AS difpedfact, l~kdmat

  FROM  vbak AS vk
  INNER JOIN vbap AS vp ON  vk~vbeln = vp~vbeln
  INNER JOIN vbrp AS v2 ON v2~aubel =  vp~vbeln AND v2~aupos = vp~posnr
  INNER JOIN vbrk AS vk2 ON vk2~vbeln = v2~vbeln AND vk2~fksto NE 'X' AND vk2~vbtyp NE 'N'
  left join vbkd as vk3 on vk3~vbeln = vk~vbeln and vk3~posnr = vp~posnr
  LEFT JOIN lips AS l ON l~vgbel = vp~vbeln AND l~posnr = vp~posnr
  INNER JOIN kna1 AS k ON k~kunnr = vk~kunnr
  INNER JOIN makt AS m ON m~matnr = vp~matnr AND m~spras = 'S'
  INNER JOIN t001w AS t ON t~werks = l~werks AND t~spras = 'S'
  INNER JOIN t171t AS z ON z~bzirk = vk2~bzirk AND z~spras = 'S'
  WHERE vk~vkorg IN @so_vkorg
  AND   vk~spart IN @so_spart
  AND   vk~erdat IN @so_erdat
  AND vk~fkara NE 'ZG2' "NOTA DE CREDITO
     INTO TABLE @it_datos.


  SORT it_datos BY werks.

  LOOP AT it_datos ASSIGNING <fs_data> WHERE kdmat IS NOT INITIAL.
    vl_data = <fs_data>-kdmat.

    SPLIT vl_data AT '/' INTO <fs_data>-caseta <fs_data>-lote <fs_data>-cantidad <fs_data>-producto.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
