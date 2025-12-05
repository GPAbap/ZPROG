*&---------------------------------------------------------------------*
*&  Include           ZCO_COCKPIT_PRESUPUESTO_ALV
*& 07032023
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv_tree USING p_it_outtable TYPE STANDARD TABLE
      p_fieldcat TYPE lvc_t_fcat
      container TYPE char20.
  .

  it_layout-sel_mode = 'A'.
  it_layout-no_rowmark = 'X'.
  IF id_exec NE 'AjustePres'.
    it_layout-CWIDTH_OPT = 'X'.
  ELSE.
    it_layout-CWIDTH_OPT = ''.
  ENDIF.
  it_layout-info_fname = 'COLOR'.
  it_layout-stylefname = 'CELLTAB'.

  TRY.
    CALL METHOD gref_alvgrid102->free.
  CATCH cx_sy_ref_is_initial.

  ENDTRY.

  TRY.
    CALL METHOD gref_ccontainer102->free.
  CATCH cx_sy_ref_is_initial.

  ENDTRY.


  CREATE OBJECT gref_ccontainer102
  EXPORTING
    container_name              = container
  EXCEPTIONS
    cntl_error                  = 1
    cntl_system_error           = 2
    create_error                = 3
    lifetime_error              = 4
    lifetime_dynpro_dynpro_link = 5
    OTHERS                      = 6.

  CREATE OBJECT gref_alvgrid102
  EXPORTING
    i_parent          = gref_ccontainer102
  EXCEPTIONS
    error_cntl_create = 1
    error_cntl_init   = 2
    error_cntl_link   = 3
    error_dp_create   = 4
    OTHERS            = 5.


  CALL METHOD gref_alvgrid102->set_table_for_first_display
  EXPORTING
    is_layout                     = it_layout
*        it_toolbar_excluding          = lt_excl_func1
  CHANGING
    it_outtab                     = p_it_outtable[]
    it_fieldcatalog               = p_fieldcat
  EXCEPTIONS
    invalid_parameter_combination = 1
    program_error                 = 2
    too_many_lines                = 3
    OTHERS                        = 4.

  CALL METHOD gref_alvgrid102->refresh_table_display
  EXPORTING
    i_soft_refresh = 'X'.

  CALL METHOD gref_alvgrid102->set_ready_for_input
  EXPORTING
    i_ready_for_input = 1.


  CREATE OBJECT event_handlerdyn102.

  SET HANDLER event_handlerdyn102->handle_user_command FOR gref_alvgrid102.
  SET HANDLER event_handlerdyn102->handle_toolbar FOR gref_alvgrid102.
  SET HANDLER event_handlerDyn102->on_link_click FOR gref_alvgrid102.

  CALL METHOD gref_alvgrid102->set_toolbar_interactive.

**** REGISTRO DE BOTON ENTER
  CALL METHOD gref_alvgrid102->register_edit_event
  EXPORTING
    i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CREATE OBJECT grid_handlerdyn102.
  SET HANDLER grid_handlerdyn102->handle_data_changed FOR gref_alvgrid102.




ENDFORM.                    " DISPLAY_ALV
