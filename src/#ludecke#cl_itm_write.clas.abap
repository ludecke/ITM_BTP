CLASS /ludecke/cl_itm_write DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
    DATA iv_error TYPE string.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_write_text,
             textkey     TYPE string,
             target_text TYPE string,
           END OF ty_write_text.
    TYPES i_write_texts TYPE STANDARD TABLE OF ty_write_text WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_request,
             object_type       TYPE string,
             object_name       TYPE string,
             targ_lang         TYPE string,
             transport_request TYPE string,
             texts             TYPE i_write_texts,
           END OF ty_request.

    TYPES: BEGIN OF ty_response,
             status            TYPE string,
             object_name       TYPE string,
             targ_lang         TYPE string,
             transport_request TYPE string,
             written           TYPE i_write_texts,
           END OF ty_response.

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



CLASS /ludecke/cl_itm_write IMPLEMENTATION.


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
        iv_error = TEXT-001. "Request body is not valid JSON
        send_error(
          response = response
          code     = 'BAD_REQUEST'
          message  = iv_error ).                            "#EC NOTEXT
        RETURN.
    ENDTRY.

    " --- call the i18n engine ---
    TRY.
        DATA(lo_i18n) = NEW /ludecke/cl_itm_i18n( ).

        lo_i18n->write(
          object_type       = wa_request-object_type
          object_name       = wa_request-object_name
          targ_lang         = wa_request-targ_lang
          transport_request = wa_request-transport_request
          texts             = CORRESPONDING #( wa_request-texts ) ).

        DATA(ls_response) = VALUE ty_response(
          status            = 'OK'
          object_name       = wa_request-object_name
          targ_lang         = wa_request-targ_lang
          transport_request = wa_request-transport_request
          written           = wa_request-texts ).

        lv_json = /ui2/cl_json=>serialize(
                    data        = ls_response
                    pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

        response->set_status( i_code = 200 i_reason = 'OK' ). "#EC NOTEXT
        response->set_content_type( 'application/json' ).   "#EC NOTEXT
        response->set_text( lv_json ).

      CATCH /ludecke/cx_itm_exception INTO DATA(lx).
        send_error(
          response = response
          code     = 'WRITE_FAILED'
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
