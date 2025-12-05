*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_MAILAVISO................................*
DATA:  BEGIN OF STATUS_ZCO_TT_MAILAVISO              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_MAILAVISO              .
CONTROLS: TCTRL_ZCO_TT_MAILAVISO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_MAILAVISO              .
TABLES: ZCO_TT_MAILAVISO               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
