*  --------------------------------------------------------------------*
*  Report  Z_PROCESOBASCULASAL_COPY                                    *
*----------------------------------------------------------------------*
*  Description: Programa para el Obtener información que se obtiene de *
*  las basculas en las diferentes plantas.                             *
*----------------------------------------------------------------------*
*  ABAP Name     : Z_PROCESOBASCULASAL_COPY   "Salida de Camión        *
*  Online/Batch  : Online/Batch                                        *
*  Autor         : Irais Rocio Gómez Jacinto  -  ITG Consulting        *
*  Date          : Enero 2006                                          *
*  Transport     : TE1KXXXXXX.                                         *
*----------------------------------------------------------------------*
*  Changes     (internal Version: Documentation/Info on line level)    *
*----------------------------------------------------------------------*
*  Date      Name    internal    Transp.No. Description                *
*                    -Version-                                         *
*----------------------------------------------------------------------*
*REPORT  Z_PROCESOBASCULASAL_N MESSAGE-ID 00.
*---*---* INCLUDE PARA TABLAS Y DATOS GLOBALES
INCLUDE Z_PROCESOBASCULASAL_N_TOP.

INCLUDE ZIBASCULA.

*---*---* INCLUDE PARA PARAMETROS DE SELECCION Y PANTALLA INICIAL
INCLUDE Z_PROCESOBASCULASAL_N_S01.
*---*---* INCLUDE PARA RUTINAS GENERALES
INCLUDE Z_PROCESOBASCULASAL_N_F01.

* INI PROCETI CJTC DESK929466
INITIALIZATION.
  PERFORM F_INCIALIZA_VALORES.
* FIN PROCETI CJTC DESK929466

*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*--*
*---*---*---*---*---*  INICIO DE PROGRAMA PRINCIPAL *---*---*---*---*--*
START-OF-SELECTION.
* Valida información
* Bloquea pedido y materiales
  PERFORM VALIDA_INFO.
* Lee y valida archivo TXT para tomar peso de indicador
  PERFORM PROCESO_GRAL.
  PERFORM PROCEDA_DATOS.    "Procesa datos antes de llenar tablas

END-OF-SELECTION.
*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*--*
*---*---*---*---*---*---*FIN DE PROGRAMA PRINCIPAL *---*---*---*---*---*
  PERFORM PROCESS_ALV.
  PERFORM DISPLAY_ALV.
*---*---* CABECERO
FORM TOP_OF_PAGE.
  DATA: DATOS1(60), DATOS2(60), DATOS3(60), DATOS4(60),
        DATOS5(60), DATOS6(60), DATOS7(60),
        DATOS8(60), DATOS9(60), DATOS10(60),
        LT_COMMENTARY TYPE SLIS_T_LISTHEADER WITH HEADER LINE,
        L_FECHA(10), L_HORA(8),
        USER_ADDRESS  LIKE  ADDR3_VAL.
  DATOS6 = '               '.
  WRITE SY-DATUM TO DATOS1.
  WRITE SY-UZEIT TO DATOS2.
  MOVE: ZBASCULA_0-PESO_BASENT TO W_PESO_BASENT,
        ZBASCULA_0-UM_BASENT   TO W_UM_BASENT,
        ZBASCULA_0-NNEA        TO W_NNEA,
        W_PESODIFERENCIA       TO W_PESO_BASDIF.
  CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
    EXPORTING
      USER_NAME              = SY-UNAME
    IMPORTING
      USER_ADDRESS           = USER_ADDRESS
    EXCEPTIONS
      USER_ADDRESS_NOT_FOUND = 1
      OTHERS                 = 2.
  CONCATENATE SY-UNAME '(' USER_ADDRESS-NAME_TEXT ')'
  INTO DATOS3 SEPARATED BY SPACE.
*  CONCATENATE tab_archivo2 w_umentradabas2
  CONCATENATE GD_SPESO     W_UMENTRADABAS2

  INTO DATOS4 SEPARATED BY SPACE.
  CONCATENATE TEXT-T04 DATOS1
  INTO DATOS5 SEPARATED BY SPACE.
  CONCATENATE TEXT-T05 DATOS2
  INTO DATOS6 SEPARATED BY SPACE.
  CONCATENATE TEXT-T06 DATOS3
  INTO DATOS7 SEPARATED BY SPACE.
  CONCATENATE W_PESO_BASENT W_UM_BASENT
  INTO DATOS8 SEPARATED BY SPACE.
  CONCATENATE W_PESO_BASDIF W_UMENTRADABAS2
  INTO DATOS9 SEPARATED BY SPACE.
  LT_COMMENTARY-TYP  = 'H'.
  LT_COMMENTARY-INFO = TEXT-H01.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-KEY  = TEXT-T10.
  LT_COMMENTARY-INFO = W_NNEA.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-INFO = TEXT-T03.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-KEY  = TEXT-T01.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-KEY  = TEXT-T07.
  LT_COMMENTARY-INFO = DATOS8.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-KEY  = TEXT-T02.
  LT_COMMENTARY-INFO = DATOS4.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-INFO = TEXT-T03.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-KEY  = TEXT-T11.
  LT_COMMENTARY-INFO = DATOS9.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-INFO = TEXT-T03.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-INFO = DATOS5.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-INFO = DATOS6.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP  = 'S'.
  LT_COMMENTARY-INFO = DATOS7.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      I_LOGO             = 'LGP_ZIRGJ'
      IT_LIST_COMMENTARY = LT_COMMENTARY[].
ENDFORM.                           " TOP_OF_PAGE

FORM PF_STATUS_SET USING RT_EXTAB  TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN2'.
ENDFORM.                    "pf_status_set

FORM USER_COMMAND USING R_UCOMM     LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.
  CASE R_UCOMM.
    WHEN '&PROC'.
      PERFORM GRABA_FASE2.
  ENDCASE.
ENDFORM.                               " USER_COMMAND
