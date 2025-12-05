************************************************************************
* EMPRESA:      GRUPO PORRES DIVISION AZUCAR
* PROGRAMA:     ZRCO0030
* DESCRIPCION:  COMPARACIÓN PLAN REAL PARA CENTROS DE COSTO Y CUENTAS
* AUTOR:        MARIA DEL CARMEN OCOTLAN GUZMAN MEDINA
* FECHA:        NOVIEMBRE DEL 2018
************************************************************************
REPORT ZFI_NOBLOQUEO_PRES MESSAGE-ID ZE LINE-SIZE 255 LINE-COUNT 65.
TABLES:
  zcsks,         " Centros de Costo Específicos
  csks,          " Centros de Costo
  COSP.          " Objeto CO: Totales de costes
data: begin of bdc_data occurs 500.
  include structure bdcdata.
data: end of bdc_data.
data:
  ban value 0.
data: begin of tab occurs 0,
  kokrs like zcsks-kokrs,
  kostl like zcsks-kostl,
end of tab.
*&---------------------------------------------------------------------*
*&     INICIO PROGRAMA
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  SELECT * FROM  zcsks
    where kokrs BETWEEN 'GA00' and 'GA09'.
    if sy-subrc = 0.
      MOVE-CORRESPONDING zcsks to tab.
      APPEND tab.
    endif.
  ENDSELECT.
  LOOP AT tab.
    perform valida.
* invertir bloqueo
    if ban = 1.
      refresh bdc_data.
      perform bloqueo.
      ban = 0.
    ENDIF.
  ENDLOOP.
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  BLOQUEO
*&---------------------------------------------------------------------*
FORM BLOQUEO .
* Dynpro
**perform bdc_dynpro using 'SAPLKMA1' '0200'.
**perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-KOKRS'.
**perform bdc_field  using 'BDC_OKCODE' '=GRUN'.
**perform bdc_field  using 'CSKSZ-KOKRS' tab-kokrs.
**perform bdc_field  using 'CSKSZ-KOSTL' tab-kostl.
** Dynpro
** perform bdc_dynpro using 'SAPLKMA1' '0299'.
** perform bdc_field  using 'BDC_OKCODE' '=KZEI'.
** perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-KTEXT'.
** Dynpro
** perform bdc_dynpro using 'SAPLKMA1' '0299'.
** perform bdc_field  using 'BDC_OKCODE' '=BU'.
** perform bdc_field  using 'BDC_CURSOR' 'CSKSZ-BKZKS'.
** perform bdc_field  using 'CSKSZ-BKZKP' ' '.
** perform bdc_field  using 'CSKSZ-BKZKS' ' '.
** call transaction 'KS02' using bdc_data mode 'E'.
* call transaction 'KS02' using bdc_data mode 'A'.

DATA: vl_CONTROLLINGAREA LIKE bapi0012_gen-co_area,
        it_COSTCENTERLIST  TYPE STANDARD TABLE OF bapi0012_ccinputlist,
        wa_COSTCENTERLIST  LIKE LINE OF it_COSTCENTERLIST,
        it_RETURN          TYPE STANDARD TABLE OF bapiret2.

 vl_controllingarea = tab-kokrs.
  wa_costcenterlist-costcenter = tab-kostl.
  wa_costcenterlist-valid_from = '20220101'.
  wa_costcenterlist-valid_to = '99991231'.
  wa_costcenterlist-lock_ind_actual_primary_costs = ' '.
  wa_costcenterlist-lock_ind_act_secondary_costs = ' '.

  APPEND wa_costcenterlist TO it_costcenterlist.

  CALL FUNCTION 'BAPI_COSTCENTER_CHANGEMULTIPLE'
    EXPORTING
      controllingarea = vl_controllingarea
    TABLES
      costcenterlist  = it_costcenterlist
      return          = it_return
     .

   IF IT_RETURN[] IS NOT INITIAL.
     READ TABLE it_return into data(wa) WITH KEY TYPE = 'E'.
     IF sy-subrc ne 0.
       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT          = 'X'
        .

     ENDIF.
  ENDIF.

ENDFORM.                    " BLOQUEO
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
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BUSCACECO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUSCACECO .
  SELECT single * FROM  csks
  WHERE  kokrs  = tab-kokrs
  AND    kostl  = tab-kostl
  AND    datbi  = '99991231'.
  if sy-subrc = 0.
  endif.
ENDFORM.                    " BUSCACECO
*&---------------------------------------------------------------------*
*&      Form  VALIDA
*&---------------------------------------------------------------------*
*  Valida que el CeCo esté desbloqueado
*----------------------------------------------------------------------*
FORM VALIDA .
  SELECT single * FROM  csks
  WHERE  kokrs  = tab-kokrs
  AND    kostl  = tab-kostl
  AND    datbi  = '99991231'
  AND    BKZKP  = 'X'
  AND    BKZKS  = 'X'.
  if sy-subrc = 0.
    ban = '1'.
  endif.
ENDFORM.                    " VALIDA
