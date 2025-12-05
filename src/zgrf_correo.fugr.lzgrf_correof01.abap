*----------------------------------------------------------------------*
***INCLUDE LZGRF_CORREOF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form send_file_as_email_attach
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_BODY
*&      --> ATTACHMENT
*&      --> CORREOS
*&      --> ASUNTO
*&      --> FORMATO
*&      --> NOMBRE_ARCHIVO
*&      --> ATTACHMENT2
*&      --> FORMATO2
*&      --> MAILSENDER
*&---------------------------------------------------------------------*
FORM SEND_FILE_AS_EMAIL_ATTACH   TABLES p_body
                                USING p_attachment
                                      p_email
                                      p_mtitle
                                      p_format
                                      p_filename
                                      p_attach2
                                      p_format2
                                      p_sender."*MODIFICACIÓN MICHAEL CHAVEZ ajuste para mandar el parametro de correo electronico*** INI

***********MODIFICACIÓN MICHAEL CHAVEZ ajuste para mandar el parametro de correo electronico*** FIN

***********MODIFICACIÓN MICHAEL CHAVEZ ajuste para mandar el parametro de correo electronico*** INI
  DATA: ld_sender TYPE ADR6-SMTP_ADDR.
***********MODIFICACIÓN MICHAEL CHAVEZ ajuste para mandar el parametro de correo electronico*** FIN
  DATA: BEGIN OF it_correo OCCURS 0,
    mail  TYPE ad_smtpadr,
  END OF it_correo.

  DATA: send_request       TYPE REF TO cl_bcs,
        ld_attachment      TYPE xstring,
        w_docsize(12)      TYPE C.
  DATA: document           TYPE REF TO cl_document_bcs.
  DATA: ld_text            TYPE bcsy_text.
  DATA: bcs_exception      TYPE REF TO cx_bcs,
        ld_format          TYPE soodk-objtp.
  DATA: binary_content     TYPE solix_tab.
  DATA: ld_email           TYPE string.
  DATA: sender             TYPE REF TO IF_SENDER_BCS.
  DATA: recipient          TYPE REF TO if_recipient_bcs.
  DATA: sent_to_all        TYPE os_boolean.
  DATA: ld_filename(50)    TYPE C.
  DATA: ld_subject(50)     TYPE C,
        w_text             TYPE string,
        w_cnt              TYPE I,
        w_mess_size(12)    TYPE C,
        sender_name        TYPE uname,
        mail_e             TYPE ADR6-SMTP_ADDR.
  TRY.

*      ld_attachment = p_attachment.
    ld_text[] = p_body[].
*      ld_format = p_format.
    ld_email  = p_email.
*      ld_filename = p_filename.
    ld_subject = p_mtitle.

*     -------- create persistent send request ------------------------
    send_request = cl_bcs=>create_persistent( ).
* Avoid request of read and delivery
    send_request->set_status_attributes( i_requested_status = 'N'  ).



    DESCRIBE TABLE ld_text LINES w_cnt.
*     -------- create and set document with attachment ---------------
*     create document from internal table with text
    w_mess_size = w_cnt * 255.
    document = cl_document_bcs=>create_document(
    i_type    = 'TXT'
    i_text    = ld_text
    i_length  = w_mess_size
    i_subject = ld_subject ).


*      perform set_attachment using document
*                                   ld_attachment
*                                   ld_format
*                                   ld_filename.

*      call function 'SCMS_XSTRING_TO_BINARY'
*        exporting buffer = ld_attachment
*        tables binary_tab = binary_content.
*
*
*     add attachment to document
*     BCS expects document content here e.g. from document upload
*     binary_content = ...
*      w_docsize = xstrlen( ld_attachment ).
*      CALL METHOD document->add_attachment
*        EXPORTING  i_attachment_type = ld_format
*                   i_attachment_subject = ld_filename
*                   i_att_content_hex    = binary_content
*                   i_attachment_size    = w_docsize.

*      if p_attach2 ne space.
*        clear: ld_attachment, ld_format.
*        ld_attachment = p_attach2.
*        ld_format = p_format2.

*        perform set_attachment using document
*                                   ld_attachment
*                                   ld_format
*                                   ld_filename.
*      endif.

*     add document to send request
    CALL METHOD send_request->set_document( document ).

*     --------- set sender -------------------------------------------
*     note: this is necessary only if you want to set the sender
*           different from actual user (SY-UNAME). Otherwise sender is
*           set automatically with actual user.

*      sender = cl_sapuser_bcs=>create( sy-uname ).

    sender_name = 'MAILSYS'.
*
*      if p_format2 = 'AVP' . "Sender para Mail Enviado de Aviso de Pago!
*          sender_name = 'MAILSYS2'.
*      endif.
    ld_sender = p_sender.
    IF ld_sender NE SPACE.
      mail_e = ld_sender.
    ELSE.
      mail_e = 'notificapago@gporres.com.mx'.
    ENDIF.


    sender = cl_cam_address_bcs=>create_internet_address( mail_e ).
    CALL METHOD send_request->set_sender
    EXPORTING
      i_sender = sender.

*     --------- add recipient (e-mail address) -----------------------
*     create recipient - please replace e-mail address !!!

    SPLIT ld_email AT ';' INTO TABLE it_correo.
    LOOP AT it_correo.
      IF it_correo-mail IS INITIAL.
        CONTINUE.
      ENDIF.
      CLEAR recipient.
      CONDENSE it_correo-mail.
      recipient = cl_cam_address_bcs=>create_internet_address(
      it_correo-mail ).

*     add recipient with its respective attributes to send request
      CALL METHOD send_request->add_recipient
      EXPORTING
        i_recipient = recipient
        i_express   = 'X'.
    ENDLOOP.


*     ---------- send document ---------------------------------------
    CALL METHOD send_request->send(
    EXPORTING
      i_with_error_screen = 'X'
      receiving
      result              = sent_to_all ).
    IF sent_to_all = 'X'.
*        write text-003.
    ENDIF.

    COMMIT WORK.

* -----------------------------------------------------------
* *                     exception handling
* -----------------------------------------------------------
* * replace this very rudimentary exception handling
* * with your own one !!!
* -----------------------------------------------------------
  CATCH cx_bcs INTO bcs_exception.
*      write: 'Fehler aufgetreten.'(001).
*      write: 'Fehlertyp:'(002), bcs_exception->error_type.
    WRITE: 'Error .'(001).
    WRITE: 'No se Envio el Mail:'(002), bcs_exception->error_type.

    EXIT.

  ENDTRY.
ENDFORM.                    " SEND_FILE_AS_EMAIL_ATTACH
