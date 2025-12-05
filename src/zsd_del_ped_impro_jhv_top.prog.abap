*&---------------------------------------------------------------------*
*& Include          ZSD_DEL_PED_IMPRO_JHV_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

TABLES: vbak, vbap.

TYPES: BEGIN OF st_pedidos,
         vbeln     TYPE vbeln_va,
         erdat     TYPE erdat,
         ernam     TYPE ernam,
         kunnr     TYPE kunag,
         name1     TYPE name1,
         abgru     TYPE abgru_va,
         status(4) TYPE c,
       END OF st_pedidos.

DATA: it_pedidos TYPE STANDARD TABLE OF st_pedidos,
      wa_pedidos LIKE LINE OF it_pedidos.

data lt_fieldcat TYPE slis_t_fieldcat_alv.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t-001.
  SELECT-OPTIONS: so_fecha FOR vbak-erdat OBLIGATORY,
                  so_uname FOR vbak-ernam DEFAULT 'JOBSAP' OBLIGATORY NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b1.
