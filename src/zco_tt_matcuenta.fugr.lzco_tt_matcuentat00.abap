*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCO_TT_MATCUENTA................................*
DATA:  BEGIN OF STATUS_ZCO_TT_MATCUENTA              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCO_TT_MATCUENTA              .
CONTROLS: TCTRL_ZCO_TT_MATCUENTA
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZCO_TT_MATCUENTA              .
TABLES: ZCO_TT_MATCUENTA               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
