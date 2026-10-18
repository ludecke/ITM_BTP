  METHOD get_i18n.
    IF io_i18n IS BOUND.
      result = io_i18n.
    ELSE.
      result = NEW /ludecke/cl_itm_i18n( ).
    ENDIF.
  ENDMETHOD.