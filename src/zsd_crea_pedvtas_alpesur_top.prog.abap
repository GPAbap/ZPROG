*&---------------------------------------------------------------------*
*& Include zsd_crea_pedvtas_alpesur_top
*&---------------------------------------------------------------------*

TABLES: tvakt, "Clase de Documento
        tvko, "organización de ventas
        tvtw, "Canal de distribución
        tvta, "sector
        tvkbz, "Oficina de ventas
        tvbvk, "Grupo de vendedores
        tvau. "Motivo de pedido

CONSTANTS ndias TYPE dlydy VALUE 5.

CONSTANTS: c_comma VALUE ',',
           c_point VALUE '.',
           c_esc   VALUE '"'.

DATA: it_datos_pedidos   TYPE STANDARD TABLE OF zsd_st_datos_pedidos WITH NON-UNIQUE SORTED KEY pk COMPONENTS ticket werks posnr, "almacena los pedidos por archivo cargado.
      it_datos_pedidos_vtru   TYPE STANDARD TABLE OF zsd_st_datos_pedidos WITH NON-UNIQUE SORTED KEY pk COMPONENTS ticket werks posnr,
      wa_datos_pedidos   LIKE LINE OF it_datos_pedidos,
      wa_tickets_creados LIKE LINE OF it_datos_pedidos.

DATA: it_plantillaSAN TYPE STANDARD TABLE OF zsd_tt_plantsan, "tabla para agregar los pedidos a SAP
      wa_plantillaSAN LIKE LINE OF it_plantillaSAN.

DATA: it_datos_pedidosvtru TYPE STANDARD TABLE OF zsd_st_datos_pedidos, "tabla para pedidos a Ruta
      wa_datos_pedidosvtru LIKE LINE OF it_datos_pedidosvtru.

DATA it_clientes_vpg TYPE STANDARD TABLE OF zsd_tt_configvpg.

DATA: ifile TYPE STANDARD TABLE OF eps2fili,
      wa_ifile LIKE LINE OF ifile.

DATA : p_file_n TYPE localfile .

*DATA: BEGIN OF it_tab OCCURS 0,
*        rec(1000) TYPE c,
*      END OF it_tab.
*DATA: wa_tab(1000) TYPE c.

TYPES: BEGIN OF ty_string,
         str(50) TYPE c,
       END OF ty_string.
DATA it_string TYPE TABLE OF ty_string.

TYPES: BEGIN OF st_valida,
         ticket    TYPE char13,
         werks     TYPE werks_d,
         posnr     TYPE posnr,
         nomplan   TYPE char30,
         fechaplan TYPE datum,
       END OF st_valida.

DATA: it_tab TYPE kcdu_srecs,
      wa_row TYPE  kcdu_srec.

DATA: it_tvv1 TYPE STANDARD TABLE OF tvv1,
      wa_tvv1 LIKE LINE OF it_tvv1.

DATA: lv_vpg    TYPE Kunnr,
      lv_metpag TYPE char2.

DATA: lv_directorio       TYPE char80,lv_directoriocp TYPE string,
      vl_directorioC(200) TYPE c.

DATA: lv_datecrea TYPE sy-datum.

DATA: it_valida TYPE STANDARD TABLE OF st_valida WITH NON-UNIQUE SORTED KEY Vl COMPONENTS ticket werks posnr,
      wa_valida LIKE LINE OF it_valida.

TYPES: BEGIN OF ty_archivos,
         werks TYPE werks_d,
         fecha TYPE datum,
       END OF ty_archivos.

DATA: it_archivos TYPE STANDARD TABLE OF ty_archivos,
      wa_archivos LIKE LINE OF it_archivos.

DATA obj_pedidos TYPE REF TO zcl_pedidos_vta_alpesur.
