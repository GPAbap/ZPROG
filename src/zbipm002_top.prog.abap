*&---------------------------------------------------------------------*
*& Include zbipm002_top
*&---------------------------------------------------------------------*

TABLES: zccomb, rimr0.


TYPES: BEGIN OF st_medidas,
         ID_Tipo_doc   TYPE zccomb-id_forori,
         ID_equipo     TYPE zccomb-id_vehiculo,
         fecha_consumo TYPE datum,
         hora_consumo  TYPE char10,
         odometro      TYPE zccomb-km_odometro,
         litros        TYPE zccomb-lt_consumo,
       END OF st_medidas.

"batch input controller
DATA bdc_data LIKE bdcdata OCCURS 0 WITH HEADER LINE.
DATA messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: l_messtab TYPE STANDARD TABLE OF bdcmsgcoll,
      w_messtab like LINE OF l_messtab.

DATA: l_mstring(480).
DATA: l_subrc LIKE sy-subrc.

DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
      ls_layout   TYPE slis_layout_alv.


DATA: it_consumos TYPE STANDARD TABLE OF st_medidas,
     wa_consumos LIKE LINE OF it_consumos.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS so_datum FOR  rimr0-dfdat.

SELECTION-SCREEN END OF BLOCK b1.
