*&---------------------------------------------------------------------*
*&  Include           Z_REP_INGRESOS_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

TYPES: BEGIN OF tys_bseg_tot,
         bukrs   TYPE bukrs,
         belnr   TYPE belnr_d,
         gjahr   TYPE gjahr,
         koart   TYPE koart,
         total   TYPE p DECIMALS 2,
         iva     TYPE p DECIMALS 2,
         iva_ret TYPE p DECIMALS 2,
         hkont   TYPE hkont,
         band    TYPE c,
         bschl   TYPE bschl,
       END OF tys_bseg_tot,

       BEGIN OF st_xml,
         doc_comp         TYPE belnr_d,
         doc_contable     TYPE zaxn_belnr_d,
         bukrs            type bukrs,
         gjahr            type gjahr,
         uuid             TYPE zaxnare_el032,
         metododepago     TYPE zaxnare_el042,
         formadepago      TYPE zaxnare_el043,
         total            TYPE zaxnare_el014,
         moneda           TYPE zwaers_sat,
         folio            TYPE zzfolio_sat,
         rfc_e            TYPE zaxnare_el009,
         xml_dir          TYPE zaxnare_el034,
         tipo_comprobante TYPE zaxnare_el031,
       END OF st_xml.



DATA: gt_bseg_tot TYPE TABLE OF tys_bseg_tot,
      gs_bseg_tot TYPE tys_bseg_tot.

DATA: gt_bkpf TYPE STANDARD TABLE OF bkpf.

DATA: gtext(100)  TYPE c,
      gtext2(100) TYPE c,
      gtext3(100) TYPE c.


*******Fieldcat
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      lf_layout   TYPE slis_layout_alv,    "Manejar diseño de layout
      t_sort      TYPE slis_t_sortinfo_alv.
DATA: gcl_xml       TYPE REF TO cl_xml_document.

DATA it_ingresos_union TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_ingresos_rv TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_ingresos TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_inversiones TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_inversionesadd TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_ordenainvers TYPE STANDARD TABLE OF zfi_st_egresos.

DATA: it_ZFI_XML_COMPLEM TYPE STANDARD TABLE OF zfi_xml_complem WITH NON-UNIQUE SORTED KEY pk COMPONENTS doc_comp doc_contable bukrs gjahr monat,
      wa_ZFI_XML_COMPLEM LIKE LINE OF it_ZFI_XML_COMPLEM,
      it_xml TYPE STANDARD TABLE OF st_xml WITH NON-UNIQUE SORTED KEY pk COMPONENTS doc_comp doc_contable bukrs gjahr,
      wa_xml like line of it_xml.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-020 .
  PARAMETERS: s_bukrs TYPE bukrs OBLIGATORY.
  PARAMETERS  p_gjahr TYPE bkpf-gjahr OBLIGATORY.
  SELECT-OPTIONS:  S_monat FOR bkpf-monat OBLIGATORY NO INTERVALS,
  s_CPUDT FOR bkpf-cpudt ,
  s_budat FOR bkpf-budat.
  SELECT-OPTIONS: s_belnr FOR bkpf-belnr.


  SELECTION-SCREEN SKIP .

  PARAMETERS: p_conta RADIOBUTTON GROUP g1,
              p_conci RADIOBUTTON GROUP g1,
              p_cocon RADIOBUTTON GROUP g1.


SELECTION-SCREEN END OF BLOCK b2.
