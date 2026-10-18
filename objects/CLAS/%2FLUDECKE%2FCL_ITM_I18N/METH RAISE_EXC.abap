  METHOD raise_exc.
    RAISE EXCEPTION TYPE /ludecke/cx_itm_exception
      EXPORTING
        textid   = VALUE scx_t100key( msgid = ic_msgid
                                      msgno = msgno
                                      attr1 = 'TEXT1'
                                      attr2 = 'TEXT2'
                                      attr3 = 'TEXT3'
                                      attr4 = 'TEXT4' )
        previous = prev
        text1    = attr1
        text2    = attr2
        text3    = attr3
        text4    = attr4.
  ENDMETHOD.