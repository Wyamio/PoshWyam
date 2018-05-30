$ModuleRoot = $PSScriptRoot

$public = @(Get-ChildItem -Path $ModuleRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$private = @(Get-ChildItem -Path $ModuleRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
foreach ($import in @($public + $private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import script $($import.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName