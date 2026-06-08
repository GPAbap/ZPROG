*&---------------------------------------------------------------------*
*& Include          ZMM_RE_PROVEEDOR_BLOQUEADO_TOP
*&---------------------------------------------------------------------*
TABLES: lfa1, lfb1, lfm1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_lifnr FOR lfa1-lifnr,
                  s_bukrs FOR lfb1-bukrs,
                  s_ekorg FOR lfm1-ekorg.

  PARAMETERS:
              p_cfi  AS CHECKBOX DEFAULT 'X',
              p_cmm  AS CHECKBOX DEFAULT 'X',
              p_buk  AS CHECKBOX DEFAULT 'X',
              p_eko  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b1.

"TEXT-001 = 'Filtros de proveedores bloqueados'.

TYPES: BEGIN OF ty_alv,
         sel        TYPE abap_bool,
         light      TYPE c LENGTH 1,
         lifnr      TYPE lifnr,
         name1      TYPE lfa1-name1,
         central_fi TYPE abap_bool,
         central_mm TYPE abap_bool,
         bukrs_blk  TYPE i,
         ekorg_blk  TYPE i,
         status     TYPE char10,
         message    TYPE string,
       END OF ty_alv.

DATA: gt_alv TYPE STANDARD TABLE OF ty_alv,
      gs_alv TYPE ty_alv.

DATA: go_grid TYPE REF TO cl_gui_alv_grid,
      go_cont TYPE REF TO cl_gui_custom_container.

CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.

    METHODS on_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS on_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_toolbar.
    APPEND VALUE #(
      function  = 'UNBLOCK'
      icon      = icon_unlocked
      quickinfo = 'Desbloquear seleccionados'
      text      = 'Desbloquear'
    ) TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD on_user_command.
    CASE e_ucomm.
      WHEN 'UNBLOCK'.
        PERFORM unblock_selected.
    ENDCASE.
  ENDMETHOD.

  METHOD on_double_click.
    READ TABLE gt_alv INTO gs_alv INDEX e_row-index.
    IF sy-subrc = 0 AND gs_alv-lifnr IS NOT INITIAL.
      SET PARAMETER ID 'LIF' FIELD gs_alv-lifnr.
      CALL TRANSACTION 'XK03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

DATA go_handler TYPE REF TO lcl_handler.
