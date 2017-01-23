function Publish-BlogDraft {
    [CmdletBinding(DefaultParameterSetName='Title')]
    param(
        [Parameter(ParameterSetName='Title', Position=0, Mandatory=$True)]
        $Title,
        
        [Parameter(ParameterSetName='Path', ValueFromPipelineByPropertyName=$True, Mandatory=$True)]
        [string[]]
        $Path
    )
    
    begin {
    }
    
    process {
        if ($PsCmdlet.ParameterSetName -eq 'Title') {
            Get-BlogPost -Title $Title -ErrorAction Stop | Where-Object { $_.Draft } | Publish-BlogDraft
        } else {
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

Export-ModuleMember -Function Publish-BlogDraft