# Author: Dave Davis
# Website: www.virtualizestuff.com

function New-NsxtParentPort{
    [CmdLetBinding()]
     param (
        [Parameter (Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)]
            [ValidateNotNullOrEmpty()]
            $VmName,
            [Parameter (Mandatory=$False)]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]$Connection=$global:defaultNsxtServers
            )
     begin 
     {
        if (-not $global:DefaultNsxtServers.isconnected)
        {
            try
            {
                Connect-NsxtServer -Menu -ErrorAction Stop
            }

            catch
            {
                throw "Could not connect to an NSX-T Manager, please try again"
            }
        }
        # I was having issues getting attachment.context to work using the Get-NsxtService method so resorted to Invoke-Restmethod as a workaround. This does require the credentials again for NSX-T Manager :(
        [System.Management.Automation.PSCredential]$global:cred = $(Get-Credential -Message "NSX-T credentials, please!")
        $vmService = Get-NsxtService -Name com.vmware.nsx.fabric.virtual_machines
     }
     process 
     {
        Foreach ($vm in $VmName){
            $virtualmachines = $vmService.list().results | Where-Object {$_.display_name -eq $vm}
            if ($virtualmachines.display_name -notcontains $vm){
                throw "Virtual Machine: $vm doesnt appear to be connected to a NSX-T logical switch. Please make sure it's connected and try again."
            }
            $lpSvc = Get-NsxtService -Name com.vmware.nsx.logical_ports 
            $logicalports = $lpSvc.list().results | Where-Object {$_.display_name -match $vm} | Sort-Object -Property "create_time"
            
            $incr = 0
            ForEach ($logicalport in $logicalports) {
                $body = [pscustomobject]@{
                resource_type = "LogicalPort"
                display_name = "p_$($logicalport.display_name)_eth$($incr)"
                attachment = @{
                attachment_type = "VIF"
                context = @{
                    resource_type = "VifAttachmentContext"
                    vif_type = "PARENT"
                }
                id = $logicalport.attachment.id
                }
                admin_state = "UP"
                logical_switch_id = $logicalport.logical_switch_id  
                _revision = 0
                } | ConvertTo-Json
    
                $URI = "$($Connection.serviceuri.absoluteUri)" + "api/v1/logical-ports/$($logicalport.id)"
                $parentVIF = Invoke-RestMethod -Authentication Basic -method "put" -uri $URI -body $body -ContentType "application/json" -SkipCertificateCheck -Credential $cred
                $incr ++
                # Parent VIFs
                $parentVIF
            } 
        }
     }
 }

 function New-NsxtChildPort{
    [CmdLetBinding()]
     param (
        [Parameter (Position=0, 
                    Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)]
            [ValidateNotNullOrEmpty()]
            [object []]$parentVIF,
        [Parameter (Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string []]$Name,
        [Parameter (Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [int []]$VLAN,
        [Parameter (Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string []]$LogicalSwitchName,
        [Parameter (Mandatory=$False)]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]$Connection=$global:defaultNsxtServers
       )
     begin {
        if (-not $global:DefaultNsxtServers.isconnected)
        {
            try
            {
                Connect-NsxtServer -Menu -ErrorAction Stop
            }

            catch
            {
                throw "Could not connect to an NSX-T Manager, please try again"
            }
        }
        
        $lsSvc = Get-NsxtService -Name com.vmware.nsx.logical_switches
        $logicalSwitches = $lsSvc.list().results
     }
     process {
        foreach ($i in $logicalSwitchName){
            if (($logicalSwitches.display_name -match $i).length -eq 1){
            }
            else{
                Write-Host "Logical Switch: $i does not exists" -ForegroundColor Red 
            }
        }
        foreach ($n in $Name)
        {
            foreach ($p in $parentVIF){
                $bodyobj = [pscustomobject]@{
                    resource_type = "LogicalPort"
                    display_name = "c_" + $n + "_vlan" + $VLAN[$Name.IndexOf($n)] + "_" + $p.display_name.split(".").split("/")[1] + "_" + $p.display_name.split("_")[-1]
                    attachment = @{
                    attachment_type = "VIF"
                    context = @{
                        resource_type = "VifAttachmentContext"
                        parent_vif_id = " "    
                        traffic_tag = $VLAN[$Name.IndexOf($n)]
                        app_id = (New-Item -Name $([System.Guid]::NewGuid().ToString())).name + "_" + $VLAN[$Name.IndexOf($n)]
                        vif_type = "CHILD"
                    }
                    id = (New-Item -Name $([System.Guid]::NewGuid().ToString())).name + "_" + $VLAN[$Name.IndexOf($n)]
                    }
                    logical_switch_id = ($logicalSwitches | Where-Object {$_.display_name -eq $LogicalSwitchName[$Name.IndexOf($n)]}).id    
                    # address binding is hardcoded but may look into pull this information in dynamically
                    address_bindings = @(
                        @{
                        mac_address = "00:00:00:00:00:00"
                        ip_address = "127.0.0.1"
                        vlan = $VLAN[$Name.IndexOf($n)]
                        }
                    )   
                    admin_state = "UP"
                }
                $bodyobj.attachment.context.parent_vif_id = $p.attachment.id
                $body = $bodyobj | ConvertTo-Json
                $URI = "$($Connection.serviceuri.absoluteUri)" + "api/v1/logical-ports/"
                Invoke-RestMethod -Authentication Basic -method "post" -uri $URI -body $body -ContentType "application/json" -SkipCertificateCheck -Credential $cred
            }                                  
        }  
     }
 }