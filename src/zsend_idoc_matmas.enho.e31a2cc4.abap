"Name: \PR:SAPLMGMU\EX:LMGMUF01_08\EI
ENHANCEMENT 0 ZSEND_IDOC_MATMAS.
    IF herkunft = herkunft_dial AND rmmg2-flg_plm IS INITIAL.
      IF rmmg2-call_func IS INITIAL.   "//br020196 -  bei Aufruf durch
        " andere Applik. CALL FUNKT.
        GET PARAMETER ID 'MATSYNC' FIELD matsync. "wk/99a
        IF matsync IS INITIAL.         "wk/99a
          COMMIT WORK.                 "wk/99a
        ELSE.                          "wk/99a
          COMMIT WORK AND WAIT.        "wk/99a
        ENDIF.                         "wk/99a
      ENDIF.                           " COMMIT durch Aufrufer
    ENDIF.

*DATA:
*  vl_matnr TYPE mara-matnr.
*
*  vl_matnr = rmmg1-matnr.

*   Por problema red Porres entre MII y S4 QAS
*   Si esta en blanco o no existe flag, no ejecuta Función
    SELECT SINGLE zvalor
      INTO @DATA(lv_valor)
      FROM zcons_pp
     WHERE zprogram   = 'LMGMUF01'
       AND zcampo     = 'IDOC'
       AND zconstante = 'SEND_MATMAS'
       AND zvalor     = @abap_true.
    IF sy-subrc = 0.

*** Envio de IDOC
      CALL FUNCTION 'BAPI_ZIDOC_MATMAS'
        EXPORTING
          im_matnr = rmmg1-matnr
          im_werks = rmmg1-werks.

    ENDIF.

ENDENHANCEMENT.
