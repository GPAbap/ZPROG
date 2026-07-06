*&---------------------------------------------------------------------*
*& Include          ZMM_RE_OC_DETALLE_FUN
*&---------------------------------------------------------------------*

FORM get_data.

  SELECT z1~mjahr, z1~lifnr, z1~conse, z1~ebeln,
         z1~erdat, z1~erzet, z1~ernam, z1~emaie, z1~emaif, z1~emaih, z1~emaiu,
         z2~ebelp,z2~matnr, z2~csur,l~name1 as nom_prov, m~maktx as nom_mat
    INTO CORRESPONDING FIELDS OF  TABLE @it_outtable
FROM zmmt001 AS z1
INNER JOIN zmmt003 AS z2 ON z2~ebeln = z1~ebeln and z2~mjahr eq z1~mjahr
          and z2~conse eq z1~conse
INNER JOIN lfa1 AS l ON l~lifnr EQ z1~lifnr
INNER JOIN makt AS m ON m~matnr EQ z2~matnr
WHERE z1~mjahr EQ @p_mjahr AND
    z1~lifnr IN @s_lifnr AND
    z1~conse IN @s_consec AND
    z1~ebeln IN @s_ebeln AND
    z1~erdat IN @s_erdat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .

 TRY.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = it_outtable
      ).

*---------------------------------------------------
* ACTIVAR FUNCIONES STANDARD
*---------------------------------------------------
      go_alv->get_functions( )->set_all( abap_true ).

*---------------------------------------------------
* CONFIGURAR LAYOUTS
*---------------------------------------------------
      go_layout = go_alv->get_layout( ).

      gs_key-report = sy-repid.

      go_layout->set_key( gs_key ).

* Permitir guardar layouts
      go_layout->set_save_restriction(
        if_salv_c_layout=>restrict_none
      ).

* Layout por defecto
      go_layout->set_default( abap_true ).

*Eliminamos Mandt
lo_columns = go_alv->get_columns( ).

TRY.
    lo_column = lo_columns->get_column( 'MANDT' ).
    lo_column->set_visible( abap_false ).
  CATCH cx_salv_not_found.
ENDTRY.

*---------------------------------------------------
* MOSTRAR ALV
*---------------------------------------------------
      go_alv->display( ).

    CATCH cx_salv_msg INTO DATA(lx_msg).
      MESSAGE lx_msg->get_text( ) TYPE 'E'.

  ENDTRY.


ENDFORM.
