*&---------------------------------------------------------------------*
*& Include          ZMM_APP_PRINT_RESB_FUN
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

* Cabecera de reserva
    SELECT a~ktext, t~butxt, r~rsnum, t~bukrs, r~rsdat,
        r~kostl, r~aufnr, a~vaplz, a~ernam, a~aenam, f~equnr,
        e~eqktx, i~tplnr, x~pltxt,b~matnr, b~rspos, b~bdmng,
        b~enmng,b~meins,b~wempf, b~sgtxt, d~lgpbe, m~maktx, w~verpr,
        b~bdmng - b~enmng AS pendi, CASE WHEN b~enmng EQ 0 THEN 'IMPRESION' ELSE 'REIMPRESION' END AS estatus
      INTO TABLE @it_salida
      FROM rkpf AS r
      INNER JOIN resb AS b ON b~rsnum = r~rsnum AND xloek NE 'X'
      INNER JOIN makt AS m ON m~matnr = b~matnr
      INNER JOIN mbew AS w ON w~matnr = b~matnr AND w~bwkey = b~werks
      INNER JOIN mard AS d ON d~matnr = b~matnr AND d~werks = b~werks AND d~lgort = b~lgort
      INNER JOIN t001 AS t ON t~bukrs = r~parbu
      LEFT JOIN aufk AS a ON a~aufnr = r~aufnr
      LEFT JOIN afih AS f ON f~aufnr = r~aufnr
      LEFT JOIN eqkt AS e ON e~equnr = f~equnr
      LEFT JOIN iloa AS i ON i~iloan = f~iloan
      LEFT JOIN iflotx AS x ON x~tplnr = i~tplnr
      WHERE r~rsnum EQ @rsnum_p
      AND b~rspos IN @rspos_p.

ENDFORM.

FORM imprime_reserva.
  LOOP AT it_salida into data(wa_salida).
    NEW-PAGE PRINT ON PARAMETERS params NO DIALOG.
    PRINT-CONTROL SIZE 2 FONT 10.
* Datos de Cabecera
    SKIP TO LINE 3.
    WRITE:/28 wa_salida-butxt.
    SKIP.
    WRITE:/30 'ALMACEN DE MATERIALES'.
    WRITE:/30 'DOCUMENTO DE RESERVA'.
    WRITE:/35 wa_salida-estatus."estatus.
    SKIP.
    WRITE:/5 'FOLIO: ',
           13 wa_salida-rsnum,
           56 'FECHA: ',
           63 wa_salida-rsdat.
    SKIP.
    WRITE:/5 'ORDEN: ',
           13 wa_salida-aufnr, wa_salida-ktext.
    WRITE:/5 'UBIC. TECNICA: ', wa_salida-tplnr, wa_salida-pltxt.
    WRITE:/5 'EQUIPO: ', wa_salida-equnr, wa_salida-eqktx.
    ULINE.
    WRITE:/2 'CLAVE',
          11 'MATERIAL',
          55 'UBICACION'.
    WRITE:/32 'CANT PEND',
          42 'UMB',
          56 'P UNIT.',
          73 'IMPORTE'.
    ULINE.
    SKIP.
    exit.
  ENDLOOP.
  LOOP AT it_salida into data(wa_salida1).
    importe = wa_salida1-bdmng * wa_salida1-verpr.
    total = total + importe.
    WRITE:/2 wa_salida1-matnr,
          10 wa_salida1-maktx,
          55 wa_salida1-lgpbe.
    WRITE:/32 wa_salida1-pendi DECIMALS 3  LEFT-JUSTIFIED,
*    WRITE:/32 tabp-bdmng DECIMALS 3  LEFT-JUSTIFIED,
          42 wa_salida1-meins,
          46 wa_salida1-verpr DECIMALS 2,
          65 importe DECIMALS 2.
    SKIP.
  ENDLOOP.
  SKIP.
  ULINE.
  WRITE:/70 total DECIMALS 2.
  SKIP 4.
  WRITE:/33 'A U T O R I Z A'.
  SKIP 4.
  WRITE:/20 '________________________________________'.
*  WRITE:/25 resb-sgtxt+0(40). WEMPF
  WRITE:/25 wa_salida1-wempf.
  IF wa_salida1-sgtxt = ' '.
    WRITE:/25 'RESERVA GENERADA POR MODULO PM'.
  ENDIF.
  SKIP 2.
  WRITE:/ wa_salida1-ernam, '/', wa_salida1-aenam, '/', sy-uname.
ENDFORM.                    "IMPRIME_RESERVA
