*&---------------------------------------------------------------------*
*& Report  ZREP_BASCULA
*&
*&---------------------------------------------------------------------*
*& Ernesto Islas Juárez                                 Oct,10 2019
*& Reporte de proceso de básculas
*&---------------------------------------------------------------------*


INCLUDE zrep_b_vtas_unif_top.

INITIALIZATION.
  PERFORM initz.

START-OF-SELECTION.
  PERFORM init.
  PERFORM read_d.
  PERFORM manual_ent.
  PERFORM manual_sal.
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
  DATA: vl_lines TYPE STANDARD TABLE OF tline,
        vl_name  LIKE thead-tdname.

  CLEAR tb1[].

  SELECT * INTO TABLE tb1
     FROM zbasculavtas_1
  WHERE f_proc_ent IN so_erdat
    AND ticket     IN so_basnr
    AND vbeln      IN so_vbeln.
*    and werks   = p_werks.

  LOOP AT tb1 INTO sb1.
    CLEAR: no_out,
           srep.

    CLEAR sb0.
    IF sb1-ticket IS NOT INITIAL.
      SELECT SINGLE * INTO sb0
        FROM zbasculavtas_0
      WHERE ticket = sb1-ticket.
    ENDIF.

    CLEAR: sb2,
           tb3[],
           sb4.

    IF NOT sb1-vbeln   IS INITIAL AND
       NOT sb1-ticket  IS INITIAL.

      SELECT SINGLE * INTO sb2
        FROM zbasculavtas_2
      WHERE ticket  = sb1-ticket
        AND vbeln   = sb1-vbeln.

      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING sb2 TO srep.
      ENDIF.

      SELECT SINGLE bstkd INTO srep-zid_portal
        FROM vbkd
      WHERE vbeln = sb1-vbeln.

      IF p_werks IS NOT INITIAL.
        SELECT * INTO TABLE tb3
          FROM zbasculavtas_3
        WHERE ticket    = sb1-ticket
          AND vbeln     = sb1-vbeln
          AND werks     = p_werks.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
      ELSE.
        SELECT * INTO TABLE tb3
          FROM zbasculavtas_3
        WHERE ticket    = sb1-ticket
          AND vbeln     = sb1-vbeln.
      ENDIF.
*      SELECT SINGLE * INTO sb00
*        FROM zbascula00
*      WHERE "basnr   = sb1-basnr
*            vbeln   = sb2-vbeln.
      SELECT SINGLE * INTO sb4
        FROM zbasculavtas_4
      WHERE ticket   = sb1-ticket
        AND vbeln    = sb1-vbeln.
    ENDIF.

    MOVE sb1-vbeln       TO srep-vbeln_va.
    MOVE sb1-ticket      TO srep-ticket.
    MOVE sb1-ticketf       TO srep-ticketf.
    MOVE sb1-bukrs_vf       TO srep-bukrs.
    MOVE sb1-operador    TO srep-operador.
***    MOVE sb00-linea      TO srep-ciatrans.
    MOVE sb1-placas      TO srep-placas.
    MOVE sb1-placac      TO srep-placac.
***    MOVE sb00-entnr       TO srep-vbeln_vl.
    MOVE sb4-documento   TO srep-vbeln_vf.
    MOVE sb0-peso_basent TO srep-peso_basent.
    MOVE sb0-um_basent   TO srep-um_basent.
    MOVE sb0-peso_bassal TO srep-peso_bassal.
    MOVE sb0-um_bassal   TO srep-um_bassal.
    MOVE sb0-peso_basdif TO srep-peso_basdif.






*    MOVE sb0-doc_contable1 TO srep-mblnr.
*    MOVE sb0-mjahr1        TO srep-mjahr.

    PERFORM m_ic.

    PERFORM read_vbak.

    LOOP AT tb3 INTO sb3.

      MOVE sb3-matnr TO srep-matnr.
      MOVE sb3-posnr TO srep-posnr.
      MOVE sb3-arktx TO srep-maktx.
*      MOVE sb3-charg TO srep-charg.
      MOVE sb3-werks TO srep-werks.

      PERFORM read_pos.
      MOVE svbap-kwmeng TO srep-kwmeng.
      MOVE svbap-vrkme  TO srep-vrkme.
      MOVE gd_vbeln_vl  TO srep-vbeln_vl.

      IF srep-posnr GT '010'.
        srep-peso_basent = 0.
        srep-peso_bassal = 0.
        srep-peso_basdif = 0.
      ENDIF.

      CONCATENATE srep-vbeln_va srep-posnr INTO vl_name.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
*         CLIENT                  = SY-MANDT
          id                      = 'TX18'
          language                = sy-langu
          name                    = vl_name
          object                  = 'VBBP'
*         ARCHIVE_HANDLE          = 0
*         LOCAL_CAT               = ' '
*         USE_OLD_PERSISTENCE     = ABAP_FALSE
*     IMPORTING
*         HEADER                  =
*         OLD_LINE_COUNTER        =
        TABLES
          lines                   = vl_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      READ TABLE vl_lines INTO DATA(wa_line) INDEX 1.
      MOVE wa_line-tdline TO srep-zcaseta.

      APPEND srep TO trep.
      ADD 1 TO no_out.

    ENDLOOP.

    IF no_out IS INITIAL.
      APPEND srep TO trep.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " READd
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
      i_structure_name   = 'ZREP_BASCULA_VTAS'
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
      WHEN 'EBELN' OR
           'MBLNR' OR
           'VBELN_VA'.
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

  IF srep-vbeln_va IS NOT INITIAL.
    srep-icent = '@7Q@'.
  ENDIF.

  IF srep-vbeln_vf IS NOT INITIAL AND
     sb3-ind_pfinal  = abap_true.
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
            CHECK srep-vbeln_va IS NOT INITIAL.
            SET PARAMETER ID 'AUN' FIELD srep-vbeln_va.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
          WHEN 'VBELN_VL'.
**            CHECK srep-vbeln_vl IS NOT INITIAL.
**            SET PARAMETER ID 'VL'  FIELD srep-vbeln_vl.
**            CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
          WHEN 'VBELN_VF'.
**            CHECK srep-vbeln_vf IS NOT INITIAL.
**            SET PARAMETER ID 'VF'  FIELD srep-vbeln_vf.
**            CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
          WHEN 'MBLNR'.
**            CHECK srep-mblnr IS NOT INITIAL.
**            SET PARAMETER ID 'MBN'  FIELD srep-mblnr.
**            SET PARAMETER ID 'MJA'  FIELD srep-mjahr.
**            CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.

        ENDCASE.
      ENDIF.

  ENDCASE.

ENDFORM. "user_commandr

*&---------------------------------------------------------------------*
*&      Form  initz
*&---------------------------------------------------------------------*
*       text
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
*&      Form  READ_POS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_pos .

  CLEAR svbap.
  SELECT SINGLE * INTO svbap
  FROM vbap
    WHERE vbeln = srep-vbeln_va
      AND posnr = srep-posnr.

ENDFORM.                    " READ_POS
*&---------------------------------------------------------------------*
*&      Form  READ_VBAK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_vbak .

  DATA: in_docnum   TYPE vbeln.

  CLEAR svbak.
  SELECT SINGLE * INTO svbak
  FROM vbak
    WHERE vbeln = srep-vbeln_va.

  CALL FUNCTION 'KNA1_READ_SINGLE'
    EXPORTING
      id_kunnr            = svbak-kunnr
    IMPORTING
      es_kna1             = tab_kna1
    EXCEPTIONS
      not_found           = 1
      input_not_specified = 2
      OTHERS              = 3.

  READ TABLE tab_kna1 INDEX 1.

  CONCATENATE tab_kna1-name1
              tab_kna1-name2 INTO srep-name1.

  srep-kunnr = svbak-kunnr.


  in_docnum = svbak-vbeln.

  CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
    EXPORTING
      iv_docnum  = in_docnum
*     IV_ITEMNUM =
*     IV_ALL_ITEMS           =
*     IV_SELF_IF_EMPTY       = ' '
    IMPORTING
      et_docflow = tflow.

  CLEAR gd_vbeln_vl.
  LOOP AT tflow INTO sflow WHERE vbtyp_n = 'J'.
    gd_vbeln_vl = sflow-vbeln.
  ENDLOOP.


ENDFORM.                    " READ_VBAK
*&---------------------------------------------------------------------*
*& Form manual
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM manual_ent .
  SELECT 'SA01' AS bukrs,substring( e~num_pesada,1,4 ) AS werks,
          e~no_ticket AS ticket, e~remision AS ticketf, e~pedido_sap AS vbeln_va,
          s~ebelp AS posnr, 'PZA' AS vrkme, e~peso_entrada  AS peso_basent,
          'KG' AS um_basent, s~peso_sal AS peso_bassal, 'KG' AS um_bassal,
          ( s~peso_sal - e~peso_entrada ) AS peso_basdif,
          e~operador, e~placas, fechape AS fecha_ent, e~horape AS hora_ent,
          s~caseta,  e~id_pedido AS zid_portal, s~sexo, s~pzas,  s~prom_aves,
          s~fecha_sal, s~hora_sal, s~motivo_no_fact, s~ind_no_fact

    FROM zmm_tt_bascm_ent AS e
    INNER JOIN zmm_tt_bascm_sal AS s
    ON s~num_pesada = e~num_pesada
  WHERE e~fechape IN @so_erdat
      AND e~no_ticket     IN @so_basnr
      AND e~pedido_sap      IN @so_vbeln
      AND e~tipo_doc = 'VTA'

    INTO TABLE @DATA(it_ent_manuales).

  LOOP AT it_ent_manuales INTO DATA(wa_ent_man).

    CLEAR srep.
    MOVE-CORRESPONDING wa_ent_man TO srep.
    IF srep-posnr GT '010'.
      srep-peso_basent = 0.
      srep-peso_bassal = 0.
      srep-peso_basdif = 0.
    ENDIF.

    IF srep-vbeln_va IS NOT INITIAL.
      srep-icent = '@7Q@'.
    ENDIF.

    IF srep-vbeln_vf IS NOT INITIAL AND
       sb3-ind_pfinal  = abap_true.
      srep-icsal = '@4A@'.
    ENDIF.


    APPEND srep TO trep.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form manual_sal
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM manual_sal .
  DATA: rg_ticket TYPE RANGE OF zbasculavtas_1-ticket,
        wa_ticket like LINE OF rg_ticket.


  SELECT    e~bukrs_vf AS bukrs,e~kunnr, e~name1,
            e~ticket, e~ticketf, e~vbeln AS vbeln_va,
            s~ebelp AS posnr, 'PZA' AS vrkme, e~pbas_ent  AS peso_basent,
            e~umpbas_ent AS um_basent, s~peso_sal AS peso_bassal, 'KG' AS um_bassal,
            ( s~peso_sal - e~pbas_ent ) AS peso_basdif,
            e~operador, e~placac AS placas, f_proc_ent AS fecha_ent, e~h_proc_ent AS hora_ent,
            s~caseta,  s~id_pedido AS zid_portal, s~sexo, s~pzas,  s~prom_aves,
            s~fecha_sal, s~hora_sal, s~motivo_no_fact, s~ind_no_fact

      FROM zbasculavtas_1 AS e
      INNER JOIN  zmm_tt_bascm_sal AS s
      ON e~ticket = s~nea
    WHERE e~f_proc_ent IN @so_erdat
        AND e~ticket     IN @so_basnr
        AND e~vbeln      IN @so_vbeln
        INTO TABLE @DATA(it_ent_manuales).

  DATA(it_tickets) = it_ent_manuales[].
  SORT it_tickets BY ticket.
  delete ADJACENT DUPLICATES FROM it_tickets COMPARING  ticket.

  LOOP AT it_tickets into data(w_tickets).
      wa_ticket-sign = 'I'.
      wa_ticket-option  = 'EQ'.
      wa_ticket-low = w_tickets-ticket.
      APPEND wa_ticket to rg_ticket.
  ENDLOOP.

   DELETE trep WHERE ticket in rg_ticket.

  LOOP AT it_ent_manuales INTO DATA(wa_ent_man).

    CLEAR srep.
    MOVE-CORRESPONDING wa_ent_man TO srep.
    IF srep-posnr GT '010'.
      srep-peso_basent = 0.
      srep-peso_bassal = 0.
      srep-peso_basdif = 0.
    ENDIF.

    IF srep-vbeln_va IS NOT INITIAL.
      srep-icent = '@7Q@'.
    ENDIF.

    IF srep-vbeln_vf IS NOT INITIAL AND
       sb3-ind_pfinal  = abap_true.
      srep-icsal = '@4A@'.
    ENDIF.

    SELECT SINGLE bstkd INTO srep-zid_portal
       FROM vbkd
     WHERE vbeln = wa_ent_man-vbeln_va.

    SELECT SINGLE uname_ent INTO srep-uname_ent
     FROM zbasculavtas_2
   WHERE vbeln = wa_ent_man-vbeln_va.

    SELECT SINGLE usrb_ent INTO srep-usrb_ent
FROM zbasculavtas_2
WHERE vbeln = wa_ent_man-vbeln_va.


    APPEND srep TO trep.

  ENDLOOP.


ENDFORM.
