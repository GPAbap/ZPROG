************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZRESPUESTA_ALTA_NOM_BBVA_H2H                  *
* Titulo              :  Respuesta alta nomina en portal H2H BBVA      *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VIII.2020                                      *
************************************************************************
*&---------------------------------------------------------------------*
*& Report  ZRESPUESTA_ALTA_NOM_BBVA_H2H
*&---------------------------------------------------------------------*

REPORT  ZRESPUESTA_ALTA_NOM_BBVA_H2H_2.

INCLUDE ZRESP_ALTA_NOMINA_TOP.

"$. Region Obtener datos de archivos ----------------------------------*
"' Lee el archivo a una ruta del servidor
CLEAR:   I_ZRUTAS_H2H_BBVA, I_DIR_LIST, V_IV_DIR_NAME, I_LOG.
REFRESH: I_ZRUTAS_H2H_BBVA, I_DIR_LIST, I_LOG.

SELECT *
  FROM ZRUTAS_H2H_BBVA
  INTO TABLE I_ZRUTAS_H2H_BBVA
  WHERE ID_ARCH = 'RESP_NOM'.

READ TABLE I_ZRUTAS_H2H_BBVA INDEX 1.

V_IV_DIR_NAME = I_ZRUTAS_H2H_BBVA-RUTA.

CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
  EXPORTING
    IV_DIR_NAME            = V_IV_DIR_NAME
  TABLES
    DIR_LIST               = I_DIR_LIST
  EXCEPTIONS
    INVALID_EPS_SUBDIR     = 1
    SAPGPARAM_FAILED       = 2
    BUILD_DIRECTORY_FAILED = 3
    NO_AUTHORIZATION       = 4
    READ_DIRECTORY_FAILED  = 5
    TOO_MANY_READ_ERRORS   = 6
    EMPTY_DIRECTORY_LIST   = 7
    OTHERS                 = 8.

"' Si se encontraron archivos...
IF I_DIR_LIST[] IS NOT INITIAL.
  "' Ordenar y revisar cada archivo
  SORT I_DIR_LIST[] BY NAME ASCENDING.

  LOOP AT I_DIR_LIST.
    CLEAR: V_TIPO, V_CONVENIO, V_CONSECUTIVO, V_EXTENSION, V_OK, V_NULL.
    DATA: V_LENG_NOM_ARCH TYPE I.
    CLEAR V_LENG_NOM_ARCH.
    V_LENG_NOM_ARCH = STRLEN( I_DIR_LIST-NAME ).
    V_LENG_NOM_ARCH = V_LENG_NOM_ARCH - 3.
    V_EXTENSION = I_DIR_LIST-NAME+V_LENG_NOM_ARCH(3).

    IF V_EXTENSION = 'TXT' OR
       V_EXTENSION ='txt'.
      V_OK = I_DIR_LIST-NAME.
      V_TIPO     = V_OK+0(4).
      IF V_TIPO = 'VALI' OR            " Validacion
         V_TIPO = 'APLP' OR            " Aplicación Propia
         V_TIPO = 'APLI'.              " Aplicacion Interbancaria

        V_CONVENIO    = V_OK+4(8).
        V_SERVICIO    = V_OK+14(3).
        V_SUBSERVICIO = V_OK+18(7).
        V_CONSECUTIVO = V_OK+29(7).

        "' Realiza procesado del archivo
        PERFORM F_PROCESA_ARCHIVO  USING I_DIR_LIST-NAME.
        "' Realiza eliminacion de archivo para evitar duplicados
        PERFORM F_MUEVE_BORRA_ARCH USING I_DIR_LIST-NAME.
      ENDIF.

    ENDIF.
  ENDLOOP.
"' Si ninguno de los archivos encontrados cumple con los criterios, mostrar mensaje de error
  IF I_LOG[] IS INITIAL.
    I_LOG-MSG = 'No existen archivos que cumplan con los criterios a procesar'.
    APPEND I_LOG.
  ENDIF.
"' Si no se encontraron archivos, mostrar mensaje de error
ELSE.
  I_LOG-MSG = 'No existen archivos a procesar en la carpeta'.
  APPEND I_LOG.

ENDIF.

*** Despliega el log con los resultados
LOOP AT I_LOG.
  WRITE:/1 I_LOG-MSG.
ENDLOOP.

"$. Endregion Obtener datos de archivos -------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_PROCESA_ARCHIVO
*&---------------------------------------------------------------------*
"$. Region
FORM F_PROCESA_ARCHIVO USING V_NOMBRE_ARCH TYPE ANY.
  "' Añadir Encabezado del mensaje
  IF I_LOG[] IS INITIAL.
    I_LOG-MSG = 'Archivos procesados:'.
    APPEND I_LOG.
  ENDIF.

  "' Ruta y nombre de descarga
  CONCATENATE V_IV_DIR_NAME V_NOMBRE_ARCH  INTO C_FILENAME.
  I_LOG-MSG = C_FILENAME.
  APPEND I_LOG.

  "' Rutas para respaldo
  CONCATENATE V_IV_DIR_NAME               V_NOMBRE_ARCH  INTO SOURCEPATH.
  CONCATENATE V_IV_DIR_NAME '/procesado/'  V_NOMBRE_ARCH  INTO TARGETPATH.

  "' Inicializa la Respuesta
  CLEAR   I_RESPUESTA.
  REFRESH I_RESPUESTA.

  "' Inicia procesado del archivo...
  OPEN DATASET C_FILENAME FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  "' Si hubo un error al abrir el archivo, terminar
  IF SY-SUBRC NE 0.
    EXIT.
  ELSE.
    "' Iniciar loop infinito...
    DO.
      "' Obtener la información del archivo
      CLEAR V_STRING.
      READ DATASET C_FILENAME INTO V_STRING.
      "' Condición de salida: No hay más información
      IF SY-SUBRC NE 0.
        EXIT.
      "' Guardar información en la Respuesta
      ELSE.
        APPEND V_STRING TO I_RESPUESTA.
      ENDIF.
    ENDDO.
    "' Cerrar archivo
    CLOSE DATASET C_FILENAME.
  ENDIF.


  "' Extrae la sociedad para el convenio
  READ TABLE I_RESPUESTA INDEX 1.
  DATA: V_BUKRS TYPE BUKRS.
  CLEAR: V_BUKRS.
  SELECT SINGLE BUKRS
    FROM ZH2H_BBVA_CONTRA
    INTO V_BUKRS
    WHERE ZCONTRATO = I_RESPUESTA+57(10).

  DATA: I_ZH2H_BBVA_ST_NOM TYPE ZH2H_BBVA_ST_NOM OCCURS 0 WITH HEADER LINE.
  CLEAR:   I_ZH2H_BBVA_ST_NOM.
  REFRESH: I_ZH2H_BBVA_ST_NOM.

  CLEAR: V_REG_OK, V_REG_ERR, V_IMP_OK, V_IMP_ERR,
         V_FECHA_OPER, V_FECHA_PAGO.

  "' Iterar Respuesta
  LOOP AT I_RESPUESTA.
    "' Si el Registro es 'OK'...
    IF I_RESPUESTA+0(1) = '1'.
      "' Guardar Registro 'OK'
      ADD 1 TO I_ZH2H_BBVA_ST_NOM-ZREGOK.

      "' Guardar Importe total como cantidad con formato 'XXXX.XX'(Quitar ceros a la izquierda, los 2 digitos a la derecha representan centimos)
      V_IMPORTE = I_RESPUESTA+7(15).
      V_CANT = V_IMPORTE+0(13).
      SHIFT V_CANT LEFT DELETING LEADING '0'.
      V_CENT = V_IMPORTE+13(2).
      CLEAR V_IMPORTE.
      CONCATENATE V_CANT V_CENT INTO V_IMPORTE SEPARATED BY '.'.
      V_IMP_OK = V_IMPORTE.
      "' En caso de que el Importe sea de 0, asegurarse de que su formato sea '0.00'
      IF V_IMP_OK = '.00'.
        V_IMP_OK = '0.00'.
      ENDIF.

      "' Guardar Fecha de operacion
      V_FECHA_OPER   = I_RESPUESTA+74(8).
      "' Guardar Fecha de pago
      V_FECHA_PAGO   = I_RESPUESTA+82(8).

    "' Si el Registro lleva un 'ERROR'
    ELSEIF I_RESPUESTA+0(1) = '2'.
      "' Guardar Registro "ERROR"
      ADD 1 TO I_ZH2H_BBVA_ST_NOM-ZREGERR.
      "' Guardar Importe total como cantidad con formato 'XXXX.XX'(Quitar ceros a la izquierda, los 2 digitos a la derecha representan centimos)
      V_IMPORTE = I_RESPUESTA+7(15).
      V_CANT = V_IMPORTE+0(13).
      SHIFT V_CANT LEFT DELETING LEADING '0'.
      V_CENT = V_IMPORTE+13(2).
      CLEAR V_IMPORTE.
      CONCATENATE V_CANT V_CENT INTO V_IMPORTE SEPARATED BY '.'.
      V_IMP_ERR = V_IMPORTE.
      "' En caso de que el Importe sea de 0, asegurarse de que su formato sea '0.00'
      IF V_IMP_ERR = '.00'.
        V_IMP_ERR = '0.00'.
      ENDIF.

      "' Guardar Fecha de operacion
      V_FECHA_OPER   = I_RESPUESTA+74(8).
      "' Guardar Fecha de pago
      V_FECHA_PAGO   = I_RESPUESTA+82(8).
    ENDIF.
  ENDLOOP.


  DATA: V_CONSEC TYPE N LENGTH 3.
  CLEAR V_CONSEC.

*** Barre el archivo de respuesta
  LOOP AT I_RESPUESTA.
    "' Barre el detalle para asignar el error
    IF I_RESPUESTA+0(1) = '3' OR I_RESPUESTA+0(1) = '4'.
      ADD 1 TO V_CONSEC.

      "' Asigna la sociedad
      I_ZH2H_BBVA_ST_NOM-BUKRS                  = V_BUKRS.

      "' Asigna la llave por registros duplicados
      CONCATENATE SY-DATUM SY-UZEIT V_CONSEC
        INTO I_ZH2H_BBVA_ST_NOM-LLAVE.

      "' Registros OK
      I_ZH2H_BBVA_ST_NOM-ZREGOK                 = V_REG_OK.

      "' Importe OK
      I_ZH2H_BBVA_ST_NOM-ZIMPOK                 = V_IMP_OK.

      "' Registros error
      I_ZH2H_BBVA_ST_NOM-ZREGERR                = V_REG_ERR.

      "' Importe error
      I_ZH2H_BBVA_ST_NOM-ZIMPERR                = V_IMP_ERR.

      "' Fecha de operacion
      I_ZH2H_BBVA_ST_NOM-ZFECHOPER              = V_FECHA_OPER.

      "' Fecha de pago
      I_ZH2H_BBVA_ST_NOM-ZFECHAPAGO             = V_FECHA_PAGO.

      "' Referencia numerica
      I_ZH2H_BBVA_ST_NOM-ZREFERENCIA            = I_RESPUESTA+1(7).

      "' RFC / CURP
      I_ZH2H_BBVA_ST_NOM-ZRFCCURP               = I_RESPUESTA+8(18).

      "' Tipo de cuenta
      I_ZH2H_BBVA_ST_NOM-ZTIPOCTA               = I_RESPUESTA+26(2).

      "' Banco destino
      I_ZH2H_BBVA_ST_NOM-ZBCODEST               = I_RESPUESTA+28(3).

      "' Cuenta de abono
      I_ZH2H_BBVA_ST_NOM-ZCTABONO               = I_RESPUESTA+34(16).

      "' Importe
      CLEAR V_IMPORTE.
      V_IMPORTE = I_RESPUESTA+50(15).
      V_CANT = V_IMPORTE+0(13).
      SHIFT V_CANT LEFT DELETING LEADING '0'.
      V_CENT = V_IMPORTE+13(2).
      CLEAR V_IMPORTE.
      CONCATENATE V_CANT V_CENT INTO V_IMPORTE SEPARATED BY '.'.

      I_ZH2H_BBVA_ST_NOM-RBETR                  = V_IMPORTE.

      "' Nombre del titular
      I_ZH2H_BBVA_ST_NOM-ZNME1               = I_RESPUESTA+152(40).

      "' Codigo de respuesta
      DATA: V_STATUS_D TYPE C LENGTH 7.
      CLEAR V_STATUS_D.
      V_STATUS_D = I_RESPUESTA+65(7).
      SHIFT V_STATUS_D LEFT DELETING LEADING '0'.
      I_ZH2H_BBVA_ST_NOM-STATUS_D               =  V_STATUS_D.
      CONDENSE I_ZH2H_BBVA_ST_NOM-STATUS_D.

      "' Descripcion de respuesta
      I_ZH2H_BBVA_ST_NOM-COMENTARIO_D               = I_RESPUESTA+72(80).

      APPEND I_ZH2H_BBVA_ST_NOM.
      CLEAR  I_ZH2H_BBVA_ST_NOM.

    ENDIF.
  ENDLOOP.

  "' Actualiza la tabla con el resultado
  LOOP AT I_ZH2H_BBVA_ST_NOM.
    INSERT ZH2H_BBVA_ST_NOM FROM I_ZH2H_BBVA_ST_NOM.
    MODIFY ZH2H_BBVA_ST_NOM FROM I_ZH2H_BBVA_ST_NOM.
    COMMIT WORK AND WAIT.
  ENDLOOP.

ENDFORM.                    " F_PROCESA_ARCHIVO
"$. Endregion


*&---------------------------------------------------------------------*
*&      Form  F_MUEVE_BORRA_ARCH
*&---------------------------------------------------------------------*
"$. Region
FORM F_MUEVE_BORRA_ARCH  USING    P_I_DIR_LIST_NAME.

  "' Generar copia de archivo en carpeta objetivo
  PERFORM F_COPIA_ARCHIVO.

  "' Borrar archivo
  CLEAR C_FILENAME.
  C_FILENAME = SOURCEPATH.
  DELETE DATASET C_FILENAME.

ENDFORM.                    " F_MUEVE_BORRA_ARCH
    "$. Endregion

*&---------------------------------------------------------------------*
*&      Form  F_COPIA_ARCHIVO
*&---------------------------------------------------------------------*
"$. Region
FORM F_COPIA_ARCHIVO .
  DATA: BEGIN OF INT_FILE OCCURS 1,
          LINE(1000) TYPE X,
        END OF INT_FILE.
  DATA:
    ILENGTH      TYPE P,
    COUNT_TABLE  TYPE P,
    LINE         LIKE INT_FILE-LINE,
    BIN_FILESIZE TYPE P.

  FIELD-SYMBOLS: <F1>.
* Öffnen File auf dem Applikationsserver
  OPEN DATASET SOURCEPATH FOR INPUT
                    IN BINARY MODE.
  IF SY-SUBRC <> 0.
*    message e414 with sourcepath raising error_file.
  ENDIF.
* read in Information File
  REFRESH INT_FILE.
  BIN_FILESIZE = 0.
  DO.
    READ DATASET SOURCEPATH INTO INT_FILE LENGTH ILENGTH.
    IF SY-SUBRC = 0.
      APPEND INT_FILE.
      BIN_FILESIZE = BIN_FILESIZE + ILENGTH.
    ELSE.
      IF SY-SUBRC = 8.
* open of file failed
*        message e414 with sourcepath raising error_file.
      ELSE.
* end of file reached
        APPEND INT_FILE.
        BIN_FILESIZE = BIN_FILESIZE + ILENGTH.
        EXIT.
      ENDIF.
    ENDIF.
  ENDDO.
* close file on application server
  CLOSE DATASET SOURCEPATH.
* correct content of last line
  DESCRIBE TABLE INT_FILE LINES COUNT_TABLE.
  IF COUNT_TABLE <> 0.
    READ TABLE INT_FILE INDEX COUNT_TABLE.
    CLEAR LINE.
    IF ILENGTH > 0.
      ASSIGN INT_FILE-LINE(ILENGTH) TO <F1>.
      LINE = <F1>.
    ELSE.
      CLEAR LINE.
    ENDIF.
    CLEAR INT_FILE-LINE.
    INT_FILE-LINE = LINE.
    MODIFY INT_FILE INDEX COUNT_TABLE.
  ENDIF.
* transfer to targetfile
* open file on application server
  OPEN DATASET TARGETPATH FOR OUTPUT
                    IN BINARY MODE.
  IF SY-SUBRC <> 0.
*    message e415 with targetpath space raising error_file.
  ENDIF.
* correction content of lat line
  DESCRIBE TABLE INT_FILE LINES COUNT_TABLE.
  ILENGTH = BIN_FILESIZE MOD 1000.
* Length file
  LENGTH = BIN_FILESIZE.
* write to file
  LOOP AT INT_FILE.
    IF SY-TABIX <> COUNT_TABLE.
      TRANSFER INT_FILE TO TARGETPATH.
    ELSE.
      TRANSFER INT_FILE TO TARGETPATH LENGTH ILENGTH.
    ENDIF.
    IF SY-SUBRC <> 0.
*      message e415 with targetpath space raising error_file.
    ENDIF.
  ENDLOOP.
* close file on application server
  CLOSE DATASET TARGETPATH.


ENDFORM. " F_COPIA_ARCHIVO
   "$. Endregion
