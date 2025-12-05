*&---------------------------------------------------------------------*
*& Report ZSD_RE_RELFAC_X_DEST_MCIA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsd_re_relfac_x_dest_mcia.

* INI PROCETI CJTC-DESK929556
* Se encapsulan todas las declaraciones y rutinas en includes
* para facilitar la legibilidad del programa
INCLUDE: ZSD_RE_RELFAC_dat,
         ZSD_RE_RELFAC_f01.
* FIN PROCETI CJTC-DESK929556


*--------------------------------------------------------------------*
*--------               INITIALIZATION                      ---------*
*--------------------------------------------------------------------*
INITIALIZATION.
  repname = sy-repid.
*  PERFORM build_eventtab USING events[].
*  PERFORM build_comment USING heading[].
  PERFORM initialize_fieldcat USING fieldtab.

*--------------------------------------------------------------------*
*--------   AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_alv     ------*
*--------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_alvasg.
*  PERFORM alvl_value_request USING p_alvasg '  '.


*--------------------------------------------------------------------*
*--------             START-OF-SELECTION                     --------*
*--------------------------------------------------------------------*
START-OF-SELECTION.
  fecha = fkdat_p+3(8).
  gjahr_p = fkdat_p+3(4).
  PERFORM obtener_datos.

*--------------------------------------------------------------------*
*--------             END-OF-SELECTION                        -------*
*--------------------------------------------------------------------*
END-OF-SELECTION.

*  PERFORM build_layout USING layout.
  PERFORM armar_output.
  PERFORM write_output.

*--------------------------------------------------------------------*
*--------               Subrutinas                            -------*
*--------------------------------------------------------------------*
