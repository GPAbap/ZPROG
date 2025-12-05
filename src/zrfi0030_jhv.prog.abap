*&---------------------------------------------------------------------*
*& Report ZRFI0030_JHV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrfi0030_jhv."  NO STANDARD PAGE HEADING LINE-SIZE  230
"LINE-COUNT 65(0).

INCLUDE zrfi0030_jhv_top.
INCLUDE zrfi0030_jhv_fun.

*-----------------------------------------------------------------------
* PROGRAMA PRINCIPAL
*-----------------------------------------------------------------------
*TOP-OF-PAGE.
*WRITE: 05 'Fecha: ', sy-datum, sy-uname,
*50 'Relación de EGRESOS ',
*130 'Pagina: ', sy-pagno,
*147 'ZFI0030  '.
*ULINE.
*FORMAT COLOR 1 ON.
*WRITE:/5 'Fecha',
*16 'D. Pago',
*27 'Prov.',
*38 'Nombre Proveedor',
*90 'Importe Pagado',
*115 'D. Provisión',
*145 'Importe Pagado',
*163 'Referencia '.
*FORMAT COLOR OFF.
*ULINE.
************************************************************************
* PROGRAMA PRINCIPAL
************************************************************************
START-OF-SELECTION.
* Busco documentos de pago en cabecera de documentos BKPF

  PERFORM get_data.
  PERFORM fieldcat.
  PERFORM show_Alv.
