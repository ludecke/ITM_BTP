  METHOD /ludecke/if_itm_i18n~read.

    IF object_type <> ic_dtel.
      raise_exc( msgno = '010' attr1 = object_type ).
    ENDIF.

    DATA(lv_sour) = CONV spras( sour_lang ).
    DATA(lv_targ) = CONV spras( targ_lang ).
    DATA(i_attr)  = get_dtel_attributes( ).

    DATA(lo_obj) = xco_cp_i18n=>target->data_element->object( CONV sxco_ad_object_name( object_name ) ).

    DATA(lo_src) = lo_obj->get_translation(
      io_language        = xco_cp=>language( lv_sour )
      it_text_attributes = i_attr ).
    DATA(lo_tgt) = lo_obj->get_translation(
      io_language        = xco_cp=>language( lv_targ )
      it_text_attributes = i_attr ).

    DATA(lo_ar)      = xco_cp_abap_repository=>object->dtel->for( CONV sxco_ad_object_name( object_name ) ).
    DATA(lo_content) = lo_ar->content( ).

    result-source_system_id = sy-sysid.
    result-object_type      = ic_dtel.
    result-object_name      = object_name.

    LOOP AT lo_src->texts INTO DATA(lo_src_text).
      DATA(lv_key) = lo_src_text->attribute->value.

      DATA(wa_text) = VALUE ty_text(
        textkey     = lv_key
        source_text = lo_src_text->get_string_value( )
        maxlength   = maxlen_for_key( content = lo_content textkey = lv_key ) ).

      LOOP AT lo_tgt->texts INTO DATA(lo_tgt_text).
        IF lo_tgt_text->attribute->value = lo_src_text->attribute->value.
          wa_text-target_text = lo_tgt_text->get_string_value( ).
          EXIT.
        ENDIF.
      ENDLOOP.

      APPEND wa_text TO result-texts.
    ENDLOOP.

  ENDMETHOD.