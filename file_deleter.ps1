<#
Author: Ryan Stone
Last Revision: 06/08/2022

Reads list of hostnames from file
Iterates through the hostnames and deletes specified file from each PC

TODO: User inputs location of files
TODO: Log hostname instead of path when Remove-Item fails
#>

# Strings
$HostsFilePath = "C:\Users\flagr\Desktop\PS_File_Deleter\hosts.txt"
$TargetFilePath = "\c\temp\test.txt"
$LogFilePath  = "C:\Users\flagr\Desktop\PS_File_Deleter\deleter.log"

# Function to get the hostnames from the file.
function Get-Targets {
    param (
        [string]$FileName
    )

    $Targets = [System.Collections.ArrayList]::new()
    foreach($Line in [System.IO.File]::ReadLines($FileName)) {
        [void]$Targets.Add($Line)  # [void] suppresses output
    }

    $Targets
}

# Function to create the path from a hostname
function Set-TargetPath {
    param (
        [string]$TargetComputerName
    )

    $TargetPathBuilder = [System.Text.StringBuilder]::new()
    [void]$TargetPathBuilder.Append("\\")
    [void]$TargetPathBuilder.Append($TargetComputerName)
    [void]$TargetPathBuilder.Append($TargetFilePath)
    
    $TargetPathBuilder.ToString()
}

# Function to delete each file. Saves path to log file if unsuccessful.
function DeleteFilesFromTargets {
    param (
        [string[]]$TargetPaths  # Array of strings
    )

    foreach($TargetPath in $TargetPaths) {
        try {
            Remove-Item $TargetPath -ErrorAction Stop
        }
        catch {
            Add-Content -Path $LogFilePath -Value $TargetPath
        }
    }
}

# $_ is current object in pipeline.
$Paths = (Get-Targets -FileName $HostsFilePath | ForEach-Object {Set-TargetPath -TargetComputerName $_})
DeleteFilesFromTargets -TargetPaths $Paths
