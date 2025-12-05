*&---------------------------------------------------------------------*
*& Include          ZFI_CARGAPRECIOMATNR_FN
*&---------------------------------------------------------------------*
FORM upload_matnrlist CHANGING estado type sy-subrc.


  lv_ruta = 'C:\'.   "Ruta default

*
*
*  CALL METHOD cl_gui_frontend_services=>file_open_dialog
*    EXPORTING
*      window_title            = 'Seleccione un archivo'
*      initial_directory       = lv_ruta
*    CHANGING
*      file_table              = lt_file
*      rc                      = lv_rc
*    EXCEPTIONS
*      file_open_dialog_failed = 1
*      cntl_error              = 2
*      error_no_gui            = 3
*      not_supported_by_gui    = 4
*      OTHERS                  = 5.

  IF p_file is not INITIAL .
    READ TABLE lt_file INTO ls_file INDEX 1.
    vl_filename = p_file. "ls_file-filename.

    "llenamos la estructura del archivo cargado

    REFRESH it_listamateriales.

    CREATE OBJECT lo_uploader.
    lo_uploader->max_rows = 60000.
    lo_uploader->filename = vl_filename.
    lo_uploader->header_rows_count = 2.
    lo_uploader->upload( CHANGING ct_data = it_listamateriales ).
    "---------------------------------------------------
    "-----una vez cargada, se migra a la tabla ZCO_MATNR_PRES
    LOOP AT it_listamateriales INTO wa_listamateriales.
      MOVE-CORRESPONDING wa_listamateriales TO wa_zco_tt_matnrpres.
      INSERT zco_tt_matnrpres FROM wa_zco_tt_matnrpres.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form sub_file_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sub_file_f4 .
 DATA:
    l_desktop  TYPE string,
    l_i_files  TYPE filetable,
    l_wa_files TYPE file_table,
    l_rcode    TYPE int4.

** Finding desktop
  CALL METHOD cl_gui_frontend_services=>get_desktop_directory
    CHANGING
      desktop_directory    = l_desktop
    EXCEPTIONS
*     cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH
         'Desktop not found'.
  ENDIF.

* Update View
  CALL METHOD cl_gui_cfw=>update_view
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Select Excel file'
      default_extension       = '.xlsx'
      file_filter             = '.xlsx'
      initial_directory       = l_desktop
    CHANGING
      file_table              = l_i_files
      rc                      = l_rcode
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.


  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH 'Error while opening file'.
  ENDIF.
  READ TABLE l_i_files INDEX 1 INTO l_wa_files.
  IF sy-subrc = 0.
    p_file = l_wa_files-filename.
  ELSE.
    MESSAGE 'Debe Seleccionar un archivo válido' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
