************************************************************************
* MARY GUZMAN
* PROGRAMA REVISAR INDICADORES DE COMPRAS
* Revisar tiempo de respuesta de las solicitudes de pedido
************************************************************************
report zrmm0011_a no standard page heading line-size 305 line-count 65.
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
  cdpos,
  eket,
  ekpo,
  ekko,
  eban.
*DATA:
selection-screen begin of block block1 with frame title text-001.
*  PARAMETERS:
*    FRGC1_P LIKE T16FS-FRGC1 OBLIGATORY.      " Código de Liberación
select-options:
  ekorg_p for eban-ekorg,                  " Org. Compras
  bsart_p for eban-bsart,                  " clase de documento
  werks_p for eban-werks,                  " Centro
  lgort_p for eban-lgort,                  " Almacén
  matkl_p for eban-matkl,                  " Grupo de Artículos
  banfn_p for eban-banfn,                  " tEMPORAL
  badat_p for eban-badat.                  " FECHA DE SOLICITUD
selection-screen end of block block1.
* Tabla Interna
data: begin of rec occurs   0,
  banfn like eban-banfn,     " Sol Ped
  bnfpo like eban-bnfpo,     " Posición SolPed
  bsart like eban-bsart,     " Clase de Documento
  bstyp like eban-bstyp,     " Tipo de documento de compras
  loekz like eban-loekz,     " Indicador de borrado
  statu like eban-statu,     " Status de tratamiento de la solicitud de
  ekgrp like eban-ekgrp,     " Grupo de compras
  txz01 like eban-txz01,     " Texto
  matnr like eban-matnr,     " Material
  werks like eban-werks,     " Centro
  lgort like eban-lgort,     " Almacén
  matkl like eban-matkl,     " Grupo de Artículos
  menge like eban-menge,     " Cantidad
  badat like eban-badat,     " Fecha de Solicitud
  lfdat like eban-lfdat,     " Fecha de entrega
  frgdt like eban-frgdt,     " Fecha de Liberación de Solped
  preis like eban-preis,     " Precio Unitario
  ekorg like eban-ekorg,     " Organización de Compras
  ebeln like eban-ebeln,     " Pedido
  ebelp like eban-ebelp,     " Posición del Pedido
  bedat like eban-bedat,     " Fecha de creación del pedido
  bednr like eban-bednr,     " No. Necesidad
end of rec.
data: begin of solped occurs   0,
  bsart like eban-bsart,     " Clase de Documento
  matkl like eban-matkl,     " Grupo de Artículos
  banfn like eban-banfn,     " Sol Ped
  bnfpo like eban-bnfpo,     " Posición SolPed
  bstyp like eban-bstyp,     " Tipo de documento de compras
  loekz like eban-loekz,     " Indicador de borrado
  statu like eban-statu,     " Status de tratamiento de la solicitud de
  ekgrp like eban-ekgrp,     " Grupo de compras
  txz01 like eban-txz01,     " Texto
  matnr like eban-matnr,     " Material
  werks like eban-werks,     " Centro
  lgort like eban-lgort,     " Almacén
  menge like eban-menge,     " Cantidad
  badat like eban-badat,     " Fecha de Solicitud
  lfdat like eban-lfdat,     " Fecha de entrega
  frgdt like eban-frgdt,     " Fecha de Liberación de Solped
  preis like eban-preis,     " Precio Unitario
  ekorg like eban-ekorg,     " Organización de Compras
  ebeln like eban-ebeln,     " Pedido
  ebelp like eban-ebelp,     " Posición del Pedido
  bedat like eban-bedat,     " Fecha de creación del pedido
  bukrs like ekko-bukrs,     " Sociedad
  frgsx like ekko-frgsx,     " ESTRATEGA DE LIBERACION
  aedat like ekko-aedat,     " Fecha de creación del regi
  eindt like eket-eindt,     " Fecha Entrega Pedido
  ernam like ekko-ernam,     " Usuario que creo el regist
  lifnr like ekko-lifnr,     " Proveedor
  netwr like ekpo-netwr,     " IMPORTE
  username like cdhdr-username, " Usuario que modif de pedid
  udate like cdhdr-udate,    " Fecha de modif de pedido
  utime like cdhdr-utime,    " Hora de modif del pedido
  frgxt like t16ft-frgxt,    " Denominación de la estrat
  knumv like ekko-knumv,     " Num. de Condición
  kwert_t like konv-kwert,   " Valor de la Condición
  maktg like makt-maktg,     " Descripción del material
  kwert like konv-kwert,     " Valor de la condición
  cpudt_in like ekbe-cpudt,  " Fecha Entrada
  menge_em like ekbe-menge,  " entrada de mercancía cant.
  unit_rec like konv-kwert,  " Precio Unitario Recibido
  menge_fa like ekbe-menge,  " Cantidad Facturada
  cpudt_fa like ekbe-cpudt,  " Fecha Verif. Factura.
  bednr    like eban-bednr,  " requerimiento
end of solped.
data:
  dias(7),
  prom1(10),
  prom4(10),
  fecha1(10),
  fecha2(10),
  fecha3(10),
  fecha4(10),
  tfecha1(10),
  tfecha4(10),
  cont(10),
  v_tabkey like cdpos-tabkey,
  final(10).
*-----------------------------------------------------------------------
* ESPECIFICACIONES DE CALCULO
*-----------------------------------------------------------------------
start-of-selection.
* Selecciona las solicitudes de pedido requeridas
  select * into corresponding fields of table rec from eban
    where  badat  in badat_p
    and    ekorg  in ekorg_p
    and    werks  in werks_p
    and    lgort  in lgort_p
    and    banfn  in banfn_p
    and    matkl  in matkl_p
* Actualización 20140514 Mary Gzumán
    and    loekz  ne 'X'.
*  perform flibsolped.
  dias = ( badat_p+11(8) - badat_p+3(8) ) + 1.
  perform proceso.
  perform imprimir.
end-of-selection.
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* FORM PROCESO
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
form proceso.
  loop at rec.
*    IF rec-loekz = ' ' AND rec-ebeln <> '          '.
      move-corresponding rec to solped.
      perform flibsolped.
      select single * from ekko
        where ebeln = rec-ebeln.
      if sy-subrc = 0.
        move:
        ekko-ebeln to solped-ebeln,
        ekko-bukrs to solped-bukrs,
        ekko-aedat to solped-aedat,
        ekko-ernam to solped-ernam,
        ekko-ekgrp to solped-ekgrp,
        ekko-knumv to solped-knumv,
        ekko-frgsx to solped-frgsx.
* Reviso si entro a estrategia de liberación
        select single * from t16ft
        where spras = 'S'
        and   frggr = 'P1'
        and   frgsx = ekko-frgsx.
        if sy-subrc = 0.
          move t16ft-frgxt to solped-frgxt.
        else.
          move 'NO ENTRO A ESTRATEGIA' to solped-frgxt.
        endif.
* selecciona el documento de modificacion de cambio de sts X estrategia
        select * from cdhdr
          where objectclas = 'EINKBELEG'
          and   objectid   = ekko-ebeln
          and   tcode      = 'ME28'.
          if sy-subrc = 0.
            move:
            cdhdr-username to solped-username,
            cdhdr-udate    to solped-udate,
            cdhdr-utime    to solped-utime.
          else.
            move:
            '            ' to solped-username,
            '            ' to solped-udate,
            '        '     to solped-utime.
          endif.
        endselect.
* Valor del pedido por posición
        select * from konv
        where knumv = solped-knumv
        and   kschl = 'PBXX'.
          if sy-subrc = 0.
            solped-kwert_t = konv-kwert + solped-kwert_t.
          endif.
        endselect.
        perform detalle.
      endif.          " sy-subrc -> EKKO
*    ENDSELECT.
*    ELSE.
*      MOVE-CORRESPONDING rec TO  solped.
*      MOVE 'SOLPED BORRADA' TO solped-txz01.
*      APPEND solped.
*    ENDIF.
  endloop.
endform.          " PROCESO
*-----------------------------------------------------------------------
************************************************************************
* ESPECIFICACIONES DE SALIDA
************************************************************************
form imprimir.
  format intensified off.
  uline.
  write:/10 'ANALISIS DE LIBERACION DE PEDIDOS'.
  uline.
  write:/10 'DATOS DE LA SOLICITUD DE PEDIDO',
            'DATOS DEL PEDIDO'.
  uline.
  write:/2 'GPO ART',
      13 'SOLPED',
      23 'POS',
      29 'ITEM',
      48 'DESCRIPCION',
      97 'CANT REQ',
     107 'F SOLPED',
     118 'F LIBER SP',
     129 'F ENTRE SP',
     140 'PEDIDO',
     151 'POS',
     157 'F PEDIDO',
     168 'F LIB PED',
     179 'F ENTR PED',
     190 'F ENTRAD M',
     206 'CANTIDAD EM',
     219 'F FACTURA',
     237 'CANT FACT',
     250 'lib S P',
     261 'lib Ped',
     271 'Ent Merc',
     281 'T proceso'.

  format intensified on.
  sort solped by bsart matkl banfn bnfpo.
  loop at solped.
* Fecha de pedido - fecha de liberación de solicitud
    fecha1 = solped-bedat - solped-frgdt.
* Fecha de liberación - fecha de pedido
    fecha2 = solped-udate - solped-bedat.
* Fecha de verificación - fecha de entrada de mercancías
    fecha3 = solped-cpudt_fa - solped-cpudt_in.
* Fecha total de trámite para el usuario
* Fecha de entrada de mercancías - Fecha de solped
    if solped-cpudt_in ne 0.
      fecha4 = solped-cpudt_in - solped-frgdt.
    elseif solped-cpudt_fa ne 0.
      fecha4 = solped-cpudt_fa - solped-frgdt.
    else.
      fecha4 = 0.
    endif.
*   CONCATENATE '(' solped-username ')' INTO nombre.
    at new bsart.
      write solped-bsart.
    endat.
    write:/2
    solped-matkl,      " Grupo de Artículos
    solped-banfn,      " Solicitud de Pedido
    solped-bnfpo,      " Posición
    solped-matnr,      " Material
    solped-txz01,      " Texto de la posición
    solped-menge,      " Cantidad Solicitada
*    solped-preis,      " Precio Unitario
    solped-badat,      " Fecha de Solicitud
    solped-frgdt,      " FEcha de Liberación
    solped-lfdat,      " Fecha entrega solped
    solped-ebeln,      " Pedido
    solped-ebelp,      " Posición del pedido
    solped-bedat,      " Fecha de Pedido
*    solped-netwr,      " Precio Unitario Ped.
    solped-udate,      " Fecha Liberación Pedido
    solped-eindt,      " Fecha entrega Pedido
    solped-cpudt_in,   " Fecha Entrada Material
    solped-menge_em,   " Entrada de Mercancía CANT
*    solped-unit_rec,   " Prec. Unit. REcibido
    solped-cpudt_fa,   " Fecha recepción de factura
    solped-menge_fa,   " Cantidad Recibida
    fecha1,            " Indicador 1
    fecha2,             " Indicador 2
    fecha3,
    fecha4. " Días totales de proceso
*    solped-bednr.
    tfecha1 = tfecha1 + fecha1.
    tfecha4 = tfecha4 + fecha4.
    cont = cont + 1.
  at end of matkl.
    skip.
  endat.
  at end of bsart.
    prom1 = tfecha1 / cont.
    prom4 = tfecha4 / cont.
    write:/
    'Total de posiciones de Solicitudes: ',cont.
    write:/
    'Total de días de tratamiento:       ', tfecha1.
    write:/
    'Promedio final de tratamiento:      ', prom1.
*    tfecha4
    write:/
    'Promedio final de Total de proceso: ', prom4.
    clear:
    tfecha1,
    tfecha4,
    prom1,
    prom4.
    skip.
  endat.
  endloop.
endform.          " IMPRIMIR
*-----------------------------------------------------------------------
* BUSCA DETALLE DE POSICIÓN
form detalle.
  select * from ekpo
    where ebeln = rec-ebeln
    and   ebelp = rec-ebelp.
    if sy-subrc = 0.
* Busca fecha de entrega del pedido
      select single * from  eket
      where  ebeln  = ekpo-ebeln
      and    ebelp  = ekpo-ebelp.
      if sy-subrc = 0.
        solped-eindt = eket-eindt.
      endif.
      select single * from makt
      where matnr = ekpo-matnr.
      if sy-subrc = 0.
      endif.   " makt
      select single * from konv
      where knumv = ekko-knumv
      and   kposn = ekpo-ebelp.
      if sy-subrc = 0.
        move:
        ekpo-netwr to solped-netwr,
        konv-kwert to solped-kwert,
        ekpo-menge to solped-menge,
        makt-maktg to solped-maktg.
        if ekpo-matnr = '                    '.
          concatenate ekpo-knttp ekpo-txz01 into solped-maktg
          separated by space.
        endif.
* busca fecha de entrada de mercancias.
        select single * from ekbe
          where ebeln  = solped-ebeln
          and   ebelp  = solped-ebelp
          and   vgabe  = '1'.
          if sy-subrc = 0.
            move ekbe-budat to solped-cpudt_in.
            move ekbe-menge to solped-menge_em.
            solped-unit_rec = ekbe-dmbtr / ekbe-menge.
          else.
            clear:
            solped-menge_em,
            solped-unit_rec,
            solped-cpudt_in.
          endif.
* busca fecha de verificación de factura.
        select single * from ekbe
          where ebeln  = solped-ebeln
          and   ebelp  = solped-ebelp
          and   vgabe  = '2'.
          if sy-subrc = 0.
            move ekbe-menge to solped-menge_fa.
            move ekbe-budat to solped-cpudt_fa.
            if solped-cpudt_in = 0.
              solped-cpudt_in = ekbe-budat.
            endif.
          else.
            clear:
            solped-menge_fa,
            solped-cpudt_fa.
          endif.
          append solped.   " Mary 20160707
*FORMAT INTENSIFIED ON.
      endif.   " konv
    endif.   " ekpo
  endselect.   " ekpo
endform.                    "DETALLE
*&---------------------------------------------------------------------*
*&      Form  flibsolped
*&---------------------------------------------------------------------*
form flibsolped .
  concatenate '100' rec-banfn rec-bnfpo into v_tabkey.
  select single * from  cdpos
  where  objectclas  = 'BANF'
  and    objectid    = rec-banfn
  and    tabname     = 'EBAN'
  and    tabkey      = v_tabkey
  and    chngind     = 'U'
  and    value_new   = '7'.
  if sy-subrc = 0.
    select single * from  cdhdr
    where  objectclas  = cdpos-objectclas
    and    objectid    = cdpos-objectid
    and    changenr    = cdpos-changenr.
    if sy-subrc = 0.
      solped-frgdt  = cdhdr-udate.
    else.
      solped-frgdt  = eban-erdat.
    endif.
  endif.
endform.                    " fesolped
