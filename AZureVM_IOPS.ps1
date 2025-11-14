
#!pwsh
cls 

try {
    $x = Invoke-WebRequest -Uri "https://portal.azure.com/" -UseBasicParsing
}
catch [System.Net.WebException] {
    if ($_.Exception.Response.StatusCode -eq 407) {
        Write-Host "Proxy authentication failed (407)."
        # Add logic to handle the authentication failure, e.g., prompt for credentials
		Connect-AzAccount
    }elseif ($($_.Exception.Message).Contains("failed with status code '407'")) {
		Write-Host "Proxy authentication failed (407). Error: + $($_.Exception.Message) "
		Connect-AzAccount
		
	} else {
        Write-Host "An unexpected web error occurred: $($_.Exception.Message)"
    }
}
catch {
	
	if ($($_.Exception.Message).Contains("failed with status code '407'")) {
		Write-Host "Proxy authentication failed (407). Error: + $($_.Exception.Message) "
		Connect-AzAccount
		
	} else {
    Write-Host "An unexpected error occurred++++: $($_.Exception.Message)"
	}
}



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





# Connect to Azure (if not already connected)
 #Connect-AzAccount

# Set your Azure subscription context (if needed)
 Set-AzContext -SubscriptionId "CCP-BAPP-DE-20250905062538"

$resourceGroupName = "rg-bapp-de-az-5c583d3c68f0-workload" # Replace with your VM's resource group name
$vmName = "BY0RBR" # Replace with your VM's name

# Get the VM object
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

#PT1M
$timeGrain1 = New-TimeSpan -Minutes 1

Get-AzMetricDefinition -ResourceId $vm.Id | Where-Object { $_.Name.Value -eq "OSDiskIOPSConsumedPercentage" }

Get-AzMetricDefinition -ResourceId $vm.Id | Where-Object { $_.Name.Value -eq "DataDiskIOPSConsumedPercentage" }


Get-AzMetricDefinition -ResourceId $vm.Id | Where-Object { $_.Name.Value -eq "DataDiskIOPSConsumedPercentage" } | Select-Object -ExpandProperty SupportedTimeGrains

# Get the metrics for OS Disk IOPS Consumed Percentage
#$osDiskIopsConsumed = Get-AzMetric -ResourceId $vm.Id -MetricName "OSDiskIOPSConsumedPercentage" -TimeGrain 00:01:00 -StartTime (Get-Date).AddHours(-1) -AggregationType Average
$osDiskIopsConsumed = Get-AzMetric `
  -ResourceId $vm.Id `
  -MetricName "OSDiskIOPSConsumedPercentage" `
  -TimeGrain 00:01:00 `
  -StartTime (Get-Date).AddHours(-1) `
  -EndTime (Get-Date) `
  -AggregationType Average `
  -MetricNamespace "Microsoft.Compute/virtualMachines"

# Get the metrics for Data Disk IOPS Consumed Percentage
#$dataDiskIopsConsumed = Get-AzMetric -ResourceId $vm.Id -MetricName "DataDiskIOPSConsumedPercentage" -TimeGrain 00:01:00 -StartTime (Get-Date).AddHours(-1) -AggregationType Average
$dataDiskIopsConsumed = Get-AzMetric `
  -ResourceId $vm.Id `
  -MetricName "DataDiskIOPSConsumedPercentage" `
  -TimeGrain 00:01:00 `
  -StartTime (Get-Date).AddHours(-1) `
  -EndTime (Get-Date) `
  -AggregationType Average `
  -MetricNamespace "Microsoft.Compute/virtualMachines"
  

# Display the results
Write-Host "VM: $($vm.Name)"
Write-Host "OS Disk IOPS Consumed Percentage (Last Hour, Average):"
$osDiskIopsConsumed.Data | ForEach-Object {
    Write-Host "  Time: $($_.TimeStamp), Value: $($_.Average)%"
}

Write-Host "Data Disk IOPS Consumed Percentage (Last Hour, Average):"
$dataDiskIopsConsumed.Data | ForEach-Object {
    Write-Host "  Time: $($_.TimeStamp), Value: $($_.Average)%"
}