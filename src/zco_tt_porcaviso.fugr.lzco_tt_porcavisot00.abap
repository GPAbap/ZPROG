*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_PORCAVISO................................*
DATA:  BEGIN OF STATUS_ZCO_TT_PORCAVISO              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_PORCAVISO              .
CONTROLS: TCTRL_ZCO_TT_PORCAVISO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_PORCAVISO              .
TABLES: ZCO_TT_PORCAVISO               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
