class ZCL_IM_AC_DOCUMENT definition
  public
  final
  create public .

public section.

  interfaces IF_EX_AC_DOCUMENT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_AC_DOCUMENT IMPLEMENTATION.


  method IF_EX_AC_DOCUMENT~CHANGE_AFTER_CHECK.
    BREAK JHERNANDEV.

CHECK sy-tcode eq 'MIRO'.

     FIELD-SYMBOLS:
    <lt_items> TYPE ANY TABLE,
    <ls_item>  TYPE any,
    <lv_ebeln> TYPE any,
    <lv_ebelp> TYPE any,
    <lv_koart> TYPE any,
    <lv_umskz> TYPE any.

  DATA:
    lv_has_po_dp       TYPE abap_bool,
    lv_has_dp_clearing TYPE abap_bool.

  "Intentar obtener tabla de posiciones del documento FI
  ASSIGN COMPONENT 'ITEM' OF STRUCTURE im_document TO <lt_items>.

  IF <lt_items> IS NOT ASSIGNED.
    ASSIGN COMPONENT 'ITEMS' OF STRUCTURE im_document TO <lt_items>.
  ENDIF.

  IF <lt_items> IS NOT ASSIGNED.
    MESSAGE e001(zmrm) WITH 'No se encontró tabla de partidas en IM_DOCUMENT'.
    RETURN.
  ENDIF.

  "1. Buscar partidas de pedido en la factura
  LOOP AT <lt_items> ASSIGNING <ls_item>.

    UNASSIGN: <lv_ebeln>, <lv_ebelp>.

    ASSIGN COMPONENT 'EBELN' OF STRUCTURE <ls_item> TO <lv_ebeln>.
    ASSIGN COMPONENT 'EBELP' OF STRUCTURE <ls_item> TO <lv_ebelp>.

    IF <lv_ebeln> IS NOT ASSIGNED
       OR <lv_ebelp> IS NOT ASSIGNED
       OR <lv_ebeln> IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR lv_has_po_dp.

    "2. Validar si el pedido/posición tiene anticipo
    SELECT SINGLE @abap_true
      FROM ekbe
      WHERE ebeln = @<lv_ebeln>
        AND ebelp = @<lv_ebelp>
        AND vgabe = '4'
      INTO @lv_has_po_dp.

    IF lv_has_po_dp IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR lv_has_dp_clearing.

    "3. Validar si en el documento FI viene compensación de anticipo
    LOOP AT <lt_items> ASSIGNING FIELD-SYMBOL(<ls_item2>).

      UNASSIGN: <lv_koart>, <lv_umskz>.

      ASSIGN COMPONENT 'KOART' OF STRUCTURE <ls_item2> TO <lv_koart>.
      ASSIGN COMPONENT 'UMSKZ' OF STRUCTURE <ls_item2> TO <lv_umskz>.

      IF <lv_koart> IS ASSIGNED
         AND <lv_umskz> IS ASSIGNED
         AND <lv_koart> = 'K'
         AND <lv_umskz> IS NOT INITIAL.

        lv_has_dp_clearing = abap_true.
        EXIT.

      ENDIF.

    ENDLOOP.

    IF lv_has_dp_clearing IS INITIAL.
      MESSAGE e000(ZMM_FI_MIRO)
        WITH <lv_ebeln> <lv_ebelp>.
    ENDIF.

  ENDLOOP.

  endmethod.


  method IF_EX_AC_DOCUMENT~CHANGE_INITIAL.

  endmethod.


  method IF_EX_AC_DOCUMENT~IS_ACCTIT_RELEVANT.

  endmethod.


  method IF_EX_AC_DOCUMENT~IS_COMPRESSION_REQUIRED.
  endmethod.


  method IF_EX_AC_DOCUMENT~IS_SUPPRESSED_ACCT.
  endmethod.
ENDCLASS.
