function Join-PathSegment {
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
        $Path | ForEach-Object {
            $p = $_
            $ChildPath | ForEach-Object {
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
