FUNCTION-POOL zabap_funciones.              "MESSAGE-ID ..

* INCLUDE LZABAP_FUNCIONESD...               " Local class definition

TYPES: BEGIN OF st_pedidos,
         vbeln TYPE vbeln,
         erdat TYPE erdat,
         vkorg TYPE vkorg,
         vtweg TYPE vtweg,
         spart TYPE spart,
         vkbur TYPE vkbur,
         kunnr TYPE kunnr,
       END OF st_pedidos,

       BEGIN OF st_entregas,
         vbeln TYPE vbeln,
         erdat TYPE erdat,
         matnr TYPE matnr,
         lfimg TYPE lfimg,
         werks TYPE werks_d,
         disgr TYPE disgr,
         vgbel TYPE vgbel,
       END OF st_entregas,

       BEGIN OF st_created_vbeln,
         documento TYPE vbeln,
         vbeln     TYPE vbeln,
       END OF st_created_vbeln.

DATA: it_created_vbeln TYPE STANDARD TABLE OF st_Created_vbeln,
      wa_created       LIKE LINE OF it_created_vbeln.
