FUNCTION bapi_zcohu_hu_goods_issue.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(POST_ALL) TYPE  XFELD DEFAULT 'X'
*"     VALUE(I_BLDAT) TYPE  MKPF-BLDAT DEFAULT SY-DATUM
*"     VALUE(I_BUDAT) TYPE  MKPF-BUDAT DEFAULT SY-DATUM
*"     VALUE(I_STORNO) TYPE  XFELD OPTIONAL
*"  TABLES
*"      IT_HUCONS STRUCTURE  VHUMI_CONS OPTIONAL
*"      ET_SCOMP STRUCTURE  RCOMP OPTIONAL
*"      IT_HUMI_QTY STRUCTURE  VHUMI_QTY OPTIONAL
*"      IT_HUM_KOMMI STRUCTURE  HUM_KOMMI OPTIONAL
*"  EXCEPTIONS
*"      NO_VALID_HU
*"      INVALID_VALUES
*"      INCOMPLETE_VALUES
*"      POSTING_ERROR
*"      TEMP_ERROR
*"----------------------------------------------------------------------

  CALL FUNCTION 'COHU_HU_GOODS_ISSUE'
    EXPORTING
      post_all          = post_all
      i_bldat           = i_bldat
      i_budat           = i_budat
      i_storno          = i_storno
    TABLES
      it_hucons         = it_hucons
      et_scomp          = et_scomp
      it_humi_qty       = it_humi_qty
      it_hum_kommi      = it_hum_kommi
    EXCEPTIONS
      no_valid_hu       = 1
      invalid_values    = 2
      incomplete_values = 3
      posting_error     = 4
      temp_error        = 5
      OTHERS            = 6.

  IF sy-subrc <> 0.

    CASE sy-subrc.
      WHEN 1.
        RAISE no_valid_hu.
      WHEN 2.
        RAISE invalid_values.
      WHEN 3.
        RAISE incomplete_values.
      WHEN 4.
        RAISE posting_error.
      WHEN 5.
        RAISE temp_error.
      WHEN OTHERS.
    ENDCASE.

  ENDIF.




ENDFUNCTION.
