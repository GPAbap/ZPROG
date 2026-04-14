*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_TT_TARJETAS.................................*
DATA:  BEGIN OF STATUS_ZPM_TT_TARJETAS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_TT_TARJETAS               .
CONTROLS: TCTRL_ZPM_TT_TARJETAS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_TT_TARJETAS               .
TABLES: ZPM_TT_TARJETAS                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
