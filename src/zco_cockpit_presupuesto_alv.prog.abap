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
FORM display_alv USING p_it_outtable TYPE STANDARD TABLE
                        p_fieldcat TYPE lvc_t_fcat
                        container TYPE char20.
                    .
  it_layout-CWIDTH_OPT = 'X'.

  CASE container.
  WHEN 'CCONTAINER'.
    TRY.
      CALL METHOD gref_alvgrid->free.
    CATCH CX_SY_REF_IS_INITIAL.

    ENDTRY.

    TRY.
      CALL METHOD gref_ccontainer->free.
    CATCH CX_SY_REF_IS_INITIAL.

    ENDTRY.


    CREATE OBJECT gref_ccontainer
    EXPORTING
      container_name              = container
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

    CREATE OBJECT gref_alvgrid
    EXPORTING
      i_parent          = gref_ccontainer
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

    CALL METHOD gref_alvgrid->set_table_for_first_display
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

    CALL METHOD gref_alvgrid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.
  WHEN 'CCONTAINER_ALV'.
    TRY.
      CALL METHOD gref_alvgridd->free.
    CATCH CX_SY_REF_IS_INITIAL.

    ENDTRY.

    TRY.
      CALL METHOD gref_ccontainerd->free.
    CATCH CX_SY_REF_IS_INITIAL.

    ENDTRY.

    clear: gref_alvgridd, gref_ccontainerd.

    CREATE OBJECT gref_ccontainerd
    EXPORTING
      container_name              = container
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

    CREATE OBJECT gref_alvgridd
    EXPORTING
      i_parent          = gref_ccontainerd
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

    CALL METHOD gref_alvgridd->set_table_for_first_display
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

    CALL METHOD gref_alvgridd->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.

  WHEN 'CCONTAINER01'.
    TRY.
      CALL METHOD gref_alvgrid101->free.
    CATCH CX_SY_REF_IS_INITIAL.

    ENDTRY.

    TRY.
      CALL METHOD gref_ccontainer101->free.
    CATCH CX_SY_REF_IS_INITIAL.

    ENDTRY.

    CREATE OBJECT gref_ccontainer101
    EXPORTING
      container_name              = container
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

    CREATE OBJECT gref_alvgrid101
    EXPORTING
      i_parent          = gref_ccontainer101
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

    CALL METHOD gref_alvgrid101->set_table_for_first_display
*      EXPORTING
*       is_layout                     = gs_layout
*        it_toolbar_excluding          = lt_excl_func1
    CHANGING
      it_outtab                     = p_it_outtable[]
      it_fieldcatalog               = p_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

    CALL METHOD gref_alvgrid101->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.

  WHEN 'CCONTAINER101D'.
    TRY.
      CALL METHOD gref_alvgrid101D->free.
    CATCH CX_SY_REF_IS_INITIAL.

    ENDTRY.

    TRY.
      CALL METHOD gref_ccontainer101D->free.
    CATCH CX_SY_REF_IS_INITIAL.

    ENDTRY.


    CREATE OBJECT gref_ccontainer101D
    EXPORTING
      container_name              = container
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

    CREATE OBJECT gref_alvgrid101D
    EXPORTING
      i_parent          = gref_ccontainer101D
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

    CALL METHOD gref_alvgrid101D->set_table_for_first_display
*      EXPORTING
*       is_layout                     = gs_layout
*        it_toolbar_excluding          = lt_excl_func1
    CHANGING
      it_outtab                     = p_it_outtable[]
      it_fieldcatalog               = p_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

    CALL METHOD gref_alvgrid101D->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.

  WHEN OTHERS.
  ENDCASE.

  CREATE OBJECT event_handler.

  CASE  container.
  WHEN 'CCONTAINER'.
    SET HANDLER event_handler->handle_user_command FOR gref_alvgrid.
    SET HANDLER event_handler->on_link_click FOR gref_alvgrid.
    CALL METHOD gref_alvgrid->set_toolbar_interactive.
 when 'CCONTAINER_ALV'.
    SET HANDLER event_handler->handle_user_command FOR gref_alvgridd.
    "SET HANDLER event_handler->on_link_click FOR gref_alvgridd.
    CALL METHOD gref_alvgridd->set_toolbar_interactive.
 WHEN 'CCONTAINER01'.
    SET HANDLER event_handler->handle_user_command FOR gref_alvgrid101.
    SET HANDLER event_handler->handle_toolbar FOR gref_alvgrid101.

    SET HANDLER event_handler->on_link_click FOR gref_alvgrid101.
    CALL METHOD gref_alvgrid101->set_toolbar_interactive.
  WHEN 'CCONTAINER101D'.
    SET HANDLER event_handler->handle_user_command FOR gref_alvgrid101D.
    CALL METHOD gref_alvgrid101D->set_toolbar_interactive.
  WHEN OTHERS.
  ENDCASE..





ENDFORM.                    " DISPLAY_ALV
