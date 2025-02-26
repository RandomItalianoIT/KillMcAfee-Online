$zipFile = ".\McAfeeUninstall.zip"
$tempPath = "C:\Temp\McAfeeUninstall"
$mcprPath = "$tempPath\mccleanup.exe"
$logFile = "$tempPath\mccleanup.txt"
$finalLogDir = "C:\ProgramData\WeKilledtheMcAfeeVirus"
$finalLogFile = "$finalLogDir\mccleanup.txt"
$mcAfeeRegKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\McAfee.wps"
$mcAfeeMainKey = "HKLM:\SOFTWARE\McAfee"
$startMenuPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\McAfee"

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

$programArg = "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdiver,HW,MAS,MAT,MBK,MCPR,McProxy,McSvcHost,VUL,MHN,MNA,MOBK,MPFP,MPFPCU,MPS,SHRED,MPSCU,MQC,MQCCU,MSAD,MSHR,MSK,MSKCU,MWL,NMC,RedirSvc,VS,REMEDIATION,MSC,YAP,TRUEKEY,LAM,PCB,Symlink,SafeConnect,MGS,WMIRemover,RESIDUE -v -s"
Start-Process -FilePath $mcprPath -ArgumentList $programArg -Wait -NoNewWindow

if (Test-Path $mcAfeeRegKey) { Remove-Item -Path $mcAfeeRegKey -Force -ErrorAction SilentlyContinue }
if (Test-Path $mcAfeeMainKey) { Remove-Item -Path $mcAfeeMainKey -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path $startMenuPath) { Remove-Item -Path $startMenuPath -Recurse -Force }

if (-Not (Test-Path $finalLogDir)) { New-Item -ItemType Directory -Path $finalLogDir -Force }
if (Test-Path $logFile) { Move-Item -Path $logFile -Destination $finalLogFile -Force }

if (Test-Path $finalLogFile) { Exit 0 } else { Exit 1 }
