*----------------------------------------------------------------------*
*                        B A Y C O                                     *
*----------------------------------------------------------------------*
* Proyecto      : Reporte de incidencias de la HH                      *
* Requerimiento :                                                      *
* Programa      : ZSDRE_CINV01                                         *
* Creado por    : Roberto Bautista Dominguez                           *
* F de creacion : 05/09/2017                                           *
* Descripcion   : Reporte de incidencias por HH                        *
* Transporte    :                                                      *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                       Log de modificaciones
*----------------------------------------------------------------------*
* Modified by    : <Nombre_desarrollador>                              *
* Requerimiento  : <ID_req_modificacion>                               *
* Modificado por : <Nombre_desarrollador> <User>                       *
* Fecha          : <DD/MM/YYYY>                                        *
* Descripcion    : Descripcion de la modificacion                      *
* Transporte     : <Orden_transporte>                                  *
*----------------------------------------------------------------------*
REPORT  zsdre_cinv01.

* ==================================================================== *
* Tablas
TABLES:
  zhuinv_post.
* ==================================================================== *
* Tipos

* ==================================================================== *
* Tablas
DATA:
  tg_alv       TYPE STANDARD TABLE OF zhuinv_post.

* ==================================================================== *
* Estructuras

* ==================================================================== *
* Variables globales

* ==================================================================== *
* Parametros de selección
SELECTION-SCREEN BEGIN OF BLOCK bk1 WITH FRAME TITLE text-t01.
* ==================================================================== *

SELECT-OPTIONS:
  so_huinv  FOR zhuinv_post-huinv_nr,
  so_inven  FOR zhuinv_post-inventory,
  so_w_inv  FOR zhuinv_post-werks_inv,
  so_l_inv  FOR zhuinv_post-lgort_inv,
  so_exidv  FOR zhuinv_post-exidv,
  so_matnr  FOR zhuinv_post-matnr,
  so_charg  FOR zhuinv_post-charg,
  so_statu  FOR zhuinv_post-status,
  so_w_hu   FOR zhuinv_post-werks_hu,
  so_l_hu   FOR zhuinv_post-lgort_hu.
SELECTION-SCREEN BEGIN OF BLOCK bk2 WITH FRAME TITLE text-t02.

PARAMETERS:
  cb_test AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK bk2.
* ==================================================================== *
SELECTION-SCREEN END OF BLOCK bk1.
* ==================================================================== *

* ==================================================================== *
START-OF-SELECTION.
* ==================================================================== *

  PERFORM f_read_data.
  PERFORM f_reporte.

* ==================================================================== *
END-OF-SELECTION.
* ==================================================================== *


*======================================================================*
*                R   u     t     i    n     a     s
*======================================================================*


************************************************************************
* Proyecto...: MEDIX                                                   *
* Rutina.....: F_READ_DATA                                             *
* Descripción: Leer los datos                                          *
* Fecha......: 19/04/2016                                              *
* Autor......: Roberto Bautista Dominguez                              *
************************************************************************
FORM f_read_data.

  SELECT * INTO TABLE tg_alv
    FROM zhuinv_post
   WHERE huinv_nr  IN so_huinv
     AND inventory IN so_inven
     AND werks_inv IN so_w_inv
     AND lgort_inv IN so_l_inv
     AND exidv     IN so_exidv
     AND matnr     IN so_matnr
     AND charg     IN so_charg
     AND status    IN so_statu
     AND werks_hu  IN so_w_hu
     AND lgort_hu  IN so_l_hu.


ENDFORM.                    "f_read_data
***********************************************************************
* Proyecto...: Vuelo M15                                              *
* Rutina.....: F_REP3                                                 *
* Descripción: Ver reporte                                            *
* Fecha......: 19/04/2016                                             *
* Autor......: Roberto Bautista Dominguez                             *
***********************************************************************
FORM f_reporte.

  DATA:
    vl_alv    TYPE REF TO cl_salv_table,
    vl_layout TYPE REF TO cl_salv_layout,
    vl_key    TYPE        salv_s_layout_key.

  DATA:
    vl_columns TYPE REF TO cl_salv_columns_table,
    vl_column  TYPE REF TO cl_salv_column_table,
    vl_funct   TYPE REF TO cl_salv_functions_list.

  IF cb_test = space.
    DATA vl_ans TYPE C.
    PERFORM f0050_mensaje USING TEXT-m04 CHANGING vl_ans.
    IF vl_ans = '1'.

      DELETE zhuinv_post FROM TABLE tg_alv.
      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE s208(00) WITH TEXT-s01.
      ENDIF.
    ENDIF.

  ENDIF.

  CLEAR: vl_alv.

  TRY .

      cl_salv_table=>factory(
      IMPORTING
        r_salv_table   = vl_alv
      CHANGING
        t_table        = tg_alv ).

      vl_columns = vl_alv->get_columns( ).
      vl_columns->set_optimize( abap_true ).
      vl_key-report = sy-repid .
      vl_layout     = vl_alv->get_layout( ) .
      vl_layout->set_key( vl_key ).
      vl_layout->set_save_restriction(
      if_salv_c_layout=>restrict_none ).
      vl_funct = vl_alv->get_functions( ).
      vl_funct->set_all( abap_true ).
      vl_alv->display( ).

    CATCH cx_salv_msg.    " ALV: General Error Class with Message

  ENDTRY.

ENDFORM.                    " F_VER_REPORTE
*&---------------------------------------------------------------------*
*&      Form  f0050_mensaje
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->X_TEXT     text
*      <--X_ANS      text
*----------------------------------------------------------------------*
FORM f0050_mensaje USING x_text TYPE any
                CHANGING x_ans  TYPE any.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '¡¡¡¡¡¡¡¡¡¡ P R E C A U C I O N !!!!!!!!!!'
      text_question         = x_text
      text_button_1         = text-m01
      icon_button_1         = space
      text_button_2         = text-m02
      icon_button_2         = space
      default_button        = '2'
      display_cancel_button = space
      start_column          = 25
      start_row             = 6
    IMPORTING
      answer                = x_ans
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF sy-subrc NE 0.
    RETURN.
  ENDIF.
ENDFORM.                    "f0050_mensaje
