function Install-Wyam {
    [CmdletBinding()]
    param (
        $Root = (Get-WyamRoot)
    )
    
    begin {
        $tools = Join-Path $Root "tools"
        $nuget = Join-Path $tools "nuget.exe"
        $nugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        $wyam = Join-Paths $tools "wyam","tools","wyam.exe"
    }
    
    process {
        # Make sure tools folder exists
        if (-not (Test-Path $tools)) {
            Write-Verbose -Message "Creating tools directory..."
            [void](New-Item -Path $tools -Type Directory)
        }

        # Try find NuGet.exe in path if not exists
        if (-not (Test-Path $nuget)) {
            Write-Verbose -Message "Trying to find nuget.exe in PATH..."
            $existingPaths = $Env:Path -Split ';' | Where-Object { (-not [string]::IsNullOrEmpty($_)) -and (Test-Path $_ -PathType Container) }
            $found = Get-ChildItem -Path $existingPaths -Filter "nuget.exe" | Select-Object -First 1
            if ($found -ne $null -and (Test-Path $found.FullName)) {
                Write-Verbose -Message "Found in PATH at $($found.FullName)."
                $nuget = $found.FullName
            }
        }

        # Try download NuGet.exe if not exists
        if (!(Test-Path $nuget)) {
            Write-Verbose -Message "Downloading nuget.exe..."
            try {
                (New-Object System.Net.WebClient).DownloadFile($nugetUrl, $nuget)
            } catch {
                throw "Could not download nuget.exe."
            }
        }

        if (-not (Test-Path $wyam)) {
            Write-Verbose -Message "Restoring Wyam from NuGet..."
            $NuGetOutput = Invoke-Expression "&`"$nuget`" install Wyam -Prerelease -ExcludeVersion -OutputDirectory `"$tools`""
        }
    }
    
    end {
    }
}