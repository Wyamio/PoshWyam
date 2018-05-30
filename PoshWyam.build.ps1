. $PsScriptRoot\PoshWyam.settings.ps1
. $PsScriptRoot\PoshWyam.buildutils.ps1

Task InstallDependencies {
    Write-Host 'Installing dependencies...'
    EnsureModule pester 4.3.1
    EnsureModule PSScriptAnalyzer 1.16.1
}

Task Clean {
    if (Test-Path $Artifacts) {
        Remove-Item "$Artifacts/*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    [void](New-Item $Artifacts -ItemType Directory -Force)
}

Task Analyze InstallDependencies, {
    $scriptAnalyzerParams = @{
        Path = "$PsScriptRoot\PoshWyam"
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    $saResults | ConvertTo-Json | Set-Content (Join-Path $Artifacts "ScriptAnalysisResults.json")

    if ($saResults) {
        $saResults | Format-Table
        throw 'One or more PSScriptAnalyzer errors/warnings were found'
    }
}

Task Stage Clean, {
    [void](New-Item -Path $Artifacts -ItemType Directory -ErrorAction SilentlyContinue)
    Write-Host "Copying script files."
    [void](Copy-Item -Path "$PsScriptRoot\PoshWyam" -Destination $Artifacts -Recurse -Force)

    EnsureNuGet -Name 'Wyam' -Destination "$Artifacts/PoshWyam"
    EnsureNuGet -Name 'YamlDotNet'
    $lib = Get-ChildItem -Include 'netstandard*' -Path "$Artifacts/YamlDotNet/lib" -Recurse | Select-Object -First 1
    if (-not (Test-Path $lib)) {
        throw "Unable to locate YamlDotNet binaries."
    }
    [void](New-Item -Name 'lib' -Path "$Artifacts/PoshWyam" -ItemType Directory -Force -ErrorAction SilentlyContinue)
    try {
        [void](Copy-Item -Path (Join-Path $lib '*') "$Artifacts/PoshWyam/lib" -ErrorAction SilentlyContinue)
    } catch {
    }
}

Task RunTests InstallDependencies, Stage, {
    $invokePesterParams = @{

    }

    $testResults = Invoke-Pester @invokePesterParams

    $testResults | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $Artifacts 'PesterResults.json')
}

Task ConfirmTestsPassed {

}

# Task Archive {
#     $moduleInfo = @{

#     }

#     Publish-ArtifactZip @moduleInfo

#     $nuspecInfo = @{

#     }

#     Publish-NugetPackage @nuspecInfo
# }

# Task Publish {

# }

Task Test RunTests, ConfirmTestsPassed

Task . Clean, Analyze, Stage, Test #, Archive, Publish