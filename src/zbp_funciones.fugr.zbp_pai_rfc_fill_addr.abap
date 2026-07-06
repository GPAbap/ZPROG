FUNCTION zbp_pai_rfc_fill_addr.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  CHANGING
*"     REFERENCE(CITY1) TYPE  AD_CITY1
*"     REFERENCE(POST_CODE1) TYPE  AD_PSTCD1
*"     REFERENCE(STREET) TYPE  AD_STREET
*"     REFERENCE(HOUSE_NUM1) TYPE  AD_HSNM1
*"     REFERENCE(COUNTRY) TYPE  LAND1
*"     REFERENCE(REGION) TYPE  REGIO
*"     REFERENCE(STATUS_CODE) TYPE  I
*"----------------------------------------------------------------------
  DATA lv_response TYPE string.

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

  DATA ls_response TYPE ty_response.
  DATA lt_mappings TYPE /ui2/cl_json=>name_mappings.



  DATA: lt_dfkkbptaxnum TYPE TABLE OF dfkkbptaxnum,
        s_rfc           TYPE string, s_idcif TYPE string.

  CALL FUNCTION 'BUP_BUPA_TAX_GET'
    TABLES
      et_tax              = lt_dfkkbptaxnum
    EXCEPTIONS
      no_taxnumbers_found = 1
      OTHERS              = 2.

  IF lt_dfkkbptaxnum IS NOT INITIAL.

    IF line_exists( lt_dfkkbptaxnum[ taxtype = 'MX1'] ).
      DATA(lv_rfc) = lt_dfkkbptaxnum[ taxtype = 'MX1'].
    ENDIF.

    IF line_exists( lt_dfkkbptaxnum[ taxtype = 'MX4'] ).

      DATA(lv_idcif) = lt_dfkkbptaxnum[ taxtype = 'MX4'].
    ENDIF.

    IF lv_rfc IS NOT INITIAL AND lv_idcif IS NOT INITIAL.

      s_rfc = lv_rfc-taxnum.
      s_idcif = lv_idcif-taxnum.

      zcl_bp_rfc_addr_helper=>fill_addr_by_rfc_idcif(
        EXPORTING
          iv_rfc     = s_rfc"'GPS680713D5A'"p_rfc
          iv_idcif   = s_idcif"'14081169329'"p_idcif
        IMPORTING
          e_response = lv_response
          e_status = status_code
      ).
      IF lv_response IS NOT INITIAL.


        """""""""""""""""""""""""""""""""""""""""""""""""
        lt_mappings = VALUE #(
    ( abap = 'REGIMENES'                 json = 'Regimenes' )
    ( abap = 'REGIMEN_FISCAL'            json = 'RegimenFiscal' )
    ( abap = 'FECHA_ALTA'                json = 'Fecha de alta' )
    ( abap = 'DENOMINACION_RAZON_SOCIAL' json = 'Denominación o Razón Social' )
    ( abap = 'REGIMEN_CAPITAL'           json = 'Régimen de capital' )
    ( abap = 'FECHA_CONSTITUCION'        json = 'Fecha de constitución' )
    ( abap = 'FECHA_INICIO_OPERACIONES'  json = 'Fecha de Inicio de operaciones' )
    ( abap = 'SITUACION_CONTRIBUYENTE'   json = 'Situación del contribuyente' )
    ( abap = 'FECHA_ULTIMO_CAMBIO'       json = 'Fecha del último cambio de situación' )
    ( abap = 'ENTIDAD_FEDERATIVA'        json = 'Entidad Federativa' )
    ( abap = 'MUNICIPIO_DELEGACION'      json = 'Municipio o delegación' )
    ( abap = 'COLONIA'                   json = 'Colonia' )
    ( abap = 'TIPO_VIALIDAD'             json = 'Tipo de vialidad' )
    ( abap = 'NOMBRE_VIALIDAD'           json = 'Nombre de la vialidad' )
    ( abap = 'NUMERO_EXTERIOR'           json = 'Número exterior' )
    ( abap = 'NUMERO_INTERIOR'           json = 'Número interior' )
    ( abap = 'CP'                        json = 'CP' )
    ( abap = 'CORREO_ELECTRONICO'        json = 'Correo electrónico' )
    ( abap = 'AL'                        json = 'AL' )
  ).

        /ui2/cl_json=>deserialize(
          EXPORTING
            json          = lv_response
            name_mappings = lt_mappings
          CHANGING
            data          = ls_response
        ).
        """""""""""""""""""""""""""""""""""""""""""""""""
        city1 = ls_response-municipio_delegacion.
        post_code1 = ls_response-cp.
        CONCATENATE ls_response-nombre_vialidad ls_response-colonia into street SEPARATED BY space.
        house_num1 = ls_response-numero_exterior.
        country = 'MX'.
        IF ls_response-entidad_federativa IS NOT INITIAL.
          region  = ls_response-entidad_federativa+0(3).
        ENDIF.

      ENDIF.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.

ENDFUNCTION.
