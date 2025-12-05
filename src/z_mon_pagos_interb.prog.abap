************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZMONITOR_ALTA_PAGOS_BBVA_H2H                  *
* Titulo              :  Monitor status pagos enviados a BBVA          *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VIII.2020                                      *
************************************************************************
*&---------------------------------------------------------------------*
*& Report  ZMONITOR_ALTA_PAGOS_BBVA_H2H
*&---------------------------------------------------------------------*

REPORT  Z_MON_PAGOS_INTERB.

*** Include de declaraciones
INCLUDE Z_MON_PAGOS_INTERB_TOP.
*INCLUDE ZMON_ALTA_PAGOS_TOP_2.
*INCLUDE ZMON_ALTA_PAGOS_TOP.

*** Include generador de comprobante (PDF)
INCLUDE Z_MON_PAGOS_INTERB_FUN.
*INCLUDE ZMON_ALTA_PAGOS_COM_2.

*** Include de selecciones
INCLUDE Z_MON_PAGOS_INTERB_SEL.
*INCLUDE ZMON_ALTA_PAGOS_SEL_2.
*INCLUDE ZMON_ALTA_PAGOS_SEL.


*** Include de procesamiento
INCLUDE Z_MON_PAGOS_INTERB_F01.
*INCLUDE ZMON_ALTA_PAGOS_F01_2.
*INCLUDE ZMON_ALTA_PAGOS_F01.

*** Inicio del procesamiento
START-OF-SELECTION.

*** Extrae datos para el ALV
  PERFORM F_EXTRAE_DATOS.

*** Muestra el ALV
  IF NOT I_ZH2H_BBVA_ST_PAG[] IS INITIAL.
*    PERFORM F_ARMA_CATALOGO.
    PERFORM F_GENERAR_TABLA_DE_PAGOS.
  ELSE.
    MESSAGE E001(00) WITH 'No existen datos para los' 'criterios de selección'.
  ENDIF.

END-OF-SELECTION.
