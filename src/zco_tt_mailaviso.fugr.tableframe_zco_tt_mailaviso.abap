*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZCO_TT_MAILAVISO
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZCO_TT_MAILAVISO   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
