*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_AUTPRES..................................*
DATA:  BEGIN OF STATUS_ZCO_TT_AUTPRES                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_AUTPRES                .
CONTROLS: TCTRL_ZCO_TT_AUTPRES
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_AUTPRES                .
TABLES: ZCO_TT_AUTPRES                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
