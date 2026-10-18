  METHOD send_error.

    DATA(ls_err) = VALUE ty_error(
      error   = abap_true
      code    = code
      message = message ).

    DATA(lv_json) = /ui2/cl_json=>serialize(
                      data        = ls_err
                      pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

    iv_error = TEXT-002. "Bad Request
    response->set_status( i_code = 400 i_reason = iv_error ). "#EC NOTEXT
    response->set_content_type( 'application/json' ).       "#EC NOTEXT
    response->set_text( lv_json ).

  ENDMETHOD.