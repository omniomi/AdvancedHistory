[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateSet('Build','Test','Finish')]
    [string]
    $Task
)

if (-Not($env:APPVEYOR_BUILD_FOLDER)) { throw "This script is intended to be run by Appveyor CI/CD." }

$SrcRootDir = Join-Path (Split-Path -parent $PSScriptRoot) "\src"
$ModuleName = Get-Item $SrcRootDir/*.psd1 |
                      Where-Object { $null -ne (Test-ModuleManifest -Path $_ -ErrorAction SilentlyContinue) } |
                      Select-Object -First 1 | Foreach-Object BaseName

switch ($Task) {
    'Test'   {
        $TestResultsFile = Join-Path $env:APPVEYOR_BUILD_FOLDER "\TestResults.xml"
        $TestDirectory   = Join-Path $env:APPVEYOR_BUILD_FOLDER '\tests\'
        $Result = Invoke-Pester $TestDirectory -OutputFormat NUnitXml -OutputFile $TestResultsFile -PassThru
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path $TestResultsFile))
        if ($Result.FailedCount -gt 0) {
            throw "$($res.FailedCount) tests failed."
        }
    }

    'Build'  {
        $BuildScript = Join-Path $env:APPVEYOR_BUILD_FOLDER '\tools\build.ps1'
        .$BuildScript -Task Build
    }

    'Finish' {
        $ReleaseDirectory = Join-Path $env:APPVEYOR_BUILD_FOLDER "\Release\$ModuleName"
        $ZipFile = Join-Path $env:APPVEYOR_BUILD_FOLDER "$ModuleName.zip"
        Add-Type -assemblyname System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($ReleaseDirectory, $ZipFile)
        Push-AppveyorArtifact $zipFile
    }
}