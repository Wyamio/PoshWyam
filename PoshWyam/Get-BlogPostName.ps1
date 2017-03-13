function Get-FileName {
    [CmdletBinding()]
    [OutputType([string])]
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
        $name -replace $regex,'-'
    }
    
    end {
    }
}

function Get-BlogPostName {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        $Title
    )
    
    begin {
    }
    
    process {
        "$(Get-FileName $Title).md"
    }
    
    end {
    }
}
