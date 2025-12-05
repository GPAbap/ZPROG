"Name: \FU:CO_ZV_ORDER_POST\SE:END\EI
ENHANCEMENT 0 ZCO_ZV_ORDER_POST.
*** Se activa Versión
IF sy-tcode = 'CO01'
OR sy-tcode = 'CO02'.

  COMMIT WORK.

  DATA:
    tl_caufv TYPE STANDARD TABLE OF caufv,
    sl_caufv TYPE caufv.

*    WAIT UP TO 5 SECONDS.
  IF caufvd_num[] IS NOT INITIAL.

    SELECT * INTO TABLE tl_caufv
      FROM caufv
       FOR ALL ENTRIES IN caufvd_num
     WHERE aufnr = caufvd_num-aufnr_neu.

    IF sy-subrc = 0.
      SORT tl_caufv BY aufnr ASCENDING.
      LOOP AT tl_caufv INTO sl_caufv.

        CALL FUNCTION 'BAPI_ZIDOC_LOIPRO'
          EXPORTING
            im_aufnr = sl_caufv-aufnr
            im_matnr = sl_caufv-plnbez
            im_werks = sl_caufv-werks.

        COMMIT WORK.

      ENDLOOP.

    ENDIF.

  ENDIF.
  IF sy-tcode = 'CO02'.
    LOOP AT tl_caufv INTO sl_caufv.
      IF sl_caufv-werks = 'PA01'.
        WAIT UP TO 5 SECONDS.
        CALL FUNCTION 'ZMAQUILA_ORDEN'
          EXPORTING
            aufnr = sl_caufv-aufnr.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDIF.


ENDENHANCEMENT.
