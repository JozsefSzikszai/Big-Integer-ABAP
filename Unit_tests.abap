CLASS lct_big_integer DEFINITION DEFERRED.
CLASS zcl_big_integer DEFINITION LOCAL FRIENDS lct_big_integer.

CLASS lct_big_integer DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_numbers,
             actual   TYPE string,
             second   TYPE string,
             expected TYPE string,
           END OF ty_numbers.
    TYPES tt_numbers TYPE STANDARD TABLE OF ty_numbers WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_digits,
             actual   TYPE zcl_big_integer=>tt_digits,
             second   TYPE zcl_big_integer=>tt_digits,
             expected TYPE i,
           END OF ty_digits.
    TYPES tt_digits TYPE STANDARD TABLE OF ty_digits WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_negative,
             actual   TYPE string,
             expected TYPE char1,
           END OF ty_negative.
    TYPES tt_negative TYPE STANDARD TABLE OF ty_negative WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_array,
             actual   TYPE string,
             expected TYPE zcl_big_integer=>tt_digits,
           END OF ty_array.
    TYPES tt_arrays TYPE STANDARD TABLE OF ty_array WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_mirror,
             actual   TYPE zcl_big_integer=>tt_digits,
             expected TYPE zcl_big_integer=>tt_digits,
           END OF ty_mirror.
    TYPES tt_mirrors TYPE STANDARD TABLE OF ty_mirror WITH DEFAULT KEY.

    METHODS abs FOR TESTING.
    METHODS compare_numbers FOR TESTING.
    METHODS compare_same_length_numbers FOR TESTING.
    METHODS divide FOR TESTING.
    METHODS equals FOR TESTING.
    METHODS get_sign FOR TESTING.
    METHODS mirror_array FOR TESTING.
    METHODS multiply FOR TESTING.
    METHODS remainder FOR TESTING.
    METHODS subtract FOR TESTING.
    METHODS sum FOR TESTING.
    METHODS to_array FOR TESTING.
    METHODS to_string FOR TESTING.
ENDCLASS.       "cut_Big_Integer
************************************************************************
CLASS lct_big_integer IMPLEMENTATION.
************************************************************************
  METHOD abs.

    DATA(lt_numbers) = VALUE tt_numbers( ( actual = |0|   expected = |0| )
                                         ( actual = |-0|  expected = |0| )
                                         ( actual = |+0|  expected = |0| )
                                         ( actual = |2|   expected = |2| )
                                         ( actual = |+3|  expected = |3| )
                                         ( actual = |18|  expected = |18| )
                                         ( actual = |-6|  expected = |6| )
                                         ( actual = |-74| expected = |74| ) ).

    LOOP AT lt_numbers
         ASSIGNING FIELD-SYMBOL(<ls_number>).

      DATA(cut) = NEW zcl_big_integer( <ls_number>-actual ).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->abs( )->to_string( )
        exp   = <ls_number>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD compare_numbers.

    DATA(lt_digits) = VALUE tt_digits( ( actual   = VALUE #( ( |1| ) )
                                         second   = VALUE #( ( |1| ) ( |2| ) )
                                         expected = 1 )
                                       ( actual   = VALUE #( ( |1| ) ( |2| ) )
                                         second   = VALUE #( ( |2| ) )
                                         expected = -1 ) ).

    DATA(cut) = NEW zcl_big_integer( |0| ).

    LOOP AT lt_digits
         ASSIGNING FIELD-SYMBOL(<ls_digit>).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->compare_numbers( it_digits = <ls_digit>-actual
                                      it_digits_to_compare = <ls_digit>-second )
        exp   = <ls_digit>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD compare_same_length_numbers.

    DATA(lt_digits) = VALUE tt_digits( ( actual   = VALUE #( ( |1| ) )
                                         second   = VALUE #( ( |1| ) )
                                         expected = 0 )
                                       ( actual   = VALUE #( ( |1| ) )
                                         second   = VALUE #( ( |2| ) )
                                         expected = 1 )
                                       ( actual   = VALUE #( ( |2| ) )
                                         second   = VALUE #( ( |1| ) )
                                         expected = -1 )
                                       ( actual   = VALUE #( ( |1| ) ( |3| ) )
                                         second   = VALUE #( ( |1| ) ( |3| ) )
                                         expected = 0 )
                                       ( actual   = VALUE #( ( |1| ) ( |4| ) )
                                         second   = VALUE #( ( |1| ) ( |6| ) )
                                         expected = 1 )
                                       ( actual   = VALUE #( ( |1| ) ( |7| ) )
                                         second   = VALUE #( ( |1| ) ( |1| ) )
                                         expected = -1 )
                                       ( actual   = VALUE #( ( |1| ) ( |4| ) )
                                         second   = VALUE #( ( |2| ) ( |6| ) )
                                         expected = 1 )
                                       ( actual   = VALUE #( ( |2| ) ( |7| ) )
                                         second   = VALUE #( ( |1| ) ( |8| ) )
                                         expected = -1 ) ).

    DATA(cut) = NEW zcl_big_integer( |0| ).

    LOOP AT lt_digits
         ASSIGNING FIELD-SYMBOL(<ls_digit>).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->compare_same_length_numbers( it_digits = <ls_digit>-actual
                                                  it_digits_to_compare = <ls_digit>-second )
        exp   = <ls_digit>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD divide.

    DATA(lt_numbers) = VALUE tt_numbers( ( actual = |0|  second = |0|  expected = |0| )
                                         ( actual = |8|  second = |0|  expected = |0| )
                                         ( actual = |-5| second = |0|  expected = |0| )
                                         ( actual = |0|  second = |2|  expected = |0| )
                                         ( actual = |0|  second = |-7| expected = |0| )

                                         ( actual = |8|  second = |-2|  expected = |-4| )
                                         ( actual = |5|  second = |-3|  expected = |-1| )
                                         ( actual = |16| second = |-7|  expected = |-2| )
                                         ( actual = |71| second = |-10| expected = |-7| )

                                         ( actual = |-9|  second = |5|  expected = |-1| )
                                         ( actual = |-7|  second = |2|  expected = |-3| )
                                         ( actual = |-26| second = |4|  expected = |-6| )
                                         ( actual = |-55| second = |12| expected = |-4| )

                                         ( actual = |-6|   second = |-2|  expected = |3| )
                                         ( actual = |-15|  second = |-4|  expected = |3| )
                                         ( actual = |-27|  second = |-3|  expected = |9| )
                                         ( actual = |-132| second = |-12| expected = |11| ) ).

    LOOP AT lt_numbers
         ASSIGNING FIELD-SYMBOL(<ls_number>).

      DATA(cut) = NEW zcl_big_integer( <ls_number>-actual ).
      TRY.
          DATA(result) = cut->divide( NEW #( <ls_number>-second ) ).
          cl_abap_unit_assert=>assert_equals(
            act   = result->to_string( )
            exp   = <ls_number>-expected
          " msg   = 'Testing value rv_Number'
*     level =
          ).
        CATCH cx_sy_zerodivide.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD equals.

    DATA(lt_numbers) = VALUE tt_numbers( ( actual = |0|   second = |0|   expected = |0| )
                                         ( actual = |8|   second = |8|   expected = |0| )
                                         ( actual = |35|  second = |35|  expected = |0| )
                                         ( actual = |-5|  second = |-5|  expected = |0| )
                                         ( actual = |-74| second = |-74| expected = |0| )

                                         ( actual = |0|   second = |4|    expected = |1| )
                                         ( actual = |0|   second = |26|   expected = |1| )
                                         ( actual = |3|   second = |6|    expected = |1| )
                                         ( actual = |3|   second = |72|   expected = |1| )
                                         ( actual = |-2|  second = |-1|   expected = |1| )
                                         ( actual = |-16| second = |-13|  expected = |1| )
                                         ( actual = |-7|  second = |5|    expected = |1| )
                                         ( actual = |-54| second = |41|   expected = |1| )

                                         ( actual = |6|  second = |0|   expected = |-1| )
                                         ( actual = |7|  second = |2|   expected = |-1| )
                                         ( actual = |17| second = |8|   expected = |-1| )
                                         ( actual = |39| second = |11|  expected = |-1| )
                                         ( actual = |-5| second = |-9|  expected = |-1| )
                                         ( actual = |-8| second = |-46| expected = |-1| )
                                         ( actual = |5|  second = |-3|  expected = |-1| )
                                         ( actual = |15| second = |-21| expected = |-1| ) ).

    LOOP AT lt_numbers
         ASSIGNING FIELD-SYMBOL(<ls_number>).

      DATA(cut) = NEW zcl_big_integer( <ls_number>-actual ).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->equals( NEW #( <ls_number>-second ) )
        exp   = <ls_number>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD get_sign.

    DATA(lt_negative) = VALUE tt_negative( ( actual = |0|    expected = ' ' )
                                           ( actual = |+0|   expected = ' ' )
                                           ( actual = |-0|   expected = ' ' )
                                           ( actual = |8|    expected = zcl_big_integer=>mc_sign_positive )
                                           ( actual = |38|   expected = zcl_big_integer=>mc_sign_positive )
                                           ( actual = |-5|   expected = zcl_big_integer=>mc_sign_negative )
                                           ( actual = |-427| expected = zcl_big_integer=>mc_sign_negative ) ).

    LOOP AT lt_negative
         ASSIGNING FIELD-SYMBOL(<ls_negative>).

      DATA(cut) = NEW zcl_big_integer( <ls_negative>-actual ).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->get_sign( )
        exp   = <ls_negative>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD mirror_array.

    DATA(lt_mirrors) = VALUE tt_mirrors( ( actual = VALUE #( ( |0| ) ) expected = VALUE #( ( |0| ) ) )
                                         ( actual = VALUE #( ( |5| ) ) expected = VALUE #( ( |5| ) ) )
                                         ( actual = VALUE #( ( |1| ) ( |3| ) ) expected = VALUE #( ( |3| ) ( |1| ) ) )
                                         ( actual = VALUE #( ( |2| ) ( |0| ) ) expected = VALUE #( ( |2| ) ) ) ).

    DATA(cut) = NEW zcl_big_integer( |0| ).

    LOOP AT lt_mirrors
         ASSIGNING FIELD-SYMBOL(<ls_mirror>).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->mirror_array( <ls_mirror>-actual )
        exp   = <ls_mirror>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD multiply.

    DATA(lt_numbers) = VALUE tt_numbers( ( actual = |0|   second = |0|   expected = |0| )
                                         ( actual = |0|   second = |5|   expected = |0| )
                                         ( actual = |0|   second = |32|  expected = |0| )
                                         ( actual = |0|   second = |-3|  expected = |0| )
                                         ( actual = |0|   second = |-15| expected = |0| )
                                         ( actual = |4|   second = |0|   expected = |0| )
                                         ( actual = |56|  second = |0|   expected = |0| )
                                         ( actual = |-7|  second = |0|   expected = |0| )
                                         ( actual = |-24| second = |0|   expected = |0| )

                                         ( actual = |1|  second = |4|   expected = |4| )
                                         ( actual = |1|  second = |34|  expected = |34| )
                                         ( actual = |5|  second = |1|   expected = |5| )
                                         ( actual = |36| second = |1|   expected = |36| )
                                         ( actual = |-1|  second = |8|  expected = |-8| )
                                         ( actual = |-1|  second = |49| expected = |-49| )
                                         ( actual = |-7|  second = |1|  expected = |-7| )
                                         ( actual = |-74| second = |1|  expected = |-74| )

                                         ( actual = |3|   second = |7|   expected = |21| )
                                         ( actual = |15|  second = |17|  expected = |255| )
                                         ( actual = |-4|  second = |-8|  expected = |32| )
                                         ( actual = |-21| second = |-17| expected = |357| )

                                         ( actual = |7|   second = |-85| expected = |-595| )
                                         ( actual = |26|  second = |-75| expected = |-1950| )
                                         ( actual = |-6|  second = |52|  expected = |-312| )
                                         ( actual = |-74| second = |49|  expected = |-3626| ) ).

    LOOP AT lt_numbers
         ASSIGNING FIELD-SYMBOL(<ls_number>).

      DATA(cut) = NEW zcl_big_integer( <ls_number>-actual ).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->multiply( NEW #( <ls_number>-second ) )->to_string( )
        exp   = <ls_number>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD remainder.

    DATA(lt_numbers) = VALUE tt_numbers( ( actual = |0|  second = |0|  expected = |0| )
                                         ( actual = |8|  second = |0|  expected = |0| )
                                         ( actual = |-5| second = |0|  expected = |0| )
                                         ( actual = |0|  second = |2|  expected = |0| )
                                         ( actual = |0|  second = |-7| expected = |0| )

                                         " positive positive
                                         ( actual = |5|  second = |2|  expected = |1| )
                                         ( actual = |9|  second = |3|  expected = |0| )
                                         ( actual = |19| second = |4|  expected = |3| )
                                         ( actual = |37| second = |12| expected = |1| )
                                         ( actual = |45| second = |57| expected = |45| )

                                         " positive negative
                                         ( actual = |8|  second = |-2|  expected = |0| )
                                         ( actual = |5|  second = |-3|  expected = |2| )
                                         ( actual = |16| second = |-7|  expected = |2| )
                                         ( actual = |71| second = |-10| expected = |1| )
                                         ( actual = |63| second = |-88| expected = |63| )

                                         " negative positive
                                         ( actual = |-9|  second = |5|  expected = |1| )
                                         ( actual = |-7|  second = |2|  expected = |1| )
                                         ( actual = |-26| second = |6|  expected = |4| )
                                         ( actual = |-55| second = |12| expected = |5| )
                                         ( actual = |-39| second = |68| expected = |29| )

                                         " negative negative
"                                         ( actual = |-6|   second = |-2|  expected = |0| )
                                         ( actual = |-15|  second = |-4|  expected = |1| )
                                         ( actual = |-27|  second = |-6|  expected = |3| )
"                                         ( actual = |-132| second = |-12| expected = |0| )
                                         ( actual = |-75|  second = |-87| expected = |12| ) ).

    LOOP AT lt_numbers
         ASSIGNING FIELD-SYMBOL(<ls_number>).

      DATA(cut) = NEW zcl_big_integer( <ls_number>-actual ).
      TRY.
          DATA(result) = cut->remainder( NEW #( <ls_number>-second ) ).
          cl_abap_unit_assert=>assert_equals(
            act   = result->to_string( )
            exp   = <ls_number>-expected
          " msg   = 'Testing value rv_Number'
*     level =
          ).
        CATCH cx_sy_zerodivide.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD subtract.

    DATA(lt_numbers) = VALUE tt_numbers( ( actual = |0|  second = |0|  expected = |0| )
                                         ( actual = |0|  second = |8|  expected = |-8| )
                                         ( actual = |0|  second = |37| expected = |-37| )
                                         ( actual = |5|  second = |0|  expected = |5| )
                                         ( actual = |16| second = |0|  expected = |16| )

                                         " positive minus positive
                                         ( actual = |7|  second = |2|  expected = |5| )
                                         ( actual = |24| second = |7|  expected = |17| )
                                         ( actual = |35| second = |17| expected = |18| )
                                         ( actual = |5|  second = |9|  expected = |-4| )
                                         ( actual = |6|  second = |17| expected = |-11| )
                                         ( actual = |41| second = |63| expected = |-22| )

                                         " positive minus negative
                                         ( actual = |3|  second = |-2|  expected = |5| )
                                         ( actual = |23| second = |-7|  expected = |30| )
                                         ( actual = |41| second = |-22| expected = |63| )

                                         " negative minus positive
                                         ( actual = |-6|  second = |4|  expected = |-10| )
                                         ( actual = |-4|  second = |13| expected = |-17| )
                                         ( actual = |-24| second = |15| expected = |-39| )

                                         " negative minus negative
                                         ( actual = |-8|  second = |-3|  expected = |-5| )
                                         ( actual = |-3|  second = |-5|  expected = |2| )
                                         ( actual = |-7|  second = |-15| expected = |8| )
                                         ( actual = |-17| second = |-6|  expected = |-11| )
                                         ( actual = |-23| second = |-36| expected = |13| ) ).

    LOOP AT lt_numbers
         ASSIGNING FIELD-SYMBOL(<ls_number>).

      DATA(cut) = NEW zcl_big_integer( <ls_number>-actual ).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->subtract( NEW #( <ls_number>-second ) )->to_string( )
        exp   = <ls_number>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD sum.

    DATA(lt_numbers) = VALUE tt_numbers( ( actual = |0| second = |0|    expected = |0| )
                                         ( actual = |0| second = |8|    expected = |8| )
                                         ( actual = |0| second = |426|  expected = |426| )
                                         ( actual = |0| second = |-5|   expected = |-5| )
                                         ( actual = |0| second = |-117|  expected = |-117| )

                                         ( actual = |3|    second = |0| expected = |3| )
                                         ( actual = |276|  second = |0| expected = |276| )
                                         ( actual = |-6|   second = |0| expected = |-6| )
                                         ( actual = |-523| second = |0| expected = |-523| )

                                         ( actual = |3|  second = |4|  expected = |7| )
                                         ( actual = |6|  second = |8|  expected = |14| )
                                         ( actual = |15| second = |27| expected = |42| )

                                         ( actual = |-4|  second = |-2|  expected = |-6| )
                                         ( actual = |-7|  second = |-5|  expected = |-12| )
                                         ( actual = |-23| second = |-47| expected = |-70| )

                                         ( actual = |8|  second = |-6|  expected = |2| )
                                         ( actual = |45| second = |-7|  expected = |38| )
                                         ( actual = |54| second = |-21| expected = |33| )
                                         ( actual = |5|  second = |-8|  expected = |-3| )
                                         ( actual = |16| second = |-29| expected = |-13| )

                                         ( actual = |-9|  second = |6|  expected = |-3| )
                                         ( actual = |-37| second = |8|  expected = |-29| )
                                         ( actual = |-71| second = |37| expected = |-34| )
                                         ( actual = |-4|  second = |8|  expected = |4| )
                                         ( actual = |-54| second = |87| expected = |33| ) ).


    LOOP AT lt_numbers
         ASSIGNING FIELD-SYMBOL(<ls_number>).

      DATA(cut) = NEW zcl_big_integer( <ls_number>-actual ).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->sum( NEW #( <ls_number>-second ) )->to_string( )
        exp   = <ls_number>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD to_array.

    DATA(lt_arrays) = VALUE tt_arrays( ( actual = |0|    expected = VALUE #( ( |0| ) ) )
                                       ( actual = |3|    expected = VALUE #( ( |3| ) ) )
                                       ( actual = |-5|   expected = VALUE #( ( |5| ) ) )
                                       ( actual = |17|   expected = VALUE #( ( |1| ) ( |7| ) ) )
                                       ( actual = |-85|  expected = VALUE #( ( |8| ) ( |5| ) ) )
                                       ( actual = |471|  expected = VALUE #( ( |4| ) ( |7| ) ( |1| ) ) )
                                       ( actual = |-633| expected = VALUE #( ( |6| ) ( |3| ) ( |3| ) ) ) ).

    LOOP AT lt_arrays
         ASSIGNING FIELD-SYMBOL(<ls_array>).

      DATA(cut) = NEW zcl_big_integer( <ls_array>-actual ).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->to_array( )
        exp   = <ls_array>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
  METHOD to_string.

    DATA(lt_numbers) = VALUE tt_numbers( ( actual = ||     expected = |0| )
                                         ( actual = |0|    expected = |0| )
                                         ( actual = |00|   expected = |0| )
                                         ( actual = |0000| expected = |0| )

                                         ( actual = |1|    expected = |1| )
                                         ( actual = |01|   expected = |1| )
                                         ( actual = |0001| expected = |1| )

                                         ( actual = |c|    expected = |0| )
                                         ( actual = |abc|  expected = |0| )
                                         ( actual = |a0c|  expected = |0| )
                                         ( actual = |1a2|  expected = |12| )
                                         ( actual = |b7d7| expected = |77| )
                                         ( actual = |8ab3| expected = |83| )
                                         ( actual = |56ab| expected = |56| )
                                         ( actual = |-7|   expected = |-7| ) ).

    LOOP AT lt_numbers
         ASSIGNING FIELD-SYMBOL(<ls_number>).

      DATA(cut) = NEW zcl_big_integer( <ls_number>-actual ).

      cl_abap_unit_assert=>assert_equals(
        act   = cut->to_string( )
        exp   = <ls_number>-expected
      " msg   = 'Testing value rv_Number'
*     level =
      ).

    ENDLOOP.

  ENDMETHOD.
************************************************************************
ENDCLASS.
