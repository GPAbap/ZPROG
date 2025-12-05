************************************************************************
* Programa             : SAPMZCOINV                                    *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Picking                                       *
* Fecha Creación       : 04.07.2017                                    *
* Consultor Funcional  :                                               *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                    LOG DE MODIFICACIONES                             *
*----------------------------------------------------------------------*
* Descripción          :                                               *
* Funcional            :                                               *
* Desarrollador        :                                               *
* Fecha Modificación   :                                               *
*----------------------------------------------------------------------*

PROGRAM  sapmzcoinv.

*======================================================================*
INCLUDE <icon>.

*======================================================================*
* Tipos
TYPE-POOLS:
abap.

*======================================================================*
* Tipos

TYPES:BEGIN OF ty_head,
  handle   TYPE huinv_hdr-handle,
  huinv_nr TYPE huinv_hdr-huinv_nr,
  werks    TYPE huinv_hdr-werks,
  lgort    TYPE huinv_hdr-lgort,
  counted  TYPE huinv_hdr-counted,
  posted   TYPE huinv_hdr-posted.
TYPES:  END OF ty_head.

TYPES:BEGIN OF ty_item,
  item_nr    TYPE huinv_item-item_nr,
  venum      TYPE huinv_item-venum,
  matnr      TYPE huinv_item-matnr,
  charg      TYPE huinv_item-charg,
  exidv      TYPE huinv_item-exidv,
  vemng      TYPE huinv_item-vemng,
  meins      TYPE huinv_item-meins,
  huexist    TYPE huinv_item-huexist,
  huexistnot TYPE huinv_item-huexistnot,
  top_exidv  TYPE huinv_item-top_exidv,
  mark       TYPE c LENGTH 1.
TYPES:  END OF ty_item.

*======================================================================*
* Tablas internas
DATA:
  tg_bdc TYPE STANDARD TABLE OF bdcdata,
  tg_msj TYPE STANDARD TABLE OF bdcmsgcoll.


DATA:
  tg_item       TYPE STANDARD TABLE OF ty_item,
  tg_huinv_item TYPE STANDARD TABLE OF huinv_item.

DATA:
  tg_loghandle  TYPE bal_t_logh,
  tg_lognumbers TYPE bal_t_lgnm.

*======================================================================*
* Estructuras
DATA:
  sg_msj  TYPE bdcmsgcoll.

DATA:
  sg_head TYPE ty_head,
  sg_item TYPE ty_item.

*======================================================================*
* Constantes


*======================================================================*
* Variables globales
DATA:
  vg_huinv_nr  TYPE huinv_hdr-huinv_nr,
  vg_top_exidv TYPE huinv_item-top_exidv.

DATA:
  vg_ok_code TYPE sy-ucomm,
  vg_dynnr   TYPE sy-dynnr.

DATA:
  vg_log            TYPE bal_s_log,
  vg_handler        TYPE balloghndl.

DATA:
  vg_msg1   TYPE c LENGTH 20,
  vg_msg2   TYPE c LENGTH 20,
  vg_msg3   TYPE c LENGTH 20,
  vg_msg4   TYPE c LENGTH 20,
  vg_msg5   TYPE c LENGTH 20,
  vg_msg6   TYPE c LENGTH 20,
  vg_msg7   TYPE c LENGTH 20,
  vg_msg8   TYPE c LENGTH 20,
  vg_msg9   TYPE c LENGTH 20,
  vg_msg10  TYPE c LENGTH 20.

DATA:
  vg_line    TYPE i,
  vg_lines   TYPE i,
  vg_index   TYPE i.

DATA:
  vg_error TYPE c LENGTH 1.

* ===================================================================== *
