*&---------------------------------------------------------------------*
*& Include          ZMM_IMP_REM_TRAS_PV_JHV_TOP
*&---------------------------------------------------------------------*
 DATA: vl_cantidad_mh TYPE char10, vl_valor TYPE string,
       vl_zona        TYPE string,
       vl_posnr       TYPE posnr,
       vl_tdname      TYPE tdobname.

 DATA: vl_cant10     TYPE char20,vl_cant20 TYPE char20,vl_cant30 TYPE char20,
       vl_pp10       TYPE char20,vl_pp20 TYPE char20,vl_pp30 TYPE char20,
       vl_pigmento10 TYPE char20,vl_pigmento20 TYPE char20,vl_pigmento30 TYPE char20,
       vl_zona10     TYPE char20,vl_zona20 TYPE char20,vl_zona30 TYPE char20,
       vl_caseta10   TYPE char20,vl_caseta20 TYPE char20,vl_caseta30 TYPE char20,
       vl_edad10     TYPE char20,vl_edad20 TYPE char20,vl_edad30 TYPE char20,
       vl_lote10     TYPE charg_d,vl_lote20 TYPE charg_d,vl_lote30 TYPE charg_d,
       vl_vtext10    TYPE vtext, vl_vtext20 TYPE vtext, vl_vtext30 TYPE vtext,
       lv_timestamp  TYPE char10,
       vl_total_aves TYPE menge_d,
       vl_peso_prom  TYPE zpesop.


 DATA: l_function TYPE rs38l_fnam.
 DATA gv_bascula TYPE tdbool.

 DATA it_remision TYPE STANDARD TABLE OF zsd_st_data_cli.
 DATA it_bascula  TYPE STANDARD TABLE OF zbascula_rem_pv.

 SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001 NO INTERVALS.
   PARAMETERS p_belnr TYPE ebeln.
 SELECTION-SCREEN END OF BLOCK b1.
