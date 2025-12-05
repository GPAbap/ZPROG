*&---------------------------------------------------------------------*
*& Include          ZFI_CARGAPRECIOMATNR_CLS
*&---------------------------------------------------------------------*
CLASS lcl_excel_uploader DEFINITION.
  PUBLIC SECTION.
  DATA: header_rows_count TYPE I.
  DATA: max_rows          TYPE I.
  DATA: filename          TYPE localfile.
  DATA: initial_col       TYPE I.
  DATA: matnr_col(4)         TYPE C.
  METHODS:
  constructor.
  METHODS:
  upload CHANGING ct_data TYPE ANY TABLE.
  PRIVATE SECTION.
  DATA: lv_tot_components TYPE I.
  METHODS:
  do_upload
  IMPORTING
    iv_begin TYPE I
    iv_end   TYPE I
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
    DATA: lo_struct   TYPE REF TO cl_abap_structdescr,
          lo_table    TYPE REF TO cl_abap_tabledescr,
          lt_comp     TYPE cl_abap_structdescr=>component_table.

    lo_table ?= cl_abap_structdescr=>describe_by_data( ct_data ).
    lo_struct ?= lo_table->get_table_line_type( ).
    lt_comp    = lo_struct->get_components( ).
*
    lv_tot_components = LINES( lt_comp ).
*
    DATA: lv_empty TYPE flag,
          lv_begin TYPE I,
          lv_end   TYPE I.
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
    DATA: lv_tot_rows   TYPE I.
    DATA: lv_packet     TYPE I.
    DATA lv_matnr TYPE matnr.
    FIELD-SYMBOLS: <struc> TYPE ANY,
    <field> TYPE ANY.

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
            IF ls_exceldata-VALUE NE '' OR ls_exceldata-VALUE NE space OR ls_exceldata-VALUE IS NOT INITIAL.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT  = ls_exceldata-VALUE
              IMPORTING
                OUTPUT = lv_matnr.

              lv_matnr = lv_matnr+22(18). "Se recorta a 18 posiciones, dado a que el elemento de datos de matnr es de 40
              ls_exceldata-VALUE = lv_matnr.
            ENDIF.
          ENDIF.

          <field> = ls_exceldata-VALUE.
        CATCH cx_sy_conversion_no_number.
          "MESSAGE 'error de contenido numerico' TYPE 'S'.
          REPLACE ALL OCCURRENCES OF '$' IN ls_exceldata-VALUE WITH space.
          REPLACE ALL OCCURRENCES OF ',' IN ls_exceldata-VALUE WITH space.
          CONDENSE ls_exceldata-VALUE NO-GAPS.
          <field> = ls_exceldata-VALUE.
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
