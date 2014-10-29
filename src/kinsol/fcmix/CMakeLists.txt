# CMakeLists.txt file for the FKINSOL library

# Add variable fcvode_SOURCES with the sources for the FCVODE library
SET(fkinsol_SOURCES
  fkinband.c
  fkinbbd.c
  fkindense.c
  fkinjtimes.c
  fkinpreco.c
  fkinsol.c
  )

IF(LAPACK_FOUND)
  SET(fkinsol_BL_SOURCES fkinlapack.c fkinlapdense.c fkinlapband.c)
ELSE(LAPACK_FOUND)
  SET(fkinsol_BL_SOURCES "")
ENDIF(LAPACK_FOUND)

# Define C preprocessor flag -DBUILD_SUNDIALS_LIBRARY 
ADD_DEFINITIONS(-DBUILD_SUNDIALS_LIBRARY)

# Only build STATIC libraries (we cannot build shared libraries 
# for the FCMIX interfaces due to unresolved symbol errors 
# coming from inexistent user-provided functions)

# Add the build target for the FKINSOL library
ADD_LIBRARY(sundials_fkinsol STATIC ${fkinsol_SOURCES} ${fkinsol_BL_SOURCES})

target_include_directories(sundials_fkinsol PUBLIC . ..)
SET_TARGET_PROPERTIES(sundials_fkinsol
  PROPERTIES OUTPUT_NAME sundials_fkinsol CLEAN_DIRECT_OUTPUT 1)
IF(LAPACK_FOUND)
    target_link_libraries(sundials_fkinsol PUBLIC lapack)
endif()  

# Install the FKINSOL library
#INSTALL(TARGETS sundials_fkinsol DESTINATION lib)

#
MESSAGE(STATUS "Added KINSOL FCMIX module")
