class ZCPICO_YISAUNLGY_WS_FACTURAS definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods CREATE
    importing
      !INPUT type ZCPIBO_FACTURAS_CREATE_REQUES4
    exporting
      !OUTPUT type ZCPIBO_FACTURAS_CREATE_CONFIR3
    raising
      CX_AI_SYSTEM_FAULT
      ZCPICX_STANDARD_FAULT_MESSAGE1 .
  methods READ
    importing
      !INPUT type ZCPIBO_FACTURAS_READ_BY_IDQUE3
    exporting
      !OUTPUT type ZCPIBO_FACTURAS_READ_BY_IDRES4
    raising
      CX_AI_SYSTEM_FAULT
      ZCPICX_STANDARD_FAULT_MESSAGE1 .
  methods UPDATE
    importing
      !INPUT type ZCPIBO_FACTURAS_UPDATE_REQUES4
    exporting
      !OUTPUT type ZCPIBO_FACTURAS_UPDATE_CONFIR2
    raising
      CX_AI_SYSTEM_FAULT
      ZCPICX_STANDARD_FAULT_MESSAGE1 .
protected section.
private section.
ENDCLASS.



CLASS ZCPICO_YISAUNLGY_WS_FACTURAS IMPLEMENTATION.


method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZCPICO_YISAUNLGY_WS_FACTURAS'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


method CREATE.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'CREATE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


method READ.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'READ'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


method UPDATE.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'UPDATE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
