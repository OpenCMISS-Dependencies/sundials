# CMakeLists.txt file for the FCVODE library

# Add variable fcvode_SOURCES with the sources for the FCVODE library
SET(fcvode_SOURCES
  fcvband.c
  fcvbbd.c
  fcvbp.c
  fcvdense.c
  fcvewt.c
  fcvjtimes.c
  fcvode.c
  fcvpreco.c
  fcvroot.c
  )

IF(LAPACK_FOUND)
  SET(fcvode_BL_SOURCES fcvlapack.c fcvlapband.c fcvlapdense.c)
ELSE(LAPACK_FOUND)
  SET(fcvode_BL_SOURCES "")
ENDIF(LAPACK_FOUND)

# Define C preprocessor flag -DBUILD_SUNDIALS_LIBRARY 
ADD_DEFINITIONS(-DBUILD_SUNDIALS_LIBRARY)

# Add the build target for the FCVODE library
ADD_LIBRARY(sundials_fcvode STATIC ${fcvode_SOURCES} ${fcvode_BL_SOURCES})
target_include_directories(sundials_fcvode PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>)
SET_TARGET_PROPERTIES(sundials_fcvode
  PROPERTIES OUTPUT_NAME sundials_fcvode CLEAN_DIRECT_OUTPUT 1)
IF(LAPACK_FOUND)
    target_link_libraries(sundials_fcvode PUBLIC lapack)
endif()

# Install the FCVODE library
INSTALL(TARGETS sundials_fcvode EXPORT sundials-config
    DESTINATION lib)

#
MESSAGE(STATUS "Added CVODE FCMIX module")
