# -------------------------------------------------------------
# A Fortran compiler is needed if:
# (a) FCMIX is enabled
# (b) LAPACK is enabled (for the name-mangling scheme)
# -------------------------------------------------------------

IF(FCMIX_ENABLE OR LAPACK_ENABLE)
  INCLUDE(SundialsFortran)
  IF(NOT F77_FOUND AND FCMIX_ENABLE)
    PRINT_WARNING("Fortran compiler not functional"
      "FCMIX support will not be provided")
  ENDIF()
ENDIF()

# -------------------------------------------------------------
# Check if we need an alternate way of specifying the Fortran
# name-mangling scheme if we were unable to infer it using a
# compiler. 
# Ask the user to specify the case and number of appended underscores
# corresponding to the Fortran name-mangling scheme of symbol names 
# that do not themselves contain underscores (recall that this is all
# we really need for the interfaces to LAPACK).
# Note: the default scheme is lower case - one underscore
# -------------------------------------------------------------

IF(LAPACK_ENABLE AND NOT F77SCHEME_FOUND)
  # Specify the case for the Fortran name-mangling scheme
  SHOW_VARIABLE(SUNDIALS_F77_FUNC_CASE STRING
    "case of Fortran function names (lower/upper)"
    "lower")
  # Specify the number of appended underscores for the Fortran name-mangling scheme
  SHOW_VARIABLE(SUNDIALS_F77_FUNC_UNDERSCORES STRING 
    "number of underscores appended to Fortran function names"
    "one")  
  # Based on the given case and number of underscores,
  # set the C preprocessor macro definition
  IF(${SUNDIALS_F77_FUNC_CASE} MATCHES "lower")
    IF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "none")
      SET(CMAKE_Fortran_SCHEME_NO_UNDERSCORES "mysub")
    ENDIF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "none")
    IF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "one")
      SET(CMAKE_Fortran_SCHEME_NO_UNDERSCORES "mysub_")
    ENDIF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "one")
    IF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "two")
      SET(CMAKE_Fortran_SCHEME_NO_UNDERSCORES "mysub__")
    ENDIF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "two")
  ELSE(${SUNDIALS_F77_FUNC_CASE} MATCHES "lower")
    IF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "none")
      SET(CMAKE_Fortran_SCHEME_NO_UNDERSCORES "MYSUB")
    ENDIF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "none")
    IF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "one")
      SET(CMAKE_Fortran_SCHEME_NO_UNDERSCORES "MYSUB_")
    ENDIF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "one")
    IF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "two")
      SET(CMAKE_Fortran_SCHEME_NO_UNDERSCORES "MYSUB__")
    ENDIF(${SUNDIALS_F77_FUNC_UNDERSCORES} MATCHES "two")
  ENDIF(${SUNDIALS_F77_FUNC_CASE} MATCHES "lower")
  # Since the SUNDIALS codes never use symbol names containing
  # underscores, set a default scheme (probably wrong) for symbols
  # with underscores.
  SET(CMAKE_Fortran_SCHEME_WITH_UNDERSCORES "my_sub_")
  # We now "have" a scheme.
  SET(F77SCHEME_FOUND TRUE)
ENDIF()

# -------------------------------------------------------------
# If we have a name-mangling scheme (either automatically
# inferred or provided by the user), set the SUNDIALS 
# compiler preprocessor macro definitions.
# -------------------------------------------------------------

SET(F77_MANGLE_MACRO1 "")
SET(F77_MANGLE_MACRO2 "")

IF(F77SCHEME_FOUND)
  # Symbols WITHOUT underscores
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "mysub")
    SET(F77_MANGLE_MACRO1 "#define SUNDIALS_F77_FUNC(name,NAME) name")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "mysub")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "mysub_")
    SET(F77_MANGLE_MACRO1 "#define SUNDIALS_F77_FUNC(name,NAME) name ## _")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "mysub_")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "mysub__")
    SET(F77_MANGLE_MACRO1 "#define SUNDIALS_F77_FUNC(name,NAME) name ## __")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "mysub__")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MYSUB")
    SET(F77_MANGLE_MACRO1 "#define SUNDIALS_F77_FUNC(name,NAME) NAME")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MYSUB")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MYSUB_")
    SET(F77_MANGLE_MACRO1 "#define SUNDIALS_F77_FUNC(name,NAME) NAME ## _")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MYSUB_")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MYSUB__")
    SET(F77_MANGLE_MACRO1 "#define SUNDIALS_F77_FUNC(name,NAME) NAME ## __")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MYSUB__")
  # Symbols with underscores 
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "my_sub")
    SET(F77_MANGLE_MACRO2 "#define SUNDIALS_F77_FUNC_(name,NAME) name")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "my_sub")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "my_sub_")
    SET(F77_MANGLE_MACRO2 "#define SUNDIALS_F77_FUNC_(name,NAME) name ## _")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "my_sub_")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "my_sub__")
    SET(F77_MANGLE_MACRO2 "#define SUNDIALS_F77_FUNC_(name,NAME) name ## __")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "my_sub__")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MY_SUB")
    SET(F77_MANGLE_MACRO2 "#define SUNDIALS_F77_FUNC_(name,NAME) NAME")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MY_SUB")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MY_SUB_")
    SET(F77_MANGLE_MACRO2 "#define SUNDIALS_F77_FUNC_(name,NAME) NAME ## _")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MY_SUB_")
  IF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MY_SUB__")
    SET(F77_MANGLE_MACRO2 "#define SUNDIALS_F77_FUNC_(name,NAME) NAME ## __")
  ENDIF(${CMAKE_Fortran_SCHEME_NO_UNDERSCORES} MATCHES "MY_SUB__")
ENDIF(F77SCHEME_FOUND)