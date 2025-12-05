*&---------------------------------------------------------------------*
*& Include zmm_re_pa_cbr_jhv_top
*&---------------------------------------------------------------------*

TABLES: t001w, mara, mseg,marc.

data it_data type STANDARD TABLE OF ZPP_ST_PLANTA_ALIMENTO.

DATA: t_mrp_stock_detail TYPE bapi_mrp_stock_detail,
      t_mrp_list         TYPE bapi_mrp_list,
      t_mrp_ind_lines    type STANDARD TABLE OF bapi_mrp_ind_lines,
      t_return           TYPE STANDARD TABLE OF bapiret2,
      wmdvsx             TYPE STANDARD TABLE OF bapiwmdvs,
      wmdvex             TYPE STANDARD TABLE OF bapiwmdve.


  TYPE-POOLS: slis.

  DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fieldcat TYPE slis_fieldcat_alv,
        ls_layout type slis_layout_alv.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: so_werks FOR t001w-werks OBLIGATORY,
                  so_matnr FOR mara-matnr ,
                  so_dispo for marc-dispo OBLIGATORY NO INTERVALS DEFAULT 'MP3',
                  so_budat FOR mseg-budat_mkpf OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

  PARAMETERS p_dias TYPE p LENGTH 2 DECIMALS 0 OBLIGATORY DEFAULT 1.

SELECTION-SCREEN END OF BLOCK b2.
