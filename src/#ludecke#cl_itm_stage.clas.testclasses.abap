CLASS ltc_stage DEFINITION DEFERRED.
CLASS /ludecke/cl_itm_stage DEFINITION LOCAL FRIENDS ltc_stage.

"!@testing /LUDECKE/CL_ITM_STAGE
CLASS ltc_stage DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA io_cut TYPE REF TO /ludecke/cl_itm_stage.

    METHODS setup.

    "! A valid line; parameters override single fields
    METHODS line
      IMPORTING
        object_type   TYPE string DEFAULT `DTEL`
        object_name   TYPE string DEFAULT `ZTEST`
        targ_lang     TYPE string DEFAULT `F`
        textkey       TYPE string DEFAULT `SHORT_FIELD_LABEL`
      RETURNING
        VALUE(result) TYPE /ludecke/cl_itm_stage=>ty_line.

    METHODS validate_no_lines FOR TESTING.
    METHODS validate_valid FOR TESTING.
    METHODS validate_type_too_long FOR TESTING.
    METHODS validate_iso_language FOR TESTING.
    METHODS validate_textkey_too_long FOR TESTING.
    METHODS validate_second_line FOR TESTING.
    METHODS build_one_group FOR TESTING.
    METHODS build_split_object FOR TESTING.
    METHODS build_split_language FOR TESTING.
    METHODS build_upper_case FOR TESTING.
    METHODS validate_description_too_long FOR TESTING.
ENDCLASS.

CLASS ltc_stage IMPLEMENTATION.

  METHOD setup.
    io_cut = NEW #( ).
  ENDMETHOD.

  METHOD line.
    result = VALUE #( object_type = object_type
                      object_name = object_name
                      targ_lang   = targ_lang
                      textkey     = textkey
                      source_text = `Source`
                      target_text = `Target` ).
  ENDMETHOD.

  METHOD validate_no_lines.
    cl_abap_unit_assert=>assert_equals( act = io_cut->validate( VALUE #( ) ) exp = `no lines` ).
  ENDMETHOD.

  METHOD validate_valid.
    cl_abap_unit_assert=>assert_initial( io_cut->validate( VALUE #( ( line( ) ) ) ) ).
  ENDMETHOD.

  METHOD validate_type_too_long.
    cl_abap_unit_assert=>assert_equals(
      act = io_cut->validate( VALUE #( ( line( object_type = `DTELX` ) ) ) )
      exp = `invalid line 1` ).
  ENDMETHOD.

  METHOD validate_iso_language.
    cl_abap_unit_assert=>assert_equals(
      act = io_cut->validate( VALUE #( ( line( targ_lang = `FR` ) ) ) )
      exp = `invalid line 1` ).
  ENDMETHOD.

  METHOD validate_textkey_too_long.
    cl_abap_unit_assert=>assert_equals(
      act = io_cut->validate( VALUE #( ( line( textkey = repeat( val = `X` occ = 256 ) ) ) ) )
      exp = `invalid line 1` ).
  ENDMETHOD.

  METHOD validate_second_line.
    cl_abap_unit_assert=>assert_equals(
      act = io_cut->validate( VALUE #( ( line( ) ) ( line( object_name = `` ) ) ) )
      exp = `invalid line 2` ).
  ENDMETHOD.

  METHOD build_one_group.

    DATA(lv_stage) = xco_cp=>uuid( )->value.

    io_cut->build(
      EXPORTING payload      = VALUE #( lines = VALUE #( ( line( textkey = `SHORT_FIELD_LABEL` ) )
                                                         ( line( textkey = `MEDIUM_FIELD_LABEL` ) ) ) )
                stage_id     = lv_stage
                now          = 0
      IMPORTING stage_groups = DATA(i_groups)
                stage_lines  = DATA(i_lines) ).

    cl_abap_unit_assert=>assert_equals( act = lines( i_groups ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lines( i_lines )  exp = 2 ).

    DATA(wa_group) = i_groups[ 1 ].
    cl_abap_unit_assert=>assert_equals( act = wa_group-stage_id exp = lv_stage ).
    cl_abap_unit_assert=>assert_equals(
      act = wa_group-status
      exp = /ludecke/if_stage_definitions=>ic_status_new ).

    cl_abap_unit_assert=>assert_equals( act = i_lines[ 1 ]-line_no exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = i_lines[ 2 ]-line_no exp = 2 ).
    LOOP AT i_lines INTO DATA(wa_line).
      cl_abap_unit_assert=>assert_equals( act = wa_line-group_id exp = wa_group-group_id ).
      cl_abap_unit_assert=>assert_equals( act = wa_line-stage_id exp = lv_stage ).
    ENDLOOP.

  ENDMETHOD.

  METHOD build_split_object.

    io_cut->build(
      EXPORTING payload      = VALUE #( lines = VALUE #( ( line( object_name = `ZA` ) )
                                                         ( line( object_name = `ZB` ) ) ) )
                stage_id     = xco_cp=>uuid( )->value
                now          = 0
      IMPORTING stage_groups = DATA(i_groups)
                stage_lines  = DATA(i_lines) ).

    cl_abap_unit_assert=>assert_equals( act = lines( i_groups ) exp = 2 ).
    " each group numbers its lines from 1
    LOOP AT i_lines INTO DATA(wa_line).
      cl_abap_unit_assert=>assert_equals( act = wa_line-line_no exp = 1 ).
    ENDLOOP.

  ENDMETHOD.

  METHOD build_split_language.

    io_cut->build(
      EXPORTING payload      = VALUE #( lines = VALUE #( ( line( targ_lang = `F` ) )
                                                         ( line( targ_lang = `D` ) ) ) )
                stage_id     = xco_cp=>uuid( )->value
                now          = 0
      IMPORTING stage_groups = DATA(i_groups) ).

    cl_abap_unit_assert=>assert_equals( act = lines( i_groups ) exp = 2 ).

  ENDMETHOD.

  METHOD build_upper_case.

    io_cut->build(
      EXPORTING payload      = VALUE #( lines = VALUE #( ( line( object_type = `dtel` object_name = `ztest` ) )
                                                         ( line( object_type = `DTEL` object_name = `ZTEST` ) ) ) )
                stage_id     = xco_cp=>uuid( )->value
                now          = 0
      IMPORTING stage_groups = DATA(i_groups) ).

    " mixed case of the same object is one group, stored upper case
    cl_abap_unit_assert=>assert_equals( act = lines( i_groups ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = i_groups[ 1 ]-object_type exp = 'DTEL' ).
    cl_abap_unit_assert=>assert_equals( act = i_groups[ 1 ]-object_name exp = 'ZTEST' ).

  ENDMETHOD.

  METHOD validate_description_too_long.
    cl_abap_unit_assert=>assert_equals(
      act = io_cut->validate( lines       = VALUE #( ( line( ) ) )
                              description = repeat( val = `X` occ = 81 ) )
      exp = `description too long` ).
  ENDMETHOD.

ENDCLASS.
