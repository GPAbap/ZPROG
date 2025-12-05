*&---------------------------------------------------------------------*
*& Report ZSD_RE_SAN2SAP
*&---------------------------------------------------------------------*
*& 11/01/2023
*& Concentrado de Reportes de Pedidos creados desde
*&archivos CVS de SAN para SAP Hana
*& Desarrollador: Jaime Hernandez Velasquez
*& Pedido creados
*& Pedidos no creados
*&---------------------------------------------------------------------*
REPORT ZSD_RE_SAN2SAP.

INCLUDE ZSD_RE_SAN2SAP_TOP.
INCLUDE ZSD_RE_SAN2SAP_SS.
INCLUDE ZSD_RE_SAN2SAP_FUN.
INCLUDE ZSD_RE_SAN2SAP_ALV.
INCLUDE ZSD_RE_SAN2SAP_HIST.

at selection-screen.

perform check_autorizacion.


START-OF-SELECTION. "......
"--------- seleccion de radio buttons
IF p_creado EQ 'X'. "alv Jerarquico
  PERFORM tickets_creados. "
  PERFORM create_fieldcat. "
  PERFORM layout_build. "
  PERFORM show_alv_HSL. "
ELSEIF p_nocrea EQ 'X'. "Alv Normal
  PERFORM tickets_nocreados. "
  PERFORM create_fieldcat_nc. "
  PERFORM layout_build. "
  PERFORM show_alv. "

ENDIF.
*****************************************Eliminar el Transporte que se quedo en Calidad SPDK906732
