  METHOD attr_for_key.
    result = xco_cp_data_element=>text_attribute->for(
               textkey ).
    IF result IS NOT BOUND.
      raise_exc( msgno = '012' attr1 = textkey ).
    ENDIF.
  ENDMETHOD.