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
       END OF st_entregas.
