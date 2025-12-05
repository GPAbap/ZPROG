*----------------------------------------------------------------------*
***INCLUDE ZFI_REP_COSTOS_PROD_PBO.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR '100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0100 OUTPUT.
  IF go_container IS INITIAL.
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CONTAINER'.
    CREATE OBJECT go_alv_grid
      EXPORTING
        i_parent = go_container.
*    CREATE OBJECT r_handler.
*    SET HANDLER r_handler->on_double_click FOR go_alv_grid.
    PERFORM datos_alv.


    ls_vari-variant = p_vari.

*    CALL METHOD r_alv->get_layout
*      RECEIVING
*        value = r_lay.
*    CALL METHOD r_lay->set_key
*      EXPORTING
*        value = Set_key.
*
*    CALL METHOD r_lay->set_save_restriction
*      EXPORTING
*        value = if_salv_c_layout=>restrict_none.
*
*
*    CALL METHOD r_lay->set_initial_layout
*      EXPORTING
*        value = set_lay.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
*       i_structure_name   = 'zreporte_xml_cp'
        i_buffer_active    = ' '
        i_bypassing_buffer = 'X'
        is_layout          = r_layout
        is_variant         = ls_vari
        i_save             = 'A'
      CHANGING
        it_outtab          = it_dis
        it_fieldcatalog    = it_fieldcat.
  ELSE.
    CALL METHOD go_alv_grid->refresh_table_display.
  ENDIF.
ENDMODULE.
