$invalidPostNameChars = [RegEx]::Escape([System.IO.Path]::GetInvalidFileNameChars() + @(' ',"`t","`n"))

function Get-BlogPostName {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        $Title
    )
    
    begin {
    }
    
    process {
        $name = $Title -replace "[$invalidPostNameChars]",'-'
        "$($name.ToLower()).md"
    }
    
    end {
    }
}
