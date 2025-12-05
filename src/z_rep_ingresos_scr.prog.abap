*&---------------------------------------------------------------------*
*&  Include           Z_REP_INGRESOS_SCRV2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           Z_REP_INGRESOS_SCR
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PBO_BEGIN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_begin OUTPUT.
  cl_bus_abstract_sub_screen=>dynpro_pbo_begin(
    iv_dynpro_number = sy-dynnr
    iv_program_name = sy-repid ).
ENDMODULE.                 " PBO_BEGIN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_END  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_end OUTPUT.

  cl_bus_abstract_sub_screen=>dynpro_pbo_end(
    iv_dynpro_number = sy-dynnr
    iv_program_name = sy-repid ).

ENDMODULE.                 " PBO_END  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_BEGIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_begin INPUT.
  cl_bus_abstract_screen=>dynpro_pai_begin(
    iv_dynpro_number = sy-dynnr
    iv_program_name = sy-repid ).
ENDMODULE.                 " PAI_BEGIN  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_END  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_end INPUT.
  cl_bus_abstract_screen=>dynpro_pai_end(
    iv_dynpro_number = sy-dynnr
    iv_program_name = sy-repid ).
ENDMODULE.                 " PAI_END  INPUT
