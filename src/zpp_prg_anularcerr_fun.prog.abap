*&---------------------------------------------------------------------*
*& Include          ZPP_PRG_ANULARCERR_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_orders
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_orders .

SELECT aufnr werks auart erdat
  into table it_ordenes
 FROM aufk
  where aufnr in so_aufk.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form exec_bi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_ORDENES[]
*&---------------------------------------------------------------------*
FORM exec_bi.

FIELD-SYMBOLS <fs_data> type st_ordenes.

  LOOP AT it_ordenes ASSIGNING <fs_data>.
      PERFORM bdc_dynpro USING 'SAPLCOKO1' '0110'.
      PERFORM bdc_field USING 'BDC_CURSOR' 'R62CLORD-FLG_KNOT'.
      PERFORM bdc_field USING 'BDC_OKCODE' '=ENTK'.
      PERFORM bdc_field USING 'CAUFVD-AUFNR' <fs_data>-aufnr.
      PERFORM bdc_field USING 'R62CLORD-FLG_KNOT' 'X'.
      PERFORM bdc_field USING 'R62CLORD-FLG_OVIEW' ''.

      PERFORM bdc_dynpro USING 'SAPLCOKO1' '0115'.
      PERFORM bdc_field USING 'BDC_OKCODE' '=RABK'.
      PERFORM bdc_field USING 'BDC_SUBSCR' 'SAPLCOKO1                               0120SUBSCR_0115'.
      PERFORM bdc_field USING 'BDC_CURSOR' 'CAUFVD-GAMNG'.

    PERFORM bdc_dynpro USING 'SAPLCOKO1' '0115'.
    PERFORM bdc_field USING 'BDC_OKCODE' '=BU'.
    PERFORM bdc_field USING 'BDC_SUBSCR' 'SAPLCOKO1                               0120SUBSCR_0115'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'CAUFVD-GAMNG'.

    PERFORM bdc_transaction USING 'CO02'.
    IF messtab[] is INITIAL.
      <fs_data>-status = '@0A@'.
    else.
      <fs_data>-status = '@08@'.
    ENDIF.

  ENDLOOP.
ENDFORM.

FORM bdc_dynpro USING PROGRAM DYNPRO.
  CLEAR bdcdata.
  bdcdata-PROGRAM = PROGRAM.
  bdcdata-DYNPRO = DYNPRO.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM. "BDC_DYNPRO

*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  DATA nodata VALUE '/'.

  IF fval <> nodata.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM. "BDC_FIELD

*&---------------------------------------------------------------------*
*& Form BDC_TRANSACTION
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* -->TCODE text
*----------------------------------------------------------------------*
FORM bdc_transaction USING tcode.
  DATA ctumode LIKE ctu_params-dismode VALUE 'N'.
  DATA ctu VALUE 'X'.
  DATA cupdate LIKE ctu_params-updmode VALUE 'L'.

  DATA l_messtab TYPE bdcmsgcoll.

* batch input session
  REFRESH messtab.
  CALL TRANSACTION tcode USING bdcdata
        MODE ctumode
        UPDATE cupdate
        MESSAGES INTO messtab.
  l_subrc = sy-subrc.

  IF messtab[] IS INITIAL.
    l_messtab-msgid = 'F2'.
    l_messtab-msgnr = '174'.
    l_messtab-msgv1 = 'Registro actualizado o ya limitado'.
    APPEND l_messtab TO messtab.
  ENDIF.

  REFRESH bdcdata.
ENDFORM. "BDC_TRANSACTION

FORM create_fieldcat.

 clear wa_fieldcat.


wa_fieldcat-fieldname = 'AUFNR'.
wa_fieldcat-seltext_s = 'Orden.'.
wa_fieldcat-seltext_l = 'Orden.'.
wa_fieldcat-seltext_m = 'Orden.'.
APPEND wa_fieldcat to gt_fieldcat. CLEAR wa_fieldcat.

wa_fieldcat-fieldname = 'AUART'.
wa_fieldcat-seltext_s = 'Cl. Orden'.
wa_fieldcat-seltext_l = 'Cl. Orden'.
wa_fieldcat-seltext_m = 'Cl. Orden'.
APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

wa_fieldcat-fieldname = 'WERKS'.
wa_fieldcat-seltext_s = 'Centro'.
wa_fieldcat-seltext_l = 'Centro'.
wa_fieldcat-seltext_m = 'Centro'.
APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

wa_fieldcat-fieldname = 'ERDAT'.
wa_fieldcat-seltext_s = 'Fecha Orden'.
wa_fieldcat-seltext_l = 'Fecha Orden'.
wa_fieldcat-seltext_m = 'Fecha Orden'.
APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

wa_fieldcat-fieldname = 'STATUS'.
wa_fieldcat-seltext_s = 'Estatus'.
wa_fieldcat-seltext_l = 'Estatus'.
wa_fieldcat-seltext_m = 'Estatus'.
APPEND wa_fieldcat TO gt_fieldcat. CLEAR wa_fieldcat.

ENDFORM.

FORM show_alv.

  lf_layout-zebra = 'X'.
  lf_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
     I_CALLBACK_PROGRAM                = sy-repid
      IS_LAYOUT                         = lf_layout
     IT_FIELDCAT                       = gt_fieldcat
     TABLES
      t_outtab                          = it_ordenes
   EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
