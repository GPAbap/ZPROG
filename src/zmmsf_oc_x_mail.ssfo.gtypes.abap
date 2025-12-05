TYPES: BEGIN OF tt_display,
         po_item    TYPE ebelp,
         material   TYPE matnr,
         quantity   TYPE bstmg,
         unit       TYPE bstme,
         maktx      TYPE maktx,
         name1      TYPE t001w-name1,
         lgobe      TYPE t001l-lgobe,
         net_value  TYPE nwertbapi,
         net_price  TYPE bpreibapi,
         eeind(10)  TYPE c,
         address2   TYPE adrn2,
       END OF tt_display.





