CMAKE_MINIMUM_REQUIRED(VERSION 3.21)

# Demonstration of modern CMake to introduce an out-of-tree/3rd party
# shared object dependency into a project in such a way that CMake
# knows to copy the shared object (e.g .dll file) into the build-tree
# and with `install()` invocations.

# *NOTE*:
# - Flatness: Instead of creating a directory hierarchy, I'm using a
# single CMakeLists.txt for the main project for brevity.
# - No Headers: I'm fwd declaring functions to reduce file count.
# - For simplicity's sake, this demo currently only supports
#   RelWithDebInfo.


PROJECT(DllDependency)

# -------------------------------------------------------------------
# A low level target that describes the dll and it's interface lib.
# The external dll is provided in the ExternalDLL directory with its
# own simple CMakeLists.

ADD_LIBRARY(
	ExternalDLL
	SHARED IMPORTED GLOBAL
)

IF (WIN32)
	# Describe the path to the DLL itself, which the sub-project placed
	# into a well-known location for us, and the path to the shared lib
	# stub.
	# It's unfortunate this still has to be so aggressively platform
	# specific.
	# We also added in the extra difficulty of the Debug build of the
	# DLL and its library having a _Debug suffix.
	SET_TARGET_PROPERTIES(
		ExternalDLL
		PROPERTIES
			IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/DLL/lib/DLL.dll"
			IMPORTED_IMPLIB   "${CMAKE_CURRENT_LIST_DIR}/DLL/lib/DLL.lib"

			IMPORTED_LOCATION_DEBUG "${CMAKE_CURRENT_LIST_DIR}/DLL/lib/DLL_Debug.dll"
			IMPORTED_IMPLIB_DEBUG   "${CMAKE_CURRENT_LIST_DIR}/DLL/lib/DLL_Debug.lib"
	)
ELSE ()
	MESSAGE(FATAL_ERROR "Non-Windows demo not implemented, yet.")
ENDIF()

# Tell CMake it needs to install the imported artifact and where the
# various pieces of it should go.
# NOTE: Only tested on windows so far, don't know what this will do
# with shared objects or dylibs, yet.
INSTALL(
	IMPORTED_RUNTIME_ARTIFACTS

	ExternalDLL

	DESTINATION   "${CMAKE_CURRENT_LIST_DIR}/Artifacts"
)


# -------------------------------------------------------------------
# ExternalDLL is brought into the code hierarchy through LowestLib

ADD_LIBRARY			 (LowestLib	lowest.cpp)
TARGET_LINK_LIBRARIES(LowestLib PUBLIC ExternalDLL)


# -------------------------------------------------------------------
# An intermediate library to put distance between the dll and the
# final build product, the executable.
#
# "MiddleLib" has no knowledge of LowestLib relying on a 3rd party.

ADD_LIBRARY			 (MiddleLib middle.cpp)
TARGET_LINK_LIBRARIES(MiddleLib PUBLIC LowestLib)


# -------------------------------------------------------------------
# Finally, our executable definition has no awareness of the DLL.

ADD_EXECUTABLE		 (Program program.cpp)
TARGET_LINK_LIBRARIES(Program PUBLIC MiddleLib)


# -------------------------------------------------------------------
# How install might look on a CI machine.
INSTALL(
	TARGETS Program

	# On Windows, DLL is considered Runtime, whereas on other OSes,
	# the .so/.dylib/etc is considered a library.
	DESTINATION "${CMAKE_CURRENT_LIST_DIR}/Artifacts"
)


# Build and install the entire project:
#  cmake -B        ./DLL/build ./DLL      # specify -G if you must
#  cmake --build   ./DLL/build --config RelWithDebInfo 
#  cmake --install ./DLL/build --config RelWithDebInfo
#  cmake -B        ./build                # specify -G if you must
#  cmake --build   ./build     --config RelWithDebInfo
#  cmake --install ./build     --config RelWithDebInfo
#
# After which you should find Program.exe and External.{dll|so}
# in ./build/Program (or build/Program/<configuration>/) and
# ./Artifacts/
