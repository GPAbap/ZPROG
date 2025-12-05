*&---------------------------------------------------------------------*
*& Include          ZCO_RE_CKMCCD_TOP
*&---------------------------------------------------------------------*
TYPE-pools SLIS.
tables: mara, makt, t001w,mlccskey.


types: BEGIN OF st_ckml,
       werks type werks_d,
       name1 type name1.
       INCLUDE STRUCTURE CKML_MANCHANG_CCS_GRID.
TYPES END OF st_ckml.

Data: rg_werks type RANGE OF t001w-werks,
      wrg_werks like line of rg_werks.



data: it_ckml type STANDARD TABLE OF  st_ckml,
      ls_ckml like LINE OF it_ckml.

data: gt_fieldcat type slis_t_fieldcat_alv,
      wa_fieldcat type slis_fieldcat_alv,
      gl_layout type slis_layout_alv,
      gt_sort type STANDARD TABLE OF  slis_sortinfo_alv,
      ls_sort type slis_sortinfo_alv.


data: ls_marv TYPE marv,
      gs_wwo TYPE cki_wwo_ml,
      ls_t001w type t001w,
      lt_kalnr TYPE ckmv0_matobj_tbl,
      ls_kalnr TYPE ckmv0_matobj_str,
      lr_keart          TYPE ckmv0_yt_keart,
      lr_mlcct          TYPE ckmv0_yt_mlcct,
      lr_kkzst          TYPE ckmv0_yt_kkzst,
      lt_keph_mlcd      TYPE ccs01_t_keph_mlcd,
      lt_mlcd            TYPE ckmcd_t_mlcd,
      mt_tckh3          TYPE STANDARD TABLE OF tckh3,
      mt_tckh1          TYPE STANDARD TABLE OF tckh1,
      ls_tckh8          LIKE tckh8,
      ls_tckh3          LIKE tckh3,
      lt_tckh3          LIKE TABLE OF tckh3,
      l_elehk TYPE ck_elesmhk.

data: mt_curtp TYPE cki_ml_cty OCCURS 0 WITH HEADER LINE,
      gt_ckmlkeph TYPE mlccs_t_keph.

  DATA: BEGIN OF ls_name,
          text(3)   TYPE c VALUE 'KST',
          number(3) TYPE n,
        END OF ls_name.

*TYPES: BEGIN OF ty_grid.
*        INCLUDE TYPE ckml_manchang_ccs_grid.
*END OF ty_grid.

data:   ls_grid_data_sum TYPE ckml_manchang_ccs_grid,
        ls_grid_data_sum_delta type ckml_manchang_ccs_grid.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

  PARAMETERS p_matnr type matnr OBLIGATORY.
  SELECT-OPTIONS  so_werks for t001w-werks OBLIGATORY.
  PARAMETERS: p_poper type poper OBLIGATORY,
              p_gjahr type gjahr OBLIGATORY .
SELECTION-SCREEN END OF BLOCK b1.
