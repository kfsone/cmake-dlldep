# This simulates some out-of-tree or 3rd-party shared object
# dependency. To create the 'external' files required,
# simply:
#
#  cmake -B        ./build
#  cmake --build   ./build --config RelWithDebInfo
#  cmake --install ./build --config RelWithDebInfo

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)

PROJECT(DLL)

ADD_LIBRARY(
	DLL	SHARED

	dll.cpp
)

# Let's also demonstrate how to deal with a variant that has
# different names for different configs. You can't use generator
# expressions for "IMPORTED_IMPLIB" and "IMPORTED_LOCATION" as
# of 3.22, so instead you have to use the config-specific variables.
SET_TARGET_PROPERTIES(
	DLL PROPERTIES

	OUTPUT_NAME_DEBUG "DLL_Debug"
)

# Debug version is called "DLL-Debug.{lib,dll}" and release is
# called "DLL.{lib,dll}".

# To fully simulate being an out-of-tree product, we're going
# to finish by installing to a "well known path" without our
# directory, i.e. lib/
INSTALL(
	TARGETS	  DLL
	ARCHIVE   DESTINATION "${CMAKE_CURRENT_LIST_DIR}/lib"
	LIBRARY   DESTINATION "${CMAKE_CURRENT_LIST_DIR}/lib"
	RUNTIME   DESTINATION "${CMAKE_CURRENT_LIST_DIR}/lib"
	FRAMEWORK DESTINATION "${CMAKE_CURRENT_LIST_DIR}/lib"
)
