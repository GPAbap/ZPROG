*&---------------------------------------------------------------------*
*& Report ZPP_BOM_MASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPP_BOM_MASS.
INCLUDE ZPP_BOM_MASS_TOP.
INCLUDE ZPP_BOM_MASS_FN.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

PERFORM sub_file_f4.


START-OF-SELECTION.

PERFORM f_procesa_tabla.
PERFORM create_fieldcat.
PERFORM layout_build.
PERFORM show_alv_hsl.
