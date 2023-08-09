[void] [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


# Save assessment report in an excel file
Function Save-AssessmentReport(){

$AzContext = Get-AzContext
$AzTenant = Get-AzTenant -TenantId $AzContext.Tenant.Id

$desktop = "C:\Users\"+$env:USERNAME+"\Desktop\"
$folder = "Sub-"+'(' +$AzContext.Subscription.Name +') ID-('+$global:SourceSubscription+')'
#$filePath = "C:\Users\"+$env:USERNAME+"\Desktop\Sub-"+'(' +$AzContext.Subscription.Name +')ID-('+$global:SourceSubscription+')'
$filePath = $desktop+$folder

if(Test-Path -Path $filePath){ Rm -Path $filePath -Recurse -Force }
New-Item -Path $desktop -Name ('\Sub-'+'(' +$AzContext.Subscription.Name +') ID-('+$global:SourceSubscription+')') -ItemType "directory" -ErrorAction SilentlyContinue | Out-Null

$Resources = Get-AzResource | Select Name, Type, ResourceGroupName, Location, kind, ParentResource, ResourceId 
$Resources | Export-Csv -Path ($filepath+'.\1a#AzureResources.csv') -ErrorAction SilentlyContinue

Function-Assessment
    if($Global:RSx){$Global:RSx | Format-Table | Out-Host}
    else{Write-Host "No Resource Found..." -ForegroundColor Red}
$Global:RSx | Export-Csv -Path ($filepath+'.\0#AssessmentReport.csv') -ErrorAction SilentlyContinue

Function-ResourceGroups
    if($Global:ResourceGroups){$Global:ResourceGroups | Format-Table | Out-Host }
    else{Write-Host "No Resource Group Found..." -ForegroundColor Red}
$Global:ResourceGroups | Export-Csv -Path ($filepath+'.\1b#ResourceGroups.csv') -ErrorAction SilentlyContinue

Function-CheckMarketPlaceVM
    if($Global:VMx){$Global:VMx | Format-Table | Out-Host}
    else{Write-Host "No Virtual Machine Found..." -ForegroundColor Red}
$Global:VMx | Export-Csv -Path ($filepath+'.\3a#VirtualMachines.csv') -ErrorAction SilentlyContinue

Function-CheckClassicVirtualMachine
    if($Global:ClassicVMx){ $Global:ClassicVMx | Format-Table | Out-Host}
    else{Write-Host "No Classic VM Found..." -ForegroundColor Red}
$Global:ClassicVMx | Export-Csv -Path ($filepath+'.\3c#ClassicVirtualMachines.csv') -ErrorAction SilentlyContinue 

Function-CheckAppServiceAndPlan
    if($Global:AppPlanx){ $Global:AppPlanx | Format-Table | Out-Host}
    else{ Write-Host "No App Service Plan/ App Service found... "-ForegroundColor Red}
$Global:AppPlanx | Export-Csv -Path ($filepath+'.\2a#AppServicePlansWebApps.csv') -ErrorAction SilentlyContinue

Function-CheckAppServiceCertBinding
    if($Global:BinDx){ $Global:BinDx | Format-Table | Out-Host}
    else{ Write-Host "No certificate binding found... "-ForegroundColor Red}
$Global:BinDx | Export-Csv -Path ($filepath+'.\2b#WebAppSSLBindings.csv') -ErrorAction SilentlyContinue

Function-CheckManagedDisk
    if($Global:Diskx){ $Global:Diskx | Format-Table | Out-Host}
    else{ Write-Host "No disk found..." -ForegroundColor Red }
$Global:Diskx | Export-Csv -Path ($filepath+'.\5#ManagedDisks.csv') -ErrorAction SilentlyContinue

Function-CheckIPAddress
    if($Global:IPx){ $Global:IPx | Format-Table | Out-Host }
    else{Write-Host "No Public IP address found..." -ForegroundColor Red }
$Global:IPx | Export-Csv -Path ($filepath+'.\4#PublicIPAddress.csv') -ErrorAction SilentlyContinue

Function-CheckVNETPeering
    if($Global:VNetx){ $Global:VNetx | Format-Table | Out-Host}
    else{Write-Host "No Virtual Network found..." -ForegroundColor Red }
$Global:VNetx | Export-Csv -Path ($filepath+'.\6a#VNetPeerings.csv') -ErrorAction SilentlyContinue

Function-CheckLoadBalancers
    if($Global:LBx){ $Global:LBx | Format-Table | Out-Host}
    else{Write-Host "No Load Balancer found..." -ForegroundColor Red }
$Global:LBx | Export-Csv -Path ($filepath+'.\7#LoadBalancers.csv') -ErrorAction SilentlyContinue

Function-CheckRecoveryserviceVaults
    if($Global:RSVx){ $Global:RSVx | Format-Table | Out-Host}
    else{Write-Host "No Recovery Service Vault found..." -ForegroundColor Red }
$Global:RSVx | Export-Csv -Path ($filepath+'.\8#RecoveryServiceVaults.csv') -ErrorAction SilentlyContinue

Function-NetworkSecurityGroups
    if($Global:NetworkSecurityGroups){ $Global:NetworkSecurityGroups | Format-Table | Out-Host}
    else{Write-Host "No Network Security Group found..." -ForegroundColor Red }
$Global:NetworkSecurityGroups | Export-Csv -Path ($filepath+'.\6b#NetworkSecurityGroups.csv') -ErrorAction SilentlyContinue

Function-PrivateEndpoints
    if($Global:PvtEndPointX){
        $Global:PvtEndPointX | Export-Csv -Path ($filepath+'.\6c#PrivateEndpoints.csv') -ErrorAction SilentlyContinue
    }else{Write-Host "No Private Endpoint found..." -ForegroundColor Red}

Function-CheckVMDependency
    if($Global:VMVnetMap){
        $Global:VMVnetMap | Select 'Virtual Network','NIC',"Virtual Machine","Resource Group(VNet)","Resource Group(NIC)","Resource Group(VM)","Resource Group(Disk)","Resource Group(NSG)","Resource Group(PubIP)","Resource Group(BootDiag)","OS Disk","Public IP","NSG","BootDiag Storage" | Format-Table | Out-Host}
    else{Write-Host "No Virtual Network found..." -ForegroundColor Red}
$Global:VMVnetMap | Select 'Virtual Network','NIC',"Virtual Machine","Resource Group(VNet)","Resource Group(NIC)","Resource Group(VM)","Resource Group(Disk)","Resource Group(NSG)","Resource Group(PubIP)","Resource Group(BootDiag)","OS Disk","Public IP","NSG","BootDiag Storage" | Export-Csv -Path ($filepath+'.\3b#VMDependencies.csv') -ErrorAction SilentlyContinue

Function-ServiceQuota
    if($Global:ServiceQuota){ $Global:ServiceQuota | Format-Table | Out-Host }
    else{Write-Host "No compute resource found in the subscription, default quota available for all resource types..." -ForegroundColor Red}
$Global:ServiceQuota | Export-Csv -Path ($filepath+'.\9a#ServiceQuota.csv') -ErrorAction SilentlyContinue

Function-RoleAssignments
    $Global:RoleAssignments | Export-Csv -Path ($filepath+'.\9b#RoleAssignments.csv') -ErrorAction SilentlyContinue

Write-Host "`n`nAssessment complete, please wait..." -ForegroundColor Green


###################### Merge all csv into an excel file #######################

cd $filePath #target folder
$csvs = Get-ChildItem .\*  -Include *.csv -Force -ErrorAction Stop

$outputfilename = "AssessmentToolReport-" +'(' +$AzContext.Subscription.Name +')' + '('+ $AzTenant.Name + ')' + ".xlsx" 

$excelapp = new-object -comobject Excel.Application
$excelapp.sheetsInNewWorkbook = $csvs.Count
$xlsx = $excelapp.Workbooks.Add()
$sheet=1

foreach ($csv in $csvs)
{
    $row=1
    $column=1
    $worksheet = $xlsx.Worksheets.Item($sheet)
    $worksheet.Name = $csv.BaseName
    $filec = (Get-Content $csv) | Select-Object -Skip 1
    foreach($line in $filec )
    {  
        $linecontents = $line -split ',(?!\s*\w+")'
            foreach($cell in $linecontents)
                {   
                    #$worksheet.Cells.Item(1,$column).Interior.ColorIndex = 33
                    $worksheet.Cells.Item($row,$column) = $cell.Replace('"','')
                    $column++
                }
        $column=1
        $row++
    }
    for($k=1;($k -le $linecontents.Count);$k++ ){ 
        $worksheet.Cells.Item(1,$k).Interior.ColorIndex = 33 
        #$worksheet.Cells.Item(1,$k).Font.Size = 12
        $worksheet.Cells.Item(1,$k).Font.Bold = $true   
    }
    $sheet++
}
$output = $filePath + "\" + $outputfilename
$xlsx.SaveAs($output)
$excelapp.quit()
$csvs | foreach {$_.attributes = "Hidden"}

cd ('C:\Users\' + $env:USERNAME)

Write-Host "`nCheck the folder $filePath `n" -ForegroundColor Yellow

Invoke-Item $filePath -ErrorAction SilentlyContinue

$transcript = Stop-Transcript 
$transpath = $transcript.Path.Split('\')

Move-Item -Path $transcript.Path -Destination ($transpath[0]+'\'+$transpath[1]+'\'+$transpath[2]+'\'+$transpath[3]+'\'+$folder+'\'+$transpath[4])

}  

###### Assess all the resources (Function #1: Button1) ######
Function Function-Assessment(){

Write-Host "`n> Checking Resource Types... `n" -ForegroundColor Green

$Resources = Get-AzResource | Select Name, Type, ResourceGroupName, Location
$ResType = ($Resources | Select Type -Unique)

$Group = ($Resources | Select Type) | ConvertTo-Csv | Group | Select Name, Count 
$Hash5 = @{}
foreach( $Element in $Group ){$Hash5.Add($Element.Name.Replace('"',''), $Element.Count)}

$storageAccount = 'paygassessmentcsp'
$tableName = "Movable"
$version = "2017-04-17"
$sasReadToken = "?sv=2020-08-04&ss=t&srt=sco&sp=rl&se=2022-12-31T18:29:59Z&st=2022-01-11T10:58:11Z&spr=https&sig=EohwSoFJp6OlbNtpXo99J8Gvqcbqw5tn3yn5y8MjT08%3D"

$GMTTime = (Get-Date).ToUniversalTime().toString('R')
$header = @{
    'x-ms-date'    = $GMTTime;
    Accept = 'application/json;odata=nometadata'
}


$Global:RSx = [System.Collections.ArrayList]::new()
foreach($RT in $ResType){
    $csvObject = New-Object PSObject
    $RType = $RT.Type
    
    $index1 = $RType.IndexOf('.')
    $index2 = $RType.IndexOf('/')
    $index3 = $RType.LastIndexOf('/')
    $splits = $RType.Split('/',6) 

    $PKey = $RType.Substring(($index1 + 1),($index2 - $index1 - 1))  
    $RKey = $splits[1]+$splits[2]+$splits[3]+$splits[4]+$splits[5]+$splits[6]
    $RKey = $RKey.ToLower()

    $tableUri = "https://$storageAccount.table.core.windows.net/$tableName(PartitionKey='$PKey',RowKey='$RKey')$sasReadToken" 
    try{
        $item = Invoke-RestMethod -Method GET -Uri $tableUri -Headers $header  -ContentType application/json
    }catch{
        #Write-Host "StatusCode:" $_.Exception
        $item = $null
    }
    
    $Mv = $item.MvAcrossSub 
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Type" -value $RType

    if($item.FriendlyName){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Friendly Name" -value $item.FriendlyName
    }else{
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Friendly Name" -value " "
    }
    
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Count" -value $Hash5.$RType
    if($Mv -eq $true){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable?" -value "Yes"   
    }elseif($Mv -eq $false){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable?" -value "No"
    }else{
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable?" -value "Unknown"
    }
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Remarks" -value $item.Description 

    $i= $Global:RSx.Add($csvObject)
}

}

###### Check Marketplace VM (Function #2: Button2 ) ##########
Function Function-CheckMarketPlaceVM(){

Write-Host "`n> Checking Virtual Machines...`n" -ForegroundColor Green

$vms = Get-AzVM 
$Global:VMx = [System.Collections.ArrayList]::new() 
foreach($vm in $vms)
{
    $csvObject = New-Object PSObject
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Virtual Machine" -value $vm.Name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group" -value $vm.ResourceGroupName
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Location" -value $vm.Location
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Size" -value $vm.HardwareProfile.VmSize
    if($vm.StorageProfile.OsDisk.ManagedDisk){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "OS Disk Type" -value 'Managed Disk'
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "VHD Uri" -value ""
    }
    else{
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "OS Disk Type" -value 'Unmanaged Disk' #$vm.StorageProfile.OsDisk
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "VHD Uri" -value $vm.StorageProfile.OsDisk.Vhd.Uri
    }
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "DataDisk Count" -value $vm.StorageProfile.DataDisks.Count

    $OperatingSys = '('+$vm.StorageProfile.ImageReference.Offer+' '+$vm.StorageProfile.ImageReference.Sku+')'
    if($vm.StorageProfile.ImageReference -eq $null){ $OperatingSys = ''}
    if($vm.StorageProfile.OsDisk.OsType -eq 0){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Operating System" -value ("Windows "+$OperatingSys)
    }else{Add-Member -inputObject $csvObject -memberType NoteProperty -name "Operating System" -value ("Linux "+$OperatingSys)}

    
    if($vm.DiagnosticsProfile.BootDiagnostics.Enabled -eq $true){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Boot Diagnostics" -value "Enabled"
    }else{ Add-Member -inputObject $csvObject -memberType NoteProperty -name "Boot Diagnostics" -value "Disabled"}
    
    if($vm.DiagnosticsProfile.BootDiagnostics.StorageUri){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Boot Diagnostics Storage" -value $vm.DiagnosticsProfile.BootDiagnostics.StorageUri.Split('/')[2].Split('.')[0]  
    }else{ Add-Member -inputObject $csvObject -memberType NoteProperty -name "Boot Diagnostics Storage" -value " "}


    if($vm.Plan){Add-Member -inputObject $csvObject -memberType NoteProperty -name "Plan associated?" -value 'Yes'}
    else{Add-Member -inputObject $csvObject -memberType NoteProperty -name "Plan associated?" -value 'No'}

    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Plan Name" -value $vm.Plan.Name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Publisher" -value $vm.Plan.Publisher
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Product" -value $vm.Plan.Product 
    
    $diskEncryption = Get-AzVMDiskEncryptionStatus -VMName $vm.Name -ResourceGroupName $vm.ResourceGroupName
    if($diskEncryption.OsVolumeEncrypted -eq 'Encrypted'){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "OsVolumeEncrypted" -value $diskEncryption.OsVolumeEncrypted
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "DiskEncryptionKey" -value $diskEncryption.OsVolumeEncryptionSettings.DiskEncryptionKey.SecretUrl
    }else{
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "OsVolumeEncrypted" -value $diskEncryption.OsVolumeEncrypted
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "DiskEncryptionKey" -value " "
    }
    if($diskEncryption.OsVolumeEncryptionSettings.KeyEncryptionKey){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "KeyEncryptionKey" -value $diskEncryption.OsVolumeEncryptionSettings.KeyEncryptionKey.KeyUrl
    }else{
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "KeyEncryptionKey" -value " "
    }

    $i = $Global:VMx.Add($csvObject) 
}

}

###### Classic Virtual Machines (Function #3: Button3) #######
Function Function-CheckClassicVirtualMachine(){

Write-Host "`n> Checking Classic Virtual Machines...`n" -ForegroundColor Green

$ClassicVms = Get-AzResource -ResourceType Microsoft.ClassicCompute/virtualMachines -ExpandProperties
$Global:ClassicVMx = [System.Collections.ArrayList]::new() 

foreach($ClassicVm in $ClassicVms){
    $csvObject = New-Object PSObject
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Virtual Machine(Classic)" -value $ClassicVm.Name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group" -value $ClassicVm.ResourceGroupName
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Location" -value $ClassicVm.Location
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Status" -value $ClassicVm.Properties.instanceView.status
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Operating System" -value $ClassicVm.Properties.storageProfile.operatingSystemDisk.operatingSystem   
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Cloud Service(Classic)" -value $ClassicVm.Properties.domainName.name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "RG (Cloud Service)" -value $ClassicVm.Properties.domainName.id.Split('/')[4] 
    if($ClassicVm.Properties.networkProfile.virtualNetwork){  
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Virtual Network" -value $ClassicVm.Properties.networkProfile.virtualNetwork.name
    }else{Add-Member -inputObject $csvObject -memberType NoteProperty -name "Virtual Network" -value ''}
    if($ClassicVm.Properties.networkProfile.virtualNetwork.staticIpAddress){
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Static IP" -value $ClassicVm.Properties.networkProfile.virtualNetwork.staticIpAddress
    }else{Add-Member -inputObject $csvObject -memberType NoteProperty -name "Static IP" -value ''} 
    if($ClassicVm.Properties.instanceView.publicIpAddresses){
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Public IP" -value $ClassicVm.Properties.instanceView.publicIpAddresses[0]
    }else{Add-Member -inputObject $csvObject -memberType NoteProperty -name "Public IP" -value ''}
    if($ClassicVm.Properties.networkProfile.reservedIps){
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Reserved IP" -value $ClassicVm.Properties.networkProfile.reservedIps[0].name
    }else{Add-Member -inputObject $csvObject -memberType NoteProperty -name "Reserved IP" -value ''}
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Storage Account" -value $ClassicVm.Properties.storageProfile.operatingSystemDisk.storageAccount.name

    $i = $Global:ClassicVMx.Add($csvObject)
}
}

###### Check App Services (Function #4: Button4) #############
Function Function-CheckAppServiceAndPlan(){

Write-Host "`n> Checking App Service Plans and App Services... `n" -ForegroundColor Green

$Global:AppPlanx = [System.Collections.ArrayList]::new()
#$Appx = [System.Collections.ArrayList]::new()

$AppServices = Get-AzResource -ResourceType Microsoft.Web/sites -ExpandProperties
$WebApps = Get-AzResource -ResourceType Microsoft.Web/sites/slots -ExpandProperties
$WebAppPlans = Get-AzResource -ResourceType Microsoft.Web/serverfarms -ExpandProperties

foreach($Plan in $WebAppPlans){
    $csvObject = New-Object PSObject

    $AppS = $AppServices | Where-Object { $_.Properties.serverFarmId -eq $Plan.Id}
    $SlotS = $WebApps | Where-Object { $_.Properties.serverFarmId -eq $Plan.Id}

    $WebSpace = $Plan.Properties.webSpace
    if($WebSpace.Contains('-')){
        $OriginRG = $WebSpace.Substring(0,$WebSpace.LastIndexOf('-'))
    }else{ $OriginRG = 'Not Found'}
    $sites = "[ App-"+$AppS.Count + " | Slot-"+ $SlotS.count+" ]"

    Add-Member -inputObject $csvObject -memberType NoteProperty -name "App Service Plan" -value $Plan.Name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "App Service" -value $sites
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Status" -value $Plan.Properties.status
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "WebSpace" -value $WebSpace
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Origin RG" -value $OriginRG
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Current RG" -value $Plan.ResourceGroupName
    

    if($Plan.ResourceGroupName -eq $OriginRG){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Internal Move" -value "Not require"
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Move Resource" -value "---"
    }
    elseif($OriginRG -eq 'Not Found'){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Internal Move" -value "Unknown"
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Move Resource" -value "Unknown"    
    }
    else{
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Internal Move" -value "Require"
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Move Resource" -value ("From: "+ $Plan.ResourceGroupName + " -> To: " + $OriginRG)
    }

    $i = $Global:AppPlanx.Add($csvObject)
    
    
    foreach($app in $AppS){
        $csvObject2 = New-Object PSObject
        $b = $app.Properties.serverFarmId -match "/providers/Microsoft.Web/serverfarms/(?<content>.*)"
        $planname = $matches['content'] 
        $appWebSpace = $app.Properties.webSpace

        if($appWebSpace.Contains('-')){
        $OriginRG = $appWebSpace.Substring(0,$appWebSpace.LastIndexOf('-'))
        }else{ $OriginRG = 'Not Found'}

        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "App Service Plan" -value ('  ...')
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "App Service" -value $app.name
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Status" -value $app.Properties.state
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "WebSpace" -value $appWebSpace
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Origin RG" -value $OriginRG
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Current RG" -value $app.ResourceGroupName 
        

        if($app.ResourceGroupName -eq $OriginRG){
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Internal Move" -value "Not require"
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Move Resource" -value "---"
        }
        elseif($OriginRG -eq 'Not Found'){
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Internal Move" -value "Unknown"
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Move Resource" -value "Unknown"    
        }
        else{
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Internal Move" -value "Require"
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Move Resource" -value ("From: "+ $app.ResourceGroupName + " -> To: " + $OriginRG)
        }
     
    $j = $Global:AppPlanx.Add($csvObject2)     
    
    }

    foreach($slot in $SlotS){
        $csvObject3 = New-Object PSObject
        $b = $slot.Properties.serverFarmId -match "/providers/Microsoft.Web/serverfarms/(?<content>.*)"
        $planname = $matches['content'] 
        $appWebSpace = $slot.Properties.webSpace

        if($appWebSpace.Contains('-')){
        $OriginRG = $appWebSpace.Substring(0,$appWebSpace.LastIndexOf('-'))
        }else{ $OriginRG = 'Not Found'}

        Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "App Service Plan" -value ('  ...')
        Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "App Service" -value $slot.name
        Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Status" -value $slot.Properties.state
        Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "WebSpace" -value $appWebSpace
        Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Origin RG" -value $OriginRG
        Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Current RG" -value $slot.ResourceGroupName 
        

        if($slot.ResourceGroupName -eq $OriginRG){
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Internal Move" -value "Not require"
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Move Resource" -value "---"
        }
        elseif($OriginRG -eq 'Not Found'){
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Internal Move" -value "Unknown"
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Move Resource" -value "Unknown"    
        }
        else{
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Internal Move" -value "Require"
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Move Resource" -value ("From: "+ $slot.ResourceGroupName + " -> To: " + $OriginRG)
        }
     
    $j = $Global:AppPlanx.Add($csvObject3)     
    
    }

}

}

###### App Service SSL Bindings (Function #5: Button5) #######
Function Function-CheckAppServiceCertBinding(){

Write-Host "`n> Checking App Service Certificate bindings...`n" -ForegroundColor Green

$appSerCerts = Get-AzWebAppCertificate
$hash = @{}
foreach($cer in $appSerCerts){
    $RG = ($cer.Id.split('/'))[4]
    $Thumb = $cer.Thumbprint
    $hash[$Thumb+$RG]= @($RG,$cer.Name) 
}

$AppServices = Get-AzResource -ResourceType Microsoft.Web/sites -ExpandProperties
$WebApps = Get-AzResource -ResourceType Microsoft.Web/sites/slots -ExpandProperties

$Global:BinDx = [System.Collections.ArrayList]::new()

foreach($App in $AppServices){

        $appWebSpace = $App.Properties.webSpace
        if($appWebSpace.Contains('-')){
            $OriginRG = $appWebSpace.Substring(0,$appWebSpace.LastIndexOf('-'))
        }else{ $OriginRG = 'Not Found'}

    $sslBind = $App.Properties.hostNameSslstates
    foreach($sb in $sslBind){
        $csvObject = New-Object PSObject
        if($sb.sslState -eq 'Disabled'){continue}
        $tmp = $sb.thumbprint+$App.ResourceGroupName
        $tmp1 = $sb.thumbprint

        if($hash.$tmp){$certName = $hash.$tmp[1];$certRG = $hash.$tmp[0]}
        else{$certName = ''; $certRG = '' }
        
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "App Service" -value $App.Name
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Host Name" -value $sb.name
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "SSL State" -value $sb.sslState
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Thumbprint" -value $sb.thumbprint
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Thumbprint RG" -value $certRG
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "App Service Origin RG" -value $OriginRG 
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Microsoft.web/certificate" -value $certName       

        $i = $Global:BinDx.Add($csvObject)
    }
}

foreach($App in $WebApps){

    $appWebSpace = $App.Properties.webSpace
    if($appWebSpace.Contains('-')){
        $OriginRG = $appWebSpace.Substring(0,$appWebSpace.LastIndexOf('-'))
    }else{ $OriginRG = 'Not Found'}

    $sslBind = $App.Properties.hostNameSslstates
    foreach($sb in $sslBind){
        $csvObject2 = New-Object PSObject
        if($sb.sslState -eq 'Disabled'){continue}
        $tmp = $sb.thumbprint+$App.ResourceGroupName

        if($hash.$tmp){$certName = $hash.$tmp[1];$certRG = $hash.$tmp[0]}
        else{$certName = "";$certRG = ""}
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "App Service" -value $App.Name 
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Host Name" -value $sb.name
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "SSL State" -value $sb.sslState
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Thumbprint" -value $sb.thumbprint
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Thumbprint RG" -value $certRG
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "App Service Origin RG" -value $OriginRG
        Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Microsoft.web/certificate" -value $certName

        $i = $Global:BinDx.Add($csvObject2)
    }
}

}

###### Check Managed Disks (Function #6: Button6) ############
Function Function-CheckManagedDisk(){

Write-Host "`n> Checking Managed Disks...`n" -ForegroundColor Green 

$Global:Diskx = [System.Collections.ArrayList]::new()
$Disks = Get-AzDisk

    foreach($Disk in $Disks){ 
        $csvObject = New-Object PSObject
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Managed Disk" -value $Disk.Name
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group" -value $Disk.ResourceGroupName
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Location" -value $Disk.Location
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "SKU" -value ($Disk.Sku.Tier+" | "+$Disk.Sku.Name)
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Size(GB)" -value $Disk.DiskSizeGB
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Encryption Type" -value $Disk.Encryption.Type
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Disk Encryption Set" -value $Disk.Encryption.DiskEncryptionSetId
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Encryption Enabled" -value $Disk.EncryptionSettingsCollection.Enabled
        if($Disk.EncryptionSettingsCollection.EncryptionSettings){
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "DiskEncryptionKey" -value $Disk.EncryptionSettingsCollection.EncryptionSettings[0].DiskEncryptionKey.SecretUrl
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "KeyEncryptionKey" -value $Disk.EncryptionSettingsCollection.EncryptionSettings[0].keyEncryptionKey.KeyUrl    
        }

        if($Disk.ManagedBy){
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "ManagedBy" -value $Disk.ManagedBy
        }else{ Add-Member -inputObject $csvObject -memberType NoteProperty -name "ManagedBy" -value " "}

        if($Disk.Zones){
            $z = $Disk.Zones[0]
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Availability Zone" -value $z
        }else{
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Availability Zone" -value 'None'
        }
        if($Disk.Zones -or $Disk.Encryption.DiskEncryptionSetId -or $Disk.EncryptionSettingsCollection.EncryptionSettings){
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable across Subscription?" -value 'No'
        }
        else{ 
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable across Subscription?" -value 'Yes'
        }        
        $i = $Global:Diskx.Add($csvObject)
    }

}

###### Check Public IP Address(Function #7: Button7) #########
Function Function-CheckIPAddress(){

Write-Host "`n> Checking Public IP Addresses... `n" -ForegroundColor Green

$Global:IPx = [System.Collections.ArrayList]::new()
$Pubip = Get-AzPublicIpAddress

    foreach ($ip in $Pubip) {
        $csvObject = New-Object PSObject
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Public IP" -value $ip.Name
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group" -value $ip.ResourceGroupName
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Location" -value $ip.Location
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "IP Version" -value $ip.PublicIpAddressVersion
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Address" -value $ip.IpAddress
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Allocation Method" -value $ip.PublicIpAllocationMethod
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "SKU" -value $ip.Sku.Name
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Tier" -value $ip.Sku.Tier
        if($ip.Zones){
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Zones" -value ($ip.Zones[0]+' '+ $ip.Zones[1]+' '+ $ip.Zones[2]) 
        }else{
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Zones" -value " "
        }
        
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Attached To" -value $ip.IpConfiguration.Id

        if($ip.Sku.Name -eq 'Basic'){
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable across Subscription?" -value 'Yes'    
        }
        else{
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable across Subscription?" -value 'No'
        }
        $i= $Global:IPx.Add($csvObject) 
    } 

}

###### Check Virtual Network Peering (Function #8: Buuton8)###
Function Function-CheckVNETPeering(){

Write-Host "`n> Checking Virtual Network Peering...`n" -ForegroundColor Green

$Global:VNetx = [System.Collections.ArrayList]::new()
$VNETs = Get-AzVirtualNetwork 

    foreach ($VNET in $VNETs) { 
        $csvObject = New-Object PSObject
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Virtual Network" -value $VNET.Name
        $addressP = $VNET.AddressSpace.AddressPrefixes[0]+" " +$VNET.AddressSpace.AddressPrefixes[1]+" "+$VNET.AddressSpace.AddressPrefixes[2]+" " +$VNET.AddressSpace.AddressPrefixes[3]+" " +$VNET.AddressSpace.AddressPrefixes[4]
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Address Space" -value $addressP
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Peering Count" -value $VNET.VirtualNetworkPeerings.Count
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Peering Name" -value ''
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Peering State" -value ''
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Peered VNet" -value ''
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "AllowVirtualNetworkAccess" -value ''
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "AllowForwardedTraffic" -value ''
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "AllowGatewayTransit" -value ''
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "UseRemoteGateways" -value ''
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "RemoteGateways" -value ''     
        $i = $Global:VNetx.Add($csvObject)
        
        $Peerings = Get-AzVirtualNetworkPeering -VirtualNetworkName $VNET.Name -ResourceGroupName $VNET.ResourceGroupName

        foreach($Peer in $Peerings){
            $csvObject2 = New-Object PSObject
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Virtual Network" -value '...'
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Address Space" -value " "
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Peering Count" -value " "
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Peering Name" -value $Peer.Name
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Peering State" -value $Peer.PeeringState
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Peered VNet" -value $Peer.RemoteVirtualNetwork.Id
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "AllowVirtualNetworkAccess" -value $Peer.AllowVirtualNetworkAccess
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "AllowForwardedTraffic" -value $Peer.AllowForwardedTraffic
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "AllowGatewayTransit" -value $Peer.AllowGatewayTransit
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "UseRemoteGateways" -value $Peer.UseRemoteGateways
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "RemoteGateways" -value $Peer.RemoteGateways
            $i = $Global:VNetx.Add($csvObject2)
          }       
     } 
 
}

###### Load Balancers (Function #9: Button9) #################
Function Function-CheckLoadBalancers(){

Write-Host "`n> Checking Load Balancers...`n" -ForegroundColor Green

$Global:LBx = [System.Collections.ArrayList]::new()

$LBs = Get-AzLoadBalancer 
foreach($LB in $LBs){
    $csvObject = New-Object PSObject
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Load Balancer" -value $LB.Name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group" -value $LB.ResourceGroupName
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Location" -value $LB.Location

    if($LB.FrontendIpConfigurations[0].PublicIpAddress){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Type" -value "External"
    }
    else{ Add-Member -inputObject $csvObject -memberType NoteProperty -name "Type" -value "Internal"}

    Add-Member -inputObject $csvObject -memberType NoteProperty -name "SKU" -value $LB.Sku.Name
    if($LB.Sku.Name -eq 'Basic'){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable across subscription ?" -value 'Yes'
    }else{
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable across subscription ?" -value 'No'
    }
    $i = $Global:LBx.Add($csvObject) 
}
}

###### Recovery Service Vaults (Function #10: Button10) ######
Function Function-CheckRecoveryserviceVaults(){

Write-Host "`n> Checking Recovery Service Vaults...`n" -ForegroundColor Green 

$Global:RSVx = [System.Collections.ArrayList]::new()

$Vaults = Get-AzRecoveryServicesVault
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

foreach($Val in $Vaults){
    $csvObject = New-Object PSObject
    Write-Host "RSV: "$Val.Name "| RG: "$Val.ResourceGroupName
    $Vault = Get-AzRecoveryServicesVault -Name $Val.Name -ResourceGroupName $Val.ResourceGroupName 
    $con = Set-AzRecoveryServicesVaultContext -Vault $Vault 

    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Recovery Service Vault" -value $Val.Name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group" -value $Val.ResourceGroupName
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Location" -value $Val.Location

    $con1 = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM 
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "AzureVM Backup" -value $con1.count
    $con2 = Get-AzRecoveryServicesBackupContainer -ContainerType AzureSQL 
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "AzureSQL VM Backup" -value $con2.count
    $con3 = Get-AzRecoveryServicesBackupContainer -ContainerType AzureStorage 
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "AzureStorage Backup" -value $con3.count

    
    $i = Set-AzRecoveryServicesAsrVaultSettings -Vault $Vault -ErrorAction SilentlyContinue
    $Fabrics = Get-AzRecoveryServicesAsrFabric -ErrorAction SilentlyContinue
    
    $Items = 0
    foreach($Fabric in $Fabrics){
        $ProtectionContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $Fabric
        if($ProtectionContainer){
            $ProtectedItems = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $ProtectionContainer
            $Items += $ProtectedItems.Count
        }
    }
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "ASR Protected Item" -value $Items

    if($con2 -or $con3 -or ($Items -gt 0)){
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable across subscription?" -value "No"
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Remarks" -value "Remove protected items before migration"           
    }else{
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Movable across subscription?" -value "Yes"
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Remarks" -value " "
    }  

    $i = $Global:RSVx.Add($csvObject) 
}

}

###### VM dependent resources (Function #11: Button11) #######
Function Function-CheckVMDependency(){

Write-Host "`n> Checking VM Dependencies...`n" -ForegroundColor Green

$Global:VMVnetMap = [System.Collections.ArrayList]::new()
$NICs = Get-AzNetworkInterface
foreach($NIC in $NICs){               
    $csvObject = New-Object PSObject
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Virtual Network" -value $NIC.IpConfigurations[0].Subnet.Id.Split('/')[-3]
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group(VNet)" -value $NIC.IpConfigurations[0].Subnet.Id.Split('/')[4]
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "NIC" -value $NIC.Name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "IP Address" -value $NIC.IpConfigurations[0].PrivateIpAddress
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group(NIC)" -value $NIC.ResourceGroupName

    if($NIC.VirtualMachine.Id){
        $V = $NIC.VirtualMachine.Id.Split('/'); $VM = Get-AzVm -ResourceGroupName $V[4] -Name $V[-1] -ErrorAction SilentlyContinue       
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Virtual Machine" -value $V[-1]
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group(VM)" -value $V[4] 
        if($VM.StorageProfile.OsDisk.ManagedDisk){
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "OS Disk" -Value $VM.StorageProfile.OsDisk.ManagedDisk.Id.Split('/')[-1] 
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group(Disk)" -Value $VM.StorageProfile.OsDisk.ManagedDisk.Id.Split('/')[4] 
        }else{
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "OS Disk" -Value $VM.StorageProfile.OsDisk.Vhd.Uri 
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group(Disk)" -Value '' 
        }
        if($VM.DiagnosticsProfile.BootDiagnostics.StorageUri){
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "BootDiag Storage" -Value $VM.DiagnosticsProfile.BootDiagnostics.StorageUri.Split('/')[2].Split('.')[0]
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group(BootDiag)" -Value ''
        }
        if($NIC.NetworkSecurityGroup){
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "NSG" -Value $NIC.NetworkSecurityGroup.Id.Split('/')[-1]
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group(NSG)" -Value $NIC.NetworkSecurityGroup.Id.Split('/')[4]
        }
        if($NIC.IpConfigurations[0].PublicIpAddress){
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Public IP" -Value $NIC.IpConfigurations[0].PublicIpAddress.Id.Split('/')[-1]
            Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group(PubIP)" -Value $NIC.IpConfigurations[0].PublicIpAddress.Id.Split('/')[4]
        }

    }        
    $i = $Global:VMVnetMap.Add($csvObject)
}

}

###### Resource Groups (Function #12) ########################
Function Function-ResourceGroups(){

Write-Host "`n> Checking Resource Groups...`n" -ForegroundColor Green
$Global:ResourceGroups = [System.Collections.ArrayList]::new()
$RGs = Get-AzResourceGroup

$Resources = Get-AzResource | Select Name, Type, ResourceGroupName
$RGroups = ($Resources | Select ResourceGroupName) | ConvertTo-Csv | Group | Select Name, Count -Skip 2
$Hash6 = @{}
foreach( $Element in $RGroups ){$Hash6.Add($Element.Name.Replace('"',''), $Element.Count)}

foreach($RG in $RGs){
    $csvObject = New-Object PSObject
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group" -value $RG.ResourceGroupName
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Location" -value $RG.Location
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Count" -value $Hash6.($RG.ResourceGroupName)
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group ID" -value $RG.ResourceId   
    
    $i = $Global:ResourceGroups.Add($csvObject)
    }

}

###### Check all NSGs and their rules(Function #13) ##########
Function Function-NetworkSecurityGroups(){

    Write-Host "`n> Checking Network Security Groups...`n" -ForegroundColor Green
    $Global:NetworkSecurityGroups = [System.Collections.ArrayList]::new()
    $NSGs = Get-AzNetworkSecurityGroup

    foreach($NSG in $NSGs){

        $csvObject = New-Object PSObject

        Add-Member -inputObject $csvObject -memberType NoteProperty -name "NSG Name" -value $NSG.Name
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group" -value $NSG.ResourceGroupName
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Location" -value $NSG.Location
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Rule Type" -value " "
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Rule Name" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Description" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Direction" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Priority" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Protocol" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Source Port Range" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Source Address" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Destination Port Range" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Destination Address" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Source ASG" -value ""
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Destination ASG" -value ""


        $Global:NetworkSecurityGroups.Add($csvObject) | Out-Null

        foreach( $Rule in $NSG.SecurityRules ){
            $csvObject3 = New-Object PSObject
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "NSG Name" -value "..."
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Resource Group" -value ""
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Location" -value ""
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Rule Type" -value "SecurityRules"
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Rule Name" -value $Rule.Name
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Description" -value $Rule.Description
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Direction" -value $Rule.Direction
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Priority" -value $Rule.Priority
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Protocol" -value $Rule.Protocol
            $sourcePorts = $Rule.SourcePortRange[0]+" "+$Rule.SourcePortRange[1]+" "+$Rule.SourcePortRange[2]+" "+$Rule.SourcePortRange[3]+" "+$Rule.SourcePortRange[4]+" "+$Rule.SourcePortRange[5]
            $sourceAddress = $Rule.SourceAddressPrefix[0]+" "+$Rule.SourceAddressPrefix[1]+" "+$Rule.SourceAddressPrefix[2]+" "+$Rule.SourceAddressPrefix[3]+" "+$Rule.SourceAddressPrefix[4]+" "+$Rule.SourceAddressPrefix[5]
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Source Port Range" -value $sourcePorts
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Source Address" -value $sourceAddress
            $destPorts = $Rule.DestinationPortRange[0]+" "+$Rule.DestinationPortRange[1]+" "+$Rule.DestinationPortRange[2]+" "+$Rule.DestinationPortRange[3]+" "+$Rule.DestinationPortRange[4]+" "+$Rule.DestinationPortRange[5]
            $destAddress = $Rule.DestinationAddressPrefix[0]+" "+$Rule.DestinationAddressPrefix[1]+" "+$Rule.DestinationAddressPrefix[2]+" "+$Rule.DestinationAddressPrefix[3]+" "+$Rule.DestinationAddressPrefix[4]+" "+$Rule.DestinationAddressPrefix[5]
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Destination Port Range" -value $destPorts
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Destination Address" -value $destAddress
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Source ASG" -value $Rule.SourceApplicationSecurityGroups[0].Id
            Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Destination ASG" -value $Rule.DestinationApplicationSecurityGroups[0].id
        
            $Global:NetworkSecurityGroups.Add($csvObject3) | Out-Null
        }

        foreach( $Rule in $NSG.DefaultSecurityRules ){
            $csvObject2 = New-Object PSObject
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "NSG Name" -value "..."
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Resource Group" -value ""
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Location" -value ""
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Rule Type" -value "DefaultSecurityRules"
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Rule Name" -value $Rule.Name
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Description" -value $Rule.Description
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Direction" -value $Rule.Direction
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Priority" -value $Rule.Priority
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Protocol" -value $Rule.Protocol
            $sourcePorts = $Rule.SourcePortRange[0]+" "+$Rule.SourcePortRange[1]+" "+$Rule.SourcePortRange[2]+" "+$Rule.SourcePortRange[3]+" "+$Rule.SourcePortRange[4]+" "+$Rule.SourcePortRange[5]
            $sourceAddress = $Rule.SourceAddressPrefix[0]+" "+$Rule.SourceAddressPrefix[1]+" "+$Rule.SourceAddressPrefix[2]+" "+$Rule.SourceAddressPrefix[3]+" "+$Rule.SourceAddressPrefix[4]+" "+$Rule.SourceAddressPrefix[5]
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Source Port Range" -value $sourcePorts
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Source Address" -value $sourceAddress
            $destPorts = $Rule.DestinationPortRange[0]+" "+$Rule.DestinationPortRange[1]+" "+$Rule.DestinationPortRange[2]+" "+$Rule.DestinationPortRange[3]+" "+$Rule.DestinationPortRange[4]+" "+$Rule.DestinationPortRange[5]
            $destAddress = $Rule.DestinationAddressPrefix[0]+" "+$Rule.DestinationAddressPrefix[1]+" "+$Rule.DestinationAddressPrefix[2]+" "+$Rule.DestinationAddressPrefix[3]+" "+$Rule.DestinationAddressPrefix[4]+" "+$Rule.DestinationAddressPrefix[5]
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Destination Port Range" -value $destPorts
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Destination Address" -value $destAddress
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Source ASG" -value $Rule.SourceApplicationSecurityGroups[0].Id
            Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Destination ASG" -value $Rule.DestinationApplicationSecurityGroups[0].id
            
            $Global:NetworkSecurityGroups.Add($csvObject2) | Out-Null
        }

    }
}

###### Check Private Endpoints (Function #14) ##########
Function Function-PrivateEndpoints(){

Write-Host "`n> Checking Private Endpoints...`n" -ForegroundColor Green
$Global:PvtEndPointX = [System.Collections.ArrayList]::new()
$PrivateEndpoints = Get-AzPrivateEndpoint

foreach($PvtEndPoint in $PrivateEndpoints){
    
    $csvObject = New-Object PSObject
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Private Endpoint" -value $PvtEndPoint.Name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource Group" -value $PvtEndPoint.ResourceGroupName
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Location" -value $PvtEndPoint.Location
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Linked Resource" -value $PvtEndPoint.PrivateLinkServiceConnections[0].PrivateLinkServiceId
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Sub Resource Type" -value $PvtEndPoint.PrivateLinkServiceConnections[0].GroupIds[0]
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Subnet" -value $PvtEndPoint.Subnet.Id
    
    $nic = Get-AzNetworkInterface -ResourceId $PvtEndPoint.NetworkInterfaces[0].Id

    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Private IP" -value $nic.IpConfigurations[0].PrivateIpAddress
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "NIC" -value $PvtEndPoint.NetworkInterfaces[0].Id

    $Global:PvtEndPointX.Add($csvObject) | Out-Null
    }

}


#Fetch Service Quota Function
Function Function-ServiceQuota(){

$Locations = [System.Collections.ArrayList]::new()
$Location = Get-AzResource | select Location -Unique
for($i=0; $i -lt $Location.Count; $i++){
    if($Location[$i].Location -eq "global"){}
    else{[void] $Locations.Add($Location[$i].Location)}
}

$Global:ServiceQuota = [System.Collections.ArrayList]::new()

foreach($loc in $Locations){
# Retrieve Compute quota
$ComputeQuota = Get-AzVMUsage -Location $loc | Select-Object -Property Name, CurrentValue, Limit
$ComputeQuota | ForEach-Object {
    if (-not $_.Name.LocalizedValue) {$_.Name = $_.Name.Value -creplace '(\B[A-Z])', ' $1'}
    else {$_.Name = $_.Name.LocalizedValue}
}

Write-Host "`n> Checking Compute Quota : " $loc -ForegroundColor Green

foreach($quota in $ComputeQuota){
if($quota.CurrentValue -eq 0){}
else{
    $csvObject = New-Object PSObject
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Region" -value $loc
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Type" -value "Compute"
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Resource type" -value $quota.Name
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Current value" -value $quota.CurrentValue
    Add-Member -inputObject $csvObject -memberType NoteProperty -name "Limit" -value $quota.Limit
    [void] $Global:ServiceQuota.Add($csvObject)
    }
}



<# Retrieve Storage quota
$StorageQuota = Get-AzStorageUsage -Location $loc | Select-Object -Property Name, CurrentValue, Limit
Write-Host "`nChecking Storage Quota : " $loc
foreach($quota in $StorageQuota){
if($quota.CurrentValue -eq 0){}
else{
    $csvObject2 = New-Object PSObject
    Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Region" -value $loc
    Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Type" -value "Storage"
    Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Resource type" -value $quota.Name
    Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Current value" -value $quota.CurrentValue
    Add-Member -inputObject $csvObject2 -memberType NoteProperty -name "Limit" -value $quota.Limit
    [void] $Global:ServiceQuota.Add($csvObject2)
    }
} #>



<# Retrieve Network quota
$NetworkQuota = Get-AzNetworkUsage -Location $loc | Select-Object ResourceType, CurrentValue, Limit
Write-Host "`nChecking Network Quota : " $loc
foreach($quota in $NetworkQuota){
if($quota.CurrentValue -eq 0){}
else{
    $csvObject3 = New-Object PSObject
    Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Region" -value $loc
    Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Type" -value "Network"
    Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Resource type" -value $quota.ResourceType
    Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Current value" -value $quota.CurrentValue
    Add-Member -inputObject $csvObject3 -memberType NoteProperty -name "Limit" -value $quota.Limit
    [void] $Global:ServiceQuota.Add($csvObject3)
    }
} #>
}

}

#Role Assignment Function
Function Function-RoleAssignments(){
    
    Write-Host "`n> Checking IAM Role Assignments...`n" -ForegroundColor Green
    $Global:RoleAssignments = [System.Collections.ArrayList]::new()   
    $RoleAssignment = Get-AzRoleAssignment -Scope ("/subscriptions/"+$global:SourceSubscription ) 

    foreach($role in $RoleAssignment){
        $csvObject = New-Object PSObject        
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Display Name" -value $role.DisplayName
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "SignIn Name" -value $role.SignInName
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Object Type" -value $role.ObjectType
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Object ID" -value $role.ObjectId
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Role" -value $role.RoleDefinitionName
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "RoleDefinition ID" -value $role.RoleDefinitionId
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Scope" -value $role.Scope
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "Description" -value $role.Description
        Add-Member -inputObject $csvObject -memberType NoteProperty -name "CanDelegate" -value $role.CanDelegate
        
        $Global:RoleAssignments.Add($csvObject) | Out-Null
    }

}

# 4:Assessment GUI
Function AssessAzResources(){

Select-AzSubscription -Tenant $global:TenantID -Subscription $global:SourceSubscription | Out-Host

[xml]$XAML = @"
 <Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"

        Title=" Azure resources" Height="430" Width="645">
    <Grid>
        <Label Name="label" Content="Tenant ID : " HorizontalAlignment="Left" Margin="70,20,0,0" VerticalAlignment="Top" Width="400"/>
        <Button Name="Icon2" Content="Icon" HorizontalAlignment="Left" Margin="25,23,0,0" VerticalAlignment="Top" Height ="31" Width="34" />
        <Button Name="Icon3" Content="Icon" HorizontalAlignment="Left" Margin="25,60,0,0" VerticalAlignment="Top" Height ="31" Width="34" />
        <Label Name="label2" Content="Subscription ID : " HorizontalAlignment="Left" Margin="70,43,0,0" VerticalAlignment="Top" Width="400"/>
        <Label Name="label3" Content="Subscription Name : " HorizontalAlignment="Left" Margin="70,66,0,0" VerticalAlignment="Top" Width="400" />
        
        <Button Name="Button1" Content="Movable Resources" HorizontalAlignment="Left" Margin="25,120,0,0" VerticalAlignment="Top" Height ="30" Width="150"/>
        <Button Name="Button2" Content="Virtual Machines" HorizontalAlignment="Left" Margin="229,120,0,0" VerticalAlignment="Top" Height ="30" Width="135"/>
        <Button Name="Icon4" Content="Icon" HorizontalAlignment="Left" Margin="195,119,0,0" VerticalAlignment="Top" Height ="31" Width="34" />
        <Button Name="Button3" Content="Classic Virtual Machines" HorizontalAlignment="Left" Margin="420,120,0,0" VerticalAlignment="Top" Height ="30" Width="145"/>
        <Button Name="Icon5" Content="Icon" HorizontalAlignment="Left" Margin="386,119,0,0" VerticalAlignment="Top" Height ="31" Width="34" />

        <Button Name="Button4" Content="App Service Plans and App Services" HorizontalAlignment="Left" Margin="59,165,0,0" VerticalAlignment="Top" Height ="30" Width="225"/>
        <Button Name="Icon6" Content="Icon" HorizontalAlignment="Left" Margin="25,164,0,0" VerticalAlignment="Top" Height ="32" Width="34" />
        <Button Name="Icon7" Content="Icon" HorizontalAlignment="Left" Margin="310,164,0,0" VerticalAlignment="Top" Height ="31" Width="34" />
        <Button Name="Button5" Content="App Service TLS/SSL Bindings" HorizontalAlignment="Left" Margin="344,164,0,0" VerticalAlignment="Top" Height ="30" Width="220"/>
        
        <Button Name="Button6" Content="Managed Disks" HorizontalAlignment="Left" Margin="59,220,0,0" VerticalAlignment="Top" Height ="30" Width="115"/>
        <Button Name="Icon8" Content="Icon" HorizontalAlignment="Left" Margin="25,220,0,0" VerticalAlignment="Top" Height ="31" Width="34" />
        <Button Name="Button7" Content="Public IP Addresses" HorizontalAlignment="Left" Margin="229,220,0,0" VerticalAlignment="Top" Height ="30" Width="135"/>
        <Button Name="Icon9" Content="Icon" HorizontalAlignment="Left" Margin="195,220,0,0" VerticalAlignment="Top" Height ="31" Width="34" />
        <Button Name="Button8" Content="Virtual Network Peerings" HorizontalAlignment="Left" Margin="420,220,0,0" VerticalAlignment="Top" Height ="30" Width="145"/>
        <Button Name="Icon10" Content="Icon" HorizontalAlignment="Left" Margin="386,220,0,0" VerticalAlignment="Top" Height ="31" Width="34" />

        <Button Name="Button9" Content="Load Balancers" HorizontalAlignment="Left" Margin="59,265,0,0" VerticalAlignment="Top" Height ="30" Width="115"/>
        <Button Name="Icon11" Content="Icon" HorizontalAlignment="Left" Margin="25,265,0,0" VerticalAlignment="Top" Height ="31" Width="34" /> 
        <Button Name="Button10" Content="Recovery Service Vaults" HorizontalAlignment="Left" Margin="229,266,0,0" VerticalAlignment="Top" Height ="30" Width="135"/>
        <Button Name="Icon12" Content="Icon" HorizontalAlignment="Left" Margin="195,266,0,0" VerticalAlignment="Top" Height ="31" Width="34" />
        <Button Name="Button11" Content="VM Dependencies" HorizontalAlignment="Left" Margin="420,266,0,0" VerticalAlignment="Top" Height ="30" Width="145"/>
        <Button Name="Icon13" Content="Icon" HorizontalAlignment="Left" Margin="385,265,0,0" VerticalAlignment="Top" Height ="30" Width="34" />

        <Button Name="ButtonX" Content="Download Assessment Report" HorizontalAlignment="Left" Margin="25,335,0,0" VerticalAlignment="Top" Height ="26" Width="220"/>
        <Button Name="BackButton" Content="Go back" HorizontalAlignment="Left" Margin="270,335,0,0" VerticalAlignment="Top" Height ="26" Width="95"/>
        <Button Name="CancelButton" Content="Exit" HorizontalAlignment="Left" Margin="450,335,0,0" VerticalAlignment="Top" Height ="26" Width="112"/>
    </Grid>
</Window>
 
"@

#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader"; exit}
 
# Store Form Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

#$handler_DownloadButton_Click = {Write-Host "Download"}

$label.Content="Tenant ID :   "+$global:TenantID
$label2.Content="Subscription ID :   "+$global:SourceSubscription
$label3.Content="Subscription Name :   "+$global:SourceSubName

for($i=2; $i -le 13; $i++){
    $image = New-Object System.Windows.Controls.Image
    $image.Source = "https://paygassessmentcsp.blob.core.windows.net/azicons\$i.PNG"
    $image.Stretch = 'Fill'
    $IconX = Get-Variable -Name Icon$i -ValueOnly
    $IconX.Content = $image
    $IconX.BorderThickness = New-object System.Windows.Thickness(0,0,0,0)
    Set-Variable -Name Icon$i -Value $IconX
}


$Button1.add_Click({Function-Assessment; if($Global:RSx){$Global:RSx | Out-GridView -Title "Movable Resources"}else{ Write-Host "No resource found..." -ForegroundColor Red}})
$Button2.add_Click({Function-CheckMarketPlaceVM; if($Global:VMx){$Global:VMx | Out-GridView -Title "Virtual Machines"}else{Write-Host "No Virtual Machine found..." -ForegroundColor Red}})
$Button3.add_Click({Function-CheckClassicVirtualMachine; if($Global:ClassicVMx){$Global:ClassicVMx | Out-GridView -Title "Classic Virtual Machines"}else{Write-Host "No Classic VM found..." -ForegroundColor Red}})
$Button4.add_Click({Function-CheckAppServiceAndPlan; if($Global:AppPlanx){$Global:AppPlanx | Out-GridView -Title "App Services"}else{Write-Host "No App Service found..." -ForegroundColor Red}})
$Button5.add_Click({Function-CheckAppServiceCertBinding; if($Global:BinDx){$Global:BinDx | Out-GridView  -Title "App Service SSL Bindings"}else{Write-Host "No SSL-Binding found..." -ForegroundColor Red}})
$Button6.add_Click({Function-CheckManagedDisk; if($Global:Diskx){$Global:Diskx | Out-GridView -Title "Disks"}else{Write-Host "No Disk found..." -ForegroundColor Red}})
$Button7.add_Click({Function-CheckIPAddress; if($Global:IPx){$Global:IPx | Out-GridView -Title "Public IPs"}else{Write-Host "No Public IP Address found..." -ForegroundColor Red}})
$Button8.add_Click({Function-CheckVNETPeering; if($Global:VNetx){$Global:VNetx | Out-GridView -Title "VNet Peerings"}else{Write-Host "No Virtual Network found..." -ForegroundColor Red}})
$Button9.add_Click({Function-CheckLoadBalancers; if($Global:LBx){$Global:LBx | Out-GridView -Title "Load Balancers"}else{Write-Host "No Load Balancer found..." -ForegroundColor Red}})
$Button10.add_Click({Function-CheckRecoveryserviceVaults; if($Global:RSVx){$Global:RSVx | Out-GridView -Title "Recovery Service Vaults"}else{Write-Host "No Recovery Service Vault found..." -ForegroundColor Red}})
$Button11.add_Click({Function-CheckVMDependency; if($Global:VMVnetMap){$Global:VMVnetMap | Select 'Virtual Network','NIC',"Virtual Machine","Resource Group(VNet)","Resource Group(NIC)","Resource Group(VM)","Resource Group(Disk)","Resource Group(NSG)","Resource Group(PubIP)","Resource Group(BootDiag)","OS Disk","Public IP","NSG","BootDiag Storage" | Out-GridView -Title "VM Dependencies" }else{Write-Host "No VNet, VM, NIC found..." -ForegroundColor Red}})

$ButtonX.add_Click({$Form.close(); Save-AssessmentReport})
$BackButton.add_Click({$Form.close(); LoadSubscriptionForm})
$CancelButton.add_Click({$Form.close()})

$Form.ShowDialog() | out-null    
}


# 3:Logout and Login as different user 
Function DisconnectAz()
{
    $D = Disconnect-AzAccount
    Write-Host "`n`n"$D.Id " : Successfully logged out..." -ForegroundColor Cyan
    $D | Out-Host
    LoginToAzure
}


# 2:Load Subscription Form 
Function LoadSubscriptionForm(){

$global:SourceSubscription = ''
$global:SourceSubName = ''
$global:TenantID = ''

[xml]$XAML = @"
 <Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"

        Title=" Azure resource assessment" Height="370" Width="550">
    <Grid>
        <Label Name="label" Content="Select Tenant ID :" HorizontalAlignment="Left" Margin="20,20,0,0" VerticalAlignment="Top" Width="132"/>
        <ComboBox Name="DropDown" HorizontalAlignment="Left" Margin="25,50,0,0" VerticalAlignment="Top" Width="420"/>
        <Button Name="TenantIcon" Content="Icon" HorizontalAlignment="Left" Margin="447,49,0,0" VerticalAlignment="Top" Height ="24" Width="30" />
        <Button Name="SubButton" Content="Load Subscriptions" HorizontalAlignment="Left" Margin="25,80,0,0" VerticalAlignment="Top" Height ="22" Width="130"/>
        <Button Name="UserIcon" Content="Icon" HorizontalAlignment="Left" Margin="25,121,0,0" VerticalAlignment="Top" Height ="24" Width="27" />
        <Label Name="label2" Content="Current User : " HorizontalAlignment="Left" Margin="52,120,0,0" VerticalAlignment="Top" Width="380"/>
        <Label Name="label3" Content="Select Subscription :" HorizontalAlignment="Left" Margin="20,160,0,0" VerticalAlignment="Top" Width="250" />
        <Label Name="label4" Content="" HorizontalAlignment="Left" Margin="335,160,0,0" VerticalAlignment="Top" Width="250" />
        <ComboBox Name="DropDown1" HorizontalAlignment="Left" Margin="25,190,0,0" VerticalAlignment="Top" Width="420"/>
        <Button Name="SubIcon" Content="Icon" HorizontalAlignment="Left" Margin="447,189,0,0" VerticalAlignment="Top" Height ="24" Width="30" />
        <Button Name="OKButton" Content="Proceed" HorizontalAlignment="Left" Margin="25,260,0,0" VerticalAlignment="Top" Height ="24" Width="100"/>
        <Button Name="CancelButton" Content="Exit" HorizontalAlignment="Left" Margin="170,260,0,0" VerticalAlignment="Top" Height ="24" Width="100"/>
        <Button Name="DiscntButton" Content="Login as a different user" HorizontalAlignment="Left" Margin="310,260,0,0" VerticalAlignment="Top" Height ="24" Width="163"/>
    </Grid>
</Window>
 
"@

#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader"; exit}
 
# Store Form Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

$image = New-Object System.Windows.Controls.Image
$image.Source = "https://paygassessmentcsp.blob.core.windows.net/azicons/2.PNG"
$image.Stretch = 'Fill'
$TenantIcon.Content = $image
$TenantIcon.BorderThickness = New-object System.Windows.Thickness(0,0,0,0)

$image1 = New-Object System.Windows.Controls.Image
$image1.Source = "https://paygassessmentcsp.blob.core.windows.net/azicons/3.PNG"
$image1.Stretch = 'Fill'
$SubIcon.Content = $image1
$SubIcon.BorderThickness = New-object System.Windows.Thickness(0,0,0,0)

$image2 = New-Object System.Windows.Controls.Image
$image2.Source = "https://paygassessmentcsp.blob.core.windows.net/azicons/1.PNG"
$image2.Stretch = 'Fill'
$UserIcon.Content = $image2
$UserIcon.BorderThickness = New-object System.Windows.Thickness(0,0,0,0)

$handler_Okbutton_Click = {$Form.Close(); AssessAzResources}
$handler_disCntButton_Click = {$Form.Close(); DisconnectAz}
$handler_LoadSubButton_Click = {
    $SubButton.IsEnabled = $false
    $Subscriptions = Get-AzSubscription -TenantId $global:TenantID
    $Subscriptions | Format-Table | Out-Host
    ForEach ($Item in $Subscriptions) {
        [void] $DropDown1.Items.Add($Item.Name+' | '+$Item.Id)
    }
    $DropDown1.IsEnabled = $true
    #$label4.Content = "[ Subscriptions loading... ]"
    $label4.Content = "[ Subscriptions found : "+$Subscriptions.count +" ]" 
    $label4.Foreground = "#FF4500"  
}
$handler_TenantSelect_Click = {
    $global:TenantID = $DropDown.SelectedItem.Split(':')[0]
    Write-Host "`n`nSelected Tenant : "$global:TenantID -ForegroundColor Green
    $SubButton.IsEnabled = $true
}

$handler_SubSelect_Click = {
    $global:SourceSubscription = $DropDown1.SelectedItem.Split('|')[1].remove(0,1)
    $global:SourceSubName = $DropDown1.SelectedItem.Split('|')[0]
    Write-Host "`nSelected Subscription :"$global:SourceSubscription -ForegroundColor Green
    $OKButton.IsEnabled = $true
}

$label2.Content = ('Logged In :  '+$global:User)
$SubButton.IsEnabled = $false
$DropDown1.IsEnabled = $false
$OKButton.IsEnabled = $false
$DiscntButton.Foreground = "#0000CC" 
ForEach ($Item in $global:Tenants) { 
        $TenantNameID = $Item.Id +" : " + $Item.Name
        [void] $DropDown.Items.Add($TenantNameID)
}

$SubButton.add_click($handler_LoadSubButton_Click)
$DropDown.add_SelectionChanged($handler_TenantSelect_Click)
$DropDown1.add_SelectionChanged($handler_SubSelect_Click)
$DiscntButton.add_Click($handler_disCntButton_Click)
$CancelButton.add_Click({$Form.Close()})
$OKButton.add_click($handler_Okbutton_Click)

$Form.ShowDialog() | out-null
}


# 1:Login to Azure
Function LoginToAzure()   
{
    $Context = Get-AzContext
    $global:Tenants = Get-AzTenant | Select ID, Name

    if($Context){
        #$global:Tenants = $Context.Account.Tenants
        $global:User = $Context.Account.Id
    }
    else{
        Write-Host "`nPlease enter credentials to log in..." -ForegroundColor Yellow
        $Conn = Connect-AzAccount -Force -ErrorAction Stop
        $Conn | Out-Host
        $global:User = $Conn.Context.Account.Id
    }
    LoadSubscriptionForm
}


Function QuickAssess()
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$myTenantID,

        [Parameter(Mandatory=$true, Position=1)]
        [string]$mySubscriptionID
    )
    
    $Context = Get-AzContext 

    if($Context.Tenant.TenantId -eq $myTenantID){
        $global:User = $Context.Account.Id
        $global:SourceSubscription = $mySubscriptionID
        Select-AzSubscription -Subscription $mySubscriptionID -Tenant $myTenantID -Verbose -ErrorAction Stop
        Save-AssessmentReport
    }
    else{
        Write-Host "`nPlease enter credentials to log in..." -ForegroundColor Yellow
        $Conn = Connect-AzAccount -Tenant $myTenantID -Subscription $mySubscriptionID -ErrorAction Stop
        $Conn | Out-Host
        $global:User = $Conn.Context.Account.Id
        $global:SourceSubscription = $mySubscriptionID
        Save-AssessmentReport
    }
}


$timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
$logfile = "C:\Users\" +$env:USERNAME+ "\Desktop\AssesmentToolLog "+$timestamp+".log"
Start-Transcript -Path $logfile 
Get-Date


$title    = 'Azure resource assessment:'
$question = "`n`tDo you want a quick assessment?`n"

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

if ($decision -eq 0) {
    
    $mytenant = Read-Host "`nPlease enter the Tenant ID "  
    $mysubscription = Read-Host 'Please enter the Subscription ID ' 
    
    # Call the quick assessment function
    QuickAssess $mytenant $mysubscription

} else {
    
    # Call the start function
    LoginToAzure
}
