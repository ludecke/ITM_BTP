CLASS lhc_batch DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Batch RESULT result.
ENDCLASS.

CLASS lhc_batch IMPLEMENTATION.

  METHOD get_global_authorizations.
    " access is controlled by the IAM app / business catalog;
    " the translation write itself is checked by XCO (S_TRANSLAT)
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_group DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Group RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Group RESULT result.
    METHODS apply FOR MODIFY
      IMPORTING keys FOR ACTION Group~apply RESULT result.
ENDCLASS.

CLASS lhc_group IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%action-apply = if_abap_behv=>mk-on.
      result-%action-apply = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.


  METHOD get_instance_features.

    READ ENTITIES OF /ludecke/r_stagebatch IN LOCAL MODE
      ENTITY Group
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(i_groups).

    " a queued group is in flight - no second apply
    result = VALUE #( FOR wa_group IN i_groups
      ( %tky          = wa_group-%tky
        %action-apply = COND #( WHEN wa_group-Status = /ludecke/if_stage_definitions=>ic_status_queued
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.


  METHOD apply.

    DATA i_update TYPE TABLE FOR UPDATE /ludecke/r_stagebatch\\Group.

    LOOP AT keys INTO DATA(wa_key).

      DATA(lv_tr) = to_upper( condense( CONV string( wa_key-%param-TransportRequest ) ) ).

      IF lv_tr IS INITIAL.
        APPEND VALUE #( %tky = wa_key-%tky ) TO failed-group.
        APPEND VALUE #( %tky = wa_key-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = TEXT-001 ) ) TO reported-group. "Enter a transport request
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky             = wa_key-%tky
                      Status           = /ludecke/if_stage_definitions=>ic_status_queued
                      TransportRequest = lv_tr
                      Message          = space
                      %control         = VALUE #( Status           = if_abap_behv=>mk-on
                                                  TransportRequest = if_abap_behv=>mk-on
                                                  Message          = if_abap_behv=>mk-on ) )
        TO i_update.

    ENDLOOP.

    IF i_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF /ludecke/r_stagebatch IN LOCAL MODE
      ENTITY Group
        UPDATE FROM i_update.

    READ ENTITIES OF /ludecke/r_stagebatch IN LOCAL MODE
      ENTITY Group
        ALL FIELDS WITH CORRESPONDING #( i_update )
      RESULT DATA(i_groups).

    result = VALUE #( FOR wa_group IN i_groups
      ( %tky = wa_group-%tky %param = wa_group ) ).

  ENDMETHOD.

ENDCLASS.


CLASS lsc_r_stagebatch DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_r_stagebatch IMPLEMENTATION.

    METHOD save_modified.

    " queued groups -> one background process each (runs the XCO write)
    LOOP AT update-group INTO DATA(wa_group)
         WHERE %control-Status = if_abap_behv=>mk-on
           AND Status = /ludecke/if_stage_definitions=>ic_status_queued.
      TRY.
          cl_bgmc_process_factory=>get_default( )->create(
            )->set_name( `ITM stage apply` ##NO_TEXT
            )->set_operation_tx_uncontrolled( NEW /ludecke/cl_itm_stage_apply( wa_group-GroupId )
            )->save_for_execution( ).
        CATCH cx_bgmc ##NO_HANDLER.
          " group stays queued and can be deleted in the app
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.