*&---------------------------------------------------------------------*
*& Report zmm_crea_pedidos_tras
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_crea_pedidos_tras.

include zmm_crea_pedidos_tras_top.
include zmm_crea_pedidos_tras_fn.

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

  START-OF-SELECTION.

  PERFORM load_excel_to_table USING file_nm
                              CHANGING vl_ok.
 if vl_ok eq abap_true.
    PERFORM calcular_inventario.
    if it_inventario is not INITIAL.
       PERFORM set_carga_stock.
       perform set_crea_pedidos_trasl.
       PERFORM get_entregas.
    ENDIF.

 PERFORM show_results.

 ENDIF.
