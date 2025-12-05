FUNCTION get_number_weeks.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(P_FECHA) TYPE  SY-DATUM
*"  EXPORTING
*"     REFERENCE(NUM_WEEK) TYPE  I
*"----------------------------------------------------------------------
  DATA: lv_date          TYPE sy-datum,
        lv_week          LIKE scal-week,
        lv_first_week    LIKE  scal-week,
        lv_week_of_month TYPE i.

  " Step 1: Get a date from the previous year
  lv_date = p_fecha. " Adjust for leap years if needed

  " Step 2: Get the week number of the given date
  CALL FUNCTION 'DATE_GET_WEEK'
    EXPORTING
      date = lv_date
    IMPORTING
      week = lv_week.

*  " Step 3: Calculate the first day of the month for that date
*  DATA(lv_first_day_of_month) = lv_date.
*  lv_first_day_of_month+6(2) = '01'. " Set day to 1st of the month
*
*  " Step 4: Get the week number for the first day of the month
*  CALL FUNCTION 'DATE_GET_WEEK'
*    EXPORTING
*      date = lv_first_day_of_month
*    IMPORTING
*      week = lv_first_week.

  " Step 5: Calculate the week number of the month
*  lv_week_of_month = lv_week - lv_first_week + 1.
*
*  WRITE: / 'Date:', lv_date,
*  / 'Week Number of Month:', lv_week_of_month.

  lv_week_of_month = lv_week+4(2).
  num_week = lv_week_of_month.



ENDFUNCTION.
