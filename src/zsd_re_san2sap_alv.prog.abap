*&---------------------------------------------------------------------*
*& Include          ZSD_RE_SAN2SAP_ALV
*&---------------------------------------------------------------------*
FORM show_alv_HSL.

  CLEAR st_keyinfo.

  st_keyinfo-header01 = 'VBELN'.
  st_keyinfo-item01 = 'VBELN'.
  DATA lv_pf type SLIS_FORMNAME.

lv_pf = 'ZPF_STATUS'.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = lv_pf
      i_callback_user_command  = 'USER_COMMAND'
      Is_layout                = lf_layout
      it_fieldcat              = gt_fieldcat[]
      i_tabname_header         = 'IT_CREADOSH'
      i_tabname_item           = 'IT_CREADOS'
      is_keyinfo               = st_keyinfo
    TABLES
      t_outtab_header          = it_creadosh
      t_outtab_item            = it_creados
                                 EXCEPTIONS
                                 program_error =1
      OTHERS                   = 2.

ENDFORM.

FORM zpf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTATUS'.
ENDFORM.

FORM user_command USING ucomm LIKE sy-ucomm
      selfield TYPE slis_selfield.

  CASE ucomm.
    WHEN '&XLS'.
      PERFORM exportar_excel USING 'ZSD_ST_CREADOSANH'
                                    'ZSD_ST_CREADOSAN'
                                    'IND'
                                    'VBELN'.
    WHEN '&IC1'.
    SET PARAMETER ID 'AUN' FIELD selfield-VALUE.
    CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
  ENDCASE.

ENDFORM.

FORM exportar_excel USING estructura_header TYPE ddobjname
      estructura_items  TYPE ddobjname
      indicador_header  TYPE string
      campo_clave       TYPE string.


  PERFORM seleccionar_archivo CHANGING lv_file.
  lc_archivo = lv_file.

  IF lc_archivo IS NOT INITIAL.
    CALL FUNCTION 'ZFM_EXPORT_EXCEL_HIERSEQ'
      EXPORTING
        estructura_header = estructura_header
        estructura_items  = estructura_items
        ind_header        = indicador_header
        campo_clave       = campo_clave
        filename          = lc_archivo
      TABLES
        tabla_encabezado  = it_creadosh
        tabla_items       = it_creados.

  ENDIF.



ENDFORM.

FORM seleccionar_archivo CHANGING po_file.

  DATA: v_usr_action TYPE i,
        v_path       TYPE string,   " directorio del archivo
        v_fullpath   TYPE string,   " ruta del arhivo completa
        v_filename   TYPE string.   " nombre del archivo

  CLEAR: v_usr_action,
  v_path,
  v_fullpath,
  v_filename.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      initial_directory    = 'C:\'
      file_filter          = '*.XLS'
      default_extension    = 'XLS'
    CHANGING
      filename             = v_filename
      path                 = v_path
      fullpath             = v_fullpath
      user_action          = v_usr_action
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  IF sy-subrc IS INITIAL.
    IF v_usr_action EQ cl_gui_frontend_services=>action_ok.
      MOVE v_fullpath TO po_file.
    ENDIF.
  ENDIF.

ENDFORM. "seleccionar_Archivo
