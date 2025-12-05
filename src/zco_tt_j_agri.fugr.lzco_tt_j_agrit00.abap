*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_J_AGRI...................................*
DATA:  BEGIN OF STATUS_ZCO_TT_J_AGRI                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_J_AGRI                 .
CONTROLS: TCTRL_ZCO_TT_J_AGRI
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_J_AGRI                 .
TABLES: ZCO_TT_J_AGRI                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
