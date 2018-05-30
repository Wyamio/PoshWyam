function Quote {
    param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True)]
        [string[]]$text
    )

    process {
        $text | ForEach-Object {
            if ($_ -match '\s') {
                "`"$_`""
            }
            else {
                $_
            }
        }
    }
}
