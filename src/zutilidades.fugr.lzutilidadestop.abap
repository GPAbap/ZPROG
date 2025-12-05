FUNCTION-POOL ZUTILIDADES.                  "MESSAGE-ID ..  ........



* INCLUDE LZUTILIDADESD...                   " Local class definition


DATA : iheader_details TYPE abap_compdescr_tab,
      iitems_details  TYPE abap_compdescr_tab.
DATA : ref_table_des TYPE REF TO cl_abap_structdescr.
DATA: v_cant_lineas TYPE I,
      v_cant_lineasi TYPE I,
      contador      TYPE I,
      contador2     TYPE I,
      campo(50).

DATA: BEGIN OF v_rollname OCCURS 100.
  INCLUDE STRUCTURE dfies.
DATA: END OF v_rollname.

DATA: lv_campo_clave TYPE string,
      po_file        TYPE string.

DATA: lo_tabla TYPE REF TO DATA,
lo_linea  TYPE REF TO DATA,
lo_linea1 TYPE REF TO DATA.

DATA: lv_filas(8) TYPE n,
      lv_fname    TYPE lvc_fname.


DATA: lt_fcat TYPE lvc_t_fcat,
      ls_fcat LIKE LINE OF lt_fcat.


FIELD-SYMBOLS: <fs> TYPE ANY,
<fs_campo> TYPE ANY.

FIELD-SYMBOLS: <it_excel_alv> TYPE STANDARD TABLE,
<linea>        TYPE ANY,
<linea1>       TYPE ANY,
<linea2>       TYPE ANY,
<wa_excel_alv> TYPE ANY.
