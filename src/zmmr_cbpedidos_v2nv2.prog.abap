*************************************************************************
*  Nombre de Programa: SAPMZ_MM_PEDIDO
*
*  Autor       : Gilberto Maciel Urrutia   (SISCOMV)
*
*  Fecha       : 28/11/2013
*
*  Descripción : Reporte de pedidos para imprimir formato con CB ó enviarlos
*                por correo electrónico
*
*  Transacción : ZMM_CB020
*
*  Orden de Transporte: DESK924907
*&---------------------------------------------------------------------*
REPORT zmmr_cbpedidos_v2nv2.

INCLUDE ZMMR_CBPEDIDOSTOPV2NV2.
*INCLUDE zmmr_cbpedidostopv2n.
*INCLUDE zmmr_cbpedidostopv2                       .    " global Data
INCLUDE ZMMR_CBPEDIDOSF01V2NV2.
*INCLUDE zmmr_cbpedidosf01v2n.
*INCLUDE zmmr_cbpedidosf01v2                       .  " FORM-Routines

INITIALIZATION.
  PERFORM f_fill_ranges.

AT SELECTION-SCREEN ON s_bstyp.
  PERFORM f_validate_type.

START-OF-SELECTION.

  IF s_ebeln IS INITIAL AND s_ekorg IS INITIAL AND s_ekgrp IS INITIAL
    AND s_lifnr IS INITIAL AND s_reswk IS INITIAL AND s_bedat IS INITIAL.
    MESSAGE s689(m7).
    EXIT.
  ENDIF.

  PERFORM get_pucharse_order.
