***********************************************************************
*        Schecknachweisreport                                         *
*        Informe de la prueba del cheque                              *
***********************************************************************
REPORT zrfchkn00.

INCLUDE zrfchkn00_top.
INCLUDE zrfchkn00_fun.
************************************************************************
INITIALIZATION.
  REFRESH tab_laufk.
  tab_laufk-laufk = 'W'.
  tab_laufk-sign  = 'E'.
  APPEND tab_laufk.

START-OF-SELECTION.

PERFORM get_data.
IF it_zpayr[] is not INITIAL.
  PERFORM process_data.
  PERFORM create_fieldcat.
  PERFORM show_alv.
else.
  MESSAGE 'No hay Datos para Mostrar...' type 'S'.
ENDIF.



  "SELECT SINGLE * FROM t005 WHERE land1 EQ t001-land1.
* Selección de los datos


 " CLEAR postab.


*    IF PAR_EPOS NE SPACE AND PAYR-VOIDR EQ SPACE.
*      REFRESH: POSTAB.
*      CALL FUNCTION 'GET_INVOICE_DOCUMENT_NUMBERS'
*        EXPORTING
*          I_XBUKR   = PAYR-XBUKR
*          I_ZBUKR   = PAYR-ZBUKR
*          I_VBLNR   = PAYR-VBLNR
*          I_GJAHR   = PAYR-GJAHR
*        TABLES
*          T_INVOICE = POSTAB.
*      LOOP AT POSTAB.
*        IF POSTAB-XHELL EQ SPACE.
*          EXTRACT RECHNUNG.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
* ENDSELECT.




 " PERFORM transferencias.
*  IF sy-batch NE space.
*    "MESSAGE S620.
*  ENDIF.


*---------------------------------------------------------------------*
* FORM WRITE_ZAHLUNG                                                  *
*---------------------------------------------------------------------*
* Ausgabe einer Zeile mit Scheckinformationen                         *
* Salida de una linea con la información del cheque                   *
*---------------------------------------------------------------------*



FORM transferencias.
  DATA:
    fecha_t TYPE d,
    augbl_p LIKE bsak-augbl,
    iva     LIKE bsak-wrbtr.

* Lectura de las transferencias
  SELECT * FROM  bsak
  WHERE bukrs = par_zbuk
*where bukrs = bset-bukrs
  "and budat in sel_zald
  AND gjahr = p_gjahr
*and MWSKZ BETWEEN 'V0' AND 'V2'
  AND ( ( xblnr = 'TRANSFERENCIA' OR sgtxt = 'transferencia' ) OR ( xblnr = 'transferencia' OR sgtxt = 'TRANSFERENCIA' ) ).
    IF sy-subrc = 0.

*IF BSAK-AUGBL+3(1) = '3'.

      fecha_t = bsak-augdt.
      augbl_p = bsak-augbl.

      SELECT SINGLE * FROM bseg
      WHERE bukrs = bsak-bukrs
      AND belnr = bsak-belnr
      AND gjahr = bsak-gjahr
      AND bschl = '25'.
      IF sy-subrc = 0.

        SELECT SINGLE * FROM lfa1
        WHERE lifnr = bsak-lifnr.
        IF sy-subrc = 0.

          WRITE:
           /    sy-vline,
          200 sy-vline.


          FORMAT COLOR 7 INTENSIFIED OFF.
          WRITE:
           /    sy-vline,
*      /    SY-VLINE,
           space,
           'Transferencias:', 200 sy-vline,
           / sy-vline,
           space,
           space,
           space,
           space,
           space,
           space,
           space,
           bsak-belnr,
           bsak-budat,
           bsak-waers,
           bseg-wrbtr,
           lfa1-name1,    " Escribe el RFC del
           lfa1-stcd1,    " acreedor por documento: Modificado 20/09/2007
           bsak-bukrs,
           bsak-xblnr,
           space,
           space.

          WRITE:
             200 sy-vline.

          suma_importe = 0.
          suma_base = 0.

* Lectura de las Provisiones
          SELECT * FROM  bsak
          WHERE bukrs = par_zbuk
          AND augbl = bseg-belnr
          AND augdt IN sel_zald
          AND qsskz = '  '
          AND gjahr = p_gjahr
*and mwsk1 between 'V0' and 'V2'
          AND blart IN ('RE','ZP','KR','KZ').
*if bsak-augbl+3(1) = '3'.


            SELECT SINGLE * FROM lfa1
            WHERE lifnr = bsak-lifnr.
            IF sy-subrc = 0.

              FORMAT COLOR 2 INTENSIFIED OFF.
              WRITE:
                /    sy-vline,
*      'Provisiones:', /
                bsak-bukrs,  "Sociedad
                bsak-gsber,  "Division
                bsak-xblnr,  "Referencia
                bsak-belnr,  "No. de Documento
                bsak-buzei,  "No. de Apunte Contable en el Docto.
                bsak-budat,  "Fecha de Documento
                bsak-waers.  "Moneda

*      bset-wrshb,

              IF bsak-mwsk1 = 'V0' OR bsak-mwsk1 = ' '.
                WRITE:
                  bsak-wrbtr,  "Importe Bruto
                  bsak-wrbtr,  "Base
                  space,
                  110 bsak-mwsk1,  "Identificador de Impuesto
                  125 lfa1-name1,  " Escribe el RFC del
                  lfa1-stcd1.      " acreedor por documento: Modificado 20/09/2007

                suma_importe = suma_importe + bsak-wrbtr.
                suma_base = suma_base + bsak-wrbtr.

              ELSEIF bsak-mwsk1 = 'V4'. " Actualizacion V4 11% ORG 12.02.2010
                iva = bsak-wrbtr * '0.11'.
                WRITE:
                     bsak-wrbtr,
                     bsak-wrbtr,
                     iva,
                     110 bsak-mwsk1,
                     125 lfa1-name1, " Escribe el RFC del
                     lfa1-stcd1.     " acreedor por documento: Modificado 20/09/2007
                suma_importe = suma_importe + bsak-wrbtr.
                suma_base = suma_base + bsak-wrbtr.

              ELSEIF bsak-mwsk1 = 'V3'. " Actualizacion V3 16% ORG 12.02.2010
                iva = bsak-wrbtr * '0.16'.
                WRITE:
                     bsak-wrbtr,
                     bsak-wrbtr ,
                     iva,
                     110 bsak-mwsk1,
                     125 lfa1-name1, " Escribe el RFC del
                     lfa1-stcd1.     " acreedor por documento: Modificado 20/09/2007
                suma_importe = suma_importe + bsak-wrbtr.
                suma_base = suma_base + bsak-wrbtr.
              ENDIF.

              WRITE:
               200 sy-vline,
                space.

              WRITE:
              /    sy-vline,
              200 sy-vline.
            ENDIF.
*endif.
          ENDSELECT.

          suma_importe = suma_importe - bseg-wrbtr.
          suma_importeg = suma_importeg + suma_importe.
          suma_base = suma_base - bseg-wrbtr.
          FORMAT COLOR 3 INTENSIFIED OFF.
          WRITE:
            / sy-vline,
            50 'Total: ',
            60 suma_importe, " Suma Totales de Importe - Provisiones
            79 suma_base,    " Suma Totales Base - Provisiones
          200 sy-vline.

        ENDIF.
      ENDIF.
*endif.
    ENDIF.
  ENDSELECT.
  suma_general = suma_importeg + g_tot_bas. " Suma General Cheques y Transferencias
  FORMAT COLOR 3 INTENSIFIED ON.
  WRITE:
     / sy-vline, 200 sy-vline,
     / sy-vline,
     76 suma_general,
     93 g_tot_iva,
     110 g_tot_abzug,

  200 sy-vline.

  suma_general = 0.

ENDFORM.
