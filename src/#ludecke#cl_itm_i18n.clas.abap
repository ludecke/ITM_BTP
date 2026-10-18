CLASS /ludecke/cl_itm_i18n DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /ludecke/if_itm_i18n .

    ALIASES read  FOR /ludecke/if_itm_i18n~read .
    ALIASES write FOR /ludecke/if_itm_i18n~write .

    TYPES ty_text        TYPE /ludecke/if_itm_i18n=>ty_text .
    TYPES i_texts        TYPE /ludecke/if_itm_i18n=>i_texts .
    TYPES ty_read_result TYPE /ludecke/if_itm_i18n=>ty_read_result .
    TYPES ty_write_text  TYPE /ludecke/if_itm_i18n=>ty_write_text .
    TYPES i_write_texts  TYPE /ludecke/if_itm_i18n=>i_write_texts .

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS ic_dtel TYPE string VALUE 'DTEL' ##NO_TEXT.
    CONSTANTS ic_msgid TYPE symsgid VALUE '/LUDECKE/ITM' ##NO_TEXT.

    DATA wa_t100_key TYPE scx_t100key .

    METHODS get_dtel_attributes
      RETURNING
        VALUE(result) TYPE sxco_t_dtel_text_attributes .

    METHODS attr_for_key
      IMPORTING
        textkey       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO cl_xco_dtel_text_attribute
      RAISING
        /ludecke/cx_itm_exception .

    METHODS maxlen_for_key
      IMPORTING
        content       TYPE REF TO if_xco_dtel_content
        textkey       TYPE string
      RETURNING
        VALUE(result) TYPE i .


    "! Raises /LUDECKE/CX_ITM_EXCEPTION with message msgno of /LUDECKE/ITM;
    "! attr1 - attr4 are the values for &1 - &4.
    METHODS raise_exc
      IMPORTING
        msgno TYPE symsgno
        attr1 TYPE string OPTIONAL
        attr2 TYPE string OPTIONAL
        attr3 TYPE string OPTIONAL
        attr4 TYPE string OPTIONAL
        prev  TYPE REF TO cx_root OPTIONAL
      RAISING
        /ludecke/cx_itm_exception .

    "! Texts of an exception and all its previous exceptions, deepest first, without duplicates
    METHODS chain_text
      IMPORTING
        ix            TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE string .

ENDCLASS.



CLASS /ludecke/cl_itm_i18n IMPLEMENTATION.


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

    " package and software component - informational only, a failure must not break the read
    TRY.
        DATA(lo_package) = lo_ar->if_xco_ar_object~get_package( ).
        result-package   = lo_package->name.
        result-component = lo_package->read( )-property-software_component->name.
      CATCH cx_root ##NO_HANDLER.
        " leave package / component empty
    ENDTRY.

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


  METHOD get_dtel_attributes.
    result = VALUE #(
      ( xco_cp_data_element=>text_attribute->short_field_label )
      ( xco_cp_data_element=>text_attribute->medium_field_label )
      ( xco_cp_data_element=>text_attribute->long_field_label )
      ( xco_cp_data_element=>text_attribute->heading_field_label )
      ( xco_cp_data_element=>text_attribute->short_description ) ).
  ENDMETHOD.


  METHOD attr_for_key.
    result = xco_cp_data_element=>text_attribute->for(
               textkey ).
    IF result IS NOT BOUND.
      raise_exc( msgno = '012' attr1 = textkey ).
    ENDIF.
  ENDMETHOD.


  METHOD maxlen_for_key.
    DATA ls_label TYPE if_xco_dtel_content=>ts_field_label.

    CASE textkey.
      WHEN 'SHORT_FIELD_LABEL'.
        ls_label = content->get_short_field_label( ).
        result   = ls_label-length.
      WHEN 'MEDIUM_FIELD_LABEL'.
        ls_label = content->get_medium_field_label( ).
        result   = ls_label-length.
      WHEN 'LONG_FIELD_LABEL'.
        ls_label = content->get_long_field_label( ).
        result   = ls_label-length.
      WHEN 'HEADING_FIELD_LABEL'.
        ls_label = content->get_heading_field_label( ).
        result   = ls_label-length.
      WHEN 'SHORT_DESCRIPTION'.
        " short description is alwways 60 characters long
        result = 60.
      WHEN OTHERS.
        result = 0.
    ENDCASE.
  ENDMETHOD.





  METHOD raise_exc.
    RAISE EXCEPTION TYPE /ludecke/cx_itm_exception
      EXPORTING
        textid   = VALUE scx_t100key( msgid = ic_msgid
                                      msgno = msgno
                                      attr1 = 'TEXT1'
                                      attr2 = 'TEXT2'
                                      attr3 = 'TEXT3'
                                      attr4 = 'TEXT4' )
        previous = prev
        text1    = attr1
        text2    = attr2
        text3    = attr3
        text4    = attr4.
  ENDMETHOD.

  METHOD chain_text.

    DATA i_texts TYPE string_table.

    DATA(lx) = ix.
    WHILE lx IS BOUND.
      DATA(lv_text) = lx->get_text( ).
      IF lv_text IS NOT INITIAL AND NOT line_exists( i_texts[ table_line = lv_text ] ).
        INSERT lv_text INTO i_texts INDEX 1.
      ENDIF.
      lx = lx->previous.
    ENDWHILE.

    result = concat_lines_of( table = i_texts sep = ` / ` ).

  ENDMETHOD.


ENDCLASS.
