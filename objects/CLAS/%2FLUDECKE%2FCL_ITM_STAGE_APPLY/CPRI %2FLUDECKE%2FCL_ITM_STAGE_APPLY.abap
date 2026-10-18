  PRIVATE SECTION.
    "! Test double for the translation write - set only by unit tests.
    "! Static on purpose: not part of the serialized bgPF operation.
    CLASS-DATA io_i18n TYPE REF TO /ludecke/if_itm_i18n .

    DATA iv_group_id TYPE sysuuid_x16 .

    METHODS get_i18n
      RETURNING
        VALUE(result) TYPE REF TO /ludecke/if_itm_i18n .
