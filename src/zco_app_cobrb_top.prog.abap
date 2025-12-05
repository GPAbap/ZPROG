*&---------------------------------------------------------------------*
*& Include zco_app_cobrb_top
*&---------------------------------------------------------------------*

TABLES: afpo, cobrb.
INCLUDE <icon>.
TYPES slis.



TYPES: BEGIN OF st_table_alv,
         aufnr      TYPE aufnr,
         objnr      type objnr,
         matnr      TYPE matnr,
         wemng      TYPE wemng,
         semaforo   TYPE icon_d,
         texto      TYPE string,
         lfdnr      TYPE br_lfdnr,
         perbz      TYPE perbz_ld,
         urzuo      TYPE urzuo,
         dfreg      TYPE dfreg,
         konty      TYPE konty,
         kokrs      TYPE kokrs,
         werks      TYPE werks_d,
         bukrs      TYPE bukrs,
         posnr      TYPE posnr,
         rec_objnr1 TYPE srec_objnr,
         extnr      TYPE cobr_EXTNR,
         zcobrb     TYPE zcobrb,
       END OF st_table_alv.


DATA it_table_alv TYPE STANDARD TABLE OF st_table_alv.
DATA it_table_aufnr TYPE STANDARD TABLE OF st_table_alv.

FIELD-SYMBOLS: <fs_alv>   TYPE st_table_alv,
               <fs_cobrb> TYPE st_table_alv.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv.


data cl_norma type ref to zcl_co_pc_ajustenormasliquida.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS so_aufnr FOR afpo-aufnr OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
