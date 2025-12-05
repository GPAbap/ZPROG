*&---------------------------------------------------------------------*
*& Include          ZCO_KBK6_MASS_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF st_tabla,
          periodoi(2)  TYPE c,
          periodof(2)  TYPE c,
          ejercicio(4) TYPE c,
          ceco(10)      TYPE c,
          actividad(6) TYPE c,
          importe(10)   TYPE c,
        END OF st_tabla.

DATA : it_tab TYPE TABLE OF alsmex_tabline WITH HEADER LINE,
       file   TYPE rlgrap-filename.

DATA : it_tabla TYPE STANDARD TABLE OF st_tabla,
      wa_tabla LIKE LINE OF it_tabla,
      w_message(100)  TYPE C.

"batch input controller
DATA bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE.
DATA messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: l_mstring(480).
DATA: l_subrc LIKE sy-subrc.

PARAMETERS: file_nm TYPE localfile,
            rb_real RADIOBUTTON GROUP r1 DEFAULT 'X' USER-COMMAND u1,
            rb_plan RADIOBUTTON GROUP r1,
            p_versn type versn MATCHCODE OBJECT H_TKVS.
