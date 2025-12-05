*----------------------------------------------------------------------*
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_FUN04.
* 070302023
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form containers_free104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM containers_free104 .
  IF NOT gref_alvgrid103 IS INITIAL.
    " destroy tree container (detroys contained tree control, too)
    CALL METHOD gref_alvgrid104->free
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
    IF sy-subrc <> 0.
      "MESSAGE A000.
    ENDIF.


    CALL METHOD gref_ccontainer104->free
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
    IF sy-subrc <> 0.
      "MESSAGE A000.
    ENDIF.

    CLEAR gref_ccontainer104.
    CLEAR gref_alvgrid104.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_cecos_reauth
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_cecos_reauth .

  REFRESH: it_kostl, it_only_kostl.

  DATA it_only_kostl TYPE STANDARD TABLE OF st_kostl.

  SELECT p~idpres c~kostl t~ktext c~objnr p~kstar
  INTO TABLE it_kostl
  FROM csks AS c
  INNER JOIN cskt AS t ON t~kostl EQ c~kostl AND t~spras EQ 'S'
  AND  t~datbi GE sy-datum
  "INNER JOIN cosp AS CO
  "ON CO~objnr EQ C~objnr
  INNER JOIN zco_tt_planpres AS p
  ON p~kostl = c~kostl AND p~tipmod EQ 'F' AND p~cecoaut EQ 'X'
  WHERE c~kostl IN s7_kostl
  AND c~datbi GE sy-datum
  AND p~gjahr EQ p7_gjahr
  "AND CO~vrgng EQ 'RKP1'
  .

  SORT it_kostl BY kostl kstar.

  LOOP AT it_kostl INTO wa_kostl.
    wa_kostl-status  = '@09@'.
    wa_kostl-descripcion = 'Preparado...'.
    MODIFY it_kostl FROM wa_kostl TRANSPORTING status descripcion
    WHERE kostl = wa_kostl-kostl.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fieldcat104 .

  DATA ls_fieldcat TYPE lvc_s_fcat.
  CLEAR fieldcat102.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'IDPRES'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-scrtext_m = 'Presupuesto'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KOSTL'.
  ls_fieldcat-outputlen = 6.
  ls_fieldcat-scrtext_m = 'Centro de Coste'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KTEXT'.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-scrtext_m = 'Descripción'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-outputlen = 4.
  ls_fieldcat-scrtext_m = 'Status'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DESCRIPCION'.
  ls_fieldcat-outputlen = 100.
  ls_fieldcat-scrtext_m = '           '.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_ONLY_KOSTL
*&      --> FIELDCAT102
*&      --> P_
*&---------------------------------------------------------------------*
FORM display_alv104   USING  p_it_outtable TYPE STANDARD TABLE
      p_fieldcat TYPE lvc_t_fcat
      container TYPE char20.

  it_layout-sel_mode = 'A'.
  it_layout-no_rowmark = 'X'.
  it_layout-cwidth_opt = 'X'.

  TRY.
      CALL METHOD gref_alvgrid104->free.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.

  TRY.
      CALL METHOD gref_ccontainer104->free.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.


  CREATE OBJECT gref_ccontainer104
    EXPORTING
      container_name              = container
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  CREATE OBJECT gref_alvgrid104
    EXPORTING
      i_parent          = gref_ccontainer104
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.


  CALL METHOD gref_alvgrid104->set_table_for_first_display
    EXPORTING
      is_layout                     = it_layout
*     it_toolbar_excluding          = lt_excl_func1
    CHANGING
      it_outtab                     = p_it_outtable[]
      it_fieldcatalog               = p_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  CALL METHOD gref_alvgrid104->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.


  CREATE OBJECT event_handlerdyn104.

  SET HANDLER event_handlerdyn104->handle_user_command FOR gref_alvgrid104.
  SET HANDLER event_handlerdyn104->handle_toolbar FOR gref_alvgrid104.
*  SET HANDLER event_handlerDyn102->on_link_click FOR gref_alvgrid102.

  CALL METHOD gref_alvgrid104->set_toolbar_interactive.


ENDFORM.                    " DISPLAY_ALV104
*&---------------------------------------------------------------------*
*& Form handle_user_command104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_user_command104  USING    p_e_ucomm.
  CASE p_e_ucomm.
    WHEN 'REAUTH'.
      PERFORM reauth_plan.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form reauth_plan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reauth_plan .
  DATA lv_answer TYPE c.
  TYPES: BEGIN OF st_kostlaut,
           kostl      TYPE kostl,
           autorizado TYPE c,
         END OF st_kostlaut.

  DATA: it_kostlaut TYPE STANDARD TABLE OF st_kostlaut,
        wa_kostlaut LIKE LINE OF it_kostlaut.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Preparar Plantilla para Re-Autorizar'
      text_question  = 'Confirme la preparación de los CeCos/plantilla Mostrados'
      text_button_1  = 'SI'(005)
      icon_button_1  = 'ICON_OKAY'
      text_button_2  = 'NO'(006)
      icon_button_2  = 'ICON_CANCEL'
      default_button = '2'
      start_column   = 25
      start_row      = 6
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF lv_answer EQ '1'.

    SELECT kostl autorizado INTO TABLE it_kostlaut
    FROM zco_tt_planpres
    FOR ALL ENTRIES IN it_only_kostl
    WHERE kostl EQ it_only_kostl-kostl
    AND autorizado = 'X' AND  kokrs = p7_kokrs
    AND gjahr = p7_gjahr AND tipmod = 'F'.

    LOOP AT it_kostlaut INTO wa_kostlaut.
      CLEAR wa_only_kostl.
      wa_only_kostl-status = '@0A@'. "Error
      wa_only_kostl-descripcion = 'Existen Materiales Autorizados'.
      MODIFY it_only_kostl FROM wa_only_kostl TRANSPORTING status descripcion
      WHERE kostl = wa_kostlaut-kostl.

    ENDLOOP.

    LOOP AT it_only_kostl INTO wa_only_kostl WHERE status NE '@0A@'.
      PERFORM aplicar_reautorizacion USING wa_only_kostl-kostl
            wa_only_kostl-idpres.
    ENDLOOP.

    CALL METHOD gref_alvgrid104->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'.

    MESSAGE 'La tarea ha sido finalizada' TYPE 'S'.
  ENDIF.

ENDFORM.

FORM aplicar_reautorizacion  USING  p_kostl TYPE kostl
      p_idpres TYPE char10.

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

  DATA: indice        TYPE obj_indx, lv_autorizado TYPE c.
  FIELD-SYMBOLS: <itab> TYPE STANDARD TABLE,
                 <wa>   TYPE any.

  REFRESH: itrku01g,
  irku01ja,
  it_collect,
  indexstructure,
  coobject,
  pervalue.

  indice = '000000'.

  CLEAR headerinfo.

  REFRESH: return,
  indexstructure,
  coobject,
  pervalue.

  LOOP AT it_kostl INTO wa_kostl WHERE kostl EQ p_kostl.
*  Grabamos posiciones
*  ********************************************************
    indice = indice + 1.
    headerinfo-co_area = p7_kokrs.
    headerinfo-fisc_year = p7_gjahr.
    headerinfo-period_from = 1. "periodo de
    headerinfo-period_to = 12. "periodo a
    headerinfo-version = '0'. "version

    headerinfo-plan_currtype = 'T'.

*    indice de structura
    indexstructure-object_index = indice.
    indexstructure-value_index = indice.
    APPEND indexstructure.
*********************************************************
**********Objeto CO
    coobject-object_index = indice.
    coobject-costcenter = wa_kostl-kostl.
    APPEND coobject.
*********************************************************
    pervalue-value_index = indice.
    pervalue-cost_elem = wa_kostl-kstar.
    pervalue-trans_curr = 'MXN'.
    pervalue-fix_val_per01 = 0.
    pervalue-fix_val_per02 = 0.
    pervalue-fix_val_per03 = 0.
    pervalue-fix_val_per04 = 0.
    pervalue-fix_val_per05 = 0.
    pervalue-fix_val_per06 = 0.
    pervalue-fix_val_per07 = 0.
    pervalue-fix_val_per08 = 0.
    pervalue-fix_val_per09 = 0.
    pervalue-fix_val_per10 = 0.
    pervalue-fix_val_per11 = 0.
    pervalue-fix_val_per12 = 0.
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
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    IF sy-subrc = 0.
      IF return[] IS NOT INITIAL.
        wa_only_kostl-status = '@0A@'. "Rojo
        wa_only_kostl-descripcion = 'Error interno. Validar con su Funcional Aut. Modif. CeCo'.
        MODIFY it_only_kostl FROM wa_only_kostl TRANSPORTING status descripcion WHERE kostl EQ p_kostl.
      ELSE.

        UPDATE zco_tt_planpres SET cecoaut = 'F' WHERE kostl = p_kostl AND kokrs = p7_kokrs
        AND gjahr = p7_gjahr.

        UPDATE  zco_tt_planpresh SET autorizado = '' autorizador = '' WHERE idpres = p_idpres.

        wa_only_kostl-status = '@08@'. "Verde
        wa_only_kostl-descripcion = 'Listo para Autorizar Nuevamente'.
        MODIFY it_only_kostl FROM wa_only_kostl TRANSPORTING status descripcion WHERE kostl EQ p_kostl.
      ENDIF.

      CALL METHOD gref_alvgrid104->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.

    ENDIF.
  ENDIF.


ENDFORM.                    " APLICAR_REAUTORIZACION

FORM display_alvecc USING  p_it_outtable TYPE STANDARD TABLE
      p_fieldcat TYPE lvc_t_fcat
      container TYPE char20.
  DATA: it_filter TYPE lvc_t_filt,
        wa_filter LIKE LINE OF it_filter.

  it_layout-sel_mode = 'A'.
  it_layout-no_rowmark = 'X'.
  it_layout-cwidth_opt = 'X'.

  TRY.
      CALL METHOD gref_alvgridecc->free.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.

  TRY.
      CALL METHOD gref_ccontainerecc->free.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.


  CREATE OBJECT gref_ccontainerecc
    EXPORTING
      container_name              = container
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  CREATE OBJECT gref_alvgridecc
    EXPORTING
      i_parent          = gref_ccontainerecc
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.


*  wa_filter-fieldname = 'TIPO'.
*  wa_filter-sign   = 'I'.
*  wa_filter-option = 'EQ'.
*  wa_filter-low = 'MATERIAL'.
*  APPEND wa_filter TO it_filter.
*
*  wa_filter-fieldname = 'MATNR'.
*  wa_filter-sign   = 'I'.
*  wa_filter-option = 'NE'.
*  wa_filter-low = 'SIN RELACION'.
*  APPEND wa_filter TO it_filter.





  CALL METHOD gref_alvgridecc->set_table_for_first_display
    EXPORTING
      is_layout                     = it_layout
*     it_toolbar_excluding          = lt_excl_func1
    CHANGING
      it_outtab                     = p_it_outtable[]
      it_fieldcatalog               = p_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  CALL METHOD gref_alvgridecc->set_filter_criteria(
    EXPORTING
      it_filter = it_filter ).


  CALL METHOD gref_alvgridecc->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.



  CREATE OBJECT event_handlerdynecc.

  SET HANDLER event_handlerdynecc->handle_user_commandecc FOR gref_alvgridecc.
  SET HANDLER event_handlerdynecc->handle_toolbarecc FOR gref_alvgridecc.
  "  SET HANDLER event_handlerDyn102->on_link_click FOR gref_alvgrid102.

  CALL METHOD gref_alvgridecc->set_toolbar_interactive.


ENDFORM.                    " DISPLAY_ALV104

FORM create_fieldcatecc2hana.

  DATA ls_fieldcat TYPE lvc_s_fcat.
 CLEAR fieldcat102.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'IDPRES'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-scrtext_m = 'ID Pres'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-scrtext_m = 'Soc. FI'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.



  ls_fieldcat-fieldname = 'TIPO'.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-scrtext_m = 'TIPO'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BISMT'.
  ls_fieldcat-outputlen = 18.
  ls_fieldcat-scrtext_m = 'Material Ecc'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MAKTX_ECC'.
  ls_fieldcat-outputlen = 40.
  ls_fieldcat-scrtext_m = 'Descripción ECC'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MATNR'.
  ls_fieldcat-outputlen = 18.
  ls_fieldcat-scrtext_m = 'Material Hana'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MAKTX'.
  ls_fieldcat-outputlen = 40.
  ls_fieldcat-scrtext_m = 'Descrip. Hana'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CUENTA'.
  ls_fieldcat-outputlen = 40.
  ls_fieldcat-scrtext_m = 'Cuenta Hana'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WERKS'.
  ls_fieldcat-outputlen = 6.
  ls_fieldcat-scrtext_m = 'Centro Hana'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WERKS_ECC'.
  ls_fieldcat-outputlen = 8.
  ls_fieldcat-scrtext_m = 'Centro ECC'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KOSTL'.
  "ls_fieldcat-outputlen = 8.
  ls_fieldcat-scrtext_m = 'CeCo Hana'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KOSTL_ECC'.
  "ls_fieldcat-outputlen = 8.
  ls_fieldcat-scrtext_m = 'CeCo ECC'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KSTAR'.
  "ls_fieldcat-outputlen = 8.
  ls_fieldcat-scrtext_m = 'Cl. Costo Hana'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KSTAR_ECC'.
  "ls_fieldcat-outputlen = 8.
  ls_fieldcat-scrtext_m = 'Cl. Costo ECC'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.

    CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WTGTOT'.
  ls_fieldcat-scrtext_m = 'Monto'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_commandecc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_user_commandecc  USING    p_e_ucomm.
  DATA res TYPE sy-subrc.
  DATA lv_answer.
  CASE p_e_ucomm.
    WHEN 'MIGRAR'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Migración de Presupuesto'
*         DIAGNOSE_OBJECT       = ' '
          text_question         = '¿Esta seguro de Migrar/Aplicar Datos de ECC a Hana?'
          text_button_1         = 'Si, Seguro'(001)
          icon_button_1         = 'ICON_CHECKED'
          text_button_2         = 'No estoy seguro'(002)
          icon_button_2         = 'ICON_CANCEL'
          default_button        = '2'
          display_cancel_button = ''
*         USERDEFINED_F1_HELP   = ' '
*         START_COLUMN          = 25
*         START_ROW             = 6
          popup_type            = 'ICON_MESSAGE_QUESTION'
        IMPORTING
          answer                = lv_answer
*     TABLES
*         PARAMETER             =
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.
      IF lv_answer EQ '1' .
        PERFORM insert_pres USING res.

        IF res EQ 0.
          MESSAGE 'Datos Migrados Satisfactoriamente' TYPE 'S'.
        ELSE.
          MESSAGE 'No se puedieron Migrar los Datos' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_pres
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RES
*&---------------------------------------------------------------------*
FORM insert_pres  USING    p_res TYPE sy-subrc.
  "it_zco_tt_planpresh
  DATA h_zco_tt_planpres TYPE STANDARD TABLE OF zco_tt_planpres.

  h_zco_tt_planpres[] = it_zco_tt_planpres[].

*  SORT h_zco_tt_planpres BY idpres.
*  DELETE ADJACENT DUPLICATES FROM h_zco_tt_planpres COMPARING idpres.
*  delete it_zco_tt_planpres where matnr = 'SIN RELACION'.
*  delete it_zco_tt_planpres where cuenta = 'SIN REL'.
*  delete it_zco_tt_planpres where kstar = 'No Rel. Ce' or kstar = 'No Eq. Mat'.
*  delete it_zco_tt_planpres where werks = 'SINR'.
*  delete it_zco_tt_planpres where kostl = 'SIN RELAC.'.

  LOOP AT h_zco_tt_planpres INTO DATA(wa).
    CLEAR wa_zco_tt_planpresh.
    READ TABLE it_zco_tt_planpres INTO DATA(wa_h) WITH KEY idpres = wa-idpres.
    wa_zco_tt_planpresh-mandt = wa_h-mandt.
    wa_zco_tt_planpresh-idpres = wa_h-idpres.
    wa_zco_tt_planpresh-versn  = wa_h-versn.
    wa_zco_tt_planpresh-cveaut = '01'.
    wa_zco_tt_planpresh-usuario = 'PORTAL'.
    wa_zco_tt_planpresh-fecha = sy-datum.
    wa_zco_tt_planpresh-hora = sy-timlo.
    wa_zco_tt_planpresh-autorizado = ''.
    wa_zco_tt_planpresh-autorizador = ''.
    wa_zco_tt_planpresh-fechaaut = ''.
    wa_zco_tt_planpresh-horaaut = ''.
    wa_zco_tt_planpresh-ruta_archivo = ''.
    wa_zco_tt_planpresh-comentario = 'MIGRADO DE ECC'.
    wa_zco_tt_planpresh-gjahr = '2023'.
    wa_zco_tt_planpresh-statustx = ''.
    APPEND wa_zco_tt_planpresh TO it_zco_tt_planpresh.
  ENDLOOP.

  sort it_zco_tt_planpresh by idpres.
  DELETE ADJACENT DUPLICATES FROM it_zco_tt_planpresh COMPARING ALL FIELDS.

  INSERT zco_tt_planpresh FROM TABLE it_zco_tt_planpresh.
  IF sy-subrc EQ 0.
    INSERT zco_tt_planpres FROM TABLE it_zco_tt_planpres.
    IF sy-subrc EQ 0.
      p_res = sy-subrc.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'
*     IMPORTING
*         RETURN        =
        .

      PERFORM aplicar_pres_ecc2hana.
    ENDIF.
  ELSE.
    p_res = 1. "no se grabo
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form aplicar_pres_ecc2hana
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM aplicar_pres_ecc2hana .
  DATA p_ok.

  LOOP AT it_zco_tt_planpresh INTO wa_zco_tt_planpresh.
    PERFORM autorizar_seleccionados USING wa_zco_tt_planpresh-idpres
                                    p_ok.
    IF p_ok EQ '1'.
        MESSAGE 'No se contabilizo el presupuesto debido a errores.' TYPE 'S' DISPLAY LIKE 'E'.
    ELSE.
      MESSAGE 'No se contabilizo el presupuesto debido a errores.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDLOOP.
ENDFORM.
