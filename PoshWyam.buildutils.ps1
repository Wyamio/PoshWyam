function EnsureModule($ModuleName, [System.Version]$Version) {
    $module = Get-Module $ModuleName
    if (-not $module) {
        Import-Module $ModuleName -ErrorAction SilentlyContinue
        $module = Get-Module $ModuleName
    }
    if ($module.Version -lt $Version) {
        if ($module) {
            Write-Host "Attempting to update ${ModuleName}..."
            Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue
            Update-Module $ModuleName -ErrorAction SilentlyContinue
            Import-Module $ModuleName -Force
            $module = Get-Module $ModuleName
        }
    }
    if ($module.Version -lt $Version) {
        Write-Host "Attempting to install ${ModuleName}..."
        Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue
        Install-Module $ModuleName -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction Stop
        Import-Module $ModuleName
        $module = Get-Module $ModuleName
    }
    if ($module.Version -lt $Version) {
        throw "Cannot import module $ModuleName ($Version)"
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
        $Destination = $Artifacts
    }

    $tools = Join-Path $PSScriptRoot 'tools'
    $nuget = Join-Path $tools 'nuget.exe'
    if (-not (Test-Path $nuget)) {
        Write-Host "Installing NuGet.exe..."
        try {
            [void](New-Item -ItemType Directory -Path $tools -Force)
            (New-Object System.Net.WebClient).DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe", $nuget)
        } catch {
            Throw "Could not download NuGet.exe."
        }
    }

    $nuget = Resolve-Path $nuget
    Write-Verbose "Using '$nuget'."

    Write-Host "Installing $Name..."
    & "$nuget" install $Name -Prerelease -ExcludeVersion -OutputDirectory $Destination
}
