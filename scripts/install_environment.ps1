param(
  [string]$CourseRoot = "",
  [string]$RHome = "E:\R-4.4.2",
  [string]$CondaEnv = "seuratv5-course-py",
  [switch]$InstallRPackages,
  [switch]$InstallPythonEnv,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$SkillRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Write-Step {
  param([string]$Message)
  Write-Host ""
  Write-Host "==> $Message"
}

function Resolve-CourseRoot {
  param([string]$InputPath)
  if ($InputPath -and (Test-Path -LiteralPath $InputPath)) {
    return (Resolve-Path -LiteralPath $InputPath).Path
  }

  $candidates = @()
  if (Test-Path -LiteralPath "F:\") {
    $candidates += Get-ChildItem -LiteralPath "F:\" -Directory -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -like "0000-*" } |
      ForEach-Object {
        Get-ChildItem -LiteralPath $_.FullName -Recurse -File -Filter "monocle_xxdchange.tar.gz" -ErrorAction SilentlyContinue |
          ForEach-Object { Split-Path -Parent (Split-Path -Parent $_.FullName) }
      }
  }

  if ($candidates.Count -gt 0) {
    return $candidates[0]
  }

  return ""
}

function Add-UserPathEntry {
  param([string]$PathEntry)
  if (-not $PathEntry -or -not (Test-Path -LiteralPath $PathEntry)) {
    Write-Host "Skip missing PATH entry: $PathEntry"
    return
  }

  $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if (-not $currentUserPath) { $currentUserPath = "" }
  $parts = $currentUserPath -split ";" | Where-Object { $_ -ne "" }
  $trimChars = [char[]]@("\", "/")
  $alreadyPresent = $parts | Where-Object { $_.TrimEnd($trimChars) -ieq $PathEntry.TrimEnd($trimChars) }

  if (-not $alreadyPresent) {
    $newPath = if ($currentUserPath) { "$PathEntry;$currentUserPath" } else { $PathEntry }
    if ($DryRun) {
      Write-Host "[DryRun] Add to user PATH: $PathEntry"
    } else {
      [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
      Write-Host "Added to user PATH: $PathEntry"
    }
  } else {
    Write-Host "PATH already contains: $PathEntry"
  }

  $envParts = $env:Path -split ";" | Where-Object { $_ -ne "" }
  $envAlready = $envParts | Where-Object { $_.TrimEnd($trimChars) -ieq $PathEntry.TrimEnd($trimChars) }
  if (-not $envAlready) {
    $env:Path = "$PathEntry;$env:Path"
  }
}

function Invoke-Script {
  param([string]$File, [string[]]$Arguments)
  $display = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$File`" $($Arguments -join ' ')"
  if ($DryRun) {
    Write-Host "[DryRun] $display"
    return
  }
  & powershell -NoProfile -ExecutionPolicy Bypass -File $File @Arguments
}

$CourseRoot = Resolve-CourseRoot -InputPath $CourseRoot
if ($CourseRoot) {
  Write-Host "Course root: $CourseRoot"
} else {
  Write-Warning "Course root was not found. Pass -CourseRoot explicitly when installing local course archives."
}

Write-Step "Adding runtime directories to PATH"
Add-UserPathEntry -PathEntry (Join-Path $RHome "bin")

foreach ($root in @("E:\rtools44", "C:\rtools44")) {
  Add-UserPathEntry -PathEntry (Join-Path $root "usr\bin")
  Add-UserPathEntry -PathEntry (Join-Path $root "x86_64-w64-mingw32.static.posix\bin")
}

Add-UserPathEntry -PathEntry "C:\Program Files\Git\usr\bin"
Add-UserPathEntry -PathEntry "C:\ProgramData\miniconda3"
Add-UserPathEntry -PathEntry "C:\ProgramData\miniconda3\Scripts"
Add-UserPathEntry -PathEntry "C:\ProgramData\miniconda3\condabin"

foreach ($jags in @(
  "C:\Program Files\JAGS\JAGS-4.3.1\x64\bin",
  "C:\Program Files\JAGS\JAGS-4.3.1\bin"
)) {
  Add-UserPathEntry -PathEntry $jags
}

if ($InstallPythonEnv) {
  Write-Step "Installing Python environment"
  $args = @("-CondaEnv", $CondaEnv)
  if ($DryRun) { $args += "-DryRun" }
  Invoke-Script -File (Join-Path $SkillRoot "scripts\install_python_env.ps1") -Arguments $args
}

if ($InstallRPackages) {
  Write-Step "Installing R packages"
  $rscript = Join-Path $RHome "bin\Rscript.exe"
  if (-not (Test-Path -LiteralPath $rscript)) {
    $rscriptCmd = Get-Command Rscript -ErrorAction SilentlyContinue
    if ($rscriptCmd) {
      $rscript = $rscriptCmd.Source
    }
  }
  if (-not (Test-Path -LiteralPath $rscript)) {
    throw "Rscript was not found. Check -RHome or add Rscript to PATH."
  }
  $rArgs = @((Join-Path $SkillRoot "scripts\install_r_packages.R"))
  if ($CourseRoot) {
    $rArgs += "--course-root"
    $rArgs += $CourseRoot
  }
  if ($DryRun) {
    Write-Host "[DryRun] `"$rscript`" $($rArgs -join ' ')"
  } else {
    & $rscript @rArgs
  }
}

Write-Step "Checking environment"
$checkArgs = @("-Rscript", (Join-Path $RHome "bin\Rscript.exe"), "-CondaEnv", $CondaEnv)
if ($CourseRoot) {
  $checkArgs += "-CourseRoot"
  $checkArgs += $CourseRoot
}
Invoke-Script -File (Join-Path $SkillRoot "scripts\check_environment.ps1") -Arguments $checkArgs

Write-Host ""
Write-Host "Environment setup command completed. Open a new terminal so the updated user PATH is fully applied."
