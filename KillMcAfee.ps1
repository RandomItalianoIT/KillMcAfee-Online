$zipFile = "C:\Temp\McAfeeUninstall.zip"
$tempPath = "C:\Temp\McAfeeUninstall"
$destination = "C:\Temp\McAfeeUninstall.zip"
$mcprPath = "$tempPath\mccleanup.exe"
$logFile = "$tempPath\mccleanup.txt"
$finalLogDir = "C:\ProgramData\WeKilledtheMcAfeeVirus"
$finalLogFile = "$finalLogDir\mccleanup.txt"
$mcAfeeRegKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\McAfee.wps"
$mcAfeeMainKey = "HKLM:\SOFTWARE\McAfee"
$startMenuPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\McAfee"
$URL = 'https://github.com/RandomItalianoIT/KillMcAfee-Online/raw/refs/heads/main/McAfeeUninstall.zip'

Mkdir C:\Temp
Write-Output "Downloading McAfee Removal Tool"
Invoke-WebRequest -Uri $URL -OutFile $destination -Method Get

if (-Not (Test-Path $zipFile)) { Exit 1 }
if (-Not (Test-Path "C:\Temp")) { New-Item -ItemType Directory -Path "C:\Temp" -Force }

if (Test-Path $tempPath) {
    Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

try {
    Expand-Archive -Path $zipFile -DestinationPath $tempPath -Force
} catch { Exit 1 }

if (-Not (Test-Path $mcprPath)) { Exit 1 }

Write-Output "Attempting to uninstall McAfee"
$programArg = "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdiver,HW,MAS,MAT,MBK,MCPR,McProxy,McSvcHost,VUL,MHN,MNA,MOBK,MPFP,MPFPCU,MPS,SHRED,MPSCU,MQC,MQCCU,MSAD,MSHR,MSK,MSKCU,MWL,NMC,RedirSvc,VS,REMEDIATION,MSC,YAP,TRUEKEY,LAM,PCB,Symlink,SafeConnect,MGS,WMIRemover,RESIDUE -v -s"
Start-Process -FilePath $mcprPath -ArgumentList $programArg -Wait -NoNewWindow

if (Test-Path $mcAfeeRegKey) { Remove-Item -Path $mcAfeeRegKey -Force -ErrorAction SilentlyContinue }
if (Test-Path $mcAfeeMainKey) { Remove-Item -Path $mcAfeeMainKey -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path $startMenuPath) { Remove-Item -Path $startMenuPath -Recurse -Force }

if (-Not (Test-Path $finalLogDir)) { New-Item -ItemType Directory -Path $finalLogDir -Force }
if (Test-Path $logFile) { Move-Item -Path $logFile -Destination $finalLogFile -Force }

# **New Section: Remove McAfee Appx Packages**
Write-Output "Checking for McAfee Appx packages..."
Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*McAfee*" } | ForEach-Object { 
    try {
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction Stop
        Write-Output "Successfully removed: $($_.PackageFullName)"
    } catch {
        Write-Output "Failed to remove: $($_.PackageFullName) - Error: $_"
    }
}

# **Final Exit Check**
if (Test-Path $finalLogFile) { 
    Write-Output "McAfee removal completed successfully."
    Exit 0 
} else { 
    Write-Output "McAfee removal failed."
    Exit 1 
}
