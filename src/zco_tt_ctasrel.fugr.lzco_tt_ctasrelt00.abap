*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_CTASREL..................................*
DATA:  BEGIN OF STATUS_ZCO_TT_CTASREL                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_CTASREL                .
CONTROLS: TCTRL_ZCO_TT_CTASREL
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_CTASREL                .
TABLES: ZCO_TT_CTASREL                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
