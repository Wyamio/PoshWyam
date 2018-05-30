$invalidPostNameChars = [RegEx]::Escape([System.IO.Path]::GetInvalidFileNameChars() + @(' ', "`t", "`n"))

function Get-FileName {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        $Title,

        [Parameter(Mandatory=$false)]
        $Extension
    )

    begin {
    }

    process {
        $name = $Title -replace "[$invalidPostNameChars]", '-'
        "$($name.ToLower())$Extension"
    }

    end {
    }
}
