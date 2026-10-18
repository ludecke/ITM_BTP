  METHOD chain_text.

    DATA i_texts TYPE string_table.

    DATA(lx) = ix.
    WHILE lx IS BOUND.
      DATA(lv_text) = lx->get_text( ).
      IF lv_text IS NOT INITIAL AND NOT line_exists( i_texts[ table_line = lv_text ] ).
        INSERT lv_text INTO i_texts INDEX 1.
      ENDIF.
      lx = lx->previous.
    ENDWHILE.

    result = concat_lines_of( table = i_texts sep = ` / ` ).

  ENDMETHOD.