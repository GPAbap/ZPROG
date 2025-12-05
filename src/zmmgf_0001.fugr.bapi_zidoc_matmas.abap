FUNCTION bapi_zidoc_matmas.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IM_MATNR) TYPE  MARA-MATNR OPTIONAL
*"     VALUE(IM_WERKS) TYPE  MARC-WERKS OPTIONAL
*"----------------------------------------------------------------------
  DATA:
    vl_werks TYPE marc-werks.

*{   REPLACE        SPDK902957                                        1
*\  IF im_werks = '0310'.
  IF im_werks = 'PP01'. " 05.05.2022 OLOPEZ
*}   REPLACE
    PERFORM f_bloq_unbloq USING im_matnr.

    SELECT SINGLE werks INTO vl_werks
      FROM marc
     WHERE matnr = im_matnr
       AND werks = im_werks.

    IF sy-subrc = 0.
      SUBMIT rbdsemat
        WITH mestyp  EQ 'MATMAS'
        WITH logsys  EQ 'MIIPPAEVOL'
        WITH matsel  EQ im_matnr
        WITH sendall EQ 'X'
         AND RETURN.
    ENDIF.

  ENDIF.

ENDFUNCTION.
