************************************************************************
*                                                                      *
*            ********************************************              *
*            *   Confidential and Proprietary           *              *
*            *   XAMAI S.A. de C.V.                     *              *
*            *   All Rights Reserved                    *              *
*            ********************************************              *
*                                                                      *
************************************************************************
* Programa principal  :  ZMOV_DIA_43_TOP                               *
* Titulo              :  Include de declaraciones                      *
*                                                                      *
* Programador         : David Del Valle Mendoza
* Programador         : Jaime Hernández Velásquez (Correcciones y Mejoras)
* Fecha               : VIII.2020                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZCONC_AUT_TOP
*&---------------------------------------------------------------------*

 TABLES: KNA1.

*** Pantalla de seleccion **********************************************************************
 SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-S01.

   SELECT-OPTIONS: P_KUNNR FOR KNA1-KUNNR NO-EXTENSION NO INTERVALS OBLIGATORY.
   SELECTION-SCREEN SKIP.
   PARAMETERS: P_MODO TYPE C AS CHECKBOX DEFAULT 'X'.

 SELECTION-SCREEN END OF BLOCK B1.


 DATA: I_BSID             TYPE BSID              OCCURS 0 WITH HEADER LINE,
       I_BSID_DOC         TYPE BSID              OCCURS 0 WITH HEADER LINE,
       I_KNA1             TYPE KNA1              OCCURS 0 WITH HEADER LINE,
       I_VBRK             TYPE VBRK              OCCURS 0 WITH HEADER LINE,
       I_FEBKO            TYPE FEBKO             OCCURS 0 WITH HEADER LINE,
       I_T012K            TYPE T012K             OCCURS 0 WITH HEADER LINE,
       I_ZCONC_FORMA_PAGO TYPE ZCONC_FORMA_PAGO  OCCURS 0 WITH HEADER LINE,
       V_POS              TYPE N LENGTH 2,
       V_POS_TOT          TYPE N LENGTH 2,
       V_POS_PARC         TYPE STRING,
       V_LINE             TYPE STRING,
       V_CTA              TYPE N LENGTH 10,
       V_TEXTO_POS        TYPE STRING,
       V_BUKRS            TYPE BUKRS,
       BDCDATA_TAB        TYPE TABLE OF BDCDATA,
       BDCDATA_WA         TYPE BDCDATA,
       I_MSG              TYPE TABLE OF BDCMSGCOLL,
       WA_MSG             TYPE BDCMSGCOLL,
       V_FORMA_PAGO       TYPE C LENGTH 2,
       V_FECHA_CAMPO      TYPE C LENGTH 10,
       V_FECHA_DOCUM      TYPE C LENGTH 10,
       V_IMPORTE_FACTURA  TYPE NETWR,
       V_SALDO_FACTURA    TYPE NETWR,
       V_MONTO_DISPONIBLE TYPE NETWR,
       V_SALDO_AGOTADO    TYPE C,
       V_FLAG_FB05        TYPE C,
       V_XBLNR            TYPE STRING,
       V_BKTXT            TYPE STRING,
       V_AUGTX            TYPE STRING,
       V_KUNNR            TYPE KUNNR,
       V_KUN_SEL(10)      TYPE C.
DATA: I_ZCLIENTES_CONCIL TYPE ZCLIENTES_CONCIL OCCURS 0 WITH HEADER LINE.


 DATA: BEGIN OF I_FEBEP OCCURS 0.
         INCLUDE STRUCTURE FEBEP.
 DATA:   KUNNR TYPE KUNNR,
       END OF I_FEBEP.


 DATA: BEGIN OF I_FACTURAS_PAGAR OCCURS 0,
         TIPO      TYPE C,
         VBELN     TYPE VBELN,
         NETWR     TYPE NETWR,
         BELNR     TYPE BSID-BELNR,
         WAERS     TYPE BSID-WAERS,
         BUDAT     TYPE BSID-BUDAT,
         FECHA_DOC TYPE FEBEP-BUDAT,
         KUNNR     TYPE BSID-KUNNR.
 DATA: END OF I_FACTURAS_PAGAR.

 DATA: BEGIN OF I_SALDOS OCCURS 0,
         BUKRS   TYPE BSID-BUKRS,
         KUNNR   TYPE BSID-KUNNR,
         BUDAT   TYPE BSID-BUDAT,
         VBELN   TYPE BSID-VBELN,
         SALDO   TYPE BSID-DMBTR,
         BELNR   TYPE BSID-BELNR,
         WAERS   TYPE BSID-WAERS,
         IMPORTE TYPE BSID-DMBTR.
 DATA: END OF I_SALDOS.

 DATA: BEGIN OF I_LOG OCCURS 0,
         MSG TYPE STRING.
 DATA: END OF I_LOG.
