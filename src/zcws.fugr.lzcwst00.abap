*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCWS............................................*
DATA:  BEGIN OF STATUS_ZCWS                          .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCWS                          .
CONTROLS: TCTRL_ZCWS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCWS                          .
TABLES: ZCWS                           .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
