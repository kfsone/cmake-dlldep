# Building an out-of-source DLL Dependency in CMake.

Over the lifetime of CMake the handling of executables dependent on shared objects has been a continual subject of questions and confusion.

How do you get CMake to understand that a given shared-object file (esp. a Windows DLL) must be present alongside binary executables and ensure that it is, for you?

There are many existing answers, the most common of which is: you don't - make a function that describes a post-build function that uses `add_custom_target` with `copy_if_different` and do it yourself.

# Old CMake

The old approach to describing libraries and the properties they required was either abject pollution of shared namespace, setting include directories and compiler definitions everywhere for everyone, or creating collections of variables and requiring users to use them at the right time, down stream.

```cmake
SET(LOW_LEVEL_LIB_CLFAGS_DEBUG "-O3 -g0 -fpfast")
```
```cmake
# Don't inject low_level_lib_cflags here because <reasons>
SET(HIGH_LEVEL_LIV1_CFLAGS_DEBUG "-msse2")
```
```cmake
ADD_EXECUTABLE(result ...)
TARGET_LINK_LIBRARIES(result HIGH_LEVEL_LIB1 HIGH_LEVEL_LIB2)
SET(CMAKE_CFLAGS "${HIGH_LEVEL_LIB1_CFLAGS_DEBUG} ${HIGH_LEVEL_LIB2_DEBUG} ${LOW_LEVEL_LIB_CFLAGS_DEBUG} ...")
```

# Modern CMake: Targets
With modern cmake, though, a fleet of target-oriented tools are now at our disposal, and we can describe private, public and interface relationships with them.

One would expect to be able to describe the requirements of a 3rd party or out-of-tree shared object as a library:

```cmake
ADD_LIBRARY(
  OutOfTreeFmod
  SHARED IMPORT
)
SET_TARGET_PROPERTIES(
  OutOfTreeFmod
  IMPORTED_IMPLIB "${FMOD_PATH}/lib/fmod.lib"
  IMPORTED_LOCATION "${FMOD_PATH}/lib/fmod.dll"
)
INSTALL(
  TARGETS OutOfTreeFmod
  RUNTIME_DEPENDENCIES
)
```

and several "target_link_libraries" downstream, to simply be able to say:

```cmake
ADD_EXECUTABLE(
  AppName
  app.c
)
TARGET_LINK_LIBRARIES(
  AppName
  some_intree_dependency  # links OutOfTreeFmod
)
INSTALL(
  TARGETS AppName
  RUNTIME_DEPENDENCIES
  RUNTIME DESTINATION "${CMAKE_INSTALL_PATH}/bin"
)
```

# Beyond just install though

For most of us, we need those runtimes to be copied alongside the build artifacts - e.g on windows the .exe files.

```
# from the cmake --build
^/project/build/src/appname/appname.exe 
^/project/build/src/appname/fmod.dll

# from cmake --install
~/bin/appname.exe
~/bin/fmod.dll
```

