[CmdletBinding()]
Param(
    # Service name to install
    [Parameter(Mandatory=$true)]
    [string]
    $serviceName,
    # Path to executable
    [Parameter(Mandatory=$true)]
    [string]
    $binaryPath,
    # Username to register service
    [Parameter(Mandatory=$true)]
    [string]
    $login,
    # Password to register service
    [Parameter(Mandatory=$true)]
    [string]
    $pass

)


#debugging purpose only
#$serviceName = "mytemp-Service"

function ReinstallService1 ($serviceName, $binaryPath, $login, $pass)
{  
    Write-Host "installing service"
    # creating credentials which can be used to run my windows service
    $secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($login, $secpasswd)

    # creating widnows service using all provided parameters
    New-Service -name $serviceName -binaryPathName $binaryPath -displayName $serviceName -startupType Automatic -credential $mycreds
    Write-Host "installation completed"
}

if (Get-Service $serviceName -ErrorAction SilentlyContinue)
{
    $serviceToRemove = Get-WmiObject -Class Win32_Service -Filter "name='$serviceName'"
    $serviceToRemove.delete()
    Write-Host "service removed"
    ReinstallService1 -serviceName $serviceName -binaryPath $binaryPath -login $login -pass $pass
}
else
{
    Write-Host "Service does not exists installing"
    ReinstallService1 -serviceName $serviceName -binaryPath $binaryPath -login $login -pass $pass
}

