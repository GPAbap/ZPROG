*&---------------------------------------------------------------------*
*& Include zpp_re_renorddep_fun
*&---------------------------------------------------------------------*


FORM get_data.

  FIELD-SYMBOLS: <fs_struct> TYPE  st_outtable.
  DATA: it_acum TYPE STANDARD TABLE OF st_outtable,
        wa_acum LIKE LINE OF it_acum.
  REFRESH it_outtable.

  SELECT DISTINCT p~pwerk, p~ltrmi, p~aufnr,
  CASE WHEN m~bwart = '261' OR m~bwart = '262' THEN
  CASE WHEN m~bwart = '262' THEN m~/cwm/menge * -1 ELSE m~/cwm/menge END END  AS consumido,
  wemng AS pt,
  CASE WHEN m~bwart = '531' OR m~bwart = '532' THEN
   CASE WHEN m~bwart = '532' THEN m~erfmg * -1 ELSE m~erfmg END END  AS decomiso
  INTO TABLE @DATA(it_auxiliar)
  FROM afko AS a
  INNER JOIN afpo AS p ON p~aufnr = a~aufnr
  INNER JOIN resb AS r ON r~aufnr = a~aufnr
  INNER JOIN mseg AS m ON m~aufnr = a~aufnr
  WHERE a~aufnr IN @s_aufnr
  AND p~ltrmi IN @s_ltrmi
  AND pwerk IN @s_pwerk
  .

  LOOP AT it_auxiliar INTO DATA(wa_auxiliar).
    CLEAR wa_acum.
    wa_acum-pwerks = wa_auxiliar-pwerk.
    wa_acum-ltrmi = wa_auxiliar-ltrmi.
    wa_acum-aufnr = wa_auxiliar-aufnr.
    wa_acum-consumido = wa_auxiliar-consumido.
    wa_acum-decomiso = wa_auxiliar-decomiso.
    COLLECT wa_acum INTO it_acum.

  ENDLOOP.


  LOOP AT it_acum ASSIGNING <fs_struct>.
    READ TABLE it_auxiliar INTO wa_auxiliar WITH KEY pwerk = <fs_struct>-pwerks ltrmi = <fs_struct>-ltrmi aufnr = <fs_struct>-aufnr.
    IF sy-subrc EQ 0.
      <fs_struct>-pt = wa_auxiliar-pt.
    ENDIF.

    <fs_struct>-diferencia = <fs_struct>-consumido - <fs_struct>-pt - <fs_struct>-decomiso.

    IF <fs_struct>-consumido GT 0.

      <fs_struct>-porcentaje = ( <fs_struct>-diferencia / <fs_struct>-consumido ) * 100.
      <fs_struct>-rendimiento = ( <fs_struct>-pt / <fs_struct>-consumido ) * 100.
      <fs_struct>-porc_decom = ( <fs_struct>-decomiso / <fs_struct>-consumido ) * 100.

    ENDIF.
  ENDLOOP.

  it_outtable[] = it_acum[].



ENDFORM.


FORM set_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'PWERKS'.
  wa_fieldcat-seltext_s = 'Centro'.
  wa_fieldcat-seltext_m = 'Centro'.
  wa_fieldcat-seltext_l = 'Centro'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'LTRMI'.
  wa_fieldcat-seltext_s = 'Fecha'.
  wa_fieldcat-seltext_m = 'Fecha'.
  wa_fieldcat-seltext_l = 'Fecha'.
  APPEND wa_fieldcat TO gt_fieldcat.
  wa_fieldcat-fieldname = 'AUFNR'.
  wa_fieldcat-seltext_s = 'Orden'.
  wa_fieldcat-seltext_m = 'Orden'.
  wa_fieldcat-seltext_l = 'Orden'.
  APPEND wa_fieldcat TO gt_fieldcat.

  wa_fieldcat-fieldname = 'CONSUMIDO'.
  wa_fieldcat-seltext_s = 'Kilos Pollo Vivo'.
  wa_fieldcat-seltext_m = 'Kilos Pollo Vivo'.
  wa_fieldcat-seltext_l = 'Kilos Pollo Vivo'.
  wa_fieldcat-decimals_out = '3'.
  wa_fieldcat-intlen = 15.
  APPEND wa_fieldcat TO gt_fieldcat.
  wa_fieldcat-fieldname = 'PT'.
  wa_fieldcat-seltext_s = 'Kilos de Venta'.
  wa_fieldcat-seltext_m = 'Kilos de Venta'.
  wa_fieldcat-seltext_l = 'Kilos de Venta'.
  wa_fieldcat-decimals_out = '3'.
  wa_fieldcat-intlen = 15.
    APPEND wa_fieldcat TO gt_fieldcat.
    wa_fieldcat-fieldname = 'RENDIMIENTO'.
  wa_fieldcat-seltext_s = 'Rendimiento'.
  wa_fieldcat-seltext_m = 'Rendimiento'.
  wa_fieldcat-seltext_l = 'Rendimiento'.
  wa_fieldcat-decimals_out = '3'.
  wa_fieldcat-intlen = 15.
  APPEND wa_fieldcat TO gt_fieldcat.
  wa_fieldcat-fieldname = 'DECOMISO'.
  wa_fieldcat-seltext_s = 'Kilos de Decomiso'.
  wa_fieldcat-seltext_m = 'Kilos de Decomiso'.
  wa_fieldcat-seltext_l = 'Kilos de Decomiso'.
  wa_fieldcat-intlen = 15.
  wa_fieldcat-decimals_out = '3'.
  APPEND wa_fieldcat TO gt_fieldcat.
  wa_fieldcat-fieldname = 'PORC_DECOM'.
  wa_fieldcat-seltext_s = '% Decomiso'.
  wa_fieldcat-seltext_m = '% Decomiso'.
  wa_fieldcat-seltext_l = '% Decomiso'.
  wa_fieldcat-intlen = 15.
  wa_fieldcat-decimals_out = '3'.
  APPEND wa_fieldcat TO gt_fieldcat.
  wa_fieldcat-fieldname = 'DIFERENCIA'.
  wa_fieldcat-seltext_s = 'Kgs.SyP'.
  wa_fieldcat-seltext_m = 'Kilos Sangre y Pluma'.
  wa_fieldcat-seltext_l = 'Kilos Sangre y Pluma'.
  wa_fieldcat-decimals_out = '3'.
  wa_fieldcat-intlen = 15.
  APPEND wa_fieldcat TO gt_fieldcat.
  wa_fieldcat-fieldname = 'PORCENTAJE'.
  wa_fieldcat-seltext_s = '% Sang. y Pluma'.
  wa_fieldcat-seltext_m = '% Sangre y Pluma'.
  wa_fieldcat-seltext_l = '% Sangre y Pluma'.
  wa_fieldcat-decimals_out = '3'.
  wa_fieldcat-intlen = 15.
  APPEND wa_fieldcat TO gt_fieldcat.
ENDFORM.

FORM show_alv.

  lf_layout-zebra = 'X'.
 " lf_layout-colwidth_optimize = 'X'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat
      i_save             = 'A'
    TABLES
      t_outtab           = it_outtable
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.


ENDFORM.
