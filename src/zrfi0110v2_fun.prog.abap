*&---------------------------------------------------------------------*
*& Include          ZRFI0110V2_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form PROCESO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proceso .
  DATA:
    iva_val   TYPE p DECIMALS 2,
    n         TYPE i,
    rfc_corte TYPE stcd1,
    ult_reg   LIKE sy-tabix,
    sal_ind   LIKE sy-tabix,
    ind_sig   LIKE sy-tabix,
    ind_ant   LIKE sy-tabix,
    lla_bus   LIKE lfa1-lifnr.

  FIELD-SYMBOLS <fs_data> TYPE st_bseg.

  REFRESH tab_bseg.
* SELECCIONA LOS REGISTROS QUE CORRESPONDAN A LA SOCIEDAD Y EJERCICIO
*      QUE SEA UNA CUENTA DE MAYOR, QUE LA CLAVE DE CONTABILIZACION SEA
*      "CONTAB. DEBE", COD. DE IMPUESTO "V1" O "V2", QUE NO TENGA
*      RETENCIONES Y QUE TENGA UN IMPORTE >< 0.
  SELECT b2~bukrs, b2~belnr, b2~gjahr, b2~koart, b2~kunnr,b2~lifnr,
         b2~dmbtr,b2~hwbas,b2~mwskz, b2~h_budat AS budat, b2~h_blart AS blart,
         b1~xblnr, b2~shkzg, b2~hkont
  INTO CORRESPONDING FIELDS OF TABLE @tab_bseg
    FROM  bkpf AS b1
   INNER JOIN bseg AS b2 ON b2~belnr = b1~belnr AND b2~bukrs = b1~bukrs AND b2~gjahr = b1~gjahr
*   left join KNA1 as k on k~kunnr = b2~kunnr
*    left join lfa1 as l on l~lifnr = b2~lifnr
  WHERE   koart = 'S'
  AND      b1~bukrs = @p_bukrs
  AND      b1~gjahr = @gjahr
  AND      b2~h_budat IN @p_budat
  AND    ( b2~bschl = '40' OR b2~bschl = '50' )
* AND    ( MWSKZ = 'V4' OR MWSKZ = 'V3' )  AGREGAR INDICADORES X4 Y X3 14.01.2015
*  AND    ( mwskz = 'X2' OR mwskz = 'X3' OR mwskz = 'X4' )
  AND mwskz IN ('X2','X3', 'X4','X5', 'X6','X7','X8','Y5','Y6','Y7','Y8')
  AND      qsskz = '  '
*  AND      HWBAS <> 0 "comentado temporalmente
  AND      dmbtr NE '0'
********************************** INICIO ************************
**************************************************************************
  "AND   ( hkont = '0000147007' OR hkont = '0000147008' OR hkont = '0000147100' OR hkont = '0000147014').
  AND hkont IN ('0119001002', '0119001001', '0119001003', '0119001006','0119001007','0119001008',
                '0119001013', '0119001014', '0119001015', '0119001016',
                '0118001013', '0118001014', '0118001016', '0118001016').

********************************* INICIO ************************
**************************************************************************
  SELECT  b2~bukrs, b2~belnr, b2~gjahr, b2~koart, b2~kunnr,b2~lifnr,
          b2~dmbtr,b2~hwbas,b2~mwskz, b2~h_budat AS budat, b2~h_blart AS blart,
          b1~xblnr, b2~shkzg, b2~hkont
    APPENDING CORRESPONDING FIELDS OF TABLE @tab_bseg
     FROM  bkpf AS b1
   INNER JOIN bseg AS b2 ON b2~belnr = b1~belnr AND b2~bukrs = b1~bukrs AND b2~gjahr = b1~gjahr
  WHERE   koart = 'S'
  AND     b1~bukrs = @p_bukrs
  AND     b1~gjahr = @gjahr
  AND      b2~h_budat IN @p_budat
  AND     qsskz = '  '
   AND    dmbtr NE '0'
  AND      hkont = '0000147007'.


  SELECT b~belnr, l~lifnr, l~stcd1, l~name1, l~name2, l~ktokk
    INTO TABLE @DATA(it_acreedor)
  FROM lfa1 AS l
  INNER JOIN bseg AS b ON b~lifnr = l~lifnr
    FOR ALL ENTRIES IN @tab_bseg
          WHERE b~belnr = @tab_bseg-belnr AND
                b~bukrs = @tab_bseg-bukrs AND
                b~gjahr = @tab_bseg-gjahr.

  SELECT b~belnr, k~kunnr, k~stcd1, k~name1, k~name2
  INTO TABLE @DATA(it_cliente)
        FROM kna1 AS k
        INNER JOIN bseg AS b ON b~kunnr = k~kunnr
        FOR ALL ENTRIES IN @tab_bseg
        WHERE b~belnr = @tab_bseg-belnr AND
        b~bukrs = @tab_bseg-bukrs AND
        b~gjahr = @tab_bseg-gjahr.


* BUSCA LOS DATOS ADICIONALES PARA COMPLETAR EL REGISTRO.
  LOOP AT tab_bseg ASSIGNING <fs_data>.


    READ TABLE it_cliente INTO DATA(wa_kunnr) WITH KEY belnr = <fs_data>-belnr.
    IF sy-subrc EQ 0.
      <fs_data>-acred = wa_kunnr-kunnr.
      <fs_data>-stcd1 = wa_kunnr-stcd1.
      <fs_data>-name1 = wa_kunnr-name1.
      <fs_data>-name2 = wa_kunnr-name2.
      <fs_data>-band = 0.
    ELSE.
      READ TABLE it_acreedor INTO DATA(wa_lifnr) WITH KEY belnr = <fs_data>-belnr.
      IF sy-subrc EQ 0.
        <fs_data>-acred = wa_lifnr-lifnr.
        <fs_data>-stcd1 = wa_lifnr-stcd1.
        <fs_data>-name1 = wa_lifnr-name1.
        <fs_data>-name2 = wa_lifnr-name2.
        <fs_data>-ktokk = wa_lifnr-ktokk.
        <fs_data>-band = 0.
      ENDIF.
    ENDIF.


  ENDLOOP.

  UNASSIGN <fs_data>.
  SORT tab_bseg BY stcd1.

*  READ TABLE tab_bseg INDEX 1.
*  MOVE tab_bseg-stcd1 TO rfc_corte.
*  DESCRIBE TABLE tab_bseg LINES ult_reg.

  LOOP AT tab_bseg ASSIGNING <fs_data>.
* Imprimir Detalle
    PERFORM imprimir_detalle USING <fs_data>.
* Llena Tabla de Movimientos
    PERFORM movimientos_iva USING <fs_data>.
*    sal_ind = sy-tabix.
*    IF sal_ind = ult_reg.
*      MOVE '' TO rfc_corte.
*    ELSE.
*      ind_sig = sy-tabix + 1.
*      READ TABLE tab_bseg into data(wa) INDEX ind_sig.
*    ENDIF.
*    IF tab_bseg-stcd1 <> rfc_corte.
*      MOVE tab_bseg-stcd1 TO rfc_corte.
*      READ TABLE tab_bseg INDEX sal_ind.
*      MOVE fecha TO tab_bseg-fecha.
*      MODIFY tab_bseg.
** Imprimir Corte
*      " PERFORM IMPRIMIR_CORTE.
*    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOTALCUENTA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM totalcuenta .
  MOVE p_budat+7(2) TO mes.
  MOVE mes TO valor+8(2).
  SELECT        * FROM  glt0
  WHERE  bukrs  = p_bukrs
  AND    ryear  = gjahr
  "AND    racct  = '0000167000'.
   AND    racct  = '0208001002'.
    IF glt0-drcrk EQ 'H'.
      ASSIGN (valor) TO <m>.
      tot_iva_cli = tot_iva_cli + <m>.
      tot_iva_cli = tot_iva_cli * -1.
    ENDIF.
  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form maestro_iva
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM maestro_iva USING fs_data TYPE st_bseg.
  SELECT SINGLE * FROM ziva1 WHERE
  bukrs   = p_bukrs AND
  gjahr   = gjahr   AND
  stcd1   = fs_data-stcd1.
  IF sy-subrc <> 0.
    SELECT SINGLE * FROM t001
    WHERE bukrs = p_bukrs.
    MOVE t001-bukrs             TO ziva1-bukrs.
    MOVE gjahr                  TO ziva1-gjahr.
    MOVE t001-butxt             TO ziva1-name1.
    MOVE t001-stceg             TO ziva1-stcd1.
    MOVE '014'                  TO ziva1-zcvebco.
    MOVE '00078'                TO ziva1-znumsuc.
    MOVE '               '      TO ziva1-znumcta.
    MOVE '       '              TO ziva1-zlocbco.
    MOVE '2'                    TO ziva1-ztipdec.
    MOVE p_budat-low+4(2)  TO ziva1-zperope+0(2).
    MOVE p_budat-low+2(2)  TO ziva1-zperope+2(2).
    MOVE p_budat-high+4(2) TO ziva1-zperope+4(2).
    MOVE p_budat-high+2(2) TO ziva1-zperope+6(2).
    MODIFY ziva1.
  ELSE.
    MOVE '2'                    TO ziva1-ztipdec.
    MOVE p_budat-low+4(2)  TO ziva1-zperope+0(2).
    MOVE p_budat-low+2(2)  TO ziva1-zperope+2(2).
    MOVE p_budat-high+4(2) TO ziva1-zperope+4(2).
    MOVE p_budat-high+2(2) TO ziva1-zperope+6(2).
    MODIFY ziva1.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_fieldcat .

  wa_fieldcat-fieldname   = 'BLART'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'CD'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'BELNR'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Documento'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
  wa_fieldcat-no_zero      = 'X'.
*  wa_fieldcat-datatype = 'Datatype'.
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'HKONT'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Cuenta'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'TXT20'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Texto cuenta'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'ACRED'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Clave de proveedor'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'STCD1'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'RFC'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'NAME1'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Nombre'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'NAME2'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Nombre 2'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'XBLNR'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Factura'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'FEC_COR'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Fecha documento'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'HWBAS'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Subtotal'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  wa_fieldcat-do_sum      = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.

  wa_fieldcat-fieldname   = 'MWSKZ'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Indicador IVA'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.


  wa_fieldcat-fieldname   = 'DMBTR'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'Importe IVA'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  wa_fieldcat-do_sum      = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.


  wa_fieldcat-fieldname   = 'IMP_TOT'. "fieldcat name nombre del campo en la tabla interna
  wa_fieldcat-seltext_m   = 'TOTAL'. " Descripcion del campo
  wa_fieldcat-outputlen   = 15. "longitud del campo
  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
*  wa_fieldcat-key         = 'X'. "es campo llave
  wa_fieldcat-do_sum      = 'X'.
  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
  CLEAR  wa_fieldcat. "limpiamos la work area.
*
*  wa_fieldcat-fieldname   = 'NAT_CTA'. "fieldcat name nombre del campo en la tabla interna
*  wa_fieldcat-seltext_m   = 'TOTAL'. " Descripcion del campo
*  wa_fieldcat-outputlen   = 15. "longitud del campo
*  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
**  wa_fieldcat-key         = 'X'. "es campo llave
**    wa_fieldcat-do_sum      = 'X'.
*  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
*  CLEAR  wa_fieldcat. "limpiamos la work area.
*
*  wa_fieldcat-fieldname   = 'KOART'. "fieldcat name nombre del campo en la tabla interna
*  wa_fieldcat-seltext_m   = 'Koart'. " Descripcion del campo
*  wa_fieldcat-outputlen   = 15. "longitud del campo
*  wa_fieldcat-emphasize   = 'X'. "emfatiza la columna
**  wa_fieldcat-key         = 'X'. "es campo llave
*  APPEND wa_fieldcat TO gt_fieldcat. "agregamos esta fila a la tabla
*  CLEAR  wa_fieldcat. "limpiamos la work area.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .

  wa_format-zebra               = 'X'.     "Patron de rayas
  wa_format-no_vline            = space.   "Columnas separadas espacio
  wa_format-no_hline            = space.   "Filas separadas espacio
  "wa_format-no_subtotals        = space.   "Subtotales no posibles
  wa_format-colwidth_optimize   = 'X'.     "Tamaño optimizado columna
  wa_format-totals_before_items = space.   "Despliega los totales
  "wa_format-coltab_fieldname    = 'VBELN'. "Color

  wa_sort-spos = 1.               " Prioridad de ordenamiento
  wa_sort-fieldname = 'STCD1'.    " campo por el cual se ordena
  wa_sort-tabname = 'it_final'. " Tabla interna
  wa_sort-up = 'X'.           " Ordenamos ascendentemente
  wa_sort-subtot    = 'X'.
*  wa_sort-expa = 'X'.      "this is important
  APPEND wa_sort TO it_sort. " append de work area a tabla interna
  CLEAR wa_sort.
************
* Procesa ALV.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid " "Nombre del report para volver al dynpro correspondiente
*     i_callback_pf_status_set = 'PF_STATUS'            " Nombre del STATUS que usaremos, si no usamos un STATUS se tomara el default
*     i_callback_top_of_page   = 'F_TOP_OF_PAGE'         " Nombre de cabecera si aplica
*     i_callback_user_command  = 'USER_COMMAND'          " Nombre de User command (para captar funciones de botones o teclas)
      is_layout          = wa_format               " Formato del ALV
"     i_structure_name   = 'XXX'                  " Nombre de estructura si deseamos utilizarla en vez de un fieldcat
      it_sort            = it_sort                " Nombre de tabla interna con patrones de ordenamiento.
      it_fieldcat        = gt_fieldcat[]           " Nombre de la tabla interna del catalogo de campos (fieldcat)
      i_save             = 'X'                     " Permite guardar (para disposiciones).
    TABLES
      t_outtab           = it_final               " Nombre de la tabla interna que sera procesada para el ALV
    EXCEPTIONS
      program_error      = 1                       " Captura de errores.
      OTHERS             = 2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  IMPRIMIR_DETALLE
*----------------------------------------------------------------------*
FORM imprimir_detalle USING fs_data TYPE  st_bseg.
  DATA:
        fec_cor(10) TYPE c.

  CONCATENATE fs_data-budat+0(4) '/' fs_data-budat+4(2) " NOTA 99354
  '/' fs_data-budat+6(2) INTO  fec_cor.                  " NOTA 99354

  IF fs_data-shkzg = 'S' AND fs_data-band = 1.
    MOVE '-'          TO nat_cta.
    SUBTRACT fs_data-hwbas FROM sub_tot_cor.
    SUBTRACT fs_data-hwbas FROM sub_tot_gen.
    SUBTRACT fs_data-dmbtr FROM iva_cor.
    SUBTRACT fs_data-dmbtr FROM iva_gen.
    imp_tot = fs_data-hwbas + fs_data-dmbtr.
    SUBTRACT imp_tot  FROM tot_cor.
    SUBTRACT imp_tot  FROM tot_gen.
    ADD 1        TO tot_reg_gen.
    IF fs_data-mwskz = 'V4'.                   " Actualizacion iva 11 % ORG 02.02.2010
      SUBTRACT fs_data-dmbtr FROM tot_iva_11.
    ELSEIF fs_data-mwskz = 'V3' OR fs_data-mwskz = 'X3' OR fs_data-mwskz = 'X4'.      " Actualizacion iva 16 % ORG 02.02.2010 14.01.2015
      SUBTRACT fs_data-dmbtr FROM tot_iva_16.
    ELSEIF fs_data-mwskz = 'X2'.
      SUBTRACT fs_data-dmbtr FROM tot_iva_08.
    ENDIF.
  ELSE.
    IF fs_data-shkzg = 'H' AND fs_data-band = 0.
      MOVE '-'          TO nat_cta.
      SUBTRACT fs_data-hwbas FROM sub_tot_cor.
      SUBTRACT fs_data-hwbas FROM sub_tot_gen.
      SUBTRACT fs_data-dmbtr FROM iva_cor.
      SUBTRACT fs_data-dmbtr FROM iva_gen.
      imp_tot = fs_data-dmbtr + fs_data-hwbas.
      SUBTRACT imp_tot  FROM tot_cor.
      SUBTRACT imp_tot  FROM tot_gen.
      ADD 1        TO tot_reg_gen.
      IF fs_data-mwskz = 'V4'.                  " Actualizacion iva 11 % ORG 02.02.2010
        SUBTRACT fs_data-dmbtr FROM tot_iva_11.
      ELSEIF fs_data-mwskz = 'V3' OR fs_data-mwskz = 'X3' OR fs_data-mwskz = 'X4'.    " Actualizacion iva 16 % ORG 02.02.2010 14.01.2015
        SUBTRACT fs_data-dmbtr FROM tot_iva_16.
      ELSEIF fs_data-mwskz = 'X2'.
        SUBTRACT fs_data-dmbtr FROM tot_iva_08.
      ENDIF.
    ELSE.
      IF fs_data-shkzg = 'H' AND fs_data-band = 1.
        MOVE '+'     TO nat_cta.
        ADD fs_data-hwbas TO sub_tot_cor.
        ADD fs_data-hwbas TO sub_tot_gen.
        ADD fs_data-dmbtr TO iva_cor.
        ADD fs_data-dmbtr TO iva_gen.
        imp_tot = fs_data-dmbtr + fs_data-hwbas.
        ADD imp_tot  TO tot_cor.
        ADD imp_tot  TO tot_gen.
        ADD 1        TO tot_reg_gen.
        IF fs_data-mwskz = 'V4'.                " Actualizacion iva 11 % ORG 02.02.2010
          ADD fs_data-dmbtr TO tot_iva_11.
        ELSEIF fs_data-mwskz = 'V3' OR fs_data-mwskz = 'X3' OR fs_data-mwskz = 'X4'.  " Actualizacion iva 16 % ORG 02.02.2010 14.01.2015
          ADD fs_data-dmbtr TO tot_iva_16.
        ELSEIF fs_data-mwskz = 'X2'.
          ADD fs_data-dmbtr TO tot_iva_08.
        ENDIF.
      ELSE.
        IF fs_data-shkzg = 'S' AND fs_data-band = 0.
          MOVE '+'     TO nat_cta.
          ADD fs_data-hwbas TO sub_tot_cor.
          ADD fs_data-hwbas TO sub_tot_gen.
          ADD fs_data-dmbtr TO iva_cor.
          ADD fs_data-dmbtr TO iva_gen.
          imp_tot = fs_data-dmbtr + fs_data-hwbas.
          ADD imp_tot  TO tot_cor.
          ADD imp_tot  TO tot_gen.
          ADD 1        TO tot_reg_gen.
          IF fs_data-mwskz = 'V4'.              " Actualizacion iva 11 % ORG 02.02.2010
            ADD fs_data-dmbtr TO tot_iva_11.
          ELSEIF fs_data-mwskz = 'V3' OR fs_data-mwskz = 'X3' OR fs_data-mwskz = 'X4'.  " Actualizacion iva 16 % ORG 02.02.2010 14.01.2015
            ADD fs_data-dmbtr TO tot_iva_16.
          ELSEIF fs_data-mwskz = 'X2'.
            ADD fs_data-dmbtr TO tot_iva_08.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.


  wa_final-blart = fs_data-blart.
  wa_final-belnr = fs_data-belnr.
  wa_final-acred = fs_data-acred.
  wa_final-stcd1 = fs_data-stcd1.
  wa_final-name1 = fs_data-name1.
  wa_final-name2 = fs_data-name2.
  wa_final-xblnr = fs_data-xblnr.
  wa_final-fec_cor = fec_cor.              "FECHA DE DOCUMENTO
*        wa_final-hwbas = TAB_BSEG-HWBAS.
  IF nat_cta = '+'.
    wa_final-hwbas = fs_data-hwbas.
    wA_final-dmbtr = fs_data-dmbtr.
    wa_final-imp_tot = imp_tot.
  ELSE.
    wa_final-hwbas = fs_data-hwbas.
    IF wa_final-hwbas GT 0.
      wa_final-hwbas = wa_final-hwbas * -1.
    ENDIF.
    wA_final-dmbtr = fs_data-dmbtr.
    wa_final-imp_tot = imp_tot.
    IF wa_final-dmbtr GT 0.
      wa_final-dmbtr = wa_final-dmbtr * -1.
    ENDIF.

    IF wa_final-imp_tot GT 0.
      wa_final-imp_tot = wa_final-imp_tot  * -1.
    ENDIF.
  ENDIF.
*        155(5)  IVA_PJE,
  wa_final-mwskz = fs_data-mwskz.
*        wA_final-dmbtr = TAB_BSEG-DMBTR.
*        wa_final-imp_tot = IMP_TOT.
  wa_final-nat_cta = nat_cta.
  wa_final-koart = fs_data-koart.
  wa_final-hkont = fs_data-hkont.

  "CONCATENATE p_bukrs(2) '00' INTO lv_kokrs.
  lv_kokrs = 'GP00'.
  SELECT SINGLE txt20
  FROM skat
  INTO wa_final-txt20
  WHERE spras = 'S'
  AND ktopl = lv_kokrs
  AND saknr = wa_final-hkont.

  APPEND wa_final TO it_final.
ENDFORM.                    " IMPRIMIR_DETALLE

*&---------------------------------------------------------------------*
*&      Form  MOVIMIENTOS_IVA
*&---------------------------------------------------------------------*
FORM movimientos_iva USING fs_data TYPE st_bseg.
  SELECT SINGLE * FROM zivai WHERE
  bukrs = p_bukrs AND
  gjahr = gjahr AND
  belnr = fs_data-belnr.
  IF sy-subrc <> 0.
    MOVE p_bukrs        TO  zivai-bukrs.
    MOVE gjahr          TO  zivai-gjahr.
    MOVE fs_data-belnr TO  zivai-augbl.
    MOVE fs_data-stcd1 TO  zivai-stcd1.
    MOVE fs_data-belnr TO  zivai-belnr.
    MOVE fs_data-lifnr TO  zivai-lifnr.
    MOVE fs_data-blart TO  zivai-blart.
    MOVE fs_data-koart TO  zivai-koart.
    MOVE nat_cta        TO  zivai-znatcta.
    MOVE fs_data-name1 TO  zivai-name1.
    MOVE fs_data-name2 TO  zivai-name2.
    MOVE fs_data-xblnr TO  zivai-bktxt.
    MOVE fs_data-budat TO  zivai-budat.
    MOVE fs_data-hwbas TO  zivai-wrbtr.           " Subtotal
    MOVE fs_data-dmbtr TO  zivai-zwrbtr.          " IVA
    zivai-zwrbtr1 = zivai-wrbtr + zivai-zwrbtr.    " TOTAL
    IF fs_data-mwskz EQ 'V4'.           " Modificacion IVA 11% ORG 02.02.2010
      MOVE '11' TO zivai-mwskz.
    ELSEIF fs_data-mwskz EQ 'V3' OR fs_data-mwskz EQ 'X3' OR fs_data-mwskz EQ 'X4'.    " Modificacion IVA 16% ORG 02.02.2010 14.01.2015
      MOVE '16' TO zivai-mwskz.
    ELSEIF fs_data-mwskz EQ 'X2'.
      MOVE '08' TO zivai-mwskz.
    ENDIF.
    SEARCH tip_1 FOR fs_data-ktokk.
    IF sy-subrc = 0.
      MOVE '1' TO zivai-ktokk.                               "     33
    ELSE.
      SEARCH tip_2 FOR fs_data-ktokk.
      IF sy-subrc = 0.
        MOVE '2' TO zivai-ktokk.                            "     33
      ELSE.
        SEARCH tip_3 FOR fs_data-ktokk.
        IF sy-subrc = 0.
          MOVE '3'  TO zivai-ktokk.                        "     33
        ELSE.
          MOVE '0'  TO zivai-ktokk.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    IF nat_cta EQ '+'.
      ADD fs_data-hwbas TO zivai-wrbtr.           " Subtotal
      ADD fs_data-dmbtr TO  zivai-zwrbtr.          " IVA
      zivai-zwrbtr1 = zivai-zwrbtr1 + zivai-wrbtr + zivai-zwrbtr.
    ELSE.
      SUBTRACT fs_data-hwbas FROM zivai-wrbtr.
      SUBTRACT fs_data-dmbtr FROM zivai-zwrbtr.
      SUBTRACT fs_data-hwbas FROM zivai-zwrbtr1.
      SUBTRACT fs_data-dmbtr FROM zivai-zwrbtr1.
    ENDIF.
    IF zivai-wrbtr > 1.
      MOVE '+' TO zivai-znatcta.
    ELSE.
      MOVE '-' TO zivai-znatcta.
    ENDIF.
  ENDIF.
  MODIFY zivai.
ENDFORM.                    " MOVIMIENTOS_IVA
