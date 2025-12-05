REPORT  ZCOMPLEMENTO_PAGOS_CFDI_33_R.

*** Declaracion de variables y pantalla de seleccion
*** Variable and selection screen
INCLUDE ZCOMP_PAGOS_CFDI_33_R_TOP.
*INCLUDE ZCOMP_PAGOS_CFDI_33_TOP.

*** Declaracion de clases para manejo de archivos y ALV
*** Classes for files and ALV
INCLUDE ZCOMP_PAGOS_CFDI_33_R_CLASS.
*INCLUDE ZCOMP_PAGOS_CFDI_33_CLASS.

*** Declaracion de botones
*** Include for buttons
INCLUDE ZCOMP_PAGOS_CFDI_33_R_BOTONES.
*INCLUDE ZCOMP_PAGOS_CFDI_33_BOTONES.

*** Declaracion de funciones
*** Include for forms
INCLUDE ZCOMP_PAGOS_CFDI_33_R_F01.
*INCLUDE ZCOMP_PAGOS_CFDI_33_F01.

*** Generacion de XML
*** Include for XML generation
INCLUDE ZCOMP_PAGOS_CFDI_33_R_F01_CUST.
*INCLUDE ZCOMP_PAGOS_CFDI_33_F01_CUST.

*****************************************************
***           Inicio del procesamiento            ***
***               START PROCESSING                ***
*****************************************************
START-OF-SELECTION.

*** Create ALV structure
  PERFORM F_CREATE_ALV_STRUCT.

  IF NOT WA_DATA_ALV[] IS INITIAL.
*** Call screen with grid
    CALL SCREEN 100.
  ENDIF.
