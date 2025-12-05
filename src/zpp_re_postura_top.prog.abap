*&---------------------------------------------------------------------*
*& Include          ZCONS_POST_TOP
*&---------------------------------------------------------------------*

TABLES: mseg, "Segmento doc.material
        mara, "Datos generales material
        makt, "Texto breve de material
        t009b, "Periodo contable
        t157e. "Motivo del movimiento


*
TYPE-POOLS: slis.

TYPES: BEGIN OF te_mseg,
         werks      LIKE mseg-werks, " Centro
         lgort      LIKE mseg-lgort, "Almacén
         mblnr      LIKE mseg-mblnr, " Número de documento de material
         mjahr      LIKE mseg-mjahr, "Ejercicio del documento de material
         zeile      LIKE mseg-zeile, "Posición en documento de material
         aufnr      LIKE mseg-aufnr, "Número de orden************
         matnr      LIKE mseg-matnr, " Número de material
         maktx      LIKE makt-maktx, "Texto breve de material
         grund      LIKE t157e-grund, "Motivo del movimiento
         grtxt      LIKE t157e-grtxt, " Motivo del movimiento (Texto)********
         bwart      LIKE mseg-bwart, " Clase de movimiento (gestión stocks)
         shkzg      LIKE mseg-shkzg, "Indicador debe/haber
         gjahr      LIKE mseg-gjahr, "Ejercicio
         poper(2)   type c,
         bukrs      LIKE mseg-bukrs, " Sociedad
         prctr      LIKE mseg-prctr, "Centro de beneficio
         sakto      LIKE mseg-sakto, "Número de la cuenta de mayor***********
         pprctr     LIKE mseg-pprctr, "Centro de beneficio interlocutor
         lfbnr      LIKE mseg-lfbnr, "Número de documento de un doc.de referencia**********
         cputm_mkpf LIKE mseg-cputm_mkpf, "HORA DE ENTRADA
         budat_mkpf LIKE mseg-budat_mkpf, "Fecha de contabilización en el documento
         cpudt_mkpf LIKE mseg-cpudt_mkpf, "Día del registro del documento contable
         dmbtr      LIKE mseg-dmbtr, "Importe en moneda local
         waers      LIKE mseg-waers, "Clave de moneda
         menge      LIKE mseg-menge, "Cantidad
         meins      LIKE mseg-meins, "Unidad de medida base
         zmatnr     type matnr, "z material de datos postura/crianza
       END OF te_mseg.

DATA: gt_mseg TYPE STANDARD TABLE OF te_mseg WITH HEADER LINE.


DATA: wa_fieldcat TYPE slis_fieldcat_alv,
      gt_layout   TYPE slis_layout_alv.

DATA:gt_fieldcat TYPE STANDARD TABLE OF slis_fieldcat_alv.

data flag.

SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:soc     FOR mseg-bukrs OBLIGATORY, " Sociedad
                 mat     FOR mseg-matnr  VISIBLE LENGTH 7," Material
                 ejer    FOR mseg-gjahr OBLIGATORY. "Ejercicio
*  PARAMETERS:    ejer(4) TYPE n OBLIGATORY."ejercicio
*                 peri    TYPE t009b-poper OBLIGATORY." ," periodo
  SELECT-OPTIONS: peri    FOR t009b-poper OBLIGATORY," ," periodo
                  alma    FOR mseg-umlgo  , "Almacen
                  cen     FOR mseg-werks  , "Centros
                  lote    FOR mseg-charg  , "Lote
                  tipo    FOR mara-mtart   VISIBLE LENGTH 4, "Tipo de Material
                  cla_mov FOR mseg-bwart  . "Clase de movimiento
SELECTION-SCREEN END OF BLOCK a.
