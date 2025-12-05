*&---------------------------------------------------------------------*
*& Report ZCONS_POST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpp_re_postura NO STANDARD PAGE HEADING.

INCLUDE zpp_re_postura_top.
*INCLUDE zcons_post_top.

INCLUDE zpp_re_postura_fn.
*INCLUDE zcons_post_fn.

INCLUDE zpp_re_postura_alv.
*INCLUDE zcons_post_alv.

AT SELECTION-SCREEN.
  PERFORM validate_werks CHANGING flag.

START-OF-SELECTION.

  IF flag IS INITIAL.
    PERFORM crear_alv.

    PERFORM CONSULTA_zcons_post.

    PERFORM Mostrar_alv.
  ELSE.
    CLEAR flag.
    REFRESH cen.
    MESSAGE 'Solo Centros de Crianza/Postura estan permitidos en este reporte' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
