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