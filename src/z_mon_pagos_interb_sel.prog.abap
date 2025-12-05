************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZMONITOR_ALTA_PAGOS_BBVA_H2H                   *
* Titulo              :  Include de extraccion de información          *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VIII.2020                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZMON_ALTA_PAGOS_SEL
*&---------------------------------------------------------------------*

*** Pantalla de seleccion
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-P01.
SELECT-OPTIONS: S_LAUFD FOR REGUH-LAUFD,
                S_LAUFI FOR REGUH-LAUFI,
                S_UBKNT FOR REGUH-UBKNT.

SELECTION-SCREEN SKIP.


SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS R_ERROR AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: COMMENT 4(20) TEXT-002.
SELECTION-SCREEN : END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS R_OK AS CHECKBOX.
SELECTION-SCREEN: COMMENT 4(20) TEXT-001.
SELECTION-SCREEN : END OF LINE.



SELECTION-SCREEN END OF BLOCK B1.

*&---------------------------------------------------------------------*
*&      Form  F_EXTRAE_DATOS
*&---------------------------------------------------------------------*
FORM F_EXTRAE_DATOS .

  CLEAR:   I_ZH2H_BBVA_ST_PAG.
  REFRESH: I_ZH2H_BBVA_ST_PAG.


*** Extrae los interlocutores que cumplan con los dos criterios de seleccion
  SELECT *
    FROM ZH2H_BBVA_ST_PAG
    INTO TABLE I_ZH2H_BBVA_ST_PAG
    WHERE LAUFD IN S_LAUFD
    AND   LAUFI IN S_LAUFI
    AND   UBKNT IN S_UBKNT.

*** Guardar los datos obtenidos en la tabla de datos...
  LOOP AT I_ZH2H_BBVA_ST_PAG.

    """ Obtener datos de fila...
    CLEAR WA_PREFINAL.
    WA_PREFINAL-MANDANTE = I_ZH2H_BBVA_ST_PAG-MANDT.
    WA_PREFINAL-SOCIEDAD = I_ZH2H_BBVA_ST_PAG-BUKRS.
    WA_PREFINAL-FECHA_EJECUCION = I_ZH2H_BBVA_ST_PAG-LAUFD.
    WA_PREFINAL-ID_ADICIONAL = I_ZH2H_BBVA_ST_PAG-LAUFI.
    WA_PREFINAL-NUM_PROVEEDOR = I_ZH2H_BBVA_ST_PAG-LIFNR.
    WA_PREFINAL-REFERENCIA_SIT = I_ZH2H_BBVA_ST_PAG-REF_SIT.
    WA_PREFINAL-REFERENCIA_NUM = I_ZH2H_BBVA_ST_PAG-REF_NUM.
    WA_PREFINAL-RECEPTOR_PAGO = I_ZH2H_BBVA_ST_PAG-ZNME1.
    WA_PREFINAL-IMPORTE_ML = I_ZH2H_BBVA_ST_PAG-RBETR.
    WA_PREFINAL-CLAVE_MONEDA = I_ZH2H_BBVA_ST_PAG-WAERS.
    WA_PREFINAL-NUM_BANCO = I_ZH2H_BBVA_ST_PAG-UBKNT.
    WA_PREFINAL-NUM_RECEPTOR = I_ZH2H_BBVA_ST_PAG-ZBNKN.
    WA_PREFINAL-COD_RES_H = I_ZH2H_BBVA_ST_PAG-STATUS_H.
    WA_PREFINAL-COMENTARIO_H = I_ZH2H_BBVA_ST_PAG-COMENTARIO_H.
    WA_PREFINAL-COD_RES_D = I_ZH2H_BBVA_ST_PAG-STATUS_D.
    WA_PREFINAL-COMENTARIO_D = I_ZH2H_BBVA_ST_PAG-COMENTARIO_D.

    """ Añadir fila a los datos guardados
    APPEND WA_PREFINAL TO IT_PREFINAL.

    ENDLOOP.

ENDFORM.                    " F_EXTRAE_DATOS
