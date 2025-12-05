FUNCTION bapi_zhu_packing_refresh.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IF_SOFORTAUFTRAG) TYPE  XFELD DEFAULT SPACE
*"     VALUE(IF_GET_HUS) TYPE  XFELD OPTIONAL
*"     VALUE(IF_DEQUEUE) TYPE  XFELD OPTIONAL
*"     VALUE(IT_VENUM) TYPE  HUM_VENUM_T OPTIONAL
*"  TABLES
*"      ET_VEKP STRUCTURE  VEKPVB OPTIONAL
*"      ET_VEPO STRUCTURE  VEPOVB OPTIONAL
*"----------------------------------------------------------------------

  DATA:
    tl_vekp TYPE vsep_t_vekp,
    tl_vepo TYPE vsep_t_vepo.

  CALL FUNCTION 'HU_PACKING_REFRESH'
    EXPORTING
      if_sofortauftrag = if_sofortauftrag
      if_get_hus       = if_get_hus
      if_dequeue       = if_dequeue
      it_venum         = it_venum
    IMPORTING
      et_vekp          = tl_vekp
      et_vepo          = tl_vepo.

  et_vekp[] = tl_vekp[].
  et_vepo[] = tl_vepo[].

ENDFUNCTION.
