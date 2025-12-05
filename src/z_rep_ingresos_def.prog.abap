*&---------------------------------------------------------------------*
*&  Include           Z_REP_INGRESOS_DEFV2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           Z_REP_INGRESOS_DEF
*&---------------------------------------------------------------------*


CLASS lcl_appl DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: get_instance RETURNING value(re_appl) TYPE REF TO lcl_appl.
    CLASS-METHODS: get_data RETURNING VALUE(re_t_data) TYPE ZINGRESOS_OUTPUT_T2.

    CLASS-METHODS: save_concil  IMPORTING im_t_data TYPE ZINGRESOS_OUTPUT_T2 ,
                   get_rep_iva  RETURNING VALUE(re_t_data) TYPE ZING_REPS_OUTPUT_T,
                   get_rep_ISR  RETURNING VALUE(re_t_data) TYPE ZING_REPS_OUTPUT_T,
                   get_reS_ING  RETURNING VALUE(re_t_data) TYPE ZING_REPS_OUTPUT_T.



  PRIVATE SECTION.
    CLASS-DATA: cd_o_appl TYPE REF TO lcl_appl.


ENDCLASS.

CLASS lcl_screen DEFINITION INHERITING FROM cl_bus_abstract_main_screen.

  PUBLIC SECTION.
    CLASS-DATA: mt_out TYPE STANDARD TABLE OF ZINGRE_concil2.
    CLASS-DATA: mt_out_iva TYPE STANDARD TABLE OF ZING_REPS_OUTPUT.
    CLASS-DATA: mt_out_ISR TYPE STANDARD TABLE OF ZING_REPS_OUTPUT.
    CLASS-DATA: mt_out_RESING TYPE STANDARD TABLE OF ZING_REPS_OUTPUT.
    CLASS-DATA: cd_appl TYPE REF TO lcl_appl.
    METHODS pbo_begin REDEFINITION.
    METHODS pai_end REDEFINITION.
    METHODS pai_begin REDEFINITION.
    METHODS pbo_end REDEFINITION.
    METHODS show_new IMPORTING im_t_data TYPE ZINGRESOS_OUTPUT_T2.
    METHODS show_new_IVA IMPORTING im_t_data TYPE ZING_REPS_OUTPUT_T .
    METHODS show_REP_ISR IMPORTING im_t_data TYPE ZING_REPS_OUTPUT_T .
    METHODS show_RES_ING IMPORTING im_t_data TYPE ZING_REPS_OUTPUT_T .
*    METHODS save_concil IMPORTING im_t_data TYPE ZINGRESOS_OUTPUT_T .


*    CONSTANTS: c_dynnr TYPE sy-dynnr VALUE '2000'.
  PROTECTED SECTION.

    CLASS-DATA: cd_o_alv TYPE REF TO cl_gui_alv_grid,
                cd_o_con TYPE REF TO cl_gui_custom_container.
*                G_HANDLER TYPE REF TO LCL_EVENT_HANDLER. "handler
    METHODS call_screen REDEFINITION. "Implementierung der Methode Call_Screen, geerbt von cl_bus_abstract_main_screen
    METHODS call_screen_starting_at REDEFINITION.
    METHODS handle_pai FOR EVENT process_after_input OF cl_bus_abstract_main_screen IMPORTING iv_function_code.
*    CLASS-METHODS: top_of_page FOR EVENT top_of_page OF  cl_gui_alv_grid.

  PRIVATE SECTION.

    METHODS: create_alv IMPORTING im_t_data TYPE ZINGRESOS_OUTPUT_T2 ,
             create_alv_IVA IMPORTING im_t_data TYPE ZING_REPS_OUTPUT_T ,
               create_alv_ISR IMPORTING im_t_data TYPE ZING_REPS_OUTPUT_T ,
               create_alv_RES_ING IMPORTING im_t_data TYPE ZING_REPS_OUTPUT_T ,
             create_fcat RETURNING VALUE(re_t_fcat) TYPE lvc_t_fcat,
             create_fcat_riva RETURNING VALUE(re_t_fcat) TYPE lvc_t_fcat,
             create_fcat_rISR RETURNING VALUE(re_t_fcat) TYPE lvc_t_fcat,
             create_fcat_RES_ING RETURNING VALUE(re_t_fcat) TYPE lvc_t_fcat.



ENDCLASS.


CLASS LCL_EVENT_HANDLER DEFINITION .
  PUBLIC SECTION .
  METHODS:
*Event Handler for Top of page
      TOP_OF_PAGE FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID IMPORTING E_DYNDOC_ID.
ENDCLASS.             "#lcl_event_handler DEFINITION

CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD TOP_OF_PAGE.
* Top-of-page event
*    PERFORM EVENT_TOP_OF_PAGE USING E_DYNDOC_ID.

    DATA : DL_TEXT(255) TYPE C.
  "#Text
    CALL METHOD e_DYNDOC_ID->ADD_TEXT
     EXPORTING    TEXT = 'Flight Details'
       SAP_STYLE = CL_DD_AREA=>HEADING
       SAP_FONTSIZE = CL_DD_AREA=>LARGE
       SAP_COLOR = CL_DD_AREA=>LIST_HEADING_INT.
  CALL METHOD e_DYNDOC_ID->ADD_GAP
  EXPORTING     WIDTH = 200.

"  SAP_COLOR = CL_DD_AREA=>LIST_NEGATIVE_INV.   * Add new-line   CALL METHOD DG_DYNDOC_ID->NEW_LINE.
  ENDMETHOD.                            "#top_of_page
ENDCLASS.      " #LCL_EVENT_HANDLER
