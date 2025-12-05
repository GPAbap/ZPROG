*&---------------------------------------------------------------------*
*&  Include           ZCO_COCKPIT_PRESUPUESTO_FUN
*&  07032023
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INIT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_header .
  DATA: wa_header TYPE slis_listheader.
  REFRESH gt_header.

* Cargo el Título
  wa_header-typ = 'H'.
  wa_header-info = 'Cockpit Presupuesto'.
  APPEND  wa_header TO gt_header.

* Cargo el Subtítulo
  CLEAR wa_header.
  wa_header-typ = 'A'.
  wa_header-info = sy-datum.
  APPEND  wa_header TO gt_header.
ENDFORM.                    " INIT_HEADER
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM top_of_page .
* Pasa a la cabecera el logo
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = 'ENJOYSAP_LOGO'
      it_list_commentary = gt_header.
ENDFORM.                    " TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  FILL_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_EVENTS  text
*      -->P_ENDMODULE  text
*----------------------------------------------------------------------*
FORM fill_event  USING    p_gt_events TYPE slis_t_event
      .

  DATA: ls_event TYPE slis_alv_event.

* Toma los eventos
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = p_gt_events.

* Selecciono el evento #TOP_OF_PAGE# y le seteo el FORM a ejecutar
  CLEAR ls_event.

  READ TABLE p_gt_events WITH KEY name = slis_ev_top_of_page
  INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'TOP_OF_PAGE' TO ls_event-form.
    APPEND ls_event TO p_gt_events.
  ENDIF.
ENDFORM.                    " FILL_EVENT
*&---------------------------------------------------------------------*
*&      Form  INIT_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_fieldcat .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
*     i_internal_tabname     = 'zco_st_laycargapresupuesto'
      i_structure_name       = 'zco_st_laycargapresupuesto'
*     I_CLIENT_NEVER_DISPLAY = ' '
      i_inclname             = sy-repid
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = lt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " INIT_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  INIT_PARAMETERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_parameters .


ENDFORM.                    " INIT_PARAMETERS
*&---------------------------------------------------------------------*
*&      Form  GET_RUTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
FORM get_ruta . "CHANGING p_ruta.
  DATA: lt_file     TYPE filetable,
        ls_file     TYPE file_table,
        lv_rc       TYPE i,
        l_sel_dir   TYPE string,
        p_ruta(132) TYPE c,
        new_date    TYPE sy-datum.

  DATA: vl_name(10) TYPE c, vl_ext(6) TYPE c.
  REFRESH it_xls.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = ' '
      initial_folder       = ' '
    CHANGING
      selected_folder      = l_sel_dir
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  p_ruta = l_sel_dir.

  CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
    EXPORTING
      directory  = p_ruta
*     FILTER     = '*.*'
* IMPORTING
*     FILE_COUNT =
*     DIR_COUNT  =
    TABLES
      file_table = file_table
      dir_table  = dir_table
    EXCEPTIONS
      cntl_error = 1
      OTHERS     = 2.

  IF sy-subrc = 0.

    LOOP AT file_table INTO wa_file_table.

      IF wa_file_table-pathname CS '~'."rutas abreviadas

      ELSE.


        SPLIT wa_file_table-pathname AT '.' INTO vl_name vl_ext .
        TRANSLATE vl_ext TO LOWER CASE.
        IF vl_ext EQ 'xlsx' OR vl_ext EQ 'xls'.
          CONCATENATE p_ruta '\' wa_file_table-pathname INTO wa_xls-archivo.
          wa_xls-status = '@09@'. "Yellow traffic light no tratado
          CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
            EXPORTING
              date      = sy-datum
              days      = 0
              months    = 0
*             SIGNUM    = '+'
              years     = 1
            IMPORTING
              calc_date = new_date.

          wa_xls-anio = new_date+0(4).
          APPEND wa_xls TO it_xls.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF it_xls IS NOT INITIAL.
    PERFORM show_files_pres.
  ENDIF.
ENDFORM.                    " GET_RUTA
*&---------------------------------------------------------------------*
*&      Form  LOAD_EXCEL_TO_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM load_excel_to_table USING p_wa_xls_archivo
CHANGING p_ok .
  DATA vl_filename TYPE rlgrap-filename.
  DATA: lo_uploader TYPE REF TO lcl_excel_uploader.


  REFRESH it_outtable.

  vl_filename = p_wa_xls_archivo .
  CREATE OBJECT lo_uploader.
  lo_uploader->max_rows = 53000.
  lo_uploader->filename = vl_filename.
  lo_uploader->header_rows_count = 2.
  lo_uploader->upload( CHANGING ct_data = it_outtable ).

  IF sy-subrc EQ 0.
    p_ok = '1'.
  ENDIF.
ENDFORM.                    " LOAD_EXCEL_TO_TABLE
*&---------------------------------------------------------------------*
*&      Form  CREATE_DYNAMIC_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_EXCEL  text
*----------------------------------------------------------------------*
FORM create_dynamic_itab."  USING    p_it_excel TYPE type_excel_tab .

  DATA: lr_datdr TYPE REF TO cl_abap_datadescr,
        lr_struc TYPE REF TO cl_abap_structdescr,
        gw_comp  TYPE abap_componentdescr,
        gt_comp  TYPE abap_component_tab.

  FIELD-SYMBOLS: <fs_excel> TYPE LINE OF type_excel_tab.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = 'zco_tt_planpres'      "i_structure_name = 'zco_st_laycargapresupuesto'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = lt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT lt_fieldcat INTO wa_fieldcat.
    lr_datdr ?= cl_abap_datadescr=>describe_by_data( wa_fieldcat-fieldname ).
    gw_comp-name = wa_fieldcat-fieldname.
    gw_comp-type = lr_datdr.
    APPEND gw_comp  TO gt_comp. CLEAR gw_comp.
  ENDLOOP.

  TRY.
      lr_struc = cl_abap_structdescr=>create( p_components = gt_comp ).
    CATCH cx_sy_struct_creation.
      WRITE: / 'CX_SY_STRUCT_CREATION ERROR'.
  ENDTRY.

  CREATE DATA x_dyn_wa TYPE HANDLE lr_struc.
  ASSIGN x_dyn_wa->*  TO <fs_wa>.
  CREATE DATA t_dyn_tab LIKE STANDARD TABLE OF <fs_wa>.
  ASSIGN t_dyn_tab->* TO <fs_table>.


ENDFORM.                    " CREATE_DYNAMIC_ITAB
*&---------------------------------------------------------------------*
*&      Form  FILL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_EXCEL  text
*----------------------------------------------------------------------*
FORM fill_data  USING    p_it_excel TYPE type_excel_tab .
  FIELD-SYMBOLS: <fs_excel> TYPE LINE OF type_excel_tab,
                 <fs_c>     TYPE LINE OF type_excel_tab,
                 <fs_field> TYPE any.

  DATA row TYPE i.
  DATA vl_tipo(20) TYPE c.
  DATA vl_leyenda(100) TYPE c.
  CONCATENATE TEXT-001 '(Import. Excel)' INTO vl_leyenda.
  MESSAGE vl_leyenda TYPE 'S'.
  LOOP AT p_it_excel ASSIGNING <fs_excel>. "WHERE ( row NE '1' ) . " 1 -> cabecera
*  ¿Que columna estamos tratando ?
    READ TABLE lt_fieldcat INTO wa_fieldcat INDEX <fs_excel>-col.
    CHECK ( sy-subrc EQ 0 ).

    READ TABLE p_it_excel ASSIGNING <fs_c> WITH  KEY row = <fs_excel>-row col = <fs_excel>-col.
    CHECK ( sy-subrc EQ 0 ).


    row = 0.
    row = <fs_excel>-row.
    READ TABLE <fs_table> ASSIGNING <fs_wa> INDEX row.
    IF ( sy-subrc <> 0 ).
      APPEND INITIAL LINE TO <fs_table>  ASSIGNING <fs_wa>.
      vl_tipo = <fs_c>-value.
    ENDIF.
    "TRANSLATE <fs_c>-value USING '- '.
    "CONDENSE <fs_c>-value NO-GAPS.
    CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
      EXPORTING
        intext  = <fs_c>-value
      IMPORTING
        outtext = <fs_c>-value.
    CONDENSE <fs_c>-value NO-GAPS.
    REPLACE ALL OCCURRENCES OF '$' IN <fs_c>-value WITH space.
    REPLACE ALL OCCURRENCES OF ',' IN <fs_c>-value WITH space.
    REPLACE ALL OCCURRENCES OF '-' IN <fs_c>-value WITH space.
    CONDENSE <fs_c>-value NO-GAPS.

    ASSIGN COMPONENT wa_fieldcat-fieldname OF STRUCTURE <fs_wa> TO <fs_field>.
    CHECK ( sy-subrc EQ 0 ).

*  Realizar las conversiones de datos necesarias ahora
    IF wa_fieldcat-fieldname EQ 'MATERIAL'.
      PERFORM val_data USING vl_tipo <fs_excel>-value
      CHANGING <fs_excel>-value.
    ENDIF.
    <fs_field> = <fs_excel>-value.

    "PERFORM mostrar_progreso USING vl_leyenda 1.
  ENDLOOP.




ENDFORM.                    " FILL_DATA
*&---------------------------------------------------------------------*
*&      Form  VAL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM val_data USING tipo TYPE any
                    valor TYPE any
              CHANGING p_valor TYPE any.

  CONDENSE tipo NO-GAPS.
  DATA vl_matnr LIKE mara-matnr.
  DATA vl_htype LIKE dd01v-datatype.

  vl_matnr = valor.
  CASE tipo.
    WHEN 'MATERIAL'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = vl_matnr
        IMPORTING
          output = vl_matnr.
      p_valor = vl_matnr.
    WHEN 'SERVICIO'.

      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          string_in = vl_matnr
        IMPORTING
*         string_out       = vl_sout
          htype     = vl_htype.
      .

      IF vl_htype EQ 'NUMC'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = vl_matnr
          IMPORTING
            output = vl_matnr.
      ELSE.
        vl_matnr = ''.
      ENDIF.

      p_valor = vl_matnr.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.                    " VAL_DATA

*&---------------------------------------------------------------------*
*&      Form  get_idpres
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_IDPRESS  text
*----------------------------------------------------------------------*
FORM get_idpres CHANGING p_idpress TYPE char10.

  DATA
        lv_lines TYPE i.

  DESCRIBE TABLE it_outtable
  LINES lv_lines.

  IF lv_lines GT 0.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr   = '01'
        object        = 'ZRNPLANDA'
        ignore_buffer = 'X'
      IMPORTING
        number        = p_idpress.
  ENDIF.

ENDFORM. "get_idpress

*&---------------------------------------------------------------------*
*&      Form  save_header_press
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IDPRES   text
*      <--P_OK       text
*----------------------------------------------------------------------*
FORM save_header_pres USING p_idpres TYPE char10
      p_archivo TYPE any
      p_comentario TYPE char200
      p_anio TYPE i
CHANGING p_ok .
  CLEAR wa_planpresh.

  wa_planpresh-idpres = p_idpres.
  wa_planpresh-gjahr = p_anio.
  wa_planpresh-cveaut = '01'.
  wa_planpresh-usuario = sy-uname.
  wa_planpresh-fecha = sy-datum.
  wa_planpresh-hora = sy-uzeit.
  wa_planpresh-ruta_archivo = p_archivo.
  wa_planpresh-comentario = p_comentario.
  wa_planpresh-autorizado = 'X'.
  wa_planpresh-autorizador = sy-uname.
  wa_planpresh-fechaaut = sy-datum.
  wa_planpresh-horaaut = sy-uzeit.
  wa_planpresh-statustx = 'Carga automática de Materiales'.

  INSERT zco_tt_planpresh FROM wa_planpresh.

  IF sy-subrc EQ 0.
    p_ok = '1'.
  ELSE.
    p_ok = '0'.
  ENDIF.



ENDFORM. "save_header_pres

*&---------------------------------------------------------------------*
*&      Form  save_position_pres
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IDPRES   text
*----------------------------------------------------------------------*
FORM save_position_pres USING p_idpres TYPE char10
      p_maxpospress TYPE num5
      p_anio TYPE i
CHANGING p_ok TYPE c.
  DATA lv_position TYPE i.
  DATA vl_leyenda(100) TYPE c.
  DATA: it_return   TYPE  bapiret2,
        it_bapiret2 TYPE TABLE OF bapiret2.
  DATA lv_answer TYPE c.
  DATA wa_lgort LIKE LINE OF it_lgort.
  DATA: lv_matnr TYPE matnr,lv_werks TYPE werks_d.
  DATA: lv_preuni     TYPE netpr,
        lv_inflacion  TYPE netpr,
        lv_preunipres TYPE netpr.

  DATA: lv_tipo         TYPE char20,
        lv_fieldnameaux TYPE lvc_fname.

  DATA: lv_numfile     TYPE i, lv_numpres TYPE i,
        s_numfile(6)   TYPE c, s_numpres(6) TYPE c,
        s_numregistros TYPE string.

  DATA: lv_error,message_error TYPE symsgv.

  DATA: num_mes       LIKE t247-mnr,
        mes_corto     LIKE t247-ktx,
        lv_fldnmecat  TYPE lvc_fname,
        lv_fldnmecat2 TYPE lvc_fname,
        lv_fldnmemont TYPE lvc_fname.


  CLEAR message_error.

  FIELD-SYMBOLS: <fs_out>  TYPE zco_st_laycargapresupuesto,
                 <row_out> TYPE any,
                 <aux_meg> TYPE any.

  " IF p_maxpospress EQ 0.
  lv_position = 1.
  " ELSE.
  "  lv_position = p_maxpospress.
  "ENDIF.

  PERFORM create_dynamic_itab.

  CONCATENATE TEXT-001 '(Grabando Datos)' INTO vl_leyenda.
  SORT it_outtable BY tipo matnr.
  "LOOP AT it_outtable INTO wa_outtable .
  LOOP AT it_outtable ASSIGNING <fs_out>.
    IF p_ok NE '0'.
      APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_wa>.
      ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = p_idpres.
      ASSIGN COMPONENT 'PRESPOS' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = lv_position.
      ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-werks.


      " wa_planpres-idpres = p_idpres.
      "wa_planpres-prespos = lv_position.

      "---se complementa con ceros en CeCo. Si tienen . decimal se quedan tal cual
      ASSIGN COMPONENT 'KOSTL' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-kostl.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <linea>
        IMPORTING
          output = <linea>.

      "-----------------------------------------------------------------------------------


      READ TABLE it_csks INTO wa_csks WITH KEY kostl = <linea>.
      " se obtienen Sociedad CO, Ejercicio y Sociedad
      ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = p_anio.
      "wa_planpres-gjahr = sy-datum+0(4).
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT 'KOKRS' OF STRUCTURE <fs_wa> TO <linea>.
        <linea> = wa_csks-kokrs.
        "wa_planpres-kokrs = wa_csks-kokrs.
        ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_wa> TO <linea>.
        <linea> = wa_csks-bukrs.
        "wa_planpres-bukrs = wa_csks-bukrs.

*        PERFORM assing_werks USING wa_csks-bukrs "Se asigna el Centro Correspondiente
*        CHANGING lv_werks."wa_planpres-werks.

*        ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_wa> TO <linea>.
*        <linea> = lv_werks.
      ENDIF.

      "IF wa_planpres-werks EQ 'SA00'.
*      IF lv_werks EQ 'SA00'.
*        <linea> = <fs_out>-werks.
*        "wa_planpres-werks =  wa_outtable-werks.
*      ENDIF.
*-------------se complementa el campo Werks
      ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_wa> TO <linea>.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_out>-werks
        IMPORTING
          output = <fs_out>-werks.
      <linea> = <fs_out>-werks.
*------------------------------

      "---------YA SE TIENE EL CENTRO, SE BUSCA EL ALMACEN (LGORT)
*      CLEAR wa_lgort.
*      READ TABLE it_lgort INTO wa_lgort WITH KEY matnr = <fs_out>-matnr werks = <linea>.
*      IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'LGORT' OF STRUCTURE <fs_wa> TO <linea>.
      IF wa_csks-kokrs = 'SA00'.
        <linea> = 'GPRF'.
      ELSEIF wa_csks-kokrs = 'GA00'.
        <linea> = 'AZRF'.
      ENDIF.
      "wa_planpres-lgort = wa_lgort-lgort.
*      ENDIF.

      "----------------------------------------------------------------
*      ASSIGN COMPONENT 'WRTTP' OF STRUCTURE <fs_wa> TO <linea>.
*      <linea> = 1.
      "wa_planpres-wrttp = 1. "constante
      ASSIGN COMPONENT 'VERSN' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = '000'.
      "wa_planpres-versn = '0  '. "constante


      "wa_planpres-kostl = wa_outtable-ceco. "aun conserva el CeCo.
      "asigna ceros a la izquierda
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_out>-kostl
        IMPORTING
          output = <fs_out>-kostl.

      ASSIGN COMPONENT 'KOSTL' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-kostl.

      "--------------------------------------------
      ASSIGN COMPONENT 'KSTAR' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-kstar.
      "wa_planpres-kstar = wa_outtable-clcoste.

      "IF wa_planpres-kstar EQ space OR wa_planpres-kstar IS INITIAL.
      IF <linea> EQ space OR <linea> IS INITIAL.
        READ TABLE it_zco_tt_matcuenta INTO wa_zco_tt_matcuenta WITH KEY material = <fs_out>-matnr.
        IF sy-subrc EQ 0.
          "asigna ceros a la izquierda
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_zco_tt_matcuenta-saknr
            IMPORTING
              output = wa_zco_tt_matcuenta-saknr.

          <linea> = wa_zco_tt_matcuenta-saknr.
          "wa_planpres-kstar = wa_zco_tt_matcuenta-saknr.
        ELSE.
          CLEAR message_error.
          CONCATENATE 'El código:' <fs_out>-matnr 'no tiene Clase Costo relacionada'
          INTO message_error SEPARATED BY space.

          <fs_out>-tipmod = 'E'.
          <fs_out>-logerror = message_error.
          "MODIFY it_outtable FROM wa_outtable INDEX lv_position.
        ENDIF.
      ELSE.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <fs_out>-kstar
          IMPORTING
            output = <fs_out>-kstar.
        <linea> = <fs_out>-kstar.
      ENDIF.
      "--------------------------------
      ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-maktx.
      "wa_planpres-maktx  = wa_outtable-descr_mat.
      ASSIGN COMPONENT 'TIPO' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-tipo.
      "wa_planpres-tipo   = wa_outtable-tipo.
      ASSIGN COMPONENT 'CO_MEINH' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-meins.
      "wa_planpres-co_meinh = wa_outtable-um.
      ASSIGN COMPONENT 'TIPO' OF STRUCTURE <fs_out> TO <row_out>.
      lv_tipo = <row_out>.
*        "----------------Se actualiza el precio del Material Existente en
*        "---------------ZCO_TT_MATNRPRES
      IF lv_tipo EQ 'MATERIAL'.
        CLEAR: wa_matnrpres,
        lv_preuni.

        READ TABLE it_matnrpres INTO wa_matnrpres
        WITH KEY kokrs = wa_csks-kokrs matnr = <fs_out>-matnr gjahr = p_anio.
        IF sy-subrc EQ 0.
          lv_preuni = wa_matnrpres-netpr.
          lv_inflacion = wa_matnrpres-dmbtr.
        ELSE.
          lv_preuni = 1.
          lv_inflacion = 0.
        ENDIF.

        CLEAR lv_preunipres.
        lv_preunipres = ( lv_preuni * ( lv_inflacion / 100 ) ) + lv_preuni.


        ASSIGN COMPONENT 'PREUNI' OF STRUCTURE <fs_wa> TO <linea>.
        <linea> = lv_preuni.

        ASSIGN COMPONENT 'PREUNIPRES' OF STRUCTURE <fs_wa> TO <linea>.
        <linea> = lv_preunipres.
      ELSE.
        ASSIGN COMPONENT 'PREUNI' OF STRUCTURE <fs_wa> TO <linea>.
        <linea> = <fs_out>-preuniup.

        ASSIGN COMPONENT 'PREUNIPRES' OF STRUCTURE <fs_wa> TO <linea>.
        <linea> = <fs_out>-preuniup.
      ENDIF.
*--------------------------------------------------------------------------------

      num_mes = 0.
      DO 12 TIMES.
        num_mes = num_mes + 1.

        PERFORM get_periodo USING    num_mes
        CHANGING num_mes
          mes_corto
          lv_fldnmecat
          lv_fldnmemont.
        "Cantidad MEG
        lv_fldnmecat2 = lv_fldnmecat.

        IF lv_tipo EQ 'MATERIAL'.
          ASSIGN COMPONENT lv_fldnmemont OF STRUCTURE <fs_out> TO <row_out>. "Carga de Excel WTG
          ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE <fs_wa> TO <linea>.  "Este es tabla Z MEG

          <linea> = <row_out>.
        ELSE.
          lv_fieldnameaux = lv_fldnmecat.
          REPLACE 'MEG' IN lv_fieldnameaux WITH 'WOG'. "se renombra para traer los montos
          ASSIGN COMPONENT lv_fieldnameaux OF STRUCTURE <fs_out> TO <row_out>. "Carga de Excel WOG
          ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE <fs_wa> TO <linea>.  "Este es tabla Z MEG

          <linea> = <row_out>.
        ENDIF.

        "Montos $$
        IF lv_tipo EQ 'MATERIAL'.
          REPLACE 'MEG' IN lv_fldnmecat WITH 'WOG'.
          ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE <fs_out> TO <row_out>. "Archivo excel
          ASSIGN COMPONENT lv_fldnmemont OF STRUCTURE <fs_wa> TO <linea>. "Tabla Z WTG
          ASSIGN COMPONENT lv_fldnmecat2 OF STRUCTURE <fs_wa> TO <aux_meg>. "Tabla Z WTG
          <row_out> = <aux_meg> * lv_preunipres.
          <linea> = <row_out>.
          ASSIGN COMPONENT 'WTGTOT' OF STRUCTURE <fs_wa> TO <linea>.
          <linea> = <linea> + <row_out>."<fs_out>-meg002.
        ELSE.
          ASSIGN COMPONENT lv_fldnmemont OF STRUCTURE <fs_out> TO <row_out>. "Archivo excel
          ASSIGN COMPONENT lv_fldnmemont OF STRUCTURE <fs_wa> TO <linea>. "Tabla Z WTG

          <linea> = <row_out>.
        ENDIF.
      ENDDO.

      IF lv_tipo NE 'MATERIAL'.
        ASSIGN COMPONENT 'WTGTOT' OF STRUCTURE <fs_wa> TO <linea>.
        <linea> = <fs_out>-meg002.
      ENDIF.


      ASSIGN COMPONENT 'MEGTOT' OF STRUCTURE <fs_wa> TO <linea>.

      <linea> = <fs_out>-wtgtot.

      "wa_planpres-megtot = wa_outtable-wtgtot.
      ASSIGN COMPONENT 'TWAER' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-waers.
      "wa_planpres-twaer = wa_outtable-moneda.
      ASSIGN COMPONENT 'PRUNMX' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-preuni.
      "wa_planpres-prunmx = wa_outtable-preuni.



      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-matnr.

      ASSIGN COMPONENT 'MATKL' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-matkl.

      ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = <fs_out>-orden.

      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_wa> TO <linea>.

      IF <linea> IS INITIAL.
        ASSIGN COMPONENT 'CUENTA' OF STRUCTURE <fs_wa> TO <linea>.
        "asigna ceros a la izquierda
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <fs_out>-kstar
          IMPORTING
            output = <fs_out>-kstar.

        <linea> = <fs_out>-kstar.
*    --------------------------------
      ELSE.
        ASSIGN COMPONENT 'CUENTA' OF STRUCTURE <fs_wa> TO <linea>.
        <linea> = space.
        "wa_planpres-cuenta = space.
      ENDIF.

      ASSIGN COMPONENT 'TIPMOD' OF STRUCTURE <fs_wa> TO <linea>.
      <linea> = 'F'.
      "wa_planpres-tipmod = 'F'. "CONSTANTE TEMPORAL

*----------Ahora validamos que el material este correctamente en el centro que dice ser
*      ASSIGN COMPONENT 'TIPO' OF STRUCTURE <fs_wa> TO <linea>.
*      "IF wa_planpres-tipo EQ 'MATERIAL'.
*      IF <linea> EQ 'MATERIAL'.
*        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_wa> TO <linea>.
*        "IF wa_planpres-matnr NE '' OR wa_planpres-matnr IS NOT INITIAL.
*        IF <linea> NE '' OR <linea> IS NOT INITIAL.
*          lv_matnr = <linea>.
*          ASSIGN COMPONENT 'WERKS' OF STRUCTURE <fs_wa> TO <linea>.
*          lv_werks = <linea>.
*
*          CALL FUNCTION 'BAPI_MATERIAL_STOCK_REQ_LIST'
*            EXPORTING
*              material = lv_matnr "wa_planpres-matnr
*              plant    = lv_werks "wa_planpres-werks
*            IMPORTING
*              return   = it_return.
*
*          IF it_return-type EQ 'E'.
*            lv_error = 'X'.
*            CLEAR message_error.
*            message_error = it_return-message.
*          ELSE.
*            lv_error = ''.
*          ENDIF.
*        ENDIF.
*      ELSE.
*        lv_error = space.
*      ENDIF.
*
*     IF lv_error NE 'X'.


*---------------------------------------------------------------------------------------------
      IF <fs_out>-tipmod NE 'E'.
        "Valida, solo cantidades positivas se agregan
        ASSIGN COMPONENT 'WTGTOT' OF STRUCTURE <fs_wa> TO <linea>.
        "IF wa_planpres-wtgtot > 0 .
        IF <linea> > 0 .

          CLEAR wa_planpres.
          MOVE-CORRESPONDING: <fs_wa> TO wa_planpres.
          wa_planpres-cecoaut = 'X'.
          INSERT zco_tt_planpres FROM wa_planpres.
          INSERT zco_tt_planpresr FROM wa_planpres.

        ENDIF.

        IF sy-subrc EQ 0.
          p_ok = '1'.
        ENDIF.

      ENDIF.
      "ENDIF.
      PERFORM mostrar_progreso USING vl_leyenda 1.
*      ELSE.
*        <fs_out>-tipmod = 'E'.
*        <fs_out>-logerror = message_error.
*
*      ENDIF.
      lv_position = lv_position + 1.
    ENDIF.
  ENDLOOP.

  IF message_error IS NOT INITIAL OR message_error NE ''.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = 'Se han Encontrado Errores durante la Carga'
        txt1  = 'No se grabo el archivo de presupuesto, debido a errores encontrados.'
        txt2  = 'Se descargará archivo con las incidencias detalladas'.

    "IF lv_answer NE '1'.
    PERFORM mostrar_progreso USING 'Haciendo rollback...' 1.
    PERFORM rollback USING p_idpres.

    p_ok = '0'.
    DELETE it_outtable WHERE tipmod NE 'E'.
    CLEAR lv_position.
    DESCRIBE TABLE it_outtable LINES lv_position.
    IF lv_position > 0.
      s_numfile = lv_position.
      PERFORM download_xls_error USING it_outtable.
    ENDIF.

    CONCATENATE 'Se encontraron: ' s_numpres 'registros, con errores '
    INTO s_numregistros SEPARATED BY space.
    MESSAGE s_numregistros TYPE 'S'.
  ENDIF.

ENDFORM. "save_position_press.
*&---------------------------------------------------------------------*
*&      Form  FILL_CSKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_csks .
  SELECT kokrs kostl bukrs
  INTO CORRESPONDING FIELDS OF TABLE it_csks
  FROM csks
  WHERE datbi GT sy-datum.
ENDFORM.                    " FILL_CSKS
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_PROGRESO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_P01  text
*      -->P_1      text
*----------------------------------------------------------------------*
FORM mostrar_progreso  USING    p_text_p01 TYPE c
      p_incremento TYPE i.

  STATICS: lv_porcentaje TYPE i.

*Setea el porcentaje
  " lv_porcentaje = lv_porcentaje + p_incremento.

  IF lv_porcentaje => 100.
    lv_porcentaje = 10.
  ENDIF.

*Muestra el indicador en la barra de status
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_porcentaje
      text       = p_text_p01.


ENDFORM.                    " MOSTRAR_PROGRESO
*&---------------------------------------------------------------------*
*&      Form  ASSING_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_CSKS_BUKRS  text
*      <--P_WA_PLANPRES_WERKS  text
*----------------------------------------------------------------------*
FORM assing_werks  USING    p_wa_csks_bukrs LIKE wa_csks-bukrs
CHANGING p_wa_planpres_werks TYPE werks_d.

  CASE p_wa_csks_bukrs.
    WHEN 'GA05'.
      p_wa_planpres_werks = 'HXIN'.
    WHEN 'GA06'.
      p_wa_planpres_werks = 'MDIN'.
    WHEN 'GA07'.
      p_wa_planpres_werks = 'SCIN'.
    WHEN 'GA09'.
      p_wa_planpres_werks = 'F001'.
    WHEN 'GA10'.
      p_wa_planpres_werks = 'F501'.
    WHEN 'GA11'.
      p_wa_planpres_werks = 'SPIN'.
    WHEN 'GA12'.
      p_wa_planpres_werks = 'ECIN'.
    WHEN OTHERS.
      p_wa_planpres_werks = 'SA00'.
  ENDCASE.
ENDFORM.                    " ASSING_WERKS
*&---------------------------------------------------------------------*
*&      Form  SHOW_FILES_PRES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_files_pres .

  DATA ls_fcat TYPE lvc_s_fcat .
  REFRESH po_fieldcat.
* Indicador
  CLEAR ls_fcat.
  ls_fcat-col_pos   = 1.
  ls_fcat-coltext   = 'Archivo Presupuesto'.
  ls_fcat-fieldname = 'ARCHIVO'.
  ls_fcat-outputlen = 100.
  ls_fcat-no_out    = ' '.
  ls_fcat-key = 'X'.
  ls_fcat-hotspot = 'X'.
  APPEND ls_fcat TO po_fieldcat.

* año
  CLEAR ls_fcat.
  ls_fcat-col_pos   = 2.
  ls_fcat-coltext   = 'Año'.
  ls_fcat-fieldname = 'ANIO'.
  ls_fcat-edit      = 'X'.
  ls_fcat-outputlen = 4.
  APPEND ls_fcat TO po_fieldcat.
* Status
  CLEAR ls_fcat.
  ls_fcat-col_pos   = 3.
  ls_fcat-coltext   = 'Status'.
  ls_fcat-fieldname = 'STATUS'.
  ls_fcat-outputlen = 10.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO po_fieldcat.

* Status
  CLEAR ls_fcat.
  ls_fcat-col_pos   = 4.
  ls_fcat-coltext   = 'Comentarios'.
  ls_fcat-fieldname = 'COMENTARIO'.
  ls_fcat-edit      = 'X'.
  ls_fcat-outputlen = 200.


  APPEND ls_fcat TO po_fieldcat.
  PERFORM display_alv USING it_xls po_fieldcat 'CCONTAINER'.


ENDFORM.                    " SHOW_FILES_PRES
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_XLS_ARCHIVO  text
*----------------------------------------------------------------------*
FORM upload_data  USING p_wa_xls_archivo TYPE any
      p_comentario TYPE char200
      p_anio TYPE i.

  DATA: _ok, lv_idpres TYPE char10,lv_answer TYPE c.
  DATA vl_leyenda(200) TYPE c.
  DATA vl_autorizado(100) TYPE c.
  DATA existe.
  "para Pop-up Decide-list
  DATA: li_spopli TYPE STANDARD TABLE OF spopli,
        wa_spopli TYPE spopli.
  "---------------------------

  REFRESH it_planpres.
  CLEAR wa_planpres.
  REFRESH it_planpresh.

  PERFORM load_excel_to_table USING p_wa_xls_archivo
  CHANGING _ok.
  IF _ok EQ '1'.
    "Antes de continuar, se valida si ya existe un presupuesto del mismo
    "centro de costos y se pregunta si se quiere actualizar.
    CLEAR: wa_outtable, wa_csks.
    READ TABLE it_outtable INTO wa_outtable INDEX 1.

    "se complementa con ceros los que son numeros. Los que tienen punto, los va a tomar
    "como cadena y los deja tal cual
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_outtable-kostl
      IMPORTING
        output = wa_outtable-kostl.
    "-----------------------------------------------------------------------------------------

    READ TABLE it_csks INTO wa_csks WITH KEY kostl = wa_outtable-kostl.

    IF wa_csks-bukrs IS NOT INITIAL.

      PERFORM check_pres_exist USING wa_csks-bukrs wa_outtable-kostl
            p_anio
      CHANGING it_temporal.

      IF it_temporal[] IS NOT INITIAL. "si hay presupuesto antes registrado
        existe = 'X'.
        LOOP AT it_temporal INTO wa_temporal.
          IF wa_temporal-autorizador IS NOT INITIAL.
            CONCATENATE 'Autorizado por'
            wa_temporal-autorizador
*                         'El día de'
*                         wa_temporal-fechaaut
            INTO vl_autorizado SEPARATED BY space.
          ENDIF.
          lv_idpres = wa_temporal-idpres.
          CONCATENATE
          wa_temporal-idpres 'registrado el día'
          wa_temporal-fecha
          '¿Que desea aplicar?'
          INTO vl_leyenda SEPARATED BY space.
        ENDLOOP.


        CLEAR: wa_spopli.
        wa_spopli-varoption = 'Cancelar Presupuesto Anterior'.
        APPEND wa_spopli TO li_spopli.

        CLEAR: wa_spopli.
        wa_spopli-varoption = 'Cancelar'.
        APPEND wa_spopli TO li_spopli.

        CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
          EXPORTING
            start_col = 25
            start_row = 6
            textline1 = vl_leyenda
            textline2 = vl_autorizado
*           TEXTLINE3 = ' '
            titel     = 'Presupuesto Encontrado para esta Soc.'
*           DISPLAY_ONLY             = ' '
          IMPORTING
            answer    = lv_answer
          TABLES
            t_spopli  = li_spopli.


        "------------------------------------------------
        IF lv_answer EQ '1'.
          existe = 'X'.

          LOOP AT it_temporal INTO wa_temporal.
            "Primer se actualiza a O el presupuesto anterior

            UPDATE zco_tt_planpres SET tipmod = 'O', cecoaut = 'F' WHERE idpres = @wa_temporal-idpres.
            UPDATE zco_tt_planpresh SET autorizado = 'C', statustx = 'Cancelado por Existencia de Ceco',
                    autorizador = @sy-uname, fechaaut = @sy-datum, horaaut = @sy-uzeit
            WHERE idpres = @wa_temporal-idpres.


          ENDLOOP.
          PERFORM record_pres USING p_wa_xls_archivo
                existe
*                wa_temporal-idpres
                p_comentario
                p_anio.

*        ELSEIF lv_answer EQ '2'.
*          existe = 'A'.
*          PERFORM record_pres USING p_wa_xls_archivo
*                                   existe
*                                   lv_idpres
*                                   p_comentario
*                                   p_anio.
*        ELSEIF  lv_answer EQ '3'.
*          existe = 'N'.
*          PERFORM record_pres USING p_wa_xls_archivo
*                                  existe
*                                  lv_idpres
*                                  p_comentario
*                                  p_anio.

        ELSEIF  lv_answer EQ '4' OR lv_answer EQ '2' OR lv_answer EQ 'A'.
          MESSAGE 'Ha cancelado la operación de importar presupuesto.' TYPE 'S'.
        ENDIF.
      ELSE.
        PERFORM record_pres USING p_wa_xls_archivo
              existe
*              lv_idpres
              p_comentario
              p_anio.

      ENDIF.
    ELSE.
      MESSAGE 'El archivo de Carga de presupuesto, es erróneo y/o no contienen CeCo registrado'
      TYPE 'I'.
      CLEAR wa_xls.
      wa_xls-status = '@0A@'. "red traffic light
      MODIFY it_xls FROM wa_xls TRANSPORTING status WHERE archivo =  p_wa_xls_archivo.
    ENDIF.
  ENDIF.

ENDFORM.                    " UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM handle_user_command  USING    p_e_ucomm.
  DATA lv_answer.
  DATA: ok      TYPE i, lv_anio TYPE i.
  DATA p_ok.
  DATA: lv_body   TYPE string, lv_asunto TYPE string, lv_smtp TYPE string,lv_bukrs TYPE bukrs,
        lv_idpres TYPE char10.

  DATA: li_spopli          TYPE STANDARD TABLE OF spopli,
        wa_spopli          TYPE spopli,
        vl_leyenda(200)    TYPE c,
        vl_autorizado(100) TYPE c.

  CASE  p_e_ucomm.
    WHEN 'REFR'.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'Cancelar Presupuesto Seleccionado'
          text_question  = '¿Esta seguro de cancelar el/los documento(s)?'
          text_button_1  = 'Si, Seguro'(007)                                   " Texto botón 1
          icon_button_1  = 'ICON_CHECKED'                             " Ícono botón 1
          text_button_2  = 'No'(008)                                   " Texto botón 2
          icon_button_2  = 'ICON_INCOMPLETE'                              " Ícono botón 2
          default_button = '1'                                        " Botón por defecto
*         DISPLAY_CANCEL_BUTTON       = 'X'
*         USERDEFINED_F1_HELP         = ' '
          start_column   = 25
          start_row      = 6
          popup_type     = 'ICON_MESSAGE_CRITICA'
*         IV_QUICKINFO_BUTTON_1       = ' '
*         IV_QUICKINFO_BUTTON_2       = ' '
        IMPORTING
          answer         = lv_answer " Respuesta
*         TABLES
*         PARAMETER      =
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF lv_answer EQ '1'.
        PERFORM cancel_idpres.
        PERFORM exec_auth_pres CHANGING ok.
        IF ok > 0.
          PERFORM field_catalog.
          PERFORM display_alv USING it_pendientes po_fieldcat 'CCONTAINER01'.
          TRY.
              CALL METHOD gref_alvgrid101d->free.
              CLEAR gref_alvgrid101d.
            CATCH cx_sy_ref_is_initial.

          ENDTRY.

          TRY.
              CALL METHOD gref_ccontainer101d->free.
              CLEAR gref_ccontainer101d.
            CATCH cx_sy_ref_is_initial.

          ENDTRY.

        ELSE.

          TRY.
              CALL METHOD gref_alvgrid101->free.
              CLEAR gref_alvgrid101.
            CATCH cx_sy_ref_is_initial.

          ENDTRY.

          TRY.
              CALL METHOD gref_ccontainer101->free.
              CLEAR gref_ccontainer101.
            CATCH cx_sy_ref_is_initial.

          ENDTRY.


          TRY.
              CALL METHOD gref_alvgrid101d->free.
              CLEAR gref_alvgrid101d.
            CATCH cx_sy_ref_is_initial.

          ENDTRY.

          TRY.
              CALL METHOD gref_ccontainer101d->free.
              CLEAR gref_ccontainer101d.
            CATCH cx_sy_ref_is_initial.

          ENDTRY.




        ENDIF.
      ELSE.
        MESSAGE 'Ha cancelado la operación' TYPE 'S'.
      ENDIF.
    WHEN 'AUTHSEL'.
      REFRESH it_arma.
      "---------
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'Autorizar Presupuesto Seleccionado'
          text_question  = '¿Esta seguro de autorizar el/los documento(s)?'
          text_button_1  = 'Si, Seguro'(007)                          " Texto botón 1
          icon_button_1  = 'ICON_CHECKED'                             " Ícono botón 1
          text_button_2  = 'No'(008)                                   " Texto botón 2
          icon_button_2  = 'ICON_INCOMPLETE'                           " Ícono botón 2
          default_button = '1'                                        " Botón por defecto
*         DISPLAY_CANCEL_BUTTON       = 'X'
*         USERDEFINED_F1_HELP         = ' '
          start_column   = 25
          start_row      = 6
          popup_type     = 'ICON_MESSAGE_CRITICA'
*         IV_QUICKINFO_BUTTON_1       = ' '
*         IV_QUICKINFO_BUTTON_2       = ' '
        IMPORTING
          answer         = lv_answer " Respuesta
*         TABLES
*         PARAMETER      =
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      "---------------------
      IF lv_answer EQ '1'.
*Sino se habilita el detalle, no permitir autorizar.
        IF gref_alvgrid101d IS INITIAL.
          MESSAGE 'Debe Mostrar el Detalle para poder Autorizar' TYPE 'S'.
          EXIT.
        ENDIF.
***-------------------------------------------------------
        it_arma[] = it_pendientes[].
        DELETE it_arma WHERE flag NE 'X'.
        LOOP AT it_arma INTO wa_arma.

          IF wa_arma-autorizado NE 'X'.

            PERFORM autorizar_seleccionados USING wa_arma-idpres
                  p_ok.
*          endif. "validación desde el portal
            CLEAR wa_usuario.
            IF p_ok = '1'. "exito


              READ TABLE it_usuario INTO wa_usuario WITH KEY bname = wa_arma-usuario.
              "------------------se envia por correo la notificación
              CONCATENATE 'Buen día ' wa_usuario-name_text
              '.El presupuesto con ID: ' wa_arma-idpres ' ha sido Autorizado.'
              INTO lv_body SEPARATED BY space.

              CONCATENATE 'Atención ' wa_usuario-name_text   INTO lv_asunto SEPARATED BY space.

              lv_smtp = wa_usuario-smtp_addr.
              MESSAGE 'Presupuesto Autorizado' TYPE 'S'.
              TRY.
                  CALL METHOD gref_alvgrid101d->free.
                  CLEAR gref_alvgrid101d.
                CATCH cx_sy_ref_is_initial.

              ENDTRY.

              TRY.
                  CALL METHOD gref_ccontainer101d->free.
                  CLEAR gref_ccontainer101d.
                CATCH cx_sy_ref_is_initial.

              ENDTRY.

            ELSE.
              MESSAGE 'No se contabilizo el presupuesto debido a errores.' TYPE 'S' DISPLAY LIKE 'E'.
            ENDIF.
          ELSE.
            IF wa_arma-autorizado EQ 'X'.
              MESSAGE 'Ya no hay CeCos pendientes por autorizar para esta Sociedad'
              TYPE 'S' DISPLAY LIKE 'W'.
            ELSEIF wa_arma-autorizado EQ 'T'.
              MESSAGE 'Aún hay CeCos pendientes, pero no tiene el la autorización para aplicarlos'
              TYPE 'S' DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.
        ENDLOOP.

      ELSE.
        MESSAGE 'Ha cancelado la operación' TYPE 'S'.
      ENDIF.
    WHEN 'COMPROBAR'.
      PERFORM check_presupuesto.
    WHEN 'MAT'.
      PERFORM aut_materiales.
    WHEN 'RESERVAS'.

      PERFORM reservas.


    WHEN 'SOLPED'.
      PERFORM solpeds.
    WHEN 'SELALL'.
      IF gv_selectall = ''.
        PERFORM select_all.
      ELSE.
        PERFORM limpiar_checkbox.
      ENDIF.
    WHEN 'SELALLAJU'.
      IF gv_selectall = ''.
        PERFORM select_all_ajuste.
      ELSE.
        PERFORM limpiar_checkbox_ajuste.
      ENDIF.
    WHEN 'SAVEPRES'.
      "se guardan los ajustes a montos del presupuesto.
      PERFORM save_ajus_pres.
    WHEN 'CUBO'.
      DATA ls_fieldcat TYPE lvc_s_fcat.
      READ TABLE fieldcat102 INTO ls_fieldcat WITH KEY fieldname = 'WTG001'.
      IF sy-subrc EQ 0.
        PERFORM get_fieldcat_rpt USING 'MEG'.
      ELSE.
        PERFORM get_fieldcat_rpt USING 'WTG'.
      ENDIF.

      PERFORM display_alv_tree USING it_matpres
            fieldcat102
            'ALV_CONTAINER'.
    WHEN 'ANALIS'.
      PERFORM analizar_pto.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  CHECK_PRES_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_CSKS_BUKRS  text
*      <--P__OK  text
*----------------------------------------------------------------------*
FORM check_pres_exist  USING    p_wa_csks_bukrs TYPE bukrs
                                p_kostl TYPE kostl
                                p_anio TYPE i
                       CHANGING  p_it_tabla TYPE STANDARD TABLE.


  DATA vl_idpres(10) TYPE c.

  SELECT idpres
  INTO TABLE @DATA(it_idpres)
  FROM zco_tt_planpres "vl_idpres FROM zco_tt_planpres
  WHERE bukrs EQ @p_wa_csks_bukrs AND kostl = @p_kostl AND tipmod = 'F'
  AND gjahr = @p_anio AND tipo = 'MATERIAL'
  .

  IF sy-subrc EQ 0.
    SELECT idpres usuario fecha autorizador fechaaut
    INTO TABLE it_temporal
    FROM zco_tt_planpresh
    FOR ALL ENTRIES IN it_idpres
    WHERE idpres EQ it_idpres-idpres.

    IF sy-subrc EQ 0.
      p_it_tabla[] = it_temporal[].
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_PRES_EXIST
*&---------------------------------------------------------------------*
*&      Form  RECORD_PRES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM record_pres USING p_wa_xls_archivo TYPE any
      p_existe TYPE c
*      p_idpres_ant TYPE char10
      p_comentario TYPE char200
      p_anio TYPE i.


  DATA: lv_idpres(10) TYPE c, _ok.
  DATA vl_leyenda(200) TYPE c.
  DATA lv_maxpospres TYPE num5. "TYPE I.
  DATA vl_tipo TYPE string.
  DATA v_material.

*  "Primer se actualiza a O el presupuesto anterior
*  IF p_existe EQ 'X'.
*    UPDATE zco_tt_planpres SET tipmod = 'O' WHERE idpres = p_idpres_ant.
*    UPDATE zco_tt_planpresh SET autorizado = 'C', statustx = 'Cancelado por Existencia de Ceco',
*            autorizador = @sy-uname, fechaaut = @sy-datum, horaaut = @sy-uzeit
*    WHERE idpres = @p_idpres_ant.
*
*  ENDIF.
  lv_maxpospres = 0.

*  IF p_existe EQ 'A'.
*    lv_idpres = p_idpres_ant.
*
*    "se selecciona el número maximo de posición registrada
*    "en el IdPres anterior para evitar colisionar y seguir con el
*    " consecutivo.
*    SELECT SINGLE MAX( prespos ) INTO lv_maxpospres FROM zco_tt_planpres WHERE idpres = lv_idpres.
*    "--------------------------------------------------------------------
*  ELSE. "si es X o N se crea un nuevo ID de prespuesto

*  ENDIF.



  "----------------------------------------------------
  vl_tipo = 'interno'.
  PERFORM update_data_itab USING it_outtable vl_tipo.
  IF vl_tipo = 'interno'.
    DELETE it_outtable WHERE tipo NE 'MATERIAL'. "14-08-2024
    DELETE it_outtable WHERE wtgtot EQ 0.
  ENDIF.

  PERFORM create_fcat_planpres.
  "  PERFORM display_alv USING it_outtable po_fieldcat 'CCONTAINER_ALV'.
  "Se crea el encabezado del presupuesto

  PERFORM get_idpres CHANGING lv_idpres.
  PERFORM save_header_pres USING lv_idpres
                                 p_wa_xls_archivo
                                 p_comentario
                                 p_anio
                           CHANGING _ok.
  IF _ok EQ '1'.
    "se buscan valores en tablas standar que pudo ingresar mal usuario en Layout


    "Se crean las posiciones del presupuesto
    PERFORM save_position_pres USING lv_idpres
                                      lv_maxpospres
                                      p_anio
                                       CHANGING _ok.


    IF _ok EQ '1'.
      wa_xls-status = '@08@'. "green traffic light
      CONCATENATE '' 'Grabado de Datos Finalizado con Éxito' INTO vl_leyenda.
    ELSE.
      wa_xls-status = '@0A@'. "red traffic light
      "CONCATENATE ' ' 'Datos Finalizado con Errores' INTO vl_leyenda.
      PERFORM rollback USING lv_idpres.
    ENDIF.
  ELSE.
    wa_xls-status = '@0A@'. "red traffic light
    CONCATENATE ' ' 'Finalizado con Errores. No se grabo presupuesto' INTO vl_leyenda.
  ENDIF.


  MESSAGE vl_leyenda TYPE 'S'.
  MODIFY it_xls FROM wa_xls TRANSPORTING status WHERE archivo EQ p_wa_xls_archivo.
  CALL METHOD gref_alvgrid->refresh_table_display.

ENDFORM.                    " RECORD_PRES
*&---------------------------------------------------------------------*
*&      Form  GET_NAME_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      <--P_<LFS_IT>  text
*----------------------------------------------------------------------*
FORM get_name_file  USING    p_e_row_id TYPE any
CHANGING p_lfs_it TYPE any.
  FIELD-SYMBOLS <lfs_it> TYPE any.



  READ TABLE it_xls ASSIGNING  <lfs_it>
  INDEX p_e_row_id.

  p_lfs_it = <lfs_it>.

ENDFORM.                    " GET_NAME_FILE
*&---------------------------------------------------------------------*
*&      Form  update_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_data.

  TYPES: BEGIN OF st_planpres,
           idpres  TYPE char10,
           prespos TYPE num5,
           matnr   TYPE matnr,
           matkl   TYPE matkl,
         END OF st_planpres.

  DATA: it_planpres     TYPE STANDARD TABLE OF st_planpres,
        wa_planpres     LIKE LINE OF it_planpres,
        it_zco_planpres TYPE STANDARD TABLE OF st_planpres,
        wa_zco_planpres LIKE LINE OF it_zco_planpres.
*        it_zco_planpres TYPE STANDARD TABLE OF zco_tt_planpres,
*        wa_zco_planpres LIKE LINE OF it_zco_planpres.

  SELECT idpres prespos m~matnr m~matkl
  INTO TABLE it_planpres
  FROM mara AS m
  INNER JOIN zco_tt_planpres AS p ON p~matnr EQ m~matnr
  WHERE p~tipo EQ 'MATERIALES' OR p~tipo EQ 'MATERIAL'
  AND p~tipmod EQ 'F'
  AND p~matkl EQ '' AND idpres LIKE '90%'.

  SELECT idpres prespos matnr matkl
  INTO TABLE it_zco_planpres
  FROM zco_tt_planpres
  WHERE tipo EQ 'MATERIALES' OR tipo EQ 'MATERIAL'
  AND tipmod EQ 'F'
  AND matkl EQ '' AND idpres LIKE '90%'.
  .

  IF sy-subrc EQ 0.
    LOOP AT it_zco_planpres INTO wa_zco_planpres.
      READ TABLE it_planpres INTO wa_planpres WITH KEY matnr = wa_zco_planpres-matnr.
      wa_zco_planpres-matkl = wa_planpres-matkl.
      UPDATE zco_tt_planpres SET matkl = wa_planpres-matkl
      WHERE idpres = wa_zco_planpres-idpres
      AND prespos = wa_zco_planpres-prespos
      AND matnr = wa_zco_planpres-matnr.

    ENDLOOP.
  ENDIF.

  MESSAGE 'Gpo. Art. Actualizado' TYPE 'S'.
ENDFORM.                    "update_data
FORM update_data_mein.
  FIELD-SYMBOLS: <fs_planpres> TYPE zco_tt_planpres.

  DATA: vl_lines      TYPE i,vl_linesc(10) TYPE c.
  DATA vl_msg TYPE string.


  SELECT *
    INTO TABLE @DATA(it_planpres)
    FROM zco_tt_planpres
  WHERE gjahr = @sy-datum+0(4)
    AND preunipres = 0
    "and autorizado = 'X'
    AND tipmod = 'F'
    AND tipo = 'MATERIAL'

  .
  SORT it_planpres BY matnr.
  REFRESH it_matnrpres.

  SELECT  m~kokrs m~gjahr m~matnr m~netpr i~dmbtr
    INTO TABLE it_matnrpres
  FROM zco_tt_matnrpres AS m
    INNER JOIN zco_tt_inflacion AS i
    ON i~kokrs = m~kokrs AND i~gjhar = m~gjahr.

  SORT it_matnrpres BY matnr.

  LOOP AT it_planpres ASSIGNING <fs_planpres>.

    READ TABLE it_matnrpres INTO DATA(wa_matnr) WITH KEY
         kokrs = <fs_planpres>-kokrs gjahr = <fs_planpres>-gjahr
         matnr = <fs_planpres>-matnr.

    <fs_planpres>-preunipres = wa_matnr-netpr * ( wa_matnr-dmbtr / 100 ) + wa_matnr-netpr.

    UPDATE zco_tt_planpres SET preunipres = <fs_planpres>-preunipres
          WHERE idpres   = <fs_planpres>-idpres AND
          prespos  = <fs_planpres>-prespos AND
          matnr    = <fs_planpres>-matnr .

    IF sy-subrc EQ 0.

      <fs_planpres>-wtg001 = <fs_planpres>-preunipres * <fs_planpres>-meg001.
      <fs_planpres>-wtg002 = <fs_planpres>-preunipres * <fs_planpres>-meg002.
      <fs_planpres>-wtg003 = <fs_planpres>-preunipres * <fs_planpres>-meg003.
      <fs_planpres>-wtg004 = <fs_planpres>-preunipres * <fs_planpres>-meg004.
      <fs_planpres>-wtg005 = <fs_planpres>-preunipres * <fs_planpres>-meg005.
      <fs_planpres>-wtg006 = <fs_planpres>-preunipres * <fs_planpres>-meg006.
      <fs_planpres>-wtg007 = <fs_planpres>-preunipres * <fs_planpres>-meg007.
      <fs_planpres>-wtg008 = <fs_planpres>-preunipres * <fs_planpres>-meg008.
      <fs_planpres>-wtg009 = <fs_planpres>-preunipres * <fs_planpres>-meg009.
      <fs_planpres>-wtg010 = <fs_planpres>-preunipres * <fs_planpres>-meg010.
      <fs_planpres>-wtg011 = <fs_planpres>-preunipres * <fs_planpres>-meg011.
      <fs_planpres>-wtg012 = <fs_planpres>-preunipres * <fs_planpres>-meg012.
*
      <fs_planpres>-wtgtot = <fs_planpres>-wtg001 + <fs_planpres>-wtg002
      + <fs_planpres>-wtg003 + <fs_planpres>-wtg004
      + <fs_planpres>-wtg005 + <fs_planpres>-wtg006
      + <fs_planpres>-wtg007 + <fs_planpres>-wtg008
      + <fs_planpres>-wtg009 + <fs_planpres>-wtg010
      + <fs_planpres>-wtg011 + <fs_planpres>-wtg012.

      UPDATE zco_tt_planpres SET
                  wtg001 = <fs_planpres>-wtg001
                  wtg002 = <fs_planpres>-wtg002
                  wtg003 = <fs_planpres>-wtg003
                  wtg004 = <fs_planpres>-wtg004
                  wtg005 = <fs_planpres>-wtg005
                  wtg006 = <fs_planpres>-wtg006
                  wtg007 = <fs_planpres>-wtg007
                  wtg008 = <fs_planpres>-wtg008
                  wtg009 = <fs_planpres>-wtg009
                  wtg010 = <fs_planpres>-wtg010
                  wtg011 = <fs_planpres>-wtg011
                  wtg012 = <fs_planpres>-wtg012
                  wtgtot = <fs_planpres>-wtgtot
      WHERE idpres   = <fs_planpres>-idpres AND
      prespos  = <fs_planpres>-prespos AND
      matnr    = <fs_planpres>-matnr .




    ENDIF.

  ENDLOOP.



  DESCRIBE TABLE it_planpres LINES vl_lines.
  vl_linesc = vl_lines.
  CONCATENATE 'Se actualizaron ' vl_linesc 'Materiales.' INTO vl_msg SEPARATED BY space.

  MESSAGE vl_msg TYPE 'S'.



ENDFORM.                    "update_data
*&---------------------------------------------------------------------*
*&      Form  ROLLBACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_IDPRES  text
*----------------------------------------------------------------------*
FORM rollback  USING    p_lv_idpres TYPE char10.
  DELETE FROM zco_tt_planpres  WHERE idpres = p_lv_idpres.
  " DELETE FROM zco_tt_planpreso WHERE idpres = p_lv_idpres.
  " DELETE FROM zco_tt_planpresi WHERE idpres = p_lv_idpres.
  DELETE FROM zco_tt_planpresh WHERE idpres = p_lv_idpres.
ENDFORM.                    " ROLLBACK
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_XLS_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_OUTTABLE  text
*----------------------------------------------------------------------*
FORM download_xls_error  USING p_it_outtable TYPE STANDARD TABLE.
  DATA: filename TYPE string, path TYPE string, fullpath TYPE string.
  DATA ruta LIKE rlgrap-filename.

  TYPES: BEGIN OF flditab,
           fldname(20) TYPE c,
         END OF flditab.

  DATA it_flditab TYPE STANDARD TABLE OF flditab WITH HEADER LINE.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    CHANGING
      filename = filename
      path     = path
      fullpath = fullpath.

  ruta = fullpath.

  IF ruta IS NOT INITIAL.


    PERFORM build_fcat_error CHANGING it_flditab[].

    CALL FUNCTION 'MS_EXCEL_OLE_STANDARD_DAT'
      EXPORTING
        file_name                 = ruta
      TABLES
        data_tab                  = p_it_outtable
*       fieldnames                = it_flditab
      EXCEPTIONS
        file_not_exist            = 1
        filename_expected         = 2
        communication_error       = 3
        ole_object_method_error   = 4
        ole_object_property_error = 5
        invalid_pivot_fields      = 6
        download_problem          = 7
        OTHERS                    = 8.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      MESSAGE 'Archivo descargado Correctamente' TYPE 'S'.
    ENDIF.

  ENDIF.

ENDFORM.                    " DOWNLOAD_XLS_ERROR
*&---------------------------------------------------------------------*
*&      Form  BUILD_FCAT_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FLDITAB  text
*----------------------------------------------------------------------*
FORM build_fcat_error  CHANGING p_flditab TYPE STANDARD TABLE.
  TYPES: BEGIN OF flditab,
           fldname(20) TYPE c,
         END OF flditab.

  DATA: t_flditab TYPE STANDARD TABLE OF  flditab,
        w_flditab LIKE LINE OF t_flditab.


  w_flditab-fldname = 'TIPO'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'DESCR_MAT'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'UM'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'PERIO'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG001'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG002'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG003'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG004'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG005'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG006'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG007'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG008'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG009'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG010'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG011'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTG012'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WTGTOT'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'PREUNIUP'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'MONEDA'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'PREUNI'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'MEG002'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG001'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG002'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG003'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG004'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG005'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG006'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG007'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG008'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG009'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG010'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG011'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WOG012'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'WERKS'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'CUENSAP'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'CLCOSTE'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'NCLCOSTE'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'CECO'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'NCECO'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'MATERIAL'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'TIPSER'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'MATKL'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'UBICAT'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'UBICA'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'ORDEN'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'GPOPLAN'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'TEXTEXP'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'TIPMOD'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'FECMOD'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'LGORT'. APPEND w_flditab TO t_flditab.
  w_flditab-fldname = 'LOGERROR'. APPEND w_flditab TO t_flditab.

  p_flditab[] = t_flditab[].
ENDFORM.                    " BUILD_FCAT_ERROR
*&---------------------------------------------------------------------*
*&      Form  CHECK_PRESUPUESTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_presupuesto.
  DATA: ruta          TYPE string, _ok, lv_cont TYPE sy-tabix, lv_idpres(10) TYPE c.
  DATA: lv_numfile   TYPE i, lv_numpres TYPE i, status_msg TYPE string,lv_anio(3) TYPE c,
        s_numfile(6) TYPE c, s_numpres(6) TYPE c.

  TYPES: BEGIN OF st_resultado,
           kokrs   TYPE kokrs,
           bukrs   TYPE bukrs,
           kostl   TYPE kostl,
           matnr   TYPE matnr,
           maktx   TYPE maktx,
           werks   TYPE werks_d,
           omeg001 TYPE megxxx,
           omeg002 TYPE megxxx,
           omeg003 TYPE megxxx,
           omeg004 TYPE megxxx,
           omeg005 TYPE megxxx,
           omeg006 TYPE megxxx,
           omeg007 TYPE megxxx,
           omeg008 TYPE megxxx,
           omeg009 TYPE megxxx,
           omeg010 TYPE megxxx,
           omeg011 TYPE megxxx,
           omeg012 TYPE megxxx,
           cmeg001 TYPE megxxx,
           cmeg002 TYPE megxxx,
           cmeg003 TYPE megxxx,
           cmeg004 TYPE megxxx,
           cmeg005 TYPE megxxx,
           cmeg006 TYPE megxxx,
           cmeg007 TYPE megxxx,
           cmeg008 TYPE megxxx,
           cmeg009 TYPE megxxx,
           cmeg010 TYPE megxxx,
           cmeg011 TYPE megxxx,
           cmeg012 TYPE megxxx,
           tipomsg TYPE c,
           mensaje TYPE txt120,
         END OF st_resultado.

  DATA: it_resultado TYPE STANDARD TABLE OF st_resultado,
        wa_resultado LIKE LINE OF it_resultado.

  PERFORM get_archivo_comp CHANGING ruta.
  PERFORM load_excel_to_table USING ruta
  CHANGING _ok.
  IF _ok EQ '1'.
    lv_cont = 0.
    "    PERFORM update_data_itab.



    SORT it_outtable BY kostl matnr werks.
    DESCRIBE TABLE it_outtable LINES lv_numfile.
    REFRESH it_arma.
    it_arma[] = it_pendientes[].
    DELETE it_arma WHERE flag NE 'X'.
    LOOP AT it_arma INTO wa_arma.
      lv_idpres =  wa_arma-idpres.
      lv_anio = wa_arma-gjahr.
    ENDLOOP.

    IF lv_idpres IS NOT INITIAL.
      PERFORM show_presupuesto USING lv_idpres lv_anio.
      SORT gt_zco_tt_planpres BY kokrs bukrs kostl matnr werks.
      SORT it_outtable BY kostl matnr werks.
      DESCRIBE TABLE gt_zco_tt_planpres LINES lv_numpres.

      LOOP AT it_outtable INTO wa_outtable WHERE tipo EQ 'MATERIAL'.
        lv_cont = sy-tabix.

        "asigna ceros a la izquierda
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_outtable-kostl
          IMPORTING
            output = wa_outtable-kostl.

        READ TABLE it_csks INTO wa_csks WITH KEY kostl = wa_outtable-kostl.
        " se obtienen Sociedad CO, Ejercicio y Sociedad
        IF sy-subrc EQ 0.
          PERFORM assing_werks USING wa_csks-bukrs "Se asigna el Centro Correspondiente
          CHANGING wa_outtable-werks.
          CLEAR wa_zco_tt_planpres.
          CLEAR wa_resultado.
          READ TABLE gt_zco_tt_planpres INTO wa_zco_tt_planpres WITH KEY matnr = wa_outtable-matnr
          kostl = wa_outtable-kostl
          kokrs = wa_csks-kokrs
          bukrs = wa_csks-bukrs
          kstar = wa_outtable-kstar.


          IF sy-subrc EQ 0.

            MOVE-CORRESPONDING wa_zco_tt_planpres TO wa_resultado.

            IF wa_zco_tt_planpres-meg001 EQ wa_outtable-wtg001 AND wa_zco_tt_planpres-meg002 EQ wa_outtable-wtg002
            AND wa_zco_tt_planpres-meg003 EQ wa_outtable-wtg003 AND wa_zco_tt_planpres-meg004 EQ wa_outtable-wtg004
            AND wa_zco_tt_planpres-meg005 EQ wa_outtable-wtg005 AND wa_zco_tt_planpres-meg006 EQ wa_outtable-wtg006
            AND wa_zco_tt_planpres-meg007 EQ wa_outtable-wtg007 AND wa_zco_tt_planpres-meg008 EQ wa_outtable-wtg008
            AND wa_zco_tt_planpres-meg009 EQ wa_outtable-wtg009 AND wa_zco_tt_planpres-meg010 EQ wa_outtable-wtg010
            AND wa_zco_tt_planpres-meg011 EQ wa_outtable-wtg011 AND wa_zco_tt_planpres-meg012 EQ wa_outtable-wtg012
            .
              wa_outtable-tipmod = 'C'.
              wa_outtable-logerror = 'Registro Correcto en Cantidades'.

            ELSE.
              wa_outtable-tipmod = 'E'.
              wa_outtable-logerror = 'Error en cantidades'.
            ENDIF.
            "----------se pasan datos y se insertan nueva tabla
            wa_resultado-omeg001 = wa_outtable-wtg001.wa_resultado-omeg002 = wa_outtable-wtg002.
            wa_resultado-omeg003 = wa_outtable-wtg003.wa_resultado-omeg004 = wa_outtable-wtg004.
            wa_resultado-omeg005 = wa_outtable-wtg005.wa_resultado-omeg006 = wa_outtable-wtg006.
            wa_resultado-omeg007 = wa_outtable-wtg007.wa_resultado-omeg008 = wa_outtable-wtg008.
            wa_resultado-omeg009 = wa_outtable-wtg009.wa_resultado-omeg010 = wa_outtable-wtg010.
            wa_resultado-omeg011 = wa_outtable-wtg011.wa_resultado-omeg012 = wa_outtable-wtg012.

            wa_resultado-cmeg001 = wa_zco_tt_planpres-meg001.wa_resultado-cmeg002 = wa_zco_tt_planpres-meg002.
            wa_resultado-cmeg003 = wa_zco_tt_planpres-meg003.wa_resultado-cmeg004 = wa_zco_tt_planpres-meg004.
            wa_resultado-cmeg005 = wa_zco_tt_planpres-meg005.wa_resultado-cmeg006 = wa_zco_tt_planpres-meg006.
            wa_resultado-cmeg007 = wa_zco_tt_planpres-meg007.wa_resultado-cmeg008 = wa_zco_tt_planpres-meg008.
            wa_resultado-cmeg009 = wa_zco_tt_planpres-meg009.wa_resultado-cmeg010 = wa_zco_tt_planpres-meg010.
            wa_resultado-cmeg011 = wa_zco_tt_planpres-meg011.wa_resultado-cmeg012 = wa_zco_tt_planpres-meg012.

            wa_resultado-tipomsg = wa_outtable-tipmod.
            wa_resultado-mensaje = wa_outtable-logerror.

            "----------------------------------------------------------------
          ELSE.
            wa_resultado-kokrs = wa_csks-kokrs.
            wa_resultado-bukrs = wa_csks-bukrs.
            wa_resultado-kostl = wa_outtable-kostl.
            wa_resultado-matnr = wa_outtable-matnr.
            wa_resultado-maktx = wa_outtable-maktx.
            wa_resultado-tipomsg = 'E'.
            wa_resultado-mensaje = 'No se encontro CeCo y/ Material registrado en este ID Presupuesto'.
          ENDIF.
        ENDIF.
        APPEND wa_resultado TO it_resultado.
        MODIFY it_outtable FROM wa_outtable INDEX lv_cont.
      ENDLOOP.
      PERFORM download_xls_error USING it_resultado.
      s_numfile = lv_numfile.
      s_numpres = lv_numpres.
      CONCATENATE 'Se encontraron' s_numfile 'filas en archivo y ' s_numpres 'filas en SAP' INTO status_msg SEPARATED BY space.
      MESSAGE status_msg TYPE 'S'.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_PRESUPUESTO
*&---------------------------------------------------------------------*
*&      Form  GET_ARCHIVO_COMP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_RUTA  text
*----------------------------------------------------------------------*
FORM get_archivo_comp  CHANGING p_ruta.
  DATA: lt_file TYPE filetable,
        ls_file TYPE file_table,
        lv_rc   TYPE i,
        lv_ruta TYPE string.

  IF p_ruta IS INITIAL.
    lv_ruta = 'C:\'.   "Ruta default
  ELSE.
    lv_ruta = p_ruta.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Selec. Archivo Relación Presupuesto Seleccionado'
      initial_directory       = lv_ruta
    CHANGING
      file_table              = lt_file
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc EQ 0.
    READ TABLE lt_file INTO ls_file INDEX 1.
    p_ruta = ls_file-filename.
  ENDIF.
ENDFORM.                    " GET_ARCHIVO_COMP
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_MATNRLIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_matnrlist .
  DATA: lt_file TYPE filetable,
        ls_file TYPE file_table,
        lv_rc   TYPE i,
        lv_ruta TYPE string.

  DATA vl_filename TYPE rlgrap-filename.
  DATA: lo_uploader TYPE REF TO lcl_excel_uploader.
  DATA: it_zco_tt_matnrpres TYPE STANDARD TABLE OF zco_tt_matnrpres,
        wa_zco_tt_matnrpres LIKE LINE OF it_zco_tt_matnrpres.

  lv_ruta = 'C:\'.   "Ruta default



  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Seleccione un archivo'
      initial_directory       = lv_ruta
    CHANGING
      file_table              = lt_file
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc EQ 0.
    READ TABLE lt_file INTO ls_file INDEX 1.
    vl_filename = ls_file-filename.

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



ENDFORM.                    " UPLOAD_MATNRLIST

FORM import_4ECC.
  DATA: lt_file TYPE filetable,
        ls_file TYPE file_table,
        lv_rc   TYPE i,
        lv_ruta TYPE string.

  DATA vl_filename TYPE rlgrap-filename.
  DATA: lo_uploader TYPE REF TO lcl_excel_uploader.


  FIELD-SYMBOLS <fs_wa> TYPE zco_tt_planpres.
  lv_ruta = 'C:\'.   "Ruta default

  REFRESH it_auth.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Seleccione un archivo'
      initial_directory       = lv_ruta
    CHANGING
      file_table              = lt_file
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc EQ 0.
    READ TABLE lt_file INTO ls_file INDEX 1.
    vl_filename = ls_file-filename.

    "llenamos la estructura del archivo cargado

    REFRESH it_zco_tt_planpres.

    CREATE OBJECT lo_uploader.
    lo_uploader->max_rows = 200000.
    lo_uploader->initial_col = 1.
    lo_uploader->matnr_col = '0011'.
    lo_uploader->filename = vl_filename.
    lo_uploader->header_rows_count = 2.
    lo_uploader->upload( CHANGING ct_data = it_zco_tt_planpres ).
    "---------------------------------------------------
    LOOP AT it_zco_tt_planpres ASSIGNING <fs_wa>.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <fs_wa>-bismt
        IMPORTING
          output = <fs_wa>-bismt.
    ENDLOOP.
    "-----

    SELECT kokrs, cuenta_ecc, CUENTA_hana
    INTO TABLE @DATA(it_cuentas)
    FROM zco_tt_ctasrel
    .

    SELECT m~matnr, m~bismt
    INTO TABLE @DATA(it_matnrHana)
    FROM mara AS m
    FOR ALL ENTRIES IN @it_zco_tt_planpres
    WHERE m~bismt = @it_zco_tt_planpres-bismt.


    SELECT m2~matnr, m~maktx,d~lgort
    INTO TABLE @DATA(it_makt)
    FROM mara AS m2
    INNER JOIN makt AS m ON m~matnr = m2~matnr
    INNER JOIN mard AS d ON d~matnr = m2~matnr
    FOR ALL ENTRIES IN @it_matnrHana
    WHERE m2~matnr = @it_matnrHana-matnr AND
      m~spras = 'S'.

    SELECT a~sort1, t~werks, a~addrnumber
      INTO TABLE @DATA(it_werks_hana)
      FROM adrc AS a
    INNER JOIN t001w AS t
      ON t~adrnr = a~addrnumber
   FOR ALL ENTRIES IN @it_zco_tt_planpres
   WHERE sort1 = @it_zco_tt_planpres-werks_ecc
      AND langu = 'S' AND addr_group = 'CA01'. "Direcciones Customazing

    SELECT name2, kostl, kokrs, bukrs
      INTO TABLE @DATA(it_kostl)
    FROM csks
    FOR ALL ENTRIES IN @it_zco_tt_planpres
     WHERE name2 = @it_zco_tt_planpres-kostl_ecc
     .

    LOOP AT it_zco_tt_planpres ASSIGNING <fs_wa>.
      IF <fs_wa>-tipo EQ 'MATERIAL'.

        "Se actualiza centro de ecc por el actual hana
        READ TABLE it_werks_hana INTO DATA(wa_werks) WITH KEY sort1 = <fs_wa>-werks_ecc.
        IF sy-subrc EQ 0.
          <fs_wa>-werks = wa_werks-werks.
        ELSE.
          <fs_wa>-werks = 'SINR'.
        ENDIF.


        READ TABLE it_matnrhana INTO DATA(hana) WITH KEY bismt = <fs_wa>-bismt.
        IF sy-subrc EQ 0.
          <fs_wa>-matnr = hana-matnr.
          READ TABLE it_makt INTO DATA(wa) WITH KEY matnr = <fs_wa>-matnr.
          IF sy-subrc EQ 0.
            <fs_wa>-maktx = wa-maktx.
            <fs_wa>-lgort = wa-lgort.
          ENDIF.
        ELSE.
          <fs_wa>-matnr = 'SIN RELACION'.
        ENDIF.

        "Se realizan las consultar para obtener la clase de costo.
        IF <fs_wa>-matnr NE 'SIN RELACION'.


          SELECT SINGLE bklas INTO @DATA(vl_bklas)
          FROM mbew WHERE matnr = @<fs_wa>-matnr.
          IF vl_bklas IS NOT INITIAL.
            SELECT SINGLE bwmod INTO @DATA(vl_bwmod)
              FROM t001k WHERE bwkey = @<fs_wa>-werks.
            IF sy-subrc EQ 0.
              SELECT SINGLE konts INTO @DATA(vl_konts)
                FROM t030 WHERE ktopl = 'GP00'
                AND bwmod = @vl_bwmod
                AND komok = 'VBR'
                AND bklas = @vl_bklas.
              IF sy-subrc EQ 0.
                <fs_wa>-kstar = vl_konts.
              ELSE.
                <fs_wa>-kstar = 'Sin t030'.
              ENDIF.
            ELSE.
              <fs_wa>-kstar = 'No Rel. Ce'.
            ENDIF.
          ENDIF.
        ELSE.
          <fs_wa>-kstar = 'No Eq. Mat'.
        ENDIF.

      ELSEIF <fs_wa>-tipo EQ 'CUENTA'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <fs_wa>-cuenta
          IMPORTING
            output = <fs_wa>-cuenta.

        READ TABLE it_cuentas INTO DATA(wa_cuenta) WITH KEY cuenta_ecc = <fs_wa>-cuenta kokrs = <fs_wa>-kokrs.
        IF sy-subrc EQ 0 .
          <fs_wa>-cuenta = wa_cuenta-cuenta_hana.
          <fs_wa>-kstar = wa_cuenta-cuenta_hana.
        ELSE.
          <fs_wa>-cuenta = 'SIN REL'.

        ENDIF.
      ENDIF.


      "CeCos
      READ TABLE it_kostl INTO DATA(wa_kostl) WITH KEY name2 = <fs_wa>-kostl_ecc.
      IF sy-subrc EQ 0.
        <fs_wa>-kostl = wa_kostl-kostl.
      ELSE.
        <fs_wa>-kostl = 'SIN RELAC.'.
      ENDIF.



      <fs_wa>-cecoaut = ''.
      "Se agregan los CeCos para contabilizar el presupuesto migrado.

      CLEAR wa_auth.
      wa_auth-kostl = <fs_wa>-kostl.
      wa_auth-bname = sy-uname.
      wa_auth-name_text = sy-uname.
      APPEND wa_auth TO it_auth.
    ENDLOOP.

    SORT it_auth BY kostl.
    DELETE ADJACENT DUPLICATES FROM it_auth COMPARING kostl.
    "


    CALL SCREEN 1005.


  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fcat_planpres
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fcat_planpres .

  DATA ls_fcat TYPE lvc_s_fcat .
  REFRESH po_fieldcat.
  DATA col TYPE i.

  col = 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Tipo'.
  ls_fcat-fieldname = 'TIPO'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Material Hana'.
  ls_fcat-fieldname = 'MATNR'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Descripcion'.
  ls_fcat-fieldname = 'MAKTX'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Material ECC.'.
  ls_fcat-fieldname = 'BISMT'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'UMB'.
  ls_fcat-fieldname = 'MEINS'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Centro Log. Hana'.
  ls_fcat-fieldname = 'WERKS'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Centro Log. ECC'.
  ls_fcat-fieldname = 'WERKS_ANT'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Cl. Coste'.
  ls_fcat-fieldname = 'KSTAR'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Centro Coste'.
  ls_fcat-fieldname = 'KOSTL'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Prec. Unit.'.
  ls_fcat-fieldname = 'PREUNI'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Moneda'.
  ls_fcat-fieldname = 'WAERS'.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.
  "-----Cantidades
  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Enero'.
  ls_fcat-fieldname = 'MEG001'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Febrero'.
  ls_fcat-fieldname = 'MEG002'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Marzo'.
  ls_fcat-fieldname = 'MEG003'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Abril'.
  ls_fcat-fieldname = 'MEG004'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Mayo'.
  ls_fcat-fieldname = 'MEG005'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Junio'.
  ls_fcat-fieldname = 'MEG006'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Julio'.
  ls_fcat-fieldname = 'MEG007'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Agosto'.
  ls_fcat-fieldname = 'MEG008'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Septiembre'.
  ls_fcat-fieldname = 'MEG009'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Octubre'.
  ls_fcat-fieldname = 'MEG010'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Noviembre'.
  ls_fcat-fieldname = 'MEG011'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Diciembre'.
  ls_fcat-fieldname = 'MEG012'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Total'.
  ls_fcat-fieldname = 'MEGTOT'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.
*-------------------------
  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Enero'.
  ls_fcat-fieldname = 'WTG001'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Febrero'.
  ls_fcat-fieldname = 'WTG002'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Marzo'.
  ls_fcat-fieldname = 'WTG003'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Abril'.
  ls_fcat-fieldname = 'WTG004'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Mayo'.
  ls_fcat-fieldname = 'WTG005'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Junio'.
  ls_fcat-fieldname = 'WTG006'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Julio'.
  ls_fcat-fieldname = 'WTG007'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Agosto'.
  ls_fcat-fieldname = 'WTG008'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Septiembre'.
  ls_fcat-fieldname = 'WTG009'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Octubre'.
  ls_fcat-fieldname = 'WTG010'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Noviembre'.
  ls_fcat-fieldname = 'WTG011'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Diciembre'.
  ls_fcat-fieldname = 'WTG012'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Total'.
  ls_fcat-fieldname = 'WTGTOT'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO po_fieldcat. col = col + 1.

ENDFORM.
