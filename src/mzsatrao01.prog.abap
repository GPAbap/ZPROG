************************************************************************
* Programa             : SAPMZSATRA                                     *
* Desarrollador        : Roberto Bautista Dominguez                    *
* Descripción          : Picking                                       *
* Fecha Creación       : 04.07.2017                                    *
* Consultor Funcional  :                                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           MZSATRAO01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                    LOG DE MODIFICACIONES                             *
*----------------------------------------------------------------------*
* Descripción          :                                               *
* Funcional            :                                               *
* Desarrollador        :                                               *
* Fecha Modificación   :                                               *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_0010 OUTPUT.

  SET PF-STATUS 'STA_0100'.
  SET TITLEBAR '100'.

  IF sy-dynnr EQ '0010'.
    CLEAR:
      vg_mayor,vg_grupo,vg_otras,vg_anula.
  ENDIF.
  vg_dynnr =  sy-dynnr.
ENDMODULE.                 " STATUS_SCREEN_0050  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_0012 OUTPUT.

  SET PF-STATUS 'STA_0100'.
  SET TITLEBAR '012'.
  IF vg_otras = abap_true.
    IF vg_datum IS INITIAL.
      vg_datum =  sy-datum.
    ENDIF.
  ENDIF.
  vg_dynnr =  sy-dynnr.

ENDMODULE.                 " STATUS_SCREEN_0050  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_0013 OUTPUT.

  SET PF-STATUS 'STA_0100'.
  SET TITLEBAR '013'.
  vg_dynnr =  sy-dynnr.

ENDMODULE.                 " STATUS_SCREEN_0050  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_0051 OUTPUT.

  SET PF-STATUS 'STA_0100'.
  IF sy-dynnr = '0050'.
    SET TITLEBAR '050'.
  ELSE.
    SET TITLEBAR '051'.
  ENDIF.
  IF vg_datum IS INITIAL.
    vg_datum =  sy-datum.
  ENDIF.

  vg_dynnr =  sy-dynnr.

ENDMODULE.                 " STATUS_SCREEN_0050  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen OUTPUT.

  SET PF-STATUS 'STA_0100'.
  SET TITLEBAR '103'.
*  vg_dynnr =  sy-dynnr.
*
*  IF vg_dynnr = '0100'.
*    IF tg_lips[] IS INITIAL.
*
*      SELECT * INTO TABLE tg_tvar
*        FROM tvarvc
*       WHERE name = 'VSTEL'.
*
*      CLEAR ra_vstel[].
*      LOOP AT tg_tvar INTO sg_tvar.
*
*        sg_vstel-sign   = sg_tvar-sign.
*        sg_vstel-option = sg_tvar-opti.
*        sg_vstel-low    = sg_tvar-low.
*
*        APPEND sg_vstel TO ra_vstel.
*        CLEAR sg_vstel.
*
*      ENDLOOP.
**  Validación: estatus de la entrega
*      SELECT lips~vbeln lips~posnr lips~matnr lips~charg lips~lfimg lips~vgbel lips~vgpos
*        INTO TABLE tg_lips
*        FROM ( lips
*       INNER JOIN likp
*          ON lips~vbeln EQ likp~vbeln
*       INNER JOIN vbuk
*          ON lips~vbeln EQ vbuk~vbeln )
**     FOR ALL entries IN tg_vbs
*       WHERE likp~vbeln EQ '0084055484'
*          OR likp~vbeln EQ '0084055485'
*          OR likp~vbeln EQ '0084055486'
*          OR likp~vbeln EQ '0084055495'
*          OR likp~vbeln EQ '0084055496'
*          OR likp~vbeln EQ '0084055497'
*          OR likp~vbeln EQ '0084055498'
*          OR likp~vbeln EQ '0084055499'
*          OR likp~vbeln EQ '0084055887'
*          OR likp~vbeln EQ '0084055888'
*          OR likp~vbeln EQ '0084055889'
*          OR likp~vbeln EQ '0084055890'
*          OR likp~vbeln EQ '0084056358'
*          OR likp~vbeln EQ '0084056359'
*          OR likp~vbeln EQ '0084056874'
*          OR likp~vbeln EQ '0084056875'
*          OR likp~vbeln EQ '0084056876'
*          OR likp~vbeln EQ '0084057044'.
**       AND likp~vstel IN ra_vstel.
**    likp~lfdat EQ sy-datum.
**     AND lips~vbeln EQ tg_vbs-vbeln.
**     AND vbuk~kostk EQ 'A'.
*
*      LOOP AT tg_lips INTO sg_lips.
*
*        MOVE: sg_lips-vbeln TO sg_vbs-vbeln.
*        APPEND sg_vbs TO tg_vbs.
*
*      ENDLOOP.
*
*      DELETE ADJACENT DUPLICATES FROM tg_vbs COMPARING ALL FIELDS.
*
*    ENDIF.
*  ENDIF.
ENDMODULE.                 " STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_102 OUTPUT.

  SET PF-STATUS 'STA_0100'.
  IF sy-dynnr EQ '0102'.
    SET TITLEBAR '102'.
  ELSE.
    SET TITLEBAR '104'.
  ENDIF.
  vg_dynnr =  sy-dynnr.

ENDMODULE.                 " STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_screen_101 OUTPUT.

  SET PF-STATUS 'STA_0100'.
  SET TITLEBAR '100'.
  vg_dynnr =  sy-dynnr.
  SORT tg_vbs BY vbeln.
ENDMODULE.                 " STATUS_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_data OUTPUT.

  vg_index = sy-stepl + vg_line.
  READ TABLE tg_vbs INTO sg_vbs INDEX vg_index.

  IF  sy-subrc NE 0.
    EXIT FROM STEP-LOOP.
*  ELSE.
*    sg_entr-vbeln =  sg_vbs-vbeln.
  ENDIF.
ENDMODULE.                 " SHOW_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_data_102 OUTPUT.

  vg_index2 = sy-stepl + vg_line2.
  READ TABLE tg_p101 INTO sg_p101 INDEX vg_index2.

  IF  sy-subrc NE 0.
    EXIT FROM STEP-LOOP.
  ENDIF.
ENDMODULE.                 " SHOW_DATA  OUTPUT
