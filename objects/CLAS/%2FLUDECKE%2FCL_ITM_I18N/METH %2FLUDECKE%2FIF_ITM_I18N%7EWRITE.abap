  METHOD /ludecke/if_itm_i18n~write.

    IF object_type <> ic_dtel.
      raise_exc( msgno = '010' attr1 = object_type ).
    ENDIF.

    DATA(lv_targ) = CONV spras( targ_lang ).

    DATA i_texts TYPE sxco_t_dtel_texts.

    LOOP AT texts INTO DATA(wa_in).
      DATA(lo_attr) = attr_for_key( wa_in-textkey ).
      APPEND lo_attr->create_text(
               io_value = xco_cp=>string( wa_in-target_text ) ) TO i_texts.
    ENDLOOP.

    DATA(lo_scenario) = xco_cp_cts=>change_scenario->transported(
                          CONV sxco_transport( transport_request ) ).

    TRY.
        xco_cp_i18n=>target->data_element->object( CONV sxco_ad_object_name( object_name ) )->set_translation(
          it_texts           = i_texts
          io_language        = xco_cp=>language( lv_targ )
          io_change_scenario = lo_scenario ).

      CATCH cx_root INTO DATA(lx_write).
        raise_exc( msgno = '011'
                   attr1 = object_type
                   attr2 = object_name
                   attr3 = chain_text( lx_write )
                   prev  = lx_write ).
    ENDTRY.

  ENDMETHOD.