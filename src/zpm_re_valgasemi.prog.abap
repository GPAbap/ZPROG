*&---------------------------------------------------------------------*
*& Report zpm_re_valgasemi
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpm_re_valgasemi.
include zpm_re_valgasemi_top.
include zpm_re_valgasemi_fun.

at selection-screen.
 SELECT SINGLE BUKRS INTO @DATA(vl_bukrs)
   FROM T001
  WHERE  bukrs = @bukrs_p.
if vl_bukrs is INITIAL.
    MESSAGE 'Sociedad no Existe' type 'E'.
ENDIF.


START-OF-SELECTION.
* Valida Gasolinera
  PERFORM get_data.
  PERFORM create_fieldcat.
  PERFORM show_alv.

END-OF-SELECTION.
