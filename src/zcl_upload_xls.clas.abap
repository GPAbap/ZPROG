class ZCL_UPLOAD_XLS definition
  public
  final
  create public .

public section.

  data HEADER_ROWS_COUNT type I .
  data MAX_ROWS type I .
  data FILENAME type LOCALFILE .
  data INITIAL_COL type I .
  data TIPO_FORM type C .

  methods CONSTRUCTOR .
  methods UPLOAD
    changing
      !CT_DATA type ANY TABLE .
protected section.
private section.

  data LV_TOT_COMPONENTS type I .

  methods DO_UPLOAD
    importing
      !IV_BEGIN type I
      !IV_END type I
    exporting
      !RV_EMPTY type FLAG
    changing
      !CT_DATA type STANDARD TABLE .
ENDCLASS.



CLASS ZCL_UPLOAD_XLS IMPLEMENTATION.


METHOD constructor.
    max_rows = 200000.
    initial_col = 1.
    tipo_form = 'A'.
  ENDMETHOD.                    "constructor


METHOD do_upload.

    DATA: li_exceldata  TYPE STANDARD TABLE OF zalsmex_tabline1.
    DATA: ls_exceldata  LIKE LINE OF li_exceldata.
    DATA: lv_tot_rows   TYPE i.
    DATA: lv_packet     TYPE i.

    FIELD-SYMBOLS: <struc> TYPE any,
                   <field> TYPE any.

*   Upload this packet
    CALL FUNCTION 'ZALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = filename
        i_begin_col             = initial_col
        i_begin_row             = iv_begin
        i_end_col               = lv_tot_components
        i_end_row               = iv_end
        sheets                  = 1
      TABLES
        it_data                  = li_exceldata
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
      AT NEW p_rows.
        APPEND INITIAL LINE TO ct_data ASSIGNING <struc>.
      ENDAT.

      " component and its value
      ASSIGN COMPONENT ls_exceldata-p_cols OF STRUCTURE <struc> TO <field>.



      FIND ALL OCCURRENCES OF ',' IN ls_exceldata-value MATCH COUNT sy-subrc.
      IF sy-subrc EQ 0.
        REPLACE '$' WITH space INTO ls_exceldata-value.
        CONDENSE ls_exceldata-value NO-GAPS.
      ELSE.
        FIND ALL OCCURRENCES OF ',' IN ls_exceldata-value MATCH COUNT sy-subrc.
        IF sy-subrc EQ 0.
          REPLACE '$' WITH space INTO ls_exceldata-value.
          CONDENSE ls_exceldata-value NO-GAPS.
        ENDIF.
      ENDIF.

      FIND ALL OCCURRENCES OF ',' IN ls_exceldata-value MATCH COUNT sy-subrc.
      IF sy-subrc EQ 0.
        REPLACE ALL OCCURRENCES OF ',' IN ls_exceldata-value WITH space .
        CONDENSE ls_exceldata-value NO-GAPS.
      ELSE.
        REPLACE '$' WITH space INTO ls_exceldata-value.
        IF sy-subrc EQ 0.
          REPLACE '$' WITH space INTO ls_exceldata-value.
          CONDENSE ls_exceldata-value NO-GAPS.
        ENDIF.
      ENDIF.
      <field> = ls_exceldata-value.
      " add the row count
      AT END OF p_rows.
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
ENDCLASS.
