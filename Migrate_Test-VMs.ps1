#This script tests the connection of a vm before and after a migration to verify connectivity.

# User variables to modify
$vmhost = "esx012*"
$dest_cluster = "gold-02"

# Variables
$vms = Get-VMHost $vmhost | Get-VM | Get-View # Gets the vms to be migrated.
$dest_cluster_hosts = get-cluster $dest_cluster | Get-VMHost | Sort-Object MemoryUsageGB # Gets the cluster where the vms will be migrated.
$test_failed_vms = @() # Documents the failed vms that will still be migrated.
$test_passed_vms = @() # Documents the successful vms.

foreach($vm in $vms){
    $dest_vmhost = $dest_cluster_hosts[0] # Grabs the host with the least amount of memory.
    $org_vmhost = Get-VM $vm.Name | Get-VMHost | Select-Object name # Grabs the host the vm is on before the migration.

    # Tests the ip address before any migration takes place. 
    # If there is an error the vm will be migrated and no further tests will take place.
    try{
        test-connection -Destination $vm.Guest.IpAddress -Count 1 -ErrorAction stop | Out-Null
        }
    catch{
        Write-Host " "
        Write-Host $vm.name "failed the initial connection test and is being migrated anyways"
        Get-VM $vm.Name | Move-VM -Destination $dest_vmhost.Name | Out-Null
        $test_failed_vms += $vm.Name
        continue
        }

    # If the test was passed the vm will be migrated.
    write-host " "
    Write-Host $vm.name "passed the connection test and is being migrated"
    Get-VM $vm.Name | Move-VM -Destination $dest_vmhost.Name | Out-Null
     
    # Tests the ip address on the new host.
    # If the test fails the vm will be migrated back to the orginal host and the script will terminate to investigate the problem.
    try{
        test-connection -Destination $vm.Guest.IpAddress -Count 1 -ErrorAction stop | Out-Null
        }
    catch{
        Write-Host " "
        Write-Host $vm.name "failed the connection test after the migration"
        Write-Host "The vm will be migrated back to the original ESX host and the script will be terminated for investigation"
        Get-VM $vm.Name | Move-VM -Destination $org_vmhost.Name | Out-Null
        break
        }

    $test_passed_vms += $vm.Name

    }

Write-Host " "
Write-Host "-------------------------------------------------------"
Write-Host "The following vms failed the initial test and were migrated anyways" -ForegroundColor Yellow
$test_failed_vms
Write-Host " "
Write-Host "The following vms were moved and passed the final connection test successfully" -ForegroundColor Green
$test_passed_vms
