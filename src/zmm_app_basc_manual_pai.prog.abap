*&---------------------------------------------------------------------*
*& Include ZMM_APP_BASC_MANUAL_PAI
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODULE FOR TC 'TBC_EBELP'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tbc_ebelp_modify INPUT.
  APPEND INITIAL LINE TO g_tbc_ebelp_itab.
  MOVE-CORRESPONDING zmm_tt_bascm_sal TO g_tbc_ebelp_wa.
  MODIFY g_tbc_ebelp_itab
    FROM g_tbc_ebelp_wa
    INDEX tbc_ebelp-current_line.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.
  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      zturnosbascula-numempleado = p_nempl.
      zturnosbascula-planta      = p_planta.
      zturnosbascula-fecha_sal   = sy-datum.
      zturnosbascula-hora_sal    = sy-uzeit.
      MODIFY zturnosbascula.
      LEAVE TO SCREEN 0.
    WHEN 'REG_SAL'.
      PERFORM save_data_sal.

    WHEN 'CANCEL2'.
      LEAVE TO SCREEN 0.
    WHEN 'DEL_POS'.
      PERFORM del_pos.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CONS_PESADA_TICKET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE cons_pesada INPUT.

  SELECT no_ticket, remision, id_pedido, pedido_sap,
  placas, operador, peso_entrada, peso_ofrecido,num_pesada,tipo_doc,
    fechape, horape
    INTO TABLE @it_entrada_m
  FROM zmm_tt_bascm_ent
    WHERE num_pesada = @zmm_tt_bascm_sal-num_pesada.

  IF it_entrada_m IS NOT INITIAL.
    vg_flag_cons = abap_true.
    READ TABLE it_entrada_m INTO DATA(wa_entrada) INDEX 1.
    zmm_tt_bascm_sal-nea = wa_entrada-no_ticket.
    zmm_tt_bascm_sal-remision = wa_entrada-remision.
    zmm_tt_bascm_sal-id_pedido = wa_entrada-id_pedido.
    zmm_tt_bascm_sal-pedido_sap = wa_entrada-pedido_sap.
    zmm_tt_bascm_sal-placas = wa_entrada-placas.
    zmm_tt_bascm_sal-fecha_ent = wa_entrada-fecha_ent.
    zmm_tt_bascm_sal-hora_ent = wa_entrada-hora_ent.

    zmm_tt_bascm_sal-fecha_sal = sy-datum.
    zmm_tt_bascm_sal-hora_sal = sy-uzeit.

  ENDIF.



ENDMODULE.

MODULE cons_ticket INPUT.

  IF vg_flag_cons EQ abap_false.

    SELECT ticket,ticketf,vbeln,placac, pbas_ent,
      f_proc_ent, h_proc_ent
      INTO TABLE @it_entrada_b
    FROM zbasculavtas_1
      WHERE ticket = @zmm_tt_bascm_sal-nea.

    IF it_entrada_b IS NOT INITIAL.
      READ TABLE it_entrada_b INTO DATA(wa) INDEX 1.
      IF wa-vbeln+0(3) EQ '048'.
        REFRESH it_entrada_b.

        SELECT tticket AS ticket, ticketf,ebeln AS vbeln,placac, pbas_ent,
       f_proc_ent, h_proc_ent
       INTO TABLE @it_entrada_b
     FROM zbasculatrasla_1
       WHERE tticket = @zmm_tt_bascm_sal-nea.

      ENDIF.
    ELSE.

      SELECT tticket AS ticket, ticketf,ebeln AS vbeln,placac, pbas_ent,
       f_proc_ent, h_proc_ent
       INTO TABLE @it_entrada_b
     FROM zbasculatrasla_1
       WHERE tticket = @zmm_tt_bascm_sal-nea.

    ENDIF.

  ENDIF.

  IF it_entrada_b IS NOT INITIAL.
    READ TABLE it_entrada_b INTO DATA(wa_entrada2) INDEX 1.
    zmm_tt_bascm_sal-nea = wa_entrada2-ticket.
    zmm_tt_bascm_sal-remision = wa_entrada2-ticketf.
    zmm_tt_bascm_sal-id_pedido = wa_entrada2-vbeln.
    zmm_tt_bascm_sal-pedido_sap = wa_entrada2-vbeln.
    zmm_tt_bascm_sal-placas = wa_entrada2-placac.
    zmm_tt_bascm_sal-fecha_ent = wa_entrada2-f_proc_ent.
    zmm_tt_bascm_sal-hora_ent = wa_entrada2-h_proc_ent.

    zmm_tt_bascm_sal-fecha_sal = sy-datum.
    zmm_tt_bascm_sal-hora_sal = sy-uzeit.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form save_data_sal
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data_sal .
  DATA: vl_pos_o      TYPE i,
        vl_pos_n      TYPE i,
        it_posiciones TYPE ebelp.

  DATA wa_salida LIKE zmm_tt_bascm_sal.
  DATA flag.

  IF g_tbc_ebelp_itab IS INITIAL.
    MESSAGE 'Faltan posiciones de pedido' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.

    DELETE  g_tbc_ebelp_itab WHERE ebelp EQ '00000'.

    IF it_entrada_m IS NOT INITIAL.

      READ TABLE it_entrada_m INTO DATA(wa_entrada) INDEX 1.
      IF sy-subrc EQ 0.

        SELECT MAX( posnr ) AS posiciones
          INTO it_posiciones
          FROM vbap
        WHERE vbeln =  zmm_tt_bascm_sal-pedido_sap.

        IF it_posiciones IS INITIAL.

          SELECT MAX( ebelp ) AS posiciones
        INTO it_posiciones
        FROM ekpo
      WHERE ebeln =  zmm_tt_bascm_sal-pedido_sap.

        ENDIF.
      ENDIF.
    ELSE.
      READ TABLE it_entrada_b INTO DATA(wa_entrada_b) INDEX 1.
      IF wa_entrada_b-vbeln+0(3) EQ '048' OR  wa_entrada_b-vbeln+0(2) EQ '48'.
        SELECT MAX( ebelp ) AS posiciones
          INTO it_posiciones
          FROM ekpo
        WHERE ebeln =  zmm_tt_bascm_sal-pedido_sap.
      ELSE.
        SELECT MAX( posnr ) AS posiciones
          INTO it_posiciones
          FROM vbap
        WHERE vbeln =  zmm_tt_bascm_sal-pedido_sap.
      ENDIF.

    ENDIF.
    vl_pos_o = it_posiciones.

    DATA(aux_itab) = g_tbc_ebelp_itab[].

    SORT aux_itab BY ebelp DESCENDING.
    READ TABLE aux_itab INTO DATA(wa_aux) INDEX 1.

    vl_pos_n = wa_aux-ebelp.


*    IF vl_pos_o NE vl_pos_n.
*      MESSAGE 'No coincide número posiciones en registro' TYPE 'S' DISPLAY LIKE 'E'.
*    ELSE.
    MOVE-CORRESPONDING zmm_tt_bascm_sal TO wa_salida.

    LOOP AT g_tbc_ebelp_itab INTO DATA(wa_itab).
      MOVE-CORRESPONDING wa_itab TO zmm_tt_bascm_sal." wa_salida.
      zmm_tt_bascm_sal-ind_no_fact = 'X'.
      zmm_tt_bascm_sal-uname = sy-uname.
      TRY.
          INSERT zmm_tt_bascm_sal.
          IF sy-subrc EQ 0.
            MESSAGE 'Se ha guardado la salida de báscula' TYPE 'S' DISPLAY LIKE 'I'.
            flag = abap_true.
          ELSE.
            MESSAGE 'No se guardo. Puede que ya exista el registro en la bd. Verifique' TYPE 'S' DISPLAY LIKE 'E'.
            flag = abap_false.
          ENDIF.
        CATCH cx_sql_exception.
          MESSAGE 'No se guardo. Puede que ya exista el registro en la bd. Verifique' TYPE 'S' DISPLAY LIKE 'E'.
      ENDTRY.

    ENDLOOP.
    IF flag EQ abap_true.
      CLEAR zmm_tt_bascm_sal.
      REFRESH  g_tbc_ebelp_itab.
    ENDIF.

*    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_pos
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM del_pos .

  DATA: lt_fields TYPE STANDARD TABLE OF sval,
        ls_field  TYPE sval.
  DATA vl_ebelp TYPE i.

  vl_ebelp = 0.

  " Field 1: Material Number
  ls_field-tabname   = 'EKPO'.       " Table or structure name
  ls_field-fieldname = 'EBELP'.      " Field name
  ls_field-field_obl = 'X'.          " Mandatory
  ls_field-value     = '00010'.   " Default value
  APPEND ls_field TO lt_fields.

  " Call popup
  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = 'Ingrese la posición a Eliminar...'
    TABLES
      fields          = lt_fields
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.

  IF sy-subrc = 0.
    DELETE  g_tbc_ebelp_itab WHERE ebelp EQ '00000'.
    LOOP AT lt_fields INTO ls_field.
      DELETE g_tbc_ebelp_itab WHERE ebelp = ls_field-value.
      IF g_tbc_ebelp_itab IS NOT INITIAL.
        LOOP AT g_tbc_ebelp_itab ASSIGNING FIELD-SYMBOL(<new_pos>).
          <new_pos>-ebelp = vl_ebelp + 10.

          vl_ebelp = <new_pos>-ebelp.
        ENDLOOP.
      ENDIF.


    ENDLOOP.
  ELSE.
    MESSAGE 'No se elimino ningún registro.' TYPE 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CHECK_POS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_pos INPUT.
  DATA vl_pos TYPE ebelp.

  READ TABLE g_tbc_ebelp_itab WITH KEY ebelp = zmm_tt_bascm_sal-ebelp TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    MESSAGE 'Ya existe una posición igual a la ingresada.' TYPE 'S' DISPLAY LIKE 'E'.
    CLEAR zmm_tt_bascm_sal-ebelp.
  ELSE.
    IF zmm_tt_bascm_sal-ebelp > '00010'.
      vl_pos = zmm_tt_bascm_sal-ebelp - '00010'.
      READ TABLE g_tbc_ebelp_itab WITH KEY ebelp = vl_pos TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        MESSAGE 'Debe seguir el consecutivo de posiciones' TYPE 'S' DISPLAY LIKE 'E'.
        CLEAR zmm_tt_bascm_sal-ebelp.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CALC_NETO_PROM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE calc_neto_prom INPUT.

  READ TABLE it_entrada_m INTO DATA(wa_entrada_m) INDEX 1.
  IF sy-subrc NE 0.
    READ TABLE it_entrada_b INTO DATA(wa_entrada_b) INDEX 1.
    IF zmm_tt_bascm_sal-peso_sal GT 0.
      zmm_tt_bascm_sal-peso_neto = zmm_tt_bascm_sal-peso_sal - wa_entrada_b-pbas_ent.
      IF zmm_tt_bascm_sal-peso_neto LE 0.
        MESSAGE 'Error en peso Neto. No puede haber Cant. Negativa' TYPE 'S' DISPLAY LIKE 'E'.
        CLEAR zmm_tt_bascm_sal-peso_neto .
      ENDIF.
    ENDIF.

  ELSE.
    IF zmm_tt_bascm_sal-peso_sal GT 0.

      zmm_tt_bascm_sal-peso_neto = zmm_tt_bascm_sal-peso_sal - wa_entrada_m-peso_entrada.
      IF zmm_tt_bascm_sal-peso_neto LE 0.
        MESSAGE 'Error en peso Neto. No puede haber Cant. Negativa' TYPE 'S' DISPLAY LIKE 'E'.
        CLEAR zmm_tt_bascm_sal-peso_neto .
      ENDIF.
    ENDIF.

  ENDIF.

  DATA(cant) = REDUCE menge_d( INIT sum = 0
                        FOR ls IN g_tbc_ebelp_itab
                        NEXT sum = sum + ls-pzas ).

  IF cant GT 0.
    zmm_tt_bascm_sal-prom_aves = zmm_tt_bascm_sal-peso_neto / cant.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CANCEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE cancel INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VAL_CASETA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE val_caseta INPUT.
  IF zmm_tt_bascm_sal-caseta IS INITIAL.
    MESSAGE 'La caseta no puede estar vacío' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VAL_SEXO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE val_sexo INPUT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VAL_PZAS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE val_pzas INPUT.
  IF zmm_tt_bascm_sal-pzas <= 0.
    MESSAGE 'La cantidad debe ser mayor que cero' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDMODULE.
