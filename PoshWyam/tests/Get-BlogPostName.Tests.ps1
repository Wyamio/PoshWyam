$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module "$here\..\PoshWyam.psd1" -Force

Describe "Get-BlogPostName" {
    InModuleScope PoshWyam {
        Context "simple title" {
            It "gives simple name in lower case" {
                $result = Get-BlogPostName -Title "Simple"

                $result | Should be "simple.md"
            }
        }

        Context "illegal file characters" {
            It "replaces with hyphen" {
                $result = Get-BlogPostName -Title "Illegal`\Character"

                $result | Should be "illegal-character.md"
            }
        }

        Context "spaces" {
            It "replaces with hyphen" {
                $result = Get-BlogPostName -Title "With Spaces"

                $result | Should be "with-spaces.md"
            }
        }
    }
}
