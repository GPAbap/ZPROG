*&---------------------------------------------------------------------*
*& Report ZCO_KBK6_MASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_kbk6_mass.

INCLUDE ZCO_KBK6_MASS_top.
INCLUDE ZCO_KBK6_MASS_fun.
INCLUDE ZCO_KBK6_MASS_bin.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR file_nm.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
*     PROGRAM_NAME  = SYST-REPID
*     DYNPRO_NUMBER = SYST-DYNNR
*     FIELD_NAME    = ' '
      static        = 'X'
*     MASK          = ' '
    CHANGING
      file_name     = file_nm
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  IF rb_plan eq ''.
    LOOP AT SCREEN.
        IF screen-group4 eq '003'.
            screen-output = 0.
            screen-invisible = 1.
            screen-active = 0.
            MODIFY SCREEN.
        ENDIF.
    ENDLOOP.
   ELSE.
      LOOP AT SCREEN.
        IF screen-group4 eq '003'.
            screen-output = 1.
            screen-invisible = 0.
            screen-active = 1.
            MODIFY SCREEN.
        ENDIF.
    ENDLOOP.
  ENDIF.


START-OF-SELECTION.

  REFRESH it_tab[]. CLEAR wa_tabla.

  file = file_nm.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = file
      i_begin_col             = '1'
      i_begin_row             = '1'
      i_end_col               = '10'
      i_end_row               = '9999'
    TABLES
      intern                  = it_tab
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT it_tab INTO DATA(wa_tab).
    IF wa_tab-Row NE '001'.

      CASE wa_tab-col.
        WHEN '001'.
          wa_tabla-periodoi = wa_tab-value.
        WHEN '002'.
          wa_tabla-periodof = wa_tab-value.
        WHEN '003'.
          wa_tabla-ejercicio = wa_tab-value.
        WHEN '004'.
          wa_tabla-ceco = wa_tab-value.
        WHEN '005'.
          wa_tabla-actividad = wa_tab-value.
        WHEN '006'.
          wa_tabla-importe = wa_tab-value.
      ENDCASE.

      AT END OF row.

        APPEND wa_tabla TO it_tabla.
        CLEAR wa_tabla.

      ENDAT.

    ENDIF.
  ENDLOOP.

  IF it_tabla[] IS NOT INITIAL.
    PERFORM exec_bi.
    MESSAGE 'Terminado' TYPE 'S'.
  ENDIF.

*PERFORM get_orders.
*
*IF it_ordenes[] IS INITIAL.
*  MESSAGE 'Archivo no cargado o vacio' TYPE 'S' DISPLAY LIKE 'E'.
*ELSE.
*  PERFORM exec_bi.


  "PERFORM create_fieldcat.
  "PERFORM show_alv.
  "ENDIF.
