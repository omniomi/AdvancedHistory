function ClearMenu {
    [cmdletbinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
    param (
        [int]$Top,
        [int]$Size
    )
    $TrueTop = $Top - 3
    for ($i = 1 ; $i -le $Size; $i++) {
        [System.Console]::SetCursorPosition(0, $TrueTop + $i)
        [System.Console]::Write(' ' * $Host.UI.RawUI.WindowSize.Width)
    }
    [System.Console]::SetCursorPosition(0, $TrueTop)
}