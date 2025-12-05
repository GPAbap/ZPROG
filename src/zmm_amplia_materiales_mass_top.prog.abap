*&---------------------------------------------------------------------*
*& Include          ZMM_AMPLIA_MATERIALES_MASS_TOP
*&---------------------------------------------------------------------*

TABLES: t001l, "Storage Locations
        mara,  "General Material Data
        makt,  "Material Descriptions
        mbew,  "Material Valuation
        marc,  "Plant Data for Material
        mvke.  "Sales Data

DATA: bapi_head    LIKE bapimathead,
      bapi_makt    LIKE bapi_makt,    "Material Description
      bapi_mara1   LIKE bapi_mara,    "Client Data
      bapi_marax   LIKE bapi_marax,
      bapi_marc1   LIKE bapi_marc,    "Plant View
      bapi_marcx   LIKE bapi_marcx,
      bapi_mbew1   LIKE bapi_mbew,    "Accounting View
      bapi_mbewx   LIKE bapi_mbewx,
      bapi_mvke1   TYPE bapi_mvke,
      bapi_mvkex   TYPE bapi_mvkex,
      bapi_return  LIKE bapiret2,
      bapi_mard    TYPE bapi_mard,
      bapi_mardx   TYPE bapi_mardx,
      bapi_mlan    TYPE STANDARD TABLE OF bapi_mlan,
      ls_bapi_mlan TYPE bapi_mlan.
DATA: lt_bapi_return TYPE STANDARD TABLE OF bapiret2,
      bapi_qmat      TYPE STANDARD TABLE OF bapi1001004_qmat,
      ls_bapi_qmat   TYPE bapi1001004_qmat.

DATA: BEGIN OF bdcdata OCCURS 0.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF bdcdata.

DATA: BEGIN OF int_makt OCCURS 100.
        INCLUDE STRUCTURE bapi_makt.
DATA: END OF int_makt.

DATA: ls_qmat TYPE qmat,
      lt_qmat TYPE STANDARD TABLE OF qmat.

DATA: BEGIN OF int_mat OCCURS 100,
        werks(4),     "Plant
        mtart(4),     "Material type
        matnr(18),    "Material number
        matkl(9) ,    "Material group
        mbrsh(1),     "Industry sector
        meins(3),     "Base unit of measure
        gewei(3),     "Weight Unit
        spart(2),     "Division
        ekgrp(3),     "Purchasing group
        bwkey(4),     "Valuation Area
        bwtar(10),    "Valuation Type
        vprsv(1),     "Price control indicator
        stprs(12),    "Standard price
        peinh(3),     "Price unit
        spras(2),     "Language key
        maktx(40),     "Material description
        vkorg(04),     "Sales Organisation
        vtweg(02),     "Distribution Channel
        mara(01),      "MARA VALUE
        mbew(01),      "MBEW
        makt(01),      "MAKT
        mvke(01),      "SALES
      END OF int_mat.

SELECT-OPTIONS:
            plant    FOR  marc-werks OBLIGATORY MEMORY ID plt,
            material FOR  mara-matnr MEMORY ID mat,
*            matltype FOR  mara-mtart MEMORY ID mty,
*            division FOR  mara-spart MEMORY ID div,
*            to_sorg  FOR  mvke-vkorg "OBLIGATORY
*NO INTERVALS NO-EXTENSION MEMORY ID vko,
*"Sales Org/Dist Channel is required for the Sales View.
*            to_dchnl FOR  mvke-vtweg "OBLIGATORY
*NO INTERVALS NO-EXTENSION MEMORY ID vtw,
            to_plant FOR  marc-werks OBLIGATORY
NO INTERVALS NO-EXTENSION.
PARAMETERS:  f_file  LIKE rlgrap-filename
DEFAULT 'C:\DATA\ZMATERIAL.XLS' MEMORY ID f_file,
             getdata AS CHECKBOX DEFAULT 'X',
             "Tick to download materials data to local harddisk
             upddata AS CHECKBOX DEFAULT 'X'.
"Tick to update date to Materials Master
