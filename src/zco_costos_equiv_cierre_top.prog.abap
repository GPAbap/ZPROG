*&---------------------------------------------------------------------*
*& Include          ZCO_COSTOS_EQUIV_CIERRE_TOP
*&---------------------------------------------------------------------*

TABLES: makg, makz, mseg, afko, afpo,t009b.

DATA: it_makg TYPE STANDARD TABLE OF zmakg,
      it_makz TYPE STANDARD TABLE OF zmakz,
      it_makz_final TYPE STANDARD TABLE OF makz,
      it_makg_final TYPE STANDARD TABLE OF makg.

DATA lv_objnr TYPE jsto-objnr.
DATA: it_aufnr_end  TYPE STANDARD TABLE OF zco_tt_aufnr_fin.

data vg_seguir type sy-subrc.

TYPES: BEGIN OF st_mseg,
         aufnr       TYPE aufnr,
         plnbez      TYPE matnr,
         matnr       TYPE matnr,
         menge       TYPE menge_d,
         subtotal    type menge_d,
         super_total TYPE menge_d,
         ziffr       TYPE aequi,
       END OF st_mseg.


TYPES: BEGIN OF st_mseg_acum,
         plnbez      TYPE matnr,
         matnr       TYPE matnr,
         menge       TYPE menge_d,
         subtotal    type menge_d,
         super_total TYPE menge_d,
         ziffr       TYPE aequi,
         total       type aequi,
       END OF st_mseg_acum.


DATA it_mseg TYPE STANDARD TABLE OF st_mseg.
DATA it_mseg_acum TYPE STANDARD TABLE OF st_mseg_acum.
DATA it_mseg_final TYPE STANDARD TABLE OF st_mseg_acum.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_gjahr TYPE gjahr OBLIGATORY,
              p_poper type poper OBLIGATORY.



SELECTION-SCREEN END OF BLOCK b1.
