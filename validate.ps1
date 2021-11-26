## Checks that the build tree makes sense.

# Stop on any failing command
$ErrorActionPreference = "stop"

function Find-ProgramDll {
  Param(
    [Parameter(Mandatory)] [String] $InPath
  )

  # Look for 'program.exe' in path so we can test if the .dll is
  # alongside of it.
  $exes = dir -r $InPath Program.exe
  if ($exes.length -eq 0) {
    throw "No executables found in the '${InPath}'"
  } elseif ($exes -is [system.array]) {
    throw "Multiple Program.exes found in ${InPath}. (git clean -dfx ?)"
  }

  echo "++ Found Program.exe in ${InPath}"

  $expectDll = Join-Path $exes.directory "DLL.dll"
  if (! (Test-Path $expectDll)) {
    throw "DLL was NOT found in ${InPath} (expected $expectDll)"
  }
  echo "++ DLL found in ${InPath}"
}

Find-ProgramDll "./build"
Find-ProgramDll "./Artifacts"

# Lastly, try and run the program.
echo "++ Attempting to run ./Artifacts/Program.exe"
if (! (./Artifacts/Program.exe)) {
  throw "Execution failed"
}
