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
