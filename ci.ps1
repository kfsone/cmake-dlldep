## Powershell script to build the project.

Param(
  [Parameter(HelpMessage="Specify which cmake configuration to build.")]
  [String] $Configuration = "RelWithDebInfo"
)

# Stop if anything fails.
$ErrorActionPreference = "stop"

# Ensure there are no residual artifacts
git clean -fxd

# The DLL dependency simulating a 3rd party binary
echo  "++ Building DLL"
cmake    -B        ./DLL/build  ./DLL  &&
  cmake  --build   ./DLL/build  --config $Configuration &&
  cmake  --install ./DLL/build  --config $Configuration
if (! $?) { throw "DLL build failed" }

# The main project
echo  "++ Building Program"
cmake    -B        ./build      ./
  cmake  --build   ./build      --config $Configuration &&
  cmake  --install ./build      --config $Configuration
if (! $?) { throw "Program build failed" }

echo  "++ Built"

