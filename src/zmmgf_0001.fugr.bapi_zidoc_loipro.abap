FUNCTION bapi_zidoc_loipro.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IM_AUFNR) TYPE  CAUFV-AUFNR OPTIONAL
*"     VALUE(IM_MATNR) TYPE  CAUFV-PLNBEZ OPTIONAL
*"     VALUE(IM_WERKS) TYPE  CAUFV-WERKS OPTIONAL
*"----------------------------------------------------------------------

  DATA:
    s_aufnr TYPE RANGE OF aufnr,
    s_matnr TYPE RANGE OF matnr,
    s_werks TYPE RANGE OF werks,
    w_aufnr LIKE LINE OF s_aufnr,
    w_matnr LIKE LINE OF s_matnr,
    w_werks LIKE LINE OF s_werks.

  DATA:
*{   REPLACE        SPDK902957                                        1
*\    vl_werks TYPE caufv-werks VALUE '0310'.
    vl_werks TYPE caufv-werks VALUE 'PP01'. " 05.05.2022 OLOPEZ
*}   REPLACE

  CONSTANTS:
    c_eq     TYPE c LENGTH 2 VALUE 'EQ',
    c_i      TYPE c LENGTH 1 VALUE 'I'.

  DATA:
    vl_mestyp  TYPE tbdme-mestyp  VALUE 'LOIPRO',
    vl_opt_sys TYPE tbdlst-logsys VALUE 'MIIPPAEVOL'.

  IF im_werks = vl_werks.
    CLEAR: w_aufnr,s_aufnr[],
    w_matnr,s_matnr[],
    w_werks,s_werks[].

    w_aufnr-low    = im_aufnr.
    w_matnr-low    = im_matnr.
    w_werks-low    = im_werks.
    w_aufnr-sign   = w_matnr-sign   = w_werks-sign   = c_i.
    w_aufnr-option = w_matnr-option = w_werks-option = c_eq.

    APPEND: w_aufnr TO s_aufnr,
    w_matnr TO s_matnr,
    w_werks TO s_werks.

    PERFORM f_bloq_unbloq USING im_aufnr.

    SELECT SINGLE werks INTO vl_werks
      FROM caufv
     WHERE aufnr  = im_aufnr
       AND plnbez = im_matnr
       AND werks  = vl_werks.

    IF sy-subrc = 0.

      SUBMIT rcclord
        WITH s_aufnr IN s_aufnr
        WITH s_matnr IN s_matnr
        WITH s_werks IN s_werks
        WITH opt_sys = vl_opt_sys
        WITH mestyp  = vl_mestyp
         AND RETURN.

      MESSAGE s398(00) WITH 'La orden' im_aufnr 'se envio vía idoc'.

    ENDIF.

  ENDIF.

ENDFUNCTION.
