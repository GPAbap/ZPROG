report ZBICO_KS02
       no standard page heading line-size 255.
data: begin of bdc_data occurs 500.
  include structure bdcdata.
data: end of bdc_data.
***   DECLARACION DE TABLA INTERNA
data: begin of rec occurs 1000,     " Estructura para archivo plano
  kokrs(4) type c,               " Sociedad CO *
  bukrs(4) type c,
  kostl(10),               " Centro de Coste *
  pernr(8),
end of rec.
data: type like rlgrap-filetype value 'ASC'.
data: length type i.
*-----------  P A R A M E T R O S   -----------------*
selection-screen begin of block block1 with frame title text-001.
  parameters:
    archivo like rlgrap-filename default
    'D:\Documents\4 Datos\CeCos aXXX.prn'.
selection-screen end of block block1.
*-----------  P R O G.    P R I N C I P A L   -----------------*
*carga archivo a tabla internas
*Llena tabla TAB_INT
call function 'WS_UPLOAD'
   exporting
      filename             = archivo
      filetype             = type
   importing
      filelength           = length
      tables
   data_tab                = rec.
* RUTINA PRINCIPAL
start-of-selection.
   perform open_group.
   loop at rec.
      refresh bdc_data.
      perform pantalla_0200.
      perform bdc_transaction using 'KS02'.
   endloop.
   perform close_group.
end-of-selection.

*-----------------------------------------------------------------------
*   PERFORM OPEN_GROUP.
*-----------------------------------------------------------------------
form open_group.
   call function 'BDC_OPEN_GROUP'
      exporting
         client              = sy-mandt
         group               = 'CECO'
         user                = sy-uname
      exceptions
         client_invalid      = 1
         destination_invalid = 2
         group_invalid       = 3
         group_is_locked     = 4
         holddate_invalid    = 5
         internal_error      = 6
         queue_error         = 7
         running             = 8
         system_lock_error   = 9
         user_invalid        = 10
         others              = 11.
endform.                    " OPEN_GROUP
form pantalla_0200.
*
perform bdc_dynpro using 'SAPLKMA1' '0200'.
perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-KOSTL'.
perform bdc_field  using 'BDC_OKCODE' '/00'.
perform bdc_field  using 'CSKSZ-KOKRS' rec-kokrs.
perform bdc_field  using 'CSKSZ-KOSTL' rec-kostl.
*
perform bdc_dynpro using 'SAPLKMA1' '0299'.
perform bdc_field  using 'BDC_OKCODE' '=KOMM'.
perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-KTEXT'.
*
perform bdc_dynpro using 'SAPLKMA1' '0299'.
perform bdc_field  using 'BDC_OKCODE' '=ADRE'.
perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-SPRAS'.
*
perform bdc_dynpro using 'SAPLKMA1' '0299'.
perform bdc_field  using 'BDC_OKCODE' '=BU'.
perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-NAME1'.
perform bdc_field  using 'CSKSZ-NAME1' rec-pernr.
endform.
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
form bdc_transaction using tcode.
   call function 'BDC_INSERT'
      exporting
         tcode            = tcode
         tables
         dynprotab        = bdc_data
      exceptions
         internal_error   = 1
         not_open         = 2
         queue_error      = 3
         tcode_invalid    = 4
         printing_invalid = 5
         posting_invalid  = 6
         others           = 7.
endform.                    " BDC_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  CLOSE_GROUP
*&---------------------------------------------------------------------*
form close_group.
   call function 'BDC_CLOSE_GROUP'
      exceptions
         not_open    = 1
         queue_error = 2
         others      = 3.
endform.                    " CLOSE_GROUP
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
form bdc_field using program dynpro.
   clear bdc_data.
   bdc_data-fnam = program.
   bdc_data-fval = dynpro.
   append bdc_data.
endform.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
form bdc_dynpro using program dynpro.
   clear bdc_data.
   bdc_data-program = program.
   bdc_data-dynpro  = dynpro.
   bdc_data-dynbegin = 'X'.
   append bdc_data.
endform.                    " BDC_DYNPRO
