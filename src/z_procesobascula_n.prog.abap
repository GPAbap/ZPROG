*----------------------------------------------------------------------*
*  Report  Z_PROCESOBASCULA                                            *
*----------------------------------------------------------------------*
*  Description: Programa para el Obtener información que se obtiene de *
*  las basculas en las diferentes plantas.                             *
*----------------------------------------------------------------------*
*  ABAP Name     : Z_PROCESOBASCULA                                    *
*  Online/Batch  : Online                                              *
*  Autor         : Irais Rocio Gómez Jacinto  -  ITG Consulting        *
*  Date          : Junio 2005                                          *
*  Transport     : TE1KXXXXXX                                          *
*----------------------------------------------------------------------*
*  Changes     (internal Version: Documentation/Info on line level)    *
*----------------------------------------------------------------------*
*  Date      Name    internal    Transp.No. Description                *
*                    -Version-                                         *
*----------------------------------------------------------------------*
REPORT  Z_PROCESOBASCULA_N  MESSAGE-ID 00.

*---*---* INCLUDE PARA DATOS Y TABLAS GLOBALES
INCLUDE Z_PROCESOBASCULA_N_TOP.

INCLUDE ZIBASCULA.

*INCLUDE z_procesobascula_top.
*---*---* INCLUDE PARA PARAMETROS DE SELECCIÓN Y PANTALLA INICIAL
INCLUDE Z_PROCESOBASCULA_N_S01.
*INCLUDE z_procesobascula_s01.
*---*---* INCLUDE PARA RUTINAS GENERALES
INCLUDE Z_PROCESOBASCULA_N_F01.
*INCLUDE z_procesobascula_f01.
*---*---* Pantalla de Selección
AT SELECTION-SCREEN.
  INITIALIZATION.
  PERFORM p_initialitation.
*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*--*
*---*---*---*---*---* INICIO DE PROGRAMA PRINCIPAL  *---*---*---*---*--*
START-OF-SELECTION.
  PERFORM OBTIENE_DATOS.    "Obtiene datos
  PERFORM PROCESO_GENERAL.  "Ejecuta rutinas generales
  PERFORM PROCESA_INFO.     "Procesa informacion

END-OF-SELECTION.
*---*---*---*---*---* FIN DE PROGRAMA PRINCIPAL *---*---*---*---*---*--*
*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*--*
  PERFORM PROCESS_ALV.
  PERFORM DISPLAY_ALV.
*---*---* CABECERO
FORM TOP_OF_PAGE.
  DATA: DATOS1(60), DATOS2(60), DATOS3(60), DATOS4(60),
        DATOS5(60), DATOS6(60), DATOS7(60),
        LT_COMMENTARY TYPE SLIS_T_LISTHEADER WITH HEADER LINE,
        L_FECHA(10), L_HORA(8),
        USER_ADDRESS  LIKE  ADDR3_VAL.
  DATOS6 = '               '.
  WRITE SY-DATUM TO DATOS1.
  WRITE SY-UZEIT TO DATOS2.
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
* concatenate tab_archivo w_umentradabas
  CONCATENATE GD_SPESO    W_UMENTRADABAS
  INTO DATOS4 SEPARATED BY SPACE.
  CONCATENATE TEXT-T01 DATOS1
  INTO DATOS5 SEPARATED BY SPACE.
  CONCATENATE TEXT-T02 '  ' DATOS2
  INTO DATOS6 SEPARATED BY SPACE.
  CONCATENATE TEXT-T03 '  ' DATOS3
  INTO DATOS7 SEPARATED BY SPACE.
  LT_COMMENTARY-TYP = 'H'.
  LT_COMMENTARY-INFO = TEXT-H01.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP = 'S'.
  LT_COMMENTARY-KEY = TEXT-T04.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP = 'S'.
  LT_COMMENTARY-KEY = TEXT-T05.
  LT_COMMENTARY-INFO = DATOS4.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP = 'S'.
  LT_COMMENTARY-INFO = TEXT-T00.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP = 'S'.
  LT_COMMENTARY-INFO = DATOS5.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP = 'S'.
  LT_COMMENTARY-INFO = DATOS6.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP = 'S'.
  LT_COMMENTARY-INFO = DATOS7.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  LT_COMMENTARY-TYP = 'S'.
  LT_COMMENTARY-INFO = TEXT-T00.
  APPEND LT_COMMENTARY.
  CLEAR  LT_COMMENTARY.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      I_LOGO             = 'LGP_ZIRGJ'
      IT_LIST_COMMENTARY = LT_COMMENTARY[].
ENDFORM.                           " TOP_OF_PAGE

FORM PF_STATUS_SET USING RT_EXTAB  TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.

*---*---* Funcionalidad para Procesar Pedido.
FORM USER_COMMAND USING R_UCOMM     LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.
  CASE R_UCOMM.
    WHEN '&PEDIDO'.
      PERFORM GRABA_FASE1.
  ENDCASE.
ENDFORM.                               " USER_COMMAND
