*&---------------------------------------------------------------------*
*& Include          ZMM_APP_PRINT_RESB_TOP
*&---------------------------------------------------------------------*

************************************************************************
* ESPECIFICACIONES DE ENTRADA
************************************************************************
TABLES:
  iflotx,         " Ubic. técnica
  eqkt,          " texto equipos
  mard,          " centro/almacén
  iloa,          " Emplazamiento e imputación para objeto-MT
  afih,          " Cabecera de orden de mantenimiento
  aufk,          " Maestro de órdenes
  t001l,         " Almacenes
  t001,          " Sociedades
  mbew,          " Valoración de material
  makt,          " Textos breves de material
  resb,          " Reserva/Necesidades secundarias
  rkpf.          " Cabecera doc.reserva
DATA:
  params      LIKE pri_params,
  valid       TYPE c,
  estatus(11) TYPE c,
  total       LIKE mbew-verpr,
  importe     LIKE mbew-verpr.
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
    rsnum_p LIKE resb-rsnum OBLIGATORY.      " NUm. de Reserva
  SELECT-OPTIONS:
      rspos_p FOR resb-rspos.
SELECTION-SCREEN END OF BLOCK block1.

types: BEGIN OF st_salida,
       ktext LIKE aufk-ktext,
       butxt LIKE t001-butxt,
       rsnum LIKE rkpf-rsnum,
       bukrs like aufk-bukrs,
       rsdat LIKE rkpf-rsdat,
       kostl LIKE rkpf-kostl,
       aufnr LIKE rkpf-aufnr,
       vaplz LIKE aufk-vaplz,
       ernam LIKE aufk-ernam,
       aenam LIKE aufk-aenam,
       equnr LIKE afih-equnr,
       eqktx LIKE eqkt-eqktx,
       tplnr LIKE iloa-tplnr,
       pltxt LIKE  iflotx-pltxt,
       matnr LIKE resb-matnr,
       rspos LIKE resb-rspos,
       bdmng LIKE resb-bdmng,
       enmng LIKE resb-enmng,
       meins LIKE resb-meins,
       wempf LIKE resb-wempf,
       sgtxt LIKE resb-sgtxt,
       lgpbe LIKE mard-lgpbe,
       maktx LIKE makt-maktx,
       verpr LIKE mbew-verpr,
       pendi LIKE resb-enmng,
       estatus(15) type c,
  END OF st_salida.

  data it_salida TYPE STANDARD TABLE OF st_salida.
  DATA band.
