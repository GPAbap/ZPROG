*&---------------------------------------------------------------------*
*& Report ZMM_RETORNO_MATERIAL_PV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_retorno_material_pv.

INCLUDE zmm_retorno_material_pv_top.
INCLUDE zmm_retorno_material_pv_fun.


*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
**  PERFORM sel_file.

START-OF-SELECTION.

  gv_consulta = sy-datum." - 1.

  BREAK jhernandev.
  PERFORM get_datos.
  IF it_diferencias IS NOT INITIAL.
    PERFORM bapi_goodsmvt_create.
  ENDIF.
*  IF p_file IS NOT INITIAL.
*    PERFORM load_file.
*    perform get_datos_material.
*  ELSE.
*    MESSAGE 'Debe seleccionar un archivo...' TYPE 'I'.
*  ENDIF.
