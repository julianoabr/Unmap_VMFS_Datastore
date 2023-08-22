$fileSuffix = Read-Host -Prompt "Enter File Suffix"

$password = Read-Host -prompt "Enter your Password"

Write-Host "$password is password" -ForegroundColor White -BackgroundColor Red

$secure = ConvertTo-SecureString $password -AsPlainText -Force

ConvertFrom-SecureString -SecureString $secure | Out-File ".\$fileSuffix-EncryptPWD.txt"
