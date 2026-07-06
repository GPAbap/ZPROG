*&---------------------------------------------------------------------*
*&  Include           ZSD_AUT_CREAPEDVTAS_03_TOPV2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSD_AUT_CREAPEDVTAS_03_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSD_AUT_CREAPEDVTAS_02_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSD_AUT_CREAPEDVTAS_01_TOP
*&---------------------------------------------------------------------*
TABLES: tvakt, "Clase de Documento
        tvko, "organización de ventas
        tvtw, "Canal de distribución
        tvta, "sector
        tvkbz, "Oficina de ventas
        tvbvk, "Grupo de vendedores
        tvau. "Motivo de pedido

DATA: it_equivaleppa TYPE STANDARD TABLE OF zsd_tt_ppaequsan.

DATA: rg_spart TYPE RANGE OF vbak-spart,
      wa_spart LIKE LINE OF rg_spart.


TYPES: BEGIN OF ty_string,

         str(50) TYPE c,
       END OF ty_string.
DATA it_string TYPE TABLE OF ty_string.
DATA wa_string TYPE ty_string .

"---------07-11-2022 agregado de tablas base SAN equivalentes  HANA.
DATA: it_TVAKT TYPE STANDARD TABLE OF tvakt,
      it_tvko  TYPE STANDARD TABLE OF tvko,
      it_TVTW  TYPE STANDARD TABLE OF tvtw,
      it_TVTA  TYPE STANDARD TABLE OF tvta,
      it_TVKBZ TYPE STANDARD TABLE OF tvkbz,
      it_TVBVK TYPE STANDARD TABLE OF tvbvk,
      it_TVAU  TYPE STANDARD TABLE OF tvau.
"----------------------------------------------------------------------
TYPES: BEGIN OF st_auartecc,
         auart_hana TYPE auart,
         auart_ecc  TYPE auart,
         vkorg      TYPE vkorg,
         dzterm     TYPE dzterm,
       END OF st_auartecc,

       BEGIN OF st_centros,
         werks_hana TYPE werks_d,
         werks_ecc  TYPE werks_d,
       END OF st_centros.



DATA: it_auart   TYPE STANDARD TABLE OF st_auartecc,
      wa_auart   LIKE LINE OF it_auart,

      it_centros TYPE STANDARD TABLE OF st_centros,
      wa_centros LIKE LINE OF it_centros.


*DATA: it_archivos TYPE STANDARD TABLE OF ZSD_TT_CONFIGSAN,
*      wa_archivos LIKE LINE OF it_archivos.

DATA: it_directorio TYPE STANDARD TABLE OF zsd_tt_dirsftp,
      wa_directorio LIKE LINE OF it_directorio.

DATA: lv_directorio TYPE char80.


DATA: lv_vpg    TYPE Kunnr,
      lv_metpag TYPE char2.

TYPES: BEGIN OF ty_rango,
         fecha TYPE datum,
       END OF ty_rango.

DATA: it_rango TYPE STANDARD TABLE OF ty_rango,
      wa_rango LIKE LINE OF it_rango.

DATA: lv_fecha TYPE datum.

TYPES: BEGIN OF ty_archivos,
         werks TYPE werks_d,
         fecha TYPE datum,
       END OF ty_archivos.

DATA: it_archivos TYPE STANDARD TABLE OF ty_archivos,
      wa_archivos LIKE LINE OF it_archivos.

DATA: it_dep TYPE STANDARD TABLE OF zsd_tt_configsan,
      wa_dep LIKE LINE OF it_dep.

TYPES: BEGIN OF st_datos_pedidos,
         "Header
         row        TYPE i, "fila
         ticket     TYPE char14,  "ticket
         auart      TYPE auart, "clase de documento
         vkorg      TYPE vkorg, "Organizacion de ventas
         vtweg      TYPE vtweg, "canal de distribución
         spart      TYPE spart, "Sector
         vkbur      TYPE vkbur, "Oficina de Ventas
         vkgrp      TYPE vkgrp, "Grupo de Vendedores
         sold       TYPE kunnr,  " cliente
         name1      TYPE name1,  "Nombre del cliente
         ship       TYPE kunnr,  "cliente envio
         vdatu      TYPE vbak-vdatu, "fecha entrega
         bstdk      TYPE bstdk,  "fecha ref cliente
         bstkd      TYPE vbkd-bstkd, "Dato Referencia Cliente
         werks      TYPE werks_d, "Centro
**ITEM
         matnr      TYPE matnr18, "material
         waerk      TYPE waerk, "Moneda
         kursk      TYPE kursk, "Tipo de cambio
         kwmeng     TYPE kwmeng, "cantidad Pedida
         vrkme      TYPE vrkme, "unidad de medida
         posnr      TYPE posnr, "posicion del documento
         etdat      TYPE etdat, "Fecha de Reparto
         pstyv      TYPE pstyv,  "Tipo de posición
         bmeng      TYPE kwmeng, "cantidad de reparto.
         kpein      TYPE kpein, "contador condiciones. Siempre '01'
         dzterm     TYPE dzterm, "clase de condiciones de pago
         kbetr      TYPE kbetr, " Importe de condicion, si existe en Hana, será mandatorio
         route      TYPE route,   "Ruta
         lgort      TYPE lgort_d, " Almacen
         texto      TYPE v_ttxid_n-tdtext, "Texto de Cabecera
******* MODIFICACIONES MICHAEL 18.08.2020 INI
         desc       TYPE kschl,
         porc       TYPE kbetr,
         tippor     TYPE krech,
******* MODIFICACIONES MICHAEL 18.08.2020 FIN
******* MODIFICACIONES MICHAEL 03.09.202 INI
         cust_grp1  TYPE char2, "KVGR1,
         cust_grp2  TYPE kvgr2,
******* MODIFICACIONES MICHAEL 03.09.202 FIN
         metpag     TYPE kvgr2,
         vpg        TYPE char1, "venta publico general
         fact       TYPE char1, "facturado
         canc       TYPE char1, "cancelado
         reft       TYPE char13, "ref ticket cancelado
         gross_wght TYPE  brgew_ap, "Peso bruto de la posición
         net_weight TYPE ntgew_ap, "Peso neto de la posición
         untof_wght TYPE gewei, "Unidad de peso
         unof_wtiso TYPE gewei_iso, "Unidad de peso en código ISO
         bsark      TYPE bsark,
****************** 27 diciembre 2021 - DESK943284
       END OF st_datos_pedidos.

TYPES: BEGIN OF st_pedidosg,
         row    TYPE i, "fila
         vbeln  TYPE vbeln,
         auart  TYPE auart, "clase de documento
         vkorg  TYPE vkorg, "Organizacion de ventas
         vtweg  TYPE vtweg, "canal de distribución
         spart  TYPE spart, "Sector
         route  TYPE route,   "Ruta
         lgort  TYPE lgort_d, " Almacen
         bstdk  TYPE bstdk,  "fecha ref cliente
         sold   TYPE kunnr,  " cliente
         name1  TYPE name1,  "Nombre del cliente,
         bmeng  TYPE kwmeng, "cantidad de reparto
         kbetr  TYPE kbetr, " Importe de condicion, si existe en Hana, será mandatorio
         status TYPE string,

       END OF st_pedidosg.

**** TABLA COMPARATIVA
DATA: it_valida TYPE STANDARD TABLE OF zsd_tt_plantsan,
      wa_valida LIKE LINE OF it_valida.
***TABLA no creados
DATA: it_nocrea TYPE STANDARD TABLE OF zsd_tt_pednocrea,
      wa_nocrea LIKE LINE OF it_nocrea.

DATA: it_plantillaSAN TYPE STANDARD TABLE OF zsd_tt_plantsan,
      wa_plantillaSAN LIKE LINE OF it_plantillaSAN.

************** TABLAS PEDIDOS NO CREADOS
DATA: it_nocreados TYPE STANDARD TABLE OF zsd_tt_pednocrea,
      wa_nocreados LIKE LINE OF it_nocreados.

*************** TABLAS PARA RELACIONAR TICKETS CON PEDIDOS
DATA: it_pedvssan2 TYPE STANDARD TABLE OF zsd_tt_pedticsan,
      wa_pedvssan2 LIKE LINE OF it_pedvssan2.

DATA: it_pedvssan TYPE STANDARD TABLE OF zsd_tt_pedticsan,
      wa_pedvssan LIKE LINE OF it_pedvssan.

DATA: it_datos_pedidos   TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidos   LIKE LINE OF it_datos_pedidos,
      wa_tickets_creados LIKE LINE OF it_datos_pedidos.

************* AUXILIAR PARA RESTA 1
DATA: it_datos_resp TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_resp LIKE LINE OF it_datos_resp.
************* AUXILIAR PARA RESTA
DATA: it_datos_resta TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_resta LIKE LINE OF it_datos_resta.

************* AUXILIAR PARA PEDIDOS CANCELADOS
DATA: it_datos_pedidos2 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidos2 LIKE LINE OF it_datos_pedidos2.

************* AUXILIAR PARA CANCELAR PEDIDOS INTERNOS
DATA: it_datos_pedidos3 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidos3 LIKE LINE OF it_datos_pedidos3.

* TABLA SECTOR 18
DATA: it_datos_pedidos18 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidos18 LIKE LINE OF it_datos_pedidos18.

DATA: it_datos_pedidos18f TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidos18f LIKE LINE OF it_datos_pedidos18f.

* TABLA SECTOR 30
DATA: it_datos_pedidos30 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidos30 LIKE LINE OF it_datos_pedidos30.

DATA: it_datos_pedidos30f TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidos30f LIKE LINE OF it_datos_pedidos30f.

*******TABLAS PEDIDOS VVPG

DATA: it_datos_pedidosV TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosV LIKE LINE OF it_datos_pedidosV.

DATA: it_datos_pedidosV2 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosV2 LIKE LINE OF it_datos_pedidosV2.

DATA: it_datos_pedidos_vpg TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidos_vpg LIKE LINE OF it_datos_pedidos_vpg.

DATA: it_datos_pedidos_vpg_i TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidos_vpg_i LIKE LINE OF it_datos_pedidos_vpg_i.


***********************************+************************************+*
*******29 de enero VPGI ***********************************+*

DATA: it_datos_pedidosvpgi2 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosvpgi2 LIKE LINE OF it_datos_pedidosvpgi2.

DATA: it_datos_pedidosVpgi18 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosVpgi18 LIKE LINE OF it_datos_pedidosVpgi18.


DATA: it_datos_pedidosvpgi01f TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosvpgi01f LIKE LINE OF it_datos_pedidosvpgi01f.

DATA: it_datos_pedidosvpgi11f TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosvpgi11f LIKE LINE OF it_datos_pedidosvpgi11f.


***********************************+************************************+*
***********************************+************************************+*
***********************************+************************************+*

******************************** VPG 30 SEPARADO POR FORMAS DE PAGO
DATA: it_datos_pedidosV2FP TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosV2FP LIKE LINE OF it_datos_pedidosV2FP.
**************************************************+

DATA: it_datos_pedidosv18 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosv18 LIKE LINE OF it_datos_pedidosv18.

DATA: it_datos_pedidosv182 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosv182 LIKE LINE OF it_datos_pedidosv182.

********************************** VPG 18 SEPARADO POR FORMAS DE PAGO
DATA: it_datos_pedidosv182FP TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datos_pedidosv182FP LIKE LINE OF it_datos_pedidosv182FP.
***********************************************

************* AUXILIAR PARA SEPARAR OF VTAS **************
DATA: it_datosauxv2 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datosauxv2 LIKE LINE OF it_datosauxv2.

DATA: it_datosauxv18 TYPE STANDARD TABLE OF st_datos_pedidos,
      wa_datosauxv18 LIKE LINE OF it_datosauxv18.
************* AUXILIAR PARA SEPARAR OF VTAS **************

DATA: it_tvv1 TYPE STANDARD TABLE OF tvv1,
      wa_tvv1 LIKE LINE OF it_tvv1.


DATA: cpedido TYPE i.

DATA: lv_nomplan TYPE char30.
******* DECLARACIONES (VAN EN UN DATA)**************
* DATA DECLARATIONS.
DATA:  v_vbeln LIKE vbak-vbeln.
DATA: header LIKE bapisdhd1. "bapisdhead1.
DATA: headerx LIKE bapisdhd1x."bapisdhead1x.
DATA: item    LIKE bapisditm OCCURS 0 WITH HEADER LINE."bapisditem OCCURS 0 WITH HEADER LINE.
DATA: itemx   LIKE bapisditmx OCCURS 0 WITH HEADER LINE."bapisditemx OCCURS 0 WITH HEADER LINE.
DATA: partner LIKE bapiparnr OCCURS 0 WITH HEADER LINE."bapipartnr  OCCURS 0 WITH HEADER LINE.
DATA: itext   LIKE bapisdtext OCCURS 0 WITH HEADER LINE.
DATA: return  LIKE bapiret2    OCCURS 0 WITH HEADER LINE.
DATA: return_all  LIKE bapiret2    OCCURS 0 WITH HEADER LINE.

****WORK AREA PARA RETURN

DATA: wa_ret LIKE LINE OF return.

DATA:logic_switch LIKE  bapisdls OCCURS 0 WITH HEADER LINE.

DATA: it_pedidosg TYPE STANDARD TABLE OF st_pedidosg,
      wa_pedidosg LIKE LINE OF it_pedidosg.

DATA: lt_schedules_inx   TYPE STANDARD TABLE OF  bapischdlx"bapischdlx
                         WITH HEADER LINE.
DATA: lt_schedules_in    TYPE STANDARD TABLE OF bapischdl
                         WITH HEADER LINE.

DATA: order_cond LIKE bapicond OCCURS 0 WITH HEADER LINE.
DATA: order_condx LIKE bapicondx OCCURS 0 WITH HEADER LINE.

DATA: contador TYPE i.

DATA: it_zpedido TYPE STANDARD TABLE OF zsd_tt_pedcreaut,
      wa_zpedido LIKE LINE OF it_zpedido.

DATA: BEGIN OF it_tab OCCURS 0,
        rec(1000) TYPE c,
      END OF it_tab.
DATA: wa_tab(1000) TYPE c.

"contador para pruebas controladas
DATA: c TYPE i.

DATA: wa_file_data TYPE text4096.

************************
************************
************************
*DECLARACIONES DE REPORT

DATA : lv_dir TYPE eps2filnam.

*lv_dir   = '\\NETSAN\CFDISAN\prueba san antonio.xlsx'.
lv_dir   = '\\NETSAN\CFDISAN'.
DATA: it_files TYPE TABLE OF eps2fili,
      wa_files LIKE LINE OF it_files.

DATA : p_file_n TYPE localfile .

DATA: lv_newdate TYPE sy-datum.

DATA: lv_datecrea TYPE sy-datum.

DATA: row TYPE i.


DATA: t1    TYPE i,
      t2    TYPE i,
      t     TYPE p DECIMALS 2,
      Ttime TYPE p DECIMALS 2,
      n     TYPE i VALUE 10000.

DATA: posnr_aux         TYPE char6,
      dsched_line       TYPE char4,
      pedidos_generados TYPE string,
      indice            TYPE i,
      last_price        TYPE kbetr.



*****************FIELDCATS *************************
TYPE-POOLS slis.


DATA: lt_files    TYPE filetable,
      l_file      TYPE file_table,
      l_title     TYPE string,
      l_subrc     TYPE i,
      l_usr_act   TYPE i,
      l_def_file  TYPE string,
      l_cuentaban TYPE string,
      p_column    TYPE i,
      p_row       TYPE i,
      vl_ext(4)   TYPE c,
      vl_long     TYPE i,
      vl_cad(50)  TYPE c,
      vl_flag     TYPE c,
      ncolumnas   TYPE i.

DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
      lt_sort     TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      gs_key      TYPE slis_keyinfo_alv,
      gt_events   TYPE slis_t_event,
      lw_fieldcat TYPE slis_fieldcat_alv,
      lw_layout   TYPE  slis_layout_alv.
