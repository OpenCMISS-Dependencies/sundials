# CMakeLists.txt file for the FIDA library

# Add variable fida_SOURCES with the sources for the FIDA library
SET(fida_SOURCES
  fidaband.c
  fidabbd.c
  fida.c
  fidadense.c
  fidaewt.c
  fidajtimes.c
  fidapreco.c
  fidaroot.c
  )

IF(LAPACK_FOUND)
  SET(fida_BL_SOURCES fidalapack.c fidalapdense.c fidalapband.c)
ELSE(LAPACK_FOUND)
  SET(fida_BL_SOURCES "")
ENDIF(LAPACK_FOUND)

# Define C preprocessor flag -DBUILD_SUNDIALS_LIBRARY 
ADD_DEFINITIONS(-DBUILD_SUNDIALS_LIBRARY)

# Add the build target for the FIDA library
ADD_LIBRARY(sundials_fida ${fida_SOURCES} ${fida_BL_SOURCES})

# Set the library name and make sure it is not deleted
SET_TARGET_PROPERTIES(sundials_fida
  PROPERTIES OUTPUT_NAME sundials_fida CLEAN_DIRECT_OUTPUT 1)
target_include_directories(sundials_fida PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>)
IF(LAPACK_FOUND)
    target_link_libraries(sundials_fida PUBLIC lapack)
endif()

# Install the FIDA library
INSTALL(TARGETS sundials_fida EXPORT sundials-config
    DESTINATION lib)
#
MESSAGE(STATUS "Added IDA FCMIX module")
