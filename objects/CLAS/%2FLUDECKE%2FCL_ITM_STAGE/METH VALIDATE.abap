  METHOD validate.

    IF lines IS INITIAL.
      result = 'no lines'.                                                  "#EC NOTEXT
      RETURN.
    ENDIF.

    LOOP AT lines INTO DATA(wa_line).
      DATA(lv_index) = sy-tabix.
      IF wa_line-object_type IS INITIAL OR strlen( wa_line-object_type ) > 4
         OR wa_line-object_name IS INITIAL OR strlen( wa_line-object_name ) > 30
         OR strlen( wa_line-targ_lang ) <> 1
         OR wa_line-textkey IS INITIAL OR strlen( wa_line-textkey ) > 255
         OR strlen( wa_line-source_text ) > 255
         OR strlen( wa_line-target_text ) > 255.
        result = |invalid line { lv_index }|.                               "#EC NOTEXT
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.