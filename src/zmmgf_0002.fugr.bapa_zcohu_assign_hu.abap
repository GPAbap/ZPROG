FUNCTION bapa_zcohu_assign_hu.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_AUFNR) TYPE  AUFK-AUFNR OPTIONAL
*"     VALUE(I_EXIDV) TYPE  VEKP-EXIDV OPTIONAL
*"  TABLES
*"      T_BEREITHU STRUCTURE  BEREITHU OPTIONAL
*"      T_AFVC STRUCTURE  AFVC OPTIONAL
*"      T_RESB STRUCTURE  RESB OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  CALL FUNCTION 'COHU_ASSIGN_HU'
    EXPORTING
      i_aufnr    = i_aufnr
      i_exidv    = i_exidv
    TABLES
      t_bereithu = t_bereithu
      t_afvc     = t_afvc
      t_resb     = t_resb
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

ENDFUNCTION.
