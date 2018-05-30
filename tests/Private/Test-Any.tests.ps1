Import-Module "$Artifacts\PoshWyam\PoshWyam.psd1" -Force

InModuleScope PoshWyam {
    Describe "Test-Any" {
        Context "with -Filter { `$_ -gt 10 } -InputObject @(1, 5, 10, 15, 20)" {
            It "returns true" {
                $result = Test-Any -Filter { $_ -gt 10 } -InputObject @(1, 5, 10, 15, 20)

                $result | Should be $true
            }
        }
        Context "with -Filter { `$_ -gt 20 } -InputObject @(1, 5, 10, 15, 20)" {
            It "returns false" {
                $result = Test-Any -Filter { $_ -gt 20 } -InputObject @(1, 5, 10, 15, 20)

                $result | Should be $false
            }
        }
    }
}
