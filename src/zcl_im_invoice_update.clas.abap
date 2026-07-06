class ZCL_IM_INVOICE_UPDATE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_INVOICE_UPDATE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_INVOICE_UPDATE IMPLEMENTATION.


  method IF_EX_INVOICE_UPDATE~CHANGE_AT_SAVE.

*    DATA lv_has_downpayment TYPE abap_bool.
*
*  LOOP AT ti_rseg_new ASSIGNING FIELD-SYMBOL(<fs_rseg>).
*
*    CLEAR lv_has_downpayment.
*
*    SELECT SINGLE @abap_true
*      FROM ekbe
*      WHERE ebeln = @<fs_rseg>-ebeln
*        AND ebelp = @<fs_rseg>-ebelp
*        AND vgabe = '4'
*      INTO @lv_has_downpayment.
*
*    IF lv_has_downpayment = abap_true.
*
*      "Aquí debes validar si el anticipo fue realmente compensado.
*      "Si no existe compensación:
*      MESSAGE e001(zmrm)
*        WITH <fs_rseg>-ebeln <fs_rseg>-ebelp
*        RAISING error_with_message.
*
*    ENDIF.
*
*  ENDLOOP.


  endmethod.


  method IF_EX_INVOICE_UPDATE~CHANGE_BEFORE_UPDATE.
  endmethod.


  METHOD if_ex_invoice_update~change_in_update.


    DATA: ls_headdata   TYPE bapimathead,
          ls_plantdata  TYPE bapi_marc,
          ls_plantdatax TYPE bapi_marcx,
          " lt_return     TYPE STANDARD TABLE OF bapiret2,
          ls_return     TYPE bapiret2.

    DATA: ls_rseg TYPE rseg.


    BREAK jhernandez.
    IF s_rbkp_new-belnr IS NOT INITIAL
       AND s_rbkp_new-gjahr IS NOT INITIAL.

      LOOP AT ti_mrmrseg INTO ls_rseg.

        IF ls_rseg-matnr IS NOT INITIAL.

          SELECT SINGLE t~begru INTO @data(vl_begru)
            FROM mara AS m
            INNER JOIN t134 AS t
            ON t~mtart = m~mtart
            WHERE m~matnr = @ls_rseg-matnr.

        IF vl_begru = 'X' and ls_rseg-werks ne 'PP01'.

          ls_headdata-material   = ls_rseg-matnr.
          ls_headdata-purchase_view = 'X'.

          ls_plantdata-plant          = ls_rseg-werks.
          ls_plantdata-pur_status = space. "'81'.
*        ls_plantdata-sloc_exprc = ls_rseg-.



          ls_plantdatax-plant           = ls_rseg-werks.
*        ls_plantdatax-sloc_exprc      = 'X'.
          ls_plantdatax-pur_status = 'X'.

          CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
            EXPORTING
              headdata   = ls_headdata
              plantdata  = ls_plantdata
              plantdatax = ls_plantdatax
            IMPORTING
              return     = ls_return.

*          IF ls_return-type = 'E'.
*            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*            WRITE: / ls_return-type, ls_return-message.
*
*          ELSE.
*            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*              EXPORTING
*                wait = 'X'.
         ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
