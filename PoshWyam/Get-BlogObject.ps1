function Get-BlogObject {
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
            $content | ForEach-Object {
                $line = $_
                if ($line -imatch "\s*title:(.*)") {
                    $props.Add('Title', $Matches[1].Trim("`t `""))
                } elseif ($line -imatch "\s*published:(.*)") {
                    $props.Add('Published', [DateTime]($Matches[1].Trim("`t `"")))
                } elseif ($line -imatch "\s*tags:(.*)") {
                    $props.Add('Tags', @($Matches[1].Trim("`t []") -split ',' | ForEach-Object { $_.Trim("`t `"") }))
                }
            }
            $post = New-Object -TypeName PSObject -Property $props
            $post.PSObject.TypeNames.Insert(0, 'PoshWyam.BlogPost')
            $post
        }
    }
    
    end {
    }
}
