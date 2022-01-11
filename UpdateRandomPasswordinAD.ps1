<#

Author - Rakesh Sharma
Description - Rotate the password of Service Account every 30 Days
1>Generate a Random Password
2>Save the password in text file
3>Update the password in AD
4>Update the password\secret value in Key Vault
Note:- This script has only been tested in simulated test enviornment, it is highly recomended to verify,update and test the script accordingly before hitting production.
#>

Install-Module Azure
Install-Module Microsoft.PowerShell.SecretManagement
Install-Module Microsoft.PowerShell.SecretStore
Install-Module AzureRM.KeyVault
Install-Module Az.KeyVault.


Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore
Import-Module AzureRM.KeyVault
Import-Module Az.KeyVault

Add-Type -AssemblyName 'System.Web'
$minLength = 5 ## characters
$maxLength = 10 ## characters
$length = Get-Random -Minimum $minLength -Maximum $maxLength
$nonAlphaChars = 5
$password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)
$secPw = ConvertTo-SecureString -String $password -AsPlainText -Force

function New-RandomPassword {
    param(
        [Parameter()]
        [int]$MinimumPasswordLength = 5,
        [Parameter()]
        [int]$MaximumPasswordLength = 10,
        [Parameter()]
        [int]$NumberOfAlphaNumericCharacters = 5,
        [Parameter()]
        [switch]$ConvertToSecureString
    )
    
    Add-Type -AssemblyName 'System.Web'
    $length = Get-Random -Minimum $MinimumPasswordLength -Maximum $MaximumPasswordLength
    $password = [System.Web.Security.Membership]::GeneratePassword($length,$NumberOfAlphaNumericCharacters)
    
    if ($ConvertToSecureString.IsPresent) {
        ConvertTo-SecureString -String $password -AsPlainText -Force
        clear-Content -Path "C:\MyDocuments\PWD\Password.txt"
        add-Content -Path "C:\MyDocuments\PWD\Password.txt" -Value $password 
        Write-Host $password

    } else {
        $password
        ##Write-Host $password
    }
}

##Function Call
New-RandomPassword -MinimumPasswordLength 10 -MaximumPasswordLength 15 -NumberOfAlphaNumericCharacters 6 -ConvertToSecureString
$password2set =get-Content "C:\MyDocuments\PWD\Password.txt"
Write-Host "Reading from File = "$password2set

##UnComment and modify parameters to this Code to update password in AD

##*****

Set-ADAccountPassword -Identity 'CN=Rakesh-Demo,OU=Accounts,DC=xxxx,DC=com' -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password2set -Force)

##*****

Login-AzureRmAccount 
$VaultName = "rskeyvaulttest"
$SecretName = "rakshar"
$NewSecret = ConvertTo-SecureString -String $password2set -AsPlainText -Force
$ContentType = 'txt'
Set-AzureKeyVaultSecret -VaultName $VaultName -Name $SecretName -SecretValue $NewSecret -ContentType $ContentType -Tags $Tags