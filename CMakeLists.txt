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
PROJECT(SUNDIALS VERSION 2.5 LANGUAGES C)

option(BUILD_TESTS "${PROJECT_NAME} - Build tests" ON)
option(PACKAGE_CONFIG_DIR "Directory for package config files (relative to CMAKE_INSTALL_PREFIX)" "lib/cmake")
option(USE_LAPACK "${PROJECT_NAME} - Use LAPACK routines" ON)
option(USE_MPI "${PROJECT_NAME} - Use MPI" ON)
option(BUILD_FORTRAN "${PROJECT_NAME} - Build Fortran interfaces" ON)
set(BUILD_PRECISION sdcz CACHE STRING "${PROJECT_NAME} - Build precisions (sdcz)")

SET(FCMIX_ENABLE NO)
if (BUILD_FORTRAN)
    enable_language(Fortran)
    # Added by D. Wirtz - using cmake caps now for fortran/c interfacing
    include(FortranCInterface)
    FortranCInterface_HEADER(${CMAKE_CURRENT_BINARY_DIR}/sundials/sundials_fortran.h
                             MACRO_NAMESPACE SUNDIALS_FORTRAN_C_)
    FortranCInterface_VERIFY()
    # Add globally to include directories
    include_directories(${CMAKE_CURRENT_BINARY_DIR})
    SET(FCMIX_ENABLE YES)
endif()

IF(USE_LAPACK)
    FIND_PACKAGE(BLAS ${BLAS_VERSION} REQUIRED)
    FIND_PACKAGE(LAPACK ${LAPACK_VERSION} REQUIRED)
    SET(SUNDIALS_BLAS_LAPACK YES)
endif()

if(USE_MPI)
    FIND_PACKAGE(MPI REQUIRED)
    SET(MPI_MPICC ${MPI_C_COMPILER})
    SET(MPI_MPIF77 ${MPI_Fortran_COMPILER})
    SET(MPI_EXTRA_LIBRARIES ${MPI_EXTRA_LIBRARIES} ${MPI_Fortran_LIBRARIES})
    
    include(CheckCSourceCompiles)
    set(CMAKE_REQUIRED_DEFINITIONS ${MPI_COMPILE_FLAGS})
    set(CMAKE_REQUIRED_INCLUDES ${MPI_INCLUDE_PATH})
    set(CMAKE_REQUIRED_LIBRARIES ${MPI_LIBRARIES} ${MPI_EXTRA_LIBRARIES})
    check_c_source_compiles(
        "#include <mpi.h>\n
        int main(){
        int c;
        char **v;
        MPI_Comm C_comm;
        MPI_Init(&c, &v);
        C_comm = MPI_Comm_f2c((MPI_Fint) 1);
        MPI_Finalize();
        return(0);
        }" 
        MPIC_MPI2
    )
    
    IF(MPIC_MPI2)
      SET(F77_MPI_COMM_F2C "#define SUNDIALS_MPI_COMM_F2C 1")
      message(STATUS "Checking MPI2-compatibility ... YES")
    ELSE()
      SET(F77_MPI_COMM_F2C "#define SUNDIALS_MPI_COMM_F2C 0")
      message(STATUS "Checking MPI2-compatibility ... Failed. ${MY_OUTPUT}")
    ENDIF()
    # We have separate code for fortran-mpi code, so we'll leave that
    # here to have the chance of separate treatment
    SET(USE_MPIF ${USE_MPI})
endif()
include(CMakePackageConfigHelpers)



MARK_AS_ADVANCED(EXECUTABLE_OUTPUT_PATH LIBRARY_OUTPUT_PATH)
MARK_AS_ADVANCED(CLEAR
  CMAKE_C_COMPILER
  CMAKE_C_FLAGS
  CMAKE_C_FLAGS_DEBUG
  CMAKE_C_FLAGS_MINSIZEREL
  CMAKE_C_FLAGS_RELEASE
  CMAKE_C_FLAGS_RELWITHDEB)

# Specify the VERSION for libraries
SET(cvodelib_VERSION "1.0.0")
SET(cvodeslib_VERSION "2.0.0")
SET(idalib_VERSION "2.0.0")
SET(idaslib_VERSION "0.0.0")
SET(kinsollib_VERSION "1.0.0")
SET(cpodeslib_VERSION "0.0.0")
SET(nveclib_VERSION "0.0.2")

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
  ENDIF()
ENDMACRO(HIDE_VARIABLE)

MACRO(SHOW_VARIABLE var type doc default)
  IF(DEFINED ${var})
    SET(${var} "${${var}}" CACHE "${type}" "${doc}" FORCE)
  ELSE()
    SET(${var} "${default}" CACHE "${type}" "${doc}")
  ENDIF()
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
  MESSAGE(WARNING "${message}.\n   ${action}.")
ENDMACRO(PRINT_WARNING)

# Returns an unquoted string.  Note that CMake will readily turn such
# strings back into lists, due to the duality of lists and
# semicolon-separated strings.  So be careful how you use it.

MACRO(LIST2STRING alist astring)
  FOREACH(elem ${${alist}})
   SET(${astring} "${${astring}} ${elem}")
  ENDFOREACH()
ENDMACRO()

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
# DLL-Export declarations under windows/shared libs (for sundials_config.h)
if (WIN32 AND BUILD_SHARED_LIBS)
    SET(SUNDIALS_DLL_DECL YES)
endif()

# Option to specify precision
# choices are "double, single or extended"
# ---------------------------
# For OpenCMISS context we use sdcz for precision choosing.
# So we convert that here. While some packages allow to build multiple
# precisions, we here only have one to choose - we take the bigger one if also wanted.
if (BUILD_PRECISION MATCHES [d])
    SET(SUNDIALS_PRECISION "double")
elseif (BUILD_PRECISION MATCHES [s])
    SET(SUNDIALS_PRECISION "single")
endif()

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
ENDIF()

# -------------------------------------------------------------
# Enable Fortran support?
# -------------------------------------------------------------
# FCMIX support is an option only if at least one solver that 
# provides such an interface is built.
SET(FCMIX_ENABLE ON)

# -------------------------------------------------------------
# Enable examples?
# -------------------------------------------------------------
IF (BUILD_TESTS)
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
  #  ENDIF()

  #ELSE()

  #  HIDE_VARIABLE(EXAMPLES_INSTALL_PATH)

  #ENDIF()

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
ENDIF()

# -------------------------------------------------------------
# Configure
# -------------------------------------------------------------

# All required substitution variables should be available at this point.
# Generate the header file and place it in the binary dir.
CONFIGURE_FILE(
  ${PROJECT_SOURCE_DIR}/include/sundials/sundials_config.in
  ${PROJECT_BINARY_DIR}/include/sundials/sundials_config.h
  )

# add collecting interface library - subsequent libraries will add themselves to this for easy linking against ALL sundials libs
add_library(sundials INTERFACE)

# Add the include directory in the source tree and the one in
# the binary tree (for the header file sundials_config.h)
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/include ${PROJECT_BINARY_DIR}/include)

# -------------------------------------------------------------
# Add selected modules to the build system
# -------------------------------------------------------------

# Shared components
ADD_SUBDIRECTORY(src/sundials)
ADD_SUBDIRECTORY(src/nvec_ser)
IF(USE_MPI)
  ADD_SUBDIRECTORY(src/nvec_par)
ENDIF()

# CVODE library

IF(BUILD_CVODE)	
  ADD_SUBDIRECTORY(src/cvode)
  IF(FCMIX_ENABLE)
    ADD_SUBDIRECTORY(src/cvode/fcmix)
  ENDIF()
ENDIF()

# CVODES library
IF(BUILD_CVODES)	
  ADD_SUBDIRECTORY(src/cvodes)
ENDIF()

# IDA library
IF(BUILD_IDA)	
  ADD_SUBDIRECTORY(src/ida)
  IF(FCMIX_ENABLE)
    ADD_SUBDIRECTORY(src/ida/fcmix)
  ENDIF()
ENDIF()

# IDAS library
IF(BUILD_IDAS)	
  ADD_SUBDIRECTORY(src/idas)
ENDIF()

# KINSOL library
IF(BUILD_KINSOL)	
  ADD_SUBDIRECTORY(src/kinsol)
  IF(FCMIX_ENABLE)
    ADD_SUBDIRECTORY(src/kinsol/fcmix)
  ENDIF()
ENDIF()

# CPODES library
IF(BUILD_CPODES)	
  ADD_SUBDIRECTORY(src/cpodes)
ENDIF()

# -------------------------------------------------------------
# Include the subdirectories corresponding to various examples
# -------------------------------------------------------------

# If building and installing the examples is enabled, include
# the subdirectories for those examples that will be built.
# Also, if we will generate exported example Makefiles, set 
# variables needed in generating them from templates.

IF(BUILD_TESTS)

  IF(BUILD_CVODE)
    ADD_SUBDIRECTORY(examples/cvode/serial)
    IF(FCMIX_ENABLE)
      ADD_SUBDIRECTORY(examples/cvode/fcmix_serial)
    ENDIF()
    IF(USE_MPI)
      ADD_SUBDIRECTORY(examples/cvode/parallel)
    ENDIF()
    IF(USE_MPIF)
      ADD_SUBDIRECTORY(examples/cvode/fcmix_parallel)
    ENDIF()
  ENDIF()
  
  IF(BUILD_CVODES)	
    ADD_SUBDIRECTORY(examples/cvodes/serial)
    IF(USE_MPI)
      ADD_SUBDIRECTORY(examples/cvodes/parallel)
    ENDIF()
  ENDIF()
  
  IF(BUILD_IDA)
    ADD_SUBDIRECTORY(examples/ida/serial)
    IF(FCMIX_ENABLE)
      ADD_SUBDIRECTORY(examples/ida/fcmix_serial)
    ENDIF()
    IF(USE_MPI)
      ADD_SUBDIRECTORY(examples/ida/parallel)
    ENDIF()
    IF(USE_MPIF)
      ADD_SUBDIRECTORY(examples/ida/fcmix_parallel)
    ENDIF()
  ENDIF()
  
  IF(BUILD_IDAS)	
    ADD_SUBDIRECTORY(examples/idas/serial)
    IF(USE_MPI)
      ADD_SUBDIRECTORY(examples/idas/parallel)
    ENDIF()
  ENDIF()

  IF(BUILD_KINSOL)	
    ADD_SUBDIRECTORY(examples/kinsol/serial)
    IF(FCMIX_ENABLE)
      ADD_SUBDIRECTORY(examples/kinsol/fcmix_serial)
    ENDIF()
    IF(USE_MPI)
      ADD_SUBDIRECTORY(examples/kinsol/parallel)
    ENDIF()
    IF(USE_MPIF)
      ADD_SUBDIRECTORY(examples/kinsol/fcmix_parallel)
    ENDIF()
  ENDIF()

  IF(BUILD_CPODES)	
    ADD_SUBDIRECTORY(examples/cpodes/serial)
    IF(USE_MPI)
      ADD_SUBDIRECTORY(examples/cpodes/parallel)
    ENDIF()
  ENDIF()
  
ENDIF()

#----------------------------------
# Install
#----------------------------------

# install configured header file
INSTALL(
  FILES ${PROJECT_BINARY_DIR}/include/sundials/sundials_config.h
  DESTINATION include/sundials
)
if (FCMIX_ENABLE)
    INSTALL(
      FILES ${CMAKE_CURRENT_BINARY_DIR}/sundials/sundials_fortran.h
      DESTINATION include/sundials
    )
endif()
install(TARGETS sundials EXPORT sundials-config)
install(EXPORT sundials-config DESTINATION ${PACKAGE_CONFIG_DIR})
include(CMakePackageConfigHelpers)
WRITE_BASIC_PACKAGE_VERSION_FILE(${CMAKE_CURRENT_BINARY_DIR}/sundials-config-version.cmake COMPATIBILITY AnyNewerVersion)
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/sundials-config-dependencies.cmake 
    "include(CMakeFindDependencyMacro)\r\n"
    	"set(${PROJECT_NAME}_IMPORT_PREFIX \${_IMPORT_PREFIX})\r\n"
)
if (USE_LAPACK)
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/sundials-config-dependencies.cmake 
        "find_dependency(BLAS ${BLAS_VERSION})\r\n"
        "find_dependency(LAPACK ${LAPACK_VERSION})\r\n")
endif()
file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/sundials-config-dependencies.cmake "set(_IMPORT_PREFIX \${${PROJECT_NAME}_IMPORT_PREFIX})")
install(FILES 
    ${CMAKE_CURRENT_BINARY_DIR}/sundials-config-version.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/sundials-config-dependencies.cmake
    DESTINATION ${PACKAGE_CONFIG_DIR})