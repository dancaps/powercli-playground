<#If the host is not running esx build number 5050593 it will 
create a new object with the name, version and build information,
update an array and give you the output of the array when it has
checked all the hosts.#>

$esxhosts = Get-VMHost | Get-View 
$needsUpgrade = @()

foreach($esx in $esxhosts){

    if($esx.config.product.build -ne "5050593"){
        $hash = @{"Name" = $esx.name;
                  "Version" = $esx.config.product.version;
                  "Build" = $esx.config.product.build
                  }
        $newObj = New-Object -TypeName PSObject -Property $hash
        $needsUpgrade = $needsUpgrade + $newObj

    }
}

$needsUpgrade
