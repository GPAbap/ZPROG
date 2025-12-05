*&---------------------------------------------------------------------*
*& Reporte ZRSDTRA022                                                  *
*& Descripción: Relación de Entregas realizadas para pagos de seguros  *
*&---------------------------------------------------------------------*
*& Sistema: Validación de Transportistas                               *
*& Autor: Mary Guzmán                                                  *
*& Fecha: Octubre del 2007.                                            *
*& Modificación:                                                       *
*&  Copia de ZRSDTRA019, para adicionarle campos para relación para    *
*&  pago de seguros
*& Copia de ZRSDTRA022 el 20230208                                                *
*&---------------------------------------------------------------------*
*-----     Especificaciones de Cabecera
REPORT  ZRSDTRA022_v2.
*  NO STANDARD PAGE HEADING
*  MESSAGE-ID zmsdtra001
*  LINE-SIZE 226
*  LINE-COUNT 65.

INCLUDE ZRSDTRA022_v2_TOP.
INCLUDE ZRSDTRA022_v2_FUN.

START-OF-SELECTION.

PERFORM get_data.
PERFORM create_fieldcat.
PERFORM show_alv.


END-OF-SELECTION.
