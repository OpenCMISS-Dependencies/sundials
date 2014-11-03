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
# CMakeLists.txt file for the KINSOL library

INSTALL(CODE "MESSAGE(\"\nInstall KINSOL\n\")")

# Add variable kinsol_SOURCES with the sources for the KINSOL library
SET(kinsol_SOURCES
  kinsol.c
  kinsol_io.c
  kinsol_direct.c
  kinsol_band.c
  kinsol_dense.c
  kinsol_spils.c
  kinsol_spbcgs.c
  kinsol_spgmr.c
  kinsol_sptfqmr.c
  kinsol_bbdpre.c
  )

# Add variable shared_SOURCES with the common SUNDIALS sources which will
# also be included in the KINSOL library
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

# Add variable kinsol_HEADERS with the exported KINSOL header files
SET(kinsol_HEADERS
  kinsol_band.h
  kinsol_bbdpre.h
  kinsol_dense.h
  kinsol_direct.h
  kinsol.h
  kinsol_spbcgs.h
  kinsol_spgmr.h
  kinsol_spils.h
  kinsol_sptfqmr.h
  )

# Add prefix with complete path to the KINSOL header files
ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/kinsol/ kinsol_HEADERS)

# If Blas/Lapack support was enabled, set-up additional file lists
IF(LAPACK_FOUND)
  SET(kinsol_BL_SOURCES kinsol_lapack.c)
  SET(kinsol_BL_HEADERS kinsol_lapack.h)
  ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/kinsol/ kinsol_BL_HEADERS)
ELSE(LAPACK_FOUND)
  SET(kinsol_BL_SOURCES "")
  SET(kinsol_BL_HEADERS "")
ENDIF(LAPACK_FOUND)

# Define C preprocessor flag -DBUILD_SUNDIALS_LIBRARY 
ADD_DEFINITIONS(-DBUILD_SUNDIALS_LIBRARY)

# Add the build target for the static KINSOL library
ADD_LIBRARY(sundials_kinsol STATIC
  ${kinsol_SOURCES} ${kinsol_BL_SOURCES} ${shared_SOURCES})

target_include_directories(sundials_kinsol PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../sundials>)
SET_TARGET_PROPERTIES(sundials_kinsol
  PROPERTIES OUTPUT_NAME sundials_kinsol CLEAN_DIRECT_OUTPUT 1)
IF(LAPACK_FOUND)
    target_link_libraries(sundials_kinsol PUBLIC lapack)
endif()

# Install the KINSOL library
INSTALL(TARGETS sundials_kinsol EXPORT sundials-config
    DESTINATION lib
    INCLUDES DESTINATION include/kinsol)

# Install the KINSOL header files
INSTALL(FILES ${kinsol_HEADERS} ${kinsol_BL_HEADERS} DESTINATION include/kinsol)

# Install the KINSOL implementation header file
INSTALL(FILES kinsol_impl.h DESTINATION include/kinsol)

#
MESSAGE(STATUS "Added KINSOL module")
