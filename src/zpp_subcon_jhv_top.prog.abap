*&---------------------------------------------------------------------*
*& Include zpp_subcon_jhv_top
*&---------------------------------------------------------------------*

TYPE-POOLS slis.
DATA : l_aufnr TYPE aufnr,
       l_ebeln TYPE ebeln,
       l_budat TYPE budat,
       lt_tab  TYPE TABLE OF zpp_tf_jhv_subcon,
       l_where TYPE string.

DATA lo_alv               TYPE REF TO cl_salv_table.


DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      st_fieldcat TYPE slis_fieldcat_alv,
      ls_layout   TYPE slis_layout_alv,
      it_sort     TYPE slis_t_sortinfo_alv,
      wa_sort     LIKE LINE OF it_sort.


SELECT-OPTIONS : s_aufnr FOR l_aufnr,
                s_ebeln FOR l_ebeln,
                s_budat FOR l_budat.
