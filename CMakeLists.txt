# ---------------------------------------------------------------
# $Revision: 2.0 $
# $Date: 2014/10/29 $
# ---------------------------------------------------------------
# Original Programmer:  Radu Serban @ LLNL
# Embedding into OpenCMISS framework: Daniel Wirtz @ ABI, Univ. Auckland
# ---------------------------------------------------------------
# Copyright (c) 2007, The Regents of the University of California.
# Produced at the Lawrence Livermore National Laboratory.
# All rights reserved.
# For details, see the LICENSE file.
# ---------------------------------------------------------------
# Top level CMakeLists.txt for SUNDIALS (for cmake build system)

CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(sundials VERSION 2.5 LANGUAGES C)

if (OPENCMISS_DEPENDENCIES_LIBRARIES)
    SET(CMAKE_PREFIX_PATH ${OPENCMISS_DEPENDENCIES_CONFIGS_DIR} ${CMAKE_PREFIX_PATH})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${OPENCMISS_DEPENDENCIES_LIBRARIES})
else()
    SET(CMAKE_PREFIX_PATH ../cmake/release ../cmake/debug ${CMAKE_PREFIX_PATH})
    SET(OPENCMISS_DEPENDENCIES_CONFIGS_DIR ${CMAKE_CURRENT_BINARY_DIR})
    SET(BUILD_TESTING ON)
endif()

FIND_PACKAGE(BLAS CONFIG REQUIRED)
FIND_PACKAGE(LAPACK CONFIG REQUIRED)
FIND_PACKAGE(MPI REQUIRED)

MARK_AS_ADVANCED(EXECUTABLE_OUTPUT_PATH LIBRARY_OUTPUT_PATH)
MARK_AS_ADVANCED(CLEAR
  CMAKE_C_COMPILER
  CMAKE_C_FLAGS
  CMAKE_C_FLAGS_DEBUG
  CMAKE_C_FLAGS_MINSIZEREL
  CMAKE_C_FLAGS_RELEASE
  CMAKE_C_FLAGS_RELWITHDEB)

# Specify the VERSION and SOVERSION for shared libraries

SET(cvodelib_VERSION "1.0.0")
SET(cvodelib_SOVERSION "1")

SET(cvodeslib_VERSION "2.0.0")
SET(cvodeslib_SOVERSION "2")

SET(idalib_VERSION "2.0.0")
SET(idalib_SOVERSION "2")

SET(idaslib_VERSION "0.0.0")
SET(idaslib_SOVERSION "0")

SET(kinsollib_VERSION "1.0.0")
SET(kinsollib_SOVERSION "1")

SET(cpodeslib_VERSION "0.0.0")
SET(cpodeslib_SOVERSION "0")

SET(nveclib_VERSION "0.0.2")
SET(nveclib_SOVERSION "0")

# Specify the location of additional CMAKE modules

SET(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/config)

# -------------------------------------------------------------
# MACRO definitions
# -------------------------------------------------------------

# Macros to hide/show cached variables.
# These two macros can be used to "hide" or "show" in the
# list of cached variables various variables and/or options 
# that depend on other options.
# Note that once a variable is modified, it will preserve its
# value (hidding it merely makes it internal)

MACRO(HIDE_VARIABLE var)
  IF(DEFINED ${var})
    SET(${var} "${${var}}" CACHE INTERNAL "")
  ENDIF(DEFINED ${var})
ENDMACRO(HIDE_VARIABLE)

MACRO(SHOW_VARIABLE var type doc default)
  IF(DEFINED ${var})
    SET(${var} "${${var}}" CACHE "${type}" "${doc}" FORCE)
  ELSE(DEFINED ${var})
    SET(${var} "${default}" CACHE "${type}" "${doc}")
  ENDIF(DEFINED ${var})
ENDMACRO(SHOW_VARIABLE)

# Macros to append a common suffix or prefix to the elements of a list

MACRO(ADD_SUFFIX rootlist suffix)
  SET(outlist )
  FOREACH(root ${${rootlist}})
    LIST(APPEND outlist ${root}${suffix})
  ENDFOREACH(root)
  SET(${rootlist} ${outlist})
ENDMACRO(ADD_SUFFIX)

MACRO(ADD_PREFIX prefix rootlist)
  SET(outlist )
  FOREACH(root ${${rootlist}})
    LIST(APPEND outlist ${prefix}${root})
  ENDFOREACH(root)
  SET(${rootlist} ${outlist})
ENDMACRO(ADD_PREFIX)

# Macro to print warning that some features will be disabled
# due to some failure.

MACRO(PRINT_WARNING message action)
  MESSAGE("WARNING: ${message}.\n   ${action}.")
ENDMACRO(PRINT_WARNING)

# Returns an unquoted string.  Note that CMake will readily turn such
# strings back into lists, due to the duality of lists and
# semicolon-separated strings.  So be careful how you use it.

MACRO(LIST2STRING alist astring)
  FOREACH(elem ${${alist}})
   SET(${astring} "${${astring}} ${elem}")
  ENDFOREACH(elem)
ENDMACRO(LIST2STRING)

# -------------------------------------------------------------
# Which modules to build?
# -------------------------------------------------------------

# For each SUNDIALS solver available (i.e. for which we have the
# sources), give the user the option of enabling/disabling it.
SET(BUILD_CVODE ON)
SET(BUILD_CVODES ON)
SET(BUILD_IDA ON)
SET(BUILD_IDAS ON)
SET(BUILD_KINSOL ON)
# Not included in source
SET(BUILD_CPODES OFF)
# -------------------------------------------------------------
# Other configuration options
# -------------------------------------------------------------
SET(BUILD_STATIC_LIBS ON)
SET(BUILD_SHARED_LIBS OFF)

# Prepare substitution variable SUNDIALS_EXPORT for sundials_config.h
# When building shared SUNDIALS libraries under Windows, use
#      #define SUNDIALS_EXPORT __declspec(dllexport)
# When linking to shared SUNDIALS libraries under Windows, use
#      #define SUNDIALS_EXPORT __declspec(dllimport)
# In all other cases (other platforms or static libraries
# under Windows), the SUNDIALS_EXPORT macro is empty
SET(SUNDIALS_EXPORT "#define SUNDIALS_EXPORT")

#IF(BUILD_SHARED_LIBS AND WIN32)
#  SET(SUNDIALS_EXPORT
#    "#ifdef BUILD_SUNDIALS_LIBRARY
#define SUNDIALS_EXPORT __declspec(dllexport)
#else
#define SUNDIALS_EXPORT __declspec(dllimport)
#endif")
#ELSE()
#  
#ENDIF()

# Option to specify precision
# ---------------------------
SET(SUNDIALS_PRECISION "double" CACHE STRING "double, single or extended")

# prepare substitution variable PRECISION_LEVEL for sundials_config.h
STRING(TOUPPER ${SUNDIALS_PRECISION} SUNDIALS_PRECISION)
SET(PRECISION_LEVEL "#define SUNDIALS_${SUNDIALS_PRECISION}_PRECISION 1")

# Option to use the generic math libraries (UNIX only)
# ----------------------------------------------------
IF(UNIX)
    # executables will be linked against -lm 
    SET(EXTRA_LINK_LIBS m)
    # prepare substitution variable GENERIC_MATH_LIB for sundials_config.h
    SET(GENERIC_MATH_LIB "#define SUNDIALS_USE_GENERIC_MATH")
ENDIF(UNIX)

# -------------------------------------------------------------
# Enable Fortran support?
# -------------------------------------------------------------
# FCMIX support is an option only if at least one solver that 
# provides such an interface is built.

IF(BUILD_CVODE OR BUILD_IDA OR BUILD_KINSOL)
  SET(FCMIX_ENABLE ON)  
  #SHOW_VARIABLE(FCMIX_ENABLE BOOL "Enable Fortran-C support" OFF)
#ELSE()
#  HIDE_VARIABLE(FCMIX_ENABLE)
ENDIF()

# -------------------------------------------------------------
# Enable BLAS/LAPACK support?
# -------------------------------------------------------------
#OPTION(LAPACK_ENABLE "Enable Lapack support" OFF)
SET(LAPACK_ENABLE ON)
#IF(NOT LAPACK_ENABLE)
#  HIDE_VARIABLE(SUNDIALS_F77_FUNC_CASE)
#  HIDE_VARIABLE(SUNDIALS_F77_FUNC_UNDERSCORES)
#  HIDE_VARIABLE(LAPACK_LIBRARIES)
#ENDIF(NOT LAPACK_ENABLE)

# -------------------------------------------------------------
# Enable MPI support?
# -------------------------------------------------------------
SET(MPI_ENABLE ON)
#OPTION(MPI_ENABLE "Enable MPI support" OFF)
#IF(NOT MPI_ENABLE)
#  HIDE_VARIABLE(MPI_INCLUDE_PATH)
#  HIDE_VARIABLE(MPI_LIBRARIES)
#  HIDE_VARIABLE(MPI_EXTRA_LIBRARIES)
#  HIDE_VARIABLE(MPI_MPICC)
#  HIDE_VARIABLE(MPI_MPIF77)
#ENDIF(NOT MPI_ENABLE)

# -------------------------------------------------------------
# Enable examples?
# -------------------------------------------------------------
IF (BUILD_TESTING)

  # If examples are enabled, set different options

  # The examples will be linked with the library corresponding to the build type.
  # Whenever building shared libraries, use them to link the examples.
  #IF(BUILD_SHARED_LIBS)
  #  SET(LINK_LIBRARY_TYPE "shared")
  #ELSE()
    SET(LINK_LIBRARY_TYPE "static")
  #ENDIF()

  # Check if example files are to be exported
  #SHOW_VARIABLE(EXAMPLES_INSTALL BOOL "Install example files" ON)

  # If examples are to be exported, check where we should install them.
  #IF(EXAMPLES_INSTALL)

  #  SHOW_VARIABLE(EXAMPLES_INSTALL_PATH STRING
  #    "Output directory for installing example files" "${CMAKE_INSTALL_PREFIX}/examples")
    
  #  IF(NOT EXAMPLES_INSTALL_PATH)
  #    PRINT_WARNING("The example installation path is empty"
  #      "Example installation path was reset to its default value")
  #    SET(EXAMPLES_INSTALL_PATH "${CMAKE_INSTALL_PREFIX}/examples" CACHE STRING
  #      "Output directory for installing example files" FORCE)
  #  ENDIF(NOT EXAMPLES_INSTALL_PATH)

  #ELSE(EXAMPLES_INSTALL)

  #  HIDE_VARIABLE(EXAMPLES_INSTALL_PATH)

  #ENDIF(EXAMPLES_INSTALL)

ELSE()

  # If examples are disabled, hide all options related to
  # building and installing the SUNDIALS examples

  HIDE_VARIABLE(EXAMPLES_INSTALL)
  HIDE_VARIABLE(EXAMPLES_INSTALL_PATH)
  
ENDIF()

# -------------------------------------------------------------
# Add any other necessary compiler flags & definitions
# -------------------------------------------------------------

# Under Windows, add compiler directive to inhibit warnings
# about use of unsecure functions

IF(WIN32)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
ENDIF(WIN32)

# Fortran linking stuff
include(FortranMangling)

# -------------------------------------------------------------
# Find (and test) the Lapack libraries
# -------------------------------------------------------------

# If LAPACK is needed, first try to find the appropriate
# libraries and linker flags needed to link against them.

# Macro to be inserted in sundials_config.h
SET(BLAS_LAPACK_MACRO "#define SUNDIALS_BLAS_LAPACK 1")
#SET(BLAS_LAPACK_MACRO "#define SUNDIALS_BLAS_LAPACK 0")

#IF(LAPACK_ENABLE)

  #INCLUDE(SundialsLapack)

  #IF(LAPACK_FOUND)
  #  SET(BLAS_LAPACK_MACRO "#define SUNDIALS_BLAS_LAPACK 1")
  #ELSE(LAPACK_FOUND)
  #  SHOW_VARIABLE(LAPACK_LIBRARIES STRING "Lapack libraries" "${LAPACK_LIBRARIES}")
  #  SHOW_VARIABLE(LAPACK_LINKER_FLAGS STRING "Lapack required linker flags" "${LAPACK_LINKER_FLAGS}")
  #ENDIF(LAPACK_FOUND)
  #
  #IF(LAPACK_LIBRARIES AND NOT LAPACK_FOUND)
  #  PRINT_WARNING("LAPACK not functional"
  #    "Blas/Lapack support will not be provided")
  #ENDIF(LAPACK_LIBRARIES AND NOT LAPACK_FOUND)

#ELSE(LAPACK_ENABLE)

  #HIDE_VARIABLE(LAPACK_LIBRARIES)
  #HIDE_VARIABLE(LAPACK_LINKER_FLAGS)

#ENDIF(LAPACK_ENABLE)

# -------------------------------------------------------------
# Decide how to compile MPI codes.
# -------------------------------------------------------------
IF(MPI_ENABLE)
  INCLUDE(SundialsMPIC)
  IF(NOT MPIC_FOUND)
    PRINT_WARNING("MPI not functional"
      "Parallel support will not be provided")
  ENDIF()
  IF(MPIC_MPI2)
    SET(F77_MPI_COMM_F2C "#define SUNDIALS_MPI_COMM_F2C 1")
  ELSE()
    SET(F77_MPI_COMM_F2C "#define SUNDIALS_MPI_COMM_F2C 0")
  ENDIF()
  IF(MPIC_FOUND AND FCMIX_ENABLE)
    INCLUDE(SundialsMPIF)
  ENDIF()
ENDIF()

# -------------------------------------------------------------
# Configure the header file sundials_config.h
# -------------------------------------------------------------

# All required substitution variables should be available at this point.
# Generate the header file and place it in the binary dir.
CONFIGURE_FILE(
  ${PROJECT_SOURCE_DIR}/include/sundials/sundials_config.in
  ${PROJECT_BINARY_DIR}/include/sundials/sundials_config.h
  )

# Add the include directory in the source tree and the one in
# the binary tree (for the header file sundials_config.h)
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/include ${PROJECT_BINARY_DIR}/include)

# -------------------------------------------------------------
# Add selected modules to the build system
# -------------------------------------------------------------

# Shared components

ADD_SUBDIRECTORY(src/sundials)
ADD_SUBDIRECTORY(src/nvec_ser)
IF(MPIC_FOUND)
  ADD_SUBDIRECTORY(src/nvec_par)
ENDIF(MPIC_FOUND)

# CVODE library

IF(BUILD_CVODE)	
  ADD_SUBDIRECTORY(src/cvode)
  IF(FCMIX_ENABLE AND F77_FOUND)
    ADD_SUBDIRECTORY(src/cvode/fcmix)
  ENDIF(FCMIX_ENABLE AND F77_FOUND)
ENDIF(BUILD_CVODE)

# CVODES library

IF(BUILD_CVODES)	
  ADD_SUBDIRECTORY(src/cvodes)
ENDIF(BUILD_CVODES)

# IDA library

IF(BUILD_IDA)	
  ADD_SUBDIRECTORY(src/ida)
  IF(FCMIX_ENABLE AND F77_FOUND)
    ADD_SUBDIRECTORY(src/ida/fcmix)
  ENDIF(FCMIX_ENABLE AND F77_FOUND)
ENDIF(BUILD_IDA)

# IDAS library

IF(BUILD_IDAS)	
  ADD_SUBDIRECTORY(src/idas)
ENDIF(BUILD_IDAS)

# KINSOL library

IF(BUILD_KINSOL)	
  ADD_SUBDIRECTORY(src/kinsol)
  IF(FCMIX_ENABLE AND F77_FOUND)
    ADD_SUBDIRECTORY(src/kinsol/fcmix)
  ENDIF(FCMIX_ENABLE AND F77_FOUND)
ENDIF(BUILD_KINSOL)

# CPODES library

IF(BUILD_CPODES)	
  ADD_SUBDIRECTORY(src/cpodes)
ENDIF(BUILD_CPODES)

# -------------------------------------------------------------
# Include the subdirectories corresponding to various examples
# -------------------------------------------------------------

# If building and installing the examples is enabled, include
# the subdirectories for those examples that will be built.
# Also, if we will generate exported example Makefiles, set 
# variables needed in generating them from templates.

IF(BUILD_TESTING)

  IF(BUILD_CVODE)
    ADD_SUBDIRECTORY(examples/cvode/serial)
    IF(FCMIX_ENABLE AND F77_FOUND)
      ADD_SUBDIRECTORY(examples/cvode/fcmix_serial)
    ENDIF(FCMIX_ENABLE AND F77_FOUND)
    IF(MPIC_FOUND)
      ADD_SUBDIRECTORY(examples/cvode/parallel)
    ENDIF(MPIC_FOUND)
    IF(MPIF_FOUND)
      ADD_SUBDIRECTORY(examples/cvode/fcmix_parallel)
    ENDIF(MPIF_FOUND)
  ENDIF(BUILD_CVODE)
  
  IF(BUILD_CVODES)	
    ADD_SUBDIRECTORY(examples/cvodes/serial)
    IF(MPIC_FOUND)
      ADD_SUBDIRECTORY(examples/cvodes/parallel)
    ENDIF(MPIC_FOUND)
  ENDIF(BUILD_CVODES)
  
  IF(BUILD_IDA)
    ADD_SUBDIRECTORY(examples/ida/serial)
    IF(FCMIX_ENABLE AND F77_FOUND)
      ADD_SUBDIRECTORY(examples/ida/fcmix_serial)
    ENDIF(FCMIX_ENABLE AND F77_FOUND)
    IF(MPIC_FOUND)
      ADD_SUBDIRECTORY(examples/ida/parallel)
    ENDIF(MPIC_FOUND)
    IF(MPIF_FOUND)
      ADD_SUBDIRECTORY(examples/ida/fcmix_parallel)
    ENDIF(MPIF_FOUND)
  ENDIF(BUILD_IDA)
  
  IF(BUILD_IDAS)	
    ADD_SUBDIRECTORY(examples/idas/serial)
    IF(MPIC_FOUND)
      ADD_SUBDIRECTORY(examples/idas/parallel)
    ENDIF(MPIC_FOUND)
  ENDIF(BUILD_IDAS)

  IF(BUILD_KINSOL)	
    ADD_SUBDIRECTORY(examples/kinsol/serial)
    IF(FCMIX_ENABLE AND F77_FOUND)
      ADD_SUBDIRECTORY(examples/kinsol/fcmix_serial)
    ENDIF(FCMIX_ENABLE AND F77_FOUND)
    IF(MPIC_FOUND)
      ADD_SUBDIRECTORY(examples/kinsol/parallel)
    ENDIF(MPIC_FOUND)
    IF(MPIF_FOUND)
      ADD_SUBDIRECTORY(examples/kinsol/fcmix_parallel)
    ENDIF(MPIF_FOUND)
  ENDIF(BUILD_KINSOL)

  IF(BUILD_CPODES)	
    ADD_SUBDIRECTORY(examples/cpodes/serial)
    IF(MPIC_FOUND)
      ADD_SUBDIRECTORY(examples/cpodes/parallel)
    ENDIF(MPIC_FOUND)
  ENDIF(BUILD_CPODES)
  
ENDIF(BUILD_TESTING)

#----------------------------------
# Install configuration header file
#----------------------------------

# install configured header file
#INSTALL(
#  FILES ${PROJECT_BINARY_DIR}/include/sundials/sundials_config.h
#  DESTINATION include/sundials
#  )