class ZCL_CO_PC_AJUSTENORMASLIQUIDA definition
  public
  final
  create public .

public section.

  methods AJUSTA_NORMA
    importing
      !I_AUFNR type AUFNR
      !I_TABLA type STANDARD TABLE
    returning
      value(R_SUBRC) type SY-SUBRC .
  PROTECTED SECTION.
private section.

  data PV_AUFNR type AUFNR .
  data:
    pv_table TYPE STANDARD TABLE OF zco_st_cobrb .
  data:
    pv_cobrb_update TYPE STANDARD TABLE OF cobrb .
  data:
    wa_cobrb_update LIKE LINE OF pv_cobrb_update .
ENDCLASS.



CLASS ZCL_CO_PC_AJUSTENORMASLIQUIDA IMPLEMENTATION.


METHOD ajusta_norma.
    pv_aufnr = i_aufnr.
    pv_table[] = i_tabla[].

    LOOP AT pv_table INTO DATA(wa_tabla) WHERE aufnr = pv_aufnr.
      MOVE-CORRESPONDING wa_tabla TO wa_cobrb_update.
      wa_cobrb_update-mandt = sy-mandt.
      APPEND wa_cobrb_update TO pv_cobrb_update.


    ENDLOOP.

    IF pv_cobrb_update IS NOT INITIAL.
      CALL FUNCTION 'K_SRULE_SAVE_UTASK'
        TABLES
*         t_cobra_insert    =
*         t_cobra_update    =
*         t_cobra_delete    =
*         t_cobrb_insert    =
          t_cobrb_update    = pv_cobrb_update
*         t_cobrb_delete    =
        EXCEPTIONS
          srule_utask_error = 1
          OTHERS            = 2.
      r_subrc = sy-subrc.
    else.
      r_subrc = 4. "sin datos en tabla de actualizacion
    ENDIF.
  ENDMETHOD.
ENDCLASS.
