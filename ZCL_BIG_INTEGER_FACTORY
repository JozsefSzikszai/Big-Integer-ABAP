CLASS zcl_big_integer_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        !iv_number            TYPE string
      RETURNING
        VALUE(ro_big_integer) TYPE REF TO zif_big_integer
      RAISING
        zcx_no_valid_number .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BIG_INTEGER_FACTORY IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_BIG_INTEGER_FACTORY=>CREATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NUMBER                      TYPE        STRING
* | [<-()] RO_BIG_INTEGER                 TYPE REF TO ZIF_BIG_INTEGER
* | [!CX!] ZCX_NO_VALID_NUMBER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create.

    TRY.
        ro_big_integer = CAST zif_big_integer( NEW zcl_big_integer( iv_number ) ).
      CATCH zcx_no_valid_number.
        RAISE EXCEPTION TYPE zcx_no_valid_number.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
