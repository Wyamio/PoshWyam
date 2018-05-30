Import-Module "$Artifacts\PoshWyam\PoshWyam.psd1" -Force

InModuleScope PoshWyam {
    Describe "Get-FileName" {
        Context "simple title" {
            It "gives simple name in lower case" {
                $result = Get-FileName -Title "Simple"

                $result | Should be "simple"
            }
        }
        Context "illegal file characters" {
            It "replaces with hyphen" {
                $result = Get-FileName -Title "Illegal`\Character"

                $result | Should be "illegal-character"
            }
        }
        Context "spaces" {
            It "replaces with hyphen" {
                $result = Get-FileName -Title "With Spaces"

                $result | Should be "with-spaces"
            }
        }
        Context "extension" {
            It "gives name with extension" {
                $result = Get-FileName -Title "Simple" -Extension ".md"

                $result | Should be "simple.md"
            }
        }
    }
}
