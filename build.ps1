[CmdletBinding()]
Param(
    [Parameter(Position=0, Mandatory=$False)]
    [ValidateSet("Clean", "Build", "Test", "Install")]
    [string[]]$TaskList,
    [string]$InstallDir,
    [switch]$Develop
)

Push-Location $PSScriptRoot
try {
    if (-not (Test-Path 'tools')) {
        [void](New-Item -Name 'tools' -ItemType Directory)
    }

    $psake = Get-ChildItem -Include psake.psd1 -Path 'tools' -Recurse
    if ((-not $psake) -or (-not (Test-Path $psake))) {
        Save-Module -Name Psake -Path 'tools'
        $psake = Get-ChildItem -Include psake.psd1 -Path 'tools' -Recurse
        if (-not (Test-Path $psake)) {
            throw 'Unable to bootstrap Psake'
        }
    }
    Import-Module $psake -Force

    $params = $PSBoundParameters + @{ 'BuildFile' = 'poshwyam.psake.ps1'; 'ErrorAction' = 'Stop'; 'Parameters' = @{ 'dev' = "$Develop"; 'InstallDir' = "$InstallDir" } }
    $params.Remove('Develop')
    $params.Remove('InstallDir')
    Invoke-Psake @params
} finally {
    Pop-Location
}
