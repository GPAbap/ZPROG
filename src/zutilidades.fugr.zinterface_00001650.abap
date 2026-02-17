FUNCTION ZINTERFACE_00001650.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_POSTAB) LIKE  RFPOS STRUCTURE  RFPOS
*"  EXPORTING
*"     VALUE(E_POSTAB) LIKE  RFPOS STRUCTURE  RFPOS
*"----------------------------------------------------------------------
*{   INSERT         SPDK914528                                        1
*{   INSERT         SPDK914528                                        1
       e_postab = i_postab."                <-- importante
      CALL FUNCTION 'GET_GKONT'
           EXPORTING
            belnr           = i_postab-belnr
            bukrs           = i_postab-bukrs
            buzei           = i_postab-buzei
            gjahr           = i_postab-gjahr
            gknkz           = '3'
       IMPORTING
            gkont           = e_postab-gkont
            koart           = e_postab-gkart
       EXCEPTIONS
            belnr_not_found = 1
            buzei_not_found = 2
            gknkz_not_found = 3
            otros          = 4.

*      IF sy-subrc eq 0.
*        IF e_postab-gkont = 'D'.
          e_postab-zkunnr = e_postab-gkont.
*        ENDIF.


*      ENDIF.

*}   INSERT

*-------------- Initialize Output by using the following line ----------
* E_POSTAB = I_POSTAB.

*}   INSERT
ENDFUNCTION.
