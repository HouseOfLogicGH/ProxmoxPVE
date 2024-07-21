Param(
    [string] $proxmoxhost = "proxmoxhost.local",
    [string] $username = "username@pve",
    [string] $password = "YourPassword",
    [string] $nodename = "yournodename",
    [int]$vmid = 100
    )

if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
[ServerCertificateValidationCallback]::Ignore()




$uri = "https://" + $proxmoxhost + ":8006/api2/json/access/ticket"

$ticketrequestbody = @{
    username = $username
    password = $password
}

try
    {
    $ticketresponse = Invoke-RestMethod $uri -Method POST -Body $ticketrequestbody -ContentType 'application/x-www-form-urlencoded' -WebSession $session
    }
catch
    {
    # failure
    Write-Error "Ticket Request Failed"
    exit
    }

$ticketdata = $ticketresponse.data

$CSRFPreventionToken = $ticketdata.CSRFPreventionToken

$ticket = $ticketdata.ticket

$expirydate = (Get-Date).AddHours(12).DateTime

[string]$BaseUri     = "https://" + $proxmoxhost + ":8006/api2/json/version"

$cookie=new-object system.net.cookie
$cookie.name = "PVEAuthCookie"
$cookie.path = "/"
$cookie.value = $ticket
$cookie.domain = $proxmoxhost
$cookie.expires = $expirydate
$session=new-object microsoft.powershell.commands.webrequestsession
$session.cookies.add($cookie)

$Headers=@{
    CSRFPreventionToken = $CSRFPreventionToken

}

# get the proxmox version

try
    {
    $APIResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers  -ContentType  "application/json" -Method Get -websession $session 
    }
catch
    {
    Write-Error "API Request Failed"
    exit
    }


if( $null -ne $APIResponse )
    {
    $pveversion = $APIResponse.data.version

    }

Write-Host $pveversion


# end of connection test section

#exit

# now get vm status
$BaseUri     = "https://" + $proxmoxhost + ":8006/api2/json/nodes/" + $nodename + "/qemu/" + $vmid + "/status/current"

try
    {
    $APIResponse2 = Invoke-RestMethod -URI $BaseURI -Headers $Headers  -ContentType  "application/json" -Method Get -websession $session 
    }
catch
    {
    Write-Error "API Request Failed"
    exit
    }

$vmstatus = $null

if( $null -ne $APIResponse2 )
    {
    # need to get the qmpstatus to see if the machine is suspended or not - status will say "running" if suspended
    $vmstatus = $APIResponse2.data.qmpstatus

    }

Write-Output $vmstatus

if( $vmstatus -ne "running" )
    {
    $dostartup = $false

    if( $vmstatus -eq "paused" )
        {
        $BaseUri = "https://" + $proxmoxhost + ":8006/api2/json/nodes/" + $nodename + "/qemu/" + $vmid + "/status/resume"
        $dostartup = $true
        }
    else
        {
        if( $vmstatus -eq "stopped" )
            {
            $BaseUri = "https://" + $proxmoxhost + ":8006/api2/json/nodes/" + $nodename + "/qemu/" + $vmid + "/status/start"
            $dostartup = $true
            }
        else
            {
            Write-Warning "VM not detected as running but not in paused or stopped state - no action taken."
            }

        }


    if( $dostartup )
        {
    

        $startbody = @{
            node = $nodename
            vmid = $vmid

        }

        try
            {
            $APIResponse3 = Invoke-RestMethod -URI $BaseURI -Headers $Headers  -ContentType  "application/json" -Method POST -websession $session -Body ($startbody | ConvertTo-Json)
            }
        catch
            {
            Write-Error "API Request Failed"
            exit
            }

        if( $null -ne $APIResponse3 )
            {
            Write-Host $APIResponse3.data
            }
        }


    }
else
    {
    Write-Host "VM running - no action to take."
    }