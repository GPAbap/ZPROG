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
       END OF tys_bseg_tot.

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


DATA it_ingresos_union TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_ingresos_rv TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_ingresos TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_inversiones TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_inversionesadd TYPE STANDARD TABLE OF zfi_st_egresos.
DATA it_ordenainvers TYPE STANDARD TABLE OF zfi_st_egresos.




SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-020 .
  PARAMETERS: s_bukrs TYPE bukrs OBLIGATORY.
  PARAMETERS  p_gjahr TYPE bkpf-gjahr OBLIGATORY.
  SELECT-OPTIONS:  S_monat FOR bkpf-monat OBLIGATORY,
  s_CPUDT FOR bkpf-cpudt ,
  s_budat FOR bkpf-budat.
  SELECT-OPTIONS: s_belnr FOR bkpf-belnr,
                  s_WAERS FOR bkpf-waers.


  SELECTION-SCREEN SKIP .

  PARAMETERS: p_conta RADIOBUTTON GROUP g1,
              p_conci RADIOBUTTON GROUP g1,
              p_cocon RADIOBUTTON GROUP g1.


SELECTION-SCREEN END OF BLOCK b2.
