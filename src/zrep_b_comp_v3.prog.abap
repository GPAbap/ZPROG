*&---------------------------------------------------------------------*
*& Report  ZREP_BASCULA
*&
*&---------------------------------------------------------------------*
*& Ernesto Islas Juárez                                 Oct,10 2019
*& Reporte de proceso de básculas
*&---------------------------------------------------------------------*

INCLUDE zrep_b_comp_top_v3.
*INCLUDE ZREP_B_COMP_TOP_V2.

INITIALIZATION.
  PERFORM initz.

START-OF-SELECTION.
  PERFORM init.
  PERFORM read_d.
  PERFORM showr.
*&---------------------------------------------------------------------*
*&      Form  READ_d
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_d.

  DATA: no_out   TYPE i.

  CLEAR tb1[].

  SELECT *
    INTO TABLE tb1
    FROM zbascula_1
   WHERE fechape IN so_erdat
     AND nnea    IN so_nnea
     AND ebeln   IN so_ebeln.
*    and werks   = p_werks.

  LOOP AT tb1 INTO sb1.
    CLEAR: no_out,
           srep.
    IF sb1-ebeln IS INITIAL.
      CONTINUE.
    ENDIF.
    CLEAR sb0.
    IF sb1-nnea IS NOT INITIAL.
      SELECT SINGLE *
        INTO sb0
        FROM zbascula_0
      WHERE nnea = sb1-nnea.
    ENDIF.

    CLEAR sb2.
    IF NOT sb1-ebeln   IS INITIAL AND
       NOT sb1-talon_f IS INITIAL.

      SELECT SINGLE *
        INTO sb2
        FROM zbascula_2
      WHERE ebeln   = sb1-ebeln
        AND talon_f = sb1-talon_f.
    ENDIF.

    CLEAR tb3.
    IF sb1-nnea IS NOT INITIAL.
      IF p_werks IS NOT INITIAL.
        SELECT * INTO TABLE tb3
          FROM zbascula_3
        WHERE nnea    = sb1-nnea
          AND ebeln   = sb1-ebeln
          AND werks   = p_werks.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
      ELSE.
        SELECT * INTO TABLE tb3
          FROM zbascula_3
        WHERE nnea    = sb1-nnea
          AND ebeln   = sb1-ebeln.
      ENDIF.

    ENDIF.

    MOVE-CORRESPONDING sb0 TO srep.
    MOVE-CORRESPONDING sb2 TO srep.

    MOVE sb1-ebeln         TO srep-ebeln.
    MOVE sb1-lifnr         TO srep-lifnr.
    SELECT SINGLE name1 INTO srep-name1 FROM lfa1 WHERE lifnr EQ sb1-lifnr.
    SELECT SINGLE bednr INTO srep-bednr FROM ekpo WHERE ebeln EQ sb1-ebeln.
    MOVE sb1-nnea          TO srep-nnea.
    MOVE sb0-neaf          TO srep-neaf.
    MOVE sb1-bukrs         TO srep-bukrs.
    MOVE sb0-operador      TO srep-operador.
    MOVE sb0-ciatrans      TO srep-ciatrans.
    MOVE sb0-placas        TO srep-placas.
    MOVE sb0-placac        TO srep-placac.
    MOVE sb0-talon_f       TO srep-talon_f.
    MOVE sb0-factura_p     TO srep-factura_p.
    MOVE sb0-peso_basent   TO srep-peso_basent.
    MOVE sb0-um_basent     TO srep-um_basent.
    MOVE sb0-peso_bassal   TO srep-peso_bassal.
    MOVE sb0-um_bassal     TO srep-um_bassal.
    MOVE sb0-peso_basdif   TO srep-peso_basdif.
    MOVE sb0-doc_contable1 TO srep-mblnr.
    MOVE sb0-mjahr1        TO srep-mjahr.
    UNPACK srep-mblnr      TO srep-mblnr.
    MOVE sb0-doc_merma1    TO srep-doc_merma1.

    LOOP AT tb3 INTO sb3.
      MOVE sb3-matnr TO srep-matnr.
      MOVE sb3-ebelp TO srep-ebelp.
      MOVE sb3-txz01 TO srep-maktx.
      MOVE sb3-charg TO srep-charg.
      MOVE sb3-werks TO srep-werks.
      MOVE sb3-peso_embarcado TO srep-peso_embarcado.
      MOVE sb3-umembarcado   TO srep-umembarcado.

      PERFORM m_ic.

      PERFORM read_mseg.

      MOVE smseg-menge TO srep-qty_em.
      MOVE smseg-meins TO srep-um_em.
************************MODIFICACIONES MICHAEL 25.08.2020 INI
*      srep-merma = sb3-peso_embarcado - sb0-peso_basdif.
      IF sb0-peso_basdif > 0 AND sb3-peso_embarcado > 0.
        srep-merma = sb0-peso_basdif - sb3-peso_embarcado.
        srep-ummerma = sb3-umembarcado.
        srep-merma_per = ( sb3-peso_embarcado * '0.25' ) / 100.
        srep-dif_merma = abs( srep-merma ) - srep-merma_per.
        if srep-merma lt 0.
        srep-dif_merma = srep-dif_merma * -1.
        ENDIF.
      ELSE.
        srep-merma = ''.
        srep-ummerma = ''.
      ENDIF.
************************MODIFICACIONES MICHAEL 25.08.2020 FIN
      APPEND srep TO trep.
      ADD 1 TO no_out.
    ENDLOOP.

    IF no_out IS INITIAL.
      APPEND srep TO trep.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " readd
*&---------------------------------------------------------------------*
*&      Form  READ_VENTAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_ventas .

ENDFORM.                    " READ_VENTAS
*&---------------------------------------------------------------------*
*&      Form  READ_TRA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_tra .

ENDFORM.                    " READ_TRA
*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init .
  CLEAR trep[].

ENDFORM.                    " INIT
*&---------------------------------------------------------------------*
*&      Form  SHOWR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM showr .

  CLEAR tfieldcat[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME     =
*     I_INTERNAL_TABNAME =
      i_structure_name   = 'ZREP_BASCULAV3'
*     I_CLIENT_NEVER_DISPLAY       = 'X'
*     I_INCLNAME         =
      i_bypassing_buffer = 'X'
*     I_BUFFER_ACTIVE    =
    CHANGING
      ct_fieldcat        = tfieldcat.


  FIELD-SYMBOLS <fs_fieldcat> LIKE LINE OF tfieldcat.

  LOOP AT tfieldcat ASSIGNING <fs_fieldcat>.

    CASE <fs_fieldcat>-fieldname.
      WHEN 'ICENT' OR 'ICSAL' .
        <fs_fieldcat>-icon = abap_true.
      WHEN 'EBELN' OR 'MBLNR'.
        <fs_fieldcat>-hotspot = abap_true.
    ENDCASE.

***    CASE <fs_fieldcat>-fieldname.
***      WHEN 'PRC'.
***        CONCATENATE 'Proceso' ''
***        INTO <fs_fieldcat>-seltext_s
***        SEPARATED BY space.
***
***        CONCATENATE 'Proceso' ''
***        INTO <fs_fieldcat>-seltext_m
***        SEPARATED BY space.
***
***        CONCATENATE 'Proceso' ''
***        INTO <fs_fieldcat>-seltext_l
***        SEPARATED BY space.
***
***        CONCATENATE 'Proceso' ''
***        INTO <fs_fieldcat>-reptext_ddic
***        SEPARATED BY space.
***
***        <fs_fieldcat>-outputlen = '10'.
***
***      WHEN 'WRBTR_1'.
***
***      WHEN 'VBELN_VF' OR
***           'VBELN_VL' OR
***           'VBELN_VA' OR
***           'TKNUM'    OR
***           'MBLNR'    OR
***           'EBELN'    OR
***           'BELNR_VERIF' OR
***           'REMISION' OR
***           'PATH_REMISION' OR
***           'PATH_CFDI' OR
***           'PATH_3218'.
***        <fs_fieldcat>-hotspot = abap_true.
***      WHEN 'PRCG'.
***        <fs_fieldcat>-no_out  = abap_true.
***    ENDCASE.

  ENDLOOP.

  PERFORM flay.

*--- make alv
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' "LIST
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      =
*     i_buffer_active         =
      i_callback_program      = sy-repid
*     i_callback_pf_status_set = 'PFSTATUS'
      i_callback_user_command = 'USER_COMMAND'
**      i_callback_top_of_page = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     i_background_id         = 'ZBACKGROUND_WHITE'
*     i_grid_title            = lvc_title
*     I_GRID_SETTINGS         =
      is_layout               = r_layout
      it_fieldcat             = tfieldcat[]
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
      it_sort                 = gt_sort[]
*     IT_FILTER               =
*     IS_SEL_HIDE             = abap_true
*     I_DEFAULT               = 'X'
      i_save                  = 'A'
**      is_variant             = ls_variant
***      it_events              = gt_events[]
*     it_event_exit           =
****      it_event_exit            = it_eventexit
*     IS_PRINT                = gt_print
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     IT_ALV_GRAPHICS         =
*     IT_ADD_FIELDCAT         =
*     IT_HYPERLINK            =
*     I_HTML_HEIGHT_TOP       =
*     I_HTML_HEIGHT_END       =
*     IT_EXCEPT_QINFO         =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = trep
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.


ENDFORM.                    " SHOWR
*&---------------------------------------------------------------------*
*&      Form  FLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM flay .

  r_layout-zebra             = abap_true.
  r_layout-colwidth_optimize = abap_true.

ENDFORM.                    " FLAY
*&---------------------------------------------------------------------*
*&      Form  M_IC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM m_ic .

  IF sb1-ebeln IS NOT INITIAL.
    srep-icent = '@7Q@'.
  ENDIF.

  IF sb0-nnea IS NOT INITIAL AND
     sb0-ind_pfinal  = abap_true.
    srep-icsal = '@4A@'.
  ENDIF.

ENDFORM.                    " M_IC

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     TYPE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CLEAR srep.
  READ TABLE trep INDEX rs_selfield-tabindex INTO srep.

  CASE r_ucomm.

*User clicks a transaction code and that tcode is called from ALV

    WHEN '&IC1'.
      IF sy-subrc = 0.
        CASE rs_selfield-fieldname.
          WHEN 'VBELN_VA'.
**            CHECK srep-vbeln_va IS NOT INITIAL.
**            SET PARAMETER ID 'AUN' FIELD srep-vbeln_va.
**            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
          WHEN 'VBELN_VL'.
**            CHECK srep-vbeln_vl IS NOT INITIAL.
**            SET PARAMETER ID 'VL'  FIELD srep-vbeln_vl.
**            CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
          WHEN 'VBELN_VF'.
**            CHECK srep-vbeln_vf IS NOT INITIAL.
**            SET PARAMETER ID 'VF'  FIELD srep-vbeln_vf.
**            CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
          WHEN 'MBLNR'.
            CHECK srep-mblnr IS NOT INITIAL.
            SET PARAMETER ID 'MBN'  FIELD srep-mblnr.
            SET PARAMETER ID 'MJA'  FIELD srep-mjahr.
            CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
          WHEN 'EBELN'.
            CHECK srep-ebeln IS NOT INITIAL.

            SET PARAMETER ID 'BES'  FIELD srep-ebeln.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

**          WHEN 'BELNR_VERIF'.
**            CHECK srep-belnr_verif IS NOT INITIAL.
**            SET PARAMETER ID 'RBN'  FIELD srep-belnr_verif.
**            SET PARAMETER ID 'GJR'  FIELD srep-gjahr_verif.
**            CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
        ENDCASE.
      ENDIF.

  ENDCASE.

ENDFORM. "user_commandr
*&---------------------------------------------------------------------*
*&      Form  INITZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initz .

  CLEAR so_erdat.

  so_erdat-option = 'EQ'.
  so_erdat-sign   = 'I'.
  so_erdat-high   = sy-datum.
  so_erdat-low    = sy-datum - 2.
  APPEND so_erdat.

ENDFORM.                    " INITZ
*&---------------------------------------------------------------------*
*&      Form  READ_MSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_mseg .

  CLEAR smseg.
*
  SELECT SINGLE *
    INTO smseg
    FROM mseg
  WHERE mblnr = srep-mblnr
    AND mjahr = srep-mjahr
    AND matnr = srep-matnr.

ENDFORM.                    " READ_MSEG
