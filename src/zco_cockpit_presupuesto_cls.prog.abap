*&---------------------------------------------------------------------*
*&  Include           ZCO_COCKPIT_PRESUPUESTO_CLS
*& 07032023
*&---------------------------------------------------------------------*


*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION .
  PUBLIC SECTION .

    DATA: ls_toolbar TYPE stb_button.
    DATA: gv_bukrs TYPE bukrs.
    METHODS:
*--To implement user commands
      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

* hotspot
      on_link_click
        FOR EVENT hotspot_click   "Hotspot Handler
        OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id,

*      Method to handle toolbar
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive.                   "#EC *



ENDCLASS.                    "lcl_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_toolbar.
    CLEAR ls_toolbar.



*APPEND ls_toolbar TO lt_toolbar.
*    append ls_toolbar to e_object->mt_toolbar.
*add push button to the alv tool bar
    CLEAR ls_toolbar.
    MOVE 'REFR' TO ls_toolbar-function.
    MOVE 'Cancela Solicitud' TO ls_toolbar-quickinfo.
    MOVE '@1T@' TO ls_toolbar-icon.
    MOVE 'Cancelar Seleccionado' TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.
*    move 'CTRL+D' to ls_toolbar-function.
    APPEND ls_toolbar TO e_object->mt_toolbar.

*
    CLEAR ls_toolbar.
    MOVE 'AUTHSEL' TO ls_toolbar-function.
    MOVE 'Autorizar Seleccionados' TO ls_toolbar-quickinfo.
*    move '@1T@' to ls_toolbar-icon.
    MOVE 'Autorizar Seleccionados' TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.
*    move 'CTRL+D' to ls_toolbar-function.
    APPEND ls_toolbar TO e_object->mt_toolbar.

*    MOVE 'COMPROBAR' TO ls_toolbar-function.
*    MOVE 'Comprobar Presupuesto: Archivo Original con SAP' TO ls_toolbar-quickinfo.
**    move '@1T@' to ls_toolbar-icon.
*    MOVE 'Comprobar presupuesto' TO ls_toolbar-text.
*    MOVE ' ' TO ls_toolbar-disabled.
**    move 'CTRL+D' to ls_toolbar-function.
*    APPEND ls_toolbar TO e_object->mt_toolbar.

*            clear ls_toolbar.
*    move 'PRINT' to ls_toolbar-function.
*    move 'Emitir PDF' to ls_toolbar-quickinfo.
*    move '@IT@' to ls_toolbar-icon.
*    move 'Emitir PDF' to ls_toolbar-text.
*    move ' ' to ls_toolbar-disabled.
*    append ls_toolbar to e_object->mt_toolbar.



  ENDMETHOD.                    "handle_toolbar

  METHOD on_link_click.
    DATA: lv_answer TYPE c.
    FIELD-SYMBOLS <lfs_it> TYPE any.
    FIELD-SYMBOLS <lfs_wa> TYPE any.
    FIELD-SYMBOLS <lfs_anio> TYPE any.
    DATA: lv_anio    TYPE i,lv_aniodif TYPE i.
    DATA lv_autorizado.
    DATA: lv_idpres TYPE char10,
          lv_bukrs  TYPE bukrs.

    TYPES: BEGIN OF st_xls,
             archivo         TYPE string,
             anio(4)         TYPE c,
             status(4)       TYPE c,
             comentario(200) TYPE c,
           END OF st_xls.

    TYPES: BEGIN OF st_pendientes,
             idpres      TYPE char10,
             versn       type char3,
             gjahr       TYPE gjahr,
             cveaut      TYPE char2,
             usuario     TYPE uname,
             fecha       TYPE datum,
             hora        TYPE uzeit,
             autorizado  TYPE char1,
             autorizador TYPE uname,
             fechaaut    TYPE datum,
             horaaut     TYPE uzeit,
             statustx    TYPE char20,
             flag(1), " for selection of records
           END OF st_pendientes.


    DATA lv_it_xls TYPE STANDARD TABLE OF st_xls.
    DATA  lv_it_pendientes TYPE STANDARD TABLE OF st_pendientes.

    DATA lv_comentario(200) TYPE c.

* Only respond to a single click when the user pointed to the CLAIM or
* the TRANSID column, in a specific row.
*

*        INDEX e_row_id.



    IF e_column_id EQ 'ARCHIVO'.
      REFRESH lv_it_xls.
      APPEND INITIAL LINE TO lv_it_xls.
      READ TABLE lv_it_xls ASSIGNING <lfs_it> INDEX 1.



      PERFORM get_name_file USING e_row_id
      CHANGING <lfs_it>.

      IF <lfs_it> IS ASSIGNED.

        ASSIGN COMPONENT 'ANIO' OF STRUCTURE <lfs_it> TO <lfs_wa>.
        lv_anio = <lfs_wa>.
        IF lv_anio LT sy-datum+0(4).
          MESSAGE 'No se puede ingresar un presupuesto con año menor al actual'
          TYPE 'S' DISPLAY LIKE 'E'.
          RETURN.
        ELSEIF lv_anio GT sy-datum+0(4).
          lv_aniodif = lv_anio - sy-datum+0(4).
          IF lv_aniodif GE 2.
            MESSAGE 'No se puede ingresar un presupuesto con un rango mayor a dos años posteriores del año actual'
            TYPE 'S' DISPLAY LIKE 'E'.
            RETURN.
          ENDIF.

        ENDIF.

        ASSIGN COMPONENT 'COMENTARIO' OF STRUCTURE <lfs_it> TO <lfs_wa>.
        lv_comentario = <lfs_wa>.


        ASSIGN COMPONENT 'STATUS' OF STRUCTURE <lfs_it> TO <lfs_wa>.

        IF e_column_id EQ 'ARCHIVO' AND <lfs_wa> EQ '@09@'.

          CALL FUNCTION 'POPUP_TO_CONFIRM'
            EXPORTING
              titlebar       = 'Carga de archivo de Presupuesto'
              text_question  = '¿Esta seguro de aplicar el documento?'
              text_button_1  = 'Si'(003)                                   " Texto botón 1
              icon_button_1  = 'ICON_CHECKED'                             " Ícono botón 1
              text_button_2  = 'No'(004)                                   " Texto botón 2
              icon_button_2  = 'ICON_INCOMPLETE'                              " Ícono botón 2
              default_button = '1'                                        " Botón por defecto
              start_column   = 25
              start_row      = 6
              popup_type     = 'ICON_MESSAGE_CRITICA'
            IMPORTING
              answer         = lv_answer " Respuesta
            EXCEPTIONS
              text_not_found = 1
              OTHERS         = 2.


          IF lv_answer EQ '1'.
            ASSIGN COMPONENT 'ARCHIVO' OF STRUCTURE <lfs_it> TO <lfs_wa>.

            PERFORM upload_data USING <lfs_wa>
                  lv_comentario
                  lv_anio.

          ENDIF.

        ELSE.
          MESSAGE 'Archivo de presupuesto ya ha sigo cargado' TYPE 'S'.
        ENDIF.

      ENDIF. "row in ALV obtained

    ELSEIF e_column_id EQ 'IDPRES'.
      REFRESH lv_it_pendientes.
      APPEND INITIAL LINE TO lv_it_pendientes.
      READ TABLE lv_it_pendientes ASSIGNING <lfs_it> INDEX 1.

      PERFORM get_idpres_sel USING e_row_id
      CHANGING <lfs_it>.                                                                 "Read table para identificar por llave
      IF <lfs_it> IS NOT INITIAL.
        ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <lfs_it> TO  <lfs_wa>.
        ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <lfs_it> TO <lfs_anio>.
                                                         "si se identifica
        PERFORM show_presupuesto USING <lfs_wa> <lfs_anio>.                "Ejecutamos la muestra de presupuesto
        UNASSIGN <lfs_wa>.
        "Limpiamos el value.
      ELSE.
        MESSAGE 'Ya no hay CeCos pendientes por autorizar para este usuario.' TYPE 'S'.
      ENDIF.
    ELSEIF e_column_id EQ 'STATUSTX'.
      REFRESH lv_it_pendientes.
      APPEND INITIAL LINE TO lv_it_pendientes.
      READ TABLE lv_it_pendientes ASSIGNING <lfs_it> INDEX 1.
      PERFORM get_idpres_sel USING e_row_id
      CHANGING <lfs_it>.
      lv_idpres = <lfs_it>.
      lv_bukrs = gv_bukrs.

      IF <lfs_it> IS NOT INITIAL.
        ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <lfs_it> TO  <lfs_wa>.                                                  "si se identifica
        PERFORM get_cecos_pend USING lv_idpres.                "Ejecutamos la muestra de presupuesto
        UNASSIGN <lfs_wa>.
      ENDIF.

    ENDIF.

  ENDMETHOD.                    "on_link_click

* Logic to handle the push button
  METHOD handle_user_command.
*   To handle user command
    PERFORM handle_user_command USING e_ucomm .
  ENDMETHOD.                           " METHOD HANDLE_USER_COMMAND
ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION


"Clase que no limita la carga de los 9999 registros de Excel a una TT.
*----------------------------------------------------------------------*
*       CLASS lcl_excel_uploader DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_excel_uploader DEFINITION.
  PUBLIC SECTION.
    DATA: header_rows_count TYPE i.
    DATA: max_rows          TYPE i.
    DATA: filename          TYPE localfile.
    DATA: initial_col       TYPE i.
    DATA: matnr_col(4)         TYPE c.
    METHODS:
      constructor.
    METHODS:
      upload CHANGING ct_data TYPE ANY TABLE.
  PRIVATE SECTION.
    DATA: lv_tot_components TYPE i.
    METHODS:
      do_upload
        IMPORTING
          iv_begin TYPE i
          iv_end   TYPE i
        EXPORTING
          rv_empty TYPE flag
        CHANGING
          ct_data  TYPE STANDARD TABLE.

ENDCLASS.                    "lcl_excel_uploader DEFINITION

*
CLASS lcl_excel_uploader IMPLEMENTATION.
  METHOD constructor.
    max_rows = 200000.
    initial_col = 2.
    matnr_col = '0002'.
  ENDMETHOD.                    "constructor
  METHOD upload.
    DATA: lo_struct TYPE REF TO cl_abap_structdescr,
          lo_table  TYPE REF TO cl_abap_tabledescr,
          lt_comp   TYPE cl_abap_structdescr=>component_table.

    lo_table ?= cl_abap_structdescr=>describe_by_data( ct_data ).
    lo_struct ?= lo_table->get_table_line_type( ).
    lt_comp    = lo_struct->get_components( ).
*
    lv_tot_components = lines( lt_comp ).
*
    DATA: lv_empty TYPE flag,
          lv_begin TYPE i,
          lv_end   TYPE i.
*
    lv_begin = header_rows_count + 1.
    lv_end   = max_rows.
    WHILE lv_empty IS INITIAL.
      do_upload(
      EXPORTING
        iv_begin = lv_begin
        iv_end   = lv_end
      IMPORTING
        rv_empty = lv_empty
      CHANGING
        ct_data  = ct_data
        ).
      lv_begin = lv_end + 1.
      lv_end   = lv_begin + max_rows.
    ENDWHILE.
  ENDMETHOD.                    "upload
*
  METHOD do_upload.

    DATA: li_exceldata  TYPE STANDARD TABLE OF alsmex_tabline.
    DATA: ls_exceldata  LIKE LINE OF li_exceldata.
    DATA: lv_tot_rows   TYPE i.
    DATA: lv_packet     TYPE i.
    DATA lv_matnr TYPE matnr.
    FIELD-SYMBOLS: <struc> TYPE any,
                   <field> TYPE any.

*   Upload this packet
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = filename
        i_begin_col             = initial_col
        i_begin_row             = iv_begin
        i_end_col               = lv_tot_components
        i_end_row               = iv_end
      TABLES
        intern                  = li_exceldata
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
*   something wrong, exit
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      rv_empty = 'X'.
      EXIT.
    ENDIF.

*   No rows uploaded, exit
    IF li_exceldata IS INITIAL.
      rv_empty = 'X'.
      EXIT.
    ENDIF.

*   Move from Row, Col to Flat Structure
    LOOP AT li_exceldata INTO ls_exceldata.
      " Append new row
      AT NEW row.
        APPEND INITIAL LINE TO ct_data ASSIGNING <struc>.
      ENDAT.

      " component and its value
      ASSIGN COMPONENT ls_exceldata-col OF STRUCTURE <struc> TO <field>.
      IF sy-subrc EQ 0.

        TRY.
            IF ls_exceldata-col EQ matnr_col. "cambio de 0040 a 0002 codigo de material
              IF ls_exceldata-value NE '' OR ls_exceldata-value NE space OR ls_exceldata-value IS NOT INITIAL.

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_exceldata-value
                  IMPORTING
                    output = lv_matnr.

                lv_matnr = lv_matnr+22(18). "Se recorta a 18 posiciones, dado a que el elemento de datos de matnr es de 40
                ls_exceldata-value = lv_matnr.
              ENDIF.
            ENDIF.

            <field> = ls_exceldata-value.
          CATCH cx_sy_conversion_no_number.
            "MESSAGE 'error de contenido numerico' TYPE 'S'.
            REPLACE ALL OCCURRENCES OF '$' IN ls_exceldata-value WITH space.
            REPLACE ALL OCCURRENCES OF ',' IN ls_exceldata-value WITH space.
            CONDENSE ls_exceldata-value NO-GAPS.
            <field> = ls_exceldata-value.
        ENDTRY.

      ENDIF.

      " add the row count
      AT END OF row.
        IF <struc> IS NOT INITIAL.
          lv_tot_rows = lv_tot_rows + 1.
        ENDIF.
      ENDAT.
    ENDLOOP.

*   packet has more rows than uploaded rows,
*   no more packet left. Thus exit
    lv_packet = iv_end - iv_begin.
    IF lv_tot_rows LT lv_packet.
      rv_empty = 'X'.
    ENDIF.

  ENDMETHOD.                    "do_upload
ENDCLASS.                    "lcl_excel_uploader IMPLEMENTATION
"Clase para el menú tipo arbol, para el dispatcher de reportes
*----------------------------------------------------------------------*
*       CLASS LCL_APPLICATION DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_application DEFINITION.

  PUBLIC SECTION.
    METHODS:
      handle_node_double_click
        FOR EVENT node_double_click
        OF cl_gui_simple_tree
        IMPORTING node_key,
      handle_expand_no_children
        FOR EVENT expand_no_children
        OF cl_gui_simple_tree
        IMPORTING node_key.
ENDCLASS.                    "LCL_APPLICATION DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_APPLICATION IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.

  METHOD  handle_node_double_click.

    CASE node_key.
      WHEN 'MatCantidade'.
        gv_numsubscr = '103'.
        PERFORM containers_free.
      WHEN 'MatMontos'.
        gv_numsubscr = '104'.
        PERFORM containers_free.
      WHEN 'ValidarMat'.
        AUTHORITY-CHECK OBJECT 'ZCO_RESERV'
          ID 'BTCUNAME' FIELD sy-uname
          ID 'ACTVT' FIELD '03'.

        IF sy-subrc EQ 0.
          gv_numsubscr = '102'.
          PERFORM containers_free.
        ELSE.
          MESSAGE 'No tiene autorización para realizar esta actividad' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'ElabSolpeds'.
        AUTHORITY-CHECK OBJECT 'ZCO_SOLPED'
          ID 'BTCUNAME' FIELD sy-uname
          ID 'ACTVT' FIELD '03'.

        IF sy-subrc EQ 0.
          gv_numsubscr = '102'.
          PERFORM containers_free.
        ELSE.
          MESSAGE 'No tiene autorización para realizar esta actividad' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'AjustePres'.
        gv_numsubscr = '105'.
        PERFORM containers_free.
      WHEN OTHERS.
    ENDCASE.
    id_exec = node_key.
  ENDMETHOD.                    "HANDLE_NODE_DOUBLE_CLICK

  METHOD handle_expand_no_children.
    " this method handles the expand no children event of the tree
    " control instance
    DATA: node_table TYPE node_table_type,
          node       TYPE mtreesnode.

    " show the key of the double clicked node in a dynpro field
*    G_EVENT = 'EXPAND_NO_CHILDREN'.
*    G_NODE_KEY = NODE_KEY.

    IF node_key = 'Seleccionar'.
* add two nodes to the tree control (the children of 'Child1')

* Node with key 'New1'
      CLEAR node.
      node-node_key = c_nodekey-new1.
      node-relatkey = c_nodekey-child1.
      node-relatship = cl_gui_simple_tree=>relat_last_child.
      node-n_image = '@0M@'.
      node-isfolder = ' '.
      node-text = 'Mat. Presupuesto'(ne1).
      APPEND node TO node_table.

* Node with key 'New2'
      CLEAR node.
      node-node_key = c_nodekey-new2.
      node-relatkey = c_nodekey-child1.
      node-relatship = cl_gui_simple_tree=>relat_last_child.
      node-n_image = '@10@'.
      node-expander = ' '.
      node-text = 'Reporte Serv/Ctas.'(ne2).
      APPEND node TO node_table.

      CLEAR node.
      node-node_key = c_nodekey-new3.
      node-relatkey = c_nodekey-child1.
      node-relatship = cl_gui_simple_tree=>relat_last_child.
      node-n_image = '@SP@'.
      node-expander = ' '.
      node-text = 'Confirmar Mat.'(ne2).
      APPEND node TO node_table.

* Node with key 'New4'
      CLEAR node.
      node-node_key = c_nodekey-new4.
      node-relatkey = c_nodekey-child1.
      node-relatship = cl_gui_simple_tree=>relat_last_child.
      node-n_image = '@XE@'.
      node-expander = ' '.
      node-text = 'Solped Presup.'(ne2).
      APPEND node TO node_table.

      CLEAR node.
      node-node_key = c_nodekey-new5.
      node-relatkey = c_nodekey-child1.
      node-relatship = cl_gui_simple_tree=>relat_last_child.
      node-n_image = '@58@'.
      node-expander = ' '.
      node-text = 'Ajustes Presupuesto'(ne2).
      APPEND node TO node_table.




      CALL METHOD g_tree->add_nodes
        EXPORTING
          table_structure_name           = 'MTREESNODE'
          node_table                     = node_table
        EXCEPTIONS
          failed                         = 1
          error_in_node_table            = 2
          dp_error                       = 3
          table_structure_name_not_found = 4
          OTHERS                         = 5.
      IF sy-subrc <> 0.
        "MESSAGE A000.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "HANDLE_EXPAND_NO_CHILDREN

ENDCLASS.                    "LCL_APPLICATION IMPLEMENTATION
*-----------para dynpro102
CLASS lcl_event_receiverdyn102 DEFINITION .
  PUBLIC SECTION .

    DATA: ls_toolbar TYPE stb_button.

    METHODS:
*--To implement user commands
      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

* hotspot
      on_link_click
        FOR EVENT hotspot_click   "Hotspot Handler
        OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no,

*      Method to handle toolbar
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive.


ENDCLASS.                    "lcl_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_receiverdyn102 IMPLEMENTATION.
  METHOD handle_toolbar.

    IF id_exec EQ 'ElabSolpeds'.

      CLEAR ls_toolbar.
      MOVE 'SOLPED' TO ls_toolbar-function.
      MOVE 'Crear Solped' TO ls_toolbar-quickinfo.
      MOVE '@G5@' TO ls_toolbar-icon.
      MOVE 'Crear Solped' TO ls_toolbar-text.
      MOVE '' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR ls_toolbar.
      MOVE 'SELALL' TO ls_toolbar-function.
      MOVE 'Seleccionar Todo' TO ls_toolbar-quickinfo.
      MOVE '@4B@' TO ls_toolbar-icon.
      MOVE 'Seleccionar Todo' TO ls_toolbar-text.
      MOVE '' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.


    ELSEIF id_exec EQ 'MatCantidade' OR id_exec EQ 'MatMontos' .
      CLEAR ls_toolbar.
      MOVE 'CUBO' TO ls_toolbar-function.
      MOVE 'Alternar Cant/Montos' TO ls_toolbar-quickinfo.
      MOVE '@BW@' TO ls_toolbar-icon.
      MOVE 'Cant./Montos' TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR ls_toolbar.
      MOVE 'ANALIS' TO ls_toolbar-function.
      MOVE 'Análisis del Presupuesto' TO ls_toolbar-quickinfo.
      MOVE '@SK@' TO ls_toolbar-icon.
      MOVE 'Análisis Pto.' TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

    ELSEIF id_exec EQ 'ValidarMat'.
      CLEAR ls_toolbar.
      MOVE 'MAT' TO ls_toolbar-function.
      MOVE 'Conf. Materiales' TO ls_toolbar-quickinfo.
      MOVE '@SP@' TO ls_toolbar-icon.
      MOVE 'Conf. Materiales' TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR ls_toolbar.
      MOVE 'RESERVAS' TO ls_toolbar-FUNCTION.
      MOVE 'Crear Reserva' TO ls_toolbar-quickinfo.
      MOVE '@D0@' TO ls_toolbar-ICON.
      MOVE 'Crear Reserva' TO ls_toolbar-TEXT.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR ls_toolbar.
      MOVE 'SELALL' TO ls_toolbar-function.
      MOVE 'Seleccionar Todo' TO ls_toolbar-quickinfo.
      MOVE '@4B@' TO ls_toolbar-icon.
      MOVE 'Seleccionar Todo' TO ls_toolbar-text.
      MOVE '' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

    ELSE.
      CLEAR ls_toolbar.
      MOVE 'SAVEPRES' TO ls_toolbar-function.
      MOVE 'Grabar Ajuste' TO ls_toolbar-quickinfo.
      MOVE '@DN@' TO ls_toolbar-icon.
      MOVE 'Grabar Ajuste' TO ls_toolbar-text.
      MOVE '' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR ls_toolbar.
      MOVE 'SELALLAJU' TO ls_toolbar-function.
      MOVE 'Seleccionar Todo' TO ls_toolbar-quickinfo.
      MOVE '@4B@' TO ls_toolbar-icon.
      MOVE 'Seleccionar Todo' TO ls_toolbar-text.
      MOVE '' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.
  ENDMETHOD.                    "handle_toolbar

* Logic to handle the push button
  METHOD handle_user_command.
*   To handle user command
    PERFORM handle_user_command USING e_ucomm .
  ENDMETHOD.                    "handle_user_command
  METHOD on_link_click.

    PERFORM item_click USING e_row_id e_column_id es_row_no.
  ENDMETHOD.                    "on_link_click


ENDCLASS.                    "lcl_event_receiverDyn102 IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_grid_event_receiverDyn102 DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_grid_event_receiverdyn102 DEFINITION.
  PUBLIC SECTION.


    METHODS:
      handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.

ENDCLASS.                    "LCL_GRID_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_GRID_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_grid_event_receiverdyn102 IMPLEMENTATION.


  METHOD handle_data_changed.
    DATA: edit,tipo.
    FIELD-SYMBOLS: <ft_cells> TYPE lvc_t_modi, <ls_tabla> TYPE any, <linea> TYPE any.

    ASSIGN er_data_changed->mt_mod_cells TO <ft_cells>.
    READ TABLE <ft_cells> ASSIGNING <ls_tabla> INDEX 1.
    ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <ls_tabla> TO <linea>.
    IF <linea> EQ 'BEKNZ'.
      PERFORM update_checkbox.

    ELSE.

      PERFORM val_auth_reserv USING er_data_changed CHANGING tipo.

      PERFORM valida_edit USING er_data_changed
      CHANGING edit.

      IF tipo EQ 'A' AND edit EQ 'S'. "si es autorizacion y no hay solped registrada
        PERFORM check_data USING er_data_changed.
      ELSEIF edit EQ 'C'. "si es checkbox el editable
        PERFORM update_checkbox.
      ELSEIF tipo EQ 'C'.
        PERFORM update_checkbox.
      ELSEIF tipo EQ 'A' AND edit EQ ''. "si el material a autorizar ya tiene solped
        MESSAGE 'Material con Solped. No es posible modificar' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

    ENDIF.
  ENDMETHOD.                    "handle_data_changed


ENDCLASS.                    "LCL_GRID_EVENT_RECEIVER IMPLEMENTATION


*------------------------------------------------
CLASS lcl_grid_event_receiverdyn103 DEFINITION.
  PUBLIC SECTION.

    DATA: ls_toolbar TYPE stb_button.

    METHODS:
*--To implement user commands
      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

*   Method to handle toolbar
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive.


ENDCLASS.

CLASS lcl_grid_event_receiverdyn103 IMPLEMENTATION.
  METHOD handle_user_command.
*   To handle user command
    PERFORM handle_user_command103 USING e_ucomm .
  ENDMETHOD.

  METHOD handle_toolbar.

    CLEAR ls_toolbar.
    MOVE 'LIMPIAR' TO ls_toolbar-function.
    MOVE 'Limpiar CeCo(s)' TO ls_toolbar-quickinfo.
    MOVE '@0V@' TO ls_toolbar-icon.
    MOVE 'Limpiar CeCo(s)' TO ls_toolbar-text.
    MOVE '' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.
ENDCLASS.                    "LCL_GRID_EVENT_RECEIVER IMPLEMENTATION
*------------------------------------------------
CLASS lcl_grid_event_receiverdynecc DEFINITION.
  PUBLIC SECTION.

    DATA: ls_toolbar TYPE stb_button.

    METHODS:
*--To implement user commands
      handle_user_commandecc
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

*   Method to handle toolbar
      handle_toolbarecc
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive.


ENDCLASS.

CLASS lcl_grid_event_receiverdynecc IMPLEMENTATION.
  METHOD handle_user_commandecc.
*   To handle user command
    PERFORM handle_user_commandecc USING e_ucomm .
  ENDMETHOD.

  METHOD handle_toolbarecc.

    CLEAR ls_toolbar.
    MOVE 'MIGRAR' TO ls_toolbar-function.
    MOVE 'MIGRAR ECC A HANA' TO ls_toolbar-quickinfo.
    MOVE '@0V@' TO ls_toolbar-icon.
    MOVE 'Migrar Ecc a Hana' TO ls_toolbar-text.
    MOVE '' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.
ENDCLASS.

CLASS lcl_grid_event_receiverdyn104 DEFINITION.
  PUBLIC SECTION.

    DATA: ls_toolbar TYPE stb_button.

    METHODS:
*--To implement user commands
      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

*   Method to handle toolbar
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive.


ENDCLASS.

CLASS lcl_grid_event_receiverdyn104 IMPLEMENTATION.
  METHOD handle_user_command.
*   To handle user command
    PERFORM handle_user_command104 USING e_ucomm .
  ENDMETHOD.

  METHOD handle_toolbar.

    CLEAR ls_toolbar.
    MOVE 'REAUTH' TO ls_toolbar-function.
    MOVE 'Preparar Autozación' TO ls_toolbar-quickinfo.
    MOVE '@0V@' TO ls_toolbar-icon.
    MOVE 'Preparar Autorizacion' TO ls_toolbar-text.
    MOVE '' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.
ENDCLASS.                    "LCL_GRID_EVENT_RECEIVER IMPLEMENTATION
