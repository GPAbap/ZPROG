*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* 07032023
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_FUN01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  EXEC_AUTH_PRES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exec_auth_pres CHANGING p_ok TYPE i .

  DATA: lv_kostl TYPE kostl, lv_bukrs TYPE bukrs.
  DATA: tr_kostl TYPE RANGE OF kostl,
        wr_kostl LIKE LINE OF tr_kostl.

  DATA lv_lines TYPE i.

  DATA: name  TYPE vrm_id,
        list  TYPE vrm_values,
        value LIKE LINE OF list.

  CLEAR list. REFRESH list.
  name = 'ZCO_TT_AUTPRES-RESPONSABLE'.

  REFRESH it_pendientes.
  REFRESH it_usuario.

  PERFORM containers_free.

*&---------------------------------------------------------------------*
*          select para traer los datos a autorizar
*&---------------------------------------------------------------------*
  IF p_auth NE space.




    LOOP AT it_auth INTO wa_auth.
      CLEAR wr_kostl.
      wr_kostl-sign = 'I'.
      wr_kostl-option = 'EQ'.
      wr_kostl-low = wa_auth-kostl.
      APPEND wr_kostl TO tr_kostl.

    ENDLOOP.

    SELECT  h~idpres
    h~versn
    h~gjahr
    h~cveaut
    h~usuario
    h~fecha
    h~hora
    h~autorizado
    h~autorizador
    h~fechaaut
    h~horaaut
    h~comentario
    h~statustx
    FROM zco_tt_planpresh AS h
    INNER JOIN zco_tt_planpres AS p ON p~idpres = h~idpres
    INTO TABLE gt_zplanda
    WHERE h~autorizado NE 'X' AND h~autorizado NE 'C'
    AND p~bukrs EQ p_bukrs1 AND p~kostl IN tr_kostl
* Mary Guzmán 20240829
    AND p~gjahr = '2025'
    AND cecoaut NE 'X'
    .

    SORT gt_zplanda BY idpres fecha hora.
    DELETE ADJACENT DUPLICATES FROM gt_zplanda COMPARING idpres.

    LOOP AT gt_zplanda INTO wa_zplanda.
      IF wa_zplanda-gjahr IS INITIAL.
        SELECT SINGLE MAX( gjahr ) FROM zco_tt_planpres
        INTO wa_zplanda-gjahr
        WHERE idpres = wa_zplanda-idpres.
        MODIFY gt_zplanda FROM wa_zplanda TRANSPORTING gjahr
        WHERE idpres = wa_zplanda-idpres AND versn = wa_zplanda-versn.
      ENDIF.
    ENDLOOP.


    "Obtenemos los datos del usuario que registro la carga del presupuesto.

    "------------------------------------------------------------------------------
    SELECT u~bname name_text smtp_addr
    INTO TABLE it_usuario
    FROM user_addrp AS u
    INNER JOIN usr21 AS u21 ON u21~bname = u~bname
    INNER JOIN adr6 AS a ON a~persnumber = u21~persnumber AND a~addrnumber = u21~addrnumber
    .


*&---------------------------------------------------------------------*
*          Leemos los registros y los pasamos a otra tabla interna
*&---------------------------------------------------------------------*
    APPEND LINES OF gt_zplanda TO it_pendientes.
*&---------------------------------------------------------------------*
*          Contamos los registros para saber si proseguimos o no
*&---------------------------------------------------------------------*
    DESCRIBE TABLE it_pendientes
    LINES v_line_count.       "Contamos las lineas de la tabla interna

    IF ( v_line_count EQ 0 ). "Si la tabla interna trae 0 registros

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'     "Enviamos un mensaje
        EXPORTING
          titel     = 'Sin registros existentes'
          textline1 = 'No existen CeCos pendientes por autorizar para el usuario actual'.
*    EXIT.

    ENDIF.
    p_ok = v_line_count.
  ELSE.
    MESSAGE 'No hay usuario autorizador para ejecutar la operación' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " EXEC_AUTH_PRES
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_catalog .
  DATA ls_fcat TYPE lvc_s_fcat .
  REFRESH po_fieldcat.
* Casilla
  CLEAR ls_fcat.
  ls_fcat-col_pos   = 1.
  ls_fcat-coltext   = ''.
  ls_fcat-fieldname = 'FLAG'.
  ls_fcat-no_out    = ' '.
  ls_fcat-checkbox = c_check.   " print as checkbox
  ls_fcat-edit = c_check.       " make field open for input
  APPEND ls_fcat TO po_fieldcat.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = 2.
  ls_fcat-coltext   = 'SOLICITUD'.
  ls_fcat-fieldname = 'IDPRES'.
  ls_fcat-no_out    = ' '.
  ls_fcat-hotspot = 'X'.
  APPEND ls_fcat TO po_fieldcat.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = 2.
  ls_fcat-coltext   = 'VERSION'.
  ls_fcat-fieldname = 'VERSN'.
  ls_fcat-no_out    = ' '.
  ls_fcat-hotspot = 'X'.
  APPEND ls_fcat TO po_fieldcat.


  CLEAR ls_fcat.
  ls_fcat-col_pos   = 3.
  ls_fcat-coltext   = 'EJERCICIO'.
  ls_fcat-fieldname = 'GJAHR'.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO po_fieldcat.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = 4.
  ls_fcat-coltext   = 'Aut.'.
  ls_fcat-fieldname = 'CVEAUT'.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO po_fieldcat.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = 5.
  ls_fcat-coltext   = 'Usuario'.
  ls_fcat-fieldname = 'USUARIO'.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO po_fieldcat.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = 6.
  ls_fcat-coltext   = 'Fecha'.
  ls_fcat-fieldname = 'FECHA'.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO po_fieldcat.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = 7.
  ls_fcat-coltext   = 'Hora'.
  ls_fcat-fieldname = 'HORA'.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO po_fieldcat.

*  CLEAR ls_fcat.
*  ls_fcat-col_pos   = 8.
*  ls_fcat-coltext   = 'Estatus'.
*  ls_fcat-fieldname = 'AUTORIZADO'.
*  ls_fcat-no_out    = ' '.
*  APPEND ls_fcat TO po_fieldcat.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = 8.
  ls_fcat-coltext   = 'Estatus'.
  ls_fcat-fieldname = 'STATUSTX'.
  ls_fcat-no_out    = ''.
  ls_fcat-hotspot    = 'X'.
  APPEND ls_fcat TO po_fieldcat.

*  CLEAR ls_fcat.
*  ls_fcat-col_pos   = 8.
*  ls_fcat-coltext   = 'Autorizador'.
*  ls_fcat-fieldname = 'AUTORIZADOR'.
*  ls_fcat-no_out    = ' '.
*  APPEND ls_fcat TO po_fieldcat.
*
*  CLEAR ls_fcat.
*  ls_fcat-col_pos   = 9.
*  ls_fcat-coltext   = 'Fecha Aut.'.
*  ls_fcat-fieldname = 'FECHAAUT'.
*  ls_fcat-no_out    = ' '.
*  APPEND ls_fcat TO po_fieldcat.
*
*  CLEAR ls_fcat.
*  ls_fcat-col_pos   = 10.
*  ls_fcat-coltext   = 'Hora Aut.'.
*  ls_fcat-fieldname = 'HORAAUT'.
*  ls_fcat-no_out    = ' '.
*  APPEND ls_fcat TO po_fieldcat.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = 9.
  ls_fcat-coltext   = 'Comentarios'.
  ls_fcat-fieldname = 'COMENTARIO'.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO po_fieldcat.
ENDFORM.                    " FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  SHOW_PRESUPUESTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_FINAL_IDPRES  text
*----------------------------------------------------------------------*
FORM show_presupuesto USING p_wa_final_idpres p_wa_anio.
  REFRESH gt_zco_tt_planpres.

  DATA: tr_kostl TYPE RANGE OF kostl,
        wr_kostl LIKE LINE OF tr_kostl.

*
*  DATA: w_bukrs LIKE dynpread-fieldvalue,
*        w_ceco LIKE dynpread-fieldvalue.
*  DATA lv_kostl TYPE kostl.

*  CALL FUNCTION 'C14Z_DYNP_READ_FIELD'
*    EXPORTING
*      i_program      = sy-repid
*      i_dynpro       = sy-dynnr
*      i_fieldname    = 'ZCO_TT_AUTPRES-BUKRS'
*      i_flg_steploop = 'X'
*    CHANGING
*      e_value        = w_bukrs.
*
*  CALL FUNCTION 'C14Z_DYNP_READ_FIELD'
*    EXPORTING
*      i_program      = sy-repid
*      i_dynpro       = sy-dynnr
*      i_fieldname    = 'ZCO_TT_AUTPRES-KOSTL'
*      i_flg_steploop = 'X'
*    CHANGING
*      e_value        = w_ceco.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = w_kostl
*    IMPORTING
*      output = lv_kostl.

  LOOP AT it_auth INTO wa_auth.
    CLEAR wr_kostl.
    wr_kostl-sign = 'I'.
    wr_kostl-option = 'EQ'.
    wr_kostl-low = wa_auth-kostl.
    APPEND wr_kostl TO tr_kostl.
  ENDLOOP.

  SELECT * "exclusivo para la validación de datos que vienen desde el portal, y que los que se cargan por SAP.
  FROM zco_tt_planpres AS p
  INTO CORRESPONDING FIELDS OF TABLE gt_zco_tt_planpres
  WHERE idpres = p_wa_final_idpres
  AND gjahr = p_wa_anio
  AND bukrs = p_bukrs1
  AND kostl IN tr_kostl.


  " Hacemos query para traer el detalle

*  IF sy-subrc NE 0.
*    SELECT idpres kokrs bukrs kostl kstar matnr maktx twaer co_meinh preuni
*           prunmx wtg001 wtg002 wtg003 wtg004 wtg005 wtg006
*           wtg007 wtg008 wtg009 wtg010 wtg011 wtg012 wtgtot
*           meg001 meg002 meg003 meg004 meg005 meg006 meg007
*           meg008 meg009 meg010 meg011 meg012 megtot werks
*      FROM zco_tt_planpreso AS p
*
*      INTO CORRESPONDING FIELDS OF TABLE gt_zco_tt_planpres
*      WHERE idpres = p_wa_final_idpres.            " Hacemos query para traer el detalle
*  ENDIF.

  IF sy-subrc = 0.
    PERFORM field_catalog_details.            "Catalogo de campos
*    PERFORM set_layout_sp.               "Layout
*    PERFORM set_sort_detail.             "Detail AGOSTO 2021
    IF p_wa_final_idpres+0(1) EQ '9'.
      PERFORM update_data_itab USING gt_zco_tt_planpres
            'externo'.
      PERFORM update_totales_portal USING gt_zco_tt_planpres.
    ENDIF.
    PERFORM display_alv USING gt_zco_tt_planpres
          de_fieldcat
          'CCONTAINER101D'.
  ENDIF.

ENDFORM.                    " SHOW_PRESUPUESTO
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_catalog_details .

  DATA ls_fcat TYPE lvc_s_fcat .
  REFRESH de_fieldcat.
  DATA col TYPE i.

  col = 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Solicitud'.
  ls_fcat-fieldname = 'IDPRES'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Soc. CO'.
  ls_fcat-fieldname = 'KOKRS'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Sociedad'.
  ls_fcat-fieldname = 'BUKRS'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Centro'.
  ls_fcat-fieldname = 'WERKS'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Centro Coste'.
  ls_fcat-fieldname = 'KOSTL'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Clase Coste'.
  ls_fcat-fieldname = 'KSTAR'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Num. Material'.
  ls_fcat-fieldname = 'MATNR'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Desc. Material'.
  ls_fcat-fieldname = 'MAKTX'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Prec. Unit.'.
  ls_fcat-fieldname = 'PREUNI'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Prec. Unit. Pres'.
  ls_fcat-fieldname = 'PREUNIPRES'.
  ls_fcat-key    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Precio Mon.'.
  ls_fcat-fieldname = 'PRUNMX'.
  ls_fcat-no_out    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'UMB'.
  ls_fcat-fieldname = 'CO_MEINH'.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'Moneda'.
  ls_fcat-fieldname = 'TWAER'.
  ls_fcat-no_out    = ' '.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.
  "-----Cantidades
  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Enero'.
  ls_fcat-fieldname = 'MEG001'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Febrero'.
  ls_fcat-fieldname = 'MEG002'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Marzo'.
  ls_fcat-fieldname = 'MEG003'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Abril'.
  ls_fcat-fieldname = 'MEG004'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Mayo'.
  ls_fcat-fieldname = 'MEG005'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Junio'.
  ls_fcat-fieldname = 'MEG006'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Julio'.
  ls_fcat-fieldname = 'MEG007'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Agosto'.
  ls_fcat-fieldname = 'MEG008'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Septiembre'.
  ls_fcat-fieldname = 'MEG009'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Octubre'.
  ls_fcat-fieldname = 'MEG010'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Noviembre'.
  ls_fcat-fieldname = 'MEG011'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Diciembre'.
  ls_fcat-fieldname = 'MEG012'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = 'C. Total'.
  ls_fcat-fieldname = 'MEGTOT'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.
*-------------------------
  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Enero'.
  ls_fcat-fieldname = 'WTG001'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Febrero'.
  ls_fcat-fieldname = 'WTG002'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Marzo'.
  ls_fcat-fieldname = 'WTG003'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Abril'.
  ls_fcat-fieldname = 'WTG004'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Mayo'.
  ls_fcat-fieldname = 'WTG005'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Junio'.
  ls_fcat-fieldname = 'WTG006'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Julio'.
  ls_fcat-fieldname = 'WTG007'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Agosto'.
  ls_fcat-fieldname = 'WTG008'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Septiembre'.
  ls_fcat-fieldname = 'WTG009'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Octubre'.
  ls_fcat-fieldname = 'WTG010'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Noviembre'.
  ls_fcat-fieldname = 'WTG011'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Diciembre'.
  ls_fcat-fieldname = 'WTG012'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.

  CLEAR ls_fcat.
  ls_fcat-col_pos   = col.
  ls_fcat-coltext   = '$ Total'.
  ls_fcat-fieldname = 'WTGTOT'.
  ls_fcat-no_out    = ' '.
  ls_fcat-do_sum    = 'X'.
  APPEND ls_fcat TO de_fieldcat. col = col + 1.



ENDFORM.                    " FIELD_CATALOG_DETAILS
*&---------------------------------------------------------------------*
*&      Form  GET_IDPRES_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      <--P_<LFS_IT>  text
*----------------------------------------------------------------------*
FORM get_idpres_sel  USING    p_e_row_id TYPE any
CHANGING p_lfs_it TYPE any.

  FIELD-SYMBOLS: <lfs_it> TYPE any,
                 <ls_aux> TYPE any.
  READ TABLE it_pendientes ASSIGNING <lfs_it> INDEX  p_e_row_id.
  IF sy-subrc EQ 0.
    ASSIGN COMPONENT 'AUTORIZADO' OF STRUCTURE <lfs_it> TO <ls_aux>.
    IF <ls_aux> EQ 'T'.
      MESSAGE 'Aún hay CeCos por autorizar para este usuario.'
      TYPE 'S' DISPLAY LIKE 'W'.
      p_lfs_it = <lfs_it>.
    ELSEIF <ls_aux> EQ 'X'.
      MESSAGE 'Ha autorizado todos los CeCos de esta sociedad. Ya no hay CeCos pendientes por autorizar'
      TYPE 'S' DISPLAY LIKE 'W'.
      "CLEAR <lfs_it>.
    ELSE.
      p_lfs_it = <lfs_it>.
    ENDIF.

  ENDIF.


ENDFORM.                    " GET_IDPRES_SEL
*&---------------------------------------------------------------------*
*&      Form  CANCEL_IDPRES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cancel_idpres .
* define local data
  DATA: ls_row  TYPE lvc_s_row,
        lt_rows TYPE lvc_t_row.
  DATA: lv_body   TYPE string, lv_asunto TYPE string,
        lv_smtp   TYPE string.

  it_arma[] = it_pendientes[].
  DELETE it_arma WHERE flag NE 'X'.

  LOOP AT it_arma INTO wa_arma.

    READ TABLE it_usuario INTO wa_usuario WITH KEY bname = wa_arma-usuario.

    UPDATE zco_tt_planpresh SET autorizado = 'C', autorizador = @sy-uname,
                            fechaaut = @sy-datum, horaaut = @sy-uzeit,
                            statustx = 'Cancelado'
                            WHERE idpres = @wa_arma-idpres.

    UPDATE zco_tt_planpres SET tipmod = 'O'  autorizado = 'F'  WHERE idpres = wa_arma-idpres.

    CONCATENATE 'Buen día ' wa_usuario-name_text '.El presupuesto con ID: ' wa_arma-idpres ' ha sido cancelado. '
    INTO lv_body SEPARATED BY space.

    CONCATENATE 'Atención ' wa_usuario-name_text   INTO lv_asunto SEPARATED BY space.

    lv_smtp = wa_usuario-smtp_addr.

  ENDLOOP.

ENDFORM.                    " CANCEL_IDPRES
*&---------------------------------------------------------------------*
*&      Form  AUTORIZAR_SELECCIONADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ARMA_IDPRES  text
*----------------------------------------------------------------------*
FORM autorizar_seleccionados  USING    p_wa_arma_idpres
      p_ok.
  DATA: i_rku01_cur LIKE rku01_cur, "Interfase de planif.: grupos de campos de moneda traspasados
        itrku01g    TYPE TABLE OF rku01g WITH HEADER LINE, "Traspaso de datos CO: Interfase costes con valores totales
        irku01ja    TYPE TABLE OF rku01ja WITH HEADER LINE. "Traspaso de datos CO: Interfase costes por año

  DATA: headerinfo     LIKE bapiplnhdr,
        indexstructure LIKE bapiacpstru OCCURS 0 WITH HEADER LINE,
        coobject       LIKE bapipcpobj OCCURS 0 WITH HEADER LINE,
        pervalue       LIKE bapipcpval OCCURS 0 WITH HEADER LINE,
        return         LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  DATA: lv_bukrs     TYPE bukrs, lv_kostl TYPE kostl,lv_lines TYPE i, lv_indicador,
        lv_statustx  TYPE char20.
  DATA: tr_kostl TYPE RANGE OF kostl,
        wr_kostl LIKE LINE OF tr_kostl.

  DATA: indice TYPE obj_indx.
  FIELD-SYMBOLS: <itab> TYPE STANDARD TABLE,
                 <wa>   TYPE any.

  REFRESH: itrku01g,
  irku01ja,
  it_zco_tt_logpres, "log de resultados
  it_posiciones,
  it_collect,
  indexstructure,
  coobject,
  pervalue.

  indice = '000000'.

  IF p_wa_arma_idpres+0(1) EQ '9' . "SUBIDAS POR EL PORTAL
    UPDATE zco_tt_planpres SET tipmod = 'F',versn = '000' WHERE idpres =  @p_wa_arma_idpres.
  ENDIF.

  SELECT SINGLE bukrs INTO p_bukrs1 FROM zco_tt_planpres WHERE idpres =  p_wa_arma_idpres.


  LOOP AT it_auth INTO wa_auth.
    CLEAR wr_kostl.
    wr_kostl-sign = 'I'.
    wr_kostl-option = 'EQ'.
    wr_kostl-low = wa_auth-kostl.
    APPEND wr_kostl TO tr_kostl.
  ENDLOOP.


  SELECT *
  FROM zco_tt_planpres
  INTO CORRESPONDING FIELDS OF TABLE it_posiciones
  WHERE idpres =  p_wa_arma_idpres
  AND tipo = 'ORDEN'
  AND tipmod = 'F'
  AND bukrs = p_bukrs1
  AND kostl IN tr_kostl
  .

  SORT it_posiciones BY aufnr kstar DESCENDING.

  LOOP AT it_posiciones INTO wa_posiciones.
**** INICIO BAPI DE CARGA DE ORDEN  ***********************
    REFRESH itrku01g.
    irku01ja-kstar    = wa_posiciones-kstar.              "must be filled
    irku01ja-aufnr    = wa_posiciones-aufnr.
    irku01ja-perab     = 1.
    irku01ja-perbi     = 12.
    irku01ja-wtg001   = wa_posiciones-wtg001.                "value when planning
    irku01ja-wkg001   = wa_posiciones-wtg001.                "value when planning
    irku01ja-wog001   = wa_posiciones-wtg001."value when planning

    irku01ja-wtg002   = wa_posiciones-wtg002.                "value when planning
    irku01ja-wkg002   = wa_posiciones-wtg002.                "value when planning
    irku01ja-wog002   = wa_posiciones-wtg002."value when planning

    irku01ja-wtg003   = wa_posiciones-wtg003.                "value when planning
    irku01ja-wkg003   = wa_posiciones-wtg003.                "value when planning
    irku01ja-wog003   = wa_posiciones-wtg003."value when planning

    irku01ja-wtg004   = wa_posiciones-wtg004.                "value when planning
    irku01ja-wkg004   = wa_posiciones-wtg004.                "value when planning
    irku01ja-wog004   = wa_posiciones-wtg004."value when planning

    irku01ja-wtg005   = wa_posiciones-wtg005.                "value when planning
    irku01ja-wkg005   = wa_posiciones-wtg005.                "value when planning
    irku01ja-wog005   = wa_posiciones-wtg005."value when planning

    irku01ja-wtg006   = wa_posiciones-wtg006.                "value when planning
    irku01ja-wkg006   = wa_posiciones-wtg006.                "value when planning
    irku01ja-wog006   = wa_posiciones-wtg006."value when planning

    irku01ja-wtg007   = wa_posiciones-wtg007.                "value when planning
    irku01ja-wkg007   = wa_posiciones-wtg007.                "value when planning
    irku01ja-wog007   = wa_posiciones-wtg007."value when planning

    irku01ja-wtg008   = wa_posiciones-wtg008.                "value when planning
    irku01ja-wkg008   = wa_posiciones-wtg008.                "value when planning
    irku01ja-wog008   = wa_posiciones-wtg008."value when planning

    irku01ja-wtg009   = wa_posiciones-wtg009.                "value when planning
    irku01ja-wkg009   = wa_posiciones-wtg009.                "value when planning
    irku01ja-wog009   = wa_posiciones-wtg009."value when planning

    irku01ja-wtg010   = wa_posiciones-wtg010.                "value when planning
    irku01ja-wkg010   = wa_posiciones-wtg010.                "value when planning
    irku01ja-wog010   = wa_posiciones-wtg010."value when planning

    irku01ja-wtg011   = wa_posiciones-wtg011.                "value when planning
    irku01ja-wkg011   = wa_posiciones-wtg011.                "value when planning
    irku01ja-wog011   = wa_posiciones-wtg011."value when planning

    irku01ja-wtg012   = wa_posiciones-wtg012.                "value when planning
    irku01ja-wkg012   = wa_posiciones-wtg012.                "value when planning
    irku01ja-wog012   = wa_posiciones-wtg012."value when planning

    irku01ja-twaer    = 'MXN'.              "transaction currency
    irku01ja-fcwkg    = '1'.           "distribution key must be filled
    irku01ja-fcwkf    = '1'.                  "must be filled
    irku01ja-fcwkv    = '1'.                  "must be filled
    irku01ja-fcmeg    = '1'.                  "must be filled
    irku01ja-fcmef    = '1'.                  "must be filled
    irku01ja-fcmev    = '1'.                  "must be filled

    COLLECT irku01ja.
    i_rku01_cur-wtg_man = 'X'.
    i_rku01_cur-wtf_man = 'X'.
  ENDLOOP.
***************** EMPAQUETADO DE ESTANDAR DE ORDEN ******************
  IF irku01ja[] IS NOT INITIAL.

    CALL FUNCTION 'K_COSTS_PLAN_INTERFACE_PERIOD'
      EXPORTING
        commit           = 'X'
        gjahr            = wa_posiciones-gjahr
        kokrs            = wa_posiciones-kokrs
        messages_show    = 'X'
        perab            = 1 "p_perab
        perbi            = 12 "p_perbi
        update_values    = 'X'
        versn            = wa_posiciones-versn
        vrgng            = 'RKP1'
        irku01_cur       = i_rku01_cur
      TABLES
        irku01ja         = irku01ja
      EXCEPTIONS
        messages_occured = 1
        OTHERS           = 2.

    REFRESH  itrku01g.

    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      IF sy-subrc = 0.

        IF wa_posiciones-idpres NE space.
          wa_zco_tt_logpres-datum = sy-datum.
          wa_zco_tt_logpres-uzeit = sy-uzeit.
          wa_zco_tt_logpres-idpres = wa_posiciones-idpres.
          wa_zco_tt_logpres-message = 'Carga de ordenes realizada correctamente'.
          p_ok = '1'.
          INSERT zco_tt_logpres FROM wa_zco_tt_logpres.

          APPEND wa_zco_tt_logpres TO it_zco_tt_logpres.
          CLEAR wa_zco_tt_logpres.
        ENDIF.
      ENDIF.
    ELSE.

      wa_zco_tt_logpres-datum = sy-datum.
      wa_zco_tt_logpres-uzeit = sy-uzeit.
      wa_zco_tt_logpres-idpres = wa_posiciones-idpres.
      wa_zco_tt_logpres-message = 'error en la carga de ordenes'.
      p_ok = '0'.
      INSERT zco_tt_logpres FROM wa_zco_tt_logpres.

      APPEND wa_zco_tt_logpres TO it_zco_tt_logpres.
      CLEAR wa_zco_tt_logpres.

    ENDIF.
  ENDIF.


  REFRESH it_posiciones.
  CLEAR wa_posiciones.
  CLEAR headerinfo.

  REFRESH: return,
  indexstructure,
  coobject,
  pervalue.


  SELECT *
  FROM zco_tt_planpres
  INTO CORRESPONDING FIELDS OF TABLE it_posiciones
  WHERE idpres = p_wa_arma_idpres
  AND tipo NE 'ORDEN' "MATERIALES CUENTAS Y SERVICIOS
  AND tipmod = 'F'
  AND bukrs = p_bukrs1
  AND kostl IN tr_kostl.


  SORT it_posiciones BY matnr kokrs bukrs kostl kstar.
  LOOP AT it_posiciones INTO wa_posiciones.

*              Grabamos posiciones
*              ********************************************************
    MOVE-CORRESPONDING wa_posiciones TO wa_collect.
    wa_collect-matnr = space.
    wa_collect-perio = space.
    wa_collect-co_meinh = space.
    wa_collect-aufnr = space.
    wa_collect-ingrp = space.
    wa_collect-equnr = space.
    wa_collect-aufnr = space.
    wa_collect-ingrp = space.
    wa_collect-perio = space.
    wa_collect-tipser = space.
    wa_collect-texexp = space.
    wa_collect-tipmod = space.
    wa_collect-fecmod = space.
    wa_collect-usuario = space.
    wa_collect-fecha = space.
    wa_collect-hora = space.
    wa_collect-autorizado = space.
    wa_collect-autorizador = space.
    wa_collect-fechaaut = space.
    wa_collect-horaaut = space.
    wa_collect-sgtxt = space.
    wa_collect-werks = space.
    wa_collect-twaer = 'MXN'.

    COLLECT wa_collect INTO it_collect.
  ENDLOOP.


*********************+ borramos los que no tengan kostl
  DELETE it_collect WHERE kostl EQ space.

  LOOP AT it_collect INTO wa_collect.
    indice = indice + 1.
    headerinfo-co_area = wa_collect-kokrs.
    headerinfo-fisc_year = wa_collect-gjahr.
    headerinfo-period_from = 1. "periodo de
    headerinfo-period_to = 12. "periodo a
    headerinfo-version = '000'. "wa_collect-versn. "version

    headerinfo-plan_currtype = 'T'.
*    indice de structura
    indexstructure-object_index = indice.
    indexstructure-value_index = indice.
    APPEND indexstructure.
*********************************************************
**********Objeto CO
    coobject-object_index = indice.
    coobject-costcenter = wa_collect-kostl.
    APPEND coobject.
*********************************************************
    pervalue-value_index = indice.
    pervalue-cost_elem = wa_collect-kstar.
    pervalue-trans_curr = wa_collect-twaer.
    pervalue-fix_val_per01 = wa_collect-wtg001.
    pervalue-fix_val_per02 = wa_collect-wtg002.
    pervalue-fix_val_per03 = wa_collect-wtg003.
    pervalue-fix_val_per04 = wa_collect-wtg004.
    pervalue-fix_val_per05 = wa_collect-wtg005.
    pervalue-fix_val_per06 = wa_collect-wtg006.
    pervalue-fix_val_per07 = wa_collect-wtg007.
    pervalue-fix_val_per08 = wa_collect-wtg008.
    pervalue-fix_val_per09 = wa_collect-wtg009.
    pervalue-fix_val_per10 = wa_collect-wtg010.
    pervalue-fix_val_per11 = wa_collect-wtg011.
    pervalue-fix_val_per12 = wa_collect-wtg012.

    APPEND pervalue.
  ENDLOOP.


*              ******  BAPI PARA CARGA DE PLAN DE PRESUPUESTO
  CALL FUNCTION 'BAPI_COSTACTPLN_POSTPRIMCOST'
    EXPORTING
      headerinfo     = headerinfo
      delta          = '' " = 'X' los valores nuevos y existentes se totalizan. '' se reemplazan
    TABLES
      indexstructure = indexstructure
      coobject       = coobject
      pervalue       = pervalue
      return         = return.

  " Se hace commit
  IF sy-subrc = 0.

    IF sy-subrc = 0.
      IF wa_posiciones-idpres NE space.
        IF return[] IS NOT INITIAL.

          LOOP AT return.
            MOVE-CORRESPONDING: return TO wa_zco_tt_logpres.
            wa_zco_tt_logpres-datum = sy-datum.
            wa_zco_tt_logpres-uzeit = sy-uzeit.
            wa_zco_tt_logpres-idpres = wa_posiciones-idpres.

            INSERT zco_tt_logpres FROM wa_zco_tt_logpres.

            APPEND wa_zco_tt_logpres TO it_zco_tt_logpres.
            CLEAR wa_zco_tt_logpres.

          ENDLOOP.
          "mostrar ventana de errores
          CALL FUNCTION 'ZUT_FLOATALV'
            EXPORTING
              i_start_column = 25
              i_start_line   = 6
              i_end_column   = 100
              i_end_line     = 10
              i_title        = 'Error al intentar contabilizar Presupuesto'
              i_popup        = 'X'
            TABLES
              it_alv         = return.

          p_ok = '0'.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          "-----------------------------------

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          wa_zco_tt_logpres-datum = sy-datum.
          wa_zco_tt_logpres-uzeit = sy-uzeit.
          wa_zco_tt_logpres-idpres = wa_posiciones-idpres.
          wa_zco_tt_logpres-message = 'Carga realizada correctamente'.
          p_ok = '1'.
          INSERT zco_tt_logpres FROM wa_zco_tt_logpres.

          APPEND wa_zco_tt_logpres TO it_zco_tt_logpres.
          CLEAR wa_zco_tt_logpres.

          UPDATE zco_tt_planpres
          SET autorizador = sy-uname
          fechaaut = sy-datum
          horaaut = sy-uzeit
          cecoaut = 'X'
          WHERE idpres = p_wa_arma_idpres
          AND bukrs = p_bukrs1
          AND kostl IN tr_kostl.


          SELECT SINGLE COUNT(*) INTO lv_lines
          FROM zco_tt_planpres
          WHERE idpres = p_wa_arma_idpres
          AND bukrs = p_bukrs1
          AND cecoaut NE 'X'.

          IF lv_lines > 0.
            lv_indicador = 'T'.
            lv_statustx = 'CeCos Pend. Aut.'.
          ELSE.
            lv_indicador = 'X'.
            lv_statustx = 'autorizado Completo'.
          ENDIF.

*         actualizamos la tabla zeta
          UPDATE zco_tt_planpresh
          SET autorizado = lv_indicador
          autorizador = sy-uname
          fechaaut = sy-datum
          horaaut = sy-uzeit
          statustx = lv_statustx
          WHERE idpres =  p_wa_arma_idpres
          .

          CLEAR wa_pendientes.
          wa_pendientes-autorizado = lv_indicador.
          wa_pendientes-statustx = lv_statustx.
          MODIFY it_pendientes FROM wa_pendientes
          TRANSPORTING autorizado statustx WHERE idpres =  p_wa_arma_idpres.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          TRY.
              CALL METHOD gref_alvgrid101->refresh_table_display
                EXPORTING
                  i_soft_refresh = 'X'.
            CATCH cx_sy_ref_is_initial.

          ENDTRY.
        ENDIF.

      ENDIF.

    ENDIF.
  ELSE.

    LOOP AT return.
      MOVE-CORRESPONDING: return TO wa_zco_tt_logpres.
      wa_zco_tt_logpres-datum = sy-datum.
      wa_zco_tt_logpres-uzeit = sy-uzeit.
      wa_zco_tt_logpres-idpres = wa_posiciones-idpres.

      INSERT zco_tt_logpres FROM wa_zco_tt_logpres.

      APPEND wa_zco_tt_logpres TO it_zco_tt_logpres.
      CLEAR wa_zco_tt_logpres.
    ENDLOOP.


  ENDIF.


*    LOOP AT it_posiciones INTO wa_posiciones WHERE idpresant NE ''.
*      UPDATE zco_tt_planpres
*      SET tipmod = 'O'
*      WHERE idpres = wa_posiciones-idpresant
*      AND prespos = wa_posiciones-prespos
*      AND bukrs = wa_posiciones-bukrs
*      AND kostl = wa_posiciones-kostl.
*
*    ENDLOOP.


ENDFORM.                    " AUTORIZAR_SELECCIONADOS


*&---------------------------------------------------------------------*
*&      Form  get_parameters
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_BURKS    text
*      <--P_KOSTL    text
*----------------------------------------------------------------------*
FORM get_parameters CHANGING p_burks TYPE bukrs
  p_kostl TYPE kostl.

  DATA: w_bukrs LIKE dynpread-fieldvalue,
        w_ceco  LIKE dynpread-fieldvalue.

  CALL FUNCTION 'C14Z_DYNP_READ_FIELD'
    EXPORTING
      i_program      = sy-repid
      i_dynpro       = sy-dynnr
      i_fieldname    = 'ZCO_TT_AUTPRES-BUKRS'
      i_flg_steploop = 'X'
    CHANGING
      e_value        = w_bukrs.

  p_burks = w_bukrs.

  CALL FUNCTION 'C14Z_DYNP_READ_FIELD'
    EXPORTING
      i_program      = sy-repid
      i_dynpro       = sy-dynnr
      i_fieldname    = 'ZCO_TT_AUTPRES-KOSTL'
      i_flg_steploop = 'X'
    CHANGING
      e_value        = w_ceco.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = w_ceco
    IMPORTING
      output = p_kostl.

ENDFORM.                    "get_parameters
*&---------------------------------------------------------------------*
*&      Form  CHECK_CECOS_PEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_CECOS_PEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_KOSTL  text
*----------------------------------------------------------------------*
FORM get_cecos_pend  USING p_idpres TYPE char10.
  " CHANGING p_lv_kostl TYPE kostl.

  TYPES: BEGIN OF st_cecosp,
           idpres TYPE char10,
           gjahr  TYPE gjahr,
           bukrs  TYPE bukrs,
           kostl  TYPE kostl,
         END OF st_cecosp.

  DATA: it_cecosp TYPE STANDARD TABLE OF st_cecosp,
        wa_cecosp LIKE LINE OF it_cecosp.

  DATA lv_lines TYPE i.
  DATA go_alv TYPE REF TO cl_salv_table.
  DATA: lr_functions TYPE REF TO cl_salv_functions_list,
        lr_selection TYPE REF TO cl_salv_selections,
        lt_rows      TYPE salv_t_row,
        lwa_rows     TYPE int4.

  SELECT idpres gjahr bukrs kostl
  INTO TABLE it_cecosp
  FROM zco_tt_planpres
  WHERE idpres = p_idpres
  AND tipmod = 'F' AND
  cecoaut NE 'X'.

  DESCRIBE TABLE it_cecosp LINES lv_lines.

  IF lv_lines GT 0.
    DELETE ADJACENT DUPLICATES FROM it_cecosp COMPARING ALL FIELDS.
    "---------------------------------------------
    TRY.
        cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = it_cecosp[] ).

      CATCH cx_salv_msg.
    ENDTRY.

    lr_functions = go_alv->get_functions( ).
    lr_functions->set_all( 'X' ).

    IF go_alv IS BOUND.

      go_alv->set_screen_popup(
      start_column = 25
      end_column  = 100
      start_line  = 6
      end_line    = 10 ).

      go_alv->display( ).

      lr_selection = go_alv->get_selections( ).
      lr_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).
      lt_rows = lr_selection->get_selected_rows( ).

      READ TABLE lt_rows INTO lwa_rows INDEX 1.
      READ TABLE it_cecosp INTO wa_cecosp INDEX lwa_rows.
      " p_lv_kostl = wa_cecosp-kostl.
    ENDIF.
    "-----------------------------------------------------
  ELSE.

    MESSAGE 'No hay CeCos pendientes de la Sociedad seleccionada' TYPE 'S'.

  ENDIF.


ENDFORM.                    " GET_CECOS_PEND
*&---------------------------------------------------------------------*
*&      Form  UPDATE_TOTALES_PORTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ZCO_TT_PLANPRES  text
*----------------------------------------------------------------------*
FORM update_totales_portal  USING    p_gt_zco_tt_planpres TYPE STANDARD TABLE.
  DATA: lt_zco_tt_planpres  TYPE TABLE OF zco_tt_planpres,
        lwa_zco_tt_planpres LIKE LINE OF lt_zco_tt_planpres.

  lt_zco_tt_planpres[] = p_gt_zco_tt_planpres[].


  LOOP AT lt_zco_tt_planpres INTO lwa_zco_tt_planpres WHERE tipo = 'MATERIAL'.
    lwa_zco_tt_planpres-wtg001 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg001.
    lwa_zco_tt_planpres-wtg002 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg002.
    lwa_zco_tt_planpres-wtg003 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg003.
    lwa_zco_tt_planpres-wtg004 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg004.
    lwa_zco_tt_planpres-wtg005 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg005.
    lwa_zco_tt_planpres-wtg006 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg006.
    lwa_zco_tt_planpres-wtg007 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg007.
    lwa_zco_tt_planpres-wtg008 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg008.
    lwa_zco_tt_planpres-wtg009 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg009.
    lwa_zco_tt_planpres-wtg010 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg010.
    lwa_zco_tt_planpres-wtg011 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg011.
    lwa_zco_tt_planpres-wtg012 = lwa_zco_tt_planpres-preunipres * lwa_zco_tt_planpres-meg012.

    lwa_zco_tt_planpres-wtgtot = lwa_zco_tt_planpres-wtg001 + lwa_zco_tt_planpres-wtg002
    + lwa_zco_tt_planpres-wtg003 + lwa_zco_tt_planpres-wtg004
    + lwa_zco_tt_planpres-wtg005 + lwa_zco_tt_planpres-wtg006
    + lwa_zco_tt_planpres-wtg007 + lwa_zco_tt_planpres-wtg008
    + lwa_zco_tt_planpres-wtg009 + lwa_zco_tt_planpres-wtg010
    + lwa_zco_tt_planpres-wtg011 + lwa_zco_tt_planpres-wtg012.

    MODIFY lt_zco_tt_planpres FROM lwa_zco_tt_planpres.

    UPDATE zco_tt_planpres SET wtg001 = lwa_zco_tt_planpres-wtg001
    wtg002 = lwa_zco_tt_planpres-wtg002
    wtg003 = lwa_zco_tt_planpres-wtg003
    wtg004 = lwa_zco_tt_planpres-wtg004
    wtg005 = lwa_zco_tt_planpres-wtg005
    wtg006 = lwa_zco_tt_planpres-wtg006
    wtg007 = lwa_zco_tt_planpres-wtg007
    wtg008 = lwa_zco_tt_planpres-wtg008
    wtg009 = lwa_zco_tt_planpres-wtg009
    wtg010 = lwa_zco_tt_planpres-wtg010
    wtg011 = lwa_zco_tt_planpres-wtg011
    wtg012 = lwa_zco_tt_planpres-wtg012
    wtgtot = lwa_zco_tt_planpres-wtgtot
    WHERE idpres   = lwa_zco_tt_planpres-idpres AND
    prespos  = lwa_zco_tt_planpres-prespos AND
    matnr    = lwa_zco_tt_planpres-matnr .



  ENDLOOP.

  p_gt_zco_tt_planpres[] = lt_zco_tt_planpres[].
ENDFORM.                    " UPDATE_TOTALES_PORTAL
