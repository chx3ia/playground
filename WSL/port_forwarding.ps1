<#
  A PowerShell script to make port fordwarding from host to WSL.   
  Credits to:
    http://woshub.com/port-forwarding-in-windows/
    https://support.microsoft.com/en-za/help/929851/the-default-dynamic-port-range-for-tcp-ip-has-changed-in-windows-vista
    https://github.com/microsoft/WSL/issues/4150#issuecomment-504209723
#>
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

# eth0 is the default interface of WSL
$wsl_address = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $wsl_address -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found ){
    $wsl_address = $matches[0];
} else{
    echo "Error: the ip address of WSL 2 cannot be found";
    exit;
}

# parepare a array for the TCP port to forward
$ports_TCP=@(2222, 6777, 7777, 8777, 3478, 8888);

# iterate the array 
iex "netsh interface portproxy reset";
for( $i = 0; $i -lt $ports_TCP.length; $i++ ){
  $port = $ports_TCP[$i];
  iex "netsh interface portproxy add v4tov4 listenport=$port connectport=$port connectaddress=$wsl_address";
}
iex "netsh interface portproxy show v4tov4";

# rules for fordwarding UDP to WSL, the port ranges are from 50000 to 501000
iex "netsh interface ipv4 set dynamicport udp start=50000 num=1001"

# show the forwarding result 
iex "netsh interface ipv4 show dynamicport udp"
