CLASS /ludecke/cx_itm_exception DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_t100_message .

    "! Values for the message placeholders &1 - &4
    DATA text1 TYPE string READ-ONLY .
    DATA text2 TYPE string READ-ONLY .
    DATA text3 TYPE string READ-ONLY .
    DATA text4 TYPE string READ-ONLY .

    METHODS constructor
      IMPORTING
        textid   LIKE if_t100_message=>t100key OPTIONAL
        previous LIKE previous OPTIONAL
        text1    TYPE string OPTIONAL
        text2    TYPE string OPTIONAL
        text3    TYPE string OPTIONAL
        text4    TYPE string OPTIONAL .
