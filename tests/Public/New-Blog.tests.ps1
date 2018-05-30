Import-Module "$Artifacts\PoshWyam\PoshWyam.psd1" -Force

Describe "New-Blog" {
    Context "In current directory" {
        It "Creates blog" {
            Push-Location "TestDrive:\"
            try {
                New-Blog -Title 'Example Blog' -Host 'https://example.com'

                cp TestDrive:\example-blog "$Artifacts\test"

                Test-Path "TestDrive:\example-blog" | Should be $true
                Test-Path "TestDrive:\example-blog\config.wyam" | Should be $true
                Test-Path "TestDrive:\example-blog\drafts" | Should be $true
                Test-Path "TestDrive:\example-blog\input\about.md" | Should be $true
                Test-Path "TestDrive:\example-blog\input\posts\first-post.md" | Should be $true
            }
            finally {
                Pop-Location
            }
        }
    }
}