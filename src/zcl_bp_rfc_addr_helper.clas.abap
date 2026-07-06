CLASS zcl_bp_rfc_addr_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS fill_addr_by_rfc_idcif
      IMPORTING iv_rfc     TYPE string
                iv_idcif   TYPE string
      EXPORTING
                e_response TYPE string
                e_status type i.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BP_RFC_ADDR_HELPER IMPLEMENTATION.


  METHOD fill_addr_by_rfc_idcif.
    DATA: lo_client   TYPE REF TO if_http_client,
          lv_url      TYPE string,
          lv_body     TYPE string,
          lv_response TYPE string,
          lv_status   TYPE i,
          lv_reason   TYPE string.

    DATA: lv_rfc   TYPE string, " VALUE 'GPS680713D5A',
          lv_idcif TYPE string. " VALUE '14081169329'.

    lv_rfc = iv_rfc.
    lv_idcif = iv_idcif.

    CONCATENATE
      'http://192.168.18.34:8000/sat/csf/'
      lv_rfc
      '/'
      lv_idcif
      INTO lv_url.

    cl_http_client=>create_by_url(
      EXPORTING
        url    = lv_url
      IMPORTING
        client = lo_client
    ).

    lo_client->request->set_method( 'GET' ).

    lo_client->request->set_header_field(
      name  = 'Accept'
      value = 'application/json'
    ).

    TRY.
        lo_client->send( ).
        IF sy-subrc <> 0.
          MESSAGE 'Sin conexión al CSF-SAT' TYPE 'S'.
        ENDIF.

         lo_client->receive(
           EXCEPTIONS
             http_communication_failure = 1
             http_invalid_state         = 2
             http_processing_failed     = 3
             others                     = 4
         ).
         IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.




        lo_client->response->get_status(
          IMPORTING
            code   = lv_status
            reason = lv_reason
        ).

        lv_response = lo_client->response->get_cdata( ).

      CATCH cx_root INTO DATA(lx_root) .
        MESSAGE lx_root->get_text( ) TYPE 'S'.
    ENDTRY.

    lo_client->close( ).

    e_response = lv_response.
    e_status = lv_status.

  ENDMETHOD.
ENDCLASS.
