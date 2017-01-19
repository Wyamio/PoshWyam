<#
.SYNOPSIS
    Invokes wyam.exe from the tools directory of the project.
.DESCRIPTION
    Invokes wyam.exe from the tools directory of the project.
#>
function Invoke-Wyam {
    [CmdletBinding()]
    param (
        # The arguments to pass to wyam.exe.
        [parameter(Position=1,ValueFromRemainingArguments=$True)]
        $Arguments
    )
    
    begin {
        $root = Get-WyamRoot
        $tools = Join-Path $Root "tools"
        $wyam = Join-Paths $tools "wyam","tools","wyam.exe"
        $Arguments = ($Arguments | % {
            if ($_ -contains "\s") {
                "`"$_`""
            } else {
                $_
            }
        }) -join ' '
    }
    
    process {
        if (-not (Test-Path $wyam)) {
            Install-Wyam
        }

        Write-Verbose $Arguments
        $expr = "&`"$wyam`" $Arguments"
        Write-Verbose $expr
        Invoke-Expression $expr
    }
    
    end {
    }
}

Export-ModuleMember -Function Invoke-Wyam