*&---------------------------------------------------------------------*
*& Include          ZSD_RE_SAN2SAP_FUN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form tickets_creados
*&---------------------------------------------------------------------*
*& Obtiene los tickets con numero de pedido creados automaticamente
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM tickets_creados .

  SELECT    a~vbeln, a~werks, a~fechacrea, h~erdat, h~vbtyp, h~auart, a~ticket,
            h~vkorg, h~vtweg, h~spart, h~vkbur, h~kunnr, k~name1, h~kvgr1, h~kvgr2,
            h~kvgr3, h~knumv, p~posnr, p~matnr, m~maktx, p~waerk, p~brgew,p~gewei,
            p~kwmeng, p~vrkme, p~netpr, p~abgru, CASE when a~bsark eq 'VTRU' THEN 'RUTA' else 'MOST' end as bsark
      FROM zsd_tt_pedticsan AS a
      INNER JOIN vbak AS h ON h~vbeln EQ a~vbeln
      INNER JOIN vbap AS p ON p~vbeln EQ h~vbeln
      INNER JOIN kna1 AS k ON k~kunnr EQ h~kunnr
      INNER JOIN makt AS m ON m~matnr EQ p~matnr
      WHERE a~ticket IN @SO_tick AND
            a~werks IN @so_werks AND
            a~fechacrea IN @so_fecha
     INTO CORRESPONDING FIELDS OF TABLE @it_creados
    .


  SORT it_creados BY vbeln posnr ASCENDING.
  DELETE ADJACENT DUPLICATES FROM it_creados COMPARING vbeln posnr.
  MOVE-CORRESPONDING it_creados TO it_creadosh.

  DELETE ADJACENT DUPLICATES FROM it_creadosh COMPARING vbeln.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fieldcat .
  CLEAR wa_fieldcat.
  REFRESH gt_fieldcat.


  DATA(v_repid) = sy-repid.
  FIELD-SYMBOLS <wa> TYPE slis_fieldcat_alv.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = v_repid
      i_structure_name       = 'ZSD_ST_CREADOSAN'
      i_client_never_display = 'X'
      i_inclname             = v_repid
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = gt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.



  LOOP AT gt_fieldcat ASSIGNING <wa>.
    IF <wa>-fieldname EQ 'VBELN'.
      <wa>-tabname = 'IT_CREADOSH'.
      <wa>-seltext_m = 'Pedido V.'.
      <wa>-seltext_s = 'Pedido V.'.
      <wa>-seltext_l = 'Pedido V.'.
      <wa>-hotspot = 'X'.
    ELSEIF <wa>-fieldname EQ 'FECHACREA'.
      <wa>-tabname = 'IT_CREADOSH'.
      <wa>-seltext_m = 'Fec. Crea'.
      <wa>-seltext_s = 'Fec. Crea'.
      <wa>-seltext_l = 'Fec. Creacion'.
    ELSEIF <wa>-fieldname EQ 'WERKS'.
      <wa>-tabname = 'IT_CREADOSH'.
      <wa>-seltext_m = 'Centro'.
      <wa>-seltext_s = 'Centro'.
      <wa>-seltext_l = 'Centro'.
    ELSEIF <wa>-fieldname EQ 'KUNNR'.
      <wa>-tabname = 'IT_CREADOSH'.
      <wa>-seltext_m = 'N. Cliente'.
      <wa>-seltext_s = 'N. Cte'.
      <wa>-seltext_l = 'Fec. Creacion'.
    ELSEIF <wa>-fieldname EQ 'NAME1'.
      <wa>-tabname = 'IT_CREADOSH'.
      <wa>-seltext_m = 'Nombre'.
      <wa>-seltext_s = 'Nombre'.
      <wa>-seltext_l = 'Nombre Cliente'.
    ELSEIF <wa>-fieldname EQ 'BSARK'.
      <wa>-tabname = 'IT_CREADOSH'.
      <wa>-seltext_m = 'Tip. Pedido'.
      <wa>-seltext_s = 'Tip. Pedido'.
      <wa>-seltext_l = 'Tipo Pedido'.
    ELSE.
      <wa>-tabname = 'IT_CREADOS'.
    ENDIF.

    IF <wa>-fieldname EQ 'MATNR'.
      <wa>-outputlen = 10.
    ELSEIF <wa>-fieldname EQ 'WAERS'.
      <wa>-outputlen = 3.
    ELSEIF <wa>-fieldname EQ 'NETPR'.
      <wa>-seltext_s = 'Precio'.
      <wa>-seltext_m = 'Precio'.
      <wa>-seltext_l = 'Precio Unit.'.
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM layout_build.
  lf_layout-zebra               = 'X'.   " Streifenmuster
  lf_layout-get_selinfos        = 'X'.
  lf_layout-expand_fieldname = 'IND'.
  lf_layout-expand_all = 'X'.
  lf_layout-colwidth_optimize = 'X'.
ENDFORM. " LAYOUT_BUILD
*&---------------------------------------------------------------------*
*& Form tickets_nocreados
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM tickets_nocreados .

  SELECT h~fecha h~werks h~ticket p~pos p~auart
  p~vkorg p~vtweg p~spart p~route p~lgort p~bstdk
  p~sold p~name1 p~bmeng p~kbetr p~message
  INTO TABLE it_nocreados
 FROM zsd_tt_logsanh AS h
  INNER JOIN zsd_tt_logsanp AS p ON p~ticket EQ h~ticket
 WHERE h~ticket IN SO_tick
  AND werks IN so_werks
  AND fecha IN so_fecha.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fieldcat_nc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_fieldcat_nc .
  CLEAR wa_fieldcat.
  REFRESH gt_fieldcat.


  wa_fieldcat-fieldname = 'FECHA'.
  wa_fieldcat-col_pos = 1.
  wa_fieldcat-seltext_l = 'Fecha'.
  wa_fieldcat-seltext_m = 'Fecha'.
  wa_fieldcat-seltext_s = 'Fecha'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-col_pos = 2.
  wa_fieldcat-seltext_l = 'Centro'.
  wa_fieldcat-seltext_m = 'Centro'.
  wa_fieldcat-seltext_s = 'Centro'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'TICKET'.
  wa_fieldcat-col_pos = 3.
  wa_fieldcat-seltext_l = 'Ticket San'.
  wa_fieldcat-seltext_m = 'Ticket san'.
  wa_fieldcat-seltext_s = 'Ticket'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'POS'.
  wa_fieldcat-col_pos = 4.
  wa_fieldcat-seltext_l = 'Posicion'.
  wa_fieldcat-seltext_m = 'Posicion'.
  wa_fieldcat-seltext_s = 'Pos.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'AUART'.
  wa_fieldcat-col_pos = 5.
  wa_fieldcat-seltext_l = 'Cl. Doc.'.
  wa_fieldcat-seltext_m = 'Cl. Doc.'.
  wa_fieldcat-seltext_s = 'Cl.D.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VKORG'.
  wa_fieldcat-col_pos = 6.
  wa_fieldcat-seltext_l = 'Of. Vta.'.
  wa_fieldcat-seltext_m = 'Of. Vta.'.
  wa_fieldcat-seltext_s = 'Of. Vta.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'VTWEG'.
  wa_fieldcat-col_pos = 7.
  wa_fieldcat-seltext_l = 'C. Dist.'.
  wa_fieldcat-seltext_m = 'C. Dist.'.
  wa_fieldcat-seltext_s = 'C.Dist.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'SPART'.
  wa_fieldcat-col_pos = 8.
  wa_fieldcat-seltext_l = 'Sector'.
  wa_fieldcat-seltext_m = 'Sector'.
  wa_fieldcat-seltext_s = 'Sector'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ROUTE'.
  wa_fieldcat-col_pos = 9.
  wa_fieldcat-seltext_l = 'Ruta'.
  wa_fieldcat-seltext_m = 'Ruta'.
  wa_fieldcat-seltext_s = 'Ruta'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'LGORT'.
  wa_fieldcat-col_pos = 10.
  wa_fieldcat-seltext_l = 'Almacén'.
  wa_fieldcat-seltext_m = 'Almacén'.
  wa_fieldcat-seltext_s = 'Almacén'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BSTDK'.
  wa_fieldcat-col_pos = 11.
  wa_fieldcat-seltext_l = 'Fec. Ref. Cte.'.
  wa_fieldcat-seltext_m = 'Fec. Ref. Cte.'.
  wa_fieldcat-seltext_s = 'F.R.C.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'SOLD'.
  wa_fieldcat-col_pos = 12.
  wa_fieldcat-seltext_l = 'Num. Cte.'.
  wa_fieldcat-seltext_m = 'Num. Cte.'.
  wa_fieldcat-seltext_s = 'Cliente'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-col_pos = 13.
  wa_fieldcat-seltext_l = 'Nombre'.
  wa_fieldcat-seltext_m = 'Nombre'.
  wa_fieldcat-seltext_s = 'Nombre'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'BMENG'.
  wa_fieldcat-col_pos = 14.
  wa_fieldcat-seltext_l = 'Cantidad'.
  wa_fieldcat-seltext_m = 'Cantidad'.
  wa_fieldcat-seltext_s = 'Cant.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'KBETR'.
  wa_fieldcat-col_pos = 15.
  wa_fieldcat-seltext_l = 'Importe'.
  wa_fieldcat-seltext_m = 'Importe'.
  wa_fieldcat-seltext_s = 'Importe'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'MESSAGE'.
  wa_fieldcat-col_pos = 16.
  wa_fieldcat-seltext_l = 'Error'.
  wa_fieldcat-seltext_m = 'Error'.
  wa_fieldcat-seltext_s = 'Error'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat[]
    TABLES
      t_outtab           = it_nocreados
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_autorizacion
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SO_WERKS
*&---------------------------------------------------------------------*
FORM check_autorizacion.

  IF so_werks-high IS INITIAL.

    AUTHORITY-CHECK OBJECT 'ZWERKSSAN'
    ID 'BTCUNAME' FIELD  sy-uname
    ID 'WERKS' FIELD so_werks-low
    ID 'ACTVT' FIELD '03'.

    IF sy-subrc <> 0.
      MESSAGE 'No tiene autorización para la sociedad' TYPE 'E'.
    ENDIF.
  ELSE.

    SELECT werks INTO TABLE @DATA(it_werks) FROM t001w WHERE werks IN @so_werks.

    CLEAR so_werks.
    refresh so_werks.

    LOOP AT it_werks INTO DATA(wa_werks).
      AUTHORITY-CHECK OBJECT 'ZWERKSSAN'
        ID 'BTCUNAME' FIELD  sy-uname
        ID 'WERKS' FIELD wa_werks-werks
        ID 'ACTVT' FIELD '03'.

      IF sy-subrc EQ 0.

        so_werks-sign = 'I'.
        so_werks-option = 'EQ'.
        so_werks-low = wa_werks-werks.
        APPEND so_werks.

      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.
