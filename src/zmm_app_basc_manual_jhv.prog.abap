*&---------------------------------------------------------------------*
*& Report ZMM_APP_BASC_MANUAL_JHV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMM_APP_BASC_MANUAL_JHV MESSAGE-ID 00..

*---*---* INCLUDE PARA PARAMETROS DE SELECCIÓN Y PANTALLA INICIAL
INCLUDE z_basculas_n_s01.
include ZMM_APP_BASC_MANUAL_TOP.
include ZMM_APP_BASC_MANUAL_FUN.

AT SELECTION-SCREEN OUTPUT.
  PERFORM par_seleccion.

INITIALIZATION.
  pwd = TEXT-s01.
LOOP AT SCREEN.
  IF SCREEN-name = 'P_NOMBRE'.
    SCREEN-INPUT = 0.
    MODIFY SCREEN.
    exit.
  ENDIF.
ENDLOOP.

START-OF-SELECTION.
  PERFORM procesa_informacion.

END-OF-SELECTION.

INCLUDE zmm_app_basc_manual_mod.

*&SPWizard: Data incl. inserted by SP Wizard. DO NOT CHANGE THIS LINE!
INCLUDE ZMM_APP_BASC_MANUAL_DAT .
*&SPWizard: Include inserted by SP Wizard. DO NOT CHANGE THIS LINE!
INCLUDE ZMM_APP_BASC_MANUAL_PBO .
INCLUDE ZMM_APP_BASC_MANUAL_PAI .
