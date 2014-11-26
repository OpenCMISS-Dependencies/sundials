# ---------------------------------------------------------------
# $Revision: 1.3 $
# $Date: 2009/02/17 02:58:48 $
# ---------------------------------------------------------------
# Programmer:  Radu Serban @ LLNL
# ---------------------------------------------------------------
# Copyright (c) 2007, The Regents of the University of California.
# Produced at the Lawrence Livermore National Laboratory.
# All rights reserved.
# For details, see the LICENSE file.
# ---------------------------------------------------------------
# CMakeLists.txt file for the serial NVECTOR library

INSTALL(CODE "MESSAGE(\"\nInstall NVECTOR_SERIAL\n\")")

# Add variable nvecserial_SOURCES with the sources for the NVECSERIAL lib
SET(nvecserial_SOURCES nvector_serial.c)

# Add variable shared_SOURCES with the common SUNDIALS sources which will
# also be included in the NVECSERIAL library
SET(shared_SOURCES sundials_math.c)
ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/src/sundials/ shared_SOURCES)

# Add variable nvecserial_HEADERS with the exported NVECSERIAL header files
SET(nvecserial_HEADERS nvector_serial.h)
ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/nvector/ nvecserial_HEADERS)

# Define C preprocessor flag -DBUILD_SUNDIALS_LIBRARY 
ADD_DEFINITIONS(-DBUILD_SUNDIALS_LIBRARY)

ADD_LIBRARY(sundials_nvecserial ${nvecserial_SOURCES} ${shared_SOURCES})
SET_TARGET_PROPERTIES(sundials_nvecserial
  PROPERTIES OUTPUT_NAME sundials_nvecserial CLEAN_DIRECT_OUTPUT 1)
target_include_directories(sundials_nvecserial PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
INSTALL(TARGETS sundials_nvecserial
    EXPORT sundials-config 
    DESTINATION lib
    INCLUDES DESTINATION include/nvector)

# Install the NVECSERIAL header files
INSTALL(FILES ${nvecserial_HEADERS} DESTINATION include/nvector)

# If FCMIX is enabled, build and install the FNVECSERIAL library
IF(FCMIX_ENABLE AND F77_FOUND)
  SET(fnvecserial_SOURCES fnvector_serial.c)
  ADD_LIBRARY(sundials_fnvecserial ${fnvecserial_SOURCES})
  SET_TARGET_PROPERTIES(sundials_fnvecserial
    PROPERTIES OUTPUT_NAME sundials_fnvecserial CLEAN_DIRECT_OUTPUT 1)
  target_include_directories(sundials_fnvecserial PUBLIC .)
    #INSTALL(TARGETS sundials_fnvecserial DESTINATION lib)
ENDIF(FCMIX_ENABLE AND F77_FOUND)

#
MESSAGE(STATUS "Added NVECTOR_SERIAL module")
