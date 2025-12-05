*&---------------------------------------------------------------------*
*& Include          ZSD_RE_VENTASPOLLO_SS
*&---------------------------------------------------------------------*


START-OF-SELECTION.

  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

    SELECT-OPTIONS: so_vkorg FOR vbak-vkorg DEFAULT 'AV01',
                    so_spart FOR vbak-spart DEFAULT '01',
                    so_erdat for vbak-erdat DEFAULT sy-datum OBLIGATORY.


  SELECTION-SCREEN END OF BLOCK b1.
  SELECTION-SCREEN SKIP 1.

  PERFORM get_data.
  PERFORM create_fieldcat.
  PERFORM show_alv.
