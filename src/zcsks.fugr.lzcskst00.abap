*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCSKS...........................................*
DATA:  BEGIN OF STATUS_ZCSKS                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCSKS                         .
CONTROLS: TCTRL_ZCSKS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCSKS                         .
TABLES: ZCSKS                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
