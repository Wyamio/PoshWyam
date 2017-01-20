<#
.SYNOPSIS
    Gets the Wyam project root location.
.DESCRIPTION
    Gets the Wyam project root location by recursively searching up from the current location for the Wyam configuration file.
#>
function Get-WyamRoot {
    [CmdletBinding()]
    param (
        # Specifies the name of the Wyam config file to search for. Default value is "config.wyam".
        $Config = "config.wyam"
    )
    
    begin {
    }
    
    process {
        $path = Get-Location
        while ($path) {
            Write-Verbose $path
            if (Test-Path (Join-Path $path $Config)) {
                return $path
            }
            $path = Split-Path -Path $path -Parent
        }
        throw 'Not in a Wyam project.'
    }
    
    end {
    }
}

Export-ModuleMember -Function Get-WyamRoot
