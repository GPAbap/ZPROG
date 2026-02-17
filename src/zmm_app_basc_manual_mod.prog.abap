*----------------------------------------------------------------------*
***INCLUDE ZMM_APP_BASC_MANUAL_MOD.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS100'.
  "SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.


  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      zturnosbascula-numempleado = p_nempl.
      zturnosbascula-planta      = p_planta.
      zturnosbascula-fecha_sal   = sy-datum.
      zturnosbascula-hora_sal    = sy-uzeit.
      MODIFY zturnosbascula.
      LEAVE TO SCREEN 0.
    WHEN 'REG_PES'.
      PERFORM save_data.
    WHEN 'REG_SAL'.
      CALL SCREEN 0101.
    WHEN 'CANCEL1'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.

FORM save_data.

  IF zmm_tt_bascm_ent-num_pesada IS INITIAL.
    MESSAGE 'No se genero número de pesada. Verifique' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    zmm_tt_bascm_ent-uname = sy-uname.
    TRY.
        INSERT  zmm_tt_bascm_ent.
        CLEAR zmm_tt_bascm_ent.
        MESSAGE 'Datos guardados satisfactoriamente' TYPE 'S' DISPLAY LIKE 'I'.

      CATCH cx_sql_exception.
        MESSAGE 'Error al guardar en Hana' TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  PEDIDO_SAP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pedido_sap INPUT.

  DATA vl_return LIKE inri-returncode.
  DATA vl_number TYPE n LENGTH 5.
  DATA v_centro TYPE werks_d.

  DATA: vl_numpedido TYPE string,
        vl_strnum    TYPE string.

  IF zmm_tt_bascm_ent-tipo_doc = 'VTA'.

    IF zmm_tt_bascm_ent-pedido_sap IS NOT INITIAL
         AND zmm_tt_bascm_ent-num_pesada IS INITIAL.
      SELECT SINGLE werks INTO v_centro
        FROM vbap
      WHERE vbeln =  zmm_tt_bascm_ent-pedido_sap.
    ENDIF.

  ELSE.
    IF zmm_tt_bascm_ent-pedido_sap IS NOT INITIAL
       AND zmm_tt_bascm_ent-num_pesada IS INITIAL.
      SELECT SINGLE reswk INTO v_centro
        FROM ekko
      WHERE ebeln =  zmm_tt_bascm_ent-pedido_sap.
    ENDIF.

  ENDIF.

  IF v_centro IS NOT INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'                  " Número rango de números
        object                  = 'ZNUM_BASM'                 " Nombre del objeto rango de números
      IMPORTING
        number                  = vl_number                 " Número libre
        returncode              = vl_return                 " Código retorno
      EXCEPTIONS
        interval_not_found      = 1                " Intervalos no encontrados
        number_range_not_intern = 2                " Rango de números no es interno
        object_not_found        = 3                " Objeto no definido en TNRO
        quantity_is_0           = 4                " La cantidad de números solicitados debe ser superior a 0
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    vl_strnum = vl_number.
    CONCATENATE v_centro vl_strnum INTO vl_strnum.
    zmm_tt_bascm_ent-num_pesada = vl_strnum.
    zmm_tt_bascm_ent-fechape = sy-datum.
    zmm_tt_bascm_ent-horape = sy-uzeit.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init OUTPUT.

ENDMODULE.
