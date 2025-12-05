FUNCTION-POOL ZMCWM.                        "MESSAGE-ID ..

* INCLUDE LZMCWMD...                         " Local class definition

*........Konstanten allgemein...........................................
DATA:    CON_X(1)    TYPE C VALUE 'X',
         INIT_TIME   LIKE LTAK-BZEIT.

*........Konstanten zur allgemeinen Steuerung...........................
DATA:    CON_SUHIE_KOPF_WM     VALUE 'M',
         CON_SUHIE_POSITION_WM VALUE 'N',
         CON_STAFO LIKE TMC2D-STAFO VALUE '000009',
         CON_MIN   LIKE MCWMIT-LZEIT VALUE 'MIN',
         LIS_UPD.
