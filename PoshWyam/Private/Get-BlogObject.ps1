function Get-BlogObject {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "yaml")]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [Alias('FullName')]
        [string[]]
        $Path,

        [switch]
        $Draft
    )
    
    begin {
    }
    
    process {
        $Path | ForEach-Object {
            $post = Resolve-Path $_ -ErrorAction Stop
            $props = @{
                'Path' = $post.Path
                'Name' = Split-Path $post -Leaf
                'Draft' = $Draft
            }
            $content = Get-Content $post
            $yaml = ''
            $firstLine = $true
            $inFrontMatter = $true
            $content | ForEach-Object {
                if ($inFrontMatter) {
                    $line = $_.Trim()
                    if ($line.Length -gt 0 -and $line -eq ('-' * $line.Length)) {
                        if (-not $firstLine) {
                            $inFrontMatter = $false
                        }
                    }
                    else {
                        $yaml += $line + [System.Environment]::NewLine
                    }
                    $firstLine = $false
                }
            }
            $frontMatter = $yaml | ConvertFrom-Yaml
            $frontMatter.Tags = @($frontMatter.Tags)
            $props['Title'] = $frontMatter.Title
            $props['Published'] = [DateTime]($frontMatter.Published)
            $props['Tags'] = $frontMatter.Tags
            $props.Add('FrontMatter', $frontMatter)
            $post = New-Object -TypeName PSObject -Property $props
            $post.PSObject.TypeNames.Insert(0, 'PoshWyam.BlogPost')
            $post
        }
    }
    
    end {
    }
}
