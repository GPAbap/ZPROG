class ZCL_IM_MRM_DOWNPAYMENT definition
  public
  final
  create public .

*"* public components of class CL_EX_MRM_DOWNPAYMENT
*"* do not include other source files here!!!
public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MRM_DOWNPAYMENT .
protected section.
*"* protected components of class CL_EX_MRM_DOWNPAYMENT
*"* do not include other source files here!!!
private section.
*"* private components of class CL_EX_MRM_DOWNPAYMENT
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_MRM_DOWNPAYMENT IMPLEMENTATION.


METHOD if_ex_mrm_downpayment~downpayment_check.
*
*  DATA lv_has_open_dp TYPE abap_bool.
*
*  CLEAR: lv_has_open_dp,
*         e_prevent_message.
*
*  SELECT SINGLE @abap_true
*    FROM ekbe
*    WHERE ebeln = @i_drseg-ebeln
*      AND ebelp = @i_drseg-ebelp
*      AND vgabe = '4'
*    INTO @lv_has_open_dp.
*
*  IF lv_has_open_dp = abap_true.
*
*    "Evita el mensaje estándar de SAP
**    e_prevent_message = abap_true.
*
*    "Mensaje propio
**   MESSAGE e001(zmrm)
**      WITH i_drseg-ebeln i_drseg-ebelp.
*  ENDIF.


ENDMETHOD.
ENDCLASS.
