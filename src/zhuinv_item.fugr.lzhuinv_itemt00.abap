*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHUINV_ITEM.....................................*
DATA:  BEGIN OF STATUS_ZHUINV_ITEM                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHUINV_ITEM                   .
CONTROLS: TCTRL_ZHUINV_ITEM
            TYPE TABLEVIEW USING SCREEN '9999'.
*.........table declarations:.................................*
TABLES: *ZHUINV_ITEM                   .
TABLES: ZHUINV_ITEM                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
