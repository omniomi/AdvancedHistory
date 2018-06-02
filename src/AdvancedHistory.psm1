# -------------------------- Load Localization ----------------------------
#
Data LocalizedData {
    # culture="en-US"
    ConvertFrom-StringData @'
'@
}
Microsoft.PowerShell.Utility\Import-LocalizedData LocalizedData -FileName AdvancedHistory.Localization.psd1 -ErrorAction SilentlyContinue

# -------------------------- Load Script Files ----------------------------
#
# Do not add Export-ModuleMember logic. All functions in .\Public are added to the manifest during build.
# If you need to import from \src\ run the build.ps1 in \tools\ with 'ExportFunctionsToSrc' as the task.
#
$ModuleScriptFiles = @(Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 -Recurse  | Where-Object { $_.Name -notlike "*.ps1xml" } )

foreach ($ScriptFile in $ModuleScriptFiles) {
    try {
       Write-Verbose "$($LocalizedData.VerboseLoadingScript -f $ScriptFile.Name)"
        . $ScriptFile.FullName
    }
    catch {
       Write-Error "$($LocalizedData.ErrorLoadingScript -f $ScriptFile.FullName)"
    }
}