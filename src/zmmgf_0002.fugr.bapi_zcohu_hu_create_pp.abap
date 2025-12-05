FUNCTION bapi_zcohu_hu_create_pp.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_AUFNR) TYPE  AFKO-AUFNR OPTIONAL
*"     VALUE(I_VELIN) TYPE  VEPO-VELIN DEFAULT '1'
*"     VALUE(I_COMMIT) TYPE  XFELD DEFAULT 'X'
*"     VALUE(I_NO_QUAN_CHECK) TYPE  XFELD DEFAULT 'X'
*"  TABLES
*"      T_EXBEREIT STRUCTURE  EXBEREIT OPTIONAL
*"  EXCEPTIONS
*"      HU_CREATE_ERROR
*"----------------------------------------------------------------------

  CALL FUNCTION 'COHU_HU_CREATE_PP'
    EXPORTING
      i_aufnr         = i_aufnr
      i_velin         = i_velin
      i_commit        = i_commit
      i_no_quan_check = i_no_quan_check
    TABLES
      t_exbereit      = t_exbereit
    EXCEPTIONS
      hu_create_error = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    RAISE hu_create_error.
  ENDIF.

ENDFUNCTION.
