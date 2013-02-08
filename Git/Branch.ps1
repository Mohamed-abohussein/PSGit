
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-GitBranch
{
    [CmdletBinding()]    
    Param
    (
        # Param1 help description
        [Parameter()]
        [switch]$All,
        [switch]$Raw
    )
    Begin{
    function BranchDesc([string] $line){
        if (-not ($line -match '(?<current>\*)?\s+(?<BranchName>\S+)')){
            throw "unable to parse '$line'"
        }
        $branchName = $matches.BranchName
        $isRemote = $branchName.StartsWith('remotes/')
        if ($isRemote){
            $branchName = $branchName.Substring(8)
        }
        $obj = [pscustomobject] @{
            BranchName = $branchName
            Current = $line.StartsWith('*')
            Remote=$isRemote            
        }
        $obj.psobject.TypeNames.Insert(0,'Orc.Git.BranchDescription')
        $obj
    }
    }

    End
    {
        if ($all){
            $gitArgs = "-a"
        }
        foreach($b in git branch $gitArgs){
            if ($Raw){
                $b
            }
            else {
                BranchDesc $b       
            }
        }
    }    
}
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Mount-GitRemoteBranch
{
    [CmdletBinding(SupportsShouldProcess)]    
    Param
    (
        # The remote name, for example origin/develop. User Get-GitBranch -All to get remote names
        [Parameter(Mandatory,Position=0)]
        [ValidateScript({$_ -in (Get-GitBranch -All | where Remote -eq $True | Foreach BranchName)})]
        [ValidatePattern("/")]
        [string] $RemoteBranchName,
        # Param1 help description
        [Parameter(Position=1)]
        [string]$LocalName

        
    )
    
    Process
    {
        if (-not $LocalName){
            $LocalName = $RemoteBranchName.Substring($RemoteBranchName.LastIndexOf('/') + 1)
        }
        if ($PSCmdlet.ShouldProcess($RemoteBranchName, "git checkout -b $LocalName")){
            Write-Verbose "git checkout -b $LocalName $RemoteBranchName"
            git checkout -b $LocalName $RemoteBranchName
        }
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Remove-GitBranch
{
    [CmdletBinding()]    
    Param
    (
        # Param1 help description
        [Parameter(Mandatory,Position=0)]
        [string]$BranchName,

        # Param2 help description
        [switch] $Force        
    )

    End
    {
        $GitArgs = "-d"
        if ($Force){
            $GitArgs = "-D"
            
        }
        git branch $GitArgs $BranchName
    }
}


<#
.Synopsis
   Switch to a different git branch
.DESCRIPTION
   Updates files in the working tree to match the version in the index or the specified tree. 
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Switch-GitBranch
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, ValueFromPipelineByPropertyName,Position=0)]
        [string]$BranchName        
    )
    
    Process
    {        
        git checkout $BranchName
    }
    
}


<#
.Synopsis
   Switch to a different git branch
.DESCRIPTION
   Updates files in the working tree to match the version in the index or the specified tree. 
   If no paths are given, git checkout will also update HEAD to set the specified branch as the current branch.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-GitBranch
{
    [CmdletBinding()]    
    Param
    (
        # Param1 help description
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)]
        [string]$BranchName,
        [Parameter(Mandatory,Position=1)]
        [string] $StartPoint    
    )        
    Process
    {
        git checkout -b $BranchName $StartPoint 
    }
    
}


Set-Alias swgb Switch-GitBranch
Set-Alias ggb  Get-GitBranch


Register-ParameterCompleter -CommandName Switch-GitBranch -ParameterName BranchName -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)        
        Get-GitBranch | where Remote -eq $false | where Current -eq $false | where BranchName -like $wordToComplete* | foreach{ 
            $name = $_.BranchName
            New-CompletionResult -CompletionText $name  -ListItemText $name  -ToolTip $name 
        }
    }    

Register-ParameterCompleter -CommandName Mount-GitRemoteBranch -ParameterName RemoteBranchName -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        $localBranches = Get-GitBranch | where Remote -eq $false | where BranchName -like $wordToComplete* | foreach BranchName 
        Get-GitBranch  -All | where Remote -eq $true | foreach{ 
            $name = $_.BranchName
            $subName = $name.SubString($name.LastIndexOf('/')+1)
            if ($subname -notin $localBranches){
                New-CompletionResult -CompletionText $name  -ListItemText $name  -ToolTip $name 
            }
        }
    }    