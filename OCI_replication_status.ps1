cls
#!pwsh
$OCIVMS = Import-CSV "C:\Temp\OCI\Wave10.42_servers.csv"



# Connect to Azure (if not already connected)
# Check if an Azure connection already exists
$azureContext = Get-AzContext -ErrorAction SilentlyContinue

# If no context is found, connect to Azure
if (-not $azureContext) {
    Write-Host "No existing Azure connection found. Connecting to Azure..."
    Connect-AzAccount
} else {
    Write-Host "Already connected to Azure with account: $($azureContext.Account.Id) in subscription: $($azureContext.Subscription.Name)"
}



# Create an initial array of PSCustomObjects
$myArray = @()
$strArray = @()
$replicatedArray = @()
$str = ""


# Display the updated array
#$myArray

ForEach ($OCIVM in $OCIVMS) {
		 try {
		 	$str = "" 
			#Write-Output "Checking for Server: $($OCIVM.Hostname)"
			# Create a new PSCustomObject
			$newObject = [PSCustomObject]@{ landsubscription = $OCIVM."Landing subscription"; landrsv = $OCIVM."landing rsv"; landrg = $OCIVM."landing resource group" }
			$str = $OCIVM."Landing subscription" +  $OCIVM."landing rsv" + $OCIVM."landing resource group"

				if ($strArray.Contains($str)) {
					# Add the new object to the array
					
				}else {
					#Write-Host "$newObject already exists in the array."
					$strArray  += $str
					$myArray += $newObject
				}

			 }

        catch {
           Write-Output "vm Failed- $OCIVM.Hostname -------------------------"
           Write-Output $_.Exception.Message

        }

 
}
		
$myArray | Format-Table -AutoSize


ForEach ($sub in $myArray) {

    try {
		 		 
			 $sub | Format-Table -AutoSize
			
		if ( ([string]::IsNullOrEmpty( $sub."landsubscription") -or ([string]::IsNullOrEmpty($sub."landrsv")) -or ([string]::IsNullOrEmpty($sub."landrg")) ) )  {
				Write-Host "one of the parameter is empty $sub "
		} else {
			
			
			Set-AzContext -Subscription $sub."landsubscription"
			# Define your Recovery Services Vault details
			$vaultName = $sub."landrsv"
			#$vaultName
			$resourceGroupName = $sub."landrg"
			#$resourceGroupName 
			# Get the Recovery Services Vault
			$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $resourceGroupName
			#$vault
			$dv = Set-AzRecoveryServicesAsrVaultContext -Vault $vault
			#$dv
			$fabric = Get-AzRecoveryServicesAsrFabric
			#$fabric
			$container = Get-AzRecoveryServicesAsrProtectionContainer -fabric $fabric
			#$container
			$ReplicationProtectedItems = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $container
			#$ReplicationProtectedItems
			
			ForEach ($repitem in $ReplicationProtectedItems) {
				$newObject = [PSCustomObject]@{ 
					landsubscription = $sub."landsubscription";
					landrsv = $vaultName;
					landrg = $resourceGroupName;
					servername = $repitem."FriendlyName" 
					ReplicationHealth =   $repitem."ReplicationHealth" ; 
					ProtectionState =  $repitem."ProtectionState"; 
					ProtectionStateDescription =  $repitem."ProtectionStateDescription"
				}
				$replicatedArray += $newObject
			}
			#$ReplicationProtectedItems | Select-Object  FriendlyName , ReplicationHealth, ProtectionState, ProtectionStateDescription ,PrimaryFabricFriendlyName  | Format-Table


    
		}
		 
			
		 
		 }

        catch {
           Write-Output "vm Failed- $OCIVM.Hostname -------------------------"
           Write-Output $_.Exception.Message

        }
	}
	
	
	$replicatedArray | select landsubscription, landrsv,landrg, servername,ReplicationHealth, ProtectionState,ProtectionStateDescription |export-csv  'C:\temp\OCIMigration_replication_data.csv' -Delimiter "|" -NoTypeInformation
	$replicatedArray | select landsubscription, landrsv,landrg, servername,ReplicationHealth, ProtectionState,ProtectionStateDescription |Format-Table			
		