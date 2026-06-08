class ZCX_DES_BLOQUEO_PROVEEDOR definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.
    DATA mv_text TYPE string.
  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  methods CONSTRUCTOR
    importing
*      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
*      !PREVIOUS like PREVIOUS optional
       iv_text TYPE string .
protected section.
private section.
ENDCLASS.



CLASS ZCX_DES_BLOQUEO_PROVEEDOR IMPLEMENTATION.


  method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.

mv_text = iv_text.
*clear me->textid.
*if textid is initial.
*  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
*else.
*  IF_T100_MESSAGE~T100KEY = TEXTID.
*endif.


  endmethod.
ENDCLASS.
