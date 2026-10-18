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
