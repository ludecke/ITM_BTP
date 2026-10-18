INTERFACE /ludecke/if_stage_definitions
  PUBLIC .

  CONSTANTS ic_status_new    TYPE c LENGTH 1 VALUE 'N' ##NO_TEXT.
  CONSTANTS ic_status_queued TYPE c LENGTH 1 VALUE 'Q' ##NO_TEXT.
  CONSTANTS ic_status_error  TYPE c LENGTH 1 VALUE 'E' ##NO_TEXT.

ENDINTERFACE.
