************************************************************************
* Programa             : SAPMZSATRA                                     *
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

PROGRAM  sapmzsatra.

*======================================================================*
INCLUDE <icon>.

*======================================================================*
* Tipos
TYPE-POOLS:
abap.

*======================================================================*
* Tipos
TYPES: BEGIN OF ty_p101,
         vbeln TYPE lips-vbeln,
         posnr TYPE lips-posnr,
         matnr TYPE lips-matnr,
         charg TYPE lips-charg,
         lfimg TYPE lips-lfimg,
         vgbel TYPE lips-vgbel,
         vgpos TYPE lips-vgpos,
         werks TYPE lips-werks,
         lgort TYPE lips-lgort,
         meins TYPE lips-meins,
         pikmg TYPE lipsd-pikmg,
         capro TYPE lipsd-pikmg,
         csurt TYPE lipsd-pikmg,
         proce TYPE c LENGTH 1.
TYPES    END OF ty_p101.

TYPES: BEGIN OF ty_vbs,
         vbeln TYPE vbss-vbeln,
         name1 TYPE kna1-name1,
         pick  TYPE c LENGTH 1.
TYPES:   END OF ty_vbs.

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
        status TYPE vekp-status,
        uevel  TYPE vekp-uevel,
        vbeln  TYPE vepo-vbeln.
TYPES:  END OF ty_vepo.

TYPES: BEGIN OF ty_vbap,
         vbeln TYPE vbap-vbeln,
         posnr TYPE vbap-posnr,
         matnr TYPE vbap-matnr,
         werks TYPE vbap-werks,
         wmeng TYPE vbep-wmeng,
         vrkme TYPE vbep-vrkme.
TYPES:   END OF ty_vbap.

TYPES: BEGIN OF ty_lotes,
         matnr TYPE lips-matnr,
         charg TYPE lips-charg,
         lfimg TYPE lips-lfimg.
TYPES    END OF ty_lotes.

TYPES: BEGIN OF ty_likp,
         vbeln TYPE likp-vbeln,
         kunnr TYPE likp-kunnr,
         name1 TYPE kna1-name1,
         lfart TYPE likp-lfart.
TYPES:   END OF ty_likp.

TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbak-vbeln,
         vtweg TYPE vbak-vtweg.
TYPES:   END OF ty_vbak.

TYPES: BEGIN OF ty_vepo_pallet,
         venum TYPE vepo-venum,
         unvel TYPE vepo-unvel,
         vemng TYPE vepo-vemng,
         matnr TYPE vepo-matnr,
         charg TYPE vepo-charg,
         werks TYPE vepo-werks,
         lgort TYPE vepo-lgort.
TYPES:   END OF ty_vepo_pallet.

TYPES: BEGIN OF ty_vbfa,
         vbelv TYPE vbfa-vbelv,
         posnv TYPE vbfa-posnv,
         vbeln TYPE vbfa-vbeln,
         posnn TYPE vbfa-posnn.
TYPES:   END OF ty_vbfa.

*======================================================================*
* Tablas internas
DATA:
  tg_bdc TYPE STANDARD TABLE OF bdcdata,
  tg_msj TYPE STANDARD TABLE OF bdcmsgcoll.

DATA:
  tg_vbap  TYPE STANDARD TABLE OF ty_vbap,
  tg_lotes TYPE STANDARD TABLE OF ty_lotes.

DATA:
  tg_p101     TYPE STANDARD TABLE OF ty_p101,
  tg_lips     TYPE STANDARD TABLE OF ty_p101,
  tg_vbs      TYPE STANDARD TABLE OF ty_vbs,
  tg_tvar     TYPE STANDARD TABLE OF tvarvc,
  tg_dele     TYPE STANDARD TABLE OF zhuinv_item,
  tg_item     TYPE STANDARD TABLE OF zhuinv_item,
  tg_anterior TYPE STANDARD TABLE OF zhuinv_item,
  tg_vbfa     TYPE STANDARD TABLE OF ty_vbfa.

DATA:
  tg_likp TYPE STANDARD TABLE OF ty_likp,
  tg_vbuk TYPE STANDARD TABLE OF ty_likp,
  tg_vbak TYPE STANDARD TABLE OF ty_vbak,
  tg_vbss TYPE STANDARD TABLE OF vbss.

DATA:
  tg_loghandle  TYPE bal_t_logh,
  tg_lognumbers TYPE bal_t_lgnm.

*======================================================================*
* Estructuras
DATA:
  sg_msj   TYPE bdcmsgcoll,
  sg_zitem TYPE zhuinv_item,
  sg_lotes TYPE ty_lotes,
  sg_item  TYPE zhuinv_item.

DATA:
  sg_vbs  TYPE ty_vbs,
  sg_p101 TYPE ty_p101,
  sg_lips TYPE ty_p101,
  sg_tvar TYPE tvarvc.


*======================================================================*
* Constantes
CONSTANTS:
  c_vl02n TYPE sy-tcode VALUE 'VL02N',
  c_va02  TYPE sy-tcode VALUE 'VA02'.

*======================================================================*
* Variables globales
DATA:
  vg_sammg TYPE vbsk-sammg.

DATA:
  vg_final   TYPE c LENGTH 1,
  vg_modo    TYPE c LENGTH 1 VALUE 'N',
  vg_error   TYPE c LENGTH 1,
  vg_err_msg TYPE c LENGTH 1.

DATA:
  vg_ok_code TYPE sy-ucomm,
  vg_cursor  TYPE sy-index,
  vg_field   TYPE char50,
  vg_dynnr   TYPE sy-dynnr,
  vg_mayor   TYPE c LENGTH 1,
  vg_grupo   TYPE c LENGTH 1,
  vg_otras   TYPE c LENGTH 1,
  vg_anula   TYPE c LENGTH 1,
  vg_vbeln2  TYPE vbap-vbeln,
  vg_vbln_ok TYPE vbap-vbeln,
  vg_lfart   TYPE likp-lfart.

DATA:
  vg_log     TYPE bal_s_log,
  vg_handler TYPE balloghndl,
  vg_value   TYPE i.

DATA:
  vg_contab TYPE c LENGTH 1,
  vg_scaner TYPE c LENGTH 20,
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
  vg_line   TYPE i,
  vg_lines  TYPE i,
  vg_index  TYPE i,
  vg_line2  TYPE i,
  vg_lines2 TYPE i,
  vg_index2 TYPE i,
  vg_compl  TYPE i.

DATA:
  vg_datum TYPE sy-datum.

* ===================================================================== *
DATA:
  vg_vbeln TYPE vbap-vbeln,
  vg_entre TYPE vbap-vbeln.
* ===================================================================== *
* Rangos
DATA:
  ra_vstel TYPE RANGE OF vstel,
  ra_lgort TYPE RANGE OF lgort_d.

DATA:
  sg_vstel LIKE LINE OF ra_vstel.
