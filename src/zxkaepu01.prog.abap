IF cs_record-obart = 'KS'.

  DATA: lv_lifnr TYPE lifnr,
        lv_name1 TYPE name1.

  SELECT  ekko~lifnr, lfa1~name1
  INTO (@lv_lifnr,@lv_name1)
    FROM ekko
  INNER JOIN lfa1 ON lfa1~lifnr = ekko~lifnr
   WHERE bukrs = @cs_record-bukrs
     AND ebeln  = @cs_record-ebeln
     AND ekko~lifnr  <> ''
   . ENDSELECT.

  IF sy-subrc EQ 0.


    cs_record-zz_lifnr = lv_lifnr.
    cs_record-zz_name = lv_name1.
  ENDIF.
ENDIF.
