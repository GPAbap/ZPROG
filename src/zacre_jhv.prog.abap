*&---------------------------------------------------------------------*
*& Report zacre_jhv
*&---------------------------------------------------------------------*
*& Migrado por Jaime Hernandez V. 03072024
*&---------------------------------------------------------------------*
REPORT zacre_jhv.
************************************************************************
**Descripcion.- Acreedores..
**Autor.- Sandra Castillo Espinoza.
**Fecha.- Agosto-Septiembre 1999.
**Empresa.- Grupo Pecuario San Antonio.
***********************************************************************

TABLES:BSIK,LFA1,LFC1.

DATA: SUMA LIKE BSIK-DMBTR,
      SUMAT LIKE BSIK-DMBTR,
      CARGO LIKE BSIK-DMBTR,
      ABONO LIKE BSIK-DMBTR,
      GJAHR LIKE BSIK-GJAHR,
      TOTAL LIKE BSIK-DMBTR.

DATA: BEGIN OF TABLA OCCURS 0,
      LIFNR LIKE BSIK-LIFNR,
      SHKZG LIKE BSIK-SHKZG,
      DMBTR LIKE BSIK-DMBTR,
      NAME1 LIKE LFA1-NAME1,
      BUDAT LIKE BSIK-BUDAT,
      ORT01 LIKE LFA1-ORT01,
      CARGO LIKE BSIK-DMBTR,
      ABONO LIKE BSIK-DMBTR,
      SUMA LIKE  BSIK-DMBTR,
END OF TABLA.

DATA: BEGIN OF TABLA1 OCCURS 0,
      LIFNR LIKE BSIK-LIFNR,
      NAME1 LIKE LFA1-NAME1,
      ORT01 LIKE LFA1-ORT01,
      SHKZG LIKE BSIK-SHKZG,
      BUDAT LIKE BSIK-BUDAT,
      DMBTR LIKE BSIK-DMBTR,
      WAERS LIKE BSIK-WAERS,
      SUMA  LIKE BSIK-DMBTR,
END OF TABLA1.

DATA: BEGIN OF TAB_BSIK OCCURS 0,
      BELNR LIKE BSIK-BELNR,
      BUDAT LIKE BSIK-BUDAT,
      DMBTR LIKE BSIK-DMBTR,
      SHKZG LIKE BSIK-SHKZG,
      SGTXT LIKE BSIK-SGTXT,
      WAERS LIKE BSIK-WAERS,
      BLART LIKE BSIK-BLART,
      BSCHL LIKE BSIK-BSCHL,
END OF TAB_BSIK.

DATA: BEGIN OF TAB_BSIK1 OCCURS 0,
      LIFNR LIKE BSIK-LIFNR,
      BUDAT LIKE BSIK-BUDAT,
      BELNR LIKE BSIK-BELNR,
END OF TAB_BSIK1.

DATA: INDEX LIKE SY-TABIX,
      PESOS LIKE BSIK-DMBTR,
      PESOS1 LIKE BSIK-DMBTR,
      DOLAR LIKE BSIK-WRBTR,
      DOLAR1 LIKE BSIK-WRBTR,
      DOLAR2 LIKE BSIK-WRBTR,
      DOLAR3 LIKE BSIK-WRBTR,
      LIFNR1 LIKE BSIK-LIFNR,
      LIFNR2 LIKE BSIK-LIFNR,
      ACRE1 LIKE BSIK-LIFNR,
      USDN  LIKE BSIK-DMBTR,
      ACRE(10) TYPE C,
      NO(2) TYPE N,
      I(2) TYPE N.
SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:LIFNR FOR LFA1-LIFNR.
PARAMETERS:BUKRS LIKE BSIK-BUKRS,
           KTOKK LIKE LFA1-KTOKK.
PARAMETERS: BOTON AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK BLOCK1.

START-OF-SELECTION.
*----------------------------------------------------------------------*
*PROCESO PARA OPCION POR ACREEDOR                                      *
*----------------------------------------------------------------------*
  IF  LIFNR <> SPACE.

    IF BOTON = 'X'.

      SELECT        * FROM  BSIK
             WHERE  BUKRS  = BUKRS
             AND    LIFNR  IN LIFNR.
        IF BSIK-UMSKZ <> SPACE AND BSIK-UMSKZ <> 'F'.
          MOVE BSIK-LIFNR TO TABLA-LIFNR.
          COLLECT TABLA.
        ENDIF.
      ENDSELECT.
*----------------------------------------------------------------------*

      SELECT        * FROM  BSIK
             WHERE  BUKRS  = BUKRS
            AND    LIFNR IN LIFNR.
        IF BSIK-UMSKZ <> SPACE AND BSIK-UMSKZ <> 'F'.
          MOVE-CORRESPONDING BSIK TO TAB_BSIK1.
          APPEND TAB_BSIK1.
        ENDIF.
      ENDSELECT.

      SORT TAB_BSIK1.
*----------------------------------------------------------------------*
      LOOP AT TABLA.

        SELECT        * FROM  BSIK
               WHERE  BUKRS  = BUKRS
               AND    LIFNR  = TABLA-LIFNR.
          IF BSIK-UMSKZ <> SPACE AND BSIK-UMSKZ <> 'F'.
            IF BSIK-SHKZG = 'S'.
              CARGO = CARGO + BSIK-DMBTR.
            ELSE.
              ABONO = ABONO + BSIK-DMBTR.
            ENDIF.
*       if bsik-waers = 'USD' or bsik-waers = 'USDN'.
*        dolar1 = dolar1 + bsik-wrbtr.
*      endif.
          ENDIF.
        ENDSELECT.

        MOVE CARGO TO TABLA-CARGO.
        MOVE ABONO TO TABLA-ABONO.
        MODIFY TABLA.
        CLEAR:CARGO,
              ABONO.
      ENDLOOP.


      LOOP AT TABLA.

        SELECT SINGLE  * FROM LFA1
               WHERE  LIFNR  = TABLA-LIFNR.
        MOVE LFA1-LIFNR TO TABLA-LIFNR.
        MOVE LFA1-NAME1 TO TABLA-NAME1.
        MODIFY TABLA.
      ENDLOOP.

      MOVE SY-DATUM+0(4) TO GJAHR.


      LOOP AT TABLA.
        CLEAR SUMA.


        AT END OF LIFNR.
          FORMAT COLOR 3 INTENSIFIED OFF.

          INDEX = SY-TABIX.
          READ TABLE TABLA INDEX INDEX.
          READ TABLE TAB_BSIK1 WITH KEY LIFNR = TABLA-LIFNR.
          SUMA = TABLA-CARGO - TABLA-ABONO.
          IF SUMA <> 0.
            SUMAT = SUMAT + SUMA.

            FORMAT COLOR 5 INTENSIFIED OFF.
            WRITE:/'*', TABLA-LIFNR.
            FORMAT COLOR OFF.

            FORMAT COLOR 3 INTENSIFIED OFF.
            WRITE: 22 TABLA-NAME1.
            FORMAT COLOR OFF.

            FORMAT COLOR 1 INTENSIFIED OFF.
            WRITE: 56 SUMA.
            CLEAR SUMA.
            FORMAT COLOR OFF.

            FORMAT COLOR 6 INTENSIFIED OFF.
            WRITE: 79 TAB_BSIK1-BUDAT.
            FORMAT COLOR OFF.
            CLEAR TAB_BSIK1.
          ENDIF.
        ENDAT.
        AT LAST.


          FORMAT COLOR 6 INTENSIFIED OFF.
          WRITE:/ 'Totales        ', 55 SUMAT.
*  write:/ 'Total Dolares Incluidos', 55 dolar1.
          CLEAR: SUMAT.
          FORMAT COLOR OFF.
        ENDAT.
      ENDLOOP.
*----------------------------------------------------------------------*
    ELSE.                                      "ACREEDORES SIN ANTICIPO
*----------------------------------------------------------------------*

      SELECT        * FROM  BSIK
             WHERE  BUKRS  = BUKRS
             AND    LIFNR  IN LIFNR.
        IF BSIK-UMSKZ = SPACE AND BSIK-UMSKZ <> 'F'.
          MOVE BSIK-LIFNR TO TABLA-LIFNR.
          COLLECT TABLA.
        ENDIF.
      ENDSELECT.

      LOOP AT TABLA.

        SELECT        * FROM  BSIK
               WHERE  BUKRS  = BUKRS
               AND    LIFNR  = TABLA-LIFNR.
          IF BSIK-UMSKZ = SPACE AND BSIK-UMSKZ <> 'F'.
            IF BSIK-SHKZG = 'S'.
              CARGO = CARGO + BSIK-DMBTR.
            ELSE.
              ABONO = ABONO + BSIK-DMBTR.
            ENDIF.
            IF BSIK-WAERS = 'USD'.
              DOLAR1 = DOLAR1 + BSIK-WRBTR.
            ENDIF.
            IF BSIK-WAERS = 'USDN'.
              USDN  =   BSIK-WRBTR / 1000.
              DOLAR2 = DOLAR2 + USDN.
              CLEAR USDN.
            ENDIF.
          ENDIF.
        ENDSELECT.

        MOVE CARGO TO TABLA-CARGO.
        MOVE ABONO TO TABLA-ABONO.
        MODIFY TABLA.
        CLEAR:CARGO,
              ABONO.
      ENDLOOP.


      LOOP AT TABLA.

        SELECT SINGLE  * FROM LFA1
               WHERE  LIFNR  = TABLA-LIFNR.
        MOVE LFA1-LIFNR TO TABLA-LIFNR.
        MOVE LFA1-NAME1 TO TABLA-NAME1.
        MODIFY TABLA.
      ENDLOOP.

      MOVE SY-DATUM+0(4) TO GJAHR.


      LOOP AT TABLA.
        CLEAR SUMA.
        AT END OF LIFNR.
          FORMAT COLOR 3 INTENSIFIED OFF.

          INDEX = SY-TABIX.
          READ TABLE TABLA INDEX INDEX.

          SUMA = TABLA-CARGO - TABLA-ABONO.
          IF SUMA <> 0.
            SUMAT = SUMAT + SUMA.
            FORMAT COLOR 5 INTENSIFIED OFF.
            WRITE:/'*', TABLA-LIFNR.
            FORMAT COLOR OFF.

            FORMAT COLOR 3 INTENSIFIED OFF.
            WRITE: 22 TABLA-NAME1.
            FORMAT COLOR OFF.

            FORMAT COLOR 1 INTENSIFIED OFF.
            WRITE: 62 SUMA.
            CLEAR SUMA.
            FORMAT COLOR OFF.
          ENDIF.
        ENDAT.
        AT LAST.


          FORMAT COLOR 6 INTENSIFIED OFF.

          DOLAR3  =   DOLAR1 + DOLAR2.
          WRITE:/ 'Totales        ', 55 SUMAT.
          WRITE:/ 'Total Dolares Incluidos', DOLAR3.
          CLEAR: SUMAT, DOLAR3, DOLAR2.
          FORMAT COLOR OFF.
        ENDAT.
      ENDLOOP.

    ENDIF.
*----------------------------------------------------------------------*
************************************************************************
  ELSE.
*busca por grupo de acreedores
************************************************************************

    SELECT        * FROM  LFA1
           WHERE  KTOKK  = KTOKK.
      MOVE LFA1-NAME1 TO TABLA1-NAME1.
      MOVE LFA1-LIFNR TO TABLA1-LIFNR.

      APPEND TABLA1.
    ENDSELECT.


    LOOP AT TABLA1.

      SELECT        * FROM  BSIK
             WHERE  BUKRS  = BUKRS
             AND    LIFNR  = TABLA1-LIFNR  ORDER BY BUDAT ASCENDING.

        IF BSIK-SHKZG = 'S'.
          CARGO = CARGO + BSIK-DMBTR.
        ELSE.
          ABONO = ABONO + BSIK-DMBTR.
        ENDIF.
        IF BSIK-WAERS = 'USD' OR BSIK-WAERS = 'USDN'.
          DOLAR = DOLAR + BSIK-WRBTR.
        ENDIF.

        IF SY-DBCNT = '1'.
          MOVE BSIK-BUDAT TO TABLA1-BUDAT.
        ENDIF.
      ENDSELECT.


      TOTAL  = ABONO - CARGO.
      TABLA1-SUMA = TOTAL * -1.
      MOVE BSIK-WAERS TO TABLA1-WAERS.
      MODIFY TABLA1.
      CLEAR TOTAL.
      CLEAR: ABONO,
             CARGO.
    ENDLOOP.

    CLEAR TABLA1.
******************
    SORT TABLA1.
    LOOP AT TABLA1.
      IF TABLA1-SUMA <> 0.
        FORMAT COLOR 5 INTENSIFIED OFF.
        WRITE:/'*', TABLA1-LIFNR.
        FORMAT COLOR OFF.
        FORMAT COLOR 3 INTENSIFIED OFF.
        WRITE: 22 TABLA1-NAME1..
        FORMAT COLOR OFF.
        FORMAT COLOR 1 INTENSIFIED OFF.
        WRITE: 62 TABLA1-SUMA.
        FORMAT COLOR OFF.
      ENDIF.
      AT LAST.
        ULINE.
        SUM.
        FORMAT COLOR 6 INTENSIFIED OFF.
        WRITE:/ 'Totales',  56 TABLA1-SUMA.
        WRITE:/ 'Total Dolares Incluidos', 56 DOLAR.
        CLEAR: DOLAR.
        FORMAT COLOR OFF.
        ULINE.
      ENDAT.

    ENDLOOP.
  ENDIF.


***********************************************************************
AT LINE-SELECTION.
  IF SY-LISEL+0(1) = '*'.

    MOVE SY-LISEL+2(10) TO LIFNR2.

*INICIA PROCETI 22.04.2013
    IF LIFNR2+0(1) <> '2'.
      MOVE LIFNR2 TO ACRE.
      PERFORM REMPLAZA USING ACRE.
    ELSE.
      MOVE LIFNR2 TO ACRE.
      PERFORM REMPLAZA USING ACRE.
    ENDIF.
*FIN PROCETI 22.04.2013
    SET PF-STATUS 'ZMENU'.
    SET TITLEBAR '100'.
    WINDOW STARTING  AT 1  20
            ENDING  AT  86 40.

    IF BOTON = 'X'.
      PERFORM ZFIRE003.
    ELSE.

      PERFORM ZFIRE004.
    ENDIF.

  ENDIF.

TOP-OF-PAGE.
  IF LIFNR <> SPACE AND BOTON = 'X'.
    SKIP.
    FORMAT COLOR 5 INTENSIFIED OFF.
    WRITE:/ 'ACREEDOR', 20 'NOMBRE DEL ACREEDOR', 58 'IMPORTE',
            73 'FECHA EXPEDICION'.
    SKIP .
    FORMAT COLOR OFF.
  ELSEIF LIFNR <> SPACE AND BOTON <> 'X'.
    SKIP.
    FORMAT COLOR 5 INTENSIFIED OFF.
    WRITE:/ 'ACREEDOR', 20 'NOMBRE DEL ACREEDOR', 62 'IMPORTE'.

    SKIP .
    FORMAT COLOR OFF.
  ENDIF.
  IF LIFNR = SPACE.
    SKIP.
    FORMAT COLOR 5 INTENSIFIED OFF.
    WRITE:/ 'ACREEDOR', 20 'NOMBRE DEL ACRREDOR', 62 'IMPORTE         '.
*       73 'FECHA EXPEDICION'.

    SKIP .
    FORMAT COLOR OFF.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  ZFIRE003
*&---------------------------------------------------------------------*
FORM ZFIRE003.

  SELECT        * FROM  BSIK
         WHERE  BUKRS  = BUKRS
         AND    LIFNR = ACRE.
    IF BSIK-UMSKZ <> SPACE AND BSIK-UMSKZ <> 'F'.
      MOVE-CORRESPONDING BSIK TO TAB_BSIK.

      APPEND TAB_BSIK.
    ENDIF.
  ENDSELECT.
  FORMAT COLOR 2 ON INTENSIFIED OFF.
*WRITE:/ 'Acreedor:', LIFNR2, '
*                                          '.
  WRITE:/ 'Acreedor:', LIFNR2.

  FORMAT COLOR OFF.
  FORMAT COLOR 2 ON INTENSIFIED OFF.

 WRITE:/'Documento', 13 'Fecha docto', 30 'Importe', 55 'Texto',
         105 'Moneda', 110 'CL.DOC', 116 'CV.CONT '.

  FORMAT COLOR OFF.
  CLEAR TAB_BSIK.
  SORT TAB_BSIK.
  LOOP AT TAB_BSIK.
    IF TAB_BSIK-SHKZG = 'H'.
      TAB_BSIK-DMBTR = TAB_BSIK-DMBTR * -1.
    ENDIF.
    FORMAT COLOR 1 ON INTENSIFIED OFF.
    WRITE:/ TAB_BSIK-BELNR, 12 TAB_BSIK-BUDAT, 22 TAB_BSIK-DMBTR,
            54 TAB_BSIK-SGTXT, 105 TAB_BSIK-WAERS, 110 TAB_BSIK-BLART,
            116 TAB_BSIK-BSCHL,'   '.
    FORMAT COLOR OFF.
  ENDLOOP.
  REFRESH TAB_BSIK.
ENDFORM.                    " ZFIRE003
*&---------------------------------------------------------------------*
*&      Form  REMPLAZA
*&---------------------------------------------------------------------*
FORM REMPLAZA USING    P_ACRE.
*INICIA PROCETI 22.04.2013
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = ACRE
    IMPORTING
      OUTPUT = ACRE.
*FIN PROCETI 22.04.2013
ENDFORM.                    " REMPLAZA
*&---------------------------------------------------------------------*
*&      Form  ZFIRE004
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ZFIRE004.


  SELECT        * FROM  BSIK
         WHERE  BUKRS  = BUKRS
         AND    LIFNR = ACRE.
    IF BSIK-UMSKZ = SPACE AND BSIK-UMSKZ <> 'F'.
      MOVE-CORRESPONDING BSIK TO TAB_BSIK.

      APPEND TAB_BSIK.
    ENDIF.
  ENDSELECT.
  FORMAT COLOR 2 ON INTENSIFIED OFF.
*WRITE:/ 'Acreedor:', LIFNR2, '
*                                          '.
  WRITE:/ 'Acreedor:', LIFNR2.
  FORMAT COLOR OFF.
  FORMAT COLOR 2 ON INTENSIFIED OFF.

  WRITE:/'Documento', 13 'Fecha docto', 30 'Importe', 55 'Texto',
         105 'Moneda', 110 'CL.DOC', 116 'CV.CONT '.

  FORMAT COLOR OFF.
  CLEAR TAB_BSIK.
  SORT TAB_BSIK.
  LOOP AT TAB_BSIK.
    IF TAB_BSIK-SHKZG = 'H'.
      TAB_BSIK-DMBTR = TAB_BSIK-DMBTR * -1.
    ENDIF.
    FORMAT COLOR 1 ON INTENSIFIED OFF.
    WRITE:/ TAB_BSIK-BELNR, 12 TAB_BSIK-BUDAT, 22 TAB_BSIK-DMBTR,
            54 TAB_BSIK-SGTXT, 105 TAB_BSIK-WAERS, 110 TAB_BSIK-BLART,
            116 TAB_BSIK-BSCHL,'   '.
    FORMAT COLOR OFF.
  ENDLOOP.
  REFRESH TAB_BSIK.




ENDFORM.                    " ZFIRE004
