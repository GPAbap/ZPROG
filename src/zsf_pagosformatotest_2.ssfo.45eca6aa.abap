  data: lv_lines type i.
  ADD 1 TO gv_index.
  describe table IT_CABECERA lines lv_lines.
  if lv_lines = gv_index.
    gv_salto = 'N'.
  endif.


















