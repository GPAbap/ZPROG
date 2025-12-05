*----------------------------------------------------------------------*
* Reporte   : ZRSD0002                                                 *
* Autor     : MARÍA DEL CARMEN OCOTLÁN GUZMÁN MEDINA                   *
* Compañia  : ALPESUR                                                  *
* Fecha Req : 24 de Noviembre 1998                                     *
* Descripción: Reporte para relacionar los clientes que tienen         *
*              pendiente uno o más pedidos pendientes.                 *
*----------------------------------------------------------------------*
report zrsd0002 message-id zp line-size 130 line-count 65
                    no standard page heading.
* ----------    T   A   B   L   A    S       --------------------------*
tables:
  vbakuk,                " Documento de ventas: Cabecera
  vbfa,
  vbap,                  " Documento de ventas: Detalle
  vbep,                  " Documento ventas: Datos de reparto (material)
  kna1.                  " Maestro de clientes (básicos)

tables: t022d,
        tsp03.                  " tipos de letras.
* ---------- Parámetros en SCREEN ---------- *
selection-screen begin of block block1 with frame title text-001.
select-options:
  p_audat for vbakuk-audat,           " Fecha de Pedido
  p_vkorg for vbakuk-vkorg,           " Organización de Ventas
  p_vtweg for vbakuk-vtweg,           " Canal de distribución
  p_spart for vbakuk-spart,           " Sector
  p_vkbur for vbakuk-vkbur.           " Oficina de Ventas
selection-screen end of block block1.
*----------Tablas Internas ----------*
data: begin of tab_vbap occurs 0,
  vbeln  like vbap-vbeln,             " no. pedido
  name1  like kna1-name1,             " nombre del cliente
  kunnr  like vbakuk-kunnr,           " no. de clientes (solicitante)
  kwmeng like vbap-kwmeng,            " cantidad de pedido
  kbmeng like vbap-kbmeng,            " cantidad confirmada
  lsmeng like vbap-lsmeng,            " Cantidad por entregar
  meins  like vbap-meins,             " unidad de medida
  audat  like vbak-audat,             " fecha de pedido
  vkorg  like vbakuk-vkorg,           " org. de ventas
  vtweg  like vbakuk-vtweg,           " canal de distribucion
  spart  like vbakuk-spart,           " Sector
  vkbur  like vbakuk-vkbur,           " oficina de venta
end of tab_vbap.

* ---------- Variables ---------- *
data:
  tkwmeng like vbap-kwmeng,
  tkbmeng like vbap-kbmeng,
  tlsmeng like vbap-lsmeng,
  band type i value 0.
*---------------------------------------------------------------------*
*            INICIA PROGRAMA
*---------------------------------------------------------------------*
start-of-selection.
  perform proceso.
  perform lectura.
end-of-selection.
top-of-page.
perform imprime_encabezado.
*&---------------------------------------------------------------------*
*&      Form  PROCESO
*&---------------------------------------------------------------------*
form proceso.
  refresh tab_vbap.
* Seleccionar los registros que estan dentro de los parámetros
  select * into corresponding fields of table tab_vbap from vbakuk
  where lfstk in ('A', 'B')
*{   INSERT         SPPK900094                                        2
  and   gbstk ne 'C'
*}   INSERT
  and   audat in p_audat                " Fecha
  and   vkorg in p_vkorg                " Organización de Vta.
  and   vtweg in p_vtweg                " canal dist.
  and   spart in p_spart                " sector
  and   vkbur in p_vkbur.               " Oficina de Ventas
  if sy-subrc = 0.
* Busca el Detalle del Documento encontrado
    loop at tab_vbap.
      select * from vbap
        where vbeln eq tab_vbap-vbeln       " Número de Pedido
*{   REPLACE        SPPK900094                                        4
*\        and   abgru = '  '.
        and   abgru = '  '
*}   REPLACE
*{   INSERT         SPPK900094                                        3
        and   gbsta ne 'C'.
*}   INSERT
        if sy-subrc = 0.
* Valida que la posición del registro tenga un status de oferta o pedido
* si SY-SUBRC <> 0 quiere decir que esta pendiente de surtir el pedido
          select single * from vbfa
          where vbelv   = vbap-vbeln
          and   posnv   = vbap-posnr.
          if sy-subrc <> 0.
             move:
            vbap-meins  to tab_vbap-meins.
            tab_vbap-kwmeng = tab_vbap-kwmeng + vbap-kwmeng.
            tab_vbap-kbmeng = tab_vbap-kbmeng + vbap-kbmeng.
            tab_vbap-lsmeng = tab_vbap-lsmeng + vbap-lsmeng.
* Busca nombre del cliente.
            select single * from kna1
            where kunnr = tab_vbap-kunnr.
            if sy-subrc = 0.
              move kna1-name1 to tab_vbap-name1.
            else.
              tab_vbap-name1 = '????????????'.
            endif.
* adiciona el registro.
            modify tab_vbap.
          else.
            move:
            vbap-meins  to tab_vbap-meins.
* Cantidad Pedida
            tab_vbap-kwmeng = tab_vbap-kwmeng + vbap-kwmeng.
*            tab_vbap-kbmeng = tab_vbap-kbmeng + vbap-kbmeng.
*            tab_vbap-lsmeng = tab_vbap-lsmeng + vbap-lsmeng.
*            tab_vbap-kwmeng = tab_vbap-kwmeng - vbfa-rfmng.
* Cantidad Entregada
            tab_vbap-kbmeng = tab_vbap-kbmeng + vbfa-rfmng.
* Cantidad Faltante
            tab_vbap-lsmeng = tab_vbap-kwmeng - vbfa-rfmng.
* Busca nombre del cliente.
            select single * from kna1
            where kunnr = tab_vbap-kunnr.
            if sy-subrc = 0.
              move kna1-name1 to tab_vbap-name1.
            else.
              tab_vbap-name1 = '????????????'.
            endif.
* adiciona el registro.
            modify tab_vbap.
          endif.

        else.
*{   INSERT         SPPK900094                                        1
*         delete tab_vbap.
*}   INSERT
          write:/10 'TODOS LOS PEDIDOS ESTAN CONFIRMADOS'.
        endif.
      endselect.
    endloop.
  else.
    write:/10 'TODOS LOS PEDIDOS ESTAN CONFIRMADOS'.
  endif.
endform.
*&---------------------------------------------------------------------*
*&      Form  LECTURA
*&---------------------------------------------------------------------*
form lectura.
  sort tab_vbap by kunnr vbeln.     " CLIENTE DOCUMENTO
  loop at tab_vbap.
*{   INSERT         SPPK900094                                        1
      if tab_vbap-kwmeng ne 0.
*}   INSERT
      format color 2.
      format intensified on.
      write: /5 tab_vbap-vbeln,                    " pedido
              16 tab_vbap-kunnr,                   " cliente
              28 tab_vbap-name1(30).               " nombre cliente
      format intensified off.
      write:  59 tab_vbap-kwmeng,                  " cant. pedido
              77 tab_vbap-kbmeng,                  " cant. confirmada
              95 tab_vbap-lsmeng,                  " cant. faltante
             114 tab_vbap-meins,                   " unidad de medida
             119 tab_vbap-audat.                   " fecha del pedido
      format intensified on.
    at last.
      sum.
      format color 3.
      reserve 4 lines.
      skip.
      write: sy-uline.
      write: /1 'T O T A L : ',
             59 tab_vbap-kwmeng,
             77 tab_vbap-kbmeng,
             95 tab_vbap-lsmeng,
            119 '          '.
      write: / sy-uline.
    endat.
*{   INSERT         SPPK900094                                        2
    ENDIF.
*}   INSERT
  endloop.
endform.                    " LECTURA
*&---------------------------------------------------------------------*
*&      Form  IMPRIME_ENCABEZADO
*&---------------------------------------------------------------------*
form imprime_encabezado.
  set left scroll-boundary column 60.
  format color 4.
  write: 57   'PEDIDOS PENDIENTES'.
  write: 119  '          '.
  write: / sy-uline.
  write:  sy-uline.
  format color 1.
  skip.
  write: 2 'No. de',           "No. de pedido
        16 'Cliente',
        28 'Nombre',                   " de cliente
        69 'Cantidad',                 " pedida
        86 'Cantidad',                 " Confirmada
       100 'Cantidad',                 " Faltante
       114 'U/M',                      " unidad de medida
       119 '  Fecha   '.               " de pedido
  write: /2 'pedido',                  " de pedido
         16 ' ',
         27 ' ',
         28 'de cliente',              " nombre
         70 'pedida',                  " cantidad
         85 'confirmada',              " cantidad
        105 'faltante',                " cantidad
        114 ' ',                       " Unidad de medida
        119 'de pedido '.              " Fecha
  skip.
endform.                    " IMPRIME_ENCABEZADO
