*&---------------------------------------------------------------------*
*& Include          ZBIPM001_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

TYPES: BEGIN OF st_f4_values,
         Tipo        TYPE char1,
         descripcion TYPE txt20,
       END OF st_f4_values.
DATA: lt_s_color TYPE lvc_t_scol,
      ls_s_color TYPE lvc_s_scol.

INCLUDE <color>.


DATA: it_f4_values TYPE STANDARD TABLE OF st_f4_values,
      wa_f4_values LIKE LINE OF it_f4_values.

DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
      ls_layout   TYPE slis_layout_alv.

DATA: obj_upload TYPE REF TO zcl_upload_xls.

DATA: it_interno      TYPE STANDARD TABLE OF zccomb_st_autoc,
      it_e_tarjeta    TYPE STANDARD TABLE OF zccomb_st_consum_tarjeta,
      it_e_sintarjeta TYPE STANDARD TABLE OF zccomb_st_consum_sin_tarjeta,
      it_outtable     TYPE TABLE OF zccomb,
      wa_outtable     type zccomb.


TYPES: BEGIN OF st_autoconsumo.
TYPES: fe_carmas    TYPE zFE_CARMAS.
TYPES: hr_carmas    TYPE zHR_CARMAS.
TYPES: id_forori    TYPE zID_FORORI.
TYPES: cv_sociedad  TYPE bukrs.
       INCLUDE  STRUCTURE    zccomb_st_autoc.
TYPES: rg_procesado TYPE zRG_PROCESADO.
TYPES: tcolor TYPE slis_t_specialcol_alv.
TYPES:  END OF st_autoconsumo.


TYPES: BEGIN OF st_contarjeta.
TYPES: fe_carmas    TYPE zFE_CARMAS.
TYPES: hr_carmas    TYPE zHR_CARMAS.
TYPES: id_forori    TYPE zID_FORORI.
TYPES: cv_sociedad  TYPE bukrs.
       INCLUDE  STRUCTURE zccomb_st_consum_tarjeta.
TYPES: rg_procesado TYPE zRG_PROCESADO.
TYPES: tcolor TYPE slis_t_specialcol_alv.
TYPES:  END OF st_contarjeta.

TYPES: BEGIN OF st_sintarjeta.
TYPES: fe_carmas    TYPE zFE_CARMAS.
TYPES: hr_carmas    TYPE zHR_CARMAS.
TYPES: id_forori    TYPE zID_FORORI.
TYPES: cv_sociedad  TYPE bukrs.
       INCLUDE  STRUCTURE zccomb_st_consum_sin_tarjeta.
TYPES: rg_procesado TYPE zRG_PROCESADO.
TYPES: tcolor TYPE slis_t_specialcol_alv.
TYPES:  END OF st_sintarjeta.

DATA: it_autoconsumo TYPE STANDARD TABLE OF st_autoconsumo,
      wa_autoconsumo LIKE LINE OF it_autoconsumo,
      it_contarjeta  TYPE STANDARD TABLE OF st_contarjeta,
      wa_contarjeta  LIKE LINE OF it_contarjeta,
      it_sintarjeta  TYPE STANDARD TABLE OF st_sintarjeta,
      wa_sintarjeta  LIKE LINE OF it_sintarjeta.

data: xcolor type slis_specialcol_alv.

data lv_flag_error.


START-OF-SELECTION.
  PARAMETERS: p_file   TYPE localfile OBLIGATORY,
              p_format TYPE char1 OBLIGATORY, "<Formato: A de autoconsumo, T de tarjeta y S de sin tarjeta>
              p_bukrs  TYPE bukrs OBLIGATORY.
