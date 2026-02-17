*&---------------------------------------------------------------------*
*& Include ZMM_APP_BASC_MANUAL_PBO
*&---------------------------------------------------------------------*

*&SPWIZARD: OUTPUT MODULE FOR TC 'TBC_EBELP'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE TBC_EBELP_INIT OUTPUT.
  IF G_TBC_EBELP_COPIED IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZMM_TT_BASCM_SAL'
*&SPWIZARD: INTO INTERNAL TABLE 'g_TBC_EBELP_itab'
*    SELECT * FROM ZMM_TT_BASCM_SAL
*       INTO CORRESPONDING FIELDS
*       OF TABLE G_TBC_EBELP_ITAB.
    G_TBC_EBELP_COPIED = 'X'.
    clear vg_flag_cons.
    REFRESH CONTROL 'TBC_EBELP' FROM SCREEN '0101'.
  ENDIF.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TBC_EBELP'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE TBC_EBELP_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TBC_EBELP_WA TO ZMM_TT_BASCM_SAL.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
SET PF-STATUS 'STATUS100'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
