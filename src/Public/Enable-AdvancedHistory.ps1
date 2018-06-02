function Enable-AdvancedHistory {
    [cmdletbinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    param(
        [parameter()]
        [Alias('Key')]
        [string]$Shortcut = 'F7',

        [parameter()]
        [switch]$Unique
    )

    if (-not (Test-Path (Get-PSReadlineOption).HistorySavePath)) {
        $Exception     = New-Object System.ArgumentException ($LocalizedData.ErrHistorySavePath)
        $ErrorCategory = [System.Management.Automation.ErrorCategory]::ObjectNotFound
        $ErrorRecord   = New-Object System.Management.Automation.ErrorRecord($Exception, $LocalizedData.ErrHistorySavePathId, $ErrorCategory, (Get-PSReadlineOption).HistorySavePath)
        $PSCmdlet.ThrowTerminatingError($ErrorRecord)
    }

    if ($Global:HistoryCountOverride) {
        $Script:HistorySize = $Global:HistoryCountOverride
    } else {
        $Script:HistorySize = 256
    }

    try {
        <#
            This is adapted from an example created by Jeff Hicks which used Out-GridView for a similar effect but using a popout window.
            https://www.petri.com/more-efficient-powershell-with-psreadline
        #>
        Set-PSReadlineKeyHandler -Key $Shortcut -BriefDescription AdvancedHistory -Description "Show keyboard navigable history." -ScriptBlock {
            $Filter = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Filter, [ref]$null)
            if ($Filter) {
                $Filter = [regex]::Escape($Filter)
            }
            $History = [System.Collections.ArrayList]@(
                $Last = ''
                $Lines = ''
                foreach ($Line in [System.IO.File]::ReadLines((Get-PSReadlineOption).HistorySavePath)) {
                    if ($Line.EndsWith('`')) {
                        $Line = $Line.Substring(0, $Line.Length - 1)
                        $Lines = if ($Lines) {
                            "$Lines`n$Line"
                        }
                        else {
                            $Line
                        }
                        continue
                    }

                    if ($Lines) {
                        $Line = "$Lines`n$Line"
                        $Lines = ''
                    }

                    if (($Line -cne $Last) -and (!$Filter -or ($Line -match $Filter))) {
                        $Last = $Line
                        $Line
                    }
                }
            )
            $History.Reverse()
            if ($Unique) {
                $X = WriteMenu -Title $LocalizedData.Title -Entries ($History.ToArray() | Select-Object -Unique | Select-Object -First $Script:HistorySize)
            } else {
                $X = WriteMenu -Title $LocalizedData.Title -Entries ($History.ToArray() | Select-Object -First $Script:HistorySize)
            }
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($X -join "`n"))
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}