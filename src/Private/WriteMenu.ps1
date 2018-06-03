<#
    Adapted from an early version of https://github.com/QuietusPlus/Write-Menu (MIT License)
    https://gist.github.com/QuietusPlus/59d8612ec13ea929704542eb0bd8d52c (CC-SA-4.0 License)

    Opted for the initial version as it was sufficient for this purpose.
    - Reworked logic for performance.
    - Removed redundancy.
    - Removed Clear-Host executions.
    - Comments and Cleanup.
#>
function WriteMenu {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [array]$Items,

        [Parameter()]
        [string]$Title = $null,

        [Parameter()]
        [int]$Page = 0
    )

    [System.Console]::CursorVisible = $false

    try {
        # Print title when applicable and determine number of lines dedicated to static content.
        if ($Title -ne $null) {
            [System.Console]::WriteLine("`n" + $Title + "`n")
            $AddedLines = 7
        }
        else {
            [System.Console]::WriteLine('')
            $AddedLines = 5
        }
        # Determine available lines for list items.
        $ListSize = ($host.UI.RawUI.WindowSize.Height - $AddedLines)

        # Console colours.
        $Foreground         = [System.Console]::ForegroundColor
        $Background         = [System.Console]::BackgroundColor
        # Invert for selection.
        $ForegroundSelected = $Background
        $BackgroundSelected = $Foreground

        # Number of entries in total.
        $ItemsTotal = $Items.Length

        # First entry of the current page.
        $FirstEntry = ($ListSize * $Page)

        # Total pages
        $PageTotal = [math]::Ceiling((($ItemsTotal - $ListSize) / $ListSize))

        # Handle variable size of the last page.
        if ($Page -eq $PageTotal) {
            $PageEntriesCount = ($ItemsTotal - ($ListSize * $PageTotal))
        }
        else {
            $PageEntriesCount = $ListSize
        }

        # Starting positions for the cursor
        $PositionCurrent  = 0
        $PositionSelected = 0
        $PositionTotal    = 0
        $PositionTop      = [System.Console]::CursorTop

        # Get entries for current page
        $PageEntries = @(foreach ($i in 0..$ListSize) {
            $Items[($FirstEntry + $i)]
        })

        do {
            # Initialize Loop
            $MenuLoop = $true

            # Write menu options
            [System.Console]::CursorTop = ($PositionTop - $PositionTotal)
            for ($PositionCurrent = 0; $PositionCurrent -le ($PageEntriesCount - 1); $PositionCurrent++) {
                [System.Console]::Write("`r")
                # Truncate entry
                $Entry = $PageEntries[$PositionCurrent]
                if ($Entry.Length -gt ($Host.UI.RawUI.WindowSize.Width - 2)) {
                    $Entry = $Entry.Substring(0,($Host.UI.RawUI.WindowSize.Width - 5)) + '...'
                }

                # If selected, invert colours
                if ($PositionCurrent -eq $PositionSelected) {
                    [System.Console]::BackgroundColor = $BackgroundSelected
                    [System.Console]::ForegroundColor = $ForegroundSelected
                    [System.Console]::Write('  ' + $Entry)
                    [System.Console]::BackgroundColor = $Background
                    [System.Console]::ForegroundColor = $Foreground
                } else {
                    [System.Console]::Write('  ' + $Entry)
                }
                [System.Console]::WriteLine('')
            }
            # Write pagination
            [System.Console]::WriteLine("`n $($LocalizedData.Page) $($Page + 1) / $($PageTotal + 1)")

            # Handle key input
            $InputKey = [System.Console]::ReadKey($true)
            if (($InputKey.Key -eq 'DownArrow') -and ($PositionSelected -lt ($PageEntriesCount - 1))) {
                $PositionSelected++
            }
            elseif (($InputKey.Key -eq 'UpArrow') -and ($PositionSelected -gt 0)) {
                $PositionSelected--
            }
            elseif ($InputKey.Key -eq 'Enter' -or $InputKey.Key -eq 'Escape') {
                $MenuLoop = $false
            }
            elseif ($InputKey.Key -eq 'LeftArrow') {
                if ($Page -ne 0) {
                    $Page--
                    $MenuLoop = $false
                }
            }
            elseif ($InputKey.Key -eq 'RightArrow') {
                if ($Page -ne $PageTotal) {
                    $Page++
                    $MenuLoop = $false
                }
            }

        } while ($MenuLoop)

        if ($InputKey.Key -eq 'Escape') {
            ClearMenu $PositionTop ($PageEntriesCount + $AddedLines)
            [System.Console]::CursorVisible = $true
        }
        elseif ($InputKey.Key -eq 'Enter') {
            ClearMenu $PositionTop ($PageEntriesCount + $AddedLines)
            $PageEntries[$PositionSelected]
            [System.Console]::CursorVisible = $true
        }
        elseif (($InputKey.Key -eq 'LeftArrow') -or ($InputKey.Key -eq 'RightArrow')) {
            ClearMenu $PositionTop ($PageEntriesCount + $AddedLines)
            WriteMenu -Items $Items -Page $Page -Title $Title
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    } finally {
        [System.Console]::CursorVisible = $true
    }
}