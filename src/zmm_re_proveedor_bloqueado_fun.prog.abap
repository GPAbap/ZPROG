*&---------------------------------------------------------------------*
*& Form get_blocked_vendors
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*


FORM get_blocked_vendors.

  DATA: lr_lifnr_job TYPE RANGE OF lifnr,
        ls_lifnr_job LIKE LINE OF lr_lifnr_job,
        lv_lifnr     TYPE lifnr.

  CLEAR gt_alv.

  SELECT lfa1~lifnr, lfa1~name1, lfa1~sperr,
         lfa1~sperm
   INTO TABLE @DATA(lt_lfa1)
   FROM lfa1
   INNER JOIN zmm_log_bl_prov AS z
    ON z~zlifnr = lfa1~lifnr
  WHERE z~zlifnr IN @s_lifnr
    AND z~zaction EQ 'BLOCK'.

  SORT lt_lfa1 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING lifnr.


  LOOP AT lt_lfa1 INTO DATA(ls_lfa1).

    CLEAR gs_alv.
    gs_alv-lifnr = ls_lfa1-lifnr.
    gs_alv-name1 = ls_lfa1-name1.

    IF ls_lfa1-sperr = 'X'.
      gs_alv-central_fi = abap_true.
    ENDIF.

    IF ls_lfa1-sperm = 'X'.
      gs_alv-central_mm = abap_true.
    ENDIF.

    SELECT COUNT(*)
      INTO gs_alv-bukrs_blk
      FROM lfb1
     WHERE lifnr = ls_lfa1-lifnr
       AND bukrs IN s_bukrs
       AND sperr = 'X'.

    SELECT COUNT(*)
      INTO gs_alv-ekorg_blk
      FROM lfm1
     WHERE lifnr = ls_lfa1-lifnr
       AND ekorg IN s_ekorg
       AND sperm = 'X'.

    IF ( p_cfi = abap_true AND gs_alv-central_fi = abap_true )
    OR ( p_cmm = abap_true AND gs_alv-central_mm = abap_true )
    OR ( p_buk = abap_true AND gs_alv-bukrs_blk  > 0 )
    OR ( p_eko = abap_true AND gs_alv-ekorg_blk  > 0 ).

      gs_alv-light  = '1'.
      gs_alv-status = 'BLOQUEADO'.
      APPEND gs_alv TO gt_alv.

    ENDIF.

  ENDLOOP.

ENDFORM.





FORM unblock_selected.

  DATA: lo_vendor TYPE REF TO zcl_des_bloqueo_proveedor,
        lt_log    TYPE zcl_des_bloqueo_proveedor=>tt_log,
        lv_answer TYPE c LENGTH 1.

  CALL METHOD go_grid->check_changed_data.

  READ TABLE gt_alv TRANSPORTING NO FIELDS WITH KEY sel = abap_true.
  IF sy-subrc <> 0.
    MESSAGE 'Selecciona al menos un proveedor' TYPE 'I'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Confirmar desbloqueo'
      text_question         = '¿Deseas desbloquear los proveedores seleccionados?'
      text_button_1         = 'Sí'
      text_button_2         = 'No'
      default_button        = '2'
      display_cancel_button = abap_true
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> '1'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_vendor.

  LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<ls_alv>) WHERE sel = abap_true.

    CLEAR lt_log.

    TRY.
        lo_vendor->unblock_vendor(
          EXPORTING
            iv_lifnr     = <ls_alv>-lifnr
            iv_do_commit = abap_true
          IMPORTING
            et_log       = lt_log
        ).

        <ls_alv>-sel        = abap_false.
        <ls_alv>-light      = '3'.
        <ls_alv>-status     = 'OK'.
        <ls_alv>-message    = 'Proveedor desbloqueado correctamente'.
        <ls_alv>-central_fi = abap_false.
        <ls_alv>-central_mm = abap_false.
        <ls_alv>-bukrs_blk  = 0.
        <ls_alv>-ekorg_blk  = 0.

      CATCH zcx_des_bloqueo_proveedor INTO DATA(lx).
        <ls_alv>-light   = '1'.
        <ls_alv>-status  = 'ERROR'.
        <ls_alv>-message = lx->mv_text.
    ENDTRY.

  ENDLOOP.

  CALL METHOD go_grid->refresh_table_display.

ENDFORM.

FORM display_grid.

  DATA: lt_fcat TYPE lvc_t_fcat,
        ls_fcat TYPE lvc_s_fcat,
        ls_layo TYPE lvc_s_layo.

  DEFINE add_col.
    CLEAR ls_fcat.
    ls_fcat-fieldname = &1.
    ls_fcat-coltext   = &2.
    ls_fcat-edit      = &3.
    ls_fcat-checkbox  = &4.
    APPEND ls_fcat TO lt_fcat.
  END-OF-DEFINITION.

  add_col 'SEL'        'Sel.'        abap_true  abap_true.
  add_col 'LIGHT'      'Sem.'        abap_false abap_false.
  add_col 'LIFNR'      'Proveedor'   abap_false abap_false.
  add_col 'NAME1'      'Nombre'      abap_false abap_false.
  add_col 'CENTRAL_FI' 'Bloq.FI'     abap_false abap_true.
  add_col 'CENTRAL_MM' 'Bloq.MM'     abap_false abap_true.
  add_col 'BUKRS_BLK'  'Soc.Bloq.'   abap_false abap_false.
  add_col 'EKORG_BLK'  'Org.Bloq.'   abap_false abap_false.
  add_col 'STATUS'     'Estado'      abap_false abap_false.
  add_col 'MESSAGE'    'Mensaje'     abap_false abap_false.

  ls_layo-zebra      = abap_true.
  ls_layo-cwidth_opt = abap_true.
  ls_layo-excp_fname = 'LIGHT'.

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout       = ls_layo
    CHANGING
      it_outtab       = gt_alv
      it_fieldcatalog = lt_fcat.

ENDFORM.
