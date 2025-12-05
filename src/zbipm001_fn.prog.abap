*&---------------------------------------------------------------------*
*& Include          ZBIPM001_FN
*&---------------------------------------------------------------------*

FORM fill_types.

  REFRESH it_f4_values.
  wa_f4_values-tipo = 'A'.
  wa_f4_values-descripcion = 'Autoconsumo'.
  APPEND wa_f4_values TO it_f4_values.

  wa_f4_values-tipo = 'T'.
  wa_f4_values-descripcion = 'Con Tarjeta'.
  APPEND wa_f4_values TO it_f4_values.

  wa_f4_values-tipo = 'S'.
  wa_f4_values-descripcion = 'Sin Tarjeta'.
  APPEND wa_f4_values TO it_f4_values.

ENDFORM.

FORM f4_function.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'Tipo'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'P_FORMAT'
      window_title    = 'Seleccione Tipo Formato'
      value_org       = 'S'
    TABLES
      value_tab       = it_f4_values
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.

FORM sel_file.

  DATA: lt_file TYPE TABLE OF file_table,
        ls_file TYPE file_table,
        lv_file TYPE string,
        lv_rc   TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Seleccione su archivo...'
    CHANGING
      file_table              = lt_file
      rc                      = lv_rc
"     user_action             = gw_user_action
*     file_encoding           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  READ TABLE lt_file INTO ls_file INDEX 1.
  IF sy-subrc EQ 0.
    p_file = ls_file-filename.
    CLEAR ls_file.
  ENDIF.
ENDFORM.

FORM load_file.
  CREATE OBJECT obj_upload.
  DATA vl_filename TYPE rlgrap-filename.
  DATA: vl_valida, vl_ok.

  vl_filename = p_file.
  obj_upload->max_rows = 53000.
  obj_upload->filename = vl_filename.
  obj_upload->header_rows_count = 1.

  PERFORM get_one_column CHANGING vl_valida vl_ok.

  IF vl_valida EQ abap_true.
*    IF vl_mesok EQ abap_true.

    CASE p_format.
      WHEN 'A'.
        obj_upload->upload( CHANGING ct_data = it_interno ).
        PERFORM validar_carga USING it_interno 'A' CHANGING vl_ok.
        IF vl_ok EQ abap_false.
          PERFORM fill_outtable USING it_interno.
        ELSE.
          MESSAGE 'Este archivo ya se encuentra registrado' TYPE 'I' DISPLAY LIKE 'S'.
        ENDIF.
      WHEN 'T'.
        obj_upload->upload( CHANGING ct_data = it_e_tarjeta ).
        PERFORM validar_carga USING it_e_tarjeta 'T' CHANGING vl_ok.
        IF vl_ok EQ abap_false.
          PERFORM fill_outtable USING it_e_tarjeta.
        ELSE.
          MESSAGE 'Este archivo ya se encuentra registrado' TYPE 'I' DISPLAY LIKE 'S'.
        ENDIF.

      WHEN 'S'.
        obj_upload->upload( CHANGING ct_data = it_e_sintarjeta ).
        PERFORM validar_carga USING it_e_sintarjeta 'S' CHANGING vl_ok.
        IF vl_ok EQ abap_false.
          PERFORM fill_outtable USING it_e_sintarjeta.
        ELSE.
          MESSAGE 'Este archivo ya se encuentra registrado' TYPE 'I' DISPLAY LIKE 'S'.
        ENDIF.
        .
    ENDCASE.
*     else.
*      MESSAGE 'Archivo Correcto, pero no corresponde al mes actual.' TYPE 'I'.
*    ENDIF.
    .

  ELSE.
    MESSAGE 'El archivo con el tipo de Formato seleccionado no corresponde' TYPE 'I' DISPLAY LIKE 'S'.
  ENDIF.

ENDFORM.

FORM validar_carga USING p_tabla TYPE STANDARD TABLE
                         p_tipo
                   CHANGING p_check.

  DATA vl_fecha TYPE string.

  DATA:
    desc_table    TYPE REF TO cl_abap_tabledescr,
    desc_struc    TYPE REF TO cl_abap_structdescr,
    components    TYPE abap_component_tab,
    r_type_struct TYPE REF TO cl_abap_structdescr,
    r_type_table  TYPE REF TO cl_abap_tabledescr,
    r_data_tab    TYPE REF TO data,
    r_data_str    TYPE REF TO data.


  TYPES: BEGIN OF st_fec_val,
           tipo,
           bukrs   TYPE bukrs,
           fec_con TYPE zfe_consumo,
           fec_tr  TYPE zfe_transaccion,
           fec_ac  TYPE zfe_autoconsumo,
         END OF st_fec_val.

  TYPES: BEGIN OF st_result,
           tipo,
           bukrs TYPE bukrs,
           fecha TYPE budat,
         END OF st_result.

  DATA: it_fec_val TYPE STANDARD TABLE OF st_fec_val,
        it_result  TYPE STANDARD TABLE OF st_result,
        wa_fec_val LIKE LINE OF it_fec_val.

  FIELD-SYMBOLS:
    <p_component> TYPE abap_compdescr,
    <fs_table>    TYPE INDEX TABLE, "-> here table must by type INDEX TABLE in order to append to it
    <fs_wa>       TYPE any,
    <lfs_comp_wa> TYPE abap_compdescr,
    <ls_struct>   TYPE any,
    <fs_row>      TYPE any,
    <fs_field>    TYPE any.

  desc_table ?= cl_abap_tabledescr=>describe_by_data( p_tabla ).

  desc_struc ?= desc_table->get_table_line_type( ).

  components =  desc_struc->get_components( ).

  r_type_struct = cl_abap_structdescr=>create(
     p_components = components ).

  r_type_table = cl_abap_tabledescr=>create( r_type_struct ).

  CREATE DATA: r_data_tab TYPE HANDLE r_type_table,
               r_data_str TYPE HANDLE r_type_struct.

  ASSIGN: r_data_tab->* TO <fs_table>,r_data_str->* TO <fs_wa>.




  CASE p_tipo.
    WHEN 'A'.
      LOOP AT p_tabla ASSIGNING <ls_struct>.
        APPEND INITIAL LINE TO it_fec_val ASSIGNING <fs_wa>.
        ASSIGN COMPONENT 'FE_AUTOCONSUMO' OF STRUCTURE <ls_struct> TO <fs_field>.
        IF <fs_field> IS NOT INITIAL.
          CONCATENATE <fs_field>+0(4) <fs_field>+5(2) <fs_field>+8(2) INTO vl_fecha.
          ASSIGN COMPONENT 'TIPO' OF STRUCTURE <fs_wa> TO <fs_row>.
          <fs_row> = p_tipo.
          ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_wa> TO <fs_row>.
          <fs_row> = p_bukrs.
          ASSIGN COMPONENT 'FEC_AC' OF STRUCTURE <fs_wa> TO <fs_row>.
          <fs_row> = vl_fecha.
        ENDIF.
      ENDLOOP.
    WHEN 'T'.
      LOOP AT p_tabla ASSIGNING <ls_struct>.
        APPEND INITIAL LINE TO it_fec_val ASSIGNING <fs_wa>.
        ASSIGN COMPONENT 'FE_TRANSACCION' OF STRUCTURE <ls_struct> TO <fs_field>.
        IF <fs_field> IS NOT INITIAL.
          CONCATENATE <fs_field>+6(4) <fs_field>+3(2) <fs_field>+0(2) INTO vl_fecha.
          ASSIGN COMPONENT 'TIPO' OF STRUCTURE <fs_wa> TO <fs_row>.
          <fs_row> = p_tipo.
          ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_wa> TO <fs_row>.
          <fs_row> = p_bukrs.
          ASSIGN COMPONENT 'FEC_TR' OF STRUCTURE <fs_wa> TO <fs_row>.
          <fs_row> = vl_fecha.
        ENDIF.
      ENDLOOP.

    WHEN 'S'.
      LOOP AT p_tabla ASSIGNING <ls_struct>.
        APPEND INITIAL LINE TO it_fec_val ASSIGNING <fs_wa>.
        ASSIGN COMPONENT 'FE_CONSUMO' OF STRUCTURE <ls_struct> TO <fs_field>.
        IF <fs_field> IS NOT INITIAL.
          CONCATENATE <fs_field>+6(4) <fs_field>+3(2) <fs_field>+0(2) INTO vl_fecha.
          ASSIGN COMPONENT 'TIPO' OF STRUCTURE <fs_wa> TO <fs_row>.
          <fs_row> = p_tipo.
          ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_wa> TO <fs_row>.
          <fs_row> = p_bukrs.
          ASSIGN COMPONENT 'FEC_CON' OF STRUCTURE <fs_wa> TO <fs_row>.
          <fs_row> = vl_fecha.
        ENDIF.
      ENDLOOP.
  ENDCASE.


  SORT it_fec_val BY fec_ac fec_con fec_tr.
  DELETE it_fec_val WHERE fec_ac IS INITIAL AND fec_con IS INITIAL AND fec_tr IS INITIAL.
  READ TABLE it_fec_val INTO wa_fec_val INDEX 1.

  REFRESH it_result.
  IF wa_fec_val-fec_ac IS NOT INITIAL.
    DELETE ADJACENT DUPLICATES FROM it_fec_val COMPARING fec_ac.
  ELSEIF wa_fec_val-fec_tr IS NOT INITIAL.
    DELETE ADJACENT DUPLICATES FROM it_fec_val COMPARING fec_tr.
  ELSE.
    DELETE ADJACENT DUPLICATES FROM it_fec_val COMPARING fec_con.
  ENDIF.

  CASE p_tipo.
    WHEN 'A'.
      SELECT id_forori AS tipo, cv_sociedad AS bukrs, fe_carmas AS fecha
            INTO TABLE @it_result
      FROM zccomb
      FOR ALL ENTRIES IN @it_fec_val
      WHERE fe_autoconsumo = @it_fec_val-fec_ac
      AND id_forori = @it_fec_val-tipo
      AND cv_sociedad = @it_fec_val-bukrs.
    WHEN 'T'.

      SELECT id_forori AS tipo, cv_sociedad AS bukrs, fe_carmas AS fecha
             INTO TABLE @it_result
       FROM zccomb
       FOR ALL ENTRIES IN @it_fec_val
       WHERE fe_transaccion = @it_fec_val-fec_tr
       AND id_forori = @it_fec_val-tipo
       AND cv_sociedad = @it_fec_val-bukrs.

    WHEN 'S'.
      SELECT id_forori AS tipo, cv_sociedad AS bukrs, fe_carmas AS fecha
             INTO TABLE @it_result
       FROM zccomb
       FOR ALL ENTRIES IN @it_fec_val
       WHERE fe_consumo = @it_fec_val-fec_con
       AND id_forori = @it_fec_val-tipo
       AND cv_sociedad = @it_fec_val-bukrs.
  ENDCASE.
  IF it_result IS NOT INITIAL.
    p_check = abap_true.
  ELSE.
    p_check = abap_false.
  ENDIF.

ENDFORM.
FORM fill_outtable USING p_table TYPE STANDARD TABLE.

  FIELD-SYMBOLS: <ls_struct> TYPE any,
                 <fs_field>  TYPE any.

  DATA vl_hora       TYPE sy-uzeit.


  DATA: wa_id     TYPE char10, wa_unidad TYPE char10.

  SELECT equnr, groes
  INTO TABLE @DATA(it_equipos)
  FROM equi.

  CASE p_format.
    WHEN 'A'.
      LOOP AT p_table ASSIGNING <ls_struct>.
        MOVE-CORRESPONDING <ls_struct> TO wa_autoconsumo.
        wa_autoconsumo-fe_carmas = sy-datum.
        IF vl_hora IS INITIAL.
          vl_hora = sy-uzeit.
        ENDIF.
        "se agrega un segunda para evitar duplicate key
        CALL FUNCTION 'END_TIME_DETERMINE'
          EXPORTING
            duration   = 1
            unit       = 'S'
          IMPORTING
            end_time   = vl_hora
          CHANGING
            start_date = sy-datum
            start_time = vl_hora.

        wa_autoconsumo-hr_carmas = vl_hora.
        vl_hora = wa_autoconsumo-hr_carmas.
        """""""""""SE OBTIENE EL NUMERO DE EQUIPO POR EL NUMERO DE TARJETA
        ASSIGN COMPONENT 'NO_TARAUT' OF STRUCTURE <ls_struct> TO <fs_field>.
        READ TABLE it_equipos INTO DATA(vl_equnr) WITH KEY groes = <fs_field>.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT 'NO_UNIDAD' OF STRUCTURE <ls_struct> TO <fs_field>.
          <fs_field> = vl_equnr.
          CLEAR vl_equnr.
        ENDIF.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        wa_autoconsumo-id_forori = p_format.
        wa_autoconsumo-cv_sociedad = p_bukrs.
        wa_autoconsumo-rg_procesado = '0'.
        wa_autoconsumo-no_unidad = <fs_field>.
        ASSIGN COMPONENT 'FE_AUTOCONSUMO' OF STRUCTURE <ls_struct> TO <fs_field>.
        wa_autoconsumo-hr_autoconsumo = <fs_field>+11(8).
        CONCATENATE <fs_field>+0(4) <fs_field>+5(2) <fs_field>+8(2) INTO wa_autoconsumo-fe_autoconsumo.
        APPEND wa_autoconsumo TO it_autoconsumo.
      ENDLOOP.
      PERFORM valida_autoconsumo.

      PERFORM show_alv USING it_autoconsumo.
    WHEN 'T'.
      LOOP AT p_table ASSIGNING <ls_struct>.
        MOVE-CORRESPONDING <ls_struct> TO wa_contarjeta.
        wa_contarjeta-fe_carmas = sy-datum.
        IF vl_hora IS INITIAL.
          vl_hora = sy-uzeit.
        ENDIF.
        "se agrega un segunda para evitar duplicate key
        CALL FUNCTION 'END_TIME_DETERMINE'
          EXPORTING
            duration   = '1'
            unit       = 'S'
          IMPORTING
            end_time   = vl_hora
          CHANGING
            start_date = sy-datum
            start_time = vl_hora.

        wa_contarjeta-hr_carmas = vl_hora.
        vl_hora = wa_contarjeta-hr_carmas.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """""""""""""separar el ID del vehiculo con el nombre en SAP
        CLEAR: wa_id, wa_unidad.
        ASSIGN COMPONENT 'TX_VEHICULO' OF STRUCTURE <ls_struct> TO <fs_field>.
        SPLIT <fs_field> AT space INTO wa_id wa_unidad.
        CONDENSE wa_unidad NO-GAPS.
        <fs_field> = wa_unidad.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        wa_contarjeta-id_forori = p_format.
        wa_contarjeta-cv_sociedad = p_bukrs.
        wa_contarjeta-rg_procesado = '0'.
        wa_contarjeta-tx_vehiculo = <fs_field>.
        ASSIGN COMPONENT 'FE_TRANSACCION' OF STRUCTURE <ls_struct> TO <fs_field>.
        wa_contarjeta-hr_transaccion = <fs_field>+11(8).
        CONCATENATE <fs_field>+6(4) <fs_field>+3(2) <fs_field>+0(2) INTO <fs_field>.
        wa_contarjeta-fe_transaccion = <fs_field>.
        APPEND wa_contarjeta TO it_contarjeta.
      ENDLOOP.
      DELETE it_contarjeta WHERE es_transaccion NE 'APROBADA'.
      PERFORM valida_contarjeta.
      PERFORM show_alv USING it_contarjeta.
    WHEN 'S'.

      LOOP AT p_table ASSIGNING <ls_struct>.
        MOVE-CORRESPONDING <ls_struct> TO wa_sintarjeta.
        wa_sintarjeta-fe_carmas = sy-datum.
        IF vl_hora IS INITIAL.
          vl_hora = sy-uzeit.
        ENDIF.
        "se agrega un segundo para evitar duplicate key
        CALL FUNCTION 'END_TIME_DETERMINE'
          EXPORTING
            duration   = 1
            unit       = 'S'
          IMPORTING
            end_time   = vl_hora
          CHANGING
            start_date = sy-datum
            start_time = vl_hora.

        wa_sintarjeta-hr_carmas = vl_hora.
        vl_hora = wa_sintarjeta-hr_carmas.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        REPLACE ALL OCCURRENCES OF ':' IN wa_sintarjeta-hr_consumo WITH space.
        CONCATENATE wa_sintarjeta-hr_consumo '00' INTO wa_sintarjeta-hr_consumo.
        CONDENSE wa_sintarjeta-hr_consumo NO-GAPS.
        CALL FUNCTION 'END_TIME_DETERMINE'
          EXPORTING
            duration   = 1
            unit       = 'S'
          IMPORTING
            end_time   = wa_sintarjeta-hr_consumo
          CHANGING
            start_date = sy-datum
            start_time = wa_sintarjeta-hr_consumo.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        wa_sintarjeta-id_forori = p_format.
        wa_sintarjeta-cv_sociedad = p_bukrs.
        wa_sintarjeta-rg_procesado = '0'.
        ASSIGN COMPONENT 'FE_CONSUMO' OF STRUCTURE <ls_struct> TO <fs_field>.
        CONCATENATE <fs_field>+6(4) <fs_field>+3(2) <fs_field>+0(2) INTO wa_sintarjeta-fe_consumo.
        APPEND wa_sintarjeta TO it_sintarjeta.
      ENDLOOP.
      PERFORM valida_sintarjeta.
      PERFORM show_alv USING it_sintarjeta.
  ENDCASE.
  .
ENDFORM.

FORM create_fieldcat.

  DATA lv_structure LIKE dd02l-tabname.
  DATA wa_fieldcat TYPE slis_fieldcat_alv.
  DATA lv_pos TYPE i.
  CASE p_format.
    WHEN 'A'.
      lv_structure = 'ZCCOMB_ST_AUTOC'.
    WHEN 'T'.
      lv_structure = 'ZCCOMB_ST_CONSUM_TARJETA'.
    WHEN 'S'.
      lv_structure = 'ZCCOMB_ST_CONSUM_SIN_TARJETA'.
  ENDCASE.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
*     i_internal_tabname     =
      i_structure_name       = lv_structure
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  wa_fieldcat-fieldname = 'FE_CARMAS'.
  wa_fieldcat-seltext_m = 'Fecha Carga'.
  wa_fieldcat-col_pos = 1.
  APPEND wa_fieldcat TO lt_fieldcat.

  wa_fieldcat-fieldname = 'HR_CARMAS'.
  wa_fieldcat-seltext_m = 'Hr. Carga'.
  wa_fieldcat-col_pos = 2.
  APPEND wa_fieldcat TO lt_fieldcat.

  wa_fieldcat-fieldname = 'ID_FORORI'.
  wa_fieldcat-seltext_m = 'Tipo Formato'.
  wa_fieldcat-col_pos = 3.
  APPEND wa_fieldcat TO lt_fieldcat.

  wa_fieldcat-fieldname = 'CV_SOCIEDAD'.
  wa_fieldcat-seltext_m = 'Sociedad'.
  wa_fieldcat-col_pos = 4.
  APPEND wa_fieldcat TO lt_fieldcat.

  wa_fieldcat-fieldname = 'RG_PROCESADO'.
  wa_fieldcat-seltext_m = 'Procesado'.
  wa_fieldcat-col_pos = 5.
  APPEND wa_fieldcat TO lt_fieldcat.

  lv_pos = 6.
  LOOP AT lt_fieldcat INTO wa_fieldcat.
    IF wa_fieldcat-fieldname EQ 'FE_CARMAS'.
      EXIT.
    ENDIF.


    wa_fieldcat-col_pos = lv_pos.

    MODIFY lt_fieldcat FROM wa_fieldcat INDEX sy-tabix TRANSPORTING col_pos.
    lv_pos = lv_pos + 1.

  ENDLOOP.

  IF p_format = 'A'.
    CLEAR wa_fieldcat.
    wa_fieldcat-fieldname = 'HR_AUTOCONSUMO'.
    wa_fieldcat-col_pos = 12.
    MODIFY lt_fieldcat FROM wa_fieldcat TRANSPORTING col_pos WHERE fieldname = 'HR_AUTOCONSUMO'.
  ELSEIF p_format = 'T'.
    wa_fieldcat-fieldname = 'HR_TRANSACCION'.
    wa_fieldcat-col_pos = 16.
    MODIFY lt_fieldcat FROM wa_fieldcat TRANSPORTING col_pos WHERE fieldname = 'HR_TRANSACCION'.

  ENDIF.


*  wa_fieldcat-col_pos   = lv_pos.
*  wa_fieldcat-fieldname = 'TABCOLOR'.
*  wa_fieldcat-ref_fieldname = 'COLTAB'.
*  wa_fieldcat-ref_tabname = 'CALENDAR_TYPE'.
*  APPEND wa_fieldcat TO lt_fieldcat.

  SORT lt_fieldcat BY col_pos.
ENDFORM.


FORM show_alv USING p_table TYPE STANDARD TABLE.

  PERFORM create_fieldcat.

  ls_layout-zebra = 'X'.
  ls_layout-coltab_fieldname = 'TCOLOR'.
  "layout-info_fieldname = 'COLOR_LINE'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
*     i_callback_top_of_page   = space
*     i_callback_html_top_of_page = space
*     i_callback_html_end_of_list = space
*     i_structure_name         =
*     i_background_id          =
*     i_grid_title             =
*     i_grid_settings          =
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
    TABLES
      t_outtab                 = p_table
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.

FORM set_status USING rt_extab TYPE slis_t_extab..
  SET PF-STATUS 'ZSTANDARD'.
ENDFORM.

FORM user_command USING p_ucomm LIKE sy-ucomm
              p_selfield TYPE slis_selfield.

  DATA cx TYPE REF TO cx_root.
  DATA msg TYPE string.

  CASE p_ucomm.
    WHEN '&SAVE'.
      IF p_format = 'A'.
        LOOP AT it_autoconsumo INTO wa_autoconsumo.
          MOVE-CORRESPONDING wa_autoconsumo TO wa_outtable.
          APPEND wa_outtable TO it_outtable.
        ENDLOOP.
*        INSERT  zccomb FROM TABLE it_outtable.
      ELSEIF p_format = 'T'.
        LOOP AT it_contarjeta INTO wa_contarjeta.
          MOVE-CORRESPONDING wa_contarjeta TO wa_outtable.
          APPEND wa_outtable TO it_outtable.
        ENDLOOP.
*        INSERT  zccomb FROM TABLE it_outtable.
      ELSEIF p_format = 'S'.
        LOOP AT it_sintarjeta INTO wa_sintarjeta.
          MOVE-CORRESPONDING wa_sintarjeta TO wa_outtable.
          APPEND wa_outtable TO it_outtable.
        ENDLOOP.
      ENDIF.
      IF lv_flag_error EQ abap_false.
        TRY.

            INSERT  zccomb FROM TABLE it_outtable.
            IF sy-subrc EQ 0.
              MESSAGE 'Datos grabados correctamente' TYPE 'S'.
            ELSE.
              MESSAGE 'Ocurrio un error al intentar grabar los datos' TYPE 'E' DISPLAY LIKE 'S'.
            ENDIF.
          CATCH cx_sy_open_sql_db INTO cx.
            MESSAGE 'Manejo de Archivo Finalizado. No se puede tratar la misma carga 2 veces' TYPE 'E'.

        ENDTRY.
      ELSE.
        MESSAGE 'Hay datos con errores. Imposible Grabar' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
ENDFORM.

FORM get_one_column
                    CHANGING p_valida TYPE c
                             p_mesok TYPE c.

  DATA vl_filename TYPE rlgrap-filename.
  DATA: li_exceldata  TYPE STANDARD TABLE OF alsmex_tabline.
  DATA: ls_exceldata  LIKE LINE OF li_exceldata.
  DATA: vl_flag,vl_mesok.
  DATA vl_fecha TYPE string.
  DATA vl_mes(2) TYPE c.
  DATA vl_indice TYPE i.

  vl_filename = p_file.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = vl_filename
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 11
      i_end_row               = 500
    TABLES
      intern                  = li_exceldata
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.


  READ TABLE li_exceldata INTO ls_exceldata INDEX 1.

  CASE p_format.
    WHEN 'A'.
      IF ls_exceldata-value = 'TAG'.
        vl_flag = abap_true.
        vl_indice = 18.
      ENDIF.
    WHEN 'T'.
      IF ls_exceldata-value = 'Id Grupo Región'.
        vl_flag = abap_true.
        vl_indice = 22.
      ENDIF.

    WHEN 'S'.
      IF ls_exceldata-value = 'Placas'.
        vl_flag = abap_true.
        vl_indice = 14.
      ENDIF.
  ENDCASE.

*  CLEAR ls_exceldata.
*  READ TABLE li_exceldata INTO ls_exceldata INDEX vl_indice.
*  vl_fecha = ls_exceldata-value.
*
*  CASE  vl_indice.
*    WHEN 18.
*      vl_mes = vl_fecha+5(2).
*
*    WHEN 22.
*      vl_mes = vl_fecha+3(2).
*    WHEN 14.
*      vl_mes = vl_fecha+3(2).
*  ENDCASE.
*
*  IF vl_mes EQ sy-datum+4(2).
*    vl_mesok = abap_true.
*  ENDIF.

  p_valida = vl_flag.
*  p_mesok = vl_mesok.

ENDFORM.

FORM valida_autoconsumo.

  FIELD-SYMBOLS: <fs_field>  TYPE any,
                 <fs_struct> TYPE any,
                 <fs_color>  TYPE table.
  DATA: vl_equnr    TYPE equnr, vl_odometro TYPE qsollwertc.
  SELECT equnr, groes INTO TABLE @DATA(it_equi)
  FROM equi.

  vl_odometro = 1.

  LOOP AT it_autoconsumo ASSIGNING <fs_struct>.

    ASSIGN COMPONENT 'NO_UNIDAD' OF STRUCTURE <fs_struct> TO <fs_field>.
    IF <fs_field> IS INITIAL.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'NO_UNIDAD'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ELSE.
      vl_equnr = <fs_field>.
    ENDIF.

    UNASSIGN <fs_field>.
    UNASSIGN <fs_color>.
    ASSIGN COMPONENT 'KM_DIFERENCIA' OF STRUCTURE <fs_struct> TO <fs_field>.
    IF <fs_field> LE 0.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'KM_DIFERENCIA'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ELSE.
      IF vl_equnr IS NOT INITIAL.
        PERFORM get_kilometraje USING vl_equnr
                                CHANGING vl_odometro.
        IF  <fs_field> LT vl_odometro.

          ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
          CLEAR xcolor.
          xcolor-fieldname = 'KM_DIFERENCIA'.
          xcolor-color-col = '6'.
          xcolor-color-int = '1'. "Intensified on/off
          xcolor-color-inv = '0'.
          APPEND xcolor TO <fs_color>.
          lv_flag_error = abap_true.

        ENDIF.
      ENDIF.
    ENDIF.

    UNASSIGN <fs_field>.
    UNASSIGN <fs_color>.
    ASSIGN COMPONENT 'NO_TARAUT' OF STRUCTURE <fs_struct> TO <fs_field>.
    READ TABLE it_equi INTO DATA(wa_equi) WITH KEY groes = <fs_field>.
    IF sy-subrc NE 0.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'NO_TARAUT'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ENDIF.


    UNASSIGN <fs_field>.
    UNASSIGN <fs_color>.
    ASSIGN COMPONENT 'CT_AUTOCONSUMO' OF STRUCTURE <fs_struct> TO <fs_field>.
    IF <fs_field> LE 0.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'CT_AUTOCONSUMO'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ENDIF.






  ENDLOOP.
ENDFORM.

FORM valida_contarjeta.
  FIELD-SYMBOLS: <fs_field>  TYPE any,
                 <fs_struct> TYPE any,
                 <fs_color>  TYPE table.

  DATA: vl_id     TYPE string, vl_unidad TYPE string.
  DATA: vl_equnr    TYPE equnr, vl_odometro TYPE qsollwertc.

  vl_odometro = 1.

  SELECT equnr, groes INTO TABLE @DATA(it_equi)
  FROM equi.

  SELECT znum_tarjeta, zunidad
    INTO TABLE @DATA(it_tarjetas)
    FROM zpm_tt_tarjetas
 .


  LOOP AT it_contarjeta ASSIGNING <fs_struct>.

    ASSIGN COMPONENT 'NO_TARJETA' OF STRUCTURE <fs_struct> TO <fs_field>.

    READ TABLE it_tarjetas INTO DATA(wa_tarjetas) WITH KEY znum_tarjeta = <fs_field>.
    IF sy-subrc EQ 0.

      READ TABLE it_equi INTO DATA(wa_data) WITH KEY equnr = wa_tarjetas-zunidad.
      IF sy-subrc NE 0.
        ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
        CLEAR xcolor.
        xcolor-fieldname = 'NO_TARJETA'.
        xcolor-color-col = '6'.
        xcolor-color-int = '1'. "Intensified on/off
        xcolor-color-inv = '0'.
        APPEND xcolor TO <fs_color>.
        lv_flag_error = abap_true.
      ELSE.
        vl_equnr = wa_tarjetas-zunidad.
        ASSIGN COMPONENT 'TX_VEHICULO' OF STRUCTURE <fs_struct> TO <fs_field>.
        <fs_field> = vl_equnr.
      ENDIF.
    ELSE.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'NO_TARJETA'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.

    ENDIF.


    UNASSIGN <fs_field>.
    UNASSIGN <fs_color>.
    ASSIGN COMPONENT 'FE_TRANSACCION' OF STRUCTURE <fs_struct> TO <fs_field>.
    IF <fs_field> IS INITIAL.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'FE_TRANSACCION'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ENDIF.

    UNASSIGN <fs_field>.
    UNASSIGN <fs_color>.
    ASSIGN COMPONENT 'KM_TRANSACCION' OF STRUCTURE <fs_struct> TO <fs_field>.
    IF <fs_field> LE 0.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'KM_TRANSACCION'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ELSE.
      IF vl_equnr IS NOT INITIAL.
        PERFORM get_kilometraje USING vl_equnr
                                CHANGING vl_odometro.

        IF  <fs_field> LT vl_odometro.
          ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
          CLEAR xcolor.
          xcolor-fieldname = 'KM_TRANSACCION'.
          xcolor-color-col = '6'.
          xcolor-color-int = '1'. "Intensified on/off
          xcolor-color-inv = '0'.
          APPEND xcolor TO <fs_color>.
          lv_flag_error = abap_true.
        ENDIF.

      ENDIF.
    ENDIF.

    UNASSIGN <fs_field>.
    UNASSIGN <fs_color>.
    ASSIGN COMPONENT 'CD_MERCANCIA' OF STRUCTURE <fs_struct> TO <fs_field>.
    IF <fs_field> LE 0.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'CD_MERCANCIA'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ENDIF.




  ENDLOOP.
ENDFORM.

FORM valida_sintarjeta.

  FIELD-SYMBOLS: <fs_field>  TYPE any,
                 <fs_struct> TYPE any,
                 <fs_color>  TYPE table.

  DATA: vl_id     TYPE string, vl_unidad TYPE string.

  DATA: vl_equnr    TYPE equnr, vl_odometro TYPE qsollwertc.

  SELECT equnr, groes INTO TABLE @DATA(it_equi)
  FROM equi.

  vl_odometro = 1.

  LOOP AT it_sintarjeta ASSIGNING <fs_struct>.
    ASSIGN COMPONENT 'CV_UNIDAD' OF STRUCTURE <fs_struct> TO <fs_field>.

    vl_unidad = <fs_field>.
    READ TABLE it_equi INTO DATA(wa_data) WITH KEY equnr = vl_unidad.
    IF sy-subrc NE 0.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'CV_UNIDAD'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ELSE.
      vl_equnr = vl_unidad.
    ENDIF.

    UNASSIGN <fs_field>.
    UNASSIGN <fs_color>.
    ASSIGN COMPONENT 'LT_CONSUMO' OF STRUCTURE <fs_struct> TO <fs_field>.
    IF <fs_field> LE 0.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'LT_CONSUMO'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ENDIF.


    UNASSIGN <fs_field>.
    UNASSIGN <fs_color>.
    ASSIGN COMPONENT 'KM_ODOMETRO' OF STRUCTURE <fs_struct> TO <fs_field>.
    IF <fs_field> LE 0.
      ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
      CLEAR xcolor.
      xcolor-fieldname = 'KM_ODOMETRO'.
      xcolor-color-col = '6'.
      xcolor-color-int = '1'. "Intensified on/off
      xcolor-color-inv = '0'.
      APPEND xcolor TO <fs_color>.
      lv_flag_error = abap_true.
    ELSE.
      IF vl_equnr IS NOT INITIAL.
        PERFORM get_kilometraje USING vl_equnr
                                CHANGING vl_odometro.

        IF  <fs_field> LT vl_odometro.
          ASSIGN COMPONENT 'TCOLOR' OF STRUCTURE <fs_struct> TO <fs_color>.
          CLEAR xcolor.
          xcolor-fieldname = 'KM_ODOMETRO'.
          xcolor-color-col = '6'.
          xcolor-color-int = '1'. "Intensified on/off
          xcolor-color-inv = '0'.
          APPEND xcolor TO <fs_color>.
          lv_flag_error = abap_true.
        ENDIF.

      ENDIF.
    ENDIF.


  ENDLOOP.
ENDFORM.


FORM get_kilometraje USING p_equnr TYPE equnr
                     CHANGING p_odometro TYPE qsollwertc.

  DATA: lv_expo TYPE qsollwerte,
        lv_char TYPE qsollwertc.


  SELECT imptt~point, MAX( mdocm ) AS mdocm
  INTO  TABLE @DATA(it_itob)
  FROM imptt
  INNER JOIN itob ON itob~objnr = imptt~mpobj
  INNER JOIN imrg ON imrg~point = imptt~point AND cancl NE 'X'
  AND inact NE 'X'
  AND psort = 'KILOMETRAJE'
  WHERE  equnr EQ @p_equnr
    GROUP BY imptt~point.

  IF it_itob IS NOT INITIAL.

    LOOP AT  it_itob INTO DATA(wa_itob).

      SELECT SINGLE recdv INTO @DATA(wa_recdv) FROM imrg WHERE mdocm = @wa_itob-mdocm AND point = @wa_itob-point.

      CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
        EXPORTING
          i_number_of_digits       = '0'
          i_fltp_value             = wa_recdv
          i_value_not_initial_flag = 'X'
          i_screen_fieldlength     = 16
        IMPORTING
          e_char_field             = lv_char.

      CONDENSE lv_char NO-GAPS.

      p_odometro = lv_char.

    ENDLOOP.
  else.
    p_odometro = 1.

  ENDIF.

ENDFORM.
