class ZCL_IM_MB_MIGO_BADI definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_MIGO_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_MB_MIGO_BADI IMPLEMENTATION.


  method IF_EX_MB_MIGO_BADI~CHECK_HEADER.
  endmethod.


  METHOD if_ex_mb_migo_badi~check_item.

  ENDMETHOD.


  method IF_EX_MB_MIGO_BADI~HOLD_DATA_DELETE.
  endmethod.


  method IF_EX_MB_MIGO_BADI~HOLD_DATA_LOAD.
  endmethod.


  method IF_EX_MB_MIGO_BADI~HOLD_DATA_SAVE.
  endmethod.


  method IF_EX_MB_MIGO_BADI~INIT.
  endmethod.


  method IF_EX_MB_MIGO_BADI~LINE_DELETE.
  endmethod.


  method IF_EX_MB_MIGO_BADI~LINE_MODIFY.
  endmethod.


  method IF_EX_MB_MIGO_BADI~MAA_LINE_ID_ADJUST.
  endmethod.


  method IF_EX_MB_MIGO_BADI~MODE_SET.
  endmethod.


  method IF_EX_MB_MIGO_BADI~PAI_DETAIL.
  endmethod.


  method IF_EX_MB_MIGO_BADI~PAI_HEADER.
  endmethod.


  method IF_EX_MB_MIGO_BADI~PBO_DETAIL.
  endmethod.


  method IF_EX_MB_MIGO_BADI~PBO_HEADER.
  endmethod.


  METHOD if_ex_mb_migo_badi~post_document.

    DATA: ls_goitem TYPE goitem.


    " Ejemplo: bloquear material específico en entrada 101
    IF "ls_goitem-matnr = 'MAT_BLOQUEADO'
      " AND
      ls_goitem-bwart = '101'.
      ls_goitem-kzwes = 'X'.
      "MESSAGE e001(zmm) WITH 'Material bloqueado para entrada de mercancía en MIGO'.

    endif.


    ENDMETHOD.


  method IF_EX_MB_MIGO_BADI~PROPOSE_SERIALNUMBERS.
  endmethod.


  method IF_EX_MB_MIGO_BADI~PUBLISH_MATERIAL_ITEM.
  endmethod.


  method IF_EX_MB_MIGO_BADI~RESET.
  endmethod.


  method IF_EX_MB_MIGO_BADI~STATUS_AND_HEADER.
  endmethod.
ENDCLASS.
