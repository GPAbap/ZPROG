************************************************************************
* Programa             : SAPMZCPED                                     *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Pedido automático                             *
* Fecha Creación       : 04.11.2017                                    *
* Consultor Funcional  :                                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           MZCPEDF01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                    LOG DE MODIFICACIONES                             *
*----------------------------------------------------------------------*
* Descripción          :                                               *
* Funcional            :                                               *
* Desarrollador        :                                               *
* Fecha Modificación   :                                               *
*----------------------------------------------------------------------*
PROGRAM  sapmzcped.

*======================================================================*
INCLUDE <icon>.

*======================================================================*
* Tipos
TYPE-POOLS:
abap.

*======================================================================*
* Tipos


TYPES:BEGIN OF ty_vepo,
  venum  TYPE vekp-venum,
  exidv  TYPE vekp-exidv,
  vhilm  TYPE vekp-vhilm,
  unvel  TYPE vepo-unvel,
  matnr  TYPE vepo-matnr,
  matnr1 TYPE vepo-matnr,
  vemng  TYPE vepo-vemng,
  charg  TYPE vepo-charg,
  venum2 TYPE vekp-venum,
  exidv2 TYPE vekp-exidv,
  vhilm2 TYPE vekp-vhilm,
  vhart  TYPE vekp-vhart,
  ntgew  TYPE vekp-ntgew,
  werks  TYPE lips-werks,
  lgort  TYPE lips-lgort,
  status TYPE vekp-status,
  uevel  TYPE vekp-uevel.
TYPES:  END OF ty_vepo.

TYPES: BEGIN OF ty_vepo_pallet,
  venum TYPE vepo-venum,
  unvel TYPE vepo-unvel,
  vemng TYPE vepo-vemng,
  matnr TYPE vepo-matnr,
  charg TYPE vepo-charg,
  werks TYPE vepo-werks,
  lgort TYPE vepo-lgort.
TYPES:   END OF ty_vepo_pallet.

TYPES: BEGIN OF ty_pant,
  matnr TYPE zsdtt_002-matnr,
  lfimg TYPE zsdtt_002-lfimg,
  scan  TYPE zsdtt_002-lfimg,
  pza   TYPE zsdtt_002-lfimg.
TYPES:  END OF ty_pant.

*======================================================================*
* Tablas internas
DATA:
  tg_bdc TYPE STANDARD TABLE OF bdcdata,
  tg_msj TYPE STANDARD TABLE OF bdcmsgcoll.

DATA:
  tg_p101       TYPE STANDARD TABLE OF zsdtt_002,
  tg_dele       TYPE STANDARD TABLE OF zsdtt_002,
  tg_p102       TYPE STANDARD TABLE OF zsdtt_002.

DATA:
  tg_loghandle  TYPE bal_t_logh,
  tg_lognumbers TYPE bal_t_lgnm.

*======================================================================*
* Estructuras
DATA:
  sg_msj    TYPE bdcmsgcoll,
  sg_p101   TYPE zsdtt_002,
  sg_p102   TYPE zsdtt_002.

*======================================================================*
* Constantes
*CONSTANTS:

*======================================================================*
* Variables globales
DATA:
  vg_nocarga TYPE zsdtt_002-nocarga,
  vg_fecha   TYPE zsdtt_002-fecha.

DATA:
  vg_final TYPE c LENGTH 1,
  vg_modo  TYPE c LENGTH 1 VALUE 'N',
  vg_error TYPE c LENGTH 1.

DATA:
  vg_ok_code TYPE sy-ucomm,
  vg_dynnr   TYPE sy-dynnr,
  vg_agrega  TYPE c LENGTH 1,
  vg_quitar  TYPE c LENGTH 1,
  vg_oferta  TYPE c LENGTH 1.

DATA:
  vg_log            TYPE bal_s_log,
  vg_handler        TYPE balloghndl,
  vg_value          TYPE i.

DATA:
  vg_scaner  TYPE c LENGTH 20,
  vg_msg1    TYPE c LENGTH 20,
  vg_msg2    TYPE c LENGTH 20,
  vg_msg3    TYPE c LENGTH 20,
  vg_msg4    TYPE c LENGTH 20,
  vg_msg5    TYPE c LENGTH 20,
  vg_msg6    TYPE c LENGTH 20,
  vg_msg7    TYPE c LENGTH 20,
  vg_msg8    TYPE c LENGTH 20,
  vg_msg9    TYPE c LENGTH 20,
  vg_msg10   TYPE c LENGTH 20.

DATA:
  vg_line    TYPE i,
  vg_lines   TYPE i,
  vg_index   TYPE i,
  vg_line2   TYPE i,
  vg_lines2  TYPE i,
  vg_index2  TYPE i,
  vg_compl   TYPE i.

* ===================================================================== *
DATA:
  vg_vbeln   TYPE bapivbeln-vbeln.

* ===================================================================== *
* Rangos
DATA:
  ra_lgort TYPE RANGE OF lgort_d.
