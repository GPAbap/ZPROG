*&---------------------------------------------------------------------*
*& Report  ZMMR_CBPEDIDOS
*&
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


INCLUDE ZMMR_CBPEDIDOSN1_TOPV2.
*INCLUDE ZMMR_CBPEDIDOSN1_TOP.
*INCLUDE zmmr_cbpedidosntop.       " global Data
INCLUDE ZMMR_CBPEDIDOSN1_F01V2.
*INCLUDE ZMMR_CBPEDIDOSN1_F01.
*INCLUDE zmmr_cbpedidosnf01.       " FORM-Routines

INITIALIZATION.
  PERFORM f_fill_ranges.

AT SELECTION-SCREEN ON s_bstyp.
  PERFORM f_validate_type.

START-OF-SELECTION.
  IF s_ebeln IS INITIAL AND s_ekorg IS INITIAL AND s_ekgrp IS INITIAL
    AND s_lifnr IS INITIAL AND s_reswk IS INITIAL AND s_bedat IS INITIAL.
*  AND s_matnr IS INITIAL AND s_matkl IS INITIAL.
    MESSAGE s689(m7).
    EXIT.
  ENDIF.

  PERFORM get_pucharse_order.
