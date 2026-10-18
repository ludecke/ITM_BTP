CLASS /ludecke/cl_itm_read DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
    DATA iv_error TYPE string.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_request,
             object_type TYPE string,
             object_name TYPE string,
             sour_lang   TYPE string,
             targ_lang   TYPE string,
           END OF ty_request.

    TYPES: BEGIN OF ty_error,
             error   TYPE abap_bool,
             code    TYPE string,
             message TYPE string,
           END OF ty_error.

    METHODS send_error
      IMPORTING
        response TYPE REF TO if_web_http_response
        code     TYPE string
        message  TYPE string .

ENDCLASS.



CLASS /ludecke/cl_itm_read IMPLEMENTATION.


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


ENDCLASS.
