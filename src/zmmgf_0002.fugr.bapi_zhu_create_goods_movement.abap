FUNCTION bapi_zhu_create_goods_movement.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IF_EVENT) TYPE  HUWBEVENT OPTIONAL
*"     VALUE(IF_SIMULATE) TYPE  XFELD DEFAULT SPACE
*"     VALUE(IF_COMMIT) TYPE  XFELD DEFAULT SPACE
*"     VALUE(IF_TCODE) TYPE  SYTCODE DEFAULT 'HUMO'
*"     VALUE(IS_IMKPF) TYPE  IMKPF OPTIONAL
*"     VALUE(IT_MOVE_TO) TYPE  HUM_DATA_MOVE_TO_T OPTIONAL
*"     VALUE(IT_INTERNAL_ID) TYPE  HUM_VENUM_T OPTIONAL
*"     VALUE(IT_EXTERNAL_ID) TYPE  HUM_EXIDV_T OPTIONAL
*"  EXPORTING
*"     VALUE(EF_POSTED) TYPE  SYSUBRC
*"     VALUE(ES_MESSAGE) TYPE  HUITEM_MESSAGES
*"     VALUE(ET_MESSAGES) TYPE  HUITEM_MESSAGES_T
*"     VALUE(ES_EMKPF) TYPE  EMKPF
*"  TABLES
*"      CT_IMSEG STRUCTURE  IMSEG OPTIONAL
*"----------------------------------------------------------------------

  DATA:
    tl_imseg TYPE vsep_t_imseg.

  CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
    EXPORTING
      if_event       = if_event
      if_simulate    = if_simulate
      if_commit      = if_commit
      if_tcode       = if_tcode
      is_imkpf       = is_imkpf
      it_move_to     = it_move_to
      it_internal_id = it_internal_id
      it_external_id = it_external_id
    IMPORTING
      ef_posted      = ef_posted
      es_message     = es_message
      et_messages    = et_messages
      es_emkpf       = es_emkpf
    CHANGING
      ct_imseg       = tl_imseg.

  ct_imseg[]       = tl_imseg[].

ENDFUNCTION.
