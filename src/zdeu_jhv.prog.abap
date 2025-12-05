*&---------------------------------------------------------------------*
*& Report zdeu_jhv
*&---------------------------------------------------------------------*
*&Migrado por Jaime Hernández Velásquez 03072024
*&---------------------------------------------------------------------*
REPORT zdeu_jhv NO STANDARD PAGE HEADING LINE-SIZE 120 LINE-COUNT 65.
************************************************************************
**Descripcion.- Deudores..
**Autor.- Sandra Castillo Espinoza.
**Fecha.- Agosto-Septiembre 1999.
**Empresa.- Grupo Pecuario San Antonio.
***********************************************************************


TABLES:bsid,kna1,zvkna1,knc1, knkk.

DATA: suma  LIKE bsid-dmbtr,
      sumat LIKE bsid-dmbtr,
      cargo LIKE bsid-dmbtr,
      abono LIKE bsid-dmbtr,
      gjahr LIKE bsid-gjahr,
      total LIKE bsik-dmbtr.

DATA: BEGIN OF tabla OCCURS 0,
        kunnr LIKE bsid-kunnr,
        shkzg LIKE bsid-shkzg,
        dmbtr LIKE bsid-dmbtr,
        name1 LIKE kna1-name1,
        ort01 LIKE kna1-ort01,
        cargo LIKE bsid-dmbtr,
        abono LIKE bsid-dmbtr,
        suma  LIKE  bsid-dmbtr,
      END OF tabla.

DATA: BEGIN OF tabla1 OCCURS 0,
        kunnr LIKE bsid-kunnr,
        name1 LIKE kna1-name1,
        ort01 LIKE kna1-ort01,
        shkzg LIKE bsid-shkzg,
        dmbtr LIKE bsid-dmbtr,
        waers LIKE bsid-waers,
        budat LIKE bsid-budat,
        suma  LIKE bsid-dmbtr,
      END OF tabla1.

DATA: BEGIN OF tab_bsid OCCURS 0,
        belnr LIKE bsid-belnr,
        budat LIKE bsid-budat,
        dmbtr LIKE bsid-dmbtr,
        shkzg LIKE bsid-shkzg,
        sgtxt LIKE bsid-sgtxt,
        waers LIKE bsid-waers,
        blart LIKE bsid-blart,
        bschl LIKE bsid-bschl,
      END OF tab_bsid.

DATA: index  LIKE sy-tabix,
      pesos  LIKE bsid-dmbtr,
      pesos1 LIKE bsid-dmbtr,
      dolar  LIKE bsid-wrbtr,
      dolar1 LIKE bsid-wrbtr,
      kunnr1 LIKE bsid-kunnr,
      kunnr2 LIKE bsid-kunnr,
      "DEUDO(10) TYPE C,
      deudo  TYPE bsid-kunnr,
      deudo1 LIKE bsid-kunnr,
      no(2)  TYPE n,
      i(2)   TYPE n.
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:kunnr FOR kna1-kunnr.
  PARAMETERS:bukrs LIKE bsid-bukrs,
             ktokd LIKE kna1-ktokd.
  PARAMETERS: boton AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK block1.

START-OF-SELECTION.

*----------------PROCESO PARA OPCION POR DEUDOR------------------------*
  IF  kunnr <> space.


    IF boton = 'X'.            "DEUDORES CON ANTICIPO SOLAMENTE

      SELECT        * FROM  bsid
             WHERE  bukrs  = bukrs
             AND    kunnr  IN kunnr.

        MOVE bsid-kunnr TO tabla-kunnr.
        COLLECT tabla.

      ENDSELECT.

      LOOP AT tabla.

        SELECT        * FROM  bsid
               WHERE  bukrs  = bukrs
               AND    kunnr  = tabla-kunnr.
          IF bsid-umskz <> space.
            IF bsid-shkzg = 'S'.
              cargo = cargo + bsid-dmbtr.
            ELSE.
              abono = abono + bsid-dmbtr.
            ENDIF.
            IF bsid-waers = 'USD'.
              dolar1 = dolar1 + bsid-wrbtr.
            ENDIF.
          ENDIF.
        ENDSELECT.
        MOVE cargo TO tabla-cargo.
        MOVE abono TO tabla-abono.
        MODIFY tabla.
        CLEAR:cargo,
              abono.
      ENDLOOP.


      LOOP AT tabla.

        SELECT SINGLE  * FROM zvkna1
               WHERE  kunnr  = tabla-kunnr.
        MOVE zvkna1-kunnr TO tabla-kunnr.
        MOVE zvkna1-name1 TO tabla-name1.
        MOVE zvkna1-ort01 TO tabla-ort01.
        MODIFY tabla.
      ENDLOOP.

      MOVE sy-datum+0(4) TO gjahr.


      LOOP AT tabla.
        CLEAR suma.
        AT END OF kunnr.

          SELECT SINGLE  * FROM  knkk
                 WHERE  kunnr  = tabla-kunnr.
          IF sy-subrc EQ 0.
          ENDIF.


          FORMAT COLOR 3 INTENSIFIED OFF.

          index = sy-tabix.
          READ TABLE tabla INDEX index.

          suma = tabla-cargo - tabla-abono.
          IF suma <> 0.
            sumat = sumat + suma.
            FORMAT COLOR 5 INTENSIFIED OFF.
            WRITE:/'*', tabla-kunnr.
            FORMAT COLOR OFF.

            FORMAT COLOR 3 INTENSIFIED OFF.
            WRITE: 20 tabla-name1.
            FORMAT COLOR OFF.

            FORMAT COLOR 1 INTENSIFIED OFF.
            WRITE: 55 suma.
            CLEAR suma.
            FORMAT COLOR OFF.

            FORMAT  COLOR 2 INTENSIFIED OFF.
            WRITE: 84 knkk-klimk.
            FORMAT COLOR OFF.
          ENDIF.
        ENDAT.
        AT LAST.


          FORMAT COLOR 6 INTENSIFIED OFF.
          WRITE:/ 'Totales        ', 55 sumat.
          WRITE:/ 'Total Dolares Incluidos', 55 dolar1.
          CLEAR: sumat, dolar1.
          FORMAT COLOR OFF.
        ENDAT.
      ENDLOOP.
*----------------------------------------------------------------------*
    ELSE.                                      "DEUDORES SIN ANTICIPO
*----------------------------------------------------------------------*
      SELECT        * FROM  bsid
             WHERE  bukrs  = bukrs
             AND    kunnr  IN kunnr.

        MOVE bsid-kunnr TO tabla-kunnr.
        COLLECT tabla.

      ENDSELECT.




      LOOP AT tabla.

        SELECT        * FROM  bsid
               WHERE  bukrs  = bukrs
               AND    kunnr  = tabla-kunnr.
          IF bsid-umskz = space.
            IF bsid-shkzg = 'S'.
              cargo = cargo + bsid-dmbtr.
            ELSE.
              abono = abono + bsid-dmbtr.
            ENDIF.
            IF bsid-waers = 'USD'.
              dolar1 = dolar1 + bsid-wrbtr.
            ENDIF.
          ENDIF.
        ENDSELECT.
        MOVE cargo TO tabla-cargo.
        MOVE abono TO tabla-abono.
        MODIFY tabla.
        CLEAR:cargo,
              abono.
      ENDLOOP.


      LOOP AT tabla.

        SELECT SINGLE  * FROM zvkna1
               WHERE  kunnr  = tabla-kunnr.
        MOVE zvkna1-kunnr TO tabla-kunnr.
        MOVE zvkna1-name1 TO tabla-name1.
        MOVE zvkna1-ort01 TO tabla-ort01.
        MODIFY tabla.
      ENDLOOP.

      MOVE sy-datum+0(4) TO gjahr.


      LOOP AT tabla.
        CLEAR suma.
        AT END OF kunnr.

          SELECT SINGLE  * FROM  knkk
                 WHERE  kunnr  = tabla-kunnr.
          IF sy-subrc EQ 0.
          ENDIF.


          FORMAT COLOR 3 INTENSIFIED OFF.

          index = sy-tabix.
          READ TABLE tabla INDEX index.

          suma = tabla-cargo - tabla-abono.
          IF suma <> 0.
            sumat = sumat + suma.
            FORMAT COLOR 5 INTENSIFIED OFF.
            WRITE:/'*', tabla-kunnr.
            FORMAT COLOR OFF.

            FORMAT COLOR 3 INTENSIFIED OFF.
            WRITE: 14 tabla-name1.
            FORMAT COLOR OFF.

            FORMAT COLOR 1 INTENSIFIED OFF.
            WRITE: 55 suma.
            CLEAR suma.
            FORMAT COLOR OFF.

            FORMAT  COLOR 2 INTENSIFIED OFF.
            WRITE: 84 knkk-klimk.
            FORMAT COLOR OFF.
          ENDIF.
        ENDAT.
        AT LAST.


          FORMAT COLOR 6 INTENSIFIED OFF.
          WRITE:/ 'Totales        ', 55 sumat.
          WRITE:/ 'Total Dolares Incluidos', 55 dolar1.
          CLEAR: sumat, dolar1.
          FORMAT COLOR OFF.
        ENDAT.
      ENDLOOP.
    ENDIF.
*----------------------------------------------------------------------*
  ELSE.
*busca por grupo de DEUDORES.
*----------------------------------------------------------------------*
    IF ktokd <> 'GACO'.         "OPCION NO. 1

      SELECT        * FROM  zvkna1
             WHERE  ktokd  = ktokd.
        MOVE zvkna1-name1 TO tabla1-name1.
        MOVE zvkna1-kunnr TO tabla1-kunnr.
        MOVE zvkna1-ort01 TO tabla1-ort01.

        APPEND tabla1.
      ENDSELECT.


      LOOP AT tabla1.

        SELECT        * FROM  bsid
               WHERE  bukrs  = bukrs
               AND    kunnr  = tabla1-kunnr ORDER BY budat ASCENDING.

          IF bsid-shkzg = 'S'.
            cargo = cargo + bsid-dmbtr.
          ELSE.
            abono = abono + bsid-dmbtr.
          ENDIF.
          IF bsid-waers = 'USD'.
*         pesos = pesos + bsid-dmbtr.
*   else.
            dolar = dolar + bsid-wrbtr.
          ENDIF.
          IF sy-dbcnt = '1'.
            MOVE bsid-budat TO tabla1-budat.
          ENDIF.
        ENDSELECT.


        total  = abono - cargo.
        tabla1-suma = total * -1.
*   move bsid-budat to tabla1-budat.
        MOVE bsid-waers TO tabla1-waers.
        MODIFY tabla1.
        CLEAR total.
        CLEAR: abono,
               cargo.
      ENDLOOP.
      CLEAR tabla1.
******************
      SORT tabla1.
      LOOP AT tabla1.
        IF tabla1-suma <> 0.
          FORMAT COLOR 5 INTENSIFIED OFF.
          WRITE:/'*', tabla1-kunnr.
          FORMAT COLOR OFF.
          FORMAT COLOR 3 INTENSIFIED OFF.
          WRITE: 12 tabla1-name1..
          FORMAT COLOR OFF.
          FORMAT COLOR 2 INTENSIFIED OFF.
          WRITE: 44 tabla1-ort01.
          FORMAT COLOR OFF.
          FORMAT COLOR 1 INTENSIFIED OFF.
          WRITE: 62 tabla1-suma.
          FORMAT COLOR OFF.
          FORMAT COLOR 6 INTENSIFIED OFF.
          WRITE: 92 tabla1-budat.
          FORMAT COLOR OFF.
        ENDIF.
        AT LAST.
          ULINE.
          SUM.
          FORMAT COLOR 6 INTENSIFIED OFF.
          WRITE:/ 'Totales',  72 tabla1-suma.
*rite:/ 'Total Pesos', 60 pesos.
          WRITE:/ 'Total Dolares Incluidos', 75 dolar.
          CLEAR: dolar.
          FORMAT COLOR OFF.
          ULINE.
        ENDAT.
      ENDLOOP.
    ENDIF.
************************************************************************
*************SI EL GRUPO ES GACO.***************************************
************************************************************************
    IF ktokd = 'GACO'.

      SELECT        * FROM  zvkna1
             WHERE  ktokd  = 'GACO'.
        MOVE zvkna1-name1 TO tabla1-name1.
        MOVE zvkna1-kunnr TO tabla1-kunnr.
        MOVE zvkna1-ort01 TO tabla1-ort01.

        APPEND tabla1.
      ENDSELECT.


      LOOP AT tabla1.

        SELECT        * FROM  bsid
               WHERE  bukrs  = bukrs
               AND    kunnr  = tabla1-kunnr ORDER BY budat ASCENDING.

          IF bsid-shkzg = 'S'.
            cargo = cargo + bsid-dmbtr.
          ELSE.
            abono = abono + bsid-dmbtr.
          ENDIF.

          IF bsid-waers = 'USD'.
*       pesos = pesos + bsid-dmbtr.
*-       else.
            dolar = dolar + bsid-wrbtr.
          ENDIF.
          IF sy-dbcnt = '1'.
            MOVE bsid-budat TO tabla1-budat.
          ENDIF.
        ENDSELECT.



        total  = abono - cargo.
        tabla1-suma = total * -1.
        MOVE bsid-waers TO tabla1-waers.
*   move bsid-budat to tabla1-budat.
        MODIFY tabla1.
        CLEAR total.
        CLEAR: abono,
               cargo.
      ENDLOOP.
      CLEAR tabla1.
******************
      LOOP AT tabla1.

        IF tabla1-suma <> 0.
          FORMAT COLOR 5 INTENSIFIED OFF.
          WRITE:/'*', tabla1-kunnr.
          FORMAT COLOR OFF.

          FORMAT COLOR 3 INTENSIFIED OFF.
          WRITE: 12 tabla1-name1.
          FORMAT COLOR OFF.
          FORMAT COLOR 2 INTENSIFIED OFF.
          WRITE:  45 tabla1-ort01.
          FORMAT COLOR OFF.
          FORMAT COLOR 1 INTENSIFIED OFF.
          WRITE: 72  tabla1-suma.
          FORMAT COLOR OFF.
          FORMAT COLOR 6 INTENSIFIED OFF.
          WRITE: 92 tabla1-budat.
          FORMAT COLOR OFF.
        ENDIF.
        AT LAST.
          ULINE.
          SUM.
          FORMAT COLOR 6 INTENSIFIED OFF.
          WRITE:/ 'Totales',  72 tabla1-suma.
*write:/ 'Total Pesos', 60 pesos.
          WRITE:/ 'Total Dolares Incluidos',  72 dolar.
          CLEAR: dolar.
          FORMAT COLOR OFF.
          ULINE.
        ENDAT.
      ENDLOOP.
    ENDIF.
  ENDIF.


***********************************************************************
AT LINE-SELECTION.
  IF sy-lisel+0(1) = '*'.

    MOVE sy-lisel+2(09) TO kunnr2.

   " IF kunnr2+0(3) <> '300'.

*      I = STRLEN( KUNNR2 ).
*    IF I = 1.
*      MOVE KUNNR2 TO DEUDO PERCENTAGE 10 RIGHT.
*      PERFORM REMPLAZA USING DEUDO.
*    ELSEIF I = 2.
*      MOVE KUNNR2 TO DEUDO PERCENTAGE 20 RIGHT.
*      PERFORM REMPLAZA USING DEUDO.
*    ELSEIF I = 3.
*      MOVE KUNNR2 TO DEUDO PERCENTAGE 30 RIGHT.
*      PERFORM REMPLAZA USING DEUDO.
*    ELSEIF I = 4.
*      MOVE KUNNR2 TO DEUDO PERCENTAGE 40 RIGHT.
*      PERFORM REMPLAZA USING DEUDO.
*    ELSEIF I = 5.
*      MOVE KUNNR2 TO DEUDO PERCENTAGE 50 RIGHT.
*      PERFORM REMPLAZA USING DEUDO.
*    ELSEIF I = 6.
*      MOVE KUNNR2 TO DEUDO PERCENTAGE 60 RIGHT.
*      PERFORM REMPLAZA USING DEUDO.
*  ENDIF.
      deudo = kunnr2.
      PERFORM remplaza USING deudo.
*        else.
*      MOVE kunnr2 TO deudo PERCENTAGE 60 RIGHT.
*      PERFORM remplaza USING deudo.


   " ENDIF.
    SET PF-STATUS 'ZMENU'.
    SET TITLEBAR '100'.
    WINDOW STARTING  AT 1  20
            ENDING  AT  86 40.
    IF boton = 'X'.
      PERFORM zfire003.
    ELSE.

      PERFORM zfire004.
    ENDIF.
  ENDIF.

TOP-OF-PAGE.
  IF kunnr <> space.
    SKIP.
    FORMAT COLOR 5 INTENSIFIED OFF.
    WRITE:/ 'DEUDOR', 20 'NOMBRE DEL DEUDOR', 55 'IMPORTE',
     94 'LIMITE DE CREDITO'.

    SKIP .
    FORMAT COLOR OFF.
  ELSE.
*op-of-page.
    SKIP.
    FORMAT COLOR 5 INTENSIFIED OFF.
    WRITE:/ 'DEUDOR', 20 'NOMBRE DEL DEUDOR', 53 'PUESTO', 72 'IMPORTE',
     90 'ULTIMA FECHA'.
    SKIP .
    FORMAT COLOR OFF.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  ZFIRE003
*&---------------------------------------------------------------------*
FORM zfire003.

  SELECT        * FROM  bsid
         WHERE  bukrs  = bukrs
         AND    kunnr = deudo.
    IF bsid-umskz <> space.
      MOVE-CORRESPONDING bsid TO tab_bsid.

      APPEND tab_bsid.
    ENDIF.
  ENDSELECT.
  FORMAT COLOR 2 ON INTENSIFIED OFF.
*WRITE:/ 'Deudor:', KUNNR2, '
*                                          '.
  WRITE:/ 'Deudor:', kunnr2.
  FORMAT COLOR OFF.
  FORMAT COLOR 2 ON INTENSIFIED OFF.

  WRITE:/'Documento', 13 'Fecha docto', 55 'Importe', 48 'Texto',
         97 'Moneda', 105 'CL.DOC', 112 'CV.CONT '.

  FORMAT COLOR OFF.
  CLEAR tab_bsid.
  SORT tab_bsid.
  LOOP AT tab_bsid.
    IF tab_bsid-shkzg = 'H'.
      tab_bsid-dmbtr = tab_bsid-dmbtr * -1.
    ENDIF.
    FORMAT COLOR 1 ON INTENSIFIED OFF.
    WRITE:/ tab_bsid-belnr, 12 tab_bsid-budat, 22 tab_bsid-dmbtr,
            54 tab_bsid-sgtxt, 100 tab_bsid-waers, 110 tab_bsid-blart,
            117 tab_bsid-bschl,'   '.
    FORMAT COLOR OFF.
  ENDLOOP.
  REFRESH tab_bsid.
ENDFORM.                    " ZFIRE003
*&---------------------------------------------------------------------*
*&      Form  REMPLAZA
*&---------------------------------------------------------------------*
FORM remplaza USING    p_deudo.

*  DO.
*    REPLACE ' ' WITH '0' INTO p_deudo.
*    IF sy-subrc <> 0.
*      EXIT.
*    ENDIF.
*  ENDDO.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input         = p_deudo
 IMPORTING
   OUTPUT        = p_deudo
          .

ENDFORM.                    " REMPLAZA
*&---------------------------------------------------------------------*
*&      Form  ZFIRE004
*&---------------------------------------------------------------------*
FORM zfire004.


  SELECT        * FROM  bsid
         WHERE  bukrs  = bukrs
         AND    kunnr = deudo.
    IF bsid-umskz = space.
      MOVE-CORRESPONDING bsid TO tab_bsid.

      APPEND tab_bsid.
    ENDIF.
  ENDSELECT.
  FORMAT COLOR 2 ON INTENSIFIED OFF.
*WRITE:/ 'Deudor:', KUNNR2, '
*                                          '.
  WRITE:/ 'Deudor:', kunnr2.
  FORMAT COLOR OFF.
  FORMAT COLOR 2 ON INTENSIFIED OFF.

  WRITE:/'Documento', 13 'Fecha docto', 34 'Importe', 110 'Texto',
         97 'Moneda', 105 'CL.DOC', 112 'CV.CONT '.

  FORMAT COLOR OFF.
  CLEAR tab_bsid.
  SORT tab_bsid.
  LOOP AT tab_bsid.
    IF tab_bsid-shkzg = 'H'.
      tab_bsid-dmbtr = tab_bsid-dmbtr * -1.
    ENDIF.
    FORMAT COLOR 1 ON INTENSIFIED OFF.
    WRITE:/ tab_bsid-belnr, 12 tab_bsid-budat, 22 tab_bsid-dmbtr,
            54 tab_bsid-sgtxt, 100 tab_bsid-waers, 110 tab_bsid-blart,
            117 tab_bsid-bschl,'   '.
    FORMAT COLOR OFF.
  ENDLOOP.
  REFRESH tab_bsid.
ENDFORM.                    " ZFIRE004
