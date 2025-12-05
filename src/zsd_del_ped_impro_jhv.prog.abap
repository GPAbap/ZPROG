*&---------------------------------------------------------------------*
*& Report ZSD_DEL_PED_IMPRO_JHV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsd_del_ped_impro_jhv.
INCLUDE zsd_del_ped_impro_jhv_top.
INCLUDE zsd_del_ped_impro_jhv_fun.


START-OF-SELECTION.

  PERFORM get_data.

  IF it_pedidos IS NOT INITIAL.
    perform show_alv.
  ENDIF.
