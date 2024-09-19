#BEFORE USING MAIN SCRIPT YOU HAVE TO RUN THIS TO CREATE
#1. AES.KEY
#2. SAVE YOUR DOMAIN CRED
#3. CREATE CRED TO USE IN YOUR SCRIPT

#1. Create KEY
$Key = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | Out-File -FilePath "$env:SystemDRive\Encrypt\aes.key"


#2. Create Credential using AES KEY
(get-credential).Password | ConvertFrom-SecureString -key (Get-Content "$env:SystemDRive\Encrypt\aes.key") | Set-Content "$env:SystemDRive\Encrypt\domain-password.txt"



#3.Using Password with Script
$userName = 'domain\user'
$password = Get-Content "$env:SystemDRive\Encrypt\domain-password.txt" | ConvertTo-SecureString -Key (Get-Content "$env:SystemDRive\Encrypt\aes.key")
$credential = New-Object System.Management.Automation.PsCredential($username,$password)