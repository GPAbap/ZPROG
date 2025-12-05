*&---------------------------------------------------------------------*
*& Include zpm_re_valgasemi_top
*&---------------------------------------------------------------------*
TABLES: zvale, equz,zgas,eqkt.

TYPE-POOLS: slis.

*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

********para ALV
DATA: ti_header TYPE slis_t_listheader,
      st_header TYPE slis_listheader,
      lf_layout TYPE slis_layout_alv.    "Manejar diseño de layout

TYPES: BEGIN OF st_vales,
         bukrs LIKE zvale-bukrs,    " Sociedad
         ingrp LIKE equz-ingrp,     " Grupo Planificador
         zcgas LIKE zvale-zcgas,    " Gasolinera
         zdes  LIKE  zgas-zdes,    " descripcion
         equnr LIKE equz-equnr,      " equipo
         eqktx LIKE eqkt-eqktx,     "descripcion
         znval LIKE zvale-znval,    " Número de Vale
         zfech LIKE zvale-zfech,    " Fecha de emisión de vale
         zhras TYPE zhras,          " Hora de emisión
         mdocm TYPE imrc_mdocm,     " Doc Medición
       END OF st_vales.

DATA it_vales TYPE STANDARD TABLE OF st_vales.



* Parámetros de Selección
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
    bukrs_p LIKE zvale-bukrs OBLIGATORY.
  SELECT-OPTIONS:
    ingrp_p FOR equz-ingrp,
    zfech_p FOR zvale-zfech.
SELECTION-SCREEN END OF BLOCK block1.
