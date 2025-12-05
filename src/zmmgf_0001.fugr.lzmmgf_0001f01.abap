*----------------------------------------------------------------------*
***INCLUDE LZMMGF_0001F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_BLOQ_UNBLOQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bloq_unbloq USING x_bloq.

  DATA:
    vl_cont TYPE i.

  DO.
    CLEAR tg_seqg3.
    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gclient               = sy-mandt
        guname                = sy-uname
      TABLES
        enq                   = tg_seqg3
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        OTHERS                = 3.

    vl_cont = vl_cont + 1.
    LOOP AT tg_seqg3 INTO sg_seqg3
    WHERE garg+3 = x_bloq.
    ENDLOOP.
    IF sy-subrc NE 0.
      EXIT.
    ELSE.
      IF vl_cont = 80000.
        EXIT.
      ENDIF.
    ENDIF.
  ENDDO.

ENDFORM.                    " F_BLOQ_UNBLOQ
