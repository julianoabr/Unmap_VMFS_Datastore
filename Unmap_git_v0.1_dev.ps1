#Requires -RunAsAdministrator
#Requires -Version 5.1

<#
.Synopsis
   Do unmap on Datastores before version 6
.DESCRIPTION
   Do unmap on Datastores versions 3 to 5. Schedule a task on Windows to Run It
.EXAMPLE
   Alter lines 284 to 305 to Unmap on different days
.EXAMPLE
   Another example of how to use this cmdlet
.SOURCE
   Based on KB https://kb.vmware.com/s/article/2057513
   Encrypt Password on Powershell (using AES KEY) https://www.altaro.com/msp-dojo/encrypt-password-powershell/
.CREATOR
   Juliano Alves de Brito Ribeiro (find me at julianoalvesbr@live.com or https://github.com/julianoabr)
.VERSION
   0.1
.ENVIRONMENT
   Production
#>


Clear-Host

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -WebOperationTimeoutSeconds -1 -Scope AllUsers -Confirm:$false -Verbose

#VALIDATE IF OPTION IS NUMERIC
function isNumeric ($x) {
    $x2 = 0
    $isNum = [System.Int32]::TryParse($x, [ref]$x2)
    return $isNum
} #end function is Numeric


#FUNCTION CONNECT TO VCENTER
function Connect-TovCenterServer
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet('Manual','Automatic')]
        $methodToConnect = 'Manual',
        
                      
        [Parameter(Mandatory=$false,
                   Position=1)]
        [System.String[]]$vCenterServers, 
                
       
        [Parameter(Mandatory=$false,
                   Position=2)]
        [ValidateSet('80','443')]
        [System.String]$port = '443',

        [Parameter(Mandatory=$false,
                   Position=3)]
        [System.String]$userName = 'domain\user'

    )

    #Set up path and user variables (CHANGE ACCORDING TO YOUR ENVIRONMENT)
    $AESKeyFilePath = "$env:systemdrive\path1\PWD\ENCRYPT\aeskey.txt" # location of the AESKey                
    
    $SecurePwdFilePath = "$env:systemdrive\patsh1\PROCESS\PWD\ENCRYPT\credpassword.txt" # location of the file that hosts the encrypted password                
    
    $userUPN = $userName # User account login 

    #use key and password to create local secure password 
    #IF YOU ARE IN A DOMAIN ENVIRONMENT AES KEY IS NOT NECESSARY
    $AESKey = Get-Content -Path $AESKeyFilePath 
    
    $pwdTxt = Get-Content -Path $SecurePwdFilePath
    
    $securePass = $pwdTxt | ConvertTo-SecureString -Key $AESKey

    #crete a new psCredential object with required username and password
    $vCenterCred = New-Object System.Management.Automation.PSCredential($userUPN, $securePass)

    
    #VALIDATE MODULE
    $moduleExists = Get-Module -Name Vmware.VimAutomation.Core

    if ($moduleExists){
    
        Write-Output "The Module Vmware.VimAutomation.Core is already loaded"
    
    }#if validate module
    else{
    
        Import-Module -Name Vmware.VimAutomation.Core -WarningAction SilentlyContinue -ErrorAction Stop
    
    }#else validate module

       

    if ($methodToConnect -like 'Automatic'){
        
        foreach ($vCenterServer in $vCenterServers){
        
            $Script:workingServer = $vCenterServer

            $vCentersConnected = $global:DefaultVIServers.Count

            if ($vCentersConnected -eq 0){
            
                Write-Host "You are not connected to any vCenter" -ForegroundColor DarkGreen -BackgroundColor White
            
            }#validate connected vCenters
            else{
            
                Disconnect-VIServer -Server * -Confirm:$false -Force -Verbose -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            
            }#validate if you are connected to some vCenter
        
        
        }#end of Foreach

    }#end of If Method to Connect
    else{
        
        $vCentersConnected = $global:DefaultVIServers.Count

        if ($vCentersConnected -eq 0){
            
            Write-Host "You are not connected to any vCenter" -ForegroundColor DarkGreen -BackgroundColor White
            
        }#validate connected vCenters
        else{
            
            Disconnect-VIServer -Server * -Confirm:$false -Force -Verbose -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            
         }#validate connected vCenters
        
        $workingLocationNum = ""
        
        $tmpWorkingLocationNum = ""
        
        $Script:WorkingServer = ""
        
        $i = 0

        #MENU SELECT VCENTER
        foreach ($vCenterServer in $vCenterServers){
	   
                $vcServerValue = $vCenterServer
	    
                Write-Output "            [$i].- $vcServerValue ";	
	            $i++	
                }#end foreach	
                Write-Output "            [$i].- Exit this script ";

                while(!(isNumeric($tmpWorkingLocationNum)) ){
	                $tmpWorkingLocationNum = Read-Host "Type vCenter Number that you want to connect"
                }#end of while

                    $workingLocationNum = ($tmpWorkingLocationNum / 1)

                if(($WorkingLocationNum -ge 0) -and ($WorkingLocationNum -le ($i-1))  ){
	                $Script:WorkingServer = $vcServers[$WorkingLocationNum]
                }
                else{
            
                    Write-Host "Exit selected, or Invalid choice number. End of Script " -ForegroundColor Red -BackgroundColor White
            
                    Exit;
                }#end of else

       
      
    }#end of Else Method to Connect

     foreach ($vCenterServer in $vCenterServers){

     #Connect to Vcenter
     $Script:vcInfo = Connect-VIServer -Server $Script:WorkingServer -Port $port -WarningAction Continue -ErrorAction Stop -Credential $vCenterCred
     
     Write-Host "You are connected to vCenter: $Script:WorkingServer" -ForegroundColor White -BackGroundColor DarkMagenta

     }
    


}#End of Function Connect to Vcenter


#VMFS UNMAP
function Perform-VMFSUnmap 
{
    [CmdletBinding()]
    Param
    (
        # Param help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.String[]]$dsName, 
        
         
        [Parameter(Mandatory=$false,
                   Position=1)]
        [System.String]$dsNAA,

        [Parameter(Mandatory=$false,
                   Position=2)]
        [System.String]$esxiHostName
                
  
    )

    $esxiHost = Get-VMHost -Name $esxiHostName
    
    Write-Host "Using ESXCLI to connect to ESXi: $esxiHostName" -ForegroundColor Green
    
    $ds = Get-Datastore -Name $dsName

    $esxcli = Get-EsxCli -VMHost $esxiHost -V2

    $dsESXi = $esxcli.storage.core.device.list.Invoke() | Where-Object {$_.Device -eq $dsNAA}
        
    $arguments = $esxcli.storage.vmfs.unmap.CreateArgs()

    $arguments.volumelabel = $dsName
    
    if ($dsESXi.ThinProvisioningStatus -eq 'yes'){
    
        #https://kb.vmware.com/s/article/2057513
        $dsBlockSize = $ds.ExtensionData.Info.Vmfs.BlockSizeMB

        if ($dsBlockSize -eq 1)
        {
           $arguments.reclaimunit="200"

           Write-host "Reclaim Unit = 200 MB for 1 MB block VMFS3 / VMFS5" -ForegroundColor DarkGreen -BackgroundColor White

        }
        elseif ($dsblockSize -eq 4)
        {
        
            $arguments.reclaimunit="800" 

            Write-host "Reclaim Unit = 800 MB for 4 MB block VMFS3" -ForegroundColor DarkGreen -BackgroundColor White

        }else{
    
           $arguments.reclaimunit="1600" 

           Write-host "Reclaim Unit = 1600 MB for 8 MB block VMFS3" -ForegroundColor DarkGreen -BackgroundColor White
    
        }

        Write-Host "Unmapping Datastore: $dsName on ESXi: $esxiHostName" -ForegroundColor Green

        $esxcli.storage.vmfs.unmap.Invoke($arguments)

        Write-Host "Unmapped completed on Datastore: $dsName. Runned on ESXi: $esxiHostName" -ForegroundColor Green
       
    
    }#end of if lun thin
    else{
    
        Write-Host "Datastore: $dsName is not a LUN Thin provisioned. I can't run UNMAP on that" -ForegroundColor Red -BackgroundColor White
        
        
    }#end of else lun thin   

}#end of function


#DEFINE VCENTER LIST
$vcServerList = @();

#ADD OR REMOVE VCs        
$vcServerList = ('vC1','vC2','vC3','vC4','vC5') | Sort-Object

$dayToRun = (get-date -Format "dd").ToString()

#$dayToRun = 19 #TEST ONLY
 
switch ($dayToRun)
{
    {($_ -eq 1) -or ($_ -eq 15)} {
        
        $vcServer = 'vC1'

    }
    {($_ -eq 2) -or ($_ -eq 16)} {
    
        $vcServer = 'vC2'
    
    }
    {($_ -eq 3) -or ($_ -eq 17)} {
    
        $vcServer = 'vC3'
    
    }
    {($_ -eq 4) -or ($_ -eq 18)} {
    
        $vcServer = 'vC4'
    
    }
    {($_ -eq 5) -or ($_ -eq 19)} {
    
       $vcServer = 'vC5'
    
    }
    Default {
    
        Write-Host "Today is not a day to run UNMAP"
    
    }

}

#CALL FUNCTION
Connect-ToVcenterServer -methodToConnect Automatic -vCenterServers $vcServer -port 443

#CREATE VARIABLES
$dsListName = @()

$esxiHostList = @()

$dsListName = Get-Datastore | Where-Object -FilterScript {($_.ExtensionData.Summary.MultipleHostAccess) -and ($_.FileSystemVersion -lt 6) -and ($_.Type -eq 'VMFS')} | Select-Object -ExpandProperty Name | Sort-Object

[System.Int32]$counter = 0

[System.String]$esxiHostName = ""

[System.String]$esxiHName = ""

foreach ($dsName in $dsListName){
  
    $tmpDsCanonicalName = Get-Datastore -Name $dsName | Select-Object -Property @{N='CanonicalName';E={$_.ExtensionData.Info.Vmfs.Extent[0].DiskName}}

    $dsCanonicalName = $tmpDsCanonicalName.CanonicalName

    $dsName = Get-Datastore | Where-Object -FilterScript {$_.ExtensionData.Info.Vmfs.Extent.DiskName -eq $dsCanonicalName} | Select-Object -ExpandProperty Name

    $esxiHostList = Get-VMHost -Datastore $dsName | Select-Object -ExpandProperty Name | Sort-Object -Verbose
  
    $esxiHName = Get-Random -InputObject $esxiHostList

    Write-Host "ESXi to run: $esxiHName" -ForegroundColor White -BackgroundColor DarkMagenta
    
    #CALL FUNCTION UNMAP    
    Perform-VMFSUnmap -dsName $dsName -dsNAA $dsCanonicalName -esxiHostName $esxiHName
    
}#end of foreach

Clear-Host

#end of script
