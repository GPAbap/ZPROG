*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_CECOAUT..................................*
DATA:  BEGIN OF STATUS_ZCO_TT_CECOAUT                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_CECOAUT                .
CONTROLS: TCTRL_ZCO_TT_CECOAUT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_CECOAUT                .
TABLES: ZCO_TT_CECOAUT                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
