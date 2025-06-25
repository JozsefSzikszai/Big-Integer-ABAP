CLASS zcl_big_integer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_digits TYPE STANDARD TABLE OF num1 WITH DEFAULT KEY .

    METHODS abs
      RETURNING
        VALUE(ro_result) TYPE REF TO zcl_big_integer .
    METHODS constructor
      IMPORTING
        !iv_number TYPE string
      RAISING
        zcx_invalid_number .
    METHODS divide
      IMPORTING
        !io_bi_to_divide TYPE REF TO zcl_big_integer
      RETURNING
        VALUE(ro_result) TYPE REF TO zcl_big_integer
      RAISING
        cx_sy_zerodivide .
    METHODS equals
      IMPORTING
        !io_bi_to_compare TYPE REF TO zcl_big_integer
      RETURNING
        VALUE(rv_result)  TYPE i .
    METHODS get_sign
      RETURNING
        VALUE(rv_sign) TYPE char1 .
    METHODS multiply
      IMPORTING
        !io_bi_to_multiply TYPE REF TO zcl_big_integer
      RETURNING
        VALUE(ro_result)   TYPE REF TO zcl_big_integer .
    METHODS remainder
      IMPORTING
        !io_bi_to_divide TYPE REF TO zcl_big_integer
      RETURNING
        VALUE(ro_result) TYPE REF TO zcl_big_integer
      RAISING
        cx_sy_zerodivide .
    METHODS subtract
      IMPORTING
        !io_bi_to_subtract TYPE REF TO zcl_big_integer
      RETURNING
        VALUE(ro_result)   TYPE REF TO zcl_big_integer .
    METHODS sum
      IMPORTING
        !io_bi_to_add    TYPE REF TO zcl_big_integer
      RETURNING
        VALUE(ro_result) TYPE REF TO zcl_big_integer .
    METHODS to_array
      RETURNING
        VALUE(rt_digits) TYPE tt_digits .
    METHODS to_string
      RETURNING
        VALUE(rv_number) TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS mc_sign_negative TYPE char1 VALUE '-' ##NO_TEXT.
    CONSTANTS mc_sign_positive TYPE char1 VALUE '+' ##NO_TEXT.
    CONSTANTS mc_zero TYPE string VALUE '0' ##NO_TEXT.
    DATA mt_digits TYPE tt_digits .
    DATA mv_number TYPE string .
    DATA mv_sign TYPE char1 .

    METHODS calculate_remainder
      IMPORTING
        !it_digits           TYPE tt_digits
        !it_digits_to_divide TYPE tt_digits
      RETURNING
        VALUE(rt_result)     TYPE tt_digits .
    METHODS cleanup_number
      IMPORTING
        !iv_number       TYPE string
      RETURNING
        VALUE(rv_number) TYPE string
      RAISING
        zcx_invalid_number .
    METHODS compare_numbers
      IMPORTING
        !it_digits            TYPE tt_digits
        !it_digits_to_compare TYPE tt_digits
      RETURNING
        VALUE(rv_equals)      TYPE i .
    METHODS compare_same_length_numbers
      IMPORTING
        !it_digits            TYPE tt_digits
        !it_digits_to_compare TYPE tt_digits
      RETURNING
        VALUE(rv_equals)      TYPE i .
    METHODS convert_to_array
      IMPORTING
        !iv_number       TYPE string
      RETURNING
        VALUE(rt_digits) TYPE tt_digits .
    METHODS convert_to_string
      IMPORTING
        !it_digits       TYPE tt_digits
      RETURNING
        VALUE(rv_number) TYPE string .
    METHODS divide_two_numbers
      IMPORTING
        !it_digits           TYPE tt_digits
        !it_digits_to_divide TYPE tt_digits
      RETURNING
        VALUE(rt_result)     TYPE tt_digits .
    METHODS mirror_array
      IMPORTING
        !it_digits       TYPE tt_digits
      RETURNING
        VALUE(rt_result) TYPE tt_digits .
    METHODS multiply_two_numbers
      IMPORTING
        !it_digits             TYPE tt_digits
        !it_digits_to_multiply TYPE tt_digits
      RETURNING
        VALUE(rt_result)       TYPE tt_digits .
    METHODS subtract_two_numbers
      IMPORTING
        !it_digits             TYPE tt_digits
        !it_digits_to_subtract TYPE tt_digits
      RETURNING
        VALUE(rt_result)       TYPE tt_digits .
    METHODS sum_two_numbers
      IMPORTING
        !it_digits        TYPE tt_digits
        !it_digits_to_add TYPE tt_digits
      RETURNING
        VALUE(rt_result)  TYPE tt_digits .
    METHODS trim_number
      IMPORTING
        !iv_number       TYPE string
      RETURNING
        VALUE(rv_number) TYPE string .
ENDCLASS.



CLASS ZCL_BIG_INTEGER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->ABS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RO_RESULT                      TYPE REF TO ZCL_BIG_INTEGER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD abs.

    ro_result =  NEW #( mv_number ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->CALCULATE_REMAINDER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DIGITS                      TYPE        TT_DIGITS
* | [--->] IT_DIGITS_TO_DIVIDE            TYPE        TT_DIGITS
* | [<-()] RT_RESULT                      TYPE        TT_DIGITS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD calculate_remainder.

    DATA(lt_digits) = it_digits.

    " it_digits must be the higher number
    " keep subtracting as long as needed
    DO.
      DATA(equal) = compare_numbers( it_digits = lt_digits
                                     it_digits_to_compare = it_digits_to_divide ).
      CASE equal.
        WHEN -1.
          lt_digits = subtract_two_numbers( it_digits = lt_digits
                                            it_digits_to_subtract = it_digits_to_divide ).
        WHEN 0.
          rt_result = VALUE #( ( |0| ) ).
          EXIT.
        WHEN 1.
          " This should not happen :)
          rt_result = lt_digits.
          EXIT.
      ENDCASE.

    ENDDO.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->CLEANUP_NUMBER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NUMBER                      TYPE        STRING
* | [<-()] RV_NUMBER                      TYPE        STRING
* | [!CX!] ZCX_INVALID_NUMBER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD cleanup_number.

    rv_number = trim_number( iv_number ).

    " Empty string is taken as zero
    IF rv_number IS INITIAL.
      rv_number = mc_zero.
      RETURN.
    ENDIF.

    " Zero, nothing to do
    IF rv_number EQ mc_zero.
      RETURN.
    ENDIF.

    " Single digit
    IF strlen( rv_number ) EQ 1.
      IF rv_number CO '123456789'.
        mv_sign = mc_sign_positive.
        RETURN.
      ELSE.
        RAISE EXCEPTION TYPE zcx_invalid_number.
      ENDIF.
    ENDIF.

    " First position: sign or a digit
    IF rv_number(1) CN '0123456789-+'.
      RAISE EXCEPTION TYPE zcx_invalid_number.
    ENDIF.

    " From second position: digits only
    IF rv_number+1 CN '0123456789'.
      RAISE EXCEPTION TYPE zcx_invalid_number.
    ENDIF.

    " Check negative sign, only first position counts
    IF rv_number(1) = mc_sign_negative.
      mv_sign = mc_sign_negative.
      rv_number = trim_number( substring( val = rv_number
                                          off = 1
                                          len = ( strlen( rv_number ) - 1 ) ) ).
    ELSEIF rv_number(1) = mc_sign_positive.
      mv_sign = mc_sign_positive.
      rv_number = trim_number( substring( val = rv_number
                                          off = 1
                                          len = ( strlen( rv_number ) - 1 ) ) ).
    ELSE.
      mv_sign = mc_sign_positive.
      rv_number = trim_number( rv_number ).
    ENDIF.

    " Zero cannot be positive or negative
    IF ( rv_number IS INITIAL   OR
         rv_number EQ mc_zero ) AND
         mv_sign   NE ' '.
      RAISE EXCEPTION TYPE zcx_invalid_number.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->COMPARE_NUMBERS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DIGITS                      TYPE        TT_DIGITS
* | [--->] IT_DIGITS_TO_COMPARE           TYPE        TT_DIGITS
* | [<-()] RV_EQUALS                      TYPE        I
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD compare_numbers.

    " 1 Number to compare is greater, 0 equals, -1 number to compare is smaller
    rv_equals = COND #( WHEN lines( it_digits ) > lines( it_digits_to_compare )
                             THEN -1
                        WHEN lines( it_digits ) < lines( it_digits_to_compare )
                             THEN 1
                        ELSE compare_same_length_numbers( it_digits            = it_digits
                                                          it_digits_to_compare = it_digits_to_compare ) ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->COMPARE_SAME_LENGTH_NUMBERS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DIGITS                      TYPE        TT_DIGITS
* | [--->] IT_DIGITS_TO_COMPARE           TYPE        TT_DIGITS
* | [<-()] RV_EQUALS                      TYPE        I
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD compare_same_length_numbers.

    " The two digits arrays have to have the same size
    " 1 Number to compare is greater, 0 equals, -1 number to compare is smaller
    " Same...
    IF it_digits = it_digits_to_compare.
      rv_equals = 0.
      RETURN.
    ENDIF.

    " If not same => compare digit by digit
    DO lines( it_digits ) TIMES.
      IF it_digits[ sy-index ] EQ it_digits_to_compare[ sy-index ].
        CONTINUE.
      ELSEIF it_digits[ sy-index ] GT it_digits_to_compare[ sy-index ].
        rv_equals = -1.
        RETURN.
      ELSE.
        rv_equals = 1.
        RETURN.
      ENDIF.
    ENDDO.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NUMBER                      TYPE        STRING
* | [!CX!] ZCX_INVALID_NUMBER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

    TRY.
        mv_number = cleanup_number( iv_number ).
      CATCH zcx_invalid_number.
        RAISE EXCEPTION TYPE zcx_invalid_number.
    ENDTRY.

    mt_digits = convert_to_array( mv_number ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->CONVERT_TO_ARRAY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NUMBER                      TYPE        STRING
* | [<-()] RT_DIGITS                      TYPE        TT_DIGITS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD convert_to_array.

    DATA(position) = 0.

    WHILE position < strlen( iv_number ).
      APPEND iv_number+position(1) TO rt_digits.
      ADD 1 TO position.
    ENDWHILE.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->CONVERT_TO_STRING
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DIGITS                      TYPE        TT_DIGITS
* | [<-()] RV_NUMBER                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD convert_to_string.

    LOOP AT it_digits
         ASSIGNING FIELD-SYMBOL(<ls_digit>).
      rv_number = rv_number && <ls_digit>.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->DIVIDE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_BI_TO_DIVIDE                TYPE REF TO ZCL_BIG_INTEGER
* | [<-()] RO_RESULT                      TYPE REF TO ZCL_BIG_INTEGER
* | [!CX!] CX_SY_ZERODIVIDE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD divide.

    " division by zero => not possible
    IF io_bi_to_divide->get_sign( ) = ' '.
      RAISE EXCEPTION TYPE cx_sy_zerodivide.
    ENDIF.

    " Zero is divided by any number => result is zero
    IF mv_number = mc_zero.
      ro_result = NEW zcl_big_integer( mc_zero ).
      RETURN.
    ENDIF.

    ro_result = NEW zcl_big_integer( COND #( WHEN mv_sign EQ io_bi_to_divide->get_sign( )
                                                  THEN mc_sign_positive
                                             ELSE mc_sign_negative ) &&
                                     SWITCH #( compare_numbers( it_digits = mt_digits
                                                                it_digits_to_compare = io_bi_to_divide->to_array( ) )
                                               WHEN -1 THEN convert_to_string( divide_two_numbers( it_digits = mt_digits
                                                                                                   it_digits_to_divide = io_bi_to_divide->to_array( ) ) )
                                               ELSE mc_zero ) ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->DIVIDE_TWO_NUMBERS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DIGITS                      TYPE        TT_DIGITS
* | [--->] IT_DIGITS_TO_DIVIDE            TYPE        TT_DIGITS
* | [<-()] RT_RESULT                      TYPE        TT_DIGITS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD divide_two_numbers.

    DATA(lt_digits) = it_digits.

    " As long as number is higher, keep subtracting it
    DO.
      DATA(equals) = compare_numbers( it_digits            = lt_digits
                                      it_digits_to_compare = it_digits_to_divide ).
      IF equals EQ 1.
        EXIT.
      ENDIF.

      rt_result = sum_two_numbers( it_digits        = rt_result
                                   it_digits_to_add = VALUE #( ( |1| ) ) ).

      CASE equals.
        WHEN -1.
          lt_digits = subtract_two_numbers( it_digits             = lt_digits
                                            it_digits_to_subtract = it_digits_to_divide ).
        WHEN 0.
          EXIT.
      ENDCASE.
    ENDDO.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->EQUALS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_BI_TO_COMPARE               TYPE REF TO ZCL_BIG_INTEGER
* | [<-()] RV_RESULT                      TYPE        I
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD equals.

    " 1 Number to compare is greater, 0 equals, -1 number to compare is smaller
    " Check sign of our number, than check sign of number to compare
    rv_result = SWITCH #( mv_sign
                          WHEN ' ' " Our number is zero
                               THEN SWITCH #( io_bi_to_compare->get_sign( )
                                               WHEN ' ' THEN 0
                                               WHEN mc_sign_positive THEN 1
                                               WHEN mc_sign_negative THEN -1 )
                          WHEN mc_sign_positive " Our number is positive
                               THEN SWITCH #( io_bi_to_compare->get_sign( )
                                              WHEN mc_sign_positive
                                                   THEN compare_numbers( it_digits            = mt_digits
                                                                         it_digits_to_compare = io_bi_to_compare->to_array( ) )
                                              ELSE -1 )
                          WHEN mc_sign_negative " Our number is negative
                               THEN SWITCH #( io_bi_to_compare->get_sign( )
                                              WHEN mc_sign_negative
                                                   THEN compare_numbers( it_digits            = io_bi_to_compare->to_array( )
                                                                         it_digits_to_compare = mt_digits  )
                                              ELSE 1 ) ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->GET_SIGN
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_SIGN                        TYPE        CHAR1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_sign.

    rv_sign = mv_sign.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->MIRROR_ARRAY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DIGITS                      TYPE        TT_DIGITS
* | [<-()] RT_RESULT                      TYPE        TT_DIGITS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD mirror_array.

    " Turn array back
    CHECK it_digits IS NOT INITIAL.
    rt_result = VALUE #( FOR i = lines( it_digits ) THEN i - 1 WHILE i > 0
                      ( it_digits[ i ] ) ).
    WHILE rt_result[ 1 ] EQ |0|
      AND lines( rt_result ) > 1.
      DELETE rt_result INDEX 1.
    ENDWHILE.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->MULTIPLY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_BI_TO_MULTIPLY              TYPE REF TO ZCL_BIG_INTEGER
* | [<-()] RO_RESULT                      TYPE REF TO ZCL_BIG_INTEGER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD multiply.

    " If any number is zero => result is zero
    IF io_bi_to_multiply->to_string( ) = mc_zero OR
       to_string( )                    = mc_zero.
      ro_result = NEW #( mc_zero ).
      RETURN.
    ENDIF.

    " Negative sign if signs are different
    ro_result = NEW #( COND #( WHEN mv_sign = io_bi_to_multiply->get_sign( ) THEN space
                               ELSE mc_sign_negative )
                       && convert_to_string( multiply_two_numbers( it_digits             = mt_digits
                                                                   it_digits_to_multiply = io_bi_to_multiply->to_array( ) ) ) ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->MULTIPLY_TWO_NUMBERS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DIGITS                      TYPE        TT_DIGITS
* | [--->] IT_DIGITS_TO_MULTIPLY          TYPE        TT_DIGITS
* | [<-()] RT_RESULT                      TYPE        TT_DIGITS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD multiply_two_numbers.

    DATA result TYPE n LENGTH 2.
    DATA(remainder) = 0.

    " Calculation is done digit by digit and backwards (like on paper)
    DO lines( it_digits ) TIMES.
      DATA(pos_outer) = lines( it_digits ) - sy-index + 1.
      DATA(position) = sy-index.
      DO lines( it_digits_to_multiply ) TIMES .
        DATA(pos_inner) = lines( it_digits_to_multiply ) - sy-index + 1.
        result = it_digits[ pos_outer ] * it_digits_to_multiply[ pos_inner ] + remainder.
        remainder = 0.
        IF line_exists( rt_result[ position ] ).
          result = result + rt_result[ position ].
          rt_result[ position ] = result+1(1).
        ELSE.
          INSERT result+1 INTO TABLE rt_result.
        ENDIF.
        remainder = result(1).
        ADD 1 TO position.
      ENDDO.
      IF remainder NE 0.
        INSERT CONV num1( remainder ) INTO TABLE rt_result.
        remainder = 0.
      ENDIF.
    ENDDO.

    rt_result = mirror_array( rt_result ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->REMAINDER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_BI_TO_DIVIDE                TYPE REF TO ZCL_BIG_INTEGER
* | [<-()] RO_RESULT                      TYPE REF TO ZCL_BIG_INTEGER
* | [!CX!] CX_SY_ZERODIVIDE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD remainder.

    " division by zero => not possible
    IF io_bi_to_divide->get_sign( ) = ' '.
      RAISE EXCEPTION TYPE cx_sy_zerodivide.
    ENDIF.

    " Zero is divided by any number => remainder is zero
    IF mv_number = mc_zero.
      ro_result = NEW zcl_big_integer( mc_zero ).
      RETURN.
    ENDIF.

    DATA(equal) = compare_numbers( it_digits            = mt_digits
                                   it_digits_to_compare = io_bi_to_divide->to_array( ) ).

    ro_result = SWITCH #( equal
                          WHEN -1 THEN NEW zcl_big_integer( convert_to_string(
                                  SWITCH #( mv_sign
                                            WHEN mc_sign_positive
                                                 THEN calculate_remainder( it_digits           = mt_digits
                                                                           it_digits_to_divide = io_bi_to_divide->to_array( ) )
                                            WHEN mc_sign_negative
                                                 THEN subtract_two_numbers( it_digits = io_bi_to_divide->to_array( )
                                                                            it_digits_to_subtract = calculate_remainder( it_digits           = mt_digits
                                                                                                                         it_digits_to_divide = io_bi_to_divide->to_array( ) ) ) ) ) )
                          WHEN 0 THEN NEW zcl_big_integer( mc_zero )
                          WHEN 1 THEN SWITCH #( mv_sign
                                                WHEN mc_sign_positive
                                                     THEN NEW zcl_big_integer( to_string( ) )
                                                WHEN mc_sign_negative
                                                     THEN NEW zcl_big_integer( convert_to_string( subtract_two_numbers( it_digits = io_bi_to_divide->to_array( )
                                                                                                                        it_digits_to_subtract = mt_digits ) ) ) ) ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->SUBTRACT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_BI_TO_SUBTRACT              TYPE REF TO ZCL_BIG_INTEGER
* | [<-()] RO_RESULT                      TYPE REF TO ZCL_BIG_INTEGER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD subtract.

    " Zero is subtractd => result is the same number
    IF io_bi_to_subtract->to_string( ) EQ mc_zero.
      ro_result = NEW zcl_big_integer( mv_number ).
      RETURN.
    ENDIF.

    " Subtracted from zero => result is the same number multiplied with -1
    IF mv_number EQ mc_zero.
      ro_result = NEW zcl_big_integer( SWITCH #( io_bi_to_subtract->get_sign( )
                                                 WHEN mc_sign_positive THEN mc_sign_negative
                                                 ELSE space ) && io_bi_to_subtract->to_string( ) ).
      RETURN.
    ENDIF.

    IF mv_sign NE io_bi_to_subtract->get_sign( ).
      " signs are different => sum
      ro_result = NEW zcl_big_integer( mv_sign && convert_to_string( sum_two_numbers( it_digits = mt_digits
                                                                                      it_digits_to_add = io_bi_to_subtract->to_array( ) ) ) ).
    ELSE.
      " signs are the same => subtract
      DATA(equals) = compare_numbers( it_digits = mt_digits
                                      it_digits_to_compare = io_bi_to_subtract->to_array( ) ). "equals( io_bi_to_subtract ).
      ro_result = NEW zcl_big_integer(
        SWITCH char1( equals
                      WHEN -1 THEN SWITCH #( mv_sign
                                             WHEN mc_sign_positive THEN mc_sign_positive
                                             ELSE mc_sign_negative )
                      WHEN 1 THEN SWITCH #( mv_sign
                                            WHEN mc_sign_positive THEN mc_sign_negative
                                            ELSE mc_sign_positive ) ) &&
        convert_to_string( SWITCH #( equals
                                     WHEN -1 THEN subtract_two_numbers( it_digits             = mt_digits
                                                                        it_digits_to_subtract = io_bi_to_subtract->to_array( ) )
                                     WHEN 1 THEN subtract_two_numbers( it_digits             = io_bi_to_subtract->to_array( )
                                                                       it_digits_to_subtract = mt_digits ) ) ) ).

    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->SUBTRACT_TWO_NUMBERS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DIGITS                      TYPE        TT_DIGITS
* | [--->] IT_DIGITS_TO_SUBTRACT          TYPE        TT_DIGITS
* | [<-()] RT_RESULT                      TYPE        TT_DIGITS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD subtract_two_numbers.

    " it_digits should be the higher number
    DATA lt_digits TYPE tt_digits.
    DATA(index) = lines( it_digits ).
    DATA(index_to_subtract) = lines( it_digits_to_subtract ).
    DATA(remainder) = 0.
    DATA result TYPE i.

    WHILE index > 0
       OR index_to_subtract > 0.
      result = remainder.
      CLEAR remainder.
      IF index > 0.
        result = result + it_digits[ index ].
      ENDIF.
      IF index_to_subtract > 0.
        result = result - it_digits_to_subtract[ index_to_subtract ].
        IF result < 0.
          ADD 10 TO result.
          remainder = -1.
        ENDIF.
      ENDIF.
      INSERT CONV numc1( result ) INTO TABLE lt_digits.
      SUBTRACT 1 FROM: index, index_to_subtract.
    ENDWHILE.

    rt_result = mirror_array( lt_digits ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->SUM
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_BI_TO_ADD                   TYPE REF TO ZCL_BIG_INTEGER
* | [<-()] RO_RESULT                      TYPE REF TO ZCL_BIG_INTEGER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD sum.

    " Zero added, no change
    IF io_bi_to_add->to_string( ) = mc_zero.
      ro_result = NEW zcl_big_integer( to_string( ) ).
      RETURN.
    ENDIF.

    " Number is zero, added numer is the result
    IF mv_number = mc_zero.
      ro_result = NEW zcl_big_integer( io_bi_to_add->to_string( ) ).
      RETURN.
    ENDIF.

    IF mv_sign = io_bi_to_add->get_sign( ).
      " Summed numbers are positive => result is positive, summed numbers are negative => result is negative
      ro_result = NEW zcl_big_integer( SWITCH #( mv_sign
                                                 WHEN mc_sign_positive THEN ||
                                                 ELSE mc_sign_negative ) &&
                                       convert_to_string( sum_two_numbers( it_digits        = mt_digits
                                                                           it_digits_to_add = io_bi_to_add->to_array( ) ) ) ).
    ELSE.
      " Subtract lower number from higher, result gets the sign of higher number
      DATA(equals) = compare_numbers( it_digits            = mt_digits
                                      it_digits_to_compare = io_bi_to_add->to_array( ) ).
      ro_result = NEW zcl_big_integer(
        SWITCH #( equals
                  WHEN 1 THEN io_bi_to_add->get_sign( )
                  WHEN -1 THEN mv_sign ) &&
        convert_to_string( SWITCH #( equals
                                     WHEN 1
                                          THEN subtract_two_numbers( it_digits             = io_bi_to_add->to_array( )
                                                                     it_digits_to_subtract = mt_digits )
                                     WHEN -1
                                          THEN subtract_two_numbers( it_digits             = mt_digits
                                                                     it_digits_to_subtract = io_bi_to_add->to_array( ) ) ) ) ).
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->SUM_TWO_NUMBERS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DIGITS                      TYPE        TT_DIGITS
* | [--->] IT_DIGITS_TO_ADD               TYPE        TT_DIGITS
* | [<-()] RT_RESULT                      TYPE        TT_DIGITS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD sum_two_numbers.

    DATA result TYPE n LENGTH 2.
    DATA(remainder) = 0.
    DATA(index) = lines( it_digits ).
    DATA(index_to_add) = lines( it_digits_to_add ).
    DATA lt_result TYPE tt_digits.

    WHILE index > 0
       OR index_to_add > 0
       OR remainder > 0.
      result = remainder.
      IF index > 0.
        result = result + it_digits[ index ].
      ENDIF.
      IF index_to_add > 0.
        result = result + it_digits_to_add[ index_to_add ].
      ENDIF.
      INSERT result+1(1) INTO TABLE lt_result.
      remainder = COND #( WHEN result >= 10 THEN 1 ELSE 0 ).
      SUBTRACT 1 FROM: index, index_to_add.
    ENDWHILE.

    rt_result = mirror_array( lt_result ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->TO_ARRAY
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RT_DIGITS                      TYPE        TT_DIGITS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD to_array.

    rt_digits = mt_digits.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_BIG_INTEGER->TO_STRING
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_NUMBER                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD to_string.

    rv_number = SWITCH #( mv_sign
                          WHEN mc_sign_negative THEN mc_sign_negative && mv_number
                          ELSE mv_number ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_BIG_INTEGER->TRIM_NUMBER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NUMBER                      TYPE        STRING
* | [<-()] RV_NUMBER                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD trim_number.

    rv_number = |{ iv_number ALPHA = OUT }|.
    CONDENSE rv_number.

  ENDMETHOD.
ENDCLASS.
