************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZCOMPLEMENTO_PAGOS_CFDI_33                    *
* Titulo              :  Generación de XML con complemento de pagos    *
*                                                                      *
* Programador         : David Del Valle Mendoza                        *
* Fecha               : VII.2017                                       *
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZCOMP_PAGOS_CFDI_33_CLASS
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION .
  PUBLIC SECTION .
    METHODS:
*** Para los iconos del pdf y xml
      HANDLE_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW_ID E_COLUMN_ID ES_ROW_NO,
*** Para los botones de la barra de herramientas
      HANDLE_TOOLBAR
        FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING E_OBJECT E_INTERACTIVE,
*** Para el boton seleccionado
      HANDLE_USER_COMMAND
        FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING E_UCOMM.

ENDCLASS.                    "lcl_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

*Handle Hotspot Click
  METHOD HANDLE_HOTSPOT_CLICK .
*    PERFORM mouse_click
*      USING e_row_id
*            e_column_id.
    CALL METHOD GRID1->GET_CURRENT_CELL
      IMPORTING
        E_ROW     = LS_ROW
        E_VALUE   = LS_VALUE
        E_COL     = LS_COL
        ES_ROW_ID = LS_ROW_ID
        ES_COL_ID = LS_COL_ID
        ES_ROW_NO = ES_ROW_NO.

    DATA: P_ROW    TYPE SALV_DE_ROW,
          P_COLUMN TYPE SALV_DE_COLUMN.

    P_ROW = LS_ROW.
    P_COLUMN = LS_COL_ID.

    PERFORM SHOW_DOCUMENT  USING P_ROW
                                 P_COLUMN.

  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_TOOLBAR.
    DATA: LS_TOOLBAR  TYPE STB_BUTTON.

*** Agrega los botones nuevos a la barra de herramientas
*    CLEAR LS_TOOLBAR.
*    MOVE 0 TO LS_TOOLBAR-BUTN_TYPE.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

*** Marcar todo
    CLEAR LS_TOOLBAR.
    MOVE 'XLS' TO LS_TOOLBAR-FUNCTION.
    MOVE ICON_XLS TO LS_TOOLBAR-ICON.
    MOVE 'Exportar' TO LS_TOOLBAR-QUICKINFO.
    MOVE 'Exportar' TO LS_TOOLBAR-TEXT.
    MOVE ' ' TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

*** Desmarcar todo
*    CLEAR LS_TOOLBAR.
*    MOVE 'DSEL' TO LS_TOOLBAR-FUNCTION.
*    MOVE ICON_DESELECT_ALL TO LS_TOOLBAR-ICON.
*    MOVE 'Desmarcar todo' TO LS_TOOLBAR-QUICKINFO.
*    MOVE 'Desmarcar todo' TO LS_TOOLBAR-TEXT.
*    MOVE ' ' TO LS_TOOLBAR-DISABLED.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

*** Refrescar
*    CLEAR LS_TOOLBAR.
*    MOVE 'REFRESH' TO LS_TOOLBAR-FUNCTION.
*    MOVE ICON_REFRESH TO LS_TOOLBAR-ICON.
*    MOVE 'Refrescar' TO LS_TOOLBAR-QUICKINFO.
*    MOVE 'Refrescar' TO LS_TOOLBAR-TEXT.
*    MOVE ' ' TO LS_TOOLBAR-DISABLED.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

*** Separador
*    CLEAR LS_TOOLBAR.
*    MOVE 0 TO LS_TOOLBAR-BUTN_TYPE.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

*** Generar XML agrupado por factura
*    CLEAR LS_TOOLBAR.
*    MOVE 'XML_PAGO' TO LS_TOOLBAR-FUNCTION.
*    MOVE ICON_WORKLOAD TO LS_TOOLBAR-ICON.
*    MOVE 'Timbrar documento' TO LS_TOOLBAR-QUICKINFO.
*    MOVE 'Timbrar documento' TO LS_TOOLBAR-TEXT.
*    MOVE ' ' TO LS_TOOLBAR-DISABLED.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

*    CLEAR LS_TOOLBAR.
*    MOVE 'SP' TO LS_TOOLBAR-FUNCTION.
**    MOVE ICON_ERASE TO LS_TOOLBAR-ICON.
*    MOVE '   ' TO LS_TOOLBAR-QUICKINFO.
*    MOVE '   ' TO LS_TOOLBAR-TEXT.
*    MOVE ' ' TO LS_TOOLBAR-DISABLED.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

*** Solicitar cancelacion factura
*    CLEAR LS_TOOLBAR.
*    MOVE 'CANC' TO LS_TOOLBAR-FUNCTION.
*    MOVE ICON_ERASE TO LS_TOOLBAR-ICON.
*    MOVE 'Solicitar cancelación' TO LS_TOOLBAR-QUICKINFO.
*    MOVE 'Solicitar cancelación' TO LS_TOOLBAR-TEXT.
*    MOVE ' ' TO LS_TOOLBAR-DISABLED.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

*** Verificar status
*    CLEAR LS_TOOLBAR.
*    MOVE 'CONS' TO LS_TOOLBAR-FUNCTION.
*    MOVE ICON_ERROR_PROTOCOL TO LS_TOOLBAR-ICON.
*    MOVE 'Verificar status' TO LS_TOOLBAR-QUICKINFO.
*    MOVE 'Verificar status' TO LS_TOOLBAR-TEXT.
*    MOVE ' ' TO LS_TOOLBAR-DISABLED.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.


*** Descargar factura
*    CLEAR LS_TOOLBAR.
*    MOVE 'DESC' TO LS_TOOLBAR-FUNCTION.
*    MOVE ICON_STORE TO LS_TOOLBAR-ICON.
*    MOVE 'Descargar documentos' TO LS_TOOLBAR-QUICKINFO.
*    MOVE 'Descargar documentos' TO LS_TOOLBAR-TEXT.
*    MOVE ' ' TO LS_TOOLBAR-DISABLED.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.



  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_USER_COMMAND.

    CASE E_UCOMM.
      WHEN 'XLS'.
        PERFORM exportar_xls.
*      WHEN 'SELE'.
*        PERFORM SELECT_ALL_ROWS.
*      WHEN 'DSEL'.
*        PERFORM DESELECT_ALL_ROWS.
*      WHEN 'REFRESH'.
*        PERFORM F_REFRESH.
*      WHEN 'CANC'.
*        PERFORM F_CANC_CONS USING '0'.
*      WHEN 'CONS'.
*        PERFORM F_CANC_CONS USING '1'.
*      WHEN 'DESC'.
*        PERFORM F_DESCARGA.

      WHEN OTHERS.
        LEAVE TO SCREEN 0.
    ENDCASE.

    IF V_UCOMM = 'EXIT'.
      LEAVE TO SCREEN 0.
    ENDIF.

  ENDMETHOD.                    "handle_user_command

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      Form  F_HIDE_TOOLBAR
*&---------------------------------------------------------------------*
FORM F_HIDE_TOOLBAR .

  FS_FUN = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
  APPEND FS_FUN TO T_FUN.

ENDFORM.                    " F_HIDE_TOOLBAR
