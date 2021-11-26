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

INSTALL(
	TARGETS		DLL
	EXPORT      DLLDependency
	LIBRARY	DESTINATION ${CMAKE_CURRENT_LIST_DIR}/lib
	ARCHIVE	DESTINATION ${CMAKE_CURRENT_LIST_DIR}/lib
	RUNTIME	DESTINATION ${CMAKE_CURRENT_LIST_DIR}/lib
)

# If you wanted to create an includable .cmake so that the
# dependency could be IMPORTed elsewhere:
#
# INSTALL(
# 	EXPORT		DLLDependency
# 	FILE		DLLDependency.cmake
# 	NAMESPACE	DLLDependency::
# 	DESTINATION ../lib
# )