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
