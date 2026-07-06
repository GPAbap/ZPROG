@Analytics.dataCategory: #CUBE
@AbapCatalog.sqlViewName: 'ZICECOPLAN'
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Importe plan por centro de costo'
@Metadata.ignorePropagatedAnnotations: true
define view ZI_CECO_PLAN  as select from acdocp
{
  key rldnr  as Ledger,
  key racct as GLAccount,
  key kokrs  as ControllingArea,
  key rbukrs as CompanyCode,
  key rcntr  as CostCenter,
  key ryear  as FiscalYear,
  key poper  as FiscalPeriod,
 
      rhcur  as Currency,

      @DefaultAggregation: #SUM
      hsl    as ImportePlan
}
where
      rcntr <> ''
  and ryear <> '0000'
