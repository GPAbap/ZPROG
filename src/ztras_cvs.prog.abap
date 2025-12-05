*&---------------------------------------------------------------------*
*& Report  ZREP_BASCULA
*&
*&---------------------------------------------------------------------*
*& Ernesto Islas Juárez                                 Oct,10 2019
*& Reporte de proceso de básculas
*&---------------------------------------------------------------------*

INCLUDE ztras_cvs_top.
*INCLUDE zrep_b_tras_top.

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

  CLEAR tb1[].

  SELECT *
    INTO TABLE tb1
    FROM zbasculatrasla_1
   WHERE f_proc_ent  IN so_erdat
     AND tticket     IN so_ttick
     AND ebeln       IN so_ebeln
     AND reswk       IN so_werks.

  SELECT ekpo~afnam, ekpo~ebeln
 INTO TABLE @DATA(it_ekpo)
FROM ekpo
FOR ALL ENTRIES IN @tb1
WHERE ebeln = @tb1-ebeln
.


  LOOP AT tb1 INTO sb1.
    CLEAR: no_out,
           srep.
    IF sb1-ebeln IS INITIAL.
      CONTINUE.
    ENDIF.
    CLEAR sb0.
    IF sb1-tticket IS NOT INITIAL.
      SELECT SINGLE * INTO sb0
        FROM zbasculavtas_0
      WHERE ticket = sb1-tticket.
    ENDIF.

    CLEAR: sb2,
           tb3[],
           tb4[].

    IF NOT sb1-ebeln   IS INITIAL AND
       NOT sb1-tticket  IS INITIAL.

*      numero de lote
      READ TABLE it_ekpo INTO srep-charg WITH KEY ebeln = sb1-ebeln.

      SELECT SINGLE * INTO sb0
        FROM zbasculatrasla_0
      WHERE tticket  = sb1-tticket.

      SELECT SINGLE * INTO sb2
        FROM zbasculatrasla_2
      WHERE tticket = sb1-tticket
        AND ebeln   = sb1-ebeln.

      SELECT * INTO TABLE tb3
        FROM zbasculatrasla_3
      WHERE tticket   = sb1-tticket
        AND ebeln     = sb1-ebeln.

      SELECT * INTO TABLE tb4
        FROM zbasculatrasla_4
      WHERE tticket = sb1-tticket
        AND ebeln   = sb1-ebeln.

      CLEAR sb4.
      READ TABLE tb4 INTO sb4 WITH KEY bwart = '641'.
      MOVE sb4-documento TO srep-mblnr1.
      MOVE sb4-bwart     TO srep-bwart1.

      CLEAR sb4.
      READ TABLE tb4 INTO sb4 WITH KEY bwart = '101'.
      MOVE sb4-documento TO srep-mblnr2.
      MOVE sb4-bwart     TO srep-bwart2.

    ENDIF.

    MOVE-CORRESPONDING sb0 TO srep.
    MOVE-CORRESPONDING sb2 TO srep.

    MOVE sb1-bukrs       TO srep-bukrs.
    MOVE sb1-ebeln       TO srep-ebeln.
    MOVE sb1-vbeln       TO srep-vbeln.
    MOVE sb1-tticket     TO srep-tticket.
    MOVE sb1-ticketf     TO srep-ticketf.
    MOVE sb1-reswk       TO srep-reswk.
    MOVE sb1-operador    TO srep-operador.
*    MOVE sb0-ciatrans    TO srep-ciatrans.
    MOVE sb1-placas      TO srep-placas.
    MOVE sb1-placac      TO srep-placac.
*    MOVE sb0-talon_f     TO srep-talon_f.
***    MOVE sb00-entnr      TO srep-vbeln_vl.
**    MOVE sb00-facnr      TO srep-vbeln_vf.
    MOVE sb1-pbas_ent TO srep-peso_basent.
    MOVE sb1-umpbas_ent   TO srep-um_basent.
    MOVE sb1-pbas_sal TO srep-peso_bassal.
    MOVE sb1-umpbas_sal   TO srep-um_bassal.
    MOVE sb1-dif_pentpsal TO srep-peso_basdif.
*    MOVE sb0-doc_contable1 TO srep-mblnr.
*    MOVE sb0-mjahr1        TO srep-mjahr.

    LOOP AT tb3 INTO sb3.
      MOVE sb3-matnr TO srep-matnr.
      MOVE sb3-ebelp TO srep-ebelp.
      MOVE sb3-txz01 TO srep-maktx.
*      MOVE sb3-charg TO srep-charg.
      MOVE sb3-werks TO srep-werks.

      PERFORM m_ic.

      APPEND srep TO trep.
      ADD 1 TO no_out.
    ENDLOOP.

    IF no_out IS INITIAL.
      APPEND srep TO trep.
    ENDIF.
  ENDLOOP.

  DELETE trep WHERE werks NP 'PE*'.
  it_csv = CORRESPONDING #( trep  ).

ENDFORM.                    " READ_d
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
  REFRESH it_csv.
  REFRESH it_csv_file.


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
      i_structure_name   = 'ZREP_BASCULA_TRAS'
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

  ENDLOOP.

  it_csv = CORRESPONDING #( trep  ).

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

  IF srep-tticket IS NOT INITIAL.
    srep-icent = '@7Q@'.
  ENDIF.

  IF sb0-tticket  IS NOT INITIAL AND
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
          WHEN 'MBLNR1'.
            CHECK srep-mblnr1 IS NOT INITIAL.
            SET PARAMETER ID 'MBN'  FIELD srep-mblnr1.
*            SET PARAMETER ID 'MJA'  FIELD srep-mjahr.
            CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.

          WHEN 'MBLNR2'.
            CHECK srep-mblnr2 IS NOT INITIAL.
            SET PARAMETER ID 'MBN'  FIELD srep-mblnr2.
*            SET PARAMETER ID 'MJA'  FIELD srep-mjahr.
            CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.

          WHEN 'EBELN'.
            CHECK srep-ebeln IS NOT INITIAL.
            SET PARAMETER ID 'BES'  FIELD srep-ebeln.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
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


ENDFORM.                    " INIT
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

"  MOVE '/sapmnt/datosavi/alimentoqas/TraspAlim.csv' TO lv_file_name.

  IF it_csv[] IS NOT INITIAL.
    PERFORM convert_data.

    CLEAR : lv_lines_written.
    """""""""""""""""""""
    IF sy-sysid EQ 'SPQ'."Engorda_TrasladoAlimento_[Fecha]_[Hora].csv

      concatenate '/sapmnt/datosavi/alimentoqas/'
                  'Engorda_TrasladoAlimento_' fecha+0(4) fecha+4(2) fecha+6(2) '_'
                  hora+0(2) hora+2(2) hora+4(2) '.csv' into lv_file_name.
    ELSEIF sy-sysid EQ 'SPP'.
        concatenate '/sapmnt/datosavi/alimentopro/' 'Engorda_TrasladoAlimento_' fecha+0(4) fecha+4(2) fecha+6(2) '_'
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

*  CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
*    EXPORTING
*      i_field_seperator    = ','
*    TABLES
*      i_tab_sap_data       = it_csv
*    CHANGING
*      i_tab_converted_data = it_csv_file
*    EXCEPTIONS
*      conversion_failed    = 1
*      OTHERS               = 2.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

*
*
*  "Función para mostrar ventana para seleccionar archivo
*  CALL METHOD cl_gui_frontend_services=>file_save_dialog
*    EXPORTING
*      window_title      = 'Guardar archivo csv' "Titulo del dialogo
*      default_extension = 'CSV' "Extension predeterminada
*      default_file_name = 'File' "Nombre predeterminado del archivo
*      initial_directory = 'C:\Temp' "Directorio inicial
*    CHANGING
*      filename          = ld_filename
*      path              = ld_path
*      fullpath          = ld_fullpath
*      user_action       = ld_result.
*
*  file = ld_fullpath.


*
*
*  "Finalmente bajamos nuestro archivo
*  CALL FUNCTION 'GUI_DOWNLOAD'
*    EXPORTING
*      filename                = file
*    TABLES
*      data_tab                = it_csv_file
*    EXCEPTIONS
*      file_write_error        = 1
*      no_batch                = 2
*      gui_refuse_filetransfer = 3
*      invalid_type            = 4
*      no_authority            = 5
*      unknown_error           = 6.


ENDFORM.

FORM convert_data.
  FIELD-SYMBOLS:<fs> TYPE any.
  FIELD-SYMBOLS:<fs1> TYPE any.
  DATA:lv_length TYPE i,
       wf_ref    TYPE REF TO data.
  REFRESH : lt_file_table.
  CLEAR   : ls_file_table.

  IF it_csv[] IS NOT INITIAL.
    LOOP AT it_csv INTO DATA(wa_cvs). "ls_makt.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE wa_cvs TO <fs>.
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
ENDFORM.
