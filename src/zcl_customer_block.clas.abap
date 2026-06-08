class ZCL_CUSTOMER_BLOCK definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_CVI_CUSTOM_MAPPER .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CUSTOMER_BLOCK IMPLEMENTATION.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_BP_REL_TO_CUSTOMER_CONTACT.
  endmethod.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_BP_REL_TO_VENDOR_CONTACT.
  endmethod.


  METHOD if_ex_cvi_custom_mapper~map_bp_to_customer.

    FIELD-SYMBOLS: <ls_sales> TYPE cmds_ei_sales.
    data vl_task.

    CHECK sy-uname = 'PORTALCRM'.

    " Validar creación de cliente
    "CHECK c_customer-header-object_task = 'I'.
    CHECK c_customer-header-object_task = 'M'
          OR c_customer-header-object_task = 'U'. "Al crear por CRM manda este estatus de Creación nuevo Cliente
                                                  "Es de tipo Modify (si no existe el cliente lo crea y si ya existe
                                                  "lo actualiza. Ya sea por cualquier de las dos.. lo bloqueará con Z1
                                                  " Se agrega U para actualizaciones de Cliente.
    vl_task = c_customer-header-object_task.
    LOOP AT c_customer-sales_data-sales ASSIGNING <ls_sales>.

      <ls_sales>-data-aufsd  = 'Z1'.
      <ls_sales>-datax-aufsd = abap_true.

      IF <ls_sales>-task IS INITIAL.
        <ls_sales>-task = vl_task.
      ENDIF.

    ENDLOOP.



  ENDMETHOD.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_BP_TO_CUSTOMER_CONTACT.
  endmethod.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_BP_TO_VENDOR.
  endmethod.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_BP_TO_VENDOR_CONTACT.
  endmethod.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_CUSTOMER_TO_BP.
  endmethod.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_CUST_CONT_TO_BP_AND_REL.
  endmethod.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_PERSON_TO_CUSTOMER_CONTACT.
  endmethod.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_PERSON_TO_VENDOR_CONTACT.
  endmethod.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_VENDOR_TO_BP.
  endmethod.


  method IF_EX_CVI_CUSTOM_MAPPER~MAP_VEND_CONT_TO_BP_AND_REL.
  endmethod.
ENDCLASS.
