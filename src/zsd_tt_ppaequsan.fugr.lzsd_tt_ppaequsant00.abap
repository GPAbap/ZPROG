*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSD_TT_PPAEQUSAN................................*
DATA:  BEGIN OF STATUS_ZSD_TT_PPAEQUSAN              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSD_TT_PPAEQUSAN              .
CONTROLS: TCTRL_ZSD_TT_PPAEQUSAN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSD_TT_PPAEQUSAN              .
TABLES: ZSD_TT_PPAEQUSAN               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
