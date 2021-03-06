# Agents - Get ID
# for Ivanti Security Controls
# version 2020-11.12
#
# Changelog
# 2019-12: First version
# 2020-11: update for use of encrypted passwords
#
# patrick.kaak@ivanti.com
# @pkaak

#Body variables
$AgentName = '$[AgentName]'
$IIDoutput = '$[IIDOutput]'

#User variables
$username = Get-ResParam -Name Username #ISeC Credential Username
$password = Get-ResParam -Name Password #ISeC Credential password
$servername = '^[ISeC Servername]' #ISeC console servername
$serverport = '^[ISeC REST API portnumber]' #ISeC REST API portnumber

#System variables
$EncryptPassword = $password
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $EncryptPassword


######################################################################################################################################
## Get AgentID and Status

$url = 'https://'+$servername+':'+$serverport+'/st/console/api/v1.0/agents?name='+$AgentName

#Speak to ISeC REST API

try 
{
  $result = Invoke-RestMethod -Method Get -Credential $cred -Uri $url -ContentType 'application/json' | ConvertTo-Json -Depth 99
}
catch 
{
  # Dig into the exception to get the Response details.
  # Note that value__ is not a typo.
  Write-Host -Object 'Error (GetAgentID)'
  Write-Host 'StatusCode:' $_.Exception.Response.StatusCode.value__ 
  Write-Host 'StatusDescription:' $_.Exception.Response.StatusDescription
  Write-Host 'Error Message:' $_.ErrorDetails.Message
  exit(1)
}
  
#REST API was OK. Go futher
$result = ConvertFrom-Json -InputObject $result

#Results
if ( $result.count -ne 1 ) 
{
  Write-Host -Object 'Error: Agent not found'
}
else 
{
  $global:AgentID = $result.value.AgentID #Set AgentID to Automation
  
  #AgentStatus
  
  #Output machineName, Domain, LastCheckin, IsListening

  if ($IIDoutput -eq '1') 
  {
    $output = ''
    for ($count = 0; $count -le $result.count-1; $count++) 
    {
      if ($count -eq 0) 
      {
        $output = $result.value[$count].machineName +';'+ $result.value[$count].Domain +';'+ [datetime]$result.value[$count].lastCheckIn +';'+ $result.value[$count].isListening
      }
      else 
      {
        $output = $output +'|'+ $result.value[$count].machineName +';'+ $result.value[$count].Domain +';'+ [datetime]$result.value[$count].lastCheckIn +';'+ $result.value[$count].isListening
      }
    }
    $output
  }
  else 
  {
    $result.value | Format-Table -Property machineName, domain, lastCheckIn, isListening
  }
}
