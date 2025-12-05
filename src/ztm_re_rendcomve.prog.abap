*&---------------------------------------------------------------------*
*& Reporte Original:  ZTM_RE_RENDCOMVE                                                  *
*& Descripción: Relación de Rendimientos de combustible de vehículos   *
*&              Para Avícola e Ingenios   *
*&---------------------------------------------------------------------*
*& Grupo Pecuario San Antonio, S.A. de C.V.                            *
*& Fecha: 27 Marzo 2023                                         *
*& Autor: Jaime Hernández Velásquez                      *

*& Actualización: 16 Octubre 2025
*& Autor: Jaime Hernández Velásquez
*&---------------------------------------------------------------------*

REPORT ztm_re_rendcomve.

include ztm_re_rendcomve_top.
include ztm_re_rendcomve_fun.


START-OF-SELECTION.

      PERFORM get_data.
      PERFORM create_fieldcat.
      PERFORM show_alv.

END-OF-SELECTION.
