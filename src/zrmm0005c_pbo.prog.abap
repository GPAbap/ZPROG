*----------------------------------------------------------------------*
***INCLUDE ZRMM0005B_PBO .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
*  SET PF-STATUS 'Z_STOCK'.
*  SET TITLEBAR 'ZTIT'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_display OUTPUT.

  CLEAR: gt_fieldcat[].
  PERFORM f_llena_fieldcat
    TABLES gt_fieldcat
    USING: "'WERKS'  'Centro'      '4' '1',
*           'LGORT'  'almacén '      '4' '2',
*           'LGOBE'  'Denominación almacén '  '40' '2',
           'MATNR'  'Material '       '18' '3',
           'MAKTX'  'Texto '      '40' '4',
*           'VERPR'  'Precio Variable '    '13' '5',
           'LBKUM'  'Stock Total '      '13' '6',
*Proceti2 10/JUN/2016
*           'KLMENB'  'Ofertas(Kg)'      '13' '6',
            'COTHOY'  'Cotizados Hoy(Kg)' '13' '6',
            'COTMA'   'Cotizados Mañana (Kg)' '13' '6',
            'COTPAS'  'Cotizados Pasado mañana' '13' '6',
*Proceti2 10/JUN/2016
           'KLMENC'  'Pedidos(Kg)'      '13' '6',
           'KLMEND'  'Stock Disponible(Kg) '      '13' '6'.
*           'SALK3'  'valor Total '      '13' '7',
*           'LABST'  'Stock Valorado Libre util '   '13' '8',
*           'UMLME'  'Stock en traslado '    '13' '9',
*           'INSME'  'Stock en control de Calidad '  '13' '10',
*           'PRDHA'  'Jerarquía de productos'   '18' '11',
*           'VTEXT' 'Denominación'     '40' '12'.
*           'ICON'    '' '007' '3' 'X'.

  PERFORM f_llena_lvc_sort
  TABLES g_lvc_t_sort
  USING: 'MATNR' 'X' '' 'X' ''.
*         'LGORT' 'X' '' 'X' '',
*         'LGOBE' 'X' '' 'X' ''.

  IF g_custom_container IS INITIAL.

    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = 'CC_GRID'.

    CREATE OBJECT cc_grid
      EXPORTING
        i_parent = g_custom_container.

    CALL METHOD cc_grid->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding = it_toolbar_excludinggrid
      CHANGING
        it_outtab            = rec[]
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = g_lvc_t_sort[].
  ELSE.

* Since new data has been selected, 'grid2' must be refreshed!
    CALL METHOD cc_grid->refresh_table_display.

  ENDIF.

ENDMODULE.                 " M_DISPLAY  OUTPUT
