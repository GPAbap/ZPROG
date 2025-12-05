*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_AGRIC_SOC...................................*
DATA:  BEGIN OF STATUS_ZCO_AGRIC_SOC                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_AGRIC_SOC                 .
CONTROLS: TCTRL_ZCO_AGRIC_SOC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCO_AGRIC_SOC                 .
TABLES: ZCO_AGRIC_SOC                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
