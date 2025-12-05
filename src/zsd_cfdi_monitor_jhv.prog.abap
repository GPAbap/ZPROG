*&---------------------------------------------------------------------*
*& Report  ZSD_CFDI_MONITOR
*&
*&---------------------------------------------------------------------*
REPORT ZSD_CFDI_MONITOR_JHV.


*** Declaracion de datos
INCLUDE ZSD_MONITOR_JHV_TOP.
*INCLUDE ZSD_MONITOR_TOP.

*** Clases para manejo de archivos
INCLUDE ZSD_MONITOR_JHV_CLASS.
*INCLUDE ZSD_MONITOR_CLASS.

*** Declaracion de funciones
INCLUDE ZSD_MONITOR_JHV_F01.
*INCLUDE ZSD_MONITOR_F01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_PATH.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
    EXPORTING
      WINDOW_TITLE    = 'File Directory'
      INITIAL_FOLDER  = 'C:\temp\'
    CHANGING
      SELECTED_FOLDER = GD_PATH.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  CONCATENATE GD_PATH '\' INTO P_PATH.


START-OF-SELECTION.
*** Extrae datos de la factura
  PERFORM F_GET_DATA.

  IF NOT GT_DATA[] IS INITIAL.
*** Llena ALV
    PERFORM F_PROCESS_DATA.
*** Muestra ALV
    PERFORM F_SHOW_ALV.
  ENDIF.


END-OF-SELECTION.
