*&---------------------------------------------------------------------*
*& Include          ZMM_BAPI_DELSOLPED_TRAS_TOP
*&---------------------------------------------------------------------*

TYPES: slis.

TABLES: eban.
INCLUDE <icon>.

TYPES: BEGIN OF st_eban,
         banfn      TYPE banfn,
         bnfpo      TYPE bnfpo,
         werks      TYPE werks_d,
         name1      TYPE name1,
         bsart      TYPE bbsrt,
         pstyp      TYPE pstyp,
         statu      TYPE banst,
         estatus    TYPE  icon_d,
       END OF st_eban.

DATA: it_eban TYPE STANDARD TABLE OF st_eban.


*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      lf_layout   TYPE slis_layout_alv,    "Manejar diseño de layout
      t_sort      TYPE slis_t_sortinfo_alv,
      wa_sort     TYPE slis_sortinfo_alv.

*****     PARAMETROS DE SELECCIÓN
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
          so_werks FOR eban-werks OBLIGATORY.

*PARAMETERS:
*  fkdat_d LIKE vbrk-fkdat.     " Día a relacionar
SELECTION-SCREEN END OF BLOCK block1.
