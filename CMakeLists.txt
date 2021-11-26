CMAKE_MINIMUM_REQUIRED(VERSION 3.18)

# Demonstration of modern CMake to introduce an out-of-tree/3rd party
# shared object dependency into a project in such a way that CMake
# knows to copy the shared object (e.g .dll file) into the build-tree
# and with `install()` invocations.

# NB:
# - Flatness: Instead of creating a directory hierarchy, I'm using a
# single CMakeLists.txt for the main project for brevity.
# - No Headers: I'm fwd declaring functions to reduce file count.

PROJECT(DllDependency)

# -------------------------------------------------------------------
# A low level target that describes the dll and it's interface lib.
# The external dll is provided in the ExternalDLL directory with its
# own simple CMakeLists.

ADD_LIBRARY(
	ExternalDLL

	SHARED IMPORT
)

### TBD
# SET_TARGET_PROPERTIES(
# 	ExternalDLL
# 	PROPERTIES

# )
### TBD


# -------------------------------------------------------------------
# ExternalDLL is brought into the code hierarchy through LowestLib

ADD_LIBRARY(
	LowestLib

	lowest.cpp
)

TARGET_LINK_LIBRARIES(
	LowestLib

	PUBLIC	ExternalDLL
)


# -------------------------------------------------------------------
# An intermediate library to put distance between the dll and the
# final build product, the executable.
#
# "MiddleLib" has no knowledge of LowestLib relying on a 3rd party.

ADD_LIBRARY(
	MiddleLib

	middle.cpp
)

TARGET_LINK_LIBRARIES(
	MiddleLib

	PUBLIC LowestLib
)


# -------------------------------------------------------------------
# Finally, our executable definition has no awareness of the DLL.

ADD_EXECUTABLE(
	Program

	program.cpp
)

TARGET_LINK_LIBRARIES(
	Program

	MiddleLib
)

# How install might look on a CI machine.
# The component name is the same as the TARGETs name because why
# would it be anything else?
INSTALL(
	TARGETS Program
	DESTINATION ${CMAKE_BINARY_DIR}/../Artifacts
	COMPONENT   Program
)

# Build and install:
#  cmake -B        ./Build/  # choose your -G if you must
#  cmake --build   ./Build/  --target    Program
#  cmake --install ./Build/  --component Program
#
# After which you should find Program.exe and External.{dll|so}
# in ./Build/Program (or Build/Program/<configuration>/) and
# ./Artifacts/
