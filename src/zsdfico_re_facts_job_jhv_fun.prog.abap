*&---------------------------------------------------------------------*
*& Include          ZSDFICO_RE_FACTS_JOB_JHV_FUN
*&---------------------------------------------------------------------*

FORM show_data_ida.
* VBELN, FKDAT, VKORG,
*           VTWEG,
*BUCHK
*CONTAB_JOB
*FECHA_CONTAB
*HORA_CONTAB
*LOG1
*Check DB Capabilities
  CHECK cl_salv_gui_table_ida=>db_capabilities( )->is_table_supported( iv_ddic_table_name = 'ZSDFI_TT_FACTURA').
*Create IDA
  DATA(o_ida) = cl_salv_gui_table_ida=>create( iv_table_name = 'ZSDFI_TT_FACTURA' ).

*Set Maximum Rows Recommended

  IF cl_salv_gui_table_ida=>db_capabilities( )->is_max_rows_recommended( ).

    o_ida->set_maximum_number_of_rows(  iv_number_of_rows = 2000 ).

  ENDIF.

* Filter
data(o_sel) = new cl_salv_range_tab_collector( ).
o_sel->add_ranges_for_name( iv_name   = 'VKORG' it_ranges = p_vkorg[] ).
o_sel->add_ranges_for_name( iv_name   = 'VTWEG' it_ranges = p_vtweg[] ).
o_sel->add_ranges_for_name( iv_name   = 'FKDAT' it_ranges = p_fkdat[] ).
o_sel->add_ranges_for_name( iv_name   = 'FECHA_CONTAB' it_ranges = p_fconta[] ).


"get name and ranges
o_sel->get_collected_ranges( IMPORTING et_named_ranges = DATA(lt_named_ranges) ).

"set selected ranges to alv.
o_ida->set_select_options(
  it_ranges    = lt_named_ranges ).

* Display
  o_ida->fullscreen( )->display( ).

ENDFORM.
