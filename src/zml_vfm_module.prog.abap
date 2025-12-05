*&---------------------------------------------------------------------*
*&  Include           ML_VFM_MODULE                                    *
*&---------------------------------------------------------------------*
*4.70
*SLP7EK007998  290506 see note 912984
*HOMALNK005514 171001 Retrofit XBA

*&---------------------------------------------------------------------*
*&      Module  pbo_0042  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_0042 OUTPUT.

  PERFORM screen_0042_initialize.
  CASE ckml_vfm-view.
    WHEN 'MO' OR 'NV'.
      PERFORM free_grid.
      IF alv_tree IS INITIAL.
        PERFORM compressor USING    ckml_vfm-view
                           CHANGING t_tree_compressor[]
                                    t_tree_data[].
        PERFORM fieldcat_fill.
        PERFORM tree_controls_create.
        PERFORM tree_initialize.
        PERFORM tree_toolbar_change.
        PERFORM tree_events_register.
        PERFORM tree_show.
      ENDIF.
    WHEN 'FM'.
      PERFORM free_tree.
      IF alv_grid IS INITIAL.
        PERFORM compressor USING    ckml_vfm-view
                           CHANGING t_tree_compressor[]
                                    t_tree_data[].
        PERFORM fieldcat_fill.
        PERFORM grid_controls_create.
        PERFORM grid_toolbar_change.
        PERFORM grid_show.
        PERFORM grid_events_register.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " pbo_0042  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pai_0042  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_0042 INPUT.

  PERFORM user_command_0042.

ENDMODULE.                 " pai_0042  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0042  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0042 INPUT.

  PERFORM exit_command_0042.


ENDMODULE.                 " exit_command_0042  INPUT
*&---------------------------------------------------------------------*
*&      Module  f4_fuer_curtp  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_fuer_curtp INPUT.

  REFRESH: t_curtp_f4.

  IF NOT h_last_bwkey IS INITIAL.
    CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
       EXPORTING
            bwkey             = h_last_bwkey
*           CALL_BY_INIT_PROG = ' '
*           I_CUSTOMIZING     = ' '
       TABLES
            t_curtp_for_va    = t_curtp
       EXCEPTIONS
            bwkey_not_found   = 1
            bwkey_not_active  = 2
            matled_not_found  = 3
            internal_error    = 4
            more_than_3_curtp = 5
            OTHERS            = 6
            .
    IF sy-subrc <> 0.
*     Keine Message in F4-Hilfen!
*     MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
*             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    LOOP AT t_curtp.
      CLEAR: t_curtp_f4.
      t_curtp_f4 = t_curtp-curtp.
      t_curtp_f4-text = t_curtp-text.
      APPEND t_curtp_f4.
    ENDLOOP.
    mlkey-curtp = '10'.
  ELSEIF h_last_bwkey IS INITIAL.
    SELECT SINGLE * FROM ckmlcur
                    WHERE sprsl = sy-langu
                    AND   curtp = '10'.
    CLEAR: t_curtp_f4.
    t_curtp_f4-curtp = '10'.
    t_curtp_f4-text = ckmlcur-ddtext.
    APPEND t_curtp_f4.
    mlkey-curtp = '10'.
  ENDIF.
  READ TABLE t_curtp_f4 WITH KEY curtp = mlkey-curtp
                        TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0 OR
     mlkey-curtp IS INITIAL.
    mlkey-curtp = '10'.
  ENDIF.
  IF NOT t_curtp_f4[] IS INITIAL.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
         EXPORTING
*             DDIC_STRUCTURE   = ' '
              retfield         = 'CURTP'
*             PVALKEY          = ' '
              dynpprog         = 'ML_VALUE_FLOW_MONITOR'
              dynpnr           = '0042'
              dynprofield      = 'MLKEY-CURTP'
*             STEPL            = 0
*             WINDOW_TITLE     =
*             VALUE            = ' '
              value_org        = 'S'
*             MULTIPLE_CHOICE  = ' '
*             DISPLAY          = ' '
*             CALLBACK_PROGRAM = ' '
*             CALLBACK_FORM    = ' '
         TABLES
              value_tab        = t_curtp_f4
*             FIELD_TAB        =
*             RETURN_TAB       =
*             DYNPFLD_MAPPING  =
*        EXCEPTIONS
*             PARAMETER_ERROR  = 1
*             NO_VALUES_FOUND  = 2
*             OTHERS           = 3
              .
  ENDIF.

ENDMODULE.                 " f4_fuer_curtp  INPUT
