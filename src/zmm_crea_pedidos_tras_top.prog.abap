*&---------------------------------------------------------------------*
*& Include zmm_crea_pedidos_tras_top
*&---------------------------------------------------------------------*

TYPES: type_excel_tab TYPE STANDARD TABLE OF alsmex_tabline. "Tabla para el excel

DATA: it_outtable TYPE STANDARD TABLE OF zmm_st_layexceltras WITH NON-UNIQUE SORTED KEY pk COMPONENTS  lote_sap almacen centro_sum,
      it_auxtable TYPE STANDARD TABLE OF  zmm_st_layexceltras WITH NON-UNIQUE SORTED KEY pk COMPONENTS  lote_sap almacen centro_sum.

DATA: t_mrp_stock_detail TYPE bapi_mrp_stock_detail,
      t_mrp_list         TYPE bapi_mrp_list,
      t_mrp_ind_lines    type STANDARD TABLE OF bapi_mrp_ind_lines,
      t_return           TYPE STANDARD TABLE OF bapiret2,
      wmdvsx             TYPE STANDARD TABLE OF bapiwmdvs,
      wmdvex             TYPE STANDARD TABLE OF bapiwmdve.

data:   ls_log     TYPE zppes_alv_return,
        it_log type STANDARD TABLE OF zppes_alv_return.

DATA:       vl_ok.

TYPES: BEGIN OF st_inventario,
         material     TYPE matnr_d,
         lote         TYPE charg_d,
         almacen      TYPE lgort_d,
         caseta       type zcaseta,
         centro_recep TYPE werks_d,
         centro_sum   TYPE werks_d,
         cant_pzas    TYPE menge_d,
         unit_pzas    TYPE meins,
         peso         TYPE menge_d,
         p_prom       TYPE menge_d,
         unit         TYPE meins,
         inventario1  TYPE menge_d,
         inventario2  TYPE menge_d,
         inventariot  TYPE menge_d,
         genera_entrada type c,
         pigmento type zpigm,
       END OF st_inventario.

DATA it_inventario TYPE STANDARD TABLE OF st_inventario.

PARAMETERS: file_nm TYPE localfile.
