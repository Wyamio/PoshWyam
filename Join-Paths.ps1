function Join-Paths {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string[]]
        $Path,

        [Parameter(Position = 1)]
        [string[]]
        $ChildPath,

        [switch]
        $Resolve
    )
    
    begin {
    }
    
    process {
        $Path | % {
            $p = $_
            $ChildPath | % {
                $p = Join-Path $p $_
            }
            if ($Resolve -and -not (Test-Path $p)) {
                throw "Cannot find path '$p' because it does not exist."
            }
            $p
        }
    }
    
    end {
    }
}
