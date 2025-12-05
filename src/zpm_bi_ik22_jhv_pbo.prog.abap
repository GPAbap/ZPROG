*----------------------------------------------------------------------*
***INCLUDE ZBIPM0005B_PBO .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'Z_MENU'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_INICIALIZA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_inicializa OUTPUT.

* equnr(18),
* rdcnt(22),
* rdlts(22),
* idate(10),
* itime(8),

  CLEAR: i_fieldcatalog[].
  PERFORM f_fieldcat
  TABLES i_fieldcatalog
  USING: 'EQUNR' 'No. Equipo' '18'  '1',
         'RDCNT' 'Kilometros' '22'  '2',
         'RDLTS' 'Litros'     '22'  '3',
         'IDATE' 'Fecha'      '10'  '4',
         'ITIME' 'Hora'       '8'   '5',
         'LOG' 'Mensaje'      '200' '6'.


  PERFORM f_display_grid
  TABLES i_disp_log[]
         i_fieldcatalog.

ENDMODULE.                 " M_INICIALIZA  OUTPUT
