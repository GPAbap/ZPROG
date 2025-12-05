FUNCTION ZL_MC_TIME_DIFFERENCE.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(DATE_FROM) LIKE  LTAK-BDATU
*"     VALUE(DATE_TO) LIKE  LTAK-BDATU
*"     VALUE(TIME_FROM) LIKE  LTAK-BZEIT OPTIONAL
*"     VALUE(TIME_TO) LIKE  LTAK-BZEIT OPTIONAL
*"  EXPORTING
*"     VALUE(DELTA_TIME) TYPE  ZDECIMAL3
*"     VALUE(DELTA_UNIT) LIKE  MCWMIT-LZEIT
*"  EXCEPTIONS
*"      FROM_GREATER_TO
*"----------------------------------------------------------------------
DATA: DELTA_T       TYPE ZDECIMAL3,
      DELTA_DAY     TYPE I,
      CON_DM        TYPE I VALUE 1440,   "days in minutes
      CON_SM        TYPE I VALUE 60.     "seconds in minutes

*........Prüfe, ob Date/Time1 <= Date/Time2.............................
  IF DATE_FROM > DATE_TO OR
   ( DATE_FROM = DATE_TO AND
     TIME_FROM > TIME_TO ).

    RAISE FROM_GREATER_TO.

  ENDIF.

*........Differenz ausrechnen...........................................
  DELTA_DAY  = ( DATE_TO - DATE_FROM ) * CON_DM.
  DELTA_T    = ( TIME_TO - TIME_FROM ) / CON_SM.

  DELTA_TIME = DELTA_DAY + DELTA_T.
  DELTA_UNIT = CON_MIN.

ENDFUNCTION.
