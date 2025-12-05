*&---------------------------------------------------------------------*
*& Include          ZPP_BOM_MASS_FN
*&---------------------------------------------------------------------*
FORM f_procesa_tabla .

  IF p_file NE space.
    CALL FUNCTION 'ZALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename    = p_file
        i_begin_col = 1
        i_begin_row = 1
        i_end_col   = 20
        i_end_row   = 39999
        sheets      = p_sheet
      TABLES
        it_data     = it_salida.

    IF NOT it_salida[] IS INITIAL.
      PERFORM armar_arbol.
    ENDIF.
  ENDIF.
ENDFORM.

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
      default_extension       = '.xls'
      file_filter             = '.xls'
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

ENDFORM.                    " SUB_FILE_F4.
*&---------------------------------------------------------------------*
*& Form armar_arbol
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM armar_arbol .
  DATA vl_namesheet TYPE zmxed0011.
  DATA: vl_indicador TYPE i,
        vl_row       TYPE i,
        vl_stlnr     TYPE stnum,
        vl_stlal     TYPE stalt.




  LOOP AT it_salida INTO DATA(wa_salida).

    AT NEW namesheet.
      CLEAR wa_bomh.
      vl_indicador = gv_idetalle.
      vl_row = gv_iencabezado.
      PERFORM get_encabezado USING wa_salida-namesheet vl_row
                             CHANGING vl_stlnr vl_stlal.
      vl_namesheet = wa_salida-namesheet.
    ENDAT.

    IF wa_salida-p_rows >= vl_indicador .
      PERFORM get_detalle USING wa_salida-namesheet vl_indicador vl_stlnr vl_stlal.
      vl_indicador = vl_indicador + 1.
      READ TABLE it_salida INTO DATA(wa_aux) WITH KEY namesheet = vl_namesheet  p_rows = vl_indicador.
      IF sy-subrc NE 0.
        PERFORM add_sacos USING vl_stlnr vl_namesheet.
        vl_indicador = vl_indicador + 2.
        PERFORM get_encabezado USING wa_salida-namesheet vl_indicador
                               CHANGING vl_stlnr vl_stlal.
        vl_indicador = vl_indicador + 3.
      ENDIF.
    ENDIF.


    DELETE ADJACENT DUPLICATES FROM it_bomh COMPARING ALL FIELDS.
  ENDLOOP.
ENDFORM.

FORM add_sacos USING p_stlnr TYPE stnum
                     p_sheet TYPE zmxed0011.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_stlnr
    IMPORTING
      output = p_stlnr.

  SELECT zmatnr_sac, zmatnr_pre, zcant_base, m~maktx AS saco, m2~maktx AS prec
  INTO TABLE @DATA(it_sacos)
  FROM zpp_tt_sacprec AS z
  LEFT JOIN makt AS m ON m~matnr = z~zmatnr_sac
  LEFT JOIN makt AS m2 ON m2~matnr = z~zmatnr_pre
WHERE zstlnr = @p_stlnr.

  IF sy-subrc EQ 0.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = p_stlnr
      IMPORTING
        output = p_stlnr.

    READ TABLE it_sacos INTO DATA(wa_sacos) INDEX 1.
    IF wa_sacos-saco IS NOT INITIAL.
      wa_bomp-sheet = p_sheet.
      wa_bomp-stlnr = p_stlnr.
      wa_bomp-idnrk = wa_sacos-zmatnr_sac.
      wa_bomp-name1 = wa_sacos-saco. "wa_sacos-zmatnr_sac.
      wa_bomp-menge = wa_sacos-zcant_base.

      APPEND wa_bomp TO it_bomp.
    ENDIF.
    IF wa_sacos-prec IS NOT INITIAL.
      wa_bomp-sheet = p_sheet.
      wa_bomp-stlnr = p_stlnr.
      wa_bomp-idnrk = wa_sacos-zmatnr_pre.
      wa_bomp-name1 = wa_sacos-prec."wa_sacos-zmatnr_pre.
      wa_bomp-menge = wa_sacos-zcant_base.

      APPEND wa_bomp TO it_bomp.
    ENDIF.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_encabezado
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> NAMESHEET
*&---------------------------------------------------------------------*
FORM get_encabezado  USING    p_namesheet TYPE zmxed0011
                              p_row TYPE i
                     CHANGING p_stlnr TYPE stnum
                              p_stlal TYPE stalt.

  LOOP AT it_salida INTO DATA(wa_salida) WHERE namesheet EQ p_namesheet AND p_rows EQ p_row.
    CASE wa_salida-p_cols.
      WHEN 1.
        wa_bomh-sheet = wa_salida-namesheet.
        wa_bomh-stlnr = wa_salida-value.
        p_stlnr = wa_bomh-stlnr.

      WHEN 2.
        wa_bomh-stktx = wa_salida-value.
      WHEN 3.
        wa_bomh-wrkan = wa_salida-value.
      WHEN 4.
        wa_bomh-wrkan2 = wa_salida-value.
      WHEN 5.
        wa_bomh-stlal = wa_salida-value.
        p_stlal = wa_bomh-stlal.
      WHEN 6.
        wa_bomh-bmeng = wa_salida-value.
    ENDCASE.
  ENDLOOP.

  IF wa_bomh-stlal GE 1 AND wa_bomh-stlal LT 9999.
    wa_bomh-status = '@09@'. "amarillo
  ELSE.
    wa_bomh-status = '@0A@'. "ROJO
    MESSAGE 'Formula con error en versión. Ésta NO se APLICARÁ' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
  APPEND wa_bomh TO it_bomh.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_detalle
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> WA_SALIDA_NAMESHEET
*&---------------------------------------------------------------------*
FORM get_detalle  USING    p_namesheet TYPE zmxed0011
                           p_row TYPE i
                           p_stlnr TYPE stnum
                           p_stlal TYPE stalt.

  LOOP AT it_salida INTO DATA(wa_salida) WHERE namesheet EQ p_namesheet AND p_rows EQ p_row.
    CASE wa_salida-p_cols.
      WHEN 1.
        wa_bomp-sheet = wa_salida-namesheet.
        wa_bomp-stlnr = p_stlnr.
        wa_bomp-idnrk = wa_salida-value.
        wa_bomp-stlal = p_stlal.
      WHEN 2.
        wa_bomp-name1 = wa_salida-value.
      WHEN 3.
        wa_bomp-menge = wa_salida-value.
    ENDCASE.
  ENDLOOP.

  APPEND wa_bomp TO it_bomp.
ENDFORM.

FORM layout_build.
  lf_layout-zebra               = 'X'.   " Streifenmuster
  lf_layout-get_selinfos        = 'X'.
  lf_layout-expand_fieldname = 'IND'.
  lf_layout-expand_all = 'X'.
  lf_layout-colwidth_optimize = 'X'.
ENDFORM. " LAYOUT_BUILD

FORM show_alv_HSL.

  CLEAR st_keyinfo.

  st_keyinfo-header01 = 'SHEET'.
  st_keyinfo-item01 = 'SHEET'.
*
  st_keyinfo-header02 = 'STLNR'.
  st_keyinfo-item02 = 'STLNR'.

  st_keyinfo-header03 = 'STLAL'.
  st_keyinfo-item03 = 'STLAL'.

  DATA lv_pf TYPE slis_formname.

  lv_pf = 'ZPF_STATUS'.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = lv_pf
      i_callback_user_command  = 'USER_COMMAND'
      Is_layout                = lf_layout
      it_fieldcat              = gt_fieldcat[]
      i_tabname_header         = 'IT_BOMH'
      i_tabname_item           = 'IT_BOMP'
      is_keyinfo               = st_keyinfo
    TABLES
      t_outtab_header          = it_bomh
      t_outtab_item            = it_bomp
                                 EXCEPTIONS
                                 program_error =1
      OTHERS                   = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fieldcat .
  CLEAR wa_fieldcat.
  REFRESH gt_fieldcat.


  wa_fieldcat-fieldname = 'SHEET'.
  wa_fieldcat-col_pos = 1.
  wa_fieldcat-tabname = 'IT_BOMH'.
  wa_fieldcat-seltext_l = 'Planta'.
  wa_fieldcat-seltext_m = 'Planta'.
  wa_fieldcat-seltext_s = 'Planta'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'STLNR'.
  wa_fieldcat-col_pos = 2.
  wa_fieldcat-tabname = 'IT_BOMH'.
  wa_fieldcat-seltext_l = 'L. Materiales'.
  wa_fieldcat-seltext_m = 'L. Materiales'.
  wa_fieldcat-seltext_s = 'L. Materiales'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'STKTX'.
  wa_fieldcat-col_pos = 3.
  wa_fieldcat-tabname = 'IT_BOMH'.
  wa_fieldcat-seltext_l = 'Descripción'.
  wa_fieldcat-seltext_m = 'Descripción'.
  wa_fieldcat-seltext_s = 'Descripción'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WRKAN'.
  wa_fieldcat-col_pos = 4.
  wa_fieldcat-tabname = 'IT_BOMH'.
  wa_fieldcat-seltext_l = 'Centro'.
  wa_fieldcat-seltext_m = 'Centro'.
  wa_fieldcat-seltext_s = 'Centro'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WRKAN2'.
  wa_fieldcat-col_pos = 5.
  wa_fieldcat-tabname = 'IT_BOMH'.
  wa_fieldcat-seltext_l = 'P. Centro'.
  wa_fieldcat-seltext_m = 'P. Centro'.
  wa_fieldcat-seltext_s = 'P. Centro'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'STLAL'.
  wa_fieldcat-col_pos = 6.
  wa_fieldcat-tabname = 'IT_BOMH'.
  wa_fieldcat-seltext_l = 'Versión'.
  wa_fieldcat-seltext_m = 'Versión'.
  wa_fieldcat-seltext_s = 'Versión'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BMENG'.
  wa_fieldcat-col_pos = 7.
  wa_fieldcat-tabname = 'IT_BOMH'.
  wa_fieldcat-seltext_l = 'Peso Batch'.
  wa_fieldcat-seltext_m = 'Peso Batch'.
  wa_fieldcat-seltext_s = 'Peso Batch'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'STATUS'.
  wa_fieldcat-col_pos = 8.
  wa_fieldcat-tabname = 'IT_BOMH'.
  wa_fieldcat-seltext_l = 'Estatus'.
  wa_fieldcat-seltext_m = 'Estatus'.
  wa_fieldcat-seltext_s = 'Estatus'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'IDNRK'.
  wa_fieldcat-col_pos = 9.
  wa_fieldcat-tabname = 'IT_BOMP'.
  wa_fieldcat-seltext_l = 'Ingrediente'.
  wa_fieldcat-seltext_m = 'Ingrediente'.
  wa_fieldcat-seltext_s = 'Ingrediente'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-col_pos = 10.
  wa_fieldcat-tabname = 'IT_BOMP'.
  wa_fieldcat-seltext_l = 'Nombre'.
  wa_fieldcat-seltext_m = 'Nombre'.
  wa_fieldcat-seltext_s = 'Nombre'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'MENGE'.
  wa_fieldcat-col_pos = 11.
  wa_fieldcat-tabname = 'IT_BOMP'.
  wa_fieldcat-seltext_l = 'Cantidad'.
  wa_fieldcat-seltext_m = 'Cantidad'.
  wa_fieldcat-seltext_s = 'Cantidad'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.





ENDFORM.

FORM zpf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZSTANDARD_FULLSCREEN'.
ENDFORM.

FORM user_command USING ucomm LIKE sy-ucomm
      selfield TYPE slis_selfield.

  CASE ucomm.
    WHEN '&ZEXCEL'.
*      PERFORM exportar_excel USING  'zst_formulacionh'
*                                    'zst_formulacionp'
*                                    'IND'
*                                    'STLNR'.
    WHEN '&UPDATE'.
      PERFORM update_boms.
      selfield-refresh = 'X'.
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
        tabla_encabezado  = it_bomh
        tabla_items       = it_bomp.

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
*&---------------------------------------------------------------------*
*& Form update_boms
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_boms .
  DATA vl_sysubrc TYPE sy-subrc.
  FIELD-SYMBOLS <fs_bomh> TYPE zst_formulacionh.
  CLEAR: wa_bomh, wa_bomp.
  "Primero se elimina la lista
  LOOP AT it_bomh ASSIGNING <fs_bomh>.
    IF <FS_bomh>-status NE '@0A@'.
      "llamada a Bapi para eliminar Lista de Materiales Antes de Crearla.
      PERFORM bapi_bom_delete USING <fs_bomh>-stlnr
                                    <fs_bomh>-wrkan
                              CHANGING vl_sysubrc.
      IF vl_sysubrc EQ 0 OR sy-msgno EQ '001' ."si se borro correctamente la lista, se procede a crearla o ya no existe.
        "nuevamente con la actualizacion de materiales

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        PERFORM bapi_bom_create USING <fs_bomh>
                              CHANGING vl_sysubrc.

        IF vl_sysubrc EQ 0.
          <fs_bomh>-status = '@08@'. "verde
        ELSE.
          <fs_bomh>-status = '@0A@'. "rojo
          MESSAGE sy-msgv1 TYPE 'S' DISPLAY LIKE 'E'.
          <fs_bomh>-status = '@0A@'. "rojo
        ENDIF.
      ELSE.
        MESSAGE sy-msgv1 TYPE 'S' DISPLAY LIKE 'E'.
        <fs_bomh>-status = '@0A@'. "rojo

      ENDIF.
    ELSE.
      MESSAGE 'Formulas con error en versión. Éstas no se aplicaron' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_bom_delete
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> WA_BOMH_STLNR
*&      --> WA_BOMH_WRKAN
*&---------------------------------------------------------------------*
FORM bapi_bom_delete  USING    p_stlnr TYPE stnum
                               p_wrkan TYPE wrkan
                      CHANGING p_sysubrc TYPE sy-subrc.
  DATA:
    vl_MATERIAL    LIKE  csap_mbom-matnr,
    vl_PLANT       LIKE  csap_mbom-werks,
    vl_BOM_USAGE   LIKE  csap_mbom-stlan,
    vl_ALTERNATIVE LIKE  csap_mbom-stlal,
    vl_FL_WARNING  LIKE  capiflag-flwarning.

  vl_MATERIAL = p_stlnr.
  vl_PLANT = p_wrkan.
  vl_BOM_USAGE = 1.
  vl_ALTERNATIVE = 1.

  SET UPDATE TASK LOCAL.

  CALL FUNCTION 'CSAP_MAT_BOM_DELETE'
    EXPORTING
      material    = vl_material
      plant       = vl_plant
      bom_usage   = vl_bom_usage
      alternative = vl_alternative
*     VALID_FROM  =
*     CHANGE_NO   =
*     REVISION_LEVEL           =
*     FL_NO_CHANGE_DOC         = ' '
*     FL_COMMIT_AND_WAIT       = ' '
    IMPORTING
      fl_warning  = vl_FL_WARNING
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  p_sysubrc = sy-subrc.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_bom_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> WA_BOMH_STLNR
*&      --> WA_BOMH_WRKAN
*&      <-- VL_SYSUBRC
*&---------------------------------------------------------------------*
FORM bapi_bom_create  USING  wa_bomh TYPE zst_formulacionh
                      CHANGING p_sysubrc TYPE sy-subrc.

  DATA:
    vl_MATERIAL    LIKE  csap_mbom-matnr,
    vl_PLANT       LIKE  csap_mbom-werks,
    vl_BOM_USAGE   LIKE  csap_mbom-stlan,
    vl_ALTERNATIVE LIKE  csap_mbom-stlal.
  DATA:
    vl_baseQuan  TYPE  basmn_bi,
    vl_BASE_UNIT TYPE basme,
    vl_ALT_TEXT	 TYPE	stktx,
    vl_BOM_TEXT	 TYPE	cstext.

  DATA vl_posnr TYPE sposn.

  DATA: it_stko TYPE STANDARD TABLE OF stko_api01,
        wa_stko LIKE LINE OF it_stko,
        it_stpo TYPE STANDARD TABLE OF stpo_api01,
        wa_stpo LIKE LINE OF it_stpo.

  vl_MATERIAL = wa_bomh-stlnr.
  vl_PLANT = wa_bomh-wrkan.
  vl_BOM_USAGE = 1.
  vl_ALTERNATIVE = wa_bomh-stlal.


  vl_basequan = wa_bomh-bmeng.
  vl_BASE_UNIT = 'KG'.
  vl_ALT_TEXT = wa_bomh-stktx.
  vl_BOM_TEXT = wa_bomh-stktx.

  wa_stko-base_quan = vl_basequan.
  wa_stko-base_unit = vl_BASE_UNIT.
  wa_stko-bom_text = vl_ALT_TEXT.
  wa_stko-alt_text = vl_BOM_TEXT.
  "APPEND wa_stko TO it_stko.

  CLEAR vl_posnr.
  LOOP AT it_bomp INTO wa_bomp WHERE sheet = wa_bomh-sheet AND stlnr = wa_bomh-stlnr AND stlal = wa_bomh-stlal.
    vl_posnr = vl_posnr + 10.
    wa_stpo-item_categ = 'L'.
    wa_stpo-item_no = vl_posnr.
    wa_stpo-component = wa_bomp-idnrk.
    wa_stpo-comp_qty = wa_bomp-menge.
    "wa_stpo-comp_unit = 'KG'. "25/07/2023 SE elimina porque ingresan sacos en la formula.
    wa_stpo-rel_cost = 'X'.
    APPEND wa_stpo TO it_stpo.
  ENDLOOP.


  SET UPDATE TASK LOCAL.
  CALL FUNCTION 'CSAP_MAT_BOM_CREATE'
    EXPORTING
      material    = vl_material
      plant       = vl_plant
      bom_usage   = vl_bom_usage
      alternative = vl_alternative
      i_stko      = wa_stko
* IMPORTING
*     FL_WARNING  =
*     BOM_NO      =
    TABLES
      t_stpo      = it_stpo
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ENDIF.

  p_sysubrc = sy-subrc.

ENDFORM.
