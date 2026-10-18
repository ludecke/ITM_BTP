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