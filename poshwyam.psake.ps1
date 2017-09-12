properties {
    $Develop = [bool]::Parse($dev)
}

FormatTaskName @"
----------------------------------------------------------------------
Executing {0}
----------------------------------------------------------------------
"@

Task default -Depends Test

Task Clean {
    if ($Develop) {
        Write-Host "Cleaning '.\output\PoshWyam\'."
        Get-ChildItem -Path 'output/PoshWyam' -Exclude 'Wyam','lib' | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Cleaning '.\output\'."
        Get-ChildItem -Path 'output' | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Task Build -Depends Clean {
    Write-Host "Copying script files."
    [void](Copy-Item -Path 'PoshWyam' -Destination 'output' -Recurse -Force)

    EnsureModule -Name 'PSScriptAnalyzer'
    Write-Host "Analyzing scripts."
    #$violations = Invoke-ScriptAnalyzer -Path "$PSScriptRoot/output/PoshWyam"
    #if (@($violations).Count -gt 0) {
    #    $violations
    #    throw "Script analysis failed."
    #}

    if (-not $Develop) {
        EnsureNuGet -Name 'Wyam' -Destination 'output/PoshWyam'

        EnsureNuGet -Name 'YamlDotNet'
        $lib = Get-ChildItem -Include 'portable*' -Path 'output/YamlDotNet/lib' -Recurse
        [void](New-Item -Name 'lib' -Path 'output/PoshWyam' -ItemType Directory -ErrorAction SilentlyContinue)
        [void](Copy-Item -Path (Join-Path $lib '*') 'output/PoshWyam/lib' -ErrorAction SilentlyContinue)
    }
}

Task Test -Depends Build {
    EnsureModule 'Pester'
    Push-Location 'output/PoshWyam'
    try {
        Invoke-Pester
    } finally {
        Pop-Location
    }
}

Task Install -Depends Build {
    Write-Host "Installing to $InstallDir"
    if ((-not $InstallDir) -or (-not (Test-Path $InstallDir))) {
        throw "InstallDir unspecified or destination does not exist"
    }
    if (Test-Path "$InstallDir/PoshWhyam") {
        Remove-Item -Path "$InstallDir/PoshWyam" -Recurse -Force
    }
    Copy-Item -Path "$PSScriptRoot/output/PoshWyam/*" -Destination "$InstallDir/PoshWyam" -Force -Recurse
}

function EnsureModule {
    [CmdletBinding()]
    param(
        [string]$Name
    )

    Write-Host "Finding $Name."
    $module = Get-Module -Name $Name
    if (-not $module) {
        $module = Get-ChildItem -Include "$Name.psd1" -Path "$PSScriptRoot/output" -Recurse | Select-Object -First 1
        if (-not $module) {
            Write-Host "Installing $Name."
            Save-Module -Name $Name -Path "output" -ErrorAction SilentlyContinue
            $module = Get-ChildItem -Include "$Name.psd1" -Path "$PSScriptRoot/output" -Recurse | Select-Object -First 1
            if (-not $module) {
                throw "Unable to bootstrap $Name."
            }
        }
        Write-Host "Importing $Name."
        Import-Module $module
    }
}

function EnsureNuGet {
    [CmdletBinding()]
    param(
        [string]$Name,

        [Parameter(Mandatory = $False)]
        [string]$Destination
    )

    if (-not $PSBoundParameters.ContainsKey('Destination')) {
        $Destination = "output"
    }

    Write-Host "Finding NuGet.exe."
    $nuget = Join-Path (Join-Path $PSScriptRoot 'tools') 'nuget.exe'
    if (-not (Test-Path $nuget)) {
        $nuget = (Get-Command -Name 'nuget.exe' -ErrorAction SilentlyContinue).Source
        if (-not $nuget) {
            Write-Host "Installing NuGet.exe"
            $nuget = Join-Path (Join-Path $PSScriptRoot 'tools') 'nuget.exe'
            try {
                (New-Object System.Net.WebClient).DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe", $nuget)
            } catch {
                Throw "Could not download NuGet.exe."
            }
        }
    }
    $nuget = Resolve-Path $nuget
    Write-Host "Using '$nuget'."

    Write-Host "Installing $Name."
    & "$nuget" install $Name -Prerelease -ExcludeVersion -OutputDirectory $Destination
}
