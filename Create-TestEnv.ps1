############################################################################################################################################
#.SYNOPSIS
# Used to create several testing VM's at one time.
# 
#.DESCRIPTION
# The Create-TestEnv function creates X number of VM's from a template. It 
# disconnects all your existing virtualcenter connections, connects you to  
# the specified virtualcenter, then creates VM's based on the parameters
# below. No pipeline arguments are accepted. Version 1
#
#.PARAMETER NumVMs
# The number of VMs you wish to deploy. This number must be between 1-100
#
#.PARAMETER VMPrefix
# The name of the VM. The first VM will be created with a random number and all other VMs in this bach will be sequential. 
#
#.PARAMETER Template
# The name of the template to deploy from.
#
#.PARAMETER Datastore
# The datastore where you wish to deploy the VMs
#
#.PARAMETER Cluster
# The cluster where you wish to deploy VMs.
#
#.PARAMETER VCenter
# The virtualcenter where you wish to deploy VMs.
#
#.PARAMETER PowerOn
# This switch tells the commandlet if the VMs should be powered on after being deployed.
#
#.EXAMPLE
# Create-TestEnv -NumVMs 10 -VMPrefix TEST-VM_ -Template Linux_Centos -Datastore vsanDatastore -Cluster LON2_VDI_GOLD -VCenter lon6lbvcsvdi01.markit.partners -PowerOn:$true
#
#############################################################################################################################################

Function Global:Create-TestEnv
{

[CmdletBinding()]
Param
    (
        [parameter(Mandatory=$false)]
        #[ValidateRange(1,101)]
        $NumVMs = 0,
        [parameter(Mandatory=$false)]
        [string]
        $VMPrefix = "Test-VM_",
        [parameter(Mandatory=$true)]
        [string]
        $Template,
        [parameter(Mandatory=$true)]
        [string]
        $Datastore,
        [parameter(Mandatory=$true)]
        [string]
        $Cluster,
        [parameter(Mandatory=$true)]
        [string]
        $VCenter,
        [parameter(Mandatory=$false)]
        [switch]
        $PowerOn = $false
    )
        
foreach ($disconnect_vcenter in $global:DefaultVIServers) {
    Disconnect-VIServer $disconnect_vcenter -ErrorAction SilentlyContinue -Confirm:$false
    }

Connect-VIServer -Server $VCenter -Credential $MarkitEP -ErrorAction Stop | Out-Null
    
$cluster_hosts = Get-Cluster -Name $Cluster | Get-VMHost
$random_number = Get-Random -Minimum 10000 -Maximum 99000
$vms_created = @()

while ($cluster_hosts.count -le $NumVMs) {
    $cluster_hosts += $cluster_hosts
    }

while ($NumVMs -gt 0) {
    $vm = $VMPrefix + $random_number
    New-VM -Name $vm -Template $Template -Datastore $Datastore -VMHost $cluster_hosts[$NumVMs] | Out-Null
    $NumVMs -= 1
    $random_number += 1
    $vms_created += $vm
    if ($PowerOn -eq $true) {
        Start-VM $vm | Out-Null
        }
    }

Write-Output $vms_created

}