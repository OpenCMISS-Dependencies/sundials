# ---------------------------------------------------------------
# $Revision: 1.4 $
# $Date: 2009/02/17 02:58:47 $
# ---------------------------------------------------------------
# Programmer:  Radu Serban @ LLNL
# ---------------------------------------------------------------
# Copyright (c) 2007, The Regents of the University of California.
# Produced at the Lawrence Livermore National Laboratory.
# All rights reserved.
# For details, see the LICENSE file.
# ---------------------------------------------------------------
# CMakeLists.txt file for the CVODES library

INSTALL(CODE "MESSAGE(\"\nInstall CVODES\n\")")

# Add variable cvodes_SOURCES with the sources for the CVODES library
SET(cvodes_SOURCES
  cvodes.c
  cvodea.c
  cvodes_io.c
  cvodea_io.c
  cvodes_direct.c
  cvodes_band.c
  cvodes_dense.c
  cvodes_diag.c
  cvodes_spils.c
  cvodes_spbcgs.c
  cvodes_spgmr.c
  cvodes_sptfqmr.c
  cvodes_bandpre.c
  cvodes_bbdpre.c
  )

# Add variable shared_SOURCES with the common SUNDIALS sources which will
# also be included in the CVODES library
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

# Add variable cvodes_HEADERS with the exported CVODES header files
SET(cvodes_HEADERS
  cvodes_band.h
  cvodes_bandpre.h
  cvodes_bbdpre.h
  cvodes_dense.h
  cvodes_diag.h
  cvodes_direct.h
  cvodes.h
  cvodes_spbcgs.h
  cvodes_spgmr.h
  cvodes_spils.h
  cvodes_sptfqmr.h
  )

# Add prefix with complete path to the CVODES header files
ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/cvodes/ cvodes_HEADERS)

# If Blas/Lapack support was enabled, set-up additional file lists
IF(LAPACK_FOUND)
  SET(cvodes_BL_SOURCES cvodes_lapack.c)
  SET(cvodes_BL_HEADERS cvodes_lapack.h)
  ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/cvodes/ cvodes_BL_HEADERS)
ELSE(LAPACK_FOUND)
  SET(cvodes_BL_SOURCES "")
  SET(cvodes_BL_HEADERS "")
ENDIF(LAPACK_FOUND)

# Define C preprocessor flag -DBUILD_SUNDIALS_LIBRARY 
ADD_DEFINITIONS(-DBUILD_SUNDIALS_LIBRARY)

# Add the build target for the static CVODES library
ADD_LIBRARY(sundials_cvodes STATIC 
  ${cvodes_SOURCES}  ${cvodes_BL_SOURCES}  ${shared_SOURCES})
target_include_directories(sundials_cvodes PUBLIC . ../sundials)
SET_TARGET_PROPERTIES(sundials_cvodes
  PROPERTIES OUTPUT_NAME sundials_cvodes CLEAN_DIRECT_OUTPUT 1)
IF(LAPACK_FOUND)
    target_link_libraries(sundials_cvodes PUBLIC lapack)
endif()  

# Install the CVODES library
#INSTALL(TARGETS sundials_cvodes DESTINATION lib)

# Install the CVODES header files
#INSTALL(FILES ${cvodes_HEADERS}  ${cvodes_BL_HEADERS} DESTINATION include/cvodes)

# Install the CVODES implementation header file
#INSTALL(FILES cvodes_impl.h DESTINATION include/cvodes)

#
MESSAGE(STATUS "Added CVODES module")
