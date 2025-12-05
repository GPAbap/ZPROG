*&---------------------------------------------------------------------*
*&  Include           ZRSD0026_DA_CONADESUCAV2_F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SELECCION
*&---------------------------------------------------------------------*
FORM f_get_data.
  SELECT vbrk~bukrs
         vbrk~vkorg vbrk~spart vbrk~fkdat vbrk~vbeln "vbrk~ernam
         vbrk~kunag vbrk~knumv vbrk~bzirk vbrk~vtweg vbrk~waerk
         vbrk~kurrf vbrk~fktyp vbrk~vbtyp vbrk~fksto
         vbrp~fkimg vbrp~vrkme vbrp~matnr vbrp~kzwi1 vbrp~ntgew
         vbrp~kzwi2 vbrp~kzwi6 "se agrega kzwi2 por importe total
         vbrp~netwr
  FROM  vbrk INNER JOIN vbrp
  ON  vbrk~vbeln = vbrp~vbeln
  INTO CORRESPONDING FIELDS OF TABLE vbr
  WHERE vbrk~vkorg IN vkorg_p
  AND   vbrk~spart IN spart_p
  AND   vbrk~fkdat IN fkdat_p.

**** Inicio ** 24/01/2020 ****** Michael Chávez *** DESK940326
  SELECT bukrs party paval
    FROM t001z
    INTO TABLE gt_socs
    WHERE bukrs LIKE 'GA%'
    AND party = 'MX_RFC'.
**** Fin ** 24/01/2020 ****** Michael Chávez *** DESK940326
ENDFORM.                    " SELECCION
*&---------------------------------------------------------------------*
*&      Form  IMPRESION
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*  Imprime tabla interna con datos obtenidos de la selección
*----------------------------------------------------------------------*
FORM f_process_data.
  LOOP AT vbr.
    MOVE-CORRESPONDING vbr TO tab.
* busca texto con folio físico MGM 201903109
    CLEAR: t_textos, t_textos2.
    tdname = vbr-vbeln.
    PERFORM busca_textos USING: 'ZS03' 'S' tdname 'VBBK'.

    READ TABLE t_textos.
    MOVE t_textos-tdline+6(37) TO tab-folfis.
    clear t_textos-tdline.     " MGM 20230331
    clear t_textos.            " MGM 20230331
    CONCATENATE vbr-fkdat+6(2) vbr-fkdat+4(2) vbr-fkdat+0(4) into tab-fectim SEPARATED BY '/'.
*    MOVE t_textos-tdline+43(10) TO tab-fectim.
* Si la moneda de documento es diferente a mxn, lo convierte
* con el tipo de cambio
* Mary Guzmán 20230313
    tab-kzwi1 = tab-netwr + tab-kzwi6.
*    tab-kzwi1 = tab-kzwi1 / tab-ntgew.
    tab-kzwi1 = tab-kzwi1 * tab-kurrf.
    tab-kzwi2 = tab-kzwi2 * tab-kurrf. " mcz 24.01.20
    tab-kzwi6 = tab-kzwi6 * tab-kurrf.
    tab-netwr = tab-netwr * tab-kurrf.
* Mary Guzmán 20230313
*    IF vbr-waerk = 'MXN1'.
*      tab-kzwi1 = tab-kzwi1 / 100.
*      tab-kzwi2 = tab-kzwi2 / 100. " mcz 24.01.20
*      tab-kzwi6 = tab-kzwi6 / 100.
*      tab-netwr = tab-netwr / 100.
*    ENDIF.
    CONCATENATE tab-fktyp tab-vbtyp INTO tab-id.
* Modifica la naturaleza de las cantidades dependiendo del documento
    IF tab-fktyp EQ 'L' AND tab-vbtyp EQ 'O'.       " Devoluciones
      tab-fkimg = tab-fkimg * ( -1 ) .
      tab-kzwi1 = tab-kzwi1 * -1 .
      tab-kzwi2 = tab-kzwi2 * -1 ." mcz 24.01.20
      tab-kzwi6 = tab-kzwi6 * -1 .
      tab-netwr = tab-netwr * -1 .
      tab-obser = 'Devoluciones'.
    ELSEIF tab-fktyp EQ 'A' AND tab-vbtyp EQ 'O'.   " Notas de Crédito
      tab-fkimg = 0.
      tab-kzwi1 = tab-kzwi1 * ( -1 ) .
      tab-kzwi2 = tab-kzwi2 * -1." mcz 24.01.20
      tab-kzwi6 = tab-kzwi6 * -1.
      tab-netwr = tab-netwr * -1.
      tab-obser = 'Notas de crédito'.
    ELSEIF tab-fktyp EQ 'L' AND tab-vbtyp EQ 'N'.   " Anulaciones
      tab-fkimg = 0.
      tab-kzwi1 = tab-kzwi1 * ( -1 ) .
      tab-kzwi2 = tab-kzwi2 * -1 ." mcz 24.01.20
      tab-kzwi6 = tab-kzwi6 * -1.
      tab-netwr = tab-netwr * -1.
      tab-obser = 'Anulaciones'.
    ELSEIF tab-fktyp EQ 'A' AND tab-vbtyp EQ 'M'.    " Notas de Cargo
      tab-obser = 'Notas de cargo'.
    ENDIF.
    IF tab-fkimg = 0.
      tab-fkimg = 1.
    ENDIF.
    tab-kzwi1 = tab-kzwi1 / tab-fkimg.
    tab-kzwi2 = tab-kzwi2 / tab-fkimg." mcz 24.01.20
    tab-kzwi6 = tab-kzwi6 / tab-fkimg.
    IF tab-kzwi6 = 0.
      tab-lab = 'SI'.
    ELSE.
      tab-lab = 'NO'.
    ENDIF.

* Nombre del solicitante.
    SELECT SINGLE * FROM kna1
    WHERE kunnr EQ vbr-kunag.
    IF sy-subrc = 0.

      MOVE kna1-stcd1 TO tab-stcd1.
    ENDIF.

    select single * into @data(wa1) from DFKKBPTAXNUM
    where PARTNER = @vbr-kunag.

    IF sy-subrc = 0.
       move wa1-TAXNUM to tab-stcd1.
    ENDIF.
* Nombre del Material
    SELECT SINGLE * FROM makt
    WHERE spras EQ 'S'
      AND matnr EQ tab-matnr.
    IF sy-subrc = 0.
      tab-maktx = makt-maktx.
    ENDIF.
    SELECT SINGLE * FROM  mara
    WHERE  matnr  = tab-matnr.
    IF sy-subrc = 0.
      MOVE mara-NORMT TO tab-bismt.
    ENDIF.
    APPEND tab.
    CLEAR tab.
  ENDLOOP.

****copie este codigo de la impresión de mary para poder guardarlo en
* una tabla interna
  SORT tab BY vkorg spart id matnr .
  LOOP AT tab.
    AT NEW vkorg.
      SELECT SINGLE * FROM  tvkot
      WHERE  spras  = 'S'
      AND    vkorg  = tab-vkorg.

      IF sy-subrc = 0.
        "aqui agrego el nombre de la sociedad
        wa_layout-vtext = tvkot-vtext.
      ENDIF.
    ENDAT.
    CASE tab-vkorg.
      WHEN 'AZ01'.
        bukrs_p = 'GA05'.     " Huixtla
        wa_layout-line_color = 'C100'.
      when 'AZ02'.
        bukrs_p = 'GA07'.     " Santa Clara
        wa_layout-line_color = 'C200'.
      when 'AZ03'.
        bukrs_p = 'GA04'.     " San Pedro
        wa_layout-line_color = 'C300'.
      when 'AZ04'.
        bukrs_p = 'GA06'.     " Modelo
        wa_layout-line_color = 'C400'.
    endcase.
    select single * from  t001z
    where  bukrs  = bukrs_p
      and  party  = 'MX_RFC'.
*    write:/5

    wa_layout-rfc1 = t001z-paval+0(12).
    wa_layout-rfc2 = t001z-paval+0(12).
    wa_layout-stcd1 = tab-stcd1.
    "wa_layout-fkdat = tab-fkdat.     " Fecha

    concatenate tab-fkdat+6(2) '/' tab-fkdat+4(2) '/' tab-fkdat(4)
           into wa_layout-fkdat.

    "wa_layout-fectim = tab-fectim.    " Fecha de timbrado

*    concatenate tab-fectim+8(2) '/' tab-fectim+5(2) '/' tab-fectim(4)
*           into wa_layout-fectim.
"Se coloca la nueva dirección de localización del Folio Fiscal (zsd_cfdi_timbre)
"----Jaime Hernandez V.
    "wa_layout-folfis = tab-folfis.    " Folio Fiscal

    wa_layout-folfis = space.
    Select single UUID  from zsd_cfdi_timbre where vbeln = @tab-vbeln and ( stcd1 = @tab-stcd1 or stcd1 is INITIAL ) into @wa_layout-folfis  .

    wa_layout-fectim = space.
    "Fecha de timbrado. Por el momento se toma la de la factura, posterior se ajustara obteniendo del xml
    Select single ERDAT from zsd_cfdi_timbre where vbeln = @tab-vbeln and ( stcd1 = @tab-stcd1 or stcd1 is INITIAL ) into @wa_layout-fectim.
    "se obtiene la ruta del xml almacenado
    "Fecha de timbrado. Por el momento se toma la de la factura, posterior se ajustara obteniendo del xml
*    clear xml_file.
*    Select single ARCHIVOXML into xml_file from zsd_cfdi_timbre where vbeln = tab-vbeln and stcd1 = tab-stcd1.
*
*    IF sy-subrc eq 0.
*      REFRESH it_xmlsaT.
*
*      PERFORM transformar_xml TABLES it_xmlsat[] USING xml_file.
*    ENDIF.



    wa_layout-bismt = tab-bismt+0(8).
    wa_layout-maktx = tab-maktx.
    wa_layout-kzwi1 = tab-kzwi1.     " Importe de producto
    wa_layout-vrkme = tab-vrkme.     " Unidad de medida
    wa_layout-kzwi6 = tab-kzwi6.     " Importe de Flete
    wa_layout-vbeln = tab-vbeln.     " Número de Documento SAP
    wa_layout-fkimg = tab-fkimg.     " Cantidad
    wa_layout-netwr = tab-netwr.     " Importe Total
*************** 24 DE ENERO DE 2020
    wa_layout-imsf = tab-kzwi1 . " importe total sin flete
***** INICIO MODIFICACION MICHAEL CHAVEZ 27 ENERO 2020
* Se hace el calculo de valor del flete X cantidad facturada
    wa_layout-flete =  tab-kzwi6 * tab-fkimg. " impoorte de flete
***** FIN MODIFICACION MICHAEL CHAVEZ 27 ENERO 2020
*************** 24 DE ENERO DE 2020
    "codigo para identificar si es una venta de empresa relacionada 24.01.20
    read table gt_socs into wa_socs with key paval = wa_layout-stcd1.
    if sy-subrc = 0.
      wa_layout-ver = 'SI'.            "Venta empresa relacionada
      " 24 enero 2020
    else.
      wa_layout-ver = 'NO'.            "Venta empresa relacionada
      " 24 enero 2020
    endif.
    wa_layout-lab = tab-lab.         " Precio LAB ingenio

***** INICIO MODIFICACION MICHAEL CHAVEZ 27 ENERO 2020
* Se multiplica el valor neto por el importe del flete calculado
    "****** 24 enero 2020
    wa_layout-puli = tab-netwr - wa_layout-flete.
***** FIN MODIFICACION MICHAEL CHAVEZ 27 ENERO 2020
    wa_layout-ivli = tab-kzwi1.       "Importe venta lab ingenio
    "***** 24 enero 2020
    wa_layout-obser = tab-obser.
    append wa_layout to gt_layout.
  endloop.
*************** fin de copia de codigo de Mary
endform.                    " Detalles
*&---------------------------------------------------------------------*
*&      Form  IMPRESION
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*  Imprime tabla interna con datos obtenidos de la selección
*----------------------------------------------------------------------*
form f_display_data.

  wa_fieldcat-fieldname   = 'VTEXT'.
  wa_fieldcat-seltext_m   = 'INGENIO'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'RFC1'.
  wa_fieldcat-seltext_m   = 'RFC MARCA INGENIO'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'RFC2'.
  wa_fieldcat-seltext_m   = 'RFC SOCIEDAD EMISOR'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'STCD1'.
  wa_fieldcat-seltext_m   = 'RFC RECEPTOR'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 10.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'FKDAT'.
  wa_fieldcat-seltext_m   = 'FECHA FACTURA'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'FECTIM'.
  wa_fieldcat-seltext_m   = 'FECHA TIMBRADO'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'FOLFIS'.
  wa_fieldcat-seltext_m   = 'FOLIO FISCAL'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'BISMT'.
  wa_fieldcat-seltext_m   = 'ID MAT. SAT'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'MAKTX'.
  wa_fieldcat-seltext_m   = 'DESCRIPCIÓN MAT.'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'KZWI1'.
  wa_fieldcat-seltext_m   = 'PRECIO PRODUCTO'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'VRKME'.
  wa_fieldcat-seltext_m   = 'UM VENTA'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  wa_fieldcat-edit_mask = '==CUNIT'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.


  wa_fieldcat-fieldname   = 'KZWI6'.
  wa_fieldcat-seltext_m   = 'IMPORTE FLETE'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'VBELN'.
  wa_fieldcat-seltext_m   = 'FACTURA SAP'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'C600'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'FKIMG'.
  wa_fieldcat-seltext_m   = 'CTDAD. FACTURADA'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'MAKTX'.
  wa_fieldcat-seltext_m   = 'DESCRIPCIÓN MAT.'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

  wa_fieldcat-fieldname   = 'NETWR'.
  wa_fieldcat-seltext_m   = 'VALOR NETO'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.


************************* FIN 24 DE ENERO 2020

* Inicio Michael Chavez Zarate usuario solicita retirar col 27.01.2020
*  wa_fieldcat-fieldname   = 'IMSF'.
*  wa_fieldcat-seltext_m   = 'IMPORTE TOTAL S/FLETE'.
*  wa_fieldcat-col_pos     = 0.
*  wa_fieldcat-outputlen   = 15.
*  wa_fieldcat-emphasize   = 'X'.
*  wa_fieldcat-key         = 'X'.
*  append wa_fieldcat to gt_fieldcat.
*  clear  wa_fieldcat.
* Fin Michael Chavez Zarate usuario solicita retirar col 27.01.2020

  wa_fieldcat-fieldname   = 'FLETE'.
  wa_fieldcat-seltext_m   = 'COSTO FLETE/TON'. " NOMBRE 27.ene.2020
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.
************************* FIN 24 DE ENERO 2020

************************* FIN 24 DE ENERO 2020
  wa_fieldcat-fieldname   = 'VER'.
  wa_fieldcat-seltext_m   = 'VENTA EMP. RELACIONADA'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.
************************* FIN 24 DE ENERO 2020

  wa_fieldcat-fieldname   = 'LAB'.
  wa_fieldcat-seltext_m   = 'PRECIO LAB INGENIO'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

************************* FIN 24 DE ENERO 2020

  wa_fieldcat-fieldname   = 'PULI'.
  wa_fieldcat-seltext_m   = 'PRECIO UNI. LAB INGENIO'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.
*
*
*  wa_fieldcat-fieldname   = 'IVLI'.
*  wa_fieldcat-seltext_m   = 'IMPORTE VTA. LAB INGENIO'.
*  wa_fieldcat-col_pos     = 0.
*  wa_fieldcat-outputlen   = 15.
*  wa_fieldcat-emphasize   = 'X'.
*  wa_fieldcat-key         = 'X'.
*  append wa_fieldcat to gt_fieldcat.
*  clear  wa_fieldcat.
************************* FIN 24 DE ENERO 2020

  wa_fieldcat-fieldname   = 'OBSER'.
  wa_fieldcat-seltext_m   = 'OBSERVACIONES'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  append wa_fieldcat to gt_fieldcat.
  clear  wa_fieldcat.

* Crea Formato de Salida de ALV.
  "wa_format-INFO_FIELDNAME =      'LINE_COLOR'.
  wa_format-no_colhead          = space.   "Partidas
  wa_format-zebra               = 'X'.     "Patron de rayas
  wa_format-no_vline            = space.   "Columnas separadas espacio
  wa_format-no_hline            = space.   "Filas separadas espacio
  "wa_format-no_subtotals        = space.   "Subtotales no posibles
  wa_format-colwidth_optimize   = 'X'.     "Tamaño optimizado columna
  wa_format-totals_before_items = space.   "Despliega los totales
  "wa_format-coltab_fieldname    = 'VBELN'. "Color

************
* Procesa ALV.
  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_bypassing_buffer      = 'X'
      i_callback_program      = 'ZRSD0026_DA_CONADESUCAV2'
"     i_callback_pf_status_set = 'PF_STATUS'
      i_callback_top_of_page  = 'F_TOP_OF_PAGE'
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = wa_format
"     i_structure_name        = 'XXX'
"     it_sort                 = lt_sort
"     it_event_exit           = lt_event_exit
      it_fieldcat             = gt_fieldcat[]
      i_save                  = 'X'
    tables
      t_outtab                = gt_layout
    exceptions
      program_error           = 1
      others                  = 2.

endform.

form f_top_of_page.

  refresh gt_header.
  clear wa_header.

* Tipo H para escribir con la fuente grande
  wa_header-typ  = 'H'.
  wa_header-info = 'Información de las ventas de azúcar de los ingenios'.
  "texto que no pudo añadirse
  "'de los ingenios, con base en los Comprobantes Fiscales Digitales'
  "'por Internet (CFDI) de ingresos.' INTO

  "los ingenios, 6con base en los Comprobantes Fiscales Digitales por
  "Internet (CFDI)  de ingresos.'.
  append wa_header to gt_header.
  clear wa_header.

* Tipo S para indicar parámetro clave y su valor (fecha)
  wa_header-typ  = 'S'. "Selection

  "traemos fechas de reporte
  select single * from  t247
  where  spras  = 'S'
  and    mnr    = fkdat_p+7(2).

  "FKDAT_P+15(2)

  "concateno la fecha del reporte
  concatenate fkdat_p+9(2) 'de' t247-ltx 'de' fkdat_p+3(4)
           "'al' fkdat_p+17(2) 'de' t247-ltx 'de' fkdat_p+11(4)
           into wa_header-info
           separated by space.

  select single * from  t247
  where  spras  = 'S'
  and    mnr    = fkdat_p+15(2).

  concatenate wa_header-info 'al' fkdat_p+17(2) 'de' t247-ltx 'de'
fkdat_p+11(4)
          into wa_header-info
          separated by space.

  "wa_header-key = 'fecha de ejecucion de reporte: '.
  "CONCATENATE  sy-datum+6(2) '.'
  "             sy-datum+4(2) '.'
  "             sy-datum(4) INTO wa_header-info.   "Fecha de hoy
  append wa_header to gt_header.
  clear: wa_header.

* Tipo A para escribir en cursiva
  wa_header-typ  = 'A'. "Action
  wa_header-info = 'Grupo Porres S.A. de C.V.'.
  append wa_header to gt_header.
  clear: wa_header.

* Cabecera y Logo.
  call function 'REUSE_ALV_COMMENTARY_WRITE'
    exporting
      it_list_commentary = gt_header
      i_logo             = 'ZGPORRES_LOGO'.

endform.                    "F_TOP_OF_PAGE

*----------------------------------------------------
* FORM user_command
*----------------------------------------------------
form user_command using r_ucomm type sy-ucomm
rs_selfield type slis_selfield.

  rs_selfield-refresh = 'X'.

  case r_ucomm.
    when '&IC1'.

      if rs_selfield-fieldname = 'VBELN'.
        read table gt_layout into wa_layout index rs_selfield-tabindex.
        set parameter id: 'VF' field wa_layout-vbeln.
        call transaction 'VF03' and skip first screen.
      endif.
  endcase.


endform.
*&---------------------------------------------------------------------*
*&      Form  BUSCA_TEXTOS
*&---------------------------------------------------------------------*
*       MGM 20190319
*----------------------------------------------------------------------*
form busca_textos using id     like thead-tdid
                        lang   like thead-tdspras
                        name   like thead-tdname
                        object like thead-tdobject.
* Busca Nombre de Chofer y placa en textos de cabecera
  call function 'READ_TEXT'
    exporting
      id                      = id
      language                = lang
      name                    = name
      object                  = object
    tables
      lines                   = t_textos
    exceptions
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      others                  = 8.
  if sy-subrc eq 0.
    append lines of t_textos to t_textos2.
  endif.
endform.                               " BUSCA_TEXTOS

FORM transformar_xml  TABLES gt_xml_data STRUCTURE  smum_xmltb
                      USING   ruta_xml  TYPE zaxnare_el034.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Data Declaration
*&---------------------------------------------------------------------*
  DATA: gcl_xml       TYPE REF TO cl_xml_document.
  DATA: gv_subrc      TYPE sy-subrc.
  DATA: gv_xml_string TYPE xstring.
  DATA: gv_size       TYPE sytabix.
  " DATA: gt_xml_data   TYPE TABLE OF smum_xmltb.
  DATA: gwa_xml_data  TYPE smum_xmltb.
  DATA: gt_return     TYPE TABLE OF bapiret2.
  DATA: gv_tabix      TYPE sytabix.

  data: http_client type ref to if_http_client .
  data: xml_out type string  .


  DATA lv_filename TYPE string.
  REFRESH gt_xml_data.
  CREATE OBJECT gcl_xml.
  lv_filename = ruta_xml.

"se consulta por URL
call method cl_http_client=>create_by_url
    exporting
      url           = lv_filename
    importing
      client        = http_client.

http_client->send( ).
  http_client->receive( ).
  clear xml_out .
  xml_out = http_client->response->get_cdata( ).
  http_client->close( ).

"-----------------------------------------------
*  CALL METHOD gcl_xml->import_from_file
*    EXPORTING
*      filename = lv_filename
*    RECEIVING
*      retcode  = gv_subrc.
*

 " IF gv_subrc = 0.
    CALL METHOD gcl_xml->render_2_string
      IMPORTING
        retcode = gv_subrc
        stream  = xml_out "gv_xml_string
        size    = gv_size.
    IF gv_subrc = 0.
* Convert XML to internal table
      CALL FUNCTION 'SMUM_XML_PARSE'
        EXPORTING
          xml_input = gv_xml_string
        TABLES
          xml_table = gt_xml_data
          return    = gt_return.
    ENDIF.
  "ENDIF.

*  CALL TRANSFORMATION ('Comprobante') "zxml_sat_ts
*  SOURCE XML xml_sat
*  RESULT tab = it_xmlsat.

ENDFORM.
