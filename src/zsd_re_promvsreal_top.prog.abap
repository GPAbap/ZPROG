*&---------------------------------------------------------------------*
*& Include          ZSD_RE_PROMVSREAL_TOP
*&---------------------------------------------------------------------*
TABLES: vbrk, vbrp, vbak, vbap,vbkd.

TYPE-POOLS: slis.

TYPES: BEGIN OF st_datos,
         vbeln       TYPE vbeln,
         posnr       TYPE POSNR_d,
         bstkd       type bstkd,
         charg       TYPE charg_d,
         werks       TYPE werks_d,
         name1w      TYPE name1,
         parvada(4)  TYPE c,
         id(2)       TYPE c,
         kwmeng      TYPE menge_d,
         ntgew       TYPE ntgew_ap,
         erdat       TYPE erdat,
         vkorg       TYPE vkorg,
         vkbur       type vkbur,
         spart       TYPE spart,
         ernam       TYPE ernam,
         vtweg       TYPE vtweg,
         netwr       TYPE netwr,
         kunnr       TYPE kunnr,
         stcd1       TYPE stcd1,
         name1       TYPE name1,
         fkdat       TYPE fkdat,
         vbelnf      TYPE vbeln,
         posnrf      TYPE POSNR_vf,
         ernamf      TYPE ernam,
         bzirk       TYPE bzirk,
         bztxt       TYPE bztxt,
         kurrf       TYPE kurrf,
         fkimg       TYPE fkimg,
         vrkme       TYPE vrkme,
         ntgewf      TYPE ntgew_ap,
         matnr       TYPE matnr_d,
         maktx       TYPE maktx,
         netwrf      TYPE netwr,
         erdate      TYPE erdat,
         vbelne      TYPE vbeln,
         lfimg       TYPE lfimg,
         ntgewe      TYPE ntgew_ap,
         difpedfact  TYPE int4,
         kdmat       TYPE kdmat,
         caseta(4)   TYPE c,
         lote(4)     TYPE c,
         cantidad(5) TYPE c,
         producto(3) TYPE c,
       END OF st_datos.

DATA it_datos TYPE STANDARD TABLE OF st_datos.

*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      lf_layout   TYPE slis_layout_alv,    "Manejar diseño de layout
      t_sort      TYPE slis_t_sortinfo_alv,
      wa_sort     TYPE slis_sortinfo_alv.

*****     PARAMETROS DE SELECCIÓN
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
  so_vkorg FOR vbrk-vkorg OBLIGATORY DEFAULT 'AV01',      " Organización de ventas
  so_spart FOR vbrk-spart,      " Sector
  so_erdat FOR vbak-erdat.      " Fecha de factura
*PARAMETERS:
*  fkdat_d LIKE vbrk-fkdat.     " Día a relacionar
SELECTION-SCREEN END OF BLOCK block1.
