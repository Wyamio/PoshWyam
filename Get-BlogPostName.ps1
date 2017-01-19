function Get-BlogPostName {
    [CmdletBinding()]
    param (
        $Title
    )
    
    begin {
    }
    
    process {
        $name = $Title -replace '\s+','-'
        $name = $name.ToLower()
        $invalid = [System.IO.Path]::GetInvalidFileNameChars()
        $regex = "[$([Regex]::Escape($invalid))]"
        "${name}.md"
    }
    
    end {
    }
}