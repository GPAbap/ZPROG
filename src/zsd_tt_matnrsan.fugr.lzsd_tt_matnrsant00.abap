*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSD_TT_MATNRSAN.................................*
DATA:  BEGIN OF STATUS_ZSD_TT_MATNRSAN               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSD_TT_MATNRSAN               .
CONTROLS: TCTRL_ZSD_TT_MATNRSAN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSD_TT_MATNRSAN               .
TABLES: ZSD_TT_MATNRSAN                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
