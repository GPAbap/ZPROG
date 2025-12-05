*----------------------------------------------------------------------*
***INCLUDE ZCO_COCKPIT_PRESUPUESTO_FUN02 .
* 07032023
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_TREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_and_init_tree .
  DATA: node_table TYPE node_table_type,
        events     TYPE cntl_simple_events,
        event      TYPE cntl_simple_event,
        node_wa    LIKE LINE OF node_table.
  DATA node TYPE mtreesnode.
* create a container for the tree control
  CREATE OBJECT g_custom_container
    EXPORTING      " the container is linked to the custom control with the
      " name 'TREE_CONTAINER' on the dynpro
      container_name              = 'TREE_CONTAINER'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.
  IF sy-subrc <> 0.
    "MESSAGE A000.
  ENDIF.


* create a tree control
  CREATE OBJECT g_tree
    EXPORTING
      parent                      = g_custom_container
      node_selection_mode         = cl_gui_simple_tree=>node_sel_mode_single      " single node selection is used
    EXCEPTIONS
      lifetime_error              = 1
      cntl_system_error           = 2
      create_error                = 3
      failed                      = 4
      illegal_node_selection_mode = 5.
  IF sy-subrc <> 0.
    "MESSAGE A000.
  ENDIF.

* define the events which will be passed to the backend
  " node double click
  event-eventid = cl_gui_simple_tree=>eventid_node_double_click.
  event-appl_event = 'X'. " process PAI if event occurs
  APPEND event TO events.

  " expand no children
  event-eventid = cl_gui_simple_tree=>eventid_expand_no_children.
  event-appl_event = 'X'.
  APPEND event TO events.

  CALL METHOD g_tree->set_registered_events
    EXPORTING
      events                    = events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  IF sy-subrc <> 0.
    "MESSAGE A000.
  ENDIF.

* assign event handlers in the application class to each desired event
  SET HANDLER g_application->handle_node_double_click FOR g_tree.
  SET HANDLER g_application->handle_expand_no_children FOR g_tree.


* add some nodes to the tree control
* NOTE: the tree control does not store data at the backend. If an
* application wants to access tree data later, it must store the
* tree data itself.

  PERFORM build_node_table USING node_table
  CHANGING node.

* node_table_structure_name     = 'MTREESNODE'
*   A programmer using the tree control must create a structure in the
*   dictionary. This structure must include the structure TREEV_NODE
*   and must contain a character field with the name 'TEXT'.

  CALL METHOD g_tree->add_nodes
    EXPORTING
      table_structure_name           = 'MTREESNODE'
      node_table                     = node_table
    EXCEPTIONS
      failed                         = 1
      error_in_node_table            = 2
      dp_error                       = 3
      table_structure_name_not_found = 4
      OTHERS                         = 5.
  IF sy-subrc <> 0.
    "MESSAGE A000.
  ENDIF.

  LOOP AT node_table INTO node_wa.
    IF node_wa-node_key(1) NE 'C'.
      CALL METHOD g_tree->expand_node
        EXPORTING
          node_key = node_wa-node_key.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CREATE_AND_INIT_TREE
*&---------------------------------------------------------------------*
*&      Form  BUILD_NODE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NODE_TABLE  text
*----------------------------------------------------------------------*
FORM build_node_table  USING  node_table TYPE node_table_type
CHANGING p_node TYPE mtreesnode.

  DATA: node LIKE mtreesnode.

* Build the node table.

* Caution: The nodes are inserted into the tree according to the order
* in which they occur in the table. In consequence, a node must not
* occur in the node table before its parent node.

* Node with key 'Root'
  node-node_key = c_nodekey-root.

  " Key of the node
  CLEAR node-relatkey.      " Special case: A root node has no parent
  CLEAR node-relatship.     " node.

  node-hidden = ' '.        " The node is visible,
  node-disabled = ' '.      " selectable,
  node-isfolder = 'X'.      " a folder.
  CLEAR node-n_image.       " Folder-/ Leaf-Symbol in state "closed":
  " use default.
  CLEAR node-exp_image.     " Folder-/ Leaf-Symbol in state "open":
  " use default
  CLEAR node-expander.      " see below.
  node-text = 'Reportes Presupuestos'(roo).
  APPEND node TO node_table.

* Node with key 'Child1'
  node-node_key = c_nodekey-child1.

  " Key of the node
  " Node is inserted as child of the node with key 'Root'.
  node-relatkey = c_nodekey-root.
  node-relatship = cl_gui_simple_tree=>relat_last_child.

  node-hidden = ' '.
  node-disabled = ' '.
  node-isfolder = 'X'.
  CLEAR node-n_image.
  CLEAR node-exp_image.
  node-expander = 'X'. " The node is marked with a '+', although
  " it has no children. When the user clicks on the
  " + to open the node, the event
  " expand_no_children is fired. The programmer can
  " add the children of the
  " node within the event handler of the
  " expand_no_children event
  " (see method handle_expand_no_children
  " of class lcl_application)

  node-text = 'Seleccionar'(ch1).
  node-style = cl_gui_simple_tree=>style_emphasized_positive.
  APPEND node TO node_table.
  p_node = node.
ENDFORM.                    " BUILD_NODE_TABLE
*&---------------------------------------------------------------------*
*&      Form  VALIDAR_MATERIALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validar_materiales .

  FIELD-SYMBOLS: <ls_tabla> TYPE any,
                 <ls_linea> TYPE any.

  DATA mes_corto LIKE t247-ktx.
  DATA num_mes LIKE t247-mnr.
  DATA lv_fldnmecat TYPE lvc_fname.
  DATA lv_fldnmecatr TYPE lvc_fname.
  DATA lv_fldnmemont TYPE lvc_fname.
  DATA: lv_cantrestante TYPE megxxx,
        lv_cantoriginal TYPE megxxx,
        lv_cantwog      TYPE megxxx.

  DATA: vl_monat TYPE string,
        lv_where TYPE TABLE OF string.

  DATA lv_gjahr TYPE gjahr.

  "se validan los CeCos autorizados por Usuario Logeado
  SELECT  kostl kokrs
  FROM zco_tt_cecoaut
  INTO CORRESPONDING FIELDS OF TABLE it_cecos
  WHERE bname = sy-uname
  AND kokrs = p_kokrs
  AND kostl IN skostl.


*update zco_tt_planpres set WOG001 = 0,
*                           WOG002 = 0,
*                           WOG003 = 0,
*                           WOG004 = 0,
*                           WOG005 = 0,
*                           WOG006 = 0,
*                           WOG007 = 0,
*                           WOG008 = 0,
*                           WOG009 = 0,
*                           WOG010 = 0,
*                           WOG011 = 0,
*                           WOG012 = 0.

  "se unifican los CeCos
  IF it_cecos[] IS NOT INITIAL.

    SELECT DISTINCT mandt kostl idpres
    FROM zco_tt_planpres
    INTO TABLE it_cecos_indice
    FOR ALL ENTRIES IN it_cecos
    WHERE kokrs = it_cecos-kokrs
    AND matnr NE space
    AND kostl = it_cecos-kostl
    AND versn EQ p_versn..

    CLEAR wa_cecos_indice.
*    wa_cecos_indice-mandt = sy-mandt.
*    MODIFY it_cecos_indice from wa_cecos_indice TRANSPORTING mandt where mandt = ''.
    SORT it_cecos_indice BY kostl idpres DESCENDING.
    DELETE ADJACENT DUPLICATES FROM it_cecos_indice COMPARING kostl idpres.
    DELETE FROM zcecos_tt_indice.
    INSERT zcecos_tt_indice CLIENT SPECIFIED FROM TABLE it_cecos_indice.
  ENDIF.
*********------se Obtienen los datos de las tablas principales
  IF it_cecos_indice[] IS NOT INITIAL.
    REFRESH gt_zco_tt_planpres.
    REFRESH gt_zco_tt_planpresm.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_monat
      IMPORTING
        output = num_mes.


    lv_gjahr = p_gjahr - 1.

    SELECT
    p~mandt p~idpres p~prespos p~kokrs p~gjahr p~bukrs p~versn p~kostl p~kstar p~buzei
    p~matnr p~servno p~cuenta p~maktx p~tipo p~twaer p~periodo p~co_meinh  p~prunmx
    SUM( wtg001 ) AS wtg001 SUM( wtg002 ) AS wtg002 SUM( wtg003 ) AS wtg003 SUM( wtg004 ) AS wtg004
    SUM( wtg005 ) AS wtg005 SUM( wtg006 ) AS wtg006 SUM( wtg007 ) AS wtg007 SUM( wtg008 ) AS wtg008
    SUM( wtg009 ) AS wtg009 SUM( wtg010 ) AS wtg010 SUM( wtg011 ) AS wtg011 SUM( wtg012 ) AS wtg012
    SUM( wtgtot ) AS wtgtot
    SUM( wog001 ) AS wog001 SUM( wog002 ) AS wog002 SUM( wog003 ) AS wog003 SUM( wog004 ) AS wog004
    SUM( wog005 ) AS wog005 SUM( wog006 ) AS wog006 SUM( wog007 ) AS wog007 SUM( wog008 ) AS wog008
    SUM( wog009 ) AS wog009 SUM( wog010 ) AS wog010 SUM( wog011 ) AS wog011 SUM( wog012 ) AS wog012
    SUM( wogtot ) AS wogtot
    SUM( meg001 ) AS meg001 SUM( meg002 ) AS meg002 SUM( meg003 ) AS meg003 SUM( meg004 ) AS meg004
    SUM( meg005 ) AS meg005 SUM( meg006 ) AS meg006 SUM( meg007 ) AS meg007 SUM( meg008 ) AS meg008
    SUM( meg009 ) AS meg009 SUM( meg010 ) AS meg010 SUM( meg011 ) AS meg011 SUM( meg012 ) AS meg012
    SUM( megtot ) AS megtot
    p~gkoar p~werks p~lgort p~sgtxt p~wkurs p~equnr p~aufnr p~ingrp p~matkl p~perio p~tipser p~texexp p~tipmod p~fecmod
    p~usuario p~fecha p~hora p~autorizado p~autorizador p~fechaaut p~horaaut p~areas p~zona d2~zzsolped AS solped p~solpedpos
    p~menge d2~zzreserva AS rsnum p~rspos p~bdmng p~enmng p~eisbe p~mabst p~trame "d~labst
    m~plifz p~cecoaut preunipres
    INTO CORRESPONDING FIELDS OF TABLE gt_zco_tt_planpres
    FROM zco_tt_planpres AS p "detalle del presupuesto
    INNER JOIN zcecos_tt_indice AS i ON i~idpres = p~idpres AND i~kostl EQ p~kostl
    INNER JOIN marc AS m ON m~matnr EQ p~matnr AND m~werks EQ p~werks
    "INNER JOIN mard AS d ON d~matnr EQ p~matnr AND d~werks EQ p~werks AND d~lfgja EQ lv_gjahr "AND kzill = 'X'
    LEFT JOIN zco_tt_datomatnr AS d2 ON d2~idpres = p~idpres AND d2~prespos = p~prespos
            AND d2~zzpoper EQ num_mes AND d2~zzgjahr = p~gjahr
    WHERE kokrs EQ p_kokrs
    AND   p~kostl IN skostl
    AND   p~matnr IN smatnr
    AND gjahr EQ p_gjahr
    AND cecoaut EQ 'X'
    AND tipmod = 'F'
    AND versn EQ p_versn
    GROUP BY preunipres p~cecoaut m~plifz "d~labst
    p~trame p~mabst p~eisbe p~enmng
    p~bdmng d2~zzreserva p~rspos p~menge d2~zzsolped p~solpedpos p~zona p~areas
    p~usuario p~fecha p~hora p~autorizado p~autorizador p~fechaaut p~horaaut
    p~gkoar p~werks p~lgort p~sgtxt p~wkurs p~equnr p~aufnr p~ingrp p~matkl
    p~perio p~tipser p~texexp p~tipmod p~fecmod
    p~matnr p~servno p~cuenta p~maktx p~tipo p~twaer p~periodo p~co_meinh  p~prunmx
    p~mandt p~idpres p~prespos p~kokrs p~gjahr p~bukrs p~versn p~kostl
    p~kstar p~buzei
    .

    SORT  gt_zco_tt_planpres BY kokrs bukrs kostl matnr.
    "DELETE ADJACENT DUPLICATES FROM gt_zco_tt_planpres COMPARING kokrs bukrs kostl matnr.
************************************************************************************
******Se dejan solo posiciones de tipo MATERIAL y que Matnr no sean espacios o vacios
    SORT gt_zco_tt_planpres BY idpres prespos.
    DELETE gt_zco_tt_planpres WHERE tipo NE 'MATERIAL'.
    DELETE gt_zco_tt_planpres WHERE matnr EQ space.


*****---Procesamos los datos---------------
* Se comenta, ya que, se determino que mediante la plantilla subida
* El ultimo precio se obtiene de ahí.
    IF gt_zco_tt_planpres[] IS NOT INITIAL.
      REFRESH gt_zco_tt_planpresm.
      PERFORM get_periodo USING p_monat
      CHANGING num_mes
        mes_corto
        lv_fldnmecat
        lv_fldnmemont.




      LOOP AT gt_zco_tt_planpres ASSIGNING <ls_tabla>.
        ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE  <ls_tabla> TO <ls_linea>.
        IF <ls_linea> GT 0.
          CLEAR wa_zco_tt_planpresm.
          CLEAR lv_cantrestante.
          "se calcula la cantidad restante, previamente autorizada.
          lv_cantoriginal = <ls_linea>. "aqui se pasa la cantidad presupuestada original
          lv_fldnmecatr = lv_fldnmecat.
          REPLACE 'MEG' IN lv_fldnmecatr WITH 'WOG'.
          ASSIGN COMPONENT lv_fldnmecatr OF STRUCTURE  <ls_tabla> TO <ls_linea>.
          CLEAR lv_cantwog.
          lv_cantwog = <ls_linea>.

          lv_cantrestante = lv_cantoriginal - <ls_linea>. "aqui restamos la cantidad presupuestada
          " de la cantidad que antes hayan autorizado
          ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE  <ls_tabla> TO <ls_linea>.
          "<ls_linea> = lv_cantrestante. "asignamos el resultado al campo MEG solo para presentacion.
          IF lv_cantwog > 0.
            <ls_linea> = lv_cantwog. "Se cambia a que solo quieren ver la cant. autorizada, no la restante.
          ELSE.
            <ls_linea> =   lv_cantoriginal.
          ENDIF.

          MOVE-CORRESPONDING <ls_tabla> TO wa_zco_tt_planpresm.
          IF lv_cantrestante EQ 0.
            wa_zco_tt_planpresm-color = 'C600'.
          ELSEIF lv_cantwog > 0.
            wa_zco_tt_planpresm-color = 'C500'.
          ENDIF.
          wa_zco_tt_planpresm-cantidadoriginal = lv_cantoriginal.
          APPEND  wa_zco_tt_planpresm TO gt_zco_tt_planpresm.

          IF wa_zco_tt_planpresm-autorizado EQ 'X' AND lv_cantwog GT 0.
            PERFORM row_readonly USING wa_zco_tt_planpresm
                  lv_fldnmecat
                  sy-tabix
                  'M'
                  'RO'.
          ELSE.
            PERFORM row_readonly USING wa_zco_tt_planpresm
                  lv_fldnmecat
                  sy-tabix
                  'M'
                  'RW'.
          ENDIF.

*          IF wa_zco_tt_planpresm-rsnum NE space.
*            REPLACE 'WOG' IN lv_fldnmecat WITH 'MEG'.
*            PERFORM row_readonly USING wa_zco_tt_planpresm
*                  lv_fldnmecat
*                  sy-tabix
*                  'R'
*                  'RO'.
*          ENDIF.


        ENDIF.
        "-----------------------------------------------------------------
      ENDLOOP.
      "---------------------------------------
    ENDIF.
*------------------------------------------------------*******
  ENDIF.

ENDFORM.                    " VALIDAR_MATERIALES
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0214   text
*----------------------------------------------------------------------*
FORM get_fieldcat  USING    VALUE(p_0214).
  DATA ls_fieldcat TYPE lvc_s_fcat.
  REFRESH fieldcat102.
  CLEAR ls_fieldcat.
  DATA mes_corto LIKE t247-ktx.
  DATA num_mes LIKE t247-mnr.
  DATA lv_txtcant(20) TYPE c.
  DATA lv_txtmonto(20) TYPE c.
  DATA lv_fldnmecat TYPE lvc_fname.
  DATA lv_fldnmemont TYPE lvc_fname.


  ls_fieldcat-fieldname = 'BEKNZ'.
  ls_fieldcat-outputlen = 1.
  ls_fieldcat-scrtext_m = ''.
  ls_fieldcat-checkbox = 'X'.
  "ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'KOKRS'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-scrtext_m = 'SOCIEDAD CO'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-scrtext_m = 'SOCIEDAD'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.
*seleccion-------------------
  IF p_0214 EQ 'ValidarMat'.


    ls_fieldcat-fieldname = 'KOSTL'.
    ls_fieldcat-outputlen = 10.
    ls_fieldcat-datatype = 'NUMC'.
    ls_fieldcat-scrtext_m = 'CeCo'.
    ls_fieldcat-col_opt = 'X'.
    ls_fieldcat-key = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.
  ENDIF.
*----------------------------------------
  ls_fieldcat-fieldname = 'WERKS'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-scrtext_m = 'CENTRO'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'MATNR'.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-datatype = 'NUMC'.
  ls_fieldcat-scrtext_m = 'MATERIAL'.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'MAKTX'.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-scrtext_m = 'DESCRIP.'.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'CO_MEINH'.
  ls_fieldcat-outputlen = 4.
  ls_fieldcat-scrtext_m = 'U.M.'.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'MATKL'.
  ls_fieldcat-outputlen = 9.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-scrtext_m = 'GPO. ART'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  " IF p_0214 EQ 'ElabSolpeds'.
  ls_fieldcat-fieldname = 'PLIFZ'.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-scrtext_m = 'DIAS ENTREGA'.
  ls_fieldcat-col_opt = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'LABST'.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-scrtext_m = 'STOCK LIB. UTIL.'.
  ls_fieldcat-col_opt = 'X'.
  "ls_fieldcat-no_out = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  " ENDIF.
*------------selección
  IF p_0214 EQ 'ValidarMat'.
    ls_fieldcat-fieldname = 'PREUNIPRES'.
    ls_fieldcat-outputlen = 10.
    ls_fieldcat-scrtext_m = 'PRECIO UNI.'.
    ls_fieldcat-col_opt = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.
  ENDIF.
*----------------------------------------
  PERFORM get_periodo USING p_monat
  CHANGING num_mes
    mes_corto
    lv_fldnmecat
    lv_fldnmemont.


  CONCATENATE 'CANT. PERIODO' mes_corto INTO lv_txtcant SEPARATED BY space.
  CONCATENATE 'MONTO PERIODO' mes_corto INTO lv_txtmonto SEPARATED BY space.

  IF p_0214 EQ 'ElabSolpeds'.
    REPLACE 'MEG' IN lv_fldnmecat WITH 'WOG'.
  ENDIF.
  ls_fieldcat-fieldname = lv_fldnmecat.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-scrtext_m = lv_txtcant.
  IF p_0214 EQ 'ValidarMat'.
    ls_fieldcat-edit      = 'X'.
  ENDIF.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-ref_field = lv_fldnmecat.
  ls_fieldcat-datatype = 'MEGXXX'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-just   = 'R'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.
*seleccion--
  IF p_0214 EQ 'ValidarMat'.
    ls_fieldcat-fieldname = lv_fldnmemont.
    ls_fieldcat-outputlen = 15.
    ls_fieldcat-scrtext_m = lv_txtmonto.
    ls_fieldcat-do_sum = 'X'.
    ls_fieldcat-col_opt = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.
*--------seleccion

*----seleccion
    ls_fieldcat-fieldname = 'CANTIDADORIGINAL'.
    ls_fieldcat-outputlen = 15.
    ls_fieldcat-scrtext_m = 'CTDAD. AUT. PRESUPUESTADO'.
    ls_fieldcat-col_opt = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.
  ENDIF.

  ls_fieldcat-fieldname = 'SOLPED'.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-scrtext_m = 'SOLPED'.
  ls_fieldcat-col_opt = 'X'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO fieldcat102.
  CLEAR ls_fieldcat.

  IF p_0214 EQ 'ValidarMat'.
    ls_fieldcat-fieldname = 'RSNUM'.
    ls_fieldcat-outputlen = 15.
    ls_fieldcat-scrtext_m = 'RESERVA'.
    ls_fieldcat-col_opt = 'X'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.
  ENDIF.



  IF p_0214 EQ 'ElabSolpeds'.
    ls_fieldcat-fieldname = 'ENMNG'.
    "ls_fieldcat-outputlen = 20.
    ls_fieldcat-scrtext_m = 'STOCK MINIMO'.
    ls_fieldcat-col_opt = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'TRAME'.
    ls_fieldcat-outputlen = 20.
    ls_fieldcat-scrtext_m = 'STOCK TRANSITO'.
    ls_fieldcat-col_opt = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.



    ls_fieldcat-fieldname = 'EISBE'.
    ls_fieldcat-outputlen = 20.
    ls_fieldcat-scrtext_m = 'STOCK CONSIGNA. TRAN.'.
    ls_fieldcat-col_opt = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'MABST'.
    ls_fieldcat-outputlen = 20.
    ls_fieldcat-scrtext_m = 'STOCK CONSIGNA.'.
    ls_fieldcat-col_opt = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.

*    ls_fieldcat-fieldname = 'RSNUM'.
*    ls_fieldcat-outputlen = 20.
*    ls_fieldcat-scrtext_m = 'RESERVA'.
*    ls_fieldcat-col_opt = 'X'.
*    ls_fieldcat-EDIT = 'X'.
*    ls_fieldcat-NO_OUT = 'X'.
*    APPEND ls_fieldcat TO fieldcat102.
*    CLEAR ls_fieldcat.
**
*    ls_fieldcat-fieldname = 'RSPOS'.
*    ls_fieldcat-outputlen = 20.
*    ls_fieldcat-scrtext_m = 'POS. RESERVA'.
*    ls_fieldcat-col_opt = 'X'.
*    APPEND ls_fieldcat TO fieldcat102.
*    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = 'BDMNG'.
    ls_fieldcat-outputlen = 20.
    ls_fieldcat-scrtext_m = 'CANT. RESERVA'.
    ls_fieldcat-col_opt = 'X'.
    APPEND ls_fieldcat TO fieldcat102.
    CLEAR ls_fieldcat.
  ENDIF.
ENDFORM.                    " GET_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  GET_PERIODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MONAT  text
*      <--P_NUM_MES  text
*      <--P_MES_CORTO  text
*      <--P_FIELDNAME  text
*----------------------------------------------------------------------*
FORM get_periodo  USING    p_p_monat TYPE monat
                  CHANGING p_num_mes LIKE t247-mnr
                    p_mes_corto LIKE t247-ktx
                    p_fieldnamecat TYPE lvc_fname
                    p_fieldnamemont TYPE lvc_fname.



  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_p_monat
    IMPORTING
      output = p_num_mes.

*CALL FUNCTION 'ISP_GET_MONTH_NAME' en ECC. En Hana esta FM ya no existe
*    EXPORTING
*      language     = sy-langu
*      month_number = p_num_mes
*    IMPORTING
*      shorttext    = p_mes_corto.

  "en Hana
  SELECT SINGLE kTX FROM t247
  INTO p_mes_corto
  WHERE spras = sy-langu
  AND mnr = p_num_mes.

  CONCATENATE 'MEG0' p_num_mes INTO p_fieldnamecat.
  CONCATENATE 'WTG0' p_num_mes INTO p_fieldnamemont.



ENDFORM.                    " GET_PERIODO
*&---------------------------------------------------------------------*
*&      Form  AUT_MATERIALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM aut_materiales .
  DATA: lv_answer TYPE char1.
  DATA lv_lines TYPE i.

  DATA: it_selected_rows TYPE lvc_t_row.

  DATA vl_mesactual(2) TYPE c.
  DATA vl_anioactual(4) TYPE c.
  DATA vl_date TYPE sy-datum.



  FIELD-SYMBOLS: <linea> TYPE any.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = 'Confirmación de materiales'
      text_question = '¿Esta seguro de confirmar los materiales seleccionados?'
      text_button_1 = 'SI'
      text_button_2 = 'No'
    IMPORTING
      answer        = lv_answer.      "display_cancel_button = 'X'
  IF lv_answer = '1'.

*   Se obtienen registros seleccionados. Sino, se autoriza todo.


*    CALL METHOD gref_alvgrid102->get_selected_rows
*      IMPORTING
*        et_index_rows = et_index_rows
*        et_row_no     = et_row_no.

    "se valida que solo sean periodos mayores al periodo actual.
    CALL FUNCTION 'CACS_DATE_GET_YEAR_MONTH'
      EXPORTING
        i_date  = sy-datum
      IMPORTING
        e_month = vl_mesactual
        e_year  = vl_anioactual.

    IF p_gjahr EQ vl_anioactual .

      IF p_monat LT vl_mesactual.
        MESSAGE 'Periodo no Válido para su aplicación.' TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ELSE.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          date      = sy-datum
          days      = 0
          months    = 0
          signum    = '+'
          years     = 1
        IMPORTING
          calc_date = vl_date.

      CALL FUNCTION 'CACS_DATE_GET_YEAR_MONTH'
        EXPORTING
          i_date  = vl_date
        IMPORTING
          e_month = vl_mesactual
          e_year  = vl_anioactual.


      IF p_gjahr EQ  vl_anioactual.
        IF NOT ( p_monat EQ '01' OR p_monat EQ '02' ).

          MESSAGE 'Solo se permite Ene/Feb en Ejerc Posterior ' TYPE 'S' DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
      ELSE.
        MESSAGE 'Solo se permite Ejerc Posterior + 1' TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.
    "-------------------------------------------------------------



    REFRESH it_aux[].
    it_aux[] = gt_zco_tt_planpresm[].
    SORT it_aux BY beknz.
    DELETE it_aux WHERE beknz NE 'X'.
    DESCRIBE TABLE it_aux LINES lv_lines.


    IF lv_lines > 0.
      "LOOP AT it_aux INTO wa_aux.
      LOOP AT gt_zco_tt_planpresm INTO wa_zco_tt_planpresm WHERE beknz EQ 'X'.
        IF wa_zco_tt_planpresm-autorizado NE 'X'.

          PERFORM save_auth_mat USING sy-tabix
          CHANGING wa_zco_tt_planpresm
            .
          "CLEAR wa_zco_tt_planpresm.
          MOVE-CORRESPONDING wa_aux TO wa_zco_tt_planpresm.
*          ASSIGN COMPONENT 'COLOR' OF STRUCTURE wa_zco_tt_planpresm TO <linea>.
*          <linea> = 'C500'.
          ASSIGN COMPONENT 'AUTORIZADO' OF STRUCTURE wa_zco_tt_planpresm TO <linea>.
          <linea> = 'X'.
          MODIFY gt_zco_tt_planpresm FROM wa_zco_tt_planpresm TRANSPORTING color autorizado
          WHERE idpres = wa_zco_tt_planpresm-idpres
          AND matnr = wa_zco_tt_planpresm-matnr
          AND kostl = wa_zco_tt_planpresm-kostl
          AND bukrs = wa_zco_tt_planpresm-bukrs
          AND prespos = wa_zco_tt_planpresm-prespos
          .

        ELSE.
          DELETE it_aux WHERE matnr = wa_zco_tt_planpresm-matnr AND
                              kokrs = wa_zco_tt_planpresm-kokrs AND
                              bukrs = wa_zco_tt_planpresm-bukrs AND
                              idpres = wa_zco_tt_planpresm-idpres AND
                              kostl = wa_zco_tt_planpresm-kostl AND
                              werks = wa_zco_tt_planpresm-werks AND
                              lgort = wa_zco_tt_planpresm-lgort.


          MOVE-CORRESPONDING wa_aux TO wa_zco_tt_planpresm.
*          ASSIGN COMPONENT 'COLOR' OF STRUCTURE wa_zco_tt_planpresm TO <linea>.
*          <linea> = 'C600'.
          MODIFY gt_zco_tt_planpresm FROM wa_zco_tt_planpresm TRANSPORTING color
          WHERE idpres = wa_zco_tt_planpresm-idpres
          AND matnr = wa_zco_tt_planpresm-matnr
          AND kostl = wa_zco_tt_planpresm-kostl
          AND bukrs = wa_zco_tt_planpresm-bukrs
          AND prespos = wa_zco_tt_planpresm-prespos
          .
          lv_answer = 'E'.

        ENDIF.
      ENDLOOP.
      " PERFORM reservas. se quita la reserva automática. 16/01/2024 por solicitud de Misael.
    ELSE.
      MESSAGE 'Seleccione los Materiales que desea Confirmar' TYPE 'S' DISPLAY LIKE 'W'.
    ENDIF.
    CALL METHOD gref_alvgrid102->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'.
  ENDIF.
  PERFORM limpiar_checkbox.
  IF lv_answer EQ 'E'.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = 'Materales sin Autorizar/Reservar'
        txt1  = 'Hubo Materiales que se quisieron autorizar'
        txt2  = 'pero ya estaban autorizados, y no se genero reserva. '
        txt3  = 'Estos, fueron marcados en rojo'
        txt4  = 'o autorizados parcialmente.'.

  ENDIF.
  REFRESH it_aux.
ENDFORM.                    " AUT_MATERIALES

*&---------------------------------------------------------------------*
*&      Form  RESERVAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reservas.

  TYPES: BEGIN OF st_collect,
           matnr    TYPE matnr18,
           co_meinh TYPE co_meinh,
           kostl    TYPE kostl,
           kstar    TYPE kstar,
           werks    TYPE werks_d,
           lgort    TYPE lgort_d,
           menge    TYPE menge_d,
         END OF st_collect.

  TYPES: BEGIN OF st_errores,
           matnr          TYPE matnr18,
           werks          TYPE werks_d,
           lgort          TYPE lgort_d,
           menge(8)       TYPE c,
           stock(10)      TYPE c,
           msg_error(220) TYPE c,
         END OF st_errores.

  DATA: it_errores TYPE STANDARD TABLE OF st_errores,
        wa_errores LIKE LINE OF it_errores.

  DATA: lv_umb TYPE mseh3.


  DATA: it_collect   TYPE STANDARD TABLE OF st_collect,
        it_collect_a TYPE STANDARD TABLE OF st_collect,
        wa_collect   LIKE LINE OF it_collect,
        wa_collect_a LIKE LINE OF it_collect_a.

  DATA it_aux LIKE gt_zco_tt_planpresm.
  "DATA wa_aux LIKE LINE OF it_aux.

  DATA: lv_lines    TYPE i,
        lv_stock    TYPE trame,
        lv_continue.

  DATA mes_corto LIKE t247-ktx.
  DATA num_mes LIKE t247-mnr.
  DATA lv_fldnmecat TYPE lvc_fname.
  DATA st_fldnmecat TYPE string.
  DATA it_periodo TYPE TABLE OF string.
  DATA lv_fldnmemont TYPE lvc_fname.
  DATA lv_answer TYPE c.
  FIELD-SYMBOLS: <ls_tabla> TYPE any,
                 <ls_linea> TYPE any.

  "bapi
  DATA: it_mrp_stock_detail TYPE bapi_mrp_stock_detail.
  DATA: reservationheader LIKE bapi2093_res_head,
        reservationitems  LIKE bapi2093_res_item OCCURS 0 WITH HEADER LINE,
        reservation       LIKE bapi2093_res_key-reserv_no.
  DATA: profitabilitysegment LIKE bapi_profitability_segment OCCURS 0 WITH HEADER LINE.
*        *BAPI Get Message(Return)
  DATA: return       LIKE bapiret2             OCCURS 0 WITH HEADER LINE.

  "---------------------
  lv_lines = 0.
  lv_continue = space.




  it_aux[] = gt_zco_tt_planpresm[].
  SORT it_aux BY beknz.
  DELETE it_aux WHERE beknz NE 'X'.
  DESCRIBE TABLE it_aux LINES lv_lines.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Solicitud de Reservas de Materiales'
      text_question  = '¿Deseas Continuar?'
      text_button_1  = 'SI, Reservar'
      text_button_2  = 'NO'
      default_button = '1'
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF lv_answer EQ '1'.

    IF lv_lines > 0.
      CLEAR wa_collect.

      "se obtiene el periodo consultado
      PERFORM get_periodo USING p_monat
      CHANGING num_mes
        mes_corto
        lv_fldnmecat
        lv_fldnmemont.

      SORT it_aux BY matnr kostl kstar werks lgort.
      REPLACE 'MEG' INTO lv_fldnmecat WITH 'WOG'.
      "se empiezan a agrupar los datos
      LOOP AT it_aux INTO DATA(wa_aux).

* se valida que el material seleccionado ya este confirmado
        IF wa_aux-autorizado EQ 'X' AND wa_aux-rsnum IS INITIAL.
          wa_collect-matnr = wa_aux-matnr.
          SELECT SINGLE msehi INTO lv_umb FROM t006a WHERE mseh3 =  wa_aux-co_meinh.

          wa_collect-co_meinh = lv_umb. "wa_aux-co_meinh.
          wa_collect-kostl = wa_aux-kostl.
          wa_collect-kstar = wa_aux-kstar.
          wa_collect-werks = wa_aux-werks.
          wa_collect-lgort = wa_aux-lgort.
          "se onbtiene la cantidad del mes/periodo consultado.
          READ TABLE it_aux ASSIGNING <ls_tabla> INDEX sy-tabix.
          ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE <ls_tabla> TO <ls_linea>.
          wa_collect-menge = <ls_linea>.
          APPEND wa_collect TO it_collect.
          UNASSIGN <ls_linea>.
        ELSEIF wa_aux-autorizado EQ 'X' AND wa_aux-rsnum IS NOT INITIAL.
        ELSE.
          CLEAR wa_errores.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = wa_aux-matnr
            IMPORTING
              output = wa_aux-matnr.

          wa_errores-matnr = wa_aux-matnr.
          wa_errores-werks = wa_aux-werks.
          wa_errores-lgort = wa_aux-lgort.
          CONCATENATE 'El material:' wa_errores-matnr 'no esta confirmado.'
          'Confirme previamente antes de reservar.'
          INTO wa_errores-msg_error SEPARATED BY space.
          APPEND wa_errores TO it_errores.
        ENDIF.
        IF it_errores IS NOT INITIAL.
          CALL FUNCTION 'ZUT_FLOATALV'
            EXPORTING
              i_start_column = 25
              i_start_line   = 6
              i_end_column   = 100
              i_end_line     = 10
              i_title        = 'Materiales sin Confirmar'
              i_popup        = 'X'
            TABLES
              it_alv         = it_errores.
          RETURN.
        ENDIF.
      ENDLOOP.
      "--------------se lanza un alv emergente para que se ingresen las cantidades

      LOOP AT it_collect INTO wa_collect.
        COLLECT wa_collect INTO it_collect_a.
      ENDLOOP.
      REFRESH reservationitems.
      CLEAR reservationheader.
      "se empiezan a hacer las Reservas
*      DATA: c_matnr    TYPE matnr,
*            c_kstar    TYPE kstar,
*            c_menge    TYPE menge_d,
*            c_werks    TYPE werks_d,
*            c_lgort    TYPE lgort_d,
*            c_co_meinh TYPE co_meinh
      .
      SORT it_collect BY kostl.
      DELETE ADJACENT DUPLICATES FROM it_collect COMPARING kostl.
      SORT it_collect_a BY kostl.

      LOOP AT it_collect INTO wa_collect.


        LOOP AT it_collect_a INTO wa_collect_a WHERE kostl = wa_collect-kostl.
*        c_matnr = wa_collect_a-matnr.
*        c_menge = wa_collect_a-menge.
*        c_werks = wa_collect_a-werks.
*        c_lgort = wa_collect_a-lgort.
*        c_co_meinh = wa_collect_a-co_meinh.
*        c_kstar =  wa_collect_a-kstar.

          reservationitems-entry_qnt  = wa_collect_a-menge. "cantidad a reservar
          lv_continue = 'X'.
****------------se consulta si hay Stock de libre utilización.
***10/08/2023 Se permite realizar la reserva, aún si no hay Stock de
** libre utilización, por eso se comenta el siguiente código, ya que
** la reserva se hará al momento de confirmar los materiales presupuestados
*
*        CALL FUNCTION 'BAPI_MATERIAL_STOCK_REQ_LIST'
*          EXPORTING
*            material         = wa_collect_a-matnr
*            plant            = wa_collect_a-werks
*          IMPORTING
*            mrp_stock_detail = it_mrp_stock_detail.
*        .
**
*        IF it_mrp_stock_detail-unrestricted_stck GT 0.
*          lv_stock = it_mrp_stock_detail-unrestricted_stck.
*          IF reservationitems-entry_qnt LE lv_stock.
*            lv_continue = 'X'.
*          ELSE.
*            lv_continue = ''.
*          ENDIF.
*        ENDIF.
*--------------------10/08/2023
***---------------------------------------------------------
          "       IF lv_continue EQ 'X'.
**        Header
          MOVE sy-datum             TO reservationheader-res_date.  "####
          MOVE '201'                TO reservationheader-move_type. "#### 311
          "MOVE wa_collect_a-werks   TO reservationheader-move_plant."##
          MOVE wa_collect_a-kostl   TO reservationheader-costcenter. "CeCo
          "MOVE wa_collect_a-lgort   TO reservationheader-move_stloc.
          MOVE sy-uname             TO reservationheader-created_by."###

*        Body

          MOVE wa_collect_a-matnr     TO reservationitems-material.  "##
          MOVE wa_collect_a-werks     TO reservationitems-plant.     "##
          MOVE wa_collect_a-lgort     TO reservationitems-stge_loc.
          MOVE wa_collect_a-co_meinh  TO reservationitems-entry_uom. "##
*          MOVE c_matnr     TO reservationitems-material.  "##
*          MOVE c_werks     TO reservationitems-plant.     "##
*          MOVE c_lgort     TO reservationitems-stge_loc.
*          MOVE c_co_meinh  TO reservationitems-entry_uom. "##
          MOVE 'X'                    TO reservationitems-movement.  "##X
          "MOVE c_kstar     TO reservationitems-gl_account. " Clase de Valoracion
          MOVE wa_collect_a-kstar     TO reservationitems-gl_account. " Clase de Valoracion
          APPEND reservationitems.

        ENDLOOP.

*          IF reservationitems-entry_qnt GT 0.
*
        CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
          EXPORTING
            reservationheader    = reservationheader
          IMPORTING
            reservation          = reservation
          TABLES
            reservationitems     = reservationitems
            profitabilitysegment = profitabilitysegment
            return               = return.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*
        IF reservation NE space.
*            "
          LOOP AT it_collect_a INTO wa_collect_a WHERE kostl = wa_collect-kostl.


            LOOP AT gt_zco_tt_planpresm INTO wa_zco_tt_planpresm
            WHERE matnr = wa_collect_a-matnr AND werks = wa_collect_a-werks
            AND lgort = wa_collect_a-lgort AND kostl = wa_collect_a-kostl.

              wa_zco_tt_planpresm-rsnum = reservation.
              MODIFY gt_zco_tt_planpresm FROM wa_zco_tt_planpresm TRANSPORTING rsnum WHERE idpres = wa_zco_tt_planpresm-idpres
              AND prespos = wa_zco_tt_planpresm-prespos
              .
              wa_zco_tt_planpresm-beknz = ''.
              UPDATE zco_tt_planpres SET rsnum = reservation WHERE idpres =  wa_zco_tt_planpresm-idpres
              AND prespos = wa_zco_tt_planpresm-prespos.

              IF sy-subrc = 0.
*                  MOVE-CORRESPONDING: wa_zco_tt_planpresm TO wa_zco_tt_reservas.
*                  wa_zco_tt_reservas-monat = p_monat.
*                  MODIFY zco_tt_reservas FROM wa_zco_tt_reservas.
                "se almacena en la nueva tabla de reservas y solpeds para su historial
                CLEAR wa_zco_reservassolpeds.
                REFRESH it_zco_reservassolpeds.
                wa_zco_reservassolpeds-idpres = wa_zco_tt_planpresm-idpres.
                wa_zco_reservassolpeds-zzversn = wa_zco_tt_planpresm-versn.
                wa_zco_reservassolpeds-prespos = wa_zco_tt_planpresm-prespos.
                wa_zco_reservassolpeds-zzpoper = p_monat.
                wa_zco_reservassolpeds-zzmenge = reservationitems-entry_qnt.
                wa_zco_reservassolpeds-zzreserva = reservation.
                wa_zco_reservassolpeds-zzfecreserva = sy-datum.
                wa_zco_reservassolpeds-zzgjahr = p_gjahr.
                wa_zco_reservassolpeds-zztiempoentrega = wa_zco_tt_planpresm-plifz.
                wa_zco_reservassolpeds-zztiempoent30 = wa_zco_tt_planpresm-plifz + 30.
                wa_zco_reservassolpeds-zzuname = sy-uname.
                APPEND wa_zco_reservassolpeds TO it_zco_reservassolpeds.
                INSERT zco_tt_datomatnr FROM TABLE it_zco_reservassolpeds.




                MESSAGE 'Reserva creada exitosamente.' TYPE 'S'.
                "SE inhabilita el check para evitar crear reserva nuevamente
                REPLACE 'WOG' INTO lv_fldnmecat WITH 'MEG'.
                PERFORM row_readonly USING wa_zco_tt_planpresm
                      lv_fldnmecat
                      sy-tabix
                      'R'
                      'RO'.
                "----------------------------------------------------------------
                stable-row = 'X'.
                stable-col = 'X'."*REfreshed ALV display with the changed values
                CALL METHOD gref_alvgrid102->refresh_table_display
                  EXPORTING
                    i_soft_refresh = 'X'
                    is_stable      = stable.

              ENDIF.
            ENDLOOP.
          ENDLOOP.
        ELSE.
          CLEAR wa_errores.
          CLEAR wa_zco_tt_planpresm.
          "se regresa el estatus del renglon autorizado, si es que no se hizo la reserva
          READ TABLE gt_zco_tt_planpresm INTO wa_zco_tt_planpresm WITH KEY
          matnr = wa_collect_a-matnr werks = wa_collect_a-werks
          lgort = wa_collect_a-lgort kostl = wa_collect_a-kostl.


          wa_zco_tt_planpresm-fechaaut = space.
          wa_zco_tt_planpresm-horaaut = space.
          wa_zco_tt_planpresm-autorizador = space.
          wa_zco_tt_planpresm-autorizado = ''.
          wa_zco_tt_planpresm-color = 'C200'.

          MODIFY gt_zco_tt_planpresm FROM wa_zco_tt_planpresm TRANSPORTING
          fechaaut horaaut autorizador autorizado color
          WHERE idpres = wa_zco_tt_planpresm-idpres
          AND prespos = wa_zco_tt_planpresm-prespos
          AND matnr = wa_collect_a-matnr
          AND werks = wa_collect_a-werks
          AND lgort = wa_collect_a-lgort
          AND kostl = wa_collect_a-kostl.
          .
          "---------------------------------------------------------------------
          REPLACE 'MEG' INTO lv_fldnmecat WITH 'WOG'.
          CONCATENATE lv_fldnmecat ' = 0 ' INTO st_fldnmecat.
          REFRESH it_periodo.
          APPEND st_fldnmecat TO it_periodo.
          wa_zco_tt_planpresm-beknz = ''.
          UPDATE zco_tt_planpres SET fechaaut = @space, horaaut = @space,
                 autorizador = @space, autorizado = @space, (it_periodo)
          WHERE idpres =  @wa_zco_tt_planpresm-idpres
          AND prespos = @wa_zco_tt_planpresm-prespos.
          REPLACE 'WOG' INTO lv_fldnmecat WITH 'MEG'.
          PERFORM row_readonly USING wa_zco_tt_planpresm
                  lv_fldnmecat
                  sy-tabix
                  'M'
                  'RW'.
          "se pone el color ------------------------------


          "----------------------------------------------------------------
          stable-row = 'X'.
          stable-col = 'X'."*REfreshed ALV display with the changed values
          CALL METHOD gref_alvgrid102->refresh_table_display
            EXPORTING
              i_soft_refresh = 'X'
              is_stable      = stable.

          "---------------------------------------------------------------------
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = wa_collect_a-matnr
            IMPORTING
              output = wa_collect_a-matnr.

          wa_errores-matnr = wa_collect_a-matnr.
          wa_errores-werks = wa_collect_a-werks.
          wa_errores-lgort = wa_collect_a-lgort.
          wa_errores-menge = wa_collect_a-menge.
          wa_errores-stock = lv_stock.
          LOOP AT return WHERE type = 'E'.
            CONCATENATE wa_errores return-message INTO wa_errores SEPARATED BY space.
          ENDLOOP.
          CONCATENATE 'Error en Material:' wa_errores-matnr
          ':' wa_errores-msg_error
          INTO wa_errores-msg_error SEPARATED BY space.
          APPEND wa_errores TO it_errores.
        ENDIF.

        REFRESH reservationitems.
        CLEAR reservationheader.

      ENDLOOP.
*          ELSE.
*            MESSAGE 'Cantidad menor o igual a 0.' TYPE 'S' DISPLAY LIKE 'E'.
*          ENDIF.
*        ELSE.
*          CLEAR wa_errores.
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*            EXPORTING
*              input  = wa_collect_a-matnr
*            IMPORTING
*              output = wa_collect_a-matnr.
*          wa_errores-matnr = wa_collect_a-matnr.
*          wa_errores-werks = wa_collect_a-werks.
*          wa_errores-lgort = wa_collect_a-lgort.
*          wa_errores-menge = wa_collect_a-menge.
*          wa_errores-stock = lv_stock.
*          CONCATENATE 'No se pudo crear la Reserva de este material:' wa_errores-matnr
*          'Ya que solo hay de Stock libre:' wa_errores-stock
*          INTO wa_errores-msg_error SEPARATED BY space.
*          APPEND wa_errores TO it_errores.
*          "MESSAGE 'No hay Stock suficiente para crear su Reserva.' TYPE 'S' DISPLAY LIKE 'E'.
*        ENDIF.
      "ENDLOOP.
      "si hubo errores
      IF it_errores IS NOT INITIAL.
        CALL FUNCTION 'ZUT_FLOATALV'
          EXPORTING
            i_start_column = 25
            i_start_line   = 6
            i_end_column   = 100
            i_end_line     = 10
            i_title        = 'No se genero la Reserva para este/estos Materiales'
            i_popup        = 'X'
          TABLES
            it_alv         = it_errores.
        .

      ENDIF.
    ELSE.
      MESSAGE 'Debe Seleccionar 1 fila para reservar' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF. "lv_lines > 0
  ELSE.
    MESSAGE 'Operación Cancelada' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF. "fin pregunta

ENDFORM.                    " RESERVAS
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM check_data  USING    p_er_data_changed
      TYPE REF TO cl_alv_changed_data_protocol..

  DATA: lv_cantidad TYPE megxxx,
        valor_base  TYPE megxxx.



  DATA: ls_cell  TYPE lvc_s_modi  .

  FIELD-SYMBOLS: <ft_data>  TYPE STANDARD TABLE,
                 <ls_tabla> TYPE any, "TYPE STANDARD TABLE gt_zco_tt_planpresm,
                 <ls_linea> TYPE any.

  DATA mes_corto LIKE t247-ktx.
  DATA num_mes LIKE t247-mnr.
  DATA lv_fldnmecat TYPE lvc_fname.
  DATA lv_fldnmemont TYPE lvc_fname.

  DATA: lv_idpres  TYPE char10,lv_prespos TYPE num5.


  ASSIGN p_er_data_changed->mp_mod_rows->* TO <ft_data>.
* READ TABLE p_er_data_changed->mp_mod_rows INTO ls_cell INDEX 1.
  IF sy-subrc EQ 0.
    READ TABLE <ft_data> ASSIGNING <ls_tabla> INDEX 1.
    CLEAR valor_base.
    CLEAR wa_zco_tt_planpres.
    CLEAR lv_cantidad.

    ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <ls_tabla> TO <ls_linea>.
    lv_idpres = <ls_linea>.
    UNASSIGN <ls_linea>.
    ASSIGN COMPONENT 'PRESPOS' OF STRUCTURE <ls_tabla> TO <ls_linea>.
    lv_prespos = <ls_linea>.
    UNASSIGN <ls_linea>.

    READ TABLE gt_zco_tt_planpres
    INTO wa_zco_tt_planpres
    WITH KEY idpres = lv_idpres prespos = lv_prespos.

    IF sy-subrc EQ 0.
      "se obtiene el periodo consultado
      PERFORM get_periodo USING p_monat
      CHANGING num_mes
        mes_corto
        lv_fldnmecat
        lv_fldnmemont.

      ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE <ls_tabla> TO <ls_linea>.
      lv_cantidad = <ls_linea>.
      UNASSIGN <ls_linea>.

      ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE wa_zco_tt_planpres TO <ls_linea>.
      valor_base = <ls_linea>.
      UNASSIGN <ls_linea>.
      IF lv_cantidad LE valor_base AND lv_cantidad > 0.
        ASSIGN COMPONENT 'SOLPED' OF STRUCTURE <ls_tabla> TO <ls_linea>.
        IF <ls_linea> EQ space.

          ASSIGN COMPONENT 'BEKNZ' OF STRUCTURE <ls_tabla> TO <ls_linea>.
          <ls_linea> = 'X'.

          MODIFY gt_zco_tt_planpresm FROM <ls_tabla> TRANSPORTING (lv_fldnmecat) beknz
          WHERE idpres = lv_idpres AND prespos = lv_prespos.

          stable-row  = 'X'.
          stable-col = 'X'.

          CALL METHOD gref_alvgrid102->refresh_table_display
            EXPORTING
              i_soft_refresh = 'X'
              is_stable      = stable.
        ELSE.
          READ TABLE p_er_data_changed->mt_mod_cells INTO ls_cell INDEX 1.

          p_er_data_changed->modify_cell(
          EXPORTING
            i_row_id    = ls_cell-row_id
            i_fieldname = lv_fldnmecat "ls_cell-fieldname
            i_value     = valor_base    " Value you want to input
            ).
          MESSAGE 'Imposible modificar, ya existe solped.' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ELSEIF lv_cantidad EQ 0.
        READ TABLE p_er_data_changed->mt_mod_cells INTO ls_cell INDEX 1.

        p_er_data_changed->modify_cell(
        EXPORTING
          i_row_id    = ls_cell-row_id
          i_fieldname = lv_fldnmecat"ls_cell-fieldname
          i_value     = valor_base    " Value you want to input
          ).

        ASSIGN COMPONENT 'BEKNZ' OF STRUCTURE <ls_tabla> TO <ls_linea>.
        <ls_linea> = ''.

        MODIFY gt_zco_tt_planpresm FROM <ls_tabla> TRANSPORTING (lv_fldnmecat) beknz
        WHERE idpres = lv_idpres AND prespos = lv_prespos.

        stable-row  = 'X'.
        stable-col = 'X'.

        CALL METHOD gref_alvgrid102->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = stable.

        MESSAGE 'No puede ingresar cantidades en Cero' TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.
        READ TABLE p_er_data_changed->mt_mod_cells INTO ls_cell INDEX 1.

        p_er_data_changed->modify_cell(
        EXPORTING
          i_row_id    = ls_cell-row_id
          i_fieldname = lv_fldnmecat"ls_cell-fieldname
          i_value     = valor_base    " Value you want to input
          ).

        ASSIGN COMPONENT 'BEKNZ' OF STRUCTURE <ls_tabla> TO <ls_linea>.
        <ls_linea> = ''.

        MODIFY gt_zco_tt_planpresm FROM <ls_tabla> TRANSPORTING (lv_fldnmecat) beknz
        WHERE idpres = lv_idpres AND prespos = lv_prespos.

        stable-row  = 'X'.
        stable-col = 'X'.

        CALL METHOD gref_alvgrid102->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = stable.


        MESSAGE 'Cantidad mayor a la presupuestada.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_DATA
*&---------------------------------------------------------------------*
*&      Form  CONTAINERS_FREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM containers_free.
  IF NOT gref_alvgrid102 IS INITIAL.
    " destroy tree container (detroys contained tree control, too)
    CALL METHOD gref_alvgrid102->free
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
    IF sy-subrc <> 0.
      "MESSAGE A000.
    ENDIF.


    CALL METHOD gref_ccontainer102->free
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
    IF sy-subrc <> 0.
      "MESSAGE A000.
    ENDIF.

    CLEAR gref_ccontainer102.
    CLEAR gref_alvgrid102.
  ENDIF.

ENDFORM.                    " CONTAINERS_FREE
*&---------------------------------------------------------------------*
*&      Form  containers_free101
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM containers_free101.

  TRY.
      CALL METHOD gref_alvgrid101->free.
      CLEAR gref_alvgrid101.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.

  TRY.
      CALL METHOD gref_ccontainer101->free.
      CLEAR gref_ccontainer101.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.

  TRY.
      CALL METHOD gref_alvgrid101d->free.
      CLEAR gref_alvgrid101d.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.

  TRY.
      CALL METHOD gref_ccontainer101d->free.
      CLEAR gref_ccontainer101d.
    CATCH cx_sy_ref_is_initial.

  ENDTRY.

ENDFORM.                    "containers_free101
*&---------------------------------------------------------------------*
*&      Form  SAVE_AUTH_MAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZCO_TT_PLANPRESM  text
*----------------------------------------------------------------------*
FORM save_auth_mat  USING p_indice
CHANGING    p_wa_zco_tt_planpresm TYPE st_zco_tt_planpresm.
  DATA mes_corto LIKE t247-ktx.
  DATA num_mes LIKE t247-mnr.
  DATA lv_fldnmecat TYPE lvc_fname.
  DATA lv_fldnmecat2 TYPE lvc_fname. "cantidad real autorizada/solicitada

  DATA: lv_cantalv TYPE megxxx.
  DATA lv_fldnmemont TYPE lvc_fname.
  FIELD-SYMBOLS: <ls_tabla> TYPE any,
                 <linea>    TYPE any.
  DATA: cant_base  TYPE megxxx,
        cant_nueva TYPE megxxx.

  PERFORM get_periodo USING p_monat
  CHANGING num_mes
    mes_corto
    lv_fldnmecat
    lv_fldnmemont.

  lv_fldnmecat2 = lv_fldnmecat.
  REPLACE 'MEG' IN lv_fldnmecat2 WITH 'WOG'.


  IF p_wa_zco_tt_planpresm-solped EQ space.
    CLEAR wa_zco_tt_planpres.
    MOVE-CORRESPONDING: p_wa_zco_tt_planpresm TO wa_zco_tt_planpres.

    ASSIGN p_wa_zco_tt_planpresm TO <ls_tabla>.
    ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE <ls_tabla> TO <linea>.
    cant_nueva = <linea>.
    IF cant_nueva EQ 0.
      MESSAGE 'No puede autorizar materiales con cantidades en Cero' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    UNASSIGN <linea>.

    ASSIGN COMPONENT 'CANTIDADORIGINAL' OF STRUCTURE <ls_tabla> TO <linea>.
    cant_base = <linea>.
    UNASSIGN <linea>.

    wa_zco_tt_planpres-fechaaut = sy-datum.
    wa_zco_tt_planpres-horaaut = sy-uzeit.
    wa_zco_tt_planpres-autorizador = sy-uname.
    wa_zco_tt_planpres-autorizado = 'X'.
    "wa_zco_tt_planpres-beknz = ''.
    "Se complementan con ceros matnr
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_zco_tt_planpres-matnr
      IMPORTING
        output = wa_zco_tt_planpres-matnr.

    "----------------------------------------------
    MODIFY zco_tt_planpres FROM wa_zco_tt_planpres.

    ASSIGN wa_zco_tt_planpres TO <ls_tabla>.
    ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE <ls_tabla> TO <linea>.
    <linea> = cant_base.

    ASSIGN COMPONENT lv_fldnmecat2 OF STRUCTURE <ls_tabla> TO <linea>.
    <linea> = cant_nueva + <linea>.
    lv_cantalv = cant_base - <linea>.

    "  ASSIGN COMPONENT lv_fldnmecat OF STRUCTURE p_wa_zco_tt_planpresm TO <linea>.
    "  <linea> = lv_cantalv.
    "se pone el color ------------------------------
    ASSIGN COMPONENT 'COLOR' OF STRUCTURE p_wa_zco_tt_planpresm TO <linea>.
    IF lv_cantalv > 0.
      <linea> = 'C500'.
    ELSE.
      <linea> = 'C600'.
    ENDIF.


    "-----------------------------
    MODIFY zco_tt_planpres FROM <ls_tabla>.
    ASSIGN COMPONENT lv_fldnmecat2 OF STRUCTURE p_wa_zco_tt_planpresm TO <linea>.
    <linea> = cant_nueva.

    p_wa_zco_tt_planpresm-fechaaut = sy-datum.
    p_wa_zco_tt_planpresm-horaaut = sy-uzeit.
    p_wa_zco_tt_planpresm-autorizador = sy-uname.
    p_wa_zco_tt_planpresm-autorizado = 'X'.
    p_wa_zco_tt_planpresm-beknz = ''.

    MODIFY gt_zco_tt_planpresm FROM p_wa_zco_tt_planpresm
    TRANSPORTING (lv_fldnmecat) (lv_fldnmecat2) fechaaut horaaut autorizador autorizado beknz
    WHERE matnr = p_wa_zco_tt_planpresm-matnr
    AND prespos = p_wa_zco_tt_planpresm-prespos
    AND kostl = p_wa_zco_tt_planpresm-kostl
    AND bukrs = p_wa_zco_tt_planpresm-bukrs
    AND idpres = p_wa_zco_tt_planpresm-idpres
    .

    MODIFY it_aux FROM p_wa_zco_tt_planpresm
    TRANSPORTING (lv_fldnmecat) (lv_fldnmecat2) fechaaut horaaut autorizador autorizado beknz
    WHERE matnr = p_wa_zco_tt_planpresm-matnr
    AND prespos = p_wa_zco_tt_planpresm-prespos
    AND kostl = p_wa_zco_tt_planpresm-kostl
    AND bukrs = p_wa_zco_tt_planpresm-bukrs
    AND idpres = p_wa_zco_tt_planpresm-idpres
    .

    "Se deshabilita la celda de Cantidad porque ya fue autorizado.
    PERFORM row_readonly USING p_wa_zco_tt_planpresm
          lv_fldnmecat
          p_indice
          'M'
          'RO'.
    "------------------------------------------------------------------
  ENDIF.

ENDFORM.                    " SAVE_AUTH_MAT

*&---------------------------------------------------------------------*
*&      Form  validCantEdit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
"validCantEdit
*&---------------------------------------------------------------------*
*&      Form  VALIDA_EDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM valida_edit  USING    p_er_data_changed
      TYPE REF TO cl_alv_changed_data_protocol
CHANGING
  p_edit TYPE c.

  DATA: lv_fieldname TYPE fieldname.

  FIELD-SYMBOLS: <ft_data>   TYPE STANDARD TABLE,
                 <ft_cells>  TYPE lvc_t_modi,
                 <ls_tabla>  TYPE any,
                 <ls_tabla2> TYPE any,
                 <linea>     TYPE any.

  ASSIGN p_er_data_changed->mt_mod_cells TO <ft_cells>.
  DELETE <ft_cells> WHERE fieldname = 'BEKNZ'.

  READ TABLE <ft_cells> ASSIGNING <ls_tabla> INDEX 1.
  ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <ls_tabla> TO <linea>.

  lv_fieldname = <linea>.
  UNASSIGN <ft_cells>.
  UNASSIGN <ls_tabla>.
  UNASSIGN <linea>.

  IF lv_fieldname EQ 'BEKNZ'.
    p_edit = 'C'.
  ELSE.
    ASSIGN p_er_data_changed->mp_mod_rows->* TO <ft_data>.
    READ TABLE <ft_data> ASSIGNING <ls_tabla2> INDEX 1.
    ASSIGN COMPONENT 'SOLPED' OF STRUCTURE <ls_tabla2> TO <linea>.
    IF <linea> EQ space.
      p_edit = 'S'.
    ELSE.
      p_edit = ''.
    ENDIF.
  ENDIF.

ENDFORM.                    " VALIDA_EDIT
*&---------------------------------------------------------------------*
*&      Form  GETDATA4SOLPED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM getdata4solped .
  REFRESH: it_cecos,it_cecos_indice,gt_zco_tt_planpresm.
  FIELD-SYMBOLS: <ls_wa>    TYPE any, <linea> TYPE any,
                 <ls_matnr> TYPE st_zco_tt_planpresm.
  DATA: t_mrp_stock_detail TYPE bapi_mrp_stock_detail,
        t_mrp_list         TYPE bapi_mrp_list,
        t_return           TYPE bapiret2.


  TYPES: BEGIN OF st_auxiliar,
           "       idpres TYPE  char10,
           "       prepos TYPE num5,
           matnr  TYPE matnr,
           werks  TYPE werks_d,
           wogxxx TYPE wogxxx,
         END OF st_auxiliar.

  DATA: it_auxiliar TYPE STANDARD TABLE OF st_auxiliar,
        wa_auxiliar LIKE LINE OF it_auxiliar.
  DATA: bdmng        TYPE megxxx, enmng TYPE megxxx, total TYPE megxxx,
        vl_monat     TYPE string,
        vl_monatc(6) TYPE c,
        num_mes      TYPE fcmnr,
        lv_where     TYPE TABLE OF string.

  "se obtienen los datos
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_monat
    IMPORTING
      output = num_mes.

*  CONCATENATE 'WOG0' num_mes INTO vl_monat.
*  APPEND 'gjahr EQ @p_gjahr AND p~kokrs EQ @p_kokrs' TO lv_where.
*  APPEND 'AND p~kostl IN @skostl' TO lv_where.
*  APPEND 'AND   p~matnr IN @smatnr' TO lv_where.
*  APPEND 'AND autorizado EQ ''X''' TO lv_where.
*  APPEND 'AND tipmod = ''F''' TO lv_where.
*  APPEND 'AND versn = @P_VERSN' TO lv_where.
*  CONCATENATE 'AND WOG0' num_mes ' gt 0' INTO vl_monat.
*  APPEND vl_monat TO lv_where.
*
*  .
*
*  "update zco_tt_planpres set autorizado = @space, solped = @space, solpedpos = @space, rsnum = @space.
*
*
*
*  SELECT
*  "p~idpres, p~prespos,
*  kokrs, gjahr, bukrs,
*  p~matnr, maktx, co_meinh,
*  SUM( wog001 ) AS wog001, SUM( wog002 ) AS wog002, sum( wog003 ) as wog003,
*  SUM( wog004 ) as wog004, SUM( wog005 ) as wog005, SUM( wog006 ) as wog006,
*  SUM( wog007 ) as wog007, SUM( wog008 ) as wog008, SUM( wog009 ) as wog009,
*  SUM( wog010 ) as wog010, SUM( wog011 ) as wog011, SUM( wog012 ) as wog012,
*  p~werks, lgort, matkl, autorizado, d~zzsolped AS solped,
*  p~rsnum, p~bdmng, p~enmng, m~eisbe, m~mabst, p~trame, p~labst, m~plifz, p~preunipres
*  INTO CORRESPONDING FIELDS OF TABLE @gt_zco_tt_planpres
*  FROM zco_tt_planpres AS p
*  LEFT JOIN marc AS m ON m~matnr EQ p~matnr AND m~werks EQ p~werks
*  LEFT JOIN zco_tt_datomatnr AS d ON d~idpres = p~idpres AND d~prespos = p~prespos
*            AND d~zzpoper EQ @num_mes AND d~zzgjahr = p~gjahr
*  WHERE (lv_where)
*  group by kokrs, gjahr, bukrs, p~matnr, maktx, co_meinh,
*           p~werks, lgort, matkl, autorizado, d~zzsolped,
*            p~rsnum, p~bdmng, p~enmng, m~eisbe, m~mabst, p~trame, p~labst,
*            m~plifz, p~preunipres.

  CONCATENATE 'WOG0' num_mes INTO vl_monat.
  vl_monatc = vl_monat.
  APPEND 'gjahr EQ p_gjahr AND p~kokrs EQ p_kokrs' TO lv_where.
  APPEND 'AND p~kostl IN skostl' TO lv_where.
  APPEND 'AND   p~matnr IN smatnr' TO lv_where.
  APPEND 'AND autorizado EQ ''X''' TO lv_where.
  APPEND 'AND tipmod = ''F''' TO lv_where.
  APPEND 'AND versn = P_VERSN' TO lv_where.
  CONCATENATE 'AND WOG0' num_mes ' gt 0' INTO vl_monat.
  APPEND vl_monat TO lv_where.
  .

  SELECT
  p~mandt p~idpres p~prespos kokrs gjahr bukrs versn kostl kstar buzei
  p~matnr servno cuenta maktx tipo twaer periodo co_meinh prunmx
  wtg001 wtg002 wtg003 wtg004 wtg005 wtg006 wtg007 wtg008 wtg009 wtg010 wtg011 wtg012 wtgtot
  wog001 wog002 wog003 wog004 wog005 wog006 wog007 wog008 wog009 wog010 wog011 wog012 wogtot
  meg001 meg002 meg003 meg004 meg005 meg006 meg007 meg008 meg009 meg010 meg011 meg012 megtot
  gkoar p~werks lgort sgtxt wkurs equnr aufnr ingrp matkl perio tipser texexp tipmod fecmod
  usuario fecha hora autorizado autorizador fechaaut horaaut areas zona d~zzsolped AS solped solpedpos
  p~menge p~rsnum p~rspos p~bdmng p~enmng m~eisbe m~mabst p~trame p~labst m~plifz p~preunipres
  INTO CORRESPONDING FIELDS OF TABLE gt_zco_tt_planpres
  FROM zco_tt_planpres AS p
  LEFT JOIN marc AS m ON m~matnr EQ p~matnr AND m~werks EQ p~werks
  LEFT JOIN zco_tt_datomatnr AS d ON d~idpres = p~idpres AND d~prespos = p~prespos
            AND d~zzpoper EQ num_mes AND d~zzgjahr = p~gjahr
  WHERE (lv_where).

  SORT gt_zco_tt_planpres BY werks matnr.
  LOOP AT gt_zco_tt_planpres INTO wa_zco_tt_planpres.
    "se obtiene el stock en transito y el stock libre utilización

    CALL FUNCTION 'BAPI_MATERIAL_STOCK_REQ_LIST'
      EXPORTING
        material         = wa_zco_tt_planpres-matnr
        plant            = wa_zco_tt_planpres-werks
        get_ind_lines    = 'X'
      IMPORTING
        mrp_stock_detail = t_mrp_stock_detail
        mrp_list         = t_mrp_list
        return           = t_return.

    IF t_mrp_stock_detail IS NOT INITIAL.

      wa_zco_tt_planpres-trame = t_mrp_stock_detail-pur_orders.
      wa_zco_tt_planpres-labst = t_mrp_stock_detail-unrestricted_stck.
      wa_zco_tt_planpres-bdmng = t_mrp_stock_detail-fixed_issues.
      wa_zco_tt_planpres-mabst = t_mrp_stock_detail-unres_consi. "Consignacion Libre.
      wa_zco_tt_planpres-eisbe = t_mrp_stock_detail-consig_ord. "Consignacion Libre.
      wa_zco_tt_planpres-enmng = t_mrp_list-minlotsize. "Stock Minimo


      MODIFY gt_zco_tt_planpres FROM wa_zco_tt_planpres
      TRANSPORTING trame labst bdmng mabst eisbe enmng
      WHERE matnr =  wa_zco_tt_planpres-matnr
      AND werks = wa_zco_tt_planpres-werks.
    ELSE.
      wa_zco_tt_planpres-mabst = t_mrp_stock_detail-unres_consi. "Consignacion Libre.
      wa_zco_tt_planpres-eisbe = t_mrp_stock_detail-consig_ord. "Consignacion Libre.
      wa_zco_tt_planpres-enmng = t_mrp_list-minlotsize. "Stock Minimo
      MODIFY gt_zco_tt_planpres FROM wa_zco_tt_planpres
      TRANSPORTING  mabst eisbe enmng
      WHERE matnr =  wa_zco_tt_planpres-matnr
      AND werks = wa_zco_tt_planpres-werks.
    ENDIF.
*    "-------------------------------------------------------------------

  ENDLOOP.

  REFRESH gt_zco_tt_planpresm.

  LOOP AT gt_zco_tt_planpres ASSIGNING <ls_wa>.
    CLEAR: wa_auxiliar, wa_zco_tt_planpresm.

    MOVE-CORRESPONDING <ls_wa> TO wa_zco_tt_planpresm.
    MOVE-CORRESPONDING <ls_wa> TO wa_auxiliar.
    CASE vl_monatc.
      WHEN 'WOG001'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog001.
      WHEN 'WOG002'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog002.
      WHEN 'WOG003'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog003.
      WHEN 'WOG004'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog004.
      WHEN 'WOG005'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog005.
      WHEN 'WOG006'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog006.
      WHEN 'WOG007'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog007.
      WHEN 'WOG008'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog008.
      WHEN 'WOG009'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog009.
      WHEN 'WOG010'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog010.
      WHEN 'WOG011'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog011.
      WHEN 'WOG012'.
        wa_auxiliar-wogxxx = wa_zco_tt_planpresm-wog012.
      WHEN OTHERS.
    ENDCASE.
    APPEND  wa_zco_tt_planpresm TO gt_zco_tt_planpresm.
    COLLECT wa_auxiliar INTO it_auxiliar.

  ENDLOOP.

  CLEAR wa_auxiliar.
  LOOP AT it_auxiliar INTO wa_auxiliar.
    LOOP AT gt_zco_tt_planpresm ASSIGNING <ls_matnr> WHERE werks = wa_auxiliar-werks
                                AND matnr = wa_auxiliar-matnr .
      CASE vl_monatc.
        WHEN 'WOG001'.
          <ls_matnr>-wog001 = wa_auxiliar-wogxxx .
        WHEN 'WOG002'.
          <ls_matnr>-wog002 = wa_auxiliar-wogxxx .
        WHEN 'WOG003'.
          <ls_matnr>-wog003 = wa_auxiliar-wogxxx.
        WHEN 'WOG004'.
          <ls_matnr>-wog004 = wa_auxiliar-wogxxx.
        WHEN 'WOG005'.
          <ls_matnr>-wog005 = wa_auxiliar-wogxxx.
        WHEN 'WOG006'.
          <ls_matnr>-wog006 = wa_auxiliar-wogxxx.
        WHEN 'WOG007'.
          <ls_matnr>-wog007 = wa_auxiliar-wogxxx.
        WHEN 'WOG008'.
          <ls_matnr>-wog008 = wa_auxiliar-wogxxx.
        WHEN 'WOG009'.
          <ls_matnr>-wog009 = wa_auxiliar-wogxxx.
        WHEN 'WOG010'.
          <ls_matnr>-wog010 = wa_auxiliar-wogxxx.
        WHEN 'WOG011'.
          <ls_matnr>-wog011 = wa_auxiliar-wogxxx.
        WHEN 'WOG012'.
          <ls_matnr>-wog012 = wa_auxiliar-wogxxx.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM  gt_zco_tt_planpresm COMPARING werks matnr.

ENDFORM.                    " GETDATA4SOLPED
*&---------------------------------------------------------------------*
*&      Form  SOLPEDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM solpeds .
********** definición de variables de solped********
  "si no, creamos pedido e imprimimos.
  DATA: it_item             TYPE TABLE OF  bapiebanc,
        it_cuentas          TYPE TABLE OF  bapiebkn,
        it_servicios        TYPE TABLE OF  bapiesllc,
        it_servicioscuentas TYPE TABLE OF  bapiesklc,
        returnsp            TYPE TABLE OF  bapireturn,
        it_text             TYPE TABLE OF bapiebantx,
        wa_text             LIKE LINE OF it_text,
        wa_item             LIKE LINE OF it_item,
        wa_cuentas          LIKE LINE OF it_cuentas,
        number              LIKE  bapiebanc-preq_no.

  DATA: return  LIKE bapiret2    OCCURS 0 WITH HEADER LINE.
  DATA: return_all  LIKE bapiret2    OCCURS 0 WITH HEADER LINE.

*************************************************
  DATA: pos TYPE i.
  DATA lv_lines TYPE i.
  DATA: lv_renglon TYPE i.
  DATA: lv_answer TYPE char1.
  DATA vl_date TYPE sy-datum.
* define local data
  DATA lt_rows   TYPE lvc_t_row.

  TYPES: BEGIN OF st_agpo_solped,
           kokrs TYPE kokrs,
           bukrs TYPE bukrs,
           matnr TYPE matnr,
           menge TYPE menge_d,
           werks TYPE werks_d,
           lgort TYPE lgort,
         END OF st_agpo_solped.

  DATA: it_aux         LIKE gt_zco_tt_planpresm,
        wa_aux         LIKE LINE OF it_aux,
        it_agpo_solped TYPE STANDARD TABLE OF st_agpo_solped,
        wa_agpo_solped LIKE LINE OF it_agpo_solped.

  DATA lv_acumulado TYPE menge_d.
  DATA: vl_mesactual(2)  TYPE c,
        vl_anioactual(4) TYPE c.

  pos = 0.
  lv_renglon = 0.
  lv_lines = 0.



  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Confirmación de materiales'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = '¿Seguro de generar la Solped de los materiales seleccionados?'
      text_button_1         = 'SI'
      text_button_2         = 'No'
      display_cancel_button = ''
    IMPORTING
      answer                = lv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF lv_answer = '2'.

    MESSAGE 'Operación Cancelada.' TYPE 'S' DISPLAY LIKE 'W'.

  ELSEIF lv_answer = '1'.

    "se valida que solo sean periodos mayores al periodo actual.
    CALL FUNCTION 'CACS_DATE_GET_YEAR_MONTH'
      EXPORTING
        i_date  = sy-datum
      IMPORTING
        e_month = vl_mesactual
        e_year  = vl_anioactual.

    IF p_gjahr EQ vl_anioactual .

      IF p_monat LT vl_mesactual.
        MESSAGE 'Periodo no Válido para su aplicación.' TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ELSE.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          date      = sy-datum
          days      = 0
          months    = 0
          signum    = '+'
          years     = 1
        IMPORTING
          calc_date = vl_date.

      CALL FUNCTION 'CACS_DATE_GET_YEAR_MONTH'
        EXPORTING
          i_date  = vl_date
        IMPORTING
          e_month = vl_mesactual
          e_year  = vl_anioactual.


      IF p_gjahr EQ  vl_anioactual.
        IF NOT ( p_monat EQ '01' OR p_monat EQ '02' ).

          MESSAGE 'Solo se permite Ene/Feb en Ejerc Posterior ' TYPE 'S' DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
      ELSE.
        MESSAGE 'Solo se permite Ejerc Posterior + 1' TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.
    "-------------------------------------------------------------







    it_aux[] = gt_zco_tt_planpresm[].
    SORT it_aux BY beknz.
    DELETE it_aux WHERE beknz NE 'X'.

    "Se construye una tabla auxiliar para agrupar mismo material con diferentes cantidades, mismo centro
    " pero diferente CeCo. Se va a Generar la solped por Centro Logistico, no por CeCo.
    "sociedad Co Sociedad material, cantidad centro almacen
    DESCRIBE TABLE it_aux LINES lv_lines.
    IF lv_lines EQ 0.
      MESSAGE 'Debe seleccionar al menos 1 material para generar la Solped' TYPE 'S' DISPLAY LIKE 'E'.
    ELSE.
      SORT it_aux BY matnr werks lgort.
      PERFORM build_solped USING it_aux.
    ENDIF.

  ENDIF. "esta seguro de crear solped
ENDFORM.                    " SOLPEDS
*&---------------------------------------------------------------------*
*&      Form  CREA_SOLPED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM crea_solped USING p_lt_rows TYPE STANDARD TABLE.
  DATA lv_lines TYPE i.
  DATA ls_rows TYPE lvc_s_row.
  DATA validador.


  DESCRIBE TABLE t_pr_item LINES lv_lines.

  TYPES: BEGIN OF st_error,
           type    TYPE c,
           id      TYPE symsgid,
           number  TYPE symsgno,
           message TYPE bapi_msg,
         END OF st_error.
  DATA: it_error TYPE STANDARD TABLE OF st_error,
        wa_error LIKE LINE OF it_error.

  CALL FUNCTION 'BAPI_PR_CREATE'
    EXPORTING
      prheader  = prheader
      prheaderx = prheaderx
    IMPORTING
      number    = solped
    TABLES
      return    = retorno
      pritem    = t_pr_item
      pritemx   = t_pr_itemx
*     praccount = t_praccount
*     praccountx = t_praccountx
    .

************************ commit de solped
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

******************+ SI SE CREO SOLPED
  CONDENSE solped NO-GAPS.
  validador = solped.
  IF validador NE '#'.

    " LOOP AT it_registros INTO wa_registros.
    LOOP AT p_lt_rows INTO wa_registros.
      CLEAR wa_zco_tt_planpresm.
      READ TABLE gt_zco_tt_planpresm INTO wa_zco_tt_planpresm
      WITH KEY idpres = wa_registros-idpres
      prespos = wa_registros-prespos
      bukrs = wa_registros-bukrs
      werks = wa_registros-werks
      matnr = wa_registros-matnr.
      IF sy-subrc EQ 0.
        wa_zco_tt_planpresm-solped = solped.
        wa_zco_tt_planpresm-solpedpos = wa_registros-pos.
        wa_zco_tt_planpresm-menge = wa_registros-menge.


        MODIFY gt_zco_tt_planpresm FROM wa_zco_tt_planpresm TRANSPORTING solped solpedpos menge
        WHERE bukrs = wa_zco_tt_planpresm-bukrs
        AND matnr = wa_zco_tt_planpresm-matnr
        AND werks = wa_zco_tt_planpresm-werks
        AND prespos = wa_registros-prespos
        AND idpres = wa_registros-idpres
        .

        UPDATE zco_tt_planpres SET solped = wa_zco_tt_planpresm-solped
        solpedpos = wa_zco_tt_planpresm-solpedpos
        menge = wa_zco_tt_planpresm-menge
        WHERE bukrs = wa_zco_tt_planpresm-bukrs
        AND matnr = wa_zco_tt_planpresm-matnr
        AND werks = wa_zco_tt_planpresm-werks
        AND prespos = wa_registros-prespos
        AND idpres = wa_registros-idpres
        AND autorizado = 'X'
        AND tipmod = 'F'
        AND gjahr = p_gjahr.
        "se guarda la solped
        CLEAR wa_zco_reservassolpeds.
        REFRESH it_zco_reservassolpeds.
        wa_zco_reservassolpeds-idpres = wa_zco_tt_planpresm-idpres.
        wa_zco_reservassolpeds-zzversn = wa_zco_tt_planpresm-versn.
        wa_zco_reservassolpeds-prespos = wa_zco_tt_planpresm-prespos.
        wa_zco_reservassolpeds-zzpoper = p_monat.
        wa_zco_reservassolpeds-zzmenge = wa_zco_tt_planpresm-menge.
        wa_zco_reservassolpeds-zzsolped = solped.
        wa_zco_reservassolpeds-zzfecsolped = sy-datum.
        wa_zco_reservassolpeds-zzgjahr = p_gjahr.
        wa_zco_reservassolpeds-zztiempoentrega = wa_zco_tt_planpresm-plifz.
        wa_zco_reservassolpeds-zztiempoent30 = wa_zco_tt_planpresm-plifz + 30.
        wa_zco_reservassolpeds-zzuname = sy-uname.
        APPEND wa_zco_reservassolpeds TO it_zco_reservassolpeds.
        INSERT zco_tt_datomatnr FROM TABLE it_zco_reservassolpeds.

        MESSAGE 'Solped Creada: ' TYPE 'S'.
      ENDIF.
    ENDLOOP.


  ELSE.
    LOOP AT retorno INTO wa_retorno.
      wa_error-type = wa_retorno-type.
      wa_error-id = wa_retorno-id.
      wa_error-number = wa_retorno-number.
      wa_error-message = wa_retorno-message.
      APPEND wa_error TO it_error.
    ENDLOOP.
    PERFORM show_alvpopup USING it_error.
  ENDIF.


  CALL METHOD gref_alvgrid102->refresh_table_display
    EXPORTING
*     i_soft_refresh = 'X'
      is_stable = stable.
  REFRESH it_registros.
ENDFORM.                    " CREA_SOLPED
*&---------------------------------------------------------------------*
*&      Form  BUILD_SOLPED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*----------------------------------------------------------------------*
FORM build_solped  USING    p_lt_rows TYPE STANDARD TABLE.

  DATA: it_log TYPE STANDARD TABLE OF zco_tt_logpres,
        wa_log LIKE LINE OF it_log.


  TYPES: BEGIN OF st_collect,
           matnr      TYPE matnr18,
           co_meinh   TYPE co_meinh,
           werks      TYPE werks_d,
           lgort      TYPE lgort_d,
           menge      TYPE menge_d,
           preunipres TYPE megxxx,
           plifz      TYPE plifz,
         END OF st_collect.

  DATA: it_collect   TYPE STANDARD TABLE OF st_collect,
        it_collect_a TYPE STANDARD TABLE OF st_collect,
        wa_collect   LIKE LINE OF it_collect,
        wa_collect2  LIKE LINE OF it_collect,
        wa_collect_a LIKE LINE OF it_collect_a,
        lv_tabla     TYPE STANDARD TABLE OF st_zco_tt_planpresm.

  DATA: t_mrp_stock_detail TYPE bapi_mrp_stock_detail,
        t_mrp_list         TYPE bapi_mrp_list,
        t_return           TYPE bapiret2.

  DATA: lv_meins_es TYPE co_meinh, lv_meins_en TYPE co_meinh.

*---------------------
  FIELD-SYMBOLS: <ls_tabla> TYPE any, <linea> TYPE any.
  DATA mes_corto LIKE t247-ktx.
  DATA num_mes LIKE t247-mnr.
  DATA lv_fldnmecat TYPE lvc_fname.
  DATA lv_fldnmecat2 TYPE lvc_fname. "cantidad real autorizada/solicitada
  DATA lv_fldnmemont TYPE lvc_fname.
  DATA lv_message TYPE string.
  DATA lv_strcant(8) TYPE c.
  DATA: lv_time TYPE  dlydy,
        lv_next.
  DATA lv_stockreal TYPE menge_d.
  DATA: vl_cantidad_solped TYPE bamng,vl_crear_solped TYPE boe_bool.
*----------se obtiene el campo con la cantidad autorizada WOG
  PERFORM get_periodo USING p_monat
  CHANGING num_mes
    mes_corto
    lv_fldnmecat
    lv_fldnmemont.
  lv_fldnmecat2 = lv_fldnmecat.
  REPLACE 'MEG' IN lv_fldnmecat2 WITH 'WOG'.

  CLEAR prheader.
  CLEAR prheaderx.
  CLEAR solped.

  REFRESH it_registros.
  IF p_lt_rows[] IS NOT INITIAL.
    lv_tabla[] = p_lt_rows[].
    REFRESH retorno.
    REFRESH t_pr_item.
    REFRESH t_pr_itemx.
    REFRESH t_praccount.
    REFRESH t_praccountx.
    CLEAR: praccountx,praccount.

    pr_item-preq_item = '0000'. "posición
    pr_itemx-preq_item = '0000'. "posición


    LOOP AT p_lt_rows INTO wa_zco_tt_planpresm .
      IF wa_zco_tt_planpresm-solped EQ space.
        wa_collect-matnr = wa_zco_tt_planpresm-matnr.
        SELECT SINGLE msehi INTO wa_collect-co_meinh FROM t006a WHERE mseh3 =  wa_zco_tt_planpresm-co_meinh.
        "wa_collect-co_meinh = wa_zco_tt_planpresm-co_meinh.
        wa_collect-werks = wa_zco_tt_planpresm-werks.
        wa_collect-lgort = wa_zco_tt_planpresm-lgort.

        "se onbtiene la cantidad del mes/periodo consultado.
        READ TABLE p_lt_rows ASSIGNING <ls_tabla> INDEX sy-tabix.
        ASSIGN COMPONENT lv_fldnmecat2 OF STRUCTURE <ls_tabla> TO <linea>.
        wa_collect-menge = <linea>.

        APPEND wa_collect TO it_collect.
        UNASSIGN <linea>.

      ELSE.
        DELETE lv_tabla WHERE idpres = wa_zco_tt_planpresm-idpres
                AND prespos = wa_zco_tt_planpresm-prespos
                AND matnr = wa_zco_tt_planpresm-matnr
                AND werks = wa_zco_tt_planpresm-werks.
      ENDIF.
    ENDLOOP.

    LOOP AT it_collect INTO wa_collect.
      COLLECT wa_collect INTO it_collect_a.
    ENDLOOP.

    LOOP AT it_collect_a INTO wa_collect_a.
      SELECT SINGLE mseh3 INTO lv_meins_es FROM t006a
      WHERE msehi =  wa_collect_a-co_meinh.

      SELECT SINGLE msehi INTO lv_meins_en FROM t006a
      WHERE mseh3 =  wa_collect_a-co_meinh.


      READ TABLE lv_tabla INTO wa_zco_tt_planpresm WITH KEY
      matnr = wa_collect_a-matnr
      co_meinh = lv_meins_es"wa_collect-co_meinh
      werks  = wa_collect_a-werks
      lgort = wa_collect_a-lgort.

      IF wa_zco_tt_planpresm-preunipres EQ 0.
        wa_zco_tt_planpresm-preunipres = 1.
      ENDIF.

      wa_collect_a-preunipres = wa_zco_tt_planpresm-preunipres.
      wa_collect_a-plifz = wa_zco_tt_planpresm-plifz.
      MODIFY it_collect_a FROM wa_collect_a TRANSPORTING preunipres plifz
      WHERE  matnr = wa_collect_a-matnr AND
      co_meinh = lv_meins_en AND "wa_collect_a-co_meinh AND
      werks  = wa_collect_a-werks AND
      lgort = wa_collect_a-lgort.

    ENDLOOP.


    LOOP AT it_collect_a INTO wa_collect_a.

      SELECT SINGLE mseh3 INTO lv_meins_es FROM t006a
      WHERE msehi =  wa_collect_a-co_meinh.

      READ TABLE lv_tabla INTO wa_zco_tt_planpresm WITH KEY
      matnr = wa_collect_a-matnr
      "co_meinh = lv_meins_es"wa_collect-co_meinh
      werks  = wa_collect_a-werks
      lgort = wa_collect_a-lgort.

      "cabecera de la bapi
      prheader-pr_type = 'ZPRE'.
      prheaderx-pr_type = 'X'.
      "items
      SELECT SINGLE afnam INTO pr_item-preq_name
        FROM zco_tt_cecoaut
        WHERE kostl = wa_zco_tt_planpresm-kostl.

      pr_item-preq_item = pr_item-preq_item + 10. "posición
      pr_item-short_text = wa_zco_tt_planpresm-maktx.
      pr_item-plant = wa_collect_a-werks.
      pr_item-store_loc = wa_collect_a-lgort.
      pr_item-preq_price = wa_collect_a-preunipres.
      pr_item-pur_group = '121'.
*      praccount-costcenter = wa_zco_tt_planpresm-kostl.
*      praccountx-costcenter = 'X'.


      IF p_kokrs = 'SA00'.
        pr_item-purch_org = 'GP01'.
      ELSE.
        pr_item-purch_org = 'GP01'.
      ENDIF.
      pr_item-quantity = wa_collect_a-menge.
      "indices de Item
      pr_itemx-preq_item =  pr_itemx-preq_item + 10. "posición
      pr_itemx-preq_name = 'X'.
      pr_itemx-short_text = 'X'.
      pr_itemx-plant = 'X'.
      pr_itemx-store_loc = 'X'.
      pr_itemx-pur_group = 'X'.
      pr_itemx-purch_org = 'X'.
      pr_itemx-preq_price = 'X'.
      pr_itemx-quantity = 'X'.
      pr_itemx-material = 'X'.
      pr_itemx-unit = 'X'.
      pr_itemx-deliv_date = 'X'.

      "Se consulta la bapi de stock para validar existencia.
      CALL FUNCTION 'BAPI_MATERIAL_STOCK_REQ_LIST'
        EXPORTING
          material         = wa_collect_a-matnr
          plant            = wa_collect_a-werks
        IMPORTING
          mrp_stock_detail = t_mrp_stock_detail
          mrp_list         = t_mrp_list
          return           = t_return.

      "cant. Solic.        stock transito             reservas
*      lv_stockreal = ( t_mrp_stock_detail-unrestricted_stck + t_mrp_stock_detail-pur_orders
*                       + t_mrp_stock_detail-unres_consi + t_mrp_stock_detail-consig_ord
*                       - t_mrp_stock_detail-fixed_issues ) .

      CALL FUNCTION 'ZMM_CALC_SOLPED_STKMIN1'
        EXPORTING
          stock_minimo         = t_mrp_list-minlotsize                 " Tamaño de lote mínimo
          stock_libre          = t_mrp_stock_detail-unrestricted_stck  " Stock valorado de libre utilización
          stock_transito       = t_mrp_stock_detail-pur_orders         " Stock en tránsito
          stock_consig_lib     = t_mrp_stock_detail-unres_consi        " Stock en consignación de libre utilización
          stock_consig_trans   = t_mrp_stock_detail-consig_ord         " Pedidos de consignación
          reservas             = t_mrp_stock_detail-fixed_issues       " Reserva de entradas
          cantidad_confirmada  = pr_item-quantity                      " Cantidad solicitud de pedido
        IMPORTING
          rcantidad_confirmada = vl_cantidad_solped                    " Cantidad solicitud de pedido
          crear_solped         = vl_crear_solped                 " Campo Sí/No
          rstock_real          = lv_stockreal.

      "IF pr_item-quantity LE lv_stockreal.
      IF vl_crear_solped NE abap_true.
        lv_strcant = pr_item-quantity.
        CONCATENATE 'Material:' wa_collect_a-matnr
        'Aún Existe Stock Sufiente para lo que solicitas. Se recomienda realizar una Reserva.' INTO lv_message SEPARATED BY space.
        " MESSAGE lv_message TYPE 'S' DISPLAY LIKE 'E'.
        lv_next = 'N'.
        "EXIT.
        CLEAR wa_log.
        wa_log-idpres = wa_zco_tt_planpresm-idpres.
        wa_log-datum = sy-datum.
        wa_log-uzeit = sy-uzeit.
        wa_log-type = 'E'.
        wa_log-id = 'SP'.
        wa_log-numero = '000'.
        wa_log-message = lv_message.
        wa_log-message_v1 = wa_zco_tt_planpresm-kokrs.
        wa_log-message_v2 = wa_collect_a-matnr.
        wa_log-message_v3 = lv_stockreal.
        APPEND wa_log TO it_log.
        "se quita el check de la fila selecciona que no se hara solped por algun error encontrado
        wa_zco_tt_planpresm-beknz = space.
        MODIFY gt_zco_tt_planpresm FROM wa_zco_tt_planpresm TRANSPORTING beknz
         WHERE bukrs = wa_zco_tt_planpresm-bukrs
         AND matnr = wa_zco_tt_planpresm-matnr
         AND werks = wa_zco_tt_planpresm-werks
         AND prespos = wa_zco_tt_planpresm-prespos
         AND idpres = wa_zco_tt_planpresm-idpres
         .
        DELETE lv_tabla WHERE idpres = wa_zco_tt_planpresm-idpres
               AND prespos = wa_zco_tt_planpresm-prespos
               AND matnr = wa_zco_tt_planpresm-matnr
               AND werks = wa_zco_tt_planpresm-werks.
        PERFORM update_checkbox.
        "-----------------------------------------------------------------------------------------

        CONTINUE.
      ELSE.
*        pr_item-quantity = abs( pr_item-quantity - lv_stockreal )  "17/01/2024 sol. por MG.
*                            + t_mrp_list-minlotsize. "25/01/2024 sol. MGM
        pr_item-quantity = vl_cantidad_solped.
        "pr_item-quantity = abs( pr_item-quantity ).
        lv_next = 'S'.
      ENDIF.

      "Se valida si la cantidad rebasa el stock maximo. Si lo rebasa se ajusta a lo maximo permitidp.
*-------Pendiente para aplicar,
*        IF pr_item-quantity > wa_zco_tt_planpres-mabst.
*          pr_item-quantity-quantity = wa_zco_tt_planpres-mabst.
*        ELSEIF pr_item-quantity < wa_zco_tt_planpres-eisbe.
*          pr_item-quantity-quantity = wa_zco_tt_planpres-eisbe.
*        ENDIF.
*------------------------------------

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_collect_a-matnr
        IMPORTING
          output = wa_collect_a-matnr.
      pr_item-material = wa_collect_a-matnr.

      pr_item-unit = wa_collect_a-co_meinh. "unidad de medida
      "sumamos los dia de entrega a la fecha actual.
      lv_time = wa_collect_a-plifz.

      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          date      = sy-datum
          days      = lv_time
          months    = 0
          signum    = '+'
          years     = 0
        IMPORTING
          calc_date = pr_item-deliv_date.

      APPEND pr_item TO t_pr_item.
      APPEND pr_itemx TO t_pr_itemx.
      APPEND praccount TO t_praccount.
      APPEND praccountx TO t_praccountx.

*Se valida el numero maximo de articulos por solped
      IF pr_item-preq_item = '9999'.
        REFRESH it_registros.
        LOOP AT lv_tabla INTO wa_zco_tt_planpresm.
          CLEAR wa_registros.
          CLEAR pr_item-preq_item.
          wa_registros-idpres =  wa_zco_tt_planpresm-idpres.
          wa_registros-prespos = wa_zco_tt_planpresm-prespos.
          wa_registros-bukrs  = wa_zco_tt_planpresm-bukrs.
          wa_registros-werks  = wa_zco_tt_planpresm-werks.
          wa_registros-matnr  = wa_zco_tt_planpresm-matnr.
          wa_registros-pos  = pr_item-preq_item + 10.
          READ TABLE it_collect INTO wa_collect INDEX sy-tabix.
          wa_registros-menge = wa_collect-menge.
          APPEND wa_registros TO it_registros.
        ENDLOOP.

        PERFORM crea_solped USING it_registros.

        REFRESH retorno.
        REFRESH t_pr_item.
        REFRESH t_pr_itemx.
        REFRESH t_praccount.
        REFRESH t_praccountx.
        REFRESH it_registros.
        CLEAR: praccount, praccountx.
        pr_item-preq_item = '0000'. "posición
        pr_itemx-preq_item = '0000'. "posición

      ENDIF.
    ENDLOOP.

    IF it_collect_a IS NOT INITIAL AND lv_next EQ 'S'.
      REFRESH it_registros.
      CLEAR pr_item-preq_item.
      LOOP AT lv_tabla INTO wa_zco_tt_planpresm.
        CLEAR wa_registros.

        wa_registros-idpres =  wa_zco_tt_planpresm-idpres.
        wa_registros-prespos = wa_zco_tt_planpresm-prespos.
        wa_registros-bukrs  = wa_zco_tt_planpresm-bukrs.
        wa_registros-werks  = wa_zco_tt_planpresm-werks.
        wa_registros-matnr  = wa_zco_tt_planpresm-matnr.
        wa_registros-pos  = pr_item-preq_item + 10.
        READ TABLE it_collect INTO wa_collect INDEX sy-tabix.
        wa_registros-menge = wa_collect-menge.
        APPEND wa_registros TO it_registros.
      ENDLOOP.

      PERFORM crea_solped USING it_registros.
    ENDIF.

  ENDIF. "is not initial
  PERFORM update_checkbox.
  IF it_log[] IS NOT INITIAL.
    CALL FUNCTION 'ZUT_FLOATALV'
      EXPORTING
        i_start_column = 25
        i_start_line   = 6
        i_end_column   = 100
        i_end_line     = 10
        i_title        = 'No se genero solped para este/estos Materiales'
        i_popup        = 'X'
      TABLES
        it_alv         = it_log.
    .
    INSERT zco_tt_logpres FROM TABLE it_log.

  ENDIF.
  PERFORM update_checkbox.
ENDFORM.                    " BUILD_SOLPED
*&---------------------------------------------------------------------*
*&      Form  SHOW_ALVPOPUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RETORNO  text
*----------------------------------------------------------------------*
FORM show_alvpopup  USING  p_retorno TYPE STANDARD TABLE.

  CALL FUNCTION 'ZUT_FLOATALV'
    EXPORTING
      i_start_column = 25
      i_start_line   = 3
      i_end_column   = 100
      i_end_line     = 50
      i_title        = 'No se pudo generar la Solped'
      i_popup        = 'X'
    TABLES
      it_alv         = p_retorno.
ENDFORM.                    " SHOW_ALVPOPUP
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DATA_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_data_itab USING p_tabla TYPE STANDARD TABLE
          p_origen TYPE string.

  DATA:
    desc_table    TYPE REF TO cl_abap_tabledescr,
    desc_struc    TYPE REF TO cl_abap_structdescr,
    components    TYPE abap_component_tab,
    r_type_struct TYPE REF TO cl_abap_structdescr,
    r_type_table  TYPE REF TO cl_abap_tabledescr,
    r_data_tab    TYPE REF TO data,
    r_data_str    TYPE REF TO data,
    lv_co_meinh   TYPE co_meinh.

  FIELD-SYMBOLS:
    <p_component> TYPE abap_compdescr,
    <fs_table>    TYPE INDEX TABLE, "-> here table must by type INDEX TABLE in order to append to it
    <fs_wa>       TYPE any,
    <lfs_comp_wa> TYPE abap_compdescr.

  desc_table ?= cl_abap_tabledescr=>describe_by_data( p_tabla ).

  desc_struc ?= desc_table->get_table_line_type( ).

  components =  desc_struc->get_components( ).

  r_type_struct = cl_abap_structdescr=>create(
     p_components = components ).

  r_type_table = cl_abap_tabledescr=>create( r_type_struct ).

  CREATE DATA: r_data_tab TYPE HANDLE r_type_table,
               r_data_str TYPE HANDLE r_type_struct.

  ASSIGN: r_data_tab->* TO <fs_table>,
          r_data_str->* TO <fs_wa>.



  TYPES: BEGIN OF st_itab,
           matnr TYPE matnr18,
           meins TYPE meins,
           matkl TYPE matkl,
         END OF st_itab.

  TYPES: BEGIN OF st_itab2,
           matnr TYPE matnr18,
           maktx TYPE maktx,
         END OF st_itab2.

  TYPES: BEGIN OF st_ambitos,
           matnr TYPE matnr18,
           bwkey TYPE bwkey,
           bklas TYPE bklas,

         END OF st_ambitos.

  TYPES: BEGIN OF st_t030,
           bklas TYPE saknr,
           konts TYPE saknr,
         END OF st_t030.


  DATA: it_itab    TYPE STANDARD TABLE OF st_itab,
        it_makt    TYPE STANDARD TABLE OF st_itab2,
        it_ambitos TYPE STANDARD TABLE OF st_ambitos,
        it_t030    TYPE STANDARD TABLE OF st_t030.
  DATA: vl_maktx    TYPE maktx, vl_matkl TYPE matkl, vl_lgort TYPE lgort_d,
        vl_message  TYPE string, vl_message2 TYPE string.

  DATA: lv_kstar      TYPE kstar,
        lv_where1     TYPE TABLE OF string,
        lv_gjahr      TYPE gjahr,
        lv_preuni     TYPE netpr,
        lv_inflacion  TYPE netpr,
        lv_preunipres TYPE netpr.

  DATA: lv_idpres  TYPE char10,
        lv_prespos TYPE num5.

  DATA: lv_bklas  TYPE bklas, lv_bwmod TYPE bwmod, lv_cuenta TYPE saknr.


  FIELD-SYMBOLS: <ls_struct>     TYPE any,
                 <ls_materiales> TYPE any,
                 <ls_descrip>    TYPE any,
                 <ls_lgort>      TYPE any,
                 <matnr>         TYPE matnr18,
                 <tipo>          TYPE any,
                 <kokrs>         TYPE any,
                 <row>           TYPE any,
                 <mrow>          TYPE any,
                 <werks>         TYPE any,
                 <lgort>         TYPE any.



  LOOP AT p_tabla ASSIGNING <ls_struct>.
    APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_wa>.
    MOVE-CORRESPONDING <ls_struct> TO <fs_wa>.
  ENDLOOP.

  REFRESH lv_where1.

  IF p_origen EQ 'interno'.
    APPEND 'MATNR eq <fs_table>-material' TO lv_where1.
  ELSE.
    APPEND 'CAST(MATNR AS MATNR18) eq <fs_table>-matnr' TO lv_where1.
  ENDIF.

*  SELECT matnr meins matkl
*    INTO TABLE it_itab
*    FROM mara
*    FOR ALL ENTRIES IN <fs_table>
*    WHERE (lv_where1)
*    .
*
*  SELECT matnr maktx
*    INTO TABLE it_makt
*    FROM makt
*    FOR ALL ENTRIES IN <fs_table>
*    WHERE (lv_where1)
  .

*  SELECT matnr werks lgort
*    INTO TABLE it_lgort
*    FROM mard
*    FOR ALL ENTRIES IN <fs_table>
*    WHERE (lv_where1).

  SELECT mandt material saknr
    INTO TABLE it_zco_tt_matcuenta
    FROM zco_tt_matcuenta.

  SELECT  m~kokrs m~gjahr m~matnr m~netpr i~dmbtr
    INTO TABLE it_matnrpres
  FROM zco_tt_matnrpres AS m
    INNER JOIN zco_tt_inflacion AS i
    ON i~kokrs = m~kokrs AND i~gjhar = m~gjahr.

*  READ TABLE it_outtable INTO wa_outtable INDEX 1.
*  IF sy-subrc EQ 0.
***23082022
** Se elimina la busqueda y asignacion del ámbito de valoración
** de la Clase de coste, para el centro 0300.
** Se toma de la relacion Material SAKNR de la tabla Z ZCO_TT_MATCUENTA
*    IF wa_outtable-werks EQ '0300' .
*
*      SELECT matnr bwkey bklas
*        INTO TABLE it_ambitos
*        FROM mbew
*        FOR ALL ENTRIES IN it_outtable
*        WHERE matnr EQ it_outtable-material
*        AND bwkey EQ it_outtable-werks
*        .
*
*      SELECT bklas konts
*      INTO TABLE it_t030
*      FROM t030
*      FOR ALL ENTRIES IN it_ambitos
*      WHERE bklas EQ it_ambitos-bklas
*        AND ktopl EQ 'SA00'
*        AND ktosl EQ 'GBB'
*        AND komok EQ 'VBR'
*        AND bwmod EQ ''.
*
*      LOOP AT it_ambitos ASSIGNING <ls_struct>.
*        ASSIGN COMPONENT 'BKLAS' OF STRUCTURE <ls_struct> TO <row>.
*        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <ls_struct> TO <matnr>.
*        READ TABLE it_t030 ASSIGNING <mrow> WITH KEY bklas = <row>.
*        IF <row> IS ASSIGNED.
*          ASSIGN COMPONENT 'KONTS' OF STRUCTURE <mrow> TO <row>.
*          READ TABLE it_outtable INTO wa_outtable WITH KEY material = <matnr>.
*          wa_outtable-clcoste = <row>.
*          MODIFY it_outtable FROM wa_outtable TRANSPORTING clcoste WHERE material = <matnr>.
*        ENDIF.
*      ENDLOOP.

*    ENDIF.
*  ENDIF.
** hasta nuevo aviso.


  LOOP AT <fs_table> ASSIGNING <ls_struct>.
    ASSIGN COMPONENT 'KOKRS' OF STRUCTURE <ls_struct> TO <kokrs>.
    ASSIGN COMPONENT 'TIPO' OF STRUCTURE <ls_struct> TO <tipo>.

    IF <tipo> EQ 'MATERIAL'.
      ASSIGN COMPONENT 'WERKS' OF STRUCTURE <ls_struct> TO <werks>.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <werks>
        IMPORTING
          output = <werks>.

*      IF p_origen EQ 'interno'.
*        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <ls_struct> TO <matnr>.
*      ELSE.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <ls_struct> TO <matnr>.
*      ENDIF.


      IF <matnr> IS ASSIGNED.


        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <matnr>
          IMPORTING
            output = <matnr>.

*--------rutina solo para datos que vienen del portal
        IF p_origen EQ 'externo'.
          CLEAR: wa_matnrpres,
          lv_preuni.

          ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <ls_struct> TO <row>.
          lv_gjahr = <row>.



          READ TABLE it_matnrpres INTO wa_matnrpres
          WITH KEY kokrs = <kokrs> matnr = <matnr> gjahr = lv_gjahr.
          IF sy-subrc EQ 0.
            lv_preuni = wa_matnrpres-netpr.
            lv_inflacion = wa_matnrpres-dmbtr.
          ELSE.
            lv_preuni = 1.
            lv_inflacion = 0.
          ENDIF.

          CLEAR lv_preunipres.
          lv_preunipres = ( lv_preuni * ( lv_inflacion / 100 ) ) + lv_preuni.


          ASSIGN COMPONENT 'PREUNI' OF STRUCTURE <ls_struct> TO <row>.
          <row> = lv_preuni.

          ASSIGN COMPONENT 'PREUNIPRES' OF STRUCTURE <ls_struct> TO <row>.
          <row> = lv_preunipres.

          "Actuaizacion de la tabla
          CLEAR: lv_idpres, lv_prespos.

          ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <ls_struct> TO <row>.
          lv_idpres = <row>.
          ASSIGN COMPONENT 'PRESPOS' OF STRUCTURE <ls_struct> TO <row>.
          lv_prespos = <row>.

          UPDATE zco_tt_planpres SET preuni = lv_preuni preunipres = lv_preunipres
          WHERE idpres = lv_idpres AND prespos = lv_prespos
          AND matnr = <matnr>.

          UNASSIGN <row>.
        ENDIF.
*---------------------------------------------------------------
        "
        REFRESH it_itab.
        SELECT  matnr meins matkl
          INTO TABLE it_itab
        FROM mara
        WHERE matnr EQ <matnr>.

        UNASSIGN <ls_materiales>.
        READ TABLE it_itab ASSIGNING <ls_materiales> WITH KEY matnr = <matnr>.

        IF p_origen EQ 'interno'.
          ASSIGN COMPONENT 'MEINS' OF STRUCTURE <ls_struct> TO <row>.
        ELSE.
          ASSIGN COMPONENT 'CO_MEINH' OF STRUCTURE <ls_struct> TO <row>.
        ENDIF.

        IF <row> IS ASSIGNED.
          IF <ls_materiales> IS ASSIGNED.


            ASSIGN COMPONENT 'MEINS' OF STRUCTURE <ls_materiales> TO <mrow>.
            IF <mrow> IS ASSIGNED.

              CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
                EXPORTING
                  input    = <mrow>
                  language = 'S'
                IMPORTING
*                 LONG_TEXT            =
                  output   = <row>
*                 SHORT_TEXT           =
*             EXCEPTIONS
*                 UNIT_NOT_FOUND       = 1
*                 OTHERS   = 2
                .

              IF <row> EQ '***'.
                lv_co_meinh  = <mrow>.
              ELSE.
                lv_co_meinh = <row>.
              ENDIF.
              "<row> = <mrow>.
              IF p_origen EQ 'externo'.
                "Actuaizacion de la tabla
                CLEAR: lv_idpres, lv_prespos.

                ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <ls_struct> TO <row>.
                lv_idpres = <row>.
                ASSIGN COMPONENT 'PRESPOS' OF STRUCTURE <ls_struct> TO <row>.
                lv_prespos = <row>.

                UPDATE zco_tt_planpres SET co_meinh = lv_co_meinh
                WHERE idpres = lv_idpres AND prespos = lv_prespos
                AND matnr = <matnr>.
              ENDIF.

              UNASSIGN <row>.
              UNASSIGN <mrow>.

              ASSIGN COMPONENT 'MATKL' OF STRUCTURE <ls_struct> TO <row>.
              ASSIGN COMPONENT 'MATKL' OF STRUCTURE <ls_materiales> TO <mrow>.
              <row> = <mrow>.
              IF p_origen EQ 'externo'.
                "Actuaizacion de la tabla
                CLEAR: lv_idpres, lv_prespos.

                ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <ls_struct> TO <row>.
                lv_idpres = <row>.
                ASSIGN COMPONENT 'PRESPOS' OF STRUCTURE <ls_struct> TO <row>.
                lv_prespos = <row>.
                CLEAR vl_matkl.
                vl_matkl = <mrow>.
                UPDATE zco_tt_planpres SET  matkl = <mrow>
                WHERE idpres = lv_idpres AND prespos = lv_prespos
                AND matnr = <matnr>.
              ENDIF.

              UNASSIGN <row>.
              UNASSIGN <mrow>.

              REFRESH it_makt.
              SELECT matnr maktx
               INTO TABLE it_makt
               FROM makt
                WHERE matnr EQ <matnr>.
              READ TABLE it_makt ASSIGNING <ls_descrip> WITH KEY matnr = <matnr>.

              IF p_origen EQ 'interno'.
                ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <ls_struct> TO <row>.
              ELSE.
                ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <ls_struct> TO <row>.
              ENDIF.

              IF <row> IS ASSIGNED.
                ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <ls_descrip> TO <mrow>.
                IF <mrow> IS ASSIGNED.
                  <row> = <mrow>.
                  IF p_origen EQ 'externo'.
                    "Actuaizacion de la tabla
                    CLEAR: lv_idpres, lv_prespos.

                    ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <ls_struct> TO <row>.
                    lv_idpres = <row>.
                    ASSIGN COMPONENT 'PRESPOS' OF STRUCTURE <ls_struct> TO <row>.
                    lv_prespos = <row>.
                    CLEAR vl_maktx.
                    vl_maktx = <mrow>.

                    UPDATE zco_tt_planpres SET maktx = <mrow>
                    WHERE idpres = lv_idpres AND prespos = lv_prespos
                    AND matnr = <matnr>.
                  ENDIF.
                  UNASSIGN <row>.
                  UNASSIGN <mrow>.
                ENDIF.

              ENDIF.
              "----------------

              "----------------------

            ENDIF.
          ENDIF.

          "se valida aqui, la clase de coste.
          IF p_origen EQ 'interno'.
            ASSIGN COMPONENT 'KSTAR' OF STRUCTURE <ls_struct> TO <row>.
          ELSE.
            ASSIGN COMPONENT 'KSTAR' OF STRUCTURE <ls_struct> TO <row>.

          ENDIF.

          CLEAR: wa_zco_tt_matcuenta, lv_bklas, lv_bwmod, lv_cuenta, lv_kstar.
          lv_kstar = <row>."se asigna el que trae por default.

          READ TABLE it_zco_tt_matcuenta INTO wa_zco_tt_matcuenta WITH KEY material = <matnr>.
          IF sy-subrc EQ 0.
            "asigna ceros a la izquierda
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = wa_zco_tt_matcuenta-saknr
              IMPORTING
                output = wa_zco_tt_matcuenta-saknr.
            <row> = wa_zco_tt_matcuenta-saknr.
            "IF lv_kstar is INITIAL or lv_kstar eq space.
            lv_kstar = <row>.
            "ENDIF.
          ELSE. "Ingenios

            SELECT SINGLE bklas
            FROM mbew
            INTO lv_bklas
            WHERE matnr = <matnr>
            AND bwkey = <werks>.

            IF sy-subrc = 0.

*          SELECT SINGLE bwmod
*          FROM t001k
*          INTO lv_bwmod
*          WHERE bwkey = <werks>.
*
*            IF SY-subrc EQ 0.
              SELECT SINGLE konts
              FROM t030
              INTO lv_cuenta
              WHERE ktopl = 'GP00'
              "AND bwmod = lv_bwmod
              AND ktosl = 'GBB'
              AND komok = 'VBR'
              AND bklas = lv_bklas.

              IF sy-subrc = 0.

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = lv_cuenta
                  IMPORTING
                    output = lv_kstar.
                <row> = lv_kstar.
              ELSE.
                <row> = lv_kstar. "el que se guardo por default
              ENDIF.
*            else.
*              <row> = lv_kstar. "el que se guardo por default
*            ENDIF.
            ELSE.
              <row> = lv_kstar. "el que se guardo por default
            ENDIF.


          ENDIF.

          IF p_origen = 'externo'.
            CLEAR: lv_idpres, lv_prespos.

            ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <ls_struct> TO <row>.
            lv_idpres = <row>.
            ASSIGN COMPONENT 'PRESPOS' OF STRUCTURE <ls_struct> TO <row>.
            lv_prespos = <row>.

            "          IF wa_zco_tt_matcuenta-saknr NE space OR wa_zco_tt_matcuenta-saknr IS NOT INITIAL .

            UPDATE zco_tt_planpres SET kstar = lv_kstar
            WHERE idpres = lv_idpres AND prespos = lv_prespos
            AND matnr = <matnr>.

            "         ENDIF.

          ENDIF.

          "Se valida el almacen.
          UNASSIGN <ls_lgort>.
          REFRESH it_lgort.
          SELECT matnr werks lgort
           INTO TABLE it_lgort
          FROM mard
          WHERE matnr EQ <matnr>.

          READ TABLE it_lgort ASSIGNING <ls_lgort> WITH KEY matnr = <matnr> werks = <werks>.

          IF p_origen EQ 'interno'.
            ASSIGN COMPONENT 'LGORT' OF STRUCTURE <ls_struct> TO <row>.
          ELSE.
            ASSIGN COMPONENT 'LGORT' OF STRUCTURE <ls_struct> TO <row>.
          ENDIF.

*** si no se encuentra el material en el centro/almacén, se amplia y se guarda en Log
          IF <ls_lgort> IS ASSIGNED.
            ASSIGN COMPONENT 'LGORT' OF STRUCTURE <ls_lgort> TO <lgort>.
*            IF <kokrs> EQ 'SA00'.
*              <row> = 'GPGR'."<lgort>.
*            ELSE.
*              <row> = 'AZGR'."<lgort>.
*            ENDIF.
          ELSE.
            CLEAR vl_lgort.
            IF <werks> IS INITIAL OR <werks> EQ space.
              CONCATENATE 'No se se puede tratar material' <matnr>
                          'porque el centro fue'
                          INTO vl_message SEPARATED BY space.

              CONCATENATE 'especificado en blanco en plantilla'
                          'o el material no esta en ese centro'
                          '.Verifique su plantilla de carga'
                          INTO vl_message2 SEPARATED BY space.

**              CALL FUNCTION 'POPUP_TO_INFORM'
**                EXPORTING
**                  titel = 'Validación de Material'
**                  txt1  = vl_message
**                  txt2  = vl_message2
**                  txt3  = 'El proceso de Actualización de detuvo'
***                 TXT4  = ' '
**                .
**              EXIT.
            ELSE.
              PERFORM get_almacen USING <matnr> <werks>
                              CHANGING vl_lgort.
            ENDIF.


            IF vl_lgort IS NOT INITIAL OR vl_lgort NE space.
              "PERFORM extended_matnr USING <matnr> <werks> vl_maktx vl_lgort.
              ASSIGN vl_lgort TO <lgort>.
            ELSE.
              CONCATENATE 'No se pudo tratar el material' <matnr>
                          'Porque no se encontro almacén'
                          INTO vl_message SEPARATED BY space.
              CONCATENATE 'con relación al centro' <werks> 'Verif. Plantilla.'
                          INTO vl_message2 SEPARATED BY space.
*              CALL FUNCTION 'POPUP_TO_INFORM'
*                EXPORTING
*                  titel = 'Verificación del Material'
*                  txt1  = vl_message
*                  txt2  = vl_message2
*                  txt3  = 'El proceso de Actualización de detuvo'.

              "EXIT.
            ENDIF.

          ENDIF.

*** Fin de ampliacion************************************************

          IF p_origen = 'externo'.
            CLEAR: lv_idpres, lv_prespos.

            ASSIGN COMPONENT 'IDPRES' OF STRUCTURE <ls_struct> TO <row>.
            lv_idpres = <row>.
            ASSIGN COMPONENT 'PRESPOS' OF STRUCTURE <ls_struct> TO <row>.
            lv_prespos = <row>.

            IF <lgort> IS ASSIGNED.
              UPDATE zco_tt_planpres SET lgort = <lgort>
              WHERE idpres = lv_idpres AND prespos = lv_prespos
              AND matnr = <matnr>.
            ENDIF.

          ENDIF.
          "----------------------------------------------------------
        ENDIF.
      ENDIF. "fin valida el tipo = material
    ELSE. "SE VALIDA EL NOMBRE DE LA CUENTA
      ASSIGN COMPONENT 'KSTAR' OF STRUCTURE <ls_struct> TO <row>.
      SELECT SINGLE txt50
      INTO @DATA(vl_nom_cta)
      FROM skat
      WHERE saknr = @<row> and spras = 'S'.

      ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <ls_struct> TO <row>.
      IF sy-subrc EQ 0.
        <row> = vl_nom_cta.
      ENDIF.
    ENDIF.


  ENDLOOP.


  p_tabla[] = <fs_table>.


ENDFORM.                    " UPDATE_DATA_ITAB
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_RESERVA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mostrar_reserva USING  p_row_id TYPE lvc_s_row.
  DATA es_row TYPE lvc_t_roid.
  DATA: ld_value   TYPE lvc_value.
  DATA: row_id    TYPE i,column_id TYPE i.
  CALL METHOD gref_alvgrid102->get_current_cell
    IMPORTING
      e_row   = row_id
      e_col   = column_id
      e_value = ld_value.

  IF ld_value IS NOT INITIAL OR ld_value NE space.
    SET PARAMETER ID 'RES' FIELD ld_value.
    CALL TRANSACTION 'MB23' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    " MOSTRAR_RESERVA

*&---------------------------------------------------------------------*
*&      Form  mostrar_solped
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW_ID   text
*----------------------------------------------------------------------*
FORM mostrar_solped USING  p_row_id TYPE lvc_s_row.
  DATA es_row TYPE lvc_t_roid.
  DATA: ld_value   TYPE lvc_value.
  DATA: row_id    TYPE i,column_id TYPE i.
  CALL METHOD gref_alvgrid102->get_current_cell
    IMPORTING
      e_row   = row_id
      e_col   = column_id
      e_value = ld_value.

  IF ld_value IS NOT INITIAL OR ld_value NE space.
    SET PARAMETER ID 'BAN' FIELD ld_value.
    CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    " MOSTRAR_RESERVA
*&---------------------------------------------------------------------*
*&      Form  VAL_AUTH_RESERV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*      <--P_EDIT  text
*----------------------------------------------------------------------*
FORM val_auth_reserv USING    p_er_data_changed
      TYPE REF TO cl_alv_changed_data_protocol
CHANGING
  p_tipo TYPE c.

  DATA lv_fieldname TYPE fieldname.
  DATA: lv_row TYPE i.

  FIELD-SYMBOLS: <ft_data>  TYPE STANDARD TABLE, "lv_mp_rows,
                 <ft_cells> TYPE lvc_t_modi,
                 <ls_tabla> TYPE any,
                 <linea>    TYPE any.

  ASSIGN p_er_data_changed->mp_mod_rows->* TO <ft_data>.

  READ TABLE <ft_data> ASSIGNING <ls_tabla> INDEX 1 .
  ASSIGN COMPONENT 'AUTORIZADO' OF STRUCTURE <ls_tabla> TO <linea>.
  IF <linea> EQ 'X'.
    "SIGNIFICA QUE YA ESTA Autorizado, y entonces, se procede a realizar la reserva por la cantidad ingresada.
    "ahora se valida que la reserva sea mayor a Cero.
    ASSIGN p_er_data_changed->mt_mod_cells TO <ft_cells>.
    READ TABLE <ft_cells> ASSIGNING <ls_tabla> INDEX 1.
    ASSIGN COMPONENT 'VALUE' OF STRUCTURE <ls_tabla> TO <linea>.
    IF <linea> NE 'X'. "se le dio enter a la casilla
      IF <linea> LE 0.
        MESSAGE 'No se permiten cantidades menores o igual a 0' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ELSE.
        p_tipo = 'R'. "se identifica que es una reserva.
      ENDIF.
    ENDIF.
  ELSE.
    ASSIGN COMPONENT 'CHECK' OF STRUCTURE <ls_tabla> TO <linea>.
    IF sy-subrc EQ 0.
      p_tipo = 'C'.
      <linea> = 'X'.
      ASSIGN p_er_data_changed->mt_mod_cells TO <ft_cells>.
      READ TABLE <ft_cells> ASSIGNING <ls_tabla> INDEX 1.
      ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <ls_tabla> TO <linea>.
      lv_row = <linea>.

      CLEAR wa_ajustepres.
      wa_ajustepres-check = 'X'.
      MODIFY it_ajustepres FROM wa_ajustepres INDEX lv_row TRANSPORTING check.

    ELSE.
      p_tipo = 'A'. "significa que es una autorización de materiales
    ENDIF.

  ENDIF.

ENDFORM.                    " VAL_AUTH_RESERV
*&---------------------------------------------------------------------*
*&      Form  ROW_READONLY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_WA_ZCO_TT_PLANPRESM  text
*----------------------------------------------------------------------*
FORM row_readonly  USING p_wa_zco_tt_planpresm TYPE st_zco_tt_planpresm
      p_fieldname TYPE lvc_fname
      p_indice TYPE sy-tabix
      p_indicador TYPE char1
      p_estatus TYPE char2.

  DATA: lt_celltab TYPE lvc_t_styl,
        ls_celltab TYPE lvc_s_styl.

  DATA lv_indice TYPE sy-tabix.

*§2.After selecting data, set edit status for each row in a loop
*   according to field SEATSMAX.
  lv_indice = p_indice.
  IF p_estatus EQ 'RW'.

    PERFORM fill_celltab USING p_estatus "RW
          p_fieldname
          p_indicador
    CHANGING lt_celltab.
  ELSE.
    PERFORM fill_celltab USING p_estatus "RO
          p_fieldname
          p_indicador
    CHANGING lt_celltab.
  ENDIF.
*§2c.Copy your celltab to the celltab of the current row of gt_outtab.
  REFRESH  p_wa_zco_tt_planpresm-celltab.
  INSERT LINES OF lt_celltab INTO TABLE p_wa_zco_tt_planpresm-celltab.
  MODIFY gt_zco_tt_planpresm FROM p_wa_zco_tt_planpresm INDEX lv_indice.

ENDFORM.                    " ROW_READONLY
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ESTATUS  text
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
FORM fill_celltab  USING    p_estatus
      p_fieldname TYPE lvc_fname
      p_indicador TYPE char1
CHANGING pt_celltab TYPE lvc_t_styl.

  DATA: ls_celltab TYPE lvc_s_styl,
        l_mode     TYPE raw4,
        l_moder    TYPE raw4.
* This forms sets the style of column 'PRICE' editable
* according to 'p_mode' and the rest to read only either way.

  IF p_estatus EQ 'RW'.
*§2a.Use attribute CL_GUI_ALV_GRID=>MC_STYLE_ENABLED to set a cell
*    to status "editable".
    l_mode = cl_gui_alv_grid=>mc_style_enabled.
  ELSE. "p_mode eq 'RO'
*§2b.Use attribute CL_GUI_ALV_GRID=>MC_STYLE_DISABLED to set a cell
*    to status "non-editable".
    l_mode = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  IF p_indicador EQ 'R'.
    l_moder = cl_gui_alv_grid=>mc_style_disabled.
  ELSE.
    l_moder = cl_gui_alv_grid=>mc_style_enabled.
  ENDIF.

  ls_celltab-fieldname = 'BEKNZ'.
  ls_celltab-style = l_moder.
  INSERT ls_celltab INTO TABLE  pt_celltab.

  ls_celltab-fieldname = 'KOKRS'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'BUKRS'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = p_fieldname.
  ls_celltab-style = l_mode.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'KOSTL'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'WERKS'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'MATNR'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'CO_MEINH'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'MAKTX'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'MATKL'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'PLIFZ'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'LABST'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'PREUNIPRES'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'CANTIDADORIGINAL'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'SOLPED'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'RSNUM'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.


  IF gref_alvgrid102 IS NOT INITIAL.
    CALL METHOD gref_alvgrid102->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

  ENDIF.


ENDFORM.                    " FILL_CELLTAB
*&---------------------------------------------------------------------*
*&      Form  GET_AJUSTEPRES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_ajustepres .

  REFRESH: it_cecos, it_cecos_indice.
  FIELD-SYMBOLS: <ls_wa> TYPE any,
                 <linea> TYPE any.

  TYPES: BEGIN OF st_t001w,
           werks TYPE werks_d,
           name1 TYPE name1,
         END OF st_t001w,

         BEGIN OF st_t023t,
           matkl TYPE matkl,
           wgbez TYPE wgbez,
         END OF st_t023t.

  DATA: rg_tipo TYPE RANGE OF zco_tt_planpres-tipo,
        wg_tipo LIKE LINE OF rg_tipo.

  DATA: rg_kstar TYPE RANGE OF zco_tt_planpres-kstar,
        wg_kstar LIKE LINE OF rg_kstar.

  DATA: it_t001w     TYPE STANDARD TABLE OF st_t001w,
        wa_t001w     LIKE LINE OF it_t001w,
        it_t023t     TYPE STANDARD TABLE OF st_t023t,
        wa_t023t     LIKE LINE OF it_t023t,
        wa_acumulado LIKE LINE OF it_matpres,
        lv_matnr     TYPE matnr,
        lv_werks     TYPE werks_d,
        lv_tipo      TYPE char20.

  DATA: lv_kokrs  TYPE kokrs,
        lv_gjahr  TYPE gjahr,
        lv_ptipo  TYPE char20,
        lv_pmonat TYPE monat.

* Se quita la validación de CeCos autorizados
* 11/08/2022
* Jaime Hernandez Velasquez
  "se validan los CeCos autorizados por Usuario Logeado
  SELECT   z1~kostl z2~idpres
  INTO CORRESPONDING FIELDS OF TABLE it_cecos_indice
  FROM zco_tt_cecoaut AS z1
  INNER JOIN  zco_tt_planpres AS z2 ON z1~kokrs EQ z2~kokrs AND z1~kostl EQ z2~kostl
  WHERE z1~bname = sy-uname
  AND z2~kokrs EQ p5_kokrs
  AND z2~matnr NE space
  AND z2~versn EQ p5_versn.

  wa_cecos_indice-mandt = sy-mandt.
  MODIFY it_cecos_indice FROM wa_cecos_indice TRANSPORTING mandt WHERE mandt EQ ''.

  SORT it_cecos_indice BY kostl idpres DESCENDING.
  DELETE ADJACENT DUPLICATES FROM it_cecos_indice COMPARING kostl idpres.


  DELETE FROM zcecos_tt_indice.
  INSERT zcecos_tt_indice CLIENT SPECIFIED FROM TABLE it_cecos_indice.
*--------------
  IF p5_tipo IS INITIAL.

    wg_tipo-sign = 'I'.
    wg_tipo-option = 'EQ'.
    wg_tipo-low = 'MATERIAL'.
    APPEND wg_tipo TO  rg_tipo.
    wg_tipo-sign = 'I'.
    wg_tipo-option = 'EQ'.
    wg_tipo-low = 'CUENTA'.
    APPEND wg_tipo TO  rg_tipo.

    wg_tipo-sign = 'I'.
    wg_tipo-option = 'EQ'.
    wg_tipo-low = 'SERVICIO'.
    APPEND wg_tipo TO  rg_tipo.
  ELSE.
    wg_tipo-sign = 'I'.
    wg_tipo-option = 'EQ'.
    wg_tipo-low = p5_tipo.
    APPEND wg_tipo TO  rg_tipo.
  ENDIF.
  "clases de coste
  LOOP AT s5_kstar.
    wg_kstar-sign = 'I'.
    wg_kstar-option = 'EQ'.
    wg_kstar-low = s5_kstar-low.
    APPEND wg_kstar TO  rg_kstar.
  ENDLOOP.

  "---------------------------------
  SELECT
  z~idpres z~prespos z~kokrs z~gjahr z~bukrs z~versn z~kostl c~ktext z~kstar s~txt20 z~buzei
  z~matnr z~servno  z~cuenta  z~maktx z~tipo  z~twaer z~periodo z~co_meinh
  z~preuni  z~prunmx  z~wtg001  z~wtg002  z~wtg003  z~wtg004  z~wtg005  z~wtg006  z~wtg007
  z~wtg008  z~wtg009  z~wtg010  z~wtg011  z~wtg012 z~wtgtot  z~wog001 z~wog002  z~wog003
  z~wog004  z~wog005  z~wog006  z~wog007  z~wog008  z~wog009  z~wog010 z~wog011  z~wog012
  z~wogtot  z~meg001  z~meg002  z~meg003  z~meg004 z~meg005  z~meg006 z~meg007 z~meg008
  z~meg009 z~meg010 z~meg011 z~meg012 z~megtot z~gkoar z~werks t~name1 z~lgort z~sgtxt z~wkurs
  z~equnr z~aufnr z~ingrp z~matkl g~wgbez z~perio z~tipser  z~texexp z~tipmod  z~fecmod  z~usuario
  z~fecha z~hora z~autorizado z~autorizador z~fechaaut  z~horaaut z~areas z~zona z~solped
  z~solpedpos z~menge z~rsnum z~rspos z~bdmng z~enmng z~eisbe z~mabst z~trame z~labst
  z~plifz z~cecoaut z~preunipres

  INTO CORRESPONDING FIELDS OF TABLE it_ajustepres
  FROM zco_tt_planpres AS z
  LEFT JOIN t001w AS t ON t~werks EQ z~werks AND t~spras EQ 'S'
  INNER JOIN t023t AS g ON g~matkl EQ z~matkl AND g~spras EQ 'S'
  INNER JOIN cskt  AS c ON c~kostl EQ z~kostl AND c~kokrs EQ z~kokrs AND c~spras EQ 'S'
  AND c~datbi GT sy-datum
  INNER JOIN skat AS s ON s~saknr EQ z~kstar AND s~spras EQ 'S' AND s~ktopl EQ p5_kokrs
  INNER JOIN  zcecos_tt_indice AS i ON i~idpres = z~idpres
  AND i~kostl = z~kostl
  WHERE" z~idpres = it_cecos_indice-idpres
  gjahr EQ p5_gjahr
  AND z~kokrs EQ p5_kokrs
  AND z~bukrs IN s5_bukrs
  AND z~kostl IN s5_kostl
  AND z~werks IN s5_werks
  AND z~matkl IN s5_matkl
  AND z~matnr IN s5_matnr "rango materiales
  AND z~tipmod = 'F'
  AND z~cecoaut = 'X'
  AND z~tipo IN rg_tipo
  AND z~kstar IN rg_kstar
  AND z~versn EQ p5_versn
  .

  "se copia para mantener el detalle.
  SORT it_ajustepres ASCENDING BY gjahr bukrs kostl matnr DESCENDING.
  DELETE ADJACENT DUPLICATES FROM it_ajustepres COMPARING ALL FIELDS.

  LOOP AT it_ajustepres INTO wa_ajustepres.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = wa_ajustepres-kostl
      IMPORTING
        output = wa_ajustepres-kostl.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = wa_ajustepres-kstar
      IMPORTING
        output = wa_ajustepres-kstar.


    IF wa_ajustepres-autorizado EQ 'X'.
      wa_ajustepres-color = 'C600'.



      MODIFY it_ajustepres FROM wa_ajustepres INDEX sy-tabix.

      PERFORM row_readonly_ajuste USING wa_ajustepres
            ''
            sy-tabix
            'I'
            'RO'.
    ELSE.
      PERFORM row_readonly_ajuste USING wa_ajustepres
            ''
            sy-tabix
            'I'
            'RW'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_AJUSTEPRES
*&---------------------------------------------------------------------*
*&      Form  SAVE_AJUS_PRES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_ajus_pres .
  DATA: it_savepres TYPE STANDARD TABLE OF st_ajustepres,
        wa_savepres LIKE LINE OF it_ajustepres.

  DATA: lv_count  TYPE i,lv_ok,lv_idpres TYPE char10, lv_ajuste TYPE char200,lv_gjahr TYPE i.
  DATA: lv_smtp TYPE string,lv_body TYPE string.

  it_savepres[] = it_ajustepres[].

  DELETE it_savepres WHERE check NE 'X'.
  DESCRIBE TABLE it_savepres LINES lv_count.

  IF lv_count > 0.
    "se obtiene consecutivo de presupuesto
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr   = '01'
        object        = 'ZRNPLANDA'
        ignore_buffer = 'X'
      IMPORTING
        number        = lv_idpres.
    "--------------------------------------------------
    "Se crea el encabezado del presupuesto
    CONCATENATE 'Ajuste por' sy-uname INTO lv_ajuste.
    READ TABLE it_savepres INTO wa_savepres INDEX 1.
    lv_gjahr = wa_savepres-gjahr.
    PERFORM save_header_pres USING lv_idpres
          'Sin archivo cargado'
          lv_ajuste
          lv_gjahr
    CHANGING lv_ok.

    LOOP AT it_savepres INTO wa_savepres.
      IF wa_savepres-tipo EQ 'MATERIAL'.
        wa_savepres-meg001 = wa_savepres-wtg001 / wa_savepres-preunipres.
        wa_savepres-meg002 = wa_savepres-wtg002 / wa_savepres-preunipres.
        wa_savepres-meg003 = wa_savepres-wtg003 / wa_savepres-preunipres.
        wa_savepres-meg004 = wa_savepres-wtg004 / wa_savepres-preunipres.
        wa_savepres-meg005 = wa_savepres-wtg005 / wa_savepres-preunipres.
        wa_savepres-meg006 = wa_savepres-wtg006 / wa_savepres-preunipres.
        wa_savepres-meg007 = wa_savepres-wtg007 / wa_savepres-preunipres.
        wa_savepres-meg008 = wa_savepres-wtg008 / wa_savepres-preunipres.
        wa_savepres-meg009 = wa_savepres-wtg009 / wa_savepres-preunipres.
        wa_savepres-meg010 = wa_savepres-wtg010 / wa_savepres-preunipres.
        wa_savepres-meg011 = wa_savepres-wtg011 / wa_savepres-preunipres.
        wa_savepres-meg012 = wa_savepres-wtg012 / wa_savepres-preunipres.
      ELSE.
        wa_savepres-meg001 = 1.wa_savepres-meg002 = 1.wa_savepres-meg003 = 1.
        wa_savepres-meg004 = 1.wa_savepres-meg005 = 1.wa_savepres-meg006 = 1.
        wa_savepres-meg007 = 1.wa_savepres-meg008 = 1.wa_savepres-meg009 = 1.
        wa_savepres-meg010 = 1.wa_savepres-meg011 = 1.wa_savepres-meg012 = 1.

      ENDIF.
      "se recalcula WTG Y MEG
      wa_savepres-wtgtot = wa_savepres-wtg001 + wa_savepres-wtg002 + wa_savepres-wtg003 +
      wa_savepres-wtg004 + wa_savepres-wtg005 + wa_savepres-wtg006 +
      wa_savepres-wtg007 + wa_savepres-wtg008 + wa_savepres-wtg009 +
      wa_savepres-wtg010 + wa_savepres-wtg011 + wa_savepres-wtg012.

      wa_savepres-megtot = wa_savepres-meg001 + wa_savepres-meg002 + wa_savepres-meg003 +
      wa_savepres-meg004 + wa_savepres-meg005 + wa_savepres-meg006 +
      wa_savepres-meg007 + wa_savepres-meg008 + wa_savepres-meg009 +
      wa_savepres-meg010 + wa_savepres-meg011 + wa_savepres-meg012.

      "wa_savepres-idpresant = wa_savepres-idpres.
      wa_savepres-idpres = lv_idpres.
      wa_savepres-tipmod = 'F'.
      wa_savepres-cecoaut = ''.
      wa_savepres-autorizado = ''.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_savepres-kostl
        IMPORTING
          output = wa_savepres-kostl.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_savepres-kstar
        IMPORTING
          output = wa_savepres-kstar.

      "se inserta en la BD
      CLEAR wa_planpres.
      MOVE-CORRESPONDING: wa_savepres TO wa_planpres.
      INSERT zco_tt_planpres FROM wa_planpres.
    ENDLOOP.

    READ TABLE it_usuario INTO wa_usuario WITH KEY bname = wa_arma-usuario.
    lv_smtp = wa_usuario-smtp_addr.

    CONCATENATE 'Buen día ' wa_usuario-name_text '. El Ajuste de presupuesto con ID: ' lv_idpres ' ha sido GENERADO. '
    'Favor de Reenviar este correo a la parte correspondiente para seguir con el proceso'
    'de autorización.'
    INTO lv_body SEPARATED BY space.

    CONCATENATE 'Se ha generado el Ajuste con ID:' lv_idpres INTO lv_body.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel        = 'Ajuste de Presupuesto'
        textline1    = lv_body
        start_column = 25
        start_row    = 6.
    PERFORM containers_free.
  ENDIF.

ENDFORM.                    " SAVE_AJUS_PRES
*&---------------------------------------------------------------------*
*&      Form  row_readonly_ajuste
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AJUSTE     text
*      -->P_FIELDNAME  text
*      -->P_INDICE     text
*      -->P_INDICADOR  text
*      -->P_ESTATUS    text
*----------------------------------------------------------------------*
FORM row_readonly_ajuste  USING p_ajuste TYPE st_ajustepres
      p_fieldname TYPE lvc_fname
      p_indice TYPE sy-tabix
      p_indicador TYPE char1
      p_estatus TYPE char2.

  DATA: lt_celltab TYPE lvc_t_styl,
        ls_celltab TYPE lvc_s_styl.

  DATA lv_indice TYPE sy-tabix.

*§2.After selecting data, set edit status for each row in a loop
*   according to field SEATSMAX.
  lv_indice = p_indice.
  IF p_estatus EQ 'RW'.

    PERFORM fill_celltab_ajuste USING p_estatus "RW
    CHANGING lt_celltab.
  ELSE.
    PERFORM fill_celltab_ajuste USING p_estatus "RO
    CHANGING lt_celltab.
  ENDIF.
*§2c.Copy your celltab to the celltab of the current row of gt_outtab.
  REFRESH  p_ajuste-celltab.
  INSERT LINES OF lt_celltab INTO TABLE p_ajuste-celltab.
  MODIFY it_ajustepres FROM p_ajuste INDEX lv_indice.

ENDFORM.                    " ROW_READONLY
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ESTATUS  text
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
FORM fill_celltab_ajuste  USING    p_estatus
CHANGING pt_celltab TYPE lvc_t_styl.

  DATA: ls_celltab TYPE lvc_s_styl,
        l_mode     TYPE raw4.

  DATA: num_mes       LIKE t247-mnr,
        mes_corto     LIKE t247-ktx,
        lv_fldnmecat  TYPE lvc_fname,
        lv_fldnmemont TYPE lvc_fname.
* This forms sets the style of column 'PRICE' editable
* according to 'p_mode' and the rest to read only either way.

  IF p_estatus EQ 'RW'.
*§2a.Use attribute CL_GUI_ALV_GRID=>MC_STYLE_ENABLED to set a cell
*    to status "editable".
    l_mode = cl_gui_alv_grid=>mc_style_enabled.
  ELSE. "p_mode eq 'RO'
*§2b.Use attribute CL_GUI_ALV_GRID=>MC_STYLE_DISABLED to set a cell
*    to status "non-editable".
    l_mode = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  ls_celltab-fieldname = 'CHECK'.
  ls_celltab-style = l_mode.
  INSERT ls_celltab INTO TABLE  pt_celltab.

  ls_celltab-fieldname = 'KOKRS'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'BUKRS'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'KOSTL'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'KTEXT'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'KSTAR'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'TXT20'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'WERKS'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'NAME1'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'MATNR'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'MAKTX'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'CO_MEINH'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'MATKL'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'WGBEZ'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  num_mes = 0.
  DO 12 TIMES.
    num_mes = num_mes + 1.

    PERFORM get_periodo USING num_mes
    CHANGING num_mes
      mes_corto
      lv_fldnmecat
      lv_fldnmemont.

    ls_celltab-fieldname = lv_fldnmemont.
    ls_celltab-style = l_mode.
    INSERT ls_celltab INTO TABLE pt_celltab.

  ENDDO.

  ls_celltab-fieldname = 'WTGTOT'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  IF gref_alvgrid102 IS NOT INITIAL.
    CALL METHOD gref_alvgrid102->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

  ENDIF.


ENDFORM.                    " FILL_CELLTAB
*&---------------------------------------------------------------------*
*&      Form  CHECKBOX_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECKBOX_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM checkbox_click  USING    p_er_data_changed.
  MESSAGE 'ddsds' TYPE 'S'.
ENDFORM.                    " CHECKBOX_CLICK
*&---------------------------------------------------------------------*
*& Form get_almacen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <MATNR>
*&      --> <WERKS>
*&      <-- VL_LGORT
*&---------------------------------------------------------------------*
FORM get_almacen  USING    p_matnr
                            p_werks
                      CHANGING p_lgort.

  CASE p_werks.
    WHEN 'HXIN'.
      p_lgort = 'HXRF'.
    WHEN 'SPIN'.
      p_lgort = 'SPRF'.
    WHEN 'MDIN'.
      p_lgort = 'MDRF'.
    WHEN 'SCIN'.
      p_lgort = 'SCRF'.
    WHEN 'CDHX'.
      p_lgort = 'CDRF'.
    WHEN 'CDSS'.
      p_lgort = 'CDRF'.
    WHEN 'CDMX'.
      p_lgort = 'CDRF'.
    WHEN 'F001'.
      p_lgort = 'FORF'.
    WHEN 'F501'.
      p_lgort = 'CARF'.
    WHEN 'SHIN'.
      p_lgort = 'SHRF'.
    WHEN 'ECIN'.
      p_lgort = 'ECRF'.
    WHEN 'OPCM'.
      p_lgort = 'OPRF'.
    WHEN 'OPFA'.
      p_lgort = 'OPRF'.
    WHEN 'OPSS'.
      p_lgort = 'OPRF'.
    WHEN 'OP01'.
      p_lgort = 'OPRF'.
    WHEN 'OPCA'.
      p_lgort = 'OPRF'.
    WHEN 'OPEC'.
      p_lgort = 'OPRF'.
    WHEN 'OPFO'.
      p_lgort = 'OPRF'.
    WHEN '0300'.
      p_lgort = 'GR04'.
    WHEN '0400'.
      p_lgort = 'GR04'.
    WHEN '0350'.
      p_lgort = 'GR04'.
    WHEN '0370'.
      p_lgort = 'HU04'.
    WHEN '0375'.
      p_lgort = 'TC01'.
    WHEN '0700'.
      p_lgort = 'VV01'.
    WHEN '0702'.
      p_lgort = 'GR04'.
    WHEN '0703'.
      p_lgort = 'GR04'.
  ENDCASE.

  "FIN
ENDFORM.                    " GET_ALMACEN
*&---------------------------------------------------------------------*
*& Form extended_matnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <MATNR>
*&      --> <WERKS>
*&      --> VL_MAKTX
*&      --> VL_LGORT
*&---------------------------------------------------------------------*
FORM extended_matnr  USING    p_matnr TYPE matnr18
      p_werks TYPE werks_d
      p_maktx TYPE maktx
      p_lgort TYPE lgort_d.
  "------------

  DATA: posnr_aux   TYPE char6,
        dsched_line TYPE char4,
        datos       TYPE string,
        indice      TYPE i,
        last_price  TYPE kbetr,
        material    TYPE matnr18,
        message     TYPE bapi_msg.


  DATA: la_headdata             TYPE bapimathead,
        la_clientdata           TYPE bapi_mara,
        la_clientdatax          TYPE bapi_marax,
        la_return               TYPE bapiret2,
        la_plantdata            TYPE bapi_marc,
        la_plantdatax           TYPE  bapi_marcx,
        la_storagelocationdata  LIKE bapi_mard,
        la_storagelocationdatax LIKE bapi_mardx,
        la_valuationdata        LIKE bapi_mbew,
        la_valuationdatax       LIKE bapi_mbewx.

  DATA: i_materialdescription  TYPE TABLE OF bapi_makt,
        wa_materialdescription LIKE LINE OF i_materialdescription,
        wa_datosmigrados       TYPE zmm_tt_extmatnr.

**************tablas auxiliares de datos
  TYPES: BEGIN OF st_campos,
           matnr      TYPE matnr,
           ind_sector TYPE mbrsh,
           matl_type  TYPE mtart,
           matl_group TYPE matkl,
           base_uom   TYPE meins,
           gewei      TYPE gewei,
         END OF st_campos.

  TYPES: BEGIN OF st_pur_group,
           matnr     TYPE matnr,
           pur_group TYPE ekgrp,
         END OF st_pur_group.

  TYPES: BEGIN OF st_val_class,
           matnr     TYPE matnr,
           val_class TYPE bklas,
         END OF st_val_class.



  DATA: it_campos TYPE STANDARD TABLE OF st_campos,
        wa_campos LIKE LINE OF it_campos.

  DATA: it_pur_group TYPE STANDARD TABLE OF st_pur_group,
        wa_pur_group LIKE LINE OF it_pur_group.

  DATA: it_val_class TYPE STANDARD TABLE OF st_val_class,
        wa_val_class LIKE LINE OF it_val_class.

  DATA: vl_ind_sector TYPE mbrsh,
        vl_matl_type  TYPE mtart,
        vl_matl_group TYPE matkl,
        vl_base_uom   TYPE meins,
        vl_availcheck TYPE mtvfp,
        vl_val_class  TYPE bklas,
        vl_pur_group  TYPE ekgrp.
*******************************************************

  dsched_line = '0001'.
  indice = 1.

  CLEAR: la_headdata, la_clientdata, la_clientdatax, la_return, la_plantdata ,
  la_plantdatax, la_storagelocationdata, la_storagelocationdatax, la_valuationdata,
  la_valuationdatax, i_materialdescription, wa_materialdescription.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_matnr
    IMPORTING
      output = material.

**------------------------llenado de tablas auxiliares
  SELECT matnr mbrsh AS ind_sector mtart AS matl_type matkl AS matl_group meins AS base_uom gewei
  INTO TABLE it_campos
  FROM mara
  WHERE matnr EQ p_matnr
  .

  SELECT matnr ekgrp AS pur_group
  INTO TABLE it_pur_group
  FROM marc
  WHERE matnr EQ p_matnr
  .

  SELECT matnr bklas AS val_class
  INTO TABLE it_val_class
  FROM mbew
  WHERE matnr EQ p_matnr
  .

  DELETE it_val_class WHERE val_class IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM it_val_class COMPARING matnr val_class.


  READ TABLE it_campos INTO wa_campos WITH KEY matnr = p_matnr.
  vl_ind_sector = wa_campos-ind_sector.
  vl_matl_type = wa_campos-matl_type.
  vl_matl_group = wa_campos-matl_group.
  vl_base_uom = wa_campos-base_uom.

  IF wa_campos-gewei EQ 'KG' OR wa_campos-matl_type EQ 'HAPT' OR wa_campos-matl_type EQ 'HIBE' OR wa_campos-matl_type EQ 'LEER'.
    vl_availcheck = '02'. " si la unidad de Peso es KG incluye alimento balanceado, subproducto y pollo vivo y derivados.
  ENDIF.

  READ TABLE it_val_class INTO wa_val_class WITH KEY matnr = p_matnr.
  vl_val_class = wa_val_class-val_class.

  READ TABLE it_pur_group INTO wa_pur_group WITH KEY matnr = p_matnr.
  vl_pur_group = wa_pur_group-pur_group.


*---------------------------
  la_headdata-material = material. "layout

  la_headdata-ind_sector = vl_ind_sector. "'G'. "layout "RAMO

  la_headdata-matl_type = vl_matl_type. "'XSUM'. "layout "tipo de material

  la_headdata-basic_view      = 'X'. " Vista de datos básicos
  la_headdata-sales_view      = 'X'. " Vista de Comercial
  la_headdata-purchase_view   = 'X'. " Vista de compras
  la_headdata-storage_view    = 'X'. " Vista de almacén
  la_headdata-warehouse_view  = 'X'. " Vista de gestión de almacenes
  la_headdata-account_view    = 'X'. " Vista de contabilidad
  la_headdata-cost_view       = 'X'.  " Vista de cálculo de coste

  la_clientdata-base_uom = vl_base_uom. "'PZA'. "layout
  la_clientdatax-base_uom = 'X'.

  la_clientdata-matl_group = vl_matl_group. "'LIMPI004'. "layout
  la_clientdatax-matl_group = 'X'.

  la_plantdata-plant = p_werks. "Centro
  la_plantdatax-plant =  p_werks. "'1106'. "layout

  la_plantdata-sloc_exprc = p_lgort. "'3040'. "layout
  la_plantdatax-sloc_exprc = 'X'.

  la_plantdata-pur_group = vl_pur_group. "'A04'. "layout
  la_plantdatax-pur_group = 'X'.

  la_plantdata-mrp_ctrler = 'X'.

  la_plantdata-plnd_delry = '1'.
  la_plantdatax-plnd_delry = 'X'.

  la_plantdata-availcheck = vl_availcheck. "'KP'. "layout
  la_plantdatax-availcheck = 'x'.

  "la_plantdata-profit_ctr = wa_datos-profit_ctr. "'1012110130'. "layout
  "la_plantdatax-profit_ctr = 'X'.

  la_plantdata-mrp_type = 'ND'. "layout
  la_plantdatax-mrp_type = 'X'.

  la_storagelocationdata-plant = p_werks. "'1106'."layout
  la_storagelocationdatax-plant = p_werks. "'1106'."layout

  la_storagelocationdata-stge_loc = p_lgort. "Almacen."layout
  la_storagelocationdatax-stge_loc = p_lgort. "'Almacen."layout

  "  la_storagelocationdata-stge_bin  = wa_datos-stge_bin. "'Jicaro'."layout
  "  la_storagelocationdatax-stge_bin = 'X'.

  "la_valuationdata-moving_pr = wa_datos-moving_pr. "'37.50' ."layout
  "la_valuationdata-price_unit = wa_datos-price_unit. "'37.50'. "layout
  "la_valuationdata-val_type = ''.
  la_valuationdata-val_class = vl_val_class. "'3070'. "layout
  "la_valuationdata-val_cat = ''.
  "la_valuationdata-lifo_fifo = 'X' .
  la_valuationdata-price_ctrl = 'V'. "layout
  "la_valuationdata-vm_p_stock = wa_datos-vm_p_stock." ''.
  "la_valuationdata-pr_ctrl_py = 'V'.
  "la_valuationdata-pr_ctrl_pp = 'V'.

  SELECT SINGLE bwkey
  INTO la_valuationdata-val_area
  FROM t001w
  WHERE werks = p_werks. "'1106'.



  la_valuationdatax-val_area = la_valuationdata-val_area. "'1106'."bapi_valuationdata-val_area.
  "la_valuationdatax-moving_pr = 'X'.
  "la_valuationdatax-price_unit = 'X'.
  la_valuationdatax-val_class = 'X'.
  "la_valuationdatax-vm_p_stock = 'X'.
  "la_valuationdatax-val_cat = 'X'.
  "la_valuationdatax-lifo_fifo = 'X'.
  la_valuationdatax-price_ctrl ='X'.
  "la_valuationdatax-pr_ctrl_pp = 'X'.
  "la_valuationdatax-pr_ctrl_py = 'X'.



  SELECT SINGLE lagpr
  INTO la_plantdata-stor_costs
  FROM t439l
  WHERE werks = p_werks. "'1106'.

  la_plantdatax-stor_costs = 'X'.



  wa_materialdescription-matl_desc = p_maktx. "'TEST'.
  wa_materialdescription-langu = 'S'.

  APPEND wa_materialdescription TO i_materialdescription.

  CLEAR: wa_materialdescription.

  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata             = la_headdata
      clientdata           = la_clientdata
      clientdatax          = la_clientdatax
      plantdata            = la_plantdata
      plantdatax           = la_plantdatax
      storagelocationdata  = la_storagelocationdata
      storagelocationdatax = la_storagelocationdatax
      valuationdata        = la_valuationdata
      valuationdatax       = la_valuationdatax
      flag_online          = ' '
      flag_cad_call        = ' '
    IMPORTING
      return               = la_return
    TABLES
      materialdescription  = i_materialdescription.


  "----------------------------validacion del resultado
  CONCATENATE la_return-type la_return-message INTO message SEPARATED BY '-'.
  wa_datosmigrados-matnr = p_matnr.
  wa_datosmigrados-maktx = p_maktx.
  wa_datosmigrados-werks = p_werks.
  wa_datosmigrados-lgort = p_lgort.
  wa_datosmigrados-uname = sy-uname.

  INSERT zmm_tt_extmatnr FROM wa_datosmigrados.

  COMMIT WORK AND WAIT.
  "----------------------------------------------------

ENDFORM.                    " EXTENDED_MATNR
