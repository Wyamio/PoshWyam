Import-Module "$Artifacts\PoshWyam\PoshWyam.psd1" -Force

InModuleScope PoshWyam {
    $published = [DateTime]("$(Get-Date)") # Format/Parse round trip may not be exact
    $post = "TestDrive:\test-post.md"

    Describe "Get-BlogObject" {
        BeforeAll {

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
        }
        It "returns a valid PoshWyam.BlogPost" {
            $result = Get-BlogObject -Path $post

            $result.PSObject.TypeNames[0] | Should be PoshWyam.BlogPost
        }
        It "has correct Path" {
            $result = Get-BlogObject -Path $post

            $result.Path | Should be $post
        }
        It "has correct Name" {
            $result = Get-BlogObject -Path $post

            $result.Name | Should be "test-post.md"
        }
        It "should not be marked as Draft" {
            $result = Get-BlogObject -Path $post

            $result.Draft | Should be $False
        }
        It "should be marked as Draft if -Draft indicated" {
            $result = Get-BlogObject -Path $post -Draft

            $result.Draft | Should be $True
        }
        It "has correct Title" {
            $result = Get-BlogObject -Path $post

            $result.Title | Should be "Test Post"
        }
        It "has correct Published" {
            $result = Get-BlogObject -Path $post

            $result.Published | Should be $published
        }
        It "has correct Tags" {
            $result = Get-BlogObject -Path $post

            $result.Tags | Should be @("Tag1", "Tag2")
        }
        It "should include other properties in FrontMatter" {
            $result = Get-BlogObject -Path $post

            $result.FrontMatter.Custom | Should be 1
        }
    }
}
