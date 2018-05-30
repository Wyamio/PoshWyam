<#
.SYNOPSIS
    Invokes wyam.exe from the tools directory of the project.
.DESCRIPTION
    Invokes wyam.exe from the tools directory of the project.
#>
function Invoke-Wyam {
    [CmdletBinding(DefaultParameterSetName='Build')]
    param (
        [Parameter(ParameterSetName='Preview', Mandatory=$true)]
        [switch]$PreviewOnly,

        [Parameter(ParameterSetName='New', Mandatory=$true)]
        [switch]$New,

        # The folder (or config file) to use.
        [Parameter(ParameterSetName='Build', Mandatory=$false, Position=0)]
        [Parameter(ParameterSetName='Preview', Mandatory=$false, Position=0)]
        [string]$Path,

        # Start the preview web server.
        [Parameter(ParameterSetName='Build')]
        [switch]$Preview,

        # The port to use for the preview web server.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [int]$Port = 5080,

        # Watches the input folder for any changes.
        [Parameter(ParameterSetName='Build')]
        [switch]$Watch,

        # Pause execution at the start of the program until a debugger is attached.
        [Parameter(ParameterSetName='Build')]
        [Parameter(ParameterSetName='Preview')]
        [Parameter(ParameterSetName='New')]
        [switch]$Attach,

        # Force the use of extensions in the preview web server (by default extensionless URLs may be used).
        [Parameter(ParameterSetName='Build')]
        [Parameter(ParameterSetName='Preview')]
        [switch]$ForceExtensions,

        # Serve files in the preview web server under the specified virtual directory.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [Parameter(ParameterSetName='Preview', Mandatory=$false)]
        [string]$VirtualDirectory,

        # The path to the root of the preview server, if not the output folder.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$PreviewRoot,

        # The path(s) of input files, can be absolute or relative to the current folder.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [Parameter(ParameterSetName='New', Mandatory=$false)]
        [string[]]$InputPath,

        # The path to the output files, can be absolute or relative to the current folder.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$OutputPath,

        # The path to the configuration file (by default, config.wyam is used).
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [Parameter(ParameterSetName='New', Mandatory=$false)]
        [string]$ConfigurationPath,

        # Check the NuGet server for more recent versions of each package and update them if applicable.
        [Parameter(ParameterSetName='Build')]
        [Parameter(ParameterSetName='New')]
        [switch]$UpdatePackages,

        # Toggles the use of a local NuGet packages folder.
        [Parameter(ParameterSetName='Build')]
        [Parameter(ParameterSetName='New')]
        [switch]$UseLocalPackages,

        # Toggles the use of the global NuGet sources (default is false).
        [Parameter(ParameterSetName='Build')]
        [Parameter(ParameterSetName='New')]
        [switch]$UseGlobalSources,

        # The packages path to use (only if use-local is true).
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [Parameter(ParameterSetName='New', Mandatory=$false)]
        [string]$PackagesPath,

        # Outputs the config script after it's been processed for further debugging.
        [Parameter(ParameterSetName='Build')]
        [switch]$OutputScript,

        # Compile the configuration but do not execute.
        [Parameter(ParameterSetName='Build')]
        [switch]$VerifyConfig,

        # Prevents cleaning of the output path on each execution.
        [Parameter(ParameterSetName='Build')]
        [switch]$NoClean,

        # Prevents caching information during execution (less memory usage but slower execution).
        [Parameter(ParameterSetName='Build')]
        [switch]$NoCache,

        # Log all trace messages to the specified log file.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$LogFilePath,

        # Specifies settings to use.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [hashtable]$Setting,

        # Specifies an additional package source to use.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [Parameter(ParameterSetName='New', Mandatory=$false)]
        [string[]]$NuGetSource,

        # Specifies a recipe to use.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [Parameter(ParameterSetName='New', Mandatory=$false)]
        [string]$Recipe,

        # Adds an assembly reference by name, file name, or globbing pattern.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [Parameter(ParameterSetName='New', Mandatory=$false)]
        [string[]]$Assembly,

        # Specifies a theme to use.
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [string]$Theme,

        # Adds a NuGet package (downloading and installing it if needed).
        [Parameter(ParameterSetName='Build', Mandatory=$false)]
        [Parameter(ParameterSetName='New', Mandatory=$false)]
        [string[]]$NuGetPackage,

        # The arguments to pass to wyam.exe.
        [Parameter(Position=1, ParameterSetName='Args')]
        [string[]]$Arguments
    )

    begin {
        if ($PSCmdlet.ParameterSetName -ne 'Args') {
            $Arguments = @()
            switch ($PSCmdlet.ParameterSetName) {
                'Build' {
                    $Arguments += 'build'
                }
                'Preview' {
                    $Arguments += 'preview'
                }
                'New' {
                    $Arguments += 'new'
                }
            }
            if ($Preview) {
                $Arguments += '-p'
                if ($PSBoundParameters.ContainsKey('Port')) {
                    $Arguments += $Port
                }
            }
            if ($PreviewOnly -and $PSBoundParameters.ContainsKey('Port')) {
                $Arguments += @('-p', $Port)
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
                $InputPath | ForEach-Object {
                    $Arguments += @('-i', $_ | Quote)
                }
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
            if ($PSBoundParameters.ContainsKey('Setting')) {
                $Setting.GetEnumerator() | ForEach-Object {
                    $Arguments += @('-s', "$($_.Key | Quote)=$($_.Value | Quote)")
                }
            }
            if ($PSBoundParameters.ContainsKey('NuGetSource')) {
                $NuGetSource | ForEach-Object {
                    $Arguments += @('--ns', $_ | Quote)
                }
            }
            if ($PSBoundParameters.ContainsKey('Recipe')) {
                $Arguments += @('-r', $Recipe)
            }
            if ($PSBoundParameters.ContainsKey('Assembly')) {
                $Assembly | ForEach-Object {
                    $Arguments += @('-a', $_ | Quote)
                }
            }
            if ($PSBoundParameters.ContainsKey('Theme')) {
                $Arguments += @('-t', $Theme)
            }
            if ($PSBoundParameters.ContainsKey('NuGetPackage')) {
                $NuGetPackage | ForEach-Object {
                    $Arguments += @('-n', $_ | Quote)
                }
            }
            if ($PSBoundParameters.ContainsKey('Path')) {
                $Arguments += $Path
            }
        }
        if ([System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference) {
            $Arguments += '-v'
        }
        Write-Verbose 'Invoke-Wyam: Finding tool.'
        try {
            $root = Join-Path (Get-WyamRoot) 'tools'
        } catch {
        }
        if (-not $root -or -not (Test-Path $root)) {
            $root = Join-Path $ModuleRoot 'Wyam'
        }
        $wyam = Get-ChildItem -Path $root -Include wyam.exe -Recurse | Select-Object -First 1
        $wyam = Resolve-Path $wyam
        Write-Verbose "Invoke-Wyam: Tool located at '$wyam'"
        $Arguments = ($Arguments | Quote) -join ' '
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
    }
}
