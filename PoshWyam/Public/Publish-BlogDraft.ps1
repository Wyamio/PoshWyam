<#
.SYNOPSIS
    Publishes a draft post.

.DESCRIPTION
    Publishes a draft post by moving it to the posts folder and updating the Published date.
#>
function Publish-BlogDraft {
    [CmdletBinding(DefaultParameterSetName='Title')]
    param(
        # The Title of the draft post to publish.
        [Parameter(ParameterSetName='Title', Position=0, Mandatory=$True)]
        $Title,
        
        # The path to the draft post to publish.
        [Parameter(ParameterSetName='Path', ValueFromPipelineByPropertyName=$True, Mandatory=$True)]
        [string[]]
        $Path
    )
    
    begin {
    }
    
    process {
        if ($PsCmdlet.ParameterSetName -eq 'Title') {
            Get-BlogPost -Title $Title -ErrorAction Stop | Where-Object { $_.Draft } | Publish-BlogDraft
        }
        else {
            $Path | ForEach-Object {
                $post = $_
                $post = Resolve-Path $post -ErrorAction Stop
                $posts = Get-BlogPostsLocation
                Get-Content $post | ForEach-Object {
                    $_ -replace '\s*published:.*',"Published: $([DateTime]::Now)"
                } | Set-Content (Join-Path $posts (Split-Path -Leaf $post))
                if ((Split-Path $post) -ne $posts) {
                    Remove-Item $post
                }
            }
        }
    }
    
    end {
    }
}
