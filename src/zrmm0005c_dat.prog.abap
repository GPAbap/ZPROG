*&---------------------------------------------------------------------*
*&  Include           ZRMM0005B_DAT
*&---------------------------------------------------------------------*
TABLES:
  mbew,                                    " Valoración de Materiales
  mard,                                    " Segmento Alm/Lotes
  makt,                                    " Textos Breves de Material
  mara,                                    " Datos generales CJTC
  t001l,                                   " Almacenes.
  t001w,                                  " Centros
*Modif 18/MAyo/2016 GCS Proceti
  mvke.
*Modif 18/MAyo/2016 GCS Proceti
* Parámetros de selección
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
*Modif 18/MAyo/2016 GCS Proceti2
    werks_p LIKE t001w-werks. " OBLIGATORY.      " Centro

*Modif 18/MAyo/2016 GCS Proceti
  SELECT-OPTIONS:
*Modif 18/MAyo/2016 GCS Proceti2
    vkorg_p for mvke-vkorg, " Obligatory.     "Organizacion Vtas
    spart_p FOR mara-spart,                  " Sector
*Modif 18/MAyo/2016 GCS Proceti2
    lgort_p FOR mard-lgort,                  " Almacén
    matnr_p FOR mard-matnr,                  " Material
    s_prdha FOR mara-prdha NO-DISPLAY.       " Jerarqupia de producto CJTC
SELECTION-SCREEN END OF BLOCK block1.

* Declaración de Tabla Interna
DATA: BEGIN OF rec OCCURS 0,
        werks  LIKE mard-werks,             "Centro
        lgort  LIKE mard-lgort,             " almacén (4)
        matnr  LIKE mard-matnr,             " Material (18)
        maktx  LIKE makt-maktx,             " Texto (40)
        verpr  LIKE mbew-verpr,             " Precio Variable (13)
        lbkum  LIKE mbew-lbkum,             " Stock Total (13)
        salk3  LIKE mbew-salk3,             " valor Total (13)
        labst  LIKE mard-labst,             " Stock Valorado Libre util (13)
        umlme  LIKE mard-umlme,             " Stock en traslado (13)
        insme  LIKE mard-insme,             " Stock en control de Calidad (13)
        prdha  LIKE mara-prdha, " PROCETI CJTC
        vtext  LIKE t179t-vtext, "  PROCETI CJTC
        lgobe  TYPE t001l-lgobe, "  PROCETI CJTC
        klmenb TYPE vbap-klmeng,
*Proceti2 10/JUN/2016
        cothoy TYPE vbap-ntgew, "Cotizacion hoy
        cotma  TYPE vbap-ntgew, "Cotizacion mañana
        cotpas TYPE vbap-ntgew, "Cotizacion Pasado mañana
*Proceti2 10/JUN/2016
        klmenc TYPE vbap-klmeng,
        klmend TYPE vbap-klmeng,
      END OF rec,
      BEGIN OF t_vbfa_c OCCURS 0,
        vbelv   TYPE vbfa-vbelv,
        posnv   TYPE vbfa-posnv,
        vbeln   TYPE vbfa-vbeln,
        posnn   TYPE vbfa-posnn,
        vbtyp_n TYPE vbfa-vbtyp_n,
        rfmng   TYPE vbfa-rfmng,
        meins   TYPE vbfa-meins,
        rfwrt   TYPE vbfa-rfwrt,
        waers   TYPE vbfa-waers,
        vbtyp_v TYPE vbfa-vbtyp_v,
        plmin   TYPE vbfa-plmin,
      END OF t_vbfa_c,
      BEGIN OF t_vbfa_b OCCURS 0,
        vbelv   TYPE vbfa-vbelv,
        posnv   TYPE vbfa-posnv,
        vbeln   TYPE vbfa-vbeln,
        posnn   TYPE vbfa-posnn,
        vbtyp_n TYPE vbfa-vbtyp_n,
        rfmng   TYPE vbfa-rfmng,
        meins   TYPE vbfa-meins,
        rfwrt   TYPE vbfa-rfwrt,
        waers   TYPE vbfa-waers,
        vbtyp_v TYPE vbfa-vbtyp_v,
        plmin   TYPE vbfa-plmin,
      END OF t_vbfa_b,
      BEGIN OF t_vbap_vapma OCCURS 0,
        matnr TYPE vbap-matnr,
        vbeln TYPE vbap-vbeln,
        posnr TYPE vbap-posnr,
        werks TYPE vbap-werks,
      END OF t_vbap_vapma,
      BEGIN OF t_vbak OCCURS 0,
        vbeln TYPE vbuk-vbeln,
        vbtyp TYPE vbuk-vbtyp,
*  vbelv TYPE
      END OF t_vbak,
      BEGIN OF t_vbap OCCURS 0,
        vbeln  TYPE vbap-vbeln,
        matnr  TYPE vbap-matnr,
        klmeng TYPE vbap-klmeng,
        ntgew  TYPE vbap-ntgew,
        werks  TYPE vbap-werks,
        lgort  TYPE vbap-lgort,
*Proceti2 10/JUN/2016
        angdt  TYPE vbak-angdt,    "Fecha de Oferta
*Proceti2 10/JUN/2016
      END OF t_vbap,
      BEGIN OF t_vbap_sum OCCURS 0,
*  vbeln TYPE vbap-vbeln,
        matnr  TYPE vbap-matnr,
        klmenb TYPE vbap-klmeng,
        klmenc TYPE vbap-klmeng,
        ntgew  TYPE vbap-ntgew,
*Proceti2 10/JUN/2016
        cothoy TYPE vbap-ntgew, "Cotizacion hoy
        cotma  TYPE vbap-ntgew, "Cotizacion mañana
        cotpas TYPE vbap-ntgew, "Cotizacion Pasado mañana
*Proceti2 10/JUN/2016
        werks  TYPE vbap-werks,
        lgort  TYPE vbap-lgort,
      END OF t_vbap_sum.

DATA:
  precio(08) TYPE p DECIMALS 7,
  stock      LIKE mbew-lbkum,
  valor      LIKE mbew-salk3.

DATA: it_toolbar_excludinggrid TYPE ui_functions,
      g_lvc_t_sort             TYPE lvc_t_sort,
      gt_fieldcat              TYPE TABLE OF lvc_s_fcat..
DATA: cc_grid            TYPE REF TO cl_gui_alv_grid,
      g_custom_container TYPE REF TO cl_gui_custom_container.

DATA: w_lvc_s_sort TYPE lvc_s_sort.
