  METHOD maxlen_for_key.
    DATA ls_label TYPE if_xco_dtel_content=>ts_field_label.

    CASE textkey.
      WHEN 'SHORT_FIELD_LABEL'.
        ls_label = content->get_short_field_label( ).
        result   = ls_label-length.
      WHEN 'MEDIUM_FIELD_LABEL'.
        ls_label = content->get_medium_field_label( ).
        result   = ls_label-length.
      WHEN 'LONG_FIELD_LABEL'.
        ls_label = content->get_long_field_label( ).
        result   = ls_label-length.
      WHEN 'HEADING_FIELD_LABEL'.
        ls_label = content->get_heading_field_label( ).
        result   = ls_label-length.
      WHEN 'SHORT_DESCRIPTION'.
        " short description is alwways 60 characters long
        result = 60.
      WHEN OTHERS.
        result = 0.
    ENDCASE.
  ENDMETHOD.