*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_MATNRPRES................................*
DATA:  BEGIN OF STATUS_ZCO_TT_MATNRPRES              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_MATNRPRES              .
CONTROLS: TCTRL_ZCO_TT_MATNRPRES
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_MATNRPRES              .
TABLES: ZCO_TT_MATNRPRES               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
