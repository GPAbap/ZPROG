*&---------------------------------------------------------------------*
*& Include          ZMM_RETORNO_MATERIAL_PV_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.



"DATA: obj_upload TYPE REF TO zcl_upload_xls.

DATA: gv_consulta TYPE sy-datum.
DATA gv_UNAME TYPE sY-uname.

TYPES: BEGIN OF st_diferencias,
         matnr      TYPE matnr,
         werks      TYPE werks_d,
         charg      TYPE charg_d,
         menge      TYPE menge_d,
         /cwm/menge TYPE /cwm/menge,
         peso_prom  TYPE menge_d,
         klmeng     TYPE klmeng,
         ntgew      TYPE ntgew_ap,
         tras_pzas  TYPE menge_d,
         tras_kg    TYPE menge_d,
         dif_pzas   TYPE menge_d,
         dif_kgs    TYPE menge_d,
       END OF st_diferencias.

DATA: it_DIFERENCIAS TYPE STANDARD TABLE OF st_diferencias,
      wa_DIFERENCIAS LIKE LINE OF it_diferencias.

DATA: it_log TYPE STANDARD TABLE OF zlog_dev_mm_migo,
      wa_log LIKE LINE OF it_log.

*START-OF-SELECTION.
**  PARAMETERS: p_file   TYPE localfile OBLIGATORY.
*select-OPTIONS: so_date
