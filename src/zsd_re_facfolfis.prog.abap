*&---------------------------------------------------------------------*
*& Report zsd_re_facfolfis
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsd_re_facfolfis.

include zsd_re_facfolfis_top.
include zsd_re_facfolfis_fun.

*&---------------------------------------------------------------------*
* PROGRAMA PRINCIPAL
*&---------------------------------------------------------------------*
 START-OF-SELECTION.
  fecha = fkdat_p+3(8).
  gjahr_p = fkdat_p+3(4).
* Subrutinas
  PERFORM seleccion.
  PERFORM detalles.
  perform create_fieldcat.
  PERFORM impresion.
