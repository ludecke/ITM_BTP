  PRIVATE SECTION.

    TYPES: BEGIN OF ty_line,
             object_type TYPE string,
             object_name TYPE string,
             targ_lang   TYPE string,
             textkey     TYPE string,
             source_text TYPE string,
             target_text TYPE string,
           END OF ty_line.
    TYPES ty_lines TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_request,
             project_id TYPE string,
             lines      TYPE ty_lines,
           END OF ty_request.

    TYPES: BEGIN OF ty_response,
             status   TYPE string,
             stage_id TYPE string,
             groups   TYPE i,
             lines    TYPE i,
             message  TYPE string,
           END OF ty_response.

    TYPES tt_groups TYPE STANDARD TABLE OF /ludecke/stage_o WITH EMPTY KEY.
    TYPES tt_lines  TYPE STANDARD TABLE OF /ludecke/stage_i WITH EMPTY KEY.

    "! Sends a JSON error response with the given HTTP status.
    METHODS send_error
      IMPORTING
        response TYPE REF TO if_web_http_response
        code     TYPE i
        reason   TYPE string
        text     TYPE string .

    "! Returns an error text for the first invalid line, or initial if all valid.
    METHODS validate
      IMPORTING
        lines         TYPE ty_lines
      RETURNING
        VALUE(result) TYPE string .

    "! Builds one group per object + target language and numbers the lines within each group.
    METHODS build
      IMPORTING
        payload      TYPE ty_request
        stage_id     TYPE sysuuid_x16
        now          TYPE timestampl
      EXPORTING
        stage_groups TYPE tt_groups
        stage_lines  TYPE tt_lines .
