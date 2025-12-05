*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZCO_TT_J_AGRI
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZCO_TT_J_AGRI      .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
