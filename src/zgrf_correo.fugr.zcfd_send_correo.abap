FUNCTION ZCFD_SEND_CORREO . "FUNCION
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(CORREOS) TYPE  STRING OPTIONAL
*"     VALUE(BODY) TYPE  STRING OPTIONAL
*"     VALUE(ASUNTO) TYPE  STRING OPTIONAL
*"     VALUE(NOMBRE_ARCHIVO) TYPE  STRING OPTIONAL
*"     VALUE(ATTACHMENT) TYPE  XSTRING OPTIONAL
*"     VALUE(FORMATO) TYPE  CHAR3 OPTIONAL
*"     VALUE(ATTACHMENT2) TYPE  XSTRING OPTIONAL
*"     VALUE(FORMATO2) TYPE  CHAR3 OPTIONAL
*"     VALUE(MAILSENDER) TYPE  ZEMAIL OPTIONAL
*"----------------------------------------------------------------------

  SPLIT body AT '|' INTO TABLE it_body.

  PERFORM send_file_as_email_attach TABLES it_body
  USING attachment
        correos
        asunto
        formato
        nombre_archivo
        attachment2
        formato2
        mailsender.




ENDFUNCTION.
