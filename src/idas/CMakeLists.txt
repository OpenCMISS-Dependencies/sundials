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
# CMakeLists.txt file for the IDAS library

INSTALL(CODE "MESSAGE(\"\nInstall IDAS\n\")")

# Add variable idas_SOURCES with the sources for the IDAS library
SET(idas_SOURCES
  idas.c
  idaa.c
  idas_io.c
  idas_ic.c
  idaa_io.c
  idas_direct.c
  idas_band.c
  idas_dense.c
  idas_spils.c
  idas_spbcgs.c
  idas_spgmr.c
  idas_sptfqmr.c
  idas_bbdpre.c
  )

# Add variable shared_SOURCES with the common SUNDIALS sources which will
# also be included in the IDAS library
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

# Add variable idas_HEADERS with the exported IDAS header files
SET(idas_HEADERS
  idas_band.h
  idas_bbdpre.h
  idas_dense.h
  idas_direct.h
  idas.h
  idas_spbcgs.h
  idas_spgmr.h
  idas_spils.h
  idas_sptfqmr.h
  )

# Add prefix with complete path to the IDAS header files
ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/idas/ idas_HEADERS)

# If Blas/Lapack support was enabled, set-up additional file lists
IF(LAPACK_FOUND)
  SET(idas_BL_SOURCES idas_lapack.c)
  SET(idas_BL_HEADERS idas_lapack.h)
  ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/idas/ idas_BL_HEADERS)
ELSE()
  SET(idas_BL_SOURCES "")
  SET(idas_BL_HEADERS "")
ENDIF()

# Define C preprocessor flag -DBUILD_SUNDIALS_LIBRARY 
ADD_DEFINITIONS(-DBUILD_SUNDIALS_LIBRARY)

# Add the build target for the static IDAS library
ADD_LIBRARY(sundials_idas 
  ${idas_SOURCES} ${idas_BL_SOURCES}  ${shared_SOURCES})
target_include_directories(sundials_idas PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../sundials>)
SET_TARGET_PROPERTIES(sundials_idas
  PROPERTIES OUTPUT_NAME sundials_idas CLEAN_DIRECT_OUTPUT 1)
IF(LAPACK_FOUND)
    target_link_libraries(sundials_idas PUBLIC ${LAPACK_LIBRARIES})
endif()
target_link_libraries(sundials INTERFACE sundials_idas)

# Install the IDA library
INSTALL(TARGETS sundials_idas EXPORT sundials-config
    DESTINATION lib
    INCLUDES DESTINATION include/idas)

# Install the IDAS header files
INSTALL(FILES ${idas_HEADERS} ${idas_BL_HEADERS} DESTINATION include/idas)

# Install the IDAS implementation header file
INSTALL(FILES idas_impl.h DESTINATION include/idas)

#
MESSAGE(STATUS "Added IDAS module")
