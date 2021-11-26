CMAKE_MINIMUM_REQUIRED(VERSION 3.18)

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
	SET_TARGET_PROPERTIES(
		ExternalDLL
		PROPERTIES
			IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/DLL/lib/DLL.dll"
			IMPORTED_IMPLIB   "${CMAKE_CURRENT_LIST_DIR}/DLL/lib/DLL.lib"
	)
ELSE ()
	MESSAGE(FATAL_ERROR "Non-Windows demo not implemented, yet.")
ENDIF()


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
	DESTINATION ${CMAKE_BINARY_DIR}/../Artifacts
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
