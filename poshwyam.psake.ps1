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
        Get-ChildItem -Path 'output/PoshWyam' -Exclude 'Wyam','lib' | Remove-Item -Recurse -Force
    } else {
        Write-Host "Cleaning '.\output\'."
        Get-ChildItem -Path 'output' | Remove-Item -Recurse -Force
    }
}

Task Build -Depends Clean {
    Write-Host "Copying script files."
    [void](Copy-Item -Path 'PoshWyam' -Destination 'output' -Recurse -Force)

    EnsureModule -Name 'PSScriptAnalyzer'
    Write-Host "Analyzing scripts."
    $violations = Invoke-ScriptAnalyzer -Path 'output/PoshWyam'
    if (@($violations).Count -gt 0) {
        $violations
        throw "Script analysis failed."
    }

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

Task Import -Depends Build {
    import-module '.\output\PoshWyam\PoshWyam.psd1' -Force
}

function EnsureModule {
    [CmdletBinding()]
    param(
        [string]$Name
    )

    Write-Host "Finding $Name."
    $module = Get-Module -Name $Name
    if (-not $module) {
        $module = Get-ChildItem -Include "$Name.psd1" -Path "output" -Recurse | Select-Object -First 1
        if (-not $module) {
            Write-Host "Installing $Name."
            Save-Module -Name $Name -Path "output"
            $module = Get-ChildItem -Include "$Name.psd1" -Path "output" -Recurse | Select-Object -First 1
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

    Write-Host "$Develop"
    Write-Host "Finding NuGet.exe."
    $nuget = Join-Path 'tools' 'nuget.exe'
    if (-not (Test-Path $nuget)) {
        $nuget = (Get-Command -Name 'nuget.exe' -ErrorAction SilentlyContinue).Source
        if (-not $nuget) {
            Write-Host "Installing NuGet.exe"
            $nuget = Join-Path 'tools' 'nuget.exe'
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
