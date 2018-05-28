properties {
    $Develop = [bool]::Parse($(if ($dev) { $dev } else { 'false' }))
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
        if (Test-Path 'output/PoshWyam') {
            Get-ChildItem -Path 'output/PoshWyam' -Exclude 'Wyam','lib' | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "Cleaning '.\output\'."
        if (Test-Path 'output') {
            Get-ChildItem -Path 'output' | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Task Build -Depends Clean {
    [void](New-Item -Path 'output' -ItemType Directory -ErrorAction SilentlyContinue)
    Write-Host "Copying script files."
    [void](Copy-Item -Path 'PoshWyam' -Destination 'output' -Recurse -Force)

    #EnsureModule -Name 'PSScriptAnalyzer'
    #Write-Host "Analyzing scripts."
    #$violations = Invoke-ScriptAnalyzer -Path "$PSScriptRoot/output/PoshWyam"
    #if (@($violations).Count -gt 0) {
    #    $violations
    #    throw "Script analysis failed."
    #}

    if (-not $Develop) {
        EnsureNuGet -Name 'Wyam' -Destination 'output/PoshWyam'
        EnsureNuGet -Name 'YamlDotNet'
        $lib = Get-ChildItem -Include 'netstandard*' -Path 'output/YamlDotNet/lib' -Recurse | Select-Object -First 1
        if (-not (Test-Path $lib)) {
            throw "Unable to locate YamlDotNet binaries."
        }
        [void](New-Item -Name 'lib' -Path 'output/PoshWyam' -ItemType Directory -ErrorAction SilentlyContinue)
        try {
            [void](Copy-Item -Path (Join-Path $lib '*') 'output/PoshWyam/lib' -ErrorAction SilentlyContinue)
        } catch {
        }
    }
}

Task Test -Depends Build {
    if (-not (Get-Command Invoke-Pester)) {
        throw "Pester is not installed."
    }
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

    $tools = Join-Path $PSScriptRoot 'tools'
    $nuget = Join-Path $tools 'nuget.exe'
    if (-not (Test-Path $nuget)) {
        Write-Host "Installing NuGet.exe"
        try {
            if (-not (Test-Path $tools)) {
                [void](New-Item -ItemType Directory -Path $tools)
            }
            (New-Object System.Net.WebClient).DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe", $nuget)
        } catch {
            Throw "Could not download NuGet.exe."
        }
    }
    $nuget = Resolve-Path $nuget
    Write-Verbose "Using '$nuget'."

    Write-Host "Installing $Name."
    & "$nuget" install $Name -Prerelease -ExcludeVersion -OutputDirectory $Destination
}
