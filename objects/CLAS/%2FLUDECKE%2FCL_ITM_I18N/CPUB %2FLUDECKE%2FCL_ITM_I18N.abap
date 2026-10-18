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
