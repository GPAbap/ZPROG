*&---------------------------------------------------------------------*
*& Include          ZPP_BOM_MASS_TOP
*&---------------------------------------------------------------------*
TABLES: mast,  stas, stko, stpo, makt.

TYPE-POOLS: slis.
INCLUDE <icon>.
CONSTANTS: gv_idetalle type i VALUE 5,
           gv_iencabezado type i value 2.

DATA: lc_archivo TYPE string,
      lv_file    TYPE string.

*TYPES: BEGIN OF st_formulacionh,
*         ind,
*         sheet  TYPE zmxed0011, "nombre hoja
*         stlnr  TYPE stnum, "codigo formulación
*         stktx  TYPE stktx, "Texto
*         wrkan  TYPE wrkan, "centro
*         wrkan2 TYPE wrkan, "pricing plant
*         stlal  TYPE stalt, "version alternativa
*         bmeng  TYPE basmn, "Batch Weight
*         status(4) type c,
*       END OF st_formulacionh.
*
*TYPES: BEGIN OF st_formulacionp,
*          ind,
*          sheet  TYPE zmxed0011, "nombre hoja
*          stlnr TYPE stnum, "codigo formulación
*          idnrk TYPE idnrk, "Ingrediente
*          name1 TYPE  name1, "NOMBRE
*          menge TYPE menge_d, "CANTIDAD
*       END OF st_formulacionp.


DATA: it_bomh TYPE STANDARD TABLE OF zst_formulacionh,
      wa_bomh like LINE OF it_bomh,
      it_bomp TYPE STANDARD TABLE OF zst_formulacionp,
      wa_bomp like LINE OF it_bomp.

*Tablas
DATA: it_salida TYPE TABLE OF zalsmex_tabline1,
      gs_salida TYPE zalsmex_tabline.

*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

********para ALV
DATA: ti_header TYPE slis_t_listheader,
      st_header TYPE slis_listheader,
      ti_sort   TYPE slis_t_sortinfo_alv,
      st_sort   TYPE slis_sortinfo_alv.

**********Alv Jerarquico
DATA: st_keyinfo TYPE slis_keyinfo_alv,
      lt_sort    TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      gt_events  TYPE slis_t_event,
      lf_layout  TYPE slis_layout_alv.    "Manejar diseño de layout


*Parametros para pantalla principal.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  PARAMETERS:
    p_file      TYPE localfile OBLIGATORY,
    p_sheet     type i obligatory default 1.
SELECTION-SCREEN END OF BLOCK b1.
