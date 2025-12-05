*&---------------------------------------------------------------------*
*& Report  ZREP_BASCULA
*&
*&---------------------------------------------------------------------*
*& Ernesto Islas Juárez                                 Oct,10 2019
*& Reporte de proceso de básculas
*&---------------------------------------------------------------------*

INCLUDE zsd_gen_filevtas_top.
*INCLUDE ZREP_B_VTAS_TOP.

INITIALIZATION.
  PERFORM initz.

START-OF-SELECTION.
  PERFORM init.
  PERFORM read_d.
  "PERFORM showr.
  PERFORM save_csv.
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
      IF p_werks IS NOT INITIAL.
        SELECT * INTO TABLE tb3
          FROM zbasculavtas_3
        WHERE ticket    = sb1-ticket
          AND vbeln     = sb1-vbeln
          AND werks     = p_werks
          and matnr in ( '000000000000500021', '000000000000500022' ).
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
      ELSE.
        SELECT * INTO TABLE tb3
          FROM zbasculavtas_3
        WHERE ticket    = sb1-ticket
          AND vbeln     = sb1-vbeln
          and matnr in ( '000000000000500021', '000000000000500022' ).
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

    "PERFORM m_ic.

    PERFORM read_vbak.

    LOOP AT tb3 INTO sb3.

      MOVE sb3-matnr TO srep-matnr.
      MOVE sb3-posnr TO srep-posnr.
      MOVE sb3-arktx TO srep-maktx.
      MOVE sb3-charg TO srep-charg.
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
delete trep where matnr is INITIAL.
it_csv = CORRESPONDING #( trep ).
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

  DATA: it_csv TYPE truxs_t_text_data.


data fecha type date.
data hora type uzeit.

fecha = sy-datum.
hora = sy-uzeit.


  IF sy-sysid EQ 'SPQ'.
    MOVE '/sapmnt/datosavi/ventaqas/archivoVentas.csv' TO lv_file_name.
  ELSEIF sy-sysid EQ 'SPP'.
    MOVE '/sapmnt/datosavi/ventapro/archivoVentas.csv' TO lv_file_name.
  else.
    MESSAGE 'Programa soportado solo en QAS y PRO (Rutas SAP)' type 'E' DISPLAY LIKE 'S'.
    EXIT.
  ENDIF.

*    data lo_file_writer TYPE REF TO cl_rsan_ut_appserv_file_writer.
*
  IF trep[] IS NOT INITIAL.
    PERFORM convert_data.
*    CREATE OBJECT lo_file_writer
*        EXPORTING
*          i_filename = lv_file_name.
*
**    Write data to the file
*      LOOP AT lt_file_table INTO DATA(lv_line).
*        lo_file_writer->write_line( lv_line ).
*      ENDLOOP.
*
*      " Close the file after writing
*      lo_file_writer->close( ).

    CLEAR : lv_lines_written.
    CALL METHOD cl_rsan_ut_appserv_file_writer=>appserver_file_write
      EXPORTING
        i_filename      = lv_file_name
        i_overwrite     = abap_true
        i_data_tab      = lt_file_table
      IMPORTING
        e_lines_written = lv_lines_written
      EXCEPTIONS
        open_failed     = 1
        write_failed    = 2
        close_failed    = 3
        OTHERS          = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      WRITE :/ 'Data written to ',
               lv_file_name.
      WRITE :/ 'No of Lines Written ',
               lv_lines_written.
    ENDIF.
  ENDIF.

*CALL FUNCTION 'GUI_DOWNLOAD'
*  EXPORTING
*    filename                = '/sapmnt/datosavi/ventaqas/archivoVentas.csv'
*  TABLES
*    data_tab                = it_csv
*  EXCEPTIONS
*    file_write_error        = 1
*    no_batch                = 2
*    gui_refuse_filetransfer = 3
*    invalid_type            = 4
*    no_authority            = 5
*    unknown_error           = 6.




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
*& Form write_data_to_appserver
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM convert_data.
  FIELD-SYMBOLS:<fs> TYPE any.
  FIELD-SYMBOLS:<fs1> TYPE any.
  DATA:lv_length TYPE i,
       wf_ref    TYPE REF TO data.
  REFRESH : lt_file_table.
  CLEAR   : ls_file_table.

  IF it_csv[] IS NOT INITIAL.
    LOOP AT it_csv INTO DATA(wa_csv). "ls_makt.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE wa_csv TO <fs>.
        IF sy-subrc <> 0.
          APPEND ls_file_table TO lt_file_table.
          CLEAR ls_file_table.EXIT.
        ENDIF.
        lv_length = 0.
        DESCRIBE FIELD <fs> OUTPUT-LENGTH lv_length.
        CREATE DATA wf_ref TYPE c LENGTH lv_length.
        IF wf_ref IS BOUND.
          ASSIGN wf_ref->* TO <fs1>.
          CHECK <fs1> IS ASSIGNED.
          <fs1> = <fs>.
        ENDIF.
        IF sy-index = 1.
          ls_file_table = <fs1>.
        ELSE.
          CONCATENATE ls_file_table <fs1> INTO ls_file_table SEPARATED BY ','.
        ENDIF.
      ENDDO.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "convert_data
*&---------------------------------------------------------------------*
*& Form save_csv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_csv .
data fecha type date.
data hora type uzeit.

fecha = sy-datum.
hora = sy-uzeit.

  IF it_csv[] IS NOT INITIAL.
    PERFORM convert_data.

    CLEAR : lv_lines_written.
    """""""""""""""""""""
    IF sy-sysid EQ 'SPQ'.

      concatenate '/sapmnt/datosavi/ventaqas/'
                  'Engorda_Venta_' fecha+0(4) fecha+4(2) fecha+6(2) '_'
                  hora+0(2) hora+2(2) hora+4(2) '.csv' into lv_file_name.
    ELSEIF sy-sysid EQ 'SPP'.
        concatenate '/sapmnt/datosavi/ventapro/' 'Engorda_Venta' fecha+0(4) fecha+4(2) fecha+6(2) '_'
                  hora+0(2) hora+2(2) hora+4(2) '.csv' into lv_file_name.
    ELSE.
      MESSAGE 'Programa soportado solo en QAS y PRO (Rutas SAP)' TYPE 'E' DISPLAY LIKE 'S'.
      EXIT.
    ENDIF.

    CALL METHOD cl_rsan_ut_appserv_file_writer=>appserver_file_write
      EXPORTING
        i_filename      = lv_file_name
        i_overwrite     = abap_true
        i_data_tab      = lt_file_table
      IMPORTING
        e_lines_written = lv_lines_written
      EXCEPTIONS
        open_failed     = 1
        write_failed    = 2
        close_failed    = 3
        OTHERS          = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      WRITE :/ 'Data written to ',
               lv_file_name.
      WRITE :/ 'No of Lines Written ',
               lv_lines_written.
    ENDIF.
  ENDIF.


ENDFORM.
