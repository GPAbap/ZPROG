@AbapCatalog.sqlViewName: 'ZCDSTRA019'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Core Data Services 4 zrsdtra019'

define view zcds_zrsdtra019_JHV
//with parameters 
//    p_vkorg   : vkorg,
//    p_erdat_i : erdat,
//    p_erdat_f : erdat
    
as   select   
              @EndUserText.label: 'Fecha Entrega'
              likp.erdat,
              @EndUserText.label: 'Centro'
              lips.werks, 
              @EndUserText.label: 'P. Exped.'
              likp.vstel,
              @EndUserText.label: 'Org. Ventas'
              likp.vkorg,  
              @EndUserText.label: 'Solicitante'
              likp.kunag,
              @EndUserText.label: 'Nom. Solicitante'
              kna1.name1,
              @EndUserText.label: 'Destinatario'
              likp.kunnr, 
              @EndUserText.label: 'Población'
              kna1.ort01 as poblacion,
              @EndUserText.label: 'Destino'
              concat_with_space( kna1.ort02, kna1.regio, 1  ) as Destino,
              @EndUserText.label: 'Material'
              lips.matnr, 
              @EndUserText.label: 'Num. Entrega'
              likp.vbeln,
              @EndUserText.label: 'Pedido'
              @EndUserText.quickInfo: 'Pedido'
              lips.vgbel,
              @EndUserText.label: 'Cant. Entregada'
              //ceil((cast(lips.ntgew as abap.fltp) / 1000.00)) as ntgew,
              //division(lips.ntgew,1000,3) as ntgew,
              lips.lfimg as cantent,
              @EndUserText.label: 'U.M.'
              'T' as UM,
              @EndUserText.label: 'Cant. Embarcada'
               '0.00' as btgew_emb,
              @EndUserText.label: 'Fec. Llegada Uni.'
              likp.tddat,
              @EndUserText.label: 'Hr. Llegada Uni.'
              likp.tduhr,
              @EndUserText.label: 'Fec. Ini. Carga'
              likp.lddat,
              @EndUserText.label: 'Hr. Ini. Carga'
              likp.lduhr,
              @EndUserText.label: 'Fec. Fin. Carga'
              likp.wadat,
              @EndUserText.label: 'Hr. Fin. Carga'
              likp.wauhr,
              @EndUserText.label: 'Fec. Sal. Carga'
              cast('01.01.1999' as abap.dats) as fecsalca,
              @EndUserText.label: 'Hr. Sal. Carga'
              cast('12:00:00' as abap.tims) as hrsalca,
              @EndUserText.label: 'F. Est. Lllega Cte'
              likp.lfdat,
              @EndUserText.label: 'Hr. Est. Lllega Cte'
              likp.lfuhr,
              @EndUserText.label: 'F. Real Lllega Cte'
              cast('01.01.1999' as abap.dats) as fecrecte,
              @EndUserText.label: 'Hr. Real Lllega Cte'
              cast('12:00:00' as abap.tims) as hrrecte,
              @EndUserText.label: 'Operador'
              'Nombre del Operador                                                  ' as Operador,
              @EndUserText.label: 'Tipo Vehiculo'
              'Tipo de Vehiculo' as tipoveh,
              @EndUserText.label: 'Placa Unidad'
              'Placas de la unidad' as placasveh,
              @EndUserText.label: 'Placa Caja'
              'Placas de la caja' as placascaj,
              @EndUserText.label: 'Carta Porte'
              'Carta Porte' as cartaporte,
              @EndUserText.label: 'Cant. Picking'
              lips.lfimg,
//              @EndUserText.label: 'Cant. Puerto'
//              '0.00' as cantpuerto,
              @EndUserText.label: 'Diferencia'
              lips.lfimg as difer,
              @EndUserText.label: 'Obs. Bodega'
              'Observaciones de Bodega                                                                                                      ' as obsbod,
              @EndUserText.label: 'Obs. Venta'
              'Observaciones de Cliente                                                                                                      ' as obscte
//CASE WHEN SUBSTRING( likp~KUNAG,1,4 ) = '0000' THEN SUBSTRING( likp~KUNAG,7,4 ) else likp~KUNAG end as KUNAG ,
from  likp
inner join lips on likp.vbeln = lips.vbeln
inner join kna1  on kna1.kunnr = likp.kunnr
left outer join lfa1 on lfa1.lifnr = likp.lifnr
//where  likp.vkorg = $parameters.p_vkorg      
//AND    likp.kunag IN @kunag_p      
//and    likp.erdat between $parameters.p_erdat_i and $parameters.p_erdat_f     
//AND    lips.werks IN @werks_p     
//AND    lips.matnr IN @matnr_p     
//AND zent.lifnr IN @lifnr_p        
