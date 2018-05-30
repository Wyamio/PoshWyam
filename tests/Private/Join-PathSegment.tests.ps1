Import-Module "$Artifacts\PoshWyam\PoshWyam.psd1" -Force

InModuleScope PoshWyam {
    Describe "Join-PathSegment" {
        Context "with -Path 'C:\' -ChildPath 'foo'" {
            It "joins segments" {
                $result = Join-PathSegment -Path 'C:\' -ChildPath 'foo'

                $result | Should be 'C:\foo'
            }
        }
        Context "with -Path 'C:\dir1','C:\dir2' -ChildPath 'foo'" {
            It "joins segments for each path" {
                $result = Join-PathSegment -Path 'C:\dir1','C:\dir2' -ChildPath 'foo'

                $result | Should be @('C:\dir1\foo', 'C:\dir2\foo')
            }
        }
        Context "with -Path 'C:\' -ChildPath 'foo','bar'" {
            It "joins segments" {
                $result = Join-PathSegment -Path 'C:\' -ChildPath 'foo','bar'

                $result | Should be 'C:\foo\bar'
            }
        }
        Context "with -Path 'TestDrive:\' -ChildPath 'foo' -Resolve" {
            It "fails to resolve" {
                $resolved = $true
                try {
                    Join-PathSegment -Path 'TestDrive:\' -ChildPath 'foo' -Resolve
                } catch {
                    $resolved = $false
                }

                $resolved | Should be $false
            }
        }
    }
}
