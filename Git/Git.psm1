Import-Module PSCompletion
. $PSScriptRoot\branch.ps1



<#
 .Synopsis
    Get the git log
 .DESCRIPTION
    Long description
 .EXAMPLE
    Example of how to use this cmdlet
 .EXAMPLE
    Another example of how to use this cmdlet
 #>
 function Get-GitLog
 {
     [CmdletBinding()]
     [OutputType([string])]
     Param
     (
         # Param1 help description
         [Parameter()]
         [switch]$Graph,
 
         # Param2 help description
         [Switch] $MergesOnly
     )
    
     
     Process
     {
        $gitArgs = @()
        if ($Graph){
            $gitArgs += "--graph"
        }
        if ($Graph){
            $gitArgs += "--merges"
        }
        git log $gitArgs
     }
     
 }




Set-Alias ggl  Get-GitLog
