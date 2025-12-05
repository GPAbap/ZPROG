*&---------------------------------------------------------------------*
*& Include zavafis_top
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.
TABLES: afko, aufk, afvv.

DATA obj_alv TYPE REF TO cl_alv_a_lvc.

TYPES:BEGIN OF st_jerarquia,
        header1 TYPE char30,
        header2 TYPE char30,
        kostl   TYPE kostl,
        ltext   TYPE ltext,
      END OF st_jerarquia,

      BEGIN OF st_acum_kostl,
        kostl TYPE kostl,
        arbei TYPE arbeit,
        ismnw TYPE ismnw,
        ofmnw TYPE ofmnw,
      END OF st_acum_kostl,

      BEGIN OF st_semanas,
        feini TYPE dats,
        fefin TYPE dats,
        nsem  TYPE i,
      END OF st_semanas.


DATA: it_jerarquia  TYPE STANDARD TABLE OF st_jerarquia,
      wa_jerarquia  LIKE LINE OF it_jerarquia,
      it_acum_kostl TYPE STANDARD TABLE OF st_acum_kostl,
      wa_acum_kostl LIKE LINE OF it_acum_kostl,
      it_semanas    TYPE STANDARD TABLE OF st_semanas,
      wa_semanas    LIKE LINE OF it_semanas.


DATA : cp_outparam TYPE          sfpoutputparams,
       ip_funcname TYPE          funcname.

DATA: st_header_mtto TYPE zst_header_mtto_mayor.
DATA it_outtable TYPE STANDARD TABLE OF zst_layout_mmto_mayor.

FIELD-SYMBOLS: <fs_struct> TYPE zst_layout_mmto_mayor,
               <fs_line>   TYPE any.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: so_aufnr FOR afko-aufnr.
  "so_gltrs FOR afko-gltrs OBLIGATORY.
  PARAMETERS: p_numsem TYPE i OBLIGATORY,
              p_sowrk  TYPE aufsowrk OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
