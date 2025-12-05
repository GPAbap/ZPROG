*&---------------------------------------------------------------------*
*& Include zpp_app_notifica_top
*&---------------------------------------------------------------------*

TYPE-POOLS: SLIS.
TABLES: JEST, AFRU, AFKO,AUFK.
INCLUDE <icon>.
*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

********para ALV
DATA: ti_header TYPE slis_t_listheader,
      st_header TYPE slis_listheader,
      ti_sort   TYPE slis_t_sortinfo_alv,
      st_sort   TYPE slis_sortinfo_alv,
      lf_layout   TYPE slis_layout_alv.

Types: BEGIN OF st_ordenes,
        AUFNR type aufnr,
        werks type werks_d,
        VORNR type vornr,
        ISTAT type J_TXT30,
        status type icon_d,
       END OF st_ordenes.

data: it_ordenes type STANDARD TABLE OF st_ordenes.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  SELECT-OPTIONS: so_aufnr FOR AFKO-AUFNR ,
                  so_werks for AUFK-werks,
                  so_gstrp for AFKO-gstrp OBLIGATORY.
    SELECTION-SCREEN END OF BLOCK b1.
