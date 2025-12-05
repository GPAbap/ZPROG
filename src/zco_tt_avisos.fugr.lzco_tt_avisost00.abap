*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_AVISOS...................................*
DATA:  BEGIN OF STATUS_ZCO_TT_AVISOS                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_AVISOS                 .
CONTROLS: TCTRL_ZCO_TT_AVISOS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_AVISOS                 .
TABLES: ZCO_TT_AVISOS                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
