Function Test-Any {
    [CmdletBinding()]
    param(
        [ScriptBlock]
        $Filter,

        [Parameter(ValueFromPipeline = $true)]
        $InputObject
    )

    process {
        if (-not $Filter -or (Foreach-Object $Filter -InputObject $InputObject)) {
            $true # Signal that at least 1 [matching] object was found

            # Now that we have our result, stop the upstream commands in the
            # pipeline so that they don't create more, no-longer-needed input.
            (Add-Type -Passthru -TypeDefinition '
                using System.Management.Automation;
                namespace net.same2u.PowerShell {
                    public static class CustomPipelineStopper {
                        public static void Stop(Cmdlet cmdlet) {
                            throw (System.Exception) System.Activator.CreateInstance(typeof(Cmdlet).Assembly.GetType("System.Management.Automation.StopUpstreamCommandsException"), cmdlet);
                        }
                    }
                }')::Stop($PSCmdlet)
        }
    }

    end {
         $false
    }
}