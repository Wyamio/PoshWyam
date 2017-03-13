pushd $PSScriptRoot
try {
    .\build.ps1
    import-module (Join-Path $PSScriptRoot 'output/poshwyam/poshwyam.psd1') -force
} finally {
    popd
}
