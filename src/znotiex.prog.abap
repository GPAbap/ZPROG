*&---------------------------------------------------------------------*
*& Report znotiex
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT znotiex.

INCLUDE znotiex_top.
INCLUDE znotiex_fun.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  REFRESH: it_tabemp.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'Seleccione ruta/nombre Archivo'
      default_filename  = '*.xlsx'
      initial_directory = 'C:\'
      multiselection    = ' ' "No multiple selection
    CHANGING
      file_table        = it_tabemp
      rc                = gd_subrcemp.
  read table it_tabemp into data(wa) index 1.
  p_file = wa-filename.
START-OF-SELECTION.

  PERFORM get_ordenes.
  IF it_layout IS NOT INITIAL.
    PERFORM download_layout.
  ENDIF.
