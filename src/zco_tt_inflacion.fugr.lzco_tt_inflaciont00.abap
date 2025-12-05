*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_INFLACION................................*
DATA:  BEGIN OF STATUS_ZCO_TT_INFLACION              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_INFLACION              .
CONTROLS: TCTRL_ZCO_TT_INFLACION
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_INFLACION              .
TABLES: ZCO_TT_INFLACION               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
