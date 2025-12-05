*&---------------------------------------------------------------------*
*& Include          ZSD_RE_SAN2SAP_SS
*&---------------------------------------------------------------------*




  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

    SELECT-OPTIONS: SO_tick  FOR zsd_tt_logsanh-ticket,
                    so_werks FOR vbap-werks,
                    so_fecha FOR zsd_tt_logsanh-fecha DEFAULT sy-datum OBLIGATORY.

  SELECTION-SCREEN END OF BLOCK b1.
  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

    PARAMETERS: p_creado RADIOBUTTON  GROUP r1 USER-COMMAND act DEFAULT 'X',
                p_nocrea RADIOBUTTON GROUP r1.


  SELECTION-SCREEN END OF BLOCK b2.

*  INITIALIZATION.
*    IF p_creado = 'X'.
*      LOOP AT SCREEN.
*        IF screen-group4 = '002'.
*          screen-input = 0.
*          screen-invisible = 1.
*
*        ENDIF.
*
*        MODIFY SCREEN.
*      ENDLOOP.
*    ELSEIF p_nocrea = 'X'.
*      LOOP AT SCREEN.
*        IF screen-group4 = '002'.
*          screen-input = 1.
*          screen-invisible = 0.
*
*
*        ENDIF.
*
*        MODIFY SCREEN.
*      ENDLOOP.
*    ENDIF.

*  AT SELECTION-SCREEN OUTPUT.
*    IF p_creado = 'X'.
*      LOOP AT SCREEN.
*        IF screen-group4 = '002'.
*          screen-input = 0.
*          screen-invisible = 1.
*        ENDIF.
*
*        MODIFY SCREEN.
*      ENDLOOP.
*    ELSEIF p_nocrea = 'X'.
*      LOOP AT SCREEN.
*        IF screen-group4 = '002'.
*          screen-input = 1.
*          screen-invisible = 0.
*        ENDIF.
*
*        MODIFY SCREEN.
*      ENDLOOP.
*    ENDIF.
