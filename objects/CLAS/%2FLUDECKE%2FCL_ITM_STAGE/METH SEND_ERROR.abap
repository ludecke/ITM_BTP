  METHOD send_error.

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data        = VALUE ty_response( status = 'ERROR' message = text )   "#EC NOTEXT
      pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

    response->set_status( i_code = code i_reason = reason ).
    response->set_content_type( 'application/json' ).                      "#EC NOTEXT
    response->set_text( lv_json ).

  ENDMETHOD.