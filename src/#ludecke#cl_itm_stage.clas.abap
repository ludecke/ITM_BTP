CLASS /ludecke/cl_itm_stage DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .

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

ENDCLASS.



CLASS /ludecke/cl_itm_stage IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA wa_request TYPE ty_request.
    DATA lv_now     TYPE timestampl.

    TRY.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = request->get_text( )
            pretty_name = /ui2/cl_json=>pretty_mode-low_case
          CHANGING
            data        = wa_request ).
      CATCH cx_root.
        send_error( response = response code = 400 reason = 'Bad Request'   "#EC NOTEXT
                    text = 'invalid json' ).                                "#EC NOTEXT
        RETURN.
    ENDTRY.

    DATA(lv_error) = validate( wa_request-lines ).
    IF lv_error IS NOT INITIAL.
      send_error( response = response code = 400 reason = 'Bad Request'     "#EC NOTEXT
                  text = lv_error ).
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD lv_now.
    DATA(lv_user)     = cl_abap_context_info=>get_user_technical_name( ).
    DATA(lv_stage_id) = xco_cp=>uuid( )->value.

    build( EXPORTING payload      = wa_request
                     stage_id     = lv_stage_id
                     now          = lv_now
           IMPORTING stage_groups = DATA(i_groups)
                     stage_lines  = DATA(i_lines) ).

    TRY.
        " remove batches whose groups were all applied or rejected
        DELETE FROM /ludecke/stage_h
          WHERE NOT EXISTS ( SELECT group_id FROM /ludecke/stage_o
                               WHERE stage_id = /ludecke/stage_h~stage_id ).
        INSERT /ludecke/stage_h FROM @( VALUE #(
          stage_id              = lv_stage_id
          project_id            = wa_request-project_id
          created_by            = lv_user
          created_at            = lv_now
          local_last_changed_at = lv_now ) ).
        INSERT /ludecke/stage_o FROM TABLE @i_groups.
        INSERT /ludecke/stage_i FROM TABLE @i_lines.
        COMMIT WORK.
      CATCH cx_sy_open_sql_db INTO DATA(lx_sql).
        ROLLBACK WORK.
        send_error( response = response code = 500 reason = 'Internal Server Error' "#EC NOTEXT
                    text = lx_sql->get_text( ) ).
        RETURN.
    ENDTRY.

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data        = VALUE ty_response( status   = 'OK'                     "#EC NOTEXT
                                       stage_id = lv_stage_id
                                       groups   = lines( i_groups )
                                       lines    = lines( i_lines ) )
      pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

    response->set_status( i_code = 200 i_reason = 'OK' ).                  "#EC NOTEXT
    response->set_content_type( 'application/json' ).                      "#EC NOTEXT
    response->set_text( lv_json ).

  ENDMETHOD.


  METHOD build.

    DATA lv_line_no TYPE i.

    CLEAR: stage_groups, stage_lines.

    LOOP AT payload-lines INTO DATA(wa_line)
         GROUP BY ( object_type = to_upper( wa_line-object_type )
                    object_name = to_upper( wa_line-object_name )
                    targ_lang   = wa_line-targ_lang )
         INTO DATA(wa_group_key).

      DATA(lv_group_id) = xco_cp=>uuid( )->value.

      APPEND VALUE #( group_id              = lv_group_id
                      stage_id              = stage_id
                      object_type           = wa_group_key-object_type
                      object_name           = wa_group_key-object_name
                      targ_lang             = wa_group_key-targ_lang
                      status                = /ludecke/if_stage_definitions=>ic_status_new
                      local_last_changed_at = now ) TO stage_groups.

      lv_line_no = 0.
      LOOP AT GROUP wa_group_key INTO DATA(wa_member).
        lv_line_no = lv_line_no + 1.
        APPEND VALUE #( line_id     = xco_cp=>uuid( )->value
                        group_id    = lv_group_id
                        stage_id    = stage_id
                        line_no     = lv_line_no
                        textkey     = wa_member-textkey
                        source_text = wa_member-source_text
                        target_text = wa_member-target_text ) TO stage_lines.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD validate.

    IF lines IS INITIAL.
      result = 'no lines'.                                                  "#EC NOTEXT
      RETURN.
    ENDIF.

    LOOP AT lines INTO DATA(wa_line).
      DATA(lv_index) = sy-tabix.
      IF wa_line-object_type IS INITIAL OR strlen( wa_line-object_type ) > 4
         OR wa_line-object_name IS INITIAL OR strlen( wa_line-object_name ) > 30
         OR strlen( wa_line-targ_lang ) <> 1
         OR wa_line-textkey IS INITIAL OR strlen( wa_line-textkey ) > 255
         OR strlen( wa_line-source_text ) > 255
         OR strlen( wa_line-target_text ) > 255.
        result = |invalid line { lv_index }|.                               "#EC NOTEXT
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD send_error.

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data        = VALUE ty_response( status = 'ERROR' message = text )   "#EC NOTEXT
      pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

    response->set_status( i_code = code i_reason = reason ).
    response->set_content_type( 'application/json' ).                      "#EC NOTEXT
    response->set_text( lv_json ).

  ENDMETHOD.


ENDCLASS.
