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
        $Root = (Get-WyamRoot)
    )
    
    begin {
    }
    
    process {
        Resolve-Path (Join-Paths $Root input,posts)
    }
    
    end {
    }
}

Export-ModuleMember -Function Get-BlogPostsLocation