  METHOD get_dtel_attributes.
    result = VALUE #(
      ( xco_cp_data_element=>text_attribute->short_field_label )
      ( xco_cp_data_element=>text_attribute->medium_field_label )
      ( xco_cp_data_element=>text_attribute->long_field_label )
      ( xco_cp_data_element=>text_attribute->heading_field_label )
      ( xco_cp_data_element=>text_attribute->short_description ) ).
  ENDMETHOD.