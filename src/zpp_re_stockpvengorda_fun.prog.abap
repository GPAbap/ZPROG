*&---------------------------------------------------------------------*
*& Include          ZPP_RE_STOCKPVENGORDA_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA e_sysst LIKE bsvx-sttxt.

  DATA: vl_n_bool, vl_de_bool, vl_db_bool.

  DATA: vl_prei   TYPE menge_d, vl_ini TYPE menge_d, vl_creci TYPE menge_d,
        vl_final  TYPE menge_d, vl_final2 TYPE menge_d.

  CLEAR: vl_n_bool, vl_de_bool, vl_db_bool,
         vl_prei, vl_ini, vl_creci, vl_final, vl_final2.


  SELECT c~aufnr,c~werks, SUM( r~enmng ) AS reservas,nomng AS decomiso, nomng AS natural,nomng AS desembarque,nomng AS descartes,
      nomng AS salidas, c~gstrp, t~name1,nomng AS kilos,c~objnr,p~ablad
      FROM caufv AS c
    INNER JOIN resb AS r ON r~rsnum EQ c~rsnum AND r~matnr IN ('000000000000400190','000000000000400188')
                        AND r~enmng GT 0
    INNER JOIN t001w AS t ON t~werks EQ c~werks
    INNER JOIN afpo AS p ON p~aufnr = c~aufnr AND p~posnr EQ '1'
  WHERE c~aufnr IN @so_orden
       AND c~werks IN @so_wers
  GROUP BY c~aufnr,c~werks, nomng, gstrp, name1, c~objnr,p~ablad
      UNION ALL
  SELECT z~aufnr, z~werks, nousar AS reservas,CAST( 0 AS DEC( 13,3 ) ) AS decomiso,
   CASE WHEN z~matnr EQ 'NATURAL' THEN SUM( z~menge ) END AS natural,
   CASE WHEN z~matnr EQ 'DESEMBARQUE' THEN SUM( z~menge ) END AS desembarque,
   CASE WHEN z~matnr EQ 'DESCARTES' THEN SUM( z~menge ) END AS descartes,
   nousar AS salidas,c~gstrp, t~name1,nousar AS kilos,c~objnr,p~ablad
   FROM caufv AS c
  LEFT JOIN ztpp_mov_engorda AS z ON z~aufnr EQ c~aufnr AND z~bwart EQ '531'
  INNER JOIN afpo AS p ON p~aufnr = c~aufnr AND p~posnr EQ '1'
  INNER JOIN t001w AS t ON t~werks EQ c~werks
  WHERE c~aufnr IN @so_orden
       AND c~werks IN @so_wers
  GROUP BY z~aufnr,z~werks, nousar,gstrp, name1, c~objnr, z~matnr,p~ablad "decomisos
 UNION ALL
  SELECT m~charg AS aufnr, m~werks, bpmng AS reservas, bpmng AS decomiso,bpmng AS natural,bpmng AS desembarque,bpmng AS descartes,

                           SUM( CASE WHEN bwart EQ '602' OR bwart EQ '642' OR bwart EQ '302'  THEN menge * -1
                           ELSE menge
                          END )  AS salidas,m~vfdat AS gstrp, t~name1,
                          SUM( CASE WHEN bwart EQ '602' OR bwart EQ '642' OR bwart EQ '302'  THEN /cwm/menge * -1
                           ELSE /cwm/menge
                          END )  AS kilos, c~objnr,p~ablad
   FROM mseg AS m
   INNER JOIN caufv AS c ON c~aufnr EQ m~charg
   INNER JOIN t001w AS t ON t~werks EQ m~werks
   INNER JOIN afpo AS p ON p~aufnr = c~aufnr AND p~posnr EQ '1'
  WHERE m~matnr BETWEEN '000000000000500021' AND '000000000000500027'
      AND bwart IN ('301','302','601','602','641','642')
       AND m~charg IN @so_orden
        AND m~werks IN @so_wers
    GROUP BY m~charg, m~werks, bpmng,vfdat, name1,objnr,p~ablad
  INTO TABLE @DATA(it_tmp)
 .

  SORT it_tmp BY aufnr werks.



  SELECT aufnr, werks,
    CASE WHEN matnr EQ '000000000000500366' THEN SUM( enmng ) END AS Preiniciador,
    CASE WHEN matnr EQ '000000000000500367' THEN SUM( enmng ) END AS Iniciador,
    CASE WHEN matnr EQ '000000000000500368' OR matnr EQ '000000000000500383' THEN SUM( enmng ) END AS Crecimiento,
    CASE WHEN matnr EQ '000000000000500369' OR matnr EQ '000000000000500384' THEN SUM( enmng ) END AS Final,
    CASE WHEN matnr EQ '000000000000500453' OR matnr EQ '000000000000500266' THEN SUM( enmng ) END AS Final2
    FROM resb
    WHERE aufnr IN @so_orden
    AND bwart IN ( '261', '262' )
    AND lgort LIKE 'GPS%'
    AND matnr IN ('000000000000500366','000000000000500367',
                  '000000000000500368','000000000000500369',
                  '000000000000500383','000000000000500384',
                  '000000000000500453','000000000000500266')
    GROUP BY matnr,aufnr, werks
    INTO TABLE @DATA(it_alimento).
  SORT it_alimento BY aufnr werks.


  SELECT aufnr, werks,
    SUM( enmng ) AS Pollinaza
    FROM resb
    WHERE aufnr IN @so_orden
    AND bwart IN ( '531', '532' )
    AND matnr IN ('000000000000400054','000000000000400055')
                      GROUP BY aufnr, werks
    INTO TABLE @DATA(it_pollinaza).
  SORT it_pollinaza BY aufnr werks.




  LOOP AT it_tmp INTO DATA(wa_tmp).

    IF wa_tmp-reservas > 0.
      MODIFY it_tmp FROM wa_tmp TRANSPORTING reservas WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
    ENDIF.

    IF wa_tmp-natural > 0  AND vl_n_bool EQ abap_false.
      wa_tmp-decomiso = wa_tmp-decomiso + wa_tmp-natural.
      MODIFY it_tmp FROM wa_tmp  TRANSPORTING natural  WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks .
      MODIFY it_tmp FROM wa_tmp TRANSPORTING decomiso WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
      vl_n_bool = abap_true.
    ENDIF.

    IF wa_tmp-descartes > 0 AND vl_de_bool EQ abap_false.
      wa_tmp-decomiso = wa_tmp-decomiso + wa_tmp-descartes.
      MODIFY it_tmp FROM wa_tmp  TRANSPORTING descartes WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
      MODIFY it_tmp FROM wa_tmp TRANSPORTING decomiso WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
      vl_de_bool = abap_true.
    ENDIF.

    IF wa_tmp-desembarque > 0 AND vl_db_bool EQ abap_false .
      wa_tmp-decomiso = wa_tmp-decomiso + wa_tmp-desembarque.
      MODIFY it_tmp FROM wa_tmp  TRANSPORTING desembarque WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
      MODIFY it_tmp FROM wa_tmp TRANSPORTING decomiso WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
      vl_db_bool = abap_true.
    ENDIF.

    IF wa_tmp-salidas > 0.
      MODIFY it_tmp FROM wa_tmp TRANSPORTING salidas WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
    ENDIF.

    IF wa_tmp-kilos > 0.
      MODIFY it_tmp FROM wa_tmp TRANSPORTING kilos WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
    ENDIF.

    IF wa_tmp-gstrp  IS NOT INITIAL.
      MODIFY it_tmp FROM wa_tmp TRANSPORTING gstrp WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
    ENDIF.

    AT END OF aufnr.
      CLEAR: vl_n_bool, vl_de_bool, vl_db_bool.
    ENDAT.
  ENDLOOP.



  SORT it_tmp BY aufnr werks.
  DELETE ADJACENT DUPLICATES FROM it_tmp COMPARING aufnr werks.



  LOOP AT it_tmp INTO DATA(wa).
    APPEND INITIAL LINE TO it_outtable ASSIGNING <fs_table>.
    <fs_table>-aufnr = wa-aufnr.
    <fs_table>-werks = wa-werks.
    <fs_table>-cant_al = wa-reservas.
    <fs_table>-decomiso = wa-decomiso.
    <fs_table>-natural = wa-natural.
    <fs_table>-desembarque = wa-desembarque.
    <fs_table>-descartes = wa-descartes.
    <fs_table>-salidas = wa-salidas.
    IF wa-ablad GT 0.
      <fs_table>-densidad = wa-reservas / wa-ablad.
      <fs_table>-kgmts2 = wa-kilos / wa-ablad.
    ENDIF.


    IF wa-gstrp IS NOT INITIAL .
      <fs_table>-gstrp = wa-gstrp.
    ENDIF.

    <fs_table>-name1 = wa-name1.
    IF wa-kilos GT 0.
      <fs_table>-kilos = wa-kilos.
    ENDIF.

    <fs_table>-stock = wa-reservas - ( wa-decomiso + wa-salidas ).


    CALL FUNCTION 'AIP9_STATUS_READ'
      EXPORTING
        i_objnr = wa_tmp-objnr
        i_spras = sy-langu
      IMPORTING
        e_sysst = e_sysst.

    <fs_table>-istat = e_sysst.
    UNASSIGN <fs_table>.
  ENDLOOP.

  "Alimento



  LOOP AT it_tmp INTO wa_tmp.
    CLEAR:  vl_prei, vl_ini, vl_creci, vl_final, vl_final2.

    LOOP AT it_alimento INTO DATA(wa_alimento) WHERE aufnr = wa_tmp-aufnr AND werks = wa_tmp-werks.
      vl_prei = vl_prei + wa_alimento-preiniciador.
      vl_ini = vl_ini + wa_alimento-iniciador.
      vl_creci = vl_creci + wa_alimento-crecimiento.
      vl_final = vl_final + wa_alimento-final.
      vl_final2 = vl_final2 + wa_alimento-final2.
    ENDLOOP.

    READ TABLE it_outtable ASSIGNING FIELD-SYMBOL(<fs_struct>) WITH KEY aufnr = wa_tmp-aufnr werks = wa_tmp-werks.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'KG_PRE' OF STRUCTURE <fs_struct> TO FIELD-SYMBOL(<line>).
      <line> = vl_prei.

      ASSIGN COMPONENT 'KG_INICIA' OF STRUCTURE <fs_struct> TO <line>.
      <line> = vl_ini.

      ASSIGN COMPONENT 'KG_CREC' OF STRUCTURE <fs_struct> TO <line>.
      <line> = vl_creci.

      ASSIGN COMPONENT 'KG_FINAL' OF STRUCTURE <fs_struct> TO <line>.
      <line> = vl_final.

      ASSIGN COMPONENT 'KG_FINAL2' OF STRUCTURE <fs_struct> TO <line>.
      <line> = vl_final2.



      READ TABLE it_pollinaza ASSIGNING FIELD-SYMBOL(<fs_structp>) WITH KEY aufnr = wa_tmp-aufnr werks = wa_tmp-werks.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT 'POLLINAZA' OF STRUCTURE <fs_structp> TO FIELD-SYMBOL(<linep>).
        ASSIGN COMPONENT 'POLLINAZA' OF STRUCTURE <fs_struct> TO <line>.
        <line> = <linep>.
      ENDIF.

    ENDIF.

  ENDLOOP.

  LOOP AT it_outtable ASSIGNING <fs_table>.
    IF <fs_table>-cant_al GT 0.
      <fs_table>-porc_mort = ( <fs_table>-decomiso / <fs_table>-cant_al ) * 100.
    ENDIF.

    IF <fs_table>-kilos GT 0.
      <fs_table>-conversion = ( <fs_table>-kg_pre + <fs_table>-kg_inicia +
                                <fs_table>-kg_crec + <fs_table>-kg_final +
                                <fs_table>-kg_final2 ) / <fs_table>-kilos.
    ENDIF.

    IF <fs_table>-salidas GT 0.
      <fs_table>-pesoprom = <fs_table>-kilos / <fs_table>-salidas.
    ENDIF.

  ENDLOOP.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fieldcat .
  CLEAR wa_fieldcat.
  REFRESH gt_fieldcat.

  wa_fieldcat-fieldname = 'AUFNR'.
  wa_fieldcat-seltext_m = 'Orden.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-seltext_m = 'Centro.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-seltext_m = 'Desc. Centro'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'GSTRP'.
  wa_fieldcat-seltext_m = 'Fecha Inicio'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'CANT_AL'.
  wa_fieldcat-seltext_m = 'Cant. Alojada'.
  wa_fieldcat-seltext_l = 'Cant. Alojada'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'DECOMISO'.
  wa_fieldcat-seltext_m = 'Decomiso'.
  wa_fieldcat-seltext_l = 'Decomiso'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'DESEMBARQUE'.
  wa_fieldcat-seltext_m = 'DESEMBARQUE'.
  wa_fieldcat-seltext_l = 'DESEMBARQUE'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NATURAL'.
  wa_fieldcat-seltext_m = 'NATURAL'.
  wa_fieldcat-seltext_l = 'NATURAL'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'DESCARTES'.
  wa_fieldcat-seltext_m = 'DESCARTE'.
  wa_fieldcat-seltext_l = 'DESCARTE'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'SALIDAS'.
  wa_fieldcat-seltext_m = 'Salidas/Ventas'.
  wa_fieldcat-seltext_l = 'Salidas/Ventas'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'KILOS'.
  wa_fieldcat-seltext_m = 'Kg. Totales'.
  wa_fieldcat-seltext_l = 'Kg. Totales'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.



  wa_fieldcat-fieldname = 'STOCK'.
  wa_fieldcat-seltext_m = 'Stock Actual'.
  wa_fieldcat-seltext_l = 'Stock Actual'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'KG_PRE'.
  wa_fieldcat-seltext_m = 'Kgs. Preiniciador'.
  wa_fieldcat-seltext_l = 'Kgs. Preiniciador'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'KG_INICIA'.
  wa_fieldcat-seltext_m = 'Kgs. Iniciador'.
  wa_fieldcat-seltext_l = 'Kgs. Iniciador'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'KG_CREC'.
  wa_fieldcat-seltext_m = 'Kgs. Crecimiento'.
  wa_fieldcat-seltext_l = 'Kgs. Crecimiento'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'KG_FINAL'.
  wa_fieldcat-seltext_m = 'Kgs. Final'.
  wa_fieldcat-seltext_l = 'Kgs. Final'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'KG_FINAL2'.
  wa_fieldcat-seltext_m = 'Kgs. Final2'.
  wa_fieldcat-seltext_l = 'Kgs. Final2'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'PORC_MORT'.
  wa_fieldcat-seltext_m = '% Mortalidad'.
  wa_fieldcat-seltext_l = '% Mortalidad'.
  wa_fieldcat-decimals_out = 2.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'PESOPROM'.
  wa_fieldcat-seltext_m = 'Peso Promedio'.
  wa_fieldcat-seltext_l = 'Peso Promedio'.
  wa_fieldcat-decimals_out = 2.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'CONVERSION'.
  wa_fieldcat-seltext_m = 'Conversion'.
  wa_fieldcat-seltext_l = 'Conversion'.
  wa_fieldcat-decimals_out = 2.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

    wa_fieldcat-fieldname = 'DENSIDAD'.
  wa_fieldcat-seltext_m = 'Densidad'.
  wa_fieldcat-seltext_l = 'Densidad'.
  wa_fieldcat-decimals_out = 2.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

    wa_fieldcat-fieldname = 'KGMTS2'.
  wa_fieldcat-seltext_m = 'Kgs/Mts2'.
  wa_fieldcat-seltext_l = 'Kgs/Mts2'.
  wa_fieldcat-decimals_out = 2.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.


  wa_fieldcat-fieldname = 'POLLINAZA'.
  wa_fieldcat-seltext_m = 'Pollinaza'.
  wa_fieldcat-seltext_l = 'Pollinaza'.
  wa_fieldcat-decimals_out = 0.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ISTAT'.
  wa_fieldcat-seltext_m = 'Estatus'.
  wa_fieldcat-seltext_l = 'Estatus'.
  wa_fieldcat-no_out    = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.


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

  gl_layout-zebra = 'X'.
  gl_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK      = ' '
*     I_BYPASSING_BUFFER     = ' '
*     I_BUFFER_ACTIVE        = ' '
      i_callback_program     = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
      i_callback_top_of_page = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME       =
*     I_BACKGROUND_ID        = ' '
*     I_GRID_TITLE           =
*     I_GRID_SETTINGS        =
      is_layout              = gl_layout
      it_fieldcat            = gt_fieldcat
*     IT_EXCLUDING           =
*     IT_SPECIAL_GROUPS      =
*     IT_SORT                =
*     IT_FILTER              =
*     IS_SEL_HIDE            =
*     I_DEFAULT              = 'X'
*     I_SAVE                 = ' '
*     IS_VARIANT             =
*     IT_EVENTS              =
*     IT_EVENT_EXIT          =
*     IS_PRINT               =
*     IS_REPREP_ID           =
*     I_SCREEN_START_COLUMN  = 0
*     I_SCREEN_START_LINE    = 0
*     I_SCREEN_END_COLUMN    = 0
*     I_SCREEN_END_LINE      = 0
*     I_HTML_HEIGHT_TOP      = 0
*     I_HTML_HEIGHT_END      = 0
*     IT_ALV_GRAPHICS        =
*     IT_HYPERLINK           =
*     IT_ADD_FIELDCAT        =
*     IT_EXCEPT_QINFO        =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER =
    TABLES
      t_outtab               = it_outtable
* EXCEPTIONS
*     PROGRAM_ERROR          = 1
*     OTHERS                 = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM top_of_page.
* Titulo
  wa_header-typ  = 'H'.
  wa_header-info = 'Reporte Stock Pollo Engorda'.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

* Fecha
  wa_header-typ  = 'S'.
  wa_header-key = 'Fecha: '.
  CONCATENATE  sy-datum+6(2) '.'
               sy-datum+4(2) '.'
               sy-datum(4) INTO wa_header-info.
  APPEND wa_header TO gt_header.
  CLEAR: wa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header
      i_logo             = 'LOGO_CHICKY'.

ENDFORM.
