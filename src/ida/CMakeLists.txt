# ---------------------------------------------------------------
# $Revision: 1.4 $
# $Date: 2009/02/17 02:58:48 $
# ---------------------------------------------------------------
# Programmer:  Radu Serban @ LLNL
# ---------------------------------------------------------------
# Copyright (c) 2007, The Regents of the University of California.
# Produced at the Lawrence Livermore National Laboratory.
# All rights reserved.
# For details, see the LICENSE file.
# ---------------------------------------------------------------
# CMakeLists.txt file for the IDA library

INSTALL(CODE "MESSAGE(\"\nInstall IDA\n\")")

# Add variable ida_SOURCES with the sources for the IDA library
SET(ida_SOURCES
  ida.c
  ida_io.c
  ida_ic.c
  ida_direct.c
  ida_band.c
  ida_dense.c
  ida_spils.c
  ida_spbcgs.c
  ida_spgmr.c
  ida_sptfqmr.c
  ida_bbdpre.c
  )

# Add variable shared_SOURCES with the common SUNDIALS sources which will
# also be included in the IDA library
SET(shared_SOURCES
  sundials_nvector.c
  sundials_math.c
  sundials_direct.c
  sundials_band.c
  sundials_dense.c
  sundials_iterative.c
  sundials_spbcgs.c
  sundials_spgmr.c
  sundials_sptfqmr.c
  )

# Add prefix with complete path to the common SUNDIALS sources
ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/src/sundials/ shared_SOURCES)

# Add variable ida_HEADERS with the exported IDA header files
SET(ida_HEADERS
  ida_band.h
  ida_bbdpre.h
  ida_dense.h
  ida_direct.h
  ida.h
  ida_spbcgs.h
  ida_spgmr.h
  ida_spils.h
  ida_sptfqmr.h
  )

# Add prefix with complete path to the IDA header files
ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/ida/ ida_HEADERS)

# If Blas/Lapack support was enabled, set-up additional file lists
IF(LAPACK_FOUND)
  SET(ida_BL_SOURCES ida_lapack.c)
  SET(ida_BL_HEADERS ida_lapack.h)
  ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/ida/ ida_BL_HEADERS)
ELSE()
  SET(ida_BL_SOURCES "")
  SET(ida_BL_HEADERS "")
ENDIF()

# Define C preprocessor flag -DBUILD_SUNDIALS_LIBRARY 
ADD_DEFINITIONS(-DBUILD_SUNDIALS_LIBRARY)

# Add the build target for the static IDA library
ADD_LIBRARY(sundials_ida
  ${ida_SOURCES}  ${ida_BL_SOURCES}  ${shared_SOURCES})

target_include_directories(sundials_ida PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../sundials>)
SET_TARGET_PROPERTIES(sundials_ida
  PROPERTIES OUTPUT_NAME sundials_ida CLEAN_DIRECT_OUTPUT 1)
IF(LAPACK_FOUND)
    target_link_libraries(sundials_ida PUBLIC lapack)
endif()
target_link_libraries(sundials INTERFACE sundials_ida)

# Install the IDA library
INSTALL(TARGETS sundials_ida EXPORT sundials-config 
    DESTINATION lib
    INCLUDES DESTINATION include/ida)

# Install the IDA header files
INSTALL(FILES ${ida_HEADERS} ${ida_BL_HEADERS} DESTINATION include/ida)

# Install the IDA implementation header file
INSTALL(FILES ida_impl.h DESTINATION include/ida)

#
MESSAGE(STATUS "Added IDA module")
