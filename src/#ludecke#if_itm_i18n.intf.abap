INTERFACE /ludecke/if_itm_i18n
  PUBLIC .

  TYPES: BEGIN OF ty_text,
           textkey     TYPE string,
           source_text TYPE string,
           target_text TYPE string,
           maxlength   TYPE i,
         END OF ty_text.
  TYPES i_texts TYPE STANDARD TABLE OF ty_text WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_read_result,
           source_system_id TYPE string,
           object_type      TYPE string,
           object_name      TYPE string,
           component        TYPE string,
           package          TYPE string,
           texts            TYPE i_texts,
         END OF ty_read_result.

  TYPES: BEGIN OF ty_write_text,
           textkey     TYPE string,
           target_text TYPE string,
         END OF ty_write_text.
  TYPES i_write_texts TYPE STANDARD TABLE OF ty_write_text WITH DEFAULT KEY.

  METHODS read
    IMPORTING
      object_type   TYPE string
      object_name   TYPE string
      sour_lang     TYPE string
      targ_lang     TYPE string
    RETURNING
      VALUE(result) TYPE ty_read_result
    RAISING
      /ludecke/cx_itm_exception .

  METHODS write
    IMPORTING
      object_type       TYPE string
      object_name       TYPE string
      targ_lang         TYPE string
      transport_request TYPE string
      texts             TYPE i_write_texts
    RAISING
      /ludecke/cx_itm_exception .

ENDINTERFACE.
