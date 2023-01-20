#THIS IS USED TO INSTALL APPLICATION IN VM
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco uninstall googlechrome -y  
choco uninstall git.install -y
# choco install dotnet --version=5.0.11 -y 
# choco install dotnet-sdk --pre -y
# choco install visualstudio2019community -y
# choco uninstall visualstudio2019community -y
# choco install vscode -y
# choco install notepadplusplus -y