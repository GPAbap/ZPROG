*&---------------------------------------------------------------------*
*& Include ztm_re_rendcomve_top
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

TABLES: equz,
        equi,
        t370fld_t, " Clases de combustibles
        imptt,     " Punto de medida (Tabla)
        fleet,     " Datos Específicos de Vehículos
        imrg,      " Documentos de Medición
        eqkt.      " Textos Breves de Equipo

* Tablas Transparentes
TYPES : BEGIN OF rec,
          objnr1    LIKE equi-objnr,         " Número de objeto
          fleet_cat LIKE fleet-fleet_cat,     " Clase de vehículo
          fuel_pri  LIKE fleet-fuel_pri,      " combustible primario
          type_text TYPE fld_type_text,
          iwerk     LIKE equz-iwerk, " Centro de planificación
          ingrp     LIKE equz-ingrp, " Grupo planificador
          objnr     LIKE fleet-objnr,         " Número de objeto
          equnr     LIKE equi-equnr,
          eqktx     TYPE ktx01,
          mpobj     LIKE imptt-mpobj,         " Número de objeto del objeto de p
          point_d   LIKE imptt-point,             " Punto de medida
          point_f   LIKE imptt-point,             " Punto de medida
          point_t   LIKE imptt-point,             " Punto de medida
        END OF rec,

        BEGIN OF tab,
          iwerk     LIKE equz-iwerk, " Centro de planificación
          ingrp     LIKE equz-ingrp, " Grupo planificador
          fleet_cat LIKE fleet-fleet_cat,
          fuel_pri  LIKE fleet-fuel_pri,
          type_text TYPE fld_type_text,
          fueltx    type ktx01, "union de tipo comb mas texto
          equnr     LIKE equi-equnr,
          eqktx     TYPE ktx01,
          equtx     TYPE ktx01, "union de equipo y descripcion
          objnr     LIKE fleet-objnr,
          mpobj     LIKE imptt-mpobj,
          idate     LIKE imrg-idate,     " Fecha de la medición
          itime     LIKE imrg-itime,     " Hora de la medición
          point_d   LIKE imptt-point,
          point_f   LIKE imptt-point,
          point_t   LIKE imptt-point,
          psort     LIKE imptt-psort,
          atinn     LIKE imptt-atinn,
          mdocm     LIKE imrg-mdocm,     " Documento de medición
          time       Type P DECIMALS 2,     " Diferencia de valor de contador en unidad
          fuel      Type P DECIMALS 2, "LIKE imrg-cdiff,     " Diferencia de valor de contador en unidad
          distance  Type P DECIMALS 2, "LIKE imrg-cdiff, " Diferencia de valor de contador en u
          rend      Type P DECIMALS 2, "Operación de rendimiento
        END OF tab.

 DATA et_rihimrg TYPE STANDARD TABLE OF rihimrg.

* Variables
DATA:
  bandera VALUE '0',
  rend    LIKE imrg-cdiff.

DATA: it_rec TYPE STANDARD TABLE OF rec,
      it_tab TYPE STANDARD TABLE OF tab.

*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

********para ALV
DATA: ti_header TYPE slis_t_listheader,
      st_header TYPE slis_listheader,
      ti_sort   TYPE slis_t_sortinfo_alv,
      st_sort   TYPE slis_sortinfo_alv,
      lf_layout TYPE slis_layout_alv.    "Manejar diseño de layout


SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS:
    iwerk_p  FOR equz-iwerk,
    ingrp_p  FOR equz-ingrp,
    fleetcap FOR fleet-fleet_cat,
    fuelprip FOR fleet-fuel_pri,
    equnr_p  FOR equi-equnr,
    idate_p  FOR imrg-idate OBLIGATORY.
SELECTION-SCREEN END OF BLOCK block1.
