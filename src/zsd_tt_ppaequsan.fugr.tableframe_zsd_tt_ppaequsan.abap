*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSD_TT_PPAEQUSAN
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSD_TT_PPAEQUSAN   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
