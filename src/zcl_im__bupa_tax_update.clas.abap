class ZCL_IM__BUPA_TAX_UPDATE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_BUPA_TAX_UPDATE .
protected section.
PRIVATE SECTION.
    TYPES: BEGIN OF ty_regimen_fiscal,
             code        TYPE string,
             description TYPE string,
           END OF ty_regimen_fiscal.


    TYPES: BEGIN OF ty_regimen,
             regimen_fiscal TYPE ty_regimen_fiscal,
             fecha_alta     TYPE string,
           END OF ty_regimen.

    TYPES tt_regimen TYPE STANDARD TABLE OF ty_regimen WITH EMPTY KEY.

    TYPES: BEGIN OF ty_response,
             regimenes                 TYPE tt_regimen,
             denominacion_razon_social TYPE string,
             regimen_capital           TYPE string,
             fecha_constitucion        TYPE string,
             fecha_inicio_operaciones  TYPE string,
             situacion_contribuyente   TYPE string,
             fecha_ultimo_cambio       TYPE string,
             entidad_federativa        TYPE string,
             municipio_delegacion      TYPE string,
             colonia                   TYPE string,
             tipo_vialidad             TYPE string,
             nombre_vialidad           TYPE string,
             numero_exterior           TYPE string,
             numero_interior           TYPE string,
             cp                        TYPE string,
             correo_electronico        TYPE string,
             al                        TYPE string,
           END OF ty_response.
ENDCLASS.



CLASS ZCL_IM__BUPA_TAX_UPDATE IMPLEMENTATION.


  METHOD if_ex_bupa_tax_update~change_before_update.


  ENDMETHOD.
ENDCLASS.
