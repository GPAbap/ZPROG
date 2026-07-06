@Analytics.dataCategory: #CUBE
@AbapCatalog.sqlViewName: 'ZICECOACT'
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Importe real por centro de costo'
@Metadata.ignorePropagatedAnnotations: true
define view ZI_CECO_ACTUAL
  as select from acdoca
{
  key rldnr as Ledger,
  key racct as GLAccount,
  key kokrs  as ControllingArea,
  key rbukrs as CompanyCode,
  key rcntr  as CostCenter,
  key gjahr  as FiscalYear,
  key poper  as FiscalPeriod,

      rtcur  as Currency,

      @DefaultAggregation: #SUM
      hsl    as ImporteReal
}
where
      rcntr <> ''
  and gjahr <> '0000'
