*&---------------------------------------------------------------------*
*& Include zsd_re_facfolfis_fun
*&---------------------------------------------------------------------*

FORM create_fieldcat.
  CLEAR  wa_fieldcat.
  wa_fieldcat-fieldname = 'VTEXT'.
  wa_fieldcat-seltext_m = 'Org. Vtas'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'SPART'.
  wa_fieldcat-seltext_m = 'Sector'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-seltext_m = 'Material'.
  wa_fieldcat-datatype = 'NUMC'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'MAKTX'.
  wa_fieldcat-seltext_m = 'Descrip. Material'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'BZTXT'.
  wa_fieldcat-seltext_m = 'Zona Vtas.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'KUNNR'.
  wa_fieldcat-seltext_m = 'Num. Dest.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'NAMEWE'.
  wa_fieldcat-seltext_m = 'Dest. Mcia.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'KUNAG'.
  wa_fieldcat-seltext_m = 'Solicitante'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-seltext_m = 'Nom. Cliente'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.


  wa_fieldcat-fieldname = 'STCD1'.
  wa_fieldcat-seltext_m = 'R.F.C.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'FKDAT'.
  wa_fieldcat-seltext_m = 'Fec. Fact.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'VBELN'.
  wa_fieldcat-seltext_m = 'Fact. SAP'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'FKIMG'.
  wa_fieldcat-seltext_m = 'Cant. Fact.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'VRKME'.
  wa_fieldcat-seltext_m = 'U.M. Vta.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'KZWI1'.
  wa_fieldcat-seltext_m = 'Producto'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'KZWI6'.
  wa_fieldcat-seltext_m = 'Precio Flete'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.


  wa_fieldcat-fieldname = 'NETWR'.
  wa_fieldcat-seltext_m = 'Valor Neto Fact.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'WAERK'.
  wa_fieldcat-seltext_m = 'Moneda Fact.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'KURRF'.
  wa_fieldcat-seltext_m = 'Tipo Cambio'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'VTWEG'.
  wa_fieldcat-seltext_m = 'C. Dis.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'FOLFIS'.
  wa_fieldcat-seltext_m = 'Folio Fiscal'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'AUBEL'.
  wa_fieldcat-seltext_m = 'Documento de Ventas'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'BELNR'.
  wa_fieldcat-seltext_m = 'Factura'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'TXTINTERNOS'.
  wa_fieldcat-seltext_m = 'Textos Internos'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'NTGEW'.
  wa_fieldcat-seltext_m = 'Ctd. Fact. UMB'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'GEWEI'.
  wa_fieldcat-seltext_m = 'U.M. Cant. Fact.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR  wa_fieldcat.


ENDFORM.

FORM seleccion .

  SELECT vbrk~vkorg, tvkot~vtext, vbrk~spart, vbrk~fkdat, vbrk~vbeln,
         vbrk~kunag, kna1~name1, kna1~stcd1, vbrk~knumv, vbrk~bzirk, t171t~bztxt,
         vbrk~vtweg, vbrk~waerk,
         vbrk~kurrf, vbrk~fktyp, vbrk~vbtyp, vbrk~fksto,
         vbrp~fkimg, vbrp~vrkme, vbrp~matnr, makt~maktx,
         CASE WHEN vbrp~kzwi1 EQ 0 THEN vbrp~kzwi2 ELSE vbrp~kzwi1 END AS kzwi1,
         vbrp~kzwi6, vbrp~netwr, vbrp~aubel, vbrk~belnr,vbrp~ntgew, vbrp~gewei, z~uuid
  FROM  vbrk INNER JOIN vbrp
  ON  vbrk~vbeln = vbrp~vbeln
  INNER JOIN kna1
  ON kna1~kunnr = vbrk~kunag
  INNER JOIN t171t
  ON t171t~bzirk = vbrk~bzirk
  INNER JOIN makt
  ON makt~matnr = vbrp~matnr
  INNER JOIN tvkot
  ON tvkot~vkorg = vbrk~vkorg
  LEFT JOIN zsd_cfdi_timbre AS z ON z~bukrs = vbrk~bukrs AND z~vbeln = vbrk~vbeln
  INTO CORRESPONDING FIELDS OF TABLE @vbr
  WHERE vbrk~vkorg IN @vkorg_p
  AND   vbrk~vtweg IN @vtweg
  AND   vbrk~spart IN @spart_p
  AND   vbrk~fkdat IN @fkdat_p.

ENDFORM.                    " SELECCION

FORM detalles.
  LOOP AT vbr.
    MOVE-CORRESPONDING vbr TO tab.
* busca texto con folio físico MGM 201903109
    CLEAR: t_textos, t_textos2.
    tdname = vbr-vbeln.
    PERFORM busca_textos USING: 'ZS03' 'S' tdname 'VBBK'.
    PERFORM busca_textos USING: 'ZS12' 'S' tdname 'VBBK'.
* Si la moneda de documento es diferente a mxn, lo convierte
* con el tipo de cambio
    tab-kzwi1 = tab-kzwi1 * tab-kurrf.
    tab-kzwi6 = tab-kzwi6 * tab-kurrf.
    "tab-netwr = tab-netwr * tab-kurrf.
    IF vbr-waerk = 'MXN1'.
      tab-kzwi1 = tab-kzwi1 / 100.
      tab-kzwi6 = tab-kzwi6 / 100.
      tab-netwr = tab-netwr / 100.
    ENDIF.
    CONCATENATE tab-fktyp tab-vbtyp INTO tab-id.
* Modifica la naturaleza de las cantidades dependiendo del documento
    IF tab-fktyp EQ 'L' AND tab-vbtyp EQ 'O'.       " Devoluciones
      tab-fkimg = tab-fkimg * ( -1 ) .
      tab-ntgew = tab-ntgew * ( -1 ) .
      tab-kzwi1 = tab-kzwi1 * -1 .
      tab-kzwi6 = tab-kzwi6 * -1 .
      tab-netwr = tab-netwr * -1 .
      "operacion
      tab-kzwi1 = tab-kzwi1 + tab-kzwi6.
    ELSEIF tab-fktyp EQ 'A' AND tab-vbtyp EQ 'O'.   " Notas de Crédito
      tab-fkimg = tab-fkimg * ( -1 ) . "0. 09/06/2023 Mostrar el valor negativo de la NC.
      tab-ntgew = tab-ntgew * ( -1 ) .
      tab-kzwi1 = tab-kzwi1 * ( -1 ) .
      tab-kzwi6 = tab-kzwi6 * -1.
      tab-netwr = tab-netwr * -1.
      "operacion
      tab-kzwi1 = tab-kzwi1 + tab-kzwi6.
    ELSEIF tab-fktyp EQ 'L' AND tab-vbtyp EQ 'N'.   " Anulaciones
      tab-fkimg = tab-fkimg * ( -1 ) . "0. 09/06/2023 Mostrar el valor negativo de la anulación.
      tab-ntgew = tab-ntgew * ( -1 ) .
      tab-kzwi1 = tab-kzwi1 * ( -1 ) .
      tab-kzwi6 = tab-kzwi6 * -1.
      tab-netwr = tab-netwr * -1.
      "operacion
      tab-kzwi1 = tab-kzwi1 + tab-kzwi6.
    ELSEIF tab-fktyp EQ 'A' AND tab-vbtyp EQ 'M'.    " Notas de Cargo
*      tab-fkimg = 0.
*    else. "cuando no hay cambio                        Facturas
    ENDIF.

    IF tab-kzwi1 GT 0.
      tab-kzwi1 = tab-kzwi1 + tab-kzwi6.

    ENDIF.
    """""actualizaión del UUID desde tabla ZSD_CFDI_TIMBRE.
    tab-folfis = vbr-uuid.
* Destinatario de mercancías
    SELECT SINGLE * FROM  vbpa
    WHERE vbeln EQ vbr-vbeln
    AND   parvw EQ 'WE'.
    IF sy-subrc = 0.
      MOVE vbpa-kunnr TO tab-kunnr.
    ENDIF.

    SELECT SINGLE * FROM kna1
    WHERE kunnr EQ vbpa-kunnr.
    IF sy-subrc = 0.
      MOVE kna1-name1 TO tab-namewe.
    ENDIF.
    APPEND tab.
  ENDLOOP.
ENDFORM.                    " Detalles

FORM busca_textos USING id     LIKE thead-tdid
                        lang   LIKE thead-tdspras
                        name   LIKE thead-tdname
                        object LIKE thead-tdobject.
* Busca Nombre de Chofer y placa en textos de cabecera
  REFRESH t_textos.
  CLEAR t_textos-tdline.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = id
      language                = lang
      name                    = name
      object                  = object
    TABLES
      lines                   = t_textos
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc EQ 0.
    APPEND LINES OF t_textos TO t_textos2.
  ENDIF.
  READ TABLE t_textos.

  IF id EQ 'ZS03'.
    MOVE t_textos-tdline+6(37) TO tab-folfis.
  ELSEIF id EQ 'ZS12'.
    MOVE t_textos-tdline TO tab-txtinternos.
  ENDIF.

ENDFORM.                               " BUSCA_TEXTOS

FORM impresion .

  SORT tab BY vkorg spart id matnr bzirk kunnr.
  lf_layout-zebra = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat
      i_save             = 'A'
    TABLES
      t_outtab           = tab
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
ENDFORM.                    " IMPRESION
