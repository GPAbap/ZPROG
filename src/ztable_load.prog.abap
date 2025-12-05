*&---------------------------------------------------------------------*
*& Report  ZTABLE_LOAD                                                 *
*&                                                                     *
*&---------------------------------------------------------------------**
**Este programa carga los datos en cualquier Tabla especificados en la
* pantalla de selección.
* El Archivo debe ser txt, delimitado por TAB y el orden de los campos
* en el archivo plano debe
* corresponder con los campos de la tabla.
*- Valores en pesos sin puntos ni comas
*- Fechas sin puntos
*
*-Considera 3 lineas de cabecera para documentación
*&---------------------------------------------------------------------*

REPORT  ztable_load.

INCLUDE ZTABLE_LOAD_top.
INCLUDE ZTABLE_LOAD_fun.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
*     PROGRAM_NAME  = SYST-REPID
*     DYNPRO_NUMBER = SYST-DYNNR
*     FIELD_NAME    = ' '
      static        = 'X'
*     MASK          = ' '
    CHANGING
      file_name     = p_file
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


START-OF-SELECTION.

  PERFORM load_xls USING p_file
                   CHANGING p_ok.

  IF p_ok EQ abap_true.
     PERFORM update_cfdi.
  ENDIF.
