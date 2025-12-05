************************************************************************
* PROGRAMA:     ZRMM0010
* DESCRIPCIÓN:  IMPRIME DOCUMENTO DE RESERVA
* AUTOR:        MARIA DEL CARMEN OCOTLAN GUZMAN MEDINA
* PROYECTO:     TECNOLOGIA DE INFORMACIÓN PORRES   T I P
* FECHA:        OCTUBRE DEL 2001
* MODIFICACIÓN: OCTUBRE DEL 2014
*               MARY GUZMAN
*               DIVISIÓN INGENIOS
************************************************************************
* ESTE PROGRAMA IMPRIME ENCABEZADO Y DETALLE DEL DOCUMENTO DE RESERVA
* PARA PEDIR MERCANCIA EN EL CENTRO/ALMACEN INDICADO.
************************************************************************
* Actualización: 28 Marzo 2023
* Modificado por: Jaime Hernandez Velasquez
************************************************************************
REPORT zmm_app_print_resb NO STANDARD PAGE HEADING LINE-SIZE 80 LINE-COUNT 65.

Include zmm_app_print_resb_top.
include zmm_app_print_resb_fun.

************************************************************************
* ESPECIFICACIONES DE CALCULO
************************************************************************
START-OF-SELECTION.
  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      copies                 = 1
*     destination            = 'mary'
      expiration             = 2
      immediately            = 'X'
      line_count             = 65
      line_size              = 80
      list_name              = 'RESERVA'
    IMPORTING
      out_parameters         = params
      valid                  = valid
    EXCEPTIONS
      archive_info_not_found = 1
      invalid_print_params   = 2
      invalid_archive_params = 3
      OTHERS                 = 4.

  IF valid <> space.

    PERFORM get_data.

    IF it_salida[] IS NOT INITIAL.

      DELETE it_salida WHERE pendi EQ 0.
      IF it_salida[] IS NOT INITIAL.
        PERFORM imprime_reserva.
      ELSE.
       " WRITE:/ 'LA POSICIÓN: ', tabp-rspos, 'YA FUE SURTIDA TOTALMENTE'.
      ENDIF.
    ELSE.
      WRITE: 'VERIFIQUE EL NUMERO DE RESERVA'.
    ENDIF.
    " ENDSELECT.
    NEW-PAGE PRINT OFF.
  ENDIF.

END-OF-SELECTION.
