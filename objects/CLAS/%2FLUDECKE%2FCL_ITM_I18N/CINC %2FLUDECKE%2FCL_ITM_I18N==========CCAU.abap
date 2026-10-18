CLASS ltc_chain DEFINITION DEFERRED.
CLASS /ludecke/cl_itm_i18n DEFINITION LOCAL FRIENDS ltc_chain.

"! Exception with a fixed text, to build exception chains
CLASS lcx_text DEFINITION INHERITING FROM cx_no_check FINAL.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        text     TYPE string
        previous TYPE REF TO cx_root OPTIONAL.
    METHODS get_text REDEFINITION.
  PRIVATE SECTION.
    DATA iv_text TYPE string.
ENDCLASS.

CLASS lcx_text IMPLEMENTATION.
  METHOD constructor.
    super->constructor( previous = previous ).
    iv_text = text.
  ENDMETHOD.
  METHOD get_text.
    result = iv_text.
  ENDMETHOD.
ENDCLASS.


"!@testing /LUDECKE/CL_ITM_I18N
CLASS ltc_chain DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA io_cut TYPE REF TO /ludecke/cl_itm_i18n.
    METHODS setup.
    METHODS chain_single FOR TESTING.
    METHODS chain_deepest_first FOR TESTING.
    METHODS chain_duplicates FOR TESTING.
    METHODS chain_skips_empty FOR TESTING.
ENDCLASS.

CLASS ltc_chain IMPLEMENTATION.

  METHOD setup.
    io_cut = NEW #( ).
  ENDMETHOD.

  METHOD chain_single.
    cl_abap_unit_assert=>assert_equals(
      act = io_cut->chain_text( NEW lcx_text( `A` ) )
      exp = `A` ).
  ENDMETHOD.

  METHOD chain_deepest_first.
    DATA(lx) = NEW lcx_text( text = `C`
                 previous = NEW lcx_text( text = `B`
                   previous = NEW lcx_text( `A` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = io_cut->chain_text( lx )
      exp = `A / B / C` ).
  ENDMETHOD.

  METHOD chain_duplicates.
    DATA(lx) = NEW lcx_text( text = `B`
                 previous = NEW lcx_text( text = `A`
                   previous = NEW lcx_text( `A` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = io_cut->chain_text( lx )
      exp = `A / B` ).
  ENDMETHOD.

  METHOD chain_skips_empty.
    DATA(lx) = NEW lcx_text( text = `B`
                 previous = NEW lcx_text( text = ``
                   previous = NEW lcx_text( `A` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = io_cut->chain_text( lx )
      exp = `A / B` ).
  ENDMETHOD.

ENDCLASS.