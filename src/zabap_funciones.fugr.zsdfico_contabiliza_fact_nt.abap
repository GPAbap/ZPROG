FUNCTION zsdfico_contabiliza_fact_nt.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_FECHA) TYPE  SY-DATUM
*"----------------------------------------------------------------------
  TYPES: BEGIN OF st_facturas,
           vbeln TYPE vbeln,
           vkorg TYPE vkorg,
           vtweg TYPE vtweg,
           fkdat TYPE fkdat,
           erzet TYPE erzet,
           buchk TYPE buchk,
         END OF st_facturas.

  DATA: it_zfacturas TYPE STANDARD TABLE OF zsdfi_tt_factura WITH NON-UNIQUE SORTED KEY pk COMPONENTS vbeln,
        wa_zfacturas LIKE LINE OF it_zfacturas,
        it_facturas  TYPE STANDARD TABLE OF st_facturas WITH NON-UNIQUE SORTED KEY pk COMPONENTS vbeln.

  DATA: lv_MSGV1 TYPE msgv1, lv_fecha TYPE sy-datum, lv_fecha_cont type sy-datum,
        lv_hora_cont type sy-uzeit.

  IF i_fecha IS INITIAL.
    lv_fecha = sy-datum.
  ELSE.
    lv_fecha = i_fecha.
  ENDIF.

  SELECT vbeln, vkorg, vtweg, fkdat, erzet, buchk
    INTO TABLE @it_facturas
    FROM vbrk
  WHERE fkdat EQ @lv_fecha.

  SELECT
    vbeln
  INTO TABLE @DATA(it_exist_fact)
     FROM zsdfi_tt_factura
  FOR ALL ENTRIES IN @it_facturas
  WHERE vbeln EQ @it_facturas-vbeln.

  LOOP AT it_facturas INTO DATA(wa_facturas).
    CLEAR wa_zfacturas.

    READ TABLE it_facturas into data(wa_zfac) WITH KEY vbeln = wa_facturas-vbeln.
    IF sy-subrc eq 0.
       if wa_zfac-buchk eq 'A'.
         clear lv_fecha_cont.
         clear lv_hora_cont.
       else.
         lv_fecha_cont = wa_facturas-fkdat.
         lv_hora_cont = wa_facturas-erzet.
       ENDIF.

       TRY.
          UPDATE zsdfi_tt_factura set buchk = @wa_facturas-buchk, fecha_contab = @lv_fecha_cont,
                                   hora_contab = @lv_hora_cont where vbeln = @wa_facturas-vbeln.
       CATCH cx_sql_exception.

       ENDTRY.

    ENDIF.



  ENDLOOP.


  "se registran todas las facturas
  DATA(it_no_contab) = it_facturas[]. "solo no contables
*  it_facturas = FILTER #( it_facturas USING KEY pk EXCEPT IN it_exist_fact WHERE vbeln = vbeln ).
*
*  CLEAR wa_facturas.
*
*  LOOP AT it_facturas INTO wa_facturas.
*
*    wa_zfacturas-vbeln = wa_facturas-vbeln.
*    wa_zfacturas-vkorg = wa_facturas-vkorg.
*    wa_zfacturas-vtweg = wa_facturas-vtweg.
*    wa_zfacturas-fkdat = wa_facturas-fkdat.
*    wa_zfacturas-buchk = wa_facturas-buchk.
*    wa_zfacturas-contab_job = abap_false.
*    wa_zfacturas-fecha_contab = wa_facturas-fkdat.
*    wa_zfacturas-hora_contab = wa_facturas-erzet.
*
*    APPEND wa_zfacturas TO it_zfacturas.
*
*  ENDLOOP.
*
*  IF it_zfacturas IS NOT INITIAL.
*    INSERT zsdfi_tt_factura FROM TABLE  it_zfacturas.
*  ENDIF.

  DELETE it_no_contab WHERE buchk NE 'A'.

  LOOP AT it_no_contab INTO DATA(wa_no_contab).
    CLEAR lv_msgv1.
    PERFORM contabiliza_fact USING wa_no_contab-vbeln
                             CHANGING lv_msgv1     .
    CLEAR wa_zfacturas.
    MOVE-CORRESPONDING wa_no_contab TO wa_zfacturas.

    IF lv_msgv1 IS NOT INITIAL.
      wa_zfacturas-log1 = lv_msgv1.
    ELSE.
      wa_zfacturas-log1 = 'Contabilizado satisfactoriamente'.
      wa_zfacturas-fecha_contab = sy-datum.
      wa_zfacturas-hora_contab = sy-timlo.
      wa_zfacturas-contab_job = abap_true.
      wa_zfacturas-buchk = 'C'.
    ENDIF.

    MODIFY zsdfi_tt_factura FROM wa_zfacturas.
  ENDLOOP.





ENDFUNCTION.

FORM contabiliza_fact USING p_vbeln TYPE vbeln
                      CHANGING p_msgv1.
  DATA lv_cadena TYPE string.

  CONSTANTS lc_activity_03 TYPE char2 VALUE '03'.           "2834918
  DATA ls_vbrk   TYPE vbrk.                                 "2834918
  DATA ls_vbuk   TYPE vbuk.                                 "2834918
  DATA lt_xkomv  TYPE STANDARD TABLE OF komv.               "2834918
  DATA lt_xvbpa  TYPE STANDARD TABLE OF vbpavb.             "2834918
  DATA lt_xvbrp  TYPE STANDARD TABLE OF vbrpvb.             "2834918
  DATA lt_xvbrk  TYPE TABLE OF vbrkvb.                      "2834918
  DATA lt_vbrk   TYPE STANDARD TABLE OF vbrk.               "2834918
  DATA lt_xkomfk TYPE STANDARD TABLE OF komfk.              "2834918
  DATA lt_xthead TYPE STANDARD TABLE OF theadvb.            "2834918
  DATA lt_xvbfs  TYPE STANDARD TABLE OF vbfs.               "2834918
  DATA lt_xvbrl  TYPE STANDARD TABLE OF vbrlvb.             "2834918
  DATA lt_xvbss  TYPE STANDARD TABLE OF vbss.               "2834918
                                                            "2834918
*   Release lock of billing doc.                          "2834918
  CALL FUNCTION 'DEQUEUE_EVVBRKE'                     "2834918
    EXPORTING                                         "2834918
      mandt     = sy-mandt                            "2834918
      vbeln     = p_vbeln                  "2834918
      _scope    = '3'                                 "2834918
      _synchron = 'X'                                 "2834918
    EXCEPTIONS                                        "2834918
      OTHERS    = 1.                                  "2834918
                                                            "2834918
  SELECT SINGLE * INTO ls_vbrk FROM vbrk                    "2834918
    WHERE vbeln = p_vbeln.                                  "2834918
                                                            "2834918
  IF sy-subrc = 0.                                          "2834918
    CALL FUNCTION 'RV_INVOICE_DOCUMENT_READ'          "2834918
      EXPORTING                                       "2834918
        vbrk_i        = ls_vbrk                       "2834918
        activity      = lc_activity_03                "2834918
      IMPORTING                                       "2834918
        vbrk_e        = ls_vbrk                       "2834918
        vbuk_e        = ls_vbuk                       "2834918
      TABLES                                          "2834918
        xkomv         = lt_xkomv                      "2834918
        xvbpa         = lt_xvbpa                      "2834918
        xvbrk         = lt_xvbrk                      "2834918
        xvbrp         = lt_xvbrp                      "2834918
      EXCEPTIONS                                      "2834918
        no_authority  = 1                             "2834918
        error_message = 2                             "2834918
        OTHERS        = 3.                            "2834918
    IF sy-subrc = 0.                                        "2834918
      APPEND ls_vbrk TO lt_vbrk.                            "2834918
      CALL FUNCTION 'SD_INVOICE_RELEASE_TO_ACCOUNT'   "2834918
        EXPORTING                                     "2834918
          with_posting = 'B'                          "2834918
        TABLES                                        "2834918
          it_vbrk      = lt_vbrk                      "2834918
          xkomfk       = lt_xkomfk                    "2834918
          xkomv        = lt_xkomv                     "2834918
          xthead       = lt_xthead                    "2834918
          xvbfs        = lt_xvbfs                     "2834918
          xvbpa        = lt_xvbpa                     "2834918
          xvbrk        = lt_xvbrk                     "2834918
          xvbrp        = lt_xvbrp                     "2834918
          xvbrl        = lt_xvbrl                     "2834918
          xvbss        = lt_xvbss.                    "2834918
      "log
      LOOP AT lt_xvbfs INTO DATA(wa_log) WHERE msgty = 'E'.
        CONCATENATE wa_log-msgty wa_log-msgv1 INTO lv_cadena SEPARATED BY '-'.
        p_msgv1 = lv_cadena.
      ENDLOOP.
    ENDIF.                                                  "2834918
  ENDIF.                                                    "2834918

*LOOP AT lt_xvbfs where msgty.
*
*ENDLOOP.

ENDFORM.
