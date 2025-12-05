*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPP_MTECH2SAP...................................*
DATA:  BEGIN OF STATUS_ZPP_MTECH2SAP                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPP_MTECH2SAP                 .
CONTROLS: TCTRL_ZPP_MTECH2SAP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPP_MTECH2SAP                 .
TABLES: ZPP_MTECH2SAP                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
