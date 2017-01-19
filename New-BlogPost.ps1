<#
.SYNOPSIS
    Creates a new blog post.
.DESCIPTION
    Creates a new blog post.
#>
function New-BlogPost {
    [CmdletBinding()]
    param (
        # The blog post title.
        [Parameter(Position=0, Mandatory=$True)]
        [string]
        $Title,
        
        # The tags to include in the blog post.
        [Parameter(Position=1, Mandatory=$False)]
        [string[]]
        $Tag = @(),

        # The Wyam project root.
        $Root = (Get-WyamRoot),

        # Post a draft instead.
        [switch]
        $Draft
    )
    
    begin {
    }
    
    process {
        $parms = @{ 'Root' = $Root }
        $posts = Get-BlogPostsLocation @parms
        $path = Join-Path $posts (Get-BlogPostName $Title)
        Write-Verbose $path
        $content = @"
---
Title: "${Title}"
Published: $(Get-Date)
Tags: [$(($Tag | % { """$_""" }) -join ', ')]
---

# ${Title}
"@
        Set-Content -Path $path -Value $content
    }
    
    end {
    }
}

Export-ModuleMember -Function New-BlogPost