  METHOD if_bgmc_op_single_tx_uncontr~execute.

    DATA lv_message TYPE string.
    DATA lv_now     TYPE timestampl.

    SELECT SINGLE * FROM /ludecke/stage_o
      WHERE group_id = @iv_group_id
      INTO @DATA(wa_group).
    " only a queued group is processed - guards against double execution
    IF sy-subrc <> 0 OR wa_group-status <> /ludecke/if_stage_definitions=>ic_status_queued.
      RETURN.
    ENDIF.

    SELECT FROM /ludecke/stage_i
      FIELDS textkey, target_text
      WHERE group_id = @iv_group_id
      ORDER BY line_no
      INTO TABLE @DATA(i_lines).

    " lines without a target text are not written
    DATA(i_texts) = VALUE /ludecke/if_itm_i18n=>i_write_texts(
      FOR wa_line IN i_lines WHERE ( target_text IS NOT INITIAL )
      ( textkey = wa_line-textkey target_text = wa_line-target_text ) ).

    TRY.
        get_i18n( )->write(
          object_type       = CONV #( wa_group-object_type )
          object_name       = CONV #( wa_group-object_name )
          targ_lang         = CONV #( wa_group-targ_lang )
          transport_request = CONV #( wa_group-transport_request )
          texts             = i_texts ).

        " written - the transport is the record, the staged group is no longer needed
        DELETE FROM /ludecke/stage_i WHERE group_id = @iv_group_id.
        DELETE FROM /ludecke/stage_o WHERE group_id = @iv_group_id.
        COMMIT WORK.
        RETURN.

      CATCH /ludecke/cx_itm_exception INTO DATA(lx_itm).
        ROLLBACK WORK.
        lv_message = lx_itm->get_text( ).
      CATCH cx_root INTO DATA(lx_root).
        ROLLBACK WORK.
        lv_message = lx_root->get_text( ).
    ENDTRY.

    " failed - keep the group for the BTP user, with the reason
    GET TIME STAMP FIELD lv_now.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    UPDATE /ludecke/stage_o
      SET status                = @/ludecke/if_stage_definitions=>ic_status_error,
          message               = @lv_message,
          applied_by            = @lv_user,
          applied_at            = @lv_now,
          local_last_changed_at = @lv_now
      WHERE group_id = @iv_group_id.

    COMMIT WORK.

  ENDMETHOD.