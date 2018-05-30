function ConvertFrom-Yaml {
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]$Yaml
    )
    process {
        if ($Yaml) {
            $stringReader = New-Object System.IO.StringReader($Yaml)
            try {
                $deserializer = [YamlDotNet.Serialization.Deserializer]::new()
                $yamlObject = $deserializer.Deserialize($stringReader);
                $serializer = [YamlDotNet.Serialization.Serializer]::new('JsonCompatible')
                $stringBuilder = [System.Text.StringBuilder]::new()
                $stringWriter = [System.IO.StringWriter]::new($stringBuilder)
                $serializer.Serialize($stringWriter, $yamlObject)
                $json = $stringBuilder.ToString()
                Write-Verbose $json
                $json | ConvertFrom-Json
            } finally {
                $stringReader.Close()
            }
        }
    }
}
