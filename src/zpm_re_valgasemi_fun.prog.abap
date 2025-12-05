*&---------------------------------------------------------------------*
*& Include zpm_re_valgasemi_fun
*&---------------------------------------------------------------------*

FORM get_data.

  SELECT z~bukrs, e~ingrp, z~zcgas,z2~zdes, z~equnr,e2~eqktx, z~znval, z~zfech, z~zhras, z~mdocm
  INTO TABLE @it_vales
  FROM  zvale AS z
  INNER JOIN equz AS e ON e~equnr = z~equnr
  INNER JOIN zgas AS z2 ON z2~zcgas = z~zcgas
  INNER JOIN eqkt AS e2 ON e2~equnr = e~equnr
  WHERE  z~bukrs  = @bukrs_p
  AND    zfech IN @zfech_p
  AND    ingrp IN @ingrp_p.



  IF it_vales IS INITIAL.
    MESSAGE 'No se encontraron datos con los criterios establecidos' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.

FORM create_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'BUKRS'.
  wa_fieldcat-seltext_m = 'Sociedad'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'INGRP'.
  wa_fieldcat-seltext_m = 'Grp. Planif.'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ZCGAS'.
  wa_fieldcat-seltext_m = 'Gasolinera'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ZDES'.
  wa_fieldcat-seltext_m = 'Descripcion'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'EQUNR'.
  wa_fieldcat-seltext_m = 'Equipo'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'EQKTX'.
  wa_fieldcat-seltext_m = 'Descripcion'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ZNVAL'.
  wa_fieldcat-seltext_m = 'Num. Vale'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ZFECH'.
  wa_fieldcat-seltext_m = 'Fec. Emi. Vale'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'ZHRAS'.
  wa_fieldcat-seltext_m = 'Hr. Emi. Vale'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.

  wa_fieldcat-fieldname = 'MDOCM'.
  wa_fieldcat-seltext_m = 'Doc. Medición'.
  APPEND wa_fieldcat TO gt_fieldcat.CLEAR wa_fieldcat.
ENDFORM.


FORM show_alv.

  lf_layout-zebra = 'X'.
  lf_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
      is_layout          = lf_layout
      it_fieldcat        = gt_fieldcat
    TABLES
      t_outtab           = it_vales
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
