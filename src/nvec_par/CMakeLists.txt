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
# CMakeLists.txt file for the parallel NVECTOR library

INSTALL(CODE "MESSAGE(\"\nInstall NVECTOR_PARALLEL\n\")")

IF(MPI_MPICC)
  # use MPI_MPICC as the compiler
  SET(CMAKE_C_COMPILER ${MPI_MPICC})
ELSE()
  # add MPI_INCLUDE_PATH to include directories
  INCLUDE_DIRECTORIES(${MPI_INCLUDE_PATH})
ENDIF()

# Add variable nvecparallel_SOURCES with the sources for the NVECPARALLEL lib
SET(nvecparallel_SOURCES nvector_parallel.c)

# Add variable shared_SOURCES with the common SUNDIALS sources which will
# also be included in the NVECPARALLEL library
SET(shared_SOURCES sundials_math.c)
ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/src/sundials/ shared_SOURCES)

# Add variable nvecparallel_HEADERS with the exported NVECPARALLEL header files
SET(nvecparallel_HEADERS nvector_parallel.h)
ADD_PREFIX(${SUNDIALS_SOURCE_DIR}/include/nvector/ nvecparallel_HEADERS)

# Define C preprocessor flag -DBUILD_SUNDIALS_LIBRARY 
ADD_DEFINITIONS(-DBUILD_SUNDIALS_LIBRARY)

ADD_LIBRARY(sundials_nvecparallel ${nvecparallel_SOURCES} ${shared_SOURCES})
SET_TARGET_PROPERTIES(sundials_nvecparallel
  PROPERTIES OUTPUT_NAME sundials_nvecparallel CLEAN_DIRECT_OUTPUT 1)
target_link_libraries(sundials_nvecparallel PUBLIC MPI::MPI_C)
target_link_libraries(sundials INTERFACE sundials_nvecparallel)
target_include_directories(sundials_nvecparallel PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)  
INSTALL(TARGETS sundials_nvecparallel 
    EXPORT sundials-config
    DESTINATION lib
    INCLUDES DESTINATION include/nvector)

# Install the NVECPARALLEL header files
INSTALL(FILES ${nvecparallel_HEADERS} DESTINATION include/nvector)

# If FCMIX is enabled and MPI-F77 works, build and install the FNVECPARALLEL library
IF(FCMIX_ENABLE AND USE_MPIF)
  SET(fnvecparallel_SOURCES fnvector_parallel.c)
  ADD_LIBRARY(sundials_fnvecparallel ${fnvecparallel_SOURCES})
  SET_TARGET_PROPERTIES(sundials_fnvecparallel
    PROPERTIES OUTPUT_NAME sundials_fnvecparallel CLEAN_DIRECT_OUTPUT 1)
  target_link_libraries(sundials_fnvecparallel PUBLIC sundials_nvecparallel)
  target_link_libraries(sundials INTERFACE sundials_fnvecparallel)
  target_include_directories(sundials_fnvecparallel PRIVATE .)
  INSTALL(TARGETS sundials_fnvecparallel EXPORT sundials-config DESTINATION lib)
ENDIF()
#
MESSAGE(STATUS "Added NVECTOR_PARALLEL module")
