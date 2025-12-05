*&---------------------------------------------------------------------*
*& Report ZMM_AMPLIA_MATERIALES_MASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_amplia_materiales_mass.
INCLUDE ZMM_AMPLIA_MATERIALES_MASS_top.
INCLUDE ZMM_AMPLIA_MATERIALES_MASS_fun.



START-OF-SELECTION.

IF getdata = 'X'.
  PERFORM download_data.
  PERFORM download_file. "This File provides a log for the list of material data extended
ENDIF.

IF upddata = 'X'.
  PERFORM upload_file.
  PERFORM update_mm.
ENDIF.
