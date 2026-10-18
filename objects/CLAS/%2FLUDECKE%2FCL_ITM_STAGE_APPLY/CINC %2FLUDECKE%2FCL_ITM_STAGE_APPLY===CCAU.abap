CLASS ltc_apply DEFINITION DEFERRED.
CLASS /ludecke/cl_itm_stage_apply DEFINITION LOCAL FRIENDS ltc_apply.

"! Records the write call; raises if iv_fail is set
CLASS ltd_i18n DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES /ludecke/if_itm_i18n.
    DATA iv_fail        TYPE abap_bool.
    DATA iv_calls       TYPE i.
    DATA iv_object_type TYPE string.
    DATA iv_object_name TYPE string.
    DATA iv_targ_lang   TYPE string.
    DATA iv_transport   TYPE string.
    DATA i_texts        TYPE /ludecke/if_itm_i18n=>i_write_texts.
ENDCLASS.

CLASS ltd_i18n IMPLEMENTATION.

  METHOD /ludecke/if_itm_i18n~read ##NEEDED.
    " not used by the apply operation
  ENDMETHOD.

  METHOD /ludecke/if_itm_i18n~write.
    iv_calls       = iv_calls + 1.
    iv_object_type = object_type.
    iv_object_name = object_name.
    iv_targ_lang   = targ_lang.
    iv_transport   = transport_request.
    i_texts        = texts.
    IF iv_fail = abap_true.
      RAISE EXCEPTION TYPE /ludecke/cx_itm_exception
        EXPORTING
          textid = VALUE scx_t100key( msgid = '/LUDECKE/ITM' msgno = '011'
                                      attr1 = 'TEXT1' attr2 = 'TEXT2' attr3 = 'TEXT3' )
          text1  = object_type
          text2  = object_name
          text3  = `test failure`.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


"!@testing /LUDECKE/CL_ITM_STAGE_APPLY
CLASS ltc_apply DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA io_env TYPE REF TO if_osql_test_environment.
    DATA io_double TYPE REF TO ltd_i18n.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.

    "! Stages the group under test (3 lines, one without target text)
    "! plus an unrelated group with 1 line; returns the group under test
    METHODS stage
      IMPORTING
        status          TYPE c
      RETURNING
        VALUE(group_id) TYPE sysuuid_x16.

    METHODS apply_success FOR TESTING RAISING cx_static_check.
    METHODS apply_error FOR TESTING RAISING cx_static_check.
    METHODS skip_not_queued FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltc_apply IMPLEMENTATION.

  METHOD class_setup.
    io_env = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( '/LUDECKE/STAGE_O' ) ( '/LUDECKE/STAGE_I' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    io_env->destroy( ).
  ENDMETHOD.

  METHOD setup.
    io_env->clear_doubles( ).
    io_double = NEW #( ).
    /ludecke/cl_itm_stage_apply=>io_i18n = io_double.
  ENDMETHOD.

  METHOD teardown.
    CLEAR /ludecke/cl_itm_stage_apply=>io_i18n.
  ENDMETHOD.

  METHOD stage.

    DATA i_groups TYPE STANDARD TABLE OF /ludecke/stage_o WITH EMPTY KEY.
    DATA i_lines  TYPE STANDARD TABLE OF /ludecke/stage_i WITH EMPTY KEY.

    group_id = xco_cp=>uuid( )->value.
    DATA(lv_other) = xco_cp=>uuid( )->value.
    DATA(lv_stage) = xco_cp=>uuid( )->value.

    i_groups = VALUE #(
      ( group_id = group_id stage_id = lv_stage object_type = 'DTEL' object_name = 'ZTEST'
        targ_lang = 'F' status = status transport_request = 'H01K900009' )
      ( group_id = lv_other stage_id = lv_stage object_type = 'DTEL' object_name = 'ZOTHER'
        targ_lang = 'F' status = /ludecke/if_stage_definitions=>ic_status_new ) ).

    " inserted out of order to verify the write receives them by line_no
    i_lines = VALUE #(
      ( line_id = xco_cp=>uuid( )->value group_id = group_id stage_id = lv_stage
        line_no = 2 textkey = 'SHORT_FIELD_LABEL' target_text = 'Court' )
      ( line_id = xco_cp=>uuid( )->value group_id = group_id stage_id = lv_stage
        line_no = 1 textkey = 'MEDIUM_FIELD_LABEL' target_text = 'Moyen' )
      ( line_id = xco_cp=>uuid( )->value group_id = group_id stage_id = lv_stage
        line_no = 3 textkey = 'HEADING_FIELD_LABEL' target_text = '' )
      ( line_id = xco_cp=>uuid( )->value group_id = lv_other stage_id = lv_stage
        line_no = 1 textkey = 'SHORT_FIELD_LABEL' target_text = 'Autre' ) ).

    io_env->insert_test_data( i_groups ).
    io_env->insert_test_data( i_lines ).
    " committed so the ROLLBACK in the error path does not remove the test data
    COMMIT WORK.

  ENDMETHOD.

  METHOD apply_success.

    DATA(lv_group) = stage( /ludecke/if_stage_definitions=>ic_status_queued ).

    NEW /ludecke/cl_itm_stage_apply( lv_group )->if_bgmc_op_single_tx_uncontr~execute( ).

    cl_abap_unit_assert=>assert_equals( act = io_double->iv_calls       exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = io_double->iv_object_type exp = `DTEL` ).
    cl_abap_unit_assert=>assert_equals( act = io_double->iv_object_name exp = `ZTEST` ).
    cl_abap_unit_assert=>assert_equals( act = io_double->iv_targ_lang   exp = `F` ).
    cl_abap_unit_assert=>assert_equals( act = io_double->iv_transport   exp = `H01K900009` ).
    cl_abap_unit_assert=>assert_equals(
      act = io_double->i_texts
      exp = VALUE /ludecke/if_itm_i18n=>i_write_texts(
              ( textkey = `MEDIUM_FIELD_LABEL` target_text = `Moyen` )
              ( textkey = `SHORT_FIELD_LABEL`  target_text = `Court` ) ) ).

    SELECT COUNT(*) FROM /ludecke/stage_o WHERE group_id = @lv_group INTO @DATA(lv_groups).
    SELECT COUNT(*) FROM /ludecke/stage_i WHERE group_id = @lv_group INTO @DATA(lv_lines).
    cl_abap_unit_assert=>assert_equals( act = lv_groups exp = 0 msg = 'group not deleted' ).
    cl_abap_unit_assert=>assert_equals( act = lv_lines  exp = 0 msg = 'lines not deleted' ).

    SELECT COUNT(*) FROM /ludecke/stage_o INTO @DATA(lv_all_groups). "#EC CI_NOWHERE
    SELECT COUNT(*) FROM /ludecke/stage_i INTO @DATA(lv_all_lines). "#EC CI_NOWHERE
    cl_abap_unit_assert=>assert_equals( act = lv_all_groups exp = 1 msg = 'other group touched' ).
    cl_abap_unit_assert=>assert_equals( act = lv_all_lines  exp = 1 msg = 'other lines touched' ).

  ENDMETHOD.

  METHOD apply_error.

    io_double->iv_fail = abap_true.
    DATA(lv_group) = stage( /ludecke/if_stage_definitions=>ic_status_queued ).

    NEW /ludecke/cl_itm_stage_apply( lv_group )->if_bgmc_op_single_tx_uncontr~execute( ).

    SELECT SINGLE status, message, applied_by FROM /ludecke/stage_o
      WHERE group_id = @lv_group
      INTO @DATA(wa_group).
    cl_abap_unit_assert=>assert_subrc( exp = 0 msg = 'group must be kept' ).
    cl_abap_unit_assert=>assert_equals(
      act = wa_group-status
      exp = /ludecke/if_stage_definitions=>ic_status_error ).
    cl_abap_unit_assert=>assert_char_cp( act = wa_group-message exp = '*test failure*' ).
    cl_abap_unit_assert=>assert_equals(
      act = wa_group-applied_by
      exp = cl_abap_context_info=>get_user_technical_name( ) ).

    SELECT COUNT(*) FROM /ludecke/stage_i WHERE group_id = @lv_group INTO @DATA(lv_lines).
    cl_abap_unit_assert=>assert_equals( act = lv_lines exp = 3 msg = 'lines must be kept' ).

  ENDMETHOD.

  METHOD skip_not_queued.

    DATA(lv_group) = stage( /ludecke/if_stage_definitions=>ic_status_new ).

    NEW /ludecke/cl_itm_stage_apply( lv_group )->if_bgmc_op_single_tx_uncontr~execute( ).

    cl_abap_unit_assert=>assert_equals( act = io_double->iv_calls exp = 0 ).
    SELECT SINGLE status FROM /ludecke/stage_o WHERE group_id = @lv_group INTO @DATA(lv_status).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = /ludecke/if_stage_definitions=>ic_status_new ).

  ENDMETHOD.

ENDCLASS.