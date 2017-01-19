<#
.SYNOPSIS
    Creates a new Wyam project for a blog.
.DESCRIPTION
    Scaffolds a new Wyam project for a blog, based on the Blog recipe.
#>
function New-Blog {
    [CmdletBinding()]
    param (
        # The path of the project to create.
        [Parameter(Mandatory = $True)]
        $Path,

        # The host name where the blog will be published to.
        [Parameter(Mandatory = $True)]
        $Host,

        # The blog title.
        [Parameter(Mandatory = $True)]
        $Title,

        # The description of your blog (usually placed on the home page).
        [Parameter(Mandatory = $True)]
        $Description,

        # A short introduction to your blog (usually placed on the home page under the description). 
        [Parameter(Mandatory = $True)]
        $Introduction,

        # The theme to use.
        [Parameter(Mandatory = $False)]
        $Theme = "CleanBlog"
    )
    
    begin {
    }
    
    process {
        if (Test-Path $Path) {
            throw "Path '$Path' already exists."
        }

        $Path = New-Item -Path $Path -ItemType Directory
        $input = New-Item -Path (Join-Path $Path input) -ItemType Directory
        $posts = New-Item -Path (Join-Path $input posts) -ItemType Directory
        Set-Location -Path $Path
        Invoke-WebRequest http://cakebuild.net/download/bootstrapper/windows -OutFile build.ps1
        Set-Content -Path build.ps1 -Value (Get-Content -Path build.ps1 | %{ $_ -replace 'build.cake','wyam.cake' })
        Set-Content -Path wyam.cake -Value (Get-Content -Path (Join-Path $ModuleRoot wyam.cake) | %{ $_ -replace '%THEME%',$Theme })
        $content = @"
Settings.Host = "$Host";
GlobalMetadata["Title"] = "$Title";
GlobalMetadata["Description"] = "$Description";
GlobalMetadata["Intro"] = "$Introduction";
"@
        Set-Content -Path config.wyam -Value $content
        Copy-Item -Path (Join-Path $ModuleRoot about.md) -Destination $input
        New-BlogPost -Title "First Post" -Tag Introduction
    }
    
    end {
    }
}

Export-ModuleMember -Function New-Blog