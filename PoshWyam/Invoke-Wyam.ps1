<#
.SYNOPSIS
    Invokes wyam.exe from the tools directory of the project.
.DESCRIPTION
    Invokes wyam.exe from the tools directory of the project.
#>
function Invoke-Wyam {
    [CmdletBinding(DefaultParameterSetName='Build')]
    param (
        [Parameter(ParameterSetName='Preview', Mandatory=$false, Position=0)]
        [Parameter(ParameterSetName='Build', Mandatory=$false, Position=0)]
        [string]$Path,

        [Parameter(ParameterSetName='Preview', Mandatory=$true)]
        [switch]$Preview,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [int]$Port = 5080,

        [Parameter(ParameterSetName='Preview')]
        [switch]$Watch,

        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='Build')]
        [switch]$Attach,

        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='Build')]
        [switch]$ForceExtensions,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$VirtualDirectory,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$PreviewRoot,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$InputPath,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$OutputPath,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$ConfigurationPath,

        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='Build')]
        [switch]$UpdatePackages,

        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='Build')]
        [switch]$UseLocalPackages,

        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='Build')]
        [switch]$UseGlobalSources,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$PackagesPath,

        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='Build')]
        [switch]$OutputScript,

        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='Build')]
        [switch]$VerifyConfig,

        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='Build')]
        [switch]$NoClean,

        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='Build')]
        [switch]$NoCache,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$LogFilePath,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$GlobalMetadata,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$InitialMetadata,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$NuGetSource,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$Recipe,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$Assembly,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$Theme,

        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$NuGetPackage,

        # The arguments to pass to wyam.exe.
        [Parameter(Position=1, ParameterSetName='Args')]
        [string[]]$Arguments
    )
    
    begin {
        if ($PSCmdlet.ParameterSetName -in @('Preview','Build')) {
            $Arguments = @()
            if ($Preview) {
                $Arguments += "-p $Port"
            }
            if ($Watch) {
                $Arguments += '-w'
            }
            if ($Attach) {
                $Arguments += '--attach'
            }
            if ($ForceExtensions) {
                $Arguments += '--force-ext'
            }
            if ($PSBoundParameters.ContainsKey('VirtualDirectory')) {
                $Arguments += @('--virtual-dir', $VirtualDirectory)
            }
            if ($PSBoundParameters.ContainsKey('PreviewRoot')) {
                $Arguments += @('--preview-root', $PreviewRoot)
            }
            if ($PSBoundParameters.ContainsKey('InputPath')) {
                $Arguments += @('-i', $InputPath)
            }
            if ($PSBoundParameters.ContainsKey('OutputPath')) {
                $Arguments += @('-o', $OutputPath)
            }
            if ($PSBoundParameters.ContainsKey('ConfigurationPath')) {
                $Arguments += @('-c', $ConfigurationPath)
            }
            if ($UpdatePackages) {
                $Arguments += '-u'
            }
            if ($UseLocalPackages) {
                $Arguments += '--use-local-packages'
            }
            if ($UseGlobalSources) {
                $Arguments += '--use-global-sources'
            }
            if ($PSBoundParameters.ContainsKey('PackagesPath')) {
                $Arguments += @('--packages-path', $PackagesPath)
            }
            if ($OutputScript) {
                $Arguments += '--output-script'
            }
            if ($VerifyConfig) {
                $Arguments += '--verify-config'
            }
            if ($NoClean) {
                $Arguments += '--noclean'
            }
            if ($NoClean) {
                $Arguments += '--nocache'
            }
            if ($PSBoundParameters.ContainsKey('LogFilePath')) {
                $Arguments += @('-l', $LogFilePath)
            }
            if ($PSBoundParameters.ContainsKey('GlobalMetadata')) {
                $Arguments += @('-g', $GlobalMetadata)
            }
            if ($PSBoundParameters.ContainsKey('InitialMetadata')) {
                $Arguments += @('--initial', $InitialMetadata)
            }
            if ($PSBoundParameters.ContainsKey('NuGetSource')) {
                $Arguments += @('--ns', $NuGetSource)
            }
            if ($PSBoundParameters.ContainsKey('Recipe')) {
                $Arguments += @('-r', $Recipe)
            }
            if ($PSBoundParameters.ContainsKey('Assembly')) {
                $Arguments += @('-a', $Assembly)
            }
            if ($PSBoundParameters.ContainsKey('Theme')) {
                $Arguments += @('-t', $Theme)
            }
            if ($PSBoundParameters.ContainsKey('NuGetPackage')) {
                $Arguments += @('-n', $NuGetPackage)
            }
            if ($PSBoundParameters.ContainsKey('Path')) {
                $Arguments += $Path
            }
        }
        if ([System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference) {
            $Arguments += '--verbose'
        }
        Write-Verbose 'Invoke-Wyam: Finding tool.'
        try {
            $root = Get-WyamRoot
        } catch {
        }
        if (-not $root) {
            $root = Join-Path $ModuleRoot 'Wyam'
        }
        $tools = Join-Path $Root 'tools'
        $wyam = Resolve-Path (Join-PathSegment $tools 'wyam','tools','wyam.exe')
        Write-Verbose "Invoke-Wyam: Tool located at '$wyam'"
        $quoted = $Arguments | ForEach-Object {
            if ($_ -contains '\s') {
                "`"$_`""
            }
            else {
                $_
            }
        }
        $Arguments = ($quoted) -join ' '
    }
    
    process {
        if (-not (Test-Path $wyam)) {
            Install-Wyam -Root $root
        }

        $expr = "&`"$wyam`" $Arguments"
        Write-Verbose "Invoke-Wyam: Running command '$expr'"
        Invoke-Expression $expr
    }
    
    end {
        if ($temp) {
            Remove-Item -Path $temp -Recurse -Force
        }
    }
}
