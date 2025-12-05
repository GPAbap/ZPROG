************************************************************************
* MARY GUZMAN
* PROGRAMA PARA REVISAR LIBERACION DE PEDIDOS
************************************************************************
report zrmm0904 no standard page heading line-size 180 line-count 65.
*-----------------------------------------------------------------------
* ESPECICIFACIONES DE ENTRADA
*-----------------------------------------------------------------------
tables:
  t16fs,
  makt,
  konv,
  ekbe,
  t16ft,
  cdhdr,
  ekpo,
  ekko.
*DATA:
selection-screen begin of block block1 with frame title text-001.
parameters:
  frgc1_p like t16fs-frgc1 obligatory.      " Código de Liberación
select-options:
  bsart_p for ekko-bsart obligatory,                  " tipo de pedido
*   lgort_p FOR mard-lgort,                  " Almacén
*   frgc1_p FOR t16fs-frgc1,                 " Estrategia Liberación
  aedat_p for ekko-aedat.                  " FECHA DE SOLICITUD
selection-screen end of block block1.
* Tabla Interna
data: begin of rec occurs   0,
  bukrs like ekko-bukrs,
  frgsx like ekko-frgsx,                    " ESTRATEGA DE LIBERACION
  ebeln like ekko-ebeln,
  aedat like ekko-aedat,
  ernam like ekko-ernam,
  ekgrp like ekko-ekgrp,                    " Grupo de Compras
  werks like ekpo-werks,                    " Centro
  matkl like ekpo-matkl,                    " Grupo de Compras
  username like cdhdr-username,
  udate like cdhdr-udate,
  utime like cdhdr-utime,
  frgxt like t16ft-frgxt,
  knumv like ekko-knumv,
  kwert_t like konv-kwert,
  waers like konv-waers,
  matnr like ekpo-matnr,
  maktg like makt-maktg,
  menge like ekpo-menge,
*  kbetr LIKE konv-kbetr,
  kwert like konv-kwert,
end of rec.
data:
  nombre like cdhdr-username.
*-----------------------------------------------------------------------
* ESPECIFICACIONES DE CALCULO
*-----------------------------------------------------------------------
start-of-selection.
  select * from t16fs
    where frgc1 = frgc1_p
    or    frgc2 = frgc1_p
    or    frgc3 = frgc1_p.
  endselect.
  select * from ekko
    where aedat in aedat_p
    and   frgzu ne '        '
*    AND   frgsx IN frgsx_p
    and   bsart in bsart_p.
    if sy-subrc = 0.
* Selecciono solo los pedidos que pertenecen al
* código de liberación elegido
      select single * from t16fs
      where frggr = 'P1'
      and   frgsx = ekko-frgsx.
      if sy-subrc = 0.
        if t16fs-frgc1 = frgc1_p or t16fs-frgc2 = frgc1_p
        or t16fs-frgc3 = frgc1_p or t16fs-frgc4 = frgc1_p
        or t16fs-frgc5 = frgc1_p or t16fs-frgc6 = frgc1_p
        or t16fs-frgc7 = frgc1_p or t16fs-frgc8 = frgc1_p.
          move:
          ekko-ebeln to rec-ebeln,
          ekko-bukrs to rec-bukrs,
          ekko-aedat to rec-aedat,
          ekko-ernam to rec-ernam,
          ekko-ekgrp to rec-ekgrp,
          ekko-knumv to rec-knumv,
          ekko-frgsx to rec-frgsx.
* Reviso si entro a estrategia de liberación
          select single * from t16ft
          where spras = 'S'
          and   frggr = 'P1'
          and   frgsx = ekko-frgsx.
          if sy-subrc = 0.
            move t16ft-frgxt to rec-frgxt.
          else.
            move 'NO ENTRO A ESTRATEGIA' to rec-frgxt.
          endif.
          select * from cdhdr
            where objectclas = 'EINKBELEG'
            and   objectid   = ekko-ebeln
            and   tcode      = 'ME28'.
            if sy-subrc = 0.
              move:
              cdhdr-username to rec-username,
              cdhdr-udate    to rec-udate,
              cdhdr-utime    to rec-utime.
            else.
              move:
              '            ' to rec-username,
              '            ' to rec-udate,
              '        '     to rec-utime.
            endif.
          endselect.
          select * from konv
          where knumv = rec-knumv
          and   kschl = 'PBXX'.
            if sy-subrc = 0.
              rec-kwert_t = konv-kwert + rec-kwert_t.
            endif.
          endselect.
          perform detalle.
*       APPEND rec.
        endif.
      endif.
    endif.
  endselect.
*-----------------------------------------------------------------------
************************************************************************
* ESPECIFICACIONES DE SALIDA
************************************************************************
  format intensified off.
  uline.
  write:/10 'ANALISIS DE LIBERACION DE PEDIDOS'.
  uline.
  write:/2 'PEDIDO',
        14 'SOC.',
        20 'FECHA',
*       32 'CREADO POR',
*          'GPO COMPRAS',
*          'EST.LIBERACION',
        32 'EST.LIBERACION',
        53 '(LIBERADO POR)',
        75 'CANTIDAD',
        93 'IMPORTE',
       102 'MATERIAL'.
  format intensified on.
  sort rec by bukrs frgxt ebeln.
  loop at rec.
    concatenate '(' rec-username ')' into nombre.
    write:/2  rec-ebeln,
           14 rec-bukrs,
           20 rec-aedat,
*           32 rec-ernam,
*           46 rec-ekgrp,
           32 rec-frgxt,
           53 nombre,
*           54 rec-username,
*           66 ')',
*           69 rec-kbetr_t.
           67 rec-menge,
           83 rec-kwert,rec-waers,
*{   REPLACE        PROK900685                                        1
*\          105 REC-MAKTG.
          108 rec-maktg.
*}   REPLACE
*          94 rec-udate,
*          105 rec-utime.
*          90 rec-frgsx.
*  PERFORM detalle.
    at end of ebeln.
      sum.
      format intensified off.
      write:/2 'TOTAL PEDIDO:', 83 rec-kwert, rec-waers.
      format intensified on.
    endat.

  endloop.

end-of-selection.
*-----------------------------------------------------------------------
* BUSCA DETALLE DE POSICIÓN
form detalle.
  select * from ekpo
    where ebeln = rec-ebeln.
    if sy-subrc = 0.
      select single * from makt
      where matnr = ekpo-matnr.
      if sy-subrc = 0.
      endif.
      select single * from konv
      where knumv = ekko-knumv
      and   kposn = ekpo-ebelp.
      if sy-subrc = 0.
*FORMAT INTENSIFIED OFF.
*        WRITE:/
*               69 konv-KWERT,
*               85 ekpo-menge,
*               103 makt-maktg.
        move:
        konv-kwert to rec-kwert,
        ekpo-menge to rec-menge,
        konv-waers to rec-waers,
        makt-maktg to rec-maktg.
        if ekpo-matnr = '                    '.
          concatenate ekpo-knttp ekpo-txz01 into rec-maktg separated by
                      space.
        endif.
        append rec.
*FORMAT INTENSIFIED ON.
      endif.
    endif.
  endselect.
endform.                    "DETALLE
