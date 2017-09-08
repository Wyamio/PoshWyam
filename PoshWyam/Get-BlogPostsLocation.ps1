<#
.SYNOPSIS
    Gets the location of the blog posts.
.DESCRIPTION
    Gets the location of the blog posts. Blog posts are assumed to be in input/posts.
#>
function Get-BlogPostsLocation {
    [CmdletBinding()]
    param (
        # The Wyam project root. If not specified the root is located by searching from the current location up.
        [string]
        $Root = (Get-WyamRoot),

        # Specifies that draft posts should be located instead.
        [switch]
        $Drafts
    )
    
    begin {
    }
    
    process {
        if ($Drafts) {
            Resolve-Path (Join-Path $Root drafts)
        }
        else {
            Resolve-Path (Join-PathSegment $Root input,posts)
        }
    }
    
    end {
    }
}
