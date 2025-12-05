*&---------------------------------------------------------------------*
*& Include          ZPP_NOTIFICA_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.
TABLES: afko, afpo, t001w.

* cabecera.
DATA: wa_fieldcat TYPE slis_fieldcat_alv,
      lf_layout   TYPE slis_layout_alv,
      wa_gs_line  TYPE slis_listheader,
      gt_header   TYPE slis_t_listheader,
      wa_header   TYPE slis_listheader,
      gt_line     LIKE wa_header-info,

* Catalogo.
      gt_fieldcat TYPE STANDARD TABLE OF slis_fieldcat_alv,
      gv_title    TYPE lvc_title,
      wa_variant  TYPE disvariant,
      gv_program  TYPE sy-repid.



TYPES: BEGIN OF st_ordenes,
         aufnr      TYPE aufnr,       " Orden
         objnr      TYPE j_objnr,
         istat      TYPE j_txt30,
         gstrp      TYPE pm_ordgstrp, " Fecha inicio extrema
         gsuzp      TYPE co_gsuzp, "Fecha de inicio extrema (hora)
         gltrp      TYPE co_gltrp, " Fecha fin extrema
         gluzp      TYPE co_gluzp, " Fin extremo (hora)
         "
         gstrs      TYPE co_gstrs, "inicio programado
         gsuzs      TYPE co_gsuzs, "Hora inicio pogramado
         gltrs      TYPE co_gltrs, "fin programado
         gluzs      TYPE co_gluzs, "hora fin programadao
         estatus(4),
       END OF st_ordenes.


DATA: it_ordenes TYPE STANDARD TABLE OF st_ordenes.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
                so_aufk FOR afko-aufnr,
                so_werks FOR t001w-werks,
                so_fecha FOR afko-gstrp.
SELECTION-SCREEN END OF BLOCK b1.
