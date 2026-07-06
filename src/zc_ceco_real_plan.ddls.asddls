@AbapCatalog.sqlViewName: 'ZCCECORP'
@Analytics.dataCategory: #CUBE
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Real vs Plan por centro de costo'
@Metadata.ignorePropagatedAnnotations: true
@OData.publish: true
define view ZC_CECO_REAL_PLAN as select from ZI_CECO_ACTUAL as Real
    left outer join ZI_CECO_PLAN as Plan
      on  Real.ControllingArea = Plan.ControllingArea
      and Real.CompanyCode     = Plan.CompanyCode
      and Real.CostCenter      = Plan.CostCenter
      and Real.FiscalYear      = Plan.FiscalYear
      and Real.FiscalPeriod    = Plan.FiscalPeriod
{
 key  Real.Ledger,
  key Real.GLAccount,
  key Real.ControllingArea,
  key Real.CompanyCode,
  key Real.CostCenter,
  key Real.FiscalYear,
  key Real.FiscalPeriod,
 
      Real.Currency,
      
      @EndUserText.label: 'Importe Real'
      @Semantics.amount.currencyCode: 'Currency'
      @DefaultAggregation: #SUM
      Real.ImporteReal,
      
      @EndUserText.label: 'Importe Plan'
      @Semantics.amount.currencyCode: 'Currency'
      @DefaultAggregation: #SUM
      Plan.ImportePlan,
      
      @Semantics.amount.currencyCode: 'Currency'
      @DefaultAggregation: #SUM
      Real.ImporteReal - Plan.ImportePlan as DifferenceAmount
}
