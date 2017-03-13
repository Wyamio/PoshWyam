<#
.SYNOPSIS
    Creates a new blog post.
.DESCIPTION
    Creates a new blog post.
#>
function New-BlogPost {
    [CmdletBinding(SupportsShouldProcess = $True)]
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
        # Get directory
        $parms = @{ 'Root' = $Root }
        if ($Draft) {
            $parms['Draft'] = $True
        }
        $posts = Get-BlogPostsLocation @parms

        # Get path to post to create
        $path = Join-Path $posts (Get-BlogPostName $Title)

        # Create post
        $content = @"
---
Title: "${Title}"
Published: $(Get-Date)
Tags: [$(($Tag | ForEach-Object { """$_""" }) -join ', ')]
---

# ${Title}
"@
        Set-Content -Path $path -Value $content
        Resolve-Path $path
    }
    
    end {
    }
}
