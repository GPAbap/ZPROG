*&---------------------------------------------------------------------*
*& Report ZBIPM001
*&---------------------------------------------------------------------*
*& Carga masiva de consumos de combustible
*& programa Z para poder realizar cargas masivas de litros de combustible
*& consumidos y kilometraje actual de las unidades de avícola
*& Jaime Hernández Velásquez
*& 04/07/2024
*&---------------------------------------------------------------------*
REPORT zbipm001.

INCLUDE zbipm001_top.
INCLUDE zbipm001_fn.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_format.

  PERFORM fill_types.
  PERFORM f4_function.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM sel_file.

START-OF-SELECTION.

  IF p_file IS NOT INITIAL.
    PERFORM load_file.

  else.
  MESSAGE 'Debe seleccionar un archivo...' type 'I'.
  ENDIF.
