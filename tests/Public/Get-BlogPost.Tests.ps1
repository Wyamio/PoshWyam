Import-Module "$Artifacts\PoshWyam\PoshWyam.psd1" -Force

$published = [DateTime]("$(Get-Date)") # Format/Parse round trip may not be exact
$published = $published - [TimeSpan]::FromDays(2)
$post = "TestDrive:\input\posts\test-post.md"

Describe "Get-BlogPost" {
    BeforeAll {
        # Setup minimal amount of directory structure to test
        [void](New-Item -Path "TestDrive:\config.wyam" -ItemType File)
        [void](New-Item -Path $post -ItemType File -Force)
        Set-Content -Path $post -Value @"
---
Title: Test Post
Published: $published
Tags:
  - Tag1
  - Tag2
Custom: 1
---
#Test Post

Lorem ipsum.
"@
        $draft = "TestDrive:\drafts\another-post.md"
        [void](New-Item -Path $draft -ItemType File -Force)
        Set-Content -Path $draft -Value @"
---
Title: Another Post
Published: $($published - [TimeSpan]::FromDays(1))
Tags:
  - Tag1
  - Tag3
---
#Another Post

Lorem ipsum.
"@
        Push-Location "TestDrive:\"
    }
    AfterAll {
        Pop-Location
    }
    Context "no arguments" {
        It "returns correct number of posts" {
            $result = Get-BlogPost

            @($result).Count | Should be 2
        }
        It "returns items in Published order" {
            $result = Get-BlogPost

            @($result | ForEach-Object { $_.Draft }) | Should be @($True, $False)
        }
    }
    Context "with -Title" {
        It "returns correct posts" {
            $result = Get-BlogPost -Title "Test Post"

            @($result | ForEach-Object { $_.Draft }) | Should be @($False)
        }
    }
    Context "with positional parameter" {
        It "returns correct posts" {
            $result = Get-BlogPost "Test Post"

            @($result | ForEach-Object { $_.Draft }) | Should be @($False)
        }
    }
    Context "with wildcards in -Title" {
        It "returns correct posts" {
            $result = Get-BlogPost "Another *"

            ($result | ForEach-Object { $_.Draft }) | Should be @($True)
        }
    }
    Context "with -StartDate" {
        It "returns correct posts" {
            $result = Get-BlogPost -StartDate $published

            ($result | ForEach-Object { $_.Draft }) | Should be @($False)
        }
    }
    Context "with -EndDate" {
        It "returns correct posts" {
            $result = Get-BlogPost -EndDate ($published - [TimeSpan]::FromDays(1))

            ($result | ForEach-Object { $_.Draft }) | Should be @($True)
        }
    }
}