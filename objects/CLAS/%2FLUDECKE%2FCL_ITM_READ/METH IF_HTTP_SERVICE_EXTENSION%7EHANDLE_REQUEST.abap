  METHOD if_http_service_extension~handle_request.

    DATA wa_request TYPE ty_request.
    DATA lv_json    TYPE string.

    " --- parse request body ---
    TRY.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = request->get_text( )
            pretty_name = /ui2/cl_json=>pretty_mode-low_case
          CHANGING
            data        = wa_request ).
      CATCH cx_root.
        iv_error = TEXT-001.
        send_error(
          response = response
          code     = 'BAD_REQUEST'
          message  = iv_error ).         "Request body is not valid JSON
        RETURN.
    ENDTRY.

    " --- call the i18n engine ---
    TRY.
        DATA(lo_i18n)   = NEW /ludecke/cl_itm_i18n( ).
        DATA(ls_result) = lo_i18n->read(
          object_type = wa_request-object_type
          object_name = wa_request-object_name
          sour_lang   = wa_request-sour_lang
          targ_lang   = wa_request-targ_lang ).

        lv_json = /ui2/cl_json=>serialize(
                    data        = ls_result
                    pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

        response->set_status( i_code = 200 i_reason = 'OK' ). "#EC NOTEXT
        response->set_content_type( 'application/json' ).   "#EC NOTEXT
        response->set_text( lv_json ).

      CATCH /ludecke/cx_itm_exception INTO DATA(lx).
        send_error(
          response = response
          code     = 'READ_FAILED'
          message  = lx->get_text( ) ).                     "#EC NOTEXT
    ENDTRY.

  ENDMETHOD.