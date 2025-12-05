FUNCTION ZMM_CALC_SOLPED_STKMIN1.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(STOCK_MINIMO) TYPE  BSTMI
*"     REFERENCE(STOCK_LIBRE) TYPE  LABST
*"     REFERENCE(STOCK_TRANSITO) TYPE  TRAME
*"     REFERENCE(STOCK_CONSIG_LIB) TYPE  KLABS
*"     REFERENCE(STOCK_CONSIG_TRANS) TYPE  BEBSK
*"     REFERENCE(RESERVAS) TYPE  RESBZ
*"     REFERENCE(CANTIDAD_CONFIRMADA) TYPE  BAMNG
*"  EXPORTING
*"     REFERENCE(RCANTIDAD_CONFIRMADA) TYPE  BAMNG
*"     REFERENCE(CREAR_SOLPED) TYPE  BOE_BOOL
*"     REFERENCE(RSTOCK_REAL) TYPE  LABST
*"--------------------------------------------------------------------
  DATA: vl_stklibrecalc TYPE labst,
        vl_stockReal    TYPE labst,
        vl_solpedReal   TYPE bamng,
        vl_crear_solped,
        vl_pedir_stkmin.

  vl_stklibrecalc = stock_libre - stock_minimo.
  vl_stockreal = vl_stklibrecalc + stock_transito + stock_consig_lib
                 + stock_consig_trans - reservas.
"Si es stock real es negativo, se complementara el restante para cubrir el minimo.
  IF vl_stklibrecalc LT 0.
    vl_pedir_stkmin = abap_true.
  ELSE.
    vl_pedir_stkmin = space.
  ENDIF.


vl_solpedreal = vl_stockreal - cantidad_confirmada.
*  IF cantidad_confirmada LE  abs( vl_stockreal ).
*    vl_crear_solped = abap_true.
*  ELSE.
*    vl_crear_solped = space.
*  ENDIF.



  "calculo de la cantidad real de Solped
  "=SI([@[Crear solped?]]="SI",SI(J2="SI",ABS(G2-F2),ABS(G2-F2)),0)

  IF vl_solpedreal lt 0.
    rcantidad_confirmada = abs( vl_solpedreal ).
    vl_crear_solped = abap_true.
  ELSE.
    rcantidad_confirmada = 0.
  ENDIF.
  crear_solped = vl_crear_solped.
  rstock_real = vl_stockreal.

ENDFUNCTION.
