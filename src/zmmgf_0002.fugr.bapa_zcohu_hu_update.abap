FUNCTION bapa_zcohu_hu_update.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_AUFNR) TYPE  AUFK-AUFNR OPTIONAL
*"     VALUE(I_SYNCHRON) TYPE  XFELD OPTIONAL
*"     VALUE(I_CHECK) TYPE  XFELD OPTIONAL
*"     VALUE(I_NO_HU_UPDATE) TYPE  XFELD DEFAULT SPACE
*"     VALUE(I_CANCEL) TYPE  XFELD DEFAULT SPACE
*"     VALUE(I_PI_SHEET) TYPE  XFELD OPTIONAL
*"  EXPORTING
*"     VALUE(BATCH_DATA_ONLY) TYPE  XFELD
*"  TABLES
*"      T_RESB STRUCTURE  RESB OPTIONAL
*"      T_AFVC STRUCTURE  AFVC OPTIONAL
*"  EXCEPTIONS
*"      NOT_NECESSARY
*"      ERROR
*"----------------------------------------------------------------------

  CALL FUNCTION 'COHU_HU_UPDATE'
    EXPORTING
      i_aufnr         = i_aufnr
      i_synchron      = i_synchron
      i_check         = i_check
      i_no_hu_update  = i_no_hu_update
      i_cancel        = i_cancel
      i_pi_sheet      = i_pi_sheet
    IMPORTING
      batch_data_only = batch_data_only
    TABLES
      t_resb          = t_resb
      t_afvc          = t_afvc
    EXCEPTIONS
      not_necessary   = 1
      error           = 2
      OTHERS          = 3.

ENDFUNCTION.
