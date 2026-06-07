$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$functionsDir = Join-Path $projectRoot "functions"
$logPath = Join-Path $functionsDir "emulator.log"
$errPath = Join-Path $functionsDir "emulator.err.log"

function Test-LocalPort {
    param(
        [string] $HostName,
        [int] $Port
    )

    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($HostName, $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne(500)) {
            return $false
        }
        $client.EndConnect($async)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

if (Test-LocalPort -HostName "127.0.0.1" -Port 5001) {
    Write-Output "Firebase Functions emulator is already running on 127.0.0.1:5001."
    exit 0
}

if (-not (Test-Path (Join-Path $functionsDir "package.json"))) {
    throw "functions/package.json was not found."
}

if (Test-Path $logPath) { Clear-Content $logPath }
if (Test-Path $errPath) { Clear-Content $errPath }

$command = "/c npm.cmd run serve > `"$logPath`" 2> `"$errPath`""
$process = Start-Process -FilePath "cmd.exe" -ArgumentList $command -WorkingDirectory $functionsDir -WindowStyle Hidden -PassThru
Write-Output "Started Firebase Functions emulator PID $($process.Id)."

$deadline = (Get-Date).AddSeconds(45)
while ((Get-Date) -lt $deadline) {
    if (Test-LocalPort -HostName "127.0.0.1" -Port 5001) {
        Write-Output "Firebase Functions emulator is ready on 127.0.0.1:5001."
        exit 0
    }
    Start-Sleep -Milliseconds 750
}

Write-Output "Firebase Functions emulator did not become ready in time."
Write-Output "Last emulator.log lines:"
if (Test-Path $logPath) { Get-Content $logPath -Tail 20 }
Write-Output "Last emulator.err.log lines:"
if (Test-Path $errPath) { Get-Content $errPath -Tail 20 }
exit 1
